;Phoenix XL - Example1 _PredictText
#include-once
#include 'PredictText.au3'

;Description
;The Following Example Explains :
;How to Use the PredicText UDF with an array of Lists.
;How to Use the PredictText UDF with two or more Edit Controls

;Our Graphic User Interface
$hGUI = GUICreate('Predict Text - Phoenix XL',500,400)

;First Edit - Case Sensitive
GUICtrlCreateGroup("First Edit  -  Case Sensitive", 5, 10, 490,170)
GUICtrlCreateLabel("Type 'Hello' or 'AutoIT Rocks' or 'Phoenix XL' to Find Out What Happens",10,30,480,30)
Global $Edit1 = GUICtrlCreateEdit('', 10, 50, 480, 120)
GUICtrlCreateGroup("", -99,-99, 480,30)

;Second Edit - Case InSensitive
GUICtrlCreateGroup("Second Edit  -  Case InSensitive", 5, 200, 490,180)
GUICtrlCreateLabel("Type 'Nice Meeting You' or 'Scripting' or 'Hobby' to Find Out What Happens",10,220,480,30)
Global $Edit2 = GUICtrlCreateEdit('', 10,240, 480, 120)
GUICtrlCreateGroup("", -99,-99, 480,30)

; Required when more than two Edit control
GUIRegisterMsg(0x0111,'WM_COMMAND')
GUISetState()

;GUI Message Loop
Local $iGUIGetMsg
While 1
    $iGUIGetMsg = GUIGetMsg()
    Switch $iGUIGetMsg
		Case -3
            ExitLoop
    EndSwitch
WEnd

Func WM_COMMAND($hWnd,$iMsg,$wParam,$lParam)
	;BitShift($wParam, 16) is the Notification code.
	;$lParam is the Handle of the Control.
	;When Focus is set to an Edit Control Change the Prediction of the Edit Controls.
	If BitShift($wParam, 16)<>$EN_SETFOCUS Then Return 'GUI_RUNDEFMSG'

	;The Words which have to be Predicted for First Edit Box.
	Local $_Words1[3]=['Hello','AutoIT Rocks','Phoenix XL']
	;The Words which have to be Predicted for Second Edit Box.
	Local $_Words2[3]=['Nice Meeting You','Scripting','Hobby']
	Switch $lParam
		Case GUICtrlGetHandle($Edit1)
			;Case-Sensitive
			_RegisterPrediction($lParam,$_Words1,1)
		Case GUICtrlGetHandle($Edit2)
			_RegisterPrediction($lParam,$_Words2)
	EndSwitch
	Return 'GUI_RUNDEFMSG'
EndFunc