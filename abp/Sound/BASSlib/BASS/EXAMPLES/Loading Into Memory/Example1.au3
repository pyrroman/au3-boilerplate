;coded by UEZ 2010
#include <WinAPI.au3>
#include <..\..\BASS.au3>

Do
    $file = FileOpenDialog("Select audio file to load", @ScriptDir, "Audio (*.mp3;*.ogg; *.wma)")
    If @error Then
    $msg = MsgBox(20, "Error", "Please select an audio file!")
    If $msg = 7 Then
    Exit
    Else
    SetError(1)
    EndIf
    EndIf
Until Not @error

HotKeySet("{ESC}", "_Close")

$file_size = FileGetSize($file)
If $file_size Then
    $tBuffer = DllStructCreate("byte[" & $file_size & "]")
    $pMem = DllStructGetPtr($tBuffer)
    Global $nBytes
    $hFile =_WinAPI_CreateFile($file, 2, 2)
    _WinAPI_SetFilePointer($hFile, 3)
    _WinAPI_ReadFile($hFile, $pMem, $file_size, $nBytes)
    _WinAPI_CloseHandle($hFile)
    $bass_dll = _BASS_Startup("..\..\BASS.dll")
    _BASS_Init($BASS_DEVICE_CPSPEAKERS)
    $hMusic = _BASS_StreamCreateFile(True, $pMem, 0, $file_size, 0)
    $song_length = _BASS_ChannelGetLength($hMusic, $BASS_POS_BYTE)
    _BASS_ChannelPlay($hMusic, 1)
    While _BASS_ChannelGetPosition($hMusic, $BASS_POS_BYTE) <= _BASS_ChannelGetLength($hMusic, $BASS_POS_BYTE)
        Sleep(250)
    WEnd
    _Close()
EndIf

Func _CLose()
    _BASS_ChannelStop($hMusic)
    _BASS_StreamFree($hMusic)
    DllClose(@ScriptDir & "\BASS.dll")
    Exit
EndFunc
