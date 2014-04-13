#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#include-once

; #INDEX# =======================================================================================================================
; Title .........: 7Zip
; AutoIt Version : 3.3.8.1
; Language ......: English
; Description ...: Functions that assist with 7zip DLL.
; Author(s) .....: R. Gilman (rasim)
; Notes .........: The original code came from this subject : http://www.autoitscript.com/forum/topic/85094-7zip/
;				  - 7 October 2012 UDF updated by Tlem  :
;						* Aspect modification (like standard UDFs).
;						* Updating 32bit dll (v4.57 -> v9.20).
;						* Adding 64bit dll (v9.20) and modification of code to use it on x64 arch.
;						* Adding _7ZipStartup() to install (fileinstall) and start the 32 and 64 bit dll.
;						* Adding _7ZipShutdown() to shutdown the dll and clean the Tempdir.
;						* Adding _7ZipGetFilesList to get archive files list.
;						* Modify functions to control the opening of the dll or to auto open/close the dll.
;						  Some functions are inteted to be use in conjonction with other functions, so all
;						  functions do not open/close dll automaticaly.
;					- 18 October 2012 :
;						* Modification in _7ZipStartup to fix FileInstall problem between 32 and 64 bit dll.
;
;
;*** Using _7ZipStartup() and _7ZipShutdown() is recommanded for multiples 7Zip actions to avoid
;*** repetitive dll open and dll FileInstall/delete that can increase opération time.
;
; The last x32 DLL file can be find here : http://www.csdinc.co.jp/archiver/lib/7-zip32.html#download
; The x64 version was find somewhere on the web. Look about Minoru Akita and 7-zip64.dll...
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_7ZipStartup
;_7ZipShutdown
;_7ZipAdd					Auto Open dll
;_7ZipDelete				Auto Open dll
;_7ZIPExtract				Auto Open dll
;_7ZIPExtractEx				Auto Open dll
;_7ZIPUpdate				Auto Open dll
;_7ZipSetOwnerWindowEx
;_7ZipKillOwnerWindowEx
;_7ZipOpenArchive
;_7ZipCloseArchive
;_7ZipFindFirst
;_7ZipFindNext
;_7ZipGetFileName
;_7ZipGetArcOriginalSize
;_7ZipGetArcCompressedSize
;_7ZipGetArcRatio
;_7ZipGetDate
;_7ZipGetTime
;_7ZipGetCRC
;_7ZipGetAttribute
;_7ZipGetMethod
;_7ZipCheckArchive			Auto Open dll
;_7ZipGetArchiveType		Auto Open dll
;_7ZipGetFileCount			Auto Open dll
;_7ZipConfigDialog			Auto Open dll
;_7ZipQueryFunctionList		Auto Open dll
;_7ZipGetVersion			Auto Open dll
;_7ZipGetSubVersion			Auto Open dll
;_7ZipGetFilesList			Auto Open dll
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $sZip32Dll = "7-zip32.dll" 			;|If you intend to modify the original name of used dll, don't forget
Global $sZip64Dll = "7-zip64.dll" 			;|to modify _7ZipStartup() function in FileInstall section.
Global $sNoCompiledPath = @ScriptDir & "\"	;The directory where dll files are for non compiled use
Global $sCompiledPath = @TempDir & "\"		;The directory where fileinstall dll files for compiled use
Global Const $FNAME_MAX32 = 512
Global $hArchiveProc
Global $hDLL_7ZIP = 0

;File attributes constants
Global Const $FA_RDONLY = 0x01		;Reading private file
Global Const $FA_HIDDEN = 0x02		;Invisibility attribute file
Global Const $FA_SYSTEM = 0x04		;System file
Global Const $FA_LABEL = 0x08		;Volume label
Global Const $FA_DIREC = 0x10		;Directory
Global Const $FA_ARCH = 0x20		;Retention bit
Global Const $FA_ENCRYPTED = 0x40	;The password the file which is protected
; ===============================================================================================================================

; #STRUCTURES# ==================================================================================================================
Global $tagINDIVIDUALINFO = "int dwOriginalSize;int dwCompressedSize;int dwCRC;uint uFlag;uint uOSType;short wRatio;" & _
		"short wDate;short wTime;char szFileName[" & $FNAME_MAX32 + 1 & "];char dummy1[3];" & _
		"char szAttribute[8];char szMode[8]"

Global Const $tagEXTRACTINGINFO = "int dwFileSize;int dwWriteSize;char szSourceFileName[" & $FNAME_MAX32 + 1 & "];" & _
		"char dummy1[3];char szDestFileName[" & $FNAME_MAX32 + 1 & "];char dummy[3]"

