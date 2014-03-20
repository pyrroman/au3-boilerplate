#include <TaskDialog.au3>
; The easiest way:
$ret = _TaskDialog(0, 0, "_TaskDialog", "this is a test :)", "hh", 1, $TD_SHIELD_ICON)
MsgBox(0, "The dialog returned:", $ret)

;~ #AutoIt3Wrapper_usex64=n

; With all self-made:
$structTASKDIALOGCONFIG = DllStructCreate($tagTASKDIALOGCONFIG)
DllStructSetData($structTASKDIALOGCONFIG, 1, DllStructGetSize($structTASKDIALOGCONFIG))

$Buttons = DllStructCreate($tagTASKDIALOG_BUTTON & ";" & $tagTASKDIALOG_BUTTON)
; Button 1:
DllStructSetData($Buttons, 1, 1000) ; The ID
$Btn1Text = _TaskDialog_StringStruct("This is Button 1" & @LF & "it Returns ID 1000")
;~ $Btn1Text = _TaskDialog_StringStruct("Button 1")
DllStructSetData($Buttons, 2, DllStructGetPtr($Btn1Text)) ; The Text
; Button 2:
DllStructSetData($Buttons, 3, 1001) ; The ID
$Btn2Text = _TaskDialog_StringStruct("This is Button 2" & @LF & "it Returns ID 1001")
;~ $Btn2Text = _TaskDialog_StringStruct("Button 2")
DllStructSetData($Buttons, 4, DllStructGetPtr($Btn2Text)) ; The Text
DllStructSetData($structTASKDIALOGCONFIG, "cButtons", 2) ; We use 2 Buttons
DllStructSetData($structTASKDIALOGCONFIG, "pButtons", DllStructGetPtr($Buttons)) ; The Ptr to Buttons

DllStructSetData($structTASKDIALOGCONFIG, "nDefaultButton", 1001) ; We use 2nd Button as Default

DllStructSetData($structTASKDIALOGCONFIG, "dwFlags", BitOR($TDF_USE_COMMAND_LINKS, $TDF_SHOW_MARQUEE_PROGRESS_BAR))
DllStructSetData($structTASKDIALOGCONFIG, "dwCommonButtons", 1)

Dim $pnButton, $pnRadioButton, $pfVerificationFlagChecked

$ret = _TaskDialogIndirect($structTASKDIALOGCONFIG, $pnButton, $pnRadioButton, $pfVerificationFlagChecked)
MsgBox(0, "The dialog returned:", $ret & _
		@CRLF & "Pressed Button: " & $pnButton & _
		@CRLF & "Selected Radio: " & $pnRadioButton & _
		@CRLF & "Checkbox selected: " & $pfVerificationFlagChecked & _
		@CRLF & "error: " & Hex(@error))

; The Params-Function
Enum $ID_BTN1 = 1001, $ID_BTN2, $ID_BTN3, $ID_RADIO1, $ID_RADIO2, $ID_RADIO3

Dim $pnButton, $pnRadioButton, $pfVerificationFlagChecked
Dim $Buttons[3][2] = [[$ID_BTN1, "Click Button 1" & @LF & "It has th ID " & $ID_BTN1], _
		[$ID_BTN2, "Click Button 2" & @LF & "It has th ID " & $ID_BTN2], _
		[$ID_BTN3, "Click Button 3" & @LF & "It has th ID " & $ID_BTN3]]
Dim $RadioButtons[3][2] = [[$ID_RADIO1, "Radiobutton ID:" & $ID_RADIO1], _
		[$ID_RADIO2, "Radiobutton ID:" & $ID_RADIO2], _
		[$ID_RADIO3, "Radiobutton ID:" & $ID_RADIO3]]
Dim $ContentText = "A longer text to show the dialog a bit wirder :D" & @LF & "Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, " & _
		"totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo." & @LF & @LF & _
		'<a href="http://autoitscript.com">Visit AutoIt</a>'

$CallBackFunc = DllCallbackRegister("TDCallback", "long", "hwnd;uint;wparam;lparam;long_ptr")

Do
	$ret = _TaskDialogIndirectParams($pnButton, $pnRadioButton, $pfVerificationFlagChecked, 0, 0, BitOR($TDF_ENABLE_HYPERLINKS, $TDF_USE_COMMAND_LINKS), _
			$TDCBF_OK_BUTTON, "_TaskDialogIndirectParams", $TDCBF_CANCEL_BUTTON, "Everything with Parameters", $ContentText, $Buttons, $ID_BTN2, $RadioButtons, $ID_RADIO2, _
			"Verification: Don't show Dialog again.", "This dialog shows until you check the CheckBox!!", "Close Notes", "Important notes", _
			$TD_INFORMATION_ICON, '<a href="http://autoitscript.com">Visit AutoIt!</a>', DllCallbackGetPtr($CallBackFunc), 0)
If @error Then Exit MsgBox(0, '', Hex(@error))
	MsgBox(0, "The dialog returned:", $ret & _
			@CRLF & "Pressed Button: " & $pnButton & _
			@CRLF & "Selected Radio: " & $pnRadioButton & _
			@CRLF & "Checkbox selected: " & $pfVerificationFlagChecked)

Until $pfVerificationFlagChecked

Func TDCallback($hwnd, $uNotification, $wParam, $lParam, $dwRefData)
;~     HWND hwnd, UINT uNotification, WPARAM wParam,
;~     LPARAM lParam, LONG_PTR dwRefData )
	Switch $uNotification
		Case $TDN_HYPERLINK_CLICKED
			DllCall("shell32.dll", "long", "ShellExecuteW", _
					"hwnd", $hwnd, _
					"wstr", "open", _
					"ptr", $lParam, _
					"wstr", "", _
					"wstr", "", _
					"int", @SW_SHOW)
;~       ShellExecute ((LPCWSTR) lParam,
;~                      NULL, NULL, SW_SHOW );
	EndSwitch

	Return 0
EndFunc   ;==>TDCallback