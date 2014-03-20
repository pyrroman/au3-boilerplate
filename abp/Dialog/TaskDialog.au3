#include-once
; The DLL for lower Versions :)
#include <TaskDialog.dll.au3>
#include <Constants.au3>

Global $_TDL_TaskDialogDll = DllOpen("comctl32.dll"), $_TDL_fUseXTaskDlg=False
__TDL_LoadDLL()
Func __TDL_LoadDLL()
	Local $res = DllCall("Kernel32.dll", "handle", "GetModuleHandle", "str", "comctl32")
	$res = DllCall("Kernel32.dll", "handle", "GetProcAddress", "handle", $res[0], "str", "TaskDialog")
	If Not $res[0] Then
		Local $sPath = ""
		If @AutoItX64 Then
			$sPath = __TDL_ExtractDLL64()
		Else
			$sPath = __TDL_ExtractDLL()
		EndIf
		DllClose($_TDL_TaskDialogDll)
		$_TDL_TaskDialogDll = DllOpen($sPath)
		$_TDL_fUseXTaskDlg = True
	EndIf
	If $_TDL_TaskDialogDll = -1 Then
		MsgBox(16, @ScriptName & ' - Error', "The required DLLs for TaskDialog could not be loaded.")
		Exit
	EndIf
EndFunc

; EndDLL

;_TASKDIALOG_COMMON_BUTTON_FLAGS
Global Const $TDCBF_OK_BUTTON = 1
;~     The task dialog contains the push button: OK.
Global Const $TDCBF_YES_BUTTON = 2
;~     The task dialog contains the push button: Yes.
Global Const $TDCBF_NO_BUTTON = 4
;~     The task dialog contains the push button: No.
Global Const $TDCBF_CANCEL_BUTTON = 8
;~     The task dialog contains the push button: Cancel. This button must be specified for the dialog box to respond to typical cancel actions (Alt-F4 and Escape).
Global Const $TDCBF_RETRY_BUTTON = 16
;~     The task dialog contains the push button: Retry.
Global Const $TDCBF_CLOSE_BUTTON = 32
;~     The task dialog contains the push button: Close.

; CASE test values for button clicks
;~ Global Const $IDOK = 1
;~ Global Const $IDCANCEL = 2
;~ Global Const $IDABORT = 3
;~ Global Const $IDRETRY = 4
;~ Global Const $IDIGNORE = 5
;~ Global Const $IDYES = 6
;~ Global Const $IDNO = 7
;~ Global Const $IDCLOSE = 8


;Icons
Global Const $TD_WARNING_ICON = 65535 ;MAKEINTRESOURCEW(-1)
Global Const $TD_ERROR_ICON = 65534 ;MAKEINTRESOURCEW(-2)
Global Const $TD_INFORMATION_ICON = 65533 ;MAKEINTRESOURCEW(-3)
Global Const $TD_SHIELD_ICON = 65532 ;MAKEINTRESOURCEW(-4)

Global Const $TD_ICON_BLANK = 100
Global Const $TD_ICON_WARNING = 101
Global Const $TD_ICON_QUESTION = 102
Global Const $TD_ICON_ERROR = 103
Global Const $TD_ICON_INFORMATION = 104
Global Const $TD_ICON_BLANK_AGAIN = 105
Global Const $TD_ICON_SHIELD = 106



;_TASKDIALOG_FLAGS
Global Const $TDF_ENABLE_HYPERLINKS = 1
Global Const $TDF_USE_HICON_MAIN = 2
Global Const $TDF_USE_HICON_FOOTER = 4
Global Const $TDF_ALLOW_DIALOG_CANCELLATION = 8
Global Const $TDF_USE_COMMAND_LINKS = 16
Global Const $TDF_USE_COMMAND_LINKS_NO_ICON = 32
Global Const $TDF_EXPAND_FOOTER_AREA = 64
Global Const $TDF_EXPANDED_BY_DEFAULT = 128
Global Const $TDF_VERIFICATION_FLAG_CHECKED = 256
Global Const $TDF_SHOW_PROGRESS_BAR = 512
Global Const $TDF_SHOW_MARQUEE_PROGRESS_BAR = 1024
Global Const $TDF_CALLBACK_TIMER = 2048
Global Const $TDF_POSITION_RELATIVE_TO_WINDOW = 4096
Global Const $TDF_RTL_LAYOUT = 8192
Global Const $TDF_NO_DEFAULT_RADIO_BUTTON = 16384
Global Const $TDF_CAN_BE_MINIMIZED = 32768

