; -----------------------------------------------------------------------------
; SHABAL_TINY Hash Machine Code UDF Example
; Purpose: Provide The Machine Code Version of SHABAL Hash Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "SHABAL_TINY.au3"

Dim $BufferSize = 0x100000
Dim $Filename = FileOpenDialog("Open File", "", "Any File (*.*)")
If $Filename = "" Then Exit

For $Size = 32 To 512 Step 32
	Dim $Timer = TimerInit()
	Dim $State = _SHABAL_TINYInit($Size)

	Dim $FileHandle = FileOpen($Filename, 16)
	For $i = 1 To Ceiling(FileGetSize($Filename) / $BufferSize)
		_SHABAL_TINYInput($State, FileRead($FileHandle, $BufferSize))
	Next
	Dim $Hash = _SHABAL_TINYResult($State)
	FileClose($FileHandle)

	ConsoleWrite(StringFormat('%-12s %5i ms %s', 'SHABAL' & $Size, Round(TimerDiff($Timer)), $Hash) & @CRLF)
Next
