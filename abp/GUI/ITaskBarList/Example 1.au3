#include <ITaskBarList.au3>
#include <ButtonConstants.au3>

$GUI = GUICreate("Thumbnail Button", 250, 100)
GUICtrlCreateButton('ThumbNailClip', 1, 1)
GUISetState(@SW_SHOW)

$oTaskbar = _ITaskBar_CreateTaskBarObj()
$but1 = _ITaskBar_CreateTBButton('Down ToolTip', @ScriptDir & '\Icons\Down.ico', -1, '_Down_Button')
$but2 = _ITaskBar_CreateTBButton('Left ToolTip', @ScriptDir & '\Icons\Left.ico', -1, '_Left_Button')
$but3 = _ITaskBar_CreateTBButton('', @ScriptDir & '\Icons\Left.ico', -1, '_Right_Button');no tooltip
$but4 = _ITaskBar_CreateTBButton('Internet Explorer',@ProgramFilesDir & '\Internet Explorer\iexplore.exe', -1, '_IE_Button');
$but5 = _ITaskBar_CreateTBButton('AutoIt', @AutoItExe, -1, '_AutoIt_Button');
_ITaskBar_AddTBButtons($GUI)

_ITaskBar_SetThumbNailToolTip($GUI, 'ITaskBarList UDF ToolTip Example')

; Set progressbar to normal state (green)
 _ITaskBar_SetProgressState($GUI, 2)
For $i = 1 to 100
	_ITaskBar_SetProgressValue($GUI, $i)
	Sleep(75)
	; Set progressbar to Paused state (yellow). Notice that even thought the progressbar is in "paused" state, you can
	; still can change the value. Its just an indicator. It doesnt actually pause anything.
	If $i = 25 Then _ITaskBar_SetProgressState($GUI, 8);
	;Set progressbar to Error state (red). This works the same way as paused state. Its just an indicator.
	If $i = 50 Then _ITaskBar_SetProgressState($GUI, 4)
	;Set progressbar back to normal state (green)
	If $i = 75 Then _ITaskBar_SetProgressState($GUI, 2)
Next

;set progressbar Indeterminate
_ITaskBar_SetProgressState($GUI, 1)
Sleep(3000)
;clear progressbar
_ITaskBar_SetProgressState($GUI)

;Set ThumbNail Preview to only show the button from the GUI
MsgBox(0,'SetThumbNailClip','Notice that the ThumbNail preview shows the whole GUI.', 30, $Gui)
_ITaskBar_SetThumbNailClip($GUI, 0, 0, 80, 30)
MsgBox(0,'SetThumbNailClip','Now look again. You should only see the ThumbNailClip Button', 30, $Gui)
; clear thumbnail clip
_ITaskBar_SetThumbNailClip($GUI)

;Add Icon Overlay
_ITaskBar_SetOverlayIcon($GUI, @ProgramFilesDir & '\Internet Explorer\iexplore.exe')
MsgBox(0,'SetOverlayIcon','Taskbar tab should have and Internet Explorer icon overlay. ', 30, $Gui)
; clear icon overlay
_ITaskBar_SetOverlayIcon($GUI)

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE

Func _Down_Button()
	MsgBox(0, 'Button Pressed', 'Down Button has been Pressed.')
EndFunc   ;==>_Down_Button

Func _Left_Button()
	MsgBox(0, 'Button Pressed', 'Left Button has been Pressed.')
EndFunc   ;==>_Left_Button

Func _Right_Button()
	MsgBox(0, 'Button Pressed', 'Right Button has been Pressed.')
EndFunc   ;==>_Right_Button

Func _IE_Button()
	MsgBox(0, 'Button Pressed', 'IE Button has been Pressed.')
EndFunc

Func _AutoIt_Button()
	MsgBox(0, 'Button Pressed', 'AutoIT Button has been Pressed.')
EndFunc