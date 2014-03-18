; -----------------------------------------------------------------------------
; Base64 Machine Code UDF Example
; Purpose: Provide  Machine Code Version of Base64 Encoder/Decoder In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "Base64.au3"

Dim $Encode = _Base64Encode("The quick brown fox jumps over the lazy dog")
MsgBox(0, 'Base64 Encode Data', $Encode)

Dim $Decode = _Base64Decode($Encode)
MsgBox(0, 'Base64 Decode Data (Binary Format)', $Decode)

Dim $String = BinaryToString($Decode)
MsgBox(0, 'Base64 Decode Data (String Format)', $String)
