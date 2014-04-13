#include <GUIConstantsEx.au3>
#include "GUIScrollbars_Ex.au3"

; Create GUI 1
$hGUI_1 = GUICreate("BEFORE", 500, 400, 100, 100)

$hButton_1 = GUICtrlCreateButton("Press", 400, 300, 80, 30)

GUISetState()

; Generate scrollbars BEFORE controls
_GUIScrollbars_Generate($hGUI_1, 1000, 1000, 0, 0, True)

$hLabel_1 = GUICtrlCreateLabel("", 300, 200, 50, 50)
GUICtrlSetBkColor(-1, 0xCCCCFF)

; Create GUI 2
$hGUI_2 = GUICreate("AFTER", 500, 400, 700, 100)

$hLabel_2 = GUICtrlCreateLabel("", 200, 300, 50, 50)
GUICtrlSetBkColor(-1, 0xCCCCFF)

$hButton_2 = GUICtrlCreateButton("Press", 400, 300, 80, 30)

GUISetState()

; Generate scrollbars AFTER controls
_GUIScrollbars_Generate($hGUI_2, 700, 700)

While 1

	$aMsg = GUIGetMsg(1)
	Switch $aMsg[1]
		Case $hGUI_1
			Switch $aMsg[0]
				Case $GUI_EVENT_CLOSE
					Exit
				Case $hButton_1
					GUISwitch($hGUI_1)
					; Get corrected coords to position label over the placeholder at 300, 200
					$aPos = _GUIScrollbars_Locate_Ctrl($hGUI_1, 300, 200)
					$hNewLabel_1 = GUICtrlCreateLabel("",$aPos[0], $aPos[1], 50, 50)
					GUICtrlSetBkColor(-1, 0xCCFFCC)
					Sleep(1000)
					GUICtrlDelete($hNewLabel_1)
			EndSwitch
		Case $hGUI_2
			Switch $aMsg[0]
				Case $GUI_EVENT_CLOSE
					Exit
				Case $hButton_2
					GUISwitch($hGUI_2)
					; Get corrected coords to position label over the placeholder at 300, 200
					$aPos = _GUIScrollbars_Locate_Ctrl($hGUI_2, 200, 300)
					$hNewLabel_2 = GUICtrlCreateLabel("",$aPos[0], $aPos[1], 50, 50)
					GUICtrlSetBkColor(-1, 0xCCFFCC)
					Sleep(1000)
					GUICtrlDelete($hNewLabel_2)
			EndSwitch
	EndSwitch
WEnd



