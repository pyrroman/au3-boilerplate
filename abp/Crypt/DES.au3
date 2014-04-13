; -----------------------------------------------------------------------------
; DES/3DES Machine Code UDF
; Purpose: Provide Machine Code Version of DES/3DES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include-once
#Include <Memory.au3>

Global $_DES_CodeBuffer, $_DES_CodeBufferMemory
Global $_DES_EncryptKeyOffset, $_DES_DecryptKeyOffset, $_3DES_EncryptKeyOffset, $_3DES_DecryptKeyOffset, $_DES_CryptOffset, $_3DES_CryptOffset
Global $_DES_CryptECBOffset, $_3DES_CryptECBOffset, $_DES_EncryptCBCOffset, $_DES_DecryptCBCOffset, $_3DES_EncryptCBCOffset, $_3DES_DecryptCBCOffset

Func _DES_Exit()
	$_DES_CodeBuffer = 0
	_MemVirtualFree($_DES_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc

Func _DES_Startup()
	If Not IsDllStruct($_DES_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Code = '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'
				$Code &= 'JxiIbhoOhkIDY/RKfQc1WgEcoH7ooJbrCM0sBBabJAIcezZRBRaSJwa14z3xpPNXIwMUAQc4iC8EFqOcqZcHiaUqEyDOV+z17u2AxYFD5T7o+IRC9SMGOccj3c6Qp6/R08Q68lXM6JYlk4EbxQQtNICpMwUH7KRUzYnMEiE5Qjy8bxYRyb62/v67heZDL8wJsjbmmf7P6rEPluyKU2R7sNRa9lN8QKDsge5Ie2G0U+VGKXzuPP8PiEenr1IVgOf4VFjkAdmLsJY3oJxS/Ick80Isp6eVTDX1ySH0JK7p9f1mAGQbq1PIUe2MyCpFZvVF3qSUuhGIqaGiJzLTETuop0Em0hw6ZeXy5pR5wngYnvB7SULv6RnsaRjQqSvu7E0fN+xo6OpbLekkBLGoCe0Z6ARoSLY+UiR4nuPP8j5obS4JGnh/hKXgMnOw00YrDRSo8PIoNcrgch3w5DR8MIdcj3gQJIo88Pk4DuU93BWEP+Dc4+RAa6JMFxFIr8hU+VAa/FyPkVivyGT5YA+5FIAk7fYdR/DJaDXg+XQfI3BfkXja61CVzxJ0wiAzqXSTsTh5fD8OiBD/k4Si2SjnkVD+OET05fIsaSSL8qsfOEKLDrdMjHQTM4M8ZjTmPu0OyTIgcQORLErNJRSm941kL6u5LaLnXAPNLgM7ECATujS5jO9mRh7S5rJs2lAZEBBOOCIgVrIlZRmpZIisj6URXxGKGCJoEZUQM+IQFT7GlCU/785IQf3CsYi6pqlPcALxkzL0l1LoH6anImXsCJkPow0I8uyOyC5HZfQZJhe6TBOhhlPuKiHmsYOgRzMpHLGUJ7rAcUKTofUzOMH7yeQUtYF+nBTnxMahmCucx3WsF8iKSW7Xqe2kFOfK6LFpoIXFzdyCIimjOrNxzWOxrFjRIOKp1DmsI9fDsbRZ1ybReyywmGXu2in4sWu8/bYcKam4/PbW9GIF53zj6Px9EMTl2CKpaMD9/NfkzC4kyPjdxNR80I32Qtzi2Lf8ceQi+OLgN3HsC4jo3cT0fPCN9kP4k5occEIBGrn8P3EfiAQB3SKdtTr8cSftHjgfuk5qGJHREAwBTmoftRWsK06MZKkmCAGq29xuiEXydNxcrrBsFNtFqIHlTH8QkZmT5tocI+90R+6Qgq05HIQcATV4BBiN9OsORfkcgiCHKwRXOsOiKDfRNA6IMN9EPDojOH05w6JAN9FMDohIf+oAy1nmibFUHQQRUL6IXHRNWAi+iGR0RmDtWQAd9U4E4mwdEGjv0j0EOiCwsXQBlZqdlQSTcG8IonwUqgGIB4LkeE9MyfFeaqCdZo8U77X12/Xo0mYM9q/ZfxizAvOOf2rrfrm2464qQZv/NyIIpKWyIhGZLfcIJuWEzCiYP6gL0cmJyHP+O73Fv8a+zbvOf7eP/6XwJeh9j8Moxr8v60lUAq0ryF6NDHCF2gM03n8Q86zzhd7nGzlYG+j50JA5MSkAIRkRCQE6MioAIhoSCgI7MysAIxsTCwM8NCwAJD83LycfFw8ABz42LiYeFg4ABj01LSUdFQ0BBRwUDARBWZGA+HCmAVJfT0vTyUAiCSBEEAiJBBICJAFKXidPYAIEBggKAAwODxETFRcZOBscVgHRXoAOEQsYAQAFAxwPBhUKF2AT7BoIEAcAGxQNAik0HyUALzceKDMtITAALDEnOCI1LioQMiQdkUigUOgJ1A/uPcBR8KMGs44EATQfmw7eGYOgbQkQGA0UFwnaFKIV3BAqJIIdKBsFtHonBH4Q0SBoaCxuHiMiDOFNNKHJYaN4OFI4ahkf6HBITE2wGZQNFB2I8pa04UpwaDBg7TkboEMLaAqI7GkgOYAQcKQC4akZqrxItNswxFsZxSYkCeFZKgokaDAMNgkxrmiHTDSAJCwnHOoouFJMaMEybxREmrA6SBtwQkEMRYgJKPKTLIV0Ui1QFGgpjBkMoemWZSBmNPiF1CSUJI1OnXvwmaC2ESCEDNwoKAyGEdoRDi0RWBYUGfdUPCQcJEQkTCQcUCAwaK4UbRkJLOIU0Od80GiR'
				$Code &= 'FEF4DohBD6M5NCOINHhmPcmMmIpEEpwWvNEItNEkQ1xGlELs2hhLAYKBSy2knaX6jBAVAaIEZUM0KEoEgRyp5cgktUEpkfJlBaE8KoWGTIQMkxk0yS1MGUgeYEZ4RjhGSEKwpGQ0KYjiu3zEZ8jIoFSFiCFVKR42CRhoQhFNbgpAFE6eI6EMISQ2CBiGJKai8UkEDYm0SUAmBDiELNFQ0t8pbDQwNwwKXG+UdMoCeFNDQHBGFEU8DRQiGprRFoyEDNIoKB5ArmTRiYSaGDocLEwoEJEKv/SjHufv9Qx44QtBA7cgGAhILD5TFHCiDDrWDxSQkSdCDFlKkExokVBIHDRoNyQKYLRpLSyjeXigKIacjXChhLxSLEOsQkyQcNWW0RzQoPcIaEyhFEwGAssIBC4OlndVCgw2CDf5RxiIvkhxp8k7XcU2NGCGLNAhDJcmn2iKPDO35TdUCky0WWZEGYUIvlN4Q1xFBAR0ZCQQWJSkEEwMtgaFqDSpLawJcMKaLBSIjEz5SVwlAaEFYzcYSTP7UiTb3yWbbsVfHLcZqG0RXWerOJc7VTgGIDGLBPUkLM7PfKcsvlZ0TjYWwYxU0HgM0GiaabrHKECkyDxIusicTekdJB2MHRwduCPtRQRZ6w2ggAA='
		Else
			Local $Code = '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'
				$Code &= '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'
				$Code &= 'nBa80Qi00SRDXEaUQuzaGEsBgoFLLaSdpfqMEBUBogRlNTQoSgSBHKnlyCS1QSmR8mUFoTwqhYZMhAyTGTTJLUwZSB5gRnhGOEZIQrCkZDQpiOK7fMRnyMigVIWIIVUpHjYJGGhCEU1uCkAUTp4joQwhJDYIGIYkpqLxSQQNibRJQCYEOIQs0VDS3ylsNDA3DApcb5R0ygJ4U0NAcEYURTwNFCIamtEWjIQM0igoHkCuZNGJhJoYOhwsTCgQkQq/9KMe5+/1DHjhC0EDtyAYCEgsPlMUcKIMOtYPFJCRJ0IMWUqQTGiRUEgcNGg3JApgtGktLKN5eKAohpyNcKGEvFIsQ6xCTJBw1ZbRHNCg9whoTKEUTAYCywgELg6Wd1UKDDYIN/lHGIi+SHGnyTtdxTY0YIYs0CEMlyafaIo8M7flN1QKTLRZZkQZhQi+U3hDXEUEBHRkJBBYlKQQTAy2BoWoNKktrAlwwposFIiMTPlJXCUBoQVjNxhJM/tSJNvfJZtuxV8ctxmobRFdZ6s4lztVOAYgMYsE9SQszs98pyy+VnRONgfBjFTQeAzQaJppuscoQKTIPEi6yJxN6R0kHYwdHB24I+1FBFnrDaCAAA=='
		EndIf
		Local $Opcode = String(_DES_CodeDecompress($Code))
		$_DES_EncryptKeyOffset = (StringInStr($Opcode, "09C0") - 3) / 2
		$_DES_DecryptKeyOffset = (StringInStr($Opcode, "09DB") - 3) / 2
		$_3DES_EncryptKeyOffset = (StringInStr($Opcode, "09C9") - 3) / 2
		$_3DES_DecryptKeyOffset = (StringInStr($Opcode, "09D2") - 3) / 2
		$_DES_CryptOffset = (StringInStr($Opcode, "09F6") - 3) / 2
		$_3DES_CryptOffset = (StringInStr($Opcode, "09FF") - 3) / 2
		$_DES_CryptECBOffset = (StringInStr($Opcode, "87DB") - 3) / 2
		$_3DES_CryptECBOffset = (StringInStr($Opcode, "87C9") - 3) / 2
		$_DES_EncryptCBCOffset = (StringInStr($Opcode, "87D2") - 3) / 2
		$_DES_DecryptCBCOffset = (StringInStr($Opcode, "87F6") - 3) / 2
		$_3DES_EncryptCBCOffset = (StringInStr($Opcode, "87FF") - 3) / 2
		$_3DES_DecryptCBCOffset = (StringInStr($Opcode, "87E4") - 3) / 2
		$Opcode = Binary($Opcode)
		$Opcode = Binary($Opcode)


		$_DES_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_DES_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_DES_CodeBufferMemory)
		DllStructSetData($_DES_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_DES_Exit")
	EndIf
EndFunc

Func _DesPrepareIV($IV = Default)
	If IsKeyword($IV) Then
		$IV = "0x"
		For $i = 1 To 8
			$IV &= Hex(Random(0, 255, 1), 2)
		Next
		$IV = Binary($IV)
	Else
		Local $IVBuffer = DllStructCreate("byte[8]")
		DllStructSetData($IVBuffer, 1, Binary($IV))
		$IV = DllStructGetData($IVBuffer, 1)
	EndIf
	Return $IV
EndFunc

Func _DesEncryptKey($Key)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()

	Local $DesCtx = DllStructCreate("byte[128]")
	Local $DesKey = DllStructCreate("byte[8]")
	DllStructSetData($DesKey, 1, $Key)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_DES_EncryptKeyOffset, _
													"ptr", DllStructGetPtr($DesCtx), _
													"ptr", DllStructGetPtr($DesKey), _
													"int", 0, _
													"int", 0)

	Return $DesCtx
EndFunc

Func _DesDecryptKey($Key)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()

	Local $DesCtx = DllStructCreate("byte[128]")
	Local $DesKey = DllStructCreate("byte[8]")
	DllStructSetData($DesKey, 1, $Key)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_DES_DecryptKeyOffset, _
													"ptr", DllStructGetPtr($DesCtx), _
													"ptr", DllStructGetPtr($DesKey), _
													"int", 0, _
													"int", 0)

	Return $DesCtx
