; -----------------------------------------------------------------------------
; Adler-32 Checksum Machine Code UDF Example
; Purpose: Provide The Machine Code Version of Adler-32 Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "ADLER.au3"

Dim $ADLER = _ADLER("The quick brown fox jumps over the lazy dog")
MsgBox(0, 'ADLER', Hex($ADLER))
