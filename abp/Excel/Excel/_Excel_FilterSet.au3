#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
;-----------------------------------------------
; http://www.contextures.com/xlautofilter01.html
;-----------------------------------------------
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)
Example2($oWorkbook)
Example3($oWorkbook)
Example4($oWorkbook)
Example5($oWorkbook)
Example6($oWorkbook)
Example7($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Filter the complete active worksheet on column 1.
; Only show rows with content >20 and <40 in the specified column.
; *****************************************************************************
Func Example1($oWorkbook)
	_Excel_FilterSet($oWorkbook, Default, "A1:E30", 1, ">20", 1, "<40")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 1", "Error filtering data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 1", "Filtered on column 'A'. Only show rows with values >20 and <40.")
EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Add a filter to column 2.
; Only show rows with content <310 in the specified column.
; *****************************************************************************
Func Example2($oWorkbook)
	_Excel_FilterSet($oWorkbook, Default, Default, 2, "<310")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 2", "Error filtering data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 2", "Added filter on column 'B'. Only show rows with values <310.")
EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Remove the filter from column 1.
; *****************************************************************************
Func Example3($oWorkbook)
	_Excel_FilterSet($oWorkbook, Default, Default, 1)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 3", "Error filtering data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 3", "Removed filter from column 'A'.")
EndFunc   ;==>Example3

; *****************************************************************************
; Example 4
; Only display selected values (20, 40 and 60) of column 2.
; *****************************************************************************
Func Example4($oWorkbook)
	Local $aShow[] = ["20", "40", "60"]
	_Excel_FilterSet($oWorkbook, Default, Default, 2, $aShow, $xlFilterValues)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 4", "Error filtering data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 4", "Set filter in column 'B' to only display selected values (20, 40 and 60).")
EndFunc   ;==>Example4

; *****************************************************************************
; Example 5
; Remove all filters.
; *****************************************************************************
Func Example5($oWorkbook)
	_Excel_FilterSet($oWorkbook, Default, Default, 0)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 5", "Error filtering data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 5", "All filters removed.")
EndFunc   ;==>Example5

; *****************************************************************************
; Example 6
; Filter Column M by date. Show all dates in october of 2013 and 2014.
; 0-year, 1-month, 2-day, 3-hour, 4-minute, 5-second
; *****************************************************************************
Func Example6($oWorkbook)
	Local $aShow[] = [1, "01/10/2013", 1, "01/10/2014"]
	_Excel_FilterSet($oWorkbook, Default, Default, 13, Default, $xlFilterValues, $aShow)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 6", "Error filtering data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 6", "Column 'M' filtered by date. Show all dates in October of 2013 and 2014.")
EndFunc   ;==>Example6

; *****************************************************************************
; Example 7
; Filter Column M by date. Show all dates of last year.
; *****************************************************************************
Func Example7($oWorkbook)
	_Excel_FilterSet($oWorkbook, Default, Default, 13, $xlFilterLastYear, $xlFilterDynamic)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 7", "Error filtering data." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_FilterSet Example 7", "Column 'M' filtered by date. Show all dates of last year.")
EndFunc   ;==>Example7