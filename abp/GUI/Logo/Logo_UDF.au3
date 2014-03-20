#include-once
#include <GDIPlus.au3>
#include <WindowsConstants.au3>
#include <GUIConstants.au3>
Global Const $AC_SRC_ALPHA = 1
Global $__gImageStartup_Logo
Global $__gPNG_Logo
Global $__gGUI_Controls_Logo
Global $__gProgress_Logo
Global $__gProgress_Label_Logo
Global $__gFailure_Logo = False

; #FUNCTION# ;===============================================================================
;
; Name...........: _Logo_Startup
; Description ...: Startup Logo Creation
; Syntax.........: _Logo_Startup($s_path, $iP_Left, $iP_Top, $iP_Width, $iP_Height, $iL_Left, $iL_Top, $iL_Width, $iL_Height, $f_GDIP = True, $i_Fade = 10)
; Parameters ....: $s_path  		- Path to PNG File
;                  $iP_Left			- Progressbar Left Position
;                  $iP_Top			- Progressbar Top Position
;                  $iP_Width		- Progressbar Width
;                  $iP_Height		- Progressbar Height
;                  $iL_Left			- Label Left Position
;                  $iL_Top			- Label Top Position
;                  $iL_Width		- Label Width
;                  $iL_Height		- Label Height
;                  $f_GDIP  		- Should GDI+ be loaded (Standard = True)
;				   $i_Fade			- Speed of Logo to Fade in (Standard = 10)
; Return values .: Success - Return 1
;                  Failure - Returns 0 and Sets @Error:
;                  |1 - Invalid $s_path (Not a PNG File)
;                  |2 - Invalid Number (@extended for Wrong Number)
;                  |3 - Invalid $s_path (Image could not be loaded)
; Author ........: TheLuBu (LuBu@veytal.com)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
;
; ;==========================================================================================
Func _Logo_Startup($s_path, $iP_Left, $iP_Top, $iP_Width, $iP_Height, $iL_Left, $iL_Top, $iL_Width, $iL_Height, $f_GDIP = True, $i_Fade = 10)
	If Not StringRight($s_path, 4) = ".png" Then
		$__gFailure_Logo = True
		Return SetError(1, 0, 0)
	EndIf
	Local $ai_Positions[9]
	$ai_Positions[0] = $iP_Left
	$ai_Positions[1] = $iP_Top
	$ai_Positions[2] = $iP_Width
	$ai_Positions[3] = $iP_Height
	$ai_Positions[4] = $iL_Left
	$ai_Positions[5] = $iL_Top
	$ai_Positions[6] = $iL_Width
	$ai_Positions[7] = $iL_Height
	$ai_Positions[8] = $i_Fade
	For $i = 0 To 8
			If Not StringIsDigit($ai_Positions[$i]) Then
				$__gFailure_Logo = True
				Return SetError(2, $i + 1, 0)
			EndIf
	Next
	$ai_Positions = ""
	Local $i_width, $i_height, $i_alpha
	If $f_GDIP = True Then
		_GDIPlus_Startup()
	EndIf
	$__gImageStartup_Logo = _GDIPlus_ImageLoadFromFile($s_path)
	If @error Then
		$__gFailure_Logo = True
		If $f_GDIP = True Then
			_GDIPlus_Shutdown()
		EndIf
		Return SetError(3, 0, 0)
	EndIf
	$i_width = _GDIPlus_ImageGetWidth($__gImageStartup_Logo)
	$i_height = _GDIPlus_ImageGetHeight($__gImageStartup_Logo)
	$__gPNG_Logo = GUICreate("", $i_width, $i_height, -1, -1, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_TOOLWINDOW))
	__Logo_SetBitmap($__gPNG_Logo, $__gImageStartup_Logo, 0)
	GUISetState()
	WinSetOnTop($__gPNG_Logo, "", 1)
	$__gGUI_Controls_Logo = GUICreate("", $i_width, $i_height, -1, -1, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD, $WS_EX_TOOLWINDOW), $__gPNG_Logo)
	GUISetBkColor(0xFFFFFE)
	_WinAPI_SetLayeredWindowAttributes($__gGUI_Controls_Logo, 0xFFFFFE)
	$__gProgress_Logo = GUICtrlCreateProgress($iP_Left, $iP_Top, $iP_Width, $iP_Height)
	$__gProgress_Label_Logo = GUICtrlCreateLabel("", $iL_Left, $iL_Top, $iL_Width, $iL_Height, 1, -1)
	$i_alpha = 0
	While 1
		$i_alpha += $i_Fade
		If $i_alpha > 255 Then
			$i_alpha = 255
			ExitLoop
		EndIf
		__Logo_SetBitmap($__gPNG_Logo, $__gImageStartup_Logo, $i_alpha)
		Sleep(10)
	WEnd
	__Logo_SetBitmap($__gPNG_Logo, $__gImageStartup_Logo, 255)
	GUISetState(@SW_SHOW, $__gGUI_Controls_Logo)
	Return 1
