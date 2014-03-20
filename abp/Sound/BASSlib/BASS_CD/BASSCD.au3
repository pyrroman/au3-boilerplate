#include-once

;Include Constants and Bass Library
#include <Bass.au3>
#include <BassConstants.au3>
#include <BASSCDConstants.au3>
#include "Misc.au3"

; #INDEX# =======================================================================================================================
; Title .........: BASSCD.au3
; Description ...: Wrapper for BASSCD.dll
; Author ........: Brett Francis (BrettF)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;		_BASS_CD_SetInterface()
;		_BASS_CD_GetInfo()
;		_BASS_CD_Door()
;		_BASS_CD_DoorIsLocked()
;		_BASS_CD_DoorIsOpen()
;		_BASS_CD_IsReady()
;		_BASS_CD_GetTracks()
;		_BASS_CD_GetTrackLength()
;		_BASS_CD_GetTrackPregap()
;		_BASS_CD_GetID()
;		_BASS_CD_GetSpeed()
;		_BASS_CD_SetSpeed()
;		_BASS_CD_Release()
;		_BASS_CD_Startup()
;		_BASS_CD_StreamCreate()
;		_BASS_CD_StreamCreateFile()
;		_BASS_CD_StreamGetTrack()
;		_BASS_CD_StreamSetTrack()
;		_BASS_CD_Analog_Play()
;		_BASS_CD_Analog_PlayFile()
;		_BASS_CD_Analog_Stop()
;		_BASS_CD_Analog_IsActive()
;		_BASS_CD_Analog_GetPosition()
; ===============================================================================================================================
Global $_ghBassCDDll = -1
Global $BASS_CD_DLL_UDF_VER = "2.4.3.0"
Global $BASS_ERR_DLL_NO_EXIST = -1

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_Startup
; Description ...: Starts up BassCD functions.
; Syntax.........: _BASS_CD_Startup($sBassCDDLL)
; Parameters ....:  -	$sBassCDDLL	-	The relative path to BassCD.dll.
; Return values .: Success      - Returns True
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										- $BASS_ERR_DLL_NO_EXIST	-	File could not be found.
;								  If the version of this UDF is not compatabile with this version of Bass, then the following
;								  error will be displayed to the user.  This can be disabled by setting
;										$BASS_STARTUP_BYPASS_VERSIONCHECK = 1
;								  This is the error show to the user:
;									 	This version of Bass.au3 is not made for Bass.dll VX.X.X.X.  Please update.
; Author ........: Prog@ndy
; Modified.......: Brett Francis (BrettF)
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_Startup($sBassCDDLL = "basscd.dll")
	;Check if bass has already been started up.
	If $_ghBassCDDll <> -1 Then Return True
	;Check if $sBassDLL exists.
	If Not FileExists($sBassCDDLL) Then Return SetError($BASS_ERR_DLL_NO_EXIST, 0, False)
	;Check to make sure that the version of Bass.DLL is compatabile with this UDF version.  If not we will throw a text error.
	;Then we will exit the program
	If $BASS_STARTUP_BYPASS_VERSIONCHECK Then
		If _VersionCompare(FileGetVersion($sBassCDDLL), $BASS_CD_DLL_UDF_VER) = -1 Then
			MsgBox(0, "ERROR", "This version of BASSCD.au3 is made for BassCD.dll V" & $BASS_CD_DLL_UDF_VER & ".  Please update")
			Exit
		EndIf
	EndIf
	;Open the DLL
	$_ghBassCDDll = DllOpen($sBassCDDLL)

	;Check if the DLL was opened correctly.
	Return $_ghBassCDDll <>-1
