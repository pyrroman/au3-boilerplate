#AutoIt3Wrapper_UseX64=n

#include "AutoItObject.au3"
#include <WinAPI.au3>

Opt("MustDeclareVars", 1)

; Start AutoItObject
_AutoItObject_StartUp()

; Error monitoring
Global $oError = ObjEvent("AutoIt.Error", "_ErrFunc")
Func _ErrFunc()
	ConsoleWrite("! COM Error !  Number: 0x" & Hex($oError.number, 8) & "   ScriptLine: " & $oError.scriptline & " - " & $oError.windescription & @CRLF)
	Return
EndFunc   ;==>_ErrFunc


; START

; Some wav file
Global $sFile = @WindowsDir & "\Media\notify.wav"
If Not FileExists($sFile) Then Exit -1 ; wav file doesn't exist
; Read file
Global $hFile = FileOpen($sFile, 16)
Global $bBinary = FileRead($hFile)
FileClose($hFile)
; Raw header
Global $oWAVEHeaderByte = _AutoItObject_DllStructCreate("byte Binary[36]")
$oWAVEHeaderByte.Binary = $bBinary
; Formated header
Global $oWAVEHeader = _AutoItObject_DllStructCreate("char RIFF[4];" & _
		"dword ChunkSize;" & _
		"char Format[4];" & _
		"char Subchunk1ID[4];" & _
		"dword Subchunk1Size;" & _
		"word AudioFormat;" & _
		"word NumChannels;" & _
		"dword SampleRate;" & _
		"dword ByteRate;" & _
		"word BlockAlign;" & _
		"word BitsPerSample;", _
		$oWAVEHeaderByte())
; Print data
ConsoleWrite("RIFF: " & $oWAVEHeader.RIFF & @CRLF)
ConsoleWrite("ChunkSize: " & $oWAVEHeader.ChunkSize & @CRLF)
ConsoleWrite("Format: " & $oWAVEHeader.Format & @CRLF)
ConsoleWrite("Subchunk1ID: " & $oWAVEHeader.Subchunk1ID & @CRLF)
ConsoleWrite("Subchunk1Size: " & $oWAVEHeader.Subchunk1Size & @CRLF)
ConsoleWrite("AudioFormat: " & $oWAVEHeader.AudioFormat & @CRLF)
ConsoleWrite("NumChannels: " & $oWAVEHeader.NumChannels & @CRLF)
ConsoleWrite("SampleRate: " & $oWAVEHeader.SampleRate & @CRLF)
ConsoleWrite("ByteRate: " & $oWAVEHeader.ByteRate & @CRLF)
ConsoleWrite("BlockAlign: " & $oWAVEHeader.BlockAlign & @CRLF)
ConsoleWrite("BitsPerSample: " & $oWAVEHeader.BitsPerSample & @CRLF)

; Find "data" chunk offset. It's not always right after the "fmt ". To be on the safe side little complication is needed:
Local $tDATAlength, $iDATAlength
Local $iDATAoffset = StringInStr(BinaryToString($bBinary), "data", 1) ; offset to data
If $iDATAoffset Then
	$tDATAlength = _AutoItObject_DllStructCreate("dword Length")
	$tDATAlength.Length = BinaryMid($bBinary, $iDATAoffset + 4, 4) ; first 4 is length of "data" and other of dword.
	$iDATAlength = $tDATAlength.Length ; size of raw data (samples)
EndIf
; Put samples data to raw structure
Global $tSamplesData = _AutoItObject_DllStructCreate("byte Raw[" & $iDATAlength & "]")
$tSamplesData.Raw = BinaryMid($bBinary, $iDATAoffset + 8, $iDATAlength) ; 8 is two added fours from the above

; Calculate duration out of header data
Global $iDuration = $iDATAlength / ($oWAVEHeader.BitsPerSample * $oWAVEHeader.SampleRate * $oWAVEHeader.NumChannels / 8)
ConsoleWrite("Duration: " & $iDuration & " sec" & @CRLF)

; WAVEFORMATEX structure (http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.waveformatex(VS.85).aspx)
Local $oWAVEFORMATEX = _AutoItObject_DllStructCreate("align 2;word FormatTag;" & _
		"word Channels;" & _
		"dword SamplesPerSec;" & _
		"dword AvgBytesPerSec;" & _
		"word BlockAlign;" & _
		"word BitsPerSample;" & _
		"word Size")
; DSBUFFERDESC structure (http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.dsbufferdesc(VS.85).aspx)
Local $oDSBUFFERDESC = _AutoItObject_DllStructCreate("dword Size;" & _
		"dword Flags;" & _
		"dword BufferBytes;" & _
		"dword Reserved;" & _
		"ptr Format")
