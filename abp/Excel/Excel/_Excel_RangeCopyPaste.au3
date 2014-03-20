#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
; Open Workbook 2
Global $oWorkbook2 = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel3.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example", "Error opening workbook '_Excel2.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf
; Open Workbook 1
Global $oWorkbook1 = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oAppl, $oWorkbook1)
Example2($oWorkbook1, $oWorkbook2)
Example3($oWorkbook1)
Example4($oWorkbook1)
Example5($oWorkbook1)

Exit

; *****************************************************************************
; Example 1
; Copy a range with 3 rows and 2 columns on the active worksheet.
; Pass the source range as object.
; *****************************************************************************
Func Example1($oAppl, $oWorkbook1)

	Local $oRange = $oAppl.ActiveSheet.Range("A2:B4")
	_Excel_RangeCopyPaste($oWorkbook1.ActiveSheet, $oRange, "G7")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example 1", "Error copying cells." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example 1", "Range 'A2:B4' successfully copied to 'G7'.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Copy a single cell from another workbook. Pass the source range as object.
; *****************************************************************************
Func Example2($oWorkbook1, $oWorkbook2)

	Local $oRange = $oWorkbook2.Worksheets(1).Range("A1")
	_Excel_RangeCopyPaste($oWorkbook1.Worksheets(1), $oRange, "G15")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example 2", "Error copying cells." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example 2", "Range 'A1' from workbook _Excel3.xls successfully copied to 'G15'.")

EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Copy 2 rows (1 and 2) from worksheet 2 to the clipboard
; *****************************************************************************
Func Example3($oWorkbook1)

	_Excel_RangeCopyPaste($oWorkbook1.Worksheets(2), "1:2")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example 3", "Error copying rows." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example 3", "Rows 1+2 successfully copied from worksheet 2 to the clipboard.")

EndFunc   ;==>Example3

; *****************************************************************************
; Example 4
; Paste the range written by Example 3 from the clipboard to the active worksheet.
; Only values without formatting will be pasted.
; *****************************************************************************
Func Example4($oWorkbook1)

	_Excel_RangeCopyPaste($oWorkbook1.Activesheet, Default, "1:1", Default, $xlPasteValues)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example 4", "Error copying rows." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example 4", "2 Rows successfully pasted from the clipboard to row 1.")

EndFunc   ;==>Example4


; *****************************************************************************
; Example 5
; Paste the format of a cell to other cells
; *****************************************************************************
Func Example5($oWorkbook1)

	_Excel_RangeCopyPaste($oWorkbook1.Activesheet, "A1") ; Copy the cell to the clipboards
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example5", "Error copying rcell A1." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_RangeCopyPaste($oWorkbook1.Activesheet, Default, "B1:E16", Default, $xlPasteFormats) ; paste the format to the target range
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example5", "Error pasting cells." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeCopy Example 5", "Format of cell 'A1' successfully pasted to 'B1:E16'.")

EndFunc   ;==>Example5