Global Const $tagEXTRACTINGINFOEX = $tagEXTRACTINGINFO & ";dword dwCompressedSize;dword dwCRC;uint uOSType;short wRatio;" & _
		"short wDate;short wTime;char szAttribute[8];char szMode[8]"
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipStartup
; Description ...: Install and Open the 7-zip dll
; Syntax.........: _7ZipStartup()
; Parameters ....: None
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and set @error
;                  @Error  - 0 = No error.
;				   |1 = Error while open the dll
;                  |2 = Dll File(s) missing for compiling (must be in scriptdir)
;				   |3 = Unable to extract dll file (for compiled script)
;
; Author ........: Tlem
; ===============================================================================================================================
Func _7ZipStartup()
	If Not @Compiled Then ; If not compiled, test and open the right dll
		If Not FileExists($sNoCompiledPath & $sZip32Dll) And _
		   Not FileExists($sNoCompiledPath & $sZip64Dll) Then Return SetError(2, 0, 0)
		If @OSArch = "X86" Then
			$hDLL_7ZIP = DllOpen($sNoCompiledPath & $sZip32Dll) ; Open x32 dll from no compiled path
		Else
			$hDLL_7ZIP = DllOpen($sNoCompiledPath & $sZip64Dll) ; Open x64 dll from no compiled path
		EndIf
	Else ; If compiled, test and open the right dll (that must be in ScriptDir for compiling)
		If @OSArch = "X86" Then
			If Not FileInstall("7-zip32.dll", $sCompiledPath & $sZip32Dll, 1) Then Return SetError(3, 0, 0)
			$hDLL_7ZIP = DllOpen($sCompiledPath & $sZip32Dll) ; Open x32 dll from FileInstall path
		Else
			If Not FileInstall("7-zip64.dll", $sCompiledPath & $sZip64Dll, 1) Then Return SetError(3, 0, 0)
			$hDLL_7ZIP = DllOpen($sCompiledPath & $sZip64Dll) ; Open x64 dll from FileInstall path
		EndIf
	EndIf
	If $hDLL_7ZIP = -1 Then Return SetError(1, 0, 0) ; If no dll handle, return error
	Return 1
EndFunc   ;==>_7ZipStartup

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipShutdown
; Description ...: Close the 7-zip dll handle and delete temporary file(s)
; Syntax.........: _7ZipShutdown()
; Return values .: Success - Returns 1.
;                  Failure - Returns 0 and set @error
;                  @Error  - 0 = No error.
;				   |1 = Temporary files not deleted
;
; Author ........: Tlem
; ===============================================================================================================================
Func _7ZipShutdown()
	DllClose($hDLL_7ZIP)
	If $hArchiveProc Then DllCallbackFree($hArchiveProc)
	$hDLL_7ZIP = 0 ; Release var
	$hArchiveProc = "" ; Release var

	; Delete dll in temporary directory
	If @Compiled Then
		If Not  FileDelete($sCompiledPath & $sZip32Dll) Or Not _
				FileDelete($sCompiledPath & $sZip64Dll) Then Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_7ZipShutdown

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipAdd
; Description ...: Adds files to archive
; Syntax.........: _7ZipAdd($hWnd, $sArcName, $sFileName[, $sHide = 0[, $sCompress = 5[, $sRecurse = 1[, $sIncludeFile = 0[, _
;				   $sExcludeFile = 0[, $sPassword = 0[, $sSFX = 0[, $sVolume = 0[, $sWorkDir = 0]]]]]]]]])
; Parameters ....: $hWnd         - Handle to parent or owner window
;				   $sArcName     - Archive file name
;				   $sFileName    - File names to archive up
;				   $sHide        - Use this switch if you want the CallBack function to be called
;				   $sCompress    - Compress level 0-9
;				   $sRecurse     - Recursion method: 0 - Disable recursion
;													 1 - Enable recursion
;													 2 - Enable recursion only for wildcard names
;				   $sIncludeFile - Include filenames, specifies filenames and wildcards or list file that specify processed files
;				   $sExcludeFile - Exclude filenames, specifies what filenames or (and) wildcards must be excluded from operation
;				   $sPassword    - Specifies password
;				   $sSFX         - Creates self extracting archive
;				   $sVolume      - Specifies volumes sizes
;				   $sWorkDir     - Sets working directory for temporary base archive
;
; Return values .: Success - Returns the string with results
;                  Failure - Returns 0 and and sets @error
;                  @Error  - 0 = No error.
;				   |1 = Function failed
;				   |2 = Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipAdd($hWnd, $sArcName, $sFileName, $sHide = 0, $sCompress = 5, $sRecurse = 1, $sIncludeFile = 0, $sExcludeFile = 0, _
		$sPassword = 0, $sSFX = 0, $sVolume = 0, $sWorkDir = 0)

	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	$sArcName = '"' & $sArcName & '"'
	$sFileName = '"' & $sFileName & '"'

	Local $iSwitch = ""

	If $sHide Then $iSwitch &= " -hide"

	$iSwitch &= " -mx" & $sCompress
	$iSwitch &= _RecursionSet($sRecurse)

	If $sIncludeFile Then $iSwitch &= _IncludeFileSet($sIncludeFile)
	If $sExcludeFile Then $iSwitch &= _ExcludeFileSet($sExcludeFile)
	If $sPassword Then $iSwitch &= " -p" & $sPassword & ' -mhe'
	If FileExists($sSFX) Then $iSwitch &= " -sfx" & $sSFX
	If $sVolume Then $iSwitch &= " -v" & $sVolume
	If $sWorkDir Then $iSwitch &= " -w" & $sWorkDir

	Local $tOutBuffer = DllStructCreate("char[32768]")

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZip", _
			"hwnd", $hWnd, _
			"str", "a " & $sArcName & " " & $sFileName & " " & $iSwitch, _
			"ptr", DllStructGetPtr($tOutBuffer), _
			"int", DllStructGetSize($tOutBuffer))

	If $iFlagDll = 2 Then _7ZipShutdown()
	If Not $aRet[0] Then Return SetError(0, 0, DllStructGetData($tOutBuffer, 1))
	Return SetError(1, 0, 0)
