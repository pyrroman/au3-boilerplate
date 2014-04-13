#AutoIt3Wrapper_Au3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5 -w 6

;.......script written by trancexx (trancexx at yahoo dot com)

#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "GIFAnimation.au3"

Opt("GUICloseOnESC", 1); ESC to exit
Opt("MustDeclareVars", 1)

Global $sTempFolder = @TempDir & "\GIFS"
DirCreate($sTempFolder)

;~ Global $sFile = $sTempFolder & "\Dance.gif"
global $sFile=@DesktopDir&"\294.gif"
If Not FileExists($sFile) Then
    TrayTip("GIF Download", "Please wait...", 0)
    InetGet("http://i241.photobucket.com/albums/ff141/trancexx_bucket/Dance.gif", $sFile)
    TrayTip("", "", 0)
EndIf

If Not FileExists($sFile) Then
    MsgBox(262192, "Download", "Download failed!")
    Exit
EndIf

; Get dimension of the GIF
Global $aGIFDimension = _GIF_GetDimension($sFile)
; Make GUI
Global $hGui = GUICreate("GIF Animation", $aGIFDimension[0], $aGIFDimension[1], -1, -1, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_TOPMOST))

; GIF job
Global $hGIF = _GUICtrlCreateGIF($sFile, "", 0, 0)
GUICtrlSetTip(-1, "ESC to exit")

; Make GUI transparent
GUISetBkColor(345) ; some random color
_WinAPI_SetLayeredWindowAttributes($hGui, 345, 255) ; making the GUI transparent
_WinAPI_SetParent($hGui, 0)

; Show it
GUISetState()

; Loop till end
While 1
    If GUIGetMsg() = - 3 Then Exit
WEnd