; -----------------------------------------------------------------------------
; DES/3DES Machine Code UDF File Example
; Purpose: Provide Machine Code Version of DES/3DES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

; An example for encrypt/decrypt file by DES/3DES algorithm with CBC bit padding mode
; This code is not intended for real use since it does not provide integrity checking

#Include-once
#Include "DES.au3"

Global $_DesFileBufferSize = 0x10000

Func _DesEncryptFile($Key, $SrcFile, $DestFile, $IV = Default)
	If Not FileExists($SrcFile) Then Return SetError(1, 0, '')

	Local $SrcFileSize = FileGetSize($SrcFile)
	If $SrcFileSize = 0 Then Return SetError(2, 0, '')

	Local $SrcFileHandle = FileOpen($SrcFile, 16)
	Local $DestFileHandle = FileOpen($DestFile, 2 + 16)

	$IV = _DesPrepareIV($IV)
	Local $Ctx = _DesEncryptKey($Key)
	Local $n = Ceiling($SrcFileSize / $_DesFileBufferSize), $Data

	FileWrite($DestFileHandle, $IV)
	For $i = 1 To $n
		If $i <> $n Then
			$Data = _DesEnCryptCBC($Ctx, $IV, FileRead($SrcFileHandle, $_DesFileBufferSize))
		Else
			$Data = _DesEncryptCBC_Pad($Ctx, $IV, FileRead($SrcFileHandle, $_DesFileBufferSize))
		EndIf
		FileWrite($DestFileHandle, $Data)
	Next

	FileClose($SrcFileHandle)
	FileClose($DestFileHandle)
EndFunc

Func _DesDecryptFile($Key, $SrcFile, $DestFile)
	If Not FileExists($SrcFile) Then Return SetError(1, 0, '')

	Local $SrcFileSize = FileGetSize($SrcFile)
	If $SrcFileSize < 8 Then Return SetError(2, 0, '')

	Local $SrcFileHandle = FileOpen($SrcFile, 16)
	Local $DestFileHandle = FileOpen($DestFile, 2 + 16)

	Local $IV = FileRead($SrcFileHandle, 8)
	Local $n = Ceiling($SrcFileSize / $_DesFileBufferSize), $Ctx, $Data

	$Ctx = _DesDecryptKey($Key)
	For $i = 1 To $n
		If $i <> $n Then
			$Data = _DesDecryptCBC($Ctx, $IV, FileRead($SrcFileHandle, $_DesFileBufferSize))
		Else
			$Data = _DesDecryptCBC_Pad($Ctx, $IV, FileRead($SrcFileHandle, $_DesFileBufferSize))
		EndIf
		FileWrite($DestFileHandle, $Data)
	Next

	FileClose($SrcFileHandle)
	FileClose($DestFileHandle)
EndFunc

Func _3DesEncryptFile($Key, $SrcFile, $DestFile, $IV = Default)
	If Not FileExists($SrcFile) Then Return SetError(1, 0, '')

	Local $SrcFileSize = FileGetSize($SrcFile)
	If $SrcFileSize = 0 Then Return SetError(2, 0, '')

	Local $SrcFileHandle = FileOpen($SrcFile, 16)
	Local $DestFileHandle = FileOpen($DestFile, 2 + 16)

	$IV = _DesPrepareIV($IV)
	Local $Ctx = _3DesEncryptKey($Key)
	Local $n = Ceiling($SrcFileSize / $_DesFileBufferSize), $Data

	FileWrite($DestFileHandle, $IV)
	For $i = 1 To $n
		If $i <> $n Then
			$Data = _3DesEnCryptCBC($Ctx, $IV, FileRead($SrcFileHandle, $_DesFileBufferSize))
		Else
			$Data = _3DesEncryptCBC_Pad($Ctx, $IV, FileRead($SrcFileHandle, $_DesFileBufferSize))
		EndIf
		FileWrite($DestFileHandle, $Data)
	Next

	FileClose($SrcFileHandle)
	FileClose($DestFileHandle)
EndFunc

Func _3DesDecryptFile($Key, $SrcFile, $DestFile)
	If Not FileExists($SrcFile) Then Return SetError(1, 0, '')

	Local $SrcFileSize = FileGetSize($SrcFile)
	If $SrcFileSize < 8 Then Return SetError(2, 0, '')

	Local $SrcFileHandle = FileOpen($SrcFile, 16)
	Local $DestFileHandle = FileOpen($DestFile, 2 + 16)

	Local $IV = FileRead($SrcFileHandle, 8)
	Local $n = Ceiling($SrcFileSize / $_DesFileBufferSize), $Ctx, $Data

	$Ctx = _3DesDecryptKey($Key)
	For $i = 1 To $n
		If $i <> $n Then
			$Data = _3DesDecryptCBC($Ctx, $IV, FileRead($SrcFileHandle, $_DesFileBufferSize))
		Else
			$Data = _3DesDecryptCBC_Pad($Ctx, $IV, FileRead($SrcFileHandle, $_DesFileBufferSize))
		EndIf
		FileWrite($DestFileHandle, $Data)
	Next

	FileClose($SrcFileHandle)
	FileClose($DestFileHandle)
EndFunc
