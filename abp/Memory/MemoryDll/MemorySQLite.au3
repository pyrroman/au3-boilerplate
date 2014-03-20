; ============================================================================================================================
;  File     : MemorySQLite.au3
;  Purpose  : Modified Starndard SQLite UDF Loading SQLite3.dll In Memory Rather Than Temporary File
;  Author   : Fida Florian (piccaso), jchd, jpm
; ============================================================================================================================

#Include-once
#Include "Array.au3"
#Include "File.au3"
#Include "MemoryDll.au3"
Global Const $SQLITE_OK			= 0
Global Const $SQLITE_ERROR		= 1
Global Const $SQLITE_INTERNAL	= 2
Global Const $SQLITE_PERM		= 3
Global Const $SQLITE_ABORT		= 4
Global Const $SQLITE_BUSY		= 5
Global Const $SQLITE_LOCKED		= 6
Global Const $SQLITE_NOMEM		= 7
Global Const $SQLITE_READONLY	= 8
Global Const $SQLITE_INTERRUPT	= 9
Global Const $SQLITE_IOERR		= 10
Global Const $SQLITE_CORRUPT	= 11
Global Const $SQLITE_NOTFOUND	= 12
Global Const $SQLITE_FULL		= 13
Global Const $SQLITE_CANTOPEN	= 14
Global Const $SQLITE_PROTOCOL	= 15
Global Const $SQLITE_EMPTY		= 16
Global Const $SQLITE_SCHEMA		= 17
Global Const $SQLITE_TOOBIG		= 18
Global Const $SQLITE_CONSTRAINT	= 19
Global Const $SQLITE_MISMATCH	= 20
Global Const $SQLITE_MISUSE		= 21
Global Const $SQLITE_NOLFS		= 22
Global Const $SQLITE_AUTH		= 23
Global Const $SQLITE_ROW		= 100
Global Const $SQLITE_DONE		= 101
Global Const $SQLITE_OPEN_READONLY	= 0x01
Global Const $SQLITE_OPEN_READWRITE	= 0x02
Global Const $SQLITE_OPEN_CREATE	= 0x04
Global Const $SQLITE_ENCODING_UTF8		= 0
Global Const $SQLITE_ENCODING_UTF16		= 1
Global Const $SQLITE_ENCODING_UTF16be	= 2
Global $g_hDll_SQLite = 0
Global $g_hDB_SQLite = 0
Global $g_bUTF8ErrorMsg_SQLite = False
Global $__gbSafeModeState_SQLite = True
Global $__ghDBs_SQLite[1] 		 = ['']
Global $__ghQuerys_SQLite[1]	 = ['']
Global $__ghMsvcrtDll_SQLite 	 = 0
Func _SQLite_Startup($bUTF8ErrorMsg = False)
	If IsKeyword($bUTF8ErrorMsg) Then $bUTF8ErrorMsg = False
	$g_bUTF8ErrorMsg_SQLite = $bUTF8ErrorMsg
	Local $hDll = MemoryDllOpen(__SQLite_Inline_SQLite3Dll())
	If $hDll = -1 Then
		$g_hDll_SQLite = 0
		Return SetError(1, 0, "")
	Else
		$g_hDll_SQLite = $hDll
		Return "embedded"
	EndIf
EndFunc
Func _SQLite_Shutdown()
	If $g_hDll_SQLite > 0 Then MemoryDllClose($g_hDll_SQLite)
	$g_hDll_SQLite = 0
	If $__ghMsvcrtDll_SQLite > 0 Then DllClose($__ghMsvcrtDll_SQLite)
	$__ghMsvcrtDll_SQLite = 0
EndFunc
Func _SQLite_Open($sDatabase_Filename = Default, $iAccessMode = Default, $iEncoding = Default)
	If Not $g_hDll_SQLite Then Return SetError(1, $SQLITE_MISUSE, 0)
	If IsKeyword($sDatabase_Filename) Then $sDatabase_Filename = ":memory:"
	Local $tFilename = __SQLite_StringToUtf8Struct($sDatabase_Filename)
    If @error Then Return SetError(2, @error, 0)
	If IsKeyword($iAccessMode) Then $iAccessMode = BitOR($SQLITE_OPEN_READWRITE, $SQLITE_OPEN_CREATE)
	Local $OldBase = FileExists($sDatabase_Filename)
	If IsKeyword($iEncoding) Then
		$iEncoding = $SQLITE_ENCODING_UTF8
	EndIf
	Local $avRval = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_open_v2", "ptr", DllStructGetPtr($tFilename), _
					"long*", 0, _
					"int", $iAccessMode, _
					"ptr", 0)
	If @error Then 	Return SetError(1, @error, 0)
	If $avRval[0] <> $SQLITE_OK Then
		__SQLite_ReportError($avRval[2], "_SQLite_Open")
		_SQLite_Close($avRval[2])
		Return SetError(-1, $avRval[0], 0)
	EndIf
	$g_hDB_SQLite = $avRval[2]
	__SQLite_hAdd($__ghDBs_SQLite, $avRval[2])
	If Not $OldBase Then
		Local $encoding[3] = ["8", "16", "16be"]
		_SQLite_Exec($avRval[2], 'PRAGMA encoding="UTF-' & $Encoding[$iEncoding] & '";')
	EndIf
	Return SetExtended($avRval[0], $avRval[2])
