#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Array.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeDelete Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeDelete Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)
Example2($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Delete a range with 3 rows and 2 columns on the active worksheet
; and shift the cells up.
; *****************************************************************************
Func Example1($oWorkbook)

	_Excel_RangeDelete($oWorkbook.ActiveSheet, "A2:B4", $xlShiftUp)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeDelete Example 1", "Error deleting cells." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeDelete Example 1", "Range successfully deleted.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Delete 2 rows (1 and 2) on worksheet 2
; *****************************************************************************
Func Example2($oWorkbook)

	_Excel_RangeDelete($oWorkbook.Worksheets(2), "1:2")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeDelete Example 2", "Error deleting rows." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeDelete Example 2", "Rows successfully deleted on worksheet 2.")

EndFunc   ;==>Example2