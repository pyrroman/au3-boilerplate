$zahl = Random(1, 20,1)
MsgBox(0, "Rate die Zahl", "Rate die Zahl ")
$rate=1
While $rate = 1
	$input = InputBox("Zahl", "Zahl zwischen 1 und 20")
	If $zahl = $input Then
		MsgBox(0, "Die Zahl war richtig", "Die Zahl war richtig")
		$rate = 0
	Else
		If $zahl < $input Then
			MsgBox(0, "Die Zahl war zu groß", "Die Zahl war zu groß")
		Else
			If $zahl > $input Then
				MsgBox(0, "Die Zahl war zu klein", "Die Zahl war zu klein")
			EndIf
		EndIf
	EndIf
WEnd