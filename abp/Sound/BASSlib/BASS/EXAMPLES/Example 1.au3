#include <Bass.au3>
#include <BassConstants.au3>

Global $playing_state = -1
;Open Bass.DLL.  Required for all function calls.
_BASS_STARTUP ("BASS.dll")


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
$MusicHandle = _BASS_StreamCreateFile(False, $file, 0, 0, 0)

;Check if we opened the file correctly.
If @error Then
	MsgBox(0, "Error", "Could not load audio file" & @CR & "Error = " & @error)
	Exit
EndIf

;Iniate playback
_BASS_ChannelPlay($MusicHandle, 1)

;Get the length of the song in bytes.
$song_length = _BASS_ChannelGetLength($MusicHandle, $BASS_POS_BYTE)
While 1
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
