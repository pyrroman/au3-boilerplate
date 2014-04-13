#AutoIt3Wrapper_Au3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5 -w 6

;.......script written by trancexx (trancexx at yahoo dot com)

#include <WindowsConstants.au3>
#include "GIFAnimation.au3"

Opt("MustDeclareVars", 1)

Global $sTempFolder = @TempDir & "\GIFS"
TrayTip("GIF Download", "Please wait while gifs are downloaded and processed", 0)
DirCreate($sTempFolder)

Global $hGui = GUICreate("GIF Animations", 670, 520, -1, -1, $WS_OVERLAPPEDWINDOW)


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Global $sFile = $sTempFolder & "\smiley-computer012.gif"
If Not FileExists($sFile) Then InetGet("http://www.freesmileys.org/smileys/smiley-computer012.gif", $sFile)

Global $hGIF = _GUICtrlCreateGIF($sFile, "", 10, 10)
GUICtrlSetTip($hGIF, "Hit him")
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Global $sFile1 = $sTempFolder & "\heart.gif"
If Not FileExists($sFile1) Then InetGet("http://i54.photobucket.com/albums/g107/onlinegemini/heart.gif", $sFile1)

Global $hGIF1 = _GUICtrlCreateGIF($sFile1, "", 5, 210, Default, Default, 5)
GUICtrlSetTip($hGIF1, "Playing hearts with fuzzy effect applied")
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Global $sFile2 = $sTempFolder & "\063.gif"
If Not FileExists($sFile2) Then InetGet("http://i241.photobucket.com/albums/ff141/trancexx_bucket/sexy_50.gif", $sFile2)

Global $hGIF2 = _GUICtrlCreateGIF($sFile2, "", 307, 10, 280, 100)
GUICtrlSetTip($hGIF2, "Sexy")
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Global $sFile3 = $sTempFolder & "\hekla.gif"
If Not FileExists($sFile3) Then InetGet("http://i241.photobucket.com/albums/ff141/trancexx_bucket/hekla.gif", $sFile3)

Global $hGIF3 = _GUICtrlCreateGIF($sFile3, "", 49, 80)
GUICtrlSetTip($hGIF3, "What?")
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Global $sFile4 = $sTempFolder & "\36.gif"
If Not FileExists($sFile4) Then InetGet("http://i241.photobucket.com/albums/ff141/trancexx_bucket/36.gif", $sFile4)

Global $hGIF4 = _GUICtrlCreateGIF($sFile4, "", 170, 100)
GUICtrlSetTip($hGIF4, "Bug")
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Global $sFile5 = $sTempFolder & "\angry.gif"
If Not FileExists($sFile5) Then InetGet("http://i241.photobucket.com/albums/ff141/trancexx_bucket/angry.gif", $sFile5)

Global $hGIF5 = _GUICtrlCreateGIF($sFile5, "", 590, 470, -1, -1, 1)
GUICtrlSetTip($hGIF5, "Angry kitty")
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Global $sFile6 = $sTempFolder & "\marvin.gif"
If Not FileExists($sFile6) Then InetGet("http://i241.photobucket.com/albums/ff141/trancexx_bucket/marvin.gif", $sFile6)

Global $hGIF6 = _GUICtrlCreateGIF($sFile6, "", 520, 380)
GUICtrlSetTip($hGIF6, "Marvin")
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Global $sFile7 = $sTempFolder & "\loading.gif"
If Not FileExists($sFile7) Then InetGet("http://i241.photobucket.com/albums/ff141/trancexx_bucket/loading-1.gif", $sFile7)

Global $hGIF7 = _GUICtrlCreateGIF($sFile7, "", 350, 250)
GUICtrlSetTip($hGIF7, "loading stick")
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Global $sFile8 = $sTempFolder & "\loading2.gif"
If Not FileExists($sFile8) Then InetGet("http://i241.photobucket.com/albums/ff141/trancexx_bucket/loading-2.gif", $sFile8)

Global $hGIF8 = _GUICtrlCreateGIF($sFile8, "", 350, 390)
GUICtrlSetTip($hGIF8, "loading")
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Global $hGIF9 = _GUICtrlCreateGIF(InetRead("http://i241.photobucket.com/albums/ff141/trancexx_bucket/Loading.gif"), "", 470, 150, Default, Default, 1)
GUICtrlSetTip($hGIF9, "loading transparent")
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Global $hButton = GUICtrlCreateButton("MsgBox", 370, 490, 100, 25)
GUICtrlSetResizing($hButton, 802)

TrayTip("", "", 0)

GUIRegisterMsg(15, "_ValidateGIFs"); WM_PAINT

GUISetState()
Global $aSize, $aDimension

While 1
	Switch GUIGetMsg()
		Case -3
			Exit
		Case $hButton
			MsgBox(64, "Some title", "Just to see is the gifs are blocked by this and vice versa.", 0, $hGui)
		Case $hGIF2
			If $hGIF2 Then
				$aSize = _GIF_GetSize($hGIF2)
				$aDimension = _GIF_GetDimension($sFile2)
				MsgBox(64, "Hey", "Sexy GIF" & @CRLF & _
						"Control size is: " & $aSize[0] & " x " & $aSize[1] & @CRLF & _
						"GIF size is: " & $aDimension[0] & " x " & $aDimension[1], 0, $hGui)
			EndIf
	EndSwitch
WEnd


Func _ValidateGIFs($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	_GIF_ValidateGIF($hGIF)
	_GIF_ValidateGIF($hGIF1)
	_GIF_ValidateGIF($hGIF2)
	_GIF_ValidateGIF($hGIF3)
	_GIF_ValidateGIF($hGIF4)
	_GIF_ValidateGIF($hGIF5)
	_GIF_ValidateGIF($hGIF6)
	_GIF_ValidateGIF($hGIF7)
	_GIF_ValidateGIF($hGIF8)
	_GIF_ValidateGIF($hGIF9)
EndFunc   ;==>_ValidateGIFs