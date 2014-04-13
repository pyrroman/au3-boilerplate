#include-once

; #INDEX# ============================================================================================================
; Title .........: GUIFrame
; AutoIt Version : 3.3 +
; Language ......: English
; Description ...: Splits a GUI into slideable and resizable 2 part frames which can be further split if required
; Remarks .......: - The UDF uses OnAutoItExitRegister to call _GUIFrame_Exit to delete subclassed separator bars
;                    using the UDF created WndProc and to release the Callback on exit
;                  - If the script already has a WM_SIZE handler then do NOT use _GUIFrame_ResizeReg,
;                    but call _GUIFrame_SIZE_Handler from within the existing handler
; Author ........: Original UDF by Kip
; Modified ......; This version by Melba23 - using x64 compatible code drawn from Yashied's WinAPIEx library
; ====================================================================================================================

; #AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7

; #INCLUDES# =========================================================================================================
#include <WinAPI.au3>

; #GLOBAL VARIABLES# =================================================================================================

; Array to hold handles for each frame set
Global $aGF_HandleIndex[1][7] = [[0, 0, 0]]
; [0][0] = 0 ; Count of frames      [0][1] = Move registered flag
; [n][0] = Parent GUI handle        [n][4] = Original GUI handle
; [n][1] = First frame handle       [n][5] = Indices of first frame internal frames
; [n][2] = Second frame handle      [n][6] = Indices of second frame internal frames
; [n][3] = Separator bar handle

; Array to hold sizing percentages for each frame set
Global $aGF_SizingIndex[1][8]
; [n][0] = First frame min      [n][2] = X coord    [n][4] = Width		[n][6] = Seperator percentage position
; [n][1] = Second frame min     [n][3] = Y coord    [n][5] = Height		[n][7] = Resize type (0/1/2)

; Array to hold other settings for each frame set
Global $aGF_SettingsIndex[1][3]
; [n][0] = Separator orientation (vert/horz = 0/1)
; [n][1] = Resizable frame flag (0/1)
; [n][2] = Separator size (default = 5)

; Array to hold WinProc handles for each separator
Global $aGF_SepProcIndex[1][2] = [[0, 0]]

; Store registered Callback handle
Global $hGF_RegCallBack = DllCallbackRegister("_GUIFrame_SepWndProc", "lresult", "hwnd;uint;wparam;lparam")
$aGF_SepProcIndex[0][1] = DllCallbackGetPtr($hGF_RegCallBack)

; #ONAUTOITEXIT FUNCTIONS# ===========================================================================================
OnAutoItExitRegister("_GUIFrame_Exit")

; #CURRENT# ==========================================================================================================
; _GUIFrame_Create:       Splits a GUI into 2 frames
; _GUIFrame_SetMin:       Sets minimum sizes for each frame
; _GUIFrame_ResizeSet:    Sets resizing flag for all or specified frame sets
; _GUIFrame_GetHandle:    Returns the handle of a frame element (required for further splitting)
; _GUIFrame_Switch:       Sets a frame element as current GUI
; _GUIFrame_GetSepPos:    Returns the current position of the separator
; _GUIFrame_SetSepPos:    Moves the separator bar to adjust frame sizes
; _GUIFrame_ResizeReg:    Registers WM_SIZE message for resizing
; _GUIFrame_SIZE_Handler: Called from a WM_SIZE message handler to resize frames using _GUIFrame_Move
; ====================================================================================================================

; #INTERNAL_USE_ONLY#=================================================================================================
; _GUIFrame_SepSubClass:   Sets new WndProc for frame separator bar
; _GUIFrame_SepWndProc:    New WndProc for frame separator bar
; _GUIFrame_SepPassMsg:    Passes Msg to original frame WndProc for action
; _GUIFrame_Move:          Moves and resizes frame elements and separator bars
; _GUIFrame_Exit:          Deletes all subclassed separator bars to free UDF WndProc and frees registered callback handle
; ====================================================================================================================

