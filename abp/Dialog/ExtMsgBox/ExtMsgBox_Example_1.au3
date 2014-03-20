
; ExtMsgBox Example

#include <GUIConstantsEx.au3>
#include <Constants.au3>
#include <StaticConstants.au3>

#include "ExtMsgBox.au3"

; Set a flag to repeat Test 5
$fTest5_Again = True

$hTest_GUI = GUICreate("EMB Test",200, 470, 100, 100)
$hButton1 = GUICtrlCreateButton("Test 1", 20, 20, 60, 30)
$hButton2 = GUICtrlCreateButton("Test 2", 120, 20, 60, 30)
$hButton3 = GUICtrlCreateButton("Test 3", 20, 70, 60, 30)
$hButton4 = GUICtrlCreateButton("Test 4", 120, 70, 60, 30)
$hButton5 = GUICtrlCreateButton("Test 5", 20, 120, 60, 30)
$hButton6 = GUICtrlCreateButton("Test 6", 120, 120, 60, 30)
$hButton7 = GUICtrlCreateButton("Exit", 70, 430, 60, 30)

$sMsg  = "Move this window around the screen to see some of the child windows centre themselves upon it "
$sMsg &= "when they display." & @CRLF & @CRLF
$sMsg &= "If you place the window too close to the edge of the screen, the child windows will "
$sMsg &= "adjust their position automatically to prevent being partially hidden."
If @Compiled = 0 Then $sMsg &= @CRLF & @CRLF & "Look in the SciTE console to see the return values as buttons are pressed"

GUICtrlCreateLabel($sMsg, 10, 160, 180, 260, $SS_CENTER)
	GUICtrlSetFont(-1, 10)
GUISetState(@SW_SHOW, $hTest_GUI)

