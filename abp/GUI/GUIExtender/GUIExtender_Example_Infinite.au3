#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include "GUIExtender.au3"

Global $aGUI[1] = [0], $aButton[1] = [0], $aList[1] = [0]

_Create_GUI()

While 1
    $aMsg = GUIGetMsg(1)

    Switch $aMsg[0]
		Case $GUI_EVENT_CLOSE
			If $aMsg[1] = $aGUI[1] Then
				Exit
			Else
				For $i = 2 To $aGUI[0]
					If $aMsg[1] = $aGUI[$i] Then
						GUIDelete($aGUI[$i])
						_GUIExtender_Clear($aGUI[$i])
						ExitLoop
					EndIf
				Next
			EndIf
		Case Else
			; Was it a button
			For $i = 1 To $aButton[0]
				If $aMsg[0] = $aButton[$i] Then
					_Create_GUI()
					ExitLoop
				EndIf
			Next
		EndSwitch

		; Check for click on Action control
		_GUIExtender_Action($aMsg[1], $aMsg[0])

		; Check UDF control visibility if an Action control was pressed
		If _GUIExtender_ActionCheck() Then
			; Check which GUI held the control
			$hActive = WinGetHandle("[ACTIVE]")
			For $j = 1 To $aGUI[0]
				If $hActive = $aGUI[$j] Then
					; Check the control
					_GUIExtender_UDFCtrlCheck($hActive, $aList[$j], 2, 20, 30)
					ExitLoop
				EndIf
			Next
		EndIf

WEnd

Func _Create_GUI()

	Local $iCount = $aGUI[0]
	$iCount += 1

	ReDim $aGUI[$iCount + 1]
	$aGUI[0] = $iCount
	ReDim $aButton[$iCount + 1]
	$aButton[0] = $iCount
	ReDim $aList[$iCount + 1]
	$aList[0] = $iCount

	Local $hGUI = GUICreate("Test " & $iCount, 300, 300, 100 + (50 * $iCount), 100 + (50 * $iCount))
	$aGUI[$iCount] = $hGUI

	_GUIExtender_Init($hGUI)

	_GUIExtender_Section_Start($hGUI, 0, 100)
	GUICtrlCreateGroup(" 1 - Static ", 10, 10, 280, 80)
	_GUIExtender_Section_Action($hGUI, 2, "", "", 270, 40, 15, 15) ; Normal button
	_GUIExtender_Section_End($hGUI)

	_GUIExtender_Section_Start($hGUI, 100, 100)
	GUICtrlCreateGroup(" 2 - Extendable ", 10, 110, 280, 80)
	$aList[$iCount] = _GUICtrlListBox_Create($hGUI, 'Test', 20, 130, 260, 50)
	_GUIExtender_Section_End($hGUI)

	_GUIExtender_Section_Start($hGUI, 200, 100)
	GUICtrlCreateGroup(" 3 - Static ", 10, 210, 280, 80)
	$aButton[$iCount] = GUICtrlCreateButton('New GUI', 20, 240, 80, 30)
	_GUIExtender_Section_End($hGUI)

	GUISetState(@SW_SHOW, $hGUI)

EndFunc