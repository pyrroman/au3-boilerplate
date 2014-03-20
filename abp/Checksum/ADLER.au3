; -----------------------------------------------------------------------------
; Adler-32 Checksum Machine Code UDF
; Purpose: Provide The Machine Code Version of Adler-32 Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include-once
#Include <Memory.au3>

Global $_ADLER_CodeBuffer, $_ADLER_CodeBufferMemory

Func _ADLER_Exit()
	$_ADLER_CodeBuffer = 0
	_MemVirtualFree($_ADLER_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc

Func _ADLER($Data, $Initial = 1)
	If Not IsDllStruct($_ADLER_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Opcode = Binary('0x55450FB7D041C1E8104189D15756534883EC0885D27E69BEB0150000BB718007804181F9B015000089F54589CB410F4EE94889C84129EB83ED01488D7C29014589D90FB6104883C0014101D24501D04839F875EE4489D0488D4C2901F7E34489C0C1EA0F69D2F1FF00004129D2F7E3C1EA0F69D2F1FF00004129D04585DB7FA14883C4084489C05B5EC1E0105F4409D05DC3')
		Else
			Local $Opcode = Binary('0x5557565383EC048B5C24208B7C241C8B7424180FB7CBC1EB1085FF7E5181FFB015000089FD7E05BDB015000029EF31C0893C240FB6140683C00101D101CB39C575F189C801EEBD71800780F7E589D8C1EA0F69D2F1FF000029D1F7E58B0424C1EA0F69D2F1FF000029D385C07FAF89D883C404C1E01009C85B5E5F5DC3')
		EndIf
		$Opcode = Binary($Opcode)

		$_ADLER_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_ADLER_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_ADLER_CodeBufferMemory)
		DllStructSetData($_ADLER_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_ADLER_Exit")
	EndIf

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)

	Local $Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($_ADLER_CodeBuffer), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"uint", $Initial, _
													"uint", 0)

	Return $Ret[0]
EndFunc
