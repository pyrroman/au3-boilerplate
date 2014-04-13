#RequireAdmin

#include <File.au3>
#include <Array.au3>

#include "abp/Security/Permissions.au3"
#include "abp/Constants.au3"

Dim $sFromDir = @ScriptDir & "\" & $__ABP_NAME

; Remove BackUp dirs that Tidy autogenerates
Dim $aBackUps = _FileListToArrayRec(@ScriptDir, "BackUp", 2, 1, 0, 2)
If IsArray($aBackUps) Then
	_ArrayDelete($aBackUps, 0)
	For $sBackUp In $aBackUps
		DirRemove($sBackUp, 1)
	Next
EndIf

DirRemove($__ABP_INSTALL_DIR, 1)
DirCopy($sFromDir, $__ABP_INSTALL_DIR, 1)
If @error Then Exit MsgBox("", "", "error")

; set R+W permissions for all users in case of a need for immediate changes
; but generally it's recommended to make these modifications in the git repo and install the changes via the install script
Dim $aPerm[][3] = [['Users', 1, $GENERIC_ALL]]
_SetObjectPermissions($__ABP_INSTALL_DIR, $aPerm, $SE_FILE_OBJECT, 'Administrators', 0, 1)

