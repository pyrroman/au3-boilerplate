; -----------------------------------------------------------------------------
; SHABAL_TINY Hash Machine Code UDF Example
; Purpose: Provide The Machine Code Version of SHABAL Hash Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "SHABAL_TINY.au3"

For $Size = 32 To 512 Step 32
	ConsoleWrite(StringFormat('%-12s %s', 'SHABAL' & $Size, _SHABAL_TINY('The quick brown fox jumps over the lazy dog', $Size)) & @CRLF)
Next
