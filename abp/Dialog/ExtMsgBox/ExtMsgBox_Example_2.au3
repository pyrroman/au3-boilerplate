#include "ExtMsgBox.au3"

; Start with no tabs to show it works
$sMsg = "No tabs:" & @CR & _
		"        An artificially extended pretty long Line 1 to reach the wrap limit of the EMB" & @CR & _
		"        Line 2"
_ExtMsgBox(0, "OK", "No Tab", $sMsg)

; Now add tabs and show it does not
$sMsg = "Non-exp tabs: (Note Line 2 missing)" & @LF & _
		@TAB & "An artificially extended pretty long Line 1 to reach the wrap limit of the EMB" & @LF & _
		@TAB & "Line 2"
$aRet = _StringSize($sMsg)
_ExtMsgBox(0, "OK", "Non-Exp Tab", $sMsg)

; Allow tabs to be expanded and it works again!
_ExtMsgBoxSet(2 + 8)
$sMsg = "Exp tabs: (Note Line 2 now shown)" & @CRLF & _
		@TAB & "An artificially extended pretty long Line 1 to reach the wrap limit of the EMB" & @CRLF & _
		@TAB & "Line 2"
$aRet = _StringSize($sMsg, Default, Default, 1)
_ExtMsgBox(0, "OK", "Exp Tab", $sMsg)

; A very complex tabbed message
$sMsg_2 = "|" & @TAB & "|" & @TAB & "|" & @TAB & "|" & @TAB & "|" & @CRLF & _
         @TAB & "1"        & @TAB & "1"        & @TAB & "1" & @CRLF & _
         @TAB & " 2"       & @TAB & "22"       & @TAB & "2" & @CRLF & _
         @TAB & "  3"      & @TAB & "333"      & @TAB & "3" & @CRLF & _
         @TAB & "   4"     & @TAB & "4444"     & @TAB & "4" & @CRLF & _
         @TAB & "    5"    & @TAB & "55555"    & @TAB & "5" & @CRLF & _
         @TAB & "     6"   & @TAB & "666666"   & @TAB & "6" & @CRLF & _
         @TAB & "      7"  & @TAB & "7777777"  & @TAB & "7" & @CRLF & _
         @TAB & "       8" & @TAB & "88888888" & @TAB & "8"

; No tab expansion with proportional font
_ExtMsgBoxSet(Default)
_ExtMsgBox(0, "OK", "Non-Exp Tab", $sMsg_2)
; Tab expansion with proportional font
_ExtMsgBoxSet(2 + 8)
_ExtMsgBox(0, "OK", "Exp Tab", $sMsg_2)
; No tab expansion with mono font
_ExtMsgBoxSet(0, 0, Default, Default, Default, "Courier New")
_ExtMsgBox(0, "OK", "Non-Exp Tab", $sMsg_2)
; Tab expansion with mono font
_ExtMsgBoxSet(2 + 8)
_ExtMsgBox(0, "OK", "Exp Tab", $sMsg_2)
