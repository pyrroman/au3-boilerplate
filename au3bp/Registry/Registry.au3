#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _Reg_GetSID
; Description ...: Retrieves SID of a user from registry
; Syntax ........: _Reg_GetSID([$sProfileFolder = @UserProfileDir])
; Parameters ....: $sProfileFolder      - [optional] A string value. Default is @UserProfileDir.
; Return values .: On Success - A string containing the SID
;                  On Failure - An empty string and sets @error to a non-zero value
; Author ........: rindeal
; Remarks .......: http://support.microsoft.com/kb/154599
; ===============================================================================================================================
Func _Reg_GetSID($sProfileFolder = @UserProfileDir)
	Local $sMainKey = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList", $sSID, $sRegUserSID, $sRegVal
	For $i = 1 To 10000
		$sSID = RegEnumKey($sMainKey, $i)
		$sRegVal = RegRead($sMainKey & "\" & $sSID, "ProfileImagePath")
		If $sRegVal = $sProfileFolder Then
			$sRegUserSID = $sSID
			ExitLoop
		EndIf
	Next
	If $sRegUserSID = "" Then Return SetError(1, 0, "")
	Return $sRegUserSID
EndFunc   ;==>_Reg_GetSID