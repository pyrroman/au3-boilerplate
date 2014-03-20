#include <GUIConstantsEx.au3>

#include "GUIExtender.au3"

$hGUI = GUICreate("Multirole GUI", 280, 530)

_GUIExtender_Init($hGUI)

$hButton_1 = GUICtrlCreateButton("Edit",  10, 5, 80, 20)
$hButton_2 = GUICtrlCreateButton("Check", 100, 5, 80, 20)
$hButton_3 = GUICtrlCreateButton("Combo", 190, 5, 80, 20)

; I have found this to be the best way to set the section dimensions - see further comments below  <<<<<<<<<<<<<
$iEdit_Section_Start = 30
$iEdit_Section_Height = 270
$iEdit_Section = _GUIExtender_Section_Start($hGUI, $iEdit_Section_Start, $iEdit_Section_Height)
_GUIExtender_Section_Action($hGUI, $iEdit_Section)
; All control positions can then be related to the section start rather than the GUI  <<<<<<<<<<<<<
GUICtrlCreateEdit("This is an edit", 10, $iEdit_Section_Start + 10, 260, 200)
GUICtrlCreateButton("Cancel", 10, $iEdit_Section_Start + 220, 80, 30)
GUICtrlCreateButton("Save", 180, $iEdit_Section_Start + 220, 80, 30)
; Now you can check that the _Section_Height is correct and amend if necessary  <<<<<<<<<<<<<
_GUIExtender_Section_End($hGUI)

; And it is really easy to set the new section start  <<<<<<<<<<<<<
$iCheck_Section_Start = 300
$iCheck_Section_Height = 200
$iCheck_Section = _GUIExtender_Section_Start($hGUI, $iCheck_Section_Start, $iCheck_Section_Height)
_GUIExtender_Section_Action($hGUI, $iCheck_Section)
GUICtrlCreateCheckbox(" Option 1", 20, $iCheck_Section_Start + 10, 130, 20)
GUICtrlCreateCheckbox(" Option 2", 150, $iCheck_Section_Start + 10, 130, 20)
GUICtrlCreateCheckbox(" Option 3", 20, $iCheck_Section_Start + 30, 130, 20)
GUICtrlCreateCheckbox(" Option 4", 150, $iCheck_Section_Start + 30, 130, 20)
GUICtrlCreateButton("Save", 180, $iCheck_Section_Start + 60, 80, 30)
_GUIExtender_Section_End($hGUI)

$iCombo_Section_Start = 500
$iCombo_Section_Height = 200
$iCombo_Section = _GUIExtender_Section_Start($hGUI, $iCombo_Section_Start, $iCombo_Section_Height)
_GUIExtender_Section_Action($hGUI, $iCombo_Section)
GUICtrlCreateCombo("", 20, $iCombo_Section_Start + 10, 240, 20)
GUICtrlSetData(-1, "Alpha|Bravo|Charlie", "Alpha")
GUICtrlCreateCombo("", 20, $iCombo_Section_Start + 40, 240, 20)
GUICtrlSetData(-1, "Lima|Mike|November", "Mike")
GUICtrlCreateCombo("", 20, $iCombo_Section_Start + 70, 240, 20)
GUICtrlSetData(-1, "Xray|Yankee|Zulu", "Zulu")
GUICtrlCreateButton("Confirm", 100, $iCombo_Section_Start + 100, 80, 30)
; And here you can check the overall GUI height to make sure it all fits in!  <<<<<<<<<<<<<
_GUIExtender_Section_End($hGUI)

_GUIExtender_Section_Extend($hGUI, 0, False)

GUISetState()

While 1

	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GUI_EVENT_RESTORE
			_GUIExtender_Restore()
		; If section required
		Case $hButton_1
		_GUIExtender_Section_Extend($hGUI, $iCombo_Section, False)
					_GUIExtender_Section_Extend($hGUI, $iCheck_Section, False)
					_GUIExtender_Section_Extend($hGUI, $iEdit_Section)
		Case $hButton_2
		_GUIExtender_Section_Extend($hGUI, $iCombo_Section, False)
					_GUIExtender_Section_Extend($hGUI, $iEdit_Section, False)
					_GUIExtender_Section_Extend($hGUI, $iCheck_Section)
		Case $hButton_3
		_GUIExtender_Section_Extend($hGUI, $iCheck_Section, False)
					_GUIExtender_Section_Extend($hGUI, $iEdit_Section, False)
					_GUIExtender_Section_Extend($hGUI, $iCombo_Section)
	EndSwitch

WEnd