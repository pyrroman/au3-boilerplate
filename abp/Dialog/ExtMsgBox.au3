#include-once

; #INDEX# ============================================================================================================
; Title .........: ExtMsgBox
; AutoIt Version : v3.2.12.1 or higher
; Language ......: English
; Description ...: Generates user defined message boxes centred on an owner, on screen or at defined coordinates
; Remarks .......:
; Note ..........:
; Author(s) .....: Melba23, based on some original code by photonbuddy & YellowLab, and KaFu (default font data)
; ====================================================================================================================

;#AutoIt3Wrapper_au3check_parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w- 7

; #INCLUDES# =========================================================================================================
#include "StringSize.au3"

; #GLOBAL CONSTANTS# =================================================================================================
Global Const $EMB_ICONSTOP   = 16 ; Stop-sign icon
Global Const $EMB_ICONQUERY  = 32 ; Question-mark icon
Global Const $EMB_ICONEXCLAM = 48 ; Exclamation-point icon
Global Const $EMB_ICONINFO   = 64 ; Icon consisting of an 'i' in a circle

; #GLOBAL VARIABLES# =================================================================================================
; Default settings
Global $aEMB_DllCall_Ret = _EMB_GetDefaultFont()
Global $iEMB_Def_Font_Size = $aEMB_DllCall_Ret[0]
Global $iEMB_Def_Font_Name = $aEMB_DllCall_Ret[1]
$aEMB_DllCall_Ret = DllCall("User32.dll", "int", "GetSysColor", "int", 15) ; $COLOR_3DFACE = 15
Global $iEMB_Def_BkCol = BitAND(BitShift(String(Binary($aEMB_DllCall_Ret[0])), 8), 0xFFFFFF)
$aEMB_DllCall_Ret   = DllCall("User32.dll", "int", "GetSysColor", "int", 8) ; $COLOR_WINDOWTEXT = 8
Global $iEMB_Def_Col = BitAND(BitShift(String(Binary($aEMB_DllCall_Ret[0])), 8), 0xFFFFFF)
$aEMB_DllCall_Ret = 0
; Current settings
Global $iEMB_Style = 0
Global $iEMB_Just  = 0
Global $iEMB_BkCol = $iEMB_Def_BkCol
Global $iEMB_Col   = $iEMB_Def_Col
Global $sEMB_Font_Name = $iEMB_Def_Font_Name
Global $iEMB_Font_Size = $iEMB_Def_Font_Size

; #CURRENT# ==========================================================================================================
; _ExtMsgBoxSet: Sets the GUI style, justification, colours and font for subsequent _ExtMsgBox function calls
; _ExtMsgBox:    Generates user defined message boxes centred on an owner, on screen or at defined coordinates
; ====================================================================================================================

; #INTERNAL_USE_ONLY#=================================================================================================
; _EMB_GetDefaultFont: Determines Windows default MsgBox font size and name
; ====================================================================================================================

