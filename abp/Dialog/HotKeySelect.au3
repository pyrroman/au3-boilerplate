#include<WinAPI.au3>
#include<ButtonConstants.au3>
#include<StaticConstants.au3>
#include<WindowsConstants.au3>
#include<GUIConstantsEx.au3>
#include<SendMessage.au3>

Global Const $HKM_GETHOTKEY = $WM_USER + 2
Global Const $HOTKEYF_ALT = 0x4
Global Const $HOTKEYF_CONTROL = 0x2
Global Const $HOTKEYF_SHIFT = 0x1
Global Const $HOTKEYF_EXT = 0x80


Global $VirtualKeyCode_To_HotKey_Mapping[65][2]
_CreateVK()
MsgBox(0, 'Example',"Example for HotKeySelect.au3" & @CRLF & "Result: " & _SelectHotkey("#1"))
;http://msdn.microsoft.com/en-us/library/bb775233(VS.85).aspx
;===============================================================================
;
; Function Name: _SelectHotkey($OldHotkey = "")
; Description:: Opens a window to select a HotKey
; Parameter(s): $OldHotKey - The Old Hotkey in HotKey Format
; Requirement(s): WinAPI.au3
; Return Value(s): New HotKey
; Cancel, GUIClose: Hotkey given in OldHotKEy
; Author(s): Prog@ndy
;
;===============================================================================
;
Func _SelectHotkey($OldHotkey = "")
	Local $OldEvent = Opt("GUIOnEventMode", 0)
	Local $wKey, $OK, $hHkey, $Cancel, $msg
	Local $wnd = GUICreate("Set Hotkey", 220, 160)
	GUICtrlCreateLabel("Old Hotkey:", 2, 3, -1, 20)
	GUICtrlCreateLabel($OldHotkey, 2, 20, 218, 22, $SS_SUNKEN + $SS_CENTER)
	GUICtrlSetBkColor(-1, 0xCCCCCC)
	GUICtrlSetFont(-1, 12, 800, -1, "Arial")
	GUICtrlCreateLabel("New Hotkey:", 2, 44, -1, 20)
	$hHkey = _WinAPI_CreateWindowEx(0, "msctls_hotkey32", "", $WS_CHILD + $WS_VISIBLE, 0, 62, 220, 22, $wnd)
	$wKey = GUICtrlCreateCheckbox("+ WIN-Key", 10, 86)
	$OK = GUICtrlCreateButton("OK", 10, 130, 85, -1, $BS_DEFPUSHBUTTON)
	GUICtrlSetFont(-1, Default, 800)
	$Cancel = GUICtrlCreateButton("Abbrechen", 105, 130, 85)
	_WinAPI_SetFocus($hHkey)
	GUISetState()
	Local $Return = $OldHotkey, $Error = 0
	While 1
		$msg = GUIGetMsg()
		Switch $msg
			Case $OK
				Local $x = _GetHotKey($hHkey)
				If $x = "" Then
					Switch MsgBox(292, 'HotKeySelect', "Do you really want to remove the HotKey?")
						Case 6
							$Return = ""
							ExitLoop
						Case Else
							ContinueLoop
					EndSwitch
				EndIf
				If BitAND(GUICtrlRead($wKey), $GUI_CHECKED) = $GUI_CHECKED Then $x = "#" & $x
				$Return = $x
				ExitLoop
			Case $Cancel, $GUI_EVENT_CLOSE
				$Error = 1
				ExitLoop
		EndSwitch
	WEnd
	GUIDelete($wnd)
	Opt("GUIOnEventMode", $OldEvent)
	Return SetError($Error, 0, $Return)
EndFunc   ;==>_SelectHotkey
Func _GetHotKey($hotKeyControl)
	If Not IsHWnd($hotKeyControl) Then Return -1
	Local $Chr = ""
	Local $hk = _SendMessage($hotKeyControl, $HKM_GETHOTKEY, 0, 0)
	Local $loByte = BitAND(_WinAPI_LoWord($hk), 0xFF)
	Local $HiByte = BitShift(_WinAPI_LoWord($hk), 8)
	$hk = $loByte
	For $i = 0 To 64
		If $VirtualKeyCode_To_HotKey_Mapping[$i][0] = $hk Then
			$Chr = $VirtualKeyCode_To_HotKey_Mapping[$i][1]
			ExitLoop
		EndIf
	Next
	If $Chr <> "" Then Return $Chr
	$Chr = DllCall("user32.dll", "int", "MapVirtualKey", "int", $hk, "int", 2)
	$Chr = StringLower(Chr(BitAND($Chr[0], 0xFFFF)))
	If $Chr = "!" Or $Chr = "^" Or $Chr = "+" Or $Chr = "{" Or $Chr = "}" Or $Chr = "#" Then
		$Chr = "{" & $Chr & "}"
	EndIf
	If BitAND($HiByte, $HOTKEYF_SHIFT) = $HOTKEYF_SHIFT Then $Chr = "+" & $Chr
	If BitAND($HiByte, $HOTKEYF_ALT) = $HOTKEYF_ALT Then $Chr = "!" & $Chr
	If BitAND($HiByte, $HOTKEYF_CONTROL) = $HOTKEYF_CONTROL Then $Chr = "^" & $Chr
	If BitAND($HiByte, $HOTKEYF_EXT) = $HOTKEYF_EXT Then $Chr = "#" & $Chr
	Return $Chr
