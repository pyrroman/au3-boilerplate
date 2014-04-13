#AutoIt3Wrapper_Au3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5 -w 6

;.......script written by trancexx (trancexx at yahoo dot com)

Opt("MustDeclareVars", 1)
Opt("GUICloseOnESC", 1); ESC to exit

; Include GIF engine
#include "GIFAnimation.au3"

; Get file
Global $sTempFolder = @TempDir & "\GIFS"
DirCreate($sTempFolder)
Global $sFile = $sTempFolder & "\Loading....gif"
If Not FileExists($sFile) Then
    TrayTip("GIF Download", "Please wait...", 0)
    InetGet("http://i241.photobucket.com/albums/ff141/trancexx_bucket/Loading.gif", $sFile)
    TrayTip("", "", 0)
EndIf

; Create GUI
Global $hGui = GUICreate("GIF Animations", @DesktopWidth, @DesktopHeight, 0, 0, 0x80000000);$WS_POPUP

; Make it white
GUISetBkColor(0xFFFFFF)

; GIF job
Global $hGIF = _GUICtrlCreateGIF($sFile, "", (@DesktopWidth - 105) / 2, (@DesktopHeight - 70) / 2, -1, -1, 1) ; Using forced rendering style for this particular gif to get "better" rendering


Global $hLabel = GUICtrlCreateLabel("ESC to exit Splash", (@DesktopWidth - 470) / 2, (@DesktopHeight - 200) / 2, 470, 80)
GUICtrlSetFont($hLabel, 40, 800, -1, "Arial", 5)
GUICtrlSetColor($hLabel, 0xB9B9B9)

; Set transparency
WinSetTrans($hGui, 0, 200)

; Show GUI
GUISetState()



; Loop and wait for/till exit
While 1
    If GUIGetMsg() = -3 Then ExitLoop
WEnd

; To clean at some point in a real situation
_GIF_DeleteGIF($hGIF)
