; http://ftp.freedb.org/pub/freedb/latest/CDDBPROTO
#include<Array.au3>
#include<WindowsConstants.au3>

;7c0a551b 27 150 10602 24184 34066 45006 47031 50762 54277 57494 60336 91837 95513 100770 119043 126141 127571 130256 139980 144500 146242 156440 158969 161721 170609 177680 184318 191608 2647
;780a431a 26 150 5205 20451 29280 33375 38790 40350 42255 46260 49995 78735 100065 101886 111212 111930 124215 125805 128250 133930 155130 164433 168981 176250 179650 185222 192141 2629
;d60be510 16 150 14860 30549 45146 57872 68687 82752 102634 114321 124306 136884 153440 163448 180702 198113 214696 3047
;99088b0b 11 150 12616 25768 37230 50064 64692 77487 93340 110283 125895 144613 2189
$sQuery = InputBox("CDDB","CDDB-querystring (e.g. from bassCD)","d60be510 16 150 14860 30549 45146 57872 68687 82752 102634 114321 124306 136884 153440 163448 180702 198113 214696 3047")
$Conn = _CDDB_Connect()

$data = _CDDB_Query($Conn,$sQuery)
If @error =0 Then
	If @extended>0 Then $data = _CDDB_SelectDisc($data)

	$read = _CDDB_Read($Conn,$data[0],$data[1])
	MsgBox(0, '', @error & "-" & @extended)
	If @error=1 And @extended=0 Then
		_CDDB_Close($Conn)
		$Conn = _CDDB_Connect()
		_CDDB_Query($Conn,$sQuery)
		$read = _CDDB_Read($Conn,$data[0],$data[1])
	EndIf
	_CDDB_Close($Conn)
	_CDDB_ShowCD($read)
	If @error Then MsgBox(0,"","No CD information")
EndIf

; Shows a gui with the received information
Func _CDDB_ShowCD(ByRef $aDISC)
;~ 	If UBound($aDISC,0) <> 1 Or UBound($aDISC,1)<>8 Then Return SetError(1,0,0)
	Local $OldEvent = Opt("GUIOnEventMode",0)
	GUICreate("Found CD information", 420, 150)
	GUICtrlCreateLabel("CD Title:", 8, 10, 50)
	GUICtrlCreateInput($aDISC[1], 55, 8, 150, 18)
	GUICtrlCreateLabel("CD Artist:", 8, 30, 50)
	GUICtrlCreateInput($aDISC[2], 55, 28, 150, 18)
	GUICtrlCreateLabel("CD Genre:", 8, 50, 50)
	GUICtrlCreateInput($aDISC[4], 55, 48, 150, 18)
	GUICtrlCreateLabel("CD Year:", 8, 70, 50)
	GUICtrlCreateInput($aDISC[3], 55, 68, 150, 18)
	GUICtrlCreateLabel("CD Extd:", 8, 90, 50)
	GUICtrlCreateInput($aDISC[5], 55, 88, 150, 18)
	GUICtrlCreateLabel("CD ID:", 8, 110, 50)
	GUICtrlCreateInput($aDISC[0], 55, 108, 150, 18)
	GUICtrlCreateLabel("CD Order:", 8, 130, 50)
	GUICtrlCreateInput($aDISC[6], 55, 128, 150, 18)
	Local $hListV = GUICtrlCreateListView("Title|Artist|Ext", 210, 8, 200, 140)
	Local $aCDTracks = $aDISC[7]
	For $i = 0 To UBound($aCDTracks) - 1
		GUICtrlCreateListViewItem($aCDTracks[$i][0] & "|" & $aCDTracks[$i][1] & "|" & $aCDTracks[$i][2], $hListV)
	Next
	GUICtrlSendMsg(-1, 0x101E, 0, -1)
	GUICtrlSendMsg(-1, 0x101E, 1, -1)
	GUICtrlSendMsg(-1, 0x101E, 2, -1)
	GUISetState()

	While GUIGetMsg() <> -3
	WEnd
	GUIDelete()
	Opt("GUIOnEventMode",$OldEvent )
EndFunc