EndFunc   ;==>_7ZipAdd

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipDelete
; Description ...: Deletes files from archive
; Syntax.........: _7ZipDelete($hWnd, $sArcName, $sFileName[, $sHide = 0[, $sCompress = 5[, $sRecurse = 1[, $sIncludeFile = 0[, _
;				   $sExcludeFile = 0[, $sPassword = 0[, $sWorkDir = 0]]]]]]])
; Parameters ....: $hWnd         - Handle to parent or owner window
;				   $sArcName     - Archive file name
;				   $sFileName    - File names to deleting
;				   $sHide        - Use this switch if you want the CallBack function to be called
;				   $sCompress    - Compress level 0-9
;				   $sRecurse     - Recursion method: 0 - Disable recursion
;													 1 - Enable recursion
;													 2 - Enable recursion only for wildcard names
;				   $sIncludeFile - Include filenames, specifies filenames and wildcards or list file that specify processed files
;				   $sExcludeFile - Exclude filenames, specifies what filenames or (and) wildcards must be excluded from operation
;				   $sPassword    - Specifies password
;				   $sWorkDir     - Sets working directory for temporary base archive
;
; Return values .: Success - Returns the string with results
;                  Failure - Returns 0 and and sets @error
;                  @Error  - 0 = No error.
;				   |1 = Function failed
;				   |2 = Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipDelete($hWnd, $sArcName, $sFileName, $sHide = 0, $sCompress = 5, $sRecurse = 1, $sIncludeFile = 0, $sExcludeFile = 0, _
		$sPassword = 0, $sWorkDir = 0)

	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	$sArcName = '"' & $sArcName & '"'
	$sFileName = '"' & $sFileName & '"'

	Local $iSwitch = ""

	If $sHide Then $iSwitch &= " -hide"

	$iSwitch &= " -mx" & $sCompress
	$iSwitch &= _RecursionSet($sRecurse)

	If $sIncludeFile Then $iSwitch &= _IncludeFileSet($sIncludeFile)

	If $sExcludeFile Then $iSwitch &= _ExcludeFileSet($sExcludeFile)

	If $sPassword Then $iSwitch &= " -p" & $sPassword
	If $sWorkDir Then $iSwitch &= " -w" & $sWorkDir

	Local $tOutBuffer = DllStructCreate("char[32768]")

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZip", _
			"hwnd", $hWnd, _
			"str", "d " & $sArcName & " " & $sFileName & " " & $iSwitch, _
			"ptr", DllStructGetPtr($tOutBuffer), _
			"int", DllStructGetSize($tOutBuffer))

	If $iFlagDll = 2 Then _7ZipShutdown()
	If Not $aRet[0] Then Return SetError(0, 0, DllStructGetData($tOutBuffer, 1))
	Return SetError(1, 0, 0)
EndFunc   ;==>_7ZipDelete

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZIPExtract
; Description ...: Extracts files from archive to the current directory or to the output directory
; Syntax.........: _7ZIPExtract($hWnd, $sArcName[, $sOutput = 0[, $sHide = 0[, $sOverwrite = 0[, $sRecurse = 1[, _
;				   				$sIncludeArc[, $sExcludeArc[, $sIncludeFile = 0[, $sExcludeFile = 0[, $sPassword = 0[, _
;								$sYes = 0]]]]]]]]]])
; Parameters ....: $hWnd         - Handle to parent or owner window
;				   $sArcName     - Archive file name
;				   $sOutput      - Output directory
;				   $sHide        - Use this switch if you want the CallBack function to be called
;				   $sOverwrite   - Overwrite mode:   0 - Overwrite All existing files without prompt, _
;												     1 - Skip extracting of existing files, _
;												     2 - Auto rename extracting file, _
;												     3 - auto rename existing file
;				   $sRecurse     - Recursion method: 0 - Disable recursion
;													 1 - Enable recursion
;													 2 - Enable recursion only for wildcard names
;				   $sIncludeArc  - Include archive filenames
;				   $sExcludeArc  - Exclude archive filenames
;				   $sIncludeFile - Include filenames, specifies filenames and wildcards or list file that specify processed files
;				   $sExcludeFile - Exclude filenames, specifies what filenames or (and) wildcards must be excluded from operation
;				   $sPassword    - Specifies password
;				   $Yes          - assume Yes on all queries
;
; Return values .: Success - Returns the string with results
;                  Failure - Returns 0 and and sets @error
;                  @Error  - 0 = No error.
;				   |1 = Function failed
;				   |2 = Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZIPExtract($hWnd, $sArcName, $sOutput = 0, $sHide = 0, $sOverwrite = 0, $sRecurse = 1, $sIncludeArc = 0, $sExcludeArc = 0, _
		$sIncludeFile = 0, $sExcludeFile = 0, $sPassword = 0, $sYes = 0)

	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	$sArcName = '"' & $sArcName & '"'

	Local $iSwitch = ""

	If $sOutput Then $iSwitch = ' -o"' & $sOutput & '"'
	If $sHide Then $iSwitch &= " -hide"

	$iSwitch &= _OverwriteSet($sOverwrite)
	$iSwitch &= _RecursionSet($sRecurse)

	If $sIncludeArc Then $iSwitch &= _IncludeArcSet($sIncludeArc)
	If $sExcludeArc Then $iSwitch &= _ExcludeArcSet($sExcludeArc)

	If $sIncludeFile Then $iSwitch &= _IncludeFileSet($sIncludeFile)
	If $sExcludeFile Then $iSwitch &= _ExcludeFileSet($sExcludeFile)

	If $sPassword Then $iSwitch &= " -p" & $sPassword
	If $sYes Then $iSwitch &= " -y"

	Local $tOutBuffer = DllStructCreate("char[32768]")

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZip", _
			"hwnd", $hWnd, _
			"str", "e " & $sArcName & " " & $iSwitch, _
			"ptr", DllStructGetPtr($tOutBuffer), _
			"int", DllStructGetSize($tOutBuffer))

	If $iFlagDll = 2 Then _7ZipShutdown()
	If Not $aRet[0] Then Return SetError(0, 0, DllStructGetData($tOutBuffer, 1))
	Return SetError(1, 0, 0)
