#include-once

Global Const $_TAB = '      '

; #FUNCTION# ====================================================================================================================
; Name ..........: _VarDump
; Description ...:
; Syntax ........: _VarDump(Byref $vVar[, $iLimit = 10[, $sIndent = '']])
; Parameters ....: $vVar                - [in/out] A variant value.
;                  $iLimit              - [optional] An integer value. Default is 10.
;                  $sIndent             - [optional] A string value. Default is ''.
; Return values .: Success - 1
;                  Failure - 0 and sets the @error flag to a non-zero value.
; Author ........: jchd
; Modified ......: rindeal
; Version .......: 2014-03-04
; Requirements ..:
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _VarDump(ByRef $vVar, $iLimit = 10, $sIndent = '')
	Local $ret, $len, $ptr, $iDescLen = 8, $iDescLenStruct = 11
	If $iLimit < 3 Then $iLimit = 0

	Select

		Case IsString($vVar)
			Return StringFormat("%-" & $iDescLen & "s (%d) %s", 'String', StringLen($vVar), __VarDumpStr($vVar))

		Case VarGetType($vVar) = "Double"
			Return StringFormat("%-" & $iDescLen & "s %.18f", 'Double', $vVar)

		Case IsInt($vVar)
			Return StringFormat("%-" & $iDescLen & "s (%d) %s (%X)", VarGetType($vVar), $vVar, "Hex", $vVar)

		Case IsArray($vVar)
			Local $iSubscripts = UBound($vVar, 0)
			Local $iCells = 1
			$ret = 'Array'
			$iSubscripts -= 1
			For $i = 0 To $iSubscripts
				$ret &= '[' & UBound($vVar, $i + 1) & ']'
				$iCells *= UBound($vVar, $i + 1)
			Next
			If $iCells = 0 Then
				Return $ret & $_TAB & '  (array is empty)'
			Else
				Return $ret & @CRLF & __VarDumpArray($vVar, $iLimit, $sIndent)
			EndIf

		Case IsBinary($vVar)
			$len = BinaryLen($vVar)
			Return StringFormat("%-" & $iDescLen & "s (%d) %s", 'Binary', $len, (($len <= 32) ? $vVar : (BinaryMid($vVar, 1, 16)) & ' ... ' & StringTrimLeft(BinaryMid($vVar, $len - 15, 16), 2)))

		Case IsBool($vVar)
			Return StringFormat("%-" & $iDescLen & "s (%s)", "Boolean", $vVar)

		Case IsKeyword($vVar)
			Return StringFormat("%-" & $iDescLen & "s (%s)", "Keyword", ($vVar == Null ? 'Null' : 'Default'))

		Case IsHWnd($vVar)
			Return StringFormat("%-" & $iDescLen & "s (%x) %s", "HWnd", $vVar, WinGetTitle($vVar) ? '[TITLE:"' & WinGetTitle($vVar) & '"]' : "")

		Case IsPtr($vVar)
			Return StringFormat("%-" & $iDescLen & "s (%x)", "Pointer", $vVar)

		Case IsObj($vVar)
			Return StringFormat("%-" & $iDescLen & "s (%s) %s", "Object", ObjName($vVar), ObjName($vVar, 3))

		Case IsFunc($vVar)
			Return StringFormat("%-" & $iDescLen & "s (%s)", VarGetType($vVar), FuncName($vVar))

		Case IsDllStruct($vVar)
			$len = DllStructGetSize($vVar)
			$ptr = DllStructGetPtr($vVar)
			$i = 1
			While 1
				$vTmp = DllStructGetData($vVar, $i)
				If @error Then ExitLoop
				$i += 1
			WEnd
			$ret = StringFormat("%-" & $iDescLen & "s[%d] (%d) @:%0" & BinaryLen($ptr) & "x\r\n", "Struct", $i - 1, $len, Hex($ptr))
			Local $nbElem = 1, $idx, $incr, $data, $indent = $sIndent & $_TAB, $oldvalue, $readvalue, $field, $elem
			While 1
				$data = DllStructGetData($vVar, $nbElem)
				If @error = 2 Then ExitLoop
				$idx = 1
				$incr = 0
				; determine max index of element
				While 1
					DllStructGetData($vVar, $nbElem, 2 * $idx)
					If @error = 3 Then ExitLoop
					$incr = $idx
					$idx *= 2
				WEnd
				; index is in [$idx, (2 * $idx) - 1]
				$idx += $incr
				Do
					DllStructGetData($vVar, $nbElem, $idx)
					If @error = 3 Then
						; approach is asymetric (upper bound is too big)
						$idx -= ($incr = 1) ? 1 : $incr / 2
					Else
						$idx += Int($incr / 2)
					EndIf
					$incr = Int($incr / 2)
				Until $incr = 0
				Local $sNew = $indent & " [" & $nbElem & "]" & " ", $iIndentSize = StringLen($sNew)
				$ret &= $sNew