; #FUNCTION# =========================================================================================================
; Name...........: _ExtMsgBoxSet
; Description ...: Sets the GUI style, justification, colours and font for subsequent _ExtMsgBox function calls
; Syntax.........: _ExtMsgBoxSet($iStyle, $iJust, [$iBkCol, [$iCol, [$sFont_Size, [$iFont_Name]]]])
; Parameters ....: $iStyle      -> 0 (Default) - Taskbar Button, TOPMOST, button in user font, no tab expansion, no checkbox
;                                  Combine following to change:
;                                   1  = Button does not appear on TaskBar
;                                   2  = TOPMOST Style not set
;                                   4  = Buttons use default font
;                                   8  = Expand Tabs to ensure adequate sizing of GUI
;                                   16 = "Do not display again" checkbox
;                                   32 = Show no icon on title bar
;                                   64 = Disable EMB closure [X] and SysMenu Close
;                   >>>>>>>>>>     Setting this parameter to 'Default' will reset ALL parameters to default values <<<<
;                   $iJust      -> 0 = Left justified (Default), 1 = Centred , 2 = Right justified
;                                  + 4 = Centred single button.  Note: multiple buttons are always centred
;                                  ($SS_LEFT, $SS_CENTER, $SS_RIGHT can also be used)
;                   $iBkCol		-> The colour for the message box background.  Default = system colour
;                   $iCol		-> The colour for the message box text.  Default = system colour
;                                  Omitting a colour parameter or setting -1 leaves it unchanged
;                                  Setting a colour parameter to Default resets the system message box colour
;                   $iFont_Size -> The font size in points to use for the message box. Default = system font size
;                   $sFont_Name -> The font to use for the message box. Default = system font
;                                  Omitting a font parameter or setting font size to -1 or font name to "" = unchanged
;                                  Setting a font parameter to Default resets the system message box font and size
; Requirement(s).: v3.2.12.1 or higher
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error to 1 with @extended set to parameter index number
; Remarks .......;
; Author ........: Melba23
; Example........; Yes
;=====================================================================================================================
Func _ExtMsgBoxSet($iStyle = 0, $iJust = 0, $iBkCol = -1, $iCol = -1, $iFont_Size = -1, $sFont_Name = "")

	; Set global EMB variables to required values
	Switch $iStyle
		Case Default
			$iEMB_Style = 0 ; Button on TaskBar and $WS_EX_TOPMOST
			$iEMB_Just = 0 ; $SS_LEFT
			$iEMB_BkCol = $iEMB_Def_BkCol
			$iEMB_Col = $iEMB_Def_Col
			$sEMB_Font_Name = $iEMB_Def_Font_Name
			$iEMB_Font_Size = $iEMB_Def_Font_Size
			Return
		Case 0 To 127
			$iEMB_Style = $iStyle
		Case Else
			Return SetError(1, 1, 0)
	EndSwitch

	Switch $iJust
		Case 0, 1, 2, 4, 5, 6
			$iEMB_Just = $iJust
		Case Else
			Return SetError(1, 2, 0)
	EndSwitch

	Switch $iBkCol
		Case Default
			$iEMB_BkCol = $iEMB_Def_BkCol
		Case -1
			; Do nothing
		Case 0 To 0xFFFFFF
			$iEMB_BkCol = $iBkCol
		Case Else
			Return SetError(1, 3, 0)
	EndSwitch

	Switch $iCol
		Case Default
			$iEMB_Col = $iEMB_Def_Col
		Case -1
			; Do nothing
		Case 0 To 0xFFFFFF
			$iEMB_Col = $iCol
		Case Else
			Return SetError(1, 4, 0)
	EndSwitch

	Switch $iFont_Size
		Case Default
			$iEMB_Font_Size = $iEMB_Def_Font_Size
		Case 8 To 72
			$iEMB_Font_Size = Int($iFont_Size)
        Case -1
			; Do nothing
		Case Else
			Return SetError(1, 5, 0)
	EndSwitch

	Switch $sFont_Name
		Case Default
			$sEMB_Font_Name = $iEMB_Def_Font_Name
		Case ""
			; Do nothing
		Case Else
			If IsString($sFont_Name) Then
				$sEMB_Font_Name = $sFont_Name
			Else
				Return SetError(1, 6, 0)
			EndIf
	EndSwitch

	Return 1

EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _ExtMsgBox
; Description ...: Generates user defined message boxes centred on an owner, on screen or at defined coordinates
; Syntax.........: _ExtMsgBox ($vIcon, $vButton, $sTitle, $sText, [$iTimeout, [$hWin, [$iVPos]]])
; Parameters ....: $vIcon		-> The icon to use: 0 - No icon, 8 - UAC, or a $MB/$EMB_ICON constant as follows
;                                  16 - Stop, 32 - Query, 48 - Exclamation, 64 - Information
;                                  128 - Countdown if $iTimeout set
;                                  Any other numeric value returns -1, error 1
;                                  If set to the name of an exe, the main icon of that exe will be displayed
;                                  If set to the name of an icon, the icon will be displayed
;                   $vButton	-> Button text separated with "|" character. " " = no buttons
;                                  An ampersand (&) before the text indicates the default button.
;                                  Two focus ampersands returns -1, error 2. A single button is always default
;                                  Pressing Enter or Space fires default button
;                                  Can also use $MB_ button numeric constants: 0 = "OK", 1 = "&OK|Cancel",
;                                  2 = "&Abort|Retry|Ignore", 3 = "&Yes|No|Cancel", 4 = "&Yes|No", 5 = "&Retry|Cancel",
;                                  6 = "&Cancel|Try Again|Continue".  Other values return -1, error 3
;                                  Default max width of 370 gives 1-4 buttons @ width 80, 5 @ width 60, 6 @ width 50
;                                  Min button width set at 50, so unless default changed 7 buttons returns -1, error 4
;                   $sTitle		-> The title of the message box
;                   $sText		-> The text to be displayed. Long lines will wrap. The box depth is adjusted to fit
;                                  The preset max width can increase to a preset absolute value if required
;                   $iTimeout	-> Timeout delay before EMB closes. 0 = no timeout (Default)
;                                  If no buttons and no timeout set, delay automatically set to 5
;                   $hWin		-> Handle of the window in which EMB is centred
;                                  If window is hidden or no handle passed EMB centred in display (Default)
;                                  If parameter does not hold valid window handle, it is interpreted as horizontal
;                                  coordinate for EMB location
;                   $iVPos      -> Vertical coordinate for EMB location, only if $hWin parameter is
;                                  interpreted as horizontal coordinate.  (Default = 0)
; Requirement(s).: v3.2.12.1 or higher
; Return values .: Success:	Returns 1-based index of the button pressed, counting from the LEFT.
;                           Returns 0 if closed by a "CloseGUI" event (i.e. click [X] or press Escape)
;                           Returns 9 if timed out
;                           If "Not again" checkbox is present and checked, return value is negated
;                  Failure:	Returns -1 and sets @error as follows:
;                               1 - Icon error
;                               2 - Multiple default button error
;                               3 - Button constant error
;                               4 - Too many buttons to fit max GUI size
;                               5 - StringSize error
;                               6 - GUI creation error
; Remarks .......; EMB position automatically adjusted to appear on screen
; Author ........: Melba23, based on some original code by photonbuddy & YellowLab
; Example........; Yes
;=====================================================================================================================
Func _ExtMsgBox($vIcon, $vButton, $sTitle, $sText, $iTimeOut = 0, $hWin = "", $iVPos = 0)

	Local $iParent_Win = 0, $fCountdown = False, $cCheckbox, $aLabel_Size


	; Set default sizes for message box
	Local $iMsg_Width_max = 370, $iMsg_Width_min = 150, $iMsg_Width_abs = 500
	Local $iMsg_Height_min = 100
	Local $iButton_Width_max = 80, $iButton_Width_min = 50

	; Declare local variables
	Local $iButton_Width_Req, $iButton_Width, $iButton_Xpos, $iRet_Value, $iHpos

	; Validate timeout value
	$iTimeOut = Int(Number($iTimeOut))
	; Set automatic timeout if no buttons and no timeout set
	If $vButton == " " And $iTimeOut = 0 Then
		$iTimeOut = 5
	EndIf

	; Check for icon
	Local $iIcon_Style = 0
	Local $iIcon_Reduction = 50
	Local $sDLL = "user32.dll"
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
			Case 128 ; Countdown
				If $iTimeout > 0 Then
					$fCountdown = True
				Else
					ContinueCase
				EndIf
			Case Else
				Return SetError(1, 0, -1)
		EndSwitch
	Else
		$sDLL = $vIcon
		$iIcon_Style = 0
	EndIf

	; Check if two buttons are seeking focus
	StringRegExpReplace($vButton, "((?<!&)&)(?!&)", "*")
	If @extended > 1 Then
		Return SetError(2, 0, -1)
	EndIf

	; Check if using constants or text
	If IsNumber($vButton) Then
		Switch $vButton
			Case 0
				$vButton = "OK"
			Case 1
				$vButton = "&OK|Cancel"
			Case 2
				$vButton = "&Abort|Retry|Ignore"
			Case 3
				$vButton = "&Yes|No|Cancel"
			Case 4
				$vButton = "&Yes|No"
			Case 5
				$vButton = "&Retry|Cancel"
			Case 6
				$vButton = "&Cancel|Try Again|Continue"
			Case Else
				Return SetError(3, 0, -1)
		EndSwitch
	EndIf

	; Set tab expansion flag if required
	Local $iExpTab = Default
	If BitAnd($iEMB_Style, 8) Then
		$iExpTab = 1
	EndIf

	; Get message label size
	While 1
		Local $aLabel_Pos = _StringSize($sText, $iEMB_Font_Size, Default, $iExpTab, $sEMB_Font_Name, $iMsg_Width_max - 20 - $iIcon_Reduction)
		If @error Then
			If $iMsg_Width_max = $iMsg_Width_abs Then
				Return SetError(5, 0, -1)
			Else
				$iMsg_Width_max += 10
			EndIf
		Else
			ExitLoop
		EndIf
	WEnd

	; Reset text to wrapped version
	$sText = $aLabel_Pos[0]

	; Get individual button text
	If $vButton <> " " Then
		Local $aButtons = StringSplit($vButton, "|")
		; Get minimum GUI width needed for buttons
		Local $iMsg_Width_Button = ($iButton_Width_max + 10) * $aButtons[0] + 10
		; If shorter than min width
		If $iMsg_Width_Button < $iMsg_Width_min Then
			; Set buttons to max size and leave box min width unchanged
			$iButton_Width = $iButton_Width_max
		Else
			; Check button width needed to fit within max box width
			$iButton_Width_Req = ($iMsg_Width_max - (($aButtons[0] + 1) * 10)) / $aButtons[0]
			; Button width less than min button width permitted
			If $iButton_Width_Req < $iButton_Width_min Then
				Return SetError(4, 0, -1)
				; Buttons only need resizing to fit
			ElseIf $iButton_Width_Req < $iButton_Width_max Then
				; Set box to max width and set button size as required
				$iMsg_Width_Button = $iMsg_Width_max
				$iButton_Width = $iButton_Width_Req
				; Buttons can be max size
			Else
				; Set box min width to fit buttons
				$iButton_Width = $iButton_Width_max
				$iMsg_Width_min = $iMsg_Width_Button
			EndIf
		EndIf
		; Determine final button width required
		$iButton_Width_Req = Int((($iButton_Width + 10) * $aButtons[0]) + 10)
	Else
		$iButton_Width_Req = 0
	EndIf

	; Set label size
	Local $iLabel_Width = $aLabel_Pos[2]
	Local $iLabel_Height = $aLabel_Pos[3]
	; Set GUI size
	Local $iMsg_Width = $iLabel_Width + 20 + $iIcon_Reduction
	; Increase width to fit buttons if needed
	If $iButton_Width_Req > $iMsg_Width Then $iMsg_Width = $iButton_Width_Req
	If $iMsg_Width < $iMsg_Width_min Then
		$iMsg_Width = $iMsg_Width_min
		$iLabel_Width = $iMsg_Width_min - 20
	EndIf
	Local $iMsg_Height = $iLabel_Height + 35
	; Increase height if buttons present
	If $vButton <> " " Then
		$iMsg_Height += 30
	EndIf
	; Increase height if checkbox required
	If BitAnd($iEMB_Style, 16) Then
		$iMsg_Height += 40
	EndIf
	If $iMsg_Height < $iMsg_Height_min Then $iMsg_Height = $iMsg_Height_min

	; If only single line, lower label to to centre text on icon
	Local $iLabel_Vert = 20
	If StringInStr($sText, @CRLF) = 0 Then $iLabel_Vert = 27

	; Check for taskbar button style required
	If Mod($iEMB_Style, 2) = 1 Then ; Hide taskbar button so create as child
		If IsHWnd($hWin) Then
			$iParent_Win = $hWin ; Make child of that window
		Else
			$iParent_Win = WinGetHandle(AutoItWinGetTitle()) ; Make child of AutoIt window
		EndIf
	EndIf

	; Determine EMB location
	If $hWin = "" Then
		; No handle or position passed so centre on screen
		$iHpos = (@DesktopWidth - $iMsg_Width) / 2
		$iVPos = (@DesktopHeight - $iMsg_Height) / 2
	Else
		If IsHWnd($hWin) Then
			; Get parent GUI pos if visible
			If BitAND(WinGetState($hWin), 2) Then
				; Set EMB to centre on parent
				Local $aPos = WinGetPos($hWin)
				$iHpos = ($aPos[2] - $iMsg_Width) / 2 + $aPos[0] - 3
				$iVPos = ($aPos[3] - $iMsg_Height) / 2 + $aPos[1] - 20
			Else
				; Set EMB to centre om screen
				$iHpos = (@DesktopWidth - $iMsg_Width) / 2
				$iVPos = (@DesktopHeight - $iMsg_Height) / 2
			EndIf
		Else
			; Assume parameter is horizontal coord
			$iHpos = $hWin ; $iVpos already set
		EndIf
	EndIf

	; Now check to make sure GUI is visible on screen
	; First horizontally
	If $iHpos < 10 Then $iHpos = 10
	If $iHpos + $iMsg_Width > @DesktopWidth - 20 Then $iHpos = @DesktopWidth - 20 - $iMsg_Width
	; Then vertically
	If $iVPos < 10 Then $iVPos = 10
	If $iVPos + $iMsg_Height > @DesktopHeight - 60 Then $iVPos = @DesktopHeight - 60 - $iMsg_Height

	; Remove TOPMOST extended style if required
	Local $iExtStyle = 0x00000008 ; $WS_TOPMOST
	If BitAnd($iEMB_Style, 2) Then $iExtStyle = -1

	; Create GUI with $WS_POPUPWINDOW, $WS_CAPTION style and required extended style
	Local $hMsgGUI = GUICreate($sTitle, $iMsg_Width, $iMsg_Height, $iHpos, $iVPos, BitOR(0x80880000, 0x00C00000), $iExtStyle, $iParent_Win)
	If @error Then
		Return SetError(6, 0, -1)
	EndIf

	; Check if titlebar icon hidden - actually uses transparent icon from AutoIt executable
    If BitAND($iEMB_Style, 32) Then
		If @Compiled Then
			GUISetIcon(@ScriptName, -2, $hMsgGUI)
		Else
			GUISetIcon(@AutoItExe, -2, $hMsgGUI)
		EndIf
    EndIf
	If $iEMB_BkCol <> Default Then GUISetBkColor($iEMB_BkCol)

	; Check if user closure permitted
	If BitAnd($iEMB_Style, 64) Then
		Local $aRet = DllCall("User32.dll", "hwnd", "GetSystemMenu", "hwnd", $hMsgGUI, "int", 0)
		Local $hSysMenu = $aRet[0]
		DllCall("User32.dll", "int", "RemoveMenu", "hwnd", $hSysMenu, "int", 0xF060, "int", 0) ; $SC_CLOSE
		DllCall("User32.dll", "int", "DrawMenuBar", "hwnd", $hMsgGUI)
	EndIf

	; Set centring parameter
	Local $iLabel_Style = 0 ; $SS_LEFT
	If BitAND($iEMB_Just, 1) = 1 Then
		$iLabel_Style = 1 ; $SS_CENTER
	ElseIf BitAND($iEMB_Just, 2) = 2 Then
		$iLabel_Style = 2 ; $SS_RIGHT
	EndIf

	; Create label
	GUICtrlCreateLabel($sText, 10 + $iIcon_Reduction, $iLabel_Vert, $iLabel_Width, $iLabel_Height, $iLabel_Style)
	GUICtrlSetFont(-1, $iEMB_Font_Size, Default, Default, $sEMB_Font_Name)
	If $iEMB_Col <> Default Then GUICtrlSetColor(-1, $iEMB_Col)

	; Create checkbox if required
	If BitAnd($iEMB_Style, 16) Then
		Local $sAgain = " Do not show again"
		Local $iY = $iLabel_Vert + $iLabel_Height + 10
		; Create checkbox
		$cCheckbox = GUICtrlCreateCheckbox("", 10 + $iIcon_Reduction, $iY, 20, 20)
		; Write text in separate checkbox label
		Local $cCheckLabel = GUICtrlCreateLabel($sAgain, 20, 20, 20, 20)
		GUICtrlSetColor($cCheckLabel, $iEMB_Col)
		GUICtrlSetBkColor($cCheckLabel, $iEMB_BkCol)
		; Set font if required and size checkbox label text
		If BitAnd($iEMB_Style, 4) Then
			$aLabel_Size = _StringSize($sAgain)
		Else
			$aLabel_Size = _StringSize($sAgain, $iEMB_Font_Size, 400, 0, $sEMB_Font_Name)
			GUICtrlSetFont($cCheckLabel, $iEMB_Font_Size, 400, 0, $sEMB_Font_Name)
		EndIf
		; Move and resize checkbox label to fit
		$iY = ($iY + 10) - ($aLabel_Size[3] - 4) / 2
		ControlMove($hMsgGUI, "", $cCheckLabel, 30 + $iIcon_Reduction, $iY, $iMsg_Width - (30 + $iIcon_Reduction), $aLabel_Size[3])
	EndIf

	; Create icon or countdown timer
	If $fCountdown = True Then
		Local $cCountdown_Label = GUICtrlCreateLabel(StringFormat("%2s", $iTimeout), 10, 20, 32, 32)
		GUICtrlSetFont(-1, 18, Default, Default, $sEMB_Font_Name)
		GUICtrlSetColor(-1, $iEMB_Col)
	Else
		If $iIcon_Reduction Then GUICtrlCreateIcon($sDLL, $iIcon_Style, 10, 20)
	EndIf

	; Create buttons
	Local $cAccel_Key = 9999 ; Placeholder to prevent firing if no buttons
	If $vButton <> " " Then

		; Create dummy control for Accel key
		$cAccel_Key = GUICtrlCreateDummy()
		; Set Space key as Accel key
		Local $aAccel_Key[1][2]=[["{SPACE}", $cAccel_Key]]
		GUISetAccelerators($aAccel_Key)

		; Calculate button horizontal start
		If $aButtons[0] = 1 Then
			If BitAND($iEMB_Just, 4) = 4 Then
				; Single centred button
				$iButton_Xpos = ($iMsg_Width - $iButton_Width) / 2
			Else
				; Single offset button
				$iButton_Xpos = $iMsg_Width - $iButton_Width - 10
			EndIf
		Else
			; Multiple centred buttons
			$iButton_Xpos = 10 + ($iMsg_Width - $iMsg_Width_Button) / 2
		EndIf
		; Set default button code
		Local $iDefButton_Code = 0
		; Set default button style
		Local $iDef_Button_Style = 0
		; Work through button list
		For $i = 0 To $aButtons[0] - 1
			Local $iButton_Text = $aButtons[$i + 1]
			; Set default button
			If $aButtons[0] = 1 Then ; Only 1 button
				$iDef_Button_Style = 0x0001
			ElseIf StringLeft($iButton_Text, 1) = "&" Then ; Look for &
				$iDef_Button_Style = 0x0001
				$aButtons[$i + 1] = StringTrimLeft($iButton_Text, 1)
				; Set default button code for Accel key return
				$iDefButton_Code = $i + 1
			EndIf
			; Draw button
			GUICtrlCreateButton($aButtons[$i + 1], $iButton_Xpos + ($i * ($iButton_Width + 10)), $iMsg_Height - 35, $iButton_Width, 25, $iDef_Button_Style)
			; Set font if required
			If Not BitAnd($iEMB_Style, 4) Then GUICtrlSetFont(-1, $iEMB_Font_Size, 400, 0, $sEMB_Font_Name)
			; Reset default style parameter
			$iDef_Button_Style = 0
		Next
	EndIf

	; Show GUI
	GUISetState(@SW_SHOW, $hMsgGUI)

	; Begin timeout counter
	Local $iTimeout_Begin = TimerInit()
	Local $iCounter = 0

	; Declare GUIGetMsg return array here and not in loop
	Local $aMsg

	; Set MessageLoop mode
	Local $iOrgMode = Opt('GUIOnEventMode', 0)

	While 1
		$aMsg = GUIGetMsg(1)

		If $aMsg[1] = $hMsgGUI Then
			Select
				Case $aMsg[0] = -3 ; $GUI_EVENT_CLOSE
					$iRet_Value = 0
					ExitLoop
				Case $aMsg[0] = $cAccel_Key
					; Accel key pressed so return default button code
					If $iDefButton_Code Then
						$iRet_Value = $iDefButton_Code
						ExitLoop
					EndIf
				Case $aMsg[0] > $cAccel_Key
					; Button handle minus Accel key handle will give button index
					$iRet_Value = $aMsg[0] - $cAccel_Key
					ExitLoop
			EndSelect
		EndIf

		; Timeout if required
		If TimerDiff($iTimeout_Begin) / 1000 >= $iTimeout And $iTimeout > 0 Then
			$iRet_Value = 9
			ExitLoop
		EndIf

		; Show countdown if required
		If $fCountdown = True Then
			Local $iTimeRun = Int(TimerDiff($iTimeout_Begin) /1000)
			If $iTimeRun <> $iCounter Then
				$iCounter = $iTimeRun
				GUICtrlSetData($cCountdown_Label, StringFormat("%2s", $iTimeout - $iCounter))
			EndIf
		EndIf

	WEnd

	; Reset original mode
	Opt('GUIOnEventMode', $iOrgMode)

	If GUICtrlRead($cCheckbox) = 1 Then
		; Negate the return value
		$iRet_Value *= -1
	EndIf

	GUIDelete($hMsgGUI)

	Return $iRet_Value

