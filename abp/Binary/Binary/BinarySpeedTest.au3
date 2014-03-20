; =============================================================================
;  AutoIt Binary UDF Speed Test Example (2011.7.21)
;  Purpose: Test The Speed Of BinaryUDF
;  Author: Ward
; =============================================================================

#Include "Binary.au3"

SpeedTest(10)

Func SpeedTest($N)
	Local $Binary[$N]
	Local $Result1[$N]
	Local $Result2[$N]

	For $i = 0 To $N - 1
		$Binary[$i] = _BinaryRandom(40960, 0, 10)
	Next

	Local $ReplaceCount = 0
	Local $Timer = TimerInit()
	For $i = 0 To $N - 1
		$Result1[$i] = _BinaryReplace($Binary[$i], "0x00", "0xFFFF")
		$ReplaceCount += @Extended
	Next
	ConsoleWrite("BinaryReplace by Binary UDF: Spent " & Round(TimerDiff($Timer), 2) & " ms To Perform " & $ReplaceCount & " Times Replacements" & @CRLF)


	$ReplaceCount = 0
	$Timer = TimerInit()
	For $i = 0 To $N - 1
		$Result2[$i] = _BinaryReplace_Script($Binary[$i], "0x00", "0xFFFF")
		$ReplaceCount += @Extended
	Next
	ConsoleWrite("BinaryReplace by Pure Script: Spent " & Round(TimerDiff($Timer), 2) & " ms To Perform " & $ReplaceCount & " Times Replacements" & @CRLF)

	For $i = 0 To $N - 1
		If $Result1[$i] <> $Result2[$i] Then
			ConsoleWrite("Compare Result: Somethine Wrong, Results Are Different !" & @CRLF)
			Return
		EndIf
	Next

	ConsoleWrite("Compare Result: All Results Are Identical !" & @CRLF)
EndFunc

Func _BinaryReplace_Script($Binary, $Search, $Replace, $Occur = 0)
	$Binary = Binary($Binary)
	$Search = Binary($Search)
	$Replace = Binary($Replace)

	Local $SearchLen = BinaryLen($Search)
	Local $ReplaceLen = BinaryLen($Replace)

	Local $Direction = 1
	If $Occur < 0 Then
		$Direction = -1
		$Occur = - $Occur
	EndIf

	Local $Count = 0
	Local $Pos = 1
	Do
		$Pos = _BinaryInBin($Binary, $Search, $Direction, $Pos)
		If $Pos = 0 Then ExitLoop

		$Binary = BinaryMid($Binary, 1, $Pos - 1) & $Replace & BinaryMid($Binary, $Pos + $SearchLen)
		$Count += 1

		If $Direction = -1 Then
			$Pos = BinaryLen($Binary) - $Pos + 2
		Else
			$Pos += $ReplaceLen
		EndIf
	Until $Count = $Occur

	Return SetExtended($Count, $Binary)
EndFunc

