#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Array.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeInsert Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeInsert Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)
Example2($oWorkbook)
Example3($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Insert a range with 3 rows and 2 columns before A1 on the active worksheet
; and shift the cells down.
; *****************************************************************************
Func Example1($oWorkbook)

	_Excel_RangeInsert($oWorkbook.Activesheet, "A1:B3", $xlShiftDown)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeInsert Example 1", "Error inserting cells." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeInsert Example 1", "Range successfully inserted.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Insert 3 columns before colum B on the active worksheet
; *****************************************************************************
Func Example2($oWorkbook)

	_Excel_RangeInsert($oWorkbook.Activesheet, "B:D")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeInsert Example 2", "Error inserting columns." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeInsert Example 2", "Columns successfully inserted.")

EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Insert 2 rows before row 1 on worksheet 2
; *****************************************************************************
Func Example3($oWorkbook)

	_Excel_RangeInsert($oWorkbook.Worksheets(2), "1:2")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeInsert Example 3", "Error inserting rows." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeInsert Example 3", "Rows successfully inserted on worksheet 2.")

EndFunc   ;==>Example3