EndFunc
Func _SQLite_GetTable($hDB, $sSQL, ByRef $aResult, ByRef $iRows, ByRef $iColumns, $iCharSize = -1)
	$aResult = ''
    If __SQLite_hChk($hDB, 3) Then Return SetError(@error, 0, $SQLITE_MISUSE)
    If $iCharSize = "" Or $iCharSize < 1 Or IsKeyword($iCharSize) Then $iCharSize = -1
    Local $tSQL8 = __SQLite_StringToUtf8Struct($sSQL)
    If @error Then Return SetError(4, @error, 0)

	Local $hQuery
	Local $r = _SQLite_Query($hDB, $sSQL, $hQuery)
	If @error Then Return SetError(@error, 0, $r)
	$r = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_get_table", _
            "ptr", $hDB, _
            "ptr", DllStructGetPtr($tSQL8), _
            "long*", 0, _
            "long*", 0, _
            "long*", 0, _
            "long*", 0)
	Local $err = @error
    If $err Then
		_SQLite_QueryFinalize($hQuery)
		Return SetError(1, $err, $SQLITE_MISUSE)
	EndIf
    __SQLite_szFree($r[6])

	MemoryDllCall($g_hDll_SQLite, "none:cdecl", "sqlite3_free_table", "ptr", $r[3])
	$err = @error
	If $err Then
		_SQLite_QueryFinalize($hQuery)
		Return SetError(2, $err, $SQLITE_MISUSE)
	EndIf
    If $r[0] <> $SQLITE_OK Then
        __SQLite_ReportError($hDB, "_SQLite_GetTable", $sSQL)
		_SQLite_QueryFinalize($hQuery)
        Return SetError(-1, 0, $r[0])
    EndIf

    $iRows = $r[4]
    Local $iRval_ColCnt = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_column_count", "ptr", $hQuery)
	$err = @error
    If $err Then
		_SQLite_QueryFinalize($hQuery)
		Return SetError(1, $err, $SQLITE_MISUSE)
	EndIf
    $iColumns = $iRval_ColCnt[0]
	If $iColumns = 0 Then
        $aResult = ''
		_SQLite_QueryFinalize($hQuery)
        Return SetError(-1, 0, $SQLITE_DONE)
    EndIf
	Local $aDataRow[$iColumns]
	$r = _SQLite_FetchNames($hQuery, $aDataRow)
	$err = @error
	If $err Then
		_SQLite_QueryFinalize($hQuery)
		Return SetError($err, 0, $r)
	EndIf
	Local $iCells = ($iRows + 1) * $iColumns
	Dim $aResult[$iCells + 1]
	$aResult[0] = $iCells
	For $k = 0 To $iColumns - 1
		If $iCharSize > 0 Then
			$aDataRow[$k] = StringLeft($aDataRow[$k], $iCharSize)
		EndIf
		$aResult[$k + 1] = $aDataRow[$k]
	Next
	If $iRows > 0 Then
		For $i = 1 To $iRows
			$r = _SQLite_FetchData($hQuery, $aDataRow)
			$err = @error
			If $err Then
				_SQLite_QueryFinalize($hQuery)
				Return SetError($err, 0, $r)
			EndIf
			For $j = 0 To $iColumns - 1
				If $iCharSize > 0 Then
					$aDataRow[$j] = StringLeft($aDataRow[$j], $iCharSize)
				EndIf
				$k += 1
				$aResult[$k] = $aDataRow[$j]
			Next
		Next
	EndIf
	Return(_SQLite_QueryFinalize($hQuery))
