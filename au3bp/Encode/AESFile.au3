; -----------------------------------------------------------------------------
; AES Machine Code UDF File Example
; Purpose: Provide Machine Code Version of AES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

; An example for encrypt/decrypt file by AES algorithm with CBC bit padding/CFB/OFB mode
; This code is not intended for real use since it does not provide integrity checking

#Include-once
#Include "AES.au3"

Global $_AesFileBufferSize = 0x100000

Func _AesEncryptFile($Key, $SrcFile, $DestFile, $Mode = $AES_CBC_MODE, $IV = Default)
	If Not FileExists($SrcFile) Then Return SetError(1, 0, '')

	Local $SrcFileSize = FileGetSize($SrcFile)
	If $SrcFileSize = 0 Then Return SetError(2, 0, '')

	Local $SrcFileHandle = FileOpen($SrcFile, 16)
	Local $DestFileHandle = FileOpen($DestFile, 2 + 16)

	$IV = _AesPrepareIV($IV)
	Local $Ctx = _AesEncryptKey($Key)
	Local $n = Ceiling($SrcFileSize / $_AesFileBufferSize), $Data

	FileWrite($DestFileHandle, $IV)
	Switch String($Mode)
	Case "CFB", $AES_CFB_MODE		
		For $i = 1 To $n
			$Data = _AesEncryptCFB($Ctx, $IV, FileRead($SrcFileHandle, $_AesFileBufferSize))
			FileWrite($DestFileHandle, $Data)
		Next
	Case "OFB", $AES_OFB_MODE
		For $i = 1 To $n
			$Data = _AesCryptOFB($Ctx, $IV, FileRead($SrcFileHandle, $_AesFileBufferSize))
			FileWrite($DestFileHandle, $Data)
		Next
	Case Else
		For $i = 1 To $n
			If $i <> $n Then
				$Data = _AesEncryptCBC($Ctx, $IV, FileRead($SrcFileHandle, $_AesFileBufferSize))
			Else
				$Data = _AesEncryptCBC_Pad($Ctx, $IV, FileRead($SrcFileHandle, $_AesFileBufferSize))
			EndIf
			FileWrite($DestFileHandle, $Data)
		Next
	EndSwitch

	FileClose($SrcFileHandle)
	FileClose($DestFileHandle)
EndFunc

Func _AesDecryptFile($Key, $SrcFile, $DestFile, $Mode = $AES_CBC_MODE)
	If Not FileExists($SrcFile) Then Return SetError(1, 0, '')

	Local $SrcFileSize = FileGetSize($SrcFile)
	If $SrcFileSize < 16 Then Return SetError(2, 0, '')

	Local $SrcFileHandle = FileOpen($SrcFile, 16)
	Local $DestFileHandle = FileOpen($DestFile, 2 + 16)

	Local $IV = FileRead($SrcFileHandle, 16)
	Local $n = Ceiling($SrcFileSize / $_AesFileBufferSize), $Ctx, $Data

	Switch String($Mode)
	Case "CFB", $AES_CFB_MODE
		$Ctx = _AesEncryptKey($Key)
		For $i = 1 To $n
			$Data = _AesDecryptCFB($Ctx, $IV, FileRead($SrcFileHandle, $_AesFileBufferSize))
			FileWrite($DestFileHandle, $Data)
		Next
	Case "OFB", $AES_OFB_MODE
		$Ctx = _AesEncryptKey($Key)
		For $i = 1 To $n
			$Data = _AesCryptOFB($Ctx, $IV, FileRead($SrcFileHandle, $_AesFileBufferSize))
			FileWrite($DestFileHandle, $Data)
		Next
	Case Else
		$Ctx = _AesDecryptKey($Key)
		For $i = 1 To $n
			If $i <> $n Then
				$Data = _AesDecryptCBC($Ctx, $IV, FileRead($SrcFileHandle, $_AesFileBufferSize))
			Else
				$Data = _AesDecryptCBC_Pad($Ctx, $IV, FileRead($SrcFileHandle, $_AesFileBufferSize))
			EndIf
			FileWrite($DestFileHandle, $Data)
		Next
	EndSwitch

	FileClose($SrcFileHandle)
	FileClose($DestFileHandle)
EndFunc
