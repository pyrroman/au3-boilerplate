#Region Header

#cs

    Title:          Management of Copying Files and Folders UDF Library for AutoIt3
    Filename:       Copy.au3
    Description:    Copies a files and folders without pausing a script
    Author:         Yashied
    Version:        1.4
    Requirements:   AutoIt v3.3 +, Developed/Tested on WindowsXP Pro Service Pack 2
    Uses:           None
    Notes:          This library requires Copy.dll (v1.4.x.x)

    Available functions:

	_Copy_Abort
    _Copy_CallbackDlg
	_Copy_CloseDll
	_Copy_CopyDir
	_Copy_CopyFile
	_Copy_GetAction
	_Copy_GetState
	_Copy_MoveDir
	_Copy_MoveFile
	_Copy_OpenDll
	_Copy_Pause

    Error codes:

    0 - No error
    1 - DLL not loaded
    2 - ID is incorrect or out of range
    3 - Thread is not yet initialized
    4 - Thread is now being used
    5 - DllCall() error
    6 - DLL already loaded
    7 - Incompatible DLL version
    8 - DLL not found

    Example1:

    #Include <EditConstants.au3>
    #Include <GUIConstantsEx.au3>

    #Include "Copy.au3"

    Opt('MustDeclareVars', 1)
    Opt('TrayAutoPause', 0)

    Global $hForm, $Input1, $Input2, $Button1, $Button2, $Button3, $Button4, $Data, $Msg, $Path, $Progress, $State, $Copy = False, $Pause = False
    Global $Source = '', $Destination = ''

    If Not _Copy_OpenDll() Then
        MsgBox(16, '', 'DLL not found.')
        Exit
    EndIf

    $hForm = GUICreate('MyGUI', 360, 163)
    GUICtrlCreateLabel('Source:', 14, 23, 58, 14)
    $Input1 = GUICtrlCreateInput('', 74, 20, 248, 19, BitOR($ES_AUTOHSCROLL, $ES_LEFT, $ES_MULTILINE))
    GUICtrlSetState(-1, $GUI_DISABLE)
    $Button1 = GUICtrlCreateButton('...', 326, 19, 21, 21)
    GUICtrlCreateLabel('Destination:', 14, 55, 58, 14)
    $Input2 = GUICtrlCreateInput('', 74, 52, 248, 19, BitOR($ES_AUTOHSCROLL, $ES_LEFT, $ES_MULTILINE))
    GUICtrlSetState(-1, $GUI_DISABLE)
    $Button2 = GUICtrlCreateButton('...', 326, 51, 21, 21)
    $Progress = GUICtrlCreateProgress(14, 94, 332, 16)
    $Button3 = GUICtrlCreateButton('Copy', 135, 126, 80, 21)
    $Button4 = GUICtrlCreateButton(';', 326, 126, 21, 21)
    GUICtrlSetFont(-1, 10, 400, 0, 'Webdings')
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUISetState()

    While 1
        If $Copy Then
            $State = _Copy_GetState()
            If $State[0] Then
                $Data = Round($State[1] / $State[2] * 100)
                If GUICtrlRead($Progress) <> $Data Then
                    GUICtrlSetData($Progress, $Data)
                EndIf
            Else
                Switch $State[5]
                    Case 0
                        GUICtrlSetData($Progress, 100)
                        MsgBox(64, '', 'File was successfully copied.', 0, $hForm)
                    Case 1235 ; ERROR_REQUEST_ABORTED
                        MsgBox(16, '', 'File copying was aborted.', 0, $hForm)
                    Case Else
                        MsgBox(16, '', 'File was not copied.' & @CR & @CR & $State[5], 0, $hForm)
                EndSwitch
                GUICtrlSetData($Progress, 0)
                GUICtrlSetState($Button1, $GUI_ENABLE)
                GUICtrlSetState($Button2, $GUI_ENABLE)
                GUICtrlSetState($Button4, $GUI_DISABLE)
                GUICtrlSetData($Button3, 'Copy')
                GUICtrlSetData($Button4, ';')
                $Copy = 0
            EndIf
        EndIf
        $Msg = GUIGetMsg()
        Switch $Msg
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $Button1
                $Path = FileOpenDialog('Select Source File', StringRegExpReplace($Source, '\\[^\\]*\Z', ''), 'All Files (*.*)', 3, StringRegExpReplace($Source, '^.*\\', ''), $hForm)
                If $Path Then
                    GUICtrlSetData($Input1, $Path)
                    $Source = $Path
                EndIf
            Case $Button2
                $Path = FileOpenDialog('Select Destination File', StringRegExpReplace($Destination, '\\[^\\]*\Z', ''), 'All Files (*.*)', 2, StringRegExpReplace($Source, '^.*\\', ''), $hForm)
                If $Path Then
                    GUICtrlSetData($Input2, $Path)
                    $Destination = $Path
                EndIf
            Case $Button3
                If $Copy Then
                    _Copy_Abort()
                Else
                    If (Not $Source) Or (Not $Destination) Then
                        MsgBox(16, '', 'The source and destination file names must be specified.', 0, $hForm)
                        ContinueLoop
                    EndIf
                    If FileExists($Destination) Then
                        If MsgBox(52, '', $Destination & ' already exists.' & @CR & @CR & 'Do you want to replace it?', 0, $hForm) <> 6 Then
                            ContinueLoop
                        EndIf
                    EndIf
                    GUICtrlSetState($Button1, $GUI_DISABLE)
                    GUICtrlSetState($Button2, $GUI_DISABLE)
                    GUICtrlSetState($Button4, $GUI_ENABLE)
                    GUICtrlSetData($Button3, 'Abort')
                    _Copy_CopyFile($Source, $Destination)
                    $Copy = 1
                EndIf
            Case $Button4
                $Pause = Not $Pause
                If $Pause Then
                    GUICtrlSetData($Button4, '4')
                Else
                    GUICtrlSetData($Button4, ';')
                EndIf
                _Copy_Pause($Pause)
        EndSwitch
    WEnd

    Example2:

    #Include <EditConstants.au3>
    #Include <GUIConstantsEx.au3>

    #Include "Copy.au3"

    Opt('MustDeclareVars', 1)
    Opt('TrayAutoPause', 0)

    Global $hForm, $Input1, $Input2, $Button1, $Button2, $Button3, $Button4, $Label, $Data, $Msg, $Path, $Progress, $State, $Copy = False, $Pause = False
    Global $Source = '', $Destination = ''

    If Not _Copy_OpenDll() Then
        MsgBox(16, '', 'DLL not found.')
        Exit
    EndIf

    $hForm = GUICreate('MyGUI', 360, 175)
    GUICtrlCreateLabel('Source:', 14, 23, 58, 14)
    $Input1 = GUICtrlCreateInput('', 74, 20, 248, 19, BitOR($ES_AUTOHSCROLL, $ES_LEFT, $ES_MULTILINE))
    GUICtrlSetState(-1, $GUI_DISABLE)
    $Button1 = GUICtrlCreateButton('...', 326, 19, 21, 21)
    GUICtrlCreateLabel('Destination:', 14, 55, 58, 14)
    $Input2 = GUICtrlCreateInput('', 74, 52, 248, 19, BitOR($ES_AUTOHSCROLL, $ES_LEFT, $ES_MULTILINE))
    GUICtrlSetState(-1, $GUI_DISABLE)
    $Button2 = GUICtrlCreateButton('...', 326, 51, 21, 21)
    $Label = GUICtrlCreateLabel('',14, 91, 332, 14)
    $Progress = GUICtrlCreateProgress(14, 106, 332, 16)
    $Button3 = GUICtrlCreateButton('Copy', 135, 138, 80, 21)
    $Button4 = GUICtrlCreateButton(';', 326, 138, 21, 21)
    GUICtrlSetFont(-1, 10, 400, 0, 'Webdings')
    GUICtrlSetState(-1, $GUI_DISABLE)
    GUISetState()

    While 1
        If $Copy Then
            $State = _Copy_GetState()
            If $State[0] Then
                If $State[0] = -1 Then
                    ; Preparing
                Else
                    $Data = Round($State[1] / $State[2] * 100)
                    If GUICtrlRead($Progress) <> $Data Then
                        GUICtrlSetData($Progress, $Data)
                    EndIf
                    $Data = StringRegExpReplace($State[6], '^.*\\', '')
                    If GUICtrlRead($Label) <> $Data Then
                        GUICtrlSetData($Label, $Data)
                    EndIf
                EndIf
            Else
                Switch $State[5]
                    Case 0
                        GUICtrlSetData($Progress, 100)
                        MsgBox(64, '', 'Folder was successfully copied.', 0, $hForm)
                    Case 1235 ; ERROR_REQUEST_ABORTED
                        MsgBox(16, '', 'Folder copying was aborted.', 0, $hForm)
                    Case Else
                        MsgBox(16, '', 'Folder was not copied.' & @CR & @CR & $State[5], 0, $hForm)
                EndSwitch
                GUICtrlSetState($Button1, $GUI_ENABLE)
                GUICtrlSetState($Button2, $GUI_ENABLE)
                GUICtrlSetState($Button4, $GUI_DISABLE)
                GUICtrlSetData($Progress, 0)
                GUICtrlSetData($Label, '')
                GUICtrlSetData($Button3, 'Copy')
                GUICtrlSetData($Button4, ';')
                $Copy = 0
            EndIf
        EndIf
        $Msg = GUIGetMsg()
        Switch $Msg
            Case $GUI_EVENT_CLOSE
                ExitLoop
            Case $Button1
                $Path = FileSelectFolder('Select source folder that to be copied.', '', 2, $Source, $hForm)
                If $Path Then
                    GUICtrlSetData($Input1, $Path)
                    $Source = $Path
                EndIf
            Case $Button2
                $Path = FileSelectFolder('Select destination folder in which will be copied the source directory.', '', 2, $Destination, $hForm)
                If $Path Then
                    GUICtrlSetData($Input2, $Path)
                    $Destination = $Path
                EndIf
            Case $Button3
                If $Copy Then
                    _Copy_Abort()
                Else
                    If (Not $Source) Or (Not $Destination) Then
                        MsgBox(16, '', 'The source and destination folders must be specified.', 0, $hForm)
                        ContinueLoop
                    EndIf
                    $Path = $Destination & '\' & StringRegExpReplace($Source, '^.*\\', '')
                    If FileExists($Path) Then
                        If MsgBox(51, 'Copy', $Path & ' already exists.' & @CR & @CR & 'Do you want to merge folders?', 0, $hForm) <> 6 Then
                            ContinueLoop
                        EndIf
                    EndIf
                    GUICtrlSetState($Button1, $GUI_DISABLE)
                    GUICtrlSetState($Button2, $GUI_DISABLE)
                    GUICtrlSetState($Button4, $GUI_ENABLE)
                    GUICtrlSetData($Label, 'Preparing...')
                    GUICtrlSetData($Button3, 'Abort')
                    _Copy_CopyDir($Source, $Path, 0, 0, 0, '_Copy_CallbackDlg', $hForm)
                    $Copy = 1
                EndIf
            Case $Button4
                $Pause = Not $Pause
                If $Pause Then
                    GUICtrlSetData($Button4, '4')
                Else
                    GUICtrlSetData($Button4, ';')
                EndIf
                _Copy_Pause($Pause)
        EndSwitch
    WEnd

