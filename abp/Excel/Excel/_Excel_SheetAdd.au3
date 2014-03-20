#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetAdd Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetAdd Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)
Example2($oWorkbook)
Example3($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Insert two sheets after the last sheet and name them
; *****************************************************************************
Func Example1($oWorkbook)

	_Excel_SheetAdd($oWorkbook, -1, False, 2, "Test1|Test2")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetAdd Example 1", "Error adding sheets." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetAdd Example 1", "Two sheets added after the last one.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Insert a sheet before sheet 2. Name is default name
; *****************************************************************************
Func Example2($oWorkbook)

	_Excel_SheetAdd($oWorkbook, 2)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetAdd Example 2", "Error adding sheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetAdd Example 2", "Sheet added before sheet 2.")

EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Insert an index sheet with links to all other sheets
; *****************************************************************************
Func Example3($oWorkbook)

	Local $oSheet = _Excel_SheetAdd($oWorkbook, 1, True, 1, "Index")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetAdd Example 3", "Error adding sheet." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	$oSheet.Range("A1").Value = "Index"
	Local $iRow = 2
	For $iSheet = 2 To $oWorkbook.Sheets.Count
		$oSheet.Cells($iRow, 1).Value = $iRow - 1
		$oSheet.Cells($iRow, 2).Value = $oWorkbook.Worksheets($iRow).Name
		$oSheet.Hyperlinks.Add($oSheet.Cells($iRow, 2), "", $oSheet.Cells($iRow, 2).Value & "!A1")
		$iRow = $iRow + 1
	Next
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_SheetAdd Example 3", "Index Sheet inserted as sheet 1.")

EndFunc   ;==>Example2