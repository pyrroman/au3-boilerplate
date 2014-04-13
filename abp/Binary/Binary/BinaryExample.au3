; =============================================================================
;  AutoIt Binary UDF Example (2011.7.21)
;  Purpose: Demonstrate The Functions In Binary UDF
;  Author: Ward
; =============================================================================

#Include "../Binary.au3"

Func Example1()
	Local $Binary1 = _BinaryRandom(16)
	Local $Binary2 = _BinaryRandom(2)
	Local $p = Random(1, 100, 1)
	Local $n = -$p
	Local $Ret

	$Ret = _BinaryNOT($Binary1)
	ConsoleWrite($Binary1 & " BinaryNOT = " & $Ret & @CRLF)

	$Ret = _BinaryReverse($Binary1)
	ConsoleWrite($Binary1 & " BinaryReverse = " & $Ret & @CRLF)

	$Ret = _BinaryOR($Binary1, $Binary2)
	ConsoleWrite($Binary1 & " BinaryOR " & $Binary2 & " = " & $Ret & @CRLF)

	$Ret = _BinaryAND($Binary1, $Binary2)
	ConsoleWrite($Binary1 & " BinaryAND " & $Binary2 & " = " & $Ret & @CRLF)

	$Ret = _BinaryXOR($Binary1, $Binary2)
	ConsoleWrite($Binary1 & " BinaryXOR " & $Binary2 & " = " & $Ret & @CRLF)

	$Ret = _BinaryShift($Binary1, $p)
	ConsoleWrite($Binary1 & " BinaryShift " & $p & " = " & $Ret & @CRLF)

	$Ret = _BinaryShift($Binary1, $n)
	ConsoleWrite($Binary1 & " BinaryShift " & $n & " = " & $Ret & @CRLF)

	$Ret = _BinaryRotate($Binary1, $p)
	ConsoleWrite($Binary1 & " BinaryRotate " & $p & " = " & $Ret & @CRLF)

	$Ret = _BinaryRotate($Binary1, $n)
	ConsoleWrite($Binary1 & " BinaryRotate " & $n & " = " & $Ret & @CRLF)

EndFunc

Func Example2()
	Local $Size = 16
	Local $Binary = _BinaryRandom($Size)
	Local $Ret

	ConsoleWrite($Binary & " BinaryPeek by byte = ")
	For $i = 1 To $Size
		$Ret = _BinaryPeek($Binary, $i, "byte")
		ConsoleWrite(Hex($Ret, 2) & " ")
	Next
	ConsoleWrite(@CRLF)

	ConsoleWrite($Binary & " BinaryPeek by word = ")
	For $i = 1 To $Size Step 2
		$Ret = _BinaryPeek($Binary, $i, "word")
		ConsoleWrite(Hex($Ret, 4) & " ")
	Next
	ConsoleWrite(@CRLF)

	ConsoleWrite($Binary & " BinaryPeek by dword = ")
	For $i = 1 To $Size Step 4
		$Ret = _BinaryPeek($Binary, $i, "dword")
		ConsoleWrite(Hex($Ret, 8) & " ")
	Next
	ConsoleWrite(@CRLF)

	ConsoleWrite($Binary & " BinaryPeek by qword = ")
	For $i = 1 To $Size Step 8
		$Ret = _BinaryPeek($Binary, $i, "int64")
		ConsoleWrite(_Hex64($Ret, 16) & " ")
	Next
	ConsoleWrite(@CRLF)

	For $i = 1 To $Size
		$Binary = _BinaryPoke($Binary, $i, $i - 1, "byte")
	Next
	ConsoleWrite("BinaryPoke by byte = " & $Binary & @CRLF)

	For $i = 1 To $Size Step 2
		$Binary = _BinaryPoke($Binary, $i, $i - 1, "word")
	Next
	ConsoleWrite("BinaryPoke by word = " & $Binary & @CRLF)

	For $i = 1 To $Size Step 4
		$Binary = _BinaryPoke($Binary, $i, $i - 1, "dword")
	Next
	ConsoleWrite("BinaryPoke by dword = " & $Binary & @CRLF)

	For $i = 1 To $Size Step 8
		$Binary = _BinaryPoke($Binary, $i, $i - 1, "int64")
	Next
	ConsoleWrite("BinaryPoke by qword = " & $Binary & @CRLF)

	$Binary = _BinaryPoke($Binary, 1, "ABC", "str")
	ConsoleWrite("BinaryPoke by str = " & $Binary & @CRLF)
	ConsoleWrite("BinaryPeek by str = " & _BinaryPeek($Binary, 1, "str") & @CRLF)

	$Binary = _BinaryPoke($Binary, 1, "ABC", "wstr")
	ConsoleWrite("BinaryPoke by wstr = " & $Binary & @CRLF)
	ConsoleWrite("BinaryPeek by wstr = " & _BinaryPeek($Binary, 1, "wstr") & @CRLF)
