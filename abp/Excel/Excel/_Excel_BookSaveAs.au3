#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSaveAs Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSaveAs Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Save the workbook to another directory and overwrita an existing version
; *****************************************************************************
Func Example1($oWorkbook)

	Local $sWorkbook = @TempDir & "\_Excel1.xls"
	_Excel_BookSaveAs($oWorkbook, $sWorkbook, Default, True)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSaveAs Example 1", "Error saving workbook to '" & $sWorkbook & "'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSaveAs Example 1", "Workbook successfully saved as '" & $sWorkBook & "'.")

EndFunc   ;==>Example1
