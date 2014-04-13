#include <GUIConstantsEx.au3>

; MD5 UDF: http://www.autoitscript.com/forum/index.php?showtopic=10590

$iOptOld = Opt("GUIEventOptions",0)
Opt("GUIEventOptions", $iOptOld)

Global $__CaptchaCode_cCharacter[6], $c__CaptchaCode_Label[5], $c__CaptchaCode_Line[2], $a__CaptchaCode_Font[6]
Global $__CaptchaCode_Tries
_CaptchaCode(2)
Func _CaptchaCode($iNumOfTries)
    Local $sCaptchaCode

    $__CaptchaCode_Tries = 0

    $hWnd = GUICreate("       * ENTER CODE *", 175, 150, -1, -1, 0x00080000)
    $cBg = GUICtrlCreateLabel("", 10, 10, 150, 50)
    GUICtrlSetState($cBg, 128)
    GUICtrlSetBkColor($cBg, 0x000000)
    $cInput = GUICtrlCreateInput("", 10, 70, 150, 20)
    $cCheck = GUICtrlCreateButton("Check", 10, 95, 70)
    $cNew = GUICtrlCreateButton("New", 90, 95, 70)

    $sCaptchaCode = __CaptchaCode_Create()

    $cFg = GUICtrlCreateLabel("", 10, 10, 150, 50)
    GUICtrlSetBkColor($cFg, -2)

    GUISetState()
    While 1
        Switch GUIGetMsg()
        Case -3

        Case $cNew
            __CaptchaCode_Delete()
            $sCaptchaCode = __CaptchaCode_Create()
            GUICtrlSetData($cInput, "")

        Case $cCheck
            If $__CaptchaCode_Tries == $iNumOfTries - 1 Then
                __CaptchaCode_Delete()
                GUIDelete($hWnd)
                Return False
                ExitLoop
            Else

                If StringCompare(GUICtrlRead($cInput),$sCaptchaCode)=0 Then
                    __CaptchaCode_Delete()
                    GUIDelete($hWnd)
                    Return True
                    ExitLoop
                Else
                    $__CaptchaCode_Tries += 1
                    MsgBox(16, "* ERROR *", "Wrong Code!")
                    __CaptchaCode_Delete()
                    $sCaptchaCode = __CaptchaCode_Create()
                    GUICtrlSetData($cInput, "")
                EndIf
            EndIf

        EndSwitch

    WEnd
EndFunc

Func __CaptchaCode_Create()
    Local $sCaptcha = __CaptchaCode_Generate()
    Local $iX = Random(15, 25, 1)
    Local $iY = Random(15, 40, 1)

    $a__CaptchaCode_Font[0] = "Arial"
    $a__CaptchaCode_Font[1] = "Comic Sans"
    $a__CaptchaCode_Font[2] = "Lucida Console"
    $a__CaptchaCode_Font[3] = "Tahoma"
    $a__CaptchaCode_Font[4] = "Times New Roman"
    $a__CaptchaCode_Font[5] = "Verdana"

    $aSplit = StringSplit($sCaptcha, "")
    For $x = 0 To 5
        $__CaptchaCode_cCharacter[$x] = GUICtrlCreateLabel($aSplit[$x + 1], $iX, $iY)
        $iX += 20 + Random(1, 5, 1)
        $iY = Random(15, 40, 1)

        GUICtrlSetBkColor($__CaptchaCode_cCharacter[$x], -2)
        GUICtrlSetColor($__CaptchaCode_cCharacter[$x], Random(0x808080, 0xC0C0C0))

        $iNum = Random(1, 7, 1)
        Switch $iNum
        Case 1
            $iStyle = 2 ;2
        Case 2
            $iStyle = 4 ;4
        Case 3
            $iStyle = 8 ;8
        Case 4
            $iStyle = 2 + 4 ;6
        Case 5
            $iStyle = 4 + 8 ;12
        Case 6
            $iStyle = 2 + 8 ;10
        Case 7
            $iStyle = 2 + 4 + 8 ;16
        EndSwitch

        GUICtrlSetFont($__CaptchaCode_cCharacter[$x], 16, Random(350, 450, 1), $iStyle, $a__CaptchaCode_Font[Random(0, 5, 1)])

        Sleep(10)
    Next

    $iX = 15 + Random(1, 10, 1)
    $iY = 5 + Random(1, 10, 1)
    For $z = 0 To 4
        $c__CaptchaCode_Label[$z] = GUICtrlCreateLabel("", $iX, $iY, 1, 30)
        $iX += 25 + Random(1, 10, 1)
        $iY = 5 + Random(1, 30, 1)

        GUICtrlSetBkColor($c__CaptchaCode_Label[$z], Random(0x808080, 0xC0C0C0))
    Next

    $iX = 5 + Random(1, 25, 1)
    $iY = 20 + Random(1, 10, 1)
    For $b = 0 To 1
        $c__CaptchaCode_Line[$b] = GUICtrlCreateLabel("", $iX, $iY, 130, 1)
        $iX = 5 + Random(1, 10, 1)
        $iY += 10 + Random(1, 10, 1)

        GUICtrlSetBkColor($c__CaptchaCode_Line[$b], Random(0x808080, 0xC0C0C0))
    Next

    Return $sCaptcha
EndFunc

Func __CaptchaCode_Delete()
    For $y = 0 To 5
        GUICtrlDelete($__CaptchaCode_cCharacter[$y])
    Next

    For $a = 0 To 4
        GUICtrlDelete($c__CaptchaCode_Label[$a])
    Next

    For $c = 0 To 1
        GUICtrlDelete($c__CaptchaCode_Line[$c])
    Next
EndFunc

Func __CaptchaCode_Generate()
    Local $sCharacters = StringSplit("abcdefghijklmopqrstuvwxyzABCDFGHJKLMNPQRSTVWXYZ1234567890", "")
    Local $sCode = ""

    For $i = 1 To 6
        $sCode &= $sCharacters[Random(1, $sCharacters[0], 1)]
    Next

    Return $sCode
EndFunc