EndFunc
Func _SQLite_Exec($hDB, $sSQL, $sCallBack = "")
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	If $sCallBack <> "" Then
		Local $iRows, $iColumns
		Local $aResult = "SQLITE_CALLBACK:" & $sCallBack
		Local $iRval = _SQLite_GetTable2d($hDB, $sSQL, $aResult, $iRows, $iColumns)
		If @error Then Return SetError(3, @error, $iRval)
		Return $iRval
	EndIf
	Local $tSQL8 = __SQLite_StringToUtf8Struct($sSQL)
    If @error Then Return SetError(4, @error, 0)
	Local $avRval = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_exec", _
			"ptr", $hDB, _
			"ptr", DllStructGetPtr($tSQL8), _
			"ptr", 0, _
			"ptr", 0, _
			"long*", 0)
	If @error Then Return SetError(1, @error, $SQLITE_MISUSE)
	__SQLite_szFree($avRval[5])
	If $avRval[0] <> $SQLITE_OK Then
		__SQLite_ReportError($hDB, "_SQLite_Exec", $sSQL)
		SetError(-1)
	EndIf
	Return $avRval[0]
EndFunc
Func _SQLite_LibVersion()
	If $g_hDll_SQLite = 0 Then Return SetError(1, $SQLITE_MISUSE, 0)
	Local $r = MemoryDllCall($g_hDll_SQLite, "str:cdecl", "sqlite3_libversion")
	If @error Then Return SetError(1, @error, 0)
	Return $r[0]
EndFunc
Func _SQLite_LastInsertRowID($hDB = -1)
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, @extended, 0)
	Local $r = MemoryDllCall($g_hDll_SQLite, "long:cdecl", "sqlite3_last_insert_rowid", "ptr", $hDB)
	If @error Then Return SetError(1, @error, 0)
	Return $r[0]
EndFunc
Func _SQLite_Changes($hDB = -1)
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, @extended, 0)
	Local $r = MemoryDllCall($g_hDll_SQLite, "long:cdecl", "sqlite3_changes", "ptr", $hDB)
	If @error Then Return SetError(1, @error, 0)
	Return $r[0]
EndFunc
Func _SQLite_TotalChanges($hDB = -1)
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, @extended, 0)
	Local $r = MemoryDllCall($g_hDll_SQLite, "long:cdecl", "sqlite3_total_changes", "ptr", $hDB)
	If @error Then Return SetError(1, @error, 0)
	Return $r[0]
EndFunc
Func _SQLite_ErrCode($hDB = -1)
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $r = MemoryDllCall($g_hDll_SQLite, "long:cdecl", "sqlite3_errcode", "ptr", $hDB)
	If @error Then Return SetError(1, @error, $SQLITE_MISUSE)
	Return $r[0]
EndFunc
Func _SQLite_ErrMsg($hDB = -1)
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, @extended, "Library used incorrectly")
	Local $r = MemoryDllCall($g_hDll_SQLite, "wstr:cdecl", "sqlite3_errmsg16", "ptr", $hDB)
	If @error Then
		__SQLite_ReportError($hDB, "_SQLite_ErrMsg", Default, "Call Failed")
		Return SetError(1, @error, "Library used incorrectly")
	EndIf
	Return $r[0]
EndFunc
Func _SQLite_Display2DResult($aResult, $iCellWidth = 0, $bReturn = False)
	If Not IsArray($aResult) Or UBound($aResult, 0) <> 2 Or $iCellWidth < 0 Then Return SetError(1, 0, "")
	Local $aiCellWidth
	If $iCellWidth = 0 Or IsKeyword($iCellWidth) Then
		Local $iCellWidthMax
		Dim $aiCellWidth[UBound($aResult, 2) ]
		For $iRow = 0 To UBound($aResult, 1) - 1
			For $iCol = 0 To UBound($aResult, 2) - 1
				$iCellWidthMax = StringLen($aResult[$iRow][$iCol])
				If $iCellWidthMax > $aiCellWidth[$iCol] Then
					$aiCellWidth[$iCol] = $iCellWidthMax
				EndIf
			Next
		Next
	EndIf
	Local $sOut = "", $iCellWidthUsed
	For $iRow = 0 To UBound($aResult, 1) - 1
		For $iCol = 0 To UBound($aResult, 2) - 1
			If $iCellWidth = 0 Then
				$iCellWidthUsed = $aiCellWidth[$iCol]
			Else
				$iCellWidthUsed = $iCellWidth
			EndIf
			$sOut &= StringFormat(" %-" & $iCellWidthUsed & "." & $iCellWidthUsed & "s ", $aResult[$iRow][$iCol])
		Next
		$sOut &= @CRLF
		If Not $bReturn Then
			__SQLite_ConsoleWrite($sOut)
			$sOut = ""
		EndIf
	Next
	If $bReturn Then Return $sOut
