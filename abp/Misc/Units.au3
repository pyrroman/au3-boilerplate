#include-once
#include <WinAPILocale.au3>
 #include <WinAPI.au3>

Func __Units_Build(ByRef $iNumber, $iStep, ByRef $asUnits)
	Local $i
	While $iNumber > $iStep - 1
		$i += 1
		$iNumber /= $iStep
	WEnd
	Return $asUnits[$i]
EndFunc   ;==>__Units_Build


Func _Units_Bytes($iNumber, $iRound = 2)
	Local $iIndex, $aArray[9] = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB']
	Local $sUnit = __Units_Build($iNumber, 1024, $aArray)
	Return Round($iNumber, $iRound) & " " & $sUnit
EndFunc   ;==>_Units_Bytes

Func _Units_Length()

EndFunc   ;==>_Units_Length

MsgBox("", "", _WinAPI_GetLocaleInfoEx($LOCALE_IMEASURE)&@CRLF&_WinAPI_GetUserDefaultLocaleName()&@CRLF&_WinAPI_GetLastErrorMessage())