EndFunc   ;==>_ExtMsgBox

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _EMB_GetDefaultFont
; Description ...: Determines Windows default MsgBox font size and name
; Syntax.........: _EMB_GetDefaultFont()
; Return values .: Success - Array holding determined font data
;                : Failure - Array holding default values
;                  Array elements - [0] = Size, [1] = Weight, [2] = Style, [3] = Name, [4] = Quality
; Author ........: KaFu
; Remarks .......: Used internally by ExtMsgBox UDF
; ===============================================================================================================================
Func _EMB_GetDefaultFont()

	; Fill array with standard default data
	Local $aDefFontData[2] = [9, "Tahoma"]

	; Get AutoIt GUI handle
	Local $hWnd = WinGetHandle(AutoItWinGetTitle())
	; Open Theme DLL
	Local $hThemeDLL = DllOpen("uxtheme.dll")
	; Get default theme handle
	Local $hTheme = DllCall($hThemeDLL, 'ptr', 'OpenThemeData', 'hwnd', $hWnd, 'wstr', "Static")
	If @error Then Return $aDefFontData
	$hTheme = $hTheme[0]
	; Create LOGFONT structure
	Local $tFont = DllStructCreate("long;long;long;long;long;byte;byte;byte;byte;byte;byte;byte;byte;wchar[32]")
	Local $pFont = DllStructGetPtr($tFont)
	; Get MsgBox font from theme
	DllCall($hThemeDLL, 'long', 'GetThemeSysFont', 'HANDLE', $hTheme, 'int', 805, 'ptr', $pFont) ; TMT_MSGBOXFONT
	If @error Then Return $aDefFontData
	; Get default DC
	Local $hDC = DllCall("user32.dll", "handle", "GetDC", "hwnd", $hWnd)
	If @error Then Return $aDefFontData
	$hDC = $hDC[0]
	; Get font vertical size
	Local $iPixel_Y = DllCall("gdi32.dll", "int", "GetDeviceCaps", "handle", $hDC, "int", 90) ; LOGPIXELSY
	If Not @error Then
		$iPixel_Y = $iPixel_Y[0]
		$aDefFontData[0] = Int(2 * (.25 - DllStructGetData($tFont, 1) * 72 / $iPixel_Y)) / 2
	EndIf
	; Close DC
	DllCall("user32.dll", "int", "ReleaseDC", "hwnd", $hWnd, "handle", $hDC)
	; Extract font data from LOGFONT structure
	$aDefFontData[1] = DllStructGetData($tFont, 14)

	Return $aDefFontData

EndFunc ;=>_EMB_GetDefaultFont


