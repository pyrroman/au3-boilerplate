#include <GUIConstantsEx.au3>
#include <IE.au3>

#include "GUIExtender.au3"

HotKeySet("^{F1}","_Action_Section_1")
HotKeySet("^{F2}","_Action_Section_2")

$hGUI = GUICreate("", 750, 770)
GUISetBkColor(0xC0C0C0)

_GUIExtender_Init($hGUI)

GUICtrlCreateLabel("Press Ctrl - F1 or Ctrl - F2 to toggle embedded objects", 10, 10, 730, 30)
GUICtrlSetFont(-1, 15)

_GUIExtender_Section_Start($hGUI, 40, 370)
_GUIExtender_Section_Action($hGUI, 1)

;~ Global $oIE_1 = _IECreateEmbedded()
;~ Global $hIE_1 = GUICtrlCreateObj($oIE_1, 10, 50, 730, 350)
;~ _IENavigate ($oIE_1, "http://www.autoitscript.com")
;~ _GUIExtender_Obj_Data($hIE_1, $oIE_1) ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< New function

_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Start($hGUI, 410, 170)

$tab = GUICtrlCreateTab(10, 410, 730, 150)
ConsoleWrite("Main = " & GUICtrlGetHandle($tab) & @CRLF)

$tab0 = GUICtrlCreateTabItem("tab 0")

$tab1 = GUICtrlCreateTabItem("tab 1")

GUICtrlCreateTabItem("")

_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Start($hGUI, 580, 200)

Global $oIE_2 = ObjCreate("Shell.Explorer.2")
Global $hIE_2 = GUICtrlCreateObj($oIE_2, 10, 570, 730, 180)
$oIE_2.navigate(@MyDocumentsDir)
_GUIExtender_Obj_Data($hIE_2, $oIE_2) ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< New function

_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Extend($hGUI, 1, False)
_GUIExtender_Section_Extend($hGUI, 3, False)

GUISetState()

While 1
    $aMsg = GUIGetMsg(1)
    Switch $aMsg[0]
        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch
    _GUIExtender_Action($aMsg[1], $aMsg[0])
WEnd

Func _Action_Section_1()
    _GUIExtender_Section_Extend($hGUI, 1, Not(_GUIExtender_Section_State($hGUI, 1)))
EndFunc

Func _Action_Section_2()
    _GUIExtender_Section_Extend($hGUI, 3, Not(_GUIExtender_Section_State($hGUI, 3)))
EndFunc
