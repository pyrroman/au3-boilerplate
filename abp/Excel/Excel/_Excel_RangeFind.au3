#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Array.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeFind Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeFind Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)
Example2($oWorkbook)
Example3($oWorkbook)
Example4($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Find all occurrences of value "37000" (partial match)
; *****************************************************************************
Func Example1($oWorkbook)

	Local $aResult = _Excel_RangeFind($oWorkbook, "37000")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeFind Example 1", "Error searching the range." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeFind Example 1", "Find all occurrences of value '37000' (partial match)." & @CRLF & "Data successfully searched.")
	_Arraydisplay($aResult, "Excel UDF: _Excel_RangeFind Example 1", -1, 0, "", "|", "Col|Sheet|Name|Cell|Value|Formula|Comment")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Find all occurrences of string "=C10*10" in the formulas, exact match
; *****************************************************************************
Func Example2($oWorkbook)

	Local $aResult = _Excel_RangeFind($oWorkbook, "=C10*10", "A1:G15", $xlFormulas, $xlWhole)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeFind Example 2", "Error searching the range." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeFind Example 2", "Find all occurrences of string '=C10*10' in the formulas, exact match." & @CRLF & "Data successfully searched.")
	_Arraydisplay($aResult, "Excel UDF: _Excel_RangeFind Example 2", -1, 0, "", "|", "Col|Sheet|Name|Cell|Value|Formula|Comment")

EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Find all occurrences of string "test" in the comments
; *****************************************************************************
Func Example3($oWorkbook)

	Local $aResult = _Excel_RangeFind($oWorkbook, "test", Default, $xlComments)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeFind Example 3", "Error searching the range." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeFind Example 3", "Find all occurrences of string 'test' in the comments." & @CRLF & "Data successfully searched.")
	_Arraydisplay($aResult, "Excel UDF: _Excel_RangeFind Example 3", -1, 0, "", "|", "Col|Sheet|Name|Cell|Value|Formula|Comment")

EndFunc   ;==>Example3

; *****************************************************************************
; Example 4
; Find all values with "Story" at the end using wildcards and exact match
; *****************************************************************************
Func Example4($oWorkbook)

	Local $aResult = _Excel_RangeFind($oWorkbook, "* Story", Default, Default, $xlWhole)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeFind Example 4", "Error searching the range." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_RangeFind Example 4", "Find all values with 'Story' at the end using wildcards and exact match." & @CRLF & "Data successfully searched.")
	_Arraydisplay($aResult, "Excel UDF: _Excel_RangeFind Example 4", -1, 0, "", "|", "Col|Sheet|Name|Cell|Value|Formula|Comment")

EndFunc   ;==>Example3