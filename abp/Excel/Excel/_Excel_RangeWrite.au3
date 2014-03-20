#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Array.au3>
#include <Constants.au3>

; Create application object and create a new workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeWrite Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookNew($oAppl)
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeWrite Example", "Error creating the new workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
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
; Write a string with a line break to the active sheet in the active workbook
; *****************************************************************************
Func Example1($oWorkbook)

	_Excel_RangeWrite($oWorkbook, $oWorkbook.Activesheet, "Test" & @CRLF & "String")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeWrite Example 1", "Error writing to worksheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeWrite Example 1", "String successfully written.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Write a 1D array to the active sheet in the active workbook
; *****************************************************************************
Func Example2($oWorkbook)

	Local $aArray1D[3] = ["AA", "BB", "CC"]
	_Excel_RangeWrite($oWorkbook, $oWorkbook.Activesheet, $aArray1D, "A3")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeWrite Example 2", "Error writing to worksheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeWrite Example 2", "1D array successfully written.")

EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Write a part of a 2D array to the active sheet in the active workbook
; *****************************************************************************
Func Example3($oWorkbook)

	Local $aArray2D[3][5] = [[11,12,13,14,15],[21,22,23,24,25],[31,32,33,34,35]]
	_Excel_RangeWrite($oWorkbook, $oWorkbook.Activesheet, $aArray2D, "B1")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeWrite Example 3", "Error writing to worksheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeWrite Example 3", "2D array successfully written.")

EndFunc   ;==>Example3

; *****************************************************************************
; Example 4
; Fill a range in the active sheet in the active workbook with a formula
; *****************************************************************************
Func Example4($oWorkbook)

	_Excel_RangeWrite($oWorkbook, $oWorkbook.Activesheet, "=B1+3", "B5:F6", False)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeWrite Example 3", "Error writing to worksheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeWrite Example 3", "Range successfully filled with a formula.")

EndFunc   ;==>Example4