EndFunc   ;==>_7ZIPExtract

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZIPExtractEx
; Description ...: Extracts files from archive with full paths to the current directory or to the output directory
; Syntax.........: _7ZIPExtract($hWnd, $sArcName[, $sOutput = 0[, $sHide = 0[, $sOverwrite = 0[, $sRecurse = 1[, _
;				   				$sIncludeArc[, $sExcludeArc[, $sIncludeFile = 0[, $sExcludeFile = 0[, $sPassword = 0[, _
;								$sYes = 0]]]]]]]]]])
; Parameters ....: $hWnd         - Handle to parent or owner window
;				   $sArcName     - Archive file name
;				   $sOutput      - Output directory
;				   $sHide        - Use this switch if you want the CallBack function to be called
;				   $sOverwrite   - Overwrite mode:   0 - Overwrite All existing files without prompt, _
;												     1 - Skip extracting of existing files, _
;												     2 - Auto rename extracting file, _
;												     3 - auto rename existing file
;				   $sRecurse     - Recursion method: 0 - Disable recursion
;													 1 - Enable recursion
;													 2 - Enable recursion only for wildcard names
;				   $sIncludeArc  - Include archive filenames
;				   $sExcludeArc  - Exclude archive filenames
;				   $sIncludeFile - Include filenames, specifies filenames and wildcards or list file that specify processed files
;				   $sExcludeFile - Exclude filenames, specifies what filenames or (and) wildcards must be excluded from operation
;				   $sPassword    - Specifies password
;				   $Yes          - assume Yes on all queries
;
; Return values .: Success - Returns the string with results
;                  Failure - Returns 0 and and sets @error
;                  @Error  - 0 = No error.
;				   |1 : Function failed
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipExtractEx($hWnd, $sArcName, $sOutput = 0, $sHide = 0, $sOverwrite = 0, $sRecurse = 1, $sIncludeArc = 0, _
		$sExcludeArc = 0, $sIncludeFile = 0, $sExcludeFile = 0, $sPassword = 0, $sYes = 0)

	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	$sArcName = '"' & $sArcName & '"'

	Local $iSwitch = ""

	If $sOutput Then $iSwitch = ' -o"' & $sOutput & '"'
	If $sHide Then $iSwitch &= " -hide"

	$iSwitch &= _OverwriteSet($sOverwrite)
	$iSwitch &= _RecursionSet($sRecurse)

	If $sIncludeArc Then $iSwitch &= _IncludeArcSet($sIncludeArc)
	If $sExcludeArc Then $iSwitch &= _ExcludeArcSet($sExcludeArc)

	If $sIncludeFile Then $iSwitch &= _IncludeFileSet($sIncludeFile)
	If $sExcludeFile Then $iSwitch &= _ExcludeFileSet($sExcludeFile)

	If $sPassword Then $iSwitch &= " -p" & $sPassword
	If $sYes Then $iSwitch &= " -y"

	Local $tOutBuffer = DllStructCreate("char[32768]")

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZip", _
			"hwnd", $hWnd, _
			"str", "x " & $sArcName & " " & $iSwitch, _
			"ptr", DllStructGetPtr($tOutBuffer), _
			"int", DllStructGetSize($tOutBuffer))

	If $iFlagDll = 2 Then _7ZipShutdown()
	If Not $aRet[0] Then Return SetError(0, 0, DllStructGetData($tOutBuffer, 1))
	Return SetError(1, 0, 0)
EndFunc   ;==>_7ZipExtractEx

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZIPUpdate
; Description ...: Update older files in the archive and add files that are new to the archive
; Syntax.........: _7ZIPUpdate($hWnd, $sArcName, $sFileName[, $sHide = 0[, $sCompress = 5[, $sRecurse = 1[, _
;				   			   $sIncludeFile = 0[, $sExcludeFile = 0[, $sPassword = 0[, $sSFX = 0[, $sWorkDir = 0]]]]]]]])
; Parameters ....: $hWnd         - Handle to parent or owner window
;				   $sArcName     - Archive file name
;				   $sFileName    - File names to archive up
;				   $sHide        - Use this switch if you want the CallBack function to be called
;				   $sCompress    - Compress level 0-9
;				   $sRecurse     - Recurse method: 0 - Disable recursion
;												   1 - Enable recursion
;												   2 - Enable recursion only for wildcard names
;				   $sIncludeFile - Include filenames, specifies filenames and wildcards or list file that specify processed files
;				   $sExcludeFile - Exclude filenames, specifies what filenames or (and) wildcards must be excluded from operation
;				   $sPassword    - Specifies password
;				   $sSFX         - Creates self extracting archive
;				   $sWorkDir     - Sets working directory for temporary base archive
;
; Return values .: Success - Returns the string with results
;                  Failure - Returns 0 and and sets @error
;                  @Error  - 0 = No error.
;				   |1 : Function failed
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipUpdate($hWnd, $sArcName, $sFileName, $sHide = 0, $sCompress = 5, $sRecurse = 1, $sIncludeFile = 0, $sExcludeFile = 0, _
		$sPassword = 0, $sSFX = 0, $sWorkDir = 0)

	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	$sArcName = '"' & $sArcName & '"'
	$sFileName = '"' & $sFileName & '"'

	Local $iSwitch = ""

	If $sHide Then $iSwitch &= " -hide"

	$iSwitch = " -mx" & $sCompress
	$iSwitch &= _RecursionSet($sRecurse)

	If $sIncludeFile Then $iSwitch &= _IncludeFileSet($sIncludeFile)
	If $sExcludeFile Then $iSwitch &= _ExcludeFileSet($sExcludeFile)

	If $sPassword Then $iSwitch &= " -p" & $sPassword & ' -mhe'
	If FileExists($sSFX) Then $iSwitch &= " -sfx" & $sSFX
	If $sWorkDir Then $iSwitch &= " -w" & $sWorkDir

	Local $tOutBuffer = DllStructCreate("char[32768]")

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZip", _
			"hwnd", $hWnd, _
			"str", "u " & $sArcName & " " & $sFileName & " " & $iSwitch, _
			"ptr", DllStructGetPtr($tOutBuffer), _
			"int", DllStructGetSize($tOutBuffer))

	If $iFlagDll = 2 Then _7ZipShutdown()
	If Not $aRet[0] Then Return SetError(0, 0, DllStructGetData($tOutBuffer, 1))
	Return SetError(1, 0, 0)
