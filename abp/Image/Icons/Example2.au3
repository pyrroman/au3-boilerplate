#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>
#include "../Icons.au3"

$aData = _EnumIconFile(@ScriptDir & '\MyIcon.ico')
If Not @Error Then
    _ArrayDisplay($aData)
EndIf