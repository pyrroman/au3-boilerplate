#include-once
#include<Memory.au3>
#include<GDIPlus.au3>

; #FUNCTION# ====================================================================================================================
; Name...........: _GDIPlus_ImageLoadFromHGlobal
; Description ...: Creates an Image object based on movable HGlobal memory block
; Syntax.........: _GDIPlus_ImageLoadFromHGlobal($hGlobal)
; Parameters ....: $hGlobal - Handle of a movable HGlobal memory block
; Return values .: Success      - Pointer to a new Image object
;                  Failure      - 0 and either:
;                  |@error and @extended are set if DllCall failed:
;                  | -@error = 1 if could not create IStream
;                  | -@error = 2 if DLLCall to create image failed
;                  |$GDIP_STATUS contains a non zero value specifying the error code
; Author ........: ProgAndy
; Modified.......:
; Remarks .......: After you are done with the object, call _GDIPlus_ImageDispose to release the object resources.
;                  The HGLOBAL will be owned by the image and freed automatically when the image is disposed.
; Related .......: _GDIPlus_ImageLoadFromStream, _GDIPlus_ImageDispose
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GDIPlus_ImageLoadFromHGlobal($hGlobal)
    Local $aResult = DllCall("ole32.dll", "int", "CreateStreamOnHGlobal", "handle", $hGlobal, "bool", True, "ptr*", 0)
    If @error Or $aResult[0] <> 0 Or $aResult[3] = 0 Then Return SetError(1, @error, 0)
    Local $hImage = DllCall($ghGDIPDll, "uint", "GdipLoadImageFromStream", "ptr", $aResult[3], "int*", 0)
    Local $error = @error
    Local $tVARIANT = DllStructCreate("word vt;word r1;word r2;word r3;ptr data; ptr")
    Local $aCall = DllCall("oleaut32.dll", "long", "DispCallFunc", "ptr", $aResult[3], "dword", 8 + 8 * @AutoItX64, "dword", 4, "dword", 23, "dword", 0, "ptr", 0, "ptr", 0, "ptr", DllStructGetPtr($tVARIANT))
    If $error Then Return SetError(2, $error, 0)
    If $hImage[2] = 0 Then Return SetError(3, 0, $hImage[2])
    Return $hImage[2]
EndFunc   ;==>_GDIPlus_ImageLoadFromHGlobal


; #FUNCTION# ====================================================================================================================
; Name...........: _MemGlobalAllocFromBinary
; Description ...: Greates a movable HGLOBAL memory block from binary data
; Syntax.........: _MemGlobalAllocFromBinary($bBinary)
; Parameters ....: $bBinary - Binary data
; Return values .: Success      - Handle of a new movable HGLOBAL
;                  Failure      - 0 and set @error:
;                  |1  - no data
;                  |2  - could not allocate memory
;                  |3  - could not set data to memory
; Author ........: ProgAndy
; Modified.......:
; Remarks .......:
; Related .......: _MemGlobalAlloc, _MemGlobalFree, _MemGlobalLock
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _MemGlobalAllocFromBinary(Const $bBinary)
    Local $iLen = BinaryLen($bBinary)
    If $iLen = 0 Then Return SetError(1, 0, 0)
    Local $hMem = _MemGlobalAlloc($iLen, $GMEM_MOVEABLE)
    If @error Or Not $hMem Then Return SetError(2, 0, 0)
    DllStructSetData(DllStructCreate("byte[" & $iLen & "]", _MemGlobalLock($hMem)), 1, $bBinary)
    If @error Then
        _MemGlobalUnlock($hMem)
        _MemGlobalFree($hMem)
        Return SetError(3, 0, 0)
    EndIf
    _MemGlobalUnlock($hMem)
    Return $hMem
EndFunc   ;==>_MemGlobalAllocFromBinary

