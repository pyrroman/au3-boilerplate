#include-once
#include<string.au3>
#include<array.au3>

#region _Execute-Fuction by Shadow992 (http://www.elitepvpers.de)
Global $error_execute = 0

Func _Execute($string_execute)

	$string_execute = $string_execute & @CRLF
	$string_execute = StringReplace($string_execute, "@error", "$error_execute", 0, 2)
	Local $temp211_execute = ""
	Local $temp2_execute = ""
	Local $temp_execute = ""
	Local $number_execute = 0
	Local $number2_execute = 0
	Local $ifs_found_execute = 0
	Local $while_founds_execute = 0
	Local $new_comands_execute = ""
	Local $var_execute = _StringExplode($string_execute, @CRLF)
	Local $i_execute = 0
	Local $found_execute, $else_found_execute, $while_found_execute, $exit_loop = 0


	Dim $var2_execute[UBound($var_execute)]
	Local $ua_execute = 0
	While $ua_execute < UBound($var_execute)
		If StringLeft($var_execute[$ua_execute], 1) = " " Then
			Do
				$var_execute[$ua_execute] = StringTrimLeft($var_execute[$ua_execute], 1)
			Until StringLeft($var_execute[$ua_execute], 1) <> " "
		EndIf

		$var2_execute[$ua_execute] = StringStripWS($var_execute[$ua_execute], 8)
		$ua_execute += 1
	WEnd
	While $i_execute < UBound($var_execute)
;~ 		MsgBox(0, "", $var2_execute[$i_execute])
		If StringInStr($var2_execute[$i_execute], ";") <> 1 Then
			If StringInStr($var2_execute[$i_execute], "exit", 2) = 1 Then
				if (StringLen($var2_execute[$i_execute]) = 4) Then
					Exit
				ElseIf StringLen($var2_execute[$i_execute]) = 8 And StringInStr($var2_execute[$i_execute], "exitloop", 2) = 1 Then
					$exit_loop = 1
				EndIf
			ElseIf StringInStr($var2_execute[$i_execute], "if", 2) = 1 Then
				$found_execute = StringRegExp($var_execute[$i_execute], "(?i)if (.*<>.*)|(.*=.*)|(.*<.*)|(.*>.*)|(.*>=.*)|(.*<=.*)|(.*==.*)then", 3)
;~ 				_ArrayDisplay($found_execute)
				If IsArray($found_execute) Then
					$number_execute = 0
					if (StringLen($found_execute[0]) > 3) Then
						$found_execute[0] = StringReplace($found_execute[0], "then", "", 0, 0)
						$temp2_execute = Execute($found_execute[0])
						$error_execute = @error
						$number_execute = 0
					Else
						For $ia_execute = 0 To UBound($found_execute)-1
							if (StringLen($found_execute[$ia_execute]) > 3) Then
								For $aa_execute = 0 To StringInStr($found_execute[$ia_execute], "if", 0)
									$found_execute[$ia_execute] = StringTrimLeft($found_execute[$ia_execute], 1)
								Next
								$found_execute[$ia_execute] = StringReplace($found_execute[$ia_execute], "then", "", 0, 0)
;~ 						Msgbox(0,"test2",$found_execute[1])
								$temp2_execute = Execute($found_execute[$ia_execute])
								$error_execute = @error
								$number_execute = $ia_execute
							EndIf
						Next
