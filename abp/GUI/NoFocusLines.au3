#include-once

; #INDEX# ============================================================================================================
; Title .........: NoFocusLines
; AutoIt Version : 3.3.4.0 +
; Language ......: English
; Description ...: Prevents dotted focus lines on GUI controls of button and slider classes
; Remarks .......: Once the _Set function has been used to prevent focus lines, the specified controls should be reset
;                  with the _Clear function before deletion.  Note all such controls can be reset in
;                  one call to the _Clear function without having to specify each individual control.
;                  The _Global_Set function prevents focus lines on ANY subsequently created button or slider class
;                  control.  However, CAUTION is advised when using the _Global_Set function as even though the use of
;                  the _Global_Exit function on exit deletes all such controls and frees the memory used by the UDF,
;                  full clean up relies on internal AutoIt procedures.
; Note ..........: Button class controls include buttons, radios and checkboxes
; Author(s) .....: Melba23, based on code from Siao, aec, martin, Yashied and rover
; ====================================================================================================================

; #INCLUDES# =========================================================================================================
#include <WinAPI.au3>

OnAutoItExitRegister("_NoFocusLines_AutoExit")

; #GLOBAL VARIABLES# =================================================================================================
Global $hNoFocusLines_Proc = 0, $pOrg_SliderProc = 0, $pOrg_ButtonProc = 0, $aHandle_Proc[1][2] = [[0, ""]]

; #CURRENT# ==========================================================================================================
; _NoFocusLines_Set:         Prevents dotted focus lines on specified button and slider class controls
; _NoFocusLines_Clear:       Resets normal focus lines on specified controls.
; _NoFocusLines_Exit:        Used on script exit to reset all subclassed controls and free UDF WndProc memory
; _NoFocusLines_Global_Set:  Prevents dotted focus lines on all subsequently created button and slider class controls
; _NoFocusLines_Global_Exit: Used on script exit to delete all subclassed controls and free UDF WndProc memory
; ====================================================================================================================

; #INTERNAL_USE_ONLY#=================================================================================================
; _NoFocusLines_SubClass:    Sets WndProc for specified control
; _NoFocusLines_Proc:        New WndProc to prevent focus lines on specified button and slider class controls
; _NoFocusLines_Global_Proc: New WndProc to prevent focus lines on all subsequently created button and slider controls
; _NoFocusLines_AutoExit:    Automatically deletes all controls and frees the memory used on exit
; ====================================================================================================================

; #FUNCTION# =========================================================================================================
; Name...........: _NoFocusLines_Set
; Description ...: Prevents the dotted focus lines on specified button and slider class controls
; Syntax.........: _NoFocusLines_Set($vCID)
; Parameters ....: $vCID - ControlIDs of controls - multiple ControlIDs must be passed as a 0-based array
; Requirement(s).: v3.3 +
; Return values .: Success:  Returns number of controls currently subclassed
;                  Failure:  Sets @error as follows:
;                  1 = Global function already run
;                  2 = Invalid controlID
; Author ........: Melba23, based on code from Siao, aec, martin and Yashied
; Remarks .......: Any controls on which focus lines have been prevented by using the _SET function should be reset via
;                  the _CLEAR function if deleted prior to exit
; Example........: Yes
;=====================================================================================================================
Func _NoFocusLines_Set($vCID)

    Local $aCID[1]

    ; Check if Global function already used
    If $aHandle_Proc[0][1] = "Global" Then Return SetError(1, 0, 0)

    ; Check parameters are button or slider class controls
    If Not IsArray($vCID) Then
        Switch _WinAPI_GetClassName(GUICtrlGetHandle($vCID))
            Case "Button", "msctls_trackbar32"
                $aCID[0] = $vCID
            Case Else
                Return SetError(2, 0, 0)
        EndSwitch
    Else
        For $i = 0 To UBound($vCID) - 1
            Switch _WinAPI_GetClassName(GUICtrlGetHandle($vCID[$i]))
                Case "Button", "msctls_trackbar32"
                    ; ContinueLoop
                Case Else
                    Return SetError(2, 0, 0)
            EndSwitch
        Next
        $aCID = $vCID
    EndIf

    ; Check if _NoFocusLines_Proc has been registered
    If $hNoFocusLines_Proc = 0 Then
        ; Register callback function and obtain handle to _NoFocusLines_Proc
        $hNoFocusLines_Proc = DllCallbackRegister("_NoFocusLines_Proc", "int", "hwnd;uint;wparam;lparam")
    EndIf

    ; Get pointer to _NoFocusLines_Proc
    Local $pNoFocusLines_Proc = DllCallbackGetPtr($hNoFocusLines_Proc)

    ; Work through CIDs
    For $i = 0 To UBound($aCID) - 1

        ; Get handle for control
        Local $hHandle = GUICtrlGetHandle($aCID[$i])
        ; Check if control is already subclassed
        For $j = 1 To $aHandle_Proc[0][0]
            ; Skip if so
            If $hHandle = $aHandle_Proc[$j][0] Then
                ContinueLoop 2
            EndIf
        Next

        ; Increase control count
        $aHandle_Proc[0][0] += 1
        ; Double array size if too small (fewer ReDim needed)
        If UBound($aHandle_Proc) <= $aHandle_Proc[0][0] Then ReDim $aHandle_Proc[UBound($aHandle_Proc) * 2][2]

        ; Store control handle
        $aHandle_Proc[$aHandle_Proc[0][0]][0] = $hHandle
        ; Subclass control and store pointer to original WindowProc
        $aHandle_Proc[$aHandle_Proc[0][0]][1] = _NoFocusLines_SubClass($hHandle, $pNoFocusLines_Proc)

        ; If error in subclassing then remove this control from the array
        If $aHandle_Proc[$aHandle_Proc[0][0]][1] = 0 Then $aHandle_Proc[0][0] -= 1

    Next

    ; Remove any empty elements after a ReDim
    ReDim $aHandle_Proc[$aHandle_Proc[0][0] + 1][2]

    ; Check if subclassing was successful
    If $aHandle_Proc[0][0] > 0 Then
        $aHandle_Proc[0][1] = "Local"
    Else
        ; Free WndProc memory
        DllCallbackFree($hNoFocusLines_Proc)
        $hNoFocusLines_Proc = 0
    EndIf

    Return $aHandle_Proc[0][0]

