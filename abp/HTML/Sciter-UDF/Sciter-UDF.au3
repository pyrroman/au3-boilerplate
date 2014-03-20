#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <Sciter-Constants.au3>
#include-once

; Version 0.2

Global $aHLelementsfound = 0
Global $Sciterdll = 0
Global $SciterRef = 0
Global $HandleWindowsAttachEvent = 0
Global $SciterEvHandler = 0
Global $aHLDOM_error[7]
Global $sciterhtml
$aHLDOM_error[0] = "function completed successfully"
$aHLDOM_error[1] = "invalid HWND"
$aHLDOM_error[2] = "invalid HELEMENT"
$aHLDOM_error[3] = "attempt to use HELEMENT which is not marked by Sciter_UseElement()"
$aHLDOM_error[4] = "parameter is invalid, e.g. pointer is null"
$aHLDOM_error[5] = "operation failed, e.g. invalid html in SciterSetElementHtml()"
$aHLDOM_error[6] = "Dllcall error"

; #FUNCTION# ====================================================================================================
; Name...........:	_StStartup
; Description....:	Initialize Sciter
; Syntax.........:	_StStartup($dll = "Sciter-x.dll")
; Parameters.....:	$dll - Path to sciter DLL [Optional]
;
; Return values..:	Success - 1
;					Failure - 0
; Remarks........:
; ===============================================================================================================
Func _StStartup($dll = "Sciter-x.dll")
	$SciterRef += 1
	If $SciterRef > 1 Then Return 1
	$Sciterdll = DllOpen($dll)
	If $Sciterdll = -1 Then Return SetError(1, 0, 0)
	Return 1
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........:	_StCreate
; Description....:	Create Sciter Windows
; Syntax.........:	_StCreate($x = 0, $y = 0, $w = 100, $h = 50, $task = 0, $title = "Form")
; Parameters.....:	$x - [Optional]
;					$y - [Optional]
;					$w - [Optional]
;					$h - [Optional]
;					$task - set to 1 for windows appair in taskbar.
;					$title - title of window
;
; Return values..:	Success - Sciter window handle.
;					Failure - 0
; Remarks........:
; ===============================================================================================================
Func _StCreate($x = 0, $y = 0, $w = 100, $h = 50, $task = 0, $title = "Form")
	If $x = -1 Then $x = @DesktopWidth / 2 - ($w/2)
	If $y = -1 Then $y = @DesktopHeight / 2 - ($h/2)
	$result = DllCall($Sciterdll, "str", "SciterClassName")
	If @error Then Return 0
	$ClassName = $result[0]
	If $task = 0 Then
		$SciterHwnd = _WinAPI_CreateWindowEx(BitOR($WS_EX_LAYERED,$WS_EX_TOOLWINDOW ), $ClassName, $title, BitOR($WS_VISIBLE,$WS_popup,$WS_CLIPCHILDREN), $x, $y, $w, $h,0)
	Else
		$SciterHwnd = _WinAPI_CreateWindowEx($WS_EX_LAYERED, $ClassName, $title, BitOR($WS_VISIBLE,$WS_popup,$WS_CLIPCHILDREN), $x, $y, $w, $h,0)
	EndIf
	Return $SciterHwnd
EndFunc   ;==>_StCreate

; #FUNCTION# ====================================================================================================
; Name...........:	_StIncGui
; Description....:	Create Sciter Windows as child of $ParentGui
; Syntax.........:	_StIncGui($ParentGui, $x = 0, $y = 0, $w = 100, $h = 50)
; Parameters.....:	$ParentGui - Handle of parent Gui
;					          $x         - [Optional]
;					          $y         - [Optional]
;					          $w         - [Optional]
;					          $h         - [Optional]
;
; Return values..:	Success - Sciter window handle.
;					Failure - 0
; Remarks........:
; ===============================================================================================================
Func _StIncGui($ParentGui, $x = 0, $y = 0, $w = 100, $h = 50)
	$result = DllCall($Sciterdll, "wstr", "SciterClassNameW")
	If @error Then Return 0
	$ClassName = $result[0]
	$SciterHwnd = _WinAPI_CreateWindowEx(0, $ClassName, "", BitOR($WS_CHILD, $WS_VISIBLE,$WS_CLIPCHILDREN), $x, $y, $w, $h,$ParentGui)
	Return $SciterHwnd
