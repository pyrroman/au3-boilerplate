#include <7Zip.au3>

;Exampe #1
$ArcFile = FileSaveDialog("Open archive or Create a new archive for adding directory", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)")
If @error Then Exit

$FileName = FileSelectFolder("Select a folder to add in archive", "")
If @error Then Exit

If _7ZipStartup() Then ; To test dll opening (can be omitted for some functions)
	$retResult = _7ZipAdd(0, $ArcFile, $FileName)
	If @error Then
		MsgBox(16, "_7ZipAdd", "Error occurred")
	Else
		MsgBox(64, "_7ZipAdd", "Archive created successfully" & @LF & $retResult)
	EndIf
Else
	MsgBox(16, "_7ZipAdd", "Enable to start dll")
EndIf
_7ZipShutdown()

;Exampe #2
$ArcFile = FileSaveDialog("Open archive or Create a new archive for adding file", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)")
If @error Then Exit

$FileName = FileOpenDialog("Select a file to add in archive", "", "All (*.*)")
If @error Then Exit

$retResult = _7ZipAdd(0, $ArcFile, $FileName)
If @error Then
	MsgBox(16, "_7ZipAdd", "Error occurred")
Else
	MsgBox(64, "_7ZipAdd", "Archive created successfully" & @LF & $retResult)
EndIf


;Exampe #3
$ArcFile = FileSaveDialog("Open archive or Create a new archive for adding directory with include/exclude", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)")
If @error Then Exit

$FileName = FileSelectFolder("Select a folder to add in archive (using include/exclude)", "")
If @error Then Exit

$sInclude = "c:\Program Files\AutoIt3\Examples\GUI\*.*"
$sExclude = "c:\Program Files\AutoIt3\Examples\GUI\*.au3"

$retResult = _7ZipAdd(0, $ArcFile, $FileName, 0, 5, 1, $sInclude, $sExclude)
If @error Then
	MsgBox(64, "_7ZipAdd", "Error occurred")
Else
	MsgBox(64, "_7ZipAdd", "Archive created successfully" & @LF & $retResult)
EndIf
