;Phoenix XL - Example3 _PredictText
#include-once
#include 'PredictText.au3'
#include <EditConstants.au3>

;Description
;Enter doesnt works with Input Controls
;This Example helps in understanding how to make
;it work with Input controls using Accelerators.
;Also Shows that input or edit with password char
;unregisters the Prediction.

;Our Graphic User Interface
Local $hGUI = GUICreate('Predict Text - Phoenix XL',500,140)

;The Variable having the Minimum Length of Words to be Added
Local $_Min = 5
;The Maximum Number of NewWords, For Debuggin Purposes only
Local $_MaxArraySize = 10

;Input - Case InSensitive & Add New Words
GUICtrlCreateLabel("Username  -  Case Insensitive",10,10,480,15)
Local $Input1 = GUICtrlCreateInput('', 10,30, 480, 30)
GUICtrlCreateLabel("Password   -  No Registration Since Password Char is set.",10,70,480,15)
Local $Input2 = GUICtrlCreateInput('******', 10,90, 480, 30, 0x0020)
Local $nEnter = GUICtrlCreateDummy()	;For Capturing Enter
GUIRegisterMsg(0x0111,'WM_COMMAND')				; Required when more than two Input control

; Set an accelerator key - ENTER will fire $nEnter
Local $aAccelKeys[1][2] = [["{ENTER}", $nEnter]]
GUISetAccelerators($aAccelKeys)

Global $_Words1[3]=['John','Harry','Peter'] ;The Words which have to be Predicted for First Input Box
Global $_Words2[1]=['Password'] ;The Words which have to be Predicted for Second Input Box
;Make The Registration with AddNewWords set to 1
_RegisterListingNewWords(Default,$_Min)				; The Minimum Length of the New Word Should be equal to $_Min

GUISetState()

;GUI Message Loop
Local $iGUIGetMsg
While 1
    $iGUIGetMsg = GUIGetMsg()
    Switch $iGUIGetMsg
		Case -3	;GUI_EVENT_CLOSE
			_UnregisterPrediction()
            ExitLoop
		Case $nEnter
            ; Get control with focus
            $hFocus = _WinAPI_GetFocus()
            Switch $hFocus
				Case GUICtrlGetHandle($Input1),GUICtrlGetHandle($Input2)
					; If input Then Deselect The Selection
					_GUICtrlEdit_SetSel($hFocus,-1,-1)
				Case Else
					; If not we need to disable the Accel key
					GUISetAccelerators(0)
					; Send a CR to the control
					ControlSend($hGUI, "", $hFocus, @CR)
					; And then reenable the Accel key
					GUISetAccelerators($aAccelKeys)
            EndSwitch
    EndSwitch
WEnd

Func WM_COMMAND($hWnd,$iMsg,$wParam,$lParam)
	;BitShift($wParam, 16) is the Notification code
	;$lParam is the Handle of the Control
	;When Focus is set to an Input Control Change the Prediction of the Input Controls
	If BitShift($wParam, 16)<>$EN_SETFOCUS Then Return 'GUI_RUNDEFMSG'
	Switch $lParam
		Case GUICtrlGetHandle($Input1)
			_RegisterPrediction($lParam,$_Words1)
		Case GUICtrlGetHandle($Input2)
			_RegisterPrediction($lParam,$_Words2)	;Registration will automatically get canceled Since Password is Set.
	EndSwitch
	Return 'GUI_RUNDEFMSG'
EndFunc