; #FUNCTION# =========================================================================================================
; Name...........: _GUIFrame_Create
; Description ...: Splits a GUI into 2 frames
; Syntax.........: _GUIFrame_Create($hWnd, $iSepOrient = 0, $iSepPos = 0, $iSepSize = 5, $iX = 0, $iY = 0, $iWidth = 0, $iHeight = 0, $iStyle = 0, $iExStyle = 0)
; Parameters ....: $hWnd - Handle of GUI to split
;                  $iSepOrient - Orientation of separator bar: 0 = Vertical (default), 1 = Horizontal
;                  $iSepPos - Required initial position of separator (default = centre of frame GUI)
;                  $iSepSize - Size of separator bar (default = 5, min = 3, max = 9)
;                  $iX - Left of frame area (default = 0)
;                  $iY - Top of frame area (default = 0)
;                  $iWidth - Width of frame area (default = full width)
;                  $iHeight - Height of frame area (default = full height)
;                  SiStyle - Required style value for frame elements
;                  SiExStyle - Required extended style value for frame elements
; Requirement(s).: v3.3 +
; Return values .: Success:  Returns index number of frame/separator set
;                  Failure:  Returns 0 and sets @error as follows:
;                  1 = Child limit exceeded
;                  2 = GUI creation failed
;                  2 = Separator subclassing failed
; Author ........: Kip
; Modified ......: Melba23
; Remarks .......:
; Example........: Yes
;=====================================================================================================================
Func _GUIFrame_Create($hWnd, $iSepOrient = 0, $iSepPos = 0, $iSepSize = 5, $iX = 0, $iY = 0, $iOrg_Width = 0, $iOrg_Height = 0, $iStyle = 0, $iExStyle = 0)

	Local $iSeperator_Pos, $hSeparator, $hFirstFrame, $hSecondFrame, $nSepPercent

	; Set separator size
	Local $iSeparatorSize = 5
	Switch $iSepSize
		Case 3 To 9
			$iSeparatorSize = $iSepSize
	EndSwitch

	; Set default sizing if no parameters set
	Local $iWidth = $iOrg_Width
	Local $iHeight = $iOrg_Height
	Local $aFullSize = WinGetClientSize($hWnd)
	If Not $iOrg_Width Then $iWidth = $aFullSize[0]
	If Not $iOrg_Height Then $iHeight = $aFullSize[1]

	; Create parent GUI within client area
	Local $hParent = GUICreate("FrameParent", $iWidth, $iHeight, $iX, $iY, BitOR(0x40000000, $iStyle), $iExStyle, $hWnd) ; $WS_CHILD
	GUISetState(@SW_SHOW, $hParent)

	; Confirm size of frame parent client area
	Local $aSize = WinGetClientSize($hParent)
	$iWidth = $aSize[0]
	$iHeight = $aSize[1]

	If $iSepOrient = 0 Then

		; Set initial separator position
		$iSeperator_Pos = $iSepPos
		; Adjust position if not within GUI or default set (=0)
		If $iSepPos > $iWidth Or $iSepPos < 1 Then
			$iSeperator_Pos = Round(($iWidth / 2) - ($iSeparatorSize / 2))
		EndIf
		; Create separator bar and force cursor change over separator
		$hSeparator = GUICreate("", $iSeparatorSize, $iHeight, $iSeperator_Pos, 0, 0x40000000, -1, $hParent) ;$WS_CHILD
		GUICtrlCreateLabel("", 0, 0, $iSeparatorSize, $iHeight, -1, 0x00000001) ; $WS_EX_DLGMODALFRAME
		GUICtrlSetCursor(-1, 13)
		GUISetState(@SW_SHOW, $hSeparator)
		; Create the sizable frames
		$hFirstFrame = GUICreate("", $iSeperator_Pos, $iHeight, 0, 0, 0x40000000, -1, $hParent) ;$WS_CHILD
		GUISetState(@SW_SHOW, $hFirstFrame)
		$hSecondFrame = GUICreate("", $iWidth - ($iSeperator_Pos + $iSeparatorSize), $iHeight, $iSeperator_Pos + $iSeparatorSize, 0, 0x40000000, -1, $hParent) ;$WS_CHILD
		GUISetState(@SW_SHOW, $hSecondFrame)
		; Set seperator position percentage
		$nSepPercent = $iSeperator_Pos / $iWidth

	Else

		$iSeperator_Pos = $iSepPos
		If $iSepPos > $iHeight Or $iSepPos < 1 Then
			$iSeperator_Pos = Round(($iHeight / 2) - ($iSeparatorSize / 2))
		EndIf
		$hSeparator = GUICreate("", $iWidth, $iSeparatorSize, 0, $iSeperator_Pos, 0x40000000, -1, $hParent) ;$WS_CHILD
		GUICtrlCreateLabel("", 0, 0, $iWidth, $iSeparatorSize, -1, 0x01) ; $WS_EX_DLGMODALFRAME
		GUICtrlSetCursor(-1, 11)
		GUISetState(@SW_SHOW, $hSeparator)
		$hFirstFrame = GUICreate("", $iWidth, $iSeperator_Pos, 0, 0, 0x40000000, -1, $hParent) ;$WS_CHILD
		GUISetState(@SW_SHOW, $hFirstFrame)
		$hSecondFrame = GUICreate("", $iWidth, $iHeight - ($iSeperator_Pos + $iSeparatorSize), 0, $iSeperator_Pos + $iSeparatorSize, 0x40000000, -1, $hParent) ;$WS_CHILD
		GUISetState(@SW_SHOW, $hSecondFrame)
		$nSepPercent = $iSeperator_Pos / $iHeight

	EndIf

	; Check for error creating GUIs
	If $hParent = 0 Or $hSeparator = 0 Or $hFirstFrame = 0 Or $hSecondFrame = 0 Then
		; Delete all GUIs and return error
		GUIDelete($hParent)
		GUIDelete($hSeparator)
		GUIDelete($hFirstFrame)
		GUIDelete($hSecondFrame)
		Return SetError(2, 0, 0)
	EndIf

	; Subclass the separator
	If _GUIFrame_SepSubClass($hSeparator) = 0 Then
		; If Subclassing failed then delete all GUIs and return error
		GUIDelete($hParent)
		GUIDelete($hSeparator)
		GUIDelete($hFirstFrame)
		GUIDelete($hSecondFrame)
		Return SetError(3, 0, 0)
	EndIf

	; Create new lines in the storage arrays for this frame set
	Local $iIndex = $aGF_HandleIndex[0][0] + 1
	ReDim $aGF_HandleIndex[$iIndex + 1][7]
	ReDim $aGF_SizingIndex[$iIndex + 1][8]
	ReDim $aGF_SettingsIndex[$iIndex + 1][3]

	; Store this frame set handles/variables/defaults in the new lines
	$aGF_HandleIndex[0][0] = $iIndex
	$aGF_HandleIndex[$iIndex][0] = $hParent
	$aGF_HandleIndex[$iIndex][1] = $hFirstFrame
	$aGF_HandleIndex[$iIndex][2] = $hSecondFrame
	$aGF_HandleIndex[$iIndex][3] = $hSeparator
	$aGF_HandleIndex[$iIndex][4] = $hWnd
	$aGF_HandleIndex[$iIndex][5] = 0
	$aGF_HandleIndex[$iIndex][6] = 0
	$aGF_SizingIndex[$iIndex][0] = 0
	$aGF_SizingIndex[$iIndex][1] = 0
	$aGF_SizingIndex[$iIndex][6] = $nSepPercent
	$aGF_SettingsIndex[$iIndex][0] = $iSepOrient
	$aGF_SettingsIndex[$iIndex][1] = 0
	$aGF_SettingsIndex[$iIndex][2] = $iSeparatorSize

	; Store this frame index in parent line if parent is an existing frame
	For $i = 1 To $aGF_HandleIndex[0][0] - 1
		If $aGF_HandleIndex[$i][1] = $hWnd Then
			If $aGF_HandleIndex[$i][5] = 0 Then
				$aGF_HandleIndex[$i][5] = $iIndex
			Else
				$aGF_HandleIndex[$i][5] &= "|" & $iIndex
			EndIf
			ExitLoop
		EndIf
		If $aGF_HandleIndex[$i][2] = $hWnd Then
			If $aGF_HandleIndex[$i][6] = 0 Then
				$aGF_HandleIndex[$i][6] = $iIndex
			Else
				$aGF_HandleIndex[$i][6] &= "|" & $iIndex
			EndIf
			ExitLoop
		EndIf
	Next

	; Store coordinate and size fractions
	If $iX Then
		$aGF_SizingIndex[$iIndex][2] = $iX / $aFullSize[0]
	Else
		$aGF_SizingIndex[$iIndex][2] = 0
	EndIf
	If $iY Then
		$aGF_SizingIndex[$iIndex][3] = $iY / $aFullSize[1]
	Else
		$aGF_SizingIndex[$iIndex][3] = 0
	EndIf
	If $iOrg_Width Then
		$aGF_SizingIndex[$iIndex][4] = $iOrg_Width / $aFullSize[0]
	Else
		$aGF_SizingIndex[$iIndex][4] = 1
	EndIf
	If $iOrg_Height Then
		$aGF_SizingIndex[$iIndex][5] = $iOrg_Height / $aFullSize[1]
	Else
		$aGF_SizingIndex[$iIndex][5] = 1
	EndIf

	; Switch back to main GUI
	GUISwitch($hWnd)

	; Return the index for this frame
	Return $iIndex

