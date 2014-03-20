#AutoIt3Wrapper_Au3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5 -w 6

;.......script written by trancexx (trancexx at yahoo dot com)

#include <WindowsConstants.au3>
#include "GIFAnimation.au3"

Opt("GUICloseOnESC", 1); ESC to exit
Opt("MustDeclareVars", 1)

Global $sTempFolder = @TempDir & "\GIFS"
DirCreate($sTempFolder)
Global $sFile = $sTempFolder & "\TheRingGirl.gif"
If Not FileExists($sFile) Then
	TrayTip("GIF Download", "Please wait...", 0)
	InetGet("http://i241.photobucket.com/albums/ff141/trancexx_bucket/TheRingGirl.gif", $sFile)
	TrayTip("", "", 0)
EndIf

Global $aGIFDimension = _GIF_GetDimension($sFile)

Global $hGui = GUICreate("GIF Animation", 4 * $aGIFDimension[0], 4 * $aGIFDimension[1], -1, -1, $WS_POPUP, $WS_EX_TOPMOST)


Global $hGIF = _GUICtrlCreateGIF($sFile, "", 10, 10, 4 * $aGIFDimension[0], 4 * $aGIFDimension[1])
GUICtrlSetTip($hGIF, "I love you mommy...")

GUIRegisterMsg(15, "_Refresh"); WM_PAINT

GUICtrlSetPos($hGIF, 0, 0)

GUISetState()



While 1
	Switch GUIGetMsg()
		Case -3
			Exit
	EndSwitch
WEnd



Func _Refresh($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	_GIF_RefreshGIF($hGIF)
EndFunc   ;==>_Refresh