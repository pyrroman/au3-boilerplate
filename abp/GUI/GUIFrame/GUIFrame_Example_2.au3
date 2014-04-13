#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include "GUIFrame.au3"

Global $iSep_Pos

$hGUI = GUICreate("GUI_Frame Example 2", 500, 500, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_MAXIMIZEBOX, $WS_SIZEBOX))
GUISetState()

; Register WM_SIZE to simulate the script requiring it
GUIRegisterMsg($WM_SIZE, "_WM_SIZE")

; Create a 1st level frame
$iFrame_A = _GUIFrame_Create($hGUI)
_GUIFrame_SetMin($iFrame_A, 50, 100)

_GUIFrame_Switch($iFrame_A, 2)
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_A, 2))
GUICtrlCreateLabel("", 5, 5, $aWinSize[0] - 10, $aWinSize[1] - 10)
GUICtrlSetBkColor(-1, 0xFF0000)
GUICtrlSetState(-1, $GUI_DISABLE)
$hButton_1 = GUICtrlCreateButton("Sep Pos", 10, 10, 50, 30)

; Create a 2nd level frame
$iFrame_B = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_A, 1), 1)
GUISetBkColor(0x00FF00, _GUIFrame_GetHandle($iFrame_B, 1))
_GUIFrame_SetMin($iFrame_B, 100, 100)

_GUIFrame_Switch($iFrame_B, 1)
$hButton_2 = GUICtrlCreateButton("Pos Sep", 10, 10, 50, 30)

; Create a 3rd level frame
$iFrame_C = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_B, 2))
_GUIFrame_Switch($iFrame_C, 2)
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_C, 2))
GUICtrlCreateLabel("", 5, 5, $aWinSize[0] - 10, $aWinSize[1] - 10)
GUICtrlSetBkColor(-1, 0xD0D000)

; Create a 4th level frame
$iFrame_D = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_C, 1), 1)
_GUIFrame_Switch($iFrame_D, 1)
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_D, 1))
GUICtrlCreateLabel("", 5, 5, $aWinSize[0] - 10, $aWinSize[1] - 10)
GUICtrlSetBkColor(-1, 0x00FFFF)
_GUIFrame_Switch($iFrame_D, 2)
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_D, 2))
GUICtrlCreateLabel("", 5, 5, $aWinSize[0] - 10, $aWinSize[1] - 10)
GUICtrlSetBkColor(-1, 0xFF00FF)

; Set resizing flag for all created frames
_GUIFrame_ResizeSet(0)

; Create a non-resizable 2nd level frame
$iFrame_E = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_B, 1), 0, 0, 5, 5, 55, 200, 100)
_GUIFrame_Switch($iFrame_E, 1)
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_E, 1))
GUICtrlCreateLabel("", 5, 5, $aWinSize[0] - 10, $aWinSize[1] - 10)
GUICtrlSetBkColor(-1, 0xFF8000)
_GUIFrame_Switch($iFrame_E, 2)
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_E, 2))
GUICtrlCreateLabel("", 5, 5, $aWinSize[0] - 10, $aWinSize[1] - 10)
GUICtrlSetBkColor(-1, 0xD0C0D0)

; DO NOT Register the $WM_SIZE handler to permit resizing as the message is already registered
;_GUIFrame_ResizeReg()

While 1

	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			; The UDF does all the tidying up as you exit
			Exit
		Case $hButton_1
			_GUIFrame_SetSepPos($iFrame_A, 300)
			$iSep_Pos = _GUIFrame_GetSepPos($iFrame_A)
			GUICtrlSetData($hButton_1, $iSep_Pos)
			Sleep(1000)
			GUICtrlSetData($hButton_1, "Sep Pos")
		Case $hButton_2
			$iRet = _GUIFrame_SetSepPos($iFrame_B, 310)
			$iSep_Pos = _GUIFrame_GetSepPos($iFrame_B)
			GUICtrlSetData($hButton_2, $iSep_Pos)
			Sleep(1000)
			GUICtrlSetData($hButton_2, "Sep Pos")
	EndSwitch

WEnd

; This is the already registered WM_SIZE handler
Func _WM_SIZE($hWnd, $iMsg, $wParam, $lParam)

    ; Just call the GUIFrame resizing function here - do NOT use the _GUIFrame_ResizeReg function in the script
    _GUIFrame_SIZE_Handler($hWnd, $iMsg, $wParam, $lParam)

    Return "GUI_RUNDEFMSG"

EndFunc
