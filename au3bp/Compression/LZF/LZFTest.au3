; -----------------------------------------------------------------------------
; LZF Compression Machine Code UDF Example
; Purpose: Provide The Machine Code Version of LZF Algorithm In AutoIt
; Author: Ward
; LZF Copyright (C) 2000-2007 Marc Alexander Lehmann <schmorp@schmorp.de>
; -----------------------------------------------------------------------------

#Include "LZF.au3"

Dim $Original = Binary(FileRead(@AutoItExe))
Dim $Compressed = _LZF_Compress($Original)
Dim $Decompressed = _LZF_Decompress($Compressed)
Dim $Result = 'Original Size: ' & BinaryLen($Original) & @CRLF
$Result &= 'Compressed Size: ' & BinaryLen($Compressed) & @CRLF
$Result &= 'Decompress Succeed: ' & ($Decompressed = $Original)
MsgBox(0, 'LZF Test', $Result)
