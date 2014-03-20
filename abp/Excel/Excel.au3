#include-once
#include "ExcelConstants.au3"
#include <Array.au3>

; #INDEX# =======================================================================================================================
; Title .........: Microsoft Excel Function Library
; AutoIt Version : >= 3.3.10.0
; UDF Version ...: Beta 4
; Language ......: English
; Description ...: A collection of functions for accessing and manipulating Microsoft Excel files
; Author(s) .....: SEO (Locodarwin), DaLiMan, Stanley Lim, MikeOsdx, MRDev, big_daddy, PsaltyDS, litlmike, water, spiff59, golfinhu, bowmore, GMX, Andreu, danwilli
; Modified.......: 20140103 (YYYMMDD)
; Remarks .......:
; Contributors ..:
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_Excel_Open
;_Excel_Close
;_Excel_BookAttach
;_Excel_BookClose
;_Excel_BookList
;_Excel_BookNew
;_Excel_BookOpen
;_Excel_BookOpenText
;_Excel_BookSave
;_Excel_BookSaveAs
;_Excel_ColumnToLetter
;_Excel_ColumnToNumber
;_Excel_ConvertFormula
;_Excel_Export
;_Excel_FilterGet
;_Excel_FilterSet
;_Excel_PictureAdd
;_Excel_Print
;_Excel_RangeCopyPaste
;_Excel_RangeDelete
;_Excel_RangeFind
;_Excel_RangeInsert
;_Excel_RangeLinkAddRemove
;_Excel_RangeRead
;_Excel_RangeReplace
;_Excel_RangeSort
;_Excel_RangeValidate
;_Excel_RangeWrite
;_Excel_SheetAdd
;_Excel_SheetCopyMove
;_Excel_SheetDelete
;_Excel_SheetList
; ===============================================================================================================================

; #INTERNAL_USE_ONLY#============================================================================================================
;__Excel_CloseOnQuit
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_Open
; Description ...: Connects to an existing Excel instance or creates a new Excel application object.
; Syntax.........: _Excel_Open([$bVisible = True[, $bDisplayAlerts = False[, $bScreenUpdating = True[, $bInteractive = True[, $bForceNew = False]]]]])
; Parameters ....: $bVisible        - Optional: True specifies that the application will be visible (default = True)
;                  $bDisplayAlerts  - Optional: False suppresses all prompts and alert messages while opening a workbook (default = False)
;                  $bScreenUpdating - Optional: False suppresses screen updating to speed up your script (default = True)
;                  $bInteractive    - Optional: If False, Excel blocks all keyboard and mouse input by the user (except input to dialog boxes) (default = True)
;                  $bForceNew       - Optional: True forces to create a new Excel instance even if there is already a running instance (default = False)
; Return values .: Success - Returns the Excel application object. Sets @extended to:
;                  |0 - Excel was already running
;                  |1 - Excel was not running or $bForceNew was set to True. A new Excel instance has been created
;                  Failure - Returns 0 and sets @error
;                  |1 - Error returned by ObjCreate. @extended is set to the COM error code
; Author ........: water
; Modified ......:
; Remarks .......: If $bDisplayAlerts is set to False and a message requires a response, Excel chooses the default response.
;+
;                  To enhance performance set $bScreenUpdating to False. The screen will not be updated until you set $oExcel.ScreenUpdating = True.
;+
;                  Blocking user input ($obInteractive = False) will prevent the user from interfering with the AutoIt script.
;                  If set to False, don't forget to set it back to True ($oExcel.Interactive = True)
; Related .......: _Excel_Close
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_Open($bVisible = Default, $bDisplayAlerts = Default, $bScreenUpdating = Default, $bInteractive = Default, $bForceNew = Default)
	Local $oExcel, $bApplCloseOnQuit = False
	If $bVisible = Default Then $bVisible = True
	If $bDisplayAlerts = Default Then $bDisplayAlerts = False
	If $bScreenUpdating = Default Then $bScreenUpdating = True
	If $bInteractive = Default Then $bInteractive = True
	If $bForceNew = Default Then $bForceNew = False
	If Not $bForceNew Then $oExcel = ObjGet("", "Excel.Application")
	If $bForceNew Or @error Then
		$oExcel = ObjCreate("Excel.Application")
		If @error Or Not IsObj($oExcel) Then Return SetError(1, @error, 0)
		$bApplCloseOnQuit = True
	EndIf
	__Excel_CloseOnQuit($oExcel, $bApplCloseOnQuit)
	$oExcel.Visible = $bVisible
	$oExcel.DisplayAlerts = $bDisplayAlerts
	$oExcel.ScreenUpdating = $bScreenUpdating
	$oExcel.Interactive = $bInteractive
	Return SetError(0, $bApplCloseOnQuit, $oExcel)
EndFunc   ;==>_Excel_Open

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_Close
; Description ...: Closes all worksheets and the instance of the Excel application.
; Syntax.........: _Excel_Close($oExcel[, $iSaveChanges = True[, $bForceClose = False]])
; Parameters ....: $oExcel       - Excel application object as returned by _Excel_Open
;                  $bSaveChanges - Optional: Specifies whether changed worksheets should be saved before closing (default = True)
;                  $bForceClose  - Optional: If True the Excel application is closed even when it was not started by _Excel_Open (default = False)
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error
;                  |1 - $oExcel is not an object or not an application object
;                  |2 - Error returned by method Application.Quit. @extended is set to the COM error code
;                  |3 - Error returned by method Application.Save. @extended is set to the COM error code
; Author ........: water
; Modified ......:
; Remarks .......: If Excel was started by _Excel_Open then _Excel_Close closes all workbooks
;                  (even those opened manually by the user for this instance after _Excel_Open) and closes the specified Excel instance.
;                  If _Excel_Open connected to an already running instance of Excel then you have to set $bForceClose to True to do the same.
; Related .......: _Excel_Open
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_Close(ByRef $oExcel, $bSaveChanges = Default, $bForceClose = Default)
	If $bSaveChanges = Default Then $bSaveChanges = True
	If $bForceClose = Default Then $bForceClose = False
	If Not IsObj($oExcel) Or ObjName($oExcel, 1) <> "_Application" Then Return SetError(1, 0, 0)
	If $bSaveChanges Then
		For $oWorkbook In $oExcel.Workbooks
			If Not $oWorkbook.Saved Then
				$oWorkbook.Save()
				If @error Then Return SetError(3, @error, 0)
			EndIf
		Next
	EndIf
	If __Excel_CloseOnQuit($oExcel) Or $bForceClose Then
		$oExcel.Quit()
		If @error Then Return SetError(2, @error, 0)
		__Excel_CloseOnQuit($oExcel, False)
		$oExcel = 0
	EndIf
	Return 1
EndFunc   ;==>_Excel_Close

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_BookAttach
; Description ...: Attach to the first instance of a workbook where the search string matches based on the selected mode.
; Syntax.........: _Excel_BookAttach($sString[, $sMode = "FilePath"[, $oInstance = Default]])
; Parameters ....: $sString   - String to search for
;                  $sMode     - Optional: specifies search mode:
;                  |FileName - Name of the open workbook
;                  |FilePath - Full path to the open workbook (default)
;                  |Title    - Title of the Excel window
;                  $oInstance - Optional: Object of the Excel instance to be searched (default = keyword Default = all instances)
; Return values .: Success - Returns the Excel workbook object
;                  Failure - Returns 0 and sets @error:
;                  |1 - An error occurred or $sString can't be found in any of the open workbooks. @extended is set to the COM error code
;                  |2 - $sMode is invalid
; Author ........: Bob Anthony (big_daddy)
; Modified.......: water
; Remarks .......:
; Related .......: _Excel_BookClose, _Excel_BookNew, _Excel_BookOpen, _Excel_BookOpenText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_BookAttach($sString, $sMode = Default, $oInstance = Default)
	Local $oWorkbook, $iCount = 0, $sCLSID_Workbook = "{00020819-0000-0000-C000-000000000046}" ; Microsoft.Office.Interop.Excel.WorkbookClass
	If $sMode = Default Then $sMode = "FilePath"
	While True
		$oWorkbook = ObjGet("", $sCLSID_Workbook, $iCount + 1)
		If @error Then Return SetError(1, @error, 0)
		If $oInstance <> Default And $oInstance <> $oWorkbook.Parent Then ContinueLoop
		Switch $sMode
			Case "filename"
				If $oWorkbook.Name = $sString Then Return $oWorkbook
			Case "filepath"
				If $oWorkbook.FullName = $sString Then Return $oWorkbook
			Case "title"
				If ($oWorkbook.Application.Caption) = $sString Then Return $oWorkbook
			Case Else
				Return SetError(2, 0, 0)
		EndSwitch
		$iCount += 1
	WEnd