EndFunc   ;==>_BASS_CD_Startup
; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_SetInterface
; Description ...: Sets the interface to use to access CD drives.
; Syntax.........: _BASS_CD_SetInterface($iface)
; Parameters ....: 	-	$iface			-	 The interface to use, which can be one of the following.
;						-	$BASS_CD_IF_AUTO
;							- 	Automatically detect an available interface. The interfaces are checked in the order that they
;								are listed here. For example, if both SPTI and ASPI are available, SPTI will be used.
;						-	$BASS_CD_IF_SPTI
;							- 	SCSI Pass-Through Interface. This is only available on NT-based Windows, not Windows 9x, and
;								generally only to administrator user accounts, not limited/restricted user accounts.
;						-	$BASS_CD_IF_ASPI
;							- 	Advanced SCSI Programming Interface. This is the only interface available on Windows 9x, and
;								can also be installed on NT-based Windows.
;						-	$BASS_CD_IF_WIO
;							- 	Windows I/O. Like SPTI, this is only available on NT-based Windows, but it is also available
;								to limited/restricted user accounts. Some features are not available via this interface, notably
;								sub-channel data reading and read speed control (except on Vista or newer). Door status
;								detection is also affected.
; Return values .: Success      - Returns
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_ILLPARAM 	-	iface is invalid.
;										- $BASS_ERROR_NOTAVAIL 	-	The interface is not available, or has no drives available.
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_SetInterface($iface)
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_SetInterface', 'dword', $iface)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_SetInterface

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_GetInfo
; Description ...: Retrieves information on a drive
; Syntax.........: _BASS_CD_GetInfo($drive)
; Parameters ....: 	-	$_ghBassCDDll	-	Handle to opened BassCD.dll
;					-	$_ghBassDll	-	Handle to opened Bass.dll
;					-	$drive	-	The drive to get info on... 0 = the first drive
; Return values .: Success      - Returns Array of drive info
;									- [0] = Vendor
;									- [1] = Prouduct
;									- [2] = Rev
;									- [3] = Letter (-1=unknown, 0=A, 1=B, etc...)
;									- [4] = The drive's reading and writing capabilities, a combination of the following flags
;										-	$BASS_CD_RWFLAG_READCDR
;											-	The drive can read CD-R media.
;										-	$BASS_CD_RWFLAG_READCDRW
;											-	The drive can read CD-RW media.
;										-	$BASS_CD_RWFLAG_READCDRW2
;											-	The drive can read CD-R/RW media where the addressing type is "method 2".
;										-	$BASS_CD_RWFLAG_READDVD
;											-	The drive can read DVD-ROM media.
;										-	$BASS_CD_RWFLAG_READDVDR
;											-	The drive can read DVD-R media.
;										-	$BASS_CD_RWFLAG_READDVDRAM
;											-	The drive can read DVD-RAM media.
;										-	$BASS_CD_RWFLAG_READM2F1
;											-	The drive can read in "mode 2 form 1" format.
;										-	$BASS_CD_RWFLAG_READM2F2
;											-	The drive can read in "mode 2 form 2" format.
;										-	$BASS_CD_RWFLAG_READMULTI
;											-	The drive can read multi-session discs.
;										-	$BASS_CD_RWFLAG_READCDDA
;											-	The drive can read CD audio.
;										-	$BASS_CD_RWFLAG_READCDDASIA
;											-	The drive supports "stream is accurate".
;										-	$BASS_CD_RWFLAG_READSUBCHAN
;											-	The drive can read sub-channel data.
;										-	$BASS_CD_RWFLAG_READSUBCHANDI
;											-	The drive can read sub-channel data, and de-interleave it.
;										-	$BASS_CD_RWFLAG_READISRC
;											-	The drive can read ISRC numbers.
;										-	$BASS_CD_RWFLAG_READUPC
;											-	The drive can read UPC numbers.
;										-	$BASS_CD_RWFLAG_READANALOG
;											-	The drive is capable of analog playback.
;									- [5] = Can open - 1 = True
;									- [6] = Can lock - 1 = True
;									- [7] = Max Read Speed (KB/s)
;									- [8] = Cache Size (KB)
;									- [9] = CD Text - 1 = True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE 	-	drive is invalid
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......: 	-	Divide max read speed by 176.4 to get the real-time speed multiplier, eg. 5645 / 176.4 = "32x speed".
;					-	The rwflags, maxspeed and cache members are unavailable when the WIO interface is used.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_GetInfo($drive)
	Local $arbc[10]
	$rbcStruct = DllStructCreate($BASS_CD_INFO)
	$basscdret = DllCall($_ghBassCDDll, 'int', 'BASS_CD_GetInfo', 'dword', $drive, 'ptr', DllStructGetPtr($rbcStruct))
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		For $i = 0 To 9
			$arbc[$i] = DllStructGetData($rbcStruct, $i + 1)
		Next
		Return SetError(0, "", $arbc)
	EndIf