EndFunc

Func _DesCryptBlock(ByRef $DesCtx, $Data)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()
	If Not IsDllStruct($DesCtx) Then Return SetError(1, 0, Binary(""))

	Local $DataBuffer = DllStructCreate("byte[8]")
	DllStructSetData($DataBuffer, 1, $Data)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_DES_CryptOffset, _
													"ptr", DllStructGetPtr($DesCtx), _
													"ptr", DllStructGetPtr($DataBuffer), _
													"int", 0, _
													"int", 0)

	Return DllStructGetData($DataBuffer, 1)
EndFunc

Func _DesCryptECB(ByRef $DesCtx, $Data)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()
	If Not IsDllStruct($DesCtx) Then Return SetError(1, 0, Binary(""))

	$Data = Binary($Data)
	Local $DataLen = Ceiling(BinaryLen($Data) / 8) * 8
	If $DataLen = 0 Then Return SetError(1, 0, Binary(""))

	Local $DataBuffer = DllStructCreate("byte[" & $DataLen & "]")
	DllStructSetData($DataBuffer, 1, $Data)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_DES_CryptECBOffset, _
														"ptr", DllStructGetPtr($DesCtx), _
														"ptr", DllStructGetPtr($DataBuffer), _
														"uint", $DataLen, _
														"int", 0)
	Return DllStructGetData($DataBuffer, 1)
