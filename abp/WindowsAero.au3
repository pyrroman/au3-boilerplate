#include-once
#RequireAdmin
; #INDEX# =======================================================================================================================
; Title .........: Windows UI
; File name .....: WinUI.au3
; AutoIt Version : 3.3.10+
; Description ...: Collection of functions offering extended functionality for managing Windows UI
; Author(s) .....: GtaSpider
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $hDwmApiDll = DllOpen("dwmapi.dll")
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _EnableDisableAero
; _IsAeroEnable
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _EnableDisableAero
; Description ...: Enables or Disables the Aero design from Vista to the default design.
; Syntax ........: _EnableDisableAero([$bEnable = True])
; Parameters ....: $fEnable - [optional] [BOOLEAN]. Default is True. True enables the Aero, False disables it.
; Return values .: Returnvals of DLLCall
; Author ........: GtaSpider
; Modified ......:
; Version .......: 2014-02-07
; Requirements ..: dwmapi.dll, Win_Vista/Win_7
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _EnableDisableAero($fEnable = True) ;True/False
	Local $aDll = DllCall($hDwmApiDll, "int", "DwmEnableComposition", "int", $fEnable)
	If @error Then Return SetError(@error, 0, 0)
	Return $aDll[0]
EndFunc   ;==>_EnableDisableAero

; #FUNCTION# ====================================================================================================================
; Name ..........: _IsAeroEnable
; Description ...: Checks if aero is enable
; Syntax ........: _IsAeroEnable()
; Parameters ....: None
; Return values .: 0 If disabeld, 1 if enabled
; Author ........: GtaSpider
; Modified ......:
; Version .......: 2014-02-07
; Requirements ..: dwmapi.dll, Win_Vista/Win_7
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _IsAeroEnable()
	Local $asDll = DllCall($hDwmApiDll, "int", "DwmIsCompositionEnabled", "str", "")
	If @error Then Return SetError(@error, 0, 0)
	Return StringReplace(StringReplace(Asc($asDll[1]), "1", True), "0", False)
EndFunc   ;==>_IsAeroEnable
MsgBox("","",_EnableDisableAero(True))