EndFunc   ;==>_BASS_CD_GetInfo

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_Door
; Description ...: Opens, closes, locks or unlocks a drive door.
; Syntax.........: _BASS_CD_Door($drive, $action)
; Parameters ....: 	-	$_ghBassCDDll	-	Handle to opened BassCD.dll
;					-	$_ghBassDll	-	Handle to opened Bass.dll
;					-	$drive	-	The drive to get info on... 0 = the first driveThe drive... 0 = the first drive.
;					-	$action	-	The action to perform... one of the following.
;						-	$BASS_CD_DOOR_CLOSE 	-	Close the door.
;						-	$BASS_CD_DOOR_OPEN 		-	Open the door.
;						-	$BASS_CD_DOOR_LOCK 		-	Lock the door.
;						-	$BASS_CD_DOOR_UNLOCK 	-	Unlock the door.
; Return values .: Success      - Returns 1
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE
;											-	Drive is invalid.
;										- $BASS_ERROR_ILLPARAM
;											-	Action is invalid.
;										- $BASS_ERROR_UNKNOWN
;											-	Some other mystery problem! Could be that the door is locked.
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_Door($drive, $action)
	$basscdret = DllCall($_ghBassCDDll, 'int', 'BASS_CD_Door', 'dword', $drive, 'dword', $action)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_Door

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_DoorIsLocked
; Description ...: Checks if a drive door/tray is locked.
; Syntax.........: _BASS_CD_DoorIsLocked($drive)
; Parameters ....: 	-	$_ghBassCDDll	-	Handle to opened BassCD.dll
;					-	$_ghBassDll	-	Handle to opened Bass.dll
;					-	$drive	-	The drive to get info on... 0 = the first driveThe drive to check... 0 = the first drive.
; Return values .: Success      - Returns 1 if locked
;                  Failure      - Returns 0
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	It is not possible to get the drive's current door status via the WIO interface. So the last known status
;					will be returned in that case, which may not be accurate if the door has been locked or unlocked by
;					another application.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_DoorIsLocked($drive)
	$basscdret = DllCall($_ghBassCDDll, 'int', 'BASS_CD_DoorIsLocked', 'dword', $drive)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_DoorIsLocked

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_DoorIsOpen
; Description ...: Checks if a drive door/tray is open.
; Syntax.........: _BASS_CD_DoorIsOpen($drive)
; Parameters ....: 	-	$_ghBassCDDll	-	Handle to opened BassCD.dll
;					-	$_ghBassDll	-	Handle to opened Bass.dll
;					-	$drive	-	The drive to get info on... 0 = the first driveThe drive to check... 0 = the first drive.
; Return values .: Success      - Returns 1 if door is open
;                  Failure      - Returns 0
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	It is not possible to get the drive's current door status via the WIO interface. So the last known status
;					will be returned in that case, which may not be accurate if the door has been opened or closed by another
;					application, or manually.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_DoorIsOpen($drive)
	$basscdret = DllCall($_ghBassCDDll, 'int', 'BASS_CD_DoorIsOpen', 'dword', $drive)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_DoorIsOpen

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_IsReady
; Description ...: Checks if there is a CD ready in a drive.
; Syntax.........: _BASS_CD_IsReady($drive)
; Parameters ....: 	-	$_ghBassCDDll	-	Handle to opened BassCD.dll
;					-	$_ghBassDll	-	Handle to opened Bass.dll
;					-	$drive	-	The drive to get info on... 0 = the first drive
; Return values .: Success      - Returns 1 if CD is in drive and ready to be accessed
;                  Failure      - Returns 0
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......: This function only returns TRUE once there's a CD in the drive, and it's ready to be accessed.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_IsReady($drive)
	$basscdret = DllCall($_ghBassCDDll, 'int', 'BASS_CD_IsReady', 'dword', $drive)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_IsReady

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_GetTracks
; Description ...: Retrieves the number of tracks on the CD in a drive.
; Syntax.........: _BASS_CD_GetTracks($drive)
; Parameters ....: 	-	$_ghBassCDDll	-	Handle to opened BassCD.dll
;					-	$_ghBassDll	-	Handle to opened Bass.dll
;					-	$drive	-	The drive to get info on... 0 = the first drive
; Return values .: Success      - Returns number of tracks on CD
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE	-	Drive is invalid.
;										- $BASS_ERROR_NOCD 		-	There's no CD in the drive.
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_GetTracks($drive)
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_GetTracks', 'dword', $drive)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_GetTracks

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_GetTrackLength
; Description ...: Retrieves the length (in bytes) of a track.
; Syntax.........: _BASS_CD_GetTrackLength($drive, $track)
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
;					-	$track			-	The track to retrieve the length of... 0 = the first track.
; Return values .: Success      - Returns the length of the track
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE
;											-	Drive is invalid.
;										- $BASS_ERROR_NOCD
;											-	There's no CD in the drive.
;										- $BASS_ERROR_CDTRACK
;											-	The track number is invalid.
;										- $BASS_ERROR_NOTAUDIO
;											-	The track is not an audio track.
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......: 	CD audio is always 44100hz stereo 16-bit. That's 176400 bytes per second. So dividing the track length by
;					176400 gives the length in seconds.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_GetTrackLength($drive, $track)
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_GetTrackLength', 'dword', $drive, 'dword', $track)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_GetTrackLength

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_GetTrackPregap
; Description ...: Retrieves the pregap length (in bytes) of a track.
; Syntax.........: _BASS_CD_GetTrackPregap($drive, $track)
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
;					-	$track			-	The track to retrieve the pregap length of... 0 = the first track.
; Return values .: Success      - Returns the length of the pregap
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE
;											- Drive is invalid.
;										- $BASS_ERROR_NOCD
;											- There's no CD in the drive.
;										- $BASS_ERROR_CDTRACK
;											- The track number is invalid.
;										- $BASS_ERROR_NOTAUDIO
;											- The track is not an audio track.
;										- $BASS_ERROR_NOTAVAIL
;											- Reading sub-channel data is not supported by the drive.
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	-	To translate the pregap length from bytes to frames, divide by 2352.
;					-	The drive needs to support sub-channel reading in order to detect all but
;						the first pregap length. _BASS_CD_GetInfo can be used to check whether the
;						drive can read sub-channel data.
;					-	A track's pregap is actually played as part of the preceding track. So to
;						remove the gap from the end of a track, you would get the pregap length of the
;						following track. The gap will usually contain silence, but it doesn't have to;
;						it could contain crowd noise in a live recording, for example.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_GetTrackPregap($drive, $track)
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_GetTrackPregap', 'dword', $drive, 'dword', $track)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_GetTrackPregap

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_GetID
; Description ...: Retrieves identification info from the CD in a drive.
; Syntax.........: _BASS_CD_GetID($drive, $id)
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
;					-	$id				-	The identification to retrieve, one of the following.
;						-	$BASS_CDID_UPC
;							-	Returns the catalog number of the CD. The number uses UPC/EAN-code (BAR coding). This
;								might not be available for all CDs.
;						-	$BASS_CDID_CDDB
;							-	Produces a CDDB identifier. This can be used to get details on the CD's contents from a
;								CDDB server.
;						-	$BASS_CDID_CDDB2
;							-	Produces a CDDB2 identifier. This can be used to get details on the CD's contents from a
;								CDDB2 server.
;						-	$BASS_CDID_TEXT
;							-	Retrieves the CD-TEXT information from the CD (see below for details). CD-TEXT is not available
;								on the majority of CDs.
;						-	$BASS_CDID_CDPLAYER
;							-	Produces an identifier that can be used to lookup CD details in the CDPLAYER.INI file, located
;								in the Windows directory.
;						-	$BASS_CDID_MUSICBRAINZ
;							-	Produces an identifier that can be used to get details on the CD's contents from MusicBrainz.
;						-	$BASS_CDID_ISRC + track
;							-	Returns the International Standard Recording Code of the track... 0 = first track. This might
;								not be available for all CDs.
; Return values .: Success      - Returns the identification info
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE
;											-	Drive is invalid.
;										- $BASS_ERROR_NOCD
;											-	There's no CD in the drive.
;										- $BASS_ERROR_ILLPARAM
;											-	ID is invalid.
;										- $BASS_ERROR_NOTAVAIL
;											-	The CD does not have a UPC, ISRC or CD-TEXT info.
;										- $BASS_ERROR_UNKNOWN
;											-	Some other mystery problem!
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......: 	-	When requesting CD-TEXT, a series of null-terminated strings is returned (the final string ending in
;						a double null), in the form of "tag=text". The following is a list of all the possible tags. Where <t>
;						is shown, that represents the track number, with "0" being the whole disc/album. For example, "TITLE0"
;						is the album title, while "TITLE1" is the title of the first track.
;							TITLE<t> 			-	The track (or album) title.
;							PERFORMER<t>  		-	The performer(s).
;							SONGWRITER<t>  		-	The song writer(s).
;							COMPOSER<t>  		-	The composer(s).
;							ARRANGER<t>  		-	The arranger(s).
;							MESSAGE<t>  		-	Message.
;							GENRE<t>  			-	Genre.
;							ISRC<t>  			-	International Standard Recording Code (ISRC) of the track... <t> is never 0.
;							UPC  				-	UPC/EAN code of the album.
;							DISCID  			-	Disc identification information.
;					-	When requesting CDDB identification, the string returned is what should be used in a CDDB query. The
;						command sent to the CDDB server would be "cddb query <the returned string>". If successful, that
;						results in a list of matching CDs, which the contents of can be requested using the "cddb read" command.
;						See http://www.cddb.com/ and http://www.freedb.org/ for more information on using a CDDB server.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_GetID($drive, $id)
	$basscdret = DllCall($_ghBassCDDll, 'ptr', 'BASS_CD_GetID', 'dword', $drive, 'dword', $id)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Local $arr[1] = [-1], $CNT = 0, $Len, $Info_ptr = $basscdret[0]
		While 1
			$Len = _BASS_PtrStringLen($Info_ptr, False)
			If $Len <= 0 Then ExitLoop
			ReDim $arr[$CNT + 1]
			$arr[$CNT] = _BASS_PtrStringRead($Info_ptr, False, $Len)
			$CNT += 1
			$Info_ptr += $Len + 1
		WEnd
		Return SetError(0, "", $arr)
	EndIf