EndFunc   ;==>_GUIFrame_Create

; #FUNCTION# =========================================================================================================
; Name...........: _GUIFrame_SetMin
; Description ...: Sets minimum sizes for frames
; Syntax.........: _GUIFrame_SetMin($iFrame, $iFirstMin = 0, $iSecondMin = 0, $fAbsolute = False)
; Parameters ....: $iFrame - Index of frame set as returned by _GUIFrame_Create
;                  $iFirstMin - Min size of first (left/top) frame - max half size
;                  $iSecondMin - Min Size of second (right/bottom) frame - max half size
;                  $fAbsolute - True = Minima fixed when GUI resized
;                             - False = Minima adjusted on resize to equivalent percentage of new GUI size (default)
; Requirement(s).: v3.3 +
; Return values .: None
; Author ........: Melba23 based on some original code by Kip
; Modified ......:
; Remarks .......: If the frame is resized, these minima are adjusted accordingly unless $fAbsolute is set
; Example........: Yes
;=====================================================================================================================
Func _GUIFrame_SetMin($iFrame, $iFirstMin = 0, $iSecondMin = 0, $fAbsolute = False)

	; Check for valid frame index
	If $iFrame < 1 Or $iFrame > $aGF_HandleIndex[0][0] Then Return 0
	; Get size of parent
	Local $aSize = WinGetClientSize($aGF_HandleIndex[$iFrame][0])
	; Now check orientation and determine
	Local $iMax, $iFullSize
	If $aGF_SettingsIndex[$iFrame][0] = 0 Then
		$iMax = Floor(($aSize[0] / 2) - $aGF_SettingsIndex[$iFrame][2])
		$iFullSize = $aSize[0]
	Else
		$iMax = Floor(($aSize[1] / 2) - $aGF_SettingsIndex[$iFrame][2])
		$iFullSize = $aSize[1]
	EndIf
	; Set minimums
	If $fAbsolute Then
		$aGF_SizingIndex[$iFrame][0] = Int($iFirstMin)
		$aGF_SizingIndex[$iFrame][1] = Int($iSecondMin)
	Else
		If $iFirstMin > $iMax Then
			$aGF_SizingIndex[$iFrame][0] = $iMax / $iFullSize
		Else
			$aGF_SizingIndex[$iFrame][0] = $iFirstMin / $iFullSize
		EndIf
		If $iSecondMin > $iMax Then
			$aGF_SizingIndex[$iFrame][1] = $iMax / $iFullSize
		Else
			$aGF_SizingIndex[$iFrame][1] = $iSecondMin / $iFullSize
		EndIf
	EndIf

EndFunc   ;==>_GUIFrame_SetMin

