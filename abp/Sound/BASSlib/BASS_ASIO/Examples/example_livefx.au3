#include <GUIConstantsEx.au3>
#include <BASSASIO.au3>
#include <array.au3>

Global $hFX[5], $FXHandle[5], $FX[5] = [0, $BASS_FX_DX8_CHORUS, $BASS_FX_DX8_REVERB, $BASS_FX_DX8_GARGLE, $BASS_FX_DX8_FLANGER]

MsgBox(0, ' Feedback warning', 'Do not set the input to "WAVE" or "What you hear"(etc...) with' & @CRLF & 'the level set high, as that is likely to result in nasty feedback.')

_BASS_STARTUP()
_BASS_ASIO_STARTUP()
$bass_asio_cb_dll = DllOpen("asiocb.dll")

$hGui = GUICreate("BassAsioTest - LiveFX", 320, 140)
$hMeterL = GUICtrlCreateProgress(10, 10, 300, 10)
$hMeterR = GUICtrlCreateProgress(10, 30, 300, 10)
$hLevel = GUICtrlCreateSlider(10, 50, 300, 20)
$hFX[1] = GUICtrlCreateCheckbox("CHORUS", 50, 80)
$hFX[2] = GUICtrlCreateCheckbox("REVERB", 180, 80)
$hFX[3] = GUICtrlCreateCheckbox("GARGLE", 50, 100)
$hFX[4] = GUICtrlCreateCheckbox("FLANGER", 180, 100)
GUISetState()


$Devices = _EnumDevices()
_ArrayDisplay($Devices)


_BASS_SetConfig($BASS_CONFIG_UPDATEPERIOD, 0)
_BASS_ASIO_Init(0)
If @error Then
	MsgBox(0, "ERROR " & @error, "Can´t initialize Asio")
	Exit
EndIf

$Channels = _BASS_ASIO_GetInfo()
_ArrayDisplay($Channels)

$Samplerate = _BASS_ASIO_GetRate()
_BASS_Init(0, 0, $Samplerate)

$StreamHandle = _BASS_StreamCreate($Samplerate, 2, BitOR($BASS_SAMPLE_FLOAT, $BASS_STREAM_DECODE), $STREAMPROC_DUMMY, 0)
_BASS_ChannelSetFX($StreamHandle, $BASS_FX_DX8_REVERB, 0);

_BASS_ASIO_CB_ChannelEnable($bass_asio_cb_dll, 1, 0, 0)
_BASS_ASIO_CB_ChannelEnable($bass_asio_cb_dll, 0, 0, $StreamHandle)
_BASS_ASIO_ChannelJoin(1, 1, 0)
_BASS_ASIO_ChannelJoin(0, 1, 0)
_BASS_ASIO_ChannelSetFormat(1, 0, $BASS_ASIO_FORMAT_FLOAT)
_BASS_ASIO_ChannelSetFormat(0, 0, $BASS_ASIO_FORMAT_FLOAT)
_BASS_ASIO_Start($Channels[4]) ;$Channels[4] is the minimum buffersize, so the example is as fast as possible

_BASS_ASIO_ChannelSetVolume(0, 0, 0)
_BASS_ASIO_ChannelSetVolume(0, 1, 0)

While 1
	$levell = _BASS_ASIO_ChannelGetLevel(0, 0)
	$levelr = _BASS_ASIO_ChannelGetLevel(0, 1)
	GUICtrlSetData($hMeterL, $levell * 100)
	GUICtrlSetData($hMeterR, $levelr * 100)

	$msg = GUIGetMsg()

	For $i = 1 To 4
		If $msg = $hFX[$i] Then
			If GUICtrlRead($hFX[$i]) = $GUI_CHECKED Then
				$FXHandle[$i] = _BASS_ChannelSetFX($StreamHandle, $FX[$i], $i)
			Else
				_BASS_ChannelRemoveFX($StreamHandle, $FXHandle[$i])
			EndIf
		EndIf
	Next

	If $msg = $hLevel Then
		_BASS_ASIO_ChannelSetVolume(0, 0, GUICtrlRead($hLevel) / 100)
		_BASS_ASIO_ChannelSetVolume(0, 1, GUICtrlRead($hLevel) / 100)
	EndIf


	If $msg = -3 Then ExitLoop

	Sleep(40)
WEnd



_BASS_ASIO_Free()



Func _EnumDevices()
	Local $device = _BASS_ASIO_GetDeviceInfo(0), $count = 0, $aRet[2]
	While $device[0]
		$count += 1
		ReDim $aRet[$count + 1]
		$aRet[$count] = $device[1]
		$device = _BASS_ASIO_GetDeviceInfo($count)
		If @error Then ExitLoop
	WEnd
	$aRet[0] = $count
	Return $aRet
EndFunc   ;==>_EnumDevices
