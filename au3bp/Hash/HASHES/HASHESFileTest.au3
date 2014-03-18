; ------------------------------------------------------------------
; Hashes Machine Code UDF Example
; Purpose: A Test For All Machine Code Hash UDF
; Author: Ward
; ------------------------------------------------------------------

#Include "HASHES.au3"
#Include "CHECKSUM.au3"
#Include "MD2.au3"
#Include "MD4.au3"
#Include "MD5.au3"
#Include "SHA1.au3"
#Include "SHA224_256.au3"
#Include "SHA384_512.au3"
#Include "SHABAL.au3"
#Include "BLAKE.au3"
#Include "BMW.au3"
#Include "SKEIN.au3"
#Include "CUBEHASH.au3"
#Include "ECHO.au3"

Dim $HashString = 'CRC16,CRC32,ADLER32,'
	$HashString &= 'MD2,MD4,MD5,SHA1,SHA224,SHA256,SHA384,SHA512,'
	$HashString &= 'SHABAL192,SHABAL224,SHABAL256,SHABAL384,SHABAL512,'
	$HashString &= 'BLAKE224,BLAKE256,BLAKE384,BLAKE512,'
	$HashString &= 'BMW224,BMW256,BMW384,BMW512,'
	$HashString &= 'SKEIN224,SKEIN256,SKEIN384,SKEIN512,'
	$HashString &= 'CUBEHASH224,CUBEHASH256,CUBEHASH384,CUBEHASH512,'
	$HashString &= 'ECHO224,ECHO256,ECHO384,ECHO512'

Dim $HashList = StringSplit($HashString, ',')

Dim $BufferSize = 0x100000
Dim $Filename = FileOpenDialog("Open File", "", "Any File (*.*)")
If $Filename = "" Then Exit

For $j = 1 To $HashList[0]
	Dim $HashName = $HashList[$j]
	Dim $Timer = TimerInit()
	Dim $State = _HashInit(Eval('_HASH_' & $HashName))

	Dim $FileHandle = FileOpen($Filename, 16)
	For $i = 1 To Ceiling(FileGetSize($Filename) / $BufferSize)
		_HashInput($State, FileRead($FileHandle, $BufferSize))
	Next
	Dim $Hash = _HashResult($State)
	FileClose($FileHandle)

	ConsoleWrite(StringFormat('%-12s %5i ms %s', $HashName, Round(TimerDiff($Timer)), $Hash) & @CRLF)
Next
