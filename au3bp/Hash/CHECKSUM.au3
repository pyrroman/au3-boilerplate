; -----------------------------------------------------------------------------
; CRC16/CRC32/ADLER32 Checksum UDF
; Purpose: Provide The Machine Code Version of CRC16/CRC32/ADLER32 Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include-once
#Include <Memory.au3>

Global $_CHECKSUM_CodeBuffer, $_CHECKSUM_CodeBufferMemory
Global $_CRC16_InitOffset, $_CRC16_InputOffset, $_CRC16_ResultOffset
Global $_CRC32_InitOffset, $_CRC32_InputOffset, $_CRC32_ResultOffset
Global $_ADLER32_InitOffset, $_ADLER32_InputOffset, $_ADLER32_ResultOffset

Global $_HASH_CRC16[4] = [2, 520, '_CRC16_', '_CHECKSUM_']
Global $_HASH_CRC32[4] = [4, 1040, '_CRC32_', '_CHECKSUM_']
Global $_HASH_ADLER32[4] = [4, 4, '_ADLER32_', '_CHECKSUM_']

Func _CHECKSUM_Exit()
	$_CHECKSUM_CodeBuffer = 0
	_MemVirtualFree($_CHECKSUM_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc

Func _CHECKSUM_Startup()
	If Not IsDllStruct($_CHECKSUM_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Opcode = '0x89DBEB3289C9EB5E89D2E9F800000087DBEB7E87C9E9AA00000087D2E9ED00000009DBE9CF00000009C9E9D100000009D2E9ED0000004989C8664183200066BA01A048C7C1000100006689C866FFC8516A085966D1E873036631D0E2F6596641890448E2E4C34989C841832000BA2083B8ED48C7C10001000089C8FFC8516A0859D1E8730231D0E2F85941890488E2E9C34989C94831C94489C166418B014885D2741C67E319448A024130C04D0FB6C066C1E80866433344410248FFC2E2E766418901C34989C94831C94489C1418B01F7D04885D2741A67E317448A024130C04D0FB6C0C1E808433344810448FFC2E2E9F7D0418901C3668B0186E0668902C38B010FC88902C3C70101000000C3518B014889D14C89C24189C0E806000000598901C3EBDB55450FB7D041C1E8104189D15756534883EC0885D27E69BEB0150000BB718007804181F9B015000089F54589CB410F4EE94889C84129EB83ED01488D7C29014589D90FB6104883C0014101D24501D04839F875EE4489D0488D4C2901F7E34489C0C1EA0F69D2F1FF00004129D2F7E3C1EA0F69D2F1FF00004129D04585DB7FA14883C4084489C05B5EC1E0105F4409D05DC3'
		Else
			Local $Opcode = '0x89DB83EC048B442408890424E80601000083C404C2100089C983EC048B442408890424E82001000083C404C2100089D283EC048B442408890424E8BF01000083C404C2100087DB83EC1C8B442428894424088B442424894424048B442420890424E80E01000083C41CC2100087C983EC1C8B442428894424088B442424894424048B442420890424E81801000083C41CC2100087D283EC1C8B442428894424088B442424894424048B442420890424E85801000083C41CC2100009DB83EC1C8B442424894424048B442420890424E80301000083C41CC2100009C983EC1C8B442424894424048B442420890424E8F900000083C41CC2100009D283EC1C8B442424894424048B442420890424E81801000083C41CC210005589E5538B5D086683230066BA01A0B9000100006689C86648516A085966D1E873036631D0E2F6596689044BE2E65B5DC35589E5538B5D08832300BA2083B8EDB9000100008D41FF516A0859D1E8730231D0E2F85989048BE2EB5B5DC35589E553568B5D088B750C8B4D10668B0385F67415E3138A1630C20FB6D266C1E808663344530246E2ED6689035E5B5DC35589E553568B5D088B750C8B4D108B03F7D085F67413E3118A1630C20FB6D2C1E8083344930446E2EFF7D089035E5B5DC35589E556578B75088B7D0C66AD86E066AB5F5E5DC35589E556578B75088B7D0CAD0FC8AB5F5E5DC35589E5538B5D086A018F035B5DC35589E5538B5D088B0350FF7510FF750CE80A000000890383C40C5B5DC3EBC05557565383EC048B5C24208B7C241C8B7424180FB7CBC1EB1085FF7E5181FFB015000089FD7E05BDB015000029EF31C0893C240FB6140683C00101D101CB39C575F189C801EEBD71800780F7E589D8C1EA0F69D2F1FF000029D1F7E58B0424C1EA0F69D2F1FF000029D385C07FAF89D883C404C1E01009C85B5E5F5DC3'
		EndIf
		$_CRC16_InitOffset = (StringInStr($Opcode, "89DB") - 3) / 2
		$_CRC32_InitOffset = (StringInStr($Opcode, "89C9") - 3) / 2
		$_ADLER32_InitOffset = (StringInStr($Opcode, "89D2") - 3) / 2
		$_CRC16_InputOffset = (StringInStr($Opcode, "87DB") - 3) / 2
		$_CRC32_InputOffset = (StringInStr($Opcode, "87C9") - 3) / 2
		$_ADLER32_InputOffset = (StringInStr($Opcode, "87D2") - 3) / 2
		$_CRC16_ResultOffset = (StringInStr($Opcode, "09DB") - 3) / 2
		$_CRC32_ResultOffset = (StringInStr($Opcode, "09C9") - 3) / 2
		$_ADLER32_ResultOffset = (StringInStr($Opcode, "09D2") - 3) / 2
		$Opcode = Binary($Opcode)

		$_CHECKSUM_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_CHECKSUM_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_CHECKSUM_CodeBufferMemory)
		DllStructSetData($_CHECKSUM_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_CHECKSUM_Exit")
	EndIf
EndFunc

Func _CRC16Init()
	If Not IsDllStruct($_CHECKSUM_CodeBuffer) Then _CHECKSUM_Startup()

	Local $Context = DllStructCreate("byte[" & $_HASH_CRC16[1] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_CHECKSUM_CodeBuffer) + $_CRC16_InitOffset, _
													"ptr", DllStructGetPtr($Context), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	Return $Context
EndFunc

Func _CRC32Init()
	If Not IsDllStruct($_CHECKSUM_CodeBuffer) Then _CHECKSUM_Startup()

	Local $Context = DllStructCreate("byte[" & $_HASH_CRC32[1] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_CHECKSUM_CodeBuffer) + $_CRC32_InitOffset, _
													"ptr", DllStructGetPtr($Context), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	Return $Context
EndFunc

Func _ADLER32Init()
	If Not IsDllStruct($_CHECKSUM_CodeBuffer) Then _CHECKSUM_Startup()

	Local $Context = DllStructCreate("byte[" & $_HASH_ADLER32[1] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_CHECKSUM_CodeBuffer) + $_ADLER32_InitOffset, _
													"ptr", DllStructGetPtr($Context), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	Return $Context
EndFunc

Func _CRC16Input(ByRef $Context, $Data)
	If Not IsDllStruct($_CHECKSUM_CodeBuffer) Then _CHECKSUM_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, 0)

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_CHECKSUM_CodeBuffer) + $_CRC16_InputOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
EndFunc

