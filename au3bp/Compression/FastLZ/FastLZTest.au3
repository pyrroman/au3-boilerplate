; -----------------------------------------------------------------------------
; FastLZ Compression Machine Code UDF Example
; Purpose: Provide The Machine Code Version of FastLZ Algorithm In AutoIt
; Author: Ward
; FastLZ Copyright (C) 2005-2008 Ariya Hidayat (ariya@kde.org)
; -----------------------------------------------------------------------------

#Include "FastLZ.au3"

Dim $Original = Binary(FileRead(@AutoItExe))
Dim $Compressed = _FastLZ_Compress($Original, 1)
Dim $Decompressed = _FastLZ_Decompress($Compressed)
Dim $Result = 'Original Size: ' & BinaryLen($Original) & @CRLF
$Result &= 'Compressed Size: ' & BinaryLen($Compressed) & @CRLF
$Result &= 'Decompress Succeed: ' & ($Decompressed = $Original)
MsgBox(0, 'FastLZ Level 1 Test', $Result)

Dim $Original = Binary(FileRead(@AutoItExe))
Dim $Compressed = _FastLZ_Compress($Original, 2)
Dim $Decompressed = _FastLZ_Decompress($Compressed)
Dim $Result = 'Original Size: ' & BinaryLen($Original) & @CRLF
$Result &= 'Compressed Size: ' & BinaryLen($Compressed) & @CRLF
$Result &= 'Decompress Succeed: ' & ($Decompressed = $Original)
MsgBox(0, 'FastLZ Level 2 Test', $Result)
