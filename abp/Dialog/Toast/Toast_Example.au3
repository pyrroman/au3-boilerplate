
;Example Toast

#include "Toast.au3"

Local $sMsg, $hProgress, $aRet[2]

$sMsg  = "The message text goes in this area" & @CRLF & @CRLF
$sMsg &= "This Toast uses the System colours and font"

$aRet = _Toast_Show(0, "The Title text goes here", $sMsg, 5)
ConsoleWrite("Toast size: " & $aRet[0] & " x " & $aRet[1] & @CRLF)
_Toast_Hide()

$sMsg  = "This Toast uses colours and font defined in a _Toast_Set call." & @CRLF & @CRLF
$sMsg &= "Subsequent Toasts will use these values until they are reset by another _Toast_Set call" & @CRLF & @CRLF
$sMsg &= "You can also display a standard icon - or one from an exe as here" & @CRLF & @CRLF
$sMsg &= "The next Toast has a very small message to show the pre-set minimum size"

_Toast_Set(5, 0xFF00FF, 0xFFFF00, 0x0000FF, 0xFFFFFF, 10, "Arial")
$aRet = _Toast_Show(@AutoItExe, "User-defined Colours and Bold Header", $sMsg, 10)
ConsoleWrite("Toast size: " & $aRet[0] & " x " & $aRet[1] & @CRLF)
_Toast_Hide()

$aRet = _Toast_Show(0, "", "Tiny", 2)
ConsoleWrite("Toast size: " & $aRet[0] & " x " & $aRet[1] & @CRLF)
_Toast_Hide()

$sMsg  = "These lines are of medium length" & @CRLF & @CRLF
$sMsg &= "The width is set by the longest" & @CRLF & @CRLF
$sMsg &= "No wrapping occurs here" & @CRLF & @CRLF
$sMsg &= "Note increased font size"

_Toast_Set(-1, -1, -1, -1, -1, 15)
$aRet = _Toast_Show(0, "Mid Width", $sMsg, 5)
ConsoleWrite("Toast size: " & $aRet[0] & " x " & $aRet[1] & @CRLF)
_Toast_Hide()

$sMsg  = "This is a long message set to left justified and a much larger font using _Toast_Set" & @CRLF & @CRLF
$sMsg &= "The Toast is automatically set to the maximum preset width and the message text "
$sMsg &= "is wrapped as necessary to fit within the margins of the Toast" & @CRLF & @CRLF
$sMsg &= "The Toast colours and weight have been changed by another _Toast_Set call" & @CRLF & @CRLF
$sMsg &= "Note the closure [X] on the title bar.  This Toast will time out in 30 secs "
$sMsg &= "but clicking the [X] will resume the script immediately"

_Toast_Set(0, -1, 0xFFFF00, 0x00FF00, 0x000000, 15, "Courier New")
$aRet = _Toast_Show(64, "Max Width and Normal Header", $sMsg, -30)
ConsoleWrite("Toast size: " & $aRet[0] & " x " & $aRet[1] & @CRLF)
_Toast_Hide()

$sMsg  = "This line is very long to show that you can override the pre-set maximum width with the 'Raw' parameter. "
$sMsg &= "You have to add a few more parameters to the _Toast_Show call but that is a small price to pay"
$sMsg &= @CRLF & @CRLF & "However, the Toast will not display if it does not fit on the screen!"

_Toast_Set(5, 0xFF00FF, 0xFFFF00, 0x0000FF, 0xFFFFFF, 10, "Arial")
$aRet = _Toast_Show(0, "Unwrapped Toast", $sMsg, -20, True, True)
If IsArray($aRet) Then
	ConsoleWrite("Toast size: " & $aRet[0] & " x " & $aRet[1] & @CRLF)
	_Toast_Hide()
Else
	MsgBox(0, "Error", "Raw Toast too wide for your screen!")
EndIf


$sMsg  = "Note how Toasts adjust automatically in height to display all of the message "
$sMsg &= "regardless of whether there is a title bar to display, the font used, "
$sMsg &= "the number of lines or whether wrapping occurs" & @CRLF & @CRLF
$sMsg &= "This Toast will retract automatically when the next Toast is called "
$sMsg &= "or when the [X] is clicked"

$aRet = _Toast_Show(0, "", $sMsg, -10)
ConsoleWrite("Toast size: " & $aRet[0] & " x " & $aRet[1] & @CRLF)

$sMsg  = "This Toast has several blank lines inserted. "
$sMsg &= "This can be useful if you want to leave space to add other controls, "
$sMsg &= "such as a progress bar, to the Toast once it is displayed" & @CRLF & @CRLF & @CRLF & @CRLF
$sMsg &= "The Toast size is returned by the function so you can calculate "
$sMsg &= "where to place the other controls.  "
$sMsg &= "This example script writes the size in the SciTE console" & @CRLF & @CRLF
$sMsg &= "Note that Toast colours and font have been reset to Default"

_Toast_Set(Default)
$aRet = _Toast_Show(0, "Progress Bar", $sMsg, 0) ; No delay or progress bar will not display immediately
ConsoleWrite("Toast size: " & $aRet[0] & " x " & $aRet[1] & @CRLF)
$hProgress = GUICtrlCreateProgress(10, 65, $aRet[0] - 20, 20)
For $i = 1 To 100
	GUICtrlSetData($hProgress, $i)
	Sleep(50)
Next
Sleep(5000)
_Toast_Hide()

$sMsg  = "This Toast has the 'Wait' flag set to False. " & @CRLF & @CRLF
$sMsg &= "That means that the script will continue while the Toast is displayed as "
$sMsg &= "as you can see from this counter." & @CRLF & @CRLF
$sMsg &= "Clicking the [X] will retract the Toast immediately but it will "
$sMsg &= "automatically retract after 20 seconds in any event"

_Toast_Set(5, 0xFF00FF, 0xFFFF00, 0x0000FF, 0xFFFFFF, 10)
$aRet = _Toast_Show(32, "Script Continuing", $sMsg, -20, False) ; Delay can be set here because script continues
ConsoleWrite("Toast size: " & $aRet[0] & " x " & $aRet[1] & @CRLF)
$hLabel = GUICtrlCreateLabel("", 267, 98, 15, 15)
GUICtrlSetBkColor(-1, 0xFFFF00)
$iCount = 0
Do
	$iCount += 1
	GUICtrlSetData($hLabel, StringFormat("%2s", $iCount))
	Sleep(1000)
Until $iCount = 60 Or $hToast_Handle = 0 ; Toast will retract automatically before $iCount = 60

Exit

