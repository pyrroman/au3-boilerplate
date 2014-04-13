#include <Date.au3>
#include <7Zip.au3>

$ArcFile = FileOpenDialog("Select archive", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)")
If @error Then Exit

_7ZipStartup()
$hArc = _7ZipOpenArchive(0, $ArcFile)
If $hArc = 0 Then Exit MsgBox(16, "_7ZipOpenArchive", "Error occured")

$tINDIVIDUALINFO = _7ZipFindFirst($hArc, "*.*")
If $tINDIVIDUALINFO = -1 Then Exit

;Use functions to obtain files values
ConsoleWrite("!> FileName: " & _7ZipGetFileName($hArc) & @LF & _
			 "OriginalSize: " & _7ZipGetArcOriginalSize($hArc) & @LF & _
			 "CompressedSize: " & _7ZipGetArcCompressedSize($hArc) & @LF & _
			 "ArcRatio: " & _7ZipGetArcRatio($hArc) & @LF & _
			 "Date: " & _Date_Time_DOSDateToStr(_7ZipGetDate($hArc)) & @LF & _
			 "Time: " & _Date_Time_DOSTimeToStr(_7ZipGetTime($hArc)) & @LF & _
			 "CRC: " & _7ZipGetCRC($hArc) & @LF & _
			 "Attribute: " & _7ZipGetAttribute($hArc) & @LF & _
			 "Method: " & _7ZipGetMethod($hArc) & @LF & @LF)

;Or retrieve values from structure (the fast method)
While 1
	$tINDIVIDUALINFO = _7ZipFindNext($hArc, $tINDIVIDUALINFO)
	If $tINDIVIDUALINFO = 0 Then ExitLoop

	ConsoleWrite("!> FileName: " & DllStructGetData($tINDIVIDUALINFO, "szFileName") & @LF & _
				 "OriginalSize: " & DllStructGetData($tINDIVIDUALINFO, "dwOriginalSize") & @LF & _
				 "CompressedSize: " & DllStructGetData($tINDIVIDUALINFO, "dwCompressedSize") & @LF & _
				 "CRC: " & DllStructGetData($tINDIVIDUALINFO, "dwCRC") & @LF & _
				 "Flag: " & DllStructGetData($tINDIVIDUALINFO, "uFlag") & @LF & _
				 "OSType: " & DllStructGetData($tINDIVIDUALINFO, "uOSType") & @LF & _
				 "Ratio: " & DllStructGetData($tINDIVIDUALINFO, "wRatio") & @LF & _
				 "Date: " & _Date_Time_DOSDateToStr(DllStructGetData($tINDIVIDUALINFO, "wDate")) & @LF & _
				 "Time: " & _Date_Time_DOSTimeToStr(DllStructGetData($tINDIVIDUALINFO, "wTime")) & @LF & _
				 "Attribute: " & DllStructGetData($tINDIVIDUALINFO, "szAttribute") & @LF & @LF)
WEnd

_7ZipCloseArchive($hArc)
_7ZipShutdown()
