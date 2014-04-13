#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <WinAPI.au3>

#include "GUIScrollbars_Ex.au3"

Global $iMax_Vert, $iPage_Vert, $nRatio_Vert, $iMax_Horz, $iPage_Horz, $nRatio_Horz, $iH_Tight, $iV_Tight

; Create wrapper GUI
$hGUI = GUICreate("Scroll Bar Examples", 520, 675)
GUISetBkColor(0xC4C4C4, $hGUI)

$hCheckBox_V = GUICtrlCreateCheckBox("", 10, 10, 20, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateLabel("Vertical Scrollbar",  10, 35, 80, 40)

$hVert_Labels = GUICtrlCreateLabel("Panel Ht:",  90, 10, 100, 20)
GUICtrlCreateLabel("Scroll Ht:", 90, 35, 100, 20)
GUICtrlCreateLabel("Ratio:",  90, 60, 100, 20)

$hLabel_AH = GUICtrlCreateLabel("", 190, 10, 50, 20)
$hLabel_SH = GUICtrlCreateLabel("", 190, 35, 50, 20)
$hLabel_RH = GUICtrlCreateLabel("", 190, 60, 50, 20)

$hCheckBox_H = GUICtrlCreateCheckBox("", 260, 10, 20, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateLabel("Horizontal Scrollbar",  260, 35, 80, 40)

$hHorz_Labels = GUICtrlCreateLabel("Panel Width:",  340, 10, 100, 20)
GUICtrlCreateLabel("Scroll Width:", 340, 35, 100, 20)
GUICtrlCreateLabel("Ratio:",  340, 60, 100, 20)

$hLabel_AW = GUICtrlCreateLabel("", 440, 10, 50, 20)
$hLabel_SW = GUICtrlCreateLabel("", 440, 35, 50, 20)
$hLabel_RW = GUICtrlCreateLabel("", 440, 60, 50, 20)

For $i = $hCheckBox_V To $hLabel_RW
	GUICtrlSetFont($i, 12)
	GUICtrlSetResizing($i, $GUI_DOCKALL)
Next

$hCheck_Tight = GUICtrlCreateCheckbox(" Tight", 100, 640, 80, 30)
GUICtrlSetFont(-1, 12)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM)
GUIStartGroup()
$hRadio_Before = GUICtrlCreateRadio(" Before", 280, 640, 80, 30)
GUICtrlSetFont(-1, 12)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM)
$hRadio_After = GUICtrlCreateRadio(" After", 380, 640, 80, 30)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetFont(-1, 12)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM)
GUIStartGroup()

GUISetState()