EndFunc   ;==>_NoFocusLines_Set

; #FUNCTION# =========================================================================================================
; Name...........: _NoFocusLines_Clear
; Description ...: Repermits the dotted focus lines on controls if previously prevented by _NoFocusLines_Set
; Syntax.........: _NoFocusLines_Clear($vCID)
; Parameters ....: $vCID - ControlIDs of control(s) - multiple ControlIDs must be passed as a 0-based array
;                  If no parameter passed, all previously set controls are reset
; Requirement(s).: v3.3 +
; Return values .: Success:  Returns number of controls currently subclassed
;                  Failure:  Sets @error as follows:
;                  1 = Global function already run
;                  2 = Invalid controlID
; Author ........: Melba23, based on code from Siao, aec, martin and Yashied
; Remarks .......: If controls which have had focus lines removed by the _SET function are deleted before the script
;                  exits, it is advisable to use this function on them BEFORE deletion.
; Example........: Yes
;=====================================================================================================================
Func _NoFocusLines_Clear($vCID = "")

    Local $aCID[1]

    ; Check if Global function already used
    If $aHandle_Proc[0][1] = "Global" Then Return SetError(1, 0, 0)

    If $vCID = "" Then

        ; Reset all controls to original WndProc
        For $i = 1 To $aHandle_Proc[0][0]
            _NoFocusLines_SubClass($aHandle_Proc[$i][0], $aHandle_Proc[$i][1])
        Next

        ; Reset array
        Dim $aHandle_Proc[1][2] = [[0, "Local"]]

    Else

        ; Check parameters are valid
        If Not IsArray($vCID) Then
            If Not IsHWnd(GUICtrlGetHandle($vCID)) Then Return SetError(2, 0, 0)
            $aCID[0] = $vCID
        Else
            For $i = 0 To UBound($vCID) - 1
                If Not IsHWnd(GUICtrlGetHandle($vCID[$i])) Then Return SetError(2, 0, 0)
            Next
            $aCID = $vCID
        EndIf

        ; For each specified control
        For $j = 0 To UBound($aCID) - 1
            ; Run through array to see if control has been subclassed
            For $i = 1 To $aHandle_Proc[0][0]
                ; Control found
                If $aHandle_Proc[$i][0] = GUICtrlGetHandle($aCID[$j]) Then
                    ; Unsubclass the control
                    _NoFocusLines_SubClass($aHandle_Proc[$i][0], $aHandle_Proc[$i][1])
                    ; Remove control handle and orginal WindowProc from array
                    $aHandle_Proc[$i][0] = 0
                    $aHandle_Proc[$i][1] = 0
                EndIf
            Next
        Next

        ; Remove zeroed elements of array
        For $i = $aHandle_Proc[0][0] To 1 Step -1
            If $aHandle_Proc[$i][0] = 0 Then
                ; Reduce control count
                $aHandle_Proc[0][0] -= 1
                ; Move up all following elements
                For $j = $i To $aHandle_Proc[0][0]
                    $aHandle_Proc[$j][0] = $aHandle_Proc[$j + 1][0]
                    $aHandle_Proc[$j][1] = $aHandle_Proc[$j + 1][1]
                Next
            EndIf
        Next
        ReDim $aHandle_Proc[$aHandle_Proc[0][0] + 1][2]

    EndIf

    Return $aHandle_Proc[0][0]