EndFunc   ;==>_7ZipUpdate

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipSetOwnerWindowEx
; Description ...: Appoints the call-back function in order to receive the information of the compressing/unpacking
; Syntax.........: _7ZipSetOwnerWindowEx($hWnd, $sProcFunc)
; Parameters ....: $hWnd      - Handle to parent or owner window
;				   $sProcFunc - The call-back function name
;
; Return values .: Success  - Returns 1
;                  Failure  - Returns 0 and set error
;                  @Error  - 0 = No error.
;				   |1 : Function failed
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipSetOwnerWindowEx($hWnd, $sProcFunc)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, 0)
	If $hArchiveProc Then DllCallbackFree($hArchiveProc)
	$hArchiveProc = DllCallbackRegister($sProcFunc, "int", "hwnd;uint;uint;ptr")
	If $hArchiveProc = 0 Then Return SetError(1, 0, 0)

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipSetOwnerWindowEx", _
			"hwnd", $hWnd, _
			"ptr", DllCallbackGetPtr($hArchiveProc))
	Return $aRet[0]
EndFunc   ;==>_7ZipSetOwnerWindowEx

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipKillOwnerWindowEx
; Description ...: Cancels a window owner
; Syntax.........: _7ZipKillOwnerWindowEx($hWnd)
; Parameters ....: $hWnd      - Handle to parent or owner window
;
; Return values .: Success  - Returns 1
;                  Failure  - Returns 0 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipKillOwnerWindowEx($hWnd)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, 0)
	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipKillOwnerWindowEx", _
			"hwnd", $hWnd)
	Return $aRet[0]
EndFunc   ;==>_7ZipKillOwnerWindowEx

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipOpenArchive
; Description ...: Opens a arcive file
; Syntax.........: _7ZipOpenArchive($sArcName)
; Parameters ....: hWnd      - Handle to parent or owner window
;				   $sArcName - Archive file name
;
; Return values .: Success   - Returns a archive handle
;                  Failure   - Returns 0 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipOpenArchive($hWnd, $sArcName)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, 0)
	Local $hArc = DllCall($hDLL_7ZIP, "hwnd", "SevenZipOpenArchive", "hwnd", $hWnd, "str", $sArcName, "int", 0)
	Return $hArc[0]
EndFunc   ;==>_7ZipOpenArchive

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipCloseArchive
; Description ...: Closes a previously opened archive handle
; Syntax.........: _7ZipCloseArchive($hArc)
; Parameters ....: $hArc - Archive handle
;
; Return values .: Success   - Returns 0
;                  Failure   - Returns -1 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipCloseArchive($hArc)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, -1)
	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipCloseArchive", "hwnd", $hArc)
	Return $aRet[0]
EndFunc   ;==>_7ZipCloseArchive

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipFindFirst
; Description ...: Returns a $INDIVIDUALINFO structure with information of the first finded file
; Syntax.........: _7ZipFindFirst($hArc, $sSearch)
; Parameters ....: $hArc    - Archive handle
;				   $sSearch - File search string. (wildcards are supported)
;
; Return values .: Success  - Returns a $INDIVIDUALINFO structure
;                  Failure  - Returns -1 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipFindFirst($hArc, $sSearch)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, -1)
	Local $INDIVIDUALINFO = DllStructCreate($tagINDIVIDUALINFO)

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipFindFirst", _
			"hwnd", $hArc, _
			"str", $sSearch, _
			"ptr", DllStructGetPtr($INDIVIDUALINFO))
	If $aRet[0] = -1 Then Return $aRet[0]
	Return $INDIVIDUALINFO
EndFunc   ;==>_7ZipFindFirst

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipFindNext
; Description ...: Returns a $tINDIVIDUALINFO structure according to a previous call to _7ZipFindFirst
; Syntax.........: _7ZipFindNext($hArc, $tINDIVIDUALINFO)
; Parameters ....: $hArc            - Archive handle
;				   $tINDIVIDUALINFO - The $tINDIVIDUALINFO structure
;
; Return values .: Success  - Returns a $INDIVIDUALINFO structure
;                  Failure  - Returns 0 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipFindNext($hArc, $tINDIVIDUALINFO)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, 0)
	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipFindNext", _
			"hwnd", $hArc, _
			"ptr", DllStructGetPtr($tINDIVIDUALINFO))
	If $aRet[0] = 0 Then Return $tINDIVIDUALINFO
EndFunc   ;==>_7ZipFindNext

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetFileName
; Description ...: Returns a file name
; Syntax.........: _7ZipGetFileName($hArc)
; Parameters ....: $hArc - Archive handle
;
; Return values .: Success - Returns a string with a file name
;                  Failure - Returns 0 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetFileName($hArc)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, 0)
	Local $tNameBuffer = DllStructCreate("char[" & $FNAME_MAX32 + 1 & "]")

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipGetFileName", _
			"hwnd", $hArc, _
			"ptr", DllStructGetPtr($tNameBuffer), _
			"int", DllStructGetSize($tNameBuffer))
	If $aRet[0] = 0 Then Return DllStructGetData($tNameBuffer, 1)
