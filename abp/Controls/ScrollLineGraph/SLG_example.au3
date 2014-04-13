#include <StaticConstants.au3>
#include "../SLG.au3"
Opt('GuiOnEventMode', 1)
Const $cBlue = 0xFF00ACFF, $cGreen = 0xFF00FF00, $cPink = 0xFFF004DE, $cYellow = 0xFFFFFF00
Const $cGray = 0xFFADADAD, $cRed = 0xFFFF0000, $cPurple = 0xFF8000FF, $cOrange = 0xFFFF8000
Const $Pi = ACos(-1), $4Pi = $Pi / 4

$GUI = GUICreate("GDI+ Scrolling Line Graph", 628, 297, -1, -1, -1, $WS_EX_TOPMOST)
GUISetOnEvent(-3, '_Exit')
$Label1 = GUICtrlCreateLabel("Graph 1", 66, 36, 192, 53, BitOR($SS_CENTER, $SS_CENTERIMAGE))
GUICtrlSetFont(-1, 24, 400, 0, "MS Sans Serif")
$Label2 = GUICtrlCreateLabel("Graph 2", 372, 36, 192, 53, BitOR($SS_CENTER, $SS_CENTERIMAGE))
GUICtrlSetFont(-1, 24, 400, 0, "MS Sans Serif")
GUISetState()

$Increments = 85
$Graph1 = _SLG_CreateGraph($GUI, 18, 114, 283, 157, -1.01, 1.01, $Increments, $cPink, 2, -1, False)
$G1Line2 = _SLG_AddLine($Graph1, $cGreen)
$G1Line3 = _SLG_AddLine($Graph1, $cBlue)

$Graph2 = _SLG_CreateGraph($GUI, 324, 114, 283, 157, -1.01, 1.01, $Increments, $cBlue)
_SLG_SetGridLineColor($Graph2, 0xFF5C5C5C)
$G2Line2 = _SLG_AddLine($Graph2, $cGreen)
$G2Line3 = _SLG_AddLine($Graph2, $cRed)

While 1
    For $i = 0 To (2 * $Pi) Step 0.1

        _SLG_SetLineValue($Graph1, Sin($i))
        _SLG_SetLineValue($Graph2, Sin($i))

        For $Line = $G1Line2 To $G1Line3
            $y = Sin($i + ($4Pi * ($Line - 1)))
            _SLG_SetLineValue($Graph1, $y, $Line)
        Next
        For $Line = $G2Line2 To $G2Line3
            $y = Sin($i + ($4Pi * ($Line - 1)))
            _SLG_SetLineValue($Graph2, $y, $Line)
        Next

        _SLG_UpdateGraph($Graph1)
        _SLG_UpdateGraph($Graph2)
        Sleep(1)
    Next
WEnd

Func _Exit()
    Exit
EndFunc   ;==>_Exit