#ce

#Include-once

#EndRegion Header

#Region Global Variables and Constants

#cs

Global Const $COPY_FILE_ALLOW_DECRYPTED_DESTINATION = 0x0008
Global Const $COPY_FILE_COPY_SYMLINK = 0x0800
Global Const $COPY_FILE_FAIL_IF_EXISTS = 0x0001
Global Const $COPY_FILE_NO_BUFFERING = 0x1000
Global Const $COPY_FILE_OPEN_SOURCE_FOR_WRITE = 0x0004
Global Const $COPY_FILE_RESTARTABLE = 0x0002

Global Const $MOVE_FILE_COPY_ALLOWED = 0x0002
Global Const $MOVE_FILE_CREATE_HARDLINK = 0x0010
Global Const $MOVE_FILE_DELAY_UNTIL_REBOOT = 0x0004
Global Const $MOVE_FILE_FAIL_IF_NOT_TRACKABLE = 0x0020
Global Const $MOVE_FILE_REPLACE_EXISTING = 0x0001
Global Const $MOVE_FILE_WRITE_THROUGH = 0x0008

#ce

Global Const $COPY_OVERWRITE_YES = 0x00000001
Global Const $COPY_OVERWRITE_NO = 0x00000000
Global Const $COPY_OVERWRITE_ABORT = 0x00000002
Global Const $COPY_OVERWRITE_ALL = 0x00001000
Global Const $COPY_OVERWRITE_CALLBACK = 0x10000000
Global Const $COPY_OVERWRITE_ERROR = 0xFFFFFFFF

#EndRegion Global Variables and Constants

#Region Local Variables and Constants

