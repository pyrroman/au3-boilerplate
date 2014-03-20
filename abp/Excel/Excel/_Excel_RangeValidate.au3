#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open(True, True)
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeValidate Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookNew($oAppl)
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeValidate Example", "Error creating new workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)
Example2($oWorkbook)
Example3($oWorkbook)
Example4($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Only values from a list are valid
; *****************************************************************************
Func Example1($oWorkbook)

	_Excel_RangeValidate($oWorkbook, Default, "A1:A10", $xlValidateList, "Yes;No;Don't know")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeValidate Example 1", "Error setting range validation." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeValidate Example 1", "Validation against a list of values successfully set for range 'A1:A10'.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Only values from a list defined in a cell range (column 'D') are valid
; *****************************************************************************
Func Example2($oWorkbook)

	; Write values to a range
	Local $aValidation[] = ["10", "20", "30", "40", "50"]
	_Excel_RangeWrite($oWorkbook, Default, $aValidation, "D1")
	; Only values from the range are valid
	_Excel_RangeValidate($oWorkbook, Default, "C:C", $xlValidateList, "=D:D")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeValidate Example 2", "Error setting range validation." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeValidate Example 2", "Validation against a list of values in cell range '=D:D' successfully set for colum 'C'.")

EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Only numeric values are valid
; *****************************************************************************
Func Example3($oWorkbook)

	_Excel_RangeValidate($oWorkbook, Default, "B:B", $xlValidateDecimal, 0, $xlGreater, Default, Default, $xlValidAlertStop, "You entered a non numeric value!", "Only numeric values are valid.")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeValidate Example 3", "Error setting range validation." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeValidate Example 3", "Only numeric values are valid in column 'B'.")

EndFunc   ;==>Example3

; *****************************************************************************
; Example 4
; Custom validation. Sum of all cells in column 'E' has to be < 100
; *****************************************************************************
Func Example4($oWorkbook)

	_Excel_RangeValidate($oWorkbook, Default, "E:E", $xlValidateCustom, "=SUMME(E:E)<=100", Default, Default, Default, Default, "Sum of all cells in column 'E' > 100.")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeValidate Example 4", "Error setting range validation." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeValidate Example 4", "Sum of all cells in column 'E' has to be < 100.")

EndFunc   ;==>Example4