#Include <EditConstants.au3>
#Include <GUIConstantsEx.au3>

#Include "Copy.au3"

Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

Global $hForm, $Input1, $Input2, $Button1, $Button2, $Button3, $Button4, $Label, $Data, $Msg, $Path, $Progress, $State, $Copy = False, $Pause = False
Global $Source = '', $Destination = ''

If Not _Copy_OpenDll() Then
	MsgBox(16, '', 'DLL not found.')
	Exit
EndIf

$hForm = GUICreate('MyGUI', 360, 175)
GUICtrlCreateLabel('Source:', 14, 23, 58, 14)
$Input1 = GUICtrlCreateInput('', 74, 20, 248, 19, BitOR($ES_AUTOHSCROLL, $ES_LEFT, $ES_MULTILINE))
GUICtrlSetState(-1, $GUI_DISABLE)
$Button1 = GUICtrlCreateButton('...', 326, 19, 21, 21)
GUICtrlCreateLabel('Destination:', 14, 55, 58, 14)
$Input2 = GUICtrlCreateInput('', 74, 52, 248, 19, BitOR($ES_AUTOHSCROLL, $ES_LEFT, $ES_MULTILINE))
GUICtrlSetState(-1, $GUI_DISABLE)
$Button2 = GUICtrlCreateButton('...', 326, 51, 21, 21)
$Label = GUICtrlCreateLabel('',14, 91, 332, 14)
$Progress = GUICtrlCreateProgress(14, 106, 332, 16)
$Button3 = GUICtrlCreateButton('Copy', 135, 138, 80, 21)
$Button4 = GUICtrlCreateButton(';', 326, 138, 21, 21)
GUICtrlSetFont(-1, 10, 400, 0, 'Webdings')
GUICtrlSetState(-1, $GUI_DISABLE)
GUISetState()

While 1
	If $Copy Then
		$State = _Copy_GetState()
		If $State[0] Then
			If $State[0] = -1 Then
				; Preparing
			Else
				$Data = Round($State[1] / $State[2] * 100)
				If GUICtrlRead($Progress) <> $Data Then
					GUICtrlSetData($Progress, $Data)
				EndIf
				$Data = StringRegExpReplace($State[6], '^.*\\', '')
				If GUICtrlRead($Label) <> $Data Then
					GUICtrlSetData($Label, $Data)
				EndIf
			EndIf
		Else
			Switch $State[5]
				Case 0
					GUICtrlSetData($Progress, 100)
					MsgBox(64, '', 'Folder was successfully copied.', 0, $hForm)
				Case 1235 ; ERROR_REQUEST_ABORTED
					MsgBox(16, '', 'Folder copying was aborted.', 0, $hForm)
				Case Else
					MsgBox(16, '', 'Folder was not copied.' & @CR & @CR & $State[5], 0, $hForm)
			EndSwitch
			GUICtrlSetState($Button1, $GUI_ENABLE)
			GUICtrlSetState($Button2, $GUI_ENABLE)
			GUICtrlSetState($Button4, $GUI_DISABLE)
			GUICtrlSetData($Progress, 0)
			GUICtrlSetData($Label, '')
			GUICtrlSetData($Button3, 'Copy')
			GUICtrlSetData($Button4, ';')
			$Copy = 0
		EndIf
	EndIf
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Button1
			$Path = FileSelectFolder('Select source folder that to be copied.', '', 2, $Source, $hForm)
			If $Path Then
				GUICtrlSetData($Input1, $Path)
				$Source = $Path
			EndIf
		Case $Button2
			$Path = FileSelectFolder('Select destination folder in which will be copied the source directory.', '', 2, $Destination, $hForm)
			If $Path Then
				GUICtrlSetData($Input2, $Path)
				$Destination = $Path
			EndIf
		Case $Button3
			If $Copy Then
				_Copy_Abort()
			Else
				If (Not $Source) Or (Not $Destination) Then
					MsgBox(16, '', 'The source and destination folders must be specified.', 0, $hForm)
					ContinueLoop
				EndIf
				$Path = $Destination & '\' & StringRegExpReplace($Source, '^.*\\', '')
				If FileExists($Path) Then
					If MsgBox(51, 'Copy', $Path & ' already exists.' & @CR & @CR & 'Do you want to merge folders?', 0, $hForm) <> 6 Then
						ContinueLoop
					EndIf
				EndIf
				GUICtrlSetState($Button1, $GUI_DISABLE)
				GUICtrlSetState($Button2, $GUI_DISABLE)
				GUICtrlSetState($Button4, $GUI_ENABLE)
				GUICtrlSetData($Label, 'Preparing...')
				GUICtrlSetData($Button3, 'Abort')
				_Copy_CopyDir($Source, $Path, 0, 0, 0, '_Copy_CallbackDlg', $hForm)
				$Copy = 1
			EndIf
		Case $Button4
			$Pause = Not $Pause
			If $Pause Then
				GUICtrlSetData($Button4, '4')
			Else
				GUICtrlSetData($Button4, ';')
			EndIf
			_Copy_Pause($Pause)
	EndSwitch
WEnd
