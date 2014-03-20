Attribute VB_Name = "modBASS_SFX"
' BASS_SFX 2.4.1.5 Visual Basic module
' Copyright (c) 1999-2009 Cube Software Solutions Inc.
'
' See the BASS_SFX.CHM file for more detailed documentation

Global Const BASS_SFX_SONIQUE = 0
Global Const BASS_SFX_WINAMP = 1
Global Const BASS_SFX_WMP = 2
Global Const BASS_SFX_BBP = 3

Global Const BASS_SFX_SONIQUE_OPENGL = 1
Global Const BASS_SFX_SONIQUE_OPENGL_DOUBLEBUFFER = 2

Global Const BASS_SFX_OK = 0
Global Const BASS_SFX_ERROR_MEM = 1
Global Const BASS_SFX_ERROR_FILEOPEN = 2
Global Const BASS_SFX_ERROR_HANDLE = 3
Global Const BASS_SFX_ERROR_ALREADY = 4
Global Const BASS_SFX_ERROR_FORMAT = 5
Global Const BASS_SFX_ERROR_INIT = 6
Global Const BASS_SFX_ERROR_GUID = 7
Global Const BASS_SFX_ERROR_UNKNOWN = -1

Type BASS_SFX_PLUGININFO
        name As Long
        clsid As Long
End Type


Type BASS_SFX_PLUGININFOW
        name As Long
        clsid As Long
End Type

Declare Function BASS_SFX_WMP_GetPlugin Lib "bass.dll" (ByVal index As Long, ByRef info As BASS_SFX_PLUGININFO) As Long
Declare Function BASS_SFX_WMP_GetPluginW Lib "bass.dll" (ByVal index As Long, ByRef info As BASS_SFX_PLUGININFOW) As Long


Declare Function BASS_SFX_ErrorGetCode Lib "bass_sfx.dll" () As Long
Declare Function BASS_SFX_GetVersion Lib "bass_sfx.dll" () As Long
Declare Function BASS_SFX_Init Lib "bass_sfx.dll" (ByVal hInstance As Long, ByVal hWnd As Long) As Long
Declare Function BASS_SFX_PluginFlags Lib "bass_sfx.dll" (ByVal handle As Long, ByVal flags As Long, ByVal mask As Long) As Long
Declare Function BASS_SFX_PluginCreate Lib "bass_sfx.dll" (ByVal strPath As String, ByVal hPluginWnd As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal flags As Long) As Long
Declare Function BASS_SFX_PluginCreateW Lib "bass_sfx.dll" (ByVal strPath As Any, ByVal hPluginWnd As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal flags As Long) As Long
Declare Function BASS_SFX_PluginGetType Lib "bass_sfx.dll" (ByVal handle As Long) As Long
Declare Function BASS_SFX_PluginSetStream Lib "bass_sfx.dll" (ByVal handle As Long, ByVal hStream As Long) As Long
Declare Function BASS_SFX_PluginStart Lib "bass_sfx.dll" (ByVal handle As Long) As Long
Declare Function BASS_SFX_PluginStop Lib "bass_sfx.dll" (ByVal handle As Long) As Long
Declare Function BASS_SFX_PluginGetName Lib "bass_sfx.dll" (ByVal handle As Long) As String
Declare Function BASS_SFX_PluginGetNameW Lib "bass_sfx.dll" (ByVal handle As Long) As Long
Declare Function BASS_SFX_PluginConfig Lib "bass_sfx.dll" (ByVal handle As Long) As Long
Declare Function BASS_SFX_PluginModuleGetCount Lib "bass_sfx.dll" (ByVal handle As Long) As Long
Declare Function BASS_SFX_PluginModuleGetName Lib "bass_sfx.dll" (ByVal handle As Long, ByVal nModule As Long) As String
Declare Function BASS_SFX_PluginModuleGetNameW Lib "bass_sfx.dll" (ByVal handle As Long, ByVal nModule As Long) As Long
Declare Function BASS_SFX_PluginModuleSetActive Lib "bass_sfx.dll" (ByVal handle As Long, ByVal nModule As Long) As Long
Declare Function BASS_SFX_PluginModuleGetActive Lib "bass_sfx.dll" (ByVal handle As Long) As Long
Declare Function BASS_SFX_PluginRender Lib "bass_sfx.dll" (ByVal handle As Long, ByVal hStream As Long, ByVal hDC As Long) As Long
Declare Function BASS_SFX_PluginClicked Lib "bass_sfx.dll" (ByVal handle As Long, ByVal X As Long, ByVal Y As Long) As Long
Declare Function BASS_SFX_PluginResize Lib "bass_sfx.dll" (ByVal handle As Long, ByVal nWidth As Long, ByVal nHeight As Long) As Long
Declare Function BASS_SFX_PluginFree Lib "bass_sfx.dll" (ByVal handle As Long) As Long
Declare Function BASS_SFX_Free Lib "bass_sfx.dll" () As Long