; _TASKDIALOG_NOTIFICATIONS
Global Const $TDN_CREATED = 0
Global Const $TDN_NAVIGATED = 1
Global Const $TDN_BUTTON_CLICKED = 2 ; wParam = Button ID
Global Const $TDN_HYPERLINK_CLICKED = 3 ; lParam = (LPCWSTR)pszHREF
Global Const $TDN_TIMER = 4 ; wParam = Milliseconds since dialog created Or timer reset
Global Const $TDN_DESTROYED = 5
Global Const $TDN_RADIO_BUTTON_CLICKED = 6 ; wParam = Radio Button ID
Global Const $TDN_DIALOG_CONSTRUCTED = 7
Global Const $TDN_VERIFICATION_CLICKED = 8 ; wParam = 1 If checkbox checked 0 If Not lParam is unused And always 0
Global Const $TDN_HELP = 9
Global Const $TDN_EXPANDO_BUTTON_CLICKED = 10 ; wParam = 0 (dialog is now collapsed) wParam != 0 (dialog is now expanded)

; _TASKDIALOG_ELEMENTS
Global Enum $TDE_CONTENT, _
		$TDE_EXPANDED_INFORMATION, _
		$TDE_FOOTER, _
		$TDE_MAIN_INSTRUCTION

; _TASKDIALOG_ICON_ELEMENTS
Global Enum $TDIE_ICON_MAIN, _
		$TDIE_ICON_FOOTER

; _TASKDIALOG_MESSAGES
Global Const $TDM_NAVIGATE_PAGE = 0x400 + 101
Global Const $TDM_CLICK_BUTTON = 0x400 + 102 ; wParam = Button ID
Global Const $TDM_SET_MARQUEE_PROGRESS_BAR = 0x400 + 103 ; wParam = 0 (nonMarque) wParam != 0 (Marquee)
Global Const $TDM_SET_PROGRESS_BAR_STATE = 0x400 + 104 ; wParam = new progress state
Global Const $TDM_SET_PROGRESS_BAR_RANGE = 0x400 + 105 ; lParam = MAKELPARAM(nMinRange nMaxRange)
Global Const $TDM_SET_PROGRESS_BAR_POS = 0x400 + 106 ; wParam = new position
Global Const $TDM_SET_PROGRESS_BAR_MARQUEE = 0x400 + 107 ; wParam = 0 (stop marquee) wParam != 0 (start marquee) lparam = speed (milliseconds between repaints)
Global Const $TDM_SET_ELEMENT_TEXT = 0x400 + 108 ; wParam = element (TASKDIALOG_ELEMENTS) lParam = new element text (LPCWSTR)
Global Const $TDM_CLICK_RADIO_BUTTON = 0x400 + 110 ; wParam = Radio Button ID
Global Const $TDM_ENABLE_BUTTON = 0x400 + 111 ; lParam = 0 (disable) lParam != 0 (enable) wParam = Button ID
Global Const $TDM_ENABLE_RADIO_BUTTON = 0x400 + 112 ; lParam = 0 (disable) lParam != 0 (enable) wParam = Radio Button ID
Global Const $TDM_CLICK_VERIFICATION = 0x400 + 113 ; wParam = 0 (unchecked) 1 (checked) lParam = 1 (set key focus)
Global Const $TDM_UPDATE_ELEMENT_TEXT = 0x400 + 114 ; wParam = element (TASKDIALOG_ELEMENTS) lParam = new element text (LPCWSTR)
Global Const $TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE = 0x400 + 115 ; wParam = Button ID lParam = 0 (elevation Not required) lParam != 0 (elevation required)
Global Const $TDM_UPDATE_ICON = 0x400 + 116 ; wParam = icon element (TASKDIALOG_ICON_ELEMENTS) lParam = new icon (hIcon If TDF_USE_HICON_* was set PCWSTR otherwise)

