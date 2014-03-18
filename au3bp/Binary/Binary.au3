 #include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _BinaryMerge
; Description ...: Merges two binary strings
; Syntax ........: _BinaryMerge($bBin1, $bBin2)
; Parameters ....: $bBin1               - A binary value.
;                  $bBin2               - A binary value.
; Return values .: Merged binary
; Author ........: rindeal <dev |DOT| rindeal @AT@ outlook \DOT\ com>
; Modified ......:
; Version .......: 2014-03-05
; Requirements ..: Nothing special
; Performance ...: 10k times in 200 ms
; Remarks .......:
; Related .......:
; Link ..........: https://gist.github.com/rindeal/9358771
; Example .......: No
; ===============================================================================================================================
Func _BinaryMerge($bBin1, $bBin2)
	$bBin1 = Binary($bBin1)
	$bBin2 = Binary($bBin2)
	Local $iBinLen1 = BinaryLen($bBin1), $iBinLen2 = BinaryLen($bBin2)

	If $iBinLen1 = 0 Then Return $bBin2
	If $iBinLen2 = 0 Then Return $bBin1

	Local $tBuffer = DllStructCreate('byte[' & $iBinLen1 + $iBinLen2 & ']')
	Local $pBuffer = DllStructGetPtr($tBuffer)

	DllStructSetData($tBuffer, 1, $bBin1)
	DllStructSetData(DllStructCreate('byte[' & $iBinLen2 & ']', $pBuffer + $iBinLen1), 1, $bBin2)

	Return DllStructGetData($tBuffer, 1)
EndFunc   ;==>_BinaryMerge

Func _BinaryEnsure(ByRef $bBinary)
	$bBinary = Binary((StringLeft($bBinary, 2) = "0x") ? $bBinary : ("0x" & $bBinary))
EndFunc   ;==>_BinaryEnsure