EndFunc
Func _SQLite_GetTable2d($hDB, $sSQL, ByRef $aResult, ByRef $iRows, ByRef $iColumns, $iCharSize = -1, $fSwichDimensions = False)
	If __SQLite_hChk($hDB, 3) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	If $iCharSize = "" Or $iCharSize < 1 Or IsKeyword($iCharSize) Then $iCharSize = -1
	Local $sCallBack = "", $fCallBack = False
	If IsString($aResult) Then
		If StringLeft($aResult, 16) = "SQLITE_CALLBACK:" Then
			$sCallBack = StringTrimLeft($aResult, 16)
			$fCallBack = True
		EndIf
	EndIf
	$aResult = ''
	If IsKeyword($fSwichDimensions) Then $fSwichDimensions = False
	Local $hQuery
	Local $r = _SQLite_Query($hDB, $sSQL, $hQuery)
	If @error Then Return SetError(@error, 0, $r)
	If $r <> $SQLITE_OK Then
		__SQLite_ReportError($hDB, "_SQLite_GetTable2d", $sSQL)
		_SQLite_QueryFinalize($hQuery)
		Return SetError(-1, 0, $r)
	EndIf
	Local $iRval_ColCnt = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_column_count", "ptr", $hQuery)
	Local $err = @error
	If $err Then
		_SQLite_QueryFinalize($hQuery)
		Return SetError(1, $err, $SQLITE_MISUSE)
	EndIf
	$iColumns = $iRval_ColCnt[0]
	If $iColumns <= 0 Then
		_SQLite_QueryFinalize($hQuery)
		Return SetError(-1, 0, $SQLITE_DONE)
	EndIf
	$iRows = 0
	Local $iRval_Step
	While True
		$iRval_Step = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_step", "ptr", $hQuery)
		$err = @error
		If $err Then
			_SQLite_QueryFinalize($hQuery)
			Return SetError(1, $err, $SQLITE_MISUSE)
		EndIf
		Switch $iRval_Step[0]
			Case $SQLITE_ROW
				$iRows += 1
			Case $SQLITE_DONE
				ExitLoop
			Case Else
				_SQLite_QueryFinalize($hQuery)
				Return SetError(-1, $err, $iRval_Step[0])
		EndSwitch
	WEnd
	Local $ret = _SQLite_QueryReset($hQuery)
	$err = @error
	If $err Then
		_SQLite_QueryFinalize($hQuery)
		Return SetError($err, 0, $ret)
	EndIf
	Local $aDataRow[$iColumns]
	If Not $fCallBack Then
		$r = _SQLite_FetchNames($hQuery, $aDataRow)
		$err = @error
		If $err Then
			_SQLite_QueryFinalize($hQuery)
			Return SetError($err, 0, $r)
		EndIf
		If $fSwichDimensions Then
			Dim $aResult[$iColumns][$iRows + 1]
			For $i = 0 To $iColumns - 1
				If $iCharSize > 0 Then
					$aDataRow[$i] = StringLeft($aDataRow[$i], $iCharSize)
				EndIf
				$aResult[$i][0] = $aDataRow[$i]
			Next
		Else
			Dim $aResult[$iRows + 1][$iColumns]
			For $i = 0 To $iColumns - 1
				If $iCharSize > 0 Then
					$aDataRow[$i] = StringLeft($aDataRow[$i], $iCharSize)
				EndIf
				$aResult[0][$i] = $aDataRow[$i]
			Next
		EndIf
	Else
		Local $iCbRval
	EndIf
	If $iRows > 0 Then
		For $i = 1 To $iRows
			$r = _SQLite_FetchData($hQuery, $aDataRow)
			$err = @error
			If $err Then
				_SQLite_QueryFinalize($hQuery)
				Return SetError($err, 0, $r)
			EndIf
			If $fCallBack Then
				$iCbRval = Call($sCallBack, $aDataRow)
				If $iCbRval = $SQLITE_ABORT Or $iCbRval = $SQLITE_INTERRUPT Or @error Then
					$err = @error
					_SQLite_QueryFinalize($hQuery)
					Return SetError(4, $err, $iCbRval)
				EndIf
			Else
				For $j = 0 To $iColumns - 1
					If $iCharSize > 0 Then
						$aDataRow[$j] = StringLeft($aDataRow[$j], $iCharSize)
					EndIf
					If $fSwichDimensions Then
						$aResult[$j][$i] = $aDataRow[$j]
					Else
						$aResult[$i][$j] = $aDataRow[$j]
					EndIf
				Next
			EndIf
		Next
	EndIf
	Return(_SQLite_QueryFinalize($hQuery))
