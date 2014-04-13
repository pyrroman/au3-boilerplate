#include <windowsconstants.au3>
#include "../AutoitObject.au3"
#include "oLinkedList.au3"

#AutoIt3Wrapper_UseX64=n

#Region Square class
Func Square($iX, $iY)
	Local $self = _AutoItObject_Create()
	_AutoItObject_AddProperty($self, "x", $ELSCOPE_READONLY, $iX)
	_AutoItObject_AddProperty($self, "y", $ELSCOPE_READONLY, $iY)
	_AutoItObject_AddProperty($self, "owner")
	Return $self
EndFunc   ;==>Square
#EndRegion Square class


#Region Player classes
Func Player($symbol)
	$self = _AutoItObject_Create()
	_AutoItObject_AddProperty($self, "symbol", $ELSCOPE_READONLY, $symbol)
	_AutoItObject_AddProperty($self, "next_player")
	_AutoItObject_AddMethod($self, "best_move", "Player_best_move")
	Return $self
EndFunc   ;==>Player

Func Player_best_move($self, $game) ; oops random
	Local $aRet[2] = [-1, -1]

	Do
		$aRet[0] = Random(0,2,1)
		$aRet[1] = Random(0,2,1)
	Until Not IsObj($game.get_square($aRet[0],$aRet[1]).owner)


	Return $aRet
EndFunc   ;==>Player_best_move





#EndRegion Player classes



Func Game()
	Global $WNDPROC_Callback = DllCallbackRegister("WNDPROC", "lresult", "hwnd;uint;wparam;lparam")


	Local $self = _AutoItObject_Create()
	_AutoItObject_AddProperty($self, "board", $ELSCOPE_READONLY, LinkedList())
	$p1 = Player("X")
	$p1.next_player = Player("O")
	$p1.next_player.next_player = $p1
	_AutoItObject_AddProperty($self, "active_player", $ELSCOPE_PRIVATE, $p1)
	_AutoItObject_AddMethod($self, "onclick", "Game_onclick")
	_AutoItObject_AddMethod($self, "win_condition", "Game_win_condition")
	_AutoItObject_AddMethod($self, "check_win", "Game_check_win", True)
	_AutoItObject_AddMethod($self, "get_square", "Game_get_square")
	_AutoItObject_AddMethod($self, "match_three", "Game_match_three", True)
	_AutoItObject_AddMethod($self, "reset", "Game_reset", True)

	For $x = 0 To 2
		For $y = 0 To 2
			$self.board.add(Square($x, $y))
		Next
	Next



	Return $self
EndFunc   ;==>Game

Func Game_match_three($self, $o1, $o2, $o3)
	Return ($o1 = $o2 And $o2 = $o3)
EndFunc   ;==>Game_match_three


Func Game_reset($self, $controls)
	For $square In $self.squares
		$square.owner = 0
		GUICtrlSetData($controls[$square.x][$square.y], "")
	Next

EndFunc   ;==>Game_reset



Func Game_win_condition($self)
	For $row = 0 To 2
		If Not IsObj($self.get_square(0, $row).owner) Then ContinueLoop
		If $self.match_three($self.get_square(0, $row).owner, $self.get_square(1, $row).owner, $self.get_square(2, $row).owner) Then Return $self.get_square(0, $row).owner
	Next
	For $col = 0 To 2
		If Not IsObj($self.get_square($col, 0).owner) Then ContinueLoop
		If $self.match_three($self.get_square($col, 0).owner, $self.get_square($col, 1).owner, $self.get_square($col, 2).owner) Then Return $self.get_square($col, 0).owner
	Next

	If IsObj($self.get_square(0, 0).owner) And $self.match_three($self.get_square(0, 0).owner, $self.get_square(1, 1).owner, $self.get_square(2, 2).owner) Then Return $self.get_square(0, 0).owner

	If IsObj($self.get_square(2, 0).owner) And $self.match_three($self.get_square(2, 0).owner, $self.get_square(1, 1).owner, $self.get_square(0, 2).owner) Then Return $self.get_square(2, 0).owner

	Return 0
EndFunc   ;==>Game_win_condition


Func Game_check_win($self, $controls)
	$winner = $self.win_condition
	If IsObj($winner) Then
		MsgBox(64, "Game Finished!", $winner.symbol & " won!")
		For $square In $self.board
			$square.owner = 0
			GUICtrlSetData($controls[$square.x][$square.y], "")
		Next
	EndIf
EndFunc   ;==>Game_check_win



Func Game_get_square($self, $x, $y)
	Return $self.board.at($x * Sqrt($self.board.size) + $y)
EndFunc   ;==>Game_get_square


; When user clicks on button
Func Game_onclick($self, $controls, $x, $y)

	$clicked_square = $self.get_square($x, $y)

	; Player click
	If IsObj($clicked_square.owner) Then Return
	$clicked_square.owner = $self.active_player
	GUICtrlSetData($controls[$x][$y], $self.active_player.symbol)
	$self.check_win($controls)

	; Bot move
	$pos = $self.active_player.next_player.best_move($self)
	$self.get_square($pos[0], $pos[1] ).owner = $self.active_player.next_player
	GUICtrlSetData($controls[$pos[0]][$pos[1]], $self.active_player.next_player.symbol)
	$self.check_win($controls)




EndFunc   ;==>Game_onclick



_AutoItObject_Startup()
$game = Game()

$hWnd = GUICreate("Tic Tac Toe", 40 * 3 + 100, 40 * 3 + 100)
GUISetState()

; Create buttons
Local $Buttons[3][3]
For $i = 0 To 2
	For $j = 0 To 2
		$Buttons[$i][$j] = GUICtrlCreateButton("", 50 + $i * 40, 50 + $j * 40, 40, 40)
	Next
Next


; Dispatch button clicks to game
Do
	$msg = GUIGetMsg()
	For $i = 0 To 2
		For $j = 0 To 2
			If $msg = $Buttons[$i][$j] Then
				$game.onclick($Buttons, $i, $j)
				ExitLoop 2
			EndIf
		Next
	Next
Until $msg = -3
