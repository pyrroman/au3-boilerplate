#include "../AutoitObject.au3"
Opt("MustDeclareVars", 1)

; Error monitoring
Global $oError = ObjEvent("AutoIt.Error", "_ErrFunc")

; Initialize AutoItObject
_AutoItObject_StartUp()

; Create Object
Global $oObject = _SomeObject()

; Set some property
$oObject.Title = "Hey"

;Display messagebox
$oObject.MsgBox()

; Relese
$oObject = 0 ; <-!Comment this out to see the new behavior!

; That's it! Goodby



; Define object
Func _SomeObject()
	Local $oClassObject = _AutoItObject_Class()
	$oClassObject.Create()
	$oClassObject.AddMethod("MsgBox", "_Obj_MsgBox")
	$oClassObject.AddProperty("Title", $ELSCOPE_PUBLIC, "Something")
	$oClassObject.AddProperty("Text", $ELSCOPE_PUBLIC, "Some text")
	$oClassObject.AddProperty("Flag", $ELSCOPE_PUBLIC, 64 + 262144)
	$oClassObject.AddDestructor("_DestructorForSomeObject")
	Return $oClassObject.Object
EndFunc   ;==>_SomeObject

Func _Obj_MsgBox($oSelf)
	MsgBox($oSelf.Flag, $oSelf.Title, $oSelf.Text)
EndFunc   ;==>_Obj_MsgBox

Func _DestructorForSomeObject($oSelf)
	ConsoleWrite("!...destructing..." & @CRLF)
EndFunc

Func _ErrFunc()
    ConsoleWrite("! COM Error !  Number: 0x" & Hex($oError.number, 8) & "   ScriptLine: " & $oError.scriptline & " - " & $oError.windescription & @CRLF)
    Return
EndFunc   ;==>_ErrFunc