EndFunc
Func _SQLite_SetTimeout($hDB = -1, $iTimeout = 1000)
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	If IsKeyword($iTimeout) Then $iTimeout = 1000
	Local $avRval = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_busy_timeout", "ptr", $hDB, "int", $iTimeout)
	If @error Then Return SetError(1, @error, $SQLITE_MISUSE)
	If $avRval[0] <> $SQLITE_OK Then SetError(-1)
	Return $avRval[0]
EndFunc
Func _SQLite_Query($hDB, $sSQL, ByRef $hQuery)
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $iRval = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_prepare16_v2", _
			"ptr", $hDB, _
			"wstr", $sSQL, _
			"int", -1, _
			"long*", 0, _
			"long*", 0)
	If @error Then Return SetError(1, @error, $SQLITE_MISUSE)
	If $iRval[0] <> $SQLITE_OK Then
		__SQLite_ReportError($hDB, "_SQLite_Query", $sSQL)
		Return SetError(-1, 0, $iRval[0])
	EndIf
	$hQuery = $iRval[4]
	__SQLite_hAdd($__ghQuerys_SQLite, $iRval[4])
	Return $iRval[0]
EndFunc
Func _SQLite_FetchData($hQuery, ByRef $aRow, $fBinary = False, $fDoNotFinalize = False)
	Dim $aRow[1]
	If __SQLite_hChk($hQuery, 7, False) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $SQLITE_NULL = 5
	If IsKeyword($fBinary) Then $fBinary = False
    If IsKeyword($fDoNotFinalize) Then $fDoNotFinalize = False
	Local $iRval_Step = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_step", "ptr", $hQuery)
	If @error Then Return SetError(1, @error, $SQLITE_MISUSE)
	If $iRval_Step[0] <> $SQLITE_ROW Then
		If $fDoNotFinalize = False And $iRval_Step[0] = $SQLITE_DONE Then
			_SQLite_QueryFinalize($hQuery)
		EndIf
		Return SetError(-1, 0, $iRval_Step[0])
	EndIf
	Local $iRval_ColCnt = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_data_count", "ptr", $hQuery)
	If @error Then Return SetError(2, @error, $SQLITE_MISUSE)
    If $iRval_ColCnt[0] <= 0 Then Return SetError(-1, 0, $SQLITE_DONE)
	ReDim $aRow[$iRval_ColCnt[0]]
	For $i = 0 To $iRval_ColCnt[0] - 1
		If Not $fBinary Then
			Local $iRval_coltype = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_column_type", "ptr", $hQuery, "int", $i)
			If @error Then Return SetError(4, @error, $SQLITE_MISUSE)
			If $iRval_coltype[0] = $SQLITE_NULL Then
				$aRow[$i] = ""
				ContinueLoop
			EndIf
			Local $sRval = MemoryDllCall($g_hDll_SQLite, "wstr:cdecl", "sqlite3_column_text16", "ptr", $hQuery, "int", $i)
			If @error Then Return SetError(3, @error, $SQLITE_MISUSE)
			$aRow[$i] = $sRval[0]
		Else
			Local $vResult = MemoryDllCall($g_hDll_SQLite, "ptr:cdecl", "sqlite3_column_blob", "ptr", $hQuery, "int", $i)
			If @error Then Return SetError(6, @error, $SQLITE_MISUSE)
			Local $iColBytes = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_column_bytes", "ptr", $hQuery, "int", $i)
			If @error Then Return SetError(5, @error, $SQLITE_MISUSE)
			Local $vResultStruct = DllStructCreate("byte[" & $iColBytes[0] & "]", $vResult[0])
			$aRow[$i] = Binary(DllStructGetData($vResultStruct, 1))
		EndIf
	Next
	Return $SQLITE_OK
EndFunc
Func _SQLite_Close($hDB = -1)
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $iRval = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_close", "ptr", $hDB)
	If @error Then Return SetError(1, @error, $SQLITE_MISUSE)
	If $iRval[0] <> $SQLITE_OK Then
		__SQLite_ReportError($hDB, "_SQLite_Close")
		Return SetError(-1, 0, $iRval[0])
	EndIf
	$g_hDB_SQLite = 0
	__SQLite_hDel($__ghDBs_SQLite, $hDB)
	Return $iRval[0]
EndFunc
Func _SQLite_SafeMode($fSafeModeState)
	$__gbSafeModeState_SQLite = ($fSafeModeState = True)
	Return $SQLITE_OK
