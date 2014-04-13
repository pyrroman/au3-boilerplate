; -----------------------------------------------------------------------------
; AES Machine Code UDF File Example
; Purpose: Provide Machine Code Version of AES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "AESFile.au3"

Dim $SrcFile = FileOpenDialog("Open File", "", "AES Encrypt File (*.AESEncrypt)")
If $SrcFile = "" Then Exit

Dim $DestFile = FileSaveDialog("Save Result As", "", "AES Decrypt File (*.AESDecrypt)", 16, StringTrimRight($SrcFile, 11) & ".AESDecrypt")
If $DestFile = "" Then Exit

Dim $Timer = TimerInit()
Dim $Key = Binary('0x00000000000000000000000000000000')

_AesDecryptFile($Key, $SrcFile, $DestFile, "CBC")

MsgBox (0, "AES File Decrypt", "Decrypt " & FileGetSize($SrcFile) & " bytes file in " & Round(TimerDiff($Timer)) & " ms")
