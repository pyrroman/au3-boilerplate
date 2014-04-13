	#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>
#include "../Icons.au3"

$hModule = _WinAPI_LoadLibraryEx(@SystemDir & '\shell32.dll', $LOAD_LIBRARY_AS_DATAFILE)
$aData = _EnumIconResource($hModule, 3)
If Not @Error Then
    _ArrayDisplay($aData)
EndIf
_WinAPI_FreeLibrary($hModule)