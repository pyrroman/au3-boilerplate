
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GUIScrollbars.au3>
#include <ScrollbarConstants.au3>

#include "GUIScrollbars_Size.au3"

Global $hButton_Show_UnCorr = 9999, $hButton_Show_Corr = 9999, $hButton_Show_Size = 9999, $hButton_Show_Dock = 9999

; Set aperture and scroll sizes
$iH_Aperture = 400
$iV_Aperture = 400
$iH_Scroll = 1000
$iV_Scroll = 1000

; Create GUI
$hGUI = GUICreate("Scrollbar Test", $iH_Aperture, $iV_Aperture)
GUISetBkColor(0xD0D0FF, $hGUI)

; Create buttons
$hButton_Size = GUICtrlCreateButton("Pass Size",  10, 10, 80, 30)
$sMsg = "Pressing 'Pass Size' runs the function BEFORE the scrollbars are" & @CRLF & _
		"added.  The required size of the aperture is passed." & @CRLF & @CRLF &  _
		"Controls should be created AFTER the scrollbars are created."
$hLabel_Size = GUICtrlCreateLabel($sMsg, 10, 50, $iH_Aperture - 20, 50)
$hButton_Handle = GUICtrlCreateButton("Pass Handle", 10, 150, 80, 30)
$sMsg = "Pressing 'Pass Handle' runs the function AFTER the scrollbars are" & @CRLF & _
		"added.  The GUI handle is passed." & @CRLF & @CRLF &  _
		"Controls should be created BEFORE the scrollbars are created"
$hLabel_Handle = GUICtrlCreateLabel($sMsg, 10, 200, $iH_Aperture - 20, 50)

GUISetState()

