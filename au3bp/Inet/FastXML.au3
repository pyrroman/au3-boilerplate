#include-once
#include <Array.au3>

; #FUNCTION# ====================================================================================================================
; Name ..........: _XML_GetElements
; Description ...: Matches strings/values between XML tags
; Syntax ........: _XML_GetElements($sSource, $sElementName[, $fIsCDATA = 0])
; Parameters ....: $sSource      - A string value.
;                  $sElementName - A string value. The name of the element containing the demanded strings/values.
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
Func _XML_GetElements($sSource, $sElementName, $fIsCDATA = Default)
	Local $aMatches
	If IsKeyword($fIsCDATA) Then
		$aMatches = StringRegExp($sSource, '(?s).*' & '<\Q' & $sElementName & '\E.*?>(.{9})', 3)
		If Not @error And $aMatches[0] == '<![CDATA[' Then $fIsCDATA = True
	EndIf
	$aMatches = StringRegExp($sSource, '(?s)' & _
			'<\Q' & $sElementName & '\E.*?>' & ($fIsCDATA ? '<!\[CDATA\[' : '') & _ ; beginning
			'(.*?)' & _                                                             ; body
			($fIsCDATA ? '\]\]>' : '') & '</\Q' & $sElementName & '\E>', 3)         ; ending
	If @error Then Return SetError(1, 0, "")
	Return $aMatches
EndFunc   ;==>_XML_GetElements
