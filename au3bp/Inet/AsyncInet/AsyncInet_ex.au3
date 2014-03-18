#include "AsyncInet.au3"

Opt("TrayIconDebug", 1)
Global $NumOfTests = 100
Global $aIN[$NumOfTests], $aCodes
For $i = 0 To $NumOfTests - 1
	$aIN[$i] = "http://www.google.com"
Next
Global $t = TimerInit()
Global $aOUT = _AsyncInet_Read($aIN)
$t = TimerDiff($t)
Global $counter = 0
For $i = 0 To UBound($aOUT) - 1
	If $aOUT[$i] <> '' Then $counter += 1
Next
ConsoleWrite(StringFormat("%3d/%3d(%3d%%) files in %4d ms ==> %2d ms/file ;%3d files/s", _
		$counter, $NumOfTests, 100 * $counter / $NumOfTests, $t, $t / $counter, 1000 * $counter / $t) & @CRLF)