Func _CRC32Input(ByRef $Context, $Data)
	If Not IsDllStruct($_CHECKSUM_CodeBuffer) Then _CHECKSUM_Init()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, 0)

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_CHECKSUM_CodeBuffer) + $_CRC32_InputOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
EndFunc

Func _ADLER32Input(ByRef $Context, $Data)
	If Not IsDllStruct($_CHECKSUM_CodeBuffer) Then _CHECKSUM_Init()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, 0)

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_CHECKSUM_CodeBuffer) + $_ADLER32_InputOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
EndFunc

Func _CRC16Result(ByRef $Context)
	If Not IsDllStruct($_CHECKSUM_CodeBuffer) Then _CHECKSUM_Startup()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, "")

	Local $Digest = DllStructCreate("byte[" & $_HASH_CRC16[0] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_CHECKSUM_CodeBuffer) + $_CRC16_ResultOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Digest), _
													"int", 0, _
													"int", 0)
	Return DllStructGetData($Digest, 1)
EndFunc

Func _CRC32Result(ByRef $Context)
	If Not IsDllStruct($_CHECKSUM_CodeBuffer) Then _CHECKSUM_Init()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, "")

	Local $Digest = DllStructCreate("byte[" & $_HASH_CRC32[0] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_CHECKSUM_CodeBuffer) + $_CRC32_ResultOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Digest), _
													"int", 0, _
													"int", 0)
	Return DllStructGetData($Digest, 1)
EndFunc

Func _ADLER32Result(ByRef $Context)
	If Not IsDllStruct($_CHECKSUM_CodeBuffer) Then _CHECKSUM_Init()
	If Not IsDllStruct($Context) Then Return SetError(1, 0, "")

	Local $Digest = DllStructCreate("byte[" & $_HASH_ADLER32[0] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_CHECKSUM_CodeBuffer) + $_ADLER32_ResultOffset, _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Digest), _
													"int", 0, _
													"int", 0)
	Return DllStructGetData($Digest, 1)
EndFunc

Func _CRC16($Data)
	Local $Context = _CRC16Init()
	_CRC16Input($Context, $Data)
	Return _CRC16Result($Context)
EndFunc

Func _CRC32($Data)
	Local $Context = _CRC32Init()
	_CRC32Input($Context, $Data)
	Return _CRC32Result($Context)
EndFunc

Func _ADLER32($Data)
	Local $Context = _ADLER32Init()
	_ADLER32Input($Context, $Data)
	Return _ADLER32Result($Context)
EndFunc
