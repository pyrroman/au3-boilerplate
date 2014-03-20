#include "VarDump.au3"

Local $vTmp2[1][2][1] = [[["bar"],[Default]]]
Local $vTmp[1][2][1] = [[["foo"],[$vTmp2]]]
__DumpTest($vTmp, "nested 3D arrays")

__DumpTest(Binary("shit"), 'Binary("shit")')

__DumpTest(0xDEAD, 'hex (0xDEAD)')

Local $tSTRUCT1 = DllStructCreate("struct;int var1;uint var2;byte var3;char var4[128];endstruct")
$tSTRUCT1.var1 = -1
$tSTRUCT1.var2 = -1; The -1 (signed int) will be typecasted to unsigned int.
$tSTRUCT1.var3 = 256
$tSTRUCT1.var4 = "12345" ; Or 4 instead of "var4".
DllStructSetData($tSTRUCT1, "var4", "0", 3)
__DumpTest($tSTRUCT1, 'signed/unsigned and char[]')

__DumpTest(DllStructGetPtr($tSTRUCT1), "Struct pointer")

__DumpTest(MsgBox, 'default function')

__DumpTest(0.12345678901234567890, 'long double')

$vTmp = GUICreate("This is GUI title")
__DumpTest($vTmp, "GUI")
GUIDelete($vTmp)

$vTmp = ObjCreate("Shell.Application")
__DumpTest(ObjCreate("Shell.Application"), "Object (Shell.Application)")

Local $tTest = DllStructCreate("byte;byte[2];ubyte;ubyte[2];char;char[2];wchar;wchar[2];short;short[2];ushort;ushort[2];int;int[2];uint;uint[2];int64;int64[2];uint64;uint64[2];float;float[2];double;double[2];handle;handle[2];boolean;bool;hwnd;handle;int_ptr;long_ptr;lresult;lparam;uint_ptr;ulong_ptr;dword_ptr;wparam")
__DumpTest($tTest, 'Test structure types')

Local $struct = DllStructCreate("char[3];handle[3];uint[35];byte[128];wchar[190000]; double[3];int64[3];char[3];float;double;byte;ubyte;short;ushort;int;uint;char")
DllStructSetData($struct, 1, 'sos')
DllStructSetData($struct, 2, Ptr(123456789))
DllStructSetData($struct, 3, 8, 1)
DllStructSetData($struct, 3, 0x87654321, 2)
DllStructSetData($struct, 3, 256, 5)
DllStructSetData($struct, 4, Binary('sos'))
DllStructSetData($struct, 5, 'gno' & @CRLF & 'ji' & @TAB & 'o')
DllStructSetData($struct, 6, 3.1415926, 2)
DllStructSetData($struct, 7, 17, 1)
DllStructSetData($struct, 7, -1, 2)
DllStructSetData($struct, 8, 'end')
DllStructSetData($struct, 9, 2.7182818284590452353602874713527)
DllStructSetData($struct, 10, 2.7182818284590452353602874713527)
DllStructSetData($struct, 11, 107)
DllStructSetData($struct, 12, -108)
DllStructSetData($struct, 13, 109)
DllStructSetData($struct, 14, 110)
DllStructSetData($struct, 15, 111)
DllStructSetData($struct, 16, 112)

Local $c[2][0]
Local $e[2][2] = [[Null, Default],[__DumpTest, MsgBox]]
Local Enum $p = 33333333333333
Opt("WinTitleMatchMode", 2)
Local $a[3][4] = [ _
		[$c, $e, ObjCreate("shell.application"), WinGetHandle("Dump.au3")], _
		['zzz', 1 / 3, True, 0x123456], _
		[$struct, 93, Null, $p] _
		]

__DumpTest($a, 'Test example of moderate complexity')

Func __DumpTest($vTestVar, $sMessage = "")
	Static $c = 0
	$c += 1
	ConsoleWrite("- Test #" & $c & ($sMessage ? (" - " & $sMessage) : "") & @CRLF)
	ConsoleWrite(_VarDump($vTestVar) & @CRLF)
EndFunc   ;==>__DumpTest