; Start example
While 1

	If GUICtrlRead($hCheckBox_V) = 1 Then
		For $i = $hVert_Labels To $hLabel_RH
			GUICtrlSetState($i, $GUI_SHOW)
		Next
		$iAperture_Ht = Random(200, 500, 1)
		GUICtrlSetData($hLabel_AH, $iAperture_Ht)
		; Random ratio for vertical scroll size
		$nRatio_Vert = Random(2, 20)
		GUICtrlSetData($hLabel_RH, Round($nRatio_Vert, 2))
		$iScroll_Ht = Int($iAperture_Ht * $nRatio_Vert)
		GUICtrlSetData($hLabel_SH, $iScroll_Ht)
	Else
		For $i = $hVert_Labels To $hLabel_RH
			GUICtrlSetState($i, $GUI_HIDE)
		Next
		$iAperture_Ht = 500
		$iScroll_Ht = 0
	EndIf

	If GUICtrlRead($hCheckBox_H) = 1 Then
		For $i = $hHorz_Labels To $hLabel_RW
			GUICtrlSetState($i, $GUI_SHOW)
		Next
		$iAperture_Width = Random(200, 500, 1)
		GUICtrlSetData($hLabel_AW, $iAperture_Width)
		; Random ratio for horizontal scroll size
		$nRatio_Horz = Random(2, 20)
		GUICtrlSetData($hLabel_RW, Round($nRatio_Horz, 2))
		$iScroll_Width = Int($iAperture_Width * $nRatio_Horz)
		GUICtrlSetData($hLabel_SW, $iScroll_Width)
	Else
		For $i = $hHorz_Labels To $hLabel_RW
			GUICtrlSetState($i, $GUI_HIDE)
		Next
		$iAperture_Width = 500
		$iScroll_Width = 0
	EndIf

	If GUICtrlRead($hCheck_Tight) = 1 Then
		$iH_Tight = 1
		$iV_Tight = 1
	Else
		$iH_Tight = 0
		$iV_Tight = 0
	EndIf

	; Resize wrapper GUI
	WinMove($hGUI, "", Default, Default, Default, $iAperture_Ht + 170)

	; Create aperture GUI
	$hAperture = GUICreate("", $iAperture_Width, $iAperture_Ht, (520 - $iAperture_Width) / 2, 100, $WS_POPUP, $WS_EX_MDICHILD, $hGUI)

	; If scrollbars to be created BEFORE controls
	If GUICtrlRead($hRadio_Before) = 1 Then
		; Generate scrollbars
		$aAperture = _GUIScrollbars_Generate($hAperture, $iScroll_Width, $iScroll_Ht, $iH_Tight, $iV_Tight, True)
		If @error Then
			MsgBox(16, "Error", "Scrollbar generation failed")
			Exit
		EndIf
		; Reset aperture size to smaller area with scrollbars in place
		$iAperture_Width = $aAperture[0]
		$iAperture_Ht = $aAperture[1]
	EndIf

	; Create button to start scrolling
	$hButton_1 = GUICtrlCreateButton("Scroll", ($iAperture_Width - 80) / 2, 20, 80, 30)

	; Create label to show edge if Tight selected
	If GUICtrlRead($hCheck_Tight) = 1 Then
		If GUICtrlRead($hCheckBox_V) = 1 Then
			$iY = $iScroll_Ht - 40
		Else
			$iY = $iAperture_Ht - 40
		EndIf
		If GUICtrlRead($hCheckBox_H) = 1 Then
			$iX = $iScroll_Width - 40
		Else
			$iX = ($iAperture_Width - 40) / 2
		EndIf
		$hCorner = GUICtrlCreateLabel("", $iX, $iY, 40, 40)
		GUICtrlSetBkColor(-1, 0xC4FFC4)
	EndIf

	; Create max width and horizontal sizing labels if required
	If GUICtrlRead($hCheckBox_H) = 1 Then
		$iLine_Ht = $iAperture_Ht
		If GUICtrlRead($hCheckBox_V) = 1 Then $iLine_Ht = $iScroll_Ht
		GUICtrlCreateLabel("", $iScroll_Width - 3, 0, 3, $iLine_Ht - 3)
		GUICtrlSetBkColor(-1, 0xFF0000)
		For $i = 100 To 1500 Step 100
			GUICtrlCreateLabel($i, $i, 0, 30, 15)
			GUICtrlSetBkColor(-1, 0xC4FFC4)
		Next
		; Create page size label
		$iLabel_Ht = 0
		If GUICtrlRead($hCheckBox_V) = 1 Then $iLabel_Ht = $iAperture_Ht
		GUICtrlCreateLabel("", $iAperture_Width - 50, $iLabel_Ht + 100, 100, 40)
		GUICtrlSetBkColor(-1, 0xC4C4FF)
		GUICtrlCreateLabel("Page 1", $iAperture_Width - 40, $iLabel_Ht + 115, 40, 15)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		GUICtrlCreateLabel("Page 2", $iAperture_Width + 5, $iLabel_Ht + 115, 40, 15)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	EndIf

	; Create max length and vertical sizing labels if required
	If GUICtrlRead($hCheckBox_V) = 1 Then
		$iLine_Width = $iAperture_Width
		If GUICtrlRead($hCheckBox_H) = 1 Then $iLine_Width = $iScroll_Width
		GUICtrlCreateLabel("", 0, $iScroll_Ht - 3, $iLine_Width, 3)
		GUICtrlSetBkColor(-1, 0xFF0000)
		For $i = 100 To 5000 Step 100
			GUICtrlCreateLabel($i, 0, $i, 30, 15)
			GUICtrlSetBkColor(-1, 0xC4FFC4)
		Next
		; Create page size label
		GUICtrlCreateLabel("", $iAperture_Width - 40, $iAperture_Ht - 50, 40, 100)
		GUICtrlSetBkColor(-1, 0xFFC4C4)
		GUICtrlCreateLabel("Page 1", $iAperture_Width - 40, $iAperture_Ht - 15, 40, 15)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		GUICtrlCreateLabel("Page 2", $iAperture_Width - 40, $iAperture_Ht, 40, 15)
		GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	EndIf

	; Get correction factors for subsequently created controls
	If GUICtrlRead($hRadio_After) = 1 Then
		$aFactor = _GUIScrollbars_Generate($hAperture, $iScroll_Width, $iScroll_Ht, $iH_Tight, $iV_Tight)
		If @error Then
			MsgBox(16, "Error", "Scrollbar generation failed")
			Exit
		EndIf
	EndIf

	GUISetState()

	; Draw test label in bottom right corner
	If GUICtrlRead($hRadio_Before) = 1 Then
		; Show alignment without factors with $fBefore
		GUICtrlCreateLabel("", $iScroll_Width - 10, $iScroll_Ht - 10, 10, 10)
		GUICtrlSetBkColor(-1, 0x0000FF)
	Else
		; Show need for factors without $fBefore
		GUICtrlCreateLabel("", ($iScroll_Width - 10) * $aFactor[2], ($iScroll_Ht - 10) * $aFactor[3], 10 * $aFactor[2], 10 * $aFactor[3])
		GUICtrlSetBkColor(-1, 0x0000FF)
	EndIf

	While 1

		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit
			Case $hButton_1

				; Scroll page down if required
				If GUICtrlRead($hCheckBox_V) = 1 Then
					_GUIScrollbars_Scroll_Page($hAperture, 0, 2)
					Sleep(1000)
				EndIf
				If GUICtrlRead($hCheckBox_H) = 1 Then
					; Scroll page right if required
					_GUIScrollbars_Scroll_Page($hAperture, 2)
					Sleep(1000)
				EndIf

				; Now scroll to extremity of scrollable GUI
				If GUICtrlRead($hCheckBox_H) = 1 Then _GUIScrollbars_Scroll_Page($hAperture, 99, 0)
				If GUICtrlRead($hCheckBox_V) = 1 Then _GUIScrollbars_Scroll_Page($hAperture, 0, 99)
				Sleep(1000)
				GUIDelete($hAperture)
				ExitLoop
			Case $hCheckBox_V, $hCheckBox_H, $hRadio_Before, $hRadio_After, $hCheck_Tight
				; Delete current instance and start with new settings
				GUIDelete($hAperture)
				ExitLoop
		EndSwitch
	WEnd
WEnd