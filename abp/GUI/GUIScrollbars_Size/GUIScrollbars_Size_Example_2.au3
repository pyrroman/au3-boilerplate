#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GUIScrollBars.au3>
#include <ScrollBarConstants.au3>

#include "GUIScrollbars_Size.au3"

Global $ahLabels[100] = [0]

$hGUI = GUICreate("Test", 300, 300)

GUISetState()

$aRet = _GUIScrollbars_Size(0, 550, 300, 300)
If @error Then
	ConsoleWrite($aRet & " - " & @error & " - " & @Extended & @CRLF)
Else
	For $i = 0 To 5
		ConsoleWrite($aRet[$i] & @CRLF)
	Next
EndIf

GUIRegisterMsg($WM_VSCROLL, "_Scrollbars_WM_VSCROLL")

_GUIScrollBars_Init($hGUI)
_GUIScrollBars_ShowScrollBar($hGUI, $SB_VERT, True)
_GUIScrollBars_ShowScrollBar($hGUI, $SB_HORZ, False)
_GUIScrollBars_SetScrollInfoPage($hGUI, $SB_VERT, $aRet[2])
_GUIScrollBars_SetScrollInfoMax($hGUI, $SB_VERT, $aRet[3])

$hButton = GUICtrlCreateButton("Change number of labels", 10, 10, 265, 30)

_Draw_Labels(10)

While 1

	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GUI_EVENT_RESTORE
			_GUIScrollbars_Restore($hGUI, True, False)
		Case $hButton
			Do
				$iCount = Number(InputBox("Resize scroll area", "Select number of labels to display (min 6)", "", "", 240, 130))
			Until $iCount > 5

			 _Draw_labels($iCount)
			$aRet = _GUIScrollbars_Size(0, ($iCount + 1) * 50, 300, 300)
			_GUIScrollBars_SetScrollInfoPage($hGUI, $SB_VERT, $aRet[2])
			_GUIScrollBars_SetScrollInfoMax($hGUI, $SB_VERT, $aRet[3])
	EndSwitch

WEnd

Func _Draw_labels($iCount)

	ConsoleWrite($iCount & " - " & $ahLabels[0] & @CRLF)

	GUISwitch($hGUI)

	If $iCount > $ahLabels[0] Then
		For $i = $ahLabels[0] + 1 To $iCount
			ConsoleWrite("Add " & $i & @CRLF)
			$ahLabels[$i] = GUICtrlCreateLabel($i, 10, $i * 50, 265, 40)
			GUICtrlSetBkColor(-1, 0xFF8080)
			GUICtrlSetFont(-1, 18)
		Next
	Else
		For $i = $iCount + 1 To $ahLabels[0]
			ConsoleWrite("Del " & $i & @CRLF)
			GUICtrlDelete($ahLabels[$i])
		Next
	EndIf
	$ahLabels[0] = $iCount

EndFunc

Func _Scrollbars_WM_VSCROLL($hWnd, $Msg, $wParam, $lParam)

	#forceref $Msg, $wParam, $lParam
	Local $nScrollCode = BitAND($wParam, 0x0000FFFF)
	Local $iIndex = -1, $yChar, $yPos
	Local $Min, $Max, $Page, $Pos, $TrackPos

	For $x = 0 To UBound($aSB_WindowInfo) - 1
		If $aSB_WindowInfo[$x][0] = $hWnd Then
			$iIndex = $x
			$yChar = $aSB_WindowInfo[$iIndex][3]
			ExitLoop
		EndIf
	Next
	If $iIndex = -1 Then Return 0

	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $SB_VERT)
	$Min = DllStructGetData($tSCROLLINFO, "nMin")
	$Max = DllStructGetData($tSCROLLINFO, "nMax")
	$Page = DllStructGetData($tSCROLLINFO, "nPage")
	$yPos = DllStructGetData($tSCROLLINFO, "nPos")
	$Pos = $yPos
	$TrackPos = DllStructGetData($tSCROLLINFO, "nTrackPos")

	Switch $nScrollCode
		Case $SB_TOP
			DllStructSetData($tSCROLLINFO, "nPos", $Min)
		Case $SB_BOTTOM
			DllStructSetData($tSCROLLINFO, "nPos", $Max)
		Case $SB_LINEUP
			DllStructSetData($tSCROLLINFO, "nPos", $Pos - 1)
		Case $SB_LINEDOWN
			DllStructSetData($tSCROLLINFO, "nPos", $Pos + 1)
		Case $SB_PAGEUP
			DllStructSetData($tSCROLLINFO, "nPos", $Pos - $Page)
		Case $SB_PAGEDOWN
			DllStructSetData($tSCROLLINFO, "nPos", $Pos + $Page)
		Case $SB_THUMBTRACK
			DllStructSetData($tSCROLLINFO, "nPos", $TrackPos)
	EndSwitch

	DllStructSetData($tSCROLLINFO, "fMask", $SIF_POS)
	_GUIScrollBars_SetScrollInfo($hWnd, $SB_VERT, $tSCROLLINFO)
	_GUIScrollBars_GetScrollInfo($hWnd, $SB_VERT, $tSCROLLINFO)

	$Pos = DllStructGetData($tSCROLLINFO, "nPos")
	If ($Pos <> $yPos) Then
		_GUIScrollBars_ScrollWindow($hWnd, 0, $yChar * ($yPos - $Pos))
		$yPos = $Pos
	EndIf

	Return $GUI_RUNDEFMSG

EndFunc   ;==>_Scrollbars_WM_VSCROLL