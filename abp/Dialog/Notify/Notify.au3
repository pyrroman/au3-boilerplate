#include-once

; #INDEX# ============================================================================================================
; Title .........: Notify
; AutoIt Version : 3.3.2.0+ - uses AdlibRegister/Unregister
; Language ......: English
; Description ...: Show and hides pop-out notifications from the side of the screen in user defined colours and fonts
; Author(s) .....: Melba23 - credit to UEZ and Yashied for the PNG code
; ====================================================================================================================

;#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7

; #INCLUDES# =========================================================================================================
#include <StringSize.au3>
#include <GDIPlus.au3>

; #GLOBAL VARIABLES# =================================================================================================
; Create array to hold data for Notifications
; [0][0] = Count            [n][0] = Handle
; [0][1] = Max avail        [n][1] = Timer duration
; [0][2] = X-coord          [n][2] = Timer stamp
; [0][3] = Low Y-coord      [n][3] = Clickable
; [0][4] = Location         [n][4] = X-Coord
; [0][5] = Not Index        [n][5] = Extended X-Coord
;                           [n][6] = Hide timing and style
Global $aNotify_Data[1][7] = [[0, Int((@DesktopHeight - 60) / 50), @DesktopWidth - 10, @DesktopHeight - 10, 0, 0, 0]]
; Adjust values according to taskbar position and desired location
_Notify_Locate(0)
; Create array to hold default and current Notification values - [0][n] = Default, [1][n] = Current
; [n][0] Style   [n][1] Col   [n][2] BkCol   [n][3] Font   [n][4] Slide   [n][5] In time   [n][6] Out time   [n][7] Margin show
Global $aNotify_Settings[2][8] = [[1, 0, 0, _Notify_GetDefFont(), False, 1000, 500, 0],[0, 0, 0, 0, 0, 0, 0, 0]]
; Create array to show active retraction modes - ; [0] Timer active [1] Click active [2][2]
Global $aNotify_RetractMode[2] = [False, False]
Global $aNotify_Ret = DllCall("User32.dll", "int", "GetSysColor", "int", 8) ; $COLOR_WINDOWTEXT = 8
$aNotify_Settings[0][1] = $aNotify_Ret[0]
$aNotify_Ret = DllCall("User32.dll", "int", "GetSysColor", "int", 5) ; $COLOR_WINDOW = 5
$aNotify_Settings[0][2] = $aNotify_Ret[0]
; Use the defaults as current settings
For $i = 0 To UBound($aNotify_Settings, 2) - 1
	$aNotify_Settings[1][$i] = $aNotify_Settings[0][$i]
Next

; #CURRENT# ==========================================================================================================
; _Notify_Locate: Determine notification start position, direction of movement and maximum number
; _Notify_Set:    Sets justification, colours, font and display options for notifications
; _Notify_Show:   Shows a notification and optionally sets show/hide options
; _Notify_Hide:   Hides a notification programatically
; _Notify_RegMsg: Registers the WM_MOUSEACTIVATE message to enable retraction of the notification on clicking
; ====================================================================================================================

; #INTERNAL_USE_ONLY#=================================================================================================
; _Notify_Timer:            Checks whether a notification has timed out
; _Notify_WM_MOUSEACTIVATE: Message handler to check if notification clicked
; _Notify_Extend:           Extend a notification when initially shown in margin
; _Notify_Delete:           Retract a notification when timed out or clicked
; _Notify_Reset:            Reposition remaining notifications on screen
; _Notify_GetDefFont:       Determine system default MsgBox font
; _Notify_ShowPNG:          Set PNG as image
; _Notify_BitmapCreateDIB:  Create bitmap
; ====================================================================================================================

