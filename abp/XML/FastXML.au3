#include-once
#include <Array.au3>

; #FUNCTION# ====================================================================================================================
; Name ..........: _XML_GetElementsByTagName
; Description ...: Matches strings/values between XML tags
; Syntax ........: _XML_GetElementsByTagName($sSource, $sTag[, $fIsCDATA = 0])
; Parameters ....: $sSource      - A string value.
;                  $sTag - A string value. The name of the element containing the demanded strings/values.
;                  $fIsCDATA     - [optional] A boolean value.
;                                  True - You're sure the elements are CDATA.
;                                  False - You're sure they're not CDATA.
;                                  none - [default] You're unsure and the function will guess.
; Return values .: Success - A zero based array containing data form all matching elements.
;                  Failure - An empty string and sets the @error flag to a non-zero value.
; Author ........: rindeal
; Modified ......:
; Version .......: 2014-02-23
; Requirements ..: AutoIt 3.3.10+
; Performance ...: Document: ~6500 matches (~2300 kB), without guessing 12.6 ms, with guessing 14.8 ms
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _XML_GetElementsByTagName($sSource, $sTag, $fIsCDATA = Default)
	Local $aMatches
	$sTag = '\Q' & $sTag & '\E.*?'
	If IsKeyword($fIsCDATA) Or $fIsCDATA = "" Then $fIsCDATA = StringRegExp($sSource, '(?s)<' & $sTag & '><!\[CDATA\[')

	$aMatches = StringRegExp($sSource, '(?s)' & _
			'<' & $sTag & '>' & ($fIsCDATA ? '<!\[CDATA\[' : '') & _ ; beginning
			'(.*?)' & _                                              ; body
			($fIsCDATA ? ']]>' : '') & '</' & $sTag & '>', 3) ;        ending
	If @error Then Return SetError(1, 0, "")

	Return $aMatches
EndFunc   ;==>_XML_GetElementsByTagName
