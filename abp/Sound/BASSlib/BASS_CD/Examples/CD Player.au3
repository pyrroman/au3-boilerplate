#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <StaticConstants.au3>
#include <GUIComboBox.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <BASSCDConstants.au3>
#include <BASSCD.au3>
#include <BASS\Bass.au3>
#include <BASS\BassConstants.au3>
#include <Array.au3>
#include <HTTP.au3>;Required for _BASS_CD_GetTracklist

_BASS_Startup()
_BASS_CD_Startup()

_BASS_Init(0, -1, 44100, 0, "")

;Check if bass iniated.  If not, we cannot continue.
If @error Then
	MsgBox(0, "Error", "Could not initialize audio")
	Exit
EndIf

_BASS_PluginLoad("BassCD.dll", 0)
If @error Then
	MsgBox(0, "Error", "Could not load plugin!")
	Exit
EndIf

Global $currentDrive = 0, $MusicHandle, $loaded = False, $playing = False, $idx = 0, $totalTracks, $paused = False

;Create the GUI and controls
$Form1 = GUICreate("Form1", 552, 447, 193, 125)
$btnPrev = GUICtrlCreateButton("Prev", 304, 8, 45, 45, 0)
$btnPlay = GUICtrlCreateButton("Play", 352, 8, 45, 45, 0)
$btnPause = GUICtrlCreateButton("Pause", 400, 8, 45, 45, 0)
$btnStop = GUICtrlCreateButton("Stop", 448, 8, 45, 45, 0)
$btnNext = GUICtrlCreateButton("Next", 496, 8, 45, 45, 0)
$lblTitle = GUICtrlCreateLabel("lblTitle", 8, 60, 540, 17)
$lblAlbum = GUICtrlCreateLabel("lblAlbum", 8, 100, 540, 17)
$lblArtist = GUICtrlCreateLabel("lblArtist", 8, 80, 540, 17)
$hProgress = GUICtrlCreateProgress(8, 120, 538, 20)
GUICtrlSetLimit($hProgress, 100, 0)
$hListview = GUICtrlCreateListView("ID|Title|Artist", 8, 146, 538, 288)
;Set col width
GUICtrlSendMsg(-1, 0x101E, 0, 30)
GUICtrlSendMsg(-1, 0x101E, 1, 250)
GUICtrlSendMsg(-1, 0x101E, 2, 250)

$combo_drives = GUICtrlCreateCombo("Select a drive", 8, 28, 290, 25, $CBS_DROPDOWNLIST)
;Get all CD drives and add them to combo
$drives = DriveGetDrive("CDROM")
For $i = 1 To $drives[0]
	GUICtrlSetData($combo_drives, $drives[$i])
Next
$Label4 = GUICtrlCreateLabel("Please select your CD drive:", 8, 8, 290, 17)

;Show GUI
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $combo_drives
			;If we have slected a drive
			$read = GUICtrlRead($combo_drives)
			;Make sure it isn't default
			If $read <> "Select a drive" Then
				;Diable it.  We don't want the user to change the drive
				GUICtrlSetState($combo_drives, $GUI_DISABLE)
				$loaded = True
				;Let the user know something is happening
				GUISetCursor(15)
				;Get current selection
				$sel = _GUICtrlComboBox_GetCurSel($combo_drives)
				;This is the current drive
				$currentDrive = $sel - 1
				;Create the stream
				$MusicHandle = _BASS_CD_StreamCreate(0, 0, $BASS_SAMPLE_LOOP)
				;Check if we opened the cd correctly.
				If @error Then
					MsgBox(0, "Error", "Could not load audio file" & @CR & "Error = " & @error)
					Exit
				EndIf
				;Get total number of tracks
				$totalTracks = _BASS_CD_GetTracks($currentDrive)

				;Get the CD's ID (MUST BE ONLINE TO CHECK)
				$cdID = _BASS_CD_GetID($currentDrive, $BASS_CDID_CDDB)
				If @error Then
					MsgBox(0, "Error", "Could not get info.  @error = " & @error)
					Exit
				EndIf
				;Get tracklist data from FreeDB.org
				$tracks = _BASS_CD_GetTracklist($cdID[0])
				;Add tracks to listview
				For $i = 1 To $tracks[0][0]
					$idx = _GUICtrlListView_AddItem($hListview, $i)
					_GUICtrlListView_AddSubItem($hListview, $idx, $tracks[$i][0], 1)
					_GUICtrlListView_AddSubItem($hListview, $idx, $tracks[$i][1], 2)
				Next
				;Let the user know the name of the album
				GUICtrlSetData($lblAlbum, $tracks[0][1])
				;Return cursor to normal
				GUISetCursor(2)
			EndIf
		Case $btnStop
			If $loaded Then
				;Stop playback
				_BASS_ChannelStop($MusicHandle)
			EndIf
		Case $btnPlay
			If $loaded Then
				;Play file
				$playing = True
				;Get selected
				$idx = _GUICtrlListView_GetSelectedIndices($hListview)
				;Select the track
				_BASS_CD_StreamSetTrack($MusicHandle, $idx)
				;Play
				_BASS_ChannelPlay($MusicHandle, 1)
				;Show the data
				_SetData($idx)
			Else
				MsgBox(0, "", "Please select a drive containing an Audio CD!")
			EndIf
		Case $btnPause
			If $loaded Then
				If $paused Then
					$pause = False
					;Resume
					_BASS_Start()
				Else
					$pause = True
					;Play
					_BASS_Pause()
				EndIf
			EndIf
		Case $btnNext
			If $loaded Then
				;Goto next song
				$idx += 1
				If $idx >= $totalTracks Then $idx = 0
				_BASS_CD_StreamSetTrack($MusicHandle, $idx)
				_SetData($idx)
			EndIf
		Case $btnPrev
			If $loaded Then
				;Goto previous song
				$idx -= 1
				If $idx < 0 Then $idx = 0
				_BASS_CD_StreamSetTrack($MusicHandle, $idx)
				_SetData($idx)
			EndIf
	EndSwitch
	If $playing Then
		;get current song postion
		$current = _BASS_ChannelGetPosition($MusicHandle, $BASS_POS_BYTE)
		;Calculate percentage
		$perdone = Round(($current / $tracks[$idx + 1][2]) * 100, 0)
		;Show the user this data
		GUICtrlSetData($hProgress, $perdone)
		;Switch to next song if done
		If $perdone >= 100 Then
			$idx += 1
			If $idx >= $totalTracks Then $idx = 0
			_BASS_CD_StreamSetTrack($MusicHandle, $idx)
			_SetData($idx)
		EndIf
	EndIf
