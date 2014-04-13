;Phoenix XL - Example4 _PredictText
#include-once
#include 'PredictText.au3'

;Our Graphic User Interface
$hGUI = GUICreate('Predict Text - Phoenix XL',500,280)
; /-
GUICtrlCreateLabel("Predict Text Edit",10,10,480,30)
;The Edit where Prediction will take place
GUICtrlCreateEdit('', 10, 30, 480, 150,0)
;Handle of the Edit
Local $Edit_hWnd=GUICtrlGetHandle(-1)
;The Input for adding words to the List
Local $Input = GUICtrlCreateInput('', 100, 200, 390, 30)
;Cue Banner
GUICtrlSendMsg(-1,0x1500+1,False,'Type the Text to be Predicted')
;The Button to add the Text in Input into Predict List
Local $nButton = GUICtrlCreateButton('Add to List',10,200,80,30,1)
;Show the GUI
GUISetState()

;Status Bar - Didnt wished to use any other UDF
Global $nStatus=GUICtrlCreateEdit('',0,260,500,20,1)
AdlibRegister('Reset',100)
GUICtrlSetState(-1,128) ;GUI_DISABLE

;Var for Testing if Prediction already Set UP
Global $nPrediction = False

;Our Message Loop
While 1
	Switch GUIGetMsg()
		Case $nButton
			Local $sRead=GUICtrlRead($Input)
			Switch $nPrediction
				Case False
					;Set Space Words to 1
					_RegisterPrediction($Edit_hWnd,$sRead,Default,1)
					$nPrediction=True

					;Status Bar Update
					GUICtrlSetData($nStatus,'Prediction Has Been Registered..!')
					;Status Bar Reset
					AdlibRegister('Reset',6000)
					;Reset Edit
					GUICtrlSetData($Input,'')
				Case True
					_UpdatePredictList($sRead)

					;Status Bar Update
					GUICtrlSetData($nStatus,'Predict List Has Been Updated..!')
					;Status Bar Reset
					AdlibRegister('Reset',6000)
			EndSwitch
		Case -3
			ExitLoop
	EndSwitch
WEnd

Func Reset()
	AdlibUnRegister('Reset')
	GUICtrlSetData($nStatus,'')
	For $n=0 To 50
		GUICtrlSetData($nStatus,GUICtrlRead($nStatus)&'-')
		Sleep(10)
	Next
EndFunc