Global Const $tagCALLBACKSTATUS = _
		'UINT64 TotalBytesTransferred;' & _
		'UINT64 TotalSize;' & _
		'UINT64 FileBytesTransferred;' & _
		'UINT64 FileSize;' & _
		'INT    Synchronize;' & _
		'INT    Pause;' & _
		'INT    Abort;' & _
		'INT    SystemErrorCode;' & _
		'INT    Progress;' & _
		'INT    Callback;' & _
		'INT    Result;' & _
		'INT    Reserved;' & _
		'WCHAR  Source[512];' & _
		'WCHAR  Destination[512];'

#cs

$cpSlot[i][0]   - CALLBACKSTATUS structure
       [i][1]   - User function
       [i][2]   - User data
       [i][3]   - Action (0 - _Copy_CopyDir(); 1 - _Copy_CopyFile(); 2 - _Copy_MoveDir(); 3 - _Copy_MoveFile())
       [i][4]   - Reserved

#ce

Global $cpSlot[256][5]
Global $cpCall = 0
Global $cpPrevent = 1
Global $cpDLL = -1

#EndRegion Local Variables and Constants

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_Abort
; Description....: Aborts a process of copying or moving files.
; Syntax.........: _Copy_Abort ( [$iID] )
; Parameters.....: $iID    - The slot identifier that has been specified in the _Copy_Copy... or _Copy_Move... funtions. If this
;                            parameter is (-1), all running processes will be aborted.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the copying or moving files was completed, the function has no effect.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_Abort($iID = 0)
	If $cpDLL = -1 Then
		Return SetError(1, 0, 0)
	EndIf
	If (Not IsNumber($iID)) Or ($iID < -1) Or ($iID > UBound($cpSlot) - 1) Then
		Return SetError(2, 0, 0)
	EndIf
	If $iID = -1 Then
		For $i = 0 To UBound($cpSlot) - 1
			If (IsDllStruct($cpSlot[$i][0])) And (DllStructGetData($cpSlot[$i][0], 'Progress')) Then
				DllStructSetData($cpSlot[$i][0], 'Abort', 1)
				DllStructSetData($cpSlot[$i][0], 'Pause', 0)
				While DllStructGetData($cpSlot[$i][0], 'Progress')
					Sleep(10)
				WEnd
			EndIf
		Next
	Else
		If Not IsDllStruct($cpSlot[$iID][0]) Then
			Return SetError(3, 0, 0)
		EndIf
		If DllStructGetData($cpSlot[$iID][0], 'Progress') Then
			DllStructSetData($cpSlot[$iID][0], 'Abort', 1)
			DllStructSetData($cpSlot[$iID][0], 'Pause', 0)
			While DllStructGetData($cpSlot[$iID][0], 'Progress')
				Sleep(10)
			WEnd
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_Copy_Abort

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_CallbackDlg
; Description....: Displays a dialog to confirm overwriting the existing file.
; Syntax.........: _Copy_CallbackDlg ( $aState, $iID, $hParent )
; Parameters.....: $aState  - An array containing the current copying status information, same as retured by _Copy_GetState()
;                             function when $iIndex parameter is set to (-1).
;                  $iID     - The current slot identifier that using in the _Copy_CopyDir() or _Copy_MoveDir() funtions.
;                  $hParent - A handle to the parent window, or zero.
; Return values..:
; Author.........: Yashied
; Modified.......:
; Remarks........: The _Copy_CallbackDlg() is a default callback function that can be using when you call the _Copy_CopyDir()
;                  or _Copy_MoveDir() function (see its description). You cannot use _Copy_CallbackDlg() directly. This function
;                  will be called automatically when conflicts occur in the process of copying or moving files. To use this
;                  function, just specify its name when calling the _Copy_CopyDir() or _Copy_MoveDir(). For example:
;
;                  _Copy_MoveDir("C:\Source", "D:\Destination", BitOR($MOVE_FILE_COPY_ALLOWED, $MOVE_FILE_REPLACE_EXISTING), 0, 0, "_Copy_CallbackDlg")
;
;                  or
;
;                  _Copy_CopyDir("C:\Source", "D:\Destination", 0, 0, 0, "_Copy_CallbackDlg")
;
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_CallbackDlg($aState, $iID, $hParent)

	If $cpPrevent Then
		Return SetError(0xDEAD, 0xBEEF, $COPY_OVERWRITE_ERROR)
	EndIf

	Local $hDlg, $hBtn, $Button[4], $Icon[2]
	Local $hWnd, $hDC, $hFile, $hFont, $hPrev, $Data, $Date, $Ret, $Time, $Title
	Local $hIcon[2] = [0, 0], $hDefault = 0, $Result = 0
	Local $Opt1 = Opt('GUIOnEventMode', 0)
	Local $Opt2 = Opt('GUICloseOnESC', 1)
	Local $tSHFI = DllStructCreate('ptr;int;dword;wchar[260];wchar[80]')
	Local $tSHSI = DllStructCreate('dword;ptr;int;int;wchar[260];')
	Local $tData = DllStructCreate('wchar[1024]')
	Local $pData = DllStructGetPtr($tData)
	Local $tSize = DllStructCreate('long[2]')
	Local $pSize = DllStructGetPtr($tSize)
	Local $tFT = DllStructCreate('dword[2]')
	Local $pFT = DllStructGetPtr($tFT)
	Local $tLT = DllStructCreate('dword[2]')
	Local $pLT = DllStructGetPtr($tLT)
	Local $tST = DllStructCreate('short[8]')
	Local $pST = DllStructGetPtr($tST)

	Switch _Copy_GetAction($iID)
		Case 0
			$Title = 'Copy File'
		Case 1
			$Title = 'Move File'
		Case Else

	EndSwitch
	If $hParent Then
		GUISetState(@SW_DISABLE, $hParent)
	EndIf
	$hDlg = GUICreate($Title, 442, 313, -1, -1, 0x80C80000, 0x00000001, $hParent)
	GUISetFont(8.5, 400, 0, 'MS Shell Dlg', $hDlg)
	GUISetBkColor(0xFFFFFF, $hDlg)
	GUICtrlCreateLabel('There is already a file with the same name in this location. Would you like to replace the existing file', 15, 15, 412, 42)
	GUICtrlCreateLabel('with this one?', 15, 142, 412, 14)
	For $i = 0 To 1
		Do
			$Ret = DllCall('shell32.dll', 'dword_ptr', 'SHGetFileInfoW', 'wstr', $aState[7 - $i], 'dword', 0, 'ptr', DllStructGetPtr($tSHFI), 'uint', DllStructGetSize($tSHFI), 'uint', 0x00000100)
			If (Not @error) And ($Ret[0]) Then
				$hIcon[$i] = DllStructGetData($tSHFI, 1)
				ExitLoop
			EndIf
			If $hDefault Then
				$hIcon[$i] = $hDefault
				ExitLoop
			EndIf
			DllStructSetData($tSHSI, 1, DllStructGetSize($tSHSI))
			$Ret = DllCall('shell32.dll', 'uint', 'SHGetStockIconInfo', 'int', 0, 'uint', 0x00000100, 'ptr', DllStructGetPtr($tSHSI))
			If (Not @error) And (Not $Ret[0]) Then
				$hDefault = DllStructGetData($tSHSI, 2)
			Else
				$Ret = DllCall('shell32.dll', 'int', 'SHExtractIconsW', 'wstr', @SystemDir & '\shell32.dll', 'int', 0, 'int', 32, 'int', 32, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)
				If (Not @error) And ($Ret[0]) Then
					$hDefault = $Ret[5]
				EndIf
			EndIf
			If $hDefault Then
				$hIcon[$i] = $hDefault
			EndIf
		Until 1
		$Icon[$i] = GUICtrlCreateIcon('', 0, 35, 64 + 113 * $i, 32, 32)
		GUICtrlSendMsg(-1, 0x0170, $hIcon[$i], 0)
		GUICtrlSetState(-1, 128)
		GUICtrlCreateLabel(StringRegExpReplace($aState[7 - $i], '^.*\\', ''), 76, 61 + 113 * $i, 351, 14)
		GUICtrlSetFont(-1, 8.5, 800, 0, 'Tahoma')
		GUICtrlCreateLabel('', 76, 77 + 113 * $i, 351, 14)
		DllStructSetData($tData, 1, $aState[7 - $i])
		DllCall('shlwapi.dll', 'none', 'PathRemoveFileSpecW', 'ptr', $pData)
		$hWnd = GUICtrlGetHandle(-1)
		$hFont = GUICtrlSendMsg(-1, 0x0031, 0, 0)
		$hDC = DllCall('user32.dll', 'hwnd', 'GetDC', 'hwnd', $hWnd)
		$hPrev = DllCall('gdi32.dll', 'ptr', 'SelectObject', 'ptr', $hDC[0], 'ptr', $hFont)
		DllCall('gdi32.dll', 'int', 'GetTextExtentPoint32W', 'ptr', $hDC[0], 'wstr', 'Location: ', 'int', 10, 'ptr', $pSize)
		DllCall('shlwapi.dll', 'int', 'PathCompactPathW', 'hwnd', $hDC[0], 'ptr', $pData, 'int', 351 - DllStructGetData($tSize, 1))
		DllCall('gdi32.dll', 'ptr', 'SelectObject', 'ptr', $hDC[0], 'ptr', $hPrev)
		DllCall('user32.dll', 'int', 'ReleaseDC', 'hwnd', $hWnd, 'ptr', $hDC[0])
		GUICtrlSetData(-1, 'Location: ' & DllStructGetData($tData, 1))
		GUICtrlCreateLabel('Size: ' & StringRegExpReplace(FileGetSize($aState[7 - $i]), '(?<=\d)(?=(\d{3})+\z)', ',') & ' bytes', 76, 93 + 113 * $i, 351, 14)
		$hFile = 0
		Do
			$Data = ''
			$Ret = DllCall('kernel32.dll', 'ptr', 'CreateFileW', 'wstr', $aState[7 - $i], 'dword', 0x80000000, 'dword', 0x06, 'ptr', 0, 'dword', 3, 'dword', 0, 'ptr', 0)
			If (@error) Or ($Ret[0] = Ptr(-1)) Then
				ExitLoop
			EndIf
			$hFile = $Ret[0]
			$Ret = DllCall('kernel32.dll', 'int', 'GetFileTime', 'ptr', $hFile, 'ptr', 0, 'ptr', 0, 'ptr', $pFT)
			If (@error) Or (Not $Ret[0]) Then
				ExitLoop
			EndIf
			$Ret = DllCall('kernel32.dll', 'int', 'FileTimeToLocalFileTime', 'ptr', $pFT, 'ptr', $pLT)
			If (@error) Or (Not $Ret[0]) Then
				ExitLoop
			EndIf
			$Ret = DllCall('kernel32.dll', 'int', 'FileTimeToSystemTime', 'ptr', $pLT, 'ptr', $pST)
			If (@error) Or (Not $Ret[0]) Then
				ExitLoop
			EndIf
			$Ret = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'ulong', 0x0400, 'dword', 0, 'ptr', $pST, 'ptr', 0, 'ptr', $pData, 'int', 1024)
			If (@error) Or (Not $Ret[0]) Then
				ExitLoop
			EndIf
			$Date = DllStructGetData($tData, 1)
			$Ret = DllCall('kernel32.dll', 'int', 'GetTimeFormatW', 'ulong', 0x0400, 'dword', 0, 'ptr', $pST, 'ptr', 0, 'ptr', $pData, 'int', 1024)
			If (@error) Or (Not $Ret[0]) Then
				ExitLoop
			EndIf
			$Time = DllStructGetData($tData, 1)
			$Data = $Date & ' ' & $Time
		Until 1
		If $hFile Then
			DllCall('kernel32.dll', 'int', 'CloseHandle', 'ptr', $hFile)
		EndIf
		GUICtrlCreateLabel('Date modified: ' & $Data, 76, 109 + 113 * $i, 351, 14)
	Next
	$hBtn = GUICreate('Copy File', 442, 48, 0, 265, 0x40010000, -1, $hDlg)
	GUISetFont(8.5, 400, 0, 'MS Shell Dlg', $hBtn)
	GUICtrlCreateGraphic(0, 0, 442, 1)
	GUICtrlSetBkColor(-1, 0xDFDFDF)
	$Button[0] = GUICtrlCreateCheckBox('Apply for the next conflicts', 12, 14, 144, 21)
	$Button[1] = GUICtrlCreateButton('Yes', 189, 12, 76, 25)
	$Button[2] = GUICtrlCreateButton('No', 272, 12, 76, 25)
	$Button[3] = GUICtrlCreateButton('Abort', 355, 12, 76, 25)
	GUICtrlSetState($Button[1], 768)
	GUISetState(@SW_SHOW, $hBtn)
	GUISetState(@SW_SHOW, $hDlg)
	While 1
		Switch GUIGetMsg()
			Case  0
				ContinueLoop
			Case -3
				ExitLoop
			Case $Button[1]
				$Result = $COPY_OVERWRITE_YES
				If GUICtrlRead($Button[0]) = 1 Then
					$Result = BitOR($Result, $COPY_OVERWRITE_ALL)
				EndIf
				ExitLoop
			Case $Button[2]
				$Result = $COPY_OVERWRITE_NO
				If GUICtrlRead($Button[0]) = 1 Then
					$Result = BitOR($Result, $COPY_OVERWRITE_ALL)
				EndIf
				ExitLoop
			Case $Button[3]
				$Result = $COPY_OVERWRITE_ABORT
				ExitLoop
		EndSwitch
	WEnd
	If $hParent Then
		GUISetState(@SW_ENABLE, $hParent)
	EndIf
	GUIDelete($hDlg)
	GUIDelete($hBtn)
	Opt('GUIOnEventMode', $Opt1)
	Opt('GUICloseOnESC', $Opt2)
	For $i = 0 To 1
		If $hIcon[$i] Then
			DllCall('user32.dll', 'int', 'DestroyIcon', 'ptr', $hIcon[$i])
		EndIf
	Next
	Return $Result