EndFunc   ;==>_Logo_Startup
; #FUNCTION# ;===============================================================================
;
; Name...........: _Logo_Set_Label_Font
; Description ...: Sets Font and Color for Logo Label
; Syntax.........: _Logo_Set_Label_Font($iSize = 8.5, $iWeight = 800, $iAttribute = 0, $sFontName = "Arial", $sHexcolor = 0x000000)
; Parameters ....: $iSize  		- Font Size (see GUICtrlSetFont)
;                  $iWeight		- Font Weight (see GUICtrlSetFont)
;                  $iAttribute	- Font Attributes (see GUICtrlSetFont)
;                  $sFontName	- Font Name (see GUICtrlSetFont)
;                  $sHexcolor	- Font Color (see GUICtrlSetColor)
; Return values .: Success - Return 1
;                  Failure - Returns 0 and Sets @Error:
;				   |0 - _Logo_Startup failed
;                  |1 - Invalid $iWeight (Not a Number)
;                  |2 - Invalid $iAttribute (Not a Number)
;                  |3 - Invalid $sFontName (Not a Number)
;				   |4 - Invalid $iSize (Not a Number)
; Author ........: TheLuBu (LuBu@veytal.com)
; Modified.......:
; Remarks .......:
; Related .......:GUICtrlSetColor, GUICtrlSetFont
; Link ..........:
;
; ;==========================================================================================
Func _Logo_Set_Label_Font($iSize = 8.5, $iWeight = 800, $iAttribute = 0, $sFontName = "Arial", $sHexcolor = 0x000000)
	If $__gFailure_Logo = True Then Return 0
	If Not StringIsDigit($iWeight) Then Return SetError(1, 0, 0)
	If Not StringIsDigit($iAttribute) Then Return SetError(2, 0, 0)
	If Not StringIsXDigit($sHexcolor) Then Return SetError(3, 0, 0)
	If Not StringIsDigit($iSize) AND not StringIsFloat($iSize) Then Return SetError(4,0,0)
	GUICtrlSetFont($__gProgress_Label_Logo, $iSize, $iWeight, $iAttribute, $sFontName)
	GUICtrlSetColor($__gProgress_Label_Logo, $sHexcolor)
	Return 1
EndFunc   ;==>_Logo_Set_Label_Font
; #FUNCTION# ;===============================================================================
;
; Name...........: _Logo_Set_Data
; Description ...: Sets Label Data And/Or Progress Data
; Syntax.........: _Logo_Set_Data($i_Progress_Set = False, $s_Label_Set = False)
; Parameters ....: $i_Progress_Set 	- Font Size (see GUICtrlSetFont)
;                  $s_Label_Set		- Font Weight (see GUICtrlSetFont)
; Return values .: Success - Return 1
;                  Failure - Returns 0 and Sets @Error:
;				   |0 - _Logo_Startup failed
;                  |1 - Invalid $i_Progress_Set (Not a Number)
;                  |2 - Invalid $i_Progress_Set (Out of Range (0-100))
; Author ........: TheLuBu (LuBu@veytal.com)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
;
; ;==========================================================================================
Func _Logo_Set_Data($i_Progress_Set = False, $s_Label_Set = False)
	If $__gFailure_Logo = True Then Return 0
	If $i_Progress_Set <> False Then
		If Not StringIsDigit($i_Progress_Set) AND NOT StringIsFloat($i_Progress_Set) Then Return SetError(1,0,0)
		If $i_Progress_Set < 0 Or $i_Progress_Set > 100 Then Return SetError(2, 0, 0)
		GUICtrlSetData($__gProgress_Logo, $i_Progress_Set)
	EndIf
	If $s_Label_Set <> False Then
		GUICtrlSetData($__gProgress_Label_Logo, $s_Label_Set)
	EndIf
	Return 1