; #FUNCTION# =========================================================================================================
; Name...........: _GUIFrame_ResizeSet
; Description ...: Sets resizing flag for frames
; Syntax.........: _GUIFrame_ResizeSet($iFrame = 0[, $iType = 0])
; Parameters ....: $iFrame - Index of frame set as returned by _GUIFrame_Create (Default - 0 = all existing frames)
;                  $iType  - Separator behaviour on GUI resize
;                            0 = Frames retain percentage size (default)
;                            1 = Top/left frame fixed size
;                            2 = Bottom/right frame fixed size
; Requirement(s).: v3.3 +
; Return values .: Success: 2 - All existing frame flags set
;                           1 - Specified flag set
;                  Failure: 0 with @error set to:
;                           1 - Invalid frame specified
;                           2 - Invalid type parameter
; Author ........: Melba23
; Modified ......:
; Remarks .......:
; Example........: Yes
;=====================================================================================================================
Func _GUIFrame_ResizeSet($iFrame = 0, $iType = 0)

	Switch $iType
		Case 0, 1, 2
			; Valid
		Case Else
			Return SetError(2, 0, 0)
	EndSwitch

	Switch $iFrame
		Case 0 ; Set all frames
			For $i = 1 To $aGF_HandleIndex[0][0]
				$aGF_SettingsIndex[$i][1] = 1
				$aGF_SizingIndex[$i][7] = $iType
			Next
			Return 2
		Case 1 To $aGF_HandleIndex[0][0] ; Only valid frames accepted
			$aGF_SettingsIndex[$iFrame][1] = 1
			$aGF_SizingIndex[$iFrame][7] = $iType
			Return 1
		Case Else ; Error
			Return SetError(1, 0, 0)
	EndSwitch

EndFunc   ;==>_GUIFrame_ResizeSet

; #FUNCTION# =========================================================================================================
; Name...........: _GUIFrame_GetHandle
; Description ...: Returns the handle of a frame element (required for further splitting)
; Syntax.........: _GUIFrame_GetHandle($iFrame, $iElement)
; Parameters ....: $iFrame - Index of frame set as returned by _GUIFrame_Create
;                  $iElement - 1 = first (left/top) frame, 2 = second (right/bottom) frame
; Requirement(s).: v3.3 +
; Return values .: Success: Handle of frame
;                  Failure: 0 with @error set as follows
;                           1 - Invalid frame specified
;                           2 - Invalid element specified
; Author ........: Kip
; Modified ......: Melba23
; Remarks .......: _GUIFrame_Create requires a GUI handle as a parameter
; Example........: Yes
;=====================================================================================================================
Func _GUIFrame_GetHandle($iFrame, $iElement)

	; Check valid frame index and element
	Switch $iFrame
		Case 1 To $aGF_HandleIndex[0][0]
			Switch $iElement
				Case 1, 2
					; Return handle
					Return $aGF_HandleIndex[$iFrame][$iElement]
			EndSwitch
			Return SetError(2, 0, 0)
	EndSwitch
	Return SetError(1, 0, 0)

EndFunc   ;==>_GUIFrame_GetHandle

; #FUNCTION# =========================================================================================================
; Name...........: _GUIFrame_Switch
; Description ...: Sets a frame element as current GUI
; Syntax.........: _GUIFrame_Switch($iFrame, $iElement)
; Parameters ....: $iFrame - Index of frame set as returned by _GUIFrame_Create
;                  $iElement - 1 = first (left/top) frame, 2 = second (right/bottom) frame
; Requirement(s).: v3.3 +
; Return values .: None
; Author ........: Kip
; Modified ......: Melba23
; Remarks .......: Subsequent controls are created in the specified frame element
; Example........: Yes
;=====================================================================================================================
Func _GUIFrame_Switch($iFrame, $iElement)

	; Check valid frame index and element
	Switch $iFrame
		Case 1 To $aGF_HandleIndex[0][0]
			Switch $iElement
				Case 1, 2
					; Switch to specified element
					Return GUISwitch($aGF_HandleIndex[$iFrame][$iElement])
			EndSwitch
			Return SetError(2, 0, 0)
	EndSwitch
	Return SetError(1, 0, 0)

EndFunc   ;==>_GUIFrame_Switch

; #FUNCTION# =========================================================================================================
; Name...........: _GUIFrame_GetSepPos()
; Description ...: Returns the current position of the separator
; Syntax.........: _GUIFrame_GetSepPos($iFrame)
; Parameters ....: $iFrame - Index of frame set as returned by _GUIFrame_Create
; Requirement(s).: v3.3 +
; Return values .: Success: Position of separator
;                  Failure: -1 = Invalid frame specified
; Author ........: Melba23
; Remarks .......: This value can be stored and used as the initial separator position parameter in _GUIFrame_Create
;                  to restore exit position on restart
; Example........: Yes
;=====================================================================================================================
Func _GUIFrame_GetSepPos($iFrame)

	Local $iSepPos

	; Check for valid frame index
	If $iFrame < 1 Or $iFrame > $aGF_HandleIndex[0][0] Then Return -1

	; Get position of first frame
	Local $aFrame_Pos = WinGetPos($aGF_HandleIndex[$iFrame][1])
	; Get position of separator
	Local $aSep_Pos = WinGetPos($aGF_HandleIndex[$iFrame][3])
	; Check on separator orientation
	If $aGF_SettingsIndex[$iFrame][0] Then
		$iSepPos = $aSep_Pos[1] - $aFrame_Pos[1]
	Else
		$iSepPos = $aSep_Pos[0] - $aFrame_Pos[0]
	EndIf
	Return $iSepPos

