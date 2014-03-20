#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <SendMessage.au3>

#include "GUIExtender.au3"

; Create GUI full size
$hGUI = GUICreate("Test", 300, 380)

; Create menu
$mFileMenu = GUICtrlCreateMenu("&File")
$mExit_Menu_Item = GUICtrlCreateMenuItem("&Exit", $mFileMenu)
$mViewMenu = GUICtrlCreateMenu("&View")
$mCode_Menu_Item = GUICtrlCreateMenuItem("&Menu Only", $mViewMenu)
$mMore_Menu_Item = GUICtrlCreateMenuItem("&More", $mViewMenu)
$mEdit_Menu_Item = GUICtrlCreateMenuItem("&Edit", $mViewMenu)

; Initialise UDF
_GUIExtender_Init($hGUI)

; Create the controls as normal - but add the section start, end and action lines where needed

$iCode_Section = _GUIExtender_Section_Start($hGUI, 0, 30)
; Here we are creating a action control for this section to be used programmatically - so no parameters required
_GUIExtender_Section_Action($hGUI, $iCode_Section)
GUICtrlCreateLabel("GUIExtender UDF from Melba23.  I hope you like it!", 10, 10, 250, 20)
_GUIExtender_Section_End($hGUI)

$iThis_Section = _GUIExtender_Section_Start($hGUI, 30, 50)
$hButton_1 = GUICtrlCreateButton("About", 20, 45, 80, 25)
GUICtrlCreateLabel("More...", 235, 60, 35, 15)
; Here we are creating an action control to appear on the GUI
_GUIExtender_Section_Action($hGUI, $iThis_Section + 1, "", "", 270, 60, 15, 15) ; Note easy way to denote next section
_GUIExtender_Section_End($hGUI)

