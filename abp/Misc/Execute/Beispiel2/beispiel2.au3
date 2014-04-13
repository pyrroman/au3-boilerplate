
	$var=""
	While $var = ""
		$var = InputBox("Box", "Bitte etwas eingeben", "", "", 200, 180)
		If $var = ""  Then
			$var1=InputBox("Abgeborchen", "Sie haben die Aktion abgebrochen. Wollen sie den Vorgang wirklich abbrechen? Ja=1", "", "", 200, 180)
			if $var1="1" Then
				Exit
			EndIf
		Else
			MsgBox(0, "Succes", "Succes", 10)
		EndIf
	WEnd