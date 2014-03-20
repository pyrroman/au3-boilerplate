#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>
#include <Bass.au3>
#include <BassConstants.au3>
Dim $dxFX1, $dxFX2, $dxFX3, $dxFX4, $dxFX5, $playing = False, $step = 0, $timer


_BASS_Startup ()
_BASS_Init($BASS_DEVICE_SPEAKERS, -1, 44100, 0, "")

;Check if bass iniated.  If not, we cannot continue.
If @error Then
	MsgBox(0, "Error", "Could not initialize audio")
	Exit
EndIf

$file1 = @ScriptDir & "\SoundFiles\FLeft.wav"
$file2 = @ScriptDir & "\SoundFiles\FCenter.wav"
$file3 = @ScriptDir & "\SoundFiles\FRight.wav"
$file4 = @ScriptDir & "\SoundFiles\RLeft.wav"
$file5 = @ScriptDir & "\SoundFiles\RRight.wav"

$channel1 = _BASS_StreamCreateFile(False, $file1, 0, 0, BitOR($BASS_SAMPLE_MONO, $BASS_SPEAKER_FRONTLEFT))
$channel2 = _BASS_StreamCreateFile(False, $file2, 0, 0, BitOR($BASS_SAMPLE_MONO, $BASS_SPEAKER_CENTER))
$channel3 = _BASS_StreamCreateFile(False, $file3, 0, 0, BitOR($BASS_SAMPLE_MONO, $BASS_SPEAKER_FRONTRIGHT))
$channel4 = _BASS_StreamCreateFile(False, $file4, 0, 0, BitOR($BASS_SAMPLE_MONO, $BASS_SPEAKER_REARLEFT))
$channel5 = _BASS_StreamCreateFile(False, $file5, 0, 0, BitOR($BASS_SAMPLE_MONO, $BASS_SPEAKER_REARRIGHT))

$Form1 = GUICreate("Form1", 559, 360, 193, 125)
$Pic1 = GUICtrlCreatePic(@ScriptDir & "\Images\5_1speaker_setup.jpg", 5, 5, 350, 350, BitOR($SS_NOTIFY, $WS_GROUP, $WS_CLIPSIBLINGS))
$Label1 = GUICtrlCreateLabel("This examples shows how to use bass.au3 in a Multi-Channel Setup, when different sound files are played on different channels." & @CR & @CR & "It also shows use of different types of effects on channels, such as EAX Enviroment and DirectX 8 Effects.", 360, 8, 196, 137, $SS_SUNKEN)
$Combo1 = GUICtrlCreateCombo("Enviroment Effects", 360, 184, 193, 25, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, "=====================|GENERIC|PADDEDCELL|ROOM|BATHROOM|LIVINGROOM|STONEROOM|AUDITORIUM|CONCERTHALL|CAVE|ARENA|HANGAR|CARPETEDHALLWAY|HALLWAY|STONECORRIDOR|ALLEY|FOREST|CITY|MOUNTAINS|QUARRY|PLAIN|PARKINGLOT|SEWERPIPE|UNDERWATER|DRUGGED|DIZZY|PSYCHOTIC")
$Button1 = GUICtrlCreateButton("Test Speaker Setup", 360, 152, 195, 25, 0)
$Exit = GUICtrlCreateButton("Exit", 480, 330, 75, 25, 0)
$hover_frontleft = GUICtrlCreateLabel("", 80, 96, 36, 33, $SS_GRAYFRAME)
$hover_frontright = GUICtrlCreateLabel("", 251, 97, 36, 33, $SS_GRAYFRAME)
$hover_center = GUICtrlCreateLabel("", 156, 138, 52, 33, $SS_GRAYFRAME)
$hover_rearright = GUICtrlCreateLabel("", 303, 232, 36, 33, $SS_GRAYFRAME)
$hover_rearleft = GUICtrlCreateLabel("", 25, 235, 36, 33, $SS_GRAYFRAME)

GUISetState(@SW_SHOW)
GUICtrlSetState($hover_frontleft, $GUI_HIDE)
GUICtrlSetState($hover_frontright, $GUI_HIDE)
GUICtrlSetState($hover_center, $GUI_HIDE)
GUICtrlSetState($hover_rearright, $GUI_HIDE)
GUICtrlSetState($hover_rearleft, $GUI_HIDE)
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $Exit
			Exit
		Case $Combo1
			$string = GUICtrlRead($Combo1)
			If StringInStr($string, "Effects") Or StringInStr($string, "=") Then
				_GUICtrlComboBox_SetCurSel($Combo1, 0)
			Else
				_BASS_SetEAXPreset(Eval("EAX_ENVIRONMENT_" & $string))
			EndIf
		Case $Button1
			$playing = True
			$step = 0
	EndSwitch
	If $playing Then
		If TimerDiff($timer) >= 1500 Then
			$timer = TimerInit()
			$step += 1
			Switch $step
				Case 1
					_BASS_ChannelPlay($channel1, 1)
					GUICtrlSetState($hover_frontleft, $GUI_SHOW)
					GUICtrlSetState($hover_frontright, $GUI_HIDE)
					GUICtrlSetState($hover_center, $GUI_HIDE)
					GUICtrlSetState($hover_rearright, $GUI_HIDE)
					GUICtrlSetState($hover_rearleft, $GUI_HIDE)
				Case 2
					_BASS_ChannelPlay($channel2, 1)
					GUICtrlSetState($hover_frontleft, $GUI_HIDE)
					GUICtrlSetState($hover_frontright, $GUI_HIDE)
					GUICtrlSetState($hover_center, $GUI_SHOW)
					GUICtrlSetState($hover_rearright, $GUI_HIDE)
					GUICtrlSetState($hover_rearleft, $GUI_HIDE)
				Case 3
					_BASS_ChannelPlay($channel3, 1)
					GUICtrlSetState($hover_frontleft, $GUI_HIDE)
					GUICtrlSetState($hover_frontright, $GUI_SHOW)
					GUICtrlSetState($hover_center, $GUI_HIDE)
					GUICtrlSetState($hover_rearright, $GUI_HIDE)
					GUICtrlSetState($hover_rearleft, $GUI_HIDE)
				Case 4
					_BASS_ChannelPlay($channel4, 1)
					GUICtrlSetState($hover_frontleft, $GUI_HIDE)
					GUICtrlSetState($hover_frontright, $GUI_HIDE)
					GUICtrlSetState($hover_center, $GUI_HIDE)
					GUICtrlSetState($hover_rearright, $GUI_HIDE)
					GUICtrlSetState($hover_rearleft, $GUI_SHOW)
				Case 5
					_BASS_ChannelPlay($channel5, 1)
					GUICtrlSetState($hover_frontleft, $GUI_HIDE)
					GUICtrlSetState($hover_frontright, $GUI_HIDE)
					GUICtrlSetState($hover_center, $GUI_HIDE)
					GUICtrlSetState($hover_rearright, $GUI_SHOW)
					GUICtrlSetState($hover_rearleft, $GUI_HIDE)
				Case 6
					GUICtrlSetState($hover_frontleft, $GUI_HIDE)
					GUICtrlSetState($hover_frontright, $GUI_HIDE)
					GUICtrlSetState($hover_center, $GUI_HIDE)
					GUICtrlSetState($hover_rearright, $GUI_HIDE)
					GUICtrlSetState($hover_rearleft, $GUI_HIDE)
					$playing = False
					$step = 0
			EndSwitch
		EndIf
	EndIf
WEnd


Func OnAutoItExit()
	_BASS_Free()
EndFunc   ;==>OnAutoItExit
