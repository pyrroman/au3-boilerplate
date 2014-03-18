; -----------------------------------------------------------------------------
; XXTEA Machine Code UDF Example
; Purpose: Provide The Machine Code Version of XXTEA Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "XXTEA.au3"

Dim $Encrypt = _XXTEA_Encrypt("The Key", "The quick brown fox jumps over the lazy dog")
MsgBox(0, 'Encrypt String with Zero Padding', $Encrypt)

Dim $Decrypt = _XXTEA_Decrypt("The Key", $Encrypt)
MsgBox(0, 'Decrypt Binary Result', $Decrypt)

Dim $String = BinaryToString($Decrypt)
MsgBox(0, 'Decrypt String Result', $String)

$Encrypt = _XXTEA_Encrypt_Pad("The Key", "0x00000000000000000000000000000000")
MsgBox(0, 'Encrypt Binary With Bit Padding', $Encrypt)

$Decrypt = _XXTEA_Decrypt_Pad("The Key", $Encrypt)
MsgBox(0, 'Decrypt Binary Result', $Decrypt)
