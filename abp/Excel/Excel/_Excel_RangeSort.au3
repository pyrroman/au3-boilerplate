#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Array.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)
Example2($oWorkbook)
Example3($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Sort a range with headers ascending on column I
; *****************************************************************************
Func Example1($oWorkbook)

	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example 1", "Press OK to sort range I1:K7. Key is column I.")
	_Excel_RangeSort($oWorkbook, Default, "I1:K7", "I:I", Default, Default, $xlYes)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example 1", "Error sorting data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example 1", "Data successfully sorted in range I1:K7")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Sort a range with headers descending on column K. Sort numbers as text
; *****************************************************************************
Func Example2($oWorkbook)

	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example 2", "Press OK to sort range I1:K7. Key is column K.")
	_Excel_RangeSort($oWorkbook, Default, "I1:K7", "K:K", $xlDescending, Default, $xlYes)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example 2", "Error sorting data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example 2", "Data successfully sorted in range I1:K7")

EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Sort a range with headers descending on row 1 (column headers)
; *****************************************************************************
Func Example3($oWorkbook)

	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example 3", "Press OK to sort range I1:K7. Key is row 1.")
	_Excel_RangeSort($oWorkbook, Default, "I1:K7", "1:1", $xlDescending, Default, $xlYes, Default, $xlSortRows)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example 3", "Error sorting data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeSort Example 3", "Data successfully sorted in range I1:K7")

EndFunc   ;==>Example3