EndFunc   ;==>_Logo_Set_Data
; #FUNCTION# ;===============================================================================
;
; Name...........: _Logo_Shutdown
; Description ...: Shutdown Logo and release Data
; Syntax.........: _Logo_Shutdown($f_Shutdown_GDIP = True, $i_Fade_Out = 15)
; Parameters ....: $f_Shutdown_GDIP 	- Shutdown GDI+
;                  $i_Fade_Out			- Speed of Logo to Fade out
; Return values .: Success - Return 1
;                  Failure - Returns 0 and Sets @Error:
;				   |0 - _Logo_Startup failed
;                  |1 - Invalid $i_Fade_Out (Not a Number)
; Author ........: TheLuBu (LuBu@veytal.com)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
;
; ;==========================================================================================
Func _Logo_Shutdown($f_Shutdown_GDIP = True, $i_Fade_Out = 15)
	If $__gFailure_Logo = True Then Return 0
	If Not StringIsDigit($i_Fade_Out) Then Return SetError(1,0,0)
	Local $i_alpha = 255
	While 1
		$i_alpha = $i_alpha - $i_Fade_Out
		If $i_alpha <= 0 Then
			$i_alpha = 0
			ExitLoop
		EndIf
		__Logo_SetBitmap($__gPNG_Logo, $__gImageStartup_Logo, $i_alpha)
		Sleep(10)
	WEnd
	GUIDelete($__gGUI_Controls_Logo)
	GUIDelete($__gImageStartup_Logo)
	If $f_Shutdown_GDIP = True Then
		_GDIPlus_Shutdown()
	EndIf
	Return 1
EndFunc   ;==>_Logo_Shutdown
; #INTERNAL FUNCTION# ;======================================================================
;
; Name...........: __Logo_SetBitmap
; Description ...: Sets transparency of an GUI Background
; Syntax.........: __Logo_SetBitmap($hGui, $hImage, $iOpacity)
; Parameters ....: $hGui 		- GUI to set transparency
;                  $hImage		- Image to set transparency
;                  $iOpacity	- Transparency to set (0-255)
; Return values .: Success - Return 1
; Author ........: TheLuBu (LuBu@veytal.com)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
;
; ;==========================================================================================
Func __Logo_SetBitmap($hGui, $hImage, $iOpacity)
	Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend
	$hScrDC = _WinAPI_GetDC(0)
	$hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	$hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
	$tSize = DllStructCreate($tagSIZE)
	$pSize = DllStructGetPtr($tSize)
	DllStructSetData($tSize, "X", _GDIPlus_ImageGetWidth($hImage))
	DllStructSetData($tSize, "Y", _GDIPlus_ImageGetHeight($hImage))
	$tSource = DllStructCreate($tagPOINT)
	$pSource = DllStructGetPtr($tSource)
	$tBlend = DllStructCreate($tagBLENDFUNCTION)
	$pBlend = DllStructGetPtr($tBlend)
	DllStructSetData($tBlend, "Alpha", $iOpacity)
	DllStructSetData($tBlend, "Format", $AC_SRC_ALPHA)
	_WinAPI_UpdateLayeredWindow($hGui, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
	_WinAPI_ReleaseDC(0, $hScrDC)
	_WinAPI_SelectObject($hMemDC, $hOld)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteDC($hMemDC)
	Return 1
EndFunc   ;==>__Logo_SetBitmap