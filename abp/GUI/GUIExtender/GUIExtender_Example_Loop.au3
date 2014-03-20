#include <GUIConstantsEx.au3>

#include "GUIExtender.au3"

$hGUI_1 = GUICreate("Vertical", 300, 390, 100, 100)

_GUIExtender_Init($hGUI_1)

_GUIExtender_Section_Start($hGUI_1, 0, 60)
GUICtrlCreateGroup(" 1 - Static ", 10, 10, 280, 50)
_GUIExtender_Section_Action($hGUI_1, 2, "", "", 270, 40, 15, 15) ; Normal button
_GUIExtender_Section_End($hGUI_1)

_GUIExtender_Section_Start($hGUI_1, 60, 110)
GUICtrlCreateGroup(" 2 - Extendable ", 10, 70, 280, 100)
_GUIExtender_Section_End($hGUI_1)

_GUIExtender_Section_Start($hGUI_1, 170, 60)
GUICtrlCreateGroup(" 3 - Static", 10, 180, 280, 50)
_GUIExtender_Section_Action($hGUI_1, 4, "Close 4", "Open 4", 225, 195, 60, 20, 1) ; Push button
_GUIExtender_Section_End($hGUI_1)

_GUIExtender_Section_Start($hGUI_1, 230, 60)
GUICtrlCreateGroup(" 4 - Extendable ", 10, 240, 280, 50)
_GUIExtender_Section_End($hGUI_1)

_GUIExtender_Section_Start($hGUI_1, 290, 90)
GUICtrlCreateGroup(" 5 - Static", 10, 300, 280, 80)
_GUIExtender_Section_Action($hGUI_1, 0, "Close All", "Open All", 20, 340, 60, 20) ; Normal button
_GUIExtender_Section_End($hGUI_1)

GUICtrlCreateGroup("", -99, -99, 1, 1)

_GUIExtender_Section_Extend($hGUI_1, 4, False)

GUISetState()

$hGUI_2 = GUICreate("Horizontal", 500, 200, 500, 100)

_GUIExtender_Init($hGUI_2, 1)

_GUIExtender_Section_Start($hGUI_2, 0, 100)
GUICtrlCreateGroup(" 1 - Static ", 10, 10, 80, 180)
_GUIExtender_Section_Action($hGUI_2, 2, "", "", 70, 20, 15, 15)
_GUIExtender_Section_End($hGUI_2)

_GUIExtender_Section_Start($hGUI_2, 100, 100)
GUICtrlCreateGroup(" 2 - Extendable ", 110, 10, 80, 180)
_GUIExtender_Section_End($hGUI_2)

_GUIExtender_Section_Start($hGUI_2, 200, 100)
GUICtrlCreateGroup(" 3 - Static", 210, 10, 80, 180)
_GUIExtender_Section_Action($hGUI_2, 4, "Close 4", "Open 4", 220, 90, 60, 20, 1) ; Push button
_GUIExtender_Section_End($hGUI_2)

_GUIExtender_Section_Start($hGUI_2, 300, 100)
GUICtrlCreateGroup(" 4 - Extendable", 310, 10, 80, 180)
_GUIExtender_Section_End($hGUI_2)

_GUIExtender_Section_Start($hGUI_2, 400, 100)
GUICtrlCreateGroup(" 5 - Static", 410, 10, 80, 180)
_GUIExtender_Section_Action($hGUI_2, 0, "Close All", "Open All", 420, 160, 60, 20) ; Normal button
_GUIExtender_Section_End($hGUI_2)

GUICtrlCreateGroup("", -99, -99, 1, 1)

_GUIExtender_Section_Extend($hGUI_2, 2, False)

GUISetState()

While 1
	$aMsg = GUIGetMsg(1)
	Switch $aMsg[0]
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch

	Switch $aMsg[1]
		Case $hGUI_1, $hGUI_2
			_GUIExtender_Action($aMsg[1], $aMsg[0]) ; Check for click on Action control
	EndSwitch

WEnd