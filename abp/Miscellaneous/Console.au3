#include <WinAPI.au3>

Func _puts($sStringIn) ;returns boolean
	Local Const $ATTACH_PARENT_PROCESS = -1, $STD_INPUT_HANDLE = -10, $STD_OUTPUT_HANDLE = -11, $STD_ERROR_HANDLE = -12
	Local Static $hStdOut = DllCall("kernel32.dll", "HANDLE", "GetStdHandle", "DWORD", $STD_OUTPUT_HANDLE)[0], $fIsAttached

	$sStringIn=$sStringIn&@CRLF
	Local $stStr = DllStructCreate("BYTE wc[" & StringLen($sStringIn) & "]"), $iBytesWritten

	If $hStdOut = $INVALID_HANDLE_VALUE Then $hStdOut = DllCall("kernel32.dll", "HANDLE", "GetStdHandle", "DWORD", $STD_OUTPUT_HANDLE)[0]

	If Not $fIsAttached Then
		_WinAPI_AttachConsole($ATTACH_PARENT_PROCESS)
		$fIsAttached = True
	EndIf

	For $i = 1 To StringLen($sStringIn)
		DllStructSetData($stStr, "wc", Asc(StringMid($sStringIn, $i, 1)), $i)
	Next

	If Not _WinAPI_WriteFile($hStdOut, DllStructGetPtr($stStr), DllStructGetSize($stStr), $iBytesWritten) Or _
			$iBytesWritten <> DllStructGetSize($stStr) Then Return SetError(1)

	Return True
EndFunc   ;==>ConsoleOut