EndFunc   ;==>_7ZipGetFileName

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetArcOriginalSize
; Description ...: Returns a original size of files in an archive
; Syntax.........: _7ZipGetArcOriginalSize($hArc)
; Parameters ....: $hArc - Archive handle
;
; Return values .: Success - Returns a total size
;                  Failure - Returns -1 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetArcOriginalSize($hArc)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, -1)
	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipGetArcOriginalSize", _
			"hwnd", $hArc)
	Return $aRet[0]
EndFunc   ;==>_7ZipGetArcOriginalSize

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetArcCompressedSize
; Description ...: Returns a compressed size of files in an archive
; Syntax.........: _7ZipGetArcCompressedSize($hArc)
; Parameters ....: $hArc - Archive handle
;
; Return values .: Success - Returns a total size
;                  Failure - Returns -1 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetArcCompressedSize($hArc)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, -1)
	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipGetArcCompressedSize", _
			"hwnd", $hArc)
	Return $aRet[0]
EndFunc   ;==>_7ZipGetArcCompressedSize

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetArcRatio
; Description ...: Returns a compressing ratio
; Syntax.........: _7ZipGetArcRatio($hArc)
; Parameters ....: $hArc - Archive handle
;
; Return values .: Success - Returns a compressing ratio
;                  Failure - Returns -1 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetArcRatio($hArc)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, -1)
	Local $aRet = DllCall($hDLL_7ZIP, "short", "SevenZipGetArcRatio", _
			"hwnd", $hArc)
	Return $aRet[0]
EndFunc   ;==>_7ZipGetArcRatio

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetDate
; Description ...: Returns a date of files in an archive
; Syntax.........: _7ZipGetDate($hArc)
; Parameters ....: $hArc - Archive handle
;
; Return values .: Success - Returns a date in an MSDOS format
;                  Failure - Returns -1 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetDate($hArc)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, -1)
	Local $aRet = DllCall($hDLL_7ZIP, "short", "SevenZipGetDate", _
			"hwnd", $hArc)
	If $aRet[0] = -1 Then Return $aRet[0]
	Return "0x" & Hex($aRet[0], 4)
EndFunc   ;==>_7ZipGetDate

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetTime
; Description ...: Returns a time of files in an archive
; Syntax.........: _7ZipGetTime($hArc)
; Parameters ....: $hArc - Archive handle
;
; Return values .: Success - Returns a time in an MSDOS format
;                  Failure - Returns -1 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetTime($hArc)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, -1)
	Local $aRet = DllCall($hDLL_7ZIP, "short", "SevenZipGetTime", _
			"hwnd", $hArc)
	If $aRet[0] = -1 Then Return $aRet[0]
	Return "0x" & Hex($aRet[0], 4)
EndFunc   ;==>_7ZipGetTime

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetCRC
; Description ...: Returns a CRC of files in an archive
; Syntax.........: _7ZipGetCRC($hArc)
; Parameters ....: $hArc - Archive handle
;
; Return values .: Success - Returns a CRC
;                  Failure - Returns -1 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetCRC($hArc)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, -1)
	Local $aRet = DllCall($hDLL_7ZIP, "dword", "SevenZipGetCRC", _
			"hwnd", $hArc)
	Return $aRet[0]
EndFunc   ;==>_7ZipGetCRC

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetAttribute
; Description ...: Returns a attribute of files in an archive
; Syntax.........: _7ZipGetAttribute($hArc)
; Parameters ....: $hArc - Archive handle
;
; Return values .: Success - Returns attribute of the file
;                  Failure - Returns -1 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetAttribute($hArc)
	If $hDLL_7ZIP <= 0 Then Return SetError(2, 0, -1)
	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipGetAttribute", _
			"hwnd", $hArc)
	If $aRet[0] = -1 Then Return $aRet[0]
	Return "0x" & Hex($aRet[0], 2)
EndFunc   ;==>_7ZipGetAttribute

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetMethod
; Description ...: Returns a string with the method of compressing
; Syntax.........: _7ZipGetMethod($hArc)
; Parameters ....: $hArc - Archive handle
;
; Return values .: Success - Returns the method of compressing
;                  Failure - Returns -1 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetMethod($hArc)
	If $hDLL_7ZIP <= 0 Then Return SetError(1, 0, -1)
	Local $sBUFFER = DllStructCreate("char[8]")
	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipGetMethod", _
			"hwnd", $hArc, _
			"ptr", DllStructGetPtr($sBUFFER), _
			"int", DllStructGetSize($sBUFFER))
	If $aRet[0] <> 0 Then Return False
	Return DllStructGetData($sBUFFER, 1)
EndFunc   ;==>_7ZipGetMethod

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZIPCheckArchive
; Description ...: Checks archive files
; Syntax.........: _7ZIPCheckArchive($sArcName)
; Parameters ....: $sArcName - Archive file name
;
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipCheckArchive($sArcName)
	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipCheckArchive", _
			"str", $sArcName, _
			"int", 0)

	If $iFlagDll = 2 Then _7ZipShutdown()
	Return $aRet[0]
EndFunc   ;==>_7ZipCheckArchive

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetArchiveType
; Description ...: Returns the archive type
; Syntax.........: _7ZipGetArchiveType($sArcName)
; Parameters ....: $sArcName - Archive file name
;
; Return values .: Success - Returns 1 - ZIPtype
;									 2 - 7Ztype
;									 0 - Unknown type
;                  Failure - Returns -1 or sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetArchiveType($sArcName)
	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipGetArchiveType", _
			"str", $sArcName)

	If $iFlagDll = 2 Then _7ZipShutdown()
	Return $aRet[0]
