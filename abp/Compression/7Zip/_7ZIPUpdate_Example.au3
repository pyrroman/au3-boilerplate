#include <7Zip.au3>

$ArcFile = FileOpenDialog("Select archive", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)")
If @error Then Exit

$FileName = "c:\Program Files\AutoIt3\Examples\*.bmp"

$retResult = _7ZipUpdate(0, $ArcFile, $FileName)
If @error = 0 Then
	MsgBox(64, "_7ZipUpdate", $retResult)
Else
	MsgBox(64, "_7ZipUpdate", "Error occurred")
EndIf
