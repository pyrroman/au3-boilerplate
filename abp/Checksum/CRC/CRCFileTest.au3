; -----------------------------------------------------------------------------
; CRC Checksum Machine Code UDF Example
; Purpose: Provide The Machine Code Version of CRC16/CRC32 Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "CRC.au3"

Dim $BufferSize = 0x80000
Dim $Filename = FileOpenDialog("Open File", "", "Any File (*.*)")
If $Filename = "" Then Exit

Dim $Timer = TimerInit()
Dim $CRC32 = 0, $CRC16 = 0, $Data
Dim $FileSize = FileGetSize($Filename)
Dim $FileHandle = FileOpen($Filename, 16)

For $i = 1 To Ceiling($FileSize / $BufferSize)
	$Data = FileRead($FileHandle, $BufferSize)
	$CRC32 = _CRC32($Data, BitNot($CRC32))
	$CRC16 = _CRC16($Data, $CRC16)
Next
FileClose($FileHandle)

MsgBox(0, "Result (" & Round(TimerDiff($Timer)) & " ms)", "CRC16: " & Hex($CRC16, 4) & @CRLF & "CRC32: " & Hex($CRC32, 8))
