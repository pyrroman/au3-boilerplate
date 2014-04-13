#include <7Zip.au3>

$ArcFile = FileOpenDialog("Select archive", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)")
If @error Then Exit

$sFiles = "*.dll"

$retResult = _7ZipDelete(0, $ArcFile, $sFiles)
If @error = 0 Then
	MsgBox(64, "_7ZipDelete", $retResult)
Else
	MsgBox(16, "_7ZipDelete", "Error occurred")
EndIf
