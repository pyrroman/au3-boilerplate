#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
#region Header

#include <ITaskBarList.au3>
#include <ButtonConstants.au3>
#include <GuiImageList.au3>
#include <StaticConstants.au3>

$hGUI = GUICreate("ThumbBar", 253, 140)
$cbEnabled = GUICtrlCreateCheckbox("Enabled", 33, 48, 73, 19)
$cbHidden = GUICtrlCreateCheckbox("Hidden", 33, 78, 73, 19)
$cbBackground = GUICtrlCreateCheckbox("No BackGround", 123, 48, 97, 19)
$cbDisabled = GUICtrlCreateCheckbox("Disabled", 33, 108, 73, 19)
$cbInteractive = GUICtrlCreateCheckbox("Non Interactive", 123, 78, 91, 19)
$cbDismission = GUICtrlCreateCheckbox("Dismission Click", 123, 108, 91, 19)
$Label1 = GUICtrlCreateLabel("Button Flags", 72, 12, 108, 28)
GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
GUICtrlSetState($cbEnabled, $GUI_CHECKED)
GUICtrlSetState($cbEnabled, $GUI_DISABLE)
GUIRegisterMsg($WM_COMMAND, '_MY_WM_COMMAND')
GUISetState(@SW_SHOW)

_ITaskBar_CreateTaskBarObj()

$Wow64 = ""
If @AutoItX64 Then $Wow64 = "\Wow6432Node"
$sPath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE" & $Wow64 & "\AutoIt v3\AutoIt", "InstallDir") & "\Examples\GUI\Advanced\Images"

$hImageList = _GUIImageList_Create()
_GUIImageList_AddBitmap($hImageList, $sPath & "\Green.bmp")
_GUIImageList_AddBitmap($hImageList, $sPath & "\Blue.bmp")
_ITaskBar_SetTBImageList($hGUI, $hImageList)

$but1 = _ITaskBar_CreateTBButton('IE', @ProgramFilesDir & '\Internet Explorer\iexplore.exe')
$but2 = _ITaskBar_CreateTBButton('Left ToolTip', @ScriptDir & '\Icons\Left.ico')
$but3 = _ITaskBar_CreateTBButton('Right ToolTip', @ScriptDir & '\Icons\Right.ico')
$but4 = _ITaskBar_CreateTBButton('Green', -1, 0)
$but5 = _ITaskBar_CreateTBButton('Blue', -1, 1)
$but6 = _ITaskBar_CreateTBButton('AutoIt', @AutoItExe);
_ITaskBar_AddTBButtons($hGUI)

_ITaskBar_SetOverlayIcon($hGUI, @ProgramFilesDir & '\Internet Explorer\iexplore.exe')

While 1
	Switch GUIGetMsg()
		Case $cbHidden, $cbEnabled, $cbBackground, $cbDisabled, $cbInteractive, $cbDismission
			Global $iFlags = $THBF_ENABLED
			If BitAND(GUICtrlRead($cbHidden), $GUI_CHECKED) Then $iFlags += $THBF_HIDDEN
			If BitAND(GUICtrlRead($cbBackground), $GUI_CHECKED) Then $iFlags = BitOR($iFlags, $THBF_NOBACKGROUND)
			If BitAND(GUICtrlRead($cbDisabled), $GUI_CHECKED) Then $iFlags = BitOR($iFlags, $THBF_DISABLED)
			If BitAND(GUICtrlRead($cbInteractive), $GUI_CHECKED) Then $iFlags = BitOR($iFlags, $THBF_NONINTERACTIVE)
			If BitAND(GUICtrlRead($cbDismission), $GUI_CHECKED) Then $iFlags = BitOR($iFlags, $THBF_DISMISSONCLICK)
			For $i = $but1 To $but6;set all buttons the same flag
				_ITaskBar_UpdateTBButton($i, $iFlags)
				If @error Then ConsoleWrite(_Get_HRESULT_ERROR_STRING(@error) & @CRLF)
			Next
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd

Func _MY_WM_COMMAND($hWnd, $msg, $wParam, $lParam)

	Local $iMsg = _WinAPI_HiWord($wParam)

	If $iMsg = $THBN_CLICKED Then
		Local $iID = _WinAPI_LoWord($wParam)
		Switch $iID
			Case $but1
				ConsoleWrite('IE Button has been Pressed.' & @CRLF)
			Case $but2
				ConsoleWrite('Left Button has been Pressed.' & @CRLF)
			Case $but3
				ConsoleWrite('Right Button has been Pressed.' & @CRLF)
			Case $but4
				ConsoleWrite('Green Button has been Pressed.' & @CRLF)
			Case $but5
				ConsoleWrite('Blue Button has been Pressed.' & @CRLF)
			Case $but6
				ConsoleWrite('Autoit Button has been Pressed.' & @CRLF)
		EndSwitch
	EndIf

	Return $GUI_RUNDEFMSG

EndFunc   ;==>_MY_WM_COMMAND