; #FUNCTION# ====================================================================================================================
; Name...........: _MemGlobalAllocFromMem
; Description ...: Greates a movable HGLOBAL memory block and copies data from memory
; Syntax.........: _MemGlobalAllocFromMem($pSource, $iLength)
; Parameters ....: $pSource  - Pointer to memorybloc to copy from
;                  $iLength  - Length of data to copy
; Return values .: Success      - Handle of a new movable HGLOBAL
;                  Failure      - 0 and set @error:
;                  |1  - invalid $pSource
;                  |2  - invalid $iLength
;                  |3  - could not allocate memory
; Author ........: ProgAndy
; Modified.......:
; Remarks .......:
; Related .......: _MemGlobalAlloc, _MemGlobalFree, _MemGlobalLock
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _MemGlobalAllocFromMem($pSource, $iLength)
    If Not $pSource Then Return SetError(1, 0, 0)
    If $iLength < 1 Then Return SetError(2, 0, 0)
    Local $hMem = _MemGlobalAlloc($iLength, $GMEM_MOVEABLE)
    If @error Or Not $hMem Then Return SetError(3, 0, 0)
    _MemMoveMemory($pSource, _MemGlobalLock($hMem), $iLength)
    _MemGlobalUnlock($hMem)
    Return $hMem
EndFunc   ;==>_MemGlobalAllocFromMem

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlStatic_SetImage
; Description ...: Sets a HBITMAP to a static control like image or label
; Syntax.........: _GUICtrlStatic_SetImage($iCtrlId, $hBitmap)
; Parameters ....: $iCtrlId  - CtrlId or handle of Control in the current process
;                  $hBitmap  - Pointer top Windows HBITMAP
; Return values .: Success      - 1
;                  Failure      - 0 and set @error:
;                  |1  - invalid $pSource
;                  |1  - invalid $pSource
; Author ........: ProgAndy, Zedna
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlStatic_SetImage($iCtrlId, $hBitmap)
    Local Const $STM_SETIMAGE = 0x0172
    Local Const $IMAGE_BITMAP = 0
    Local Const $SS_BITMAP = 0xE
    Local Const $GWL_STYLE = -16

    If IsHWnd($iCtrlId) Then
        If WinGetProcess($iCtrlId) <> @AutoItPID Then Return SetError(1,0,0)
    Else
        $iCtrlId = GUICtrlGetHandle($iCtrlId)
        If Not $iCtrlId Then Return SetError(2,0,0)
    EndIf
    ; set SS_BITMAP style to control
    Local $oldStyle = DllCall("user32.dll", "long", "GetWindowLong", "hwnd", $iCtrlId, "int", $GWL_STYLE)
    If @error Then Return SetError(3, 0, 0)
    DllCall("user32.dll", "long", "SetWindowLong", "hwnd", $iCtrlId, "int", $GWL_STYLE, "long", BitOR($oldStyle[0], $SS_BITMAP))
    If @error Then Return SetError(4, 0, 0)
    Local $oldBmp = DllCall("user32.dll", "handle", "SendMessageW", "hwnd", $iCtrlId, "int", $STM_SETIMAGE, "wparam", $IMAGE_BITMAP, "handle", $hBitmap)
    If @error Then Return SetError(5, 0, 0)
    If $oldBmp[0] Then _WinAPI_DeleteObject($oldBmp[0])
    Return 1
EndFunc

_GDIPlus_Startup()
$s = Binary(FileRead(RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt", "InstallDir") & "\Examples\GUI\Torus.png"))
$hMem = _MemGlobalAllocFromBinary($s)
$hImage = _GDIPlus_ImageLoadFromHGlobal($hMem)
$gui = GUICreate("Just draw the created image", 300, 300)
GUISetState()
$hGRaph = _GDIPlus_GraphicsCreateFromHWND($gui)
_GDIPlus_GraphicsDrawImage($hGRaph, $hImage, 5, 5)
_GDIPlus_GraphicsDispose($hGRaph)


Do
Until GUIGetMsg() = -3

WinSetTitle($gui, "", "Now using _GUICtrlStatic_SetImage")
_WinAPI_RedrawWindow($gui)

$iLabel = GUICtrlCreateLabel("", 0, 0, 193, 184)
$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
_GUICtrlStatic_SetImage($iLabel, $hBitmap)

Do
Until GUIGetMsg() = -3