EndFunc   ;==>_GetHotKey

Func _CreateVK()
;~ Global Const $VK_CTRL_BREAK = '03'
	$VirtualKeyCode_To_HotKey_Mapping[0][0] = 0x03
	$VirtualKeyCode_To_HotKey_Mapping[0][1] = "{BREAK}"
;~ Global Const $VK_BACK = '08'
	$VirtualKeyCode_To_HotKey_Mapping[1][0] = 0x09
	$VirtualKeyCode_To_HotKey_Mapping[1][1] = "{TAB}"
;~ Global Const $VK_TAB = '09'
;~ Global Const $VK_CLEAR = '0C'
	$VirtualKeyCode_To_HotKey_Mapping[2][0] = 0x0C
	$VirtualKeyCode_To_HotKey_Mapping[2][1] = "{CLEAR}"
;~ Global Const $VK_ENTER = '0D'
	$VirtualKeyCode_To_HotKey_Mapping[3][0] = 0x0D
	$VirtualKeyCode_To_HotKey_Mapping[3][1] = "{ENTER}"
;~ Global Const $VK_SHIFT = 10
	$VirtualKeyCode_To_HotKey_Mapping[4][0] = 0x10
	$VirtualKeyCode_To_HotKey_Mapping[4][1] = "+"
;~ Global Const $VK_CTRL = 11
	$VirtualKeyCode_To_HotKey_Mapping[5][0] = 0x11
	$VirtualKeyCode_To_HotKey_Mapping[5][1] = "^"
;~ Global Const $VK_ALT = 12
	$VirtualKeyCode_To_HotKey_Mapping[6][0] = 0x12
	$VirtualKeyCode_To_HotKey_Mapping[6][1] = "!"
;~ Global Const $VK_PAUSE = 13
	$VirtualKeyCode_To_HotKey_Mapping[7][0] = 0x13
	$VirtualKeyCode_To_HotKey_Mapping[7][1] = "{PAUSE}"
;~ Global Const $VK_CAPS = 14
	$VirtualKeyCode_To_HotKey_Mapping[8][0] = 0x14
	$VirtualKeyCode_To_HotKey_Mapping[8][1] = "{CAPSLOCK}"
;~ Global Const $VK_ESC = '1B'
	$VirtualKeyCode_To_HotKey_Mapping[9][0] = 0x1B
	$VirtualKeyCode_To_HotKey_Mapping[9][1] = "{ESC}"
;~ Global Const $VK_SPACE = 20
	$VirtualKeyCode_To_HotKey_Mapping[10][0] = 0x20
	$VirtualKeyCode_To_HotKey_Mapping[10][1] = "{SPACE}"
;~ Global Const $VK_PAGE_UP = 21
	$VirtualKeyCode_To_HotKey_Mapping[11][0] = 0x21
	$VirtualKeyCode_To_HotKey_Mapping[11][1] = "{PGUP}"
;~ Global Const $VK_PADE_DOWN = 22
	$VirtualKeyCode_To_HotKey_Mapping[12][0] = 0x22
	$VirtualKeyCode_To_HotKey_Mapping[12][1] = "{PGDN}"
;~ Global Const $VK_END = 23
	$VirtualKeyCode_To_HotKey_Mapping[13][0] = 0x23
	$VirtualKeyCode_To_HotKey_Mapping[13][1] = "{END}"
;~ Global Const $VK_HOME = 24
	$VirtualKeyCode_To_HotKey_Mapping[14][0] = 0x24
	$VirtualKeyCode_To_HotKey_Mapping[14][1] = "{HOME}"