While 1

	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $hButton_Size
			GUICtrlSetState($hButton_Size, $GUI_HIDE)
			GUICtrlSetState($hButton_Handle, $GUI_HIDE)
			GUICtrlDelete($hLabel_Size)
			GUICtrlDelete($hLabel_Handle)
			; Get scrollbar values BEFORE showing bars
			$aRet = _GUIScrollbars_Size($iH_Scroll, $iV_Scroll, $iH_Aperture, $iV_Aperture)
			If @error Then
				MsgBox(0, "Error", "Sizing error" & @CRLF & _
						"Return: " & $aRet & @CRLF & _
						"Error: " & @error & @CRLF & _
						"Extended: " & @extended)
				Exit
			Else
				For $i = 0 To 5
					ConsoleWrite($aRet[$i]	& @CRLF)
				Next
			EndIf
			; Register scrollbar messages
			GUIRegisterMsg($WM_VSCROLL, "_Scrollbars_WM_VSCROLL")
			GUIRegisterMsg($WM_HSCROLL, "_Scrollbars_WM_HSCROLL")
			; Show scrollbars
			_GUIScrollBars_Init($hGUI)
			; Set scrollbar limits
			_GUIScrollBars_SetScrollInfoPage($hGUI, $SB_HORZ, $aRet[0])
			_GUIScrollBars_SetScrollInfoMax($hGUI, $SB_HORZ, $aRet[1])
			_GUIScrollBars_SetScrollInfoPage($hGUI, $SB_VERT, $aRet[2])
			_GUIScrollBars_SetScrollInfoMax($hGUI, $SB_VERT, $aRet[3])

			$sMsg = "The buttons and labels below have been created AFTER" & @CRLF & _
					"the scrollbars.  Pressing the buttons will show that there" & @CRLF & _
					"is no requirement to apply the correction factors to either" & @CRLF & _
					"normal or DOCKALL controls"
			GUICtrlCreateLabel($sMsg, 10, 10, $iH_Aperture - 20, 90)

			$hButton_Show_UnCorr = GUICtrlCreateButton("Show UnCorr", 100, 150, 85, 30)
			$hButton_Show_Dock = GUICtrlCreateButton("Show DOCKALL", 100, 300, 85, 30)

			; Show preset positions
			GUICtrlCreateLabel("", 200, 150, 90, 30)
			GUICtrlSetBkColor(-1, 0)
			GUICtrlCreateLabel("200x150", 200, 150, 80, 30)
			GUICtrlSetBkColor(-1, 0xC4C4C4)
			GUICtrlCreateLabel("", 200, 300, 90, 30)
			GUICtrlSetBkColor(-1, 0)
			GUICtrlCreateLabel("200x300" & @CRLF & "DOCKALL", 200, 300, 80, 30)
			GUICtrlSetBkColor(-1, 0xC4C4C4)
			GUICtrlSetResizing(-1, $GUI_DOCKALL)

			;; Show edges
			If $iH_Scroll = 0 Then
				GUICtrlCreateLabel("", 0, $iV_Scroll, $iH_Aperture, 3)
				GUICtrlSetBkColor(-1, 0xFF0000)
			ElseIf $iV_Scroll = 0 Then
				GUICtrlCreateLabel("", $iH_Scroll, 0, 3, $iV_Aperture)
				GUICtrlSetBkColor(-1, 0xFF0000)
			Else
				GUICtrlCreateLabel("", $iH_Scroll, 0, 3, $iV_Scroll)
				GUICtrlSetBkColor(-1, 0xFF0000)
				GUICtrlCreateLabel("", 0, $iV_Scroll, $iH_Scroll + 3, 3)
				GUICtrlSetBkColor(-1, 0xFF0000)
			EndIf

			$sMsg = "As the GUI has not been resized," & @CRLF & _
				"the corner position remains:" & @CRLF & _
				$iH_Scroll & " x " & $iV_Scroll
			GUICtrlCreateLabel($sMsg, $iH_Scroll - 210, $iV_Scroll - 50, 200, 50, 2)

		Case $hButton_Handle
			GUICtrlSetState($hButton_Size, $GUI_HIDE)
			GUICtrlSetState($hButton_Handle, $GUI_HIDE)
			GUICtrlDelete($hLabel_Size)
			GUICtrlDelete($hLabel_Handle)
			$sMsg = "The buttons and labels below have been created BEFORE" & @CRLF & _
					"the scrollbars.  They will be slightly moved and resized as" & @CRLF & _
					"the GUI shrinks to the new client area size.  Pressing the" & @CRLF & _
					"buttons will show the result of applying (or not) the" & @CRLF & _
					"correction factors." & @CRLF & _
					"Note the DOCKALL label remains in position"
			GUICtrlCreateLabel($sMsg, 10, 10, $iH_Aperture - 20, 90)

			$hButton_Show_UnCorr = GUICtrlCreateButton("Show UnCorr", 100, 150, 85, 30)
			$hButton_Show_Corr = GUICtrlCreateButton("Show Corr Pos", 100, 200, 85, 30)
			$hButton_Show_Size = GUICtrlCreateButton("Show Corr Size", 100, 250, 85, 30)
			$hButton_Show_Dock = GUICtrlCreateButton("Show DOCKALL", 100, 300, 85, 30)

			; Show preset positions
			GUICtrlCreateLabel("", 200, 150, 90, 30)
			GUICtrlSetBkColor(-1, 0)
			GUICtrlCreateLabel("200x150", 200, 150, 80, 30)
			GUICtrlSetBkColor(-1, 0xC4C4C4)
			GUICtrlCreateLabel("", 200, 200, 90, 30)
			GUICtrlSetBkColor(-1, 0)
			GUICtrlCreateLabel("200x200", 200, 200, 80, 30)
			GUICtrlSetBkColor(-1, 0xC4C4C4)
			GUICtrlCreateLabel("", 200, 250, 90, 30)
			GUICtrlSetBkColor(-1, 0)
			GUICtrlCreateLabel("200x250", 200, 250, 80, 30)
			GUICtrlSetBkColor(-1, 0xC4C4C4)
			GUICtrlCreateLabel("", 200, 300, 90, 30)
			GUICtrlSetBkColor(-1, 0)
			GUICtrlSetResizing(-1, $GUI_DOCKALL)
			GUICtrlCreateLabel("200x300" & @CRLF & "DOCKALL", 200, 300, 80, 30)
			GUICtrlSetBkColor(-1, 0xC4C4C4)
			GUICtrlSetResizing(-1, $GUI_DOCKALL)

			; Show edges
			If $iH_Scroll = 0 Then
				GUICtrlCreateLabel("", 0, $iV_Scroll, $iH_Aperture, 3)
				GUICtrlSetBkColor(-1, 0xFF0000)
			ElseIf $iV_Scroll = 0 Then
				GUICtrlCreateLabel("", $iH_Scroll, 0, 3, $iV_Aperture)
				GUICtrlSetBkColor(-1, 0xFF0000)
			Else
				GUICtrlCreateLabel("", $iH_Scroll, 0, 3, $iV_Scroll)
				GUICtrlSetBkColor(-1, 0xFF0000)
				GUICtrlCreateLabel("", 0, $iV_Scroll, $iH_Scroll + 3, 3)
				GUICtrlSetBkColor(-1, 0xFF0000)
			EndIf

			$hButton_Create = GUICtrlCreateButton("Create Scrollbars", 10, 110, 160, 30)

			While 1
				Switch GUIGetMsg()
					Case $GUI_EVENT_CLOSE
						Exit
					Case $hButton_Create
						GUICtrlDelete($hButton_Create)
						ExitLoop
				EndSwitch
			WEnd

			; Register scrollbar messages
			GUIRegisterMsg($WM_VSCROLL, "_Scrollbars_WM_VSCROLL")
			GUIRegisterMsg($WM_HSCROLL, "_Scrollbars_WM_HSCROLL")
			; Show scrollbars
			_GUIScrollBars_Init($hGUI)
			_GUIScrollBars_ShowScrollBar($hGUI, $SB_BOTH, True)
			If $iH_Scroll = 0 Then _GUIScrollBars_ShowScrollBar($hGUI, $SB_HORZ, False)
			If $iV_Scroll = 0 Then _GUIScrollBars_ShowScrollBar($hGUI, $SB_VERT, False)

			; Get scrollbar values AFTER showing bars
			$aRet = _GUIScrollbars_Size($iH_Scroll, $iV_Scroll, $hGUI)
			If @error Then
				MsgBox(0, "Error", "Sizing error" & @CRLF & _
						"Return: " & $aRet & @CRLF & _
						"Error: " & @error & @CRLF & _
						"Extended: " & @extended)
				Exit
			Else
				For $i = 0 To 5
					ConsoleWrite($aRet[$i]	& @CRLF)
				Next
			EndIf
			; Set scrollbar limits
			_GUIScrollBars_SetScrollInfoPage($hGUI, $SB_HORZ, $aRet[0])
			_GUIScrollBars_SetScrollInfoMax($hGUI, $SB_HORZ, $aRet[1])
			_GUIScrollBars_SetScrollInfoPage($hGUI, $SB_VERT, $aRet[2])
			_GUIScrollBars_SetScrollInfoMax($hGUI, $SB_VERT, $aRet[3])

			$sMsg = "As the GUI has been resized," & @CRLF & _
				"the corner position is now:" & @CRLF & _
				Int($iH_Scroll * $aRet[4]) & " x " & Int($iV_Scroll * $aRet[5])
			GUICtrlCreateLabel($sMsg, ($iH_Scroll * $aRet[4]) - 210, ($iV_Scroll * $aRet[5]) - 50, 200, 50, 2)

		Case $hButton_Show_UnCorr
			; Add label with uncorrected coordinates
			$aCorr = _Scroll_Move_Corr($hGUI)
			GUICtrlCreateLabel("200x150" & @CRLF & "UnCorrected", 200 - $aCorr[0], 150 - $aCorr[1], 80, 30)
			GUICtrlSetBkColor(-1, 0xFFC4C4)
			GUICtrlSetState($hButton_Show_UnCorr, $GUI_DISABLE)
		Case $hButton_Show_Corr
			; Add label with corrected coordinates
			$aCorr = _Scroll_Move_Corr($hGUI)
			GUICtrlCreateLabel("200x200" & @CRLF & "Corr Position", 200 * $aRet[4] - $aCorr[0], 200 * $aRet[5] - $aCorr[1], 80, 30)
			GUICtrlSetBkColor(-1, 0xFFD000)
			GUICtrlSetState($hButton_Show_Corr, $GUI_DISABLE)
		Case $hButton_Show_Size
			; Add label with corrected coordinates
			$aCorr = _Scroll_Move_Corr($hGUI)
			GUICtrlCreateLabel("200x250" & @CRLF & "Corr Pos + Size", 200 * $aRet[4] - $aCorr[0], 250 * $aRet[5] - $aCorr[1], 80 * $aRet[4], 30 * $aRet[5])
			GUICtrlSetBkColor(-1, 0xC4FFC4)
			GUICtrlSetState($hButton_Show_Size, $GUI_DISABLE)
		Case $hButton_Show_Dock
			; Add label with uncorrected coordinates
			$aCorr = _Scroll_Move_Corr($hGUI)
			GUICtrlCreateLabel("200x300" & @CRLF & "DOCKALL", 200 - $aCorr[0], 300 - $aCorr[1], 80, 30)
			GUICtrlSetBkColor(-1, 0xC4FFC4)
			GUICtrlSetState($hButton_Show_Dock, $GUI_DISABLE)
	EndSwitch

