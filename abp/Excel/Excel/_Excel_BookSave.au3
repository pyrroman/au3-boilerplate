#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox(16, "Excel UDF: _Excel_BookOpen Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)

Example1($oAppl)

Exit

; *****************************************************************************
; Example 1
; Create a new workbook, write some data and save it to @tempdir
; *****************************************************************************
Func Example1($oAppl)

	; Create the new workbook
	Local $oWorkbook = _Excel_BookNew($oAppl)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSave Example 1", "Error creating new workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	; Write something into cell A1
	_Excel_RangeWrite($oWorkbook, Default, "Test", "A1")
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSave Example 1", "Error writing to cell 'A1'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	; Save the workbook to @tempdir as _Excel.xls (replacing existing file)
	_Excel_BookSaveAs($oWorkbook, @TempDir & "\_Excel.xls", Default, True)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSave Example 1", "Error saving workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	; Write something into cell B1
	_Excel_RangeWrite($oWorkbook, Default, "2nd Test", "B1")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSave Example 1", "Error writing to cell 'A1'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	; Save changed workbook
	_Excel_BookSave($oWorkbook)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSave Example 1", "Error saving workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookSave Example 1", "Workbook has been successfully saved as '" & @TempDir & "\_Excel.xls'.")

EndFunc   ;==>Example1
