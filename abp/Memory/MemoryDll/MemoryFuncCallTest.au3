; ============================================================================================================================
;  File     : MemorydllTest.au3
;  Purpose  : Demonstration for MemoryFuncCall
;  Author   : ProgAndy
;  Modifier : Ward
; ============================================================================================================================

#Include "MemoryDll.au3"

Func TestFunc($Param)
	MsgBox(0, 'TestFunc', $Param)
	Return 23
EndFunc

Dim $CallBack = DllCallbackRegister("TestFunc", "int", "str")
Dim $Ret = MemoryFuncCall("int", DllCallbackGetPtr($CallBack), "str", "A string as parameter")
MsgBox(0, 'The return', $Ret[0])
DllCallbackFree($CallBack)
