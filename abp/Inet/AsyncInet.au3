#include-once
;~ #Tidy_Parameters=/sf
;~ #AutoIt3Wrapper_AU3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7 -d

#include <File.au3>
#include <Array.au3>
#include <WinAPI.au3>
#include <FileConstants.au3>
#include <InetConstants.au3>

; #INDEX# =======================================================================================================================
; Title .........: _AsyncInet
; AutoIt Version : 3.3.10+
; Description ...:
; Author(s) .....: rindeal
; Dll ...........: none
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $_AI_TimeoutQuotient
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__AI_TMPDIR_PARENT = @TempDir
Global Const $__AI_TMPDIR_PREFIX = "~tmp_ai_"
; ===============================================================================================================================

_AsyncInet_Init() ;ensure that Async has been initialized
OnAutoItExitRegister("__AsyncInet_OnExit")

; #CURRENT# =====================================================================================================================
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; ===============================================================================================================================

#Region Public Functions
	Func _AsyncInet_Init($iTimeoutQuotient = 0, $sUserAgent = Default)
		$_AI_TimeoutQuotient = __AsyncInet_Default($iTimeoutQuotient, 500)
		If $_AI_TimeoutQuotient < 50 Then $_AI_TimeoutQuotient = 50 ;minimal timequotient
		$sUserAgent = __AsyncInet_Default($sUserAgent, "Mozilla/5.0")
		HttpSetUserAgent($sUserAgent)
	EndFunc   ;==>_AsyncInet_Init

	;downloads data in binary
	Func _AsyncInet_Read(ByRef $aInputURLs, $iTimeout = 0, $sLoopFunc = "")
		If Not IsArray($aInputURLs) Then Return SetError(1, 0, 0)
		Local Const $iURLCount = UBound($aInputURLs)
		If $iURLCount > 700 Then Return SetError(1, 0, 0) ; InetGet cannot proccess more than ~700 downloads at once
		Local $aOutputData[$iURLCount], $aOutputDataPool[$iURLCount], $aInetHandles[$iURLCount], $aInetHandlePool[$iURLCount]
		$iTimeout = __AsyncInet_Default($iTimeout, $_AI_TimeoutQuotient * $iURLCount)
		Local Const $sTmpFolder = $__AI_TMPDIR_PARENT & '\' & $__AI_TMPDIR_PREFIX & __AsyncInet_RandomGen(8)
		DirCreate($sTmpFolder) ;make sure our new dir exists

		; start downloads
		Local $t = TimerInit()

		For $i = 0 To $iURLCount - 1
			If $aInputURLs[$i] = '' Or Not IsString($aInputURLs[$i]) Then ContinueLoop

			;if no protocol specified, prepend http and remove leading/trailing whitespaces and then add to download queue
			$aInetHandles[$i] = InetGet(StringRegExpReplace($aInputURLs[$i], _
					"(?s)^[ \t]*(http(s)?://)?(\S+)\s*", _ ; if no protocol specified
					"http\2://\3") _                       ; then use http
					, $sTmpFolder & "\" & $i, $INET_IGNORESSL + $INET_BINARYTRANSFER + $INET_FORCEBYPASS, $INET_DOWNLOADBACKGROUND)

			; populate the pools
			$aInetHandlePool[$i] = $i
			$aOutputDataPool[$i] = $i
		Next

		; wait till all files are downloaded or found to be failed
		Local $iTimestamp = 0, $iLastTimestamp = 0
		Do
			If Not IsArray($aInetHandlePool) Then ExitLoop ; pool is empty

			$iTimestamp = Int(TimerDiff($t) / 200) ; poll every ~200 ms
			If $iLastTimestamp <> $iTimestamp Then
				Call($sLoopFunc)
				$iLastTimestamp = $iTimestamp
			EndIf

			For $i In $aInetHandlePool
				;this loop is unstable, downloading may end even though there are still handles in the pool
				; therefore we cannot collect any info from 'InetGetInfo', eg. size
				If TimerDiff($t) > $iTimeout Then ExitLoop
				If Not IsNumber($i) Then
					ConsoleWrite("i=" & $i & @CRLF)
					ContinueLoop ; an emptyness bug?
				EndIf

				If InetGetInfo($aInetHandles[$i], $INET_DOWNLOADCOMPLETE) Then
					InetClose($aInetHandles[$i])
					__AsyncInet_RemoveFromPool($aInetHandlePool, $i)
					; loading file to the array can speed up the proccess on big file tranfers
					If FileExists($sTmpFolder & "\" & $i) Then
						$aOutputData[$i] = __AsyncInet_FileReadBin($sTmpFolder & "\" & $i)
						__AsyncInet_RemoveFromPool($aOutputDataPool, $i)
					EndIf
				EndIf

			Next

			Sleep(1) ; throttling
		Until InetGetInfo() < 1

		; read the downloaded files to array
		If IsArray($aOutputDataPool) Then
			For $i In $aOutputDataPool
				If Not IsNumber($i) Then ContinueLoop ; an emptyness bug?
				InetClose($aInetHandles[$i])
				If FileExists($sTmpFolder & "\" & $i) Then $aOutputData[$i] = __AsyncInet_FileReadBin($sTmpFolder & "\" & $i)
			Next
		EndIf

		Return $aOutputData

	EndFunc   ;==>_AsyncInet_Read
#EndRegion Public Functions

#Region Private Functions
	Func __AsyncInet_Default($vValue, $vDefault)
		If IsKeyword($vValue) Or $vValue = "" Or $vValue = 0 Or IsObj($vValue) Or IsArray($vValue) Then Return $vDefault
		Return $vValue
	EndFunc   ;==>__AsyncInet_Default

	Func __AsyncInet_FileReadBin($sPath)
		Local $fo, $sReturn
		$fo = FileOpen($sPath, $FO_BINARY)
		$sReturn = FileRead($fo)
		FileClose($fo)
		Return $sReturn
	EndFunc   ;==>__AsyncInet_FileReadBin

	Func __AsyncInet_OnExit()
		; remove corpses
		Local $aTmp = _FileListToArray($__AI_TMPDIR_PARENT, $__AI_TMPDIR_PREFIX & '*', 2)
		If Not @error Then
			For $i = 1 To $aTmp[0]
				DirRemove($__AI_TMPDIR_PARENT & "\" & $aTmp[$i], 1)
			Next
		EndIf
	EndFunc   ;==>__AsyncInet_OnExit

	Func __AsyncInet_RemoveFromPool(ByRef $avArray, $vValue)
		Return _ArrayDelete($avArray, _ArrayBinarySearch($avArray, $vValue))
	EndFunc   ;==>__AsyncInet_RemoveFromPool

	Func __AsyncInet_RandomGen($iLength)
		Local $sReturn
		While StringLen($sReturn) < $iLength
			$sReturn &= Random(0, 1, 1) ? Chr(Random(97, 122, 1)) : Chr(Random(65, 90, 1))
		WEnd
		Return $sReturn
	EndFunc   ;==>__AsyncInet_RandomGen
#EndRegion Private Functions
