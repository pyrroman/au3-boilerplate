#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include <GuiButton.au3>
#include <GUIComboBox.au3>

#include "GUIExtender.au3"

$hGUI = GUICreate("Test", 300, 440)

_GUIExtender_Init($hGUI)

_GUIExtender_Section_Start($hGUI, 50, 60)
GUICtrlCreateGroup(" 1 - Static ", 10, 50, 280, 50)
_GUIExtender_Section_Action($hGUI, 2, "", "", 270, 80, 15, 15) ; Normal button
_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Start($hGUI, 110, 110)
GUICtrlCreateGroup(" 2 - Extendable ", 10, 120, 280, 100)
_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Start($hGUI, 220, 60)
GUICtrlCreateGroup(" 3 - Static", 10, 230, 280, 50)
_GUIExtender_Section_Action($hGUI, 4, "Close 4", "Open 4", 225, 245, 60, 20, 1) ; Push button
_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Start($hGUI, 280, 60)
GUICtrlCreateGroup(" 4 - Extendable ", 10, 290, 280, 50)
_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Start($hGUI, 340, 90)
GUICtrlCreateGroup(" 5 - Static", 10, 350, 280, 80)
_GUIExtender_Section_Action($hGUI, 0, "Close All", "Open All", 20, 390, 60, 20) ; Normal button
_GUIExtender_Section_End($hGUI)

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Create the combo
$hCombo = _GUICtrlComboBox_Create($hGUI, "", 120, 310, 60, 20, $CBS_DROPDOWN); BitOR($CBS_DROPDOWN, $WS_VSCROLL, $WS_TABSTOP, $CBS_UPPERCASE))
_GUICtrlComboBox_BeginUpdate($hCombo)
_GUICtrlComboBox_AddString($hCombo, "ONE")
_GUICtrlComboBox_AddString($hCombo, "TWO")
_GUICtrlComboBox_AddString($hCombo, "THREE")
_GUICtrlComboBox_EndUpdate($hCombo)

; Create a button
$hButton = _GUICtrlButton_Create($hGUI, "Button", 120, 150, 60, 40)

_GUIExtender_Section_Extend($hGUI, 4, False)
_GUIExtender_UDFCtrlCheck($hGUI, $hButton, 2, 120, 40)
_GUIExtender_UDFCtrlCheck($hGUI, $hCombo, 4, 120, 30)

GUISetState()

While 1
	$aMsg = GUIGetMsg(1)
	Switch $aMsg[0]
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch

	_GUIExtender_Action($aMsg[1], $aMsg[0]) ; Check for click on Action control

	; Check UDF control visibility if an Action control was pressed
	If _GUIExtender_ActionCheck() Then
		; Parameters: (Handle, Section, X-coord, Y-coord) - note coords are relative to the section, not the main GUI
		_GUIExtender_UDFCtrlCheck($hGUI, $hButton, 2, 120, 40)
		_GUIExtender_UDFCtrlCheck($hGUI, $hCombo, 4, 120, 30)
	EndIf
WEnd