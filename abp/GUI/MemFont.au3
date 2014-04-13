#include-once
#include <GdiPlus.au3>


; #FUNCTION# ======================================================================================
; Name ..........: _GDIPlus_CreateFontFamilyFromName()
; Description ...: Creates a FontFamily object based on a specified font family.
; Syntax ........: _GDIPlus_CreateFontFamilyFromName($sFontname[, $hCollection = 0])
; Parameters ....: $sFontname   - [in] Name of the font family. For example, Arial.ttf is the name of the Arial font family.
;                  $hCollection - [optional] [in] Pointer to the PrivateFontCollection object to delete. (default:0)
; Return values .: Success      - a pointer to the new FontFamily object.
;                  Failure      - 0
; Author ........: Prog@ndy, Yashied
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GdipCreateFontFamilyFromName
; Example .......:
; =================================================================================================

Func _GDIPlus_CreateFontFamilyFromName($sFontname, $hCollection = 0)
	Local $aResult = DllCall($ghGDIPDll, 'int', 'GdipCreateFontFamilyFromName', 'wstr', $sFontname, 'ptr', $hCollection, 'ptr*', 0)
	If @error Then Return SetError(1, 0, 0)
	Return SetError($aResult[0], 0, $aResult[3])
EndFunc   ;==>_GDIPlus_CreateFontFamilyFromName


; #FUNCTION# ======================================================================================
; Name ..........: _GDIPlus_DeletePrivateFontCollection()
; Description ...: Deletes the specified PrivateFontCollection object.
; Syntax ........: _GDIPlus_DeletePrivateFontCollection($hCollection)
; Parameters ....: $hCollection - [in] Pointer to the PrivateFontCollection object to delete.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Prog@ndy, Yashied
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GdipDeletePrivateFontCollection
; Example .......:
; =================================================================================================

Func _GDIPlus_DeletePrivateFontCollection($hCollection)
	Local $aResult = DllCall($ghGDIPDll, 'int', 'GdipDeletePrivateFontCollection', 'ptr*', $hCollection)
	If @error Then Return SetError(1, 0, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_GDIPlus_DeletePrivateFontCollection


; #FUNCTION# ======================================================================================
; Name ..........: _GDIPlus_NewPrivateFontCollection()
; Description ...: Creates an PrivateFontCollection object.
; Syntax ........: _GDIPlus_NewPrivateFontCollection()
; Parameters ....:
; Return values .: Success      - a pointer to the PrivateFontCollection object.
;                  Failure      - 0
; Author ........: Prog@ndy, Yashied
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GdipNewPrivateFontCollection
; Example .......:
; =================================================================================================

Func _GDIPlus_NewPrivateFontCollection()
	Local $aResult = DllCall($ghGDIPDll, 'int', 'GdipNewPrivateFontCollection', 'ptr*', 0)
	If @error Then Return SetError(1, 0, 0)
	Return SetError($aResult[0], 0, $aResult[1])
EndFunc   ;==>_GDIPlus_NewPrivateFontCollection


; #FUNCTION# ======================================================================================
; Name ..........: _GDIPlus_PrivateAddMemoryFont()
; Description ...: Adds a font file from memory to the private font collection.
; Syntax ........: _GDIPlus_PrivateAddMemoryFont($hCollection, $pMemory, $iLength)
; Parameters ....: $hCollection - [in] Pointer to the font collection object.
;                  $pMemory     - [in] A pointer to a font resource.
;                  $iLength     - [in] The number of bytes in the font resource that is pointed to by $pMemory.
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Eukalyptus
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: @@MsdnLink@@ GdipPrivateAddMemoryFont
; Example .......:
; =================================================================================================

Func _GDIPlus_PrivateAddMemoryFont($hCollection, $pMemory, $iLength)
	Local $aResult = DllCall($ghGDIPDll, 'int', 'GdipPrivateAddMemoryFont', 'ptr', $hCollection, 'ptr', $pMemory, 'int', $iLength)
	If @error Then Return SetError(1, 0, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_GDIPlus_PrivateAddMemoryFont