EndFunc   ;==>_NoFocusLines_Clear

; #FUNCTION# ====================================================================================================================
; Name...........: _NoFocusLines_Exit
; Description ...: Resets any remaining subclassed controls and frees the memory used by the UDF created WndProc
; Syntax.........: _NoFocusLines_Exit()
; Requirement(s).: v3.3 +
; Return values .: None
; Author ........: Melba23
; Remarks .......: This function should be called on exit to avoid reliance on internal AutoIt procedures for memory clean up
; Example........: Yes
;================================================================================================================================
Func _NoFocusLines_Exit()

    ; Check if _Set function used
    If $aHandle_Proc[0][1] <> "Local" Then Return SetError(1, 0, 0)

    ; First unsubclass any remaining subclassed controls
    _NoFocusLines_Clear()

    ; Now free UDF created WndProc
    DllCallbackFree($hNoFocusLines_Proc)

    Return 1

EndFunc   ;==>_NoFocusLines_Exit

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _NoFocusLines_Proc
; Description ...: Replacement WindowProc to prevent focus lines appearing on button and slider class controls
; Author ........: Melba23, based on code from Siao, aec, martin and Yashied
; Modified.......:
; Remarks .......: This function is used internally by _NoFocus_Set
; ===============================================================================================================================
Func _NoFocusLines_Proc($hWnd, $iMsg, $wParam, $lParam)

    ; Ignore SETFOCUS message from all subclassed controls
    If $iMsg = 0x0007 Then Return 0 ; $WM_SETFOCUS
    ; Locate control handle in array
    For $i = 1 To $aHandle_Proc[0][0]
        ; And pass other messages to original WindowProc
        If $hWnd = $aHandle_Proc[$i][0] Then Return _WinAPI_CallWindowProc($aHandle_Proc[$i][1], $hWnd, $iMsg, $wParam, $lParam)
    Next

EndFunc   ;==>_NoFocusLines_Proc

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _NoFocusLines_SubClass
; Description ...: Sets new WindowProc for controls
; Syntax ........: _NoFocusLines_SubClass($hWnd, $pNew_WindowProc)
; Parameters ....: $hWnd - Handle of control to subclass
;                  $pNew_WindowProc - Pointer to new WindowProc
; Author ........: Melba23, based on code from Siao, aec and martin
; Modified.......:
; Remarks .......: This function is used internally by _NoFocusLines_Set and _NoFocusLines_Clear
; ===============================================================================================================================
Func _NoFocusLines_SubClass($hWnd, $pNew_WindowProc)

    Local $iRes = _WinAPI_SetWindowLong($hWnd, -4, $pNew_WindowProc)
    If @error Then Return SetError(1, 0, 0)
    If $iRes = 0 Then Return SetError(1, 0, 0)
    Return $iRes

EndFunc   ;==>_NoFocusLines_SubClass