EndFunc   ;==>_BASS_CD_GetID

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_GetSpeed
; Description ...: Retrieves the current read speed setting of a drive.
; Syntax.........: _BASS_CD_GetSpeed($drive)
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
; Return values .: Success      - Returns the read speed (in KB/s)
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE
;											- Drive is invalid.
;										- $BASS_ERROR_NOTAVAIL
;											- The read speed is unavailable.
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_GetSpeed($drive)
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_GetSpeed', 'dword', $drive)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_GetSpeed

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_SetSpeed
; Description ...: Sets the read speed of a drive.
; Syntax.........: _BASS_CD_SetSpeed($drive, $speed)
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
;					-	$speed			-	The speed, in KB/s... -1 = optimal performace.
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE
;											- Drive is invalid.
;										- $BASS_ERROR_UNKNOWN
;											- Some other mystery problem!
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	-	The speed is automatically restricted (rounded down) to what's supported by the drive, so may not be
;						exactly what was requested. BASS_CD_GetSpeed can be used to check that. The maximum supported speed
;						can be retrieved via BASS_CD_GetInfo.
;					-	To use a real-time speed multiplier, multiply it by 176.4 (and round up) to get the KB/s speed to
;						use with this function, eg. "32x speed" = 32 * 176.4 = 5645.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_SetSpeed($drive, $speed)
	$basscdret = DllCall($_ghBassCDDll, 'int', 'BASS_CD_SetSpeed', 'dword', $drive, 'dword', $speed)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_SetSpeed

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_Release
; Description ...: Releases a drive to allow other applications to access it.
; Syntax.........: _BASS_CD_Release($drive)
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE
;											- Drive is invalid.
;										- $BASS_ERROR_NOTAVAIL
;											- The ASPI interface is being used.
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	When using the SPTI interface, some applications may require BASSCD to release a CD drive before the app is
;					able to use it. After a drive has been released, BASSCD will attempt to re-acquire it in the next BASSCD
;					function call made on it.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_Release($drive)
	$basscdret = DllCall($_ghBassCDDll, 'int', 'BASS_CD_Release', 'dword', $drive)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_Release

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_StreamCreate
; Description ...:
; Syntax.........:
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
;					-	$track			-	The track... 0 = the first track.
;					-	$flags			-	Any combination of these flags.
;						- $BASS_SAMPLE_FLOAT
;							-	Use 32-bit floating-point sample data. See Floating-point channels for more info.
;						- $BASS_SAMPLE_SOFTWARE
;							-	Force the stream to not use hardware mixing.
;						- $BASS_SAMPLE_LOOP
;							-	Loop the file. This flag can be toggled at any time using BASS_ChannelFlags.
;						- $BASS_SAMPLE_FX
;							-	Requires DirectX 8 or above Enable the old implementation of DirectX 8 effects. See the DX8
;								effect implementations section for details. Use BASS_ChannelSetFX to add effects to the stream.
;						- $BASS_STREAM_AUTOFREE
;							-	Automatically free the stream when playback ends.
;						- $BASS_STREAM_DECODE
;							-	Decode the sample data, without playing it. Use BASS_ChannelGetData to retrieve decoded sample
;								data. The BASS_STREAM_AUTOFREE and SPEAKER flags can not be used together with this flag. The
;								BASS_SAMPLE_SOFTWARE and BASS_SAMPLE_FX flags are also ignored.
;						- $BASS_SPEAKER_xxx
;							-	Speaker assignment flags.
;						- $BASS_CD_SUBCHANNEL
;							-	Read sub-channel data. 96 bytes of de-interleaved sub-channel data will be returned after each
;								2352 bytes of audio. This flag can not be used with the BASS_SAMPLE_FLOAT flag, and is ignored
;								if the BASS_STREAM_DECODE flag is not used.
;						- $BASS_CD_SUBCHANNEL_NOHW
;							-	Read sub-channel data, without using any hardware de-interleaving. This is identical to the
;								BASS_CD_SUBCHANNEL flag, except that the de-interleaving is always performed by BASSCD even if the
;								drive is apparently capable of de-interleaving itself.
; Return values .: Success      - Returns the new streams handle
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_INIT
;											- _BASS_Init has not been successfully called.
;										- $BASS_ERROR_DEVICE
;											- Drive is invalid.
;										- $BASS_ERROR_ALREADY
;											- A stream using this drive already exists.
;										- $BASS_ERROR_ILLPARAM
;											- The BASS_CD_SUBCHANNEL and BASS_SAMPLE_FLOAT flags can not be used together.
;										- $BASS_ERROR_NOCD
;											- There's no CD in the drive.
;										- $BASS_ERROR_CDTRACK
;											- Track is invalid.
;										- $BASS_ERROR_NOTAUDIO
;											- The track is not an audio track.
;										- $BASS_ERROR_NOTAVAIL
;											- Reading sub-channel data is not supported by the drive.
;										- $BASS_ERROR_FORMAT
;											- The sample format is not supported by the device/drivers. If the stream is more than stereo or the BASS_SAMPLE_FLOAT flag is used, it could be that they are not supported.
;										- $BASS_ERROR_SPEAKER
;											- The specified SPEAKER flags are invalid. The device/drivers do not support them, they are attempting to assign a stereo stream to a mono speaker or 3D functionality is enabled.
;										- $BASS_ERROR_MEM
;											- There is insufficient memory.
;										- $BASS_ERROR_UNKNOWN
;											- Some other mystery problem!
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	-	Only one stream can exist at a time per CD drive. If a stream using the drive already exists, this
;						function will fail, unless the BASS_CONFIG_CD_FREEOLD config option is enabled. Note that
;						BASS_CD_StreamSetTrack can be used to change track without creating a new stream.
;					-	The sample format of a CD audio stream is always 44100hz stereo 16-bit, unless the BASS_SAMPLE_FLOAT
;						flag is used, in which case it's converted to 32-bit. When reading sub-channel data, the sample rate
;						will be 45900hz, taking the additional sub-channel data into account.
;					-	When reading sub-channel data, BASSCD will automatically de-interleave the data if the drive can't.
;						BASS_CD_GetInfo can be used to check whether the drive can de-interleave the data itself, or even
;						read sub-channel data at all.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_StreamCreate($drive, $track, $flags)
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_StreamCreate', 'dword', $drive, 'dword', $track, 'dword', $flags)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_StreamCreate

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_StreamCreateFile
; Description ...: Creates a sample stream from an audio CD track, using a CDA file on the CD.
; Syntax.........: _BASS_CD_StreamCreateFile($f, $flags)
; Parameters ....: 	-	$file			-	The CDA filename... for example, "D:\Track01.cda".
;					-	$flags			-	Any combination of these flags.
;						- $BASS_SAMPLE_FLOAT
;							-	Use 32-bit floating-point sample data. See Floating-point channels for more info.
;						- $BASS_SAMPLE_SOFTWARE
;							-	Force the stream to not use hardware mixing.
;						- $BASS_SAMPLE_LOOP
;							-	Loop the file. This flag can be toggled at any time using BASS_ChannelFlags.
;						- $BASS_SAMPLE_FX
;							-	Requires DirectX 8 or above Enable the old implementation of DirectX 8 effects. See the DX8
;								effect implementations section for details. Use BASS_ChannelSetFX to add effects to the stream.
;						- $BASS_STREAM_AUTOFREE
;							-	Automatically free the stream when playback ends.
;						- $BASS_STREAM_DECODE
;							-	Decode the sample data, without playing it. Use BASS_ChannelGetData to retrieve decoded sample
;								data. The BASS_STREAM_AUTOFREE and SPEAKER flags can not be used together with this flag. The
;								BASS_SAMPLE_SOFTWARE and BASS_SAMPLE_FX flags are also ignored.
;						- $BASS_SPEAKER_xxx
;							-	Speaker assignment flags.
;						- $BASS_CD_SUBCHANNEL
;							-	Read sub-channel data. 96 bytes of de-interleaved sub-channel data will be returned after each
;								2352 bytes of audio. This flag can not be used with the BASS_SAMPLE_FLOAT flag, and is ignored
;								if the BASS_STREAM_DECODE flag is not used.
;						- $BASS_CD_SUBCHANNEL_NOHW
;							-	Read sub-channel data, without using any hardware de-interleaving. This is identical to the
;								BASS_CD_SUBCHANNEL flag, except that the de-interleaving is always performed by BASSCD even if the
;								drive is apparently capable of de-interleaving itself.
;						- $BASS_UNICODE
;							-	File is a Unicode (UTF-16) filename.
; Return values .: Success      - Returns the new streams handle
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_INIT
;											- _BASS_Init has not been successfully called.
;										- $BASS_ERROR_DEVICE
;											- Drive is invalid.
;										- $BASS_ERROR_ALREADY
;											- A stream using this drive already exists.
;										- $BASS_ERROR_ILLPARAM
;											- The BASS_CD_SUBCHANNEL and BASS_SAMPLE_FLOAT flags can not be used together.
;										- $BASS_ERROR_NOCD
;											- There's no CD in the drive.
;										- $BASS_ERROR_CDTRACK
;											- Track is invalid.
;										- $BASS_ERROR_NOTAUDIO
;											- The track is not an audio track.
;										- $BASS_ERROR_NOTAVAIL
;											- Reading sub-channel data is not supported by the drive.
;										- $BASS_ERROR_FORMAT
;											- The sample format is not supported by the device/drivers. If the stream is more than stereo or the BASS_SAMPLE_FLOAT flag is used, it could be that they are not supported.
;										- $BASS_ERROR_SPEAKER
;											- The specified SPEAKER flags are invalid. The device/drivers do not support them, they are attempting to assign a stereo stream to a mono speaker or 3D functionality is enabled.
;										- $BASS_ERROR_MEM
;											- There is insufficient memory.
;										- $BASS_ERROR_UNKNOWN
;											- Some other mystery problem!
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	-	Only one stream can exist at a time per CD drive. If a stream using the drive already exists, this
;						function will fail, unless the BASS_CONFIG_CD_FREEOLD config option is enabled. Note that
;						BASS_CD_StreamSetTrack can be used to change track without creating a new stream.
;					-	The sample format of a CD audio stream is always 44100hz stereo 16-bit, unless the BASS_SAMPLE_FLOAT
;						flag is used, in which case it's converted to 32-bit. When reading sub-channel data, the sample rate
;						will be 45900hz, taking the additional sub-channel data into account.
;					-	When reading sub-channel data, BASSCD will automatically de-interleave the data if the drive can't.
;						BASS_CD_GetInfo can be used to check whether the drive can de-interleave the data itself, or even
;						read sub-channel data at all.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_StreamCreateFile($file, $flags)
	$bcrf = DllStructCreate("char[255]")
	DllStructSetData($bcrf, 1, $file)
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_StreamCreateFile', 'ptr', DllStructGetPtr($bcrf), 'dword', $flags)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_StreamCreateFile

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_StreamGetTrack
; Description ...: Retrieves the drive and track number of a CD stream.
; Syntax.........: _BASS_CD_StreamGetTrack($handle)
; Parameters ....: 	-	$handle			-	The CD stream handle.
; Return values .: Success      - Returns an array with the track number and drive.
;									-	[0] = Track Number
;									-	[1] = Drive
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_HANDLE
;											-	Handle is not valid.
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_StreamGetTrack($handle)
	Local $abCRet[2]
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_StreamGetTrack', 'dword', $handle)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		$abCRet[0] = _LoWord($basscdret[0])
		$abCRet[1] = _HiWord($basscdret[0])
		Return SetError(0, "", $abCRet)
	EndIf
