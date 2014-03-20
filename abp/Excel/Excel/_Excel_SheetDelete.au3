#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetDelete Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetDelete Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Delete sheet number 1 of the specified workbook
; *****************************************************************************
Func Example1($oWorkbook)

	_Excel_SheetDelete($oWorkbook, 1)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetDelete Example 1", "Error deleting sheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetDelete Example 1", "First sheet has been deleted.")

EndFunc   ;==>Example1