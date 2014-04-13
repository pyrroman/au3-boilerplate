; Creates a new *_DLL.au3 file
; Copyright (c) 2014 Jan Chren <dev.rindeal+autoit at outlook.com>

$sDLLName = InputBox("NewDLL", "Type the name of the DLL", ".dll")
If @error Then Exit MsgBox("", "error", "", 3)
$sDLLName = StringRegExpReplace($sDLLName, "(.*)\.[^\.]*", "\1")
$fo = FileOpen(StringUpper($sDLLName) & "_DLL.au3", 2 + 8)
FileWrite($fo, StringFormat( _
		'#include-once\n\n' & _
		'Global $%s_DLL = DllOpen("%s.dll")\n', _
		StringUpper($sDLLName), $sDLLName) _
		)
FileClose($fo)
MsgBox("","Done","Done!",2)