; Shows a gui to select a disc out of multiple matches
Func _CDDB_SelectDisc(ByRef $aDiscs,$Title="CDDB - Multiple Matches")
	; by Prog@ndy
	If UBound($aDiscs,0) = 1 And UBound($aDiscs,1) = 3 Then Return $aDiscs
	If UBound($aDiscs,2) <> 3 Or UBound($aDiscs,0) <> 2 Then Return SetError(1,0,0)

	Local $OldEvent = Opt("GUIOnEventMode",0)
	Local $GUI = GUICreate($Title,300,250,-1,-1,$WS_CAPTION,$WS_EX_DLGMODALFRAME)
	GUICtrlCreateLabel("There are multiple matches for this CD. Select the right one.",5,5,290,40)
	Local $LV = GUICtrlCreateListView("Title|Genre|ID",0,50,300,150)
	Local $LV_Items[UBound($aDiscs)]
	Local $OLDSEP = Opt("GUIDataSeparatorChar",Chr(6))
	For $i = 0 To UBound($aDiscs)-1
		$LV_Items[$i] = GUICtrlCreateListViewItem($aDISCS[$i][2] & Chr(6)& $aDISCS[$i][1] & Chr(6)& $aDISCS[$i][0], $LV)
	Next
	Opt("GUIDataSeparatorChar",$OLDSEP)
	GUICtrlSendMsg($LV,0x101E,0,-1)
	GUICtrlSendMsg($LV,0x101E,1,-1)
	GUICtrlSendMsg($LV,0x101E,2,-1)
	GUICtrlSendMsg($LV,0x1000+67,0,0)
	Local $OK = GUICtrlCreateButton("OK",100,210,100,30)
	GUISetState()
	While 1
		Switch GUIGetMsg()
			Case -3,$OK
				Local $INDX = GUICtrlRead($LV)
				For $i = 0 To UBound($LV_Items)-1
					If $INDX = $LV_Items[$i] Then
						Local $ret[3] = [$aDiscs[$i][0],$aDiscs[$i][1],$aDiscs[$i][2]]
						ExitLoop 2
					EndIf
				Next
		EndSwitch
	WEnd
	GUIDelete($GUI)
	Opt("GUIOnEventMode",$OldEvent )
	Return $ret
EndFunc



; takes return data as parameter
; returns an Array: [0] first digit
;                   [1] second digit
;                   [2] third digit
;                   [3] whole number
Func _CDDB_ParseCode($Code)
	; Prog@ndy
	$Code = StringRegExp($Code,"\A(\d)(\d)(\d)(?:\s|\Z)",3)
	If @error Then
		Dim $Code[4]
		SetError(1)
		Return $Code
	EndIf
	ReDim $Code[4]
	$Code[3] = $Code[0]&$Code[1]&$Code[2]
	Return $Code
EndFunc

; connect to CDDB
Func _CDDB_Connect($SERVER="freedb.freedb.org", $Port=8880, $USER="AutoIt", $HOST="AutoItScript")
	; by Prog@ndy
	TCPStartup()
	If Not StringRegExp($SERVER,"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}") Then $SERVER = TCPNameToIP($SERVER)

	Local $Conn = TCPConnect($SERVER,$Port)
	If @error Then Return SetError(1,0*TCPShutdown(),0)
	$data = __CDDB_Recv($Conn)
	Local $Code = _CDDB_ParseCode($data)
	If $Code[0] = 2 Then
		__CDDB_Send($Conn, 'cddb hello ' & $USER & ' ' & $HOST & ' AutoIt ' & @AutoItVersion & @CRLF)
		$data = __CDDB_Recv($Conn)
		$Code = _CDDB_ParseCode($data)
		If $Code[3] = 200 Or $Code[3] = 402 Then
			__CDDB_Send($Conn, 'proto 6' & @CRLF)
			$data = __CDDB_Recv($Conn)
			$Code = _CDDB_ParseCode($data)
			If $Code[3] = 201 Or $Code[3] = 502 Then
				Return $Conn
			Else
				TCPCloseSocket($Conn)
				TCPShutdown()
				Return SetError(7,$Code[3],0)
			EndIf
		Else
			TCPCloseSocket($Conn)
			TCPShutdown()
			Return SetError(6,$Code[3],0)
		EndIf
	ElseIf $Code[0] = 4 And $Code[1] = 3 Then
		TCPCloseSocket($Conn)
		TCPShutdown()
		Return SetError($Code[2],$Code[3],0)
	Else
		TCPCloseSocket($Conn)
		TCPShutdown()
		Return SetError(5,$Code[3],0)
	EndIf
EndFunc

; encodes for freedb (not needed, i think)
Func _CDDB_Encode($data,$quotes=False)
	; by Prog@ndy
	If $quotes Then Return '"' & StringRegExpReplace($data,'(\\|")',"\\$1") & '"'
	Return StringRegExpReplace($data,'(\\|")',"\\$1")
EndFunc

; sets a query
; returns the result: exact match: 1D-Array [0]-category, [1]-DiscID, [3]-Title
;                     multiple matches: 2D-Array: [n][0]-category of match n
;                                                 [n][1]-discID of match n
;                                                 [n][2]-Title of match n
;                                                 @extended is 1 for close matches
;                                                 @extended is 2 for exact matches
; on error, @error is set to 1 and @extended to the CDDB result code.
Func _CDDB_Query($Conn, $Query)
	; by Prog@ndy
	__CDDB_Send($Conn, 'cddb query ' & $Query & @CRLF)
	Local $data = __CDDB_Recv($Conn)

	Local $Code = _CDDB_ParseCode($data)

	Switch Number($Code[3])
		Case 200
			$data = StringTrimLeft($data,4)
			Return StringRegExp($data,"\A(.*?)\h(.*?)\h(.*)\Z",3)
		Case 210,211
			Local $ret0 = StringRegExp($data,"\n(.*?)\h(.*?)\h(.*)\r",3)
			Local $ret[UBound($ret0)/3][3]
			For $i = 0 To UBound($ret)-1
				$ret[$i][0] = $ret0[$i*3]
				$ret[$i][1] = $ret0[$i*3+1]
				$ret[$i][2] = $ret0[$i*3+2]
			Next
			SetExtended(1)
			If $Code[2] = 1 Then SetExtended(2)
			Return $ret
	EndSwitch
	Return SetError(1,Number($Code[3]),0)
