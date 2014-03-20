#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _GetExtProperty
; Description ...: Retrieves details about an item in a folder. For example, its size, type, or the time of its last modification.
; Syntax ........: _GetExtProperty($sPath, $iProp)
; Parameters ....: $sPath - A string value. The path to the file you are attempting to retrieve an extended property from.
;                  $iProp - [optional] An integer value. Default value is -1. The numerical value for the property you want returned.
;                           If set to -1 then all properties will be returned in a 2D array in their corresponding order:
;                               $[$i][0] - properity name
;                               $[$i][1] - properity value
;                           Otherwise you can choose a number from interval <0;286>
;                             Some interesting properties:
;                                0 - Name                 [explorer.exe]
;                                1 - Size                 [2,73 MB]
;                                2 - Item type            [Application]
;                                3 - Date modified        [25.2.2011 7:19]
;                                4 - Date created         [26.8.2013 2:11]
;                                5 - Date accessed        [26.8.2013 2:11]
;                                6 - Attributes           [A]
;                                9 - Perceived type       [Application]
;                               10 - Owner                [TrustedInstaller]
;                               11 - Kind                 [Program]
;                               19 - Rating               [Unrated]
;                               25 - Copyright            [© Microsoft Corporation. All rights reserved.]
;                               33 - Company              [Microsoft Corporation]
;                               34 - File description     [Windows Explorer]
;                               53 - Computer             [LOCALHOST (this computer)]
;                              155 - Filename             [explorer.exe]
;                              156 - File version         [6.1.7601.17567]
;                              173 - Shared               [No]
;                              176 - Folder name          [Windows]
;                              177 - Folder path          [C:\Windows]
;                              178 - Folder               [Windows (C:)]
;                              180 - Path                 [C:\Windows\explorer.exe]
;                              182 - Type                 [Application]
;                              185 - Language             [English (United States)]
;                              188 - Link status          [Unresolved]
;                              269 - Sharing status       [Not shared]
;                              270 - Product name         [Microsoft® Windows® Operating System]
;                              271 - Product version      [6.1.7601.17567]
; Return values .: On Success - If $iProp >= 0 then (string) the extended file property
;                               If $iProp = -1 then a 2D array with all properties
;                  On Failure - 0
;                      @Error = 1 (If file does not exist)
; Author ........: rindeal <dev . rindeal at outlook . com> [simplified, UDF header rewritten]
; Modified ......:
; Remarks .......: All retrieved content will be localized and all numbers will be in a human readable format!
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _File_GetDetails($sPath, $iProp = -1)
	Local Const $iProperitiesCount = 287 ; NOTE: maybe on some other systems, this value needs to be changed, not tested
	Local $oShellApp, $oDir, $oFile
	Local $asProperty[$iProperitiesCount][2]

	If Not FileExists($sPath) Then Return SetError(1, 0, 0)

	$oShellApp = ObjCreate("shell.application")
	$oDir = $oShellApp.NameSpace(StringRegExpReplace($sPath, "\\[^\\]*$", ""))
	$oFile = $oDir.Parsename(StringRegExpReplace($sPath, ".*\\", ""))

	If $iProp = -1 Then
		For $i = 0 To $iProperitiesCount - 1
			$asProperty[$i][0] = $oDir.GetDetailsOf(Null, $i)
			$asProperty[$i][1] = $oDir.GetDetailsOf($oFile, $i)
		Next
		Return $asProperty
	EndIf

	Return $oDir.GetDetailsOf($oFile, $iProp)
EndFunc   ;==>_File_GetDetails
