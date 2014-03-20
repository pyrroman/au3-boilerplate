; ============================================================================================================================
;  File     : MemoryDllGen.au3
;  Purpose  : Convert DLL files to HEX binary data
;  Author   : Ward
; ============================================================================================================================

Dim $VarName = StringStripWS(InputBox("MemoryDllGen", "Select a name of variable:", "DllBinary"), 3)
If $VarName = "" Then Exit

Dim $DllName = FileOpenDialog("Open dll file", @ScriptDir, "DLL file (*.*)")
If $DllName = "" Then Exit

Dim $Handle = FileOpen($DllName, 16)
Dim $DllBinary = FileRead($Handle)
FileClose($Handle)

Dim $LineLen = 2050
Dim $DllString = String($DllBinary)

Dim $Script = "Dim $" & $VarName & " = '" & StringLeft($DllString, $LineLen) & "'" & @CRLF
$DllString = StringTrimLeft($DllString, $LineLen)

While StringLen($DllString) > $LineLen
	$Script &= "    $" & $VarName & " &= '" & StringLeft($DllString, $LineLen) & "'" & @CRLF
	$DllString = StringTrimLeft($DllString, $LineLen)
WEnd

If StringLen($DllString) <> 0 Then $Script &= "    $" & $VarName & " &= '" & $DllString & "'" & @CRLF
ClipPut($Script)


MsgBox(64, 'MemoryDll Generator', 'The result is in the clipboard, you can paste it to your script.')