; #FUNCTION# =========================================================================================================
; Name...........: _Notify_Locate
; Description ...: Determine notification start position, direction of movement and maximum number
; Syntax ........: _Notify_Locate($iLocation)
; Parameters ....: $iLocation - Start point and direction for Notifications
;                              0 = Bottom right upwards (default)
;                              1 = Top right downwards
;                              2 = Top left downwards
;                              3 = Bottom left upwards
; Requirement(s).: v3.3.2.0 or higher - AdlibRegister/Unregister used in _Notify_Show
; Return values .: Success - Returns 1
;                 Failure - Returns 0 and sets @error as follows
;                           1 = Notificatiosn displayed
;                           2 = Invalid parameter
; Author ........: Melba23
; Remarks .......: This function will only set or reset the location if no notifications are displayed
; Example........: Yes
; ===============================================================================================================================
Func _Notify_Locate($iLocation = 0)

	; Can only reset notification location when no notifications are displayed
	If $aNotify_Data[0][0] Then
		Return SetError(1, 0, 0)
	EndIf

	; Check valid parameter
	Switch $iLocation
		Case 0 To 3
			$aNotify_Data[0][4] = $iLocation
		Case Else
			Return SetError(2, 0, 0)
	EndSwitch

	Local $tWorkArea
	; Determine which struct syntax to use to use
	If @AutoItVersion < "3.3.8.0" Then
		$tWorkArea = DllStructCreate("long Left;long Top;long Right;long Bottom")
	Else
		$tWorkArea = DllStructCreate("struct;long Left;long Top;long Right;long Bottom;endstruct")
	EndIf
	; Check if Taskbar is hidden
	Local $aRet = DllCall("shell32.dll", "uint", "SHAppBarMessage", "dword", 0x00000004, "ptr*", 0) ; $ABM_GETSTATE
	If BitAND($aRet[0], 0x01) Then

		; Set max number available
		$aNotify_Data[0][1] = Int((@DesktopHeight - 60) / 50)

		; Adjust data array depending on required location
		Switch $iLocation
			Case 0 ; From bottom right
				$aNotify_Data[0][3] = @DesktopHeight - 10 ; bottom Y
				$aNotify_Data[0][2] = @DesktopWidth - 10 ; right X
			Case 1 ; From top right
				$aNotify_Data[0][3] = 10 ; top Y
				$aNotify_Data[0][2] = @DesktopWidth - 10 ; right X
			Case 2 ; From top left
				$aNotify_Data[0][3] = 10 ; top Y
				$aNotify_Data[0][2] = 10 ; left X
			Case 3 ; From bottom left
				$aNotify_Data[0][3] = @DesktopHeight - 10 ; bottom Y
				$aNotify_Data[0][2] = 10 ; left X
		EndSwitch

	Else

		; Determine available work area ; $SPI_GETWORKAREA = 48
		DllCall("user32.dll", "bool", "SystemParametersInfoW", "uint", 48, "uint", 0, "ptr", DllStructGetPtr($tWorkArea), "uint", 0)
		If @error Then Return SetError(2, 0, -1)
		Local $aWorkArea[4] = [DllStructGetData($tWorkArea, "Left"), DllStructGetData($tWorkArea, "Top"), _
				DllStructGetData($tWorkArea, "Right"), DllStructGetData($tWorkArea, "Bottom")]

		; Set max number available
		$aNotify_Data[0][1] = Int(($aWorkArea[3] - $aWorkArea[1] - 60) / 50)

		; Adjust data array depending on required location
		Switch $iLocation
			Case 0 ; From bottom right
				$aNotify_Data[0][3] = $aWorkArea[3] - 10 ; bottom Y
				$aNotify_Data[0][2] = $aWorkArea[2] - 10 ; right X
			Case 1 ; From top right
				$aNotify_Data[0][3] = $aWorkArea[1] + 10 ; top Y
				$aNotify_Data[0][2] = $aWorkArea[2] - 10 ; right X
			Case 2 ; From top left
				$aNotify_Data[0][3] = $aWorkArea[1] + 10 ; top Y
				$aNotify_Data[0][2] = $aWorkArea[0] + 10 ; left X
			Case 3 ; From bottom left
				$aNotify_Data[0][3] = $aWorkArea[3] - 10 ; bottom Y
				$aNotify_Data[0][2] = $aWorkArea[0] + 10 ; left X
		EndSwitch

	EndIf

	Return 1

EndFunc   ;==>_Notify_Locate

