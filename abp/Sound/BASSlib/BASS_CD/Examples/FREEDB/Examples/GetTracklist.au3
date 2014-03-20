;HTTP.au3 is required to be included.  It can be found in BASSCD\Examples

;Params is usually like so:
;DiscID Track_Offsets ..."
;Example string
;3712bd15 21 150 17976 31371 45325 69881 91650 102253 126534 137627 149347 162742 176697 193021 214651 230278 248278 272836 299627 306882 319749 334317 4799
;$params is returned from _BASS_CD_GetID() with the $BASS_CDID_CDDB

;Please note that this is an example.  I have NOT fully tested for cases where there are duplicates, and every possible cause.  This is just a basic example of use.
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
						$tracklist[$tcount][2] = _BASS_CD_GetTrackLength($BASS_CD_DLL, $BASS_DLL, $currentDrive, $tcount - 1)
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