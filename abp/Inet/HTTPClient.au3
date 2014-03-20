#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
	#Tidy_Parameters=/sf
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include-once
#include <GUIConstantsEx.au3>
#include <Array.au3>
#include <StringConstants.au3>

#include "..\VarDump\VarDump.au3"

Global $_HTTPReq_iTimeout = 5000
Global $_HTTPReq_iTimerInit, $_HTTPReq_hConnect
Global $_HTTPReq_sUserAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:25.0) Gecko/20100101 Firefox/25.0"
Global Const $_HTTPReq_BUFFER_SIZE = 33554432 ; 32 MB
Global Const $_HTTPReq_TCP_BUFFER_SIZE = 2048
Global Const $_HTTPReq_CRLF_BIN = "0D0A"
Global Const $_HTTPReq_MISS_THRESHOLD = 20

GUICreate("1", 800, 600)
$edit = GUICtrlCreateEdit("", 0, 0, 780, 580)
_HTTP_Init()

$t = TimerInit()
Local $ret = _HTTP_Request("http://commons.wikimedia.org/wiki/Main_Page")
GUICtrlSetData($edit, BinaryToString($ret, 4))
GUISetState()
While GUIGetMsg() <> -3
WEnd
GUIDelete($edit)
;~ MsgBox("", "", TimerDiff($t))
$fo = FileOpen("test.png", 2 + 8 + 16)
Local $ret = _HTTP_Request("http://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Example_image.svg/200px-Example_image.svg.png")
_VarDumpConsole(@error & " " & @extended, "error ")
FileWrite($fo, $ret)
FileClose($fo)

;URI = [protocol],hostname,[port],[URL]
;
; $aReqParameters:
; [0] = verb , eg. "POST","GET","DELETE"...
; [1] = aditional headers, eg. "Some-Header: blah blah" & @crlf & "Another-Header: bleh bleh"
; [2] = optional request data, eg. "aynthing iljdbsfilau... except !! '@crlf & @crlf' sequence"
;
; $iOptions:
; 1 = allow redirects
; 2 =
; 4 =
; 8 =
#Region PUBLIC

	Func _HTTP_Init($iTimeout = $_HTTPReq_iTimeout, $sUserAgent = $_HTTPReq_sUserAgent)
		TCPStartup()
		OnAutoItExitRegister("TCPShutdown")
		$_HTTPReq_iTimeout = $iTimeout
		$_HTTPReq_sUserAgent = $sUserAgent
	EndFunc   ;==>_HTTP_Init

	Func _HTTP_Request($sURI, $sVerb = "GET", $aHeader = Default, $sMessageBody = Default, $iOptions = 0, $sCallbackFunction = "")
		If Not IsString($sURI) Then Return SetError(0, 1, -1)
		;
		Local $iAllowRedirects = BitAND($iOptions, 1)
		;
		Local $tURL = __HTTP_Parse_URL($sURI)
		If @error Then Return SetError(@error, 2, -1)

		_VarDumpConsole($tURL, "Crack URL") ;### Debug Console

		If $tURL.schema = "https" Then
			;==> process SSL WinHTTP request
			Return
		EndIf

		__HTTP_Build_Request($tURL.host, $tURL.path, $tURL.query, $sVerb, $aHeader, $sMessageBody)

		Local $sVerb = "GET", $sReqHeader = "Accept: */*", $sReqData
		;
		;prepare additional variables
		If IsArray($aReqParameters) Then
			$sVerb = $aReqParameters[0]
			If UBound($aReqParameters) > 1 Then $sReqHeader = "Accept: */*" & @CRLF & StringStripWS($aReqParameters[1], 1 + 2)
			If UBound($aReqParameters) > 2 Then $sReqData = StringStripWS($aReqParameters[2], 1)
		EndIf
		; prepend Content length if needed
		If $sReqData And __HTTP_Parse_Content_Length($sReqHeader) = -1 Then _
				$sReqHeader = "Content-Length: " & StringLen($sReqData) & @CRLF & $sReqHeader
		;build request string
		Local $sRequest = _
				StringFormat("%s %s%s HTTP/1.1\r\n", $sVerb, $tURL.path, $tURL.query) & _
				"Host: " & $tURL.host & @CRLF & _
				"User-Agent: " & $_HTTPReq_sUserAgent & @CRLF & _
				$sReqHeader & @CRLF & _
				@CRLF & _
				$sReqData & @CRLF & _
				@CRLF
		$sRequest = StringRegExpReplace($sRequest, "[\r\n]*$", @CRLF) ;squeeze final line endings
		ConsoleWrite("--> REQUEST: " & @CRLF & $sRequest & @CRLF & "<--- REQUEST" & @CRLF) ;### Debug Console
		;
		;connect to a server
		$_HTTPReq_iTimerInit = TimerInit()
		$_HTTPReq_hConnect = TCPConnect(TCPNameToIP($tURL.host), $tURL.port)
		If $_HTTPReq_hConnect = -1 Then Return SetError(@error, 3, -1)
		;
		;send request
		TCPSend($_HTTPReq_hConnect, StringToBinary($sRequest, 4)) ;convert anything to standard binary UTF-8
		If @error Then Return SetError(@error, 5, -1)
		If TimerDiff($_HTTPReq_iTimerInit) > $_HTTPReq_iTimeout Then Return SetError(-1, 6, -1)

		; TODO: if option dont receive anything, then return

		Local $sHeader, $bBody
		Local $sHeader = __HTTP_Recv_Header($bBody)

		ConsoleWrite("--> HEADER: " & @CRLF & $sHeader & @CRLF & "<--- HEADER" & @CRLF) ;### Debug Console
		ConsoleWrite("--> BODY: " & @CRLF & StringLeft(BinaryToString($bBody, 4), 512) & @CRLF & "<--- BODY" & @CRLF) ;### Debug Console

		$tHeader = __HTTP_Parse_Header($sHeader)
		_VarDumpConsole($tHeader, "HEAder") ;### Debug Console

		; TODO: if option dont receive body, then return

		If $tHeader.location And $iAllowRedirects Then _
				Return _HTTP_Request($tHeader.location, $aReqParameters = "", $iOptions = 0, $sCallbackFunction = "")

		Select
			Case StringInStr($tHeader.transfer_encoding, "chunked", $STR_NOCASESENSEBASIC)
				__HTTP_Recv_Chunked($bBody)

			Case Else
				$bBody &= __HTTP_Recv_Raw($tHeader.content_length)

		EndSelect

		TCPCloseSocket($_HTTPReq_hConnect)

		Return SetError(0, $tHeader.status_code, $bBody)
	EndFunc   ;==>_HTTP_Request
