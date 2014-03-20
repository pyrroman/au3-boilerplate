#include <WinApiLocale.au3>

#include "WindowsLocale.au3"

Local $iNumOfTests = 10000
Local $asTestCodes[$iNumOfTests], $t
For $i = 0 To $iNumOfTests - 1
	$asTestCodes[$i] = Chr(Random(97, 122, 1)) & Chr(Random(97, 122, 1))
Next
$t = TimerInit()
For $sCode In $asTestCodes
	_WindowsLocale($sCode, $_LANG_TYPE_LOCALE)
Next
$t = TimerDiff($t)
Local $sExampleOfUse = _WindowsLocale(_WinAPI_GetUserDefaultLCID(), $_LANG_TYPE_LCID_STRING)
MsgBox("", "_WindowsLocale", StringFormat("Speed: %.3f ms/query\nRetVal: %s", $t / $iNumOfTests, $sExampleOfUse))
