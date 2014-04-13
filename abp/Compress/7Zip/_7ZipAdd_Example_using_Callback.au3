#include <GuiConstantsEx.au3>
#include <7Zip.au3>

$hGUI = GUICreate("_7ZipAdd demo", 300, 200)

$ctlEdit = GUICtrlCreateEdit("", 10, 10, 280, 100)

$ctlProgress = GUICtrlCreateProgress(10, 130, 280, 20)

$ctlButton_Pack = GUICtrlCreateButton("Pack!", 10, 167, 75, 23)

$ctlButton_Close = GUICtrlCreateButton("Close", 215, 167, 75, 23)

GUISetState()

$ArcFile = FileSaveDialog("New archive name", "", "Archive Files (*.7z;*.zip;*.gzip;*.bzip2;*.tar)", 1, "", $hGUI)
If @error Then Exit

$sFolder = FileSelectFolder("Select folder to add in archive", "", 1, "", $hGUI)
If @error Then Exit

While 1
	$msg = GUIGetMsg()
	Switch $msg
		Case $GUI_EVENT_CLOSE, $ctlButton_Close
			Exit
		Case $ctlButton_Pack
			_7ZipStartup()
			$retResult = _7ZipSetOwnerWindowEx($hGUI, "_ARCHIVERPROC")
			If $retResult = 0 Then Exit MsgBox(16, "_7ZipAdd demo", "Error occured")

			$retResult = _7ZipAdd($hGUI, $ArcFile, $sFolder, 1)
			_7ZipShutdown()
			If @error = 0 Then
				MsgBox(64, "_7ZipAdd demo", "Archive created successfully", 0, $hGUI)
			Else
				MsgBox(64, "_7ZipAdd demo", "Error occurred", 0, $hGUI)
			EndIf

			GUICtrlSetData($ctlProgress, 0)
			GUICtrlSetData($ctlEdit, "")
	EndSwitch
WEnd

Func _ARCHIVERPROC($hWnd, $Msg, $nState, $ExInfo)
	Local $iFileSize, $iWriteSize, $iPercent = 0

	If $nState = 0 Then
		Local $EXTRACTINGINFO = DllStructCreate($tagEXTRACTINGINFO, $ExInfo)

		GUICtrlSetData($ctlEdit, DllStructGetData($EXTRACTINGINFO, "szSourceFileName") & @CRLF, 1)

		$iFileSize = DllStructGetData($EXTRACTINGINFO, "dwFileSize")
		$iWriteSize = DllStructGetData($EXTRACTINGINFO, "dwWriteSize")

		$iPercent = Int($iWriteSize / $iFileSize * 100)

		GUICtrlSetData($ctlProgress, $iPercent)
		Return 1
	EndIf

	If $nState = 2 Then GUICtrlSetData($ctlProgress, 100)

	Return 1
EndFunc