$__TDL__ALIGN = "align 4;"
If $_TDL_fUseXTaskDlg Then $__TDL__ALIGN = ""
Global Const $tagTASKDIALOGCONFIG = $__TDL__ALIGN & _
		"UINT cbSize;" & _
		"HWND hwndParent;" & _
		"handle hInstance;" & _
		"dword dwFlags;" & _
		"int dwCommonButtons;" & _
		"ptr pszWindowTitle;" & _ ; PCWSTR
		"ptr MainIcon;" & _ ;union {
		'' & _ ;HICON hMainIcon;" & _
		'' & _ ;PCWSTR pszMainIcon;" & _
		'' & _ ;};" & _
		"ptr pszMainInstruction;" & _ ; PCWSTR
		"ptr pszContent;" & _ ; PCWSTR
		"UINT cButtons;" & _
		"ptr pButtons;" & _ ;const TASKDIALOG_BUTTON *pButtons;" & _
		"int nDefaultButton;" & _
		"UINT cRadioButtons;" & _
		"ptr pRadioButtons;" & _ ;const TASKDIALOG_BUTTON *pRadioButtons;" & _
		"int nDefaultRadioButton;" & _
		"ptr pszVerificationText;" & _ ; PCWSTR
		"ptr pszExpandedInformation;" & _ ; PCWSTR
		"ptr pszExpandedControlText;" & _ ; PCWSTR
		"ptr pszCollapsedControlText;" & _ ; PCWSTR
		"ptr FooterIcon;" & _ ;union {
		'' & _ ;HICON hFooterIcon;" & _
		'' & _ ;PCWSTR pszFooterIcon;" & _
		'' & _ ;};" & _
		"ptr pszFooter;" & _ ; PCWSTR
		"ptr pfCallback;" & _ ; PFTASKDIALOGCALLBACK
		"LONG_PTR lpCallbackData;" & _
		"UINT cxWidth;"
;~ } TASKDIALOGCONFIG;

Global Const $_TDL_BUTTONMAXCHARS = 1024
Global Const $tagTASKDIALOG_BUTTON = $__TDL__ALIGN & _
		"int nButtonID;" & _
		"ptr pszButtonText" ; PCSWSTR


Const $E_OUTOFMEMORY = 0x8007000E
Const $E_INVALIDARG = 0x80070057
Const $E_FAIL = 0x80004005

;===============================================================================
;
; Function Name:   _TaskDialog
; Description::    see http://msdn.microsoft.com/en-us/library/bb760540(VS.85).aspx
; Parameter(s):    see MSDN-link above
; Requirement(s):  Vista or XTaskDlg.dll, doesn't work on Win95
;                  The DLL can be found here: http://www.naughter.com/xtaskdialog.html
; Return Value(s): Success: pressed button
;                  Error: 0 and @error to the error:
;                        1 - 4 : errors from DLLCall :)
;                        E_OUTOFMEMORY	There is insufficient memory to complete the operation.
;                        E_INVALIDARG	One or more arguments are invalid.
;                        E_FAIL	The operation failed.
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _TaskDialog($hwndParent, $hInstance, $szWindowTitle, $szMainInstruction, $szContent = "", $dwCommonButtons = 1, $szIcon = "")
	If $dwCommonButtons < 1 Then $dwCommonButtons = 1
	Local $WTitleType = "wstr"
	If IsNumber($szWindowTitle) Then $WTitleType = "dword"
	Local $MainInstType = "wstr"
	If IsNumber($szMainInstruction) Then $MainInstType = "dword"
	Local $ContentType = "wstr"
	If IsNumber($szContent) Then $ContentType = "dword"
	Local $IconType = "wstr"
	If IsNumber($szIcon) Then $IconType = "dword"
	Local $Dialog = DllCall($_TDL_TaskDialogDll, "dword", "TaskDialog", "hwnd", $hwndParent, "hwnd", $hInstance, $WTitleType, $szWindowTitle, $MainInstType, $szMainInstruction, $ContentType, $szContent, "int", $dwCommonButtons, $IconType, $szIcon, "int*", 0)
	If @error Then Return SetError(@error, 0, 0)
	If $Dialog[0] <> 0 Then Return SetError($Dialog[0], 0, 0)
	Return $Dialog[8]
EndFunc   ;==>_TaskDialog