; Some constants
Local Const $DSBCAPS_CTRLPOSITIONNOTIFY = 256
Local Const $DSBCAPS_CTRLFREQUENCY = 32
Local Const $DSBCAPS_GLOBALFOCUS = 32768
Local Const $DSSCL_NORMAL = 1
Local Const $DSBLOCK_ENTIREBUFFER = 2
Local Const $DSBPLAY_LOOPING = 1

; Go direct. DirectSound8 over DirectSound only because of the convinient links (http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.reference.directsoundcreate8(VS.85).aspx)
Local $aCall = DllCall("dsound.dll", "long", "DirectSoundCreate8", _
		"ptr", 0, _
		"ptr*", 0, _
		"ptr", 0)
If @error Or $aCall[0] Then Exit -2 ; DirectSoundCreate8 or call to it failed
; Collect
Local $pDSound = $aCall[2]
; Define IDirectSound8 vTable methods
Local $tagIDirectSound = "QueryInterface;" & _
		"AddRef;" & _
		"Release;" & _ ; IUnknown
		"CreateSoundBuffer;" & _
		"GetCaps;" & _
		"DuplicateSoundBuffer;" & _
		"SetCooperativeLevel;" & _
		"Compact;" & _
		"GetSpeakerConfig;" & _
		"SetSpeakerConfig;" & _
		"Initialize;" & _ ; IDirectSound
		"VerifyCertification;" ; IDirectSound8
; Wrapp IDirectSound8 interface
Local $oIDirectSound8 = _AutoItObject_WrapperCreate($pDSound, $tagIDirectSound)
; Byrocracy... (http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.idirectsound8.idirectsound8.setcooperativelevel(VS.85).aspx)
Local $aCall = $oIDirectSound8.SetCooperativeLevel("long", "hwnd", Number(_WinAPI_GetDesktopWindow()), "dword", $DSSCL_NORMAL)
If Not IsArray($aCall) Or $aCall[0] Then
	$oIDirectSound8 = 0
	Exit -3 ; SetCooperativeLevel failed
