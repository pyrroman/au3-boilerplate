#include <7Zip.au3>

$ArcFile = FileOpenDialog("Select archive", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)")
If @error Then Exit

ConsoleWrite("CheckArchive: " & _7ZipCheckArchive($ArcFile) & @LF & _
			 "ArchiveType: " & _7ZipGetArchiveType($ArcFile) & @LF & _
			 "FileCount: " & _7ZipGetFileCount($ArcFile) & @LF & _
			 "ConfigDialog: " & _7ZipConfigDialog(0) & @LF & _
			 "DLL Version: " & _7ZipGetVersion() & @LF & _
			 "DLL Sub-Version: " & _7ZipGetSubVersion() & @LF)