WEnd

Func _SetData($indx)
	;Set the lables with Album/Title/Artist
	GUICtrlSetData($lblTitle, $tracks[$indx + 1][0])
	GUICtrlSetData($lblArtist, $tracks[$indx + 1][1])
	GUICtrlSetData($lblAlbum, $tracks[0][1])
EndFunc   ;==>_SetData

;Get tracks
Func _BASS_CD_GetTracklist($params)
	;Set vairiables
	Local $tracklist[1][3]
	Local $tcount = 0
	;This is the disc ID
	$discID = StringLeft($params, StringInStr($params, " ") - 1)
	;username
	$user = @UserName
	;host
	$myhost = "localhost"
	;client
	$clientname = "AutoItTest"
	;version
	$version = "1"
	;type
	$proto = "1"

	;query string
	$cmd = "cmd=cddb+query+" & StringReplace($params, " ", "+") & "&hello=" & $user & "+" & $myhost & "+" & $clientname & "+" & $version & "&proto=" & $proto

	;Host
	$host = "freedb.freedb.org"
	;page
	$page = "/~cddb/cddb.cgi?" & $cmd
	;connect to host
	$socket = _HTTPConnect($host)

	;Send request
	_HTTPGet($host, $page, $socket)
	;get recieved data
	$recv = _HTTPRead($socket, 1)

	;Check if OKAY
	If $recv[0] = 200 Then
		;Yes
		$response = $recv[4]
		;Get the genre so we can get the tracks
		$genre = StringTrimRight(StringTrimLeft($response, StringInStr($response, " ")), StringLen($response) - StringInStr($response, " ", Default, 2) + 1)
		;Get Tracks

		;Command
		$cmd = "cmd=cddb+read+" & $genre & "+" & StringReplace($discID, " ", "+") & "&hello=" & $user & "+" & $myhost & "+" & $clientname & "+" & $version & "&proto=" & $proto
		;page
		$page = "/~cddb/cddb.cgi?" & $cmd
		;connect
		$socket = _HTTPConnect($host)
		;send request
		_HTTPGet($host, $page, $socket)
		;Get response
		$recv = _HTTPRead($socket, 1)

		;Check for success
		If $recv[0] = 200 Then
			$response = $recv[4]
			;Remove comments
			$response = StringTrimLeft($response, StringInStr($response, "#", Default, -1))
			;Split by lines
			$response = StringSplit($response, @LF)
			For $i = 1 To $response[0]
				Select
					Case StringInStr($response[$i], "TTITLE");Line has track data
						;Increase number of tracks
						$tcount += 1
						;Adjust our array
						ReDim $tracklist[$tcount + 1][3]
						;Gets track name
						$trackname = StringTrimRight(StringTrimLeft($response[$i], StringInStr($response[$i], "=")), 1)
						;Split it
						$lists = StringSplit($trackname, " / ", 1)
						;Set value
						$tracklist[$tcount][0] = $lists[2]
						$tracklist[$tcount][1] = $lists[1]
						;get lenght
						$tracklist[$tcount][2] = _BASS_CD_GetTrackLength($currentDrive, $tcount - 1)
					Case StringInStr($response[$i], "DTITLE");Line has disc data
						;Get name
						$trackname = StringTrimRight(StringTrimLeft($response[$i], StringInStr($response[$i], "=")), 1)
						;Split it
						$lists = StringSplit($trackname, " / ", 1)
						;Set it
						$tracklist[0][1] = $lists[2]
						$tracklist[0][2] = $lists[1]
				EndSelect
			Next
			;Update total
			$tracklist[0][0] = $tcount
		EndIf
		;Return array
		Return $tracklist
	EndIf
EndFunc   ;==>_BASS_CD_GetTracklist

Func OnAutoItExit()
	;Free Resources
	_BASS_Free()
EndFunc   ;==>OnAutoItExit