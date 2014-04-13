#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: WinCenter
; Description ...: Centers Window on Screen
; Syntax ........: WinCenter ( "title" [, "text"] )
; Parameters ....: "title"              - The title of the window to read.
;                  "text" 				- [optional] The text of the window to read.
; Return values .: Success - Returns handle to the window
;                  Failure - Returns 0
; Author ........: Jan Chren
; Modified ......: 16.9.2012
; Remarks .......:
; Related .......:
; Link ..........: http://www.autoitscript.com/wiki/Snippets_(_GUI_)#Center_Window_on_Screen_.7E_Authors_-_Valuater_.7E_cdkid
; Example .......: No
; ===============================================================================================================================
Func WinCenter($win, $txt)
	Local $size = WinGetClientSize($win, $txt)
	If @error Then Return SetError(1, 0, 0)
	Local $y = (@DesktopHeight / 2) - ($size[1] / 2)
	Local $x = (@DesktopWidth / 2) - ($size[0] / 2)
	Return WinMove($win, $txt, $x, $y)
EndFunc   ;==>WinCenter