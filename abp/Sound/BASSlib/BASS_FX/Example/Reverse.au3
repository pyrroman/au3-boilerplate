#include <Bass.au3>
#include <BassConstants.au3>
#include <BassFX.au3>
#include <BassFXConstants.au3>

Global $playing_state = -1
;Startup Bass & BassFX.  Also check if loading failed.
_BASS_STARTUP ("BASS.dll")
If @error = -1 Then
	MsgBox (0, "", "DLL Does not exist?  Please check file exists.")
	Exit
EndIf

_BASS_FX_Startup("bass_fx.dll")
If @error = -1 Then
	MsgBox (0, "", "DLL Does not exist?  Please check file exists.")
	Exit
EndIf

;Initalize bass.  Required for most functions.
_BASS_Init(0, -1, 44100, 0, "")

;Check if bass iniated.  If not, we cannot continue.
If @error Then
	MsgBox(0, "Error", "Could not initialize audio")
	Exit
EndIf

;Prompt the user to select a MP3 file
$file = FileOpenDialog("Open...", "", "MP3 Files (*.mp3)")

;Create a stream from that file.
$MusicHandle = _BASS_StreamCreateFile(False, $file, 0, 0, $BASS_STREAM_DECODE)

;Check if we opened the file correctly.
If @error Then
	MsgBox(0, "Error", "Could not load audio file" & @CR & "Error = " & @error)
	Exit
EndIf

$tempo = _BASS_FX_ReverseCreate ($MusicHandle, 10, 0)
_BASS_ChannelSetAttribute ($tempo, $BASS_ATTRIB_REVERSE_DIR, $BASS_FX_RVS_FORWARD)

;Iniate playback
_BASS_ChannelPlay($tempo, 1)


;Get the length of the song in bytes.
$song_length = _BASS_ChannelGetLength($MusicHandle, $BASS_POS_BYTE)
$timer = TimerInit ()
$next = 30000; 30seconds into the song so we can try reduce the chance of going backwards....
$state = 1

While 1
	If TimerDiff ($timer) >= $next Then
		If $state = 1 Then
			_BASS_ChannelSetAttribute ($tempo, $BASS_ATTRIB_REVERSE_DIR, $BASS_FX_RVS_REVERSE)
			$next = Random (3000, 5000, 1)
			ToolTip ("Reverse for " & $next & "ms", 0,0)
			$state = 0
		Else
			_BASS_ChannelSetAttribute ($tempo, $BASS_ATTRIB_REVERSE_DIR, $BASS_FX_RVS_FORWARD)
			$next = Random (5000, 10000, 1)
			ToolTip ("Forward for " & $next & "ms", 0,0)
			$state = 1
		EndIf
		$timer = TimerInit ()
		Sleep (2000)
	EndIf
	Sleep(20)
	;Get the current position in bytes
	$current = _BASS_ChannelGetPosition($MusicHandle, $BASS_POS_BYTE)
	;Calculate the percentage
	$percent = Round(($current / $song_length) * 100, 0)
	;Display that to the user
	ToolTip("Completed " & $percent & "%", 0, 0)
	;If the song is complete, then exit.
	If $current >= $song_length Then ExitLoop
WEnd

Func OnAutoItExit()
	;Free Resources
	_BASS_Free()
EndFunc   ;==>OnAutoItExit