EndFunc

Func _DesEncryptCBC(ByRef $DesCtx, ByRef $IV, $Data)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()
	If Not IsDllStruct($DesCtx) Then Return SetError(1, 0, Binary(""))

	$Data = Binary($Data)
	Local $DataLen = Ceiling(BinaryLen($Data) / 8) * 8
	If $DataLen = 0 Then Return SetError(1, 0, Binary(""))

	Local $DataBuffer = DllStructCreate("byte[" & $DataLen & "]")
	DllStructSetData($DataBuffer, 1, $Data)

	Local $IVBuffer = DllStructCreate("byte[8]")
	DllStructSetData($IVBuffer, 1, $IV)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_DES_EncryptCBCOffset, _
														"ptr", DllStructGetPtr($DesCtx), _
														"ptr", DllStructGetPtr($DataBuffer), _
														"uint", $DataLen, _
														"ptr", DllStructGetPtr($IVBuffer))
	$IV = DllStructGetData($IVBuffer, 1)
	Return DllStructGetData($DataBuffer, 1)
EndFunc

Func _DesDecryptCBC(ByRef $DesCtx, ByRef $IV, $Data)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()
	If Not IsDllStruct($DesCtx) Then Return SetError(1, 0, Binary(""))

	$Data = Binary($Data)
	Local $DataLen = Ceiling(BinaryLen($Data) / 8) * 8
	If $DataLen = 0 Then Return SetError(1, 0, Binary(""))

	Local $DataBuffer = DllStructCreate("byte[" & $DataLen & "]")
	DllStructSetData($DataBuffer, 1, $Data)

	Local $IVBuffer = DllStructCreate("byte[8]")
	DllStructSetData($IVBuffer, 1, $IV)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_DES_DecryptCBCOffset, _
														"ptr", DllStructGetPtr($DesCtx), _
														"ptr", DllStructGetPtr($DataBuffer), _
														"uint", $DataLen, _
														"ptr", DllStructGetPtr($IVBuffer))
	$IV = DllStructGetData($IVBuffer, 1)
	Return DllStructGetData($DataBuffer, 1)
