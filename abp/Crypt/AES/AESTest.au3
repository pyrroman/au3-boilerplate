#Include "../aes.au3"

_AesInit()

AesBinaryTest("TestKey", "blueberry ")

$Key = Binary("cPSQAC05GBXzMhRRz7tm8cqg+vHdHyN5")
$IV = Binary("jIShBJVBfXo=")
$Data = Binary("blueberry")
AesECBTest($Key, $Data)
AesCBCTest($Key, $IV, $Data)
AesCFBTest($Key, $IV, $Data)
AesOFBTest($Key, $IV, $Data)

AesFileTest("TestKey")

#cs
;****************************************************************************
;	Before running these tests, please download test vectors from
;	http://csrc.nist.gov/archive/aes/rijndael/rijndael-vals.zip
;
;	Warning: Monte Carlo Test will take very long time to pass a file.
;****************************************************************************

AesKnownAnswerTest("ecb_tbl.txt")
AesKnownAnswerTest("ecb_vk.txt")
AesKnownAnswerTest("ecb_vt.txt")

AesMonteCarloTest_EncryptCBC("cbc_e_m.txt")
AesMonteCarloTest_DecryptCBC("cbc_d_m.txt")
AesMonteCarloTest_EncryptECB("ecb_e_m.txt")
AesMonteCarloTest_DecryptECB("ecb_d_m.txt")
#ce

_AesExit()

Func AesBinaryTest($Key, $Data, $Mode = "CBC", $IV = Default)
	Local $Ret = _AesEncrypt($Key, $Data, $Mode, $IV)
	MsgBox(0, 'Encrypted Binary', $Ret)
	$Ret = _AesDecrypt($Key, $Ret, $Mode)
	MsgBox(0, 'Decrypted Binary', $Ret)
	MsgBox(0, 'Decrypted String', BinaryToString($Ret))
EndFunc

Func AesECBTest($Key, $Data)
	Local $Ctx = _AesEncryptKey($Key)
	Local $Ret = _AesEncryptECB($Ctx, $Data)

	$Ctx = _AesDecryptKey($Key)
	$Ret = _AesDecryptECB($Ctx, $Ret)
	MsgBox(0, 'Encrypt/Decrypt in ECB Mode', $Ret)
EndFunc

Func AesCBCTest($Key, $IV, $Data)
	Local $IVBak = $IV
	Local $Ctx = _AesEncryptKey($Key)
	Local $Ret = _AesEncryptCBC($Ctx, $IV, $Data)

	$Ctx = _AesDecryptKey($Key)
	If BinaryLen($Data) < 16 Then
		$Ret = _AesDecryptCBC($Ctx, $IV, $Ret)
	Else
		$Ret = _AesDecryptCBC($Ctx, $IVBak, $Ret)
	EndIf
	MsgBox(0, 'Encrypt/Decrypt in CBC Mode', $Ret)
EndFunc

Func AesCFBTest($Key, $IV, $Data)
	Local $IVBak = $IV
	Local $Ctx = _AesEncryptKey($Key)
	Local $Ret = _AesEncryptCFB($Ctx, $IV, $Data)

	$Ctx = _AesEncryptKey($Key)
	$Ret = _AesDecryptCFB($Ctx, $IVBak, $Ret)
	MsgBox(0, 'Encrypt/Decrypt in CFB Mode', $Ret)
EndFunc

Func AesOFBTest($Key, $IV, $Data)
	Local $IVBak = $IV
	Local $Ctx = _AesEncryptKey($Key)
	Local $Ret = _AesCryptOFB($Ctx, $IV, $Data)

	$Ctx = _AesEncryptKey($Key)
	$Ret = _AesCryptOFB($Ctx, $IVBak, $Ret)
	MsgBox(0, 'Encrypt/Decrypt in OFB Mode', $Ret)
EndFunc

Func AesFileTest($Key, $Mode = "CBC")
	Local $Filename = FileOpenDialog("Select file to encrypt", "", "Any file (*.*)")
	If $Filename = "" Then Return

	Local $Timer = TimerInit()
	_AesEncryptFile($Key, $Filename, $Filename & ".enc", $Mode)
	_AesDecryptFile($Key, $Filename & ".enc", $Filename & ".dec", $Mode)
	Local $Cost = TimerDiff($Timer)

	Local $Ret = RunWait('cmd /c "fc /b "' & $Filename & '" "' & $Filename & '.dec" && pause"')
	FileDelete($Filename & ".enc")
	FileDelete($Filename & ".dec")

	If $Ret = 0 Then
		MsgBox(0, 'Encrypt/Decrypt succeed', 'Time cost: ' & $Cost & " ms")
	Else
		MsgBox(0, 'Encrypt/Decrypt fail', 'Time cost: ' & $Cost & " ms")
	EndIf
