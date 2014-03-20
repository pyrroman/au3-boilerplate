; -----------------------------------------------------------------------------
; Base64 Machine Code UDF Example
; Purpose: Provide  Machine Code Version of Base64 Encoder/Decoder In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "Base64.au3"

Dim $BufferSize = 0x80000
Dim $SrcFile = FileOpenDialog("Open File", "", "B64 Encode File (*.B64Encode)")
If $SrcFile = "" Then Exit

Dim $DestFile = FileSaveDialog("Save Result As", "", "B64 Decode File (*.B64Decode)", 16, StringTrimRight($SrcFile, 10) & ".B64Decode")
If $DestFile = "" Then Exit

Dim $Timer = TimerInit()

Dim $SrcFileSize = FileGetSize($SrcFile)
Dim $SrcFileHandle = FileOpen($SrcFile)
Dim $DestFileHandle = FileOpen($DestFile, 2 + 16)

Dim $State = _Base64DecodeInit()
For $i = 1 To Ceiling($SrcFileSize / $BufferSize)
	FileWrite($DestFileHandle, _Base64DecodeData($State, FileRead($SrcFileHandle, $BufferSize)))
Next

FileClose($SrcFileHandle)
FileClose($DestFileHandle)

MsgBox (0, "Base 64 File Decode", "Decode " & FileGetSize($SrcFile) & " bytes file in " & Round(TimerDiff($Timer)) & " ms")
