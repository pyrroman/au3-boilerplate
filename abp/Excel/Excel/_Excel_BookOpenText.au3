#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#include <Excel Rewrite.au3>
#include <Constants.au3>

; Create application object
Global $oAppl = _Excel_Open()
If @error <> 0 Then Exit MsgBox(16, "Excel UDF: _Excel_BookOpenText Example", "Error creating the Excel application object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)

Example1($oAppl)
Example2($oAppl)

Exit

; *****************************************************************************
; Example 1
; Open a text file as delimited, separator = |, pass fieldinfo and set
; DecimalSeparator and ThousandsSeparator.
; *****************************************************************************
Func Example1($oAppl)

	Local $sTextFile = @ScriptDir & "\_Excel1.txt"
	Local $aField1[2] = [1, $xlTextFormat]
	Local $aField2[2] = [2, $xlTextFormat]
	Local $aField3[2] = [3, $xlGeneralFormat]
	Local $aField4[2] = [4, $xlDMYFormat]
	Local $aField5[2] = [5, $xlTextFormat]
	Local $aFieldInfo[5] = [$aField1, $aField2, $aField3, $aField4, $aField5]
	_Excel_BookOpenText($oAppl, $sTextFile, Default, $xlDelimited, Default, True, "|", $aFieldInfo, ",", ".")
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookOpenText Example 1", "Error opening '" & $sTextFile & "'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookOpenText Example 1", "Workbook '" & $sTextFile & "' has been opened successfully.")

EndFunc   ;==>Example1

; *****************************************************************************
; Example 2
; Open a text file as fixed, all other parameters will be determined by Excel
; *****************************************************************************
Func Example2($oAppl)

	Local $sTextFile = @ScriptDir & "\_Excel2.txt"
	_Excel_BookOpenText($oAppl, $sTextFile, Default, $xlFixedWidth)
	If @error <> 0 Then Return MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookOpenText Example 2", "Error opening '" & $sTextFile & "'." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	MsgBox($MB_SYSTEMMODAL, "Excel UDF: _Excel_BookOpenText Example 2", "Workbook '" & $sTextFile & "' has been opened successfully.")

EndFunc   ;==>Example2