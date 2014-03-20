#include <BassEnc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>

Opt("GUIOnEventMode", 1)

Global $device, $input, $EncHandle, $RecHandle, $Bitrate = 128, $KHZ = 44100, $levels, $levelL = 0, $levelR = 0, $temp, $EncState = False

_BASS_STARTUP()
_BASS_Encode_STARTUP()
$basscb_dll = DllOpen("BASSCB.dll")

$hGui = GUICreate("Bass.dll / BassEnc.dll Recording Test", 320, 320)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUICtrlCreateLabel("Select AudioDevice:", 10, 10)
$hDevice = GUICtrlCreateCombo("", 10, 30, 300, 20, BitOR($CBS_DROPDOWN, $CBS_DROPDOWNLIST, $WS_VSCROLL))
GUICtrlSetOnEvent(-1, "_SelectDevice")
GUICtrlCreateLabel("Select AudioInput:", 10, 60)
$hInput = GUICtrlCreateCombo("", 10, 80, 300, 20, BitOR($CBS_DROPDOWN, $CBS_DROPDOWNLIST, $WS_VSCROLL))
GUICtrlSetOnEvent(-1, "_SelectInput")
$hMp3 = GUICtrlCreateRadio("Mp3", 50, 110, 50)
$hWav = GUICtrlCreateRadio("Wav", 50, 130, 50)
GUICtrlSetState(-1, $GUI_CHECKED)
$hBitrate = GUICtrlCreateCombo("", 120, 110, 50, 20, BitOR($CBS_DROPDOWN, $CBS_DROPDOWNLIST, $WS_VSCROLL))
GUICtrlSetData(-1, "32|40|48|56|64|80|96|112|128|160|192|224|256|320", "128")
GUICtrlCreateLabel("KBit/s", 180, 113, 50)
$hPeakL = GUICtrlCreateProgress(10, 160, 300, 10)
$hPeakR = GUICtrlCreateProgress(10, 175, 300, 10)
GUICtrlCreateLabel("Encoder Active:", 10, 200)
$hEncActive = GUICtrlCreateLabel("", 120, 200, 200)
GUICtrlCreateLabel("Data sent to Encoder:", 10, 220)
$hEncCount = GUICtrlCreateLabel("", 120, 220, 200)
GUICtrlCreateLabel("Filesize:", 10, 240)
$hFilesize = GUICtrlCreateLabel("", 120, 240, 200)
$hStart = GUICtrlCreateButton("Start", 20, 280, 130, 20)
GUICtrlSetOnEvent(-1, "_Start")
$hStop = GUICtrlCreateButton("Stop", 170, 280, 130, 20)
GUICtrlSetOnEvent(-1, "_Stop")
GUICtrlSetState(-1, $GUI_DISABLE)
GUISetState()

ConsoleWrite("STARTING TO DEBUG BASS_ENC_EXAMPLE." & @CRLF & _
		"OS = " & @OSVersion & " (" & @OSArch & ") (SERVICE PACK = " & @OSServicePack & ") BUILD = " & @OSBuild & @CRLF & _
		"KB Layout = " & @KBLayout & @CRLF & _
		"Running AutoIt V" & @AutoItVersion & "(64 bit native = " & @AutoItX64 & ")" & @CRLF)

;_BASS_SetConfig($BASS_CONFIG_REC_BUFFER, 1000)
$device = _GetDevices()
ConsoleWrite("GETTING DEVICES FAILED" & @CRLF & @TAB & $device & @TAB & @error & @CRLF)
$r = _BASS_RecordInit($device)
ConsoleWrite("INITATING RECORDING FAILED" & @CRLF & @TAB & $r & @TAB & @error & @CRLF)
$input = _GetInputs()
ConsoleWrite("GETTING INPUTS FAILED" & @CRLF & @TAB & $input & @TAB & @error & @CRLF)
$temp = DllCall($basscb_dll, "dword", "RecordStart", "dword", $KHZ, "dword", 2, "dword", _makelong($BASS_SAMPLE_FX, 10))
ConsoleWrite("BASSCB RECORD START FAILED" & @CRLF & @TAB & $device & @TAB & @error & @CRLF)
$RecHandle = $temp[0]

