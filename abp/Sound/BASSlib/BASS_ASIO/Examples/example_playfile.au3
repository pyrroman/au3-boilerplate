#include <BASSASIO.au3>

_BASS_STARTUP("BASS.dll")
_BASS_ASIO_STARTUP()
$bass_asio_cb_dll = DllOpen("asiocb.dll")

_BASS_ASIO_Init(0)
If @error Then
	MsgBox(0, "ERROR " & @error, "Can´t initialize Asio")
	Exit
EndIf

$Samplerate = _BASS_ASIO_GetRate($bass_asio_dll)
_BASS_Init(0, 0, $Samplerate, 0, "")

$file = FileOpenDialog("Open...", "", "MP3 Files (*.mp3)")

$MusicHandle = _BASS_StreamCreateFile(False, $file, 0, 0, BitOR($BASS_SAMPLE_FLOAT, $BASS_STREAM_DECODE))
If @error Then
	MsgBox(0, "Error", "Could not load audio file" & @CR & "Error = " & @error)
	Exit
EndIf

_BASS_ASIO_CB_ChannelEnable($bass_asio_cb_dll, 0, 0, $MusicHandle)
$Channels = _BASS_ASIO_GetInfo($bass_asio_dll)
_BASS_ASIO_ChannelJoin(0, 1, 0);
_BASS_ASIO_ChannelSetFormat(0, 0, $BASS_ASIO_FORMAT_FLOAT)
_BASS_ASIO_Start($Channels[6])

_BASS_ChannelPlay($MusicHandle, 1)

$song_length = _BASS_ChannelGetLength($MusicHandle, $BASS_POS_BYTE)
While 1
	Sleep(20)
	$current = _BASS_ChannelGetPosition($MusicHandle, $BASS_POS_BYTE)
	$percent = Round(($current / $song_length) * 100, 0)
	ToolTip("Completed " & $percent & "%", 0, 0)
	If $current >= $song_length Then ExitLoop
WEnd

_BASS_Free()
