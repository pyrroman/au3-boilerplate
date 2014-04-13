#AutoIt3Wrapper_Au3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5 -w 6

;.......script written by trancexx (trancexx at yahoo dot com)
;.......File handling based on Corgano/Inverted method (this sounds smart)

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "GIFAnimation.au3"
#include <File.au3>
#include <Array.au3>

Opt("MustDeclareVars", 1)

Global Const $sFilter = "*.gif;*.png;*.jpg;*.tiff;*.bmp;*.jpeg;"

Global $sFile = FileOpenDialog("Choose Image", "", "(" & $sFilter & " )")
If @error Then Exit

Global $hGui = GUICreate("Image Viewer - " & StringRegExpReplace(@WorkingDir, ".*\\(.*?)\\", ""), 500, 500, -1, -1, $WS_OVERLAPPEDWINDOW)
GUISetBkColor(0xFFFFFF)

Global $aClientSize, $aGIFDimension, $iPosX, $iPosY
Global $sDrive, $sDir, $sFName, $sExt

Global $aGIFFilesArray = _FolderListFilesToArray(@WorkingDir, $sFilter)
_ArraySort($aGIFFilesArray)
Global $aSplitPath = _PathSplit($sFile, $sDrive, $sDir, $sFName, $sExt)
Global $iCurrentPos = _ArraySearch($aGIFFilesArray, $aSplitPath[3] & $aSplitPath[4])

Global $hButton = GUICtrlCreateButton("<  Previous", 50, 450, 100, 25)
GUICtrlSetTip(-1, "Previous Image in folder")
GUICtrlSetResizing(-1, 836)
Global $hButton1 = GUICtrlCreateButton("Pause animation", 200, 450, 100, 25)
GUICtrlSetTip(-1, "Pause/Play")
GUICtrlSetResizing(-1, 836)
Global $hButton2 = GUICtrlCreateButton("Next  >", 350, 450, 100, 25)
GUICtrlSetTip(-1, "Next Image in folder")
GUICtrlSetResizing(-1, 836)
Global $hButton3 = GUICtrlCreateButton("...", 455, 450, 30, 25)
GUICtrlSetTip(-1, "New folder")
GUICtrlSetResizing(-1, 836)

Global $hGIF
_Forward(True)

GUIRegisterMsg(5, "_AdjustGIFPos") ; WM_SIZE
GUIRegisterMsg(15, "_ValidateGIFs"); WM_PAINT
GUIRegisterMsg(36, "_SetMinMax") ; WM_GETMINMAXINFO

Global $fPlay = True

GUISetState()

While 1
	Switch GUIGetMsg()
		Case -3
			Exit
		Case $hButton
			GUISetCursor(15, 1)
			GUICtrlSetData($hButton1, "Pause animation")
			GUICtrlSetState($hButton, $GUI_DISABLE)
			GUICtrlSetState($hButton1, $GUI_DISABLE)
			GUICtrlSetState($hButton2, $GUI_DISABLE)
			_Back()
			GUICtrlSetState($hButton, $GUI_ENABLE)
			GUICtrlSetState($hButton2, $GUI_ENABLE)
			GUISetCursor(-1)
			$fPlay = True
		Case $hButton1
			If $fPlay Then
				If _GIF_PauseAnimation($hGIF) Then
					$fPlay = False
					GUICtrlSetData($hButton1, "Resume animation")
				EndIf
			Else
				If _GIF_ResumeAnimation($hGIF) Then
					$fPlay = True
					GUICtrlSetData($hButton1, "Pause animation")
				EndIf
			EndIf
		Case $hButton2
			GUISetCursor(15, 1)
			GUICtrlSetData($hButton1, "Pause animation")
			GUICtrlSetState($hButton, $GUI_DISABLE)
			GUICtrlSetState($hButton1, $GUI_DISABLE)
			GUICtrlSetState($hButton2, $GUI_DISABLE)
			_Forward()
			GUICtrlSetState($hButton, $GUI_ENABLE)
			GUICtrlSetState($hButton2, $GUI_ENABLE)
			GUISetCursor(-1)
			$fPlay = True
		Case $hButton3
			$sFile = FileOpenDialog("Choose Image", "", "(" & $sFilter & " )", 1, "", $hGui)
			If @error Then ContinueLoop
			WinSetTitle($hGui, 0, "Image Viewer - " & StringRegExpReplace(@WorkingDir, ".*\\(.*?)\\", ""))
			$aGIFFilesArray = _FolderListFilesToArray(@WorkingDir, $sFilter)
			_ArraySort($aGIFFilesArray)
			$aSplitPath = _PathSplit($sFile, $sDrive, $sDir, $sFName, $sExt)
			$iCurrentPos = _ArraySearch($aGIFFilesArray, $aSplitPath[3] & $aSplitPath[4]) - 1
			_Forward()
	EndSwitch
WEnd

