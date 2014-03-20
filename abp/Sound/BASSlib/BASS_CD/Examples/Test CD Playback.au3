#include <BASSCDConstants.au3>
#include <BASSCD.au3>
#include <BASS\Bass.au3>
#include <BASS\BassConstants.au3>

_BASS_Startup()
_BASS_CD_Startup()

_BASS_Init(0, -1, 44100, 0, "")
;Check if bass iniated.  If not, we cannot continue.
If @error Then
	MsgBox(0, "Error", "Could not initialize audio")
	Exit
EndIf

$MusicHandle = _BASS_CD_StreamCreate(0, 0, $BASS_SAMPLE_LOOP)

;Check if we opened the file correctly.
If @error Then
	MsgBox(0, "Error", "Could not load audio file" & @CR & "Error = " & @error)
	Exit
EndIf

;Iniate playback
_BASS_ChannelPlay($MusicHandle, 1)

;Play for 10 seconds.
Sleep(10000)

;Get current track
$track = _BASS_CD_StreamGetTrack($MusicHandle)
If @error Then
	MsgBox(0, "Error", "Could not get next track")
	Exit
EndIf
$track = $track[0] + 1
;Get total number of tracks on disc
$totalTracks = _BASS_CD_GetTracks(0)

;Make sure our track isn't past the total number of tracks
If $track > $totalTracks Then $track = 0

;Play next track
_BASS_CD_StreamSetTrack($MusicHandle, $track)
If @error Then
	MsgBox(0, "Error", "Could not set next track")
	Exit
EndIf

;Play for 10 seconds
Sleep(10000)

;Exit
Exit

Func OnAutoItExit()
	;Free Resources
	_BASS_Free()
EndFunc   ;==>OnAutoItExit