EndFunc

Func _DesEncryptECB_Pad(ByRef $DesCtx, $Data)
	$Data = Binary($Data)

	Local $PadLen = 8 - Mod(BinaryLen($Data), 8)
	If $PadLen = 0 Then $PadLen = 8

	Local $Pad = DllStructCreate("byte[" & $PadLen & "]")
	DllStructSetData($Pad, 1, Binary('0x80'), 1)
	$Pad = DllStructGetData($Pad, 1)

	Return _DesCryptECB($DesCtx, $Data & $Pad)
EndFunc

Func _DesDecryptECB_Pad(ByRef $DesCtx, $Data)
	$Data = _DesCryptECB($DesCtx, $Data)
	Local $DataLen = BinaryLen($Data)
	For $i = $DataLen To $DataLen - 8 Step -1
		If BinaryMid($Data, $i, 1) = Binary("0x80") Then
			Return BinaryMid($Data, 1, $i - 1)
		EndIf
	Next
	Return $Data
EndFunc

Func _DesEncryptCBC_Pad(ByRef $DesCtx, ByRef $IV, $Data)
	$Data = Binary($Data)

	Local $PadLen = 8 - Mod(BinaryLen($Data), 8)
	If $PadLen = 0 Then $PadLen = 8

	Local $Pad = DllStructCreate("byte[" & $PadLen & "]")
	DllStructSetData($Pad, 1, Binary('0x80'), 1)
	$Pad = DllStructGetData($Pad, 1)

	Return _DesEncryptCBC($DesCtx, $IV, $Data & $Pad)
