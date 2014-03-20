; ============================================================================================================================
;  File     : MemoryDllTest.au3
;  Purpose  : Test MemoryDll In Both x86 And X64 Mode
;  Author   : Ward
; ============================================================================================================================

#Include "MemoryDll.au3"

Main()

Func Main()
	If @AutoItX64 Then
		Local $InstallDir = RegRead("HKLM\SOFTWARE\Wow6432Node\AutoIt v3\AutoIt", "InstallDir")
		Local $DllPath = $InstallDir & "\AutoItX\AutoItX3_x64.dll"
	Else
		Local $InstallDir = RegRead("HKLM\SOFTWARE\AutoIt v3\AutoIt", "InstallDir")
		Local $DllPath = $InstallDir & "\AutoItX\AutoItX3.dll"
	EndIf
	If Not FileExists($DllPath) Then
		MsgBox(16, "Error", "Cannot Find AutoItX DLL !")
		Return
	EndIf

	Local $DllFile = FileOpen($DllPath, 16)
	Local $DllBin = FileRead($DllFile)
	FileClose($DllFile)

	Local $DllHandle = MemoryDllOpen($DllBin)

	MemoryDllCall($DllHandle, "none", "AU3_ToolTip", "wstr", "Hello, world!" & @CRLF & "AutoIt is best, MemoryDll.au3 is easy and fun", "long", @DesktopWidth / 3, "long", @DesktopHeight / 3)
	MemoryDllCall($DllHandle, "none", "AU3_Sleep", "long", 5000)
	MemoryDllCall($DllHandle, "none", "AU3_ToolTip", "wstr", "", "long", 0, "long", 0)

	MemoryDllClose($DllHandle)
EndFunc