;===============================================================================
;
; Function Name:   _TaskDialogIndirect
; Description::    see http://msdn.microsoft.com/en-us/library/bb760544(VS.85).aspx
; Parameter(s):    see MSDN-link above
;                     "hMainIcon" and "pszMainIcon" are one entry called "MainIcon"
;                     "hFooterIcon" and "pszFooterIcon" are one entry called "FooterIcon"
; Requirement(s):  Vista or XTaskDlg.dll, doesn't work on Win95
;                  The DLL can be found here: http://www.naughter.com/xtaskdialog.html
; Return Value(s): Success: pressed button ( equal to $pnButton )
;                  Error: 0 and @error to the error:
;                        1 - 4 : errors from DLLCall :)
;                        5 : Not a DLLStruct or pointer to Struct
;                        E_OUTOFMEMORY	There is insufficient memory to complete the operation.
;                        E_INVALIDARG	One or more arguments are invalid.
;                        E_FAIL	The operation failed.
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _TaskDialogIndirect(ByRef $structTASKDIALOGCONFIG, ByRef $pnButton, ByRef $pnRadioButton, ByRef $pfVerificationFlagChecked)
	;$hwndParent, $hInstance, $szWindowTitle, $szMainInstruction, $szContent="", $dwCommonButtons = 1, $szIcon = "")
;~ 	If $dwCommonButtons < 1 Then $dwCommonButtons = 1
	If IsDllStruct($structTASKDIALOGCONFIG) Then
		If DllStructGetData($structTASKDIALOGCONFIG, "cButtons") = 0 And _
				DllStructGetData($structTASKDIALOGCONFIG, "dwCommonButtons") = 0 Then _
				DllStructSetData($structTASKDIALOGCONFIG, "dwCommonButtons", 1)
		Local $PtrTDL = DllStructGetPtr($structTASKDIALOGCONFIG)
	ElseIf IsPtr($structTASKDIALOGCONFIG) Then
		Local $PtrTDL = $structTASKDIALOGCONFIG
	Else
		Return SetError(5, 0, 0)
	EndIf
	Local $Dialog = DllCall($_TDL_TaskDialogDll, "dword", "TaskDialogIndirect", "ptr", $PtrTDL, "int*", 0, "int*", 0, "bool*", 0)
	If @error Then Return SetError(@error, 0, 0)
	If $Dialog[0] <> 0 Then Return SetError($Dialog[0], 0, 0)
	$pnButton = $Dialog[2]
	$pnRadioButton = $Dialog[3]
	$pfVerificationFlagChecked = $Dialog[4]
	Return $Dialog[2]
EndFunc   ;==>_TaskDialogIndirect

