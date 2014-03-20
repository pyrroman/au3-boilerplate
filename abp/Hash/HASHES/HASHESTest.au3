; ------------------------------------------------------------------
; Hashes Machine Code UDF Example
; Purpose: A Test For All Machine Code Hash UDF
; Author: Ward
; ------------------------------------------------------------------

#Include "../HASHES.au3"
#Include "../CHECKSUM.au3"
#Include "../MD2.au3"
#Include "../MD4.au3"
#Include "../MD5.au3"
#Include "../SHA1.au3"
#Include "../SHA224_256.au3"
#Include "../SHA384_512.au3"
#Include "../SHABAL.au3"
#Include "../BLAKE.au3"
#Include "../BMW.au3"
#Include "../SKEIN.au3"
#Include "../CUBEHASH.au3"
#Include "../ECHO.au3"

Dim $HashString = 'CRC16,CRC32,ADLER32,'
	$HashString &= 'MD2,MD4,MD5,SHA1,SHA224,SHA256,SHA384,SHA512,'
	$HashString &= 'SHABAL192,SHABAL224,SHABAL256,SHABAL384,SHABAL512,'
	$HashString &= 'BLAKE224,BLAKE256,BLAKE384,BLAKE512,'
	$HashString &= 'BMW224,BMW256,BMW384,BMW512,'
	$HashString &= 'SKEIN224,SKEIN256,SKEIN384,SKEIN512,'
	$HashString &= 'CUBEHASH224,CUBEHASH256,CUBEHASH384,CUBEHASH512,'
	$HashString &= 'ECHO224,ECHO256,ECHO384,ECHO512'

Dim $HashList = StringSplit($HashString, ',')

Dim $ResultList1[$HashList[0] + 1]
Dim $ResultList2[$HashList[0] + 1]
Dim $ResultList3[$HashList[0] + 1]
Dim $ResultList4[$HashList[0] + 1]

Method1($HashList, $ResultList1)
Method2($HashList, $ResultList2)
Method3($HashList, $ResultList3)
Method4($HashList, $ResultList4)

For $i = 1 To $HashList[0]
	If $ResultList1[$i] <> $ResultList2[$i] Or $ResultList1[$i] <> $ResultList3[$i] Or $ResultList1[$i] <> $ResultList4[$i]Then
		MsgBox(0, 'Hashes Test', 'Hash ' & $HashList[$i] & ' Test Fail')
		Exit
	EndIf
Next
MsgBox(0, 'Hashes Test', 'Total ' &$HashList[0] & ' Type of Hashes, Results For 4 Methods Are All Identical')


Func Method1(ByRef $HashList, ByRef $ResultList)
	; _MD5('The quick brown fox jumps over the lazy dog')

	For $i = 1 To $HashList[0]
		Local $HashName = $HashList[$i]
		Local $Hash = Call('_' & $HashName, 'The quick brown fox jumps over the lazy dog')
		$ResultList[$i] = $Hash
		ConsoleWrite(StringFormat('Method1 %-12s %s', $HashName, $Hash) & @CRLF)
	Next
EndFunc

Func Method2(ByRef $HashList, ByRef $ResultList)
	; _Hash($_HASH_MD5, 'The quick brown fox jumps over the lazy dog')

	For $i = 1 To $HashList[0]
		Local $HashName = $HashList[$i]
		Local $Hash = _Hash(Eval('_HASH_' & $HashName), 'The quick brown fox jumps over the lazy dog')
		$ResultList[$i] = $Hash
		ConsoleWrite(StringFormat('Method2 %-12s %s', $HashName, $Hash) & @CRLF)
	Next
EndFunc

Func Method3(ByRef $HashList, ByRef $ResultList)
	; $State = _MD5Init()
	; _MD5Input($State, 'The quick brown fox jumps over the lazy dog')
	; _MD5Result($State)

	For $i = 1 To $HashList[0]
		Local $HashName = $HashList[$i]
		Local $State = Call('_' & $HashName & 'Init')
		Call('_' & $HashName & 'Input', $State, 'The ')
		Call('_' & $HashName & 'Input', $State, 'quick ')
		Call('_' & $HashName & 'Input', $State, 'brown ')
		Call('_' & $HashName & 'Input', $State, 'fox ')
		Call('_' & $HashName & 'Input', $State, 'jumps ')
		Call('_' & $HashName & 'Input', $State, 'over ')
		Call('_' & $HashName & 'Input', $State, 'the ')
		Call('_' & $HashName & 'Input', $State, 'lazy ')
		Call('_' & $HashName & 'Input', $State, 'dog')
		Local $Hash = Call('_' & $HashName & 'Result', $State)
		$ResultList[$i] = $Hash
		ConsoleWrite(StringFormat('Method3 %-12s %s', $HashName, $Hash) & @CRLF)
	Next
EndFunc

Func Method4(ByRef $HashList, ByRef $ResultList)
	; $State = _HashInit($_HASH_MD5)
	; _HashInput($State, 'The quick brown fox jumps over the lazy dog')
	; _HashResult($State)

	For $i = 1 To $HashList[0]
		Local $HashName = $HashList[$i]
		Local $State = Call('_' & $HashName & 'Init')
		Local $State = _HashInit(Eval('_HASH_' & $HashName))
		_HashInput($State, 'The ')
		_HashInput($State, 'quick ')
		_HashInput($State, 'brown ')
		_HashInput($State, 'fox ')
		_HashInput($State, 'jumps ')
		_HashInput($State, 'over ')
		_HashInput($State, 'the ')
		_HashInput($State, 'lazy ')
		_HashInput($State, 'dog')
		Local $Hash = _HashResult($State)
		$ResultList[$i] = $Hash
		ConsoleWrite(StringFormat('Method4 %-12s %s', $HashName, $Hash) & @CRLF)
	Next
EndFunc