$timer = TimerInit()
While 1
	Sleep(20)
	$peak = _BASS_ChannelGetLevel($RecHandle)
	If Not @error Then
		$temp = (_LoWord($peak) / 32768) * 100
		If $temp > $levelL Then $levelL = $temp
		$temp = (_HiWord($peak) / 32768) * 100
		If $temp > $levelR Then $levelR = $temp
		GUICtrlSetData($hPeakL, $levelL)
		GUICtrlSetData($hPeakR, $levelR)
		$levelL -= 4
		$levelR -= 4
	Else
		ToolTip(@error)
	EndIf
	If TimerDiff($timer) > 200 Then
		$timer = TimerInit()
		GUICtrlSetData($hEncActive, _BASS_Encode_IsActive($EncHandle))
		If $EncState Then
			GUICtrlSetData($hEncCount, _BASS_Encode_GetCount($EncHandle, $BASS_ENCODE_COUNT_IN))
			If GUICtrlRead($hWav) = $GUI_CHECKED Then
				GUICtrlSetData($hFilesize, Round(FileGetSize(@ScriptDir & "\Test.wav") / 1024, 2) & " kb")
			Else
				GUICtrlSetData($hFilesize, Round(FileGetSize(@ScriptDir & "\Test.mp3") / 1024, 2) & " kb")
			EndIf
		EndIf
	EndIf
WEnd

Func _Start()
	GUICtrlSetState($hDevice, $GUI_DISABLE)
	GUICtrlSetState($hInput, $GUI_DISABLE)
	GUICtrlSetState($hStart, $GUI_DISABLE)
	GUICtrlSetState($hMp3, $GUI_DISABLE)
	GUICtrlSetState($hWav, $GUI_DISABLE)
	GUICtrlSetState($hBitrate, $GUI_DISABLE)
	GUICtrlSetState($hStop, $GUI_ENABLE)
	If GUICtrlRead($hWav) = $GUI_CHECKED Then
		$EncHandle = _BASS_Encode_Start($RecHandle, @ScriptDir & "\Test.wav", $BASS_ENCODE_PCM)
	Else
		$EncHandle = _BASS_Encode_Start($RecHandle, 'lame -r -x -b' & GUICtrlRead($hBitrate) & ' -h - "' & @ScriptDir & '\Test.mp3"', 0)
	EndIf
	$EncState = True
EndFunc   ;==>_Start

Func _Stop()
	GUICtrlSetState($hDevice, $GUI_ENABLE)
	GUICtrlSetState($hInput, $GUI_ENABLE)
	GUICtrlSetState($hStart, $GUI_ENABLE)
	GUICtrlSetState($hMp3, $GUI_ENABLE)
	GUICtrlSetState($hWav, $GUI_ENABLE)
	GUICtrlSetState($hBitrate, $GUI_ENABLE)
	GUICtrlSetState($hStop, $GUI_DISABLE)
	_BASS_Encode_Stop($EncHandle)
	$EncState = False
EndFunc   ;==>_Stop

Func _SelectDevice()
	Local $new = _GUICtrlComboBox_GetCurSel($hDevice)
	If $new = $device Then Return
	_BASS_RecordFree()
	_BASS_RecordSetDevice($new)
	_BASS_Recordinit($new)
	GUICtrlSetData($hInput, "", "")
	_GetInputs()
	$temp = DllCall($basscb_dll, "dword", "RecordStart", "dword", $KHZ, "dword", 2, "dword", _makelong($BASS_SAMPLE_FX, 10))
	$RecHandle = $temp[0]
	$device = $new
EndFunc   ;==>_SelectDevice

Func _SelectInput()
	Local $new = _GUICtrlComboBox_GetCurSel($hInput)
	If $new = $input Then Return
	_BASS_RecordSetInput($new, $BASS_INPUT_ON, -1)
	$input = $new
EndFunc   ;==>_SelectInput

Func _GetDevices()
	Local $count = 0, $info, $name = "", $sdef = "", $idef = 0
	While 1
		$info = _BASS_RecordGetDeviceInfo($count)
		If @error Then ExitLoop
		$count += 1
		If BitAND($info[2], $BASS_DEVICE_ENABLED) Then $name &= $info[0] & "|"
		If BitAND($info[2], $BASS_DEVICE_DEFAULT) Then
			$sdef = $info[0]
			$idef = $count
		EndIf
	WEnd
	GUICtrlSetData($hDevice, $name, $sdef)
	Return $idef - 1
EndFunc   ;==>_GetDevices

Func _GetInputs()
	Local $count = 0, $info, $name = "", $flags, $sdef = "", $idef = 0
	$info = _BASS_RecordGetInputName($count)
	While $info <> ""
		$flags = _BASS_RecordGetInput($count)
		$count += 1
		$name &= $info & "|"
		If BitAND($flags[0], $BASS_INPUT_OFF) = 0 Then
			$sdef = $info
			$idef = $count
		EndIf
		$info = _BASS_RecordGetInputName($count)
	WEnd
	GUICtrlSetData($hInput, $name, $sdef)
	Return $idef - 1
EndFunc   ;==>_GetInputs

Func _Exit()
	If _BASS_Encode_IsActive($EncHandle) Then _BASS_Encode_Stop($EncHandle)
	_BASS_RecordFree()
	Exit
EndFunc   ;==>_Exit