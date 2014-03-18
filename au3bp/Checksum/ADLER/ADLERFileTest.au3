; -----------------------------------------------------------------------------
; Adler-32 Checksum Machine Code UDF Example
; Purpose: Provide The Machine Code Version of Adler-32 Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "ADLER.au3"

Dim $BufferSize = 0x80000
Dim $Filename = FileOpenDialog("Open File", "", "Any File (*.*)")
If $Filename = "" Then Exit

Dim $Timer = TimerInit()
Dim $ADLER = 1
Dim $FileSize = FileGetSize($Filename)
Dim $FileHandle = FileOpen($Filename, 16)

For $i = 1 To Ceiling($FileSize / $BufferSize)
	$ADLER = _ADLER(FileRead($FileHandle, $BufferSize), $ADLER)
Next
FileClose($FileHandle)

MsgBox(0, "Result (" & Round(TimerDiff($Timer)) & " ms)", "ADLER: " & Hex($ADLER, 8))
