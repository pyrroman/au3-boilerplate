#include "../AutoitObject.au3"

Opt("GUIOnEventMode", 1)

; Error monitoring
Global $oError = ObjEvent("AutoIt.Error", "_ErrFunc")
Func _ErrFunc()
	ConsoleWrite("! COM Error !  Number: 0x" & Hex($oError.number, 8) & "   ScriptLine: " & $oError.scriptline & " - " & $oError.windescription & @CRLF)
	Return
EndFunc   ;==>_ErrFunc


; DirectX related constants
Global Const $D3D_SDK_VERSION = 32
Global Const $D3DCLEAR_TARGET = 1
Global Const $D3DFVF_XYZRHW = 64
Global Const $D3DFVF_DIFFUSE = 4
Global Const $D3DPT_TRIANGLELIST = 4
Global Const $D3DSWAPEFFECT_DISCARD = 1
Global Const $D3DDEVTYPE_HAL = 1
Global Const $D3DCREATE_SOFTWARE_VERTEXPROCESSING = 32
Global Const $D3DADAPTER_DEFAULT = 0
Global Const $D3DPOOL_DEFAULT = 0

; Used Dlls
Global Const $hD3D9 = DllOpen("d3d9.dll")
Global Const $hUSER32 = DllOpen("user32.dll")
Global Const $hKERNEL32 = DllOpen("kernel32.dll")

; Start the AutoItObject library
_AutoItObject_StartUp()

; GUI
Global Const $hGUI = GUICreate("DirectX -- Direct3D/AutoitObject", 400, 400)

; IDirect3D9 interface pointer
Global $pD3D9 = _Direct3DCreate9()

; IDirect3D9 interface tag
Global $tagD3D9Interface = "QueryInterface;" & _
		"AddRef;" & _
		"Release;" & _
		"RegisterSoftwareDevice;" & _
		"GetAdapterCount;" & _
		"GetAdapterIdentifier;" & _
		"GetAdapterModeCount;" & _
		"EnumAdapterModes;" & _
		"GetAdapterDisplayMode;" & _
		"CheckDeviceType;" & _
		"CheckDeviceFormat;" & _
		"CheckDeviceMultiSampleType;" & _
		"CheckDepthStencilMatch;" & _
		"CheckDeviceFormatConversion;" & _
		"GetDeviceCaps;" & _
		"GetAdapterMonitor;" & _
		"CreateDevice;"

; IDirect3D9 interface object
Global $oD3D9 = _AutoItObject_WrapperCreate($pD3D9, $tagD3D9Interface)

; Call CreateDevice to set IDirect3DDevice9 interface
Global $pDevice = _D3D9_CreateDevice($hGUI)

; IDirect3DDevice9 interface tag
Global $tagD3DDevice9Interface = "QueryInterface;" & _
		"AddRef;" & _
		"Release;" & _
		"TestCooperativeLevel;" & _
		"GetAvailableTextureMem;" & _
		"EvictManagedResources;" & _
		"GetDirect3D;" & _
		"GetDeviceCaps;" & _
		"GetDisplayMode;" & _
		"GetCreationParameters;" & _
		"SetCursorProperties;" & _
		"SetCursorPosition;" & _
		"ShowCursor;" & _
		"CreateAdditionalSwapChain;" & _
		"GetSwapChain;" & _
		"GetNumberOfSwapChains;" & _
		"Reset;" & _
		"Present;" & _
		"GetBackBuffer;" & _
		"GetRasterStatus;" & _
		"SetDialogBoxMode;" & _
		"SetGammaRamp;" & _
		"GetGammaRamp;" & _
		"CreateTexture;" & _
		"CreateVolumeTexture;" & _
		"CreateCubeTexture;" & _
		"CreateVertexBuffer;" & _
		"CreateIndexBuffer;" & _
		"CreateRenderTarget;" & _
		"CreateDepthStencilSurface;" & _
		"UpdateSurface;" & _
		"UpdateTexture;" & _
		"GetRenderTargetData;" & _
		"GetFrontBufferData;" & _
		"StretchRect;" & _
		"ColorFill;" & _
		"CreateOffscreenPlainSurface;" & _
		"SetRenderTarget;" & _
		"GetRenderTarget;" & _
		"SetDepthStencilSurface;" & _
		"GetDepthStencilSurface;" & _
		"BeginScene;" & _
		"EndScene;" & _
		"Clear;" & _
		"SetTransform;" & _
		"GetTransform;" & _
		"MultiplyTransform;" & _
		"SetViewport;" & _
		"GetViewport;" & _
		"SetMaterial;" & _
		"GetMaterial;" & _
		"SetLight;" & _
		"GetLight;" & _
		"LightEnable;" & _
		"GetLightEnable;" & _
		"SetClipPlane;" & _
		"GetClipPlane;" & _
		"SetRenderState;" & _
		"GetRenderState;" & _
		"CreateStateBlock;" & _
		"BeginStateBlock;" & _
		"EndStateBlock;" & _
		"SetClipStatus;" & _
		"GetClipStatus;" & _
		"GetTexture;" & _
		"SetTexture;" & _
		"GetTextureStageState;" & _
		"SetTextureStageState;" & _
		"GetSamplerState;" & _
		"SetSamplerState;" & _
		"ValidateDevice;" & _
		"SetPaletteEntries;" & _
		"GetPaletteEntries;" & _
		"SetCurrentTexturePalette;" & _
		"GetCurrentTexturePalette;" & _
		"SetScissorRect;" & _
		"GetScissorRect;" & _
		"SetSoftwareVertexProcessing;" & _
		"GetSoftwareVertexProcessing;" & _
		"SetNPatchMode;" & _
		"GetNPatchMode;" & _
		"DrawPrimitive;" & _
		"DrawIndexedPrimitive;" & _
		"DrawPrimitiveUP;" & _
		"DrawIndexedPrimitiveUP;" & _
		"ProcessVertices;" & _
		"CreateVertexDeclaration;" & _
		"SetVertexDeclaration;" & _
		"GetVertexDeclaration;" & _
		"SetFVF;" & _
		"GetFVF;" & _
		"CreateVertexShader;" & _
		"SetVertexShader;" & _
		"GetVertexShader;" & _
		"SetVertexShaderConstantF;" & _
		"GetVertexShaderConstantF;" & _
		"SetVertexShaderConstantI;" & _
		"GetVertexShaderConstantI;" & _
		"SetVertexShaderConstantB;" & _
		"GetVertexShaderConstantB;" & _
		"SetStreamSource;" & _
		"GetStreamSource;" & _
		"SetStreamSourceFreq;" & _
		"GetStreamSourceFreq;" & _
		"SetIndices;" & _
		"GetIndices;" & _
		"CreatePixelShader;" & _
		"SetPixelShader;" & _
		"GetPixelShader;" & _
		"SetPixelShaderConstantF;" & _
		"GetPixelShaderConstantF;" & _
		"SetPixelShaderConstantI;" & _
		"GetPixelShaderConstantI;" & _
		"SetPixelShaderConstantB;" & _
		"GetPixelShaderConstantB;" & _
		"DrawRectPatch;" & _
		"DrawTriPatch;" & _
		"DeletePatch;" & _
		"CreateQuery;"

