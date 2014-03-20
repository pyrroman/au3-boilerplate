#AutoIt3Wrapper_AU3Check_Stop_OnWarning=N
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Array.au3>
#include <Constants.au3>

; Create two instances of Excel and open two workbooks
Global $oAppl1 = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookList Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook1 = _Excel_BookOpen($oAppl1, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookList Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl1)
	Exit
EndIf
Global $oAppl2 = _Excel_Open(Default, Default, Default, Default, True)
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookList Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook2 = _Excel_BookOpen($oAppl2, @ScriptDir & "\_Excel2.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookList Example", "Error opening workbook '_Excel2.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl1)
	_Excel_Close($oAppl2)
	Exit
EndIf

Example1($oAppl1)
Example2()

Exit

; *****************************************************************************
; Example 1
; Display a list of all workbooks of the specified Excel instance
; *****************************************************************************
Func Example1($oAppl)

	Local $aWorkBooks = _Excel_BookList($oAppl)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookList Example 1", "Error listing Workbooks." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_ArrayDisplay($aWorkBooks, "Excel UDF: _Excel_BookList Example 1 - List of workbooks of one instance")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Display a list of all workbooks of all Excel instances
; *****************************************************************************
Func Example2()

	Local $aWorkBooks = _Excel_BookList()
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookList Example 2", "Error listing Workbooks." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_ArrayDisplay($aWorkBooks, "Excel UDF: _Excel_BookList Example 2 - List of workbooks of all instances")

EndFunc   ;==>Example2