EndFunc   ;==>_7ZipGetArchiveType

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetFileCount
; Description ...: Returns the archive files count
; Syntax.........: _7ZipGetFileCount($sArcName)
; Parameters ....: $sArcName - Archive file name
;
; Return values .: Success - Returns the number of files
;                  Failure - Returns 0 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetFileCount($sArcName)
	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipGetFileCount", _
			"str", $sArcName)

	If $iFlagDll = 2 Then _7ZipShutdown()
	Return $aRet[0]
EndFunc   ;==>_7ZipGetFileCount

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipConfigDialog
; Description ...: Shows a about dialog of the 7-zip32.dll
; Syntax.........: SevenZipConfigDialog($hWnd)
; Parameters ....: $hWnd   - Handle to parent or owner window
;
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipConfigDialog($hWnd)
	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipConfigDialog", _
			"hwnd", $hWnd, _
			"ptr", 0, _
			"int", 0)

	If $iFlagDll = 2 Then _7ZipShutdown()
	Return $aRet[0]
EndFunc   ;==>_7ZipConfigDialog

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipQueryFunctionList
; Description ...: Checks whether or not API function which is appointed with 7-zip32.dll
; Syntax.........: _7ZipQueryFunctionList($iFunction)
; Parameters ....: $iFunction - The unique numerical value of the function
;
; Return values .: Success - Returns 1
;                  Failure - Returns 0 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipQueryFunctionList($iFunction = 0)
	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	Local $aRet = DllCall($hDLL_7ZIP, "int", "SevenZipQueryFunctionList", _
			"int", $iFunction)

	If $iFlagDll = 2 Then _7ZipShutdown()
	Return $aRet[0]
EndFunc   ;==>_7ZipQueryFunctionList

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetVersion
; Description ...: Returns a version of the 7-zip32.dll
; Syntax.........: _7ZipGetVersion()
;
; Parameters ....: None
; Return values .: Success - The version number
;                  Failure - Returns 0 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetVersion()
	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	Local $aRet = DllCall($hDLL_7ZIP, "short", "SevenZipGetVersion")

	If $iFlagDll = 2 Then _7ZipShutdown()
	Return StringLeft($aRet[0], 1) & "." & StringTrimLeft($aRet[0], 1)
EndFunc   ;==>_7ZipGetVersion

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetSubVersion
; Description ...: Returns a sub-version of the 7-zip32.dll
; Syntax.........: _7ZipGetSubVersion()
;
; Parameters ....: None
; Return values .: Success - The sub-version number
;                  Failure - Returns 0 and sets @error
;                  @Error  - 0 = No error.
;				   |1 : NA
;				   |2 : Dll not started
;
; Author ........: R. Gilman (rasim)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetSubVersion()
	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	Local $aRet = DllCall($hDLL_7ZIP, "short", "SevenZipGetSubVersion")

	If $iFlagDll = 2 Then _7ZipShutdown()
	Return $aRet[0]
EndFunc   ;==>_7ZipGetSubVersion

; #FUNCTION# ====================================================================================================================
; Name...........: _7ZipGetFilesList
; Description ...: Returns an array of files and dir in an archive
; Syntax.........: _7ZipGetFilesList($hWnd, $sArcName)
; Parameters ....: $hWnd         - Handle to parent or owner window
;				   $sArcName     - Archive file name
;
; Return values .: Success - Returns an array of files and dir in an archive
;                  Failure - Returns 0 and set error
;                  @Error  - 0 = No error.
;				   |1 : Enable to open archive
;				   |2 : Dll not started
;
; Author ........: Tlem
; Modified.......:
; Remarks .......:
; Related .......: _7ZipOpenArchive, _7ZipCloseArchive, _7ZipGetFileCount, _7ZipFindFirst, _7ZipFindNext,
;				   _7ZipGetArcOriginalSize, _7ZipGetDate, _7ZipGetTime,
;				   _Get7zipStringAttribute, _OEMToAnsi, _7ZipDateTimeToStr
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _7ZipGetFilesList($hWnd, $sArcName)
	Local $iFlagDll = _7ZipControlStartup()
	If $iFlagDll = 0 Then Return SetError(2, 0, 0)

	Local $hArc = _7ZipOpenArchive($hWnd, $sArcName)
	If $hArc = 0 Then Return SetError(1, 0, 0)

	Local $szFileCount = _7ZipGetFileCount($sArcName)
	Local $aArcFilesList[$szFileCount + 1][4]
	Local $iDosDate, $iDosTime, $iCount = 1
	$aArcFilesList[0][0] = $szFileCount
	$aArcFilesList[0][1] = "Size"
	$aArcFilesList[0][2] = "Attribute"
	$aArcFilesList[0][3] = "Date and Time"


	Local $tINDIVIDUALINFO = _7ZipFindFirst($hArc, "*")
	If $tINDIVIDUALINFO = -1 Then Return SetError(1, 0, 0)
	$aArcFilesList[1][0] = _OEMToAnsi(DllStructGetData($tINDIVIDUALINFO, "szFileName"))
	$aArcFilesList[1][2] = _Get7zipStringAttribute($hArc)
	If Not StringInStr($aArcFilesList[1][2], "D") Then
		$aArcFilesList[1][1] = DllStructGetData($tINDIVIDUALINFO, "dwOriginalSize")
	EndIf
	$iDosDate = _7ZipGetDate($hArc)
	$iDosTime = _7ZipGetTime($hArc)
	$aArcFilesList[1][3] = _7ZipDateTimeToStr($iDosDate, $iDosTime)

	While 1
		$iCount += 1
		$tINDIVIDUALINFO = _7ZipFindNext($hArc, $tINDIVIDUALINFO)
		If $tINDIVIDUALINFO = 0 Then ExitLoop
		$aArcFilesList[$iCount][0] = _OEMToAnsi(DllStructGetData($tINDIVIDUALINFO, "szFileName"))
		$aArcFilesList[$iCount][2] = _Get7zipStringAttribute($hArc)
		If Not StringInStr($aArcFilesList[$iCount][2], "D") Then
			$aArcFilesList[$iCount][1] = DllStructGetData($tINDIVIDUALINFO, "dwOriginalSize")
		EndIf
		$iDosDate = _7ZipGetDate($hArc)
		$iDosTime = _7ZipGetTime($hArc)
		$aArcFilesList[$iCount][3] = _7ZipDateTimeToStr($iDosDate, $iDosTime)
	WEnd

	_7ZipCloseArchive($hArc)
	If $iFlagDll = 2 Then _7ZipShutdown()
	Return $aArcFilesList
