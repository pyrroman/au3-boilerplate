#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Run_Obfuscator=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include "AutoitObject.au3"
#include <INet.au3>

Opt("MustDeclareVars", 1)

; Error monitoring
Global $oError = ObjEvent("AutoIt.Error", "_ErrFunc")

_AutoItObject_StartUp()

Global $oSMTP = _SmtpMailObject()
Global $aBody[1] = ["Test message"]

With $oSMTP
	.Server = "some.valid.server.com"
	.FromName = "" ; "Some Name" ;<- empty for testing for _INetSmtpMail() to error-out
	.FromAddress = "Valid.Address@mail.com"
	.ToAddress = "OtherValid.Address@mail.com"
	.Subject = "Subject of the message"
	.Body = $aBody
	.Trace = True
EndWith


; Send mail
ConsoleWrite("+Return value = " & $oSMTP.Send & @CRLF)

; Check error
ConsoleWrite("!Error number = " & $oSMTP.__error__ & @CRLF)

$oSMTP = 0
_AutoItObject_Shutdown()

Func _SmtpMailObject()
	Local $oClass = _AutoItObject_Class()
	With $oClass
		.AddMethod("Send", "_SmtpMailObject_InetSmtpMail")
		.AddProperty("Server")
		.AddProperty("FromName")
		.AddProperty("FromAddress")
		.AddProperty("ToAddress")
		.AddProperty("Subject")
		.AddProperty("Body")
		.AddProperty("Helo")
		.AddProperty("First", $ELSCOPE_PUBLIC, " ")
		.AddProperty("Trace", $ELSCOPE_PUBLIC, False)
	EndWith
	Return $oClass.Object
EndFunc   ;==>_SmtpMailObject


Func _SmtpMailObject_InetSmtpMail($oSelf)
	With $oSelf
		Local $iOut = _INetSmtpMail(.Server, .FromName, .FromAddress, .ToAddress, .Subject, .Body, .Helo, .First, .Trace)
	EndWith
	Return SetError(@error, 0, $iOut)
EndFunc   ;==>_SmtpMailObject_InetSmtpMail


Func _ErrFunc()
	ConsoleWrite("! COM Error !  Number: 0x" & Hex($oError.number, 8) & "   ScriptLine: " & $oError.scriptline & " - " & $oError.windescription & @CRLF)
	Return
EndFunc   ;==>_ErrFunc
