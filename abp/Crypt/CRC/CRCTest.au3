; -----------------------------------------------------------------------------
; CRC Checksum Machine Code UDF Example
; Purpose: Provide The Machine Code Version of CRC16/CRC32 Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "CRC.au3"

Dim $CRC32 = _CRC32("The quick brown fox jumps over the lazy dog")
Dim $CRC16 = _CRC16("The quick brown fox jumps over the lazy dog")
MsgBox(0, 'CRC', "CRC16: " & Hex($CRC16, 4) & @CRLF & "CRC32: " & Hex($CRC32))
