#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include "GUIFrame.au3"

Global $iSep_Pos

$hGUI = GUICreate("GUI_Frame Example 3", 500, 500, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_MAXIMIZEBOX, $WS_SIZEBOX))
GUISetState()

; Create a 1st level frame
$iFrame_A = _GUIFrame_Create($hGUI, 1)
_GUIFrame_SetMin($iFrame_A, 50, 125, True)	; This line sets the minima as absolute values <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;_GUIFrame_SetMin($iFrame_A, 50, 125)     	; This line adjusts the minima to equivalent percentages on resizing <<<<<<<<<<<<<<<<<<<<<

_GUIFrame_Switch($iFrame_A, 1)
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_A, 2))
GUICtrlCreateLabel("", 5, 5, $aWinSize[0] - 10, $aWinSize[1] - 10)
GUICtrlSetBkColor(-1, 0x00FF00)
GUICtrlCreateLabel("", 0, 0, 50, 50)
GUICtrlSetBkColor(-1, 0x0000FF)
GUICtrlSetResizing(-1, $GUI_DOCKSIZE)
GUICtrlSetState(-1, $GUI_DISABLE)

_GUIFrame_Switch($iFrame_A, 2)
$aWinSize = WinGetClientSize(_GUIFrame_GetHandle($iFrame_A, 2))
GUICtrlCreateLabel("", 5, 5, $aWinSize[0] - 10, $aWinSize[1] - 10)
GUICtrlSetBkColor(-1, 0xFF0000)
GUICtrlSetState(-1, $GUI_DISABLE)

; Set resizing flag for all created frames
_GUIFrame_ResizeSet(0, 2) ; Adjust the second parameter to change the resizing behaviour <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; Register the $WM_SIZE handler to permit resizing
_GUIFrame_ResizeReg()

While 1

	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			; The UDF does all the tidying up as you exit
			Exit
	EndSwitch

WEnd