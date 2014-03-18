#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <WindowsConstants.au3>
#include "AutoitObject.au3"

Global $oError = ObjEvent("AutoIt.Error", "_ErrFunc")
Func _ErrFunc()
	ConsoleWrite("! COM Error !  Number: 0x" & Hex($oError.number, 8) & "   ScriptLine: " & $oError.scriptline & " - " & $oError.windescription & @CRLF)
	Return
EndFunc   ;==>_ErrFunc


; GUI
Global $hGUI = GUICreate("DirectShow Player - AutoItObject", 540, 500, -1, -1, $WS_OVERLAPPEDWINDOW)
Global $hVolSlider = GUICtrlCreateSlider(10, 462, 120, 15)
GUICtrlSetData(-1, 100)
GUICtrlSetResizing(-1, 64 + 512)
Global $hButtonStop = GUICtrlCreateButton("Stop", 140, 450, 70, 25)
Global $hButtonPlay = GUICtrlCreateButton("Pause", 220, 450, 115, 25)
Global $hButtonBrowse = GUICtrlCreateButton("Load", 430, 450, 90, 25)
Global $hButtonFit = GUICtrlCreateButton("Fit window", 350, 450, 70, 25)


_AutoItObject_StartUp()

Global $oGraphBuilder, $oMediaControl, $oMediaEventEx, $oVideoWindow, $oMediaPosition, $oBasicAudio, $oBasicVideo

Global $iPlaying = 1, $iVol, $iUnFit = 1

GUIRegisterMsg($WM_SIZE, "_AdjustMediaViewPos")
GUIRegisterMsg($WM_GETMINMAXINFO, "_SetMinMax")
GUISetState()

While 1
	Switch GUIGetMsg()
		Case -3
			ExitLoop
		Case $hButtonFit
			If $iUnFit Then
				$iUnFit = 0
				GUICtrlSetData($hButtonFit, "Original size")
			Else
				$iUnFit = 1
				GUICtrlSetData($hButtonFit, "Fit window")
			EndIf
			_SetSize($oVideoWindow, $oBasicVideo, $hGUI)
		Case $hButtonStop
			$oMediaPosition.put_CurrentPosition("long", "double", 0)
			$oMediaControl.Stop()
			GUICtrlSetData($hButtonPlay, "Play")
			$iPlaying = 0
		Case $hButtonPlay
			If $iPlaying Then
				$oMediaControl.Pause()
				GUICtrlSetData($hButtonPlay, "Play")
				$iPlaying = 0
			Else
				$oMediaControl.Run()
				GUICtrlSetData($hButtonPlay, "Pause")
				$iPlaying = 1
			EndIf
		Case $hButtonBrowse
			$sMediaFile = FileOpenDialog("Choose fle", "", "(*.flv;*.gif;*.bmp;*.jpg;*.wmv;*.avi;*.mpg;*.mp4;*.wmv;*.wma;*.mid;*.wav;*.mp3;*.rmi;*.aif;*.au;*.snd;*.kar)|All files(*)", 1)
			If @error Then ContinueLoop
			_ReleaseBuilder($oGraphBuilder, $oMediaControl, $oMediaEventEx, $oVideoWindow, $oMediaPosition, $oBasicAudio, $oBasicVideo)
			_InitBuilder($oGraphBuilder, $oMediaControl, $oMediaEventEx, $oVideoWindow, $oMediaPosition, $oBasicAudio, $oBasicVideo)
			;$oGraphBuilder.RenderFile("int", "wstr", $sMediaFile, "ptr", 0)
			$oMediaControl.RenderFile($sMediaFile)
			$oVideoWindow.put_Caption("long", "wstr", StringRegExpReplace($sMediaFile, ".*\\|\.xm", ""))
			$oVideoWindow.put_Owner("long", "hwnd", Number($hGUI))
			$oVideoWindow.put_WindowStyle("long", "long", 0x42000000) ; WS_CHILD | WS_CLIPCHILDREN
			_SetSize($oVideoWindow, $oBasicVideo, $hGUI)
			$oBasicAudio.put_Volume("long", "long", -Exp((100 - GUICtrlRead($hVolSlider)) / 10.86))
			$oMediaControl.Run()
			GUICtrlSetData($hButtonPlay, "Pause")
			$iPlaying = 1
	EndSwitch
	If $iVol <> GUICtrlRead($hVolSlider) Then
		$iVol = GUICtrlRead($hVolSlider)
		If IsObj($oBasicAudio) Then $oBasicAudio.put_Volume("long", "long", -Exp((100 - $iVol) / 10.86))
		GUICtrlSetTip($hVolSlider, $iVol & " %VOL")
	EndIf
WEnd

_ReleaseBuilder($oGraphBuilder, $oMediaControl, $oMediaEventEx, $oVideoWindow, $oMediaPosition, $oBasicAudio, $oBasicVideo)

