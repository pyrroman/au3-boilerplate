; -----------------------------------------------------------------------------
; DES/3DES Machine Code UDF Example
; Purpose: Provide Machine Code Version of DES/3DES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "DES.au3"

Dim $Encrypt = _DesEncrypt("The Key", "The quick brown fox jumped over the lazy dog")
MsgBox(0, 'Encrypt String by DES Algorithm', $Encrypt)

Dim $Decrypt = _DesDecrypt("The Key", $Encrypt)
MsgBox(0, 'Decrypt Binary Result', $Decrypt)

Dim $String = BinaryToString($Decrypt)
MsgBox(0, 'Decrypt String Result', $String)

Dim $Encrypt = _3DesEncrypt("The Key", "The quick brown fox jumped over the lazy dog")
MsgBox(0, 'Encrypt String by 3DES Algorithm', $Encrypt)

Dim $Decrypt = _3DesDecrypt("The Key", $Encrypt)
MsgBox(0, 'Decrypt Binary Result', $Decrypt)

Dim $String = BinaryToString($Decrypt)
MsgBox(0, 'Decrypt String Result', $String)