EndFunc   ;==>_Copy_CallbackDlg

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_CloseDll
; Description....: Closes a Copy.dll if it's no longer required.
; Syntax.........: _Copy_CloseDll ( )
; Parameters.....: None
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If any process of copying or moving files is not completed, the function fails. Use _Copy_Abort() before
;                  calling this function.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_CloseDll()

	Local $aResult

	If $cpDLL = -1 Then
		Return SetError(1, 0, 0)
	EndIf
	$aResult = DllCall($cpDLL, 'int', 'GetThreadCountInfo', 'ptr', 0, 'dword*', 0)
	If @error Then
		Return SetError(5, 0, 0)
	EndIf
	If $aResult[2] Then
		Return SetError(4, 0, 0)
	EndIf
	OnAutoItExitUnRegister('__CP_AutoItExit')
	DllClose($cpDLL)
	$cpDLL = -1
	Return 1
EndFunc   ;==>_Copy_CloseDll

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_CopyDir
; Description....: Copies a directory and all sub-directories and files to another directory.
; Syntax.........: _Copy_CopyDir ( $sSource, $sDestination [, $iFlags [, $iExFlags [, $iID [, $sCallbackFunc [, $lParam]]]]] )
; Parameters.....: $sSource       - The path to the source directory that to be copied.
;                  $sDestination  - The path to the destination directory.
;                  $iFlags        - The flags that specify how the file is to be copied. It can be one or more of the following values.
;
;                                   $COPY_FILE_ALLOW_DECRYPTED_DESTINATION
;                                   $COPY_FILE_COPY_SYMLINK
;                                   $COPY_FILE_FAIL_IF_EXISTS
;                                   $COPY_FILE_NO_BUFFERING
;                                   $COPY_FILE_OPEN_SOURCE_FOR_WRITE
;
;                  $iExFlags      - The extended flags that indicates what action should be taken if the file of the same name as the
;                                   currently copying file already exists in the destination directory. An action will be applied to
;                                   all conflicts in the current job. If a callback is used (see below), this parameter is ignored.
;                                   This parameter can be only one of the following values.
;
;                                   $COPY_OVERWRITE_YES
;                                   $COPY_OVERWRITE_NO
;                                   $COPY_OVERWRITE_ABORT
;
;                  $iID           - The slot identifier (ID) to receiving the copying status. The value of this parameter must be
;                                   between 0 and 255. If the slot with the specified ID is already in use, the function fails.
;                                   This slot can not be used as long as the copying will not be completed or will not be aborted
;                                   by using the _Copy_Abort(). The maximum number of copying files or folders at once is 256.
;                                   To retrieve the copying status, you must call the _Copy_GetState() with ID that has been
;                                   specified in this function.
;                  $sCallbackFunc - The name of the user-defined function to call when a file of the same name as the currently
;                                   copying file already exists in the destination directory. Because directory are copied recursively,
;                                   you cannot know in advance whether exist a file of the same name in the target directory.
;                                   This callback can help you decide whether to overwrite an existing file, or not.
;
;                                   You have to define user function with maximum 3 function parameters, otherwise the function
;                                   won't be called. For example:
;
;                                   Func MyCallbackDlg($aState, $iID, $lParam)
;                                   ...
;                                   EndFunc
;
;                                   When the user function is called then these 3 parameters have the following values:
;
;                                   $aState - An array containing the current copying status information, same as retured by _Copy_GetState() function.
;                                   $iID    - The identifier of the current slot.
;                                   $lParam - A data that was passed to the _Copy_CopyDir() function (see below).
;
;                                   To continue the copying process, the user function should return one of the following values that
;                                   indicate what action should be taken for a given file. Any other values will be ignored.
;
;                                   $COPY_OVERWRITE_YES
;                                   $COPY_OVERWRITE_NO
;                                   $COPY_OVERWRITE_ABORT
;
;                                   If you want to apply this action for other conflicts, and no longer receive this message, you
;                                   can combine this value with the following by using BitOR().
;
;                                   $COPY_OVERWRITE_ALL
;
;                                   WARNING: Do not call any _Copy_* functions from the user function, otherwise script may hang.
;
;                                   If the user function is not specified or is empty string, the action will be taken in accordance
;                                   with the value specified in $iExFlags parameter, and will be applied to all conflicts.
;                  $lParam        - Any data that must be passed to the user-defined function.
; Return values..: Success        - 1.
;                  Failure        - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function preserves extended attributes, OLE structured storage, NTFS file system alternate data streams,
;                  and file attributes. Security attributes for the existing file are not copied to the new file.
;
;                  If the $COPY_FILE_FAIL_IF_EXISTS flag is set, the copy operation fails if the target file already exists,
;                  even if you specify the $COPY_OVERWRITE_YES action in the $iExFlags parameter.
;
;                  If you use a callback function, you should periodically call from a loop the _Copy_GeyState() to utilize the
;                  status information, otherwise the copying process may be suspended. Additionally, the _Copy_GeyState() is
;                  responsible for calling the callback function.
;
;                  Also, you can use the _Copy_CallbackDlg() as a default callback function (see its description).
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_CopyDir($sSource, $sDestination, $iFlags = 0, $iExFlags = 0, $iID = 0, $sCallbackFunc = '', $lParam = 0)
	__CP_CopyMoveProgress($sSource, $sDestination, $iFlags, $iExFlags, $iID, 0, StringStripWS($sCallbackFunc, 3), $lParam)
	If @error Then
		Return SetError(@error, 0, 0)
	Else
		Return 1
	EndIf
