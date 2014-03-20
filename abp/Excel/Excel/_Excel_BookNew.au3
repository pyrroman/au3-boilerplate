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
; Create a new workbook with only 2 worksheets
; *****************************************************************************
Func Example1($oAppl)

	_Excel_BookNew($oAppl, 2)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookNew Example 1", "Error creating new workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookNew Example 1", "Workbook has been created successfully with only 2 worksheets.")

EndFunc   ;==>Example1