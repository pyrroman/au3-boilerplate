; -----------------------------------------------------------------------------
; Hashes Machine Code UDF
; Purpose: Provide A Warp To All Machine Code Hash UDF
; Author: Ward
; -----------------------------------------------------------------------------

#Include-once

Global Enum $_INDEX_HASH_SIZE, $_INDEX_CONTEXT_SIZE, $_INDEX_HASH_NAME, $_INDEX_CODE_NAME, $_TYPE_SIZE

Func _HashInit($Type)
	If UBound($Type) <> $_TYPE_SIZE Then Return SetError(1, 0, 0)

	If Not IsDllStruct(Eval($Type[$_INDEX_CODE_NAME] & 'CodeBuffer')) Then Call($Type[$_INDEX_CODE_NAME] & 'Startup')
	Local $CodeBuffer = Eval($Type[$_INDEX_CODE_NAME] & 'CodeBuffer')

	Local $Context = DllStructCreate("dword[" & $Type[$_INDEX_CONTEXT_SIZE] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + (Eval($Type[$_INDEX_HASH_NAME] & 'InitOffset')), _
													"ptr", DllStructGetPtr($Context), _
													"int", 0, _
													"int", 0, _
													"int", 0)

	Local $State[2] = [$Type, $Context]
	Return $State
EndFunc

Func _HashInput(ByRef $State, $Data)
	If UBound($State) <> 2 Then Return SetError(1, 0, 0)
	Local $Type = $State[0]
	Local $Context = $State[1]
	If Not IsDllStruct($Context) Then Return SetError(2, 0, 0)

	If Not IsDllStruct(Eval($Type[$_INDEX_CODE_NAME] & 'CodeBuffer')) Then Call($Type[$_INDEX_CODE_NAME] & 'Startup')
	Local $CodeBuffer = Eval($Type[$_INDEX_CODE_NAME] & 'CodeBuffer')

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + (Eval($Type[$_INDEX_HASH_NAME] & 'InputOffset')), _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"int", 0)
EndFunc

Func _HashResult(ByRef $State)
	If UBound($State) <> 2 Then Return SetError(1, 0, 0)
	Local $Type = $State[0]
	Local $Context = $State[1]
	If Not IsDllStruct($Context) Then Return SetError(2, 0, 0)

	If Not IsDllStruct(Eval($Type[$_INDEX_CODE_NAME] & 'CodeBuffer')) Then Call($Type[$_INDEX_CODE_NAME] & 'Startup')
	Local $CodeBuffer = Eval($Type[$_INDEX_CODE_NAME] & 'CodeBuffer')

	Local $Digest = DllStructCreate("byte[" & $Type[$_INDEX_HASH_SIZE] & "]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + (Eval($Type[$_INDEX_HASH_NAME] & 'ResultOffset')), _
													"ptr", DllStructGetPtr($Context), _
													"ptr", DllStructGetPtr($Digest), _
													"int", 0, _
													"int", 0)
	Return DllStructGetData($Digest, 1)
EndFunc

Func _Hash( $Type, $Data)
	Local $State = _HashInit($Type)
	_HashInput($State, $Data)
	Return _HashResult($State)
EndFunc