EndFunc
Func _SQLite_QueryFinalize($hQuery)
	If __SQLite_hChk($hQuery, 2, False) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $avRval = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_finalize", "ptr", $hQuery)
	If @error Then Return SetError(1, @error, $SQLITE_MISUSE)
	__SQLite_hDel($__ghQuerys_SQLite, $hQuery)
	If $avRval[0] <> $SQLITE_OK Then SetError(-1)
	Return $avRval[0]
EndFunc
Func _SQLite_QueryReset($hQuery)
	If __SQLite_hChk($hQuery, 2, False) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $avRval = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_reset", "ptr", $hQuery)
	If @error Then Return SetError(1, @error, $SQLITE_MISUSE)
	If $avRval[0] <> $SQLITE_OK Then SetError(-1)
	Return $avRval[0]
EndFunc
Func _SQLite_FetchNames($hQuery, ByRef $aNames)
	Dim $aNames[1]
	If __SQLite_hChk($hQuery, 3, False) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $avDataCnt = MemoryDllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_column_count", "ptr", $hQuery)
	If @error Then Return SetError(1, @error, $SQLITE_MISUSE)
    If $avDataCnt[0] <= 0 Then  Return SetError(-1, 0, $SQLITE_DONE)
	ReDim $aNames[$avDataCnt[0]]
	Local $avColName
	For $iCnt = 0 To $avDataCnt[0] - 1
		$avColName = MemoryDllCall($g_hDll_SQLite, "wstr:cdecl", "sqlite3_column_name16", "ptr", $hQuery, "int", $iCnt)
		If @error Then Return SetError(2, @error, $SQLITE_MISUSE)
		$aNames[$iCnt] = $avColName[0]
	Next
	Return $SQLITE_OK
EndFunc
Func _SQLite_QuerySingleRow($hDB, $sSQL, ByRef $aRow)
    $aRow = ''
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $hQuery
	Local $iRval = _SQLite_Query($hDB, $sSQL, $hQuery)
	If @error Then
		_SQLite_QueryFinalize($hQuery)
		Return SetError(1, 0, $iRval)
	Else
        $iRval = _SQLite_FetchData($hQuery, $aRow)
        If $iRval = $SQLITE_OK Then
			_SQLite_QueryFinalize($hQuery)
			If @error Then
				Return SetError(4, 0, $iRval)
			Else
				Return $SQLITE_OK
			EndIf
		Else
			_SQLite_QueryFinalize($hQuery)
            Return SetError(3, 0, $iRval)
		EndIf
	EndIf
