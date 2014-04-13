#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

$aData = _EnumIconFile(@ScriptDir & '\MyIcon.ico')
If Not @Error Then
    _ArrayDisplay($aData)
EndIf

; #FUNCTION# ====================================================================================================================
; Name...........: _EnumIconFile
; Description....: Enumerates an icons from the specified .ico file.
; Syntax.........: _EnumIconFile ( $sFile )
; Parameters.....: $sFile  - The path to the .ico file whose icons are to be enumerated.
; Return values..: Success - The 2D array containing the following information:
;
;                            [0][0] - Number of rows in array (n)
;                            [0][i] - Unused
;                            [n][0] - The width of the icon, in pixels.
;                            [n][1] - The heigth of the icon, in pixels.
;                            [n][2] - The color depth of the icon, in bits-per-pixel.
;                            [n][3] - 1 (TRUE) if the icon has a PNG compression (Windows Vista+), or 0 (FALSE) otherwise.
;
;                  Failure - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================================

Func _EnumIconFile($sFile)

    Local $hFile, $tEntry, $tHeader, $tData, $pData, $pIcon, $Bytes, $Count, $Offset, $Enum = 0

    $hFile = _WinAPI_CreateFileEx($sFile, 3, 0x80000000, 0x03)
    If @Error Then
        Return SetError(1, 0, 0)
    EndIf
    Do
        $Bytes = _WinAPI_GetFileSizeEx($hFile)
        If Not $Bytes Then
            ExitLoop
        EndIf
        $tData = DllStructCreate('byte[' & $Bytes & ']')
        $pData = DllStructGetPtr($tData)
        If Not _WinAPI_ReadFile($hFile, $pData, $Bytes, $Bytes) Then
            ExitLoop
        EndIf
        $tHeader = DllStructCreate('ushort;ushort;ushort', $pData)
        $Count = DllStructGetData($tHeader, 3)
        If Not $Count Then
            ExitLoop
        EndIf
        Dim $Enum[$Count + 1][4] = [[$Count]]
        For $i = 1 To $Count
            $tEntry = DllStructCreate('byte;byte;byte;byte;ushort;ushort;long;long', $pData + 6 + 16 * ($i - 1))
            $Offset = DllStructGetData($tEntry, 8)
            $pIcon = $pData + $Offset
            $Enum[$i][2] = DllStructGetData($tEntry, 6)
            If DllStructGetData(DllStructCreate('byte[8]', $pIcon), 1) = Binary('0x89504E470D0A1A0A') Then
                ; PNG => Retrieve IHDR chunk data (always first chunk, offset = 8)
                $tHeader = DllStructCreate('dword;dword;byte;byte;byte;byte;byte', $pIcon + 16)
                $Enum[$i][0] = _WinAPI_SwapDWord(DllStructGetData($tHeader, 1))
                $Enum[$i][1] = _WinAPI_SwapDWord(DllStructGetData($tHeader, 2))
                $Enum[$i][3] = 1
            Else
                ; ICO => Retrieve BITMAPINFOHEADER structure
                $tHeader = DllStructCreate($tagBITMAPINFOHEADER, $pIcon)
                $Enum[$i][0] = DllStructGetData($tHeader, 2)
                $Enum[$i][1] = DllStructGetData($tHeader, 3) / 2
                $Enum[$i][3] = 0
            EndIf
        Next
    Until 1
    _WinAPI_CloseHandle($hFile)
    If Not IsArray($Enum) Then
        Return SetError(1, 0, 0)
    EndIf
    Return $Enum
	EndFunc   ;==>_EnumIconFile

; #FUNCTION# ====================================================================================================================
; Name...........: _EnumIconResource
; Description....: Enumerates an icons from the specified icon resource associated with a binary module.
; Syntax.........: _EnumIconResource ( $hModule, $sIcon )
; Parameters.....: $hModule - A handle to the binary module that contains the specified icon resource.
;                  $sIcon   - The name of the icon resource whose icons are to be enumerated.
; Return values..: Success  - The 2D array containing the following information:
;
;                             [0][0] - Number of rows in array (n)
;                             [0][i] - Unused
;                             [n][0] - The width of the icon, in pixels.
;                             [n][1] - The heigth of the icon, in pixels.
;                             [n][2] - The color depth of the icon, in bits-per-pixel.
;                             [n][3] - 1 (TRUE) if the icon has a PNG compression (Windows Vista+), or 0 (FALSE) otherwise.
;
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================================

Func _EnumIconResource($hModule, $sIcon)

    Local $hResource, $hInfo, $pData, $pIcon, $tDir, $tHeader, $Count, $Enum

    $hResource = _WinAPI_FindResource($hModule, 14, $sIcon)
    If @Error Then
        Return SetError(1, 0, 0)
    EndIf
    $hInfo = _WinAPI_LoadResource($hModule, $hResource)
    If @Error Then
        Return SetError(1, 0, 0)
    EndIf
    $pData = _WinAPI_LockResource($hInfo)
    If @Error Then
        Return SetError(1, 0, 0)
    EndIf
    $tHeader = DllStructCreate('ushort;ushort;ushort', $pData)
    $Count = DllStructGetData($tHeader, 3)
    If Not $Count Then
        Return SetError(1, 0, 0)
    EndIf
    Dim $Enum[$Count + 1][4] = [[$Count]]
    For $i = 1 To $Count
        $tDir = DllStructCreate('byte;byte;byte;byte;ushort;ushort;dword;ushort', $pData + 6 + 14 * ($i - 1))
        $hResource = _WinAPI_FindResource($hModule, 3, DllStructGetData($tDir, 8))
        If @Error Then
            Return SetError(1, 0, 0)
        EndIf
        $hInfo = _WinAPI_LoadResource($hModule, $hResource)
        If @Error Then
            Return SetError(1, 0, 0)
        EndIf
        $pIcon = _WinAPI_LockResource($hInfo)
        If @Error Then
            Return SetError(1, 0, 0)
        EndIf
        $Enum[$i][2] = DllStructGetData($tDir, 6)
        If DllStructGetData(DllStructCreate('byte[8]', $pIcon), 1) = Binary('0x89504E470D0A1A0A') Then
            ; PNG => Retrieve IHDR chunk data (always first chunk, offset = 8)
            $tHeader = DllStructCreate('dword;dword;byte;byte;byte;byte;byte', $pIcon + 16)
            $Enum[$i][0] = _WinAPI_SwapDWord(DllStructGetData($tHeader, 1))
            $Enum[$i][1] = _WinAPI_SwapDWord(DllStructGetData($tHeader, 2))
            $Enum[$i][3] = 1
        Else
            ; ICO => Retrieve BITMAPINFOHEADER structure
            $tHeader = DllStructCreate($tagBITMAPINFOHEADER, $pIcon)
            $Enum[$i][0] = DllStructGetData($tHeader, 2)
            $Enum[$i][1] = DllStructGetData($tHeader, 3) / 2
            $Enum[$i][3] = 0
        EndIf
    Next
    Return $Enum
EndFunc   ;==>_EnumIconResource