EndFunc

Func Example3()
	Local $Binary = "0x0102030401020304010203040102030401020304"
	Local $Search = _BinaryRandom(1, 1, 4)
	Local $Ret

	$Ret = _BinaryInBin($Binary, $Search, 1)
	ConsoleWrite("BinaryInBin 1st " & $Search & " (from left side 1) in " & $Binary & " = " & $Ret & @CRLF)

	$Ret = _BinaryInBin($Binary, $Search, 2)
	ConsoleWrite("BinaryInBin 2nd " & $Search & " (from left side 1) in " & $Binary & " = " & $Ret & @CRLF)

	$Ret = _BinaryInBin($Binary, $Search, -1)
	ConsoleWrite("BinaryInBin 1st " & $Search & " (from right side 1) in " & $Binary & " = " & $Ret & @CRLF)

	$Ret = _BinaryInBin($Binary, $Search, -2)
	ConsoleWrite("BinaryInBin 2nd " & $Search & " (from right side 1) in " & $Binary & " = " & $Ret & @CRLF)

	$Ret = _BinaryInBin($Binary, $Search, 1, 10)
	ConsoleWrite("BinaryInBin 1st " & $Search & " (from left side 10) in " & $Binary & " = " & $Ret & @CRLF)

	$Ret = _BinaryInBin($Binary, $Search, 2, 10)
	ConsoleWrite("BinaryInBin 2nd " & $Search & " (from left side 10) in " & $Binary & " = " & $Ret & @CRLF)

	$Ret = _BinaryInBin($Binary, $Search, -1, 10)
	ConsoleWrite("BinaryInBin 1st " & $Search & " (from right side 10) in " & $Binary & " = " & $Ret & @CRLF)

	$Ret = _BinaryInBin($Binary, $Search, -2, 10)
	ConsoleWrite("BinaryInBin 2nd " & $Search & " (from right side 10) in " & $Binary & " = " & $Ret & @CRLF)

EndFunc

Func Example4()
	Local $Ret
	Do
		Local $Binary = _BinaryRandom(4, 0, 1)
		_BinaryReplace($Binary, "0x00", "0x00")
	Until @Extended >= 3

	$Ret = _BinaryReplace($Binary, "0x00", "0xFFFF", 1)
	ConsoleWrite("BinaryReplace FIRST 0x00 by 0xFFFF in " & $Binary & " = " & $Ret & @CRLF)

	$Ret = _BinaryReplace($Binary, "0x00", "0xFFFF", -1)
	ConsoleWrite("BinaryReplace LAST  0x00 by 0xFFFF in " & $Binary & " = " & $Ret & @CRLF)

	$Ret = _BinaryReplace($Binary, "0x00", "0xFFFF")
	ConsoleWrite("BinaryReplace ALL   0x00 by 0xFFFF in " & $Binary & " = " & $Ret & @CRLF)

	Do
		$Binary = _BinaryRandom(16, 0, 3)
		_BinaryReplace($Binary, "0x00", "0x00")
	Until @Extended >= 3

	Local $Array = _BinarySplit($Binary, "0x00")
	ConsoleWrite("BinarySplit " & $Binary & " by 0x00 = [")
	For $i = 1 To $Array[0]
		ConsoleWrite(String($Array[$i]))
		If $i <> $Array[0] Then ConsoleWrite(",")
	Next
	ConsoleWrite("]" & @CRLF)
EndFunc


Example1()
ConsoleWrite(@CRLF)

Example2()
ConsoleWrite(@CRLF)

Example3()
ConsoleWrite(@CRLF)

Example4()
ConsoleWrite(@CRLF)
