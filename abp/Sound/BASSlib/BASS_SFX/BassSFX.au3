#include-once

;Include Constants
#include <Bass.au3>
#include <BassConstants.au3>
#include <BassSFXConstants.au3>
#include <WinAPI.au3>

; #INDEX# =======================================================================================================================
; Title .........: BASSFX.au3
; Description ...: Wrapper of BassFX.DLL
; Author ........: Brett Francis (BrettF)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;			_BASS_SFX_Startup()
;			_BASS_SFX_WMP_GetPlugin()
;			_BASS_SFX_ErrorGetCode()
;			_BASS_SFX_GetVersion()
;			_BASS_SFX_Init()
;			_BASS_SFX_PluginFlags()
;			_BASS_SFX_PluginCreate()
;			_BASS_SFX_PluginGetType()
;			_BASS_SFX_PluginSetStream()
;			_BASS_SFX_PluginStart()
;			_BASS_SFX_PluginStop ()
;			_BASS_SFX_PluginGetName ()
;			_BASS_SFX_PluginConfig ()
;			_BASS_SFX_PluginModuleGetCount ()
;			_BASS_SFX_PluginModuleGetName ()
;			_BASS_SFX_PluginModuleSetActive ()
;			_BASS_SFX_PluginModuleGetActive ()
;			_BASS_SFX_PluginRender()
;			_BASS_SFX_PluginClicked "bass_sfx.dll" ()
;			_BASS_SFX_PluginResize ()
;			_BASS_SFX_PluginFree ()
;			_BASS_SFX_Free ()
; ===============================================================================================================================

Global $_ghBassSFXDll = -1
Global $BASS_SFX_DLL_UDF_VER = "2.4.1.6"
Global $BASS_ERR_DLL_NO_EXIST = -1

; #FUNCTION# ====================================================================================================================
; Name...........: _BASS_SFX_Startup
; Description ...: Starts up BassSFX functions.
; Syntax.........: _BASS_SFX_Startup($sBassSFXDLL)
; Parameters ....:  -	$sBassSFXDLL	-	The relative path to BassSFX.dll.
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
Func _BASS_SFX_Startup($sBassSFXDLL = "basssfx.dll")
	;Check if bass has already been started up.
	If $_ghBassSFXDll <> -1 Then Return True
	;Check if $sBassDLL exists.
	If Not FileExists($sBassSFXDLL) Then Return SetError($BASS_ERR_DLL_NO_EXIST, 0, False)
	;Check to make sure that the version of Bass.DLL is compatabile with this UDF version.  If not we will throw a text error.
	;Then we will exit the program
	If $BASS_STARTUP_BYPASS_VERSIONCHECK Then
		If _VersionCompare(FileGetVersion($sBassSFXDLL), $BASS_SFX_DLL_UDF_VER) = -1 Then
			MsgBox(0, "ERROR", "This version of BASSSFX.au3 is made for BassSFX.dll V" & $BASS_SFX_DLL_UDF_VER & ".  Please update")
			Exit
		EndIf
	EndIf
	;Open the DLL
	$_ghBassSFXDll = DllOpen($sBassSFXDLL)

	;Check if the DLL was opened correctly.
	Return $_ghBassSFXDll <> -1
EndFunc   ;==>_BASS_SFX_Startup

;==================================================================================================
;	Name:			_BASS_SFX_WMP_GetPlugin
;	Description:	Retrieves information on a registered windows media player plugin.
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $iIndex
;			-> The plugin to get the information of... 0 = first
;==================================================================================================
;	Returns Values:
;		- Sucess
;			-> Returns an array.
;				[0] = Name
;				[1] = CLSID
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_WMP_GetPlugin($iIndex)
	Local $aRet[2]

	$rStruct = DllStructCreate($BASS_SFX_PLUGININFO)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_WMP_GetPlugin", "int", $iIndex, "ptr", DllStructGetPtr($rStruct))
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		$aRet[0] = DllStructGetData($rStruct, "name")
		$aRet[1] = DllStructGetData($rStruct, "clsid")
		Return $aRet
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_WMP_GetPlugin

;==================================================================================================
;	Name:			_BASS_SFX_ErrorGetCode
;	Description:	Retrieves the error code for the most recent BASS_SFX function call.
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- None
;==================================================================================================
;	Returns Values:
;		- Returns one of the following.  See each function for possible error codes:
;			0	=	$BASS_SFX_OK
;			1	=	BASS_SFX_ERROR_MEM
;			2	=	BASS_SFX_ERROR_FILEOPEN
;			3	=	$BASS_SFX_ERROR_HANDLE
;			4	=	$BASS_SFX_ERROR_ALREADY
;			5	=	$BASS_SFX_ERROR_FORMAT
;			6	=	$BASS_SFX_ERROR_INIT
;			7	=	$BASS_SFX_ERROR_GUID
;			-1	=	$BASS_SFX_ERROR_UNKNOWN
;==================================================================================================
Func _BASS_SFX_ErrorGetCode()
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_ErrorGetCode")
	Return $vRet[0]
EndFunc   ;==>_BASS_SFX_ErrorGetCode

;==================================================================================================
;	Name:			_BASS_SFX_GetVersion
;	Description:	Retrieve the version of the SFX library.
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- None
;==================================================================================================
;	Returns Values:
;		- Returns the SFX version.
;			-> For example, 0x02040101 (hex), would be version 2.4.1.1
;==================================================================================================
Func _BASS_SFX_GetVersion()
	$vRet = DllCall($_ghBassSFXDll, "dword", "BASS_SFX_GetVersion")
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return Hex($vRet[0])
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_GetVersion