$iMore_Section = _GUIExtender_Section_Start($hGUI, 80, 110) ; Save the section ID as a variable to use later
$hButton_2 = GUICtrlCreateButton("Sync", 20, 95, 80, 25)
GUIStartGroup()
$hRadio_1 = GUICtrlCreateRadio("Green", 120, 95, 60, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
$hRadio_2 = GUICtrlCreateRadio("Red", 180, 95, 60, 20)
$hRadio_3 = GUICtrlCreateRadio("Yellow", 240, 95, 60, 20)
$hProgress = GUICtrlCreateProgress(25, 130, 250, 15)
GUICtrlSetData(-1, 50)
$hSlider = GUICtrlCreateSlider(25, 155, 250, 20)
GUICtrlSetData(-1, 50)

_GUIExtender_Section_End($hGUI)

$iThis_Section = _GUIExtender_Section_Start($hGUI, 190, 140)
$hCombo = GUICtrlCreateCombo("", 20, 200, 260, 20)
GUICtrlSetData(-1, "Alpha|Bravo|Charlie|Delta", "Alpha")
$hList = GUICtrlCreateList("", 25, 240, 180, 80, 0x00200000)
GUICtrlSetData(-1, "One|Two|Three")
; Another action control to appear on the GUI
_GUIExtender_Section_Action($hGUI, $iThis_Section + 1, "Close", "Input", 210, 290, 60, 20, 1)
_GUIExtender_Section_End($hGUI)

$iInput_Section = _GUIExtender_Section_Start($hGUI, 330, 40)
$hInput = GUICtrlCreateInput("Your input goes here", 20, 330, 180, 20)
$hButton_3 = GUICtrlCreateButton("OK", 210, 330, 60, 20)
_GUIExtender_Section_End($hGUI)

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Retract all extendable sections
_GUIExtender_Section_Extend($hGUI, 0, False)

GUISetState()

While 1

	$aMsg = GUIGetMsg(1)
	; Check for normal AutoIt controls
	Switch $aMsg[0]
		Case $GUI_EVENT_CLOSE, $mExit_Menu_Item
			Exit
		Case $mMore_Menu_Item
			If BitAND(GUICtrlRead($mMore_Menu_Item), $GUI_CHECKED) = $GUI_CHECKED Then
				_GUIExtender_Section_Extend($hGUI, $iMore_Section, False)
				GUICtrlSetState($mMore_Menu_Item, $GUI_UNCHECKED)
			Else
				_GUIExtender_Section_Extend($hGUI, $iMore_Section)
				GUICtrlSetState($mMore_Menu_Item, $GUI_CHECKED)
			EndIf
		Case $mEdit_Menu_Item
			If BitAND(GUICtrlRead($mEdit_Menu_Item), $GUI_CHECKED) = $GUI_CHECKED Then
				_GUIExtender_Section_Extend($hGUI, $iInput_Section, False)
				GUICtrlSetState($mEdit_Menu_Item, $GUI_UNCHECKED)
			Else
				_GUIExtender_Section_Extend($hGUI, $iInput_Section)
				GUICtrlSetState($mEdit_Menu_Item, $GUI_CHECKED)
			EndIf
		Case $mCode_Menu_Item
			If BitAND(GUICtrlRead($mCode_Menu_Item), $GUI_CHECKED) = $GUI_CHECKED Then
				_GUIExtender_Section_Extend($hGUI, $iCode_Section, False)
				GUICtrlSetState($mCode_Menu_Item, $GUI_UNCHECKED)
			Else
				_GUIExtender_Section_Extend($hGUI, $iCode_Section)
				GUICtrlSetState($mCode_Menu_Item, $GUI_CHECKED)
			EndIf
		Case $hButton_1
			MsgBox(0, "GUIExtender Demo", "Use the various buttons and menu items" & @CRLF & "to extend and retract hidden areas of the GUI")
		Case $hButton_2
			GUICtrlSetData($hProgress, GUICtrlRead($hSlider) + 1)
			GUICtrlSetData($hProgress, GUICtrlRead($hSlider))
		Case $hRadio_1
			_SendMessage(GUICtrlGetHandle($hProgress), $PBM_SETSTATE, 1)
		Case $hRadio_2
			_SendMessage(GUICtrlGetHandle($hProgress), $PBM_SETSTATE, 2)
		Case $hRadio_3
			_SendMessage(GUICtrlGetHandle($hProgress), $PBM_SETSTATE, 3)
		Case $hCombo
			GUICtrlSetData($hInput, GUICtrlRead($hCombo))
		Case $hButton_3
			GUICtrlSetData($hList, GUICtrlRead($hInput))


	EndSwitch
	; Check for GUIExtender controls
	_GUIExtender_Action($aMsg[1], $aMsg[0])

	; Keep menu items in sync with the section state
	If _GUIExtender_Section_State($hGUI, $iMore_Section) = 0 And BitAND(GUICtrlRead($mMore_Menu_Item), $GUI_CHECKED) = $GUI_CHECKED Then
		GUICtrlSetState($mMore_Menu_Item, $GUI_UNCHECKED)
	ElseIf _GUIExtender_Section_State($hGUI, $iMore_Section) = 1 And BitAND(GUICtrlRead($mMore_Menu_Item), $GUI_CHECKED) <> $GUI_CHECKED Then
		GUICtrlSetState($mMore_Menu_Item, $GUI_CHECKED)
	EndIf
	If _GUIExtender_Section_State($hGUI, $iInput_Section) = 0 And BitAND(GUICtrlRead($mEdit_Menu_Item), $GUI_CHECKED) = $GUI_CHECKED Then
		GUICtrlSetState($mEdit_Menu_Item, $GUI_UNCHECKED)
	ElseIf _GUIExtender_Section_State($hGUI, $iInput_Section) = 1 And BitAND(GUICtrlRead($mEdit_Menu_Item), $GUI_CHECKED) <> $GUI_CHECKED Then
		GUICtrlSetState($mEdit_Menu_Item, $GUI_CHECKED)
	EndIf

WEnd