EndFunc   ;==>_StIncGui

; #FUNCTION# ====================================================================================================
; Name...........:	_StLoadFile
; Description....:	Load HTML file.
; Syntax.........:	_StLoadFile($STHwnd, $file)
; Parameters.....:	$STHwnd - Sciter window handle.
;					$file - File name of an HTML file.
;
; Return values..:	Success - 1
;					Failure - 0
; Remarks........:
; ===============================================================================================================
Func _StLoadFile($STHwnd, $file)
	$result = DllCall($Sciterdll, "BOOL", "SciterLoadFile", "HWND", $STHwnd, "wstr", $file)
	If @error Then Return 0
	Return $result[0]
EndFunc   ;==>_StLoadFile

; #FUNCTION# ====================================================================================================
; Name...........:	_StLoadHtml
; Description....:	Load HTML from memory.
; Syntax.........:	_StLoadHtml($STHwnd, $String)
; Parameters.....:	$STHwnd - Sciter window handle.
;					$String - HTML to load.
;
; Return values..:	Success - 1
;					Failure - 0
; Remarks........:
; ===============================================================================================================
Func _StLoadHtml($STHwnd, $String)
	$StringSize = StringLen($String)
	$result = DllCall($Sciterdll, "BOOL", "SciterLoadHtml", "HWND", $STHwnd, "str", $String, "UINT", $StringSize, "str", @ScriptDir)
	If @error Then Return SetError(@error,0,0)
	Return 1
