#include<WinAPI.au3>
#include<Memory.au3>
#include<BASS.au3>

Global $ahOGGHandle[2] = [0,0] ; global Variables

$sOGGFile = "C:\test.ogg"
; Load at the beginning:
Local $iSize = FileGetSize($sOGGFile)
If $iSize Then
    Local $ahOGGHandle[0] = _MemGlobalAlloc($iSize, $GPTR)
    $hFile = _WinAPI_CreateFile($sOGGFile, 2, 2)
    Local $iRead
    _WinAPI_ReadFile($hFile, $ahOGGHandle[0], $iSize, $iRead)
    If $iRead < $iSize Then
        _MemGlobalFree($ahOGGHandle[0])
        $ahOGGHandle[0] = 0
    EndIf
    _WinAPI_CloseHandle($hFile)
    ; create Stream:
    If $ahOGGHandle[0] Then $ahOGGHandle[1] = _BASS_StreamCreateFile(True, $ahOGGHandle[0], 0, $iSize, 0)
EndIf

; now play & stop Music,
_BASS_ChannelPlay($ahOGGHandle[1], 1)
Sleep(1000)
_BASS_ChannelStop($ahOGGHandle[1])

; free on exit
If $ahOGGHandle[1] Then _BASS_StreamFree($ahOGGHandle[1])
If $ahOGGHandle[0] Then _MemGlobalFree($ahOGGHandle[0])