EndFunc
Func _SQLite_SQLiteExe($sDatabaseFile, $sInput, ByRef $sOutput, $sSQLiteExeFilename = -1, $fDebug = False)
	If $g_hDll_SQLite = 0 Then Return SetError(1, 0, $SQLITE_MISUSE)
	If $sSQLiteExeFilename = -1 Or (IsKeyword($sSQLiteExeFilename) And $sSQLiteExeFilename = Default) Then
		$sSQLiteExeFilename = "SQLite3.exe"
		If Not FileExists($sSQLiteExeFilename) Then
			Local $aTemp = StringSplit(@AutoItExe, "\")
			$sSQLiteExeFilename = ""
			For $i = 1 to $aTemp[0]-1
				$sSQLiteExeFilename &= $aTemp[$i] & "\"
			Next
			$sSQLiteExeFilename &= "Extras\SQLite\SQLite3.exe"
		EndIf
	EndIf
	If Not FileExists($sDatabaseFile) Then
		Local $hNewFile = FileOpen($sDatabaseFile, 2 + 8)
		If $hNewFile = -1 Then
			Return SetError(1, 0, $SQLITE_CANTOPEN)
		EndIf
		FileClose($hNewFile)
	EndIf
	Local $sInputFile = _TempFile(), $sOutputFile = _TempFile(), $iRval = $SQLITE_OK
	Local $hInputFile = FileOpen($sInputFile, 2)
	If $hInputFile > -1 Then
		$sInput = ".output stdout" & @CRLF & $sInput
		FileWrite($hInputFile, $sInput)
		FileClose($hInputFile)
		Local $sCmd = @ComSpec & " /c " & FileGetShortName($sSQLiteExeFilename) & '  "' _
				 & FileGetShortName($sDatabaseFile) _
				 & '" > "' & FileGetShortName($sOutputFile) _
				 & '" < "' & FileGetShortName($sInputFile) & '"'
		Local $nErrorLevel = RunWait($sCmd, @WorkingDir, @SW_HIDE)
		If $fDebug = True Then
			Local $nErrorTemp = @error
			__SQLite_ConsoleWrite('@@ Debug(_SQLite_SQLiteExe) : $sCmd = ' & $sCmd & @CRLF & '>ErrorLevel: ' & $nErrorLevel & @CRLF)
			SetError($nErrorTemp)
		EndIf
		If @error = 1 Or $nErrorLevel = 1 Then
			$iRval = $SQLITE_MISUSE
		Else
			$sOutput = FileRead($sOutputFile, FileGetSize($sOutputFile))
			If StringInStr($sOutput, "SQL error:", 1) > 0 Or StringInStr($sOutput, "Incomplete SQL:", 1) > 0 Then $iRval = $SQLITE_ERROR
		EndIf
	Else
		$iRval = $SQLITE_CANTOPEN
	EndIf
	If FileExists($sInputFile) Then FileDelete($sInputFile)
	Switch $iRval
		Case $SQLITE_MISUSE
			SetError(2)
		Case $SQLITE_ERROR
			SetError(3)
		Case $SQLITE_CANTOPEN
			SetError(4)
	EndSwitch
	Return $iRval
EndFunc
Func _SQLite_Encode($vData)
	If IsNumber($vData) Then $vData = String($vData)
	If Not IsString($vData) And Not IsBinary($vData) Then Return SetError(1, 0, "")
	Local $vRval = "X'"
	If StringLower(StringLeft($vData, 2)) = "0x" And Not IsBinary($vData) Then

		For $iCnt = 1 To StringLen($vData)
			$vRval &= Hex(Asc(StringMid($vData, $iCnt, 1)), 2)
		Next
	Else

		If Not IsBinary($vData) Then $vData = StringToBinary($vData, 4)
		$vRval &= Hex($vData)
	EndIf
	$vRval &= "'"
	Return $vRval
EndFunc
Func _SQLite_Escape($sString, $iBuffSize = Default)
	If $g_hDll_SQLite = 0 Then Return SetError(1, $SQLITE_MISUSE, "")
	If IsNumber($sString) Then $sString = String($sString)
	Local $tSQL8 = __SQLite_StringToUtf8Struct($sString)
	If @error Then Return SetError(2, @error, 0)
	Local $aRval = MemoryDllCall($g_hDll_SQLite, "ptr:cdecl", "sqlite3_mprintf", "str", "'%q'", "ptr", DllStructGetPtr($tSQL8))
	If @error Then Return SetError(1, @error, "")
	If IsKeyword($iBuffSize) Or $iBuffSize < 1 Then $iBuffSize = -1
	Local $sResult = __SQLite_szStringRead($aRval[0], $iBuffSize)
	If @error Then Return SetError(3, @error, "")
	MemoryDllCall($g_hDll_SQLite, "none:cdecl", "sqlite3_free", "ptr", $aRval[0])
	Return $sResult
EndFunc
Func __SQLite_hChk(ByRef $hGeneric, $nError, $bDB = True)
	If $g_hDll_SQLite = 0 Then Return SetError(1, $SQLITE_MISUSE, $SQLITE_MISUSE)
	If $hGeneric = -1 Or $hGeneric = "" Or IsKeyword($hGeneric) Then
		If Not $bDB Then  Return SetError($nError, 0, $SQLITE_ERROR)
		$hGeneric = $g_hDB_SQLite
	EndIf
	If Not $__gbSafeModeState_SQLite Then Return $SQLITE_OK
	If $bDB Then
		If _ArraySearch($__ghDBs_SQLite, $hGeneric) > 0 Then Return $SQLITE_OK
	Else
		If _ArraySearch($__ghQuerys_SQLite, $hGeneric) > 0 Then Return $SQLITE_OK
	EndIf
	Return SetError($nError, 0, $SQLITE_ERROR)
EndFunc
Func __SQLite_hAdd(ByRef $ahLists, $hGeneric)
	_ArrayAdd($ahLists, $hGeneric)
EndFunc
Func __SQLite_hDel(ByRef $ahLists, $hGeneric)
	Local $iElement = _ArraySearch($ahLists, $hGeneric)
	If $iElement > 0 Then _ArrayDelete($ahLists, $iElement)
EndFunc
Func __SQLite_VersCmp($sFile, $sVersion)
	Local $avRval = DllCall($sFile, "int:cdecl", "sqlite3_libversion_number")
	If @error Then Return $SQLITE_CORRUPT
	If $avRval[0] >= $sVersion Then Return $SQLITE_OK
	Return $SQLITE_MISMATCH
EndFunc
Func __SQLite_hDbg()
	__SQLite_ConsoleWrite("State : " & $__gbSafeModeState_SQLite & @CRLF)
	Local $aTmp = $__ghDBs_SQLite
	For $i = 0 To UBound($aTmp) - 1
		__SQLite_ConsoleWrite("$__ghDBs_SQLite     -> [" & $i & "]" & $aTmp[$i] & @CRLF)
	Next
	$aTmp = $__ghQuerys_SQLite
	For $i = 0 To UBound($aTmp) - 1
		__SQLite_ConsoleWrite("$__ghQuerys_SQLite  -> [" & $i & "]" & $aTmp[$i] & @CRLF)
	Next
EndFunc
Func __SQLite_ReportError($hDB, $sFunction, $sQuery = Default, $sError = Default, $vReturnValue = Default, $curErr = @error, $curExt = @extended)
	If @Compiled Then Return SetError($curErr, $curExt)
	If IsKeyword($sError) Then $sError = _SQLite_ErrMsg($hDB)
	If IsKeyword($sQuery) Then $sQuery = ""
	Local $sOut = "!   SQLite.au3 Error" & @CRLF
	$sOut &= "--> Function: " & $sFunction & @CRLF
	If $sQuery <> "" Then $sOut &= "--> Query:    " & $sQuery & @CRLF
	$sOut &= "--> Error:    " & $sError & @CRLF
	__SQLite_ConsoleWrite($sOut & @CRLF)
	If Not IsKeyword($vReturnValue) Then Return SetError($curErr, $curExt, $vReturnValue)
	Return SetError($curErr, $curExt)
EndFunc
Func __SQLite_szStringRead($iszPtr, $iMaxLen = -1)
	If $iszPtr = 0 Then Return ""
	If $__ghMsvcrtDll_SQLite < 1 Then $__ghMsvcrtDll_SQLite = DllOpen("msvcrt.dll")
	Local $aStrLen = DllCall($__ghMsvcrtDll_SQLite, "ulong_ptr:cdecl", "strlen", "ptr", $iszPtr)
	If @error Then Return SetError(1, @error, "")
	Local $iLen = $aStrLen[0] + 1
	Local $vszString = DllStructCreate("byte[" & $iLen & "]", $iszPtr)
	If @error Then Return SetError(2, @error, "")
	Local $err = 0
	Local $rtn = __SQLite_Utf8StructToString($vszString)
	If @error Then
		$err = 3
	EndIf
	If $iMaxLen <= 0 Then
		Return SetError($err, @extended, $rtn)
	Else
		Return SetError($err, @extended, StringLeft($rtn, $iMaxLen))
	EndIf
EndFunc
Func __SQLite_szFree($Ptr, $curErr = @error)
	If $Ptr <> 0 Then MemoryDllCall($g_hDll_SQLite, "none:cdecl", "sqlite3_free", "ptr", $Ptr)
	SetError($curErr)
EndFunc
Func __SQLite_StringToUtf8Struct($sString)
	Local $aResult = DllCall("kernel32.dll", "int", "WideCharToMultiByte", "uint", 65001, "dword", 0, "wstr", $sString, "int", -1, _
								"ptr", 0, "int", 0, "ptr", 0, "ptr", 0)
	If @error Then Return SetError(1, @error, "")
	Local $tText = DllStructCreate("char[" & $aResult[0] & "]")
	$aResult = DllCall("Kernel32.dll", "int", "WideCharToMultiByte", "uint", 65001, "dword", 0, "wstr", $sString, "int", -1, _
							"ptr", DllStructGetPtr($tText), "int", $aResult[0], "ptr", 0, "ptr", 0)
	If @error Then Return SetError(2, @error, "")
	Return $tText
EndFunc
Func __SQLite_Utf8StructToString($tText)
	Local $aResult = DllCall("kernel32.dll", "int", "MultiByteToWideChar", "uint", 65001, "dword", 0, "ptr", DllStructGetPtr($tText), "int", -1, _
								"ptr", 0, "int", 0)
	If @error Then Return SetError(1, @error, "")
	Local $tWstr = DllStructCreate("wchar[" & $aResult[0] & "]")
	$aResult = DllCall("Kernel32.dll", "int", "MultiByteToWideChar", "uint", 65001, "dword", 0, "ptr", DllStructGetPtr($tText), "int", -1, _
						"wstr", DllStructGetPtr($tWstr), "int", $aResult[0])
	If @error Then Return SetError(2, @error, "")
	Return	$aResult[5]
EndFunc
Func __SQLite_ConsoleWrite($sText)
	If $g_bUTF8ErrorMsg_SQLite Then

		Local $tStr8 = __SQLite_StringToUtf8Struct($sText)
		ConsoleWrite(DllStructGetData($tStr8, 1))
	Else
		ConsoleWrite($sText)
	EndIf
EndFunc