;~ 						Msgbox(0,"test1",$found_execute[1])

					EndIf

					If $temp2_execute <> "True" Then
						$ifs_found_execute = 1
						$else_found_execute = 0
						For $a_execute = $i_execute + 1 To UBound($var2_execute) - 1
							If StringInStr($var2_execute[$a_execute], "if", 2) = 1 Then $ifs_found_execute += 1
							If StringInStr($var2_execute[$a_execute], "endif", 2) = 1 Then $ifs_found_execute -= 1
							If StringInStr($var2_execute[$a_execute], "else", 2) = 1 And $ifs_found_execute = 1 Then
								$number_execute = $a_execute
								ExitLoop
							EndIf
							If $ifs_found_execute = 0 Then
								$number_execute = $a_execute
								ExitLoop
							EndIf
						Next
						$i_execute = $number_execute
					Else
						$else_found_execute = 0
						$ifs_found_execute = 1
						For $a_execute = $i_execute + 1 To UBound($var_execute) - 1
							If StringInStr($var2_execute[$a_execute], "if", 2) = 1 Then $ifs_found_execute += 1
							If StringInStr($var2_execute[$a_execute], "endif", 2) = 1 Then $ifs_found_execute -= 1
							If StringInStr($var2_execute[$a_execute], "else", 2) = 1 And $ifs_found_execute = 1 Then
								$number2_execute = $a_execute
								$else_found_execute = 1
							EndIf
							If $ifs_found_execute = 0 Then
								$number_execute = $a_execute
								ExitLoop
							EndIf
						Next
						If $else_found_execute = 1 Then
							$new_comands_execute = ""
							For $ai_execute = $i_execute + 1 To $number2_execute - 1
								$new_comands_execute &= $var_execute[$ai_execute] & @CRLF
							Next
							_Execute($new_comands_execute)
							$i_execute = $number_execute
						EndIf
					EndIf
				Else
					Execute($var_execute[$i_execute])
					$error_execute = @error
				EndIf
			ElseIf StringInStr($var2_execute[$i_execute], "while", 2) = 1 Then
				$found_execute = StringRegExp($var_execute[$i_execute], "(?i)while (.*=.*)|(.*<.*)|(.*>.*)|(.*>=.*)|(.*<=.*)|(.*<>.*)", 3)
				If IsArray($found_execute) Then
					$number_execute = 0
					$while_found_execute = 1
					For $o_execute = 0 To UBound($found_execute) - 1
						if (StringInStr($found_execute[$o_execute], "while", 2) = 1) Then
							$number2_execute = $o_execute
							ExitLoop
						EndIf
					Next
					$temp2_execute = Execute($found_execute[$number2_execute])
					$error_execute = @error
					If $temp2_execute = "True" Then
						For $a_execute = $i_execute + 1 To UBound($var_execute) - 1
							If StringInStr($var2_execute[$a_execute], "while", 2) = 1 Then $while_found_execute += 1
							If StringInStr($var2_execute[$a_execute], "wend", 2) = 1 Then $while_found_execute -= 1
							If $while_found_execute = 0 Then
								$number_execute = $a_execute
								ExitLoop
							EndIf
						Next
						$new_comands_execute = ""
						For $u_execute = $i_execute + 1 To $number_execute - 1
							$new_comands_execute &= $var_execute[$u_execute] & @CRLF
						Next
						While $temp2_execute = "True"
							_Execute($new_comands_execute)
							$temp2_execute = Execute($found_execute[$number2_execute])
							$error_execute = @error
							If $exit_loop = 1 Then
								$exit_loop = 0
								ExitLoop
							EndIf
						WEnd
						$i_execute = $number_execute
					Else
						$while_found_execute = 1
						For $a_execute = $i_execute + 1 To UBound($var_execute) - 1
							If StringInStr($var2_execute[$a_execute], "while", 2) = 1 Then $while_found_execute += 1
							If StringInStr($var2_execute[$a_execute], "wend", 2) = 1 Then $while_found_execute -= 1
							If $while_found_execute = 0 Then
								$i_execute = $a_execute
								ExitLoop
							EndIf
						Next
					EndIf
				Else
					Execute($var_execute[$i_execute])
					$error_execute = @error
				EndIf
			ElseIf StringInStr($var2_execute[$i_execute], "for", 2) = 1 Then
				$found_execute = StringRegExp($var_execute[$i_execute], "(?i)for (\x24\w*\x20*)=(\x20*\d*\x20*)to(\x20*\d*\x20*)step(\x20*\d*\x20*)", 3)
				_ArrayDisplay($found_execute)
				If IsArray($found_execute) Then
					$number_execute = 0
					$while_found_execute = 1
					$found_execute[0] = StringTrimLeft($found_execute[0], 1)
					Assign($found_execute[0], $found_execute[1], 2)
					$temp2_execute = Execute($found_execute[$number2_execute])
					$error_execute = @error

					For $a_execute = $i_execute + 1 To UBound($var_execute) - 1
						If StringInStr($var2_execute[$a_execute], "for", 2) = 1 Then $while_found_execute += 1
						If StringInStr($var2_execute[$a_execute], "next", 2) = 1 Then $while_found_execute -= 1
						If $while_found_execute = 0 Then
							$number_execute = $a_execute
							ExitLoop
						EndIf
					Next
					$new_comands_execute = ""
					For $u_execute = $i_execute + 1 To $number_execute - 1
						$new_comands_execute &= $var_execute[$u_execute] & @CRLF
					Next
					Do
						_Execute($new_comands_execute)
						$error_execute = @error
						If $exit_loop = 1 Then
							$exit_loop = 0
							ExitLoop
						EndIf


						Assign($found_execute[0], Eval($found_execute[0]) + Execute($found_execute[3]), 2)
					Until Eval($found_execute[0]) >= Execute($found_execute[2])
					$i_execute = $number_execute
				Else
					$found_execute = StringRegExp($var_execute[$i_execute], "(?i)for (\x24\w*\x20*)=(\x20*\d*\x20*)to(\x20*\d*\x20*)", 3)
					_ArrayDisplay($found_execute)
					If IsArray($found_execute) Then
						$number_execute = 0
						$while_found_execute = 1
						$found_execute[0] = StringTrimLeft($found_execute[0], 1)
						Assign($found_execute[0], $found_execute[1], 2)
						$temp2_execute = Execute($found_execute[$number2_execute])
						$error_execute = @error

						For $a_execute = $i_execute + 1 To UBound($var_execute) - 1
							If StringInStr($var2_execute[$a_execute], "for", 2) = 1 Then $while_found_execute += 1
							If StringInStr($var2_execute[$a_execute], "next", 2) = 1 Then $while_found_execute -= 1
							If $while_found_execute = 0 Then
								$number_execute = $a_execute
								ExitLoop
							EndIf
						Next
						$new_comands_execute = ""
						For $u_execute = $i_execute + 1 To $number_execute - 1
							$new_comands_execute &= $var_execute[$u_execute] & @CRLF
						Next
						Do
							_Execute($new_comands_execute)
							$error_execute = @error
							If $exit_loop = 1 Then
								$exit_loop = 0
								ExitLoop
							EndIf
							Assign($found_execute[0], Eval($found_execute[0]) + 1)
						Until Eval($found_execute[0]) >= Execute($found_execute[2])
						$i_execute = $number_execute
					EndIf
				EndIf
			Else
				If StringInStr($var2_execute[$i_execute], "$") = 1 Then
					$temp_execute = StringRegExp($var2_execute[$i_execute], "(\x24\w*)=", 3)
					If IsArray($temp_execute) Then
						$var_execute[$i_execute] = StringRegExpReplace($var_execute[$i_execute], "(\x24\w*\x20*)=", "")
						$temp211_execute = Execute($var_execute[$i_execute])
						$error_execute = @error
						Assign(StringTrimLeft($temp_execute[0], 1), $temp211_execute, 2)
					Else
						$temp_execute = StringRegExp($var2_execute[$i_execute], "(\x24\w*\x2b)=", 3)
						If IsArray($temp_execute) Then
							$var_execute[$i_execute] = StringRegExpReplace($var_execute[$i_execute], "(\x24\w*\x20*\x2b)=", "")
							$temp_execute[0] = StringTrimRight(StringTrimLeft($temp_execute[0], 1), 2)
							$temp211_execute = Execute($var_execute[$i_execute]) + Eval($temp_execute[0])
							Assign($temp_execute[0], $temp211_execute, 2)
						Else
							$temp_execute = StringRegExp($var2_execute[$i_execute], "(\x24\w*\x2d)=", 3)
							If IsArray($temp_execute) Then
								$var_execute[$i_execute] = StringRegExpReplace($var_execute[$i_execute], "(\x24\w*\x20*\x2d)=", "")
								$temp_execute[0] = StringTrimRight(StringTrimLeft($temp_execute[0], 1), 1)
								$temp211_execute = Eval($temp_execute[0]) - Execute($var_execute[$i_execute])
								Assign($temp_execute[0], $temp211_execute, 2)
							Else
								$temp_execute = StringRegExp($var2_execute[$i_execute], "(\x24\w*\x26)=", 3)
								If IsArray($temp_execute) Then
									$var_execute[$i_execute] = StringRegExpReplace($var_execute[$i_execute], "(\x24\w*\x20*\x26)=", "")
									$temp_execute[0] = StringTrimRight(StringTrimLeft($temp_execute[0], 1), 1)
									$temp211_execute = Eval($temp_execute[0]) & Execute($var_execute[$i_execute])
									Assign($temp_execute[0], $temp211_execute, 2)
								Else
									$temp_execute = StringRegExp($var2_execute[$i_execute], "(\x24\w*\x2f)=", 3)
									If IsArray($temp_execute) Then
										$var_execute[$i_execute] = StringRegExpReplace($var_execute[$i_execute], "(\x24\w*\x20*\x2f)=", "")
										$temp_execute[0] = StringTrimRight(StringTrimLeft($temp_execute[0], 1), 1)
										$temp211_execute = Eval($temp_execute[0]) / Execute($var_execute[$i_execute])
										Assign($temp_execute[0], $temp211_execute, 2)
									Else
										$temp_execute = StringRegExp($var2_execute[$i_execute], "(\x24\w*\x2a)=", 3)
										If IsArray($temp_execute) Then
											$var_execute[$i_execute] = StringRegExpReplace($var_execute[$i_execute], "(\x24\w*\x20*\x2a)=", "")
											$temp_execute[0] = StringTrimRight(StringTrimLeft($temp_execute[0], 1), 1)
											$temp211_execute = Eval($temp_execute[0]) * Execute($var_execute[$i_execute])
											Assign($temp_execute[0], $temp211_execute, 2)
										Else
											$temp_execute = StringRegExp($var2_execute[$i_execute], "(\x24\w*\x5e)=", 3)
											If IsArray($temp_execute) Then
												$var_execute[$i_execute] = StringRegExpReplace($var_execute[$i_execute], "(\x24\w*\x20*\x5e)=", "")
												$temp_execute[0] = StringTrimRight(StringTrimLeft($temp_execute[0], 1), 1)
												$temp211_execute = Eval($temp_execute[0]) ^ Execute($var_execute[$i_execute])
												Assign($temp_execute[0], $temp211_execute, 2)
											Else
												Execute($var_execute[$i_execute])
												$error_execute = @error
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					Execute($var_execute[$i_execute])
					$error_execute = @error
				EndIf
			EndIf
		EndIf
		$i_execute += 1

	WEnd
EndFunc   ;==>_Execute
#endregion _Execute-Fuction by Shadow992 (http://www.elitepvpers.de)
