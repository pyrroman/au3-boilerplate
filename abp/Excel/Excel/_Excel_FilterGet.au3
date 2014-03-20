#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterGet Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterGet Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

; Set two filters
_Excel_FilterSet($oWorkbook, Default, "A:E", 3, "<610")
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterGet Example", "Error filtering data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $aShow[] = ["20", "40", "60"]
_Excel_FilterSet($oWorkbook, Default, "A:E", 2, $aShow, $xlFilterValues)
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterGet Example", "Error filtering data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterGet Example", "Filters set:" & @CRLF & "  Column B: values = 20, 40 or 60." & @CRLF & "  Column C: values <610.")

Example1($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Display information about the filters on the active worksheet.
; *****************************************************************************
Func Example1($oWorkbook)
	Local $aFilters = _Excel_FilterGet($oWorkbook)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterGet Example 1", "Error filtering data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_ArrayDisplay($aFilters, "Excel UDF: _Excel_FilterGet Example 1", -1, 0, "", "", "|Filter on|#areas|Criteria1|Criteria2|Operator|Range|#Records")
EndFunc   ;==>Example1