; #FUNCTION# =========================================================================================================
; Name...........: _Notify_Set
; Description ...: Sets justification, colours, font and display options for notifications
; Syntax.........: _Notify_Set($vJust, [$iCol, [$iBkCol, [$iFont_Name, [$fSlide, [$iShow, [$iHide]]]]]])
; Parameters ....: $vJust    - 0 = Left justified, 1 = Centred (Default), 2 = Right justified
;                                  Can use $SS_LEFT, $SS_CENTER, $SS_RIGHT
;                              + 4 = Partial initial extension - click for full extension
;                      >>>>>    Setting this parameter to "Default" will reset ALL parameters to default values  <<<<<
;                 $iCol   -     [Optional] The colour for the notification text
;                 $iBkCol -     [Optional] The colour for the notification background
;                               Either colour parameter not set or -1 = Unchanged
;                               Either colour parameter = Default - Resets the system colour
;                 $sFont_Name - [Optional] The font to use for the notification
;                               Not set or "" = unchanged (default)
;                               Default - Resets the system message box font
;                 $fSlide -     [Optional] Movement of notifications into new position when one retracts
;                               False = Instant (default)
;                               True  = Slide
;                 £iShow  -     [Optional] Speed and type of display (minimum 250ms) - Default = 1000ms Slide
;                               Positive integer = Slide in time in ms
;                               Negative integer = Fade in time in ms
;                 £iHide  -     [Optional] Speed and type of retraction (minimum 250ms) - Default = 500ms Slide
;                               Positive integer = Slide out time in ms
;                               Negative integer = Fade out time in ms
; Requirement(s).: v3.3.2.0 or higher - AdlibRegister/Unregister used in _Notify_Show
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error to 1 with @extended set to parameter index number
; Author ........: Melba23
; Example........; Yes
;=====================================================================================================================
Func _Notify_Set($vJust, $iCol = -1, $iBkCol = -1, $sFont_Name = "", $fSlide = False, $iShow = Default, $iHide = Default)

	; Set parameters
	Select
		Case $vJust = Default
			; Do nothing ; $aNotify_Settings[1][7] = 0
		Case BitAND($vJust, 4)
			$aNotify_Settings[1][7] = 1
			$vJust -= 4
		Case Else
			$aNotify_Settings[1][7] = 0
	EndSelect

	Switch $vJust
		Case Default
			For $i = 0 To UBound($aNotify_Settings, 2) - 1
				$aNotify_Settings[1][$i] = $aNotify_Settings[0][$i]
			Next
			Return
		Case 0, 1, 2
			$aNotify_Settings[1][0] = $vJust
		Case Else
			Return SetError(1, 1, 0)
	EndSwitch

	Switch $iCol
		Case Default
			$aNotify_Settings[1][1] = $aNotify_Settings[0][1]
		Case 0 To 0xFFFFFF
			$aNotify_Settings[1][1] = $iCol
		Case -1
			; Do nothing
		Case Else
			Return SetError(1, 2, 0)
	EndSwitch

	Switch $iBkCol
		Case Default
			$aNotify_Settings[1][2] = $aNotify_Settings[0][2]
		Case 0 To 0xFFFFFF
			$aNotify_Settings[1][2] = $iBkCol
		Case -1
			; Do nothing
		Case Else
			Return SetError(1, 3, 0)
	EndSwitch

	Switch $sFont_Name
		Case Default
			$aNotify_Settings[1][3] = $aNotify_Settings[0][3]
		Case ""
			; Do nothing
		Case Else
			If IsString($sFont_Name) Then
				$aNotify_Settings[1][3] = $sFont_Name
			Else
				Return SetError(1, 4, 0)
			EndIf
	EndSwitch

	If $fSlide = True Then
		$aNotify_Settings[0][4] = True
	Else
		$aNotify_Settings[0][4] = False
	EndIf

	Select
		Case $iShow = Default
			$aNotify_Settings[1][5] = $aNotify_Settings[0][5]
		Case IsInt($iShow) = 0
			Return SetError(1, 6, 0)
		Case Abs($iShow) < 250
			If $iShow < 0 Then
				$aNotify_Settings[1][5] = -250
			Else
				$aNotify_Settings[1][5] = 250
			EndIf
		Case Else
			$aNotify_Settings[1][5] = $iShow
	EndSelect

	Select
		Case $iHide = Default
			$aNotify_Settings[1][6] = $aNotify_Settings[0][6]
		Case IsInt($iHide) = 0
			Return SetError(1, 7, 0)
		Case Abs($iHide) < 250
			If $iHide < 0 Then
				$aNotify_Settings[1][6] = -250
			Else
				$aNotify_Settings[1][6] = 250
			EndIf
		Case Else
			$aNotify_Settings[1][6] = $iHide
	EndSelect

	Return 1

EndFunc   ;==>_Notify_Set

