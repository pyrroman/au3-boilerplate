#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_outfile=C:\Users\Brian\Desktop\example1.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include "ExpFrame.au3"

;Create GUI
$hGUI_1 = GUICreate("GUI Frames", 800, 600, 100, 100, $WS_OVERLAPPEDWINDOW)

;Create Frames
$iFrame_A = _GUIFrame_Create($hGUI_1)

;Set min sizes for the frames
_GUIFrame_SetMin($iFrame_A, 100, 100)

;Create Explorer Listviews
_GUIFrame_Switch($iFrame_A, 1)
$LocalList = _ExpFrame_Create(_GUIFrame_GetHandle($iFrame_A, 1), 'c:\')
_GUIFrame_Switch($iFrame_A, 2)
$LocalList2 = _ExpFrame_Create(_GUIFrame_GetHandle($iFrame_A, 2), 'C:\Windows')

;Register functions for Windows Message IDs needed.
GUIRegisterMsg($WM_SIZE, "_ExpFrame_WMSIZE_Handler")
GUIRegisterMsg($WM_NOTIFY, "_ExpFrame_WMNotify_Handler")
GUIRegisterMsg($WM_COMMAND, '_ExpFrame_WMCOMMAND_Handler')

; Set resizing flag for all created frames
_GUIFrame_ResizeSet(0)

GUISetState(@SW_SHOW, $hGUI_1)

While 1
	$nMsg = GUIGetMsg()
	_ExpFrame_GUIGetMsg($nMsg);<< Dont forget to pass msg to _ExpFrame_GUIGetMsg!!
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd
