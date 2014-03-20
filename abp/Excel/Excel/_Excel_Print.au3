#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Print Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel4.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Print Example", "Error opening workbook '_Excel4.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oAppl)
Example2($oAppl)
Example3($oAppl, $oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Print range A1:B3 of the active worksheet to the default printer.
; *****************************************************************************
Func Example1($oAppl)

	_Excel_Print($oAppl, "A1:B3")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Print Example 1", "Error printing cells." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Print Example 1", "Range successfully printed.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Print the active worksheet to the default printer.
; *****************************************************************************
Func Example2($oAppl)

	_Excel_Print($oAppl, $oAppl.ActiveSheet)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Print Example 2", "Error printing worksheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Print Example 2", "Active Worksheet successfully printed.")

EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Print a complete workbook to the default printer.
; *****************************************************************************
Func Example3($oAppl, $oWorkbook)

	_Excel_Print($oAppl, $oWorkbook)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Print Example 3", "Error printing workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Print Example 3", "Workbook successfully printed.")

EndFunc   ;==>Example3