;===============================================================================
;
; Function Name:   _TaskDialogIndirectParams
; Description::    see http://msdn.microsoft.com/en-us/library/bb760544(VS.85).aspx
; Parameter(s):    first three: the return-Parameters from above, the others: the members of the DLLStruct :)
; Requirement(s):  Vista or XTaskDlg.dll, doesn't work on Win95
;                  The DLL can be found here: http://www.naughter.com/xtaskdialog.html
; Return Value(s): Success: pressed button ( equal to $pnButton )
;                  Error: 0 and @error to the error:
;                        1 - 4 : errors from DLLCall :)
;                        5 : Not a DLLStruct or pointer to Struct ( should NOT appear, because the Struct is created from the Func ... )
;                        E_OUTOFMEMORY	There is insufficient memory to complete the operation.
;                        E_INVALIDARG	One or more arguments are invalid.
;                        E_FAIL	The operation failed.
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _TaskDialogIndirectParams(ByRef $pnButton, ByRef $pnRadioButton, ByRef $pfVerificationFlagChecked, _
		$hwndParent = 0, $hInstance = 0, $dwFlags = 0, $dwCommonButtons = 0, $szWindowTitle = "", $MainIcon = 0, _
		$szMainInstruction = "", $szContent = "", _
		$arButtons = 0, $nDefaultButton = 0, $arRadioButtons = 0, $nDefaultRadioButton = 0, _
		$szVerificationText = "", $szExpandedInformation = "", _
		$szExpandedControlText = "", $szCollapsedControlText = "", _
		$FooterIcon = 0, $szFooter = "", _
		$pfCallback = 0, $lpCallbackData = 0, $cxWidth = 0)

	Local $structTASKDIALOGCONFIG = DllStructCreate($tagTASKDIALOGCONFIG)
	DllStructSetData($structTASKDIALOGCONFIG, 1, DllStructGetSize($structTASKDIALOGCONFIG))
	DllStructSetData($structTASKDIALOGCONFIG, 2, $hwndParent)
	DllStructSetData($structTASKDIALOGCONFIG, 3, $hInstance)
	DllStructSetData($structTASKDIALOGCONFIG, 4, $dwFlags)
	DllStructSetData($structTASKDIALOGCONFIG, 5, $dwCommonButtons)
	If $szWindowTitle <> "" And IsString($szWindowTitle) Then
		$szWindowTitle = _TaskDialog_StringStruct($szWindowTitle)
		DllStructSetData($structTASKDIALOGCONFIG, 6, DllStructGetPtr($szWindowTitle))
	Else
		DllStructSetData($structTASKDIALOGCONFIG, 6, $szWindowTitle)
	EndIf

	If IsString($MainIcon) And $MainIcon <> "" Then
		$MainIcon = _TaskDialog_StringStruct($MainIcon)
		DllStructSetData($structTASKDIALOGCONFIG, 7, DllStructGetPtr($MainIcon))
	Else
		DllStructSetData($structTASKDIALOGCONFIG, 7, $MainIcon)
	EndIf

	If IsString($szMainInstruction) And $szMainInstruction <> "" Then
		$szMainInstruction = _TaskDialog_StringStruct($szMainInstruction)
		DllStructSetData($structTASKDIALOGCONFIG, 8, DllStructGetPtr($szMainInstruction))
	Else
		DllStructSetData($structTASKDIALOGCONFIG, 8, $szMainInstruction)
	EndIf

	If IsString($szContent) And $szContent <> "" Then
		$szContent = _TaskDialog_StringStruct($szContent)
		DllStructSetData($structTASKDIALOGCONFIG, 9, DllStructGetPtr($szContent))
	Else
		DllStructSetData($structTASKDIALOGCONFIG, 9, $szContent)
	EndIf

	If UBound($arButtons, 0) = 2 And UBound($arButtons, 2) = 2 Then
		Local $structButtons
		Local $size = DllStructGetSize(DllStructCreate($tagTASKDIALOG_BUTTON, 1))
		For $i = 1 To UBound($arButtons)
			$structButtons &= "byte[" & $size & "];"
		Next
		$structButtons = DllStructCreate($structButtons)
		Local $ButtonTemp[UBound($arButtons)]
		For $i = 1 To UBound($arButtons)
			Local $tbutton = DllStructCreate($tagTASKDIALOG_BUTTON, DllStructGetPtr($structButtons, $i))
			DllStructSetData($tbutton, 1, $arButtons[$i - 1][0])
			If IsString($arButtons[$i - 1][1]) And $arButtons[$i - 1][1] <> "" Then
				$arButtons[$i - 1][1] = _TaskDialog_StringStruct($arButtons[$i - 1][1])
				DllStructSetData($tbutton, 2, DllStructGetPtr($arButtons[$i - 1][1]))
			Else
				DllStructSetData($tbutton, 2, $arButtons[$i - 1][1])
			EndIf
;~ 			DllStructSetData($structButtons, ($i * 2), $arButtons[$i][1])
		Next
		DllStructSetData($structTASKDIALOGCONFIG, 10, UBound($arButtons))
		DllStructSetData($structTASKDIALOGCONFIG, 11, DllStructGetPtr($structButtons))
	EndIf
	DllStructSetData($structTASKDIALOGCONFIG, 12, $nDefaultButton)

	If UBound($arRadioButtons, 0) = 2 And UBound($arRadioButtons, 2) = 2 Then
		Local $structRadioButtons
		For $i = 1 To UBound($arRadioButtons)
			$structRadioButtons &= $tagTASKDIALOG_BUTTON & ";"
		Next
		$structRadioButtons = DllStructCreate($structRadioButtons)
		Local $RadioButtonTemp[UBound($arRadioButtons)]
		For $i = 1 To UBound($arRadioButtons)
			DllStructSetData($structRadioButtons, ($i * 2) - 1, $arRadioButtons[$i - 1][0])
			If IsString($arRadioButtons[$i - 1][1]) And $arRadioButtons[$i - 1][1] <> "" Then
				$arRadioButtons[$i - 1][1] = _TaskDialog_StringStruct($arRadioButtons[$i - 1][1])
				DllStructSetData($structRadioButtons, ($i * 2), DllStructGetPtr($arRadioButtons[$i - 1][1]))
			Else
				DllStructSetData($structRadioButtons, ($i * 2), $arRadioButtons[$i - 1][1])
			EndIf
