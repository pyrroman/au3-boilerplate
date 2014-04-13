#Region Header
; #INDEX# =======================================================================================================================
; Title .........: ExpFrame
; AutoIt Version : 3.3.6.0
; Language ......: English
; Description ...: Functions to create MS-Windows like Explorer in a Frame
; Author(s) .....: Beege
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _ExpFrame_Create:				      Creates an MS-Windows like Explorer in a Frame
; _ExpFrame_GUIGetMsg:			      Checks GuiGetMsg() message for events used by this UDF
; _ExpFrame_DirGetCurrent:		      Retrieves current directory of Explorer Frame
; _ExpFrame_DirSetCurrent:		      Sets current directory of Explorer Frame
; _ExpFrame_Refresh:			      Refreshes current directory
; _ExpFrame_Parent:				      Navigates Explorer Frame to parent directory
; _ExpFrame_Back:				      Navigates Explorer Frame to previous directory
; _ExpFrame_ShowHiddenFiles:	      Sets Explorer Frame  'show hidden files' flag
; _ExpFrame_WMNotify_Handler:	      Used to recive double click commands
; _ExpFrame_WMCOMMAND_Handler:	      Used to recive messages from combo boxes
; _ExpFrame_WMSIZE_Handler:		      Used to resize status bar. _GUIFrame_SIZE_Handler() will be called from this function.
; _ExpFrame_SaveColumns:		      Saves Column width values to .ini file
; _ExpFrame_RestoreColumns:		      Restores column widths from .ini file
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __DirSetCurrent:                    Sets current Directory
; __DirSetMyComputer:                 Sets current directory to "My Computer"
; __SetBackToolTip:                   Sets back button tooltip to directoy that explorer will navigate to when clicked
; __GetIndex:                         Returns the array index that the value is held in
; __WMNotify_DBClick:                 Used to handle DBClick message from WMNotify
; __GetExtType:						  Returns file type attribute
; __ComboHistoryAdd:                  Adds directory to combo box drop down menu
; __ComboMonitorEnterKey:             Function that watchs for enter key to be pressed
; __Columns_SetWidths:                Sets all column widths
; __Columns_GetWidths:                Returns a delimited string containing all column widths
; __Columns_Header_RClick:            Creates right click menu for choosing which columns to display
; __Columns_MCHeader_RClick:          Creates right click menu for choosing which columns to display when directory is "My Computer"
; __LVSort:                           Sorts columns
; __LVSortFinished:                   Called when sort is finished
; __LVSortGetColumnVal:               Tells me what kind of column is being sorted. (Size or Date)
; __LVSortGetColumnHeader:            Returns column header text
; __LVSortGetSubItemText:             Returns LV item sub text
; __LVSortCompareDates:               Compares formated filetimes
; __GetItemIndex:                     Returns List view item index. Used by __LVSort
; __GUICtrlListView_GetItemIcon:      Returns icon index being used by list item. Used by __LVSort
; __HistoryPush:                      Adds value to Directory History Stack
; __HistoryPoP:                       Pops value from stack.
; __FormatDate:                       Formats filetime to be DD/MM/YYYY am/pm
; __FormatSize:                       Formats size in bytes to size in kb,mb,gb
; __FormatUnSize:                     Formats size back to bytes from kb,mb,gb
; __GetFileIcon: 					  Returns handle to icon
; __AddExtIcontoIMGList:			  Adds icon to ImageList
; __GUIImageList_GetSystemImageList:  Returns system Imagelist
; __GUIImageList_GetFileIconIndex:    Returns file icon index
; __Extention_GetInfo:                Returns an array containing file type and icon index
; __Extention_AddtoArray:             Used to add extension information to extention array
; __FLTA:                             Returns directory file/folders list in an array
; ===============================================================================================================================
#EndRegion Header
#Region Includes
#include-once
#include <GuiConstantsEx.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>
#include <Date.au3>
#include <array.au3>
#include <File.au3>
#include <GuiMenu.au3>
#include <GuiImageList.au3>
#include <GuiStatusBar.au3>
#include <ComboConstants.au3>
#include <Misc.au3>
#include <GUIFrame.au3>
;Opt('MustDeclareVars', 1)
#EndRegion Includes

#Region Global Variables and Constants
Global Enum $g_LastCol, $g_bSet, $g_CurCol, $g_sColHeader, $g_iListIndex, $icolmax
Global $g_aColumnSort[$icolmax] = [-1, 0, -1, False, 0]

#cs
	$g_aColumnSort[$g_LastCol]		= Last column sorted
	$g_aColumnSort[$g_bSet]			= Flag to indicate that a sort is already in process
	$g_aColumnSort[$g_CurCol]		= Current column being sorted
	$g_aColumnSort[$g_sColHeader]	= Text of current column being sorted
	$g_aColumnSort[$g_iListIndex]	= index of listview we are currently sorting
#ce
Global $g_iRemovecount = 0

Global Enum $g_ListView = 1, $g_hListView, $g_hListHeader, $g_sCurrentDir, $g_sDirHistory, $g_iCol, $g_iColWidths, $g_iCompColWidths, _
		$g_iCompCol, $g_bHidden, $g_hStatusbar, $g_idButton, $g_idCombo, $g_hCombo, $g_sCombo, $g_hImageList, $g_iFolderIndex, _
		$g_oExtIndex, $LocMax
Global $g_aExpFrames[1][$LocMax]
$g_aExpFrames[0][0] = 0
Global $g_ComboMonitorIndex = 0

#cs
	$g_aExpFrames[0][0] 					= List Count
	$g_aExpFrames[0][1-6] 					= Nothing
	
	$g_aExpFrames[$i][$g_ListView] 			= listview ctrl ID
	$g_aExpFrames[$i][$g_hListView] 		= listview hwnd
	$g_aExpFrames[$i][$g_hListHeader] 		= listview header hwnd
	$g_aExpFrames[$i][$g_sCurrentDir] 		= Current Directory
	$g_aExpFrames[$i][$g_sDirHistory] 		= Directory History string
	$g_aExpFrames[$i][$g_iCol] 				= Columns-Value  :filesize = 1, modified = 2, Attributes = 4, Creation = 8, Accessed = 16
	$g_aExpFrames[$i][$g_iColWidths] 		= Column Widths
	$g_aExpFrames[$i][$g_iCompCol]			= Column-Value for my computer
	$g_aExpFrames[$i][$g_iCompColWidths] 	= Column Widths for my computer
	$g_aExpFrames[$i][$g_bHidden] 			= Show hidden files and folders flag
	$g_aExpFrames[$i][$g_hStatusbar] 		= Statusbar Handle
	$g_aExpFrames[$i][$g_idButton] 			= ctrl id to back button
	$g_aExpFrames[$i][$g_idCombo] 			= ctrl id to combo box
	$g_aExpFrames[$i][$g_hCombo] 			= Handle to combo box
	$g_aExpFrames[$i][$g_sCombo] 			= string holding directorys for combo box drop down menu
	$g_aExpFrames[$i][$g_hImageList] 		= Handle to imagelist
	$g_aExpFrames[$i][$g_iFolderIndex] 		= Index of folder icon in image list
	$g_aExpFrames[$i][$g_oExtIndex]			= Dictionary object
	$g_aExpFrames[$i][$g_sRemoveIndexs]		= String containing indexs to be removed from imagelist
#ce

Global $g_hUser32 = DllOpen('user32.dll')
Global $g_hShell32 = DllOpen('shell32.dll')
Global $g_hShlwapi = DllOpen('shlwapi.dll')

Global $g_oExtTypes = ObjCreate("Scripting.Dictionary")

OnAutoItExitRegister('__Release')

#EndRegion Global Variables and Constants


