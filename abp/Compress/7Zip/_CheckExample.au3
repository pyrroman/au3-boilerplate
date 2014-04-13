#include <7Zip.au3>

If _7ZipCheckArchive("ZipExample.zip") Then
	MsgBox(64, "Archive Check", "The archive check is OK ")
Else
	MsgBox(16, "Archive Check", "The archive check is Not OK ")
EndIf
