#include-once
#include <Array.au3>
#include <String.au3>
#include <StringConstants.au3>


; #INDEX# =======================================================================================================================
; Title .........: var_dump
; File name .....: var_dump.au3
; AutoIt Version : 3.3.10+
; Description ...: Dumps information about a variable
; Author(s) .....: rindeal
; Dll ...........:
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _str_split
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Name ..........: _var_dump
; Description ...: Dumps information about a variable
;                  This function displays structured information about one or more expressions that includes its type and value.
;                  Arrays and objects are explored recursively with values indented to show structure.
; Syntax ........: _var_dump($vExpression [, $... ])
; Parameters ....: $vExpression         - The variable you want to dump. Up to 32 variables.
; Return values .: Success - 1
;                  Failure - 0 and sets the @error flag to a non-zero value.
; Author ........: rindeal
; Modified ......:
; Version .......: 2014-01-21
; Requirements ..:
; Performance ...:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _var_dump($vExpression, $1 = Default, $2 = Default, $3 = Default, $4 = Default, $5 = Default, $6 = Default, $7 = Default, $8 = Default, $9 = Default, $10 = Default, _
		$11 = Default, $12 = Default, $13 = Default, $14 = Default, $15 = Default, $16 = Default, $17 = Default, $18 = Default, $19 = Default, $20 = Default, _
		$21 = Default, $22 = Default, $23 = Default, $24 = Default, $25 = Default, $26 = Default, $27 = Default, $28 = Default, $29 = Default, $30 = Default, $31 = Default)
	Local Const $INDENT_SIZE = 2, $LENGTH_LIMIT = 50
	Local Static $sReturn = "", $iLevel = 0, $fRecursive = 0

	Local $vTmp, $avTmp, $i
	; Merge multiple expressions to an array
	If Not IsKeyword($1) Then
		Local $avTmp[32] = [$vExpression]
		For $i = 1 To 31
			$avTmp[$i] = Eval($i)
			If IsKeyword($avTmp[$i]) Then
				ReDim $avTmp[$i]
				ExitLoop
			EndIf
		Next
		Return _var_dump($avTmp)
	EndIf
	; The Great Decision Maker
	Select
		Case IsArray($vExpression)
			; array alg
			$sReturn &= "array"
		Case IsBinary($vExpression)
			$sReturn &= StringFormat("%" & $INDENT_SIZE * $iLevel & "s%s(%d) %." & $LENGTH_LIMIT & "s\n", " ", "binary", BinaryLen($vExpression), $vExpression)
		Case IsBool($vExpression)
			$sReturn &= StringFormat("%" & $INDENT_SIZE * $iLevel & "s%s(%s)\n", " ", "bool", $vExpression)
		Case IsDllStruct($vExpression)
			; same as array
			$sReturn &= StringFormat("%"&$INDENT_SIZE * $iLevel&"s%s(%." & $LENGTH_LIMIT & "s)\n", "","struct", $i - 1)
			$i = 1
			$iLevel += 1
			While 1
				$vTmp = DllStructGetData($vExpression, $i)
				If @error Then ExitLoop
				_var_dump($vTmp)
				$i += 1
			WEnd
			$iLevel -= 1
		Case IsFunc($vExpression)
			$sReturn &= StringFormat("%" & $INDENT_SIZE * $iLevel & "s%s(%." & $LENGTH_LIMIT & "s)\n", "", "func", FuncName($vExpression))
		Case IsFloat($vExpression)
			$sReturn &= StringFormat("%" & $INDENT_SIZE * $iLevel & "s%s(%f)\n", "", "float", $vExpression)
		Case IsHWnd($vExpression)
			$sReturn &= StringFormat("%" & $INDENT_SIZE * $iLevel & 's%s(%d) %.' & $LENGTH_LIMIT & 's\n', "", "hwnd", $vExpression, WinGetTitle($vExpression) ? '[TITLE:"' & WinGetTitle($vExpression) & '"]' : "")
		Case IsInt($vExpression)
			$sReturn &= StringFormat("%" & $INDENT_SIZE * $iLevel & "s%s(%d) hex(%X)\n", "", "int", $vExpression, $vExpression)
		Case IsKeyword($vExpression)
			$sReturn &= StringFormat("%" & $INDENT_SIZE * $iLevel & "s%s(%s)\n", "", "keyword", $vExpression)
		Case IsObj($vExpression)
			$sReturn &= StringFormat("%" & $INDENT_SIZE * $iLevel & "s%s(%s) %." & $LENGTH_LIMIT & "s\n", "", "obj", ObjName($vExpression, 1), ObjName($vExpression, 2))
		Case IsPtr($vExpression)
			$sReturn &= StringFormat("%" & $INDENT_SIZE * $iLevel & "s%s(%s)\n", "", "ptr", $vExpression)
		Case IsString($vExpression)
			$sReturn &= StringFormat("%" & $INDENT_SIZE * $iLevel & "s%s(%d) %." & $LENGTH_LIMIT & "s\n", "", "string", StringLen($vExpression), $vExpression)
	EndSelect
	$vTmp = $sReturn
	If Not $fRecursive Then
		$vTmp = StringStripWS($vTmp, $STR_STRIPLEADING + $STR_STRIPTRAILING)
		If Not @Compiled Then ConsoleWrite($vTmp & @CRLF)
		$sReturn = ""
	EndIf
	Return $vTmp
EndFunc   ;==>_var_dump


_Debug()
Func _Debug()
	Local $vTmp[3] = ["", "", ""]
	_var_dump($vTmp)
	_var_dump(Binary("shit"))
	_var_dump(0xDEAD)
	_var_dump(False)
	Local $tSTRUCT1 = DllStructCreate("struct;int var1;byte var2;uint var3;char var4[128];endstruct")
	DllStructSetData($tSTRUCT1, "var1", -1) ; Or 1 instead of "var1".
	$tSTRUCT1.var2 = 255
	DllStructSetData($tSTRUCT1, "var3", -1) ; The -1 (signed int) will be typecasted to unsigned int.
	DllStructSetData($tSTRUCT1, "var4", "Hello") ; Or 4 instead of "var4".
	DllStructSetData($tSTRUCT1, "var4", Asc("h"), 1)
	_var_dump($tSTRUCT1)
	_var_dump(MsgBox)
	_var_dump(0.0123456)
	$vTmp = GUICreate("shit")
	_var_dump($vTmp)
	GUIDelete($vTmp)
	$vTmp = ""
	_var_dump(3)
	_var_dump(Default)
	$vTmp = ObjCreate("Shell.Application")
	_var_dump($vTmp)
	$vTmp = ""
	_var_dump(DllStructGetPtr($tSTRUCT1))
	_var_dump("shit")
	Local $var
	_var_dump($var)
EndFunc   ;==>_Debug