#Region Public Functions
; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_Create
; Description....:	Creates MS-Windows like Explorer in a Frame
; Syntax.........:	_ExpFrame_Create($hFrameHandle, $sStartDir = 'My Computer', $bShowHidden = False)
; Parameters.....:	$hFrameHandle - Handle to Frame
;					$sStartDir - [Optional] - Directoy to start in
;					$bShowHidden - [Optional] - Set true to show hidden files
; Return values..:	Success - Returns from Listview created in Frame
;					Failure - 0
; Author.........:	Beege
; Remarks........:	None
; ===============================================================================================================
Func _ExpFrame_Create($hFrameHandle, $sStartDir = 'My Computer', $bShowHidden = False)

	ReDim $g_aExpFrames[UBound($g_aExpFrames) + 1][UBound($g_aExpFrames, 2)]
	$g_aExpFrames[0][0] += 1
	Local $iIndex = $g_aExpFrames[0][0]

	Local $aClient = WinGetClientSize($hFrameHandle)

	$g_aExpFrames[$iIndex][$g_hStatusbar] = _GUICtrlStatusBar_Create($hFrameHandle)

	Local $iSBHeight = _GUICtrlStatusBar_GetHeight($g_aExpFrames[$iIndex][$g_hStatusbar])
	Local $iSBVBorderWidth = _GUICtrlStatusBar_GetBordersVert($g_aExpFrames[$iIndex][$g_hStatusbar])

	Local $iBHeight = 25, $iBWidth = 30
	$g_aExpFrames[$iIndex][$g_idButton] = GUICtrlCreateButton(' << ', 0, 0, $iBWidth, $iBHeight)
	$g_aExpFrames[$iIndex][$g_idCombo] = GUICtrlCreateCombo('', $iBWidth + 1, 3, $aClient[0] - ($iBWidth + 1), $iBHeight)
	GUICtrlSetResizing(-1, 2 + 32 + 4)
	$g_aExpFrames[$iIndex][$g_hCombo] = GUICtrlGetHandle($g_aExpFrames[$iIndex][$g_idCombo])

	$g_aExpFrames[$iIndex][$g_ListView] = GUICtrlCreateListView("Name", 0, $iBHeight + 1, $aClient[0], $aClient[1] - ($iSBHeight + $iSBVBorderWidth + 1) - $iBHeight)
	GUICtrlSetStyle(-1, $LVS_REPORT, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_DOUBLEBUFFER))
	GUICtrlSetResizing(-1, 102)
	GUICtrlRegisterListViewSort(-1, "__LVSort")
	$g_aExpFrames[$iIndex][$g_hListView] = GUICtrlGetHandle($g_aExpFrames[$iIndex][$g_ListView])

	$g_aExpFrames[$iIndex][$g_hListHeader] = HWnd(_GUICtrlListView_GetHeader($g_aExpFrames[$iIndex][$g_hListView]))
	$g_aExpFrames[$iIndex][$g_bHidden] = $bShowHidden
	_GUICtrlListView_SetColumnWidth($g_aExpFrames[$iIndex][$g_hListView], 0, 150)

	$g_aExpFrames[$iIndex][$g_oExtIndex] = ObjCreate("Scripting.Dictionary")
	$g_aExpFrames[$iIndex][$g_hImageList] = _GUIImageList_Create(16, 16, 6)
	_GUICtrlListView_SetImageList($g_aExpFrames[$iIndex][$g_ListView], $g_aExpFrames[$iIndex][$g_hImageList], 1)
	$g_aExpFrames[$iIndex][$g_iFolderIndex] = __AddExtIcontoIMGList($iIndex, @SystemDir, 0)

	$g_aExpFrames[$iIndex][$g_iCol] = 1 + 2 + 4 + 8 + 16 + 32
	$g_aExpFrames[$iIndex][$g_iColWidths] = '50;50;50;50;50;50'
	$g_aExpFrames[$iIndex][$g_iCompCol] = 1 + 2 + 4 + 8
	$g_aExpFrames[$iIndex][$g_iCompColWidths] = '75;75;75;75'

	If $sStartDir <> 'My Computer' And FileExists($sStartDir) Then
		$g_aExpFrames[$iIndex][$g_sCurrentDir] = $sStartDir
		__Columns_SetWidths($iIndex)
	Else
		$g_aExpFrames[$iIndex][$g_sCurrentDir] = 'My Computer'
		__Columns_SetWidths($iIndex, True)
	EndIf

	__DirSetCurrent($iIndex, $g_aExpFrames[$iIndex][$g_sCurrentDir], False)

	Return $g_aExpFrames[$iIndex][$g_ListView]

EndFunc   ;==>_ExpFrame_Create

; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_GUIGetMsg
; Description....:	Checks GuiGetMsg() message for events used by this UDF
; Syntax.........:	_ExpFrame_GUIGetMsg($nMsg)
; Parameters.....:	$nMsg - value returned from GUIGetMsg()
; Return values..:	None
; Author.........:	Beege
; Remarks........:	A call to this function must be added to your main loop.
; ===============================================================================================================
Func _ExpFrame_GUIGetMsg($nMsg)

	For $iIndex = 1 To $g_aExpFrames[0][0]
		Switch $nMsg
			Case $g_aExpFrames[$iIndex][$g_ListView]
				__LVSortFinished($nMsg)
			Case $g_aExpFrames[$iIndex][$g_idButton]
				_ExpFrame_Back($g_aExpFrames[$iIndex][$g_hListView])
		EndSwitch
	Next

EndFunc   ;==>_ExpFrame_GUIGetMsg
; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_DirGetCurrent
; Description....:	Retrieves current directory of Listview Explorer
; Syntax.........:	_ExpFrame_DirGetCurrent($CtrlID)
; Parameters.....:	$CtrlID - Ctrl Id returned from _ExpFrame_Create()
; Return values..:	Success - Current Directory
;					Failure - -1 and sets @error
; Author.........:	Beege
; Remarks........:	None
; ===============================================================================================================
Func _ExpFrame_DirGetCurrent($CtrlID)

	Local $iIndex = __GetIndex($CtrlID)
	If @error Then Return SetError(1, 0, -1)

	Return $g_aExpFrames[$iIndex][$g_sCurrentDir]

EndFunc   ;==>_ExpFrame_DirGetCurrent
; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_DirSetCurrent
; Description....:	Sets current directory of Listview Explorer
; Syntax.........:	_ExpFrame_DirSetCurrent($CtrlID, $sDirectory, $bPushHistory = True)
; Parameters.....:	$CtrlID - Ctrl Id returned from _ExpFrame_Create()
;					$sDirectory - The Directory to be set
;					$bPushHistory - [Optional] - Set to false if directory is NOT to be added to navigation History
; Return values..:	Success - 1
;					Failure - -1 and sets @error
; Author.........:	Beege
; Remarks........:	None
; ===============================================================================================================
Func _ExpFrame_DirSetCurrent($CtrlID, $sDirectory, $bPushHistory = True)

	Local $iIndex = __GetIndex($CtrlID)
	If @error Then Return SetError(1, 0, -1)

	Return __DirSetCurrent($iIndex, $sDirectory, $bPushHistory)

EndFunc   ;==>_ExpFrame_DirSetCurrent
; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_Refresh
; Description....:	Refreshes current directory
; Syntax.........:	_ExpFrame_Refresh($CtrlID)
; Parameters.....:	$CtrlID - Ctrl Id returned from _ExpFrame_Create()
; Return values..:	Success - 1
;					Failure - -1 and sets @error
; Author.........:	Beege
; Remarks........:	None
; ===============================================================================================================
Func _ExpFrame_Refresh($CtrlID)

	Local $iIndex = __GetIndex($CtrlID)
	If @error Then Return SetError(1, 0, -1)

	Return __DirSetCurrent($iIndex, $g_aExpFrames[$iIndex][$g_sCurrentDir], False)

