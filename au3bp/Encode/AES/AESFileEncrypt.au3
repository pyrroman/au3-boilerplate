; -----------------------------------------------------------------------------
; AES Machine Code UDF File Example
; Purpose: Provide Machine Code Version of AES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "AESFile.au3"

Dim $SrcFile = FileOpenDialog("Open File", "", "Any File (*.*)")
If $SrcFile = "" Then Exit

Dim $DestFile = FileSaveDialog("Save Result As", "", "AES Encrypt File (*.AESEncrypt)", 16, $SrcFile & ".AESEncrypt")
If $DestFile = "" Then Exit

Dim $Timer = TimerInit()
Dim $IV = Binary('0x00000000000000000000000000000000')
Dim $Key = Binary('0x00000000000000000000000000000000')

_AesEncryptFile($Key, $SrcFile, $DestFile, "CBC", $IV)

MsgBox (0, "AES File Encrypt", "Encrypt " & FileGetSize($SrcFile) & " bytes file in " & Round(TimerDiff($Timer)) & " ms")
