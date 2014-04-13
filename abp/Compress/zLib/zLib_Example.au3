; -----------------------------------------------------------------------------
; Zlib Compression Library (Deflate/Inflate) Machine Code UDF Example
; Purpose: Provide The Machine Code Version of Zlib Library In AutoIt
; Author: Ward
; Zlib Copyright (C) 1995-2010 Jean-loup Gailly and Mark Adler
; -----------------------------------------------------------------------------

#Include "ZLIB.au3"

; Test _ZLIB_Compress And _ZLIB_Uncompress
Dim $Original = BinaryFileRead(@AutoItExe)
Dim $Compressed = _ZLIB_Compress($Original, 9)
Dim $Decompressed = _ZLIB_Uncompress($Compressed)
Dim $Result = 'Original Size: ' & BinaryLen($Original) & @CRLF
$Result &= 'Compressed Size: ' & BinaryLen($Compressed) & @CRLF
$Result &= 'Decompress Succeed: ' & ($Decompressed = $Original)
MsgBox(0,'Deflate/Inflate Test', $Result)


; Test _ZLIB_GZCompress And _ZLIB_GZUncompress
Dim $Original = BinaryFileRead(@AutoItExe)
Dim $Compressed = _ZLIB_GZCompress($Original, 9)
Dim $Decompressed = _ZLIB_GZUncompress($Compressed)
Dim $Result = 'Original Size: ' & BinaryLen($Original) & @CRLF
$Result &= 'Compressed Size: ' & BinaryLen($Compressed) & @CRLF
$Result &= 'Decompress Succeed: ' & ($Decompressed = $Original)
MsgBox(0,'Gzip Test', $Result)


; Test _ZLIB_FileCompress And _ZLIB_FileUncompress
Dim $OriginalPath = @AutoItExe
Dim $CompressedPath = @TempDir & "\test.z"
Dim $DecompressedPath = @TempDir & "\test.unz"
_ZLIB_FileCompress($OriginalPath, $CompressedPath, 9)
_ZLIB_FileUncompress($CompressedPath, $DecompressedPath)
Dim $Result = 'Original Size: ' & FileGetSize($OriginalPath) & @CRLF
$Result &= 'Compressed Size: ' & FileGetSize($CompressedPath) & @CRLF
$Result &= 'Decompress Succeed: ' & (BinaryFileRead($DecompressedPath) = BinaryFileRead($OriginalPath))
FileDelete($CompressedPath)
FileDelete($DecompressedPath)
MsgBox(0,'Deflate/Inflate File Test', $Result)


; Test _ZLIB_GZFileCompress And _ZLIB_GZFileUncompress
Dim $OriginalPath = @AutoItExe
Dim $CompressedPath = @TempDir & "\test.gz"
Dim $DecompressedPath = @TempDir & "\test.ungz"
_ZLIB_GZFileCompress($OriginalPath, $CompressedPath)
_ZLIB_GZFileUncompress($CompressedPath, $DecompressedPath)
Dim $Result = 'Original Size: ' & FileGetSize($OriginalPath) & @CRLF
$Result &= 'Compressed Size: ' & FileGetSize($CompressedPath) & @CRLF
$Result &= 'Decompress Succeed: ' & (BinaryFileRead($DecompressedPath) = BinaryFileRead($OriginalPath))
FileDelete($CompressedPath)
FileDelete($DecompressedPath)
MsgBox(0,'Gzip File Test', $Result)

Exit

Func BinaryFileRead($Path)
	Local $File = FileOpen($Path, 16)
	Local $Data = FileRead($File)
	FileClose($File)
	Return $Data
EndFunc
