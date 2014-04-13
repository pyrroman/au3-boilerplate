 #include <GUIConstantsEx.au3>
#include <Sciter-UDF.au3>
#include <windowsconstants.au3>
#include <WinAPI.au3>
#include <SendMessage.au3>



_StStartup()

Const $SM_CXFIXEDFRAME = 7
Global Const $SC_DRAGMOVE = 0xF012
Global $guiWid = 500, $Guiht = 500

; Set distance from edge of window where resizing is possible
Global Const $iMargin = 0
; Set max and min GUI sizes
Global Const $iGUIMinX = 100, $iGUIMinY = 200, $iGUIMaxX = 800, $iGUIMaxY = 600

$hGUI = GUICreate("Sciter", $guiWid, $Guiht, -1, -1, BitOR($WS_SIZEBOX, $WS_MAXIMIZEBOX, $WS_CLIPSIBLINGS, $WS_POPUP), $WS_EX_COMPOSITED)

GUISetState()


$wtitle = _WinAPI_GetSystemMetrics($SM_CYCAPTION)
$wside = _WinAPI_GetSystemMetrics($SM_CXFIXEDFRAME)
$childHt = ($Guiht - 50) / 2 - $wtitle - 2 * $wside
$childWid = $guiWid / 2 - 2 * $wside

;~ $ST = _StCreate(-1,-1,@DesktopWidth-500,@DesktopHeight-300,1,"Skin exemple")
$ST = _StIncGui($hGUI, 0, 0, $childWid, $childHt)
$fi = FileRead(@ScriptDir & '\skin-view.htm')
_StLoadHtml($ST, $fi)
_StWindowAttachEventHandler($ST, "_events", $HANDLE_ALL)

GUISetState()

_WinAPI_SetParent($ST, $hGUI)

; Register message handlers
GUIRegisterMsg($WM_MOUSEMOVE, "_SetCursor") ; For cursor type change
GUIRegisterMsg($WM_LBUTTONDOWN, "_WM_LBUTTONDOWN") ; For resize/drag
GUIRegisterMsg($WM_GETMINMAXINFO, "_WM_GETMINMAXINFO") ; For GUI size limits
GUIRegisterMsg($WM_SIZE, "SetChildrenToBed")

While 1
	Sleep(100)
WEnd

Func _events($ev, $ad)
	If $ev = $HANDLE_KEY Then
		If $ad[0] = 0 Then
			$el = $ad[1]
			$code = $ad[2]
			If $code = 27 Then
				Exit
			EndIf
		EndIf
	EndIf
	If $ev = $HANDLE_BEHAVIOR_EVENT Then
		$bh = $ad[0]
		If $bh = $BUTTON_PRESS Then
			If _StGetAttributeByName($ad[1], "id") = "window-close" Then Exit
		ElseIf $bh = $CONTEXT_MENU_REQUEST Then
			$fi = FileRead(@ScriptDir & '\skin-view.htm')
			_StLoadHtml($ST, $fi)
		EndIf
	EndIf
EndFunc   ;==>_events

Func SetChildrenToBed($hWnd,$iMsg,$wparam,$lparam)
    Local $clientHt = BitAnd($lparam,0xffff)
    Local $clientWid = BitShift($lparam,16)
    WinMove($ST,"",0,10,$clientHt,$clientWid-10)
EndFunc


; Set cursor to correct resizing form if mouse is over a border
Func _SetCursor()
	Local $iCursorID
	Switch _Check_Border()
		Case 0
			$iCursorID = 2
		Case 1, 2
			$iCursorID = 13
		Case 3, 6
			$iCursorID = 11
		Case 5, 7
			$iCursorID = 10
		Case 4, 8
			$iCursorID = 12
	EndSwitch
	GUISetCursor($iCursorID, 1)
EndFunc   ;==>_SetCursor

; Check cursor type and resize/drag window as required
Func _WM_LBUTTONDOWN($hWnd, $iMsg, $wParam, $lParam)
	Local $iCursorType = _Check_Border()
	If $iCursorType > 0 Then ; Cursor is set to resizing style so send appropriate resize message
		$iResizeType = 0xF000 + $iCursorType
		_SendMessage($hGUI, $WM_SYSCOMMAND, $iResizeType, 0)
	Else
		Local $aCurInfo = GUIGetCursorInfo($hGUI)
		If $aCurInfo[4] = 0 Then ; Mouse not over a control
			_SendMessage($hGUI, $WM_SYSCOMMAND, $SC_DRAGMOVE, 0)
		EndIf
	EndIf
EndFunc   ;==>_WM_LBUTTONDOWN

; Determines if mouse cursor over a border
Func _Check_Border()
	Local $aCurInfo = GUIGetCursorInfo()
	Local $aWinPos = WinGetPos($hGUI)
	Local $iSide = 0
	Local $iTopBot = 0
	If $aCurInfo[0] < $iMargin Then $iSide = 1
	If $aCurInfo[0] > $aWinPos[2] - $iMargin Then $iSide = 2
	If $aCurInfo[1] < $iMargin Then $iTopBot = 3
	If $aCurInfo[1] > $aWinPos[3] - $iMargin Then $iTopBot = 6
	Return $iSide + $iTopBot
EndFunc   ;==>_Check_Border

; Set min and max GUI sizes
Func _WM_GETMINMAXINFO($hWnd, $iMsg, $wParam, $lParam)
	$tMinMaxInfo = DllStructCreate("int;int;int;int;int;int;int;int;int;int", $lParam)
	DllStructSetData($tMinMaxInfo, 7, $iGUIMinX)
	DllStructSetData($tMinMaxInfo, 8, $iGUIMinY)
	DllStructSetData($tMinMaxInfo, 9, $iGUIMaxX)
	DllStructSetData($tMinMaxInfo, 10, $iGUIMaxY)
	Return 0
EndFunc   ;==>_WM_GETMINMAXINFO
