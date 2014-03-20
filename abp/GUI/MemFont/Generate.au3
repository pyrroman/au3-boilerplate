$sFile = FileOpenDialog('Select Fontfile', @ScriptDir, '(*.*)', 1)
If @error Or Not $sFile Then Exit
$hFile = FileOpen($sFile, 16)
$bFile = FileRead($hFile)
FileClose($hFile)
$sName = InputBox('name of variable', 'name of font variable:', '$bFont')
If @error Or Not $sName Then Exit
$bConst = False
If MsgBox(4, 'AutoIt Version 3.3.4.0', 'generate font for AutoIt v 3.3.4.0 or later?' & @LF & 'select <No> if you are using an older distribution') = 6 Then $bConst = True
Switch $bConst
	Case True
		$sConst = 'Global Const ' & $sName & ' = '
		$aRegExp = StringRegExp($bFile, '^.{' & 4085 - StringLen($sConst) & '}|.{4077}|.*$', 3)
		If @error Or Not IsArray($aRegExp) Then Exit
		If Not $aRegExp[UBound($aRegExp) - 1] Then ReDim $aRegExp[UBound($aRegExp) - 1]
		For $i = 0 To UBound($aRegExp) - 1
			Switch $i
				Case UBound($aRegExp) - 1
					$sConst &= '"' & $aRegExp[$i] & '"'
				Case Else
					$sConst &= '"' & $aRegExp[$i] & '" & _' & @CRLF & '        '
			EndSwitch
		Next
	Case Else
		$sConst = 'Global ' & $sName & ' = '
		$aRegExp = StringRegExp($bFile, '^.{' & 4085 - StringLen($sConst) & '}|.{' & 4085 - StringLen($sName) - 4 & '}|.*$', 3)
		If @error Or Not IsArray($aRegExp) Then Exit
		If Not $aRegExp[UBound($aRegExp) - 1] Then ReDim $aRegExp[UBound($aRegExp) - 1]
		For $i = 0 To UBound($aRegExp) - 1
			Switch $i
				Case UBound($aRegExp) - 1
					$sConst &= '"' & $aRegExp[$i] & '"'
				Case Else
					$sConst &= '"' & $aRegExp[$i] & '"' & @CRLF & $sName & ' &= '
			EndSwitch
		Next
EndSwitch
ClipPut($sConst)
MsgBox(0, 'Done', 'generated constant is in clipboard, you can paste it into your script.')