EndFunc

Func AesKnownAnswerTest($TableFile)
	$Table = FileRead($TableFile)
	$Match = StringRegExp($Table, "KEY=[0-9A-Fa-f]*|PT=[0-9A-Fa-f]*|CT=[0-9A-Fa-f]*|I=[0-9A-Fa-f]*", 3)

	Local $KEY, $CT, $PT, $I, $Counter = 0
	For $Index = 0 To UBound($Match) - 1
		$Pair = StringSplit($Match[$Index], "=")
		If $Pair[0] <> 2 Then ContinueLoop
		Assign($Pair[1], $Pair[2], 1)

		If $Pair[1] = "CT" Then
			If Not IsBinary($Key) Then $Key = Binary('0x' & $Key)
			If Not IsBinary($PT) Then $PT = Binary('0x' & $PT)
			If Not IsBinary($CT) Then $CT = Binary('0x' & $CT)

			$Str = 'KEYSIZE=' & (BinaryLen($Key) * 8) & ', I=' & $I
			ToolTip($Str, 0, 0)
			$Ctx = _AesEncryptKey($Key)
			$Ret = _AesEncryptECB($Ctx, $PT)
			If $CT <> $Ret Then
				MsgBox(16, 'Warning', '"Known Answer Test" failed on ' & $Str)
				Return
			Else
				$Counter += 1
			EndIf
		EndIf
	Next
	ToolTip('')
	MsgBox(32, "Known Answer Test Succeed", $Counter & ' test vectors in "' & $TableFile & '" passed')
EndFunc

Func AesMonteCarloTest_EncryptECB($TableFile)
	Local $Table = FileRead($TableFile)
	Local $Match = StringRegExp($Table, "KEY=[0-9A-Fa-f]*|PT=[0-9A-Fa-f]*|CT=[0-9A-Fa-f]*|I=[0-9A-Fa-f]*", 3)
	Local $KEY, $CT, $PT, $I, $J, $Index, $Counter = 0

	For $Index = 0 To UBound($Match) - 1
		Local $Pair = StringSplit($Match[$Index], "=")
		If $Pair[0] <> 2 Then ContinueLoop
		Assign($Pair[1], $Pair[2], 1)

		If $Pair[1] = "CT" Then
			If Not IsBinary($Key) Then $Key = Binary('0x' & $Key)
			If Not IsBinary($PT) Then $PT = Binary('0x' & $PT)
			If Not IsBinary($CT) Then $CT = Binary('0x' & $CT)

			Local $Ctx = _AesEncryptKey($Key)
			For $J = 1 To 10000
				$PT = _AesEncryptECB($Ctx, $PT)

				If Mod($J, 200) = 0 Then
					Local $Str = 'KEYSIZE=' & (BinaryLen($Key) * 8) & ', I=' & $I & ', J=' & $J & ' , CT=' & $PT
					ToolTip($Str, 0, 0)
				EndIf
			Next

			If $PT <> $CT Then
				ToolTip('')
				MsgBox(16, 'Warning', '"ECB Encrypt Monte Carlo Test" failed on ' & $Str)
				Return
			Else
				$Counter += 1
			EndIf
		EndIf
	Next
	ToolTip('')
	MsgBox(32, 'ECB Encrypt Monte Carlo Test Succeed', $Counter & ' test vectors passed in "' & $TableFile & '"')
EndFunc

Func AesMonteCarloTest_DecryptECB($TableFile)
	Local $Table = FileRead($TableFile)
	Local $Match = StringRegExp($Table, "KEY=[0-9A-Fa-f]*|PT=[0-9A-Fa-f]*|CT=[0-9A-Fa-f]*|I=[0-9A-Fa-f]*", 3)
	Local $KEY, $CT, $PT, $I, $J, $Index, $Counter = 0

	For $Index = 0 To UBound($Match) - 1
		Local $Pair = StringSplit($Match[$Index], "=")
		If $Pair[0] <> 2 Then ContinueLoop
		Assign($Pair[1], $Pair[2], 1)

		If $Pair[1] = "PT" Then
			If Not IsBinary($Key) Then $Key = Binary('0x' & $Key)
			If Not IsBinary($PT) Then $PT = Binary('0x' & $PT)
			If Not IsBinary($CT) Then $CT = Binary('0x' & $CT)

			Local $Ctx = _AesDecryptKey($Key)
			For $J = 1 To 10000
				$CT = _AesDecryptECB($Ctx, $CT)

				If Mod($J, 200) = 0 Then
					Local $Str = 'KEYSIZE=' & (BinaryLen($Key) * 8) & ', I=' & $I & ', J=' & $J & ' , PT=' & $CT
					ToolTip($Str, 0, 0)
				EndIf
			Next

			If $PT <> $CT Then
				ToolTip('')
				MsgBox(16, 'Warning', '"ECB Decrypt Monte Carlo Test" failed on ' & $Str)
				Return
			Else
				$Counter += 1
			EndIf
		EndIf
	Next
	ToolTip('')
	MsgBox(32, 'ECB Decrypt Monte Carlo Test Succeed', $Counter & ' test vectors passed in "' & $TableFile & '"')