EndFunc   ;==>_Copy_CopyDir

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_CopyFile
; Description....: Copies an existing file to a new file.
; Syntax.........: _Copy_CopyFile ( $sSource, $sDestination [, $iFlags [, $iID]] )
; Parameters.....: $sSource      - The name of the existing file.
;                  $sDestination - The new name of the file.
;                  $iFlags       - The flags that specify how the file is to be copied. It can be one or more of the following values.
;
;                                  $COPY_FILE_ALLOW_DECRYPTED_DESTINATION
;                                  $COPY_FILE_COPY_SYMLINK
;                                  $COPY_FILE_FAIL_IF_EXISTS
;                                  $COPY_FILE_NO_BUFFERING
;                                  $COPY_FILE_OPEN_SOURCE_FOR_WRITE
;
;                  $iID          - The slot identifier (ID) to receiving the copying status. The value of this parameter must be
;                                  between 0 and 255. If the slot with the specified ID is already in use, the function fails.
;                                  This slot can not be used as long as the copying will not be completed or will not be aborted
;                                  by using the _Copy_Abort(). The maximum number of copying files or folders at once is 256.
;                                  To retrieve the copying status, you must call the _Copy_GetState() with ID that has been
;                                  specified in this function.
; Return values..: Success       - 1.
;                  Failure       - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function preserves extended attributes, OLE structured storage, NTFS file system alternate data streams,
;                  and file attributes. Security attributes for the existing file are not copied to the new file.
;
;                  This function fails with ERROR_ACCESS_DENIED (5) if the destination file already exists and has the
;                  FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_READONLY attribute set.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_CopyFile($sSource, $sDestination, $iFlags = 0, $iID = 0)
	__CP_CopyMoveProgress($sSource, $sDestination, $iFlags, 0, $iID, 1, '', 0)
	If @error Then
		Return SetError(@error, 0, 0)
	Else
		Return 1
	EndIf
