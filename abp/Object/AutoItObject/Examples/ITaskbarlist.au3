#include"../AutoItObject.au3"
_AutoItObject_StartUp()

Global $oError = ObjEvent("AutoIt.Error", "_ErrFunc")
Func _ErrFunc()
	ConsoleWrite("! COM Error !  Number: 0x" & Hex($oError.number, 8) & "   ScriptLine: " & $oError.scriptline & " - " & $oError.windescription & @CRLF)
	Return
EndFunc   ;==>_ErrFunc


;~ Global $CLSID_TaskBarlist = _AutoItObject_CLSIDFromString("{56FDF344-FD6D-11D0-958A-006097C9A090}")
;~ Global $IID_ITaskbarList = _AutoItObject_CLSIDFromString("{56FDF342-FD6D-11d0-958A-006097C9A090}")

$GUI = GUICreate("")
$label = GUICtrlCreateLabel("", 10, 10, 380, 100)
GUISetState()


;~ Global $pList
;~ _AutoItObject_CoCreateInstance(DllStructGetPtr($CLSID_TaskBarlist), 0, 1, DllStructGetPtr($IID_ITaskbarList), $pList)

Local $tagInterface = "QueryInterface long(ptr;ptr;ptr);" & _
        "AddRef ulong();" & _
        "Release ulong();" & _
        "HrInit long();" & _
        "AddTab long(hwnd);" & _
        "DeleteTab long(hwnd);" & _
        "ActivateTab long(hwnd);" & _
        "SetActiveAlt long(hwnd);"

;~ $oList = _AutoItObject_WrapperCreate($pList, $tagInterface)
$oList = _AutoItObject_ObjCreate("{56FDF344-FD6D-11D0-958A-006097C9A090}", "{56FDF342-FD6D-11d0-958A-006097C9A090}", $tagInterface)
MsgBox(0, 'Original Pointer', Ptr($oList.__ptr__)); & @CRLF & $pList)

$oList.HrInit()

GUICtrlSetData($label, "$oList.DeleteTab")
$oList.DeleteTab(Number($GUI))
Sleep(1000)
GUICtrlSetData($label, "$oList.AddTab")
$oList.AddTab(Number($GUI))
Sleep(1000)
GUICtrlSetData($label, "$oList.ActivateTab")
$oList.ActivateTab(Number($GUI))
Sleep(1000)

GUICtrlSetData($label, "delete $oList")
$oList = 0

MsgBox(0, '', "now usage without parameters")


;~ Global $pList
;~ _AutoItObject_CoCreateInstance(DllStructGetPtr($CLSID_TaskBarlist), 0, 1, DllStructGetPtr($IID_ITaskbarList), $pList)

Local $tagInterface = "QueryInterface;" & _
        "AddRef;" & _
        "Release;" & _
        "HrInit;" & _
        "AddTab;" & _
        "DeleteTab;" & _
        "ActivateTab;" & _
        "SetActiveAlt;"

;~ $oList = _AutoItObject_WrapperCreate($pList, $tagInterface)
$oList = _AutoItObject_ObjCreate("{56FDF344-FD6D-11D0-958A-006097C9A090}", "{56FDF342-FD6D-11d0-958A-006097C9A090}", $tagInterface)

MsgBox(0, 'Original pointer', Ptr($oList.__ptr__)); & @CRLF & $pList)

$oList.HrInit('long')

GUICtrlSetData($label, "$oList.DeleteTab")
$oList.DeleteTab('long', 'hwnd', Number($GUI))
Sleep(1000)
GUICtrlSetData($label, "$oList.AddTab")
$oList.AddTab('long', 'hwnd', Number($GUI))
Sleep(1000)
GUICtrlSetData($label, "$oList.ActivateTab")
$oList.ActivateTab('long', 'hwnd', Number($GUI))
Sleep(1000)

GUICtrlSetData($label, "delete $oList")
$oList = 0
