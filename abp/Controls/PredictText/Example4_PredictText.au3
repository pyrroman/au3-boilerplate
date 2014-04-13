;Phoenix XL - Example4 _PredictText
#include-once
#include 'PredictText.au3'

;Description
;The Following Example Explains :
;How to Use Words Having space with Predict Text
;How to Use the PredictText UDF with two or more Edit Controls

;Our Graphic User Interface
$hGUI = GUICreate('Predict Text - Phoenix XL',500,400)


;The Words which have to be Predicted for First Edit Box.
Global $_Words1[3]=['My Dream is to become a COMPUTER ENGINEER','Phoenix XL']
;The Words which have to be Predicted for Second Edit Box.
Global $_Words2[3]=['Nice Meeting You','My Dream is to become a COMPUTER ENGINEER']

;First Edit - Case Sensitive
GUICtrlCreateGroup("First Edit  - Post-Space Prediction", 5, 10, 490,170)
GUICtrlCreateLabel("Type 'My Dream is ...' or 'Phoenix XL' to Find Out What Happens",10,30,480,30)
Global $Edit1 = GUICtrlCreateEdit('', 10, 50, 480, 120)
GUICtrlCreateGroup("", -99,-99, 480,30)

;Second Edit - Case InSensitive
GUICtrlCreateGroup("Second Edit  - No Post-Space Prediction", 5, 200, 490,180)
GUICtrlCreateLabel("Type 'Nice Meeting You' or 'My Dream is ...' to Find Out What Happens",10,220,480,30)
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
	Switch $lParam
		Case GUICtrlGetHandle($Edit1)
			;==>Post-Space Prediction
			_RegisterListingSpaceWords(Default,7)
			;Note that the $_Words1[1] is a String having 7 spaces therefore the previous Function is called
			_RegisterPrediction($lParam,$_Words1,Default,1)
		Case GUICtrlGetHandle($Edit2)
			;==>No Post-Space Prediction
			_RegisterPrediction($lParam,$_Words2,Default,0)
	EndSwitch
	Return 'GUI_RUNDEFMSG'
EndFunc