While 1

	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE, $hButton7

			_ExtMsgBoxSet(1)
			$nTest = _ExtMsgBox(32+8, "Yes|&No", "Query", "Are you sure?", 0, $hTest_GUI)
			_ExtMsgBoxSet(Default)
			ConsoleWrite("The 'Exit' EMB returned: " & $nTest & @CRLF)
			If $nTest = 1 Then Exit

		Case $hButton1

			; Set the centred value and font size, leaving colours unchanged
			_ExtMsgBoxSet(2, $SS_CENTER, -1, -1, 9)

			$sMsg =  "This is centred on 'EMB Test' with the AutoIt icon, 4 buttons, centred text,a Taskbar button and TOPMOST not set" & @CRLF & @CRLF
			$sMsg &= "The width is set to maximum by the requirement for 4 buttons and the text will wrap if required to fit in" & @CRLF & @CRLF
			$sMsg &= "Button 4 is set as default and will action on 'Enter' or 'Space'" & @CRLF & @CRLF
			$sMsg &= "It will not time out"
			$iRetValue = _ExtMsgBox (@AutoItExe, "1|2|3|&4", "Test 1", $sMsg, 20, $hTest_GUI)
			ConsoleWrite("Test 1 returned: " & $iRetValue & @CRLF)

			; Reset to default
			_ExtMsgBoxSet(Default)

		Case $hButton2

			; Hide the main GUI to centre the message box on screen
			GUISetState(@SW_HIDE, $hTest_GUI)

			; Change font and justification, leaving colours unchanged
			_ExtMsgBoxSet(1 + 4, $SS_LEFT, -1, -1, 12, "Arial")

			$sMsg = "As the 'EMB Test' dialog is hidden, this is centred on screen" & @CRLF & @CRLF
			$sMsg &= "It has:" & @CRLF
			$sMsg &= @TAB & "An Info icon," & @CRLF
			$sMsg &= @TAB & "1 offset button"  & @CRLF
			$sMsg &= @TAB & "Left justified text," & @CRLF
			$sMsg &= @TAB & "Default button text," & @CRLF
			$sMsg &= @TAB & "No Taskbar button and " & @CRLF
			$sMsg &= @TAB & "TOPMOST set" & @CRLF& @CRLF
			$sMsg &= "The width is set by the maximum line length" & @CRLF & @CRLF
			$sMsg &= "(which is less than max message box width)" & @CRLF & @CRLF
			$sMsg &= "It will time out in 20 seconds"

			; Use $MB_ constants and set timeout value
			$iRetValue = _ExtMsgBox ($EMB_ICONINFO, "Default Font", "Test 2", $sMsg, 20, $hTest_GUI)
			ConsoleWrite("Test 2 returned: " & $iRetValue & @CRLF)

			; Reset to default
			_ExtMsgBoxSet(Default)

			; Show the main GUI again
			GUISetState(@SW_SHOW, $hTest_GUI)
			WinSetOnTop($hTest_GUI, "", 1)
			WinSetOnTop($hTest_GUI, "", 0)

		Case $hButton3

			; Set the message box right justification, colours (yellow text on blue background) and change font
			_ExtMsgBoxSet(1, 2, 0x004080, 0xFFFF00, 10, "Comic Sans MS")

			$sMsg  = "This is centred on 'EMB Test' with an Exclamation icon, 2 buttons, wrapped right justified coloured text, "
			$sMsg &= "coloured background, no Taskbar button and TOPMOST set" & @CRLF & @CRLF
			$sMsg &= "Note you can get && in button text" & @CRLF
			$sMsg &= "and neither button is set as default" & @CRLF & @CRLF
			$sMsg &= "It will not time out"

			; Use $MB_ constant
			$iRetValue = _ExtMsgBox ($EMB_ICONEXCLAM, "One Way|To && Fro", "Test 3", $sMsg, 0, $hTest_GUI)
			ConsoleWrite("Test 3 returned: " & $iRetValue & @CRLF)

			; Reset to default
			_ExtMsgBoxSet(Default)

		Case $hButton4

			; Centre the single button
			_ExtMsgBoxSet(1, 4, -1, -1, 11)

			$sMsg  = "No window handle was passed, so the message box is centred on screen" & @CRLF & @CRLF
			$sMsg &= "It has a Stop icon and 1 centred button, is left justified in a largish font, has no Taskbar button and has TOPMOST set" & @CRLF & @CRLF
			$sMsg &= "This are some very long lines, so the message box width is set to the default maximum and the text will be forced to wrap as it is much too long to fit" & @CRLF & @CRLF
			$sMsg &= "It will time out in 15 seconds" & @CRLF & @CRLF & @CRLF & @CRLF & @CRLF & @CRLF & @CRLF & @CRLF
			$sMsg &= "Note that the message box varies in depth automatically to display the lines needed, even if they are forced to wrap a number of times!"

			$iRetValue = _ExtMsgBox ($EMB_ICONSTOP, "OK", "Test 4", $sMsg, 15)
			ConsoleWrite("Test 4 returned: " & $iRetValue & @CRLF)

			; Reset to default
			_ExtMsgBoxSet(Default)

		Case $hButton5

			; Only run this if the flag is set
			If $fTest5_Again Then

				; Set default button font, "Not again" checkbox, no titlebar icon
				_ExtMsgBoxSet(4 + 16 + 32, 0, Default, Default, 14, "Consolas")

				$sMsg  = "This message box was passed screen coordinates rather than a window handle "
				$sMsg &= "so it is located at 200, 200." & @CRLF & @CRLF
				$sMsg &= "It has no icon on the titlebar, a Query icon, a Taskbar button, a ""Not again"" checkbox, has TOPMOST set and uses the default font for the controls with a user-set font for the text" & @CRLF & @CRLF
				$sMsg &= "It will not time out"

				$iRetValue = _ExtMsgBox ($EMB_ICONQUERY, $MB_OK, "Test 5", $sMsg, 0, 200, 200)
				ConsoleWrite("Test 5 returned: " & $iRetValue & @CRLF)

				; Clear the flag as the checkbox was checked
				If $iRetValue < 0 Then $fTest5_Again = False

				; Reset to default
				_ExtMsgBoxSet(Default)

			Else

				ConsoleWrite("Test 5 will not run again" & @CRLF)

			EndIf

		Case $hButton6

			; Set the message box right justification, not TOPMOST, disable closure, colours (orange text on green background) and change font
			_ExtMsgBoxSet(1 + 2 + 64, 0, 0x008000, 0xFF8000, 12, "MS Sans Serif")

			$sMsg  = "This message box was passed screen coordinates rather than a window handle "
			$sMsg &= "so it is located at 100, 500." & @CRLF & @CRLF
			$sMsg &= "It has a countdown, no GUI or TaskBar buttons, TOPMOST is not set and the text and background is coloured" & @CRLF & @CRLF
			$sMsg &= "It will time out in 20 seconds.  Note closure [X] and SysMenu Close are disabled"

			$iRetValue = _ExtMsgBox (128, " ", "Test 6", $sMsg, 20, 100, 500)
			ConsoleWrite(@error & @CRLF)
			ConsoleWrite("Test 6 returned: " & $iRetValue & @CRLF)

			; Reset to default
			_ExtMsgBoxSet(Default)

	EndSwitch

WEnd

