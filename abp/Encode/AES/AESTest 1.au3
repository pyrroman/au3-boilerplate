; -----------------------------------------------------------------------------
; AES Machine Code UDF Example
; Purpose: Provide Machine Code Version of AES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "AES.au3"

Dim $Encrypt = _AesEncrypt("The Key", "The quick brown fox jumped over the lazy dog")
MsgBox(0, 'Encrypt String by AES Algorithm', $Encrypt)

Dim $Decrypt = _AesDecrypt("The Key", $Encrypt)
MsgBox(0, 'Decrypt Binary Result', $Decrypt)

Dim $String = BinaryToString($Decrypt)
MsgBox(0, 'Decrypt String Result', $String)
