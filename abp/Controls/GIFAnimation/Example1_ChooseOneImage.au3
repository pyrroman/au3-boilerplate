#AutoIt3Wrapper_Au3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5 -w 6

;.......script written by trancexx (trancexx at yahoo dot com)

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "GIFAnimation.au3"

Opt("MustDeclareVars", 1)

; Start by choosing GIF to display
Global $sFile = FileOpenDialog("Choose Image", "", "(*.gif;*.png;*.jpg;*.tiff;*.bmp;*.jpeg)", -1, "")
If @error Then Exit

; Make GUI
Global $hGui = GUICreate("GIF Animation", 500, 500, -1, -1, $WS_OVERLAPPEDWINDOW)

; Add some buttons
Global $hButton = GUICtrlCreateButton("&Pause animation", 50, 450, 100, 25)
Global $hButton1 = GUICtrlCreateButton("&Delete Control", 200, 450, 100, 25)
Global $hButton2 = GUICtrlCreateButton("&Open Image", 350, 450, 100, 25)

; Make GIF Control
Global $hGIF = _GUICtrlCreateGIF($sFile, "", 10, 10)
If @extended Then GUICtrlSetState($hButton, $GUI_DISABLE)
GUICtrlSetTip($hGIF, "Image")

; Additional processing of some windows messages (for example)
GUIRegisterMsg(133, "_Refresh") ; WM_NCPAINT
GUIRegisterMsg(15, "_ValidateGIFs") ; WM_PAINT

Global $iPlay = 1

; Show it
GUISetState()

; Loop till end
While 1
	Switch GUIGetMsg()
		Case -3
			Exit
		Case $hButton
			If $iPlay Then
				If _GIF_PauseAnimation($hGIF) Then
					$iPlay = 0
					GUICtrlSetData($hButton, "Resume animation")
				EndIf
			Else
				If _GIF_ResumeAnimation($hGIF) Then
					$iPlay = 1
					GUICtrlSetData($hButton, "Pause animation")
				EndIf
			EndIf
		Case $hButton1
			_GIF_DeleteGIF($hGIF)
		Case $hButton2
			$sFile = FileOpenDialog("Choose gif", "", "(*.gif;*.png;*.jpg;*.tiff;*.bmp;*.jpeg)", -1, "", $hGui)
			If Not @error Then
				_GIF_DeleteGIF($hGIF); delete previous
				$hGIF = _GUICtrlCreateGIF($sFile, "", 10, 10)
				If @extended Then
					GUICtrlSetState($hButton, $GUI_DISABLE)
				Else
					GUICtrlSetState($hButton, $GUI_ENABLE)
				EndIf
				GUICtrlSetTip($hGIF, "Image")
				$iPlay = 1
				GUICtrlSetData($hButton, "Pause animation")
			EndIf
	EndSwitch
WEnd


Func _Refresh($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	_GIF_RefreshGIF($hGIF)
EndFunc   ;==>_Refresh

Func _ValidateGIFs($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	_GIF_ValidateGIF($hGIF)
EndFunc   ;==>_ValidateGIFs






