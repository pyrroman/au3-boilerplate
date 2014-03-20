#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Export Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Export Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oAppl)
Example2($oAppl, $oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Export cells A1:E10 of the active worksheet as PDF and display the file.
; *****************************************************************************
Func Example1($oAppl)

	Local $sOutput = @TempDir & "\_Excel1_1.pdf"
	_Excel_Export($oAppl, "A1:E10", $sOutput, Default, Default, Default, Default, Default, True)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Export Example 1", "Error saving range to '" & $sOutput & "'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Export Example 1", "Range successfully exported as '" & $sOutput & "'.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Export the whole workbook as PDF.
; *****************************************************************************
Func Example2($oAppl, $oWorkbook)

	Local $sOutput = @TempDir & "\_Excel1_2.pdf"
	_Excel_Export($oAppl, $oWorkbook, $sOutput)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Export Example 2", "Error saving the workbook to '" & $sOutput & "'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Export Example 2", "The whole workbook was successfully exported as '" & $sOutput & "'.")

EndFunc   ;==>Example2