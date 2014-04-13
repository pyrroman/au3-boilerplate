#include-once

; Get the installation of AutoIt. An improved version of _GetAutoItInstall.
; Author: guiness
Func _GetAutoItInstallEx()
    Local $aWow6432Node[2] = ['', 'Wow6432Node\'], $aFiles[4] = [3, @ProgramFilesDir, EnvGet("PROGRAMFILES"), EnvGet("PROGRAMFILES(X86)")]
    Local $sFilePath = RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\' & $aWow6432Node[@AutoItX64] & 'AutoIt v3\AutoIt\', 'InstallDir')
    If @error Then
        For $A = 1 To $aFiles[0]
            $aFiles[$A] &= '\AutoIt'
            If FileExists($aFiles[$A]) Then
                Return $aFiles[$A]
            EndIf
        Next
        Return SetError(1, 0, '')
    Else
        Return $sFilePath
    EndIf
EndFunc   ;==>_GetAutoItInstallEx