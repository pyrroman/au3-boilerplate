#include-once
#include <Array.au3>

; #FUNCTION# ====================================================================================================================
; Name ..........: _Array_1DTo2D
; Description ...: Converts 1D array to 2D array
; Syntax ........: _Array_1DTo2D(Byref $avArray, $iWidth)
; Parameters ....: $avArray             - [ByRef] An array of variants.
;                  $iWidth              - An integer value. Number of columns of the new 2D array.
; Return values .: Success - (array) The new 2D array
;                  Failure - (integer) 0 and sets the @error flag to a non-zero value.
; Author ........: rindeal <dev.rindeal+autoit at outlook.com>
; Modified ......:
; Version .......: 2014-03-12
; Requirements ..:
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Array_1DTo2D(ByRef $avArray, $iWidth)
	If Not IsArray($avArray) Or UBound($avArray, 0) <> 1 Then Return SetError(1, 0, 0)

	Local $iArraySize = UBound($avArray), $iHeight = Ceiling($iArraySize / 2), $iPos = 0
	Local $avReturn[$iHeight][$iWidth]

	For $i = 0 To $iHeight - 1 ;  1D
		For $j = 0 To $iWidth - 1 ; 2D
			$iPos = $i * $iWidth + $j
			If $iPos >= $iArraySize Then ExitLoop
			$avReturn[$i][$j] = $avArray[$iPos]
		Next
	Next

	Return $avReturn
EndFunc   ;==>_Array_1DTo2D

; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayAdd_2D
; Description ...: Adds a new row to a 1D or 2D array
; Syntax ........: _ArrayAdd_2D(Byref $avArray, $vValues[, $sSeparator = "|"])
; Parameters ....: $avArray             - (array)(variant) [ByRef] An array the values will be added to.
;                  $vValues             - (variant) Values separated by $sSeparator
;                  $sSeparator          - (string) [optional]->["|"]
; Return values .: Success - (integer) Index of the new row
;                  Failure - (integer) 0 and sets the @error flag to a non-zero value.
; Author ........: rindeal <dev.rindeal at outlook.com>
; Modified ......:
; Version .......: 2014-03-12
; Requirements ..:
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ArrayAdd_2D(ByRef $avArray, $vValues, $sSeparator = "|")
	If Not IsArray($avArray) Then Return SetError(1, 0, -1)
	If UBound($avArray, 0) > 2 Then Return SetError(2, 0, -1)

	Local $iUBound = UBound($avArray)

	If UBound($avArray, 0) = 1 Then
		ReDim $avArray[$iUBound + 1]

		$avArray[$iUBound] = $vValues
	Else
		ReDim $avArray[$iUBound + 1][UBound($avArray, 2)]

		Local $avValue = StringSplit($vValues, $sSeparator)
		If Not IsArray($avValue) Then Return SetError(1, 0, 0)

		For $i = 0 To $avValue[0] - 1
			$avArray[$iUBound][$i] = $avValue[$i + 1]
		Next
	EndIf

	Return $iUBound
EndFunc   ;==>_ArrayAdd_2D

; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayBinarySearch_2D
; Description ...:
; Syntax ........: _ArrayBinarySearch_2D(Const Byref $avArray, $vValue[, $iColumn = 0[, $iStart = 0[, $iEnd = 0]]])
; Parameters ....: $avArray             - [const ByRef] An array of variants.
;                  $vValue              - A variant value.
;                  $iColumn             - [optional] An integer value. Default is 0.
;                  $iStart              - [optional] An integer value. Default is 0.
;                  $iEnd                - [optional] An integer value. Default is 0.
; Return values .: Success - 1
;                  Failure - 0 and sets the @error flag to a non-zero value.
; Author ........: rindeal <dev.rindeal at outlook.com>
; Modified ......:
; Version .......: 2014-03-12
; Requirements ..:
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ArrayBinarySearch_2D(Const ByRef $avArray, $vValue, $iColumn = 0, $iStart = 0, $iEnd = 0)
	_ArrayBinarySearch_2D_ByCol($avArray, $vValue, $iColumn, $iStart, $iEnd)
EndFunc   ;==>_ArrayBinarySearch_2D

; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayBinarySearch_2D_ByCol
; Description ...:
; Syntax ........: _ArrayBinarySearch_2D_ByCol(Const Byref $avArray, $vValue[, $iColumn = 0[, $iStart = 0[, $iEnd = 0]]])
; Parameters ....: $avArray             - [const ByRef] An array of variants.
;                  $vValue              - A variant value.
;                  $iColumn             - [optional] An integer value. Default is 0.
;                  $iStart              - [optional] An integer value. Default is 0.
;                  $iEnd                - [optional] An integer value. Default is 0.
; Return values .: Success - 1
;                  Failure - 0 and sets the @error flag to a non-zero value.
; Author ........: rindeal <dev.rindeal at outlook.com>
; Modified ......:
; Version .......: 2014-03-12
; Requirements ..:
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ArrayBinarySearch_2D_ByCol(Const ByRef $avArray, $vValue, $iColumn = 0, $iStart = 0, $iEnd = 0)
	If Not IsArray($avArray) Then Return SetError(1, 0, -1)
	If UBound($avArray, 0) <> 2 Then Return SetError(2, 0, -1)

	$vValue = String($vValue)
	Local $iRows = UBound($avArray, 1) - 1, $iColumns = UBound($avArray, 2) - 1
	If $iRows < 1 Or $iColumns < 1 Then Return SetError(3, 0, -1)

	; Bounds checking
	If $iEnd < 1 Or $iEnd > $iRows Then $iEnd = $iRows
	If $iStart < 0 Then $iStart = 0
	If $iStart > $iEnd Then Return SetError(4, 0, -1)
	If $iColumn < 0 Then $iColumn = 0
	If $iColumn > $iColumns Then Return SetError(5, 0, -1)

	Local $iMid = Int(($iEnd + $iStart) / 2)

	If $avArray[$iStart][$iColumn] > $vValue Or $avArray[$iEnd][$iColumn] < $vValue Then Return SetError(6, 0, -1)

	; Search
	While $iStart <= $iMid And $vValue <> $avArray[$iMid][$iColumn]
		If $vValue < $avArray[$iMid][$iColumn] Then
			$iEnd = $iMid - 1
		Else
			$iStart = $iMid + 1
		EndIf
		$iMid = Int(($iEnd + $iStart) / 2)
	WEnd

	If $iStart > $iEnd Then Return SetError(7, 0, -1) ; Entry not found

	Return $iMid
EndFunc   ;==>_ArrayBinarySearch_2D_ByCol

; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayBinarySearch_2D_ByRow
; Description ...:
; Syntax ........: _ArrayBinarySearch_2D_ByRow(Const Byref $avArray, $vValue[, $iRow = 0[, $iStart = 0[, $iEnd = 0]]])
; Parameters ....: $avArray             - [const ByRef] An array of variants.
;                  $vValue              - A variant value.
;                  $iRow                - [optional] An integer value. Default is 0.
;                  $iStart              - [optional] An integer value. Default is 0.
;                  $iEnd                - [optional] An integer value. Default is 0.
; Return values .: Success - 1
;                  Failure - 0 and sets the @error flag to a non-zero value.
; Author ........: rindeal <dev.rindeal at outlook.com>
; Modified ......:
; Version .......: 2014-03-12
; Requirements ..:
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _ArrayBinarySearch_2D_ByRow(Const ByRef $avArray, $vValue, $iRow = 0, $iStart = 0, $iEnd = 0)
	If Not IsArray($avArray) Then Return SetError(1, 0, -1)
	If UBound($avArray, 0) <> 2 Then Return SetError(2, 0, -1)

	$vValue = String($vValue)
	Local $iRows = UBound($avArray, 1) - 1, $iColumns = UBound($avArray, 2) - 1
	If $iRows < 1 Or $iColumns < 1 Then Return SetError(3, 0, -1)

	; Bounds checking
	If $iEnd < 1 Or $iEnd > $iColumns Then $iEnd = $iColumns
	If $iStart < 0 Then $iStart = 0
	If $iStart > $iEnd Then Return SetError(4, 0, -1)
	If $iRow < 0 Then $iRow = 0
	If $iRow > $iRows Then Return SetError(5, 0, -1)

	Local $iMid = Int(($iEnd + $iStart) / 2)

	If $avArray[$iRow][$iStart] > $vValue Or $avArray[$iRow][$iEnd] < $vValue Then Return SetError(6, 0, -1)

	; Search
	While $iStart <= $iMid And $vValue <> $avArray[$iRow][$iMid]
		If $vValue < $avArray[$iRow][$iMid] Then
			$iEnd = $iMid - 1
		Else
			$iStart = $iMid + 1
		EndIf
		$iMid = Int(($iEnd + $iStart) / 2)
	WEnd

	If $iStart > $iEnd Then Return SetError(7, 0, -1) ; Entry not found

	Return $iMid
EndFunc   ;==>_ArrayBinarySearch_2D_ByRow

; use Scripting.Dictionary object for simple associative arrays
; with string keys. Key comparisons are case insensitive.

;~ Global $myArray
;~ $myArray = _AssocArray()
;~ If @error Then
;~     MsgBox(0x1010,"_AssocArray() Error", "Error Creating Associative Array!")
;~     Exit
;~ EndIf

;~ $myArray("AntiqueWhite") = 0xFAEBD7
;~ $myArray("Black") = 0x000000
;~ $myArray("Blue") = 0x0000FF
;~ $myArray("Brown") = 0xA52A2A
;~ $myArray("CadetBlue") = 0x5F9EA0
;~ $myArray("Chocolate") = 0xD2691E
;~ $myArray("Coral") = 0xFF7F50

;~ MsgBox(0x1040,"","Hex for Chocolate Color is: 0x" & Hex($myArray("Chocolate"),6))
;~ _AssocArrayDestroy($myArray)

Func _Array_Assoc_Create()
    Local $aArray = ObjCreate("Scripting.Dictionary")

    If @error Then
        Return SetError(1, 0, 0)
    EndIf

    $aArray.CompareMode = 1

    Return $aArray
EndFunc   ;==>_AssocArray

Func _Array_Assoc_Destroy(ByRef $aArray)
    If Not IsObj($aArray) Then
        Return False
    EndIf
    $aArray.RemoveAll()
    $aArray = 0
    Return True
EndFunc   ;==>_AssocArrayDestroy
