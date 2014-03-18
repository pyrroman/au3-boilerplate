#include "AutoitObject.au3"
Opt("MustDeclareVars", 1)

; Error monitoring
Global $oError = ObjEvent("AutoIt.Error", "_ErrFunc")

_AutoItObject_StartUp()

; Object/Class
Global $oTCP = _TCPObject()

; Some address
Global $sAddress = "www.google.com"
; Request
Global $sToSend = 'GET /' & "" & ' HTTP/1.1' & @CRLF _
         & 'User-Agent: Test' & @CRLF _
         & 'Host: 127.0.0.1' & @CRLF & @CRLF
; To collect to
Global $sData

; Startup
$oTCP.Startup()

ConsoleWrite("+ IsAlive = " & $oTCP.IsAlive & @CRLF) ; see if it's alive


; Connect
If $oTCP.Connect($oTCP.NomeToIP($sAddress), 80) Then
    ConsoleWrite("+ Socket = " & $oTCP.Socket & @CRLF) ; socket number
    ; Send request
    $oTCP.Send($sToSend)
    ; Receive in a loop
    Do
        $sData = $oTCP.Recv(1024) ; just 1024 bytes
        Sleep(100)
    Until $sData
    ;Close socket
    $oTCP.CloseSocket()
EndIf

ConsoleWrite("+ Socket = " & $oTCP.Socket & @CRLF) ; socket number

; Shutdown
$oTCP.Shutdown()

ConsoleWrite("+ IsAlive = " & $oTCP.IsAlive & @CRLF) ; see if it's alive now

MsgBox(0, $sAddress & " 1024 bytes", $sData)

; Release the object
$oTCP = 0




Func _TCPObject($iStartup = False)
    Local $oObj = _AutoItObject_Create()
    _AutoItObject_AddMethod($oObj, "Accept", "_TCP_Accept")
    _AutoItObject_AddMethod($oObj, "CloseSocket", "_TCP_CloseSocket")
    _AutoItObject_AddMethod($oObj, "Connect", "_TCP_Connect")
    _AutoItObject_AddMethod($oObj, "Listen", "_TCP_Listen")
    _AutoItObject_AddMethod($oObj, "NomeToIP", "_TCP_NomeToIP")
    _AutoItObject_AddMethod($oObj, "Recv", "_TCP_Recv")
    _AutoItObject_AddMethod($oObj, "Send", "_TCP_Send")
    _AutoItObject_AddMethod($oObj, "Shutdown", "_TCP_Shutdown")
    _AutoItObject_AddMethod($oObj, "Startup", "_TCP_Startup")
    _AutoItObject_AddMethod($oObj, "Timeout", "_TCP_Timeout")
	_AutoItObject_AddProperty($oObj, "LastError", $ELSCOPE_READONLY, 0)
    _AutoItObject_AddProperty($oObj, "TimeoutValue", $ELSCOPE_READONLY, 100)
    _AutoItObject_AddProperty($oObj, "IsAlive", $ELSCOPE_READONLY, False)
    _AutoItObject_AddProperty($oObj, "Socket", $ELSCOPE_READONLY)
	_AutoItObject_AddDestructor($oObj, "_TCP_Destructor")
    If $iStartup Then $oObj.Startup
    Return $oObj
EndFunc   ;==>_TCPObject


Func _TCP_Accept($oSelf)
    Local $iOut = TCPAccept($oSelf.Socket)
    $oSelf.LastError = @error
    Return $iOut
EndFunc   ;==>_TCP_Accept

Func _TCP_CloseSocket($oSelf)
    Local $iOut = TCPCloseSocket($oSelf.Socket)
    $oSelf.LastError = @error
    $oSelf.Socket = 0
    Return $iOut
EndFunc   ;==>_TCP_CloseSocket

Func _TCP_Connect($oSelf, $sIpAddress, $iPort)
    Local $iOut = TCPConnect($sIpAddress, $iPort)
    $oSelf.LastError = @error
	$oSelf.Socket = $iOut
    Return ($iOut <> 0 And $iOut <> -1)
EndFunc   ;==>_TCP_Connect

Func _TCP_Destructor($oSelf)
	If $oSelf.Socket Then $oSelf.CloseSocket()
    If $oSelf.IsAlive Then $oSelf.Shutdown()
EndFunc   ;==>_TCP_Destructor

Func _TCP_Listen($oSelf, $sIpAddress, $iPort, $iMaxPendingConnection = Default)
    Local $iOut = TCPListen($sIpAddress, $iPort, $iMaxPendingConnection)
    $oSelf.LastError = @error
    $oSelf.Socket = $iOut
    Return ($iOut <> 0 And $iOut <> -1)
EndFunc   ;==>_TCP_Listen

Func _TCP_NomeToIP($oSelf, $sName)
    Local $sOut = TCPNameToIP($sName)
    $oSelf.LastError = @error
    Return $sOut
EndFunc   ;==>_TCP_NomeToIP

Func _TCP_Recv($oSelf, $iLen, $iFlag = 0)
    Local $vOut = TCPRecv($oSelf.Socket, $iLen, $iFlag)
    $oSelf.LastError = @error
    Return $vOut
EndFunc   ;==>_TCP_Recv

Func _TCP_Send($oSelf, $vData)
    Local $iOut = TCPSend($oSelf.Socket, $vData)
    $oSelf.LastError = @error
    Return $iOut
EndFunc   ;==>_TCP_Send

Func _TCP_Shutdown($oSelf)
	If Not $oSelf.IsAlive Then Return $oSelf.IsAlive
    Local $iRet = TCPShutdown()
    $oSelf.LastError = @error
    $oSelf.IsAlive = Not $iRet
    Return $iRet
EndFunc   ;==>_TCP_Shutdown

Func _TCP_Startup($oSelf)
	If $oSelf.IsAlive Then Return Not $oSelf.IsAlive
    Local $iRet = TCPStartup()
    $oSelf.LastError = @error
    $oSelf.IsAlive = $iRet
	Return $iRet
EndFunc   ;==>_TCP_Startup

Func _TCP_Timeout($oSelf, $iTimeout)
    Local $iOpt = Opt("TCPTimeout", $iTimeout)
    $oSelf.LastError = @error
    $oSelf.TimeoutValue = $iTimeout
    Return $iOpt
EndFunc   ;==>_TCP_Timeout


Func _ErrFunc()
    ConsoleWrite("! COM Error !  Number: 0x" & Hex($oError.number, 8) & "   ScriptLine: " & $oError.scriptline & " - " & $oError.windescription & @CRLF)
    Return
EndFunc   ;==>_ErrFunc
