#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object and open an example workbook
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookAttach Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
Global $oWorkbook = _Excel_BookOpen($oAppl, @ScriptDir & "\_Excel1.xls")
If @error <> 0 Then
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookAttach Example", "Error opening workbook '_Excel1.xls'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	_Excel_Close($oAppl)
	Exit
EndIf

Example1()
Example2()

Exit

; *****************************************************************************
; Example 1
; Attach to the first Workbook where the file path matches
; *****************************************************************************
Func Example1()

	Local $sWorkbook = @ScriptDir & "\_Excel1.xls"
	Local $oWorkbook = _Excel_BookAttach($sWorkbook)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookAttach Example 1", "Error attaching to '" & $sWorkbook & "'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookAttach Example 1", "Search by 'filepath':" & @CRLF & @CRLF & "Successfully attached to Workbook '" & $sWorkbook & "'." & @CRLF & @CRLF & "Value of cell B3: " & $oWorkbook.Activesheet.Range("B3").Value)

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Attach to the first Workbook where the file name matches
; *****************************************************************************
Func Example2()

	Local $sWorkbook = "_Excel1.xls"
	Local $oWorkbook = _Excel_BookAttach($sWorkbook, "filename")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookAttach Example 2", "Error attaching to '" & $sWorkbook & "'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookAttach Example 2", "Search by 'filename':" & @CRLF & @CRLF & "Successfully attached to Workbook '" & $sWorkbook & "'." & @CRLF & @CRLF & "Value of cell A2: " & $oWorkbook.Activesheet.Range("A2").Value)

EndFunc   ;==>Example2