#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _Memory_Reduce
; Description ...: Removes as many pages as possible from the working set of the specified process.
; Syntax ........: _Memory_Reduce([$i_PID = @AutoItPID])
; Parameters ....: $i_PID               - [optional] An integer value. Default is @AutoItPID.
; Return values .: 1 or ( 0 and @error )
; Author ........: Based on _WinAPI_EmptyWorkingSet by Yashied w/ proper access flags, then AutoIt community
; Remarks .......: http://msdn.microsoft.com/library/default.asp?url=/library/en-us/perfmon/base/emptyworkingset.asp
;									http://www.autoitscript.com/forum/topic/13399-reducememory-udf
; ===============================================================================================================================
Func _Process_Memory_Reduce($i_PID = @AutoItPID)
	If ProcessExists($i_PID) Then
		Local $ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $i_PID)
		If @error Then Return SetError(2, 0, 0)
		Local $ai_Return = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', $ai_Handle[0])
		DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $ai_Handle[0])
		If IsArray($ai_Return) Then Return $ai_Return[0]
	EndIf
	Return SetError(1, 0, 0)
EndFunc   ;==>_Memory_Reduce

; #FUNCTION# ====================================================================================================================
; Name ..........: _GetProcessMemoryUsage
; Description ...: Returns
; Syntax ........: _GetProcessMemoryUsage([$iPID = @AutoItPID])
; Parameters ....: $iPID                - [optional] An integer value. Default is @AutoItPID.
; Return values .: An integer value - number of kB of private RAM usgae
; ===============================================================================================================================
Func _Process_Memory_GetUsage($iPID = @AutoItPID)
	$aTmp = ProcessGetStats($iPID, 0)
	If IsArray($aTmp) Then
		Return SetError(0, 0, $aTmp[0])
	Else
		Return SetError(1, 0, 0)
	EndIf
EndFunc   ;==>_GetProcessMemoryUsage