EndIf
; Fill the structures
$oWAVEFORMATEX.FormatTag = $oWAVEHeader.AudioFormat
$oWAVEFORMATEX.Channels = $oWAVEHeader.NumChannels
$oWAVEFORMATEX.SamplesPerSec = $oWAVEHeader.SampleRate
$oWAVEFORMATEX.AvgBytesPerSec = $oWAVEHeader.ByteRate
$oWAVEFORMATEX.BlockAlign = $oWAVEHeader.BlockAlign
$oWAVEFORMATEX.BitsPerSample = $oWAVEHeader.BitsPerSample
$oWAVEFORMATEX.Size = 0 ; redundant
; DSBUFFERDESC structure
$oDSBUFFERDESC.Size = $oDSBUFFERDESC.__size__
$oDSBUFFERDESC.Flags = BitOR($DSBCAPS_CTRLPOSITIONNOTIFY, $DSBCAPS_CTRLFREQUENCY, $DSBCAPS_GLOBALFOCUS)
$oDSBUFFERDESC.Format = $oWAVEFORMATEX()
; Buffer size
Local $iBufferSize = $iDATAlength
$oDSBUFFERDESC.BufferBytes = $iBufferSize
; Make SoundBuffer (http://msdn.microsoft.com/en-us/library/microsoft.directx_sdk.idirectsound8.idirectsound8.createsoundbuffer(VS.85).aspx)
$aCall = $oIDirectSound8.CreateSoundBuffer("long", "ptr", Number($oDSBUFFERDESC()), "ptr*", 0, "ptr", 0)
If Not IsArray($aCall) Or $aCall[0] Then
	$oIDirectSound8 = 0
	Exit -4 ; CreateSoundBuffer failed
EndIf
; Collect data
Local $pDirectSoundBuffer = $aCall[2]
; Define IDirectSoundBuffer vTable methods
Local $tagIDirectSoundBuffer = "QueryInterface;" & _
		"AddRef;" & _
		"Release;" & _ ; IUnknown
		"GetCaps;" & _
		"GetCurrentPosition;" & _
		"GetFormat;" & _
		"GetVolume;" & _
		"GetPan;" & _
		"GetFrequency;" & _
		"GetStatus;" & _
		"Initialize;" & _
		"Lock;" & _
		"Play;" & _
		"SetCurrentPosition;" & _
		"SetFormat;" & _
		"SetVolume;" & _
		"SetPan;" & _
		"SetFrequency;" & _
		"Stop;" & _
		"Unlock;" & _
		"Restore;" ; DirectSoundBuffer
; Wrapp IDirectSoundBuffer interface
Local $oIDirectSoundBuffer = _AutoItObject_WrapperCreate($pDirectSoundBuffer, $tagIDirectSoundBuffer)

; Get original frequency
$aCall = $oIDirectSoundBuffer.GetFrequency("long", "dword*", 0)
If Not IsArray($aCall) Then
	$oIDirectSoundBuffer = 0
	$oIDirectSound8 = 0
	Exit -5 ; GetFrequency failed
EndIf
; Collect data
Local $iPlayFreq = $aCall[1]
; Get pointer to buffer where audio is stored
$aCall = $oIDirectSoundBuffer.Lock("long", "dword", 0, "dword", $iBufferSize, "ptr*", 0, "dword*", 0, "ptr", 0, "ptr", 0, "dword", $DSBLOCK_ENTIREBUFFER)
If Not IsArray($aCall) Or $aCall[0] Then
	$oIDirectSoundBuffer = 0
	$oIDirectSound8 = 0
	Exit -6 ; Lock failed
EndIf
; Collect interesting data out of that call
Local $pWrite = $aCall[3]
Local $iLen = $aCall[4]
; Make writable buffer at thet address
Local $oSoundBuffer = _AutoItObject_DllStructCreate("byte Raw[" & $iLen & "]", $pWrite)
$oSoundBuffer.Raw = $tSamplesData.Raw
; Unlock memory (will not check for errors from now on since it's just call, call, call... situation)
$oIDirectSoundBuffer.Unlock("long", "ptr", $pWrite, "dword", $iLen, "ptr", 0, "dword", 0)

; PLAY FEW TIMES
For $i = 1 To 1
	; Set some frequency (slow it down)
	$oIDirectSoundBuffer.SetFrequency("long", "dword", $iPlayFreq / 1.8)
	; Set current position to 0 (start)
	$oIDirectSoundBuffer.SetCurrentPosition("long", "dword", 0)
	; Play
	$oIDirectSoundBuffer.Play("long", "dword", 0, "dword", 0, "dword", $DSBPLAY_LOOPING)
	; Sleep
	Sleep(1000 * $iDuration * 1.8)
	; Stop
	$oIDirectSoundBuffer.Stop("long")

	; Set new frequency
	$oIDirectSoundBuffer.SetFrequency("long", "dword", $iPlayFreq / 1.4)
	; Set current position to 0 (start)
	$oIDirectSoundBuffer.SetCurrentPosition("long", "dword", 0)
	; Play
	$oIDirectSoundBuffer.Play("long", "dword", 0, "dword", 0, "dword", $DSBPLAY_LOOPING)
	; Sleep
	Sleep(1000 * $iDuration * 1.4)
	; Stop
	$oIDirectSoundBuffer.Stop("long")

	; Set original frequency
	$oIDirectSoundBuffer.SetFrequency("long", "dword", $iPlayFreq) ; This is the original speed
	; Set current position to 0 (start)
	$oIDirectSoundBuffer.SetCurrentPosition("long", "dword", 0)
	; Play
	$oIDirectSoundBuffer.Play("long", "dword", 0, "dword", 0, "dword", $DSBPLAY_LOOPING)
	; Sleep
	Sleep(1000 * $iDuration)
	; Stop
	$oIDirectSoundBuffer.Stop("long")

	; Set new frequency (faster)
	$oIDirectSoundBuffer.SetFrequency("long", "dword", 1.4 * $iPlayFreq)
	; Set current position to 0 (start)
	$oIDirectSoundBuffer.SetCurrentPosition("long", "dword", 0)
	; Play
	$oIDirectSoundBuffer.Play("long", "dword", 0, "dword", 0, "dword", $DSBPLAY_LOOPING)
	; Sleep
	Sleep(1000 * $iDuration / 1.4)
	; Stop
	$oIDirectSoundBuffer.Stop("long")

	; Set new frequency (faster)
	$oIDirectSoundBuffer.SetFrequency("long", "dword", 1.8 * $iPlayFreq)
	; Set current position to 0 (start)
	$oIDirectSoundBuffer.SetCurrentPosition("long", "dword", 0)
	; Play
	$oIDirectSoundBuffer.Play("long", "dword", 0, "dword", 0, "dword", $DSBPLAY_LOOPING)
	; Sleep
	Sleep(1000 * $iDuration / 1.8)
	; Stop
	$oIDirectSoundBuffer.Stop("long")
Next
; END

;Release objects ($oIDirectSoundBuffer is must!)
$oIDirectSoundBuffer = 0
$oIDirectSound8 = 0