;THE END




Func _SetSize($oVideoWindow, $oBasicVideo, $hGUI)
	Local $aClientSize = WinGetClientSize($hGUI)
	Local $aCall = $oBasicVideo.GetVideoSize("long", "long*", 0, "long*", 0)
	Local $iX, $iY
	Local $iWidth = $aClientSize[0], $iHeight = $aClientSize[1] - 80
	If IsArray($aCall) And $iUnFit Then
		If $iWidth > $aCall[1] Or $iHeight > $aCall[2] Then
			$iX = ($iWidth - $aCall[1]) / 2
			$iY = ($iHeight - $aCall[2]) / 2
			$iWidth = $aCall[1]
			$iHeight = $aCall[2]
			If $iY + $iHeight + 80 > $aClientSize[1] Then $iY = $aClientSize[1] - 80 - $aCall[2]
		EndIf
	EndIf
	$oVideoWindow.SetWindowPosition("long", "long", $iX, "long", $iY, "long", $iWidth, "long", $iHeight)
	Return 1
EndFunc   ;==>_SetSize

Func _InitBuilder(ByRef $oGraphBuilder, ByRef $oMediaControl, ByRef $oMediaEventEx, ByRef $oVideoWindow, ByRef $oMediaPosition, ByRef $oBasicAudio, ByRef $oBasicVideo)

	Local $tCLSID_FilterGraph = _AutoItObject_CLSIDFromString("{e436ebb3-524f-11ce-9f53-0020af0ba770}")
	Local $tIID_IGraphBuilder = _AutoItObject_CLSIDFromString("{56a868a9-0ad4-11ce-b03a-0020af0ba770}")

	Local $tIID_IMediaPosition = _AutoItObject_CLSIDFromString("{56a868b2-0ad4-11ce-b03a-0020af0ba770}")
	Local $tIID_IMediaControl = _AutoItObject_CLSIDFromString("{56A868B1-0AD4-11CE-B03A-0020AF0BA770}")
	Local $tIID_IMediaEventEx = _AutoItObject_CLSIDFromString("{56A868C0-0AD4-11CE-B03A-0020AF0BA770}")
	Local $tIID_IVideoWindow = _AutoItObject_CLSIDFromString("{56A868B4-0AD4-11CE-B03A-0020AF0BA770}")
	Local $tIID_IBasicAudio = _AutoItObject_CLSIDFromString("{56a868b3-0ad4-11ce-b03a-0020af0ba770}")
	Local $tIID_IBasicVideo = _AutoItObject_CLSIDFromString("{56a868b5-0ad4-11ce-b03a-0020af0ba770}")

	Local $pGraphBuilder
	_AutoItObject_CoCreateInstance(DllStructGetPtr($tCLSID_FilterGraph), 0, 1, DllStructGetPtr($tIID_IGraphBuilder), $pGraphBuilder)
	If Not $pGraphBuilder Then Return SetError(1, 0, 0)

	Local $tagInterface = "QueryInterface;" & _
			"AddRef;" & _
			"Release;" & _ ; IUnknown
			"AddFilter;" & _
			"RemoveFilter;" & _
			"EnumFilters;" & _
			"FindFilterByName;" & _
			"ConnectDirect;" & _
			"Reconnect;" & _
			"Disconnect;" & _
			"SetDefaultSyncSource;" & _ ; IFilterGraph
			"Connect;" & _
			"Render;" & _
			"RenderFile;" & _
			"AddSourceFilter;" & _
			"SetLogFile;" & _
			"Abort;" & _
			"ShouldOperationContinue;" ; IGraphBuilder

	; Wrapp IGraphBuilder interface
	$oGraphBuilder = _AutoItObject_WrapperCreate($pGraphBuilder, $tagInterface)
	If @error Then Return SetError(2, 0, 0)

	; IMediaControl IDispatch
	Local $aCall = $oGraphBuilder.QueryInterface("int", "ptr", Number(DllStructGetPtr($tIID_IMediaControl)), "idispatch*", 0) ; or directly "idispatch*"
	If IsArray($aCall) Then
		$oMediaControl = $aCall[2]
	Else
		Return SetError(3, 0, 0)
	EndIf

	; IMediaEventEx IDispatch
	$aCall = $oGraphBuilder.QueryInterface("int", "ptr", Number(DllStructGetPtr($tIID_IMediaEventEx)), "idispatch*", 0) ; or directly "idispatch*"
	If IsArray($aCall) Then
		$oMediaEventEx = $aCall[2]
	Else
		Return SetError(4, 0, 0)
	EndIf

	; Get pointer to IVideoWindow interface
	$aCall = $oGraphBuilder.QueryInterface("int", "ptr", Number(DllStructGetPtr($tIID_IVideoWindow)), "ptr*", 0)
	If IsArray($aCall) Then
		$pVideoWindow = $aCall[2]
	Else
		Return SetError(5, 0, 0)
	EndIf

	; IVideoWindow is dual interface. Defining vTable methods:
	Local $tagIVideoWindow = "QueryInterface;" & _
			"AddRef;" & _
			"Release;" & _ ; IUnknown
			"GetTypeInfoCount;" & _
			"GetTypeInfo;" & _
			"GetIDsOfNames;" & _
			"Invoke;" & _ ; IDispatch
			"put_Caption;" & _
			"get_Caption;" & _
			"put_WindowStyle;" & _
			"get_WindowStyle;" & _
			"put_WindowStyleEx;" & _
			"put_WindowStyleEx;" & _
			"put_AutoShow;" & _
			"get_AutoShow;" & _
			"put_WindowState;" & _
			"get_WindowState;" & _
			"put_BackgroundPalette;" & _
			"get_BackgroundPalette;" & _
			"put_Visible;" & _
			"get_Visible;" & _
			"put_Left;" & _
			"get_Left;" & _
			"put_Width;" & _
			"get_Width;" & _
			"put_Top;" & _
			"get_Top;" & _
			"put_Height;" & _
			"get_Height;" & _
			"put_Owner;" & _
			"get_Owner;" & _
			"put_MessageDrain;" & _
			"get_MessageDrain;" & _
			"get_BorderColor;" & _
			"put_BorderColor;" & _
			"get_FullScreenMode;" & _
			"put_FullScreenMode;" & _
			"SetWindowForeground;" & _
			"NotifyOwnerMessage;" & _
			"SetWindowPosition;" & _
			"GetWindowPosition;" & _
			"GetMinIdealImageSize;" & _
			"GetMaxIdealImageSize;" & _
			"GetRestorePosition;" & _
			"HideCursor;" & _
			"IsCursorHidden;" ; IVideoWindow

	; Wrapp it:
	$oVideoWindow = _AutoItObject_WrapperCreate($pVideoWindow, $tagIVideoWindow)
	If @error Then Return SetError(6, 0, 0)

	; Get pointer to IMediaPosition interface
	$aCall = $oGraphBuilder.QueryInterface("int", "ptr", Number(DllStructGetPtr($tIID_IMediaPosition)), "ptr*", 0)
	If IsArray($aCall) Then
		$pMediaPosition = $aCall[2]
	Else
		Return SetError(7, 0, 0)
	EndIf

	; IMediaPosition is dual interface. Defining vTable methods:
	Local $tagIMediaPosition = "QueryInterface;" & _
			"AddRef;" & _
			"Release;" & _ ; IUnknown
			"GetTypeInfoCount;" & _
			"GetTypeInfo;" & _
			"GetIDsOfNames;" & _
			"Invoke;" & _ ; IDispatch
			"get_Duration;" & _
			"put_CurrentPosition;" & _
			"get_CurrentPosition;" & _
			"get_StopTime;" & _
			"put_StopTime;" & _
			"get_PrerollTime;" & _
			"put_PrerollTime;" & _
			"put_Rate;" & _
			"get_Rate;" & _
			"CanSeekForward;" & _
			"CanSeekBackward;" ; IMediaPosition

	; Wrapp it:
	$oMediaPosition = _AutoItObject_WrapperCreate($pMediaPosition, $tagIMediaPosition)
	If @error Then Return SetError(8, 0, 0)

	; Get pointer to IBasicAudio interface
	$aCall = $oGraphBuilder.QueryInterface("int", "ptr", Number(DllStructGetPtr($tIID_IBasicAudio)), "ptr*", 0)
	If IsArray($aCall) Then
		$pBasicAudio = $aCall[2]
	Else
		Return SetError(9, 0, 0)
	EndIf

	; IBasicAudio is dual interface. Defining vTable methods:
	Local $tagIBasicAudio = "QueryInterface;" & _
			"AddRef;" & _
			"Release;" & _ ; IUnknown
			"GetTypeInfoCount;" & _
			"GetTypeInfo;" & _
			"GetIDsOfNames;" & _
			"Invoke;" & _ ; IDispatch
			"put_Volume;" & _
			"get_Volume;" & _
			"put_Balance;" & _
			"get_Balance;" ; IBasicAudio

	; Wrapp it:
	$oBasicAudio = _AutoItObject_WrapperCreate($pBasicAudio, $tagIBasicAudio)
	If @error Then Return SetError(10, 0, 0)

	; Get pointer to IBasicVideo interface
	$aCall = $oGraphBuilder.QueryInterface("int", "ptr", Number(DllStructGetPtr($tIID_IBasicVideo)), "ptr*", 0)
	If IsArray($aCall) Then
		$pIBasicVideo = $aCall[2]
	Else
		Return SetError(11, 0, 0)
	EndIf

	; IBasicVideo is dual interface. Defining vTable methods:
	Local $tagIBasicVideo = "QueryInterface;" & _
			"AddRef;" & _
			"Release;" & _ ; IUnknown
			"GetTypeInfoCount;" & _
			"GetTypeInfo;" & _
			"GetIDsOfNames;" & _
			"Invoke;" & _ ; IDispatch
			"get_AvgTimePerFrame;" & _
			"get_BitRate;" & _
			"get_BitErrorRate;" & _
			"get_VideoWidth;" & _
			"get_VideoHeight;" & _
			"put_SourceLeft;" & _
			"get_SourceLeft;" & _
			"put_SourceWidth;" & _
			"get_SourceWidth;" & _
			"put_SourceTop;" & _
			"get_SourceTop;" & _
			"put_SourceHeight;" & _
			"get_SourceHeight;" & _
			"put_DestinationLeft;" & _
			"get_DestinationLeft;" & _
			"put_DestinationWidth;" & _
			"get_DestinationWidth;" & _
			"put_DestinationTop;" & _
			"get_DestinationTop;" & _
			"put_DestinationHeight;" & _
			"get_DestinationHeight;" & _
			"SetSourcePosition;" & _
			"GetSourcePosition;" & _
			"SetDefaultSourcePosition;" & _
			"SetDestinationPosition;" & _
			"GetDestinationPosition;" & _
			"SetDefaultDestinationPosition;" & _
			"GetVideoSize;" & _
			"GetVideoPaletteEntries;" & _
			"GetCurrentImage;" & _
			"IsUsingDefaultSource;" & _
			"IsUsingDefaultDestination;" ; IBasicVideo

	; Wrapp it:
	$oBasicVideo = _AutoItObject_WrapperCreate($pIBasicVideo, $tagIBasicVideo)
	If @error Then Return SetError(12, 0, 0)

	Return 1 ; All ok!