EndFunc   ;==>_Excel_BookAttach

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_BookClose
; Description ...: Closes the specified workbook.
; Syntax.........: _Excel_BookClose($oWorkbook[, $bSave = True])
; Parameters ....: $oWorkbook - Workbook object
;                  $bSave     - If True the workbook will be saved before closing (default = True)
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - Error occurred when saving the workbook. @extended is set to the COM error code returned by the Save method
;                  |3 - Error occurred when closing the workbook. @extended is set to the COM error code returned by the Close method
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: 07/17/2008 by big_daddy, litlmike, water
; Remarks .......: None
; Related .......: _Excel_BookAttach, _Excel_BookNew, _Excel_BookOpen, _Excel_BookOpenText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_BookClose(ByRef $oWorkbook, $bSave = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If $bSave = Default Then $bSave = True
	If $bSave And Not $oWorkbook.Saved Then
		$oWorkbook.Save()
		If @error Then Return SetError(2, @error, 0)
	EndIf
	$oWorkbook.Close()
	If @error Then Return SetError(3, @error, 0)
	$oWorkbook = 0
	Return 1
EndFunc   ;==>_Excel_BookClose

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_BookList
; Description ...: Returns a list of workbooks of a specified or all Excel instances.
; Syntax.........: _Excel_BookList([$oExcel = Default])
; Parameters ....: $oExcel - Optional: An Excel application object (default = keyword Default = process all Excel instances)
; Return values .: Success - Returns a two-dimensional zero based array with the following information:
;                  |0 - Object of the workbook
;                  |1 - Name of the workbook/file
;                  |2 - Complete path to the workbook/file
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oExcel is not an object or not an application object
; Author ........: water
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_BookList($oExcel = Default)
	Local $aBooks[1][3], $iIndex = 0
	If IsObj($oExcel) Then
		If ObjName($oExcel, 1) <> "_Application" Then Return SetError(1, 0, 0)
		Local $iTemp = $oExcel.Workbooks.Count
		ReDim $aBooks[$iTemp][3]
		For $iIndex = 0 To $iTemp - 1
			$aBooks[$iIndex][0] = $oExcel.Workbooks($iIndex + 1)
			$aBooks[$iIndex][1] = $oExcel.Workbooks($iIndex + 1).Name
			$aBooks[$iIndex][2] = $oExcel.Workbooks($iIndex + 1).Path
		Next
	Else
		If $oExcel <> Default Then Return SetError(1, 0, 0)
		Local $oWorkbook, $sCLSID_Workbook = "{00020819-0000-0000-C000-000000000046}"
		While True
			$oWorkbook = ObjGet("", $sCLSID_Workbook, $iIndex + 1)
			If @error Then ExitLoop
			ReDim $aBooks[$iIndex + 1][3]
			$aBooks[$iIndex][0] = $oWorkbook
			$aBooks[$iIndex][1] = $oWorkbook.Name
			$aBooks[$iIndex][2] = $oWorkbook.Path
			$iIndex += 1
		WEnd
	EndIf
	Return $aBooks
EndFunc   ;==>_Excel_BookList

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_BookNew
; Description ...: Creates a new workbook.
; Syntax.........: _Excel_BookNew($oExcel[, $iSheets = Default])
; Parameters ....: $oExcel  - Excel application object where you want to create the new workbook
;                  $iSheets - Optional: Number of sheets to create in the new workbook (default = keyword Default = Excel default value)
; Return values .: Success - Returns new workbook object
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oExcel is not an object or not an application object
;                  |2 - Error setting SheetsInNewWorkbook to $iSheets. @extended is set to the COM error code
;                  |3 - Error returned by method Workbooks.Add. @extended is set to the COM error code
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike, water
; Remarks .......:
; Related .......: _Excel_BookAttach, _Excel_BookClose, _Excel_BookOpen, _Excel_BookOpenText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_BookNew($oExcel, $iSheets = Default)
	If Not IsObj($oExcel) Or ObjName($oExcel, 1) <> "_Application" Then Return SetError(1, 0, 0)
	With $oExcel
		If $iSheets <> Default Then
			Local $iSheetsBackup = .SheetsInNewWorkbook = $iSheets
			.SheetsInNewWorkbook = $iSheets
			If @error Then Return SetError(2, @error, 0)
		EndIf
		Local $oWorkbook = .Workbooks.Add()
		If @error Then
			Local $iError = @error
			If $iSheets <> Default Then .SheetsInNewWorkbook = $iSheetsBackup
			Return SetError(3, $iError, 0)
		EndIf
		If $iSheets <> Default Then .SheetsInNewWorkbook = $iSheetsBackup
	EndWith
	Return $oWorkbook
EndFunc   ;==>_Excel_BookNew

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_BookOpen
; Description ...: Opens an existing workbook.
; Syntax.........: _Excel_BookOpen($oExcel, $sFilePath[, $bReadOnly = False[, $bVisible = True[, $sPassword = Default[, $sWritePassword = Default]]]])
; Parameters ....: $oExcel         - Excel application object where you want to open the workbook
;                  $sFilePath      - Path and filename of the file to be opened
;                  $bReadOnly      - Optional: Flag, whether to open the workbook as read-only (True or False) (default = False)
;                  $bVisible       - Optional: True specifies that the workbook window will be visible (default = True)
;                  $sPassword      - Optional: The password that was used to read-protect the workbook, if any (default is none)
;                  $sWritePassword - Optional: The password that was used to write-protect the workbook, if any (default is none)
; Return values .: Success - Returns workbook object
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oExcel is not an object or not an application object
;                  |2 - Specified $sFilePatch does not exist
;                  |3 - Unable to open $sFilePath. @extended is set to the COM error code returned by the Open method
;                  Failure - Returns workbook object and sets @error:
;                  |4 - Readwrite access could not be granted. Workbook might be open by another users/task
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike, water, GMK
; Remarks .......: If you set $bReadOnly = False but the document can't be opened read-write @error is set to 4 and
;                  the workbook object is returned (all other errors returns 0).
;                  You can alter the workbook but you have to use _Excel_BookSaveAs to save it to another location or with another name.
; Related .......: _Excel_BookAttach, _Excel_BookClose, _Excel_BookNew, _Excel_BookOpenText
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_BookOpen($oExcel, $sFilePath, $bReadOnly = Default, $bVisible = Default, $sPassword = Default, $sWritePassword = Default)
	If Not IsObj($oExcel) Or ObjName($oExcel, 1) <> "_Application" Then Return SetError(1, @error, 0)
	If Not FileExists($sFilePath) Then Return SetError(2, 0, 0)
	If $bReadOnly = Default Then $bReadOnly = False
	If $bVisible = Default Then $bVisible = True
	Local $oWorkbook = $oExcel.Workbooks.Open($sFilePath, Default, $bReadOnly, Default, $sPassword, $sWritePassword)
	If @error Then Return SetError(3, @error, 0)
	If Not $bVisible Then $oExcel.Activewindow.Visible = False
	; If a read-write workbook was opened read-only then return an error
	If $bReadOnly = False And $oWorkbook.Readonly = True Then Return SetError(4, 0, $oWorkbook)
	Return $oWorkbook
EndFunc   ;==>_Excel_BookOpen

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_BookOpenText
; Description ...: Opens a text file and parses the content to a new workbook with a single sheet.
; Syntax.........: _Excel_BookOpenText($oExcel, $sFilePath[, $iStartRow = 1[, $iDataType = Default[, $sTextQualifier = $xlTextQualifierDoubleQuote[, $bConsecutiveDelimiter = False[, $sDelimiter = ";"[, $aFieldInfo = ""[, $sDecimalSeparator = "."[, $sThousandsSeparator = ","[, $bTrailingMinusNumbers = True[, $iOrigin = Default]]]]]]]]]])
; Parameters ....: $oExcel                - Excel application object where you want to open the new workbook
;                  $sFilePath             - Path and filename of the file to be opened
;                  $iStartRow             - Optional: The row at which to start parsing the file (default = 1)
;                  $iDataType             - Optional: Specifies the column format of the data in the file. Can be any of the XlTextParsingType enumeration.
;                  |If set to keyword Default Excel attempts to determine the column format (default = keyword Default)
;                  $sTextQualifier        - Optional: Specifies the text qualifier (default = $xlTextQualifierDoubleQuote)
;                  $bConsecutiveDelimiter - Optional: True will consider consecutive delimiters as one delimiter (default = False)
;                  $sDelimiter            - Optional: One or multiple characters to be used as delimiter (default = ",")
;                  $aFieldInfo            - Optional: An array containing parse information for individual columns of data.
;                  |The interpretation depends on the value of DataType.
;                  |When the data is delimited, this argument is an array of two-element arrays, with each two-element array
;                  |specifying the conversion options for a particular column.
;                  |The first element is the column number (1-based), and the second element is one of the XlColumnDataType
;                  |constants specifying how the column is parsed (default = keyword Default)
;                  $sDecimalSeparator     - Optional: Decimal separator that Excel uses when recognizing numbers.
;                  |Default setting is the system setting (default = keyword Default)
;                  $sThousandsSeparator   - Optional: Thousands separator that Excel uses when recognizing numbers.
;                  |Default setting is the system setting (default = keyword Default)
;                  $bTrailingMinusNumbers - Optional: True treats numbers with a minus character at the end as negative numbers.
;                  |False treats such numbers as text (default = True)
;                  $iOrigin               - Optional: Origin of the text file. Can be one of the XlPlatform constants.
;                  |Additionally, this could be an integer representing the code page number of the desired code page.
;                  |For example, "1256" would specify that the encoding is Arabic (Windows).
;                  |If this argument is omitted, the method uses the current setting of the File Origin option in the Text Import Wizard.
; Return values .: Success - Returns workbook object
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oExcel is not an object or not an application object
;                  |2 - Specified $sFilePatch does not exist
;                  |3 - Unable to open or parse $sFilePath. @extended is set to the COM error code returned by the OpenText method
; Author ........: water
; Modified.......:
; Remarks .......: Parameter $aFieldInfo has to be an array containing arrays, not a 2D array. Please see example 2
; Related .......: _Excel_BookAttach, _Excel_BookClose, _Excel_BookNew, _Excel_BookOpen
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_BookOpenText($oExcel, $sFilePath, $iStartRow = Default, $iDataType = Default, $sTextQualifier = Default, $bConsecutiveDelimiter = Default, $sDelimiter = Default, $aFieldInfo = Default, $sDecimalSeparator = Default, $sThousandsSeparator = Default, $bTrailingMinusNumbers = Default, $iOrigin = Default)
	Local $bTab = False, $bSemicolon = False, $bComma = False, $bSpace = False, $aDelimiter[1], $bOther = False, $sOtherChar
	If Not IsObj($oExcel) Or ObjName($oExcel, 1) <> "_Application" Then Return SetError(1, @error, 0)
	If Not FileExists($sFilePath) Then Return SetError(2, 0, 0)
	If $iStartRow = Default Then $iStartRow = 1
	If $sTextQualifier = Default Then $sTextQualifier = $xlTextQualifierDoubleQuote
	If $bConsecutiveDelimiter = Default Then $bConsecutiveDelimiter = False
	If $sDelimiter = Default Then $sDelimiter = ","
	If $bTrailingMinusNumbers = Default Then $bTrailingMinusNumbers = True
	If StringInStr($sDelimiter, @TAB) > 0 Then $bTab = True
	If StringInStr($sDelimiter, ";") > 0 Then $bSemicolon = True
	If StringInStr($sDelimiter, ",") > 0 Then $bComma = True
	If StringInStr($sDelimiter, " ") > 0 Then $bSpace = True
	$aDelimiter = StringRegExp($sDelimiter, "[^;, " & @TAB & "]", 1)
	If Not @error Then
		$sOtherChar = $aDelimiter[0]
		$bOther = True
	EndIf
	$oExcel.Workbooks.OpenText($sFilePath, $iOrigin, $iStartRow, $iDataType, $sTextQualifier, $bConsecutiveDelimiter, _
			$bTab, $bSemicolon, $bComma, $bSpace, $bOther, $sOtherChar, $aFieldInfo, Default, $sDecimalSeparator, $sThousandsSeparator, _
			$bTrailingMinusNumbers, False)
	If @error Then Return SetError(3, @error, 0)
	Return $oExcel.ActiveWorkbook ; Method OpenText doesn't return the Workbook object
EndFunc   ;==>_Excel_BookOpenText

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_BookSave
; Description ...: Saves the specified workbook.
; Syntax.........: _Excel_BookSave($oWorkbook)
; Parameters ....: $oWorkbook - Object of the workbook to save
; Return values .: Success - Returns 1. Sets @extended to:
;                  |0 - File has not been saved because it has not been changed since the last save or file open
;                  |1 - File has been saved because it has been changed since the last save or file opne
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - Error occurred when saving the workbook. @extended is set to the COM error code
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike, water
; Remarks .......: A newly created workbook has to be saved using _Excel_BookSaveAs before
; Related .......: _Excel_BookSaveAs
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_BookSave($oWorkbook)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If Not $oWorkbook.Saved Then
		$oWorkbook.Save()
		If @error Then Return SetError(2, @error, 0)
		Return SetError(0, 1, 1)
	EndIf
	Return 1
EndFunc   ;==>_Excel_BookSave

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_BookSaveAs
; Description ...: Saves the specified workbook with a new filename and/or type.
; Syntax.........: _Excel_BookSaveAs($oWorkbook, $sFilePath[, $iType = $xlWorkbookNormal[, $bOverWrite = False[, $sPassword = Default[, $sWritePassword = Default[, $bReadOnlyRecommended = False]]]]])
; Parameters ....: $oWorkbook            - Workbook object to be saved
;                  $sFilePath            - Path and filename of the file to be read
;                  $iType                - Optional: Excel writable filetype. Can be any value of the XlFileFormat enumeration (default = $xlWorkbookNormal)
;                  $bOverWrite           - Optional: True overwrites an already existing file (default = False)
;                  $sPassword            - Optional: The string password to protect the sheet with. If set to keyword Default no password will be used (default = keyword Default)
;                  $sWritePassword       - Optional: The string write-access password to protect the sheet with. If set to keyword Default no password will be used (default = keyword Default)
;                  $bReadOnlyRecommended - Optional: True displays a message when the file is opened, recommending that the file be opened as read-only (default = False)
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object
;                  |2 - $iType is not a number
;                  |3 - File exists, overwrite flag not set
;                  |4 - File exists but could not be deleted
;                  |5 - Error occurred when saving the workbook. @extended is set to the COM error code returned by the SaveAs method
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike, water
; Remarks .......:
; Related .......: _Excel_BookSave
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_BookSaveAs($oWorkbook, $sFilePath, $iType = Default, $bOverWrite = Default, $sPassword = Default, $sWritePassword = Default, $bReadOnlyRecommended = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If $iType = Default Then $iType = $xlWorkbookNormal
	If Not IsNumber($iType) Then Return SetError(2, 0, 0)
	If $bOverWrite = Default Then $bOverWrite = False
	If $bReadOnlyRecommended = Default Then $bReadOnlyRecommended = False
	If FileExists($sFilePath) Then
		If Not $bOverWrite Then Return SetError(3, 0, 0)
		Local $iResult = FileDelete($sFilePath)
		If $iResult = 0 Then Return SetError(4, 0, 0)
	EndIf
	$oWorkbook.SaveAs($sFilePath, $iType, $sPassword, $sWritePassword, $bReadOnlyRecommended)
	If @error Then Return SetError(5, @error, 0)
	Return 1
EndFunc   ;==>_Excel_BookSaveAs

; #FUNCTION# ====================================================================================================================
; Name ..........: _Excel_ColumnToLetter
; Description ...: Convert the column number to letter(s).
; Syntax ........: _ExcelColumnToLetter($iColumn)
; Parameters ....: $iColumn - The column number which you want to turn into letter(s)
; Return values .: Success - Returns the column letter(s)
;                  Failure - Returns "" and sets @Error:
;                  |@error = 1 - The $iColumn is not a number
; Author(s):       Spiff59
; Modified ......:
; Remarks .......:
; Related .......: _Excel_ColumnToNumber
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_ColumnToLetter($iColumn)
	If Not StringRegExp($iColumn, "^[0-9]+$") Then Return SetError(1, 0, "")
	Local $sLetters, $iTemp
	While $iColumn
		$iTemp = Mod($iColumn, 26)
		If $iTemp = 0 Then $iTemp = 26
		$sLetters = Chr($iTemp + 64) & $sLetters
		$iColumn = ($iColumn - $iTemp) / 26
	WEnd
	Return $sLetters
EndFunc   ;==>_Excel_ColumnToLetter

; #FUNCTION# ====================================================================================================================
; Name ..........: _Excel_ColumnToNumber
; Description ...: Converts the column letter(s) to a number.
; Syntax ........: _Excel_ColumnToNumber($sColumn)
; Parameters ....: $sColumn - The column letter(s) which you want to turn into a number (e.g. "ZZ" to 702)
; Return values .: Success - Returns the column number
;                  Failure - Returns 0 and sets @error:
;                  |1 - $sColumn is not a valid string
; Author ........: Golfinhu
; Modified ......:
; Remarks .......:
; Related .......: _Excel_ColumnToLetter
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_ColumnToNumber($sColumn)
	$sColumn = StringUpper($sColumn)
	If Not StringRegExp($sColumn, "^[A-Z]+$") Then Return SetError(1, 0, 0)
	Local $sLetters = StringSplit($sColumn, "")
	Local $iNumber = 0
	Local $iLen = StringLen($sColumn)
	For $i = 1 To $sLetters[0]
		$iNumber += 26 ^ ($iLen - $i) * (Asc($sLetters[$i]) - 64)
	Next
	Return $iNumber
EndFunc   ;==>_Excel_ColumnToNumber

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_ConvertFormula
; Description ...: Converts cell references in a formula between A1 and R1C1 reference styles, relative and absolute reference type, or both.
; Syntax.........: _Excel_ConvertFormula($oExcel, $sFormula, $iFromStyle[, $iToStyle = Default[, $iToAbsolute = Default[, $vRelativeTo = Default]]])
; Parameters ....: $oExcel      - Excel application object
;                  $sFormula    - String containing the formula to convert
;                  $iFromStyle  - The reference style of the formula. Can be any of the XlReferenceStyle enumeration
;                  $iToStyle    - Optional: A XlReferenceStyle enumeration specifying the reference style to be returned. If omitted, the reference style isn't changed
;                  $iToAbsolute - Optional: A XlReferenceType which specifies the converted reference type. If this argument is omitted, the reference type isn't changed
;                  $vRelativeTo - Optional: A Range object or a A1 range that contains one cell. Relative references relate to this cell. If omitted A1 is used
; Return values .: Success - Returns the converted formula as a string
;                  Failure - Returns "" and sets @error
;                  |1 - $oExcel is not an object or not an application object
;                  |2 - $vRelativeTo is not an object or a valid A1 range
; Author ........: water
; Modified ......:
; Remarks .......: R1C1 references are language dependant.
;                  In English: "R10C5" (row 10 column 5), in German: "Z10S5" (Zeile 10 Spalte 5)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_ConvertFormula($oExcel, $sFormula, $iFromStyle, $iToStyle = Default, $iToAbsolute = Default, $vRelativeTo = Default)
	If Not IsObj($oExcel) Or ObjName($oExcel, 1) <> "_Application" Then Return SetError(1, 0, "")
	If $vRelativeTo <> Default Then
		If Not IsObj($vRelativeTo) Then $vRelativeTo = $oExcel.Range($vRelativeTo)
		If @error Or Not IsObj($vRelativeTo) Then Return SetError(2, 0, "")
	EndIf
	Local $sConverted = $oExcel.ConvertFormula($sFormula, $iFromStyle, $iToStyle, $iToAbsolute, $vRelativeTo)
	Return $sConverted
EndFunc   ;==>_Excel_ConvertFormula

; #FUNCTION# ====================================================================================================
; Name...........: _Excel_Export
; Description....: Exports a workbook, worksheet, chart or range as PDF or XPS.
; Syntax.........: _Excel_Export($oExcel, $vObject, $sFilename[, $iType = $xlTypePDF[, $iQuality = $xlQualityStandard[, $iIncludeProperties = True[, $iFrom = Default[, $iTo = Default[, $bOpenAfterPublish = Default]]]]]])
; Parameters ....: $oExcel             - Excel application object
;                  $vObject            - Workbook, worksheet, chart or range object to export as PDF or XPS. Range can be specified as A1 range too
;                  $sFilename          - Path/name of the exported file
;                  $iType              - Optional: Can be either $xlTypePDF or $xlTypeXPS of the XlFixedFormatType enumeration (default = $xlTypePDF)
;                  $iQuality           - Optional: Can be any of the XlFixedFormatQuality enumeration (default = $xlQualityStandard)
;                  $iIncludeProperties - Optional: True indicates that document properties should be included (default = True)
;                  $iFrom              - Optional: The page number at which to start publishing (default = keyword Default = start at the beginning)
;                  $iTo                - Optional: The page number at which to end publishing (default = keyword Default = end at the last page)
;                  $bOpenAfterPublish  - Optional: True displays the file in viewer after it is published (default = False)
; Return values .: Success - Returns the object of the exported range
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oExcel is not an object or not an application object
;                  |2 - $vObject is not an object or an invalid A1 range. @error is set to the COM error code
;                  |3 - $sFilename is empty
;                  |4 - Error exporting the object. @extended is set to the COM error code returned by the ExportAsFixedFormat method
; Author ........: water
; Modified ......:
; Remarks .......:
; Related .......: _Excel_Print
; Link ..........:
; Example .......: Yes
; ===============================================================================================================
Func _Excel_Export($oExcel, $vObject, $sFilename, $iType = Default, $iQuality = Default, $bIncludeProperties = Default, $iFrom = Default, $iTo = Default, $bOpenAfterPublish = Default)
	If Not IsObj($oExcel) Or ObjName($oExcel, 1) <> "_Application" Then Return SetError(1, 0, 0)
	If IsString($vObject) Then $vObject = $oExcel.Range($vObject)
	If @error Or Not IsObj($vObject) Then Return SetError(2, @error, 0)
	If $sFilename = "" Then Return SetError(3, 0, 0)
	If $iType = Default Then $iType = $xlTypePDF
	If $iQuality = Default Then $iQuality = $xlQualityStandard
	If $bIncludeProperties = Default Then $bIncludeProperties = True
	If $bOpenAfterPublish = Default Then $bOpenAfterPublish = False
	$vObject.ExportAsFixedFormat($iType, $sFilename, $iQuality, $bIncludeProperties, Default, $iFrom, $iTo, $bOpenAfterPublish)
	If @error Then Return SetError(4, @error, 0)
	Return $vObject
EndFunc   ;==>_Excel_Export

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_FilterGet
; Description ...: Get a list of set filters.
; Syntax.........: _Excel_FilterGet($oWorkbook[, $vWorksheet = Default])
; Parameters ....: $oWorkbook  - Excel workbook object
;                  $vWorksheet - Name, index or worksheet object to be filtered. If set to keyword Default the active sheet will be filtered
; Return values .: Success - Returns a two-dimensional zero based array with the following information:
;                  |0 - On if a filter is set for this column
;                  |1 - Number of areas (collection of ranges) the filtered column consists of
;                  |2 - Filter criteria 1. An array of strings is returned as a string separated by "|"
;                  |3 - Filter criteria 2. An array of strings is returned as a string separated by "|"
;                  |4 - An XlAutoFilterOperator value that represents the operator that associates the two filter criterias
;                  |5 - Range object for which the filters have been set
;                  |6 - Number of visible records in the filtered range (including the row with the filter arrow)
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $vWorksheet name or index are invalid or $vWorksheet is not a worksheet object. @extended is set to the COM error code
;                  |3 - No filters found
; Author ........: water
; Modified.......:
; Remarks .......:
; Related .......: _Excel_FilterSet
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_FilterGet($oWorkbook, $vWorksheet = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If Not IsObj($vWorksheet) Then
		If $vWorksheet = Default Then
			$vWorksheet = $oWorkbook.ActiveSheet
		Else
			$vWorksheet = $oWorkbook.WorkSheets.Item($vWorksheet)
		EndIf
		If @error Or Not IsObj($vWorksheet) Then Return SetError(2, @error, 0)
	ElseIf ObjName($vWorksheet, 1) <> "_Worksheet" Then
		Return SetError(2, @error, 0)
	EndIf
	Local $iIndex = 0, $iRecords, $iItems = $vWorksheet.AutoFilter.Filters.Count
	If $iItems > 0 Then
		Local $aFilters[$iItems][7]
		For $oFilter In $vWorksheet.AutoFilter.Filters
			$aFilters[$iIndex][0] = $oFilter.On
			$aFilters[$iIndex][1] = $oFilter.Count ; # of Areas for the filtered column
			$aFilters[$iIndex][2] = $oFilter.Criteria1
			If IsArray($oFilter.Criteria1) Then $aFilters[$iIndex][2] = _ArrayToString($aFilters[$iIndex][2])
			$aFilters[$iIndex][3] = $oFilter.Criteria2
			If IsArray($oFilter.Criteria2) Then $aFilters[$iIndex][3] = _ArrayToString($aFilters[$iIndex][3])
			$aFilters[$iIndex][4] = $oFilter.Operator
			$aFilters[$iIndex][5] = $oFilter.Parent.Range
			$iRecords = 0
			For $oArea In $oFilter.Parent.Range.SpecialCells($xlCellTypeVisible).Areas
				$iRecords = $iRecords + $oArea.Rows.Count
			Next
			$aFilters[$iIndex][6] = $iRecords
			$iIndex = $iIndex + 1
		Next
		Return $aFilters
	Else
		Return SetError(3, 0, "")
	EndIf
EndFunc   ;==>_Excel_FilterGet

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_FilterSet
; Description ...: Sets/unsets filter definitions and filters the range.
; Syntax.........: _Excel_FilterSet($oWorkbook, $vWorksheet, $vRange, $iField[, $sCriteria1 = Default[, $iOperator = Default[, $sCriteria2 = Default]]])
; Parameters ....: $oWorkbook  - Excel workbook object
;                  $vWorksheet - Name, index or worksheet object to be filtered. If set to keyword Default the active sheet will be filtered
;                  $vRange     - A range object or an A1 range to specify the columns to filter on.
;                  |Use keyword Default to filter on all used columns of the specified worksheet
;                  $iField     - Integer offset of the field on which you want to base the filter (the leftmost field is field one).
;                  |If set to 0 all Autofilters on the worksheet will be removed
;                  $sCriteria1 - Optional: The criteria (a string or an array of strings). Use "=" to find blank fields, or use "<>" to find nonblank fields.
;                  |If this argument is omitted, the criteria is All.
;                  |If Operator is xlTop10Items, Criteria1 specifies the number of items (for example, "10")
;                  $iOperator  - Optional: One of the constants of the XlAutoFilterOperator enumeration specifying the type of filter
;                  $sCriteria2 - Optional: The second criteria (a string). Used with Criteria1 and Operator to construct compound criteria
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $vWorksheet name or index are invalid or $vWorksheet is not a worksheet object. @extended is set to the COM error code
;                  |3 - $vRange is invalid. @extended is set to the COM error code
;                  |4 - Error returned by the Filter method. @extended is set to the COM error code
; Author ........: water
; Modified.......:
; Remarks .......: Dynamic filter:
;                  To filter data columns you set $iOperator to $xlFilterDynamic and $sCriteria1 to any of the XlDynamicFilterCriteria enumeration.
;                  See example 5 for details.
; Related .......: _Excel_FilterGet
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_FilterSet($oWorkbook, $vWorksheet, $vRange, $iField, $sCriteria1 = Default, $iOperator = Default, $sCriteria2 = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If Not IsObj($vWorksheet) Then
		If $vWorksheet = Default Then
			$vWorksheet = $oWorkbook.ActiveSheet
		Else
			$vWorksheet = $oWorkbook.WorkSheets.Item($vWorksheet)
		EndIf
		If @error Or Not IsObj($vWorksheet) Then Return SetError(2, @error, 0)
	ElseIf ObjName($vWorksheet, 1) <> "_Worksheet" Then
		Return SetError(2, @error, 0)
	EndIf
	If $vRange = Default Then
		$vRange = $vWorksheet.Usedrange
	ElseIf Not IsObj($vRange) Then
		$vRange = $vWorksheet.Range($vRange)
		If @error Or Not IsObj($vRange) Then Return SetError(3, @error, 0)
	EndIf
	If $iField <> 0 Then ; Set a new filter
		$vRange.AutoFilter($iField, $sCriteria1, $iOperator, $sCriteria2)
		If @error Then Return SetError(4, @error, 0)
		; If no filters remain then AutoFiltermode is set off
		If $vWorksheet.Filtermode = False Then $vWorksheet.AutoFilterMode = False
	Else ; remove all filters
		$vWorksheet.AutoFilterMode = False
	EndIf
	Return 1
EndFunc   ;==>_Excel_FilterSet

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_PictureAdd
; Description ...: Add a picture on the specified workbook and worksheet.
; Syntax.........: _Excel_PictureAdd($oWorkbook, $vWorksheet, $sFile, $vRangeOrLeft[, $iTop, [$iWidth = Default, [$iHeight = Default, [$bKeepRatio = True]]]])
; Parameters ....: $oWorkbook    - Excel workbook object
;                  $vWorksheet   - Name, index or worksheet object to be written to. If set to keyword Default the active sheet will be used
;                  $sFile        - Full path to picture file being added
;                  $vRangeOrLeft - Either an A1 range, a range object or an integer denoting the left position of the pictures upper left corner
;                                  If multi-cell range is specified $iWidth and $iHeight will be ignored and will use the range width/height.
;                                  See the Remarks section for details
;                  $iTop         - Optional: If $vRangeOrLeft is an integer then $iTop is the top position of the pictures upper left corner.
;                  $iWidth       - Optional: If specified, sets the width of the picture. If not specified, width will adjust automatically (default = Automatic)
;                                  See the Remarks section for details
;                  $iHeight      - Optional: If specified, sets the height of the picture. If not specified, height will adjust automatically (default = Automatic)
;                                  See the Remarks section for details
;                  $bKeepRatio   - Only used if $vRangeOrLeft is a multi-cell range (default = True)
;                  |True will maintain image aspect ratio while staying within the bounds of $vRangeOrLeft.
;                  |False will fill the $vRangeOrLeft regardless of original aspect ratio.
; Return values .: Success - Returns a Shape object that represents the new picture
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $vWorksheet name or index are invalid or $vWorksheet is not a worksheet object. @extended is set to the COM error code
;                  |3 - $vRangeOrLeft is invalid. @extended is set to the COM error code
;                  |4 - Error occurred when adding picture. @extended is set to the COM error code
;                  |5 - $sFile does not exist
; Author ........: DanWilli
; Modified.......: water
; Remarks .......: If $vRangeOrLeft is a multi cell range $iWidth and $iHeight will be ignored (to specify width/height not based on range width/height, specify a single cell $vRangeOrLeft).
;+
;                  If only one of $iWidth and $iHeight is specified, the other (set to default) will be scaled to maintain the original aspect ratio of the picture.
;                  If both $iWidth and $iHeight are specified, the picture will use the specified values regardless of original aspect ratio of the picture.
;                  If neither $iWidth nor $iHeight are specified, the picture will be auto sized to the size of the original picture.
;+
;                  $bKeepRatio will be ignored unless a multi cell range is specified (see Parameters for details)
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_PictureAdd($oWorkbook, $vWorksheet, $sFile, $vRangeOrLeft, $iTop = Default, $iWidth = Default, $iHeight = Default, $bKeepRatio = True)
	Local $Return, $iPosLeft, $iPosTop
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If Not FileExists($sFile) Then Return SetError(5, 0, 0)
	If Not IsObj($vWorksheet) Then
		If $vWorksheet = Default Then
			$vWorksheet = $oWorkbook.ActiveSheet
		Else
			$vWorksheet = $oWorkbook.WorkSheets.Item($vWorksheet)
		EndIf
		If @error Or Not IsObj($vWorksheet) Then Return SetError(2, @error, 0)
	ElseIf ObjName($vWorksheet, 1) <> "_Worksheet" Then
		Return SetError(2, @error, 0)
	EndIf
	If IsNumber($vRangeOrLeft) Then
		$iPosLeft = $vRangeOrLeft
		$iPosTop = $iTop
	Else
		If Not IsObj($vRangeOrLeft) Then
			$vRangeOrLeft = $vWorksheet.Range($vRangeOrLeft)
			If @error Or Not IsObj($vRangeOrLeft) Then Return SetError(3, @error, 0)
		EndIf
		$iPosLeft = $vRangeOrLeft.Left
		$iPosTop = $vRangeOrLeft.Top
	EndIf
	If IsNumber($vRangeOrLeft) Or ($vRangeOrLeft.Columns.Count = 1 And $vRangeOrLeft.Rows.Count = 1) Then
		If $iWidth = Default And $iHeight = Default Then
			$Return = $vWorksheet.Shapes.AddPicture($sFile, -1, -1, $iPosLeft, $iPosTop, 0, 0)
			If @error Then Return SetError(4, @error, 0)
			$Return.Scalewidth(1, -1, 0)
			$Return.Scaleheight(1, -1, 0)
		ElseIf $iWidth = Default Then
			$Return = $vWorksheet.Shapes.AddPicture($sFile, -1, -1, $iPosLeft, $iPosTop, 0, 0)
			If @error Then Return SetError(4, @error, 0)
			$Return.Visible = 0
			$Return.Scalewidth(1, -1, 0)
			$Return.Scaleheight(1, -1, 0)
			$Return.Scalewidth($iHeight / $Return.Height, -1, 0)
			$Return.Scaleheight($iHeight / $Return.Height, -1, 0)
			$Return.Visible = 1
		ElseIf $iHeight = Default Then
			$Return = $vWorksheet.Shapes.AddPicture($sFile, -1, -1, $iPosLeft, $iPosTop, 0, 0)
			If @error Then Return SetError(4, @error, 0)
			$Return.Visible = 0
			$Return.Scalewidth(1, -1, 0)
			$Return.Scaleheight(1, -1, 0)
			$Return.Scaleheight($iWidth / $Return.Width, -1, 0)
			$Return.Scalewidth($iWidth / $Return.Width, -1, 0)
			$Return.Visible = 1
		Else
			$Return = $vWorksheet.Shapes.AddPicture($sFile, -1, -1, $iPosLeft, $iPosTop, $iWidth, $iHeight)
			If @error Then Return SetError(4, @error, 0)
		EndIf
	Else
		If $bKeepRatio = True Then
			$Return = $vWorksheet.Shapes.AddPicture($sFile, -1, -1, $iPosLeft, $iPosTop, 0, 0)
			If @error Then Return SetError(4, @error, 0)
			$Return.Visible = 0
			$Return.Scalewidth(1, -1, 0)
			$Return.Scaleheight(1, -1, 0)
			Local $iRw = $vRangeOrLeft.Width / $Return.Width
			Local $iRh = $vRangeOrLeft.Height / $Return.Height
			If $iRw < $iRh Then
				$Return.Scaleheight($iRw, -1, 0)
				$Return.Scalewidth($iRw, -1, 0)
			Else
				$Return.Scaleheight($iRh, -1, 0)
				$Return.Scalewidth($iRh, -1, 0)
			EndIf
			$Return.Visible = 1
		Else
			$Return = $vWorksheet.Shapes.AddPicture($sFile, -1, -1, $iPosLeft, $iPosTop, $vRangeOrLeft.Width, $vRangeOrLeft.Height)
			If @error Then Return SetError(4, @error, 0)
		EndIf
	EndIf
	Return $Return
EndFunc   ;==>_Excel_PictureAdd

; #FUNCTION# ====================================================================================================
; Name...........: _Excel_Print
; Description....: Prints a workbook, worksheet, chart or range.
; Syntax.........: _Excel_Print($oExcel, $vObject[, $iCopies = Default[, $sPrinter = Default[, $bPreview = Default[, $iFrom = Default[, $iTo = Default[, $bPrintToFile = Default[, $bCollate = Default[, $sPrToFileName = ""]]]]]]]])
; Parameters ....: $oExcel        - Excel application object
;                  $vObject       - Workbook, worksheet, chart or range object to print. Range can be specified as A1 range too
;                  $iCopies       - Optional: Number of copies to print (default = keyword Default = 1)
;                  $sPrinter      - Optional: Name of the printer to be used. Defaults to active printer (default = keyword Default)
;                                   Example: \\Spoolservername\Printername
;                  $bPreview      - Optional: True to invoke print preview before printing (default = keyword Default = False)
;                  $iFrom         - Optional: Page number where to start printing (default = keyword Default = first page)
;                  $iTo           - Optional: Page number where to stop printing (default = keyword Default = last page)
;                  $bPrintToFile  - Optional: True to print to a file. See parameter $sPrToFileName (default = keyword Default = False)
;                  $bCollate      - Optional: True to collate multiple copies (default = keyword Default = False)
;                  $sPrToFileName - Optional: If $bPrintToFile is set to True, this argument specifies the name of the file you want to print to.
;                                   If not specified, the user is prompted to enter the file name (default = "")
; Return values .: Success - Returns the object of the printed range
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oExcel is not an object or not an application object
;                  |2 - $vObject is not an object or an invalid A1 range. @error is set to the COM error code
;                  |3 - Error printing the object. @extended is set to the COM error code
; Author ........: water
; Modified ......:
; Remarks .......:
; Related .......: _Excel_Export
; Link ..........:
; Example .......: Yes
; ===============================================================================================================
Func _Excel_Print($oExcel, $vObject, $iCopies = Default, $sPrinter = Default, $bPreview = Default, $iFrom = Default, $iTo = Default, $bPrintToFile = Default, $bCollate = Default, $sPrToFileName = "")
	If Not IsObj($oExcel) Or ObjName($oExcel, 1) <> "_Application" Then Return SetError(1, 0, 0)
	If IsString($vObject) Then $vObject = $oExcel.Range($vObject)
	If @error Or Not IsObj($vObject) Then Return SetError(2, @error, 0)
	$vObject.PrintOut($iFrom, $iTo, $iCopies, $bPreview, $sPrinter, $bPrintToFile, $bCollate, $sPrToFileName)
	If @error Then Return SetError(3, @error, 0)
	Return $vObject
EndFunc   ;==>_Excel_Print

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_RangeCopyPaste
; Description ...: Cuts or copies one or multiple cells, rows or columns to a range or from/to the clipboard.
; Syntax.........: _Excel_RangeCopyPaste($oWorksheet, $vSourceRange[, $vTargetRange = Default[, $bCut = False[, $iPaste = Default[, $iOperation = Default[, $bSkipBlanks = False[, $bTranspose = False]]]]]])
; Parameters ....: $oWorksheet   - Excel worksheet object
;                  $vSourceRange - Source range to copy/cut from. Can be a range object or an A1 range.
;                  |If set to keyword Default then the range will be copied from the clipboard.
;                  $vTargetRange - Optional: Target range to copy/cut to. Can be a range object or an A1 range.
;                  |If set to keyword Default then the range will be copied to the clipboard (default = keyword Default)
;                  $bCut         - Optional: If set to True the source range isn't copied but cut out (default = False)
;                  |This parameter is ignored when $vSourceRange is set to keyword Default.
;                  $iPaste       - Optional: The part of the range to be pasted from the clipboard (formulas, formats ...). Must be a value of the XlPasteType enumeration
;                  |(default = keyword Default)
;                  $iOperation   - Optional: The paste operation (add, divide, multiply ...). Must be a value of the XlPasteSpecialOperation enunmeration
;                  |(default = keyword Default)
;                  $bSkipBlanks  - Optional: If set to True blank cells from the clipboard will not be pasted into the target range (default = False)
;                  $bTranspose   - Optional: Set to True to transpose rows and columns when the range is pasted (default = False)
; Return values .: Success - Returns the object of the target range if $vTargetRange <> Default, else 1
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorksheet is not an object or not a worksheet object
;                  |2 - $vSourceRange is invalid. @extended is set to the COM error code
;                  |3 - $vTargetRange is invalid. @extended is set to the COM error code
;                  |4 - Error occurred when pasting cells. @extended is set to the COM error code
;                  |5 - Error occurred when cotting cells. @extended is set to the COM error code
;                  |6 - Error occurred when copying cells. @extended is set to the COM error code
;                  |7 - $vSourceRange and $vTargetRange can't be set to keyword Default at the same time
; Author ........: water
; Modified.......:
; Remarks .......: $vSourceRange and $vTargetRange can't be set to keyword Default at the same time.
;                  If $vSourceRange = Default then:
;                    * the range will be copied from the clipboard using the PasteSpecial method
;                    * $bCut will be ignored
;                    * $iPaste, $iOperation, $bSkipBlanks and $bTranspose will be honored
;                  If $vSourceRange and $vTargetRange are specified parameters $iPaste, $iOperation, $bSkipBlanks and $bTranspose are ignored
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_RangeCopyPaste($oWorksheet, $vSourceRange, $vTargetRange = Default, $bCut = Default, $iPaste = Default, $iOperation = Default, $bSkipBlanks = Default, $bTranspose = Default)
	If Not IsObj($oWorksheet) Or ObjName($oWorksheet, 1) <> "_Worksheet" Then Return SetError(1, 0, 0)
	If $bCut = Default Then $bCut = False
	If $vSourceRange = Default And $vTargetRange = Default Then Return SetError(7, 0, 0)
	If Not IsObj($vSourceRange) And $vSourceRange <> Default Then
		$vSourceRange = $oWorksheet.Range($vSourceRange)
		If @error Then Return SetError(2, @error, 0)
	EndIf
	If Not IsObj($vTargetRange) And $vTargetRange <> Default Then
		$vTargetRange = $oWorksheet.Range($vTargetRange)
		If @error Then Return SetError(3, @error, 0)
	EndIf
	If $vSourceRange = Default Then ; Paste from the clipboard
		If $bSkipBlanks = Default Then $bSkipBlanks = False
		If $bTranspose = Default Then $bTranspose = False
		$vTargetRange.PasteSpecial($iPaste, $iOperation, $bSkipBlanks, $bTranspose)
		If @error Then Return SetError(4, @error, 0)
	Else
		If $bCut Then
			$vSourceRange.Cut($vTargetRange)
			If @error Then Return SetError(5, @error, 0)
		Else
			$vSourceRange.Copy($vTargetRange)
			If @error Then Return SetError(6, @error, 0)
		EndIf
	EndIf
	If $vTargetRange <> Default Then
		Return $vTargetRange
	Else
		Return 1
	EndIf
EndFunc   ;==>_Excel_RangeCopyPaste

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_RangeDelete
; Description ...: Deletes one or multiple cells, rows or columns from the specified worksheet.
; Syntax.........: _Excel_RangeDelete($oWorksheet, $vRange[, $iShift = Default[, $iEntireRowCol = Default]])
; Parameters ....: $oWorksheet    - Excel worksheet object
;                  $vRange        - Range can be a range object, an A1 range (e.g. "A1:B2", "1:2" (row 1 to 2), "D:G" (columns D to G) etc.
;                  $iShift        - Optional: Specifies which way to shift the cells. Can be xlShiftToLeft or xlShiftUp of the XlDeleteShiftDirection enumeration.
;                  |If set to keyword Default, Excel decides based on the shape of the range (default = keyword Default)
;                  $iEntireRowCol - Optional: If set to 1 the entire row is deleted, if set to 2 the entire column is deleted (default = keyword Default = only delete specified range)
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorksheet is not an object or not an worksheet object
;                  |2 - $vRange is not a valid range. @extended is set to the COM error code
;                  |3 - Error occurred when deleting the range. @extended is set to the COM error code
; Author ........: water
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_RangeDelete($oWorksheet, $vRange, $iShift = Default, $iEntireRowCol = Default)
	If Not IsObj($oWorksheet) Or ObjName($oWorksheet, 1) <> "_Worksheet" Then Return SetError(1, 0, 0)
	If Not IsObj($vRange) Then
		$vRange = $oWorksheet.Range($vRange)
		If @error Then Return SetError(2, @error, 0)
	EndIf
	If $iEntireRowCol = 1 Then
		$vRange.EntireRow.Delete($iShift)
	ElseIf $iEntireRowCol = 2 Then
		$vRange.EntireColumn.Delete($iShift)
	Else
		$vRange.Delete($iShift)
	EndIf
	If @error Then Return SetError(3, @error, 0)
	Return 1
EndFunc   ;==>_Excel_RangeDelete

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_RangeFind
; Description ...: Finds matching cells in a range or workbook and returns an array with information about the found cells.
; Syntax.........: _Excel_RangeFind($oWorkbook, $sSearch[, $vRange = Default[, $iLookIn = $xlValues[, $iLookAt = $xlPart[, $bMatchcase = False]]]])
; Parameters ....: $oWorkbook  - Workbook object
;                  $sSearch    - Search string. Can be a string (wildcards - *?~ - can be used) or any Excel data type. See Remarks
;                  $vRange     - Optional: A range object, an A1 range (string) or keyword Default to search all sheets of the workbook (default = keyword Default)
;                  $iLookIn    - Optional: Specifies where to search. Can be any of the XLFindLookIn enumeration (default = $xlValues)
;                  $iLookAt    - Optional: Specifies whether the search text must match as a whole or any part. Can be any of the XLLookAt enumeration (default = $xlPart)
;                  $bMatchcase - Optional: True = case sensitive, False = case insensitive (default = False)
; Return values .: Success - two-dimensional zero based array with the following information:
;                  |0 - Name of the worksheet
;                  |1 - Name of the cell
;                  |2 - Address of the cell
;                  |3 - Value of the cell
;                  |4 - Formula of the cell
;                  |5 - Comment of the cell
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $sSearch is empty
;                  |3 - $vRange is invalid. @extended is set to the COM error code
;                  |4 - Error returned by the Find method. @extended is set to the COM error code
; Author ........: water
; Modified.......:
; Remarks .......: This function mimics the Ctrl+F functionality of Excel, except that it adds the cells comment to the result.
;                  Excel recognizes the following wildcards:
;                  ? (question mark)                - Any single character
;                  * (asterisk)                     - Any number of characters
;                  ~ (tilde) followed by ?, *, or ~ - A question mark, asterisk, or tilde
; Related .......: _Excel_RangeReplace
; Link ..........: http://office.microsoft.com/en-us/excel-help/wildcard-characters-HP005203612.aspx
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_RangeFind($oWorkbook, $sSearch, $vRange = Default, $iLookIn = Default, $iLookAt = Default, $bMatchcase = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If StringStripWS($sSearch, 3) = "" Then Return SetError(2, 0, 0)
	If $iLookIn = Default Then $iLookIn = $xlValues
	If $iLookAt = Default Then $iLookAt = $xlPart
	If $bMatchcase = Default Then $bMatchcase = False
	Local $oMatch, $sFirst = "", $bSearchWorkbook = False, $oSheet
	If $vRange = Default Then
		$bSearchWorkbook = True
		$oSheet = $oWorkbook.Sheets(1)
		$vRange = $oSheet.UsedRange
	ElseIf IsString($vRange) Then
		$vRange = $oWorkbook.Parent.Range($vRange)
		If @error Then Return SetError(3, @error, 0)
	EndIf
	Local $aResult[100][6], $iIndex = 0, $iIndexSheets = 1
	While 1
		$oMatch = $vRange.Find($sSearch, Default, $iLookIn, $iLookAt, Default, Default, $bMatchcase)
		If @error Then Return SetError(4, @error, 0)
		If IsObj($oMatch) Then
			$sFirst = $oMatch.Address
			While 1
				$aResult[$iIndex][0] = $oMatch.Worksheet.Name
				$aResult[$iIndex][1] = $oMatch.Name.Name
				$aResult[$iIndex][2] = $oMatch.Address
				$aResult[$iIndex][3] = $oMatch.Value
				$aResult[$iIndex][4] = $oMatch.Formula
				$aResult[$iIndex][5] = $oMatch.Comment.Text
				$oMatch = $vRange.Findnext($oMatch)
				If Not IsObj($oMatch) Or $sFirst = $oMatch.Address Then ExitLoop
				$iIndex = $iIndex + 1
				If Mod($iIndex, 100) = 0 Then ReDim $aResult[UBound($aResult, 1) + 100][6]
			WEnd
		EndIf
		If Not $bSearchWorkbook Then ExitLoop
		$iIndexSheets = $iIndexSheets + 1
		$sFirst = ""
		$oSheet = $oWorkbook.Sheets($iIndexSheets)
		If @error Then ExitLoop
		$vRange = $oSheet.UsedRange
	WEnd
	ReDim $aResult[$iIndex + 1][6]
	Return $aResult
EndFunc   ;==>_Excel_RangeFind

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_RangeInsert
; Description ...: Inserts one or multiple empty cells, rows or columns into the specified worksheet.
; Syntax.........: _Excel_RangeInsert($oWorksheet, $vRange[, $iShift = Default[, $iCopyOrigin = Default]])
; Parameters ....: $oWorksheet  - Excel worksheet object
;                  $vRange      - Range can be a range object, an A1 range (e.g. "A1:B2", "1:2" (row 1 to 2), ""D:G" (columns D to G) etc.
;                  $iShift      - Optional: Specifies which way to shift the cells. Can be xlShiftToRight or xlShiftDown of the XlInsertShiftDirection enumeration.
;                  |If set to keyword Default, Excel decides based on the shape of the range (default = keyword Default)
;                  $iCopyOrigin - Optional: Specifies which formatting option to copy. Can be any of the XlInsertFormatOrigin enumeration (default = keyword Default)
; Return values .: Success - Returns the range object containing the inserted cells, rows or columns
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorksheet is not an object or not a worksheet object
;                  |2 - $vRange is invalid. @extended is set to the COM error code
;                  |3 - Error occurred when inserting empty cells. @extended is set to the COM error code
; Author ........: water
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_RangeInsert($oWorksheet, $vRange, $iShift = Default, $iCopyOrigin = Default)
	If Not IsObj($oWorksheet) Or ObjName($oWorksheet, 1) <> "_Worksheet" Then Return SetError(1, 0, 0)
	If Not IsObj($vRange) Then
		$vRange = $oWorksheet.Range($vRange)
		If @error Then Return SetError(2, @error, 0)
	EndIf
	$vRange.Insert($iShift, $iCopyOrigin)
	If @error Then Return SetError(3, @error, 0)
	Return $vRange
EndFunc   ;==>_Excel_RangeInsert

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_RangeLinkAddRemove
; Description ...: Adds or removes a hyperlink to/from a specified range.
; Syntax.........: _Excel_RangeLinkAddRemove($oWorkbook, $vWorksheet, $vRange, $sAddress[, $sSubAddress = Default[, $sScreenTip = Default]])
; Parameters ....: $oWorkbook      - Excel workbook object
;                  $vWorksheet     - Name, index or worksheet object to be used. If set to keyword Default the active sheet will be used
;                  $vRange         - Either a range object or an A1 range to be set to a hyperlink
;                  $sAddress       - The address for the specified link. The address can be an E-mail address, an Internet
;                  +address or a file name. "" removes an existing hyperlink
;                  $sSubAddress    - Optional: The name of a location within the destination file, such as a bookmark, named range
;                  +or slide number (default = keyword Default = None)
;                  $sScreenTip     - Optional: The text that appears as a ScreenTip when the mouse pointer is positioned over the
;                  +specified hyperlink (default = keyword Default = Uses value of $sAddress)
; Return values .: Success - Returns a hyperlinks object when a link is set or 1 when a link is removed
;                  Failure - Returns 0 and sets @error
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $vWorksheet name or index are invalid or $vWorksheet is not a worksheet object. @extended is set to the COM error code
;                  |3 - $vRange is invalid. @extended is set to the COM error code
;                  |4 - Error occurred when adding/removing the hyperlink. @extended is set to the COM error code
; Author ........: water
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_RangeLinkAddRemove($oWorkbook, $vWorksheet, $vRange, $sAddress, $sSubAddress = Default, $sScreenTip = Default)
	Local $oLink
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If Not IsObj($vWorksheet) Then
		If $vWorksheet = Default Then
			$vWorksheet = $oWorkbook.ActiveSheet
		Else
			$vWorksheet = $oWorkbook.WorkSheets.Item($vWorksheet)
		EndIf
		If @error Or Not IsObj($vWorksheet) Then Return SetError(2, @error, 0)
	ElseIf ObjName($vWorksheet, 1) <> "_Worksheet" Then
		Return SetError(2, @error, 0)
	EndIf
	If Not IsObj($vRange) Then
		$vRange = $vWorksheet.Range($vRange)
		If @error Or Not IsObj($vRange) Then Return SetError(3, @error, 0)
	EndIf
	If $sAddress = "" Then
		$vRange.Hyperlinks.Delete()
		If @error Then Return SetError(4, @error, 0)
		Return 1
	Else
		$oLink = $vWorksheet.Hyperlinks.Add($vRange, $sAddress, $sSubAddress, $sScreenTip)
		If @error Then Return SetError(4, @error, 0)
		Return $oLink
	EndIf

EndFunc   ;==>_Excel_RangeLinkAddRemove

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_RangeRead
; Description ...: Reads the value, formula or displayed text from a cell or range of cells of the specified workbook and worksheet.
; Syntax.........: _Excel_RangeRead($oWorkbook[, $vWorksheet = Default[, $vRange = Default[, $iReturn = 1[, $bForceFunc = False]]]])
; Parameters ....: $oWorkbook  - Excel workbook object
;                  $vWorksheet - Optional: Name, index or worksheet object to be read. If set to keyword Default the active sheet will be used (default = keyword Default)
;                  $vRange     - Optional: Either a range object or an A1 range. If set to Default all used cells will be processed (default = keyword Default)
;                  $iReturn    - Optional: What to return from the specified cell:
;                  |1 - Value (default)
;                  |2 - Formula
;                  |3 - The displayed text
;                  $bForceFunc - True forces to use the _ArrayTranspose function instead of the Excel transpose method (default = False).
;                  |See the Remarks section for details
; Return values .: Success - Returns the data from the specified cell(s). A string for a cell, a zero-based array for a range of cells.
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $vWorksheet name or index are invalid or $vWorksheet is not a worksheet object. @extended is set to the COM error code
;                  |3 - $vRange is invalid. @extended is set to the COM error code
;                  |4 - Parameter $iReturn is invalid. Has to be > 1 and < 3
;                  |5 - Error occurred when reading data. @extended is set to the COM error code
;                  |6 - Maximum size of an AutoIt array exceeded (2^24 = 16,777,216 elements)
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike, water, GMK
; Remarks .......: The Excel transpose method has an undocumented limit on the number of cells or rows it can transpose (depends on the Excel version).
;                  The Excel transpose method doesn't support cells with more than 255 characters. Set $bForceFunc = True to bypass this limitation(s).
; Related .......: _Excel_RangeWrite
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_RangeRead($oWorkbook, $vWorksheet = Default, $vRange = Default, $iReturn = Default, $bForceFunc = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If Not IsObj($vWorksheet) Then
		If $vWorksheet = Default Then
			$vWorksheet = $oWorkbook.ActiveSheet
		Else
			$vWorksheet = $oWorkbook.WorkSheets.Item($vWorksheet)
		EndIf
		If @error Or Not IsObj($vWorksheet) Then Return SetError(2, @error, 0)
	ElseIf ObjName($vWorksheet, 1) <> "_Worksheet" Then
		Return SetError(2, @error, 0)
	EndIf
	If $vRange = Default Then
		$vRange = $vWorksheet.Usedrange
	ElseIf Not IsObj($vRange) Then
		$vRange = $vWorksheet.Range($vRange)
		If @error Or Not IsObj($vRange) Then Return SetError(3, @error, 0)
	EndIf
	If $iReturn = Default Then
		$iReturn = 1
	ElseIf $iReturn < 1 Or $iReturn > 3 Then
		Return SetError(4, 0, 0)
	EndIf
	If $bForceFunc = Default Then $bForceFunc = False
	Local $vResult
	; The max number of elements in an AutoIt array is limited to 2^24 = 16,777,216
	If $vRange.Columns.Count * $vRange.Rows.Count > 16777216 Then Return SetError(6, 0, 0)
	; Transpose has an undocumented limit on the number of cells or rows it can transpose. This limit increases with the Excel version
	; Limits:
	;   Excel 97   - 5461 cells
	;   Excel 2000 - 5461 cells
	;   Excel 2003 - ?
	;   Excel 2007 - 65536 rows ?
	;   Excel 2010 - ?
	; Example: If $oExcel.Version = 14 And $vRange.Columns.Count * $vRange.Rows.Count > 1000000 Then $bForceFunc = True
	If $bForceFunc Then
		If $iReturn = 1 Then
			$vResult = $vRange.Value
		ElseIf $iReturn = 2 Then
			$vResult = $vRange.Formula
		Else
			$vResult = $vRange.Text
		EndIf
		If @error Then Return SetError(5, @error, 0)
		; >>> Funktioniert das auch für eine 1D range (Spalte odder Zeile) oder muss ich selber transponieren?
		_ArrayTranspose($vResult)
	Else
		Local $oExcel = $oWorkbook.Parent
		If $iReturn = 1 Then
			$vResult = $oExcel.Transpose($vRange.Value)
		ElseIf $iReturn = 2 Then
			$vResult = $oExcel.Transpose($vRange.Formula)
		Else
			$vResult = $oExcel.Transpose($vRange.Text)
		EndIf
		If @error Then Return SetError(5, @error, 0)
	EndIf
	Return $vResult
EndFunc   ;==>_Excel_RangeRead

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_RangeReplace
; Description ...: Finds and replaces matching strings in a range or worksheet.
; Syntax.........: _Excel_RangeReplace($oWorkbook, $vWorksheet, $sSearch, $sReplace[, $vRange = Default[, $iLookAt = $xlPart[, $bMatchcase = False]]])
; Parameters ....: $oWorkbook  - Excel workbook object
;                  $vWorksheet - Name, index or worksheet object to be searched. If set to keyword Default the active sheet will be used
;                  $vRange     - A range object, an A1 range or keyword Default to search all cells in the specified worksheet
;                  $sSearch    - Search string
;                  $sReplace   - Replace string
;                  $iLookAt    - Optional: Specifies whether the search text must match as a whole or any part. Can be any of the XLLookAt enumeration (default = $xlPart)
;                  $bMatchcase - Optional: True = case sensitive, False = case insensitive (default = False)
; Return values .: Success - Returns the range object and sets @extended to 1 if cells have been changed
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $vWorksheet name or index are invalid or $vWorksheet is not a worksheet object. @extended is set to the COM error code
;                  |3 - $sSearch is empty
;                  |4 - $vRange is invalid. @extended is set to the COM error code
;                  |5 - Error returned by the Replace method. @extended is set to the COM error code
; Author ........: water
; Modified.......:
; Remarks .......:
; Related .......: _Excel_RangeFind
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_RangeReplace($oWorkbook, $vWorksheet, $vRange, $sSearch, $sReplace, $iLookAt = Default, $bMatchcase = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If Not IsObj($vWorksheet) Then
		If $vWorksheet = Default Then
			$vWorksheet = $oWorkbook.ActiveSheet
		Else
			$vWorksheet = $oWorkbook.WorkSheets.Item($vWorksheet)
		EndIf
		If @error Or Not IsObj($vWorksheet) Then Return SetError(2, @error, 0)
	ElseIf ObjName($vWorksheet, 1) <> "_Worksheet" Then
		Return SetError(2, @error, 0)
	EndIf
	If StringStripWS($sSearch, 3) = "" Then Return SetError(3, 0, 0)
	If $vRange = Default Then
		$vRange = $vWorksheet.Usedrange
	ElseIf Not IsObj($vRange) Then
		$vRange = $vWorksheet.Range($vRange)
		If @error Or Not IsObj($vRange) Then Return SetError(4, @error, 0)
	EndIf
	If $iLookAt = Default Then $iLookAt = $xlPart
	If $bMatchcase = Default Then $bMatchcase = False
	Local $bReplace
	$bReplace = $vRange.Replace($sSearch, $sReplace, $iLookAt, Default, $bMatchcase)
	If @error Then Return SetError(5, @error, 0)
	Return SetError(0, $bReplace, $vRange)
EndFunc   ;==>_Excel_RangeReplace

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_RangeSort
; Description ...: Sorts a cell range.
; Syntax.........: _Excel_RangeSort($oWorkbook, $vWorksheet, $vRange, $vKey1[, $iOrder1 = $xlAscending[, $iSortText = $xlSortNormal, [$iHeader = $xlNo[, $bMatchcase = False[, $iOrientation = $xlSortRows[, $sKey2 = Default[, $iOrder2 = Default[, $sKey3 = Default[, $iOrder3 = Default]]]]]]]]])
; Parameters ....: $oWorkbook    - Excel workbook object
;                  $vWorksheet   - Name, index or worksheet object to be sorted. If set to keyword Default the active sheet will be used
;                  $vRange       - A range object, an A1 range or keyword Default to sort the whole worksheet (default = keyword Default)
;                  $vKey1        - Specifies the first sort field, either as an A1 range or range object
;                  $iOrder1      - Optional: Determines the sort order. Can be any of the XlSortOrder enumeration (default = $xlAscending)
;                  $iSortText    - Optional: Specifies how to sort text in $vKey1, $sKey2 and $sKey3. Can be any of the XlSortDataOption enumeration (default = $xlSortNormal)
;                  $iHeader      - Optional: Specifies whether the first row contains header information. Can be any of the XlYesNoGuess enumeration (default = $xlNo)
;                  $bMatchCase   - Optional: True to perform a case-sensitive sort, False to perform non-case sensitive sort (default = False)
;                  $iOrientation - Optional: Specifies the sort orientation. Can be any of the XlSortOrientation enumeration (default = $xlSortColumns)
;                  $sKey2        - Optional: See $vKey1
;                  $iOrder2      - Optional: See $iOrder1
;                  $sKey3        - Optional: See $vKey1
;                  $iOrder3      - Optional: See $iOrder1
; Return values .: Success - Object of the sorted range
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $vWorksheet name or index are invalid or $vWorksheet is not a worksheet object. @extended is set to the COM error code
;                  |3 - $vRange is invalid. @extended is set to the COM error code
;                  |4 - $vKey1 is invalid. @extended is set to the COM error code
;                  |5 - $vKey2 is invalid. @extended is set to the COM error code
;                  |6 - $vKey3 is invalid. @extended is set to the COM error code
;                  |7 - Error returned by the Sort method. @extended is set to the COM error code
; Author ........: water
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_RangeSort($oWorkbook, $vWorksheet, $vRange, $vKey1, $iOrder1 = Default, $iSortText = Default, $iHeader = Default, _
		$bMatchcase = Default, $iOrientation = Default, $vKey2 = Default, $iOrder2 = Default, $vKey3 = Default, $iOrder3 = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If Not IsObj($vWorksheet) Then
		If $vWorksheet = Default Then
			$vWorksheet = $oWorkbook.ActiveSheet
		Else
			$vWorksheet = $oWorkbook.WorkSheets.Item($vWorksheet)
		EndIf
		If @error Or Not IsObj($vWorksheet) Then Return SetError(2, @error, 0)
	ElseIf ObjName($vWorksheet, 1) <> "_Worksheet" Then
		Return SetError(2, @error, 0)
	EndIf
	If $vRange = Default Then
		$vRange = $vWorksheet.Usedrange
	ElseIf Not IsObj($vRange) Then
		$vRange = $vWorksheet.Range($vRange)
		If @error Or Not IsObj($vRange) Then Return SetError(3, @error, 0)
	EndIf
	$vKey1 = $vWorksheet.Range($vKey1)
	If @error Or Not IsObj($vKey1) Then Return SetError(4, @error, 0)
	If $vKey2 <> Default Then
		$vKey2 = $vWorksheet.Range($vKey2)
		If @error Or Not IsObj($vKey2) Then Return SetError(5, @error, 0)
	EndIf
	If $vKey3 <> Default Then
		$vKey3 = $vWorksheet.Range($vKey3)
		If @error Or Not IsObj($vKey3) Then Return SetError(6, @error, 0)
	EndIf
	If $iHeader = Default Then $iHeader = $xlNo
	If $bMatchcase = Default Then $bMatchcase = False
	If $iOrientation = Default Then $iOrientation = $xlSortColumns
	If $iOrder1 = Default Then $iOrder1 = $xlAscending
	If $iSortText = Default Then $iSortText = $xlSortNormal
	If $iOrder2 = Default Then $iOrder2 = $xlAscending
	If $iOrder3 = Default Then $iOrder3 = $xlAscending
	If Int($oWorkbook.Parent.Version) < 112 Then ; Use Sort method for Excel 2003 and older
		$vRange.Sort($vKey1, $iOrder1, $vKey2, Default, $iOrder2, $vKey3, $iOrder3, $iHeader, Default, $bMatchcase, $iOrientation, Default, $iSortText, $iSortText, $iSortText)
	Else
		; http://www.autoitscript.com/forum/topic/136672-excel-multiple-column-sort/?hl=%2Bexcel+%2Bsort+%2Bcolumns#entry956163
		; http://msdn.microsoft.com/en-us/library/ff839572(v=office.14).aspx
		$vWorksheet.Sort.SortFields.Clear
		$vWorksheet.Sort.SortFields.Add($vKey1, $xlSortOnValues, $iOrder1)
		If $vKey2 <> Default Then $vWorksheet.Sort.SortFields.Add($vKey2, $xlSortOnValues, $iOrder2)
		If $vKey3 <> Default Then $vWorksheet.Sort.SortFields.Add($vKey3, $xlSortOnValues, $iOrder3)
		$vWorksheet.Sort.SetRange($vRange)
		$vWorksheet.Sort.Header = $iHeader
		$vWorksheet.Sort.MatchCase = $bMatchcase
		$vWorksheet.Sort.Orientation = $iOrientation
		$vWorksheet.Sort.Apply
	EndIf
	If @error Then Return SetError(7, @error, 0)
	Return $vRange
EndFunc   ;==>_Excel_RangeSort

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_RangeValidate
; Description ...: Adds data validation to the specified range.
; Syntax.........: _Excel_RangeValidate($oWorkbook, $vWorksheet, $vRange, $iType, $sFormula1[, $iOperator = Default[, $sFormula2 = Default[, $bIgnoreBlank = True[, $iAlertStyle = $xlValidAlertStop[, $sErrorMessage = Default[, $sInputMessage = Default]]]]]])
; Parameters ....: $oWorkbook     - Excel workbook object
;                  $vWorksheet    - Name, index or worksheet object. If set to keyword Default the active sheet will be used
;                  $vRange        - A range object, an A1 range or keyword Default to validate all cells in the specified worksheet
;                  $iType         - The validation type. Can be any of the XlDVType enumeration
;                  $sFormula1     - The first part of the data validation equation
;                  $iOperator     - Optional: The data validation operator. Can be any of the XlFormatConditionOperator enumeration (default = keyword Default)
;                  $sFormula2     - Optional: The second part of the data alidation when $iOperator is $xlBetween or $xlNotBetween. Otherwise it is ignored (default = keyword Default)
;                  $bIgnoreBlank  - Optional: If set to True, cell data is considered valid if the cell is blank (default = True)
;                  $iAlertStyle   - Optional: The validation alert style. Can be any of the XlDVAlertStyle enumeration (default = $xlValidAlertStop)
;                  $sErrorMessage - Optional: Message to be displayed in a MsgBox when invalid data has been entered (default = keyword Default)
;                  $sInputMessage - Optional: Message to be displayed in a Tooltip when you begin to enter data (default = keyword Default)
; Return values .: Success - Returns the range object
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $vWorksheet name or index are invalid or $vWorksheet is not a worksheet object. @extended is set to the COM error code
;                  |3 - $vRange is invalid. @extended is set to the COM error code
;                  |4 - Error returned by the Add method. @extended is set to the COM error code
; Author ........: water
; Modified.......:
; Remarks .......: Parameter $bDisplayAlerts for function _Excel_Open needs to be set to True to display $sErrorMessage.
;+
;                  If you want to validate against a list of values stored in another cell range ($iType = $xlValidateList) then
;                  $sFormula1 has to start with a "=" (e.g. "=C:C").
;+
;                  Before adding a new validation rule to a range the function deletes existing validation rules.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_RangeValidate($oWorkbook, $vWorksheet, $vRange, $iType, $sFormula1, $iOperator = Default, $sFormula2 = Default, $bIgnoreBlank = Default, $iAlertStyle = Default, $sErrorMessage = Default, $sInputMessage = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If Not IsObj($vWorksheet) Then
		If $vWorksheet = Default Then
			$vWorksheet = $oWorkbook.ActiveSheet
		Else
			$vWorksheet = $oWorkbook.WorkSheets.Item($vWorksheet)
		EndIf
		If @error Or Not IsObj($vWorksheet) Then Return SetError(2, @error, 0)
	ElseIf ObjName($vWorksheet, 1) <> "_Worksheet" Then
		Return SetError(2, @error, 0)
	EndIf
	If $vRange = Default Then
		$vRange = $vWorksheet.Usedrange
	ElseIf Not IsObj($vRange) Then
		$vRange = $vWorksheet.Range($vRange)
		If @error Or Not IsObj($vRange) Then Return SetError(3, @error, 0)
	EndIf
	If $bIgnoreBlank = Default Then $bIgnoreBlank = True
	If $iAlertStyle = Default Then $iAlertStyle = $xlValidAlertStop
	$vRange.Validation.Delete() ; delete existing validation before adding a new one
	$vRange.Validation.Add($iType, $iAlertStyle, $iOperator, $sFormula1, $sFormula2)
	If @error Then Return SetError(4, @error, 0)
	$vRange.Validation.IgnoreBlank = $bIgnoreBlank
	If $sInputMessage <> Default Then
		$vRange.Validation.InputMessage = $sInputMessage
		$vRange.Validation.ShowInput = True
	EndIf
	If $sErrorMessage <> Default Then
		$vRange.Validation.ErrorMessage = $sErrorMessage
		$vRange.Validation.ShowError = True
	EndIf
	Return $vRange
EndFunc   ;==>_Excel_RangeValidate

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_RangeWrite
; Description ...: Write value(s) or formula(s) to a cell or a cell range on the specified workbook and worksheet.
; Syntax.........: _Excel_RangeWrite($oWorkbook, $vWorksheet, $vValue[, $vRange = "A1"[, $bValue = True[, $bForceFunc = False]]])
; Parameters ....: $oWorkbook  - Excel workbook object
;                  $vWorksheet - Name, index or worksheet object to be written to. If set to keyword Default the active sheet will be used
;                  $vValue     - Can be a string, a 1D or 2D zero based array containing the data to be written to the worksheet
;                  $vRange     - Optional: Either an A1 range or a range object (default = "A1")
;                  $bValue     - Optional: If True the $vValue will be written to the value property. If False $vValue will be written to the formula property (default = True)
;                  $bForceFunc - True forces to use the _ArrayTranspose function instead of the Excel transpose method (default = False).
;                  |See the Remarks section for details
; Return values .: Success - Returns the object of the range the data has been written to
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $vWorksheet name or index are invalid or $vWorksheet is not a worksheet object. @extended is set to the COM error code
;                  |3 - $vRange is invalid. @extended is set to the COM error code
;                  |4 - Error occurred when writing data. @extended is set to the COM error code
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike and PsaltyDS 01/04/08 - 2D version _Excel_RangeWrite(), Golfinhu (improved speed), water
; Remarks .......: If $vRange is a single cell and $vValue is an array then $vRange is extended to hold the full array.
;                  This "expanded" range is then returned by the function.
;                  If $vRange is not a single cell and $vValue is an array and $vValue > $vRange then the array gets truncated.
;                  If $vRange is not a single cell and $vValue is an array and $vValue < $vRange then the exceeding cells get #NV.
;+
;                  The Excel transpose method has an undocumented limit on the number of cells or rows it can transpose (dependant on the Excel version).
;                  The Excel transpose method doesn't support cells with more than 255 characters. Set $bForceFunc = True to bypass this limitation(s).
; Related .......: _Excel_RangeRead
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_RangeWrite($oWorkbook, $vWorksheet, $vValue, $vRange = Default, $bValue = Default, $bForceFunc = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	If Not IsObj($vWorksheet) Then
		If $vWorksheet = Default Then
			$vWorksheet = $oWorkbook.ActiveSheet
		Else
			$vWorksheet = $oWorkbook.WorkSheets.Item($vWorksheet)
		EndIf
		If @error Or Not IsObj($vWorksheet) Then Return SetError(2, @error, 0)
	ElseIf ObjName($vWorksheet, 1) <> "_Worksheet" Then
		Return SetError(2, @error, 0)
	EndIf
	If $vRange = Default Then $vRange = "A1"
	If $bValue = Default Then $bValue = True
	If $bForceFunc = Default Then $bForceFunc = False
	If Not IsObj($vRange) Then
		$vRange = $vWorksheet.Range($vRange)
		If @error Or Not IsObj($vRange) Then Return SetError(3, @error, 0)
	EndIf
	If Not IsArray($vValue) Then
		If $bValue Then
			$vRange.Value = $vValue
		Else
			$vRange.Formula = $vValue
		EndIf
		If @error Then Return SetError(4, @error, 0)
	Else
		If $vRange.Columns.Count = 1 And $vRange.Rows.Count = 1 Then
			If UBound($vValue, 0) = 1 Then
				$vRange = $vRange.Resize(UBound($vValue, 1), 1)
			Else
				$vRange = $vRange.Resize(UBound($vValue, 1), UBound($vValue, 2))
			EndIf
		EndIf
		; ==========================
		; Transpose has an undocument limit on the number of cells or rows it can transpose. This limit increases with the Excel version
		; Limits:
		;   Excel 97   - 5461 cells
		;   Excel 2000 - 5461 cells
		;   Excel 2003 - ?
		;   Excel 2007 - 65536 rows ?
		;   Excel 2010 - ?
		; Example: If $oExcel.Version = 14 And $vRange.Columns.Count * $vRange.Rows.Count > 1000000 Then $bForceFunc = True
		; >>> Transpose macht aber keinen Sinn für eine Variable! Prüfen
		If $bForceFunc Then
			If UBound($vValue, 0) = 1 Then ; _ArrayTranspose only works for 2D arrays so we do it ourselfs for 1D arrays
				Local $aTemp[1][UBound($vValue, 1)]
				For $z = 0 To UBound($vValue, 1) - 1
					$aTemp[0][$z] = $vValue[$z]
				Next
				$vValue = $aTemp
			Else
				_ArrayTranspose($vValue)
			EndIf
			If $bValue Then
				$vRange.Value = $vValue
			Else
				$vRange.Formula = $vValue
			EndIf
			If @error Then Return SetError(4, @error, 0)
		Else
			Local $oExcel = $oWorkbook.Parent
			If $bValue Then
				$vRange.Value = $oExcel.Transpose($vValue)
			Else
				$vRange.Formula = $oExcel.Transpose($vValue)
			EndIf
			If @error Then Return SetError(4, @error, 0)
		EndIf
	EndIf
	Return $vRange
EndFunc   ;==>_Excel_RangeWrite

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_SheetAdd
; Description ...: Add new sheet(s) to a workbook and set their names.
; Syntax.........: _Excel_SheetAddNew($oWorkbook[, $vSheet = Default[, $bBefore = True[, $iCount = 1[, $sName = ""]]]])
; Parameters ....: $oWorkbook - A workbook object
;                  $vSheet    - Optional: Object, index or name of the sheet before/after which the new sheet is inserted.
;                  |-1 = insert before/after the last worksheet (default = keyword Default = active worksheet)
;                  $bBefore   - Optional: The new sheet will be inserted before $vSheet if True, after $vSheet if False (default = True)
;                  $iCount    - Optional: Number of worksheets to be inserted (default = 1)
;                  $sName     - Optional: Name(s) of the sheet(s) to create (default = "" = follows standard Excel new sheet convention).
;                  |When $iCount > 1 multiple names can be provided separated by | (pipe character). Sheets are named from left to right
; Return values .: Success - Returns object of the (first) added worksheet
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - $vSheet is invalid. Name or index does not exist. @extended is set to the COM error code
;                  |3 - Specified sheet already exists. @extended is set to the number of the name in $sName
;                  |4 - Error occurred when adding the sheet. @extended is set to the COM error code
;                  |5 - Error occurred when setting the name of the new sheet(s). @extended is set to the COM error code
; Author ........: water
; Modified.......:
; Remarks .......:
; Related .......: _Excel_SheetDelete
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_SheetAdd($oWorkbook, $vSheet = Default, $bBefore = Default, $iCount = Default, $sName = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	Local $bInsertAtEnd = False, $iStartSheet, $oBefore = Default, $oAfter = Default
	If $iCount = Default Then $iCount = 1
	If $bBefore = Default Then $bBefore = True
	If $vSheet = Default Then
		$vSheet = $oWorkbook.ActiveSheet
	ElseIf Not IsObj($vSheet) Then
		If $vSheet = -1 Then
			$vSheet = $oWorkbook.WorkSheets.Item($oWorkbook.WorkSheets.Count)
		Else
			$vSheet = $oWorkbook.WorkSheets.Item($vSheet)
		EndIf
		If @error Then Return SetError(2, @error, 0)
		If $vSheet.Index = $oWorkbook.WorkSheets.Count And $bBefore = False Then $bInsertAtEnd = True
	EndIf
	If $sName <> Default Then
		Local $aName = StringSplit($sName, "|")
		SetError(0) ; Reset @error if the separator was not found
		If $aName[1] <> "" Then ; Name provided
			For $iIndex1 = 1 To $aName[0]
				For $iIndex2 = 1 To $oWorkbook.WorkSheets.Count
					If $oWorkbook.WorkSheets($iIndex2).Name = $aName[$iIndex1] Then Return SetError(3, $iIndex1, 0)
				Next
			Next
		Else
			$sName = Default ; No name provided
		EndIf
	EndIf
	If $bBefore Then
		$oBefore = $vSheet
	Else
		$oAfter = $vSheet
	EndIf
	Local $oSheet = $oWorkbook.WorkSheets.Add($oBefore, $oAfter, $iCount)
	If @error Then Return SetError(4, @error, 0)
	If $sName <> Default Then
		; If sheets are added after the last sheet then the returned sheet is the rightmost, else it is the leftmost
		If $bInsertAtEnd = True Then
			$iStartSheet = $oSheet.Index - $iCount + 1
		Else
			$iStartSheet = $oSheet.Index
		EndIf
		$iIndex2 = 1
		For $iSheet = $iStartSheet To $iStartSheet + $iCount - 1
			If $aName[$iIndex2] <> "" Then $oWorkbook.WorkSheets($iSheet).Name = $aName[$iIndex2]
			If @error Then Return SetError(5, @error, 0)
			$iIndex2 += 1
			If $iIndex2 > $aName[0] Then ExitLoop
		Next
	EndIf
	Return $oSheet
EndFunc   ;==>_Excel_SheetAdd

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_SheetCopyMove
; Description ...: Copy or move the specified sheet before or after a specified sheet in the same or a different workbook
; Syntax.........: _Excel_SheetCopyMove($oSourceBook[, $vSourceSheet = Default[, $oTargetBook = $oSourceBook[, $vTargetSheet = 1[, $bBefore = True[, $bCopy = True]]]]])
; Parameters ....: $oSourceBook  - Object of the source workbook where the sheet should be copied/moved from
;                  $vSourceSheet - Optional: Name, index or object of the sheet to copy/move (default = keyword Default = active sheet)
;                  $oTargetBook  - Optional: Object of the target workbook where the sheet should be copied/moved to (default = keyword Default = $oSourceBook)
;                  $vTargetSheet - Optional: The copied/moved sheet will be placed before or after this sheet (name, index or object) (default = keyword Default = first sheet)
;                  $bBefore      - Optional: The copied/moved sheet will be placed before $vTargetSheet if True, after it if False (default = True)
;                  $bCopy        - Optional: Copy the specified sheet if True, move the sheet if False (default = True)
; Return values .: Success - Returns object of the copied/moved sheet
;                  Failure - Returns 0 and sets @error:
;                  |2 - $oSourceBook is not an object or not a workbook object
;                  |3 - $oTargetBook is not an object or not a workbook object
;                  |4 - Specified source sheet does not exist. Name or index is invalid. @extended is set to the COM error code
;                  |5 - Specified target sheet does not exist. Name or index is invalid. @extended is set to the COM error code
;                  |6 - Error occurred when copying/moving the sheet. @extended is set to the COM error code
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike, water
; Remarks .......: None
; Related .......: _Excel_SheetDelete
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_SheetCopyMove($oSourceBook, $vSourceSheet = Default, $oTargetBook = Default, $vTargetSheet = Default, $bBefore = Default, $bCopy = Default)
	Local $vBefore = Default, $vAfter = Default
	If Not IsObj($oSourceBook) Or ObjName($oSourceBook, 1) <> "_Workbook" Then Return SetError(2, 0, 0)
	If $vSourceSheet = Default Then $vSourceSheet = $oSourceBook.ActiveSheet
	If $oTargetBook = Default Then $oTargetBook = $oSourceBook
	If Not IsObj($oTargetBook) Or ObjName($oTargetBook, 1) <> "_Workbook" Then Return SetError(3, 0, 0)
	If $vTargetSheet = Default Then $vTargetSheet = 1
	If $bBefore = Default Then $bBefore = True
	If $bCopy = Default Then $bCopy = True
	If Not IsObj($vSourceSheet) Then
		$vSourceSheet = $oSourceBook.Sheets($vSourceSheet)
		If @error Or Not IsObj($vSourceSheet) Then SetError(4, @error, 0)
	EndIf
	If Not IsObj($vTargetSheet) Then
		$vTargetSheet = $oTargetBook.Sheets($vTargetSheet)
		If @error Or Not IsObj($vTargetSheet) Then SetError(5, @error, 0)
	EndIf
	If $bBefore Then
		$vBefore = $vTargetSheet
	Else
		$vAfter = $vTargetSheet
	EndIf
	If $bCopy Then
		$vSourceSheet.Copy($vBefore, $vAfter)
	Else
		$vSourceSheet.Move($vBefore, $vAfter)
	EndIf
	If @error Then Return SetError(6, 0, 0)
	If $bBefore Then
		Return $oTargetBook.Sheets($vTargetSheet.Index - 1)
	Else
		Return $oTargetBook.Sheets($vTargetSheet.Index + 1)
	EndIf
EndFunc   ;==>_Excel_SheetCopyMove

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_SheetDelete
; Description ...: Delete the specified sheet by string name or by number.
; Syntax.........: _Excel_SheetDelete($oWorkbook[, $vSheet = Default])
; Parameters ....: $oWorkbook - A workbook object
;                  $vSheet    - Optional: The sheet to delete, either by string name or by number (default = keyword Default = active Worksheet)
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
;                  |2 - Specified sheet does not exist. @extended is set to the COM error code
;                  |3 - Error occurred when deleting the sheet. @extended is set to the COM error code
; Author ........: water
; Modified.......:
; Remarks .......: None
; Related .......: _Excel_SheetAdd
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_SheetDelete($oWorkbook, $vSheet = Default)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	Local $oSheet
	If $vSheet = Default Then
		$oSheet = $oWorkbook.ActiveSheet
	Else
		$oSheet = $oWorkbook.WorkSheets.Item($vSheet)
	EndIf
	If @error Then Return SetError(2, @error, 0)
	$oSheet.Delete()
	If @error Then Return SetError(3, @error, 0)
	Return 1
EndFunc   ;==>_Excel_SheetDelete

; #FUNCTION# ====================================================================================================================
; Name...........: _Excel_SheetList
; Description ...: Returns a list of all sheets in the specified workbook.
; Syntax.........: _Excel_SheetList($oWorkbook)
; Parameters ....: $oWorkbook - A workbook object
; Return values .: Success - Returns a two-dimensional zero based array with the following information:
;                  |0 - Name of the worksheet
;                  |1 - Object of the worksheet
;                  Failure - Returns 0 and sets @error:
;                  |1 - $oWorkbook is not an object or not a workbook object
; Author ........: SEO <locodarwin at yahoo dot com>
; Modified.......: litlmike, water
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Excel_SheetList($oWorkbook)
	If Not IsObj($oWorkbook) Or ObjName($oWorkbook, 1) <> "_Workbook" Then Return SetError(1, 0, 0)
	Local $iSheetCount = $oWorkbook.Sheets.Count
	Local $aSheets[$iSheetCount][2]
	For $iIndex = 0 To $iSheetCount - 1
		$aSheets[$iIndex][0] = $oWorkbook.Sheets($iIndex + 1).Name
		$aSheets[$iIndex][1] = $oWorkbook.Sheets($iIndex + 1)
	Next
	Return $aSheets
EndFunc   ;==>_Excel_SheetList

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __Excel_CloseOnQuit
; Description ...: Sets or returns the state used to determine if the Excel instance can be closed by _Excel_Close.
; Syntax.........: __Excel_CloseOnQuit($oExcel[, $bNewState = Default])
; Parameters ....: $oExcel    - Object of the Excel instance to be processed
;                  $bNewState - Optional: The following values can be passed:
;                  |True if the Excel instance was started by function _Excel_Open and can be closed by _Excel_Close
;                  |False if the Excel instance was just closed by _Excel_Close and needs to be removed from the table
;                  |Default returns the current state (True, False) for the specified Excel instance
; Return values .: Success - Current state. Can be either True (Instance will be closed by _Excel_Close) or False (Instance will not be closed by _Excel_Close)
; Author ........: Valik
; Modified ......: water
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Excel_CloseOnQuit($oExcel, $bNewState = Default)
	Static $bState[101] = [0]
	If $bNewState = True Then ; Add new Excel instance to the table. Will be closed on _Excel_Close
		For $i = 1 To $bState[0]
			If Not IsObj($bState[$i]) Or $bState[$i] = $oExcel Then ; Empty cell found or instance already stored
				$bState[$i] = $oExcel
				Return True
			EndIf
		Next
		$bState[0] = $bState[0] + 1 ; No empty cell found and instance not already in table. Create a new entry at the end of the table
		$bState[$bState[0]] = $oExcel
		Return True
	Else
		For $i = 1 To $bState[0]
			If $bState[$i] = $oExcel Then ; Excel instance found
				If $bNewState = False Then ; Remove Excel instance from table (set value to zero)
					$bState[$i] = 0
					Return False
				Else
					Return True ; Excel instance found. Will be closed on _Excel_Close
				EndIf
			EndIf
		Next
	EndIf
	Return False ; Excel instance not found. Will not be closed by _Excel_Close
EndFunc   ;==>__Excel_CloseOnQuit