EndFunc

Func _DesDecryptCBC_Pad(ByRef $DesCtx, ByRef $IV, $Data)
	$Data = _DesDecryptCBC($DesCtx, $IV, $Data)
	Local $DataLen = BinaryLen($Data)
	For $i = $DataLen To $DataLen - 8 Step -1
		If BinaryMid($Data, $i, 1) = Binary("0x80") Then
			Return BinaryMid($Data, 1, $i - 1)
		EndIf
	Next
	Return $Data
EndFunc

Func _DesEncrypt($Key, $Data, $IV = Default)
	$IV = _DesPrepareIV($IV)

	Local $IVBackup = $IV
	Local $DesCtx = _DesEncryptKey($Key)
	Local $Ret = _DesEncryptCBC_Pad($DesCtx, $IV, $Data)

	If BinaryLen($Ret) = 0 Then Return SetError(1, 0, Binary(""))
	Return $IVBackup & $Ret
EndFunc

Func _DesDecrypt($Key, $Data)
	$Data = Binary($Data)
	If BinaryLen($Data) <= 8 Then Return SetError(1, 0, Binary(""))

	Local $IV = BinaryMid($Data, 1, 8)
	$Data = BinaryMid($Data, 9)

	Local $DesCtx = _DesDecryptKey($Key)
	Local $Ret = _DesDecryptCBC_Pad($DesCtx, $IV, $Data)

	If BinaryLen($Ret) = 0 Then Return SetError(1, 0, Binary(""))
	Return $Ret
EndFunc

Func _3DesEncryptKey($Key)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()

	Local $DesCtx = DllStructCreate("byte[384]")
	Local $DesKey = DllStructCreate("byte[24]")
	DllStructSetData($DesKey, 1, $Key)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_3DES_EncryptKeyOffset, _
													"ptr", DllStructGetPtr($DesCtx), _
													"ptr", DllStructGetPtr($DesKey), _
													"int", 0, _
													"int", 0)

	Return $DesCtx
EndFunc

Func _3DesDecryptKey($Key)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()

	Local $DesCtx = DllStructCreate("byte[384]")
	Local $DesKey = DllStructCreate("byte[24]")
	DllStructSetData($DesKey, 1, $Key)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_3DES_DecryptKeyOffset, _
													"ptr", DllStructGetPtr($DesCtx), _
													"ptr", DllStructGetPtr($DesKey), _
													"int", 0, _
													"int", 0)

	Return $DesCtx
EndFunc

Func _3DesCryptBlock(ByRef $DesCtx, $Data)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()
	If Not IsDllStruct($DesCtx) Then Return SetError(1, 0, Binary(""))

	Local $DataBuffer = DllStructCreate("byte[8]")
	DllStructSetData($DataBuffer, 1, $Data)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_3DES_CryptOffset, _
													"ptr", DllStructGetPtr($DesCtx), _
													"ptr", DllStructGetPtr($DataBuffer), _
													"int", 0, _
													"int", 0)

	Return DllStructGetData($DataBuffer, 1)
EndFunc


Func _3DesCryptECB(ByRef $DesCtx, $Data)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()
	If Not IsDllStruct($DesCtx) Then Return SetError(1, 0, Binary(""))

	Local $DataLen = Ceiling(BinaryLen($Data) / 8) * 8
	If $DataLen = 0 Then Return SetError(1, 0, Binary(""))

	Local $DataBuffer = DllStructCreate("byte[" & $DataLen & "]")
	DllStructSetData($DataBuffer, 1, $Data)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_3DES_CryptECBOffset, _
													"ptr", DllStructGetPtr($DesCtx), _
													"ptr", DllStructGetPtr($DataBuffer), _
													"uint", $DataLen, _
													"int", 0)
	Return DllStructGetData($DataBuffer, 1)
EndFunc