Func _Back()
	_GIF_DeleteGIF($hGIF)
	$iCurrentPos -= 1
	If $iCurrentPos = -1 Then $iCurrentPos = UBound($aGIFFilesArray) - 1
	_Forward(True)
EndFunc   ;==>_Back

Func _Forward($fInitial = False)
	If Not $fInitial Then
		_GIF_DeleteGIF($hGIF)
		$iCurrentPos += 1
		If $iCurrentPos = UBound($aGIFFilesArray) Then $iCurrentPos = 0
	EndIf
	$aGIFDimension = _GIF_GetDimension($aGIFFilesArray[$iCurrentPos])
	Local $iOriginalW = $aGIFDimension[0]
	Local $iOriginalH = $aGIFDimension[1]
	$aClientSize = WinGetClientSize($hGui)
	; "Resize" image to fit
	Local $nScale = 1
	While 1
		If $aClientSize[0] - 100 < $aGIFDimension[0] Or $aClientSize[1] - 100 < $aGIFDimension[1] Then
			$nScale /= 1.01
			$aGIFDimension[1] = Round($aGIFDimension[1] * $nScale)
			$aGIFDimension[0] = Round($aGIFDimension[0] * $nScale)
		Else
			ExitLoop
		EndIf
	WEnd
	$iPosX = ($aClientSize[0] - $aGIFDimension[0]) / 2
	$iPosY = ($aClientSize[1] - $aGIFDimension[1]) / 2 - 100
	If $iPosY < 0 Then $iPosY = 0
	If $iPosY + $aGIFDimension[1] > $aClientSize[1] - 100 Then $iPosY -= $aGIFDimension[1] - $aClientSize[1] + 100 ; not to cover buttons
	$hGIF = _GUICtrlCreateGIF($aGIFFilesArray[$iCurrentPos], "", $iPosX, $iPosY, $aGIFDimension[0], $aGIFDimension[1])
	If @extended Then
		GUICtrlSetData($hButton1, "Not animated")
		GUICtrlSetState($hButton1, $GUI_DISABLE)
	Else
		GUICtrlSetState($hButton1, $GUI_ENABLE)
	EndIf
	Local $sTip = "Size: " & $iOriginalW & " x " & $iOriginalH
	If $nScale < 1 Then $sTip &= @LF & "Resized to fit to: " & $aGIFDimension[0] & " x " & $aGIFDimension[1]
	GUICtrlSetTip($hGIF, $sTip, StringRegExpReplace($aGIFFilesArray[$iCurrentPos], ".*\\", ""), 1)
EndFunc   ;==>_Forward

Func _AdjustGIFPos($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $aClientSize[2] = [BitAND($lParam, 65535), BitShift($lParam, 16)]
	$iPosX = ($aClientSize[0] - $aGIFDimension[0]) / 2
	$iPosY = ($aClientSize[1] - $aGIFDimension[1]) / 2 - 100
	If $iPosY < 0 Then $iPosY = 0
	If $iPosY + $aGIFDimension[1] > $aClientSize[1] - 100 Then $iPosY -= $aGIFDimension[1] - $aClientSize[1] + 100 ; not to cover buttons
	GUICtrlSetPos($hGIF, $iPosX, $iPosY, $aGIFDimension[0], $aGIFDimension[1])
EndFunc   ;==>_AdjustGIFPos

Func _ValidateGIFs($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	_GIF_ValidateGIF($hGIF)
EndFunc   ;==>_ValidateGIFs

Func _SetMinMax($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg, $wParam
	If $hWnd = $hGui Then
		Local $tMINMAXINFO = DllStructCreate("int[2];" & _
				"int MaxSize[2];" & _
				"int MaxPosition[2];" & _
				"int MinTrackSize[2];" & _
				"int MaxTrackSize[2]", _
				$lParam)
		DllStructSetData($tMINMAXINFO, "MinTrackSize", 500, 1)
		DllStructSetData($tMINMAXINFO, "MinTrackSize", 350, 2)
	EndIf
EndFunc   ;==>_SetMinMax

Func _FolderListFilesToArray($sFolder, $sExtensionsFilter)
	Local $aExtensions = StringRegExp($sExtensionsFilter & ";", "\h*(\*\..*?)\h*;", 3)
	If @error Then Return SetError(1, 0, 0)
	If Not (StringRight($sFolder, 1) == "\") Then $sFolder &= "\"
	Local $hSearch, $sFile, $sData
	For $sExtension In $aExtensions
		$hSearch = FileFindFirstFile($sFolder & $sExtension)
		If $hSearch = -1 Then ContinueLoop
		While 1
			$sFile = FileFindNextFile($hSearch)
			If @error Then ExitLoop
			If @extended Then ContinueLoop ; Thank you AdmiralAlkex
			$sData &= $sFile & "|"
		WEnd
		FileClose($hSearch)
	Next
	Return StringSplit(StringTrimRight($sData, 1), "|", 2)
EndFunc   ;==>_FolderListFilesToArray