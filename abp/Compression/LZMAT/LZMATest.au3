; -----------------------------------------------------------------------------
; LZMA Compression Machine Code UDF Example
; Purpose: Provide The Machine Code Version of LZMA Algorithm In AutoIt
; Author: Ward
; LZMA Copyright (C) 1999-2006 Igor Pavlov
; -----------------------------------------------------------------------------

#Include "LZMA.au3"

Dim $Original = Binary(FileRead(@AutoItExe))
Dim $Compressed = _LZMA_Compress($Original, 5)
Dim $Decompressed = _LZMA_Decompress($Compressed)
Dim $Result = 'Original Size: ' & BinaryLen($Original) & @CRLF
$Result &= 'Compressed Size: ' & BinaryLen($Compressed) & @CRLF
$Result &= 'Decompress Succeed: ' & ($Decompressed = $Original)
MsgBox(0, 'LZMA Level 5 Test', $Result)