EndFunc   ;==>_GUIFrame_GetSepPos

; #FUNCTION# =========================================================================================================
; Name...........: _GUIFrame_SetSepPos()
; Description ...: Moves the separator bar to adjust frame sizes
; Syntax.........: _GUIFrame_SetSepPos($iFrame, $iSepPos)
; Parameters ....: $iFrame - Index of frame set as returned by _GUIFrame_Create
;                  $iSepos - Position of separator bar within frame
; Requirement(s).: v3.3 +
; Return values .: Success: 1
;                  Failure: 0 with @error set as follows
;                           1 - Invalid frame specified
;                           2 - Invalid separator position (outside frame)
;                           3 - Invalid separator position (below frame minimum size)
; Author ........: Melba23
; Remarks .......: This value can be stored and used as the initial separator position parameter in _GUIFrame_Create
;                  to restore exit position on restart
; Example........: Yes
;=====================================================================================================================
Func _GUIFrame_SetSepPos($iFrame, $iSepPos)

	Local $iFirstMin, $iSecondMin

	; Check for valid frame index
	If $iFrame < 1 Or $iFrame > $aGF_HandleIndex[0][0] Then Return SetError(1, 0, 0)

	; Check separator actually needs to move
	If $iSepPos = _GUIFrame_GetSepPos($iFrame) Then Return 1

	; Get frame GUI size
	Local $aWinPos = WinGetPos($aGF_HandleIndex[$iFrame][0])
	; Depending on separator orientation
	If $aGF_SettingsIndex[$iFrame][0] Then
		; Check sep position is valid
		If $iSepPos < 0 Or $iSepPos > $aWinPos[3] Then Return SetError(2, 0, 0)
		; Determine minima for frames
		$iFirstMin = $aWinPos[3] * $aGF_SizingIndex[$iFrame][0]
		$iSecondMin = ($aWinPos[3] * (1 - $aGF_SizingIndex[$iFrame][1])) - $aGF_SettingsIndex[$iFrame][2]
		; Check required value is valid
		If $iSepPos < $iFirstMin Or $iSepPos > $iSecondMin Then Return SetError(3, 0, 0)
		; Move frames and seperator
		WinMove($aGF_HandleIndex[$iFrame][1], "", 0, 0, $aWinPos[2], $iSepPos)
		WinMove($aGF_HandleIndex[$iFrame][2], "", 0, $iSepPos + $aGF_SettingsIndex[$iFrame][2], $aWinPos[2], $aWinPos[3] - ($iSepPos + $aGF_SettingsIndex[$iFrame][2]))
		WinMove($aGF_HandleIndex[$iFrame][3], "", 0, $iSepPos, $aWinPos[2], $aGF_SettingsIndex[$iFrame][2])
	Else
		If $iSepPos < 0 Or $iSepPos > $aWinPos[2] Then Return SetError(2, 0, 0)
		$iFirstMin = $aWinPos[2] * $aGF_SizingIndex[$iFrame][0]
		$iSecondMin = ($aWinPos[2] * (1 - $aGF_SizingIndex[$iFrame][1])) - $aGF_SettingsIndex[$iFrame][2]
		If $iSepPos < $iFirstMin Or $iSepPos > $iSecondMin Then Return SetError(3, 0, 0)
		WinMove($aGF_HandleIndex[$iFrame][1], "", 0, 0, $iSepPos, $aWinPos[3])
		WinMove($aGF_HandleIndex[$iFrame][2], "", $iSepPos + $aGF_SettingsIndex[$iFrame][2], 0, $aWinPos[2] - ($iSepPos + $aGF_SettingsIndex[$iFrame][2]), $aWinPos[3])
		WinMove($aGF_HandleIndex[$iFrame][3], "", $iSepPos, 0, $aGF_SettingsIndex[$iFrame][2], $aWinPos[3])
	EndIf
	Return 1

EndFunc   ;==>_GUIFrame_SetSepPos

; #FUNCTION# =========================================================================================================
; Name...........: _GUIFrame_ResizeReg
; Description ...: Registers WM_SIZE message for resizing
; Syntax.........: _GUIFrame_ResizeReg()
; Parameters ....: None
; Requirement(s).: v3.3 +
; Return values .: Success: 1 - Message handler registered
;                  Failure: 0 with @error set to 1 - Message handler already registered
; Author ........: Melba23
; Modified ......:
; Remarks .......:
; Example........: Yes
;=====================================================================================================================
Func _GUIFrame_ResizeReg()

	; Register the WM_SIZE message
	If $aGF_HandleIndex[0][1] = 0 Then
		Local $iRet = GUIRegisterMsg(0x05, "_GUIFrame_SIZE_Handler") ; $WM_SIZE
		If $iRet Then
			$aGF_HandleIndex[0][1] = 1
			Return 1
		EndIf
	EndIf
	Return SetError(1, 0, 0)

EndFunc   ;==>_GUIFrame_ResizeReg