EndFunc   ;==>_BASS_CD_StreamGetTrack

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_StreamSetTrack
; Description ...: Changes the track of a CD stream.
; Syntax.........: _BASS_CD_StreamSetTrack($handle, $track)
; Parameters ....: 	-	$handle			-	The CD stream handle.
;					-	$track			-	The new track... 0 = the first track.
; Return values .: Success      - Returns 1
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_HANDLE
;											- Handle is not valid.
;										- $BASS_ERROR_NOCD
;											- There's no CD in the drive.
;										- $BASS_ERROR_CDTRACK
;											- Track is invalid.
;										- $BASS_ERROR_NOTAUDIO
;											- The track is not an audio track.
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	The stream's current position is set to the start of the new track.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_StreamSetTrack($handle, $track)
	$basscdret = DllCall($_ghBassCDDll, 'int', 'BASS_CD_StreamSetTrack', 'dword', $handle, 'dword', $track)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_StreamSetTrack

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_Analog_Play
; Description ...: Starts analog playback of an audio CD track.
; Syntax.........: _BASS_CD_Analog_Play($drive, $track, $pos)
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
;					-	$track			-	The track... 0 = the first track.
;					-	$pos			-	Position (in frames) to start playback from. There are 75 frames per second.
; Return values .: Success      - Returns True
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE
;											- Drive is invalid.
;										- $BASS_ERROR_NOCD
;											- There's no CD in the drive.
;										- $BASS_ERROR_CDTRACK
;											- Track is invalid.
;										- $BASS_ERROR_NOTAUDIO
;											- The track is not an audio track.
;										- $BASS_ERROR_POSITION
;											- Pos is invalid.
;										- $BASS_ERROR_UNKNOWN
;											- Some other mystery problem!
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	-	Some old CD drives may not be able to digitally extract audio data (or not quickly enough to sustain
;						playback), so that it's not possible to use BASS_CD_StreamCreate to stream CD tracks. This is where
;						the analog playback option can come in handy.
;					-	In analog playback, the sound bypasses BASS; it goes directly from the CD drive to the soundcard
;						(assuming the drive is cabled up to the soundcard). This means that BASS output does not need to
;						be initialized to use analog playback. It also means that it is not possible to apply any DSP/FX
;						to the sound, and nor is it possible to visualise it (unless you record the sound from the soundcard).
;					-	Analog playback is not possible while digital streaming is in progress; the streaming will kill the
;						analog playback. So if you wish to switch from digital to analog playback, you should first free
;						the stream using BASS_StreamFree.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_Analog_Play($drive, $track, $pos)
	$basscdret = DllCall($_ghBassCDDll, 'int', 'BASS_CD_Analog_Play', 'dword', $drive, 'dword', $track, 'dword', $pos)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_Analog_Play

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_Analog_PlayFile
; Description ...: Starts analog playback of an audio CD track, using a CDA file on the CD.
; Syntax.........: _BASS_CD_Analog_PlayFile($file, $pos)
; Parameters ....: 	-	$file			-	The CDA filename... for example, "D:\Track01.cda".
;					-	$pos			-	Position (in frames) to start playback from. There are 75 frames per second.
; Return values .: Success      - Returns the number of the drive
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_FILEOPEN
;											- The file could not be opened.
;										- $BASS_ERROR_FILEFORM
;											- The file was not recognised as a CDA file.
;										- $BASS_ERROR_DEVICE
;											- The drive could not be found.
;										- $BASS_ERROR_POSITION
;											- Pos is invalid.
;										- $BASS_ERROR_UNKNOWN
;											- Some other mystery problem!
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	-	Some old CD drives may not be able to digitally extract audio data (or not quickly enough to sustain
;						playback), so that it's not possible to use BASS_CD_StreamCreate to stream CD tracks. This is where
;						the analog playback option can come in handy.
;					-	In analog playback, the sound bypasses BASS; it goes directly from the CD drive to the soundcard
;						(assuming the drive is cabled up to the soundcard). This means that BASS output does not need to
;						be initialized to use analog playback. It also means that it is not possible to apply any DSP/FX
;						to the sound, and nor is it possible to visualise it (unless you record the sound from the soundcard).
;					-	Analog playback is not possible while digital streaming is in progress; the streaming will kill the
;						analog playback. So if you wish to switch from digital to analog playback, you should first free
;						the stream using BASS_StreamFree.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_Analog_PlayFile($file, $pos)
	$arbc = DllStructCreate("char[255]")
	DllStructSetData($arbc, 1, $file)
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_Analog_PlayFile', 'ptr', DllStructGetPtr($arbc), 'dword', $pos)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_Analog_PlayFile

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_Analog_Stop
; Description ...: Stops analog playback on a drive.
; Syntax.........: _BASS_CD_Analog_Stop($drive)
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
; Return values .: Success      - Returns 1
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE
;											- Drive is invalid.
;										- $BASS_ERROR_UNKNOWN
;											- Some other mystery problem!
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:	Pausing can be achieved by getting the position (BASS_CD_Analog_GetPosition) just before stopping,
;					and then using that position in a call to BASS_CD_Analog_Play to resume.
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_Analog_Stop($drive)
	$basscdret = DllCall($_ghBassCDDll, 'int', 'BASS_CD_Analog_Stop', 'dword', $drive)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_Analog_Stop

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_Analog_IsActive
; Description ...: Checks if analog playback is in progress on a drive.
; Syntax.........: _BASS_CD_Analog_IsActive($drive)
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
; Return values .: Success      - Returns either
;									- $BASS_ACTIVE_STOPPED
;										- Analog playback is not in progress, or drive is invalid.
;									- $BASS_ACTIVE_PLAYING
;										- Analog playback is in progress.
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_Analog_IsActive($drive)
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_Analog_IsActive', 'dword', $drive)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		Return SetError(0, "", $basscdret[0])
	EndIf
