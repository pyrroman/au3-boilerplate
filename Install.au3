#RequireAdmin

#include <File.au3>
#include <Array.au3>

#include "abp/Security/Permissions.au3"
#include "abp/Constants.au3"

Dim $sFromDir = @ScriptDir & "\" & $___NAME___

Dim $aBackUps = _FileListToArrayRec(@ScriptDir, "BackUp", 2, 1, 0, 2)
If IsArray($aBackUps) Then
	_ArrayDelete($aBackUps, 0)
	For $sBackUp In $aBackUps
		DirRemove($sBackUp, 1)
	Next
EndIf

DirRemove($___INSTALL_DIR___, 1)
DirCopy($sFromDir, $___INSTALL_DIR___, 1)
If @error Then Exit MsgBox("", "", "error")

Dim $aPerm[][3] = [['Users', 1, $GENERIC_ALL]]
_SetObjectPermissions($___INSTALL_DIR___, $aPerm, $SE_FILE_OBJECT, 'Administrators', 0, 1)