;~ Global Const $VK_LEFT = 25
	$VirtualKeyCode_To_HotKey_Mapping[15][0] = 0x25
	$VirtualKeyCode_To_HotKey_Mapping[15][1] = "{LEFT}"
;~ Global Const $VK_UP = 26
	$VirtualKeyCode_To_HotKey_Mapping[16][0] = 0x26
	$VirtualKeyCode_To_HotKey_Mapping[16][1] = "{UP}"
;~ Global Const $VK_RIGHT = 27
	$VirtualKeyCode_To_HotKey_Mapping[17][0] = 0x27
	$VirtualKeyCode_To_HotKey_Mapping[17][1] = "{RIGHT}"
;~ Global Const $VK_DOWN = 28
	$VirtualKeyCode_To_HotKey_Mapping[18][0] = 0x28
	$VirtualKeyCode_To_HotKey_Mapping[18][1] = "{DOWN}"
;~ Global Const $VK_SELECT = 29
	$VirtualKeyCode_To_HotKey_Mapping[19][0] = 0x29
	$VirtualKeyCode_To_HotKey_Mapping[19][1] = "{SELECT}"
;~ Global Const $VK_PRINT = '2A'
	$VirtualKeyCode_To_HotKey_Mapping[20][0] = 0x2A
	$VirtualKeyCode_To_HotKey_Mapping[20][1] = "{PRINTSCREEN}"
;~ Global Const $VK_EXECUTE = '2B'
;~ $VirtualKeyCode_To_HotKey_Mapping[1][0]=0x20
;~ $VirtualKeyCode_To_HotKey_Mapping[1][1]="{SPACE}"
;~ Global Const $VK_PRINT_SCR = '2C'
	$VirtualKeyCode_To_HotKey_Mapping[21][0] = 0x2C
	$VirtualKeyCode_To_HotKey_Mapping[21][1] = "{PRINTSCREEN}"
;~ Global Const $VK_INS = '2D'
	$VirtualKeyCode_To_HotKey_Mapping[22][0] = 0x2D
	$VirtualKeyCode_To_HotKey_Mapping[22][1] = "{INS}"
;~ Global Const $VK_DEL = '2E'
	$VirtualKeyCode_To_HotKey_Mapping[23][0] = 0x2E
	$VirtualKeyCode_To_HotKey_Mapping[23][1] = "{DEL}"
;~ Global Const $VK_HELP = '2F'
	$VirtualKeyCode_To_HotKey_Mapping[24][0] = 0x2F
	$VirtualKeyCode_To_HotKey_Mapping[24][1] = "{F1}"
;~ Global Const $VK_L_WIN = '5B'
	$VirtualKeyCode_To_HotKey_Mapping[25][0] = 0x5B
	$VirtualKeyCode_To_HotKey_Mapping[25][1] = "#"
;~ Global Const $VK_R_WIN = '5C'
	$VirtualKeyCode_To_HotKey_Mapping[26][0] = 0x5C
	$VirtualKeyCode_To_HotKey_Mapping[26][1] = "#"
;~ Global Const $VK_APP = '5D'
	$VirtualKeyCode_To_HotKey_Mapping[27][0] = 0x5D
	$VirtualKeyCode_To_HotKey_Mapping[27][1] = "{APPSKEY}"
;~ Global Const $VK_NUMPAD0 = 60
	$VirtualKeyCode_To_HotKey_Mapping[28][0] = 0x60
	$VirtualKeyCode_To_HotKey_Mapping[28][1] = "{NUMPAD0}"
;~ Global Const $VK_NUMPAD1 = 61
	$VirtualKeyCode_To_HotKey_Mapping[29][0] = 0x61
	$VirtualKeyCode_To_HotKey_Mapping[29][1] = "{NUMPAD1}"
;~ Global Const $VK_NUMPAD2 = 62
	$VirtualKeyCode_To_HotKey_Mapping[30][0] = 0x62
	$VirtualKeyCode_To_HotKey_Mapping[30][1] = "{NUMPAD2}"
;~ Global Const $VK_NUMPAD3 = 63
	$VirtualKeyCode_To_HotKey_Mapping[31][0] = 0x63
	$VirtualKeyCode_To_HotKey_Mapping[31][1] = "{NUMPAD3}"
;~ Global Const $VK_NUMPAD4 = 64
	$VirtualKeyCode_To_HotKey_Mapping[32][0] = 0x64
	$VirtualKeyCode_To_HotKey_Mapping[32][1] = "{NUMPAD4}"
;~ Global Const $VK_NUMPAD5 = 65
	$VirtualKeyCode_To_HotKey_Mapping[33][0] = 0x65
	$VirtualKeyCode_To_HotKey_Mapping[33][1] = "{NUMPAD5}"
