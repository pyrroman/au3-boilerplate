; #INDEX# =======================================================================================================================
; Title .........: BassTags.au3
; Description ...: Allows easy retrieval of tags using the handle of the currently playing stream.
; Author ........: Brett Francis (BrettF)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;			_Bass_Tags_Startup()
;			_Bass_Tags_Read()
;			_Bass_Tags_GetLastErrorDesc()
;			_Bass_Tags_GetVersion()
; ===============================================================================================================================

Global $_ghBassTagsDll = -1
Global $BASS_TAGS_DLL_UDF_VER = "0.0.0.15"
Global $BASS_ERR_DLL_NO_EXIST = -1

; #FUNCTION# ====================================================================================================================
; Name...........: _Bass_Tags_Startup
; Description ...: Starts up BASS functions.
; Syntax.........: _Bass_Tags_Startup($sBassTagsDll)
; Parameters ....:  -	$sBassTagsDll	-	The relative path to tags.dll.
; Return values .: Success      - Returns True
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										- $BASS_ERR_DLL_NO_EXIST	-	File could not be found.
;
;								  If the version of this UDF is not compatabile with this version of Bass, then the following
;								  error will be displayed to the user.  This can be disabled by setting
;										$BASS_STARTUP_BYPASS_VERSIONCHECK = 1
;								  This is the error show to the user:
;									 	This version of BassTags.au3 is not made for tags.dll VX.X.X.X.  Please update.
; Author ........: Prog@ndy
; Modified.......: Brett Francis (BrettF)
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _Bass_Tags_Startup($sBassTagsDll="tags.dll")
	;Check if bass has already been started up.
	If $_ghBassTagsDll <> -1 Then Return True
	;Check if $sBassTagsDll exists.
	If Not FileExists ($sBassTagsDll) Then Return SetError ($BASS_ERR_DLL_NO_EXIST, 0, False)
	;Check to make sure that the version of tags.dll is compatabile with this UDF version.  If not we will throw a text error.
	;Then we will exit the program
	If $BASS_STARTUP_BYPASS_VERSIONCHECK Then
		If _VersionCompare(FileGetVersion ($sBassTagsDll), $BASS_TAGS_DLL_UDF_VER) = -1 Then
			MsgBox (0, "ERROR", "This version of BassTags.au3 is made for tags.dll V" & $BASS_TAGS_DLL_UDF_VER & ".  Please update")
			Exit
		EndIf
	EndIf
	;Open the DLL
	$_ghBassTagsDll = DllOpen($sBassTagsDll)

	;Check if the DLL was opened correctly.
	Return $_ghBassTagsDll <> -1
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Bass_Tags_
; Description ...:
; Syntax.........: _Bass_Tags_
; Parameters ....:  -	$	-
; Return values .: Success      - Returns True
;                  Failure      - Returns False and sets @ERROR as set by _Bass_ErrorGetCode()
;									@error will be set to-
;										- $	-
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _Bass_Tags_Read ($hHandle, $sFMT)
	$_bTags_Ret_ = DllCall ($_ghBassTagsDll, "str", "TAGS_Read", "dword", $hHandle, "str", $sFMT)
	If @error Then Return SetError (1, @error, 0)
	Return $_bTags_Ret_[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Bass_Tags_
; Description ...:
; Syntax.........: _Bass_Tags_
; Parameters ....:  -	$	-
; Return values .: Success      - Returns True
;                  Failure      - Returns False and sets @ERROR as set by _Bass_ErrorGetCode()
;									@error will be set to-
;										- $	-
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _Bass_Tags_GetLastErrorDesc ()
	$_bTags_Ret_ = DllCall ($_ghBassTagsDll, "str", "TAGS_GetLastErrorDesc")
	If @error Then Return SetError (1, @error, 0)
	Return $_bTags_Ret_[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Bass_Tags_
; Description ...:
; Syntax.........: _Bass_Tags_
; Parameters ....:  -	$	-
; Return values .: Success      - Returns True
;                  Failure      - Returns False and sets @ERROR as set by _Bass_ErrorGetCode()
;									@error will be set to-
;										- $	-
; Author ........: Brett Francis (BrettF)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _Bass_Tags_GetVersion ()
	$_bTags_Ret_ = DllCall ($_ghBassTagsDll, "dword", "TAGS_GetVersion")
	If @error Then Return SetError (1, @error, 0)
	Return $_bTags_Ret_[0]
EndFunc
