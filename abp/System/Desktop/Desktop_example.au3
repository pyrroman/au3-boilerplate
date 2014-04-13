#include <Constants.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include "../Desktop.au3"

Local $aScreenResolution = _DesktopDimensions()
MsgBox($MB_SYSTEMMODAL, '', 'Example of _DesktopDimensions:' & @CRLF & _
'Number of monitors = ' & $aScreenResolution[1] & @CRLF & _
'Primary Width = ' & $aScreenResolution[2] & @CRLF & _
'Primary Height = ' & $aScreenResolution[3] & @CRLF & _
'Secondary Width = ' & $aScreenResolution[4] & @CRLF & _
'Secondary Height = ' & $aScreenResolution[5] & @CRLF)