;~ Global Const $VK_NUMPAD6 = 66
	$VirtualKeyCode_To_HotKey_Mapping[34][0] = 0x66
	$VirtualKeyCode_To_HotKey_Mapping[34][1] = "{NUMPAD6}"
;~ Global Const $VK_NUMPAD7 = 67
	$VirtualKeyCode_To_HotKey_Mapping[35][0] = 0x67
	$VirtualKeyCode_To_HotKey_Mapping[35][1] = "{NUMPAD7}"
;~ Global Const $VK_NUMPAD8 = 68
	$VirtualKeyCode_To_HotKey_Mapping[36][0] = 0x68
	$VirtualKeyCode_To_HotKey_Mapping[36][1] = "{NUMPAD8}"
;~ Global Const $VK_NUMPAD9 = 69
	$VirtualKeyCode_To_HotKey_Mapping[37][0] = 0x69
	$VirtualKeyCode_To_HotKey_Mapping[37][1] = "{NUMPAD9}"
;~ Global Const $VK_MULTIPLY = '6A'
	$VirtualKeyCode_To_HotKey_Mapping[38][0] = 0x6A
	$VirtualKeyCode_To_HotKey_Mapping[38][1] = "{NUMPADMULT}"
;~ Global Const $VK_ADD = '6B'
	$VirtualKeyCode_To_HotKey_Mapping[39][0] = 0x6B
	$VirtualKeyCode_To_HotKey_Mapping[39][1] = "{NUMPADADD}"
;~ Global Const $VK_SEPERATOR = '6C'
	$VirtualKeyCode_To_HotKey_Mapping[40][0] = 0x6C
	$VirtualKeyCode_To_HotKey_Mapping[40][1] = "{NUMPADENTER}"
;~ Global Const $VK_SUBSTRACT = '6D'
	$VirtualKeyCode_To_HotKey_Mapping[41][0] = 0x6D
	$VirtualKeyCode_To_HotKey_Mapping[41][1] = "{NUMPADSUB}"
;~ Global Const $VK_DECIMAL = '6E'
	$VirtualKeyCode_To_HotKey_Mapping[42][0] = 0x6E
	$VirtualKeyCode_To_HotKey_Mapping[42][1] = "{NUMPADDOT}"
;~ Global Const $VK_DIVIDE = '6F'
	$VirtualKeyCode_To_HotKey_Mapping[43][0] = 0x6F
	$VirtualKeyCode_To_HotKey_Mapping[43][1] = "{NUMPADDIV}"
;~ Global Const $VK_F1 = 70
	$VirtualKeyCode_To_HotKey_Mapping[44][0] = 0x70
	$VirtualKeyCode_To_HotKey_Mapping[44][1] = "{F1}"
;~ Global Const $VK_F2 = 71
	$VirtualKeyCode_To_HotKey_Mapping[45][0] = 0x71
	$VirtualKeyCode_To_HotKey_Mapping[45][1] = "{F2}"
;~ Global Const $VK_F3 = 72
	$VirtualKeyCode_To_HotKey_Mapping[46][0] = 0x72
	$VirtualKeyCode_To_HotKey_Mapping[46][1] = "{F3}"
;~ Global Const $VK_F4 = 73
	$VirtualKeyCode_To_HotKey_Mapping[47][0] = 0x73
	$VirtualKeyCode_To_HotKey_Mapping[47][1] = "{F4}"
;~ Global Const $VK_F5 = 74
	$VirtualKeyCode_To_HotKey_Mapping[48][0] = 0x74
	$VirtualKeyCode_To_HotKey_Mapping[48][1] = "{F5}"
;~ Global Const $VK_F6 = 75
	$VirtualKeyCode_To_HotKey_Mapping[49][0] = 0x75
	$VirtualKeyCode_To_HotKey_Mapping[49][1] = "{F6}"
;~ Global Const $VK_F7 = 76
	$VirtualKeyCode_To_HotKey_Mapping[50][0] = 0x76
	$VirtualKeyCode_To_HotKey_Mapping[50][1] = "{F7}"
;~ Global Const $VK_F8 = 77
	$VirtualKeyCode_To_HotKey_Mapping[51][0] = 0x77
	$VirtualKeyCode_To_HotKey_Mapping[51][1] = "{F8}"
;~ Global Const $VK_F9 = 78
	$VirtualKeyCode_To_HotKey_Mapping[52][0] = 0x78
	$VirtualKeyCode_To_HotKey_Mapping[52][1] = "{F9}"
