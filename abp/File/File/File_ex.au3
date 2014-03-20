#include <Array.au3>
#include "FileEx.au3"

$aTest = _File_GetDetails(@WindowsDir & "\explorer.exe")
_ArrayDisplay($aTest)

MsgBox("", @WindowsDir & "\explorer.exe", _File_GetDetails(@SystemDir & "\calc.exe", 0))