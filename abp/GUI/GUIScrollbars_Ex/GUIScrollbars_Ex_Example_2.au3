#include <GUIConstantsEx.au3>
#include "GUIScrollbars_Ex.au3"

$fRest = False

; Create GUI with red background
$hGUI = GUICreate("Test", 500, 500)
GUISetBkColor(0xFF0000, $hGUI)

; Create a 1000x1000 green label
GUICtrlCreateLabel("", 0, 0, 1000, 1000)
GUICtrlSetBkColor(-1, 0x00FF00)

GUISetState()

; Generate scrollbars - Yes, this is all you need to do!!!!!!!
_GUIScrollbars_Generate($hGUI, 1000, 1000)

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GUI_EVENT_RESTORE
			_GUIScrollbars_Restore($hGUI)
		Case $GUI_EVENT_MINIMIZE
			_GUIScrollbars_Minimize($hGUI)
	EndSwitch

WEnd