;~ Global Const $VK_F10 = 79
	$VirtualKeyCode_To_HotKey_Mapping[53][0] = 0x79
	$VirtualKeyCode_To_HotKey_Mapping[53][1] = "{F10}"
;~ Global Const $VK_F11 = '7A'
	$VirtualKeyCode_To_HotKey_Mapping[54][0] = 0x7A
	$VirtualKeyCode_To_HotKey_Mapping[54][1] = "{F11}"
;~ Global Const $VK_F12 = '7B'
	$VirtualKeyCode_To_HotKey_Mapping[55][0] = 0x7B
	$VirtualKeyCode_To_HotKey_Mapping[55][1] = "{F12}"
;~ Global Const $VK_F13 = '7C'
;~ Global Const $VK_F14 = '7D'
;~ Global Const $VK_F15 = '7E'
;~ Global Const $VK_F16 = '7F'
;~ Global Const $VK_F17 = '80H'
;~ Global Const $VK_F18 = '81H'
;~ Global Const $VK_F19 = '82H'
;~ Global Const $VK_F20 = '83H'
;~ Global Const $VK_F21 = '84H'
;~ Global Const $VK_F22 = '85H'
;~ Global Const $VK_F23 = '86H'
;~ Global Const $VK_F24 = '87H'
;~ Global Const $VK_NUMLOCK = 90
	$VirtualKeyCode_To_HotKey_Mapping[56][0] = 0x90
	$VirtualKeyCode_To_HotKey_Mapping[56][1] = "{NUMLOCK}"
;~ Global Const $VK_SCROLL_LOCK = 91
	$VirtualKeyCode_To_HotKey_Mapping[57][0] = 0x91
	$VirtualKeyCode_To_HotKey_Mapping[57][1] = "{SCROLLLOCK}"
;~ Global Const $VK_L_SHIFT = 'A0'
	$VirtualKeyCode_To_HotKey_Mapping[58][0] = 0xA0
	$VirtualKeyCode_To_HotKey_Mapping[58][1] = "+"
;~ Global Const $VK_R_SHIFT = 'A1'
	$VirtualKeyCode_To_HotKey_Mapping[59][0] = 0xA1
	$VirtualKeyCode_To_HotKey_Mapping[59][1] = "+"
;~ Global Const $VK_L_CTRL = 'A2'
	$VirtualKeyCode_To_HotKey_Mapping[60][0] = 0xA2
	$VirtualKeyCode_To_HotKey_Mapping[60][1] = "^"
;~ Global Const $VK_R_CTRL = 'A3'
	$VirtualKeyCode_To_HotKey_Mapping[61][0] = 0xA3
	$VirtualKeyCode_To_HotKey_Mapping[61][1] = "^"
;~ Global Const $VK_L_MENU = 'A4'
	$VirtualKeyCode_To_HotKey_Mapping[62][0] = 0xA4
	$VirtualKeyCode_To_HotKey_Mapping[62][1] = "{APPSKEY}"
;~ Global Const $VK_R_MENU = 'A5'
	$VirtualKeyCode_To_HotKey_Mapping[63][0] = 0xA5
	$VirtualKeyCode_To_HotKey_Mapping[63][1] = "{APPSKEY}"
;~ Global Const $VK_PLAY = 'FA'
	$VirtualKeyCode_To_HotKey_Mapping[64][0] = 0xFA
	$VirtualKeyCode_To_HotKey_Mapping[64][1] = "{MEDIA_PLAY_PAUSE}"
;~ Global Const $VK_ZOOM = 'FB'
;~ Global Const $VK_OFF = 'DF'
;~ Global Const $VK_COMMA = 'BC'
;~ Global Const $VK_POINT = 'BE'
;~ Global Const $VK_PERIOD = 'BE'
;~ Global Const $VK_PLUS = 'BB'
;~ Global Const $VK_MINUS = 'BD'
	;other:
;~ Global Const $VK_COLON = 'BA' ;==> :;
;~ Global Const $VK_SLASH = 'BF' ;==> /?
;~ Global Const $VK_TILDE = 'C0' ;==> `~
;~ Global Const $VK_OPEN_BRACKET = 'DB' ;==> [{
;~ Global Const $VK_CLOSE_BRACKET = 'DD' ;==> ]}
;~ Global Const $VK_BACK_SLASH = 'DC' ;==> \|
;~ Global Const $VK_QUOTATION = 'DE' ;==> '"
EndFunc   ;==>_CreateVK
