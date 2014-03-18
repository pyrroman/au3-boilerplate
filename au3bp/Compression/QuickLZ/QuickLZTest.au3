; -----------------------------------------------------------------------------
; QuickLZ Compression Machine Code UDF Example
; Purpose: Provide The Machine Code Version of QuickLZ Algorithm In AutoIt
; Author: Ward
; QuickLZ Copyright (C) 2006-2009 Lasse Mikkel Reinhold
; -----------------------------------------------------------------------------

#Include "QuickLZ.au3"

Dim $Original = Binary(FileRead(@AutoItExe))
Dim $Compressed = _QuickLZ_Compress($Original, 1)
Dim $Decompressed = _QuickLZ_Decompress($Compressed)
Dim $Result = 'Original Size: ' & BinaryLen($Original) & @CRLF
$Result &= 'Compressed Size: ' & BinaryLen($Compressed) & @CRLF
$Result &= 'Decompress Succeed: ' & ($Decompressed = $Original)
MsgBox(0, 'QuickLZ Level 1 Result', $Result)

Dim $Original = Binary(FileRead(@AutoItExe))
Dim $Compressed = _QuickLZ_Compress($Original, 2)
Dim $Decompressed = _QuickLZ_Decompress($Compressed)
Dim $Result = 'Original Size: ' & BinaryLen($Original) & @CRLF
$Result &= 'Compressed Size: ' & BinaryLen($Compressed) & @CRLF
$Result &= 'Decompress Succeed: ' & ($Decompressed = $Original)
MsgBox(0, 'QuickLZ Level 2 Result', $Result)
