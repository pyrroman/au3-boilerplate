#include <BASSASIOConstants.au3>
#include <BASS.au3>
; #INDEX# =======================================================================================================================
; Title .........: BASSCD.au3
; Description ...: Wrapper for BASSCD.dll
; Author ........: Brett Francis (BrettF)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;			_BASS_ASIO_CB_ChannelGetLevel
;			_BASS_ASIO_CB_ChannelEnable
;			_BASS_ASIO_CB_LinkInOut
;			_BASS_ASIO_GetVersion
;			_BASS_ASIO_ErrorGetCode
;			_BASS_ASIO_GetDeviceInfo
;			_BASS_ASIO_SetDevice
;			_BASS_ASIO_GetDevice
;			_BASS_ASIO_Init
;			_BASS_ASIO_Free
;			_BASS_ASIO_ControlPanel
;			_BASS_ASIO_GetInfo
;			_BASS_ASIO_SetRate
;			_BASS_ASIO_GetRate
;			_BASS_ASIO_Start
;			_BASS_ASIO_Stop
;			_BASS_ASIO_IsStarted
;			_BASS_ASIO_GetLatency
;			_BASS_ASIO_GetCPU
;			_BASS_ASIO_Monitor
;			_BASS_ASIO_ChannelGetInfo
;			_BASS_ASIO_ChannelReset
;			_BASS_ASIO_ChannelEnable
;			_BASS_ASIO_ChannelEnableMirror
;			_BASS_ASIO_ChannelJoin
;			_BASS_ASIO_ChannelPause
;			_BASS_ASIO_ChannelIsActive
;			_BASS_ASIO_ChannelSetFormat
;			_BASS_ASIO_ChannelGetFormat
;			_BASS_ASIO_ChannelSetRate
;			_BASS_ASIO_ChannelGetRate
;			_BASS_ASIO_ChannelSetVolume
;			_BASS_ASIO_ChannelGetVolume
;			_BASS_ASIO_ChannelGetLevel
;			_BASS_ASIO_Startup
; ===============================================================================================================================
Global $_ghBassASIODll = -1
Global $BASS_ASIO_DLL_UDF_VER = "1.0.1.0"
Global $BASS_ERR_DLL_NO_EXIST = -1

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_ASIO_Startup
; Description ...: Starts up BassCD functions.
; Syntax.........: _BASS_ASIOStartup($sBassASIODll)
; Parameters ....:  -	$sBassASIODll	-	The relative path to BassCD.dll.
; Return values .: Success      - Returns True
;                  Failure      - Returns False and sets @ERROR
;									@error will be set to-
;										- $BASS_ERR_DLL_NO_EXIST	-	File could not be found.
;								  If the version of this UDF is not compatabile with this version of Bass, then the following
;								  error will be displayed to the user.  This can be disabled by setting
;										$BASS_STARTUP_BYPASS_VERSIONCHECK = 1
;								  This is the error show to the user:
;									 	This version of Bass.au3 is not made for Bass.dll VX.X.X.X.  Please update.
; Author ........: Prog@ndy
; Modified.......: Brett Francis (BrettF)
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_ASIO_Startup($sBassASIODll = "bassasio.dll")
	;Check if bass has already been started up.
	If $_ghBassASIODll <> -1 Then Return True
	;Check if $sBassDLL exists.
	If Not FileExists($sBassASIODll) Then Return SetError($BASS_ERR_DLL_NO_EXIST, 0, False)
	;Check to make sure that the version of Bass.DLL is compatabile with this UDF version.  If not we will throw a text error.
	;Then we will exit the program
	If $BASS_STARTUP_BYPASS_VERSIONCHECK Then
		If _VersionCompare(FileGetVersion($sBassASIODll), $BASS_ASIO_DLL_UDF_VER) = -1 Then
			MsgBox(0, "ERROR", "This version of BASSASIO.au3 is made for BassASIO.dll V" & $BASS_ASIO_DLL_UDF_VER & ".  Please update")
			Exit
		EndIf
	EndIf
	;Open the DLL
	$_ghBassASIODll = DllOpen($sBassASIODll)

	;Check if the DLL was opened correctly.
	Return $_ghBassASIODll <> -1
EndFunc   ;==>_BASS_ASIO_Startup


