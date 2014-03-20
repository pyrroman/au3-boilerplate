#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
; Create new Workbook
Global $oWorkbook = _Excel_BookNew($oAppl)
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example", "Error creating workbook." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1($oWorkbook)
Example2($oWorkbook)
Example3($oWorkbook)
Example4($oWorkbook)
Example5($oWorkbook)

Exit

; *****************************************************************************
; Example 1
; Insert and resize the picture into a range of cells. Aspect ratio retained
; *****************************************************************************
Func Example1($oWorkbook)
	_Excel_PictureAdd($oWorkbook, Default, @ScriptDir & "\_Excel.jpg", "B2:D8")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example 1", "Error inserting picture." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example 1", "Picture inserted/resized at 'B2:D8', aspect ratio retained.")
EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Insert the picture without resizing.
; *****************************************************************************
Func Example2($oWorkbook)
	_Excel_PictureAdd($oWorkbook, Default, @ScriptDir & "\_Excel.jpg", "F8")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example 2", "Error inserting picture." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example 2", "Picture inserted at 'F1' without resizing.")
EndFunc   ;==>Example2

; *****************************************************************************
; Example 3
; Insert the picture with a defined size/height.
; *****************************************************************************
Func Example3($oWorkbook)
	_Excel_PictureAdd($oWorkbook, Default, @ScriptDir & "\_Excel.jpg", "A8", Default, 300, 250)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example 3", "Error inserting picture." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example 3", "Picture inserted at 'A8' with defined size/height, aspect ratio ignored")
EndFunc   ;==>Example3

; *****************************************************************************
; Example 4
; Insert the picture with a defined size/height.
; *****************************************************************************
Func Example4($oWorkbook)
	_Excel_PictureAdd($oWorkbook, Default, @ScriptDir & "\_Excel.jpg", 250, 300, 300, 250)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example 4", "Error inserting picture." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example 4", "Picture inserted at position 250/300' with defined size/height, aspect ratio ignored")
EndFunc   ;==>Example4

; *****************************************************************************
; Example 5
; Insert the picture with a defined size/height.
; *****************************************************************************
Func Example5($oWorkbook)
	_Excel_PictureAdd($oWorkbook, Default, @ScriptDir & "\_Excel.jpg", "F2:H9", Default, Default, Default, False)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example 5", "Error inserting picture." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_PictureAdd Example 5", "Picture inserted/resized at 'F2:H9', aspect ratio ignored.")
EndFunc   ;==>Example5
