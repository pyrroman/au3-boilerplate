; -----------------------------------------------------------------------------
; MiniLZO Compression Machine Code UDF Example
; Purpose: Provide The Machine Code Version of MiniLZO Algorithm In AutoIt
; Author: Ward
; MiniLZO Copyright (C) 1996-2008 Markus Franz Xaver Johannes Oberhumer
; -----------------------------------------------------------------------------

#Include "MiniLZO.au3"

Dim $Original = Binary(FileRead(@AutoItExe))
Dim $Compressed = _MINILZO_Compress($Original)
Dim $Decompressed = _MINILZO_Decompress($Compressed)
Dim $Result = 'Original Size: ' & BinaryLen($Original) & @CRLF
$Result &= 'Compressed Size: ' & BinaryLen($Compressed) & @CRLF
$Result &= 'Decompress Succeed: ' & ($Decompressed = $Original)
MsgBox(0, 'MiniLZO Test', $Result)