EndFunc   ;==>_Copy_CopyFile

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_GetAction
; Description....: Retrieves the current action associated with the specified slot identifier (ID).
; Syntax.........: _Copy_GetAction ( [$iID] )
; Parameters.....: $iID    - The slot identifier that has been specified in the _Copy_Copy... or _Copy_Move... funtions.
; Return values..: Success - The current action, it can be one of the following values:
;
;                            0 - The files are copying.
;                            1 - The files are moving.
;
;                  Failure - (-1) and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: The _Copy_GetAction() just allows you to determine a function (_Copy_Copy... or _Copy_Move...) which currently
;                  used the specified slot. This can be useful within the user-defined callback function.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_GetAction($iID = 0)
	If $cpDLL = -1 Then
		Return SetError(1, 0, -1)
	EndIf
	If (Not IsNumber($iID)) Or ($iID < 0) Or ($iID > UBound($cpSlot) - 1) Then
		Return SetError(2, 0, -1)
	EndIf
	If Not IsDllStruct($cpSlot[$iID][0]) Then
		Return SetError(3, 0, -1)
	EndIf
	Switch $cpSlot[$iID][3]
		Case 0, 1
			Return 0
		Case 2, 3
			Return 1
	EndSwitch
EndFunc   ;==>_Copy_GetAction

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_GetState
; Description....: Retrieves a copying status for the specified slot.
; Syntax.........: _Copy_GetState ( [$iID [, $iIndex]] )
; Parameters.....: $iID    - The slot identifier that has been specified in the _Copy_Copy... or _Copy_Move... funtions.
;                  $iIndex - An index of the parameter that is of interest. If this parameter is (-1) or not specified, the function
;                            returns an array of all possible parameters (see below).
; Return values..: Success - A value of the required parameter or an array containing the following information.
;
;                            [0] - The current state. (0 - Complete; (-1) - Prepare; 1 - Progress)
;                            [1] - Total bytes transferred.
;                            [2] - Total size, in bytes.
;                            [3] - The current file's bytes transferred.
;                            [4] - File size, in bytes.
;                            [5] - System error code. (0 - No error; (-1) - Internal DLL error; * - System error (see MSDN))
;                            [6] - The full path to the source file that in progress.
;                            [7] - The full path to the destination file that in progress.
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function reads the required values from the buffer, and does not affect the process of copying or moving.
;                  If you are not interested in additional information about copying, you can call _Copy_GetState() only to
;                  determine that the copying is complete. For example:
;
;                  While _Copy_GetState(0, 0)
;                  ...
;                  WEnd
;
;                  Even after copying is completed, the information about the last state in the buffer will be stored until this
;                  slot will not be used again.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_GetState($iID = 0, $iIndex = -1)

	Local $State[8], $Result

	If $cpDLL = -1 Then
		Return SetError(1, 0, 0)
	EndIf
	If (Not IsNumber($iID)) Or ($iID < 0) Or ($iID > UBound($cpSlot) - 1) Then
		Return SetError(2, 0, 0)
	EndIf
	If Not IsDllStruct($cpSlot[$iID][0]) Then
		Return SetError(3, 0, 0)
	EndIf
	While DllStructGetData($cpSlot[$iID][0], 'Synchronize')
		; Synchronization
	WEnd
	DllStructSetData($cpSlot[$iID][0], 'Synchronize', 1)
	$State[0] = DllStructGetData($cpSlot[$iID][0], 'Progress')
	$State[1] = DllStructGetData($cpSlot[$iID][0], 'TotalBytesTransferred')
	$State[2] = DllStructGetData($cpSlot[$iID][0], 'TotalSize')
	$State[3] = DllStructGetData($cpSlot[$iID][0], 'FileBytesTransferred')
	$State[4] = DllStructGetData($cpSlot[$iID][0], 'FileSize')
	$State[5] = DllStructGetData($cpSlot[$iID][0], 'SystemErrorCode')
	$State[6] = DllStructGetData($cpSlot[$iID][0], 'Source')
	$State[7] = DllStructGetData($cpSlot[$iID][0], 'Destination')
	DllStructSetData($cpSlot[$iID][0], 'Synchronize', 0)
	If __CP_Callback($State, $iID) Then
		Switch BitAND(DllStructGetData($cpSlot[$iID][0], 'Result'), 0xFF)
			Case $COPY_OVERWRITE_NO
				$State[1] += $State[4]
			Case $COPY_OVERWRITE_ABORT
				While DllStructGetData($cpSlot[$iID][0], 'Progress')
					Sleep(10)
				WEnd
			Case Else

		EndSwitch
	EndIf
	Switch $iIndex
		Case -1
			Return $State
		Case  0 To 7
			Return $State[$iIndex]
		Case Else
			Return SetError(2, 0, 0)
	EndSwitch