; #FUNCTION# =========================================================================================================
; Name...........: _Notify_Show
; Description ...: Shows a notification and optionally sets show/hide options
; Syntax.........: _Notify_Show($vIcon, $sTitle, $sMessage, [$iDelay [, $iClick, [$iShow, [$iHide]]]])
; Parameters ....: $vIcon   - 0 - No icon, 8 - UAC, 16 - Stop, 32 - Query, 48 - Exclamation, 64 - Information
;                             The $MB_ICON constant can also be used for the last 4 above
;                             If set to the name of an exe, the main icon of that exe will be displayed
;                             If set to the name of an image file, that image will be displayed
;                             Any other value returns -1, error 1
;                 $sTitle   - Text to display as title in bold
;                 $sMessage - Text to display as message
;                             If $sTitle = "" then $sText can take 2 lines
;                 $iDelay   - The delay in seconds before the notification retracts (Default = 0 = Remains indefinitely)
;                 $iClick   - If notification will retact when clicked (Default = 1 = Clickable)
;                 £iShow    - [Optional] Speed and type of display (minimum 250ms) - will override current _Notify_Set setting
;                             Positive integer = Slide in time in ms
;                             Negative integer = Fade in time in ms
;                             Default = Use current _Notify_Set setting
;                 £iHide    - [Optional] Speed and type of retraction (minimum 250ms) - will override current _Notify_Set setting
;                             Positive integer = Slide out time in ms
;                             Negative integer = Fade out time in ms
;                             Default = Use current _Notify_Set setting
; Requirement(s).: v3.3.1.5 or higher - AdlibRegister/Unregister used in _Notify_Show
; Return values .: Success: Returns the handle of the Notification
;                  Failure: Returns -1 and sets @error as follows:
;                          1 = Maximum number of notification that can be displayed
;                          2 = Icon parameter invalid
;                          3 = Other parameter invalid (@extended 1=$iDelay, 2=$iClick, 3=$iShow, 4=$iHide)
;                          4 = StringSize error
;                          5 = Title/text will not fit in widest message (@extended = 0/1 = Title/Text)
;                          6 = Notification GUI creation failed
; Author ........: Melba23
; Notes .........;
; Example........; Yes
;=====================================================================================================================
Func _Notify_Show($vIcon, $sTitle, $sMessage, $iDelay = 0, $iClick = 1, $iShow = Default, $iHide = Default)

	; Check for space to show
	If $aNotify_Data[0][0] = $aNotify_Data[0][1] Then
		Return SetError(1, 0, -1)
	EndIf

	Local $aLabel_Pos, $iLabel_Width, $iLabel_Height = 20

	; Set default auto-sizing Notify dimensions
	Local $iNotify_Width_max = 300
	Local $iNotify_Width_min = 150
	Local $iNotify_Height = 40

	; Check for icon
	Local $iIcon_Style = 0
	Local $iIcon_Reduction = 36
	Local $sDLL = "user32.dll"
	Local $sImg = ""
	If StringIsDigit($vIcon) Then
		Switch $vIcon
			Case 0
				$iIcon_Reduction = 0
			Case 8
				$sDLL = "imageres.dll"
				$iIcon_Style = 78
			Case 16 ; Stop
				$iIcon_Style = -4
			Case 32 ; Query
				$iIcon_Style = -3
			Case 48 ; Exclam
				$iIcon_Style = -2
			Case 64 ; Info
				$iIcon_Style = -5
			Case Else
				Return SetError(1, 0, -1)
		EndSwitch
	Else
		Switch StringLower(StringRight($vIcon, 3))
			Case "exe", "ico"
				$sDLL = $vIcon
				$iIcon_Style = 0
			Case "bmp", "jpg", "gif", "png"
				$sImg = $vIcon
		EndSwitch
	EndIf

	; Check other parameters
	If $iDelay < 0 Then
		Return SetError(3, 1, -1)
	Else
		$iDelay = Int($iDelay)
	EndIf
	Switch $iClick
		Case 0, 1
			; Valid
		Case Else
			Return SetError(3, 2, -1)
	EndSwitch
	Select
		Case $iShow = Default
			$iShow = $aNotify_Settings[1][5]
		Case IsInt($iShow) = 0
			Return SetError(3, 3, -1)
		Case Abs($iShow) < 250
			If $iShow < 0 Then
				$iShow = -250
			Else
				$iShow = 250
			EndIf
	EndSelect
	Select
		Case $iHide = Default
			$iHide = $aNotify_Settings[1][6]
		Case IsInt($iHide) = 0
			Return SetError(3, 4, -1)
		Case Abs($iHide) < 250
			If $iHide < 0 Then
				$iHide = -250
			Else
				$iHide = 250
			EndIf
	EndSelect

	; Determine max message width
	Local $iMax_Label_Width = $iNotify_Width_max - $iIcon_Reduction - 8

	; Get text size
	If $sTitle Then
		; Measure title (bold font)
		$aLabel_Pos = _StringSize($sTitle, 9, 800, Default, $aNotify_Settings[1][3])
		If @error Then
			Return SetError(4, 0, -1)
		EndIf
		; Check fits horizontally
		If $aLabel_Pos[2] > $iMax_Label_Width Then
			Return SetError(5, 0, -1)
		Else
			; Set width required
			$iLabel_Width = $aLabel_Pos[2]
		EndIf
		; Measure message
		$aLabel_Pos = _StringSize($sMessage, 9, Default, Default, $aNotify_Settings[1][3])
		If @error Then
			Return SetError(4, 0, -1)
		EndIf
		; Check fits horizontally
		If $aLabel_Pos[2] > $iMax_Label_Width Then
			Return SetError(5, 1, -1)
		Else
			; Adjust width required if needed
			If $aLabel_Pos[2] > $iLabel_Width Then
				$iLabel_Width = $aLabel_Pos[2]
			EndIf
		EndIf
	Else
		; Measure message
		$aLabel_Pos = _StringSize($sMessage, 9, Default, Default, $aNotify_Settings[1][3], $iMax_Label_Width)
		If @error Then
			Return SetError(4, 0, -1)
		EndIf
		; If wrapped check still fits vertically
		If $aLabel_Pos[3] > 40 Then
			Return SetError(5, 1, -1)
		EndIf
		; Check fits horizontally
		If $aLabel_Pos[2] > $iMax_Label_Width Then
			Return SetError(5, 1, -1)
		Else
			; Set Notification size and label position
			If $aLabel_Pos[2] > $iLabel_Width Then
				$iLabel_Width = $aLabel_Pos[2]
			EndIf
			$sMessage = $aLabel_Pos[0]
			; Adjust vertical position to centre lines
			Local $iLabel_Y = Int((40 - $aLabel_Pos[3]) / 2)
		EndIf
	EndIf

	; Set Notify size
	Local $iNotify_Width = $iLabel_Width + 8 + $iIcon_Reduction

	; Increase if below min size
	If $iNotify_Width < $iNotify_Width_min + $iIcon_Reduction Then
		$iNotify_Width = $iNotify_Width_min + $iIcon_Reduction
		$iLabel_Width = $iNotify_Width_min - 8
	EndIf

	; Set Notify coords depending on location
	Local $iNotify_X, $iNotify_Y, $iFinal_X = 0
	Switch $aNotify_Data[0][4]
		Case 0 ; From bottom right
			If $aNotify_Settings[1][7] Then
				$iNotify_X = @DesktopWidth - 10
				$iFinal_X = $aNotify_Data[0][2] - $iNotify_Width
			Else
				$iNotify_X = $aNotify_Data[0][2] - $iNotify_Width
			EndIf
			$iNotify_Y = $aNotify_Data[0][3] - (50 * ($aNotify_Data[0][0] + 1))
		Case 1 ; From top right
			If $aNotify_Settings[1][7] Then
				$iNotify_X = @DesktopWidth - 10
				$iFinal_X = $aNotify_Data[0][2] - $iNotify_Width
			Else
				$iNotify_X = $aNotify_Data[0][2] - $iNotify_Width
			EndIf
			$iNotify_Y = $aNotify_Data[0][3] + (50 * ($aNotify_Data[0][0]))
		Case 2 ; From top left
			If $aNotify_Settings[1][7] Then
				$iNotify_X = -($iNotify_Width - 10)
				$iFinal_X = $aNotify_Data[0][2]
			Else
				$iNotify_X = $aNotify_Data[0][2]
			EndIf
			$iNotify_Y = $aNotify_Data[0][3] + (50 * ($aNotify_Data[0][0]))
		Case 3 ; From bottom left
			If $aNotify_Settings[1][7] Then
				$iNotify_X = -($iNotify_Width - 10)
				$iFinal_X = $aNotify_Data[0][2]
			Else
				$iNotify_X = $aNotify_Data[0][2]
			EndIf
			$iNotify_Y = $aNotify_Data[0][3] - (50 * ($aNotify_Data[0][0] + 1))
	EndSwitch

	; Create Notify slice with $WS_POPUPWINDOW style and $WS_EX_TOOLWINDOW, $WS_EX_TOPMOST and $WS_EX_STATICEDGE extended style
	Local $hNotify_Handle = GUICreate("", $iNotify_Width, $iNotify_Height, $iNotify_X, $iNotify_Y, 0x80880000, BitOR(0x00020000, 0x00000080, 0x00000008))
	If @error Then
		Return SetError(6, 0, -1)
	EndIf
	GUISetBkColor($aNotify_Settings[1][2])

	; Create icon
	If $iIcon_Reduction Then
		Switch StringLower(StringRight($sImg, 3))
			Case "bmp", "jpg", "gif"
				GUICtrlCreatePic($sImg, 4, 4, 32, 32)
			Case "png"
				_Notify_ShowPNG($sImg)
			Case Else
				GUICtrlCreateIcon($sDLL, $iIcon_Style, 4, 4)
		EndSwitch
	EndIf

	; Create labels
	If $sTitle Then
		; Title
		GUICtrlCreateLabel($sTitle, 4 + $iIcon_Reduction, 0, $iLabel_Width, $iLabel_Height)
		GUICtrlSetFont(-1, 9, 800, 0, $aNotify_Settings[1][3])
		GUICtrlSetBkColor(-1, $aNotify_Settings[1][2])
		GUICtrlSetColor(-1, $aNotify_Settings[1][1])
		GUICtrlSetStyle(-1, $aNotify_Settings[1][0])
		; Message
		GUICtrlCreateLabel($sMessage, 4 + $iIcon_Reduction, 20, $iLabel_Width, $iLabel_Height)
		GUICtrlSetFont(-1, 9, 400, 0, $aNotify_Settings[1][3])
		GUICtrlSetBkColor(-1, $aNotify_Settings[1][2])
		GUICtrlSetColor(-1, $aNotify_Settings[1][1])
		GUICtrlSetStyle(-1, $aNotify_Settings[1][0])
	Else
		; Message
		GUICtrlCreateLabel($sMessage, 4 + $iIcon_Reduction, $iLabel_Y, $iLabel_Width, 40 - $iLabel_Y)
		GUICtrlSetFont(-1, 9, 400, 0, $aNotify_Settings[1][3])
		GUICtrlSetBkColor(-1, $aNotify_Settings[1][2])
		GUICtrlSetColor(-1, $aNotify_Settings[1][1])
		GUICtrlSetStyle(-1, $aNotify_Settings[1][0])
	EndIf

	; Slide/Fade Notify Slice into view and activate
	If Not $aNotify_Settings[1][7] Then
		Local $iTime = Abs($iShow)
		If $iShow >= 0 Then
			Switch $aNotify_Data[0][4]
				Case 0, 1
					DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $hNotify_Handle, "int", $iTime, "long", 0x00040002) ; $AW_SLIDE_IN_RIGHT
				Case 2, 3
					DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $hNotify_Handle, "int", $iTime, "long", 0x00040001) ; $AW_SLIDE_IN_LEFT
			EndSwitch
		Else
			DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $hNotify_Handle, "int", $iTime, "long", 0x00080000) ; $AW_FADE_IN
		EndIf
	EndIf

	; Activate Notify without stealing focus
	GUISetState(@SW_SHOWNOACTIVATE, $hNotify_Handle)

	; Store Notify data
	$aNotify_Data[0][0] += 1
	ReDim $aNotify_Data[$aNotify_Data[0][0] + 1][7]
	$aNotify_Data[$aNotify_Data[0][0]][0] = $hNotify_Handle
	$aNotify_Data[$aNotify_Data[0][0]][1] = $iDelay * 1000
	$aNotify_Data[$aNotify_Data[0][0]][2] = TimerInit()
	$aNotify_Data[$aNotify_Data[0][0]][3] = $iClick
	$aNotify_Data[$aNotify_Data[0][0]][4] = $iNotify_X
	$aNotify_Data[$aNotify_Data[0][0]][5] = $iFinal_X
	$aNotify_Data[$aNotify_Data[0][0]][6] = $iHide

	; Start Adlib function for Notify retraction
	If $aNotify_Data[0][0] = 1 Then
		AdlibRegister("_Notify_Timer", 1000)
	EndIf

	Return $hNotify_Handle