WEnd

Func _Scroll_Move_Corr($hWnd)

	Local $aCorr[2]
	$aCorr[0] = _GUIScrollBars_GetScrollInfoPos($hWnd, $SB_HORZ) * Int($iH_Scroll / _GUIScrollBars_GetScrollInfoMax($hWnd, $SB_HORZ))
	$aCorr[1] = _GUIScrollBars_GetScrollInfoPos($hWnd, $SB_VERT) * Int($iV_Scroll / _GUIScrollBars_GetScrollInfoMax($hWnd, $SB_VERT))

	Return $aCorr

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

Func _Scrollbars_WM_HSCROLL($hWnd, $Msg, $wParam, $lParam)

	#forceref $Msg, $lParam
	Local $nScrollCode = BitAND($wParam, 0x0000FFFF)
	Local $iIndex = -1, $xChar, $xPos
	Local $Page, $Pos, $TrackPos

	For $x = 0 To UBound($aSB_WindowInfo) - 1
		If $aSB_WindowInfo[$x][0] = $hWnd Then
			$iIndex = $x
			$xChar = $aSB_WindowInfo[$iIndex][2]
			ExitLoop
		EndIf
	Next
	If $iIndex = -1 Then Return 0

	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $SB_HORZ)
	$Page = DllStructGetData($tSCROLLINFO, "nPage")
	$xPos = DllStructGetData($tSCROLLINFO, "nPos")
	$Pos = $xPos
	$TrackPos = DllStructGetData($tSCROLLINFO, "nTrackPos")
	Switch $nScrollCode
		Case $SB_LINELEFT
			DllStructSetData($tSCROLLINFO, "nPos", $Pos - 1)
		Case $SB_LINERIGHT
			DllStructSetData($tSCROLLINFO, "nPos", $Pos + 1)
		Case $SB_PAGELEFT
			DllStructSetData($tSCROLLINFO, "nPos", $Pos - $Page)
		Case $SB_PAGERIGHT
			DllStructSetData($tSCROLLINFO, "nPos", $Pos + $Page)
		Case $SB_THUMBTRACK
			DllStructSetData($tSCROLLINFO, "nPos", $TrackPos)
	EndSwitch

	DllStructSetData($tSCROLLINFO, "fMask", $SIF_POS)
	_GUIScrollBars_SetScrollInfo($hWnd, $SB_HORZ, $tSCROLLINFO)
	_GUIScrollBars_GetScrollInfo($hWnd, $SB_HORZ, $tSCROLLINFO)

	$Pos = DllStructGetData($tSCROLLINFO, "nPos")
	If ($Pos <> $xPos) Then _GUIScrollBars_ScrollWindow($hWnd, $xChar * ($xPos - $Pos), 0)

	Return $GUI_RUNDEFMSG

EndFunc   ;==>_Scrollbars_WM_HSCROLL