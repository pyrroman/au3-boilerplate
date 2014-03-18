; -----------------------------------------------------------------------------
; CRC Checksum Machine Code UDF
; Purpose: Provide The Machine Code Version of CRC16/CRC32 Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include-once
#Include <Memory.au3>

Global $_CRC32_CodeBuffer, $_CRC32_CodeBufferMemory
Global $_CRC16_CodeBuffer, $_CRC16_CodeBufferMemory

Func _CRC32_Exit()
	$_CRC32_CodeBuffer = 0
	_MemVirtualFree($_CRC32_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc

Func _CRC16_Exit()
	$_CRC16_CodeBuffer = 0
	_MemVirtualFree($_CRC16_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc

Func _CRC32($Data, $Initial = -1, $Polynomial = 0xEDB88320)
	If Not IsDllStruct($_CRC32_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Opcode = '0xC80004004989CA680001000059678D41FF516A0859D1E873034431C8E2F75989848DFCFBFFFFE2E589D14489C04D85D2741B67E318418A1230C2480FB6D2C1E80833849500FCFFFF49FFC2E2E8F7D0C9C3'
		Else
			Local $Opcode = '0xC8000400538B5514B9000100008D41FF516A0859D1E8730231D0E2F85989848DFCFBFFFFE2E78B5D088B4D0C8B451085DB7416E3148A1330C20FB6D2C1E80833849500FCFFFF43E2ECF7D05BC9C21000'
		EndIf
		$Opcode = Binary($Opcode)

		$_CRC32_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_CRC32_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_CRC32_CodeBufferMemory)
		DllStructSetData($_CRC32_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_CRC32_Exit")
	EndIf

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)

	Local $Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($_CRC32_CodeBuffer), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"uint", $Initial, _
													"uint", $Polynomial)

	Return $Ret[0]
EndFunc

Func _CRC16($Data, $Initial = 0, $Polynomial = 0xA001)
	If Not IsDllStruct($_CRC16_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Opcode = '0xC80002004989CA6800010000596689C866FFC8516A085966D1E87304664431C8E2F5596689844DFEFDFFFFE2E089D1664489C04D85D2741D67E31A418A1230C2480FB6D266C1E8086633845500FEFFFF49FFC2E2E6C9C3'
		Else
			Local $Opcode = '0xC800020053668B5514B9000100006689C86648516A085966D1E873036631D0E2F6596689844DFEFDFFFFE2E28B5D088B4D0C668B451085DB7418E3168A1330C20FB6D266C1E8086633845500FEFFFF43E2EA5BC9C21000'
		EndIf
		$Opcode = Binary($Opcode)

		$_CRC16_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_CRC16_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_CRC16_CodeBufferMemory)
		DllStructSetData($_CRC16_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_CRC16_Exit")
	EndIf

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)

	Local $Ret = DllCall("user32.dll", "word", "CallWindowProc", "ptr", DllStructGetPtr($_CRC16_CodeBuffer), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"ushort", $Initial, _
													"ushort", $Polynomial)

	Return $Ret[0]
EndFunc