; IDirect3DDevice9 interface object
Global $oD3DDevice9 = _AutoItObject_WrapperCreate($pDevice, $tagD3DDevice9Interface)

; Defining three points of the triangle to make
Global $tagCUSTOMVERTEX = "float X;float Y;float Z;float rhw;dword Color;"
Global $tVERTICES = DllStructCreate($tagCUSTOMVERTEX & $tagCUSTOMVERTEX & $tagCUSTOMVERTEX)

; First point
DllStructSetData($tVERTICES, 1, 200) ; X
DllStructSetData($tVERTICES, 2, 50) ; Y
DllStructSetData($tVERTICES, 3, 0) ; Z
DllStructSetData($tVERTICES, 4, 1)
DllStructSetData($tVERTICES, 5, 0xFFFF0000) ; Red (ARGB)

; Second point
DllStructSetData($tVERTICES, 6, 350) ; X
DllStructSetData($tVERTICES, 7, 350) ; Y
DllStructSetData($tVERTICES, 8, 0) ; Z
DllStructSetData($tVERTICES, 9, 1)
DllStructSetData($tVERTICES, 10, 0xFF00FF00) ; Green (ARGB)

; Third point
DllStructSetData($tVERTICES, 11, 50) ; X
DllStructSetData($tVERTICES, 12, 350) ; Y
DllStructSetData($tVERTICES, 13, 0) ; Z
DllStructSetData($tVERTICES, 14, 1)
DllStructSetData($tVERTICES, 15, 0xFF0000FF) ; Blue (ARGB)


; Create IDirect3DVertexBuffer9 interface
Global $pD3DVB = _D3D9_CreateVertexBuffer($pDevice, DllStructGetSize($tVERTICES), 0, BitOR($D3DFVF_XYZRHW, $D3DFVF_DIFFUSE), $D3DPOOL_DEFAULT)

; IDirect3DVertexBuffer9 interface tag
Global $tagD3D9VertexInterface = "QueryInterface;" & _
		"AddRef;" & _
		"Release;" & _
		"GetDevice;" & _
		"SetPrivateData;" & _
		"GetPrivateData;" & _
		"FreePrivateData;" & _
		"SetPriority;" & _
		"GetPriority;" & _
		"PreLoad;" & _
		"GetType;" & _
		"Lock;" & _
		"Unlock;" & _
		"GetDesc;"

; IDirect3DVertexBuffer9 interface object
$oD3D9Vertex = _AutoItObject_WrapperCreate($pD3DVB, $tagD3D9VertexInterface)
_D3DVB_Lock($pD3DVB, DllStructGetSize($tVERTICES), DllStructGetPtr($tVERTICES), 0)
$oD3D9Vertex.Unlock("long")


