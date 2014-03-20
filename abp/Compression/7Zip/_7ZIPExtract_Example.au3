#include <7Zip.au3>

;Example #1
$ArcFile = FileOpenDialog("Select archive", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)")
If @error Then Exit

$Output = FileSelectFolder("Select output folder", "")
If @error Then Exit

$retResult = _7ZIPExtract(0, $ArcFile, $Output)
If @error = 0 Then
	MsgBox(64, "_7ZIPExtractEx", $retResult)
Else
	MsgBox(16, "_7ZIPExtractEx", "Error occurred")
EndIf

;Example #2
$ArcFile = FileOpenDialog("Select archive", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)")
If @error Then Exit

$Output = FileSelectFolder("Select output folder", "")
If @error Then Exit

$retResult = _7ZIPExtract(0, $ArcFile, $Output, 0, 0, 1, 0, 0, 0, "*.wav")
If @error = 0 Then
	MsgBox(64, "_7ZIPExtractEx", $retResult)
Else
	MsgBox(16, "_7ZIPExtractEx", "Error occurred")
EndIf