EndFunc

Func AesMonteCarloTest_EncryptCBC($TableFile)
	Local $Table = FileRead($TableFile)
	Local $Match = StringRegExp($Table, "KEY=[0-9A-Fa-f]*|PT=[0-9A-Fa-f]*|CT=[0-9A-Fa-f]*|I=[0-9A-Fa-f]*|IV=[0-9A-Fa-f]*", 3)
	Local $KEY, $CT, $PT, $IV, $I, $J, $Index, $Counter = 0

	For $Index = 0 To UBound($Match) - 1
		Local $Pair = StringSplit($Match[$Index], "=")
		If $Pair[0] <> 2 Then ContinueLoop
		Assign($Pair[1], $Pair[2], 1)

		If $Pair[1] = "CT" Then
			If Not IsBinary($Key) Then $Key = Binary('0x' & $Key)
			If Not IsBinary($PT) Then $PT = Binary('0x' & $PT)
			If Not IsBinary($CT) Then $CT = Binary('0x' & $CT)
			If Not IsBinary($IV) Then $IV = Binary('0x' & $IV)

			Local $Ctx = _AesEncryptKey($Key)
			For $J = 1 To 10000
				If $J = 1 Then
					Local $IVBak = $IV
					Local $CTn = _AesEncryptCBC($Ctx, $IV, $PT)
					$PT = $IVBak
				Else
					Local $Ret = _AesEncryptCBC($Ctx, $IV, $PT)
					$PT = $CTn
					$CTn = $Ret
				EndIf

				If Mod($J, 200) = 0 Then
					Local $Str = 'KEYSIZE=' & (BinaryLen($Key) * 8) & ', I=' & $I & ', J=' & $J & ' , CT=' & $CTn
					ToolTip($Str, 0, 0)
				EndIf
			Next

			If $CT <> $CTn Then
				ToolTip('')
				MsgBox(16, 'Warning', 'CBC Encrypt Monte Carlo Test failed on ' & $Str)
				Return
			Else
				$Counter += 1
			EndIf
		EndIf
	Next
	ToolTip('')
	MsgBox(32, 'CBC Encrypt Monte Carlo Test Succeed', $Counter & ' test vectors passed in "' & $TableFile & '"')
EndFunc

Func AesMonteCarloTest_DecryptCBC($TableFile)
	Local $Table = FileRead($TableFile)
	Local $Match = StringRegExp($Table, "KEY=[0-9A-Fa-f]*|PT=[0-9A-Fa-f]*|CT=[0-9A-Fa-f]*|I=[0-9A-Fa-f]*|IV=[0-9A-Fa-f]*", 3)
	Local $KEY, $CT, $PT, $IV, $I, $J, $Index, $Counter = 0

	For $Index = 0 To UBound($Match) - 1
		Local $Pair = StringSplit($Match[$Index], "=")
		If $Pair[0] <> 2 Then ContinueLoop
		Assign($Pair[1], $Pair[2], 1)

		If $Pair[1] = "PT" Then
			If Not IsBinary($Key) Then $Key = Binary('0x' & $Key)
			If Not IsBinary($PT) Then $PT = Binary('0x' & $PT)
			If Not IsBinary($CT) Then $CT = Binary('0x' & $CT)
			If Not IsBinary($IV) Then $IV = Binary('0x' & $IV)

			Local $Ctx = _AesDecryptKey($Key)
			For $J = 1 To 10000
				Local $CTBak = $CT
				Local $PTn = _AesDecryptCBC($Ctx, $IV, $CT)
				$IV = $CTBak
				$CT = $PTn

				If Mod($J, 200) = 0 Then
					Local $Str = 'KEYSIZE=' & (BinaryLen($Key) * 8) & ', I=' & $I & ', J=' & $J & ' , PT=' & $PTn
					ToolTip($Str, 0, 0)
				EndIf
			Next

			If $PT <> $PTn Then
				ToolTip('')
				MsgBox(16, 'Warning', '"CBC Decrypt Monte Carlo Test" failed on ' & $Str)
				Return
			Else
				$Counter += 1
			EndIf
		EndIf
	Next
	ToolTip('')
	MsgBox(32, 'CBC Decrypt Monte Carlo Test Succeed', $Counter & ' test vectors passed in "' & $TableFile & '"')
EndFunc