EndFunc   ;==>_Notify_Show

; #FUNCTION# =========================================================================================================
; Name...........: _Notify_Hide
; Description ...: Hide a notification
; Syntax.........: _Notify_Show($hWnd)
; Parameters ....: None
; Requirement(s).: v3.3.1.5 or higher - AdlibRegister/Unregister used in _Notify_Show
; Return values .: Success: Returns 1
;                  Failure:  Returns 0 and sets @error as follows:
;                          1 = Invalid handle passed
;                          2 = Handle not found in Notification array
; Author ........: Melba23
; Notes .........;
; Example........; Yes
;=====================================================================================================================
Func _Notify_Hide($hWnd)

	; Check for valid handle
	If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0)

	; Look for handle in array
	For $i = 1 To $aNotify_Data[0][0]
		If $aNotify_Data[$i][0] = $hWnd Then
			$aNotify_Data[0][5] = $i
			; If found then retract
			_Notify_Delete()
			_Notify_Reset()
			Return 1
		EndIf
	Next

	; Handle was not found
	Return SetError(2, 0, 0)

EndFunc   ;==>_Notify_Hide

; #FUNCTION# =========================================================================================================
; Name...........: _Notify_RegMsg
; Description ...: Registers WM_MOUSEACTIVATE message needed for the UDF
; Syntax.........: _Notify_RegMsg()
; Parameters ....: None
; Requirement(s).: v3.3.1.5 or higher - AdlibRegister/Unregister used in _Notify_Show
; Return values .: None
; Author ........: Melba23
; Modified ......:
; Remarks .......: If another WM_MOUSEACTIVATE handler already registered, call the _Notify_WM_MOUSEACTIVATE handler
;                 function from within that handler
;                 If notifications not to retract when clicked the WM_MOUSEACTIVATE message need not be registered
; Example........: Yes
;=====================================================================================================================
Func _Notify_RegMsg()

	GUIRegisterMsg(0x0021, "_Notify_WM_MOUSEACTIVATE") ; $WM_MOUSEACTIVATE
	$aNotify_Data[0][4] = 1

