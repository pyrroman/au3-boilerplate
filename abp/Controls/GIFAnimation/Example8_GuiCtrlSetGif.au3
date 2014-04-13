#AutoIt3Wrapper_Au3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5 -w 6

;.......script written by trancexx (trancexx at yahoo dot com)

#include <WindowsConstants.au3>
#include "GIFAnimation.au3"

Opt("GUICloseOnESC", 1); ESC to exit
Opt("MustDeclareVars", 1)

Global $sFile = "http://i241.photobucket.com/albums/ff141/trancexx_bucket/SOCR_HT.gif"

Global $hGui = GUICreate("GUICtrlSetGIF function", 500, 500)

Global $hGIF = GUICtrlCreatePic("", 50, 50, 400, 400)

TrayTip("Transfering GIF data (" & InetGetSize($sFile) & " Bytes) from photobucket.com", "Please wait...", 0)

; GIF
_GUICtrlSetGIF($hGIF, InetRead($sFile, 16), Default, 1)
GUICtrlSetTip($hGIF, "GIF directly from server")

TrayTip("", "", 0)


GUISetState()


While 1
    Switch GUIGetMsg()
        Case - 3
            Exit
    EndSwitch
WEnd