; #FUNCTION# =========================================================================================================
; Name...........: _GUIFrame_SIZE_Handler
; Description ...: Used to resize frames when resizing of holding GUI occurs
; Syntax.........: _GUIFrame_SIZE_Handler($hWnd, $iMsg, $wParam, $lParam)
; Parameters ....: None
; Requirement(s).: v3.3 +
; Return values .: None
; Author ........: Melba23
; Modified ......:
; Remarks .......: If the script already has a WM_SIZE handler, then just call this function from within it
;                  and do NOT use the _GUIFrame_ResizeReg function
; Example........: Yes
;=====================================================================================================================
Func _GUIFrame_SIZE_Handler($hWnd, $iMsg, $wParam, $lParam)

	#forceref $iMsg, $wParam, $lParam
	Local $iIndex

	; Get index of base frame GUI
	For $iIndex = 1 To $aGF_HandleIndex[0][0]
		If $aGF_HandleIndex[$iIndex][4] = $hWnd Then ExitLoop
	Next

	; If handle not found
	If $iIndex > $aGF_HandleIndex[0][0] Then Return "GUI_RUNDEFMSG"

	; Check if we should resize this set
	If $aGF_SettingsIndex[$iIndex][1] = 1 Then

		; Get new base GUI size
		Local $aSize = WinGetClientSize($hWnd)
		; Resize frames
		_GUIFrame_Move($iIndex, $aSize[0] * $aGF_SizingIndex[$iIndex][2], $aSize[1] * $aGF_SizingIndex[$iIndex][3], $aSize[0] * $aGF_SizingIndex[$iIndex][4], $aSize[1] * $aGF_SizingIndex[$iIndex][5])

		; Adjust any resizeable internal frames - array elements are adjacent for ease of coding
		For $i = 0 To 1
			; Adjust internal frames of first/second frame if any exist
			If $aGF_HandleIndex[$iIndex][5 + $i] <> 0 Then
				; StringSplit the element content on "|"
				Local $aInternal = StringSplit($aGF_HandleIndex[$iIndex][5 + $i], "|")
				; Then loop though the Number(values) found
				For $j = 1 To $aInternal[0]
					Local $iIntIndex = Number($aInternal[$j])
					; Check if internal frame is resizable
					If $aGF_SettingsIndex[$iIntIndex][1] = 1 Then
						; And change if so
						_GUIFrame_SIZE_Handler($aGF_HandleIndex[$iIntIndex][4], $iMsg, $wParam, $lParam)
					EndIf
				Next
			EndIf
		Next

	EndIf

	Return "GUI_RUNDEFMSG"

EndFunc   ;==>_GUIFrame_SIZE_Handler

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _GUIFrame_SepSubClass
; Description ...: Sets new WndProc for frame separator bar
; Author ........: Kip
; Modified.......: Melba23, using SetWindowLongPtr x64 compatible code drawn from Yashied's WinAPIEx library
; Remarks .......: This function is used internally by _GUIFrame_Create
; ===============================================================================================================================
Func _GUIFrame_SepSubClass($hWnd)

	Local $aRet

	; Check separator has not already been used
	For $i = 1 To $aGF_SepProcIndex[0][0]
		If $aGF_SepProcIndex[$i][0] = $hWnd Then Return 0
	Next

	; Store current WinProc handle in new array line
	Local $iIndex = $aGF_SepProcIndex[0][0] + 1
	ReDim $aGF_SepProcIndex[$iIndex + 1][2]
	$aGF_SepProcIndex[0][0] = $iIndex
	$aGF_SepProcIndex[$iIndex][0] = $hWnd
	; Subclass separator bar
	If @AutoItX64 Then
		$aRet = DllCall('user32.dll', 'long_ptr', 'SetWindowLongPtrW', 'hwnd', $hWnd, 'int', -4, 'long_ptr', $aGF_SepProcIndex[0][1]) ; $GWL_WNDPROC
	Else
		$aRet = DllCall('user32.dll', 'long', 'SetWindowLongW', 'hwnd', $hWnd, 'int', -4, 'long', $aGF_SepProcIndex[0][1]) ; $GWL_WNDPROC
	EndIf
	; Check for subclassing error
	If @error Or $aRet[0] = 0 Then Return 0
	; Return success
	$aGF_SepProcIndex[$iIndex][1] = $aRet[0]
	Return 1

