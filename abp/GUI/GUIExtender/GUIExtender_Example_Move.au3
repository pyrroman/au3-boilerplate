

#include <GUIConstantsEx.au3>

#include "GUIExtender.au3"

$hGUI = GUICreate("Move Example", 250, 230)

GUICtrlCreateGroup(" Choose Orientation ", 10, 10, 230, 80)

$cRadio_Horz = GUICtrlCreateRadio(" Horizontal ", 20, 30, 100, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
$cRadio_Vert = GUICtrlCreateRadio(" Vertical ", 20, 60, 100, 20)

GUICtrlCreateGroup(" Choose Move Style ", 10, 100, 230, 110)

$cRadio_0 = GUICtrlCreateRadio(" Fix Left ", 20, 120, 100, 20)
$cRadio_1 = GUICtrlCreateRadio(" Fix Centre ", 20, 150, 100, 20)
$cRadio_2 = GUICtrlCreateRadio(" Fix Right ", 20, 180, 100, 20)

GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetState()

While 1

	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $cRadio_Horz
			GUICtrlSetData($cRadio_0, " Fix Left ")
			GUICtrlSetState($cRadio_0, $GUI_UNCHECKED)
			GUICtrlSetState($cRadio_1, $GUI_UNCHECKED)
			GUICtrlSetData($cRadio_2, " Fix Right ")
			GUICtrlSetState($cRadio_2, $GUI_UNCHECKED)
		Case $cRadio_Vert
			GUICtrlSetData($cRadio_0, " Fix Top ")
			GUICtrlSetState($cRadio_0, $GUI_UNCHECKED)
			GUICtrlSetState($cRadio_1, $GUI_UNCHECKED)
			GUICtrlSetData($cRadio_2, " Fix Bottom ")
			GUICtrlSetState($cRadio_2, $GUI_UNCHECKED)
		Case $cRadio_0
			_Create_GUI(0)
		Case $cRadio_1
			_Create_GUI(1)
		Case $cRadio_2
			_Create_GUI(2)
	EndSwitch

WEnd

Func _Create_GUI($iMove)

	Local $sTitle

	Switch $iMove
		Case 0
			If GUICtrlRead($cRadio_Horz) = 1 Then
				$sTitle = "Fixed Left"
			Else
				$sTitle = "Fixed Top"
			EndIf
		Case 1
			$sTitle = "Fixed Centre"
		Case 2
			If GUICtrlRead($cRadio_Horz) = 1 Then
				$sTitle = "Fixed Right"
			Else
				$sTitle = "Fixed Bottom"
			EndIf
	EndSwitch

	GUISetState(@SW_HIDE, $hGUI)

	$hGUI_Ex = GUICreate($sTitle, 500, 500)

	If GUICtrlRead($cRadio_Horz) = 1 Then

		_GUIExtender_Init($hGUI_Ex, 1, $iMove)
		_GUIExtender_Section_Start($hGUI_Ex, 0, 250)
		_GUIExtender_Section_Action($hGUI_Ex, 2, "", "", 220, 10, 20, 20)
		_GUIExtender_Section_End($hGUI_Ex)
		_GUIExtender_Section_Start($hGUI_Ex, 250, 250)
		GUICtrlCreateLabel("", 250, 0, 250, 500)
		GUICtrlSetBkColor(-1, 0xFFCCCC)
		_GUIExtender_Section_End($hGUI_Ex)

	Else

		_GUIExtender_Init($hGUI_Ex, 0, $iMove)
		_GUIExtender_Section_Start($hGUI_Ex, 250, 0)
		_GUIExtender_Section_Action($hGUI_Ex, 2, "", "", 470, 220, 20, 20)
		_GUIExtender_Section_End($hGUI_Ex)
		_GUIExtender_Section_Start($hGUI_Ex, 250, 250)
		GUICtrlCreateLabel("", 0, 250, 500, 250)
		GUICtrlSetBkColor(-1, 0xFFCCCC)
		_GUIExtender_Section_End($hGUI_Ex)

	EndIf

	_GUIExtender_Section_Extend($hGUI_Ex, 2, False)

	GUISetState()

	While 1

		$aMsg = GUIGetMsg(1)
		Switch $aMsg[0]
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_SHOW, $hGUI)
				GUIDelete($hGUI_Ex)
				_GUIExtender_Clear($hGUI_Ex)
				ExitLoop
		EndSwitch

		_GUIExtender_Action($aMsg[1], $aMsg[0]) ; Check for click on Action control

	WEnd

EndFunc