;==================================================================================================
;	Name:			_BASS_SFX_Init
;	Description:	Initialize the SFX library. This will initialize the library for use.
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $hBass_SFX_DLL
;			-> Location of bass_sfx.dll
;		- $hInstance
;			-> The instance handle of your main application
;		- $hWnd
;			-> The window handle of your main application
;==================================================================================================
;	Returns Values:
;		- Sucess
;			-> 1
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_Init($hWnd)
	$hInstance = _WinAPI_GetModuleHandle(0)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_Init", "hwnd", $hInstance, "hwnd", $hWnd)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return $vRet[0]
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_Init

;==================================================================================================
;	Name:			_BASS_SFX_PluginFlags
;	Description:	Modifies and retrieves a plugin's flags
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $hHandle
;			-> The handle of the sonique visual plugin
;		- $iFlags
;			->	Any combination of these flags.
;				-> BASS_SFX_SONIQUE_OPENGL
;				-> BASS_SFX_SONIQUE_OPENGL_DOUBLEBUFFER
;		- $mask
;			-> he flags (as above) to modfiy. Flags that are not included in this are left as
;			   they are, so it can be set to 0 in order to just retreive the current flags.
;==================================================================================================
;	Returns Values:
;		- Sucess
;			-> Returns the plugin's updated flags
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginFlags($hHandle, $iFlags, $mask)
	$vRet = DllCall($_ghBassSFXDll, "dword", "BASS_SFX_PluginFlags", "hwnd", $hHandle, "dword", $iFlags, "int", $mask)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginFlags

;==================================================================================================
;	Name:			_BASS_SFX_PluginCreate
;	Description:	Load a winamp, sonique, or windows media player visualization plugin for use
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $sPath
;			->
;		- $hHwnd
;			->
;		- $iWidth
;			->
;		- $iHeight
;			->
;		- $iFlags
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginCreate($sPath, $hWnd, $iWidth, $iHeight, $iFlags)
	$path = DllStructCreate("char[255]")
	DllStructSetData($path, 1, $sPath)
	$vRet = DllCall($_ghBassSFXDll, "dword", "BASS_SFX_PluginCreate", "ptr", DllStructGetPtr($path), "hwnd", $hWnd, "int", $iWidth, "int", $iHeight, "dword", $iFlags)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return $vRet[0]
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginCreate


;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginGetType($HSFX)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginGetType", "dword", $HSFX)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginGetType


;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginSetStream($hHandle, $hStream)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginSetStream", "dword", $hHandle, "dword", $hStream)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginSetStream

;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginStart($hHandle)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginStart", "dword", $hHandle)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginStart


;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginStop ($HSFX)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginStop", "dword", $HSFX)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginStop "bass_sfx.dll"

;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginGetName ($HSFX)
	$vRet = DllCall($_ghBassSFXDll, "ptr", "BASS_SFX_PluginGetName", "dword", $HSFX)
	$struct = DllStructCreate ("char[255]", $vRet[0])
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return DllStructGetData ($struct, 1)
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginGetName "bass_sfx.dll"

;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginConfig ($HSFX)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginConfig", "dword", $HSFX)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return $vRet[0]
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginConfig "bass_sfx.dll"

;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginModuleGetCount ($HSFX)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginModuleGetCount", "dword", $HSFX)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return $vRet[0]
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginModuleGetCount "bass_sfx.dll"

;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginModuleGetName ($HSFX, $iModule)
	$vRet = DllCall($_ghBassSFXDll, "ptr", "BASS_SFX_PluginModuleGetName", "dword", $HSFX, "int", $iModule)
	$rstruct = DllStructCreate ("char[255]", $vRet[0])
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return DllStructGetData ($rstruct, 1)
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginModuleGetName "bass_sfx.dll"

;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginModuleSetActive ($HSFX, $iModule)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginModuleSetActive", "dword", $HSFX, "int", $iModule)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return $vRet[0]
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginModuleSetActive "bass_sfx.dll"

;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginModuleGetActive ($HSFX)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginModuleGetActive")
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return $vRet[0]
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginModuleGetActive "bass_sfx.dll"

;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginRender($HSFX, $hStream, $HDC); "bass_sfx.dll" (ByVal handle As Long, ByVal hStream As Long, ByVal hDC As Long) As Long
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginRender", "dword", $HSFX, "dword", $hStream, "hwnd", $HDC)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return $vRet[0]
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginRender
#cs
;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginClicked "bass_sfx.dll" (ByVal handle As Long, ByVal X As Long, ByVal Y As Long) As Long
	$vRet = DllCall($_ghBassSFXDll, "int", "")
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginClicked "bass_sfx.dll"
#ce
;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginResize ($HSFX, $width, $height)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginResize", "dword", $HSFX, "int", $width, "int", $height)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return $vRet[0]
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginResize "bass_sfx.dll"

;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_PluginFree ($HSFX)
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_PluginFree", "dword", $HSFX)
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return $vRet[0]
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_PluginFree "bass_sfx.dll"

;==================================================================================================
;	Name:
;	Description:
;	Author:			Brett Francis (BrettF)
;	Version:		V1.0
;	Modified:
;==================================================================================================
;	Paramaters:
;		- $
;			->
;==================================================================================================
;	Returns Values:
;		- Sucess
;			->
;		- Failure
;			-> 0
;			-> @error is set to the value returned by _BASS_SFX_ErrorGetCode()
;==================================================================================================
Func _BASS_SFX_Free ()
	$vRet = DllCall($_ghBassSFXDll, "int", "BASS_SFX_Free")
	$iError = _BASS_SFX_ErrorGetCode()
	If $iError = 0 Then
		Return $vRet
	Else
		Return SetError($iError, 0, 0)
	EndIf
EndFunc   ;==>_BASS_SFX_Free "bass_sfx.dll"