;~ 			DllStructSetData($structRadioButtons, ($i * 2), $arRadioButtons[$i][1])
		Next
		DllStructSetData($structTASKDIALOGCONFIG, 13, UBound($arRadioButtons))
		DllStructSetData($structTASKDIALOGCONFIG, 14, DllStructGetPtr($structRadioButtons))
	EndIf
	DllStructSetData($structTASKDIALOGCONFIG, 15, $nDefaultRadioButton)

	If IsString($szVerificationText) And $szVerificationText <> "" Then
		$szVerificationText = _TaskDialog_StringStruct($szVerificationText)
		DllStructSetData($structTASKDIALOGCONFIG, 16, DllStructGetPtr($szVerificationText))
	Else
		DllStructSetData($structTASKDIALOGCONFIG, 16, $szVerificationText)
	EndIf

	If IsString($szExpandedInformation) And $szExpandedInformation <> "" Then
		$szExpandedInformation = _TaskDialog_StringStruct($szExpandedInformation)
		DllStructSetData($structTASKDIALOGCONFIG, 17, DllStructGetPtr($szExpandedInformation))
	Else
		DllStructSetData($structTASKDIALOGCONFIG, 17, $szExpandedInformation)
	EndIf

	If IsString($szExpandedControlText) And $szExpandedControlText <> "" Then
		$szExpandedControlText = _TaskDialog_StringStruct($szExpandedControlText)
		DllStructSetData($structTASKDIALOGCONFIG, 18, DllStructGetPtr($szExpandedControlText))
	Else
		DllStructSetData($structTASKDIALOGCONFIG, 18, $szExpandedControlText)
	EndIf

	If IsString($szCollapsedControlText) And $szCollapsedControlText <> "" Then
		$szCollapsedControlText = _TaskDialog_StringStruct($szCollapsedControlText)
		DllStructSetData($structTASKDIALOGCONFIG, 19, DllStructGetPtr($szCollapsedControlText))
	Else
		DllStructSetData($structTASKDIALOGCONFIG, 19, $szCollapsedControlText)
	EndIf

	If IsString($FooterIcon) And $FooterIcon <> "" Then
		$FooterIcon = _TaskDialog_StringStruct($FooterIcon)
		DllStructSetData($structTASKDIALOGCONFIG, 20, DllStructGetPtr($FooterIcon))
	Else
		DllStructSetData($structTASKDIALOGCONFIG, 20, $FooterIcon)
	EndIf

	If IsString($szFooter) And $szFooter <> "" Then
		$szFooter = _TaskDialog_StringStruct($szFooter)
		DllStructSetData($structTASKDIALOGCONFIG, 21, DllStructGetPtr($szFooter))
	Else
		DllStructSetData($structTASKDIALOGCONFIG, 21, $szFooter)
	EndIf

	DllStructSetData($structTASKDIALOGCONFIG, 22, $pfCallback)
	DllStructSetData($structTASKDIALOGCONFIG, 23, $lpCallbackData)
	DllStructSetData($structTASKDIALOGCONFIG, 24, $cxWidth)

;~ 	If IsString($) And $ <> "" Then
;~ 		$ = _TaskDialog_StringStruct($)
;~ 		DllStructSetData($structTASKDIALOGCONFIG, 8, DllStructGetPtr($))
;~ 	Else
;~ 		DllStructSetData($structTASKDIALOGCONFIG, 8, $)
;~ 	EndIf


	Local $Dialog = _TaskDialogIndirect($structTASKDIALOGCONFIG, $pnButton, $pnRadioButton, $pfVerificationFlagChecked)
	Return SetError(@error, 0, $Dialog)
EndFunc   ;==>_TaskDialogIndirectParams

Func _TaskDialog_StringStruct($str)
	Local $struct = DllStructCreate("wchar[" & StringLen($str) + 1 & "]")
	DllStructSetData($struct, 1, $str)
	Return $struct
EndFunc   ;==>_TaskDialog_StringStruct
