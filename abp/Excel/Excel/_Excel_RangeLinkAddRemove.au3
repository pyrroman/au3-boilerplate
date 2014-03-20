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