EndFunc
; reads information and parses it into 2 Arrays:
; DISC[0] - DiscID
; DISC[1] - Title
; DISC[2] - Artist
; DISC[3] - Year
; DISC[4] - Genre
; DISC[5] - Extended
; DISC[6] - Playorder
; DISC[7] - [2D-Aray] -> [n][0] - TrackTitle
;                        [n][1] - Trackartist, if available
;                        [n][2] - Extended info
; on error, @error is set to 1 and @extended to the CDDB result code.
Func _CDDB_Read($Conn,$Category,$DiscID)
	; by Prog@ndy
	__CDDB_Send($Conn, 'cddb read ' & $Category & ' ' & $DiscID & @CRLF)
	Local $data = __CDDB_Recv($Conn,True,10000,1024,1000)
	MsgBox(0, '', $data)
	Local $Code = _CDDB_ParseCode($data)
	Switch Number($Code[3])
		Case 210
		Local $aDISC[8]
		Local $sDiscinfo = StringRegExp($data,"(?s)#\s*(\r\n[^#].*\r\n)\.(?:\Z|\r|\n)",3)
			If Not @error Then
				$sDiscinfo = $sDiscinfo[0]

				$aDISC[0] = __CDDB_RegExFirst($sDiscinfo,"\nDISCID=(.*)(?:\Z|\r)")
				$aDISC[1] = __CDDB_RegExFirst($sDiscinfo,"\nDTITLE=(.*)(?:\Z|\r)")
				Local $temp = StringRegExp($aDISC[1],"\A(.*?) / (.*)\Z",3)
				If Not @error Then
					$aDISC[1] = $temp[1]
					$aDISC[2] = $temp[0]
				EndIf
				$aDISC[3] = __CDDB_RegExFirst($sDiscinfo,"\nDYEAR=(.*)(?:\Z|\r)")
				$aDISC[4] = __CDDB_RegExFirst($sDiscinfo,"\nDGENRE=(.*)(?:\Z|\r)")
				$aDISC[5] = __CDDB_RegExFirst($sDiscinfo,"\nEXTD=(.*)(?:\Z|\r)")
				$aDISC[6] = __CDDB_RegExFirst($sDiscinfo,"\nPLAYORDER=(.*)(?:\Z|\r)")
				Local $TitleInfo = StringRegExp($sDiscinfo,"\nTTITLE\d+=(.*)\r",3)
				Local $ExtInfo = StringRegExp($sDiscinfo,"\nEXTT\d+=(.*)\r",3)
				Local $TitleExt[UBound($TitleInfo)][3]
				For $i = 0 To UBound($TitleInfo)-1
					$TitleExt[$i][0] = $TitleInfo[$i]
					$temp = StringRegExp($TitleInfo[$i],"\A(.*?) / (.*)\Z",3)
					If Not @error Then
						$TitleExt[$i][0] = $temp[1]
						$TitleExt[$i][1] = $temp[0]
					EndIf
					$TitleExt[$i][2] = $ExtInfo[$i]
				Next
				$aDISC[7] = $TitleExt
				Return $aDISC
			EndIf
			Return SetError(2,0,0)
		Case Else
			Return SetError(1,0,"")
	EndSwitch
EndFunc

; close connection
Func _CDDB_Close($Conn)
	; by Prog@ndy
	Local $ret = TCPCloseSocket($Conn)
	TCPShutdown()
	Return SetError(1,0,$ret)
EndFunc
; internal use only
Func __CDDB_RegExFirst(ByRef $String,$pattern)
	; by Prog@ndy
	Local $r = StringRegExp($string,$pattern,3)
	If Not @error Then Return $r[0]
	Return ""
EndFunc

; receiving
Func __CDDB_Recv($Conn,$UTF8=True,$iTimeOut=10000,$iMaxLen=2056,$iDelay=1000)
	; by Prog@ndy
	Local $data="",$chunk,$cut
	Local $iTime = TimerInit()
	Do
		Sleep(300)
		$data=TCPRecv($Conn,$iMaxLen)
		If @error Then Return SetError(1,0,"")
	Until $data<>"" Or (TimerDiff($iTime)>=$iDelay)
	While 1
		$chunk = TCPRecv($Conn,$iMaxLen)
		Select
			Case @error
				ExitLoop
			Case $chunk = ""
				$cut += 1
				If $cut > 9 Then ExitLoop
			Case Else
				$cut = 0
				$data &= $chunk
		EndSelect
		If TimerDiff($iTime) >= $iTimeOut Then ExitLoop
		Sleep(50)
	WEnd
	If $UTF8 Then Return BinaryToString(StringToBinary($data,1),4)
	Return $data
EndFunc
; send UTF8
Func __CDDB_Send($Conn,$data)
	; by Prog@ndy
	Local $a= TCPSend($Conn,StringToBinary($data,4))
	Return SetError(@error,@extended,$a)
EndFunc