Func _BASS_ASIO_CB_ChannelEnable($input, $channel, $handle)
	$bass_asio_ret = DllCall($_ghBassASIODll, "dword", "BASS_ASIO_CB_ChannelEnable", "dword", $input, "dword", $channel, "dword", $handle)
	If @error Then
		Return SetError(@error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_CB_ChannelEnable

Func _BASS_ASIO_CB_ChannelGetLevel($input, $channel)
	$bass_asio_ret = DllCall($_ghBassASIODll, "float", "BASS_ASIO_CB_ChannelGetLevel", "dword", $input, "dword", $channel)
	If @error Then
		Return SetError(@error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_CB_ChannelGetLevel

Func _BASS_ASIO_CB_LinkInOut($inputchannel, $outputchannel)
	$bass_asio_ret = DllCall($_ghBassASIODll, "dword", "BASS_ASIO_CB_LinkInOut", "dword", $inputchannel, "dword", $outputchannel)
	If @error Then
		Return SetError(@error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_CB_LinkInOut

Func _BASS_ASIO_GetVersion($bass_asio_dll)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_GetVersion")
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_GetVersion

Func _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ErrorGetCode")
	If @error Then Return SetError(0, @error, "")
	Return SetError(0, "", $bass_asio_ret[0])
EndFunc   ;==>_BASS_ASIO_ErrorGetCode

Func _BASS_ASIO_GetDeviceInfo($bass_asio_dll, $device)
	Local $aRet[3]
	$BASS_asio_ret_struct = DllStructCreate($BASS_ASIO_DEVICEINFO)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_GetDeviceInfo", "dword", $device, "ptr", DllStructGetPtr($BASS_asio_ret_struct))
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		$aRet[0] = $bass_asio_ret[0]
		$aRet[1] = _BASS_ASIO_PtrStringRead(DllStructGetData($BASS_asio_ret_struct, 1))
		$aRet[2] = _BASS_ASIO_PtrStringRead(DllStructGetData($BASS_asio_ret_struct, 2))
		Return SetError(0, "", $aRet)
	EndIf
EndFunc   ;==>_BASS_ASIO_GetDeviceInfo

Func _BASS_ASIO_SetDevice($bass_asio_dll, $device)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_SetDevice", "dword", $device)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_SetDevice

Func _BASS_ASIO_GetDevice($bass_asio_dll)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_GetDevice")
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_GetDevice

Func _BASS_ASIO_Init($bass_asio_dll, $device)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_Init", "dword", $device)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_Init

Func _BASS_ASIO_Free($bass_asio_dll)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_Free")
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_Free

Func _BASS_ASIO_ControlPanel($bass_asio_dll)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ControlPanel")
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ControlPanel

Func _BASS_ASIO_GetInfo($bass_asio_dll)
	Local $aRet[8]
	$BASS_asio_ret_struct = DllStructCreate($BASS_ASIO_INFO)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_GetInfo", "ptr", DllStructGetPtr($BASS_asio_ret_struct))
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		For $i = 0 To 7
			$aRet[$i] = DllStructGetData($BASS_asio_ret_struct, $i + 1)
		Next
		Return SetError(0, "", $aRet)
	EndIf
EndFunc   ;==>_BASS_ASIO_GetInfo

Func _BASS_ASIO_SetRate($bass_asio_dll, $rate)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_SetRate", "double", $rate)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_SetRate

Func _BASS_ASIO_GetRate($bass_asio_dll)
	$bass_asio_ret = DllCall($bass_asio_dll, "double", "BASS_ASIO_GetRate")
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_GetRate

Func _BASS_ASIO_Start($bass_asio_dll, $buflen)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_Start", "dword", $buflen)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_Start

Func _BASS_ASIO_Stop($bass_asio_dll)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_Stop")
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_Stop

Func _BASS_ASIO_IsStarted($bass_asio_dll)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_IsStarted")
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_IsStarted

Func _BASS_ASIO_GetLatency($bass_asio_dll, $input)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_GetLatency", "dword", $input)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_GetLatency

Func _BASS_ASIO_GetCPU($bass_asio_dll)
	$bass_asio_ret = DllCall($bass_asio_dll, "float", "BASS_ASIO_GetCPU")
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_GetCPU

Func _BASS_ASIO_Monitor($bass_asio_dll, $input, $output, $gain, $state, $pan)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_Monitor", "int", $input, "dword", $output, "dword", $gain, "dword", $state, "dword", $pan)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_Monitor

Func _BASS_ASIO_ChannelGetInfo($bass_asio_dll, $input, $channel, $info)
	Local $aRet[3]
	$BASS_asio_ret_struct = DllStructCreate($BASS_ASIO_CHANNELINFO)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelGetInfo", "dword", $input, "dword", $channel, "ptr", DllStructGetPtr($BASS_asio_ret_struct))
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		For $i = 0 To 2
			$aRet[$i] = DllStructGetData($BASS_asio_ret_struct, $i + 1)
		Next
		Return SetError(0, "", $aRet)
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelGetInfo

Func _BASS_ASIO_ChannelReset($bass_asio_dll, $input, $channel, $flags)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelReset", "dword", $input, "int", $channel, "dword", $flags)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelReset

Func _BASS_ASIO_ChannelEnable($bass_asio_dll, $input, $channel, $proc, $user = "")
	If $proc <> "" Then
		$dc = DllCallbackRegister($proc, "int", "dword;ptr;dword;ptr;")
		$dsUser = DllStructCreate("char[255]")
		DllStructSetData($dsUser, 1, $user)
		$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelEnable", "dword", $input, "dword", $channel, "ptr", DllCallbackGetPtr($dc), "ptr", DllStructGetPtr($dsUser))
	Else
		$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelEnable", "dword", $input, "dword", $channel, "ptr", 0, "ptr", 0)
	EndIf
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelEnable

Func _BASS_ASIO_ChannelEnableMirror($bass_asio_dll, $channel, $input2, $channel2)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelEnableMirror", "dword", $channel, "dword", $input2, "dword", $channel2)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelEnableMirror

Func _BASS_ASIO_ChannelJoin($bass_asio_dll, $input, $channel, $channel2)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelJoin", "dword", $input, "dword", $channel, "dword", $channel2)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelJoin

Func _BASS_ASIO_ChannelPause($bass_asio_dll, $input, $channel)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelPause", "dword", $input, "dword", $channel)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelPause

Func _BASS_ASIO_ChannelIsActive($bass_asio_dll, $input, $channel)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelIsActive", "dword", $input, "dword", $channel)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelIsActive

Func _BASS_ASIO_ChannelSetFormat($bass_asio_dll, $input, $channel, $format)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelSetFormat", "dword", $input, "dword", $channel, "dword", $format)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelSetFormat

Func _BASS_ASIO_ChannelGetFormat($bass_asio_dll, $input, $channel)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelGetFormat", "dword", $input, "dword", $channel)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelGetFormat

Func _BASS_ASIO_ChannelSetRate($bass_asio_dll, $input, $channel, $rate)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelSetRate", "dword", $input, "dword", $channel, "double", $rate)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelSetRate

Func _BASS_ASIO_ChannelGetRate($bass_asio_dll, $input, $channel)
	$bass_asio_ret = DllCall($bass_asio_dll, "double", "BASS_ASIO_ChannelGetRate", "dword", $input, "dword", $channel)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelGetRate

Func _BASS_ASIO_ChannelSetVolume($bass_asio_dll, $input, $channel, $volume)
	$bass_asio_ret = DllCall($bass_asio_dll, "dword", "BASS_ASIO_ChannelSetVolume", "dword", $input, "int", $channel, "float", $volume)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelSetVolume

Func _BASS_ASIO_ChannelGetVolume($bass_asio_dll, $input, $channel)
	$bass_asio_ret = DllCall($bass_asio_dll, "float", "BASS_ASIO_ChannelGetVolume", "dword", $input, "int", $channel)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelGetVolume

Func _BASS_ASIO_ChannelGetLevel($bass_asio_dll, $input, $channel)
	$bass_asio_ret = DllCall($bass_asio_dll, "float", "BASS_ASIO_ChannelGetLevel", "dword", $input, "dword", $channel)
	$error = _BASS_ASIO_ErrorGetCode($bass_asio_dll)
	If $error <> 0 Then
		Return SetError($error, "", 0)
	Else
		Return SetError(0, "", $bass_asio_ret[0])
	EndIf
EndFunc   ;==>_BASS_ASIO_ChannelGetLevel

; #INTERNAL# ====================================================================================================================
; Name...........: _BASS_ASIO_PtrStringLen
; Description ...: Retrieves the lenth of a string in a PTR.
; Syntax.........: _BASS_ASIO_PtrStringLen($ptr, $IsUniCode = False)
; Parameters ....:  -    $ptr                   -  Pointer to the string
;               -  [Optional] $IsUniCode  -  True = Unicode, False (Default) = ANSI
; Return values .: Success   -   Returns length of string ( can be 0 as well )
;                  Failure   -   Returns -1 and sets @ERROR
;                           @error will be set to 1
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_ASIO_PtrStringLen($ptr, $IsUniCode = False)
	Local $UniCodeFunc = ""
	If $IsUniCode Then $UniCodeFunc = "W"
	Local $BASS_ret_ = DllCall("kernel32.dll", "int", "lstrlen" & $UniCodeFunc, "ptr", $ptr)
	If @error Then Return SetError(1, 0, -1)
	Return $BASS_ret_[0]
EndFunc   ;==>_BASS_ASIO_PtrStringLen

; #INTERNAL# ====================================================================================================================
; Name...........: _BASS_ASIO_PtrStringRead
; Description ...: Reads a string from a pointer
; Syntax.........: _BASS_ASIO_PtrStringRead($ptr, $IsUniCode = False, $StringLen = -1)
; Parameters ....:  -    $ptr        -  Pointer to the string
;               -  $IsUniCode  -  [Optional] True = Unicode, False (Default) = ANSI
;               -  $StringLen  -  [Optional] Length of the String
; Return values .: Success  -  Returns the read string (can be empty)
;                  Failure  -  Returns "" (empty String) and sets @ERROR
;                           @error will be set to 1
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......;
; ===============================================================================================================================
Func _BASS_ASIO_PtrStringRead($ptr, $IsUniCode = False, $StringLen = -1)
	Local $UniCodeString = ""
	If $IsUniCode Then $UniCodeString = "W"
	If $StringLen < 1 Then $StringLen = _BASS_ASIO_PtrStringLen($ptr, $IsUniCode)
	If $StringLen < 1 Then Return SetError(1, 0, "")
	Local $struct = DllStructCreate($UniCodeString & "char[" & ($StringLen + 1) & "]", $ptr)
	Return DllStructGetData($struct, 1)
EndFunc   ;==>_BASS_ASIO_PtrStringRead
