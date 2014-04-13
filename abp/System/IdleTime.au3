

#cs #FUNCTION# ====================================================================================================================
    Name...........: _GetIdleTime()

    Description ...: (Can Execute A Function) When The User Is Idle For Specified Amount Of Time

    Syntax.........: _GetIdleTime($Time,$Return=0)

    Parameters ....: $Time = The Amount Of Time to Check The User To be Idle....
					 $Return = 1 Return The Func Immediately if The User is not Idle
					 $Return = 0 Wait For The User To Get Idle For Specified Amount of Time and Then Return

    Returns........: Success = 0
					 Failure(The User Wasnt Idle For The Specified Amount of Time , Applicable only When $Return=1) = 1
	                 Unable To call User32.dll = -1
					 Unable To create Dll Structure = -2

    Author ........: Abhishek

    Remarks .......: To Execute a Func When The User is Not Idle Call a Func in [Section]

    Example .......: _Example()
#ce ===============================================================================================================================
Func _GetIdleTime($Time,$Return=0)

	Local $ISAVE, $LASTINPUTINFO = DllStructCreate("uint;dword"), $TRACE = 0
	If $LASTINPUTINFO=0 Then Return -2

	DllStructSetData($LASTINPUTINFO, 1, DllStructGetSize($LASTINPUTINFO))
	DllCall("user32.dll", "int", "GetLastInputInfo", "ptr", DllStructGetPtr($LASTINPUTINFO))
	If @error Then Return -1

	While $TRACE <= $Time
		$ISAVE = DllStructGetData($LASTINPUTINFO, 2)
		Sleep(1000)
		DllCall("user32.dll", "int", "GetLastInputInfo", "ptr", DllStructGetPtr($LASTINPUTINFO))
		Switch Floor(DllStructGetData($LASTINPUTINFO, 2) / 1000) - Floor($ISAVE / 1000)
			Case 0
				$TRACE += 1
			Case Else
				$TRACE = 0
				Switch $Return
					Case 0
						;[Section] Stuff to do when the user is not Idle
					Case 1
						Return 1
				EndSwitch
		EndSwitch
	WEnd
	;Call($FuncName) ;Stuff to do when the user is Idle for the specified amount of time
	Return 0
EndFunc

;  ===============================================================================================================================
_Example()
Func _Example()
	Sleep(500)
	Switch _GetIdleTime(10,1)
		Case 0
			MsgBox(0,"Information",'The User Was Idle For 10 Secs.......')
		Case 1
			MsgBox(0,"Information","The User Wasn't Idle For 10 Secs.......")
	EndSwitch
EndFunc
;  ===============================================================================================================================