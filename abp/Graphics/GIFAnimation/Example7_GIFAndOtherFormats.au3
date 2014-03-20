#AutoIt3Wrapper_Au3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5 -w 6

;.......script written by trancexx (trancexx at yahoo dot com)

#include <WindowsConstants.au3>
#include "GIFAnimation.au3"

Opt("GUICloseOnESC", 1); ESC to exit
Opt("MustDeclareVars", 1)


Global $hGui = GUICreate("Different formats (PE resources and binary)", 700, 500)

TrayTip("Transfering data from photobucket.com", "Please wait...", 0)

; Hot girl PNG
Global $hGIF = _GUICtrlCreateGIF(InetRead("http://i241.photobucket.com/albums/ff141/trancexx_bucket/hot-1.png", 16), "", 300, 130)
GUICtrlSetTip($hGIF, "PNG directly from server")

; TT font BMP
Global $hGIF1 = _GUICtrlCreateGIF("user32.dll", "2;36", 50, 200, 50, 170)
GUICtrlSetTip($hGIF1, "Resized BMP from resource")

; Microsoft JPEG
Global $hGIF2 = _GUICtrlCreateGIF("userenv.dll", "JPEG;1", 200, 60)
GUICtrlSetTip($hGIF2, "JPG from resource")

; message (it's safe to... blah blah) BMP
Global $hGIF3 = _GUICtrlCreateGIF("ntoskrnl.exe", "2;3", 330, 10)
GUICtrlSetTip($hGIF3, "BMP from resource")

; win7 BMP
Global $hGIF4 = _GUICtrlCreateGIF("shell32.dll", "2;51209", 5, 10)
GUICtrlSetTip($hGIF4, "BMP from resource")

; Star GIF
Global $hGIF5 = _GUICtrlCreateGIF(InetRead("http://i241.photobucket.com/albums/ff141/trancexx_bucket/star.gif", 16), "", 100, 330)
GUICtrlSetTip($hGIF5, "GIF directly from server")

; That two kids GIF
Global $hGIF6 = _GUICtrlCreateGIF(InetRead("http://i241.photobucket.com/albums/ff141/trancexx_bucket/kids.gif", 16), "", 30, 430)
GUICtrlSetTip($hGIF6, "GIF directly from server")


TrayTip("", "", 0)


GUISetState()


While 1
    Switch GUIGetMsg()
        Case - 3
            Exit
    EndSwitch
WEnd