EndFunc   ;==>_7ZipGetFilesList

; #FUNCTIONS FOR INTERNAL USE# ==================================================================================================
Func _RecursionSet($sVal)
	Switch $sVal
		Case 1
			Return " -r"
		Case 2
			Return " -r0"
		Case Else
			Return " -r-"
	EndSwitch
EndFunc   ;==>_RecursionSet

Func _IncludeFileSet($sVal)
	If StringInStr($sVal, "*") Then
		Return ' -i!"' & $sVal & '"'
	ElseIf StringLeft($sVal, 1) = "@" Then
		Return ' -i"' & $sVal & '"'
	Else
		Return ' -i!"' & $sVal & '"'
	EndIf
EndFunc   ;==>_IncludeFileSet

Func _ExcludeFileSet($sVal)
	If StringInStr($sVal, "*") Then
		Return ' -x!"' & $sVal & '"'
	ElseIf StringLeft($sVal, 1) = "@" Then
		Return ' -x"' & $sVal & '"'
	Else
		Return ' -x!"' & $sVal & '"'
	EndIf
EndFunc   ;==>_ExcludeFileSet

Func _OverwriteSet($sVal)
	Switch $sVal
		Case 0
			Return " -aoa"
		Case 1
			Return " -aos"
		Case 2
			Return " -aou"
		Case 3
			Return " -aot"
		Case Else
			Return " -aoa"
	EndSwitch
EndFunc   ;==>_OverwriteSet

Func _IncludeArcSet($sVal)
	If StringInStr($sVal, "*") Then
		Return ' -ai!"' & $sVal & '"'
	ElseIf StringLeft($sVal, 1) = "@" Then
		Return ' -ai"' & $sVal & '"'
	Else
		Return ' -ai!"' & $sVal & '"'
	EndIf
EndFunc   ;==>_IncludeArcSet

Func _ExcludeArcSet($sVal)
	If StringInStr($sVal, "*") Then
		Return ' -ax!"' & $sVal & '"'
	ElseIf StringLeft($sVal, 1) = "@" Then
		Return ' -ax"' & $sVal & '"'
	Else
		Return ' -ax!"' & $sVal & '"'
	EndIf
EndFunc   ;==>_ExcludeArcSet

Func _OEMToAnsi($sOEM)
	Local $a_AnsiFName = DllCall('user32.dll', 'Int', 'OemToChar', 'str', $sOEM, 'str', '')
	If @error = 0 Then
		Return $a_AnsiFName[2]
	Else
		Return $sOEM
	EndIf
EndFunc   ;==>_OEMToAnsi

Func _Get7zipStringAttribute($ArcHandle)
	Local $sAttrib
	Local $iAttrib = _7ZipGetAttribute($ArcHandle)

	If BitAND($iAttrib, 0X01) Then $sAttrib &= 'R'
	If BitAND($iAttrib, 0X02) Then $sAttrib &= 'H'
	If BitAND($iAttrib, 0X04) Then $sAttrib &= 'S'
	If BitAND($iAttrib, 0X08) Then $sAttrib &= 'L'
	If BitAND($iAttrib, 0X10) Then $sAttrib &= 'D'
	If BitAND($iAttrib, 0X20) Then $sAttrib &= 'A'
	If BitAND($iAttrib, 0X40) Then $sAttrib &= 'E'

	Return $sAttrib
EndFunc   ;==>_Get7zipStringAttribute

; This function is identical from _Date_Time_DOSDateTimeToStr function.
Func _7ZipDateTimeToStr($iDosDate, $iDosTime)
	Local $aDate[6]

	$aDate[0] = BitAND($iDosDate, 0x1F)
	$aDate[1] = BitAND(BitShift($iDosDate, 5), 0x0F)
	$aDate[2] = BitAND(BitShift($iDosDate, 9), 0x3F) + 1980
	$aDate[5] = BitAND($iDosTime, 0x1F) * 2
	$aDate[4] = BitAND(BitShift($iDosTime, 5), 0x3F)
	$aDate[3] = BitAND(BitShift($iDosTime, 11), 0x1F)

	Return StringFormat("%02d/%02d/%04d %02d:%02d:%02d", $aDate[0], $aDate[1], $aDate[2], $aDate[3], $aDate[4], $aDate[5])
EndFunc   ;==>_7ZipDateTimeToStr

; This function control if dll is opened and return a flag for autoclosing.
Func _7ZipControlStartup()
	If $hDLL_7ZIP <= 0 Then ; The dll not opened by _7ZipStartup()
		If _7ZipStartup() Then
			Return 2 ; dll opened by this fuction
		Else
			Return 0 ; Error on opening dll
		EndIf
	EndIf
	Return 1 ; The dll was already opened
EndFunc   ;==>_7ZipControlStartup
