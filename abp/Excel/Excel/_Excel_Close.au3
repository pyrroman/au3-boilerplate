#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object
Global $oExcel1 = ObjCreate("Excel.Application")
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Close Example", "Error creating the first Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)

; Open Excel application (force new instance)
Global $oExcel2 = _Excel_Open(Default, Default, Default, Default, True)
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Close Example", "Error creating the second Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)

Example1($oExcel1)
Example2($oExcel2)
Example3($oExcel1)

Exit

; *****************************************************************************
; Example 1
; Close the Excel instance which was not opened by _Excel_Open
; (will still be running because it was not opened by _Excel_Open)
; *****************************************************************************
Func Example1(ByRef $oExcel)

	_Excel_Close($oExcel)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Close Example 1", "Error closing the Excel application." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	Sleep(2000)
	Local $aProcesses = ProcessList("Excel.exe")
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Close Example 1", "Function ended successfully." & @CRLF & @CRLF & $aProcesses[0][0] & " Excel instance(s) still running.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Close the Excel instance opened by _Excel_Open
; *****************************************************************************
Func Example2(ByRef $oExcel)

	_Excel_Close($oExcel)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Close Example 2", "Error closing the Excel application." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	Sleep(2000)
	Local $aProcesses = ProcessList("Excel.exe")
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Close Example 2", "Function ended successfully." & @CRLF & @CRLF & $aProcesses[0][0] & " Excel instance(s) still running.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 3
; Force the Excel instance not opened by _Excel_Open
; without saving open workbooks
; *****************************************************************************
Func Example3(ByRef $oExcel)

	_Excel_Close($oExcel, Default, True)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Close Example 3", "Error closing the Excel application." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	Sleep(2000)
	Local $aProcesses = ProcessList("Excel.exe")
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Close Example 3", "Function ended successfully." & @CRLF & @CRLF & $aProcesses[0][0] & " Excel instance(s) still running.")

EndFunc   ;==>Example1