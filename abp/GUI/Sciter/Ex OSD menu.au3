#include <Sciter-UDF.au3>

_StStartup()
If @error Then MsgBox(0,"error","Error dllopen")
$ST = _StCreate(-1,-1,300,500)
WinSetOnTop ( $ST, "", 1)

$fi = FileRead(@scriptdir&'\osd.htm')
_StLoadHtml($ST,$fi)
_StWindowAttachEventHandler($ST,"_events",$HANDLE_KEY+$HANDLE_BEHAVIOR_EVENT)

While 1
	Sleep(50)
WEnd

Func _events($ev,$ad)
	If $ev = $HANDLE_BEHAVIOR_EVENT Then
		$bh = $ad[0]
		If $bh = $MENU_ITEM_ACTIVE Then
			ConsoleWrite("Item :"& _StGetAttributeByName($ad[1],"no") & " Active" & @CRLF)

		ElseIf $bh = $MENU_ITEM_CLICK Then
			ConsoleWrite("Click on Item :"& _StGetAttributeByName($ad[1],"no") & @CRLF )

		ElseIf $bh = $CONTEXT_MENU_REQUEST Then ; Right click for reload osd.htm (for testing change in html/css)
			$fi = FileRead(@scriptdir&'\osd.htm')
			_StLoadHtml($ST,$fi)
		EndIf

	ElseIf $ev = $HANDLE_KEY Then
		$KeyEvent = $ad[0]
		If $KeyEvent = $KEY_DOWN Then
			$key = $ad[2]
			If $key = 27 Then Exit ; exit on esc press
		EndIf
	EndIf

EndFunc