EndFunc   ;==>_Copy_GetState

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_MoveDir
; Description....: Moves a directory and all sub-directories and files to another directory.
; Syntax.........: _Copy_MoveDir ( $sSource, $sDestination [, $iFlags [, $iExFlags [, $iID [, $sCallbackFunc [, $lParam]]]]] )
; Parameters.....: $sSource       - The path to the source directory that to be moved.
;                  $sDestination  - The path to the destination directory.
;                  $iFlags        - The flags that specify how the file is to be moved. It can be one or more of the following values.
;
;                                   $MOVE_FILE_COPY_ALLOWED
;                                   $MOVE_FILE_CREATE_HARDLINK
;                                   $MOVE_FILE_FAIL_IF_NOT_TRACKABLE
;                                   $MOVE_FILE_REPLACE_EXISTING
;                                   $MOVE_FILE_WRITE_THROUGH
;
;                  $iExFlags      - The extended flags that indicates what action should be taken if the file of the same name as the
;                                   currently copying file already exists in the destination directory. An action will be applied to
;                                   all conflicts in the current job. If a callback is used (see below), this parameter is ignored.
;                                   This parameter can be only one of the following values.
;
;                                   $COPY_OVERWRITE_YES
;                                   $COPY_OVERWRITE_NO
;                                   $COPY_OVERWRITE_ABORT
;
;                  $iID           - The slot identifier (ID) to receiving the copying status. The value of this parameter must be
;                                   between 0 and 255. If the slot with the specified ID is already in use, the function fails.
;                                   This slot can not be used as long as the copying will not be completed or will not be aborted
;                                   by using the _Copy_Abort(). The maximum number of copying files or folders at once is 256.
;                                   To retrieve the copying status, you must call the _Copy_GetState() with ID that has been
;                                   specified in this function.
;                  $sCallbackFunc - The name of the user-defined function to call when a file of the same name as the currently
;                                   copying file already exists in the destination directory. Because directory are moved recursively,
;                                   you cannot know in advance whether exist a file of the same name in the target directory.
;                                   This callback can help you decide whether to overwrite an existing file, or not.
;
;                                   (See _Copy_CopyDir() for more information)
;
;                  $lParam        - Any data that must be passed to the user-defined function.
; Return values..: Success        - 1.
;                  Failure        - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If you move a directory within the same drive, it may take more time than moving this directory by using the
;                  _Copy_MoveFile(). If the source and destination directories located on a different drives and the
;                  $MOVEFILE_COPY_ALLOWED flag is not set, the function fails with ERROR_NOT_SAME_DEVICE (17).
;
;                  If the directory is to be moved to a different volume, the function simulates the move by using the CopyFile(),
;                  DeleteFile(), CreateDirectory(), and RemoveDirectory() API functions.
;
;                  If the $MOVE_FILE_REPLACE_EXISTING flag is not set, the move operation fails if the target file already exists,
;                  even if you specify the $COPY_OVERWRITE_YES action in the $iExFlags parameter.
;
;                  If you use a callback function, you should periodically call from a loop the _Copy_GeyState() to utilize the
;                  status information, otherwise the moving process may be suspended. Additionally, the _Copy_GeyState() is
;                  responsible for calling the callback function.
;
;                  Also, you can use the _Copy_CallbackDlg() as a default callback function (see its description).
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_MoveDir($sSource, $sDestination, $iFlags = 0, $iExFlags = 0, $iID = 0, $sCallbackFunc = '', $lParam = 0)
	__CP_CopyMoveProgress($sSource, $sDestination, $iFlags, $iExFlags, $iID, 2, StringStripWS($sCallbackFunc, 3), $lParam)
	If @error Then
		Return SetError(@error, 0, 0)
	Else
		Return 1
	EndIf
EndFunc   ;==>_Copy_MoveDir

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_MoveFile
; Description....: Moves a file or directory, including its children.
; Syntax.........: _Copy_MoveFile ( $sSource, $sDestination [, $iFlags [, $iID]] )
; Parameters.....: $sSource      - The name of the existing file or directory.
;                  $sDestination - The new name of the file or directory.
;                  $iFlags       - The flags that specify how the file is to be moved. It can be one or more of the following values.
;
;                                  $MOVE_FILE_COPY_ALLOWED
;                                  $MOVE_FILE_CREATE_HARDLINK
;                                  $MOVE_FILE_FAIL_IF_NOT_TRACKABLE
;                                  $MOVE_FILE_REPLACE_EXISTING
;                                  $MOVE_FILE_WRITE_THROUGH
;
;                  $iID          - The slot identifier (ID) to receiving the copying status. The value of this parameter must be
;                                  between 0 and 255. If the slot with the specified ID is already in use, the function fails.
;                                  This slot can not be used as long as the copying will not be completed or will not be aborted
;                                  by using the _Copy_Abort(). The maximum number of copying files or folders at once is 256.
;                                  To retrieve the copying status, you must call the _Copy_GetState() with ID that has been
;                                  specified in this function.
; Return values..: Success       - 1.
;                  Failure       - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: When moving a file, $sDestination can be on a different volume. If $sDestination is on another drive, you must
;                  set the $MOVEFILE_COPY_ALLOWED flag. When moving a directory, $sSource and $sDestination must be on the same
;                  drive.
;
;                  If the file is to be moved to a different volume, the function simulates the move by using the CopyFile()
;                  and DeleteFile() API functions.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_MoveFile($sSource, $sDestination, $iFlags = 0, $iID = 0)
	__CP_CopyMoveProgress($sSource, $sDestination, $iFlags, 0, $iID, 3, '', 0)
	If @error Then
		Return SetError(@error, 0, 0)
	Else
		Return 1
	EndIf