Func _3DesEncryptCBC(ByRef $DesCtx, ByRef $IV, $Data)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()
	If Not IsDllStruct($DesCtx) Then Return SetError(1, 0, Binary(""))

	$Data = Binary($Data)
	Local $DataLen = Ceiling(BinaryLen($Data) / 8) * 8
	If $DataLen = 0 Then Return SetError(1, 0, Binary(""))

	Local $DataBuffer = DllStructCreate("byte[" & $DataLen & "]")
	DllStructSetData($DataBuffer, 1, $Data)

	Local $IVBuffer = DllStructCreate("byte[8]")
	DllStructSetData($IVBuffer, 1, $IV)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_3DES_EncryptCBCOffset, _
														"ptr", DllStructGetPtr($DesCtx), _
														"ptr", DllStructGetPtr($DataBuffer), _
														"uint", $DataLen, _
														"ptr", DllStructGetPtr($IVBuffer))
	$IV = DllStructGetData($IVBuffer, 1)
	Return DllStructGetData($DataBuffer, 1)
EndFunc

Func _3DesDecryptCBC(ByRef $DesCtx, ByRef $IV, $Data)
	If Not IsDllStruct($_DES_CodeBuffer) Then _DES_Startup()
	If Not IsDllStruct($DesCtx) Then Return SetError(1, 0, Binary(""))

	$Data = Binary($Data)
	Local $DataLen = Ceiling(BinaryLen($Data) / 8) * 8
	If $DataLen = 0 Then Return SetError(1, 0, Binary(""))

	Local $DataBuffer = DllStructCreate("byte[" & $DataLen & "]")
	DllStructSetData($DataBuffer, 1, $Data)

	Local $IVBuffer = DllStructCreate("byte[8]")
	DllStructSetData($IVBuffer, 1, $IV)

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_DES_CodeBuffer) + $_3DES_DecryptCBCOffset, _
														"ptr", DllStructGetPtr($DesCtx), _
														"ptr", DllStructGetPtr($DataBuffer), _
														"uint", $DataLen, _
														"ptr", DllStructGetPtr($IVBuffer))
	$IV = DllStructGetData($IVBuffer, 1)
	Return DllStructGetData($DataBuffer, 1)
EndFunc

Func _3DesEncryptECB_Pad(ByRef $DesCtx, $Data)
	$Data = Binary($Data)

	Local $PadLen = 8 - Mod(BinaryLen($Data), 8)
	If $PadLen = 0 Then $PadLen = 8

	Local $Pad = DllStructCreate("byte[" & $PadLen & "]")
	DllStructSetData($Pad, 1, Binary('0x80'), 1)
	$Pad = DllStructGetData($Pad, 1)

	Return _3DesCryptECB($DesCtx, $Data & $Pad)
EndFunc

Func _3DesDecryptECB_Pad(ByRef $DesCtx, $Data)
	$Data = _3DesCryptECB($DesCtx, $Data)
	Local $DataLen = BinaryLen($Data)
	For $i = $DataLen To $DataLen - 8 Step -1
		If BinaryMid($Data, $i, 1) = Binary("0x80") Then
			Return BinaryMid($Data, 1, $i - 1)
		EndIf
	Next
	Return $Data
EndFunc

Func _3DesEncryptCBC_Pad(ByRef $DesCtx, ByRef $IV, $Data)
	$Data = Binary($Data)

	Local $PadLen = 8 - Mod(BinaryLen($Data), 8)
	If $PadLen = 0 Then $PadLen = 8

	Local $Pad = DllStructCreate("byte[" & $PadLen & "]")
	DllStructSetData($Pad, 1, Binary('0x80'), 1)
	$Pad = DllStructGetData($Pad, 1)

	Return _3DesEncryptCBC($DesCtx, $IV, $Data & $Pad)
EndFunc

Func _3DesDecryptCBC_Pad(ByRef $DesCtx, ByRef $IV, $Data)
	$Data = _3DesDecryptCBC($DesCtx, $IV, $Data)
	Local $DataLen = BinaryLen($Data)
	For $i = $DataLen To $DataLen - 8 Step -1
		If BinaryMid($Data, $i, 1) = Binary("0x80") Then
			Return BinaryMid($Data, 1, $i - 1)
		EndIf
	Next
	Return $Data
EndFunc

