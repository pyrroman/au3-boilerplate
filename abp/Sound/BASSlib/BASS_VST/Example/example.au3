#include <BassVST.au3>
#include <BassVSTConstants.au3>
#include <Bass.au3>
#include <BassConstants.au3>


;$vst_dll = @ScriptDir & "\PushTec.dll"
$vst_dll = @ScriptDir & "\KarmaFX Reverb.dll"

_BASS_STARTUP ("BASS.dll")
_BASS_VST_STARTUP ("bass_vst.dll")

$GUI = GuiCreate ("Parent GUI", 800, 600)

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

$chan = _BASS_VST_ChannelSetDSP($MusicHandle, $vst_dll, 0, 0)

;Iniate playback
_BASS_ChannelPlay($MusicHandle, False)

;Get the length of the song in bytes.
$song_length = _BASS_ChannelGetLength($MusicHandle, $BASS_POS_BYTE)

_BASS_VST_EmbedEditor($chan, $GUI)

GUISetState (@SW_SHOW)
While 1
	If GUIGetMsg () = -3 Then Exit
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