GUIRegisterMsg(15, "_Preserve") ; WM_PAINT
; Handle exit
GUISetOnEvent(-3, "_Quit")
; Show GUI
GUISetState()

; Render scene every 100ms till exit
While 1
	_Render()
	Sleep(100)
WEnd

; Drawing function
Func _Render()
		;$oD3DDevice9.Clear("long", "dword", 0, "dword", 0, "dword", $D3DCLEAR_TARGET, "dword", 0xFFFFFF00, "float", 1, "dword", 0) ;  yellow (ARGB)
		$oD3DDevice9.Clear("long", "dword", 0, "ptr", 0, "dword", $D3DCLEAR_TARGET, "dword", 0, "float", 1, "dword", 0) ; black
		$oD3DDevice9.BeginScene("long")
		$oD3DDevice9.SetStreamSource("long", "dword", 0, "ptr", Number($pD3DVB), "dword", 0, "dword", 20) ; DllStructGetSize($tCUSTOMVERTEX)
		$oD3DDevice9.SetFVF("long", "dword", 0x44) ; BitOR($D3DFVF_XYZRHW, $D3DFVF_DIFFUSE)
		$oD3DDevice9.DrawPrimitive("long", "dword", $D3DPT_TRIANGLELIST, "dword", 0, "dword", 1)
		$oD3DDevice9.EndScene("long")
		$oD3DDevice9.Present("long", "ptr", 0, "ptr", 0, "hwnd", 0, "ptr", 0)
EndFunc   ;==>_Render

; THAT'S IT, THE END.




; Direct3D9 functions:
Func _Direct3DCreate9()
	Local $aCall = DllCall($hD3D9, "ptr", "Direct3DCreate9", "dword", $D3D_SDK_VERSION)
	If @error Or Not $aCall[0] Then
		Return SetError(1, 0, 0)
	EndIf
	Return $aCall[0]
EndFunc   ;==>_Direct3DCreate9


Func _D3D9_CreateDevice($hWnd)
	Local $tD3DPRESENT_PARAMETERS = DllStructCreate("dword BackBufferWidth;" & _
			"dword BackBufferHeight;" & _
			"dword BackBufferFormat;" & _
			"dword BackBufferCount;" & _
			"dword MultiSampleType;" & _
			"dword MultiSampleQuality;" & _
			"dword SwapEffect;" & _
			"ptr DeviceWindow;" & _
			"int Windowed;" & _
			"int EnableAutoDepthStencil;" & _
			"dword AutoDepthStencilFormat;" & _
			"dword Flags;" & _
			"dword FullScreenRefreshRateInHz;" & _
			"dword PresentationInterval;")

	DllStructSetData($tD3DPRESENT_PARAMETERS, "SwapEffect", $D3DSWAPEFFECT_DISCARD)
	DllStructSetData($tD3DPRESENT_PARAMETERS, "Windowed", 1)

	Local $aCall = $oD3D9.CreateDevice("long", "dword", $D3DADAPTER_DEFAULT, "dword", $D3DDEVTYPE_HAL, "ptr", Number($hWnd), "dword", $D3DCREATE_SOFTWARE_VERTEXPROCESSING, "ptr", Number(DllStructGetPtr($tD3DPRESENT_PARAMETERS)), "ptr*", 0)
	If Not IsArray($aCall) Then Return SetError(1, 0, 0)
	Return $aCall[6]
EndFunc   ;==>_D3D9_CreateDevice


Func _D3D9_CreateVertexBuffer($pDevice, $iLength, $iUsage, $iFVF, $iPool)
	Local $aCall = $oD3DDevice9.CreateVertexBuffer("long", "dword", $iLength, "dword", $iUsage, "dword", $iFVF, "dword", $iPool, "ptr*", 0, "ptr", 0)
	If Not IsArray($aCall) Then Return SetError(1, 0, 0)
	Return $aCall[5]
EndFunc   ;==>_D3D9_CreateVertexBuffer


Func _D3DVB_Lock($pD3DVB, $iSizeToLock, $pData, $iFlags)
	Local $aCall = $oD3D9Vertex.Lock("long", "dword", 0, "dword", $iSizeToLock, "ptr*", 0, "dword", $iFlags)
	If Not IsArray($aCall) Then Return SetError(1, 0, 0)
	Local $pVert = $aCall[3]
	_CopyVert($pVert, $pData, $iSizeToLock)
	Return 0
EndFunc   ;==>_D3DVB_Lock

Func _CopyVert($pPointer1, $pPointer2, $iSize) ; copy from one address to another
	Local $tStructure = DllStructCreate("byte[" & $iSize & "]", $pPointer1)
	DllStructSetData($tStructure, 1, DllStructGetData(DllStructCreate("byte[" & $iSize & "]", $pPointer2), 1))
	Return 1
EndFunc   ;==>_CopyVert


Func _Preserve()
	_Render()
EndFunc   ;==>_Preserve

; On Exit Function
Func _Quit()
	$oD3D9Vertex = 0
	$oD3DDevice9 = 0
	$oD3D9 = 0
	Exit
EndFunc   ;==>_Quit





