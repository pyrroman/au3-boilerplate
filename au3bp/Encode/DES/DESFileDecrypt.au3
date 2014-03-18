; -----------------------------------------------------------------------------
; DES/3DES Machine Code UDF File Example
; Purpose: Provide Machine Code Version of DES/3DES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "DESFile.au3"

Dim $SrcFile = FileOpenDialog("Open File", "", "DES Encrypt File (*.DESEncrypt)")
If $SrcFile = "" Then Exit

Dim $DestFile = FileSaveDialog("Save Result As", "", "DES Decrypt File (*.DESDecrypt)", 16, StringTrimRight($SrcFile, 11) & ".DESDecrypt")
If $DestFile = "" Then Exit

Dim $Timer = TimerInit()
Dim $Key = Binary('0x0000000000000000')

_DesDecryptFile($Key, $SrcFile, $DestFile)

MsgBox (0, "DES File Decrypt", "Decrypt " & FileGetSize($SrcFile) & " bytes file in " & Round(TimerDiff($Timer)) & " ms")