EndFunc   ;==>_GUIFrame_SepSubClass

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _GUIFrame_SepWndProc
; Description ...: New WndProc for frame separator bar
; Author ........: Kip
; Modified.......: Melba23
; Remarks .......: This function is used internally by _GUIFrame_SepSubClass
; ===============================================================================================================================
Func _GUIFrame_SepWndProc($hWnd, $iMsg, $wParam, $lParam)

	Local $iSubtract, $fAbsolute = False

	If $iMsg = 0x0111 Then ; WM_COMMAND

		; Check if hWnd is a Separator bar
		For $iIndex = 1 To $aGF_HandleIndex[0][0]
			If $aGF_HandleIndex[$iIndex][3] = $hWnd Then ExitLoop
		Next
		; If not then pass message on to org WndProc
		If $iIndex > $aGF_HandleIndex[0][0] Then Return _GUIFrame_SepPassMsg($hWnd, $iMsg, $wParam, $lParam)

		; Extract values from array
		Local $hParent = $aGF_HandleIndex[$iIndex][0]
		Local $hFirstFrame = $aGF_HandleIndex[$iIndex][1]
		Local $hSecondFrame = $aGF_HandleIndex[$iIndex][2]
		Local $hSeparator = $aGF_HandleIndex[$iIndex][3]
		Local $iFirstMin = $aGF_SizingIndex[$iIndex][0]
		Local $iSecondMin = $aGF_SizingIndex[$iIndex][1]
		If $iFirstMin > 1 Or $iSecondMin > 1 Then
			$fAbsolute = True
		EndIf
		Local $iSeparatorSize = $aGF_SettingsIndex[$iIndex][2]

		; Get client size of the parent
		Local $aClientSize = WinGetClientSize($hParent)
		Local $iWidth = $aClientSize[0]
		Local $iHeight = $aClientSize[1]

		; Get cursor info for the Separator
		Local $aCInfo = GUIGetCursorInfo($hSeparator)

		; Depending on separator orientation
		If $aGF_SettingsIndex[$iIndex][0] = 0 Then

			; Get Separator X-coord
			$iSubtract = $aCInfo[0]

			Do
				; Get parent X-coord
				$aCInfo = GUIGetCursorInfo($hParent)
				Local $iCursorX = $aCInfo[0]

				; Determine width of first frame
				Local $iFirstWidth = $iCursorX - $iSubtract
				; And ensure it is at least minimum
				If $fAbsolute Then
					If $iFirstWidth < $iFirstMin Then $iFirstWidth = $iFirstMin
					If $iWidth - $iFirstWidth - $iSeparatorSize < $iSecondMin Then $iFirstWidth = $iWidth - $iSeparatorSize - $iSecondMin
				Else
					If $iFirstWidth < $iWidth * $iFirstMin Then $iFirstWidth = $iWidth * $iFirstMin
					If $iWidth - ($iFirstWidth + $iSeparatorSize) < $iWidth * $iSecondMin Then $iFirstWidth = $iWidth - ($iWidth * $iSecondMin) - $iSeparatorSize
				EndIf

				; Move the GUIs to the correct places
				WinMove($hFirstFrame, "", 0, 0, $iFirstWidth, $iHeight)
				WinMove($hSecondFrame, "", $iFirstWidth + $iSeparatorSize, 0, $iWidth - ($iFirstWidth + $iSeparatorSize), $iHeight)
				WinMove($hSeparator, "", $iFirstWidth, 0, $iSeparatorSize, $iHeight)

				; Do until the mouse button is released
			Until Not _WinAPI_GetAsyncKeyState(0x01)

			; Store current separator percentage position
			$aGF_SizingIndex[$iIndex][6] = $iFirstWidth / $iWidth

		ElseIf $aGF_SettingsIndex[$iIndex][0] = 1 Then

			$iSubtract = $aCInfo[1]
			Do
				$aCInfo = GUIGetCursorInfo($hParent)
				Local $iCursorY = $aCInfo[1]
				Local $iFirstHeight = $iCursorY - $iSubtract
				If $fAbsolute Then
					If $iFirstHeight < $iFirstMin Then $iFirstHeight = $iFirstMin
					If $iHeight - $iFirstHeight - $iSeparatorSize < $iSecondMin Then $iFirstHeight = $iHeight - $iSeparatorSize - $iSecondMin
				Else
					If $iFirstHeight < $iHeight * $iFirstMin Then $iFirstHeight = $iHeight * $iFirstMin
					If $iHeight - ($iFirstHeight + $iSeparatorSize) < $iHeight * $iSecondMin Then $iFirstHeight = $iHeight - ($iHeight * $iSecondMin) - $iSeparatorSize
				EndIf
				WinMove($hFirstFrame, "", 0, 0, $iWidth, $iFirstHeight)
				WinMove($hSecondFrame, "", 0, $iFirstHeight + $iSeparatorSize, $iWidth, $iHeight - ($iFirstHeight + $iSeparatorSize))
				WinMove($hSeparator, "", 0, $iFirstHeight, $iWidth, $iSeparatorSize)
			Until Not _WinAPI_GetAsyncKeyState(0x01)
			$aGF_SizingIndex[$iIndex][6] = $iFirstHeight / $iHeight

		EndIf

	EndIf

	; Pass the message on to org WndProc
	Return _GUIFrame_SepPassMsg($hWnd, $iMsg, $wParam, $lParam)

EndFunc   ;==>_GUIFrame_SepWndProc

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _GUIFrame_SepPassMsg
; Description ...: Passes Msg to frame parent WndProc for action
; Author ........: Kip
; Modified.......: Melba23
; Remarks .......: This function is used internally by _GUIFrame_SepWndProc
; ===============================================================================================================================
Func _GUIFrame_SepPassMsg($hWnd, $iMsg, $wParam, $lParam)

	For $i = 1 To $aGF_SepProcIndex[0][0]
		If $aGF_SepProcIndex[$i][0] = $hWnd Then Return _WinAPI_CallWindowProc($aGF_SepProcIndex[$i][1], $hWnd, $iMsg, $wParam, $lParam)
	Next