EndFunc   ;==>_Notify_RegMsg

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Notify_Timer
; Description ...: Checks whether a notification has timed out
; Syntax ........: _Notify_Timer()
; Author ........: Melba23
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func _Notify_Timer()

	; Check if other retractions occuring
	If $aNotify_RetractMode[1] Then
		Return
	EndIf
	If $aNotify_RetractMode[0] Then
		Return
	EndIf

	; Set Prevent simultaneous click
	$aNotify_RetractMode[0] = True

	; Pause Adlib as retraction and movement could overrun delay time
	AdlibUnRegister("_Notify_Timer")

	; Run through notifications
	For $i = $aNotify_Data[0][0] To 1 Step -1
		; Check timer if needed
		If $aNotify_Data[$i][1] And TimerDiff($aNotify_Data[$i][2]) > $aNotify_Data[$i][1] Then
			$aNotify_Data[0][5] = $i
			_Notify_Delete()
			_Notify_Reset()
			ExitLoop
		EndIf
	Next

	; Restart Adlib if needed
	If $aNotify_Data[0][0] Then
		AdlibRegister("_Notify_Timer", 1000)
	EndIf
	; Re-enable clicks
	$aNotify_RetractMode[0] = False

EndFunc   ;==>_Notify_Timer

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Notify_WM_MOUSEACTIVATE
; Description ...: Message handler to check if notification clicked
; Syntax ........: _Notify_WM_MOUSEACTIVATE($hWnd, $Msg, $wParam, $lParam)
; Parameters ....: Standard message handler parameters
; Author ........: Melba23
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func _Notify_WM_MOUSEACTIVATE($hWnd, $iMsg, $wParam, $lParam)

	#forceref $iMsg, $wParam, $lParam

	; Check timer is not checking
	If $aNotify_RetractMode[0] Then
		Return
	EndIf
	; Check handler not already retracting
	If $aNotify_RetractMode[1] Then
		Return
	EndIf
	; Set flag to show handler retracting
	$aNotify_RetractMode[1] = True

	For $i = $aNotify_Data[0][0] To 1 Step -1
		; Is it a click on a notification?
		If $hWnd = $aNotify_Data[$i][0] Then
			$aNotify_Data[0][5] = $i
			If $aNotify_Data[$i][5] Then
				; Extend the notification
				AdlibRegister("_Notify_Extend", 100)
			Else
				; Delete the notification if clickable
				If $aNotify_Data[$i][3] Then
					AdlibRegister("_Notify_Delete", 100)
				EndIf
			EndIf
			ExitLoop
		EndIf
	Next

	; Clear Running flag
	$aNotify_RetractMode[1] = False

	Return "GUI_RUNDEFMSG"

