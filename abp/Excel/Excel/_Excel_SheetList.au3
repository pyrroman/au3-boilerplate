#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Array.au3>
#include <Constants.au3>

; Create application object and open a workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetList Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel2.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetList Example", "Error opening workbook '_Excel2.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Display a list of all worksheets for a specific Workbook
; *****************************************************************************
Func Example1($oWorkBook)

	Local $aWorkSheets = _Excel_SheetList($oWorkBook)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetList Example 1", "Error listing Worksheets." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_ArrayDisplay($aWorkSheets, "Excel UDF: _Excel_SheetList Example 1")

EndFunc   ;==>Example1