EndFunc   ;==>_GUIFrame_SepPassMsg

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _GUIFrame_Move
; Description ...: Moves and resizes frame elements and separator bars
; Author ........: Kip
; Modified.......: Melba23
; Remarks .......: This function is used internally by _GUIFrame_SIZE_Handler
; ===============================================================================================================================
Func _GUIFrame_Move($iFrame, $iX, $iY, $iWidth = 0, $iHeight = 0)

	If $iFrame < 1 Or $iFrame > $aGF_HandleIndex[0][0] Then Return 0

	Local $fAbsolute = False, $iDimension, $iActual_Size_1, $iActual_Size_2, $iSize
	Local $iOrientation = $aGF_SettingsIndex[$iFrame][0]
	Local $iSeparatorSize = $aGF_SettingsIndex[$iFrame][2]

	; Set size if not specified
	If Not $iWidth Then $iWidth = _WinAPI_GetWindowWidth($aGF_HandleIndex[$iFrame][0])
	If Not $iHeight Then $iHeight = _WinAPI_GetWindowHeight($aGF_HandleIndex[$iFrame][0])

	; Move parent
	WinMove($aGF_HandleIndex[$iFrame][0], "", $iX, $iY, $iWidth, $iHeight)

	; Depending on separator orientation get required width/height values
	If $iOrientation = 1 Then
		$iDimension = $iHeight
		$iActual_Size_1 = _WinAPI_GetWindowHeight($aGF_HandleIndex[$iFrame][1])
		$iActual_Size_2 = _WinAPI_GetWindowHeight($aGF_HandleIndex[$iFrame][2])
	Else
		$iDimension = $iWidth
		$iActual_Size_1 = _WinAPI_GetWindowWidth($aGF_HandleIndex[$iFrame][1])
		$iActual_Size_2 = _WinAPI_GetWindowWidth($aGF_HandleIndex[$iFrame][2])
	EndIf

	; Check resize type required
	Switch $aGF_SizingIndex[$iFrame][7]
		Case 0
			; Determine new size for first frame using separator position percentage
			$iSize = Int($iDimension * $aGF_SizingIndex[$iFrame][6])
		Case 1
			; Get current fixed first frame size
			$iSize = $iActual_Size_1
		Case 2
			; Determine new first frame size with fixed second frame size
			$iSize = $iDimension - $iSeparatorSize - $iActual_Size_2
	EndSwitch

	; Set frame min percentages
	Local $iFirstMin = $aGF_SizingIndex[$iFrame][0]
	Local $iSecondMin = $aGF_SizingIndex[$iFrame][1]
	If $iFirstMin > 1 Or $iSecondMin > 1 Then
		$fAbsolute = True
	EndIf

	; Check for minimum size of first frame
	Local $iAdjust_Other = True
	Local $fSep_Adjusted = False

	; Adjust first frame size
	If $fAbsolute Then
		If $iSize < $iFirstMin Then
			$iSize = $iFirstMin
			$iAdjust_Other = False
			$fSep_Adjusted = True
		EndIf
	Else
		If $iSize < $iDimension * $iFirstMin Then
			$iSize = $iDimension * $iFirstMin
			$iAdjust_Other = False
			$fSep_Adjusted = True
		EndIf
	EndIf

	; Now adjust second frame if first not adjusted
	If $iAdjust_Other Then

		; Find max available size for this frame
		Local $iSecondMax = $iDimension - $iFirstMin - $iSeparatorSize
		If $iSecondMax < $iSecondMin Then
			$iSecondMin = $iSecondMax
		EndIf

		; Adjust second frame size
		If $fAbsolute Then
			If $iActual_Size_2 < $iSecondMin Then
				$iSize = $iDimension - $iSecondMin - $iSeparatorSize
				$fSep_Adjusted = True
			EndIf
		Else
			If $iActual_Size_2 < $iDimension * $iSecondMin Then
				$iSize = $iDimension - ($iDimension * $iSecondMin) - $iSeparatorSize
				$fSep_Adjusted = True
			EndIf
		EndIf
	EndIf

	; If the separator has been moved programatically then reset percentage size of first frame
	If $fSep_Adjusted Then
		$aGF_SizingIndex[$iFrame][6] = $iSize / $iDimension
	EndIf

	; Move and resize GUIs according to orientation
	If $iOrientation = 1 Then
		WinMove($aGF_HandleIndex[$iFrame][1], "", 0, 0, $iWidth, $iSize)
		WinMove($aGF_HandleIndex[$iFrame][2], "", 0, $iSize + $iSeparatorSize, $iWidth, $iHeight - $iSize - $iSeparatorSize)
		WinMove($aGF_HandleIndex[$iFrame][3], "", 0, $iSize, $iWidth, $iSeparatorSize)
	Else
		WinMove($aGF_HandleIndex[$iFrame][1], "", 0, 0, $iSize, $iHeight)
		WinMove($aGF_HandleIndex[$iFrame][2], "", $iSize + $iSeparatorSize, 0, $iWidth - $iSize - $iSeparatorSize, $iHeight)
		WinMove($aGF_HandleIndex[$iFrame][3], "", $iSize, 0, $iSeparatorSize, $iHeight)
	EndIf

EndFunc   ;==>_GUIFrame_Move

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _GUIFrame_Exit()
; Description ...: Deletes all subclassed separator bars to free UDF WndProc and frees registered callback handle
; Author ........: Melba23
; Remarks .......: Called by OnAutoItExitRegister to delete all subclassed separator bars and to free the UDF created WndProc.
; Example........: Yes
;================================================================================================================================
Func _GUIFrame_Exit()

	; Delete all subclassed separator bars
	For $i = $aGF_HandleIndex[0][0] To 1 Step -1
		GUIDelete($aGF_HandleIndex[$i][3])
	Next
	; Free registered Callback handle
	DllCallbackFree($hGF_RegCallBack)

EndFunc   ;==>_GUIFrame_Exit