EndFunc   ;==>_StLoadHtml

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetRootElement
; Description....:	Get root DOM element of HTML document.
; Syntax.........:	_StGetRootElement($STHwnd)
; Parameters.....:	$STHwnd - Sciter window handle.
;
; Return values..:	Success - Return root element.
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........: Root DOM object is always a 'HTML' element of the document.
; ===============================================================================================================
Func _StGetRootElement($STHwnd)
	$result = DllCall($Sciterdll, "int", "SciterGetRootElement", "HWND", $STHwnd, "ptr*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[2]
EndFunc   ;==>_StGetRootElement

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetElementHtml
; Description....:	Get Html of the element.
; Syntax.........:	_StGetElementHtml($el, $outer = 1)
; Parameters.....:	$el - DOM element handle
;					$outer - BOOL, if TRUE will return outer HTML otherwise inner. [Optional]
;
; Return values..:	Success - Return Html of element
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetElementHtml($el, $outer = 1)
	$sciterhtml = ""
	$LPCBYTE_RECEIVER = DllCallbackRegister("SciterByteCallback", "ptr", "str;UINT;ptr")
	$result = DllCall($Sciterdll, "int", "SciterGetElementHtmlCB", "ptr", $el, "BOOL", $outer, "ptr", DllCallbackGetPtr($LPCBYTE_RECEIVER), "ptr", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	DllCallbackFree($LPCBYTE_RECEIVER)
   	Return $sciterhtml
EndFunc
Func SciterByteCallback($byte,$num,$prm)
	$sciterhtml = BinaryToString($byte,4)
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........:	_StSetElementHtml
; Description....:	Set inner or outer html of the element.
; Syntax.........:	_StSetElementHtml($el, $html, $where)
; Parameters.....:	$el - DOM element handle
;					$html - string containing html text
;					$where - possible values are:
;							0: replace content of the element
;							1: insert html before first child of the element
;							2: insert html after last child of the element
;							3: replace element by html, a.k.a. element.outerHtml = "something"
;							4: insert html before the element
;							5: insert html after the element
;
; Return values..:	Success - Return 1
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:	Value 3,4 and 5 for $where do not work for inline elements like
; ===============================================================================================================
Func _StSetElementHtml($el, $html, $where = 0)
	$htmllen = StringLen($html)
	$result = DllCall($Sciterdll, "int", "SciterSetElementHtml", "ptr", $el, "str", $html, "DWORD", $htmllen, "UINT", $where)
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return 1
EndFunc   ;==>_StSetElementHtml

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetElementText
; Description....:	Get inner text of the element
; Syntax.........:	_StGetElementText($el)
; Parameters.....:	$el - DOM element handle
;
; Return values..:	Success - return text element
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetElementText($el)
	$sciterhtml = ""
	$LPCWSTR_RECEIVER = DllCallbackRegister("SciterWSTRCallback", "ptr", "wstr;UINT;ptr")
	$result = DllCall($Sciterdll, "int", "SciterGetElementTextCB", "ptr", $el, "ptr", DllCallbackGetPtr($LPCWSTR_RECEIVER), "ptr", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	DllCallbackFree($LPCWSTR_RECEIVER)
   	Return $sciterhtml
EndFunc
Func SciterWSTRCallback($wstr,$num,$prm)
	$sciterhtml = $wstr
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........:	_StSetElementText
; Description....:	Set inner text of the element.
; Syntax.........:	_StSetElementText($el, $String)
; Parameters.....:	$el - DOM element handle
;					$String - Innertext
;
; Return values..:	Success - Return 1
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StSetElementText($el, $String)
	$len = StringLen($String)
	$result = DllCall($Sciterdll, "int", "SciterSetElementText", "ptr", $el, "wstr", $String, "UINT", $len)
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return 1
EndFunc   ;==>_StSetElementText

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetChildrenCount
; Description....:	Get number of child elements.
; Syntax.........:	_StGetChildrenCount($el)
; Parameters.....:	$el - DOM element handle which child elements you need to count
;
; Return values..:	Success - Return number of child elements
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetChildrenCount($el)
	$result = DllCall($Sciterdll, "int", "SciterGetChildrenCount", "ptr", $el, "UINT*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[2]
EndFunc   ;==>_StGetChildrenCount

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetFocusElement
; Description....:	Get focused DOM element of HTML document.
; Syntax.........:	_StGetFocusElement($hwnd)
; Parameters.....:	$hwnd - Sciter windows handle
;
; Return values..:	Success - Return focus element or 0 if no focus
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:	To set focus on element use _StSetElementState($el, $STATE_FOCUS,0)
; ===============================================================================================================
Func _StGetFocusElement($hwnd)
	$result = DllCall($Sciterdll, "int", "SciterGetFocusElement", "HWND", $hwnd, "ptr*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[2]
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetElementState
; Description....:	Get state bits, see ELEMENT_STATE_BITS in "Sciter-constants.au3"
; Syntax.........:	_StGetElementState($el)
; Parameters.....:	$el - Dom element handle
;
; Return values..:	Success - Return Statebits
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetElementState($el)
	$result = DllCall($Sciterdll, "int", "SciterGetElementState", "ptr", $el, "UINT*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[2]
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........:	_StSetElementState
; Description....:	Set state bits, see ELEMENT_STATE_BITS in "Sciter-constants.au3"
; Syntax.........:	_StSetElementState($el, $stateToSet, $stateToClear = 0, $upt = 1)
; Parameters.....:	$el - Dom handle element
;					$stateToSet -
;					$stateToClear - [Optional]
;					$upt - [Optional]
;
; Return values..:	Success - Return 1
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StSetElementState($el, $stateToSet, $stateToClear = 0, $upt = 1)
	$result = DllCall($Sciterdll, "int", "SciterSetElementState", "ptr", $el, "UINT", $stateToSet, "UINT", $stateToClear, "BOOL", $upt)
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return 1
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetNthChild
; Description....:	Get handle of Nth child element.
; Syntax.........:	_StGetNthChild($el, $nth)
; Parameters.....:	$el - DOM element handle
;					$nth - number of the child element
;
; Return values..:	Success - Return handle of the child element
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetNthChild($el, $nth)
	$result = DllCall($Sciterdll, "int", "SciterGetNthChild", "ptr", $el, "UINT", $nth-1, "ptr*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[3]
EndFunc   ;==>_StGetNthChild

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetParentElement
; Description....:	Get parent element.
; Syntax.........:	_StGetParentElement($el)
; Parameters.....:	$el - DOM element handle which parent you need
;
; Return values..:	Success - Return handle of the parent element
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetParentElement($el)
	$result = DllCall($Sciterdll, "int", "SciterGetParentElement", "ptr", $el, "ptr*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[2]
EndFunc   ;==>_StGetParentElement

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetAttributeCount
; Description....:	Get number of element's attributes.
; Syntax.........:	_StGetAttributeCount($el)
; Parameters.....:	$el - DOM element handle
;
; Return values..:	Success - Return number of element attributes.
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetAttributeCount($el)
	$result = DllCall($Sciterdll, "int", "SciterGetAttributeCount", "ptr", $el, "UINT*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[2]
EndFunc   ;==>_StGetAttributeCount

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetNthAttribute
; Description....:	Get value of any element's attribute by attribute's number.
; Syntax.........:	_StGetNthAttribute($el, $nth)
; Parameters.....:	$el - DOM element handle
;					$nth - number of desired attribute
;
; Return values..:	Success - Return Array with name and value of attribute. $return[0] = name, $return[1] = value
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetNthAttribute($el, $nth)
	$result = DllCall($Sciterdll, "int", "SciterGetNthAttribute", "ptr", $el, "UINT", $nth, "str*", "", "wstr*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Dim $aRet[2]
	$aRet[0] = $result[3]
	$aRet[1] = $result[4]
	Return $aRet
EndFunc   ;==>_StGetNthAttribute

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetAttributeByName
; Description....:	Get value of any element's attribute by name.
; Syntax.........:	_StGetAttributeByName($el, $AttName)
; Parameters.....:	$el - DOM element handle
;					$AttName - attribute name
;
; Return values..:	Success - Return attribute value
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetAttributeByName($el, $AttName)
	$result = DllCall($Sciterdll, "int", "SciterGetAttributeByName", "ptr", $el, "str", $AttName, "wstr*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[3]
EndFunc   ;==>_StGetAttributeByName

; #FUNCTION# ====================================================================================================
; Name...........:	_StSetAttributeByName
; Description....:	Set attribute's value.
; Syntax.........:	_StSetAttributeByName($el, $AttName, $value)
; Parameters.....:	$el - DOM element handle
;					$AttName - attribute name
;					$value - new attribute value or 0 if you want to remove attribute.
;
; Return values..:	Success - Return 1
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StSetAttributeByName($el, $AttName, $value)
	$result = DllCall($Sciterdll, "int", "SciterSetAttributeByName", "ptr", $el, "str", $AttName, "wstr", $value)
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return 1
EndFunc   ;==>_StSetAttributeByName

; #FUNCTION# ====================================================================================================
; Name...........:	_StClearAttributes
; Description....:	Remove all attributes from the element.
; Syntax.........:	_StClearAttributes($el)
; Parameters.....:	$el - DOM element handle
;
; Return values..:	Success - Return 1
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StClearAttributes($el)
	$result = DllCall($Sciterdll, "int", "SciterClearAttributes", "ptr", $el)
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return 1
EndFunc   ;==>_StClearAttributes

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetElementIndex
; Description....:	Get element index.
; Syntax.........:	_StGetElementIndex($el)
; Parameters.....:	$el - DOM element handle
;
; Return values..:	Success - Return index of element
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetElementIndex($el)
	$result = DllCall($Sciterdll, "int", "SciterGetElementIndex", "ptr", $el, "UINT*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[2]
EndFunc   ;==>_StGetElementIndex

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetElementType
; Description....:	Get element's type.
; Syntax.........:	_StGetElementType($el)
; Parameters.....:	$el - DOM element handle
;
; Return values..:	Success - Return Type of element
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........: For <div> return will be set to "div".
; ===============================================================================================================
Func _StGetElementType($el)
	$result = DllCall($Sciterdll, "int", "SciterGetElementType", "ptr", $el, "str*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[2]
EndFunc   ;==>_StGetElementType

; #FUNCTION# ====================================================================================================
; Name...........:	_StGetStyleAttribute
; Description....:	Get element's style attribute.
; Syntax.........:	_StGetStyleAttribute($el, $StyleName)
; Parameters.....:	$el - DOM element handle
;					$StyleName - name of the style attribute
;
; Return values..:	Success - Return value of the style attribute.
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StGetStyleAttribute($el, $StyleName)
	$result = DllCall($Sciterdll, "int", "SciterGetStyleAttribute", "ptr", $el, "str", $StyleName, "wstr*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[3]
EndFunc   ;==>_StGetStyleAttribute

; #FUNCTION# ====================================================================================================
; Name...........:	_StSetStyleAttribute
; Description....:	Set element's style attribute.
; Syntax.........:	_StSetStyleAttribute($el, $StyleName, $StyleValue)
; Parameters.....:	$el - DOM element handle
;					$StyleName - name of the style attribute
;					$StyleValue - value of the style attribute.
;
; Return values..:	Success - Return 1
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StSetStyleAttribute($el, $StyleName, $StyleValue)
	$result = DllCall($Sciterdll, "int", "SciterSetStyleAttribute", "ptr", $el, "str", $StyleName, "wstr", $StyleValue)
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return 1
EndFunc   ;==>_StSetStyleAttribute

; #FUNCTION# ====================================================================================================
; Name...........:	_StCreateElement
; Description....:	Create new element, the element is disconnected initially from the DOM.
; Syntax.........:	_StCreateElement($tag, $txt = "")
; Parameters.....:	$tag - html tag of the element e.g. "div", "option", etc.
;					$txt - initial text of the element or "". text here is a plain text. [Optional]
;
; Return values..:	Success - Return handle of element
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StCreateElement($tag, $txt = "")
	If $txt <> "" Then
		$result = DllCall($Sciterdll, "int", "SciterCreateElement", "str", $tag, "wstr", $txt, "ptr*", "")
	Else
		$result = DllCall($Sciterdll, "int", "SciterCreateElement", "str", $tag, "ptr", "", "ptr*", "")
	EndIf
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[3]
EndFunc   ;==>_StCreateElement

; #FUNCTION# ====================================================================================================
; Name...........:	_StInsertElement
; Description....:	Insert element at index position of parent.
; Syntax.........:	_StInsertElement($el, $elparent, $index)
; Parameters.....:	$el - Handle element
;					$elparent - Handle element of parent
;					$index - position of the element in parent collection.
;
; Return values..:	Success - Return 1
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:	It is not an error to provide index greater than elements count in parent - it will be appended.
; ===============================================================================================================
Func _StInsertElement($el, $elparent, $index)
	$result = DllCall($Sciterdll, "int", "SciterInsertElement", "ptr", $el, "ptr", $elparent, "UINT", $index)
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return 1
EndFunc



; #FUNCTION# ====================================================================================================
; Name...........:	_StSelectElements
; Description....:	Return Array of elements in a DOM that meets specified CSS selectors.
; Syntax.........:	_StSelectElements($el, $CssSel)
; Parameters.....:	$el - DOM element handle
;					$CssSel - comma separated list of CSS selectors, e.g.: div, id, div[align="right"].
;
; Return values..:	Success - Return Array of elements, $return[0] : number of element.
;					Failure - Return 0 if no element found else Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:	See list of supported selectors: http://terrainformatica.com/Sciter/selectors.whtm
; ===============================================================================================================
Func _StSelectElements($el, $CssSel)
	$handle = DllCallbackRegister("StElementsCallback", "BOOL", "ptr;ptr")
	Dim $aHLelementsfound[1]
	$result = DllCall($Sciterdll, "int", "SciterSelectElementsW", "ptr", $el, "wstr", $CssSel, "ptr", DllCallbackGetPtr($handle), "ptr", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	DllCallbackFree($handle)
	$HLelementsCount = UBound($aHLelementsfound)
	If $HLelementsCount = 1 Then Return 0
	$aHLelementsfound[0] = $HLelementsCount-1
	Return $aHLelementsfound
EndFunc   ;==>_StSelectElements
Func StElementsCallback($el, $param)
	Local $iUBound = UBound($aHLelementsfound)
	ReDim $aHLelementsfound[$iUBound + 1]
	$aHLelementsfound[$iUBound] = $el
EndFunc   ;==>_StElementsCallback

; #FUNCTION# ====================================================================================================
; Name...........:	_StSelectParent
; Description....:	Find parent of the element by CSS selector.
; Syntax.........:	_StSelectParent($el, $CssSel, $depth = 0)
; Parameters.....:	$el - DOM element handle
;					$CssSel - comma separated list of CSS selectors, e.g.: div, id, div[align="right"].
;					$depth - if depth == 1 then it will test only element itself.
;							 Use depth = 1 if you just want to test he element for matching given CSS selector(s).
;							 depth = 0 will scan the whole child parent chain up to the root. [Optional]
;
; Return values..:	Success - Return parent of the element.
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:
; ===============================================================================================================
Func _StSelectParent($el, $CssSel, $depth = 0)
	$result = DllCall($Sciterdll, "int", "SciterSelectParentW", "ptr", $el, "wstr", $CssSel, "UINT", $depth, "ptr*", "")
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return $result[4]
EndFunc   ;==>_StSelectParent

; #FUNCTION# ====================================================================================================
; Name...........:	_StDeleteElement
; Description....:	Delete element.
; Syntax.........:	_StDeleteElement($el)
; Parameters.....:	$el - DOM element handle
;
; Return values..:	Success - Return 1
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:	After call to this function $el will become invalid.
; ===============================================================================================================
Func _StDeleteElement($el)
	$result = DllCall($Sciterdll, "int", "SciterDeleteElement", "ptr", $el)
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	Return 1
EndFunc   ;==>_StDeleteElement


;~ EXTERN_C HLDOM_RESULT HLAPI  SciterShowPopup (HELEMENT hePopup, HELEMENT heAnchor, UINT placement)
;~   Shows block element (DIV) in popup window.
;~ Func _StShowPopup($Sciterdll, $el, $anchor, $placement)
;~ 	$result = DllCall($Sciterdll, "int", "SciterShowPopup", "ptr", $el, "ptr", $anchor, "UINT", $placement)
;~ 	If @error Then Return 0
;~ 	Return 1
;~ EndFunc

; #FUNCTION# ====================================================================================================
; Name...........:	_StWindowAttachEventHandler
; Description....:	Attach/Detach ElementEventProc to the Sciter window.
; Syntax.........:	_StWindowAttachEventHandler($hwnd, $func, $events)
; Parameters.....:	$hwnd - HWND of Sciter windows
;					$func - Function to receive events (need two params eg: $func($ev, $arrayparam)
;					$events - Events you want receive (see remarks)
;						can be :
;~						$HANDLE_INITIALIZATION			: attached/detached
;~						$HANDLE_MOUSE					: mouse events
;~						$HANDLE_KEY						: key events
;~						$HANDLE_FOCUS					: focus events, if this flag is set it also means that element it attached to is focusable
;~						$HANDLE_SCROLL					: scroll events
;~						$HANDLE_SIZE					: size changed event
;~						$HANDLE_DATA_ARRIVED			: requested data () has been delivered
;~						$HANDLE_BEHAVIOR_EVENT			: secondary, synthetic events: BUTTON_CLICK, HYPERLINK_CLICK, etc.
;~						$HANDLE_METHOD_CALL				: behavior specific methods
;~						$HANDLE_SCRIPTING_METHOD_CALL 	: behavior specific methods
;						$HANDLE_TISCRIPT_METHOD_CALL    : behavior specific methods using direct tiscript::value's
;~						$HANDLE_ALL						: all of them
; Return values..:	Success - Return 1
;					Failure - Return -1, @error is set. (see $aHLDOM_error[@error] for details)
; Remarks........:	For Uppercase type see "Sciter-Constants.au3"
;					$HANDLE_MOUSE : $ret[12]=[MOUSE_EVENTS, target el, curs xpos el rel, curs ypos el rel, curs xpos doc rel, curs ypos doc rel, MOUSE_BUTTONS, KEYBOARD_STATES, CURSOR_TYPE, is on icon, el dragged, DRAGGING_TYPE]
;					$HANDLE_KEY   : $ret[4]=[KEY_EVENTS, target el, key code, KEYBOARD_STATES]
;					$HANDLE_FOCUS : $ret[4]=[FOCUS_EVENTS, target el, focus by click, cancel]
;					$HANDLE_SCROLL: $ret[4]=[SCROLL_EVENTS, target el, scroll pos, 1 if vert scroll]
;					$HANDLE_BEHAVIOR_EVENT : $ret[5]=[BEHAVIOR_EVENTS, target el, source el, EVENT_REASON or EDIT_CHANGED_REASON, data]
; ===============================================================================================================
Func _StWindowAttachEventHandler($hwnd, $func, $events)
	$HandleWindowsAttachEvent = DllCallbackRegister("HLEvHandler", "BOOL", "ptr;ptr;UINT;ptr")
	$result = DllCall($Sciterdll, "int", "SciterWindowAttachEventHandler", "HWND", $hwnd, "ptr", DllCallbackGetPtr($HandleWindowsAttachEvent), _
	"ptr", "", "UINT", $events)
	If @error Then Return SetError(6,0,-1)
	If $result[0] <> 0 Then Return SetError($result[0],0,-1)
	$SciterEvHandler = $func
	Return 1

EndFunc   ;==>_StWindowAttachEventHandler

Func HLEvHandler($tag,$el,$ev,$prm)
	$ap = -1
	$a = DllStructCreate("UINT cmd", $prm)
	$cmd = DllStructGetData($a, "cmd")
	$a = 0
	If $cmd > 32768 Then Return
	If $ev = $HANDLE_MOUSE Then
		$str = "UINT cmd;ptr target;DWORD posx;DWORD posy;DWORD pos_documentx;DWORD pos_documenty;UINT button_state;UINT alt_state;UINT cursor_type;BOOL is_on_icon;ptr dragging;UINT dragging_mode"
		$ap = getstructdata($str,$prm)
	EndIf
	If $ev = $HANDLE_KEY Then
		$str = "UINT cmd;ptr target;UINT key_code;UINT alt_state"
		$ap = getstructdata($str,$prm)
	EndIf
	If $ev = $HANDLE_FOCUS Then
		$str = "UINT cmd;ptr target;BOOL by_mouse_click;BOOL cancel"
		$ap = getstructdata($str,$prm)
	EndIf
	If $ev = $HANDLE_SCROLL Then
		$str = "UINT cmd;ptr target;int pos;BOOL vertical"
		$ap = getstructdata($str,$prm)
	EndIf
	If $ev = $HANDLE_BEHAVIOR_EVENT Then
		$str = "UINT cmd;ptr heTarget;ptr he;UINT reason;ptr data"
		$ap = getstructdata($str,$prm)
	EndIf
	If $ev = $HANDLE_METHOD_CALL Then
		$str = "UINT cmd;ptr heTarget;ptr he;UINT reason;ptr data"
		$ap = getstructdata($str,$prm)
	EndIf
	Execute ($SciterEvHandler&"("&$ev&",$ap)")

EndFunc

Func getstructdata($str,$prm)
	$a = DllStructCreate($str, $prm)
	$b = StringSplit ( $str, ";")
	Dim $ret[$b[0]]
	For $i = 0 To $b[0]-1
		$ret[$i] = DllStructGetData($a,$i+1)
	Next
	Return $ret
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........:	_StDebug
; Description....:	Active debug and display css/html error in scite console.
; Syntax.........:	_StDebug()
; Parameters.....:	None.
; Return values..:	Success - 1
;					Failure - -1
; Remarks........:
; ===============================================================================================================
Func _StDebug()
	$DEBUG_OUTPUT_PROC = DllCallbackRegister("SciterDebugCallback", "ptr", "ptr;int")
	$result = DllCall($Sciterdll, "int", "SciterSetupDebugOutput", "ptr", "", "ptr", DllCallbackGetPtr($DEBUG_OUTPUT_PROC))
	If @error Then Return -1
	Return 1
EndFunc
Func SciterDebugCallback($prm,$char)
	ConsoleWrite(ChrW($char))
EndFunc

