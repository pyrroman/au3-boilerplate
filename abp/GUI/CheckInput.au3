#include <GuiConstants.au3>

Global $MARk_1              = 0
Global $DEFAULTINPUTDATA_1      = "Click and type something here..."

Global $MARK_2              = 0
Global $DEFAULTINPUTDATA_2      = "Click here and type something..."

Global $MARK_3              = 0
Global $DEFAULTINPUTDATA_3      = "And here to..."

Global $NONEAACTIVECOLOR    = 0x989898


$GUI = GUICreate("Check Inputs Demo", 280, 150)
WinSetOnTop($GUI, "", 1)

$Input_1 = GUICtrlCreateInput("", 15, 20, 250, 20)
GUICtrlSetColor(-1, $NONEAACTIVECOLOR)

$Input_2 = GUICtrlCreateInput("", 15, 60, 250, 20)
GUICtrlSetColor(-1, $NONEAACTIVECOLOR)

$Input_3 = GUICtrlCreateInput("", 15, 100, 250, 20)
GUICtrlSetColor(-1, $NONEAACTIVECOLOR)

$ExitButton = GUICtrlCreateButton("Exit", 110, 125, 60, 20)
GUICtrlSetState(-1, $GUI_DEFBUTTON)

GUISetState()

ControlFocus($Gui, "", $ExitButton)

While 1
    _CheckInput($GUI, $Input_1, "Click and type something here...", $DEFAULTINPUTDATA_1, $MARK_1)
    _CheckInput($GUI, $Input_2, "Click here and type something...", $DEFAULTINPUTDATA_2, $MARK_2)
    _CheckInput($GUI, $Input_3, "And here to...", $DEFAULTINPUTDATA_3, $MARK_3)
    Switch GUIGetMsg()
        Case $ExitButton, -3
            Exit
        Case Else
            ;.....
    EndSwitch
WEnd

Func _CheckInput($hWnd, $ID, $InputDefText, ByRef $DefaultInputData, ByRef $Mark)
    If $Mark = 0 And $DefaultInputData = $InputDefText And _IsFocused($hWnd, $ID) Then
        $Mark = 1
        GUICtrlSetData($ID, "")
        GUICtrlSetColor($ID, 0x000000)
        $DefaultInputData = ""
        Sleep(20)
    ElseIf $Mark = 1 And $DefaultInputData = "" And GUICtrlRead($ID) = "" And Not _IsFocused($hWnd, $ID) Then
        $Mark = 0
        $DefaultInputData = $InputDefText
        GUICtrlSetData($ID, $DefaultInputData)
        GUICtrlSetColor($ID, $NONEAACTIVECOLOR)
        Sleep(20)
    EndIf
EndFunc

Func _IsFocused($hWnd, $nCID)
    Return ControlGetHandle($hWnd, '', $nCID) = ControlGetHandle($hWnd, '', ControlGetFocus($hWnd))
EndFunc