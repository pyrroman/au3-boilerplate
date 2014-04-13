#include-once
#include <SQLite.au3>

; #FUNCTION# ====================================================================================================================
; Name ..........: _SQLite_Key
; Description ...:
; Syntax ........: _SQLite_Key($hDB, $sKey)
; Parameters ....: $hDB                 - A handle to a DB.
;                  $sKey                - An old key to the DB (if already encrypted) or a new key (if still in plain text)
; Return values .: Success - 1
;                  Failure - 0 + sets the @error flag to a non-zero value + closes the DB
; Author ........: rindeal <dev.rindeal at outlook.com>
; Modified ......:
; Version .......: 2014-03-11
; Requirements ..: sqlite3.dll with encryption
; Performance ...:
; Remarks .......:
; Related .......: _SQLite_Rekey
; Link ..........: https://github.com/rindeal/wxSQLite3-VS
; Example .......: No
; ===============================================================================================================================
Func _SQLite_Key($hDB, $sKey)
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $tSQL8 = __SQLite_StringToUtf8Struct($Key)
	Local $avRval = DllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_key", _
			"ptr", $hDB, _
			"ptr", DllStructGetPtr($tSQL8), _
			"int", StringLen($Key))
	If @error Then Return SetError(1, @error, 0)
	If $avRval[0] <> $SQLITE_OK Then
		__SQLite_ReportError($avRval[2], "_SQLite_Key")
		_SQLite_Close($avRval[2])
		Return SetError(2, $avRval[0], 0)
	EndIf
	Return SetError(0, 0, 1)
EndFunc   ;==>_SQLite_Key

; #FUNCTION# ====================================================================================================================
; Name ..........: _SQLite_Rekey
; Description ...:
; Syntax ........: _SQLite_Rekey($hDB[, $sNewKey = ""])
; Parameters ....: $hDB                 - A handle to a DB.
;                  $sNewKey             - [optional] A new key to the DB. If empty then the DB will be decrypted.
; Return values .: Success - 1
;                  Failure - 0 and sets the @error flag to a non-zero value.
; Author ........: rindeal <dev.rindeal at outlook.com>
; Modified ......:
; Version .......: 2014-03-11
; Requirements ..: sqlite3.dll with encryption
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........: https://github.com/rindeal/wxSQLite3-VS
; Example .......: No
; ===============================================================================================================================
Func _SQLite_Rekey($hDB, $sNewKey = "")
	If __SQLite_hChk($hDB, 2) Then Return SetError(@error, 0, $SQLITE_MISUSE)
	Local $tSQL8 = __SQLite_StringToUtf8Struct($NewKey)
	Local $avRval = DllCall($g_hDll_SQLite, "int:cdecl", "sqlite3_rekey", _
			"ptr", $hDB, _
			"ptr", DllStructGetPtr($tSQL8), _
			"int", StringLen($NewKey))
	If @error Then Return SetError(1, @error, 0)
	If $avRval[0] <> $SQLITE_OK Then
		__SQLite_ReportError($avRval[2], "_SQLite_Rekey")
		Return SetError(2, $avRval[0], 0)
	EndIf
	Return SetError(0, 0, 1)
EndFunc   ;==>_SQLite_Rekey

; #FUNCTION# ====================================================================================================================
; Name ..........: _SQLite_TestKey
; Description ...: Tests if the provided key successfully opens the provided DB.
; Syntax ........: _SQLite_TestKey($hDB, $sKey)
; Parameters ....: $hDB                 - A handle value.
;                  $sKey                - A string value.
; Return values .: Success - 1 and the DB is unlocked
;                  Failure - 0 and sets the @error flag to a non-zero value.
; Author ........: rindeal <dev.rindeal at outlook.com>
; Modified ......:
; Version .......: 2014-03-11
; Requirements ..: sqlite3.dll with encryption
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........: http://sqlcipher.net/sqlcipher-api/#key
; Example .......: No
; ===============================================================================================================================
Func _SQLite_TestKey($hDB, $sKey)
	_SQLite_Key($hDB, $sKey)
	If @error Then Return SetError(1, @error, 0)
	Return (_SQLite_Exec($hDB, "SELECT * FROM sqlite_master LIMIT 1;") == $SQLITE_OK ? SetError(0, 0, 1) : SetError(2, @error, 0))
EndFunc   ;==>_SQLite_TestKey

Func _SQLite_BatchEscapeNames(ByRef $asNames)
	Local $sReturn

	For $i = 0 To UBound($asNames) - 1
		$asNames[$i] = '"' & StringReplace($asNames[$i], '"', '""') & '"'
		$sReturn &= $asNames[$i] & ($i = UBound($asNames) - 1 ? "" : ",")
	Next

	Return $sReturn
EndFunc   ;==>_SQLite_BatchEscapeNames

Func _SQLite_BatchEscapeValues(ByRef $avValues)
	Local $sReturn
	Local Const $iMax = UBound($avValues) - 1

	For $i = 0 To $iMax
		$avValues[$i] = (IsString($avValues[$i]) ? _SQLite_FastEscape($avValues[$i]) : $avValues[$i])
		$sReturn &= $avValues[$i] & ($i == $iMax ? "" : ",")
	Next

	Return $sReturn
EndFunc   ;==>_SQLite_BatchEscapeValues

Func _SQLite_BuildUpdateParams(ByRef $aColumns, ByRef $aValues)
	Local $sColumns = __SQLite_BatchEscapeNames($aColumns), $sValues = __SQLite_BatchEscapeValues($aValues)
	Local $sUpdateSt

	For $i = 0 To UBound($aColumns) - 1
		If $i = $iKey And UBound($aColumns) > 1 Then ContinueLoop
		$sUpdateSt &= $aColumns[$i] & "=" & $aValues[$i] & ($i = UBound($aColumns) - 1 ? "" : ",")
	Next

	Return $sUpdateSt
EndFunc   ;==>_SQLite_BuildUpdateParams
