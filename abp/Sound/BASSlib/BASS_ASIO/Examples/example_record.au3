#include <BASSENC.au3>
#include <BASSASIO.au3>

_BASS_STARTUP()
_BASS_ASIO_STARTUP()
_BASS_ENC_STARTUP()
$bass_asio_cb_dll = DllOpen("asiocb.dll")

$hGui = GUICreate("AsioTest - Record", 320, 80)
$hMeterL = GUICtrlCreateProgress(10, 10, 300, 10)
$hMeterR = GUICtrlCreateProgress(10, 30, 300, 10)
GUICtrlCreateLabel("Filesize:", 10, 50, 100)
$hFilesize = GUICtrlCreateLabel("", 120, 50, 100)
GUISetState()

_BASS_ASIO_Init(0)
If @error Then
	MsgBox(0, "ERROR " & @error, "Can´t initialize Asio")
	Exit
EndIf
$Samplerate = _BASS_ASIO_GetRate()
_BASS_Init(0, 0, $Samplerate)
$StreamHandle = _BASS_StreamCreate($Samplerate, 2, $BASS_STREAM_DECODE, $STREAMPROC_DUMMY, 0)
_BASS_ChannelPlay($StreamHandle, 0)
$Channels = _BASS_ASIO_GetInfo()

$EncodeHandle = _BASS_Encode_Start($StreamHandle, @ScriptDir & '\Test.wav', BitOR($BASS_ENCODE_PCM, $BASS_ENCODE_FP_16BIT))

_BASS_ASIO_CB_ChannelEnable($bass_asio_cb_dll, 1, 0, $StreamHandle)
_BASS_ASIO_ChannelJoin(1, 1, 0);
_BASS_ASIO_ChannelSetFormat(1, 0, $BASS_ASIO_FORMAT_16BIT)
_BASS_ASIO_ChannelSetFormat(1, 1, $BASS_ASIO_FORMAT_16BIT)
_BASS_ASIO_Start($Channels[6])

While GUIGetMsg() <> -3
	GUICtrlSetData($hFilesize, FileGetSize(@ScriptDir & "\Test.wav"))
	$levelL = _BASS_ASIO_ChannelGetLevel(1, 0)
	$levelR = _BASS_ASIO_ChannelGetLevel(1, 1)
	GUICtrlSetData($hMeterL, $levelL * 100)
	GUICtrlSetData($hMeterR, $levelR * 100)
	Sleep(100)
WEnd

_BASS_ASIO_Free()