;~ 				StringRegExp($ret,"(?si).*\n(.*)$",1)[0]
				Switch VarGetType($data)
					Case "Int32", "Int64"
						$data = DllStructGetData($vVar, $nbElem, 1) ; backup
						DllStructSetData($vVar, $nbElem, 0x7777666655554433, 1)
						$readvalue = DllStructGetData($vVar, $nbElem, 1)
						Switch $readvalue
							Case 0x7777666655554433
								$elem = "int64"
								; alias: uint64
								; alias: int_ptr(x64), long_ptr(x64), lresult(x64), lparam(x64)
								; alias: uint_ptr(x64), ulong_ptr(x64), dword_ptr(x64), wparam(x64)
							Case 0x55554433
								DllStructSetData($vVar, $nbElem, 0x88887777, 1)
								$readvalue = DllStructGetData($vVar, $nbElem, 1)
								$elem = ($readvalue > 0 ? "uint" : "int")
								; int aliases: long, bool, int_ptr(x86), long_ptr(x86), lresult(x86), lparam(x86);
								; uint aliases: ulong, dword, uint_ptr(x86), ulong_ptr(x86), dword_ptr(x86), wparam(x86)
							Case 0x4433
								DllStructSetData($vVar, $nbElem, 0x8888, 1)
								$readvalue = DllStructGetData($vVar, $nbElem, 1)
								$elem = ($readvalue > 0 ? "ushort" : "short")
								; ushort alias: word
							Case 0x33
								$elem = "byte"
								; alias: ubyte
						EndSwitch
						DllStructSetData($vVar, $nbElem, $data, 1) ; backup
						If $idx = 1 Then
							$ret &= StringFormat('%-' & $iDescLenStruct & 's %d\r\n', $elem, $data)
						Else
							$ret &= $elem & "[" & $idx & "]" & @CRLF
							For $i = 1 To $idx
								If $iLimit And $idx > $iLimit And $i = $iLimit Then
									$ret &= StringFormat("%-" & $iIndentSize & "s ... (+%d more)\r\n", "", $idx - $iLimit + 1)
									ExitLoop
								Else
									$ret &= StringFormat("%-" & $iIndentSize & "s [%d] %d\r\n", "", $i, DllStructGetData($vVar, $nbElem, $i))
								EndIf
							Next
						EndIf
					Case "String"
						$oldvalue = DllStructGetData($vVar, $nbElem, 1)
						DllStructSetData($vVar, $nbElem, ChrW(0x2573), 1)
						$readvalue = DllStructGetData($vVar, $nbElem, 1)
						DllStructSetData($vVar, $nbElem, $oldvalue, 1)
						$elem = ($readvalue = ChrW(0x2573) ? "wchar" : "char")
						If $idx > 1 Then $elem &= "[" & $idx & "]"
						$ret &= StringFormat("%-" & $iDescLenStruct & "s %s\r\n", $elem, __VarDumpStr($data))
					Case "Binary"
						Local $blen = BinaryLen($data)
						$ret &= StringFormat('%-' & $iDescLen & 's %s\r\n', _
								"byte" & ($idx > 1 ? "[" & $idx & "]" : ""), _
								(($blen <= 32) ? $data : BinaryMid($data, 1, 16) & ' ... ' & StringTrimLeft(BinaryMid($data, $blen - 15, 16), 2)))
					Case "Ptr"
						$elem = "ptr"
						; alias: hwnd, handle
						If $idx = 1 Then
							$ret &= StringFormat('%-' & $iDescLen & 's %s\r\n', $elem, $data)
						Else
							$ret &= $elem & "[" & $idx & "]" & @CRLF
							For $i = 1 To $idx
								$ret &= StringFormat('%-' & StringLen($indent & $elem) & 's [%d] %s\r\n', '', $i, DllStructGetData($vVar, $nbElem, $i))
							Next
						EndIf
					Case "Double"
						$oldvalue = DllStructGetData($vVar, $nbElem, 1)
						DllStructSetData($vVar, $nbElem, 10 ^ - 15, 1)
						$readvalue = DllStructGetData($vVar, $nbElem, 1)
						DllStructSetData($vVar, $nbElem, $oldvalue, 1)
						$elem = ($readvalue = 10 ^ - 15 ? "double" : "float")
						If $idx = 1 Then
							$ret &= StringFormat('%-' & $iDescLen & 's %s\r\n', $elem, $data & (IsInt($data) ? '.0' : ''))
						Else
							$ret &= $elem & "[" & $idx & "]" & @CRLF
							For $i = 1 To $idx
								$ret &= StringFormat('%-' & StringLen($indent & $elem) & 's [%d] %s\r\n', '', $i, DllStructGetData($vVar, $nbElem, $i) & (IsInt(DllStructGetData($vVar, $nbElem, $i)) ? '.0' : ''))
							Next
						EndIf
				EndSwitch
				$nbElem += 1
			WEnd
			Return StringTrimRight($ret, 2)

		Case Else
			Return StringFormat('%-' & $iDescLen & 's %s', VarGetType($vVar), $vVar)

	EndSelect