EndFunc   ;==>_ExpFrame_Refresh
; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_Parent
; Description....:	Navigates Explorer Listview to parent directory
; Syntax.........:	_ExpFrame_Parent($CtrlID)
; Parameters.....:	$CtrlID - Ctrl Id returned from _ExpFrame_Create()
; Return values..:	Success - 1
;					Failure - -1 and sets @error
; Author.........:	Beege
; Remarks........:	None
; ===============================================================================================================
Func _ExpFrame_Parent($CtrlID)

	Local $iIndex = __GetIndex($CtrlID)
	If @error Then Return SetError(1, 0, -1)

	Local $sChangeDir, $aDirSplit = StringSplit($g_aExpFrames[$iIndex][$g_sCurrentDir], '\')

	If $aDirSplit[0] = 2 Then
		If $aDirSplit[2] = '' Then
			$sChangeDir = 'My Computer'
		Else
			$sChangeDir = $aDirSplit[1] & '\'
		EndIf
	Else
		For $i = 1 To $aDirSplit[0] - 1
			$sChangeDir &= $aDirSplit[$i] & '\'
		Next
		$sChangeDir = StringTrimRight($sChangeDir, 1)
	EndIf

	Return __DirSetCurrent($iIndex, $sChangeDir)

EndFunc   ;==>_ExpFrame_Parent
; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_Back
; Description....:	Navigates Explorer Listview to previous directory
; Syntax.........:	_ExpFrame_Back($CtrlID)
; Parameters.....:	$CtrlID - Ctrl Id returned from _ExpFrame_Create()
; Return values..:	Success - 1
;					Failure - -1 and sets @error:
;							  1 = invalid frame
;							  2 = History stack empty
;							  3 = Directory not exist
; Author.........:	Beege
; Remarks........:	None
; ===============================================================================================================
Func _ExpFrame_Back($CtrlID)

	Local $iIndex = __GetIndex($CtrlID)
	If @error Then Return SetError(1, 0, -1)

	Local $sPop = __HistoryPoP($g_aExpFrames[$iIndex][$g_sDirHistory])
	If @error Then Return SetError(2, 0, -1);History Stack is empty

	If $sPop <> 'My Computer' And Not FileExists($sPop) Then Return SetError(3, 0, -1)

	Return __DirSetCurrent($iIndex, $sPop, False)

EndFunc   ;==>_ExpFrame_Back
; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_ShowHiddenFiles
; Description....:	Sets Explorer Listview 'show hidden files' flag
; Syntax.........:	_ExpFrame_ShowHiddenFiles($CtrlID, $bShowHidden)
; Parameters.....:	$CtrlID - Ctrl Id returned from _ExpFrame_Create()
;					$bShowHidden - Set True to have Explorer Listview display hidden files
; Return values..:	Success - 1
;					Failure - 0 and sets @error
; Author.........:	Beege
; Remarks........:	None
; ===============================================================================================================
Func _ExpFrame_ShowHiddenFiles($CtrlID, $bShowHidden)

	Local $iIndex = __GetIndex($CtrlID)

	If $bShowHidden Or Not $bShowHidden Then
		$g_aExpFrames[$iIndex][$g_bHidden] = $bShowHidden
		Return 1
	EndIf

	Return SetError(1, @extended, 0);invalad Flag

EndFunc   ;==>_ExpFrame_ShowHiddenFiles

; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_WMNotify_Handler
; Description....:	Used to recive double click commands
; Syntax.........:	_ExpFrame_WMNotify_Handler($hWnd, $iMsg, $iwParam, $ilParam)
; Parameters.....:	None
; Return values..:	None
; Author.........:	Beege
; Remarks........:	If your script does not need WMNotify handler the just register this function. Otherwise pass
;					$hWnd, $iMsg, $iwParam, $ilParam from your WMNotify function.
; ===============================================================================================================
Func _ExpFrame_WMNotify_Handler($hWnd, $iMsg, $iwParam, $ilParam)

	Local $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	Local $iCode = DllStructGetData($tNMHDR, "Code")

	Switch $iCode
		Case $NM_DBLCLK
			Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
			Local $iIndex = __GetIndex($hWndFrom)
			If @error Then Return $GUI_RUNDEFMSG
			__WMNotify_DBClick($hWnd, $iMsg, $iwParam, $ilParam)
		Case $NM_RCLICK

			Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
			Local $iIndex = __GetIndex($hWndFrom)
			If @error Then Return $GUI_RUNDEFMSG
			If $hWndFrom = $g_aExpFrames[$iIndex][$g_hListHeader] Then __Columns_Header_RClick($iIndex)
	EndSwitch

	Return $GUI_RUNDEFMSG

EndFunc   ;==>_ExpFrame_WMNotify_Handler
; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_WMCOMMAND_Handler
; Description....:	Used to recive messages from combo boxes
; Syntax.........:	_ExpFrame_WMCOMMAND_Handler($hWnd, $iMsg, $iwParam, $hWndFrom)
; Parameters.....:	None
; Return values..:	None
; Author.........:	Beege
; Remarks........:	If your script does not need WMCommand handler the just register this function. Otherwise pass
;					$hWnd, $iMsg, $iwParam, $hWndFrom from your WMCommand function.
; ===============================================================================================================
Func _ExpFrame_WMCOMMAND_Handler($hWnd, $iMsg, $iwParam, $hWndFrom)

;~ 	Local $iIDFrom = _WinAPI_LoWord($iwParam)
	Local $iCode = _WinAPI_HiWord($iwParam)

	Switch $iCode
		Case $CBN_KILLFOCUS ; Sent when a combo box loses the keyboard focus
			AdlibUnRegister('__ComboMonitorEnterKey')
		Case $CBN_SELCHANGE ; Sent when the user changes the current selection in the list box of a combo box
			Local $iIndex = __GetIndex($hWndFrom)
			If Not @error Then
				__HistoryPush($g_aExpFrames[$iIndex][$g_sDirHistory], $g_aExpFrames[$iIndex][$g_sCurrentDir])
				__DirSetCurrent($iIndex, GUICtrlRead($g_aExpFrames[$iIndex][$g_idCombo]), True)
			EndIf
		Case $CBN_SETFOCUS ; Sent when a combo box receives the keyboard focus
			Local $iIndex = __GetIndex($hWndFrom)
			If Not @error Then
				$g_ComboMonitorIndex = $iIndex
				AdlibRegister('__ComboMonitorEnterKey', 75)
			EndIf
	EndSwitch

	Return $GUI_RUNDEFMSG

EndFunc   ;==>_ExpFrame_WMCOMMAND_Handler
; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_WMSIZE_Handler
; Description....:	Used to resize status bar. _GUIFrame_SIZE_Handler() will be called from this function.
; Syntax.........:	_ExpFrame_WMSIZE_Handler()
; Parameters.....:	None.
; Return values..:	None
; Author.........:	Beege
; Remarks........:	Call this function from your registered WMSize function
; ===============================================================================================================
Func _ExpFrame_WMSIZE_Handler($hWnd, $iMsg, $wParam, $lParam)

	_GUIFrame_SIZE_Handler($hWnd, $iMsg, $wParam, $lParam)

	For $i = 1 To $g_aExpFrames[0][0]
		_GUICtrlStatusBar_Resize($g_aExpFrames[$i][$g_hStatusbar])
	Next

	Return $GUI_RUNDEFMSG

EndFunc   ;==>_ExpFrame_WMSIZE_Handler

; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_SaveColumns
; Description....:	Saves Column width values to .ini file
; Syntax.........:	_ExpFrame_SaveColumns($CtrlID, $sKey, $sIniFile = False)
; Parameters.....:	$CtrlID - Ctrl Id returned from _ExpFrame_Create()
;					$sKey - The key name in the .ini file.
;					$sIniFile - [Optional] - full path of .ini file to write to.
; Return values..:	Success - 1
;					Failure - -1 and sets @error
; Author.........:	Beege
; Remarks........:	If no .ini file is specified, settings.ini file will be created in the script directory
; ===============================================================================================================
Func _ExpFrame_SaveColumns($CtrlID, $sKey, $sIniFile = False)

	Local $iIndex = __GetIndex($CtrlID)
	If @error Then Return SetError(1, 0, -1)

	If Not $sIniFile Then $sIniFile = @ScriptDir & '/settings.ini'
	If Not FileExists($sIniFile) Then _FileCreate($sIniFile)

	If $g_aExpFrames[$iIndex][$g_sCurrentDir] = 'My Computer' Then
		__Columns_GetWidths($iIndex, True)
	Else
		__Columns_GetWidths($iIndex)
	EndIf

	IniWrite($sIniFile, $sKey, 'LVCol_0', _GUICtrlListView_GetColumnWidth($g_aExpFrames[$iIndex][$g_hListView], 0))
	IniWrite($sIniFile, $sKey, 'LVColVal', $g_aExpFrames[$iIndex][$g_iCol])
	IniWrite($sIniFile, $sKey, 'LVColWidths', $g_aExpFrames[$iIndex][$g_iColWidths])
	IniWrite($sIniFile, $sKey, 'LVMCColVal', $g_aExpFrames[$iIndex][$g_iCompCol])
	IniWrite($sIniFile, $sKey, 'LVMCColWidths', $g_aExpFrames[$iIndex][$g_iCompColWidths])

	Return 1

EndFunc   ;==>_ExpFrame_SaveColumns
; #FUNCTION# ====================================================================================================
; Name...........:	_ExpFrame_RestoreColumns
; Description....:	Restores column widths
; Syntax.........:	_ExpFrame_RestoreColumns($CtrlID, $sKey, $sIniFile = False)
; Parameters.....:	$CtrlID - Ctrl Id returned from _ExpFrame_Create()
;					$sKey - The key name in the .ini file.
;					$sIniFile - [Optional] - full path of .ini file to write to. default = settings.ini
; Return values..:	Success - 1
;					Failure - -1 and sets @error
; Author.........:	Beege
; Remarks........:	If .ini file does not exist, setting.ini file will be created in the script directory with default values
; ===============================================================================================================
Func _ExpFrame_RestoreColumns($CtrlID, $sKey, $sIniFile = False)

	Local $iIndex = __GetIndex($CtrlID)
	If @error Then Return SetError(1, 0, -1)

	If Not $sIniFile Then $sIniFile = @ScriptDir & '/settings.ini'
	If Not FileExists($sIniFile) Then _FileCreate($sIniFile)

	_GUICtrlListView_SetColumnWidth($g_aExpFrames[$iIndex][$g_hListView], 0, Number(IniRead($sIniFile, $sKey, 'LVCol_0', '150')))
	$g_aExpFrames[$iIndex][$g_iCol] = Number(IniRead($sIniFile, $sKey, 'LVColVal', '3'))
	$g_aExpFrames[$iIndex][$g_iColWidths] = IniRead($sIniFile, $sKey, 'LVColWidths', '50;50;50;50;50;50')
	$g_aExpFrames[$iIndex][$g_iCompCol] = Number(IniRead($sIniFile, $sKey, 'LVMCColVal', '7'))
	$g_aExpFrames[$iIndex][$g_iCompColWidths] = IniRead($sIniFile, $sKey, 'LVMCColWidths', '75;75;75;75')

	_ExpFrame_Refresh($CtrlID)

	Return 1

EndFunc   ;==>_ExpFrame_RestoreColumns

#EndRegion Public Functions

#Region Internal Functions
#Region Navigation
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __DirSetCurrent
; Description ...: Sets Current Directory
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __DirSetCurrent($iIndex, $sDirectory, $bPushHistory = True)

	If $sDirectory = 'My Computer' Then
		If $bPushHistory Then __HistoryPush($g_aExpFrames[$iIndex][$g_sDirHistory], $g_aExpFrames[$iIndex][$g_sCurrentDir])
		__DirSetMyComputer($iIndex)
		Return
	EndIf

	If DriveStatus($sDirectory) = "NOTREADY" Then Return 0

	__Columns_GetWidths($iIndex)

	Local $sText = '0 Directorys, 0 Files [0 Bytes]'
	_GUICtrlStatusBar_SetText($g_aExpFrames[$iIndex][$g_hStatusbar], @TAB & $sText & @TAB, 0, 0)
	If Not GUICtrlSendMsg($g_aExpFrames[$iIndex][$g_ListView], $LVM_DELETEALLITEMS, 0, 0) Then ConsoleWrite('error deleteall' & @CRLF)
	Local $aList = __FLTA($sDirectory)
	_GUICtrlListView_BeginUpdate($g_aExpFrames[$iIndex][$g_hListView])
	Local $Parent = _GUICtrlListView_AddItem($g_aExpFrames[$iIndex][$g_ListView], "[..]", $g_aExpFrames[$iIndex][$g_iFolderIndex], 0)
	Local $UpdateTimer = TimerInit()
	Local $sFile, $sAttributes, $iIcon, $sItem, $iSize, $iTotalSize = 0, $iDirs = 0, $iFiles = 0
	Local $sExt, $aExt, $sType, $iItem, $bytes = 0, $iListIndex = 1
	If IsArray($aList) Then
		For $i = 1 To $aList[0]
			If TimerDiff($UpdateTimer) > 300 Then
				$sText = $iDirs & ' Directorys, ' & $iFiles & ' Files ' & '[' & __FormatSize($iTotalSize) & ']'
				_GUICtrlStatusBar_SetText($g_aExpFrames[$iIndex][$g_hStatusbar], @TAB & $sText & @TAB, 0, 0)
				$UpdateTimer = TimerInit()
			EndIf
			$sFile = $sDirectory & '\' & $aList[$i]
			$sAttributes = FileGetAttrib($sFile)
			If Not $g_aExpFrames[$iIndex][$g_bHidden] Then ;showhidden
				If StringInStr($sAttributes, 'H') > 0 Then ContinueLoop
			EndIf
			If StringInStr($sAttributes, 'D') > 0 Then
				$iIcon = $g_aExpFrames[$iIndex][$g_iFolderIndex]
				$sType = 'Folder'
				$iSize = ''
				$iDirs += 1
			Else
				$iFiles += 1
				$bytes = FileGetSize($sFile)
				$iSize = __FormatSize($bytes)
				$iTotalSize += $bytes
				$sExt = StringLower(StringTrimLeft($aList[$i], StringInStr($aList[$i], '.', 0) - 1))
				Local $oExtIndex = $g_aExpFrames[$iIndex][$g_oExtIndex]

				If Not $g_oExtTypes.Exists($sExt) Then $g_oExtTypes.Add($sExt, __GetExtType($sExt))
				$sType = $g_oExtTypes.Item($sExt)

				Switch $sExt
					Case '.exe', '.ico', '.lnk'
						$iIcon = __AddExtIcontoIMGList($iIndex, $sFile, 0, 0)
					Case Else
						If Not $oExtIndex.Exists($sExt) Then $oExtIndex.Add($sExt, __AddExtIcontoIMGList($iIndex, $sExt))
						$iIcon = $oExtIndex.Item($sExt)
				EndSwitch
			EndIf
			$sItem = ''
			If BitAND($g_aExpFrames[$iIndex][$g_iCol], 1) Then $sItem &= '|' & $iSize ;size
			If BitAND($g_aExpFrames[$iIndex][$g_iCol], 2) Then $sItem &= '|' & $sType ;type
			If BitAND($g_aExpFrames[$iIndex][$g_iCol], 4) Then $sItem &= '|' & __FormatDate(FileGetTime($sFile, 0));Modified
			If BitAND($g_aExpFrames[$iIndex][$g_iCol], 8) Then $sItem &= '|' & $sAttributes;Attributes
			If BitAND($g_aExpFrames[$iIndex][$g_iCol], 16) Then $sItem &= '|' & __FormatDate(FileGetTime($sFile, 1));Creation
			If BitAND($g_aExpFrames[$iIndex][$g_iCol], 32) Then $sItem &= '|' & __FormatDate(FileGetTime($sFile, 2));Accessed
			$iItem = GUICtrlCreateListViewItem('', $g_aExpFrames[$iIndex][$g_ListView])
			GUICtrlSetData($iItem, $sItem);Use GUICtrlSetData to avoid columns being auto resized.
			If Not _GUICtrlListView_SetItem($g_aExpFrames[$iIndex][$g_ListView], $aList[$i], $iListIndex, 0, $iIcon) Then ConsoleWrite('error seting icon' & @CRLF);set icon index
			$iListIndex += 1
		Next
	EndIf
	_GUICtrlListView_EndUpdate($g_aExpFrames[$iIndex][$g_hListView])

	$sText = $iDirs & ' Directorys, ' & $iFiles & ' Files ' & '[' & __FormatSize($iTotalSize) & ']'
	_GUICtrlStatusBar_SetText($g_aExpFrames[$iIndex][$g_hStatusbar], @TAB & $sText & @TAB, 0, 0)

	If $bPushHistory Then __HistoryPush($g_aExpFrames[$iIndex][$g_sDirHistory], $g_aExpFrames[$iIndex][$g_sCurrentDir])
	$g_aExpFrames[$iIndex][$g_sCurrentDir] = $sDirectory

	__ComboHistoryAdd($g_aExpFrames[$iIndex][$g_idCombo], $g_aExpFrames[$iIndex][$g_sCombo], $sDirectory)
	__SetBackToolTip($iIndex, $g_aExpFrames[$iIndex][$g_idButton])

	Return 1

EndFunc   ;==>__DirSetCurrent
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __DirSetMyComputer
; Description ...: Sets current directory to "My Computer"
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __DirSetMyComputer($iIndex)

	If $g_aExpFrames[$iIndex][$g_sCurrentDir] <> 'My Computer' Then __Columns_GetWidths($iIndex)
	$g_aExpFrames[$iIndex][$g_sCurrentDir] = 'My Computer'
	_GUICtrlListView_DeleteAllItems($g_aExpFrames[$iIndex][$g_hListView])
	__Columns_SetWidths($iIndex, True)

	Local $oExtIndex = $g_aExpFrames[$iIndex][$g_oExtIndex]
	Local $drives = DriveGetDrive("ALL")
	Local $iIcon, $sItem, $iItem, $sName, $iSpace, $iAvailable, $iTotalAvailable, $iTotalSize, $iIconIndex = 0
	For $i = 1 To $drives[0]

		$sName = DriveGetLabel($drives[$i] & '\') & ' (' & StringUpper($drives[$i]) & ')'
		$sItem = $sName
		$iIcon = __AddExtIcontoIMGList($iIndex, $drives[$i] & '\', 0)

		$iSpace = DriveSpaceTotal($drives[$i]) * 1048576;Space
		$iAvailable = DriveSpaceFree($drives[$i]) * 1048576; Avalible
		$iTotalSize += $iSpace
		$iTotalAvailable += $iAvailable

		If BitAND($g_aExpFrames[$iIndex][$g_iCompCol], 1) Then $sItem &= '|' & __FormatSize($iSpace)
		If BitAND($g_aExpFrames[$iIndex][$g_iCompCol], 2) Then $sItem &= '|' & __FormatSize($iAvailable)
		If BitAND($g_aExpFrames[$iIndex][$g_iCompCol], 4) Then $sItem &= '|' & DriveGetType($drives[$i]);type
		If BitAND($g_aExpFrames[$iIndex][$g_iCompCol], 8) And DriveStatus($drives[$i] & '\') = "NOTREADY" Then $sItem &= '|' & FileGetAttrib($drives[$i] & '\');Attributes

		$iItem = GUICtrlCreateListViewItem('', $g_aExpFrames[$iIndex][$g_ListView])
		GUICtrlSetData($iItem, $sItem);Use GUICtrlSetData to avoid columns being auto resized.
		_GUICtrlListView_SetItem($g_aExpFrames[$iIndex][$g_ListView], $sName, $iIconIndex, 0, $iIcon);set icon index
		$iIconIndex += 1
	Next

	_GUICtrlStatusBar_SetText($g_aExpFrames[$iIndex][$g_hStatusbar], @TAB & $drives[0] & ' Drives, ' & __FormatSize($iTotalAvailable) & ' Free of ' & __FormatSize($iTotalSize) & @TAB, 0, 0)
	__ComboHistoryAdd($g_aExpFrames[$iIndex][$g_idCombo], $g_aExpFrames[$iIndex][$g_sCombo], 'My Computer')

	Return 1

EndFunc   ;==>__DirSetMyComputer
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __SetBackToolTip
; Description ...: Sets back button tooltip to directoy that it will navigate to when clicked
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __SetBackToolTip($iIndex, $iButton)

	Local $sDir = __HistoryPoP($g_aExpFrames[$iIndex][$g_sDirHistory], False)
	If @error Then Return GUICtrlSetTip($iButton, 'Navigate Back')
	If $sDir = 'My Computer' Or StringLen($sDir) = 3 Then Return GUICtrlSetTip($iButton, 'Back to ' & $sDir)
	$sDir = StringTrimLeft($sDir, StringInStr($sDir, '\', 0, -1))
	GUICtrlSetTip($iButton, 'Back to ' & $sDir)

EndFunc   ;==>__SetBackToolTip
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __GetIndex
; Description ...: Returns the array index that the value is held in
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __GetIndex($hWnd)

	Local $i

	For $i = 1 To $g_aExpFrames[0][0]
		Switch $hWnd
			Case $g_aExpFrames[$i][$g_ListView], $g_aExpFrames[$i][$g_hListView], $g_aExpFrames[$i][$g_hListHeader], $g_aExpFrames[$i][$g_hCombo]
				Return $i
		EndSwitch
	Next

	Return SetError(1, 0, -1)

EndFunc   ;==>__GetIndex
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __WMNotify_DBClick
; Description ...: Used to handle DBClick message from WMNotify
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __WMNotify_DBClick($hWnd, $iMsg, $iwParam, $ilParam)

	Local $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))

	Local $iIndex = __GetIndex($hWndFrom)

	Local $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
	If @AutoItX64 Then
		Local $iItemIndex = DllStructGetData($tInfo, "SubItem")
	Else
		Local $iItemIndex = DllStructGetData($tInfo, "Index")
	EndIf

	Local $sChangeDir
	Local $sItemText = _GUICtrlListView_GetItemText($g_aExpFrames[$iIndex][$g_hListView], $iItemIndex)

	Select
		Case $sItemText = '[..]'
			Return _ExpFrame_Parent($hWndFrom)
		Case $g_aExpFrames[$iIndex][$g_sCurrentDir] = 'My Computer'
			$sChangeDir = StringMid($sItemText, StringInStr($sItemText, ':') - 1, 2) & '\'
			If DriveStatus($sChangeDir) = "NOTREADY" Then Return
			__Columns_GetWidths($iIndex, True)
			__Columns_SetWidths($iIndex)
		Case Else
			If StringRight($g_aExpFrames[$iIndex][$g_sCurrentDir], 1) = '\' Then
				$sChangeDir = $g_aExpFrames[$iIndex][$g_sCurrentDir] & $sItemText
			Else
				$sChangeDir = $g_aExpFrames[$iIndex][$g_sCurrentDir] & '\' & $sItemText
			EndIf
			If StringInStr(FileGetAttrib($sChangeDir), 'D') = 0 Then Return; not a directory
	EndSelect

	__DirSetCurrent($iIndex, $sChangeDir)

EndFunc   ;==>__WMNotify_DBClick
#EndRegion Navigation

#Region ComboBox Functions
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __ComboHistoryAdd
; Description ...: Adds directory to combo box drop down menu
; Author ........: Beege
; Remarks .......: Max of 9 directory shown. No duplicates will be added
;================================================================================================================================
Func __ComboHistoryAdd(ByRef $gui_combo, ByRef $sCombo, $item)

	Local $split = StringSplit($sCombo, '|')

	_ArraySearch($split, $item)
	If Not @error Then
		GUICtrlSetData($gui_combo, $item, $item)
		Return
	EndIf

	If $split[0] > 9 Then
		_ArrayDelete($split, 1)
		$sCombo = _ArrayToString($split, '|', 1) & '|' & $item
		GUICtrlSetData($gui_combo, '', $item)
		GUICtrlSetData($gui_combo, $sCombo, $item)
	Else
		$sCombo &= '|' & $item
		GUICtrlSetData($gui_combo, $item, $item)
	EndIf

EndFunc   ;==>__ComboHistoryAdd
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __ComboMonitorEnterKey
; Description ...: Function that watchs for enter key to be pressed
; Author ........: Beege
; Remarks .......: This function is only called when a combo box has focus
;================================================================================================================================
Func __ComboMonitorEnterKey()

	If _IsPressed("0D", $g_hUser32) Then
		Local $combo = GUICtrlRead($g_aExpFrames[$g_ComboMonitorIndex][$g_idCombo])
		If FileExists($combo) Then
			__HistoryPush($g_aExpFrames[$g_ComboMonitorIndex][$g_sDirHistory], $combo)
			__DirSetCurrent($g_ComboMonitorIndex, $combo, True)
		EndIf
	EndIf

EndFunc   ;==>__ComboMonitorEnterKey
#EndRegion ComboBox Functions

#Region Columns Functions
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __Columns_SetWidths
; Description ...: Sets all column widths
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __Columns_SetWidths($iIndex, $bMyComp = False)

	For $i = 1 To _GUICtrlListView_GetColumnCount($g_aExpFrames[$iIndex][$g_hListView])
		_GUICtrlListView_DeleteColumn($g_aExpFrames[$iIndex][$g_hListView], 1)
	Next

	If $bMyComp Then
		Local $aCompColumnWidths = StringSplit($g_aExpFrames[$iIndex][$g_iCompColWidths], ';')
		If BitAND($g_aExpFrames[$iIndex][$g_iCompCol], 1) Then _GUICtrlListView_AddColumn($g_aExpFrames[$iIndex][$g_hListView], 'Space', Int($aCompColumnWidths[1]))
		If BitAND($g_aExpFrames[$iIndex][$g_iCompCol], 2) Then _GUICtrlListView_AddColumn($g_aExpFrames[$iIndex][$g_hListView], 'Available', Int($aCompColumnWidths[2]))
		If BitAND($g_aExpFrames[$iIndex][$g_iCompCol], 4) Then _GUICtrlListView_AddColumn($g_aExpFrames[$iIndex][$g_hListView], 'Type', Int($aCompColumnWidths[3]))
		If BitAND($g_aExpFrames[$iIndex][$g_iCompCol], 8) Then _GUICtrlListView_AddColumn($g_aExpFrames[$iIndex][$g_hListView], 'Attributes', Int($aCompColumnWidths[4]))
	Else
		Local $aColumnWidths = StringSplit($g_aExpFrames[$iIndex][$g_iColWidths], ';')
		If BitAND($g_aExpFrames[$iIndex][$g_iCol], 1) Then _GUICtrlListView_AddColumn($g_aExpFrames[$iIndex][$g_hListView], 'Size', Int($aColumnWidths[1]))
		If BitAND($g_aExpFrames[$iIndex][$g_iCol], 2) Then _GUICtrlListView_AddColumn($g_aExpFrames[$iIndex][$g_hListView], 'Type', Int($aColumnWidths[2]))
		If BitAND($g_aExpFrames[$iIndex][$g_iCol], 4) Then _GUICtrlListView_AddColumn($g_aExpFrames[$iIndex][$g_hListView], 'Modified', Int($aColumnWidths[3]))
		If BitAND($g_aExpFrames[$iIndex][$g_iCol], 8) Then _GUICtrlListView_AddColumn($g_aExpFrames[$iIndex][$g_hListView], 'Attributes', Int($aColumnWidths[4]))
		If BitAND($g_aExpFrames[$iIndex][$g_iCol], 16) Then _GUICtrlListView_AddColumn($g_aExpFrames[$iIndex][$g_hListView], 'Creation', Int($aColumnWidths[5]))
		If BitAND($g_aExpFrames[$iIndex][$g_iCol], 32) Then _GUICtrlListView_AddColumn($g_aExpFrames[$iIndex][$g_hListView], 'Accessed', Int($aColumnWidths[6]))
	EndIf

EndFunc   ;==>__Columns_SetWidths
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __Columns_GetWidths
; Description ...: Returns a delimited string containing all column widths
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __Columns_GetWidths($iIndex, $bMyComp = False)

	Local $i, $iColunmValue = 1, $iColunmIndex = 1, $iEnd = 6
	Local $iTempCol = $g_aExpFrames[$iIndex][$g_iCol]
	Local $sTempColWidths = $g_aExpFrames[$iIndex][$g_iColWidths]

	If $bMyComp Then
		$iEnd = 4
		$iTempCol = $g_aExpFrames[$iIndex][$g_iCompCol]
		$sTempColWidths = $g_aExpFrames[$iIndex][$g_iCompColWidths]
	EndIf

	Local $aColumnWidths = StringSplit($sTempColWidths, ';')
	For $i = 1 To $iEnd
		If BitAND($iTempCol, $iColunmValue) Then
			$aColumnWidths[$i] = _GUICtrlListView_GetColumnWidth($g_aExpFrames[$iIndex][$g_hListView], $iColunmIndex)
			$iColunmIndex += 1
		EndIf
		$iColunmValue += $iColunmValue
	Next

	If $bMyComp Then
		$g_aExpFrames[$iIndex][$g_iCompColWidths] = _ArrayToString($aColumnWidths, ';', 1)
	Else
		$g_aExpFrames[$iIndex][$g_iColWidths] = _ArrayToString($aColumnWidths, ';', 1)
	EndIf

EndFunc   ;==>__Columns_GetWidths
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __Columns_Header_RClick
; Description ...: Creates right click menu for choosing which columns to display
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __Columns_Header_RClick($iIndex)

	If $g_aExpFrames[$iIndex][$g_sCurrentDir] = 'My Computer' Then Return __Columns_MCHeader_RClick($iIndex)

	Local $iCurrentColumnValue = $g_aExpFrames[$iIndex][$g_iCol]

	Local Enum $iSize = 1, $iType, $iModified, $iAttrubute, $iCreation, $iAccess
	Local $hMenu = _GUICtrlMenu_CreatePopup(2)
	_GUICtrlMenu_AddMenuItem($hMenu, "Size", $iSize)
	_GUICtrlMenu_AddMenuItem($hMenu, "Type", $iType)
	_GUICtrlMenu_AddMenuItem($hMenu, "Modifed", $iModified)
	_GUICtrlMenu_AddMenuItem($hMenu, "Attrubutes", $iAttrubute)
	_GUICtrlMenu_AddMenuItem($hMenu, "Creation", $iCreation)
	_GUICtrlMenu_AddMenuItem($hMenu, "Accessed", $iAccess)

	Local $i, $iColValue = 1
	For $i = $iSize To $iAccess
		If BitAND($iCurrentColumnValue, $iColValue) Then _GUICtrlMenu_SetItemChecked($hMenu, $i, True, False)
		$iColValue += $iColValue
	Next

	Local $mitem = _GUICtrlMenu_TrackPopupMenu($hMenu, $g_aExpFrames[$iIndex][$g_hListView], -1, -1, 1, 1, 2)
	_GUICtrlMenu_DestroyMenu($hMenu)
	Switch $mitem
		Case $iSize
			$iColValue = 1
		Case $iType
			$iColValue = 2
		Case $iModified
			$iColValue = 4
		Case $iAttrubute
			$iColValue = 8
		Case $iCreation
			$iColValue = 16
		Case $iAccess
			$iColValue = 32
		Case Else
			Return
	EndSwitch

	If BitAND($iCurrentColumnValue, $iColValue) Then
		$iCurrentColumnValue -= $iColValue
	Else
		$iCurrentColumnValue += $iColValue
	EndIf

	__Columns_GetWidths($iIndex)
	$g_aExpFrames[$iIndex][$g_iCol] = $iCurrentColumnValue
	__Columns_SetWidths($iIndex)

	__DirSetCurrent($iIndex, $g_aExpFrames[$iIndex][$g_sCurrentDir], False);refresh

EndFunc   ;==>__Columns_Header_RClick
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __Columns_MCHeader_RClick
; Description ...: Creates right click menu for choosing which columns to display
; Author ........: Beege
; Remarks .......: This function is only called when current directory is "My Computer"
;================================================================================================================================
Func __Columns_MCHeader_RClick($iIndex)

	Local $iCurrentColumnValue = $g_aExpFrames[$iIndex][$g_iCompCol]
	Local $hList = $g_aExpFrames[$iIndex][$g_hListView]

	Local Enum $iSpace = 1, $iAvailable, $iType, $iAttrubute
	Local $hMenu = _GUICtrlMenu_CreatePopup(2)
	_GUICtrlMenu_AddMenuItem($hMenu, "Space", $iSpace)
	_GUICtrlMenu_AddMenuItem($hMenu, "Available", $iAvailable)
	_GUICtrlMenu_AddMenuItem($hMenu, "Type", $iType)
	_GUICtrlMenu_AddMenuItem($hMenu, "Attrubutes", $iAttrubute)

	Local $i, $iColValue = 1
	For $i = $iSpace To $iAttrubute
		If BitAND($iCurrentColumnValue, $iColValue) Then _GUICtrlMenu_SetItemChecked($hMenu, $i, True, False)
		$iColValue += $iColValue
	Next

	Local $mitem = _GUICtrlMenu_TrackPopupMenu($hMenu, $hList, -1, -1, 1, 1, 2)
	_GUICtrlMenu_DestroyMenu($hMenu)
	Switch $mitem
		Case $iSpace
			$iColValue = 1
		Case $iAvailable
			$iColValue = 2
		Case $iType
			$iColValue = 4
		Case $iAttrubute
			$iColValue = 8
		Case Else
			Return
	EndSwitch

	If BitAND($iCurrentColumnValue, $iColValue) Then
		$iCurrentColumnValue -= $iColValue
	Else
		$iCurrentColumnValue += $iColValue
	EndIf

	__Columns_GetWidths($iIndex, True)
	$g_aExpFrames[$iIndex][$g_iCompCol] = $iCurrentColumnValue
	__Columns_SetWidths($iIndex, True)

	__DirSetCurrent($iIndex, $g_aExpFrames[$iIndex][$g_sCurrentDir], False);refresh

EndFunc   ;==>__Columns_MCHeader_RClick
#EndRegion Columns Functions

#Region Sorting Functions
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __LVSort
; Description ...: Sorts columns
; Author ........: Beege  (original code came from help file example)
; Remarks .......: None
;================================================================================================================================
Func __LVSort($hWnd, $nItem1, $nItem2, $nColumn)

	Static $nSortDir = -1

	If $nColumn = $g_aColumnSort[$g_LastCol] Then;If this is the same column we sorted last time, switch directions.
		If Not $g_aColumnSort[$g_bSet] Then
			$nSortDir *= -1
			$g_aColumnSort[$g_bSet] = 1
			$g_aColumnSort[$g_iListIndex] = __GetIndex($hWnd)
		EndIf
	Else
		$nSortDir = 1
	EndIf
	$g_aColumnSort[$g_CurCol] = $nColumn

	Local $iIndex = $g_aColumnSort[$g_iListIndex]
	If Not $g_aColumnSort[$g_sColHeader] Then $g_aColumnSort[$g_sColHeader] = __LVSortGetColumnVal($g_aExpFrames[$iIndex][$g_ListView], $nColumn)

	;Param 0 = [..] which we want to keep at the very top always
	If Not $nItem1 Then Return -1
	If Not $nItem2 Then Return 1

	Local $nIndex1 = __GetItemIndex($hWnd, $nItem1, $nColumn)
	Local $nIndex2 = __GetItemIndex($hWnd, $nItem2, $nColumn)

	Local $aItem1Attb = __GUICtrlListView_GetItemIcon($g_aExpFrames[$iIndex][$g_ListView], $nIndex1)
	Local $aItem2Attb = __GUICtrlListView_GetItemIcon($g_aExpFrames[$iIndex][$g_ListView], $nIndex2)

	;Keep all folders at top no matter what the sorting direction is.
	If $aItem1Attb = $g_aExpFrames[$iIndex][$g_iFolderIndex] And $aItem2Attb <> $g_aExpFrames[$iIndex][$g_iFolderIndex] Then Return -1
	If $aItem2Attb = $g_aExpFrames[$iIndex][$g_iFolderIndex] And $aItem1Attb <> $g_aExpFrames[$iIndex][$g_iFolderIndex] Then Return 1

	Local $val1 = __LVSortGetSubItemText($hWnd, $nItem1, $nColumn, $nIndex1)
	Local $val2 = __LVSortGetSubItemText($hWnd, $nItem2, $nColumn, $nIndex2)
	Switch $g_aColumnSort[$g_sColHeader]
		Case 1;size
			__FormatUnSize($val1)
			__FormatUnSize($val2)
		Case 2;Time
			Return (__LVSortCompareDates($val1, $val2) * $nSortDir)
	EndSwitch

	Local $nResult = 0 ; No change of item1 and item2 positions
	If $val1 < $val2 Then
		$nResult = -1 ; Put item2 before item1
	ElseIf $val1 > $val2 Then
		$nResult = 1 ; Put item2 behind item1
	EndIf

	$nResult *= $nSortDir

	Return $nResult

EndFunc   ;==>__LVSort
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __LVSortFinished
; Description ...: Called when sort is finished
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __LVSortFinished($hWnd)

	Local $iIndex = __GetIndex($hWnd)

	$g_aColumnSort[$g_bSet] = 0
	$g_aColumnSort[$g_LastCol] = $g_aColumnSort[$g_CurCol]
	$g_aColumnSort[$g_sColHeader] = False
	;GUICtrlSendMsg($g_aExpFrames[$iIndex][$g_ListView], $LVM_SETSELECTEDCOLUMN, GUICtrlGetState($g_aExpFrames[$iIndex][$g_ListView]), 0)
	;DllCall("user32.dll", "int", "InvalidateRect", "hwnd", $g_aExpFrames[$iIndex][$g_hListView], "int", 0, "int", 1)

EndFunc   ;==>__LVSortFinished
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __LVSortGetColumnVal
; Description ...: Tells me what kind of column is being sorted. (Size or Date)
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __LVSortGetColumnVal($hWnd, $nColumn)

	Local $sHeader = __LVSortGetColumnHeader($hWnd, $nColumn)

	Switch $sHeader
		Case 'Size', 'Space', 'Available'
			Return 1
		Case 'Modified', 'Creation', 'Accessed'
			Return 2
	EndSwitch

EndFunc   ;==>__LVSortGetColumnVal
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __LVSortGetColumnHeader
; Description ...: Returns column header text
; Author ........: Beege
; Remarks .......: Optimized with static dll structures because depending of directory file count, this could be called a lot during sorting
;================================================================================================================================
Func __LVSortGetColumnHeader($hWnd, $iIndex)

	Static $tBuffer = DllStructCreate("char Text[50]")
	Static $pBuffer = DllStructGetPtr($tBuffer)
	Static $tColumn = DllStructCreate($tagLVCOLUMN)
	Static $pColumn = DllStructGetPtr($tColumn)

	DllStructSetData($tColumn, "Mask", $LVCF_TEXT)
	DllStructSetData($tColumn, "TextMax", 50)
	DllStructSetData($tColumn, "Text", $pBuffer)
	GUICtrlSendMsg($hWnd, $LVM_GETCOLUMNA, $iIndex, $pColumn)

	Return DllStructGetData($tBuffer, "Text")

EndFunc   ;==>__LVSortGetColumnHeader
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __LVSortGetSubItemText
; Description ...: Returns LV item sub text
; Author ........: Beege
; Remarks .......: Optimized with static dll structures because depending of directory file count, this could be called a lot during sorting
;================================================================================================================================
Func __LVSortGetSubItemText($nCtrlID, $nItemID, $nColumn, $nIndex)

	Static $stBuffer = DllStructCreate("char[260]")
	Static $p_stBuffer = DllStructGetPtr($stBuffer)
	Static $stLvi = DllStructCreate("uint;int;int;uint;uint;ptr;int;int;int;int")
	Static $p_stLvi = DllStructGetPtr($stLvi)

	DllStructSetData($stLvi, 1, $LVIF_TEXT)
	DllStructSetData($stLvi, 2, $nIndex)
	DllStructSetData($stLvi, 3, $nColumn)
	DllStructSetData($stLvi, 6, $p_stBuffer)
	DllStructSetData($stLvi, 7, 260)
	GUICtrlSendMsg($nCtrlID, $LVM_GETITEMA, 0, $p_stLvi);

	Return DllStructGetData($stBuffer, 1);item text

EndFunc   ;==>__LVSortGetSubItemText
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __LVSortCompareDates
; Description ...: Compares formated filetimes
; Author ........: Beege
; Remarks .......: Used by __LVSort
;================================================================================================================================
Func __LVSortCompareDates($sFiletime1, $sFiletime2)

	Local $aFT1 = StringSplit($sFiletime1, ' '), $aFT2 = StringSplit($sFiletime2, ' ')
	Local $aDate1 = StringSplit($aFT1[1], '/'), $aDate2 = StringSplit($aFT2[1], '/')

	Select
		Case $aDate1[3] <> $aDate2[3];years
			If Number($aDate1[3]) < Number($aDate2[3]) Then Return -1
			Return 1
		Case $aDate1[1] <> $aDate2[1];month
			If Number($aDate1[1]) < Number($aDate2[1]) Then Return -1
			Return 1
		Case $aDate1[2] <> $aDate2[2];day
			If Number($aDate1[2]) < Number($aDate2[2]) Then Return -1;
			Return 1
		Case $aFT1[3] <> $aFT2[3]
			If $aFT1[3] = 'AM' And $aFT2[3] = 'PM' Then Return -1
			Return 1
	EndSelect

	Local $aTime1 = StringSplit($aFT1[2], ':'), $aTime2 = StringSplit($aFT2[2], ':')

	Select
		Case $aTime1[1] <> $aTime2[1]; Hour
			If Number($aTime1[1]) < Number($aTime2[1]) Then Return -1;
			Return 1
		Case $aTime1[2] <> $aTime2[2];Minutes
			If Number($aTime1[2]) < Number($aTime2[2]) Then Return -1;
			Return 1
		Case Else
			Return 0;Dates are equal
	EndSelect

EndFunc   ;==>__LVSortCompareDates
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __GetItemIndex
; Description ...: Returns List view item index. Used by __LVSort
; Author ........: Beege
; Remarks .......: Optimized with static dll structures because this could be called a lot during sorting
;================================================================================================================================
Func __GetItemIndex($nCtrlID, $nItemID, $nColumn)

	Static $stLvfi = DllStructCreate("uint;ptr;int;int[2];int")
	Static $p_stLvfi = DllStructGetPtr($stLvfi)

	DllStructSetData($stLvfi, 1, $LVFI_PARAM)
	DllStructSetData($stLvfi, 3, $nItemID)

	Return GUICtrlSendMsg($nCtrlID, $LVM_FINDITEM, -1, $p_stLvfi);

EndFunc   ;==>__GetItemIndex
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __GUICtrlListView_GetItemIcon
; Description ...: Returns icon index being used by list item. Used by __LVSort
; Author ........: Beege
; Remarks .......: Optimized with static dll structures because depending of directory file count, this could be called a lot during sorting
;================================================================================================================================
Func __GUICtrlListView_GetItemIcon($hWnd, $iIndex)

	Static $tItem = DllStructCreate($tagLVITEM)

	DllStructSetData($tItem, "Mask", $LVIF_IMAGE)
	DllStructSetData($tItem, "Item", $iIndex)
	_GUICtrlListView_GetItemEx($hWnd, $tItem)

	Return DllStructGetData($tItem, "Image")

EndFunc   ;==>__GUICtrlListView_GetItemIcon
#EndRegion Sorting Functions
#Region History Functions
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __HistoryPush
; Description ...: Adds value to Directory History Stack
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __HistoryPush(ByRef $sDirHistory, $sDir)
	$sDirHistory = $sDir & '|' & $sDirHistory
EndFunc   ;==>__HistoryPush
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __HistoryPoP
; Description ...: Pops value from stack.
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __HistoryPoP(ByRef $sDirHistory, $bDeletePOP = True)

	Local $aSplit = StringSplit($sDirHistory, '|', 2)
	If $aSplit[0] = '' Then Return SetError(1, 0, 0)

	If Not $bDeletePOP Then Return $aSplit[0];Don't remove from stack.

	Local $sPop = $aSplit[0]
	_ArrayDelete($aSplit, 0)
	$sDirHistory = _ArrayToString($aSplit, '|')

	Return $sPop

EndFunc   ;==>__HistoryPoP
#EndRegion History Functions

#Region Format Functions
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __FormatDate
; Description ...: Formats filetime to be d/M/YYYY am/pm
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __FormatDate($aTime)

	$aTime[5] = ' AM'
	Switch Number($aTime[3])
		Case 0
			$aTime[3] = 12
		Case 13 To 24
			$aTime[3] -= 12
			$aTime[5] = ' PM'
	EndSwitch

	Return Number($aTime[1]) & '/' & Number($aTime[2]) & '/' & $aTime[0] & ' ' & Number($aTime[3]) & ':' & $aTime[4] & $aTime[5]

EndFunc   ;==>__FormatDate
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __FormatSize
; Description ...: Formats size in bytes to size in kb,mb,gb
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __FormatSize($iBytes, $zero_Blank = True)

	Switch Number($iBytes)
		Case 0
			If $zero_Blank Then Return ''
			Return '0 Bytes'
		Case 1 To 1023
			Return $iBytes & " Bytes"
		Case 1024 To 1048575
			Return Round($iBytes / 1024, 2) & " KB"
		Case 1048576 To 1073741823
			Return Round($iBytes / 1048576, 2) & " MB"
		Case Else; 1073741824 to 1099511627775
			Return Round($iBytes / 1073741824, 2) & " GB"
;~ 		Case Else
;~ 			Return Round($iBytes / 1099511627776, 2) & " TB"
	EndSwitch

EndFunc   ;==>__FormatSize
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __FormatUnSize
; Description ...: converts size back to bytes from kb,mb,gb
; Author ........: Beege
; Remarks .......: Used by __LVSort
;================================================================================================================================
Func __FormatUnSize(ByRef $val)

	Switch StringRight($val, 2)
		Case 'KB'
			$val = (Number(StringTrimRight($val, 2)) * 1024)
		Case 'MB'
			$val = (Number(StringTrimRight($val, 2)) * 1048576)
		Case 'GB'
			$val = (Number(StringTrimRight($val, 2)) * 1073741824)
		Case Else
			$val = StringTrimRight($val, 6)
	EndSwitch

EndFunc   ;==>__FormatUnSize
#EndRegion Format Functions

#Region Listview Icon Functions
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __GetFileIcon
; Description ...: Returns handle to icon
; Author ........: Yasheid
; Modified.......: Beege
; Remarks .......: None
;================================================================================================================================
Func __GetFileIcon($sPath, $bExt = 1, $iAttributes = 0)

	Static $tSHFILEINFO = DllStructCreate("ptr hIcon; int iIcon; DWORD dwAttributes; CHAR szDisplayName[255]; CHAR szTypeName[80];"), $p_tSHFILEINFO = DllStructGetPtr($tSHFILEINFO)
	Local $iFlags = BitOR(0x100, 0x1) ;$SHGFI_SMALLICON, $SHGFI_ICON

	If $bExt Then $iFlags = BitOR($iFlags, 0x10);SHGFI_USEFILEATTRIBUTES

	Local $Ret = DllCall($g_hShell32, 'dword_ptr', 'SHGetFileInfoW', 'wstr', $sPath, 'dword', $iAttributes, 'ptr', $p_tSHFILEINFO, 'uint', DllStructGetSize($tSHFILEINFO), 'uint', $iFlags)
	If @error Then Return SetError(1, 0, 0)

	Return DllStructGetData($tSHFILEINFO, 'hIcon')

EndFunc   ;==>__GetFileIcon
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __AddExtIcontoIMGList
; Description ...: Adds icon to ImageList
; Author ........: Beege
; Remarks .......: None
;================================================================================================================================
Func __AddExtIcontoIMGList($iIndex, $sExt, $isExtention = 1, $Delete = 0)

	Local $hIcon = __GetFileIcon($sExt, $isExtention)
	Local $iIconIndex = _GUIImageList_ReplaceIcon($g_aExpFrames[$iIndex][$g_hImageList], -1, $hIcon)
	If $iIconIndex = -1 Then
		Local $oExtIndex = $g_aExpFrames[$iIndex][$g_oExtIndex]
		$sExt = StringRight($sExt, 4)
		If Not $oExtIndex.Exists($sExt) Then $oExtIndex.Add($sExt, __AddExtIcontoIMGList($iIndex, $sExt))
		$iIconIndex = $oExtIndex.Item($sExt)
	EndIf
	_WinAPI_DestroyIcon($hIcon)

	Return $iIconIndex

EndFunc   ;==>__AddExtIcontoIMGList
#EndRegion Listview Icon Functions

#Region Other...
Func __GetExtType($sExt)
	Static $sType = DllStructCreate('wchar[1024]'), $p_sType = DllStructGetPtr($sType)
	DllCall($g_hShlwapi, 'uint', 'AssocQueryStringW', 'dword', 0, 'dword', 3, 'wstr', $sExt, 'wstr', '', 'ptr', $p_sType, 'dword*', 1024)
	Return DllStructGetData($sType, 1)
EndFunc   ;==>__GetExtType
; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __FLTA
; Description ...: Returns directory file/folders list in an array with folders listed first
; Author ........: SolidSnake
; Modified.......: Beege
; Remarks .......: None
;================================================================================================================================
Func __FLTA($sPath, $sFilter = "*", $iFlag = 0)
	$sPath = StringRegExpReplace($sPath, "[\\/]+\z", "") & "\" ; ensure single trailing backslash
	If Not FileExists($sPath) Then Return SetError(1, 1, "")
	If StringRegExp($sFilter, "[\\/:><\|]|(?s)\A\s*\z") Then Return SetError(2, 2, "")
	If Not ($iFlag = 0 Or $iFlag = 1 Or $iFlag = 2) Then Return SetError(3, 3, "")
	Local $sFile, $sFileList, $sFolderList, $sDelim = "|"
	Local $hSearch = FileFindFirstFile($sPath & $sFilter)
	If @error Then Return SetError(4, 4, "")
	While 1
		$sFile = FileFindNextFile($hSearch)
		If @error Then ExitLoop
		If @extended Then
			$sFolderList &= $sDelim & $sFile
		Else
			$sFileList &= $sDelim & $sFile
		EndIf
	WEnd
	FileClose($hSearch)
	$sFileList = $sFolderList & $sFileList
	If Not $sFileList Then Return SetError(4, 4, "")
	Return StringSplit(StringTrimLeft($sFileList, 1), "|")
EndFunc   ;==>__FLTA
Func __Release()
	DllClose($g_hUser32)
	DllClose($g_hShell32)
	DllClose($g_hShlwapi)
	For $i = 1 To $g_aExpFrames[0][0]
		$g_aExpFrames[$i][$g_oExtIndex] = 0
	Next
	$g_oExtTypes = 0
EndFunc   ;==>__Release
#EndRegion Other...
#EndRegion Internal Functions