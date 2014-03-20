#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookOpen Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)

Example1($oAppl)

Exit

; *****************************************************************************
; Example 1
; Create a new workbook, write some data and close it without saving
; *****************************************************************************
Func Example1($oAppl)

	; Create the new workbook
	Local $oWorkbook = _Excel_BookNew($oAppl)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookClose Example 1", "Error creating new workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	; Write something into cell A1
	_Excel_RangeWrite($oWorkbook, Default, "Test", "A1")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookClose Example 1", "Error writing to cell 'A1'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox(64, "Excel UDF: _Excel_BookClose Example 1", "Click OK to close the workbook without saving.")
	; Close the workbook without saving
	_Excel_BookClose($oWorkbook, False)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookClose Example 1", "Error saving workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookClose Example 1", "Workbook has been successfully closed.")

EndFunc   ;==>Example1
