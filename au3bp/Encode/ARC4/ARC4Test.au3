; -----------------------------------------------------------------------------
; ARC4 Machine Code UDF Example
; Purpose: Provide The Machine Code Version of ARC4 Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "ARC4.au3"

Dim $Encrypt = _ARC4("The Key", "The quick brown fox jumps over the lazy dog")
MsgBox(0, 'Encrypt String', $Encrypt)

Dim $Decrypt = _ARC4("The Key", $Encrypt)
MsgBox(0, 'Decrypt Binary Result', $Decrypt)

Dim $String = BinaryToString($Decrypt)
MsgBox(0, 'Decrypt String Result', $String)
