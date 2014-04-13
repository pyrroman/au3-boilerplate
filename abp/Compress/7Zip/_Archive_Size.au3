#include <7Zip.au3>

$ArcFile = FileOpenDialog("Select archive", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)")
If @error Then Exit

_7ZipStartup()
$NbFiles = _7ZipGetFileCount($ArcFile)
MsgBox(32, "Size", "Total size of " & $NbFiles & " files in archive = " & _7ZipFilesSize($ArcFile))
_7ZipShutdown()

Func _7ZipFilesSize($ArcFile)
	$hArc = _7ZipOpenArchive(0, $ArcFile)
	If $hArc = 0 Then
		SetError(1)
		Return 0
	EndIf
	$tINDIVIDUALINFO = _7ZipFindFirst($hArc, "*.*")
	If $tINDIVIDUALINFO = -1 Then Exit
	Local $Size

	$Size += _7ZipGetArcOriginalSize($hArc)

	While 1
		$tINDIVIDUALINFO = _7ZipFindNext($hArc, $tINDIVIDUALINFO)
		If $tINDIVIDUALINFO = 0 Then ExitLoop

		$Size += DllStructGetData($tINDIVIDUALINFO, "dwOriginalSize")
	WEnd

	_7ZipCloseArchive($hArc)

	Return $Size
EndFunc   ;==>_7ZipFilesSize