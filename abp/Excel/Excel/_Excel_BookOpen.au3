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
; Open an existing workbook and return its object identifier.
; *****************************************************************************
Func Example1($oAppl)

	Local $sWorkbook = @ScriptDir & "\_Excel1.xls"
	Local $oWorkbook = _Excel_BookOpen($oAppl, $sWorkbook, Default, Default, True)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookOpen Example 1", "Error opening '" & $sWorkbook & "'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookOpen Example 1", "Workbook '" & $sWorkbook & "' has been opened successfully." & @CRLF & @CRLF & "Creation Date: " & $oWorkBook.BuiltinDocumentProperties("Creation Date").Value)

EndFunc   ;==>Example1