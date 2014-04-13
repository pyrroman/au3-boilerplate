#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_outfile=example2.exe
#AutoIt3Wrapper_UseUpx=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include "ExpFrame.au3"

$hGUI_1 = GUICreate("GUI Frames", 600, 600, -1, -1, $WS_OVERLAPPEDWINDOW)

;create frames
$iFrame_Main = _GUIFrame_Create($hGUI_1, 1);split gui horizontally
$iFrame_Top = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_Main, 1));split top frame vertically
$iFrame_Mid_Bottom = _GUIFrame_Create(_GUIFrame_GetHandle($iFrame_Main, 2), 1);split bottom frame horizontally again

;set mins for frames
_GUIFrame_SetMin($iFrame_Main, 75, 75)
_GUIFrame_SetMin($iFrame_Top, 75, 75)
_GUIFrame_SetMin($iFrame_Mid_Bottom, 75, 75)

;Create Explorer Listviews
_GUIFrame_Switch($iFrame_Top, 1)
$LV1 = _ExpFrame_Create(_GUIFrame_GetHandle($iFrame_Top, 1))
_GUIFrame_Switch($iFrame_Top, 2)
$LV2 = _ExpFrame_Create(_GUIFrame_GetHandle($iFrame_Top, 2))
_GUIFrame_Switch($iFrame_Mid_Bottom, 1)
$LV3 = _ExpFrame_Create(_GUIFrame_GetHandle($iFrame_Mid_Bottom, 1))
_GUIFrame_Switch($iFrame_Mid_Bottom, 2)
$LV4 = _ExpFrame_Create(_GUIFrame_GetHandle($iFrame_Mid_Bottom, 2))

;Get handles to each listview. Needed for our rightclick menu
$hLV1 = GUICtrlGetHandle($LV1)
$hLV2 = GUICtrlGetHandle($LV2)
$hLV3 = GUICtrlGetHandle($LV3)
$hLV4 = GUICtrlGetHandle($LV4)

;Restore the column widths from previous use
_ExpFrame_RestoreColumns($LV1, 'LV1')
_ExpFrame_RestoreColumns($LV2, 'LV2')
_ExpFrame_RestoreColumns($LV3, 'LV3')
_ExpFrame_RestoreColumns($LV4, 'LV4')

;Register functions for Windows Message IDs needed
GUIRegisterMsg($WM_NOTIFY, "_WM_NOTIFY")
;Because this script does not need any WMSIZE msgs I will simply register the _ExpFrame_WMSIZE_Handler. GUIFrame_SIZE_Handler() is called from _ExpFrame_WMSIZE_Handler.
GUIRegisterMsg($WM_SIZE, "_ExpFrame_WMSIZE_Handler")
;Because this script does not need any WMCOMMAND msgs I will simply register the Handler
GUIRegisterMsg($WM_COMMAND, '_ExpFrame_WMCOMMAND_Handler')

; Set resizing flag for all created frames
_GUIFrame_ResizeSet(0)
GUISetState(@SW_SHOW, $hGUI_1)

Global $nMsg
While 1
	$nMsg = GUIGetMsg()
	_ExpFrame_GUIGetMsg($nMsg); << Dont forget to pass msg to _ExpFrame_GUIGetMsg!!
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_ExpFrame_SaveColumns($LV1, 'LV1')
			_ExpFrame_SaveColumns($LV2, 'LV2')
			_ExpFrame_SaveColumns($LV3, 'LV3')
			_ExpFrame_SaveColumns($LV4, 'LV4')
			Exit
	EndSwitch
WEnd

Func _WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)

	;Pass needed values to _ExpFrame_WMNotify_Handler
	_ExpFrame_WMNotify_Handler($hWnd, $iMsg, $iwParam, $ilParam)

	Local $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	Local $iCode = DllStructGetData($tNMHDR, "Code")

	Switch $iCode
		Case $NM_RCLICK
			;Get handle of ctrl that msg was sent from
			Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
			;Check if handle is any of our listviews
			Switch $hWndFrom
				Case $hLV1, $hLV2, $hLV3, $hLV4
					;Rightclick came from one of our listview so launch menu
					_RightClickMenu($hWndFrom)
			EndSwitch
	EndSwitch

	Return $GUI_RUNDEFMSG

EndFunc   ;==>_WM_NOTIFY

Func _RightClickMenu($hLV)

	;Create popup menu
	Local $hMenu = _GUICtrlMenu_CreatePopup(2)

	;Enumerate some values for menu item tracking
	Local Enum $iOption_1 = 1, $iOption_2, $iOption_3
	;Add menus
	_GUICtrlMenu_AddMenuItem($hMenu, "Menu Option 1", $iOption_1)
	_GUICtrlMenu_AddMenuItem($hMenu, "Menu Option 2", $iOption_2)
	_GUICtrlMenu_AddMenuItem($hMenu, "Menu Option 3", $iOption_3)

	; Check which item was selected
	Local $mitem = _GUICtrlMenu_TrackPopupMenu($hMenu, $hLV, -1, -1, 1, 1, 2)
	;Execute menu option
	Switch $mitem
		Case $iOption_1
			ConsoleWrite('Menu option 1 was selected' & @CRLF)
		Case $iOption_2
			ConsoleWrite('Menu Option 2 was selected' & @CRLF)
		Case $iOption_3
			ConsoleWrite('Menu Option 3 was selected' & @CRLF)
	EndSwitch

	;free menu resorces
	_GUICtrlMenu_DestroyMenu($hMenu)

EndFunc   ;==>_RightClickMenu