#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
; Open Workbook 2
Global $oWorkbook2 = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel3.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example", "Error opening workbook '_Excel2.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf
; Open Workbook 1
Global $oWorkbook1 = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook1)
Example2($oWorkbook1)
Example3($oWorkbook1, $oWorkbook2)
Example4($oWorkbook1, $oWorkbook2)

Exit

; *****************************************************************************
; Example 1
; Copy sheet 1 after sheet 3. Set the name of the new sheet
; *****************************************************************************
Func Example1($oWorkbook1)

	Local $oCopiedSheet = _Excel_SheetCopyMove($oWorkbook1, 1, Default, 3, False)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example 1", "Error copying sheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	; Set the name of the new sheet
	#forceref $oCopiedSheet
	$oCopiedSheet.Name = "Copied sheet"
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example 1", "Sheet 1 copied after sheet 3 and renamed")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Move sheet 2 before sheet 1. Set the name of the moved sheet
; *****************************************************************************
Func Example2($oWorkbook1)

	Local $oMovedSheet = _Excel_SheetCopyMove($oWorkbook1, 2, Default, 1, Default, False)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example 2", "Error moving sheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	; Set the name of the new sheet
	#forceref $oMovedSheet
	$oMovedSheet.Name = "Moved sheet"
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example 2", "Sheet 2 moved before sheet 1")

EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Copy sheet 3 of Workbook1 after sheet 3 of workbook 2
; *****************************************************************************
Func Example3($oWorkbook1, $oWorkbook2)

	_Excel_SheetCopyMove($oWorkbook1, 3, $oWorkbook2, 3, False)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example 3", "Error copying sheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example 3", "Workbook 1 Sheet 3 copied to Workbook2 after sheet 3")

EndFunc   ;==>Example3

; *****************************************************************************
; Example 4
; Move sheet 1 of Workbook1 before sheet 1 of workbook 2
; *****************************************************************************
Func Example4($oWorkbook1, $oWorkbook2)

	_Excel_SheetCopyMove($oWorkbook1, 1, $oWorkbook2, 1, Default, False)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example 4", "Error moving sheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetCopyMove Example 4", "Workbook 1 Sheet 1 moved to Workbook2 before sheet 1")

EndFunc   ;==>Example4