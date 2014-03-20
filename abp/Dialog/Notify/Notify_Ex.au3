#include "Notify.au3"

; Press ESC to exit script
HotKeySet("{ESC}", "On_Exit")

Global $fNot_1_Vis = True, $iBegin = 0

Opt("TrayAutoPause", 0)

$sAutoIt_Path = StringRegExpReplace(@AutoItExe, "(^.*\\)(.*)", "\1")
ConsoleWrite($sAutoIt_Path & @CRLF)

; Register message for click event
_Notify_RegMsg()

; Set notification location
_Notify_Locate(0) ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; Show notifications
_Notify_Set(Default)
_Notify_Show(@AutoItExe, "Not Clickable with EXE", "Retracts after 20 secs", 20, 0)
_Notify_Set(0, 0xFF0000, 0xFFFF00, "Courier New");, True)
_Notify_Show(0, "Clickable", "Coloured - stays 40 secs if not clicked", 40)
_Notify_Set(Default)
_Notify_Show($sAutoIt_Path & "Examples\GUI\Torus.png", "Clickable with PNG", "Reset to default colours")
_Notify_Set(2, 0x0000FF, 0xCCCCFF, "Comic MS")
_Notify_Show(48, "Not Clickable", "With an icon - stays 30 secs", 30, 0)
_Notify_Set(0, Default, 0xCCFF00, "Arial", True)
; This one is clickable
$hNot_1 = _Notify_Show(0, "", "No title so the message can span both lines without problem if it is long enough to need it")
_Notify_Set(0, Default, 0xFF80FF, "MS Comic Sans", True)
; This one can only be retracted programatically 2 secs after the one above
$hNot_2 = _Notify_Show(0, "Programmed Retract", "This will retract 2 seconds after the 'No Title' one", 0, 0)

While 1
    Sleep(10)
	If Not WinExists($hNot_1) And $fNot_1_Vis = True Then
		$iBegin = TimerInit()
		$fNot_1_Vis = False
	EndIf
	If $iBegin And TimerDiff($iBegin) > 2000 And WinExists($hNot_2) Then
		_Notify_Hide($hNot_2)
		$iBegin = 0
	EndIf
WEnd

Func On_Exit()
    Exit
EndFunc