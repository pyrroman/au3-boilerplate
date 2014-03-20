#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Array.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeReplace Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeReplace Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)
Example2($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Replace content of cell A1 with another value
; *****************************************************************************
Func Example1($oWorkbook)

	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeReplace Example 1", "Press OK to modify data in cell 'A1'.")
	_Excel_RangeReplace($oWorkbook, Default, "A1", 1, 3.37)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeReplace Example 1", "Error replacing data the range." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeReplace Example 1", "Data successfully replaced in cell 'A1'.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Find all cells with text "long " and remove it (replace with "")
; *****************************************************************************
Func Example2($oWorkbook)

	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeReplace Example 1", "Press OK to modify data in cell 'G1'.")
	_Excel_RangeReplace($oWorkbook, Default, Default, "long ", "")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeReplace Example 2", "Error replacing data the range." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeReplace Example 2", "Remove text 'long '." & @CRLF & "Data successfully replaced.")

EndFunc   ;==>Example3