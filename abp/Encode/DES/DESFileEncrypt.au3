; -----------------------------------------------------------------------------
; DES/3DES Machine Code UDF File Example
; Purpose: Provide Machine Code Version of DES/3DES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "DESFile.au3"

Dim $SrcFile = FileOpenDialog("Open File", "", "Any File (*.*)")
If $SrcFile = "" Then Exit

Dim $DestFile = FileSaveDialog("Save Result As", "", "DES Encrypt File (*.DESEncrypt)", 16, $SrcFile & ".DESEncrypt")
If $DestFile = "" Then Exit

Dim $Timer = TimerInit()
Dim $Key = Binary('0x0000000000000000')

_DesEncryptFile($Key, $SrcFile, $DestFile)

MsgBox (0, "DES File Encrypt", "Encrypt " & FileGetSize($SrcFile) & " bytes file in " & Round(TimerDiff($Timer)) & " ms")
