#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6


#include "AutoitObject.au3"

Global $oError = ObjEvent("AutoIt.Error", "_ErrFunc")
Func _ErrFunc()
    ConsoleWrite("! COM Error !  Number: 0x" & Hex($oError.number, 8) & "   ScriptLine: " & $oError.scriptline & " - " & $oError.windescription & @CRLF)
EndFunc   ;==>_ErrFunc

_AutoItObject_StartUp()

; Define IShellDispatch vTable methods
Global $tagIShellDispatch = $ltagIDispatch & _
        "Application;" & _
        "Parent;" & _
        "NameSpace;" & _
        "BrowseForFolder;" & _
        "Windows;" & _
        "Open;" & _
        "Explore;" & _
        "MinimizeAll;" & _
        "UndoMinimizeAll;" & _
        "FileRun;" & _
        "CascadeWindows;" & _
        "TileVertically;" & _
        "TileHorizontally;" & _
        "ShutdownWindows;" & _
        "Suspend;" & _
        "EjectPC;" & _
        "SetTime;" & _
        "TrayProperties;" & _
        "Help;" & _
        "FindFiles;" & _
        "FindComputer;" & _
        "RefreshMenu;" & _
        "ControlPanelItem;" & _ ; IShellDispatch
        "IsRestricted;" & _
        "ShellExecute;" & _
        "FindPrinter;" & _
        "GetSystemInformation;" & _
        "ServiceStart;" & _
        "ServiceStop;" & _
        "IsServiceRunning;" & _
        "CanStartStopService;" & _
        "ShowBrowserBar;" & _ ; IShellDispatch2
        "AddToRecent;" & _ ; IShellDispatch3
        "WindowsSecurity;" & _
        "ToggleDesktop;" & _
        "ExplorerPolicy;" & _
        "GetSetting;" ; IShellDispatch4

Global $oShellWrapped = _AutoItObject_ObjCreate("Shell.Application", Default, $tagIShellDispatch)
ConsoleWrite("IsObj($oShellWrapped) = " & IsObj($oShellWrapped) & @CRLF)

;~ $oShellWrapped.AddRef("dword")

;~ $oShellWrapped.MinimizeAll("long")
;~ Sleep(2000)
;~ $oShellWrapped.UndoMinimizeAll("long")
;~ $oShellWrapped.FileRun("long")

; Or maybe this:
;~ $oShellWrapped.Open("long", "variant", 36) ; ShellSpecialFolderConstants: ssfWINDOWS = 36


Global $aCall

$aCall = $oShellWrapped.GetSystemInformation("hresult", "wstr", "ProcessorSpeed", "variant*", 0)

ConsoleWrite(">ProcessorSpeed is " & $aCall[2] & " MHz" & @CRLF)

$aCall = $oShellWrapped.GetSystemInformation("hresult", "wstr", "PhysicalMemoryInstalled", "variant*", 0)
ConsoleWrite(">PhysicalMemoryInstalled is " & $aCall[2] & " Bytes" & @CRLF)


Global $hGUI = Number(GUICreate("Parent window"))
GUISetState()

; Byref (last parameter):
; iOptions param is BIF_EDITBOX
$aCall = $oShellWrapped.BrowseForFolder("long", "hwnd", $hGUI, "wstr", "Some text here.", "dword", 0x00000010, "variant", @AppDataDir, "idispatch*", 0)

Global $oFolder = $aCall[5]
;Global $oFolder = _AutoItObject_PtrToIDispatch($aCall[5]) ; if last parameter is ..."ptr*", 0...
If IsObj($oFolder) Then ConsoleWrite("!Selected folder: " & $oFolder.Self.Path & @CRLF)
;...