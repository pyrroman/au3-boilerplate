
#include <GUIConstantsEx.au3>

#include "GUIExtender.au3"

$hGUI = GUICreate("Test", 400, 300)

_GUIExtender_Init($hGUI, 1)
_GUIExtender_Section_Start($hGUI, 0, 100)
_GUIExtender_Section_Action($hGUI, 1)
GUICtrlCreateLabel("", 0, 0, 100, 300)
GUICtrlSetBkColor(-1, 0xFFCCCC)
_GUIExtender_Section_End($hGUI)
_GUIExtender_Section_Start($hGUI, 100, 200)
$cButton_1 = GUICtrlCreateButton(">>", 110, 10, 20, 30)
$cButton_2 = GUICtrlCreateButton("<<", 260, 10, 20, 30)
_GUIExtender_Section_End($hGUI)
_GUIExtender_Section_Start($hGUI, 300, 100)
_GUIExtender_Section_Action($hGUI, 3)
GUICtrlCreateLabel("", 300, 0, 100, 300)
GUICtrlSetBkColor(-1, 0xCCCCFF)
_GUIExtender_Section_End($hGUI)

GUISetState()

While 1

	$aMsg = GUIGetMsg(1)
	Switch $aMsg[0]
		Case $GUI_EVENT_CLOSE
			Exit
		Case $cButton_1
			Switch _GUIExtender_Section_State($hGUI, 1)
				Case 0
					; Extend to the left - override default
					_GUIExtender_Section_Extend($hGUI, 1, True, 2)
					GUICtrlSetData($cButton_1, ">>")
				Case 1
					; Retract from the left - override default
					_GUIExtender_Section_Extend($hGUI, 1, False, 2)
					GUICtrlSetData($cButton_1, "<<")
			EndSwitch
		Case  $cButton_2
			Switch _GUIExtender_Section_State($hGUI, 3)
				Case 0
					; Extend to the right (default)
					_GUIExtender_Section_Extend($hGUI, 3)
					GUICtrlSetData($cButton_2, "<<")
				Case 1
					; Retract from the right (default
					_GUIExtender_Section_Extend($hGUI, 3, False)
					GUICtrlSetData($cButton_2, ">>")
			EndSwitch
	EndSwitch

WEnd