EndFunc   ;==>_Notify_WM_MOUSEACTIVATE

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Notify_Extend
; Description ...: Extend a notification when initially shown in margin
; Syntax ........: _Notify_Extend()
; Parameters ....: Nove
; Author ........: Melba23
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func _Notify_Extend()

	; Check if retractions occuring
	If $aNotify_RetractMode[1] Then
		Return
	EndIf
	If $aNotify_RetractMode[0] Then
		Return
	EndIf

	; Cancel the Adlib call
	AdlibUnRegister("_Notify_Extend")

	; Read index
	Local $i = $aNotify_Data[0][5]

	; Hide notification
	GUISetState(@SW_HIDE, $aNotify_Data[$i][0])
	; Move it to final position
	Switch $aNotify_Data[0][4]
		Case 0, 3
			WinMove($aNotify_Data[$i][0], "", $aNotify_Data[$i][5], $aNotify_Data[0][3] - (50 * $i))
		Case 1, 2
			WinMove($aNotify_Data[$i][0], "", $aNotify_Data[$i][5], $aNotify_Data[0][3] + (50 * ($i - 1)))
	EndSwitch
	; Slide into place
	Switch $aNotify_Data[0][4]
		Case 0, 1
			DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $aNotify_Data[$i][0], "int", $aNotify_Settings[1][5], "long", 0x00040002) ; $AW_SLIDE_IN_RIGHT
		Case 2, 3
			DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $aNotify_Data[$i][0], "int", $aNotify_Settings[1][5], "long", 0x00040001) ; $AW_SLIDE_IN_LEFT
	EndSwitch
	; Reset position data
	$aNotify_Data[$i][4] = $aNotify_Data[$i][5]
	$aNotify_Data[$i][5] = 0

EndFunc   ;==>_Notify_Extend

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Notify_Delete
; Description ...: Retract a notification when timed out or clicked
; Syntax ........: _Notify_Delete()
; Parameters ....: None
; Author ........: Melba23
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func _Notify_Delete()

	; Cancel Adlib call
	AdlibUnRegister("_Notify_Delete")

	; Read index
	Local $i = $aNotify_Data[0][5]

	; Retract/Fade and delete notification
	Local $iTime = Abs($aNotify_Data[$i][6])
	If $aNotify_Data[$i][6] > 0 Then
		Switch $aNotify_Data[0][4]
			Case 0, 1
				DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $aNotify_Data[$i][0], "int", $iTime, "long", 0x00050001) ; $AW_SLIDE_OUT_RIGHT
			Case 2, 3
				DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $aNotify_Data[$i][0], "int", $iTime, "long", 0x00050002) ; $AW_SLIDE_OUT_LEFT
		EndSwitch
	Else
		DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $aNotify_Data[$i][0], "int", $iTime, "long", 0x00090000) ; $AW_FADE_OUT
	EndIf
	GUIDelete($aNotify_Data[$i][0])
	; Adjust array
	For $j = $i + 1 To $aNotify_Data[0][0]
		For $k = 0 To UBound($aNotify_Data, 2) - 1
			$aNotify_Data[$j - 1][$k] = $aNotify_Data[$j][$k]
		Next
	Next
	ReDim $aNotify_Data[$aNotify_Data[0][0]][7]
	$aNotify_Data[0][0] -= 1

	; Cancel timer if not needed
	If $aNotify_Data[0][0] = 0 Then
		AdlibUnRegister("_Notify_Timer")
	Else
		; Adjust positions of Notifications
		_Notify_Reset()
	EndIf

EndFunc   ;==>_Notify_Delete

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Notify_Reset
; Description ...: Reposition remaining notifications on screen
; Syntax ........: _Notify_Reset()
; Parameters ....: None
; Author ........: Melba23
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func _Notify_Reset()

	; Read index
	Local $iIndex = $aNotify_Data[0][5]

	If $aNotify_Settings[0][4] Then
		; Set step size depending on number of notifications to move
		Local $iStep = 1 + Int(($aNotify_Data[0][0] - $iIndex) / 3)
		; Slide notifications into new positions depending on location
		Switch $aNotify_Data[0][4]
			Case 0, 3
				For $j = 1 To 50 Step $iStep
					For $i = $iIndex To $aNotify_Data[0][0]
						WinMove($aNotify_Data[$i][0], "", $aNotify_Data[$i][4], $aNotify_Data[0][3] - (50 * ($i + 1)) + $j)
					Next
				Next
			Case 1, 2
				For $j = 1 To 50 Step $iStep
					For $i = $iIndex To $aNotify_Data[0][0]
						WinMove($aNotify_Data[$i][0], "", $aNotify_Data[$i][4], $aNotify_Data[0][3] + (50 * $i) - $j)
					Next
				Next
		EndSwitch
	Else
		; Move notifications into new positions instantly depending on location
		Switch $aNotify_Data[0][4]
			Case 0, 3
				For $i = 1 To $aNotify_Data[0][0]
					WinMove($aNotify_Data[$i][0], "", $aNotify_Data[$i][4], $aNotify_Data[0][3] - (50 * $i))
				Next
			Case 1, 2
				For $i = 1 To $aNotify_Data[0][0]
					WinMove($aNotify_Data[$i][0], "", $aNotify_Data[$i][4], $aNotify_Data[0][3] + (50 * ($i - 1)))
				Next
		EndSwitch
	EndIf

