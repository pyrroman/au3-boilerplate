;FileChangeDir("D:\Dokumente\Dateien von Andreas\AutoIt3\bass24")
; #FUNCTION# ====================================================================================================================
; Name...........: __BASS_LoadLibrary
; Author ........: Paul Campbell (PaulIA)
; ===============================================================================================================================
Func __BASS_LoadLibrary($sFileName)
	Local $aResult = DllCall("Kernel32.dll", "hwnd", "LoadLibraryA", "str", $sFileName)
	If @error Then Return SetError(1,0,0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_LoadLibrary
; #FUNCTION# ====================================================================================================================
; Name...........: __BASS_LoadLibrary
; Author ........: Prog@ndy
; ===============================================================================================================================
Func __BASS_GetProcAddress($hModule,$sFunctionName)
	Local $aResult = DllCall("Kernel32.dll", "hwnd", "GetProcAddress","hwnd",$hModule, "str", $sFunctionName)
	If @error Then Return SetError(1,0,0)
	Return $aResult[0]
EndFunc   ;==>_WinAPI_LoadLibrary
; #FUNCTION# ====================================================================================================================
; Name...........: __BASS_LoadLibrary
; Author ........: Prog@ndy
; ===============================================================================================================================
Func __BASS_GetModuleHandle($sFileName)
	Local $aResult = DllCall("Kernel32.dll", "hwnd", "GetModuleHandleA", "str", $sFileName)
	If @error Then Return SetError(1,0,HWnd(0))
	Return $aResult[0]
EndFunc   ;==>_WinAPI_LoadLibrary
; #FUNCTION# ====================================================================================================================
; Name...........: __BASS_DLLSLOADED
; Author ........: Prog@ndy
; Return Values: Bass.dll loaded: return 1
;                Bassvb.dll loaded return 2
;                both loaded: return 3
;                none loaded: return 0
; ===============================================================================================================================
Func __BASS_DLLSLOADED()
	Local $bass = Number(__BASS_GetModuleHandle("BASS"))>0
	Local $basscb = Number(__BASS_GetModuleHandle("BASSCB"))>0
	Return $bass + ($basscb*2)
EndFunc

Global Const $hLibBassCB = __BASS_LoadLibrary("BassCB.dll")

Global Const $DownloadProc = __BASS_GetProcAddress($hLibBassCB,"DownloadProc@12")
Global Const $StreamProc = __BASS_GetProcAddress($hLibBassCB,"StreamProc@16")
Global Const $StreamProcWriteFile = __BASS_GetProcAddress($hLibBassCB,"StreamProcWriteFile@16")

#include <..\..\Bass.au3>
#include <..\..\BassConstants.au3>
;~ ProcessSetPriority(@AutoItExe, 4)

Global Const $EXIT_BASS_NOT_LOADED = -12345

;Open Bass.DLL.  Required for all function calls.
_BASS_STARTUP ("..\..\BASS.dll")
If __BASS_DLLSLOADED()=0 Then Exit $EXIT_BASS_NOT_LOADED

;Initalize bass.  Required for most functions.
_BASS_Init(0, -1, 44100, 0, "")

;Check if bass iniated.  If not, we cannot continue.
If @error Then
    MsgBox(0, "Error", "Could not initialize audio")
    Exit
EndIf

;Set the Stream URL to listen to
$file = "http://stream.transmissionfm.com:8000/breaks-high.mp3"
;~ $file = "http://ice-01.lagardere.cz/web-e2-top40"
MsgBox(0, '', "Stream is: " & $file)
;Create a stream from that URL.
Dim $MusicHandle = _BASS_StreamCreateURL($file,0,0,$DownloadProc,0)
;Check if we opened the URL correctly.
If @error Then
    MsgBox(0, "Error", "Could not load audio file" & @CR & "Error = " & @error)
    Exit
EndIf

;Iniate playback
_BASS_ChannelPlay($MusicHandle, 1)

;endless loop
While 1
;------------------------------------------------------------------------------------------
    Sleep(10);adjusting this to reduce AutoItExe crashs, 10 is optimal on my pc, i think
;------------------------------------------------------------------------------------------
WEnd


;Functions

Func OnAutoItExit()
;Free Resources
	If @exitCode=$EXIT_BASS_NOT_LOADED Then Exit
    MsgBox(0,"Exit",'"OnAutoItExit()" was called' & @CRLF & "Error Code: " & _BASS_ErrorGetCode())
    _BASS_Free()
EndFunc;==>OnAutoItExit


Func TestFunc($buffer, $length, $user)
;---------------------------------------------------------------------------
;!!! DO NOT PUT/CHANGE/REMOVE ANYTHING IN HERE OR IT WILL BE UNSTABLE !!!!
;---------------------------------------------------------------------------
EndFunc