#EndRegion PUBLIC



#Region PRIVATE
	#Region PARSERS

		Func __HTTP_Get_Header_Field(ByRef $asHeader, $sFieldName)
;~ 		_ArrayBinarySearch(

		EndFunc   ;==>__HTTP_Get_Header_Field

		Func __HTTP_Parse_Header(ByRef $sHeader)
			$tHeader = DllStructCreate("struct;" & _
					"int status_code;" & _
					"char reason_phrase[256];" & _
					"int content_length;" & _
					"char location[4096];" & _
					"char transfer_encoding[1024];" & _
					"endstruct")

			$aStatus = __HTTP_Parse_Status($sHeader)
			If @error Then Return SetError(1, 0, 0)

			Local $asHeader = StringRegExp($sHeader, "(?mi)^([^:\r\n]+): ([^\r\n]+)\r\n", 3)
			If @error Then Return SetError(2, 0, 0)
			$asHeader = _Array_1DTo2D($asHeader, 2)
			_ArraySort($asHeader, 0, 0, 0, 0, 0)
			_ArrayDisplay($asHeader)

			If IsArray($aStatus) Then
				$tHeader.status_code = $aStatus[0]
				$tHeader.reason_phrase = $aStatus[1]
			Else
				$tHeader.status_code = 0
			EndIf
			$tHeader.content_length = __HTTP_Parse_Content_Length($sHeader)
			$tHeader.location = __HTTP_Parse_Location($sHeader)
			$tHeader.transfer_encoding = __HTTP_Parse_Transfer_Encoding($sHeader)

			Return $tHeader
		EndFunc   ;==>__HTTP_Parse_Header

		Func __HTTP_Parse_Status(ByRef $sHeader)
			; http://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html
			; [0] = Status Code
			; [1] = Reason Phrase
			Local $aParse = StringRegExp($sHeader, "(?si)^HTTP\D[\d.]+ (\d+) ([^\r\n]+)\r\n", 3)
			If @error Then Return SetError(1, 0, Null)
			Return $aParse
		EndFunc   ;==>__HTTP_Parse_Status

		Func __HTTP_Parse_Location(ByRef $sHeader)
			; http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.30
			Return __HTTP_Parse_Header_Field($sHeader, "Location")
		EndFunc   ;==>__HTTP_Parse_Location

		Func __HTTP_Parse_Content_Length(ByRef $sHeader)
			; http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.13
			Return __HTTP_Parse_Header_Field($sHeader, "Content-Length")
		EndFunc   ;==>__HTTP_Parse_Content_Length

		Func __HTTP_Parse_Transfer_Encoding(ByRef $sHeader)
			; http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.41
			Return __HTTP_Parse_Header_Field($sHeader, "Transfer-Encoding")
		EndFunc   ;==>__HTTP_Parse_Transfer_Encoding

		Func __HTTP_Parse_Header_Field(ByRef $sHeader, $sFieldName)
			; http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
			Local $aParse = StringRegExp($sHeader, "(?mi)^\Q" & $sFieldName & "\E[: ]+(.+?)\r\n", 1)
			If @error Then Return SetError(1, 0, Null)
			Return $aParse[0]
		EndFunc   ;==>__HTTP_Parse_Header_Field

		Func __HTTP_Parse_Chunk_Size(ByRef $bBody)
			; http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.6.1
			Local $aChunkSize, $abChunk

			; split to the first line and the rest
			$abChunk = StringRegExp($bBody, "(?s)^(.*)\Q" & $_HTTPReq_CRLF_BIN & "\E(.*)", 3)
			If @error Then Return SetError(1, 0, -1)

			; save the body without the chunk-size
			$bBody = $abChunk[1]
			_BinaryEnsure($bBody)

			; extract chunk-size
			$aChunkSize = StringRegExp(BinaryToString($abChunk[0], 4), "(?si)^([[:xdigit:]]+)", 3)
			If @error Then Return SetError(2, 0, -1)

			Return Dec($aChunkSize[0])
		EndFunc   ;==>__HTTP_Parse_Chunk_Size

		Func __HTTP_Parse_URL($sURI)
			; http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.2.2
			; [0] = schema
			; [1] = host
			; [2] = port
			; [3] = URL
			Local $tRet = DllStructCreate("struct;" & _
					"char schema[16];" & _
					"char host[1024];" & _
					"int port;" & _
					"char path[4096];" & _
					"char query[4096];" & _
					"endstruct")
			$tRet.schema = "http"
			$tRet.host = ""
			$tRet.port = 0
			$tRet.path = "/"
			$tRet.query = ""

			;parse the address
			;                                    			|protocol|       | hostname    		 |  |port||URL |
			Local $aURI = StringRegExp($sURI, "^\s*(https?)?(?:://)?([a-zA-Z0-9-.]{3,}):?(\d+)?(/.*)?", 3)
			If @error Then Return SetError(1, 0, 0)
			Local $iArraySize = UBound($aURI)
			If $iArraySize < 2 Then Return SetError(2, 0, 0) ;at least hostname must be specified
			;
			; save protocol if any
			If $aURI[0] Then $tRet.schema = StringLower($aURI[0])
			;
			;save hostname
			$tRet.host = $aURI[1]
			;
			;analyze additional parameters
			If $iArraySize > 2 Then
				$tRet.port = $aURI[2]
				If $iArraySize > 3 Then $tRet.path = StringStripWS($aURI[3], $STR_STRIPTRAILING)
				If $iArraySize > 4 Then $tRet.query = StringStripWS($aURI[4], $STR_STRIPTRAILING)
			EndIf
			;
			;if no port specified, then guess it from the protocol used
			If $tRet.port < 1 Then
				If $tRet.schema = "https" Then
					$tRet.port = 443
				Else
					$tRet.port = 80
				EndIf
			EndIf

			Return $tRet
		EndFunc   ;==>__HTTP_Parse_URL
	#EndRegion PARSERS

	#Region RECEIVERS

		Func __HTTP_Recv_Chunked(ByRef $bBody)
			; http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.6.1
;~ 	Chunked-Body   = *chunk
;~                   last-chunk
;~                   trailer
;~                   CRLF
;~  chunk          = chunk-size [ chunk-extension ] CRLF
;~                   chunk-data CRLF
;~  chunk-size     = 1*HEX
;~  last-chunk     = 1*("0") [ chunk-extension ] CRLF
;~  chunk-extension= *( ";" chunk-ext-name [ "=" chunk-ext-val ] )
;~  chunk-ext-name = token
;~  chunk-ext-val  = token | quoted-string
;~  chunk-data     = chunk-size(OCTET)
;~  trailer        = *(entity-header CRLF)

			Local Const $CRLF_BIN_LEN = BinaryLen(Binary(@CRLF))

			Local $bRecv, $iMissCount = 0

			Local $iChunkSize = __HTTP_Parse_Chunk_Size($bBody)
			While $iChunkSize < 0
				$bBody &= __HTTP_Recv_Raw($_HTTPReq_TCP_BUFFER_SIZE)
				If @error Then ExitLoop
				$iChunkSize = __HTTP_Parse_Chunk_Size($bBody)
			WEnd

			Local $bChunkData = $bBody

			While $iChunkSize > 0
				$bChunk = __HTTP_Recv_Raw($iChunkSize)
				If @error Then ExitLoop
				$bChunkData = _BinaryMerge($bChunkData, $bChunk)
				_VarDumpConsole(BinaryLen($bChunkData), "$bChunkData length")
				$bBody &= BinaryMid($bChunkData, 1, $iChunkSize + $CRLF_BIN_LEN)
				$bChunkData = BinaryMid($bChunkData, $iChunkSize + $CRLF_BIN_LEN + 1)
				$iChunkSize = __HTTP_Parse_Chunk_Size($bChunkData)
			WEnd

		EndFunc   ;==>__HTTP_Recv_Chunked

		Func __HTTP_Recv_gzip()

		EndFunc   ;==>__HTTP_Recv_gzip

		; #INTERNAL_USE_ONLY# ===========================================================================================================
		; Name ..........: __HTTP_Recv_Header
		; Description ...: Receives and parses HTTP header
		; Syntax ........: __HTTP_Recv_Header()
		; Parameters ....:
		; Return values .: Success - 1
		;                  Failure - 0 and sets the @error flag to the one of the following values:
		;                               1 -
		; ===============================================================================================================================
		Func __HTTP_Recv_Header(ByRef $sBody)
			Local $sHeader, $vBuffer
			; catch header
			While 1
				If TimerDiff($_HTTPReq_iTimerInit) > $_HTTPReq_iTimeout Then Return SetError(1, 0, 0)
				;
				$vBuffer = TCPRecv($_HTTPReq_hConnect, $_HTTPReq_TCP_BUFFER_SIZE, 1)
				If @error = -1 Then ExitLoop ;server closed connection/transfer ended
				;
				If $vBuffer Then
					$sHeader &= $vBuffer
					If StringInStr($sHeader, $_HTTPReq_CRLF_BIN & $_HTTPReq_CRLF_BIN, $STR_NOCASESENSEBASIC, -1) Then ExitLoop
				EndIf
			WEnd
			; split to header and body
			Local $aTmp = StringSplit($sHeader, $_HTTPReq_CRLF_BIN & $_HTTPReq_CRLF_BIN, $STR_ENTIRESPLIT + $STR_NOCOUNT)
			If @error Then Return SetError(2, 0, 0)

			$sHeader = BinaryToString(Binary($aTmp[0]), 4) ;save header

			If UBound($aTmp) > 1 Then $sBody = $aTmp[1] ;save body
			_BinaryEnsure($sBody)

			Return $sHeader
		EndFunc   ;==>__HTTP_Recv_Header

		Func __HTTP_Recv_Raw($iContentLength)
			Local $iOffset = 0
			Local $bRecv, $iMissCount = 0
			Local $tBuffer = DllStructCreate('byte[' & $iContentLength + $_HTTPReq_TCP_BUFFER_SIZE * 2 & ']')
			Local $pBuffer = DllStructGetPtr($tBuffer)

			While 1
				If TimerDiff($_HTTPReq_iTimerInit) > $_HTTPReq_iTimeout Then _
						Return SetError(1, 0, DllStructGetData(DllStructCreate('byte[' & $iOffset & ']', $pBuffer), 1))
				;
				$bRecv = TCPRecv($_HTTPReq_hConnect, $_HTTPReq_TCP_BUFFER_SIZE, 1)
				If @error = -1 Then ExitLoop ;server closed connection/transfer ended
				;
				If $bRecv Then
					DllStructSetData(DllStructCreate('byte[' & BinaryLen($bRecv) & ']', $pBuffer + $iOffset), 1, $bRecv)
					$iOffset += BinaryLen($bRecv)
					$iMissCount = 0
				Else
					$iMissCount += 1
				EndIf
				If $iOffset >= $iContentLength Or $iMissCount >= $_HTTPReq_MISS_THRESHOLD Then ExitLoop
			WEnd

			Return DllStructGetData(DllStructCreate('byte[' & $iOffset & ']', $pBuffer), 1)

		EndFunc   ;==>__HTTP_Recv_Raw
	#EndRegion RECEIVERS
	Func __HTTP_Build_Request($sHost, $sPath = "", $sQuery = "", $sVerb = "", $aHeader = "", $sMessageBody = "")
		; Request - http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5
		; Entity - http://www.w3.org/Protocols/rfc2616/rfc2616-sec7.html#sec7.1
;~
;~ 				 Request       = Request-Line              ; Section 5.1
;~                         *(( general-header        ; Section 4.5
;~                          | request-header         ; Section 5.3
;~                          | entity-header ) CRLF)  ; Section 7.1
;~                         CRLF
;~                         [ message-body ]          ; Section 4.3
;~

		If Not String($sHost) Or StringLen($sHost) < 3 Then Return SetError(1, 0, 0)
		__HTTP_Default($sPath, "/")
		__HTTP_Default($sQuery, "")
		__HTTP_Default($sVerb, "GET")
		Local $aHeaderDef[] = [""]
		__HTTP_Default($aHeader, $aHeaderDef)
		__HTTP_Default($sMessageBody, "")
;~
;~ 		    Request-Line = Method SP Request-URI SP HTTP-Version CRLF
;~ 		    Ex. =  GET http://www.w3.org/pub/WWW/TheProject.html HTTP/1.1
		Local $sRequest_Line = $sVerb & " " & $sPath & $sQuery & " HTTP/1.1" & @CRLF
;~
;~ 		    general-header = Cache-Control            ; Section 14.9
;~                       | Connection               ; Section 14.10
;~                       | Date                     ; Section 14.18
;~                       | Pragma                   ; Section 14.32
;~                       | Trailer                  ; Section 14.40
;~                       | Transfer-Encoding        ; Section 14.41
;~                       | Upgrade                  ; Section 14.42
;~                       | Via                      ; Section 14.45
;~                       | Warning                  ; Section 14.46
		Local $sGeneralHeader = "Host: " & $sQuery & @CRLF
;~
;~        request-header = Accept                   ; Section 14.1
;~                       | Accept-Charset           ; Section 14.2
;~                       | Accept-Encoding          ; Section 14.3
;~                       | Accept-Language          ; Section 14.4
;~                       | Authorization            ; Section 14.8
;~                       | Expect                   ; Section 14.20
;~                       | From                     ; Section 14.22
;~                       | Host                     ; Section 14.23
;~                       | If-Match                 ; Section 14.24
;~                       | If-Modified-Since        ; Section 14.25
;~                       | If-None-Match            ; Section 14.26
;~                       | If-Range                 ; Section 14.27
;~                       | If-Unmodified-Since      ; Section 14.28
;~                       | Max-Forwards             ; Section 14.31
;~                       | Proxy-Authorization      ; Section 14.34
;~                       | Range                    ; Section 14.35
;~                       | Referer                  ; Section 14.36
;~                       | TE                       ; Section 14.39
;~                       | User-Agent               ; Section 14.43
		Local $sRequestHeader = ""
		For $i = 0 To UBound($aHeader) - 1
			$sRequestHeader &= (StringInStr($aHeader[$i], @CRLF, 2) ? $aHeader[$i] : ($aHeader[$i] & @CRLF))
		Next

		If Not StringInStr($sRequestHeader, "Accept:", 2) Then $sRequestHeader &= "Accept: */*" & @CRLF
;~
;~        entity-header  = Allow                    ; Section 14.7
;~                       | Content-Encoding         ; Section 14.11
;~                       | Content-Language         ; Section 14.12
;~                       | Content-Length           ; Section 14.13
;~                       | Content-Location         ; Section 14.14
;~                       | Content-MD5              ; Section 14.15
;~                       | Content-Range            ; Section 14.16
;~                       | Content-Type             ; Section 14.17
;~                       | Expires                  ; Section 14.21
;~                       | Last-Modified            ; Section 14.29
;~                       | extension-header
;~        extension-header = message-header

		If StringLen($sMessageBody) > 0 And __HTTP_Parse_Content_Length($sRequestHeader) = -1 Then _
				$sRequestHeader &= "Content-Length: " & StringLen($sMessageBody) & @CRLF

		Return $sRequest_Line & $sGeneralHeader & $sRequestHeader & @CRLF & $sMessageBody
	EndFunc   ;==>__HTTP_Build_Request

	Func __HTTP_Default(ByRef $vValue, $vDefaultValue)
		If $vValue = Default Or $vValue = Null Or $vValue = -1 Or $vValue = "" Then $vValue = $vDefaultValue
	EndFunc   ;==>__HTTP_Default

	Func __HTTP_DefaultHeader(ByRef $sHeader, $sHeaderField,$sDefaultValue)
		If Not StringRegExp($sHeader,''&$sHeaderField&'') Then

		EndIf
	EndFunc
#EndRegion PRIVATE

#Region HELPERS
	Func _Array_1DTo2D(ByRef $avArray, $iWidth)
		Local $iArraySize = UBound($avArray), $iHeight = Ceiling($iArraySize / 2), $iPos = 0
		Local $avReturn[$iHeight][$iWidth]

		For $i = 0 To $iHeight - 1 ;  1D
			For $j = 0 To $iWidth - 1 ; 2D
				$iPos = $i * $iWidth + $j
				If $iPos >= $iArraySize Then ExitLoop
				$avReturn[$i][$j] = $avArray[$iPos]
			Next
		Next

		Return $avReturn
	EndFunc   ;==>_Array_1DTo2D

	Func _BinaryEnsure(ByRef $bBinary)
		$bBinary = Binary((StringLeft($bBinary, 2) = "0x") ? $bBinary : ("0x" & $bBinary))
	EndFunc   ;==>_BinaryEnsure

	; #FUNCTION# ====================================================================================================================
	; Name ..........: _BinaryMerge
	; Description ...: Merges two binary strings
	; Syntax ........: _BinaryMerge($bBin1, $bBin2)
	; Parameters ....: $bBin1               - A binary value.
	;                  $bBin2               - A binary value.
	; Return values .: Merged binary
	; Author ........: rindeal <dev.rindeal at outlook.com>
	; Modified ......:
	; Version .......: 2014-03-05
	; Requirements ..: Nothing special
	; Performance ...: 10k times in 200 ms
	; Remarks .......:
	; Related .......:
	; Link ..........: https://gist.github.com/rindeal/9358771
	; Example .......: No
	; ===============================================================================================================================
	Func _BinaryMerge($bBin1, $bBin2)
		$bBin1 = Binary($bBin1)
		$bBin2 = Binary($bBin2)
		Local $iBinLen1 = BinaryLen($bBin1), $iBinLen2 = BinaryLen($bBin2)

		If $iBinLen1 = 0 Then Return $bBin2
		If $iBinLen2 = 0 Then Return $bBin1

		Local $tBuffer = DllStructCreate('byte[' & $iBinLen1 + $iBinLen2 & ']')
		Local $pBuffer = DllStructGetPtr($tBuffer)

		DllStructSetData($tBuffer, 1, $bBin1)
		DllStructSetData(DllStructCreate('byte[' & $iBinLen2 & ']', $pBuffer + $iBinLen1), 1, $bBin2)

		Return DllStructGetData($tBuffer, 1)
	EndFunc   ;==>_BinaryMerge
#EndRegion HELPERS
