; -----------------------------------------------------------------------------
; LZMAT Compression Machine Code UDF Example
; Purpose: Provide The Machine Code Version of LZMAT Algorithm In AutoIt
; Author: Ward
; LZMAT Copyright (C) 2007-2008 Vitaly Evseenko
; -----------------------------------------------------------------------------

#Include "LZMAT.au3"

Dim $Original = Binary(FileRead(@AutoItExe))
Dim $Compressed = _LZMAT_Compress($Original)
Dim $Decompressed = _LZMAT_Decompress($Compressed)
Dim $Result = 'Original Size: ' & BinaryLen($Original) & @CRLF
$Result &= 'Compressed Size: ' & BinaryLen($Compressed) & @CRLF
$Result &= 'Decompress Succeed: ' & ($Decompressed = $Original)
MsgBox(0, 'LZMAT Test', $Result)