Func _3DesEncrypt($Key, $Data, $IV = Default)
	$IV = _DesPrepareIV($IV)

	Local $IVBackup = $IV
	Local $DesCtx = _3DesEncryptKey($Key)
	Local $Ret = _3DesEncryptCBC_Pad($DesCtx, $IV, $Data)

	If BinaryLen($Ret) = 0 Then Return SetError(1, 0, Binary(""))
	Return $IVBackup & $Ret
EndFunc

Func _3DesDecrypt($Key, $Data)
	$Data = Binary($Data)
	If BinaryLen($Data) <= 8 Then Return SetError(1, 0, Binary(""))

	Local $IV = BinaryMid($Data, 1, 8)
	$Data = BinaryMid($Data, 9)

	Local $DesCtx = _3DesDecryptKey($Key)
	Local $Ret = _3DesDecryptCBC_Pad($DesCtx, $IV, $Data)

	If BinaryLen($Ret) = 0 Then Return SetError(1, 0, Binary(""))
	Return $Ret
EndFunc

Func _DES_CodeDecompress($Code)
	If @AutoItX64 Then
		Local $Opcode = '0x89C04150535657524889CE4889D7FCB28031DBA4B302E87500000073F631C9E86C000000731D31C0E8630000007324B302FFC1B010E85600000010C073F77544AAEBD3E85600000029D97510E84B000000EB2CACD1E8745711C9EB1D91FFC8C1E008ACE8340000003D007D0000730A80FC05730783F87F7704FFC1FFC141904489C0B301564889FE4829C6F3A45EEB8600D275078A1648FFC610D2C331C9FFC1E8EBFFFFFF11C9E8E4FFFFFF72F2C35A4829D7975F5E5B4158C389D24883EC08C70100000000C64104004883C408C389F64156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8C601000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E86401000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E81D01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8DD00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFF56574889CF4889D64C89C1FCF3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
	Else
		Local $Opcode = '0x89C0608B7424248B7C2428FCB28031DBA4B302E86D00000073F631C9E864000000731C31C0E85B0000007323B30241B010E84F00000010C073F7753FAAEBD4E84D00000029D97510E842000000EB28ACD1E8744D11C9EB1C9148C1E008ACE82C0000003D007D0000730A80FC05730683F87F770241419589E8B3015689FE29C6F3A45EEB8E00D275058A164610D2C331C941E8EEFFFFFF11C9E8E7FFFFFF72F2C32B7C2428897C241C61C389D28B442404C70000000000C6400400C2100089F65557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8CD0100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8740100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E82E0100008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8EC0000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB9956578B7C240C8B7424108B4C241485C9742FFC83F9087227F7C7010000007402A449F7C702000000740566A583E90289CAC1E902F3A589D183E103F3A4EB02F3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
	EndIf
	Local $AP_Decompress = (StringInStr($Opcode, "89C0") - 3) / 2
	Local $B64D_Init = (StringInStr($Opcode, "89D2") - 3) / 2
	Local $B64D_DecodeData = (StringInStr($Opcode, "89F6") - 3) / 2
	$Opcode = Binary($Opcode)

	Local $CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
	Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $CodeBufferMemory)
	DllStructSetData($CodeBuffer, 1, $Opcode)

	Local $B64D_State = DllStructCreate("byte[16]")
	Local $Length = StringLen($Code)
	Local $Output = DllStructCreate("byte[" & $Length & "]")

	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $B64D_Init, _
													"ptr", DllStructGetPtr($B64D_State), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	DllCall("user32.dll", "int", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $B64D_DecodeData, _
													"str", $Code, _
													"uint", $Length, _
													"ptr", DllStructGetPtr($Output), _
													"ptr", DllStructGetPtr($B64D_State))

	Local $ResultLen = DllStructGetData(DllStructCreate("uint", DllStructGetPtr($Output)), 1)
	Local $Result = DllStructCreate("byte[" & ($ResultLen + 16) & "]")

	Local $Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $AP_Decompress, _
													"ptr", DllStructGetPtr($Output) + 4, _
													"ptr", DllStructGetPtr($Result), _
													"int", 0, _
													"int", 0)


	_MemVirtualFree($CodeBufferMemory, 0, $MEM_RELEASE)
	Return BinaryMid(DllStructGetData($Result, 1), 1, $Ret[0])
EndFunc
