#include-once
#include <GuiEdit.au3>
#include <WinAPI.au3>
#include <Array.au3>

; #INDEX# =======================================================================================================================
; Title .........: PredictText
; Version........: 1.3
; AutoIt Version : 3.3.7.20++
; Language ......: English
; Author(s)......: Phoenix XL
; Librarie(s)....: WinAPI, Array and GUIEdit
; Description ...: Functions for Prediction of Text in an Edit Control.
;                  An edit control is a rectangular control window typically used in a dialog box to permit the user to enter
;                  and edit text by typing on the keyboard.
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $___nList = 0 ; Variable that holds the words to be Predicted
Global $___pOld_WndProc = 0; Old Window Procedure's Address
Global $___cEdit = 0 ; Handle of the Edit
Global $___iNewWords = 0 ; Set to 1 if New Words of $___Min_Count have to be added to $___nList
Global $___Min_Count = 3 ; Variable that stores the Minimum StrinLen of the NewWords to be stored when $___iNewWords=1
Global $___C_Sensitive = 2 ; 2-Case Insensitive(faster); 1-Case Sensitive; 0-Case Insensitive(slower); Similar to StringInStr Func
Global $___SpaceNext = 0 ;Required for the Prediction after Space
Global $___Max_Words = 50 ;The Maximum number of new words
Global $___nSpaceRecurse = 3 ;The Maximum number of spaces to be evaluated in a phrase
; Unregister, Unsubclass upon Exitting
OnAutoItExitRegister("_AutoExit")
; Register callback function and obtain handle to _New_WndProc
Global $___hNew_WndProc = DllCallbackRegister("_New_WndProc", "int", "hwnd;uint;wparam;lparam")
; Get pointer to _New_WndProc
Global $___pNew_WndProc = DllCallbackGetPtr($___hNew_WndProc)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_RegisterPrediction
;_UpdatePredictList
;_UnRegisterPrediction
;_RegisterListingSpaceWords
;_RegisterListingNewWords
;_GetSelectedText
;_GetListCount
;_GetCurrentWord
;_GetCaretOffset
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;_New_WndProc
; AddToArray
; MakeArray
;_Edit_SubClass
;_AutoExit
;_PredictText
;_PredictSpaceText
;_SetSelection
;_MatchString
;_CtrlSetStyle
;_CtrlGetStyle
;_RemoveBit
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _RegisterPrediction
; Description ...: Registers Prediction for a Defined List of Words
; Syntax.........: _RegisterPrediction($Edit_Handle[, $_Predict_List = ''[, $Sensitive = 2[, $SpacePredict = 0[, $_AddNewWords = 0]]]])
;
; Parameters ....: $Edit_Handle       	- Handle to the Edit Control
;                  $_Predict_List	  	- An Array of Strings, If blank then $_AddNewWords is by Default set to 1
;                  $_AddNewWords
;							| 0 - Don't Add New Words.
;							| 1 - Add New Words which are of at least of the Minimum Length (Can be set using _RegisterListingNewWords)
;                  $Sensitive
;							| 0 - not case sensitive, using the user's locale
;							| 1 - case sensitive
;							| 2 - not case sensitive, using a basic/faster comparison(default)
;				   $SpacePredict
;							| 0 - Doesnt Predict after a Space [Default]
;							| 1 - Predicts after space [by Default till 3 Spaces]
;
; Return values .: Success		- Returns 1 & Sets @error to 0
;				   Failure		- Returns 0 & Sets @error to
;							| 1 - Password Character is set
;							| 2 - $Edit_Handle is not a Handle
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: For Every _RegisterPrediction call an _UnRegisterPrediction is called for Debugging Purposes
;				   _UnRegisterPrediction is also called explictly upon Exit
;
; Related .......: _RegisterListingNewWords, _UpdatePredictList, _UnRegisterPrediction
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _RegisterPrediction($Edit_Handle, $_Predict_List = '', $Sensitive = 2, $SpacePredict = 0, $_AddNewWords = 0)

	If $___pOld_WndProc <> 0 Then _UnRegisterPrediction()
	If Not IsHWnd($Edit_Handle) Then Return SetError(2, 0, 0)
	If _GUICtrlEdit_GetPasswordChar($Edit_Handle) <> 0 Then Return SetError(1, 0, 0)

	If $_Predict_List = Default Then $_Predict_List = $___nList
	If $_AddNewWords = Default Then $_AddNewWords = 0
	If $Sensitive = Default Then $Sensitive = 2
	If $SpacePredict = Default Then $SpacePredict = 0
	If $_Predict_List = '' Then $_AddNewWords = 1

	$___iNewWords = $_AddNewWords
	$___cEdit = $Edit_Handle
	$___C_Sensitive = $Sensitive
	$___SpaceNext = $SpacePredict

	_UpdatePredictList($_Predict_List, 1)
	Local $CStyle = _CtrlGetStyle($Edit_Handle)
	_CtrlSetStyle($Edit_Handle, _RemoveBit($CStyle, $ES_WANTRETURN))
	$___pOld_WndProc = _Edit_SubClass($Edit_Handle, $___pNew_WndProc)

	Return SetError(0, 0, 1)