EndFunc   ;==>_VarDump

Func __VarDumpArray(ByRef $aArray, $iLimit, $sIndent = $_TAB)
	Local $sDump
	Local $sArrayFetch, $sArrayRead, $bDone
	Local $iSubscripts = UBound($aArray, 0)
	Local $aUBounds[$iSubscripts]
	Local $aCounts[$iSubscripts]
	$iSubscripts -= 1
	For $i = 0 To $iSubscripts
		$aUBounds[$i] = UBound($aArray, $i + 1) - 1
		$aCounts[$i] = 0
	Next
	$sIndent &= $_TAB
	While 1
		$bDone = True
		$sArrayFetch = ''
		For $i = 0 To $iSubscripts
			$sArrayFetch &= '[' & $aCounts[$i] & ']'
			If $aCounts[$i] < $aUBounds[$i] Then $bDone = False
		Next
		$sArrayRead = Execute('$aArray' & $sArrayFetch)
		If @error Then
			ExitLoop
		Else
			$sDump &= $sIndent & $sArrayFetch & ' => ' & _VarDump($sArrayRead, $iLimit, $sIndent)
			If Not $bDone Then
				$sDump &= @CRLF
			Else
				Return $sDump
			EndIf
		EndIf

		For $i = $iSubscripts To 0 Step -1
			$aCounts[$i] += 1
			If $aCounts[$i] > $aUBounds[$i] Then
				$aCounts[$i] = 0
			Else
				ExitLoop
			EndIf
		Next
	WEnd
EndFunc   ;==>__VarDumpArray

Func _VarDumpConsole($vVar, $sComment = Null)
	If $sComment Then ConsoleWrite("-> " & $sComment & @CRLF)
	ConsoleWrite(_VarDump($vVar) & @CRLF)
EndFunc   ;==>_VarDumpConsole

Func __VarDumpStr(ByRef $vVar)
	If Not IsString($vVar) Then Return
	Local $len = StringLen($vVar)
	$vVar = Execute("'" & StringRegExpReplace($vVar, "([\p{Cc}])", "<' & Hex(AscW('$1'), 2) & '>") & "'")
	Return "`" & (($len <= 64) ? $vVar : StringMid($vVar, 1, 32) & ' ... ' & StringTrimLeft(StringMid($vVar, $len - 31, 32), 2)) & "`"
EndFunc   ;==>__VarDumpStr
