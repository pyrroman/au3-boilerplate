; -----------------------------------------------------------------------------
; ARC4 Machine Code UDF
; Purpose: Provide The Machine Code Version of ARC4 Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include-once
#Include <Memory.au3>

Global $_ARC4_CodeBuffer, $_ARC4_CodeBufferMemory, $_ARC4_Init, $_ARC4_Crypt

Func _ARC4_Exit()
	$_ARC4_CodeBuffer = 0
	_MemVirtualFree($_ARC4_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc

Func _ARC4_Init($Key)
	If Not IsDllStruct($_ARC4_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Opcode = '0x89C0554889C84889D54989CA4531C95756534883EC08C70100000000C741040000000045884A084183C1014983C2014181F90001000075EB488DB9000100004531D2664531C9EB3641BA0100000031F60FB658080FB6142E8D3413468D0C0E450FB6C94D63D9420FB6741908408870084883C00142885C19084839F8740E4539D07EC54963F24183C201EBC44883C4085B5E5F5DC389DB56534883EC084585C0448B11448B49047E4E4183E8014A8D7402014183C2014181E2FF0000004963DA0FB6441908468D0C08450FB6C94D63D9460FB644190844884419084288441908418D04000FB6C00FB644010830024883C2014839F275BB448911448949044883C4085B5EC3'
		Else
			Local $Opcode = '0x89C05531C057565383EC088B4C241C8B7C2420C70100000000C74104000000008844010883C0013D0001000075F28D910001000031DB8954240489C831D2891C2489CEEB32C704240100000031ED0FB648080FB61C2F8D2C198D5415000FB6D20FB66C160889EB88580883C001884C16083B44240474128B0C24394C24247EC58B2C2483042401EBC583C4085B5E5F5DC2100089DB5557565383EC088B5424248B44241C8B6C242085D28B188B48047E5B31D2895C2404892C248B5C240483C30181E3FF000000895C24040FB67418088B6C24048D0C0E0FB6C90FB67C080889FB885C280889F38D343781E6FF000000885C08080FB67430088B3C2489F3301C1783C2013B54242475B089EB891889480483C4085B5E5F5DC21000'
		EndIf
		$_ARC4_Init = (StringInStr($Opcode, "89C0") - 3) / 2
		$_ARC4_Crypt = (StringInStr($Opcode, "89DB") - 3) / 2
		$Opcode = Binary($Opcode)

		$_ARC4_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_ARC4_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_ARC4_CodeBufferMemory)
		DllStructSetData($_ARC4_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_ARC4_Exit")
	EndIf

	$Key = Binary($Key)
	Local $InputLen = BinaryLen($Key)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Key)
	Local $State = DllStructCreate("byte[272]")

	DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($_ARC4_CodeBuffer) + $_ARC4_Init, _
													"ptr", DllStructGetPtr($State), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
	Return $State
EndFunc

Func _ARC4_Crypt(ByRef $State, $Data)
	If Not IsDllStruct($_ARC4_CodeBuffer) Or Not IsDllStruct($State) Then Return SetError(1, 0, Binary(""))

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)

	DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($_ARC4_CodeBuffer) + $_ARC4_Crypt, _
													"ptr", DllStructGetPtr($State), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
	Return DllStructGetData($Input, 1)
EndFunc

Func _ARC4($Key, $Data)
	Local $State = _ARC4_Init($Key)
	Return _ARC4_Crypt($State, $Data)
EndFunc
