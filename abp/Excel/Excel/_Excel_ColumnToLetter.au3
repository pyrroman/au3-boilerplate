#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

Example1()

Exit

; ****************************************************************************
; Example 1
; Translate an Excel column letter to the colunm number
; ****************************************************************************
Func Example1()

	Local $sCol = "YZ"
	Local $iNumber = _Excel_ColumnToNumber($sCol)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_ColumnToNumber Example 1", "Error converting letter to number." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_ColumnToNumber Example 1", "Letter: " & $sCol & " = Number: " & $iNumber)

EndFunc   ;==>Example1