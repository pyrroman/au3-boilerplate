#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

Global $oExcel1, $oExcel2

Example1()
Example2()

_Excel_Close($oExcel1)
_Excel_Close($oExcel2)

Exit

; *****************************************************************************
; Example 1
; Create application object or connect to an already running Excel instance
; *****************************************************************************
Func Example1()

	$oExcel1 = _Excel_Open()
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Open Example 1", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Open Example 1", "Excel Application has been opened successfully." & @CRLF & @CRLF & "Will _Excel_Close close the application?: " & @extended)

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Force the creation of a new Excel application and display alerts
; *****************************************************************************
Func Example2()

	$oExcel2 = _Excel_Open(Default, True, Default, True)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Open Example 2", "Error creating a new Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	Local $aProcesses = ProcessList("Excel.exe")
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_Open Example 2", "Excel Application has been opened successfully." & @CRLF & @CRLF & $aProcesses[0][0] & " Excel instances are running.")

EndFunc   ;==>Example1