EndFunc   ;==>_RegisterPrediction

; #FUNCTION# ====================================================================================================================
; Name...........: _UpdatePredictList
; Description ...: Updates the Registered List of Words
; Syntax.........: _UpdatePredictList($_NewList [, $_wFlags = 0])
;
; Parameters ....: $_NewList	- A string or an Array of Strings, If blank then $_AddNewWords is by Default set to 1
;                  $_wFlags
;							| 0 - Add the New List to the Present List
;							| 1 - Overwrite the New List with the Present List
;							| 2 - Remove the Word or List of Words from the List
; Return values .: Success		- Returns 1 & Sets @error to 0
;				   Failure		- Returns 0 & Sets @error to
;							| 1 - The Flag Paramete is Wrong
;
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Called when _RegisterPrediction has been called with $_AddNewWords=1
;
; Related .......: _RegisterListingNewWords, _RegisterPrediction, _UnRegisterPrediction
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _UpdatePredictList($_NewList, $_wFlags = 0)
	Local $nFound
	Switch $_wFlags
		Case 0, Default
			Switch IsArray($_NewList)
				Case 1
					Local $nUbound = UBound($_NewList)
					For $i = 0 To $nUbound - 1
						AddToArray($___nList, $nUbound[$i])
					Next
				Case 0
					AddToArray($___nList, $_NewList)
			EndSwitch
		Case 1
			$___nList = $_NewList
			MakeArray($___nList)
		Case 2
			Switch IsArray($_NewList)
				Case 1
					For $n = 0 To UBound($_NewList) - 1
						While 1
							$nFound = _ArraySearch($___nList, $_NewList[$n], 0, 0, $___C_Sensitive = 1)
							If @error Then ExitLoop
							_ArrayDelete($___nList, $nFound)
						WEnd
					Next
				Case 0
					While 1
						$nFound = _ArraySearch($___nList, $_NewList, 0, 0, $___C_Sensitive = 1)
						If @error Then ExitLoop
						_ArrayDelete($___nList, $nFound)
					WEnd
			EndSwitch
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch
	Return SetError(0, 0, 1)
EndFunc   ;==>_UpdatePredictList

; #FUNCTION# ====================================================================================================================
; Name...........: _UnRegisterPrediction
; Description ...: UnRegisters the Prediction for an Edit Control
; Syntax.........: _UnRegisterPrediction()
;
; Parameters ....:
;
; Return values .: Success		- Returns
;							| 0 - Nothing is Currently Registered
;							| 1 - Unregistration was Successful
;				   Failure - Returns -1 & Sets @error to 1
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: If by some error not called AutoIt could Crash
;				   It is required to Set the Default Window Procedure of the Edit Control upon Exiting
;
; Related .......: _RegisterListingNewWords, _RegisterPrediction
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _UnRegisterPrediction()
	; If Nothing is registered Return 0
	If $___pOld_WndProc = 0 Then Return 0
	;UnSubClass the Edit Control
	Local $aRet = _Edit_SubClass($___cEdit, $___pOld_WndProc)
	;Reset the Private Global Variables
	$___pOld_WndProc = 0
	$___nList = 0
	$___cEdit = 0
	$___iNewWords = 0
	$___Min_Count = 3
	$___C_Sensitive = 2
	$___SpaceNext = 0
	$___Max_Words = 50
	$___nSpaceRecurse = 3
	;If error occured is unsubclassing then set error
	If $aRet = 0 Then Return SetError(1, 0, -1)
	Return 1