; #FUNCTION# ====================================================================================================================
; Name...........: _NoFocusLines_Global_Set
; Description ...: Prevents the dotted focus lines on ALL subsequently created button and slider class controls
; Syntax.........: _NoFocusLines_Global_Set()
; Requirement(s).: v3.3 +
; Return values .: Success:  1
;                  Failure:  0 and sets @error as follows:
;                  1 = Specific function already run
; Author ........: rover
; Remarks .......: The _Global Exit function should be called on script exit
; Note ..........; CAUTION is advised when using the _Global_Set function as even though the use of the _Global_Exit function on
;                  exit deletes all such controls and frees the memory used by the UDF, full clean up relies on internal AutoIt
;                  procedures.
; Example........: Yes
;================================================================================================================================
Func _NoFocusLines_Global_Set()

    ; Run once check
    If $aHandle_Proc[0][1] <> "" Then Return SetError(1, 0, 0)

    ; Create callback
    $hNoFocusLines_Proc = DllCallbackRegister("_NoFocusLines_Global_Proc", "int", "hwnd;uint;wparam;lparam")
    Local $pCallbackPtr = DllCallbackGetPtr($hNoFocusLines_Proc)

    ; Create temp gui with button and slider
    Local $hGUITemp = GUICreate("", 1, 1, -10, -10)
    Local $hButtonTemp = GUICtrlGetHandle(GUICtrlCreateButton("", -10, -10, 1, 1))
    Local $hSliderTemp = GUICtrlGetHandle(GUICtrlCreateSlider(-10, -10, 1, 1))

    ; Globally subclass Button class (includes buttons, radios and checkboxes)
    $pOrg_ButtonProc = DllCall("User32.dll", "dword", "SetClassLongW", "hwnd", $hButtonTemp, "int", -24, "ptr", $pCallbackPtr)
    $pOrg_ButtonProc = $pOrg_ButtonProc[0]

    ; Globally subclass Slider(Trackbar) class
    $pOrg_SliderProc = DllCall("User32.dll", "dword", "SetClassLongW", "hwnd", $hSliderTemp, "int", -24, "ptr", $pCallbackPtr)
    $pOrg_SliderProc = $pOrg_SliderProc[0]

    GUIDelete($hGUITemp)

    $aHandle_Proc[0][1] = "Global"

    Return SetError(0, 0, 1)

EndFunc   ;==>_NoFocusLines_Global_Set

; #FUNCTION# ====================================================================================================================
; Name...........: _NoFocusLines_Global_Exit
; Description ...: Deletes all controls and frees the memory used by the UDF created WndProc
; Syntax.........: _NoFocusLines_Global_Exit()
; Requirement(s).: v3.3 +
; Return values .: None
; Author ........: Melba23
; Remarks .......: This function should be called on script exit if the _Global_Set function has been used
; Note ..........; CAUTION is advised as even though the use of the _Global_Exit function on exit deletes all controls and frees
;                  the memory used by the UDF, full clean up relies on internal AutoIt procedures.
; Example........: Yes
;================================================================================================================================
Func _NoFocusLines_Global_Exit()

    ; Check if _Set function used
    If $aHandle_Proc[0][1] <> "Global" Then Return SetError(1, 0, 0)

    ; First delete all controls - any subclassed controls are now deleted
    For $i = 3 To 65532
        GUICtrlDelete($i)
    Next

    ; Now free UDF created WndProc
    DllCallbackFree($hNoFocusLines_Proc)

    Return 1

EndFunc   ;==>_NoFocusLines_Global_Exit

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _NoFocusLines_AutoExit
; Description ...: Automatically deletes all controls and frees the memory used by the UDF created WndProc on exit
; Author ........: M23
; Modified.......:
; Remarks .......: This function is used internally by NoFocusLines
; ===============================================================================================================================
Func _NoFocusLines_AutoExit()

    Switch $aHandle_Proc[0][1]
        Case "Global"
            _NoFocusLines_Global_Exit()
        Case "Local"
            _NoFocusLines_Exit()
    EndSwitch

EndFunc

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _NoFocusLines_Global_Proc
; Description ...: Replacement WindowProc to prevent focus lines appearing on button and slider class controls
; Author ........: rover
; Modified.......:
; Remarks .......: This function is used internally by _NoFocusLines_Global_Set
; ===============================================================================================================================
Func _NoFocusLines_Global_Proc($hWnd, $iMsg, $wParam, $lParam)

    If $iMsg = 0x0007 Then Return 0 ; $WM_SETFOCUS
    Switch _WinAPI_GetClassName($hWnd)
        Case "Button"
            ; pass the unhandled messages to default ButtonProc
            Return _WinAPI_CallWindowProc($pOrg_ButtonProc, $hWnd, $iMsg, $wParam, $lParam)
        Case "msctls_trackbar32"
            ; pass the unhandled messages to default SliderProc
            Return _WinAPI_CallWindowProc($pOrg_SliderProc, $hWnd, $iMsg, $wParam, $lParam)
        Case Else
            Return 0
    EndSwitch

EndFunc   ;==>_NoFocusLines_Global_Proc