#include <GUIConstantsEx.au3>
#include <..\..\BASS\Bass.au3>
#include <..\BassFXConstants.au3>
#include <array.au3>

Global $ChorusHandle, $EchoHandle, $ReverbHandle

_BASS_STARTUP()

GUICreate("BassFX Test", 320, 140)
$Meter = GUICtrlCreateProgress(10, 10, 300, 20)
$Chorus = GUICtrlCreateCheckbox("BASS_FX_BFX_CHORUS", 10, 40)
$Echo = GUICtrlCreateCheckbox("BASS_FX_BFX_ECHO2", 10, 70)
$Reverb = GUICtrlCreateCheckbox("BASS_FX_DX8_REVERB (requires DirectX 8 or above)", 10, 100)
GUISetState()

_BASS_Init(0, -1, 44100, 0, "")
$MusicHandle = _BASS_StreamCreateFile(False, @ScriptDir & "\example.mp3", 0, 0, 0)
_BASS_ChannelPlay($MusicHandle, 1)
$song_length = _BASS_ChannelGetLength($MusicHandle, $BASS_POS_BYTE)

While 1
	Sleep(20)
	$current = _BASS_ChannelGetPosition($MusicHandle, $BASS_POS_BYTE)
	If $current = 0 Then _BASS_ChannelPlay($MusicHandle, 1)
	$percent = Round(($current / $song_length) * 100, 0)
	GUICtrlSetData($Meter, $percent)
	If $current >= $song_length Then _BASS_ChannelSetPosition($MusicHandle, 1, $BASS_POS_BYTE)

	$msg = GUIGetMsg()
	Select
		Case $msg = $Chorus
			If GUICtrlRead($Chorus) = $GUI_CHECKED Then
				$ChorusHandle = _BASS_ChannelSetFX($MusicHandle, $BASS_FX_BFX_CHORUS, 5)
				$param = _BASS_FXGetParameters($ChorusHandle)
				_BASS_FXSetParameters($ChorusHandle, "0.5|0.4|0.5|1|10|5|" & $BASS_BFX_CHANALL)
			Else
				_BASS_ChannelRemoveFX($MusicHandle, $ChorusHandle)
			EndIf
		Case $msg = $Echo
			If GUICtrlRead($Echo) = $GUI_CHECKED Then
				$EchoHandle = _BASS_ChannelSetFX($MusicHandle, $BASS_FX_BFX_ECHO2, 6)
				_BASS_FXSetParameters($EchoHandle, "1|0.3|0.3|0.4|" & $BASS_BFX_CHANALL)
			Else
				_BASS_ChannelRemoveFX($MusicHandle, $EchoHandle)
			EndIf
		Case $msg = $Reverb
			If GUICtrlRead($Reverb) = $GUI_CHECKED Then
				$ReverbHandle = _BASS_ChannelSetFX($MusicHandle, $BASS_FX_DX8_REVERB, 7)
				_BASS_FXSetParameters($ReverbHandle, "0|-6|2000|0.001")
			Else
				_BASS_ChannelRemoveFX($MusicHandle, $ReverbHandle)
			EndIf
		Case $msg = -3
			ExitLoop
	EndSelect
WEnd

_BASS_Free()