EndFunc   ;==>_BASS_CD_Analog_IsActive

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_CD_Analog_GetPosition
; Description ...: Retrieves the current position on a drive.
; Syntax.........: _BASS_CD_Analog_GetPosition($drive)
; Parameters ....: 	-	$drive			-	The drive to get info on... 0 = the first drive
; Return values .: Success      - Returns an array with the track number and drive.
;									-	[0] = Track Number
;									-	[1] = offset (in frames)
;                  Failure      - Returns 0 and sets @ERROR to error returned by _BASS_ErrorGetCode()
;									@error will be set to-
;										- $BASS_ERROR_DEVICE
;											- Drive is invalid.
;										- $BASS_ERROR_UNKNOWN
;											- Some other mystery problem!
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_CD_Analog_GetPosition($drive)
	Local $abCRet[2]
	$basscdret = DllCall($_ghBassCDDll, 'dword', 'BASS_CD_Analog_GetPosition', 'dword', $drive)
	$BS_ERR = _BASS_ErrorGetCode()
	If $BS_ERR <> 0 Then
		Return SetError($BS_ERR, "", 0)
	Else
		$abCRet[0] = _LoWord($basscdret[0])
		$abCRet[1] = _HiWord($basscdret[0])
		Return SetError(0, "", $abCRet)
	EndIf
EndFunc   ;==>_BASS_CD_Analog_GetPosition
