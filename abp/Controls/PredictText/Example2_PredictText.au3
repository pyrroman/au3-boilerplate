;Phoenix XL - Example2 _PredictText
#include-once
#include 'PredictText.au3'
#include <EditConstants.au3>

;Description
;Shows how to make the UDF add new words to the Database and Predict the same.
;Also shows how to take a look at the Array size of the New Words.[not required in this version v1.2]

#cs
	In the Following Script the number of new words are always 3
	If a new word beyond this limit, is added it removes the first
	new word
#ce

;Our Graphic User Interface
Local $hGUI = GUICreate('Predict Text - Phoenix XL',500,200)

;The Variable having the Minimum Length of Words to be Added
Local $_MinSize = 5
;The Maximum Number of NewWords, For Debugging Purposes only
Local $_MaxWords = 3

;Edit - Case InSensitive & Add New Words
GUICtrlCreateGroup("Edit  -  Case InSensitive Add New Words", 5, 10, 490,180)
GUICtrlCreateLabel("Type Any Word Twice and It will Get Predicted [Min: "&$_MinSize&"chars; Max: "&$_MaxWords&"words]",10,30,480,30)
Local $Edit = GUICtrlCreateEdit('', 10,60, 480, 120)
GUICtrlCreateGroup("", -99,-99, 480,30)

;AdlibRegister('ArrayCheck',10000)[not required in this version]


;Make The Registration with AddNewWords set to 1 [When no predict List AddNewWords is by Default set to 1]
_RegisterPrediction(GUICtrlGetHandle($Edit)) ;Note the NewWord Should Atleast have $_Min alphabets in it
_RegisterListingNewWords(1,$_MinSize,$_MaxWords) ; The Minimum Length of the New Word Should be equal to $_Min

GUISetState()

;GUI Message Loop
Local $iGUIGetMsg
While 1
    $iGUIGetMsg = GUIGetMsg()
    Switch $iGUIGetMsg
		Case -3	;GUI_EVENT_CLOSE
			_UnregisterPrediction()
            ExitLoop
    EndSwitch
WEnd

#cs
	The Checking of the Array Size is automatic
	if explictily wanted to be set check the
	third parameter of _RegisterListingNewWords
#ce
;The Following function is not required in this version
Func ArrayCheck()
	Local $_Count=_GetListCount()
	; If the List has More than Three Words then Delete All the New Words
	If $_Count>$_MaxWords Then
		_UpdatePredictList('',1)
		ConsoleWrite('New Words Deleted')
	EndIf
EndFunc
