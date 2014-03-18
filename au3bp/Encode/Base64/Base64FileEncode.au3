; -----------------------------------------------------------------------------
; Base64 Machine Code UDF Example
; Purpose: Provide  Machine Code Version of Base64 Encoder/Decoder In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "Base64.au3"

Dim $BufferSize = 0x80000
Dim $SrcFile = FileOpenDialog("Open File", "", "Any File (*.*)")
If $SrcFile = "" Then Exit

Dim $DestFile = FileSaveDialog("Save Result As", "", "B64 Encode File (*.B64Encode)", 16, $SrcFile & ".B64Encode")
If $DestFile = "" Then Exit

Dim $Timer = TimerInit()

Dim $SrcFileSize = FileGetSize($SrcFile)
Dim $SrcFileHandle = FileOpen($SrcFile, 16)
Dim $DestFileHandle = FileOpen($DestFile, 2 + 16)

Dim $State = _Base64EncodeInit()
For $i = 1 To Ceiling($SrcFileSize / $BufferSize)
	FileWrite($DestFileHandle, _Base64EncodeData($State, FileRead($SrcFileHandle, $BufferSize)))
Next
FileWrite($DestFileHandle, _Base64EncodeEnd($State))

FileClose($SrcFileHandle)
FileClose($DestFileHandle)

MsgBox (0, "Base 64 File Encode", "Encode " & FileGetSize($SrcFile) & " bytes file in " & Round(TimerDiff($Timer)) & " ms")