EndFunc   ;==>_Copy_MoveFile

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_OpenDll
; Description....: Opens a Copy.dll for use in this library.
; Syntax.........: _Copy_OpenDll ( [$sDLL] )
; Parameters.....: $sDLL   - The path to the DLL file to open. By default is used Copy.dll for 32-bit and Copy_x64.dll for 64-bit
;                            operating systems.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Note, the 64-bit executables cannot load 32-bit DLLs and vice-versa.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_OpenDll($sDLL = '')
	If $cpDLL <> -1 Then
		Return SetError(6, 0, 0)
	EndIf
	If Not $sDLL Then
		If @AutoItX64 Then
			$sDLL = @ScriptDir & '\Copy_x64.dll'
		Else
			$sDLL = @ScriptDir & '\Copy.dll'
		EndIf
	EndIf
	If Not FileExists($sDLL) Then
		Return SetError(8, 0, 0)
	EndIf
	If StringCompare(StringRegExpReplace(FileGetVersion($sDLL), '(\d+\.\d+).*', '\1'), '1.4') Then
		Return SetError(7, 0, 0)
	EndIf
	$cpDLL = DllOpen($sDLL)
	If $cpDLL = -1 Then
		Return SetError(1, 0, 0)
	EndIf
	OnAutoItExitRegister('__CP_AutoItExit')
	For $i = 0 To 255
		For $j = 0 To UBound($cpSlot, 2) - 1
			$cpSlot[$i][$j] = 0
		Next
	Next
	Return 1
EndFunc   ;==>_Copy_OpenDll

; #FUNCTION# ====================================================================================================================
; Name...........: _Copy_Pause
; Description....: Suspends and resumes a process of copying or moving files.
; Syntax.........: _Copy_Pause ( $fPause [, $iID] )
; Parameters.....: $fPause - Specifies whether to suspend or resume the copying files, valid values:
;                  |TRUE   - Suspend.
;                  |FALSE  - Resume.
;                  $iID    - The slot identifier that has been specified in the _Copy_Copy... or _Copy_Move... funtions. If this
;                            parameter is (-1), all running processes will be suspended or resumed.
; Return values..: Success - 1.
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the copying or moving files was completed, the function has no effect.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Copy_Pause($fPause, $iID = 0)
	If $cpDLL = -1 Then
		Return SetError(1, 0, 0)
	EndIf
	If (Not IsNumber($iID)) Or ($iID < -1) Or ($iID > UBound($cpSlot) - 1) Then
		Return SetError(2, 0, 0)
	EndIf
	If $iID = -1 Then
		For $i = 0 To UBound($cpSlot) - 1
			If (IsDllStruct($cpSlot[$i][0])) And (DllStructGetData($cpSlot[$i][0], 'Progress')) Then
				DllStructSetData($cpSlot[$i][0], 'Pause', $fPause)
			EndIf
		Next
	Else
		If DllStructGetData($cpSlot[$iID][0], 'Progress') Then
			DllStructSetData($cpSlot[$iID][0], 'Pause', $fPause)
		Else
			Return SetError(3, 0, 0)
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_Copy_Pause

#EndRegion Public Functions

#Region Internal Functions

Func __CP_Callback(ByRef $aState, $iID)

	Local $Result

	If Not DllStructGetData($cpSlot[$iID][0], 'Callback') Then
		$cpCall = 0
	Else
		If Not $cpCall Then
			$cpCall = 1
		Else
			$cpCall = 0
			$cpPrevent = 0
			$Result = Call($cpSlot[$iID][1], $aState, $iID, $cpSlot[$iID][2])
			$cpPrevent = 1
			If (@error = 0xDEAD) And (@extended = 0xBEEF) Then
				$Result = $COPY_OVERWRITE_ERROR
			Else
				$Result = BitAND($Result, BitOR($COPY_OVERWRITE_YES, $COPY_OVERWRITE_NO, $COPY_OVERWRITE_ABORT, $COPY_OVERWRITE_ALL))
			EndIf
			DllStructSetData($cpSlot[$iID][0], 'Result', $Result)
			DllStructSetData($cpSlot[$iID][0], 'Callback', 0)
			If $Result <> $COPY_OVERWRITE_ERROR Then
				Return 1
			EndIf
		EndIf
	EndIf
	Return 0
EndFunc   ;==>__CP_Callback

Func __CP_CopyMoveProgress($sSource, $sDestination, $iFlags, $iExFlags, $iID, $iAction, $sCallbackFunc, $lParam)

	Local $aResult

	If $cpDLL = -1 Then
		Return SetError(1, 0, 0)
	EndIf
	If (Not IsNumber($iID)) Or ($iID < 0) Or ($iID > UBound($cpSlot) - 1) Then
		Return SetError(2, 0, 0)
	EndIf
	If Not IsDllStruct($cpSlot[$iID][0]) Then
		$cpSlot[$iID][0] = DllStructCreate($tagCALLBACKSTATUS)
	Else
		If DllStructGetData($cpSlot[$iID][0], 'Progress') Then
			Return SetError(4, 0, 0)
		EndIf
	EndIf
	If Not $sCallbackFunc Then
		$iExFlags = BitAND($iExFlags, BitOR($COPY_OVERWRITE_YES, $COPY_OVERWRITE_NO, $COPY_OVERWRITE_ABORT))
		$cpSlot[$iID][1] = 0
		$cpSlot[$iID][2] = 0
	Else
		$iExFlags = $COPY_OVERWRITE_CALLBACK
		$cpSlot[$iID][1] = $sCallbackFunc
		$cpSlot[$iID][2] = $lParam
	EndIf
	$cpSlot[$iID][3] = $iAction
	Switch $iAction
		Case 0
			$aResult = DllCall($cpDLL, 'int', 'CopyDirProgress', 'wstr', $sSource, 'wstr', $sDestination, 'dword', $iFlags, 'dword', $iExFlags, 'ptr', DllStructGetPtr($cpSlot[$iID][0]))
		Case 1
			$aResult = DllCall($cpDLL, 'int', 'CopyFileProgress', 'wstr', $sSource, 'wstr', $sDestination, 'dword', $iFlags, 'ptr', DllStructGetPtr($cpSlot[$iID][0]))
		Case 2
			$aResult = DllCall($cpDLL, 'int', 'MoveDirProgress', 'wstr', $sSource, 'wstr', $sDestination, 'dword', $iFlags, 'dword', $iExFlags, 'ptr', DllStructGetPtr($cpSlot[$iID][0]))
		Case 3
			$aResult = DllCall($cpDLL, 'int', 'MoveFileProgress', 'wstr', $sSource, 'wstr', $sDestination, 'dword', $iFlags, 'ptr', DllStructGetPtr($cpSlot[$iID][0]))
	EndSwitch
	If (@error) Or (Not $aResult[0]) Then
		Return SetError(5, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>__CP_CopyMoveProgress

#EndRegion Internal Functions

#Region AutoIt Exit Functions

Func __CP_AutoItExit()
	_Copy_Abort(-1)
EndFunc   ;==>__CP_AutoItExit

#EndRegion AutoIt Exit Functions
