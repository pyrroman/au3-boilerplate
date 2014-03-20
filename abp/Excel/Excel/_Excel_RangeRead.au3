#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Array.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeRead Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeRead Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)
Example2($oWorkbook)
Example3($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Read data from a single cell on the active sheet of the specified workbook
; *****************************************************************************
Func Example1($oWorkbook)
	Local $sResult = _Excel_RangeRead($oWorkbook, Default, "A1")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeRead Example 1", "Error reading from workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeRead Example 1", "Data successfully read." & @CRLF & "Value of cell A1: " & $sResult)
EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Read the formulas of a cell range on sheet 2 of the specified workbook
; *****************************************************************************
Func Example2($oWorkbook)
	Local $aResult = _Excel_RangeRead($oWorkbook, 2, "A1:C1", 2)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeRead Example 2", "Error reading from workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeRead Example 2", "Data successfully read." & @CRLF & "Please click 'OK' to display the formulas of cells A1:C1 of sheet 2.")
	_ArrayDisplay($aResult, "Excel UDF: _Excel_RangeRead Example 2 - Cells A1:C1 of sheet 2")
EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Read the formulas of a cell range (all used cells in column A)
; *****************************************************************************
Func Example3($oWorkbook)
	Local $aResult = _Excel_RangeRead($oWorkbook, Default, $oWorkbook.ActiveSheet.Usedrange.Columns("A:A"), 2)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeRead Example 3", "Error reading from workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeRead Example 3", "Data successfully read." & @CRLF & "Please click 'OK' to display all formulas in column A.")
	_ArrayDisplay($aResult, "Excel UDF: _Excel_RangeRead Example 3 - Formulas in column A")
EndFunc   ;==>Example2