EndFunc   ;==>_InitBuilder

Func _ReleaseBuilder(ByRef $oGraphBuilder, ByRef $oMediaControl, ByRef $oMediaEventEx, ByRef $oVideoWindow, ByRef $oMediaPosition, ByRef $oBasicAudio, ByRef $oBasicVideo)
	If IsObj($oMediaControl) Then $oMediaControl.Stop()
	If IsObj($oVideoWindow) Then $oVideoWindow.put_Visible("long", "long", 0)
	If IsObj($oVideoWindow) Then $oVideoWindow.put_Owner("long", "hwnd", 0)
	$oGraphBuilder = 0
	$oMediaControl = 0
	$oMediaEventEx = 0
	$oVideoWindow = 0
	$oMediaPosition = 0
	$oBasicAudio = 0
	$oBasicVideo = 0
EndFunc   ;==>_ReleaseBuilder


Func _AdjustMediaViewPos($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg
	If $hWnd = $hGUI Then
		Local $aClientSize[2] = [BitAND($lParam, 65535), BitShift($lParam, 16)]
		Local $iX, $iY
		Local $iWidth = $aClientSize[0], $iHeight = $aClientSize[1] - 80
		If IsObj($oBasicVideo) Then
			Local $aCall = $oBasicVideo.GetVideoSize("long", "long*", 0, "long*", 0)
			If IsArray($aCall) Then
				If $iUnFit Then
					If $iWidth > $aCall[1] Or $iHeight > $aCall[2] Then
						$iX = ($iWidth - $aCall[1]) / 2
						$iY = ($iHeight - $aCall[2]) / 2
						$iWidth = $aCall[1]
						$iHeight = $aCall[2]
						If $iY + $iHeight + 80 > $aClientSize[1] Then $iY = $aClientSize[1] - 80 - $aCall[2]
					EndIf
				EndIf
			EndIf
		EndIf
		If IsObj($oVideoWindow) Then $oVideoWindow.SetWindowPosition("long", "long", $iX, "long", $iY, "long", $iWidth, "long", $iHeight)
	EndIf
EndFunc   ;==>_AdjustMediaViewPos

Func _SetMinMax($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg, $wParam
	If $hWnd = $hGUI Then
		Local $tMINMAXINFO = DllStructCreate("int;int;" & _
				"int MaxSizeX; int MaxSizeY;" & _
				"int MaxPositionX;int MaxPositionY;" & _
				"int MinTrackSizeX; int MinTrackSizeY;" & _
				"int MaxTrackSizeX; int MaxTrackSizeY", _
				$lParam)
		DllStructSetData($tMINMAXINFO, "MinTrackSizeX", 520)
		DllStructSetData($tMINMAXINFO, "MinTrackSizeY", 80)
	EndIf
EndFunc   ;==>_SetMinMax
