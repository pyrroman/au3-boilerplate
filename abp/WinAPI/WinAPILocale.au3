#include-once

#include <WinAPILocale.au3>
#include "WinAPILocale_Constants.au3"

; #FUNCTION# ====================================================================================================================
; Name ..........: _WinAPI_GetLocaleInfoEx
; Description ...:
; Syntax ........: _WinAPI_GetLocaleInfoEx($iType[, $sLocaleName = $LOCALE_NAME_USER_DEFAULT])
; Parameters ....: $iType               - (integer)
;                  $sLocaleName         - (string) [optional]->[$LOCALE_NAME_USER_DEFAULT]
; Return values .:
; Author ........: rindeal <dev.rindeal at outlook.com>
; Modified ......:
; Version .......: 2014-04-07
; Requirements ..:
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WinAPI_GetLocaleInfoEx($iType, $sLocaleName = $LOCALE_NAME_USER_DEFAULT)

	Local $Ret = DllCall('kernel32.dll', 'int', 'GetLocaleInfoEx', 'wstr', $sLocaleName, 'dword', $iType, 'wstr', '', 'int', 2048)
	If @error Or Not $Ret[0] Then Return SetError(@error, @extended, '')

	Return $Ret[3]
EndFunc   ;==>_WinAPI_GetLocaleInfoEx

; #FUNCTION# ====================================================================================================================
; Name ..........: _WinAPI_GetUserDefaultLocaleName
; Description ...:
; Syntax ........: _WinAPI_GetUserDefaultLocaleName()
; Parameters ....:
; Return values .:
; Author ........: rindeal <dev.rindeal at outlook.com>
; Modified ......:
; Version .......: 2014-04-07
; Requirements ..:
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _WinAPI_GetUserDefaultLocaleName()
	Local $tLocaleName = DllStructCreate('wchar[' & $LOCALE_NAME_MAX_LENGTH + 1 & ']')

	Local $Ret = DllCall('kernel32.dll', 'int', 'GetUserDefaultLocaleName', 'struct*', $tLocaleName, 'int', $LOCALE_NAME_MAX_LENGTH)
	If @error Or Not $Ret[0] Then Return SetError(@error, @extended, '')

	Return DllStructGetData($tLocaleName, 1)

EndFunc   ;==>_WinAPI_GetUserDefaultLocaleName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LCIDToLocaleName
; Description....: Converts a locale identifier to a locale name.
; Syntax.........: _WinAPI_LCIDToLocaleName ( $LCID )
; Parameters.....: $LCID   - The locale identifier (LCID) that specifies the locale or one of the following predefined values.
;
;                           $LOCALE_INVARIANT
;                           $LOCALE_SYSTEM_DEFAULT
;                           $LOCALE_USER_DEFAULT
;
;                           Windows Vista or later
;
;                           $LOCALE_CUSTOM_DEFAULT
;                           $LOCALE_CUSTOM_UI_DEFAULT
;                           $LOCALE_CUSTOM_UNSPECIFIED
;
; Return values..: Success - String containing the locale name.
;                 Failure - Empty string and sets the @error flag to non-zero.
; Author.........: ChrisR
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ LCIDToLocaleName
; Example........: Yes
; ===============================================================================================================================
Func _WinAPI_LCIDToLocaleName($LCID)
	Local $Ret = DllCall('kernel32.dll', 'int', 'LCIDToLocaleName', 'ulong', $LCID, 'wstr', '', 'int', 500, 'int', 0)
	If (@error) Or (Not $Ret[0]) Then Return SetError(1, 0, '')
	Return $Ret[2]
EndFunc   ;==>_WinAPI_LCIDToLocaleName

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_LocaleNameToLCID
; Description....: Converts a locale name to a locale identifier.
; Syntax.........: _WinAPI_LocaleNameToLCID ( $LocaleName )
; Parameters.....: $LocaleName - The locale Name or one of the following predefined values.
;
;                           $LOCALE_NAME_INVARIANT
;                           $LOCALE_NAME_SYSTEM_DEFAULT
;                           $LOCALE_NAME_USER_DEFAULT
;
; Return values..: Success - String containing the locale identifier (LCID).
;                 Failure  - 0 and sets the @error flag to non-zero.
; Author.........: ChrisR
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ LocaleNameToLCID
; Example........:
; ===============================================================================================================================

Func _WinAPI_LocaleNameToLCID($LocaleName)
	Local $Ret = DllCall('kernel32.dll', 'int', 'LocaleNameToLCID', 'wstr', $LocaleName, 'int', 0)
	If (@error) Or (Not $Ret[0]) Then Return SetError(1, 0, '')
	Return $Ret[0]
EndFunc   ;==>_WinAPI_LocaleNameToLCID
