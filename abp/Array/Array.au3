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
	If Not IsArray($avArray) _
			Or UBound($avArray, 0) <> 1 _
			Or Not IsInt($iWidth) Then Return SetError(1, 0, 0)

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

; #FUNCTION# ====================================================================================================================
; Name ..........: _Array_Assoc_Create
; Description ...: Creates a Scripting.Dictionary object that can be used as an associative array
;                  | - the items are set/get like this: $aAssocArray("key")=$value or $aAssocArray(123)=$value
;                  | - the key names are case insensitive
; Syntax ........: _Array_Assoc_Create()
; Parameters ....: $iCompareMode - defines mode for comparing string keys
;                  | 0 = binary mode
;                  | 1 = (default) text mode
; Return values .: Success - (obj) Scripting.Dictionary object
;                  Failure - (int) 0 and sets the @error flag to a non-zero value.
; Version .......: 2014-03-23
; Remarks .......: The object must be properly destroyed using _Array_Assoc_Destroy
; Related .......: _Array_Assoc_Destroy
; Link ..........: http://msdn.microsoft.com/en-us/library/x4k5wbx4.aspx
; Example .......: No
; ===============================================================================================================================
Func _Array_Assoc_Create($iCompareMode = 1)
	Local $aArray = ObjCreate("Scripting.Dictionary")
	If @error Then Return SetError(1)

	If $iCompareMode <> 0 Or $iCompareMode <> 1 Then $iCompareMode = 1

	$aArray.CompareMode = $iCompareMode

	Return $aArray
EndFunc   ;==>_Array_Assoc_Create

; #FUNCTION# ====================================================================================================================
; Name ..........: _Array_Assoc_Destroy
; Description ...: Destroys a Scripting.Dictionary object
; Syntax ........: _Array_Assoc_Destroy(Byref $aArray)
; Parameters ....: $aArray              - (array)(unknown) [ByRef]
; Return values .: Success - (integer) 1
;                  Failure - (integer) 0 - the variable is not a Scripting.Dicitonary object
; Version .......: 2014-03-23
; Remarks .......:
; Related .......: _Array_Assoc_Destroy
; Link ..........: http://msdn.microsoft.com/en-us/library/x4k5wbx4.aspx
; Example .......: No
; ===============================================================================================================================
Func _Array_Assoc_Destroy(ByRef $aArray)
	If Not IsObj($aArray) Then Return 0
	$aArray.RemoveAll()
	$aArray = 0
	Return 1
EndFunc   ;==>_Array_Assoc_Destroy

; #FUNCTION# ====================================================================================================================
; Name ..........: _Array_Ensure
; Description ...: Makes sure the variable provided is an array and has at least n-rows
; Syntax ........: _Array_Ensure(Byref $avArray[, $iRows = 1])
; Parameters ....: $avArray             - (array)(variant) [ByRef]
;                  $iRows               - (integer) [optional]->[1]
; Return values .: If the variable provided
; Version .......: 2014-03-26
; Remarks .......:
; Related .......:
; Link ..........:
; ===============================================================================================================================
Func _Array_Ensure(ByRef $avArray, $iRows = 1)
	If Not IsArray($avArray) Or UBound($avArray,1) < $iRows Then
		Local $avNewArray[$iRows]
		$avArray = $avNewArray
	EndIf
EndFunc   ;==>_Array_Ensure