EndFunc   ;==>_Notify_Reset

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Notify_GetDefFont
; Description ...: Determine system default MsgBox font
; Syntax ........: _Notify_GetDefFont()
; Parameters ....: None
; Author ........: Melba23
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func _Notify_GetDefFont()

	; Get default system font data
	Local $tNONCLIENTMETRICS = DllStructCreate("uint;int;int;int;int;int;byte[60];int;int;byte[60];int;int;byte[60];byte[60];byte[60]")
	DllStructSetData($tNONCLIENTMETRICS, 1, DllStructGetSize($tNONCLIENTMETRICS))
	DllCall("user32.dll", "int", "SystemParametersInfo", "int", 41, "int", DllStructGetSize($tNONCLIENTMETRICS), "ptr", DllStructGetPtr($tNONCLIENTMETRICS), "int", 0)
	; Read font data for MsgBox font
	Local $tLOGFONT = DllStructCreate("long;long;long;long;long;byte;byte;byte;byte;byte;byte;byte;byte;char[32]", DllStructGetPtr($tNONCLIENTMETRICS, 15))
	; Font name
	Return DllStructGetData($tLOGFONT, 14)

EndFunc   ;==>_Notify_GetDefFont

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Notify_ShowPNG
; Description ...: Set PNG as image
; Syntax ........: _Notify_ShowPNG($sImg)
; Parameters ....: $sImg - Path of image file
; Author ........: UEZ
; Modified.......: Melba23
; Remarks .......:
; ===============================================================================================================================
Func _Notify_ShowPNG($sImg)

	_GDIPlus_Startup()
	Local $hPic = GUICtrlCreatePic("", 4, 4, 32, 32)
	Local $hBitmap = _GDIPlus_BitmapCreateFromFile($sImg)
	Local $aResult = DllCall($ghGDIPDll, "uint", "GdipCreateBitmapFromScan0", "int", 32, "int", 32, "int", 0, "int", 0x0026200A, "ptr", 0, "int*", 0)
	Local $hBitmap_Resized = $aResult[6]
	Local $hBMP_Ctxt = _GDIPlus_ImageGetGraphicsContext($hBitmap_Resized)
	DllCall($ghGDIPDll, "uint", "GdipSetInterpolationMode", "handle", $hBMP_Ctxt, "int", 7)
	_GDIPlus_GraphicsDrawImageRect($hBMP_Ctxt, $hBitmap, 0, 0, 32, 32)
	Local $hHBitmap = _Notify_BitmapCreateDIB($hBitmap_Resized)
	_WinAPI_DeleteObject(GUICtrlSendMsg($hPic, 0x0172, 0, $hHBitmap))
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_BitmapDispose($hBitmap_Resized)
	_GDIPlus_GraphicsDispose($hBMP_Ctxt)
	_WinAPI_DeleteObject($hHBitmap)
	_GDIPlus_Shutdown()

EndFunc   ;==>_Notify_ShowPNG

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _Notify_BitmapCreateDIB
; Description ...: Create bitmap
; Syntax ........: _Notify_BitmapCreateDIB($hBitmap)
; Parameters ....: $hBitmap - Handle of bitmap
; Author ........: UEZ
; Modified.......:
; Remarks .......:
; ===============================================================================================================================
Func _Notify_BitmapCreateDIB($hBitmap)

	Local $hRet = 0

	Local $aRet1 = DllCall($ghGDIPDll, "uint", "GdipGetImageDimension", "ptr", $hBitmap, "float*", 0, "float*", 0)
	If (@error) Or ($aRet1[0]) Then Return 0
	Local $tData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $aRet1[2], $aRet1[3], $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	Local $pBits = DllStructGetData($tData, "Scan0")
	If Not $pBits Then Return 0
	Local $tBIHDR = DllStructCreate("dword;long;long;ushort;ushort;dword;dword;long;long;dword;dword")
	DllStructSetData($tBIHDR, 1, DllStructGetSize($tBIHDR))
	DllStructSetData($tBIHDR, 2, $aRet1[2])
	DllStructSetData($tBIHDR, 3, $aRet1[3])
	DllStructSetData($tBIHDR, 4, 1)
	DllStructSetData($tBIHDR, 5, 32)
	DllStructSetData($tBIHDR, 6, 0)
	Local $aRet2 = DllCall("gdi32.dll", "ptr", "CreateDIBSection", "hwnd", 0, "ptr", DllStructGetPtr($tBIHDR), "uint", 0, "ptr*", 0, "ptr", 0, "dword", 0)
	If (Not @error) And ($aRet2[0]) Then
		DllCall("gdi32.dll", "dword", "SetBitmapBits", "ptr", $aRet2[0], "dword", $aRet1[2] * $aRet1[3] * 4, "ptr", DllStructGetData($tData, "Scan0"))
		$hRet = $aRet2[0]
	EndIf
	_GDIPlus_BitmapUnlockBits($hBitmap, $tData)
	Return $hRet
EndFunc   ;==>_Notify_BitmapCreateDIB