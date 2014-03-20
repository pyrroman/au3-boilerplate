#include <GUIConstantsEx.au3>

#include <GuiButton.au3>
#include <GUIComboBox.au3>

#include "GUIExtender.au3"

Opt("GUIOnEventMode", 1)

$hGUI = GUICreate("Test", 300, 390)
GUISetOnEvent($GUI_EVENT_CLOSE, "On_Exit")

_GUIExtender_Init($hGUI)

_GUIExtender_Section_Start($hGUI, 0, 70)
GUICtrlCreateGroup(" 1 - Static ", 10, 10, 280, 50)
_GUIExtender_Section_Action($hGUI, 2, "", "", 270, 40, 15, 15, 0, 1) ; Normal button
_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Start($hGUI, 70, 110)
GUICtrlCreateGroup("2 - Extendable ", 10, 70, 280, 100)
_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Start($hGUI, 180, 60)
GUICtrlCreateGroup(" 3 - Static ", 10, 180, 280, 50)
$iRet = _GUIExtender_Section_Action($hGUI, 4, "Close 4", "Open 4", 225, 205, 60, 20, 1, 1) ; Push button
ConsoleWrite($iRet & @CRLF)
_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Start($hGUI, 240, 60)
GUICtrlCreateGroup("4 - Extendable ", 10, 240, 280, 50)
_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Start($hGUI, 300, 90)
GUICtrlCreateGroup(" 5 - Static ", 10, 300, 280, 80)
_GUIExtender_Section_Action($hGUI, 0, "Close All", "Open All", 20, 340, 60, 20, 0, 1) ; Normal button
_GUIExtender_Section_End($hGUI)

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Create the combo
$hCombo = _GUICtrlComboBox_Create($hGUI, "", 120, 260, 60, 20, $CBS_DROPDOWN); BitOR($CBS_DROPDOWN, $WS_VSCROLL, $WS_TABSTOP, $CBS_UPPERCASE))
_GUICtrlComboBox_BeginUpdate($hCombo)
_GUICtrlComboBox_AddString($hCombo, "ONE")
_GUICtrlComboBox_AddString($hCombo, "TWO")
_GUICtrlComboBox_AddString($hCombo, "THREE")
_GUICtrlComboBox_EndUpdate($hCombo)

; Create a button
$hButton = _GUICtrlButton_Create($hGUI, "Button", 120, 100, 60, 40)

_GUIExtender_Section_Extend($hGUI, 4, False)
_GUIExtender_UDFCtrlCheck($hGUI, $hButton, 2, 120, 40)
_GUIExtender_UDFCtrlCheck($hGUI, $hCombo, 4, 120, 20)

GUISetState()

While 1
	Sleep(10)
	; Check UDF control visibility if an Action control was pressed
	If _GUIExtender_ActionCheck() Then
		; Parameters: (Handle, Section, X-coord, Y-coord) - note coords are relative to the section, not the main GUI
		_GUIExtender_UDFCtrlCheck($hGUI, $hButton, 2, 120, 40)
		_GUIExtender_UDFCtrlCheck($hGUI, $hCombo, 4, 120, 20)
	EndIf
WEnd

Func On_Exit()
	Exit
EndFunc