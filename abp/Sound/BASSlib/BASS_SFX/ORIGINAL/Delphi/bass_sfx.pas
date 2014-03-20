unit bass_sfx;

interface

uses Windows, Bass;

type
  HSFX = Longint;

  BASS_SFX_PLUGININFO = record
    name: PChar;
    clsid: PChar;
  end;

  BASS_SFX_PLUGININFOW = record
    name: PWChar;
    clsid: PWChar;
  end;

const
  BASS_SFX_SONIQUE = 0;
  BASS_SFX_WINAMP  = 1;
  BASS_SFX_WMP     = 2;
  BASS_SFX_BBP     = 3;
  BASS_SFX_DLL     = 'BASS_SFX.DLL';

  BASS_SFX_SONIQUE_OPENGL = 1;
  BASS_SFX_SONIQUE_OPENGL_DOUBLEBUFFER = 2;

  BASS_SFX_OK = 0;  
  BASS_SFX_ERROR_MEM = 1;
  BASS_SFX_ERROR_FILEOPEN = 2;
  BASS_SFX_ERROR_HANDLE = 3;
  BASS_SFX_ERROR_ALREADY = 4;
  BASS_SFX_ERROR_FORMAT = 5;
  BASS_SFX_ERROR_INIT = 6;
  BASS_SFX_ERROR_GUID = 7;
  BASS_SFX_ERROR_UNKNOWN = -1;

function BASS_SFX_WMP_GetPlugin(index : integer; var info : BASS_SFX_PLUGININFO): BOOL; stdcall; external BASS_SFX_DLL;
function BASS_SFX_WMP_GetPluginW(index : integer; var info : BASS_SFX_PLUGININFOW): BOOL; stdcall; external BASS_SFX_DLL;

function BASS_SFX_GetVersion : DWORD; stdcall; external BASS_SFX_DLL;
function BASS_SFX_ErrorGetCode : DWORD; stdcall; external BASS_SFX_DLL;
function BASS_SFX_Init(hInstance : DWORD; hwnd : THandle): BOOL; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginFlags(handle : HSFX; flags : DWORD; mask : DWORD): DWORD; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginCreate(strPath : PChar; hPluginWnd : THandle; nWidth, nHeight : integer; flags : DWORD): HSFX; stdcall; external BASS_SFX_DLL; //width/height no use to winamp
function BASS_SFX_PluginCreateW(strPath : PWChar; hPluginWnd : THandle; nWidth, nHeight : integer; flags : DWORD): HSFX; stdcall; external BASS_SFX_DLL; //width/height no use to winamp
function BASS_SFX_PluginGetType(handle : HSFX) : integer; stdcall; external BASS_SFX_DLL;//BASS_SFX_SONIQUE or BASS_SFX_WINAMP or BASS_SFX_WMP or BASS_SFX_BBP
function BASS_SFX_PluginSetStream(handle : HSFX; hStream : HSTREAM): BOOL; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginStart(handle: HSFX): BOOL; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginStop(handle : HSFX): BOOL; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginGetName(handle : HSFX) : PChar; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginGetNameW(handle : HSFX) : PWChar; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginConfig(handle : HSFX) :BOOL; stdcall; external BASS_SFX_DLL; //only works for winamp, but harmless to call for other plugins
function BASS_SFX_PluginModuleGetCount(handle : HSFX) : integer; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginModuleGetName(handle : HSFX; module : integer) : PChar; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginModuleGetNameW(handle : HSFX; module : integer) : PWChar; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginModuleSetActive(handle : HSFX; module : integer) : BOOL; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginModuleGetActive(handle : HSFX) : integer; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginRender(handle : HSFX; hStream : HSTREAM; DC : HDC): BOOL; stdcall; external BASS_SFX_DLL; //only sonique, bassbox, or WMP
function BASS_SFX_PluginClicked(handle : HSFX; x, y : integer): BOOL; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginResize(handle : HSFX; nWidth, nHeight : integer): BOOL; stdcall; external BASS_SFX_DLL;
function BASS_SFX_PluginFree(handle : HSFX): BOOL; stdcall; external BASS_SFX_DLL;
function BASS_SFX_Free(): BOOL; stdcall; external BASS_SFX_DLL;

implementation

end.