EndFunc   ;==>_UnRegisterPrediction

; #FUNCTION# ====================================================================================================================
; Name...........: _RegisterListingSpaceWords
; Description ...: Set or Unset Prediction Upon Space
; Syntax.........: _RegisterListingSpaceWords([$_wFlag = -1[, $Max_Len = 3]])
; Parameters ....: $_wFlag		 	- The Flag for the SapceWords
;						| 0 - UnRegister Listing Space Words
;						| 1 - Register Listing Space Words
;						|-1 - Doesnt Disturs the Value [Default]
;				   $Max_Len 		- The Maximum Number of spaces which can be Predicted
;										[Shouldn't be more than 50][By Default:3]
;
; Return values .: Success		- Returns 1 & Sets @error to 0
;				   Failure		- Returns -1 & Sets @error to 1 [Wrong Parameters]
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......:
; Related .......: _RegisterPrediction, _UpdatePredictList, _UnRegisterPrediction
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _RegisterListingSpaceWords($_wFlag = -1, $Max_Len = 3)
	Switch $_wFlag
		Case 1, 0
			;Don't Change
		Case Default, -1
			$_wFlag = $___SpaceNext
		Case Else
			Return SetError(1, $_wFlag, -1)
	EndSwitch
	If $Max_Len = Default Or $Max_Len > 50 Then $Max_Len = 3
	$___nSpaceRecurse = $Max_Len
	$___SpaceNext = $_wFlag
	Return SetError(0, 0, 1)
EndFunc   ;==>_RegisterListingSpaceWords

; #FUNCTION# ====================================================================================================================
; Name...........: _RegisterListingNewWords
; Description ...: Set or Unset Adding New Words
; Syntax.........: _RegisterListingNewWords([$_wFlag = -1[, $Min_Len = 3[,$MxNwWrds = 50]]])
; Parameters ....: $_wFlag		 	- The Flag for the NewWords
;						| 0 - UnRegister Listing New Words
;						| 1 - Register Listing New Words
;						|-1 - Doesnt Disturs the Value [Default]
;				   $Min_Len 		- The Minimum Length of the New Word [Shouldn't Be Less Than 3]
;				   $MxNwWrds		- The Maximum Number of NewWords [By Default 50]
;
; Return values .: Success		- Returns 1 & Sets @error to 0
;				   Failure		- Returns -1 & Sets @error to 1 [Wrong Parameters]
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......:
; Related .......: _RegisterPrediction, _UpdatePredictList, _UnRegisterPrediction
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _RegisterListingNewWords($_wFlag = -1, $Min_Len = 3, $MxNwWrds = 50)
	Switch $_wFlag
		Case 1, 0
			;Don't Change
		Case Default, -1
			$_wFlag = $___iNewWords
		Case Else
			Return SetError(1, $_wFlag, -1)
	EndSwitch
	If $Min_Len = Default Or $Min_Len < 3 Then $Min_Len = 3
	If $MxNwWrds = Default Or $MxNwWrds = 0 Then $MxNwWrds = 50
	$___Min_Count = $Min_Len
	$___iNewWords = $_wFlag
	$___Max_Words = $MxNwWrds
	Return SetError(0, 0, 1)
EndFunc   ;==>_RegisterListingNewWords

; #FUNCTION# ====================================================================================================================
; Name...........:  _GetSelectedText
; Description ...: Get the Selected Text in an Edit Control
; Syntax.........: _GetSelectedText($Edit_ID)
; Parameters ....: $Edit_ID  - The Control ID of the Edit
;
; Return values .: Success - Returns the Text and @extended=0
;					orelse @extended = 1 and Returns 0 when Nothing is Selected.
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GetSelectedText($Edit_ID)
	Local $Edit_Handle = GUICtrlGetHandle($Edit_ID)
	Local $_Ret = _GUICtrlEdit_GetSel($Edit_Handle)
	If $_Ret[0] = $_Ret[1] Then Return SetExtended(1, 0)
	$_Ret = ControlCommand('', '', $Edit_ID, "GetSelected", "")
	If $_Ret = '' Or $_Ret = '0' Then Return SetExtended(1, 0)
	Return $_Ret
EndFunc   ;==>_GetSelectedText

; #FUNCTION# ====================================================================================================================
; Name...........: _GetListCount
; Description ...: For debugging purposes by the User
; Syntax.........: _GetListCount()
; Parameters ....:
;
; Return values .: Success	- Returns the Total number of Words in the Predict List
;				   Failure  - Returns -1
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: The Maximum Array Size is 16777216
; Related .......: _UpdatePredictList
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _GetListCount()
	If Not IsArray($___nList) Then Return -1
	Return UBound($___nList)
EndFunc   ;==>_GetListCount

; #FUNCTION# ====================================================================================================================
; Name...........: _GetCurrentWord
; Description ...: Get the Current Word the Caret is Present at.
; Syntax.........: _GetCurrentWord($Edit_ID[, $_CaretIndex = -10])
; Parameters ....: $Edit_ID		 	- The Control ID of the Edit Control
;				   $_CaretIndex	 	- The Caret Index to Retrieve the Word from, if -1 the Present Caret Index is used
;				   $cEnter			- If Enter was Pressed then the Previous Line is Treated as the Primary Line
;						| 1 - Check the Previous Line
;						| 0 - Check the Present Line
; Return values .: Success		- Returns the Word & Sets @extended to the character offset of the first alphabet of the word.
;				   Failure		- Returns -1 & Sets @error to 1
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GetCurrentWord($Edit_ID, $_CaretIndex = -10, $cEnter = 0)
	Local $Edit_Handle = GUICtrlGetHandle($Edit_ID)
	If $_CaretIndex = Default Then $_CaretIndex = -10
	Local $_LineIndex
	If $_CaretIndex = -10 Then $_CaretIndex = _GetCaretOffset($Edit_ID)
	If $_CaretIndex < 0 Then Return SetError(1, $_CaretIndex, -1)
	Local $_Selection = _GUICtrlEdit_GetSel($Edit_Handle)
	Switch $_Selection[0]
		Case $_Selection[1]
			$_LineIndex = _GUICtrlEdit_LineFromChar($Edit_Handle, -1)
		Case Else
			_GUICtrlEdit_SetSel($Edit_Handle, -1, -1)
			$_LineIndex = _GUICtrlEdit_LineFromChar($Edit_Handle, -1)
			_GUICtrlEdit_SetSel($Edit_Handle, $_Selection[0], $_Selection[1])
	EndSwitch
	$_LineIndex -= $cEnter
	Local $_Offset = 0
	For $Index = 0 To $_LineIndex - 1
		$_Offset += StringLen(_GUICtrlEdit_GetLine($Edit_Handle, $Index)) + 2 ; 2 for Carriage Return and Line Feed
	Next
	Local $_LineText = _GUICtrlEdit_GetLine($Edit_Handle, $_LineIndex)
	If $_LineText = -1 Then Return SetError(2, 0, -1)
	Local $_SpaceSplit = StringSplit($_LineText, ' ', 1)
	For $x = 1 To $_SpaceSplit[0]
		Switch $_CaretIndex
			Case $_Offset To $_Offset + StringLen($_SpaceSplit[$x])
				;Switch $_SpaceSplit[$x]
				;	Case ''
				Return SetError(0, $_Offset, $_SpaceSplit[$x])
				;	Case Else
				;		Return SetExtended($_Offset , $_SpaceSplit[$x])
				;EndSwitch
		EndSwitch
		$_Offset += StringLen($_SpaceSplit[$x]) + 1
	Next
	Return SetError(1, 0, -1)
EndFunc   ;==>_GetCurrentWord

; #FUNCTION# ====================================================================================================================
; Name...........: _GetCaretOffset
; Description ...: Get the Offset of the Caret
; Syntax.........: _GetCaretOffset($Edit_ID)
; Parameters ....: $Edit_ID		 	- The Control ID of the Edit Control
;
; Return values .: Success		- Returns the Offset & Sets @extended to
;						| 1 - A Selection is Present
;						| 0 - No Selection is Present
;				   Failure		- Returns -1 & Sets @error to 1
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GetCaretOffset($Edit_ID)
	Local $Edit_Handle = GUICtrlGetHandle($Edit_ID)
	Local $_LineIndex = _GUICtrlEdit_GetSel($Edit_Handle)
	If Not IsArray($_LineIndex) Then Return SetError(1, 0, -1)
	Switch $_LineIndex[0]
		Case $_LineIndex[1]
			Return SetExtended(0, $_LineIndex[1])
		Case Else
			Local $_CoordMode = Opt('CaretCoordMode', 2)
			Local $_Caret = WinGetCaretPos()
			Local $_TextPos = _GUICtrlEdit_PosFromChar($Edit_Handle, $_LineIndex[0])
			Opt('CaretCoordMode', $_CoordMode)
			;$_LineIndex = _GUICtrlEdit_SetSel($Edit_Handle, -1, -1)
			;If Not IsArray($_LineIndex) Then Return SetError(1, 0, -1)
			;Local $aRet = _GetCaretOffset($Edit_ID)
			;_GUICtrlEdit_SetSel($Edit_Handle, $_LineIndex[0], $_LineIndex[1])
			Return SetExtended(1, $_TextPos[0] = $_Caret[0] And $_Caret[1] = $_TextPos[1])
	EndSwitch
EndFunc   ;==>_GetCaretOffset

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _New_WndProc
; Description ...: The New Window Procedure of the Subclassed Edit Control.
; Syntax.........: _New_WndProc($hWnd, $iMsg, $wParam, $lParam)
; Parameters ....: $hWnd   	- Handle to the window
;                  $iMsg	- Message ID
;				   $wParam 	- The first message parameter as hex value
;				   $lParam 	- The second message parameter as hex value
;
; Return values .: Passes the Same message to the Original Window Procedure and Returns the Same Value
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Called by the Edit Control Internally. If a Password Character is Set to the Edit Control,
;				   The Window Procedure is automatically set to Original and the Prediction is Unregistered
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _New_WndProc($hWnd, $iMsg, $wParam, $lParam)
	; Get the Handle of the Focused Control.
	Local $IDFrom = _WinAPI_GetDlgCtrlID($hWnd)
	Local $cOffset
	Local $_NewWord
	Switch $iMsg
		Case 0x0100 ; WM_KEYDOWN
			Switch $wParam
				Case 0x0D ;Enter
					$cOffset = _GetCaretOffset($IDFrom)
					Local $nExtended = @extended
					Switch $nExtended
						Case 0 ;Nothing Selected
							If BitAND(_CtrlGetStyle($hWnd), $ES_MULTILINE) Then _
									_GUICtrlEdit_InsertText($hWnd, @CRLF, $cOffset) ;Send @CRLF to a MultiLine Control
							;Also Check For New Word
							Switch $___iNewWords
								Case 0
									;Do Nothing
								Case 1
									;New Word - Add To The List
									Local $MultiLine = 0
									;Check if the Edit is Multiline
									Switch BitAND(_CtrlGetStyle($hWnd), $ES_MULTILINE)
										Case 0
											Return _WinAPI_CallWindowProc($___pOld_WndProc, $hWnd, $iMsg, _
													$wParam, $lParam)
										Case Else
											$_NewWord = _GetCurrentWord($IDFrom, $cOffset - 2, $MultiLine)
											If StringLen($_NewWord) < $___Min_Count Then Return _
													_WinAPI_CallWindowProc($___pOld_WndProc, $hWnd, $iMsg, $wParam, $lParam)
											Switch IsArray($___nList)
												Case 1
													For $i = 0 To UBound($___nList) - 1
														Switch $_NewWord
															Case $___nList[$i]
																ExitLoop
															Case Else
																Switch $i
																	Case UBound($___nList) - 1
																		AddToArray($___nList, $_NewWord, 1)
																EndSwitch
														EndSwitch
													Next
												Case 0
													$___nList = $_NewWord
													MakeArray($___nList)
											EndSwitch
									EndSwitch
							EndSwitch
							Return 1
						Case 1 ;Something is Selected
							_GUICtrlEdit_SetSel($hWnd, -1, -1) ;Deselect Selection
					EndSwitch
				Case 0x20 ;Spacebar
					Switch $___iNewWords
						Case 0
							;Do Nothing
						Case 1
							;New Word - Add To The List
							$cOffset = _GetCaretOffset($IDFrom)
							$_NewWord = _GetCurrentWord($IDFrom, $cOffset - 1)
							If StringLen($_NewWord) >= $___Min_Count Then
								Switch IsArray($___nList)
									Case 1
										For $i = 0 To UBound($___nList) - 1
											If $_NewWord = $___nList[$i] Then
												ExitLoop
											Else
												If $i = UBound($___nList) - 1 Then _
														AddToArray($___nList, $_NewWord, 1)
											EndIf
										Next
									Case 0
										Local $_MakeArray[1] = [$_NewWord]
										$___nList = $_MakeArray
								EndSwitch
							EndIf
					EndSwitch
				Case 0x08 ;BackSpace
					_GUICtrlEdit_ReplaceSel($hWnd, '')
			EndSwitch
		Case 0x0102 ;WM_CHAR
			Local $aRet
			Switch $wParam
				Case 33 To 65535 ;Printing Chars [Exclusive of Space and DEL]
					$aRet = _WinAPI_CallWindowProc($___pOld_WndProc, $hWnd, $iMsg, _
							$wParam, $lParam)
					_PredictText($IDFrom)
					Return $aRet
				Case 32
					Switch $___SpaceNext
						Case 0
							;Dont Predict on Space
						Case Else
							;Prediction for Words Containing SPACE
							Local $_SelText = _GetSelectedText($IDFrom)
							Switch IsInt($_SelText)
								Case 1
									;Nothing Selected
								Case 0
									If StringLeft($_SelText, 1) = ' ' Then
										$aRet = _WinAPI_CallWindowProc($___pOld_WndProc, $hWnd, _
												$iMsg, $wParam, $lParam)
										$cOffset = _GetCaretOffset($IDFrom)
										_GUICtrlEdit_InsertText($IDFrom, StringMid($_SelText, 2), $cOffset)
										_GUICtrlEdit_SetSel($IDFrom, $cOffset, $cOffset + StringLen($_SelText))
										Return $aRet
									EndIf
							EndSwitch
					EndSwitch
			EndSwitch
		Case $EM_SETPASSWORDCHAR
			If $wParam <> 0 Then _UnRegisterPrediction() ; Unregister Prediction if a Password Character is Set
	EndSwitch

	; Pass to the Original Window Procedure.
	Return _WinAPI_CallWindowProc($___pOld_WndProc, $hWnd, $iMsg, _
			$wParam, $lParam)
EndFunc   ;==>_New_WndProc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: AddToArray
; Description ...: Adds Value to the Array
; Syntax.........: AddToArray(ByRef $nArray, $Value[, $iNwWrd=0])
;
; Parameters ....: ByRef $nArray	- The Array
;				    	 $Value	 	- The Value to be Added
;						 $iNwWrd=0  - When Set to 1 Checks New Words Array Size[Internally Used]
;
; Return values .: Success - Returns Non-Zero
;				   Failure - Returns 0
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Deletes the values containing ''
;
; Related .......: AddToArray
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func AddToArray(ByRef $nArray, $Value, $iNwWrd = 0)
	;Local $Max_Array = ((17 * (10 ^ 6)) - 222784)
	For $n = 0 To UBound($nArray) - 1
		If $nArray[$n] = '' Then _ArrayDelete($nArray, $n)
	Next
	MakeArray($nArray)
	If IsInt($nArray[0]) Or $nArray[0] = '' Then
		Return _ArrayPush($nArray, $Value)
	Else
		If $iNwWrd Then
			Local $nUbound = UBound($___nList)
			If $nUbound = $___Max_Words Then
				Return _ArrayPush($nArray, $Value)
			EndIf
		EndIf
		Return _ArrayAdd($nArray, $Value)
	EndIf
	Return 0
EndFunc   ;==>AddToArray

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: MakeArray
; Description ...: Makes an Array from an Non-Array
; Syntax.........: MakeArray(ByRef $nNonArray)
;
; Parameters ....: ByRef $nNonArray - The Non-Array
;
; Return values .: Success - Returns 1
;				   Failure - Void
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: The Value of the Non-Array becomes the first
;				   value of the Array, for INTERNAL use only.
; Related .......: AddToArray
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func MakeArray(ByRef $nNonArray)
	If IsArray($nNonArray) Then Return 1
	Local $aArray[1] = [$nNonArray]
	$nNonArray = $aArray
	Return IsArray($nNonArray)
EndFunc   ;==>MakeArray

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........:  _Edit_SubClass
; Description ...: Subclass a Control
; Syntax.........: _Edit_SubClass($hWnd, $pNew_WindowProc)
; Parameters ....: $hWnd  - Handle of the Control
;                  $pNew_WindowProc - The Address of the New Window Procedure of the Control
;
; Return values .: Success - Sets @error to 0 and Returns the Previous Address of the Window Procedure
;				   Failure - Sets @error to 1
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Edit_SubClass($hWnd, $pNew_WindowProc)
	Local $iRes = _WinAPI_SetWindowLong($hWnd, -4, $pNew_WindowProc)
	If @error Then Return SetError(1, 0, 0)
	If $iRes = 0 Then Return SetError(1, 0, 0)
	Return SetError(0, 0, $iRes)
EndFunc   ;==>_Edit_SubClass

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........:  _AutoExit
; Description ...: Unregisters Prediction and Frees the DllCallBack Upon Exitting.
; Syntax.........: _AutoExit()
; Parameters ....:
;
; Return values .: Null
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used. For Debugging Purposes only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _AutoExit()
	; Unregister the Prediction
	_UnRegisterPrediction()
	; Now free UDF created WndProc
	DllCallbackFree($___hNew_WndProc)
EndFunc   ;==>_AutoExit

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _PredictText
; Description ...: Checks and Predicts the Text
; Syntax.........: _PredictText($Edit_ID)
; Parameters ....: $Edit_ID - The Edit Control ID
;
; Return values .: Success - Returns 1
;				   Failure - Returns non-one and Sets @error to non-zero
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _PredictText($Edit_ID)
	If $___SpaceNext Then
		If _PredictSpaceText($Edit_ID) Then Return 1
	EndIf
	Local $sRead = _GetCurrentWord($Edit_ID)
	Local $Match
	For $i = 0 To UBound($___nList) - 1
		$Match = _MatchString($___nList[$i], $sRead)
		If $Match Then
			Return _SetSelection($Edit_ID, $___nList[$i], $Match + StringLen($sRead))
		EndIf
	Next
	If @error Then Return SetError(@error, 0, -1)
	Return 0
EndFunc   ;==>_PredictText

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _PredictSpaceText
; Description ...: Checks and Predicts the Text
; Syntax.........: _PredictSpaceText($Edit_ID[,$cWord=-1[,$nExtended=-1]])
; Parameters ....: $Edit_ID 	- The Edit Control ID
;				   $cWord  		- Internally Used by the Recurse Calling of the Function
;				   $nExtended	- Internally Used by the Recurse Calling of the Function
; Return values .: Success - Returns 1
;				   Failure - Returns -1 and Sets @error to non-zero
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used. Iterative Version
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _PredictSpaceText($Edit_ID)
	Local $nExtended, $pWord, $sWord
	Local $cWord = _GetCurrentWord($Edit_ID)
	$nExtended = @extended
	For $___nOffset = 1 To $___nSpaceRecurse
		$pWord = _GetCurrentWord($Edit_ID, $nExtended - 2)
		$nExtended = @extended
		If $pWord < 0 Then Return 0
		$sWord = $pWord & ' ' & $cWord
		For $i = 0 To UBound($___nList) - 1
			Local $Match = _MatchString($___nList[$i], $sWord)
			If $Match Then
				Return _SetSelection($Edit_ID, $___nList[$i], StringLen($sWord) + 1)
			EndIf
		Next
		$cWord = $sWord
	Next
	Return 0
EndFunc   ;==>_PredictSpaceText

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _SetSelection
; Description ...: Helper Function for _PredictText, Is responsible for highlighting the Text
; Syntax.........: _SetSelection($Edit_ID, $_Data [, $___nOffset=1])
; Parameters ....: $Edit_ID - The Edit Control ID
;				   $_Data  	- The Text which has to be Highlighted
;				   $___nOffset	- The CutOff from the Real Data
; Return values .:
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _SetSelection($Edit_ID, $_Data, $___nOffset = 1)
	Local $_Text = StringMid($_Data, $___nOffset)
	Local $_Extended = _GetCaretOffset($Edit_ID)
	_GUICtrlEdit_InsertText($Edit_ID, $_Text, $_Extended)
	_GUICtrlEdit_SetSel($Edit_ID, $_Extended, $_Extended + StringLen($_Text))
	Return 1
EndFunc   ;==>_SetSelection

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _MatchString
; Description ...: Helper Function for _PredictText, Is responsible for checking the word
; Syntax.........: _MatchString($sString, $sSubString)
; Parameters ....: $sString 		- The Main String
;				   $sSubString  	- The SubString which has to be matched
;
; Return values .: Returns 0 if not matched or else the position of the match
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _MatchString($sString, $sSubString)
	If $sSubString = '' Then Return SetError(1, 0, '')
	Return StringInStr($sString, $sSubString, $___C_Sensitive, 1, 1, StringLen($sSubString))
EndFunc   ;==>_MatchString

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........:  _CtrlSetStyle
; Description ...: Set the Style of a Control
; Syntax.........: _CtrlSetStyle($hControl_hWnd, $Style)
; Parameters ....: $hControl_hWnd = Handle of the Control
;				   $Style  - The New Style
;
; Return values .: Similar to _WinAPI_SetWindowLong
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _CtrlSetStyle($hControl_hWnd, $Style)
	Return _WinAPI_SetWindowLong($hControl_hWnd, 0xFFFFFFF0, $Style)
EndFunc   ;==>_CtrlSetStyle

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _CtrlGetStyle
; Description ...: Get the Style of a Control
; Syntax.........: _CtrlGetStyle($hControl_hWnd, $Style)
; Parameters ....: $hControl_hWnd = Handle of the Control
;
; Return values .: Similar to _WinAPI_GetWindowLong
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: Internally Used.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _CtrlGetStyle($hControl_hWnd)
	Return _WinAPI_GetWindowLong($hControl_hWnd, 0xFFFFFFF0)
EndFunc   ;==>_CtrlGetStyle

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _RemoveBit
; Description ...: Remove a Bit from a Value
; Syntax.........: _RemoveBit($Original_Bits, $_ToRemove)
; Parameters ....: $Original_Bits - The Value which has to be Checked
;				   $_ToRemove	  -   	The Value which has to be removed
;
; Return values .: Returns the Requested Value.
;
; Author ........: Phoenix XL
; Modified.......:
; Remarks .......: If the $_ToRemove is not Present in $Original_Bits, @extended is set to 1
;				   and Original Bits are returned
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _RemoveBit($Original_Bits, $_ToRemove)
	If BitAND($Original_Bits, $_ToRemove) Then
		Return BitXOR($Original_Bits, $_ToRemove)
	Else
		Return SetExtended(1, $Original_Bits)
	EndIf
EndFunc   ;==>_RemoveBit

#cs
	Func _PredictSpaceText($RichEdit_ID)
	Local $cWord = _GetCurrentWord($RichEdit_ID), $nExtended = @extended
	Local $pWord = _GetCurrentWord($RichEdit_ID, $nExtended - 2), $___nOffset = 0
	$nExtended = @extended
	If $pWord < 0 Then Return 0
	Local $sWord = $pWord & ' ' & $cWord
	While $___nOffset < $___nSpaceRecurse
	For $i = 0 To UBound($___nList) - 1
	Local $Match = _MatchString($___nList[$i], $sWord)
	If $Match Then
	Return _SetSelection($RichEdit_ID, $___nList[$i], StringLen($sWord) + 1)
	Else
	$___nOffset += 1
	$cWord = $pWord
	$pWord = _GetCurrentWord($RichEdit_ID, $nExtended - 2)
	EndIf
	Next
	WEnd
	Return 0
	EndFunc   ;==>_PredictSpaceText
#ce
