#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

Example1()

Exit

; ****************************************************************************
; Example 1
; Translate a column number to the Excel colunm letter
; ****************************************************************************
Func Example1()

	Local $iCol = 676
	Local $sLetter = _Excel_ColumnToLetter($iCol)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_ColumnToLetter Example 1", "Error converting number to letter." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_ColumnToLetter Example 1", "Number: " & $iCol & " = Letter: " & $sLetter)

EndFunc   ;==>Example1