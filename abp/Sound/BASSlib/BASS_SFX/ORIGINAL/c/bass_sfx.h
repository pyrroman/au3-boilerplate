#ifdef __cplusplus
extern "C" {
#endif

#ifndef SFXDEF
#define SFXDEF(f) WINAPI f
#endif

#ifndef HSFX
typedef	long HSFX;
#endif

//visualization plugin types
#define		BASS_SFX_SONIQUE 0
#define		BASS_SFX_WINAMP 1
#define		BASS_SFX_WMP 2
#define		BASS_SFX_BBP 3

// PluginCreate Flags
#define		BASS_SFX_SONIQUE_OPENGL					1 //render sonique plugins using OpenGL
#define		BASS_SFX_SONIQUE_OPENGL_DOUBLEBUFFER	2 //use OpenGL double buffering

// Error codes returned by BASS_SFX_ErrorGetCode
#define		BASS_SFX_OK					0	// all is OK
#define		BASS_SFX_ERROR_MEM			1	// memory error
#define		BASS_SFX_ERROR_FILEOPEN		2	// can't open the file
#define		BASS_SFX_ERROR_HANDLE		3	// invalid handle
#define		BASS_SFX_ERROR_ALREADY		4	// already initialized
#define		BASS_SFX_ERROR_FORMAT		5	// unsupported plugin format
#define		BASS_SFX_ERROR_INIT			6	// BASS_SFX_Init has not been successfully called
#define		BASS_SFX_ERROR_GUID			7	// can't open WMP plugin using specified GUID
#define		BASS_SFX_ERROR_UNKNOWN		-1	// some other mystery problem

// Windows Media Player Specific
typedef struct{
	const char* name;
	const char* clsid;
}BASS_SFX_PLUGININFO;

typedef struct{
	LPCWSTR name;
	LPCWSTR clsid;
}BASS_SFX_PLUGININFOW;

BOOL		SFXDEF(BASS_SFX_WMP_GetPlugin)(int index, BASS_SFX_PLUGININFO* info);
BOOL		SFXDEF(BASS_SFX_WMP_GetPluginW)(int index, BASS_SFX_PLUGININFOW* info);

DWORD		SFXDEF(BASS_SFX_GetVersion)();
DWORD		SFXDEF(BASS_SFX_ErrorGetCode)();
BOOL		SFXDEF(BASS_SFX_Init)(HINSTANCE hInstance, HWND hWnd);
DWORD		SFXDEF(BASS_SFX_PluginFlags)(HSFX handle, DWORD flags, DWORD mask);
HSFX		SFXDEF(BASS_SFX_PluginCreate)(char* strPath, HWND hPluginWnd, int nWidth, int nHeight, DWORD flags);
HSFX		SFXDEF(BASS_SFX_PluginCreateW)(LPCWSTR strPath, HWND hPluginWnd, int nWidth, int nHeight, DWORD flags);
int			SFXDEF(BASS_SFX_PluginGetType)(HSFX handle);
BOOL		SFXDEF(BASS_SFX_PluginSetStream)(HSFX handle, HSTREAM hStream);
BOOL		SFXDEF(BASS_SFX_PluginStart)(HSFX handle);
BOOL		SFXDEF(BASS_SFX_PluginStop)(HSFX handle);
char*		SFXDEF(BASS_SFX_PluginGetName)(HSFX handle);
char*		SFXDEF(BASS_SFX_PluginGetNameW)(HSFX handle);
BOOL		SFXDEF(BASS_SFX_PluginConfig)(HSFX handle);
int			SFXDEF(BASS_SFX_PluginModuleGetCount)(HSFX handle);
char*		SFXDEF(BASS_SFX_PluginModuleGetName)(HSFX handle, int module);
LPCWSTR		SFXDEF(BASS_SFX_PluginModuleGetNameW)(HSFX handle, int module);
BOOL		SFXDEF(BASS_SFX_PluginModuleSetActive)(HSFX handle, int module);
int			SFXDEF(BASS_SFX_PluginModuleGetActive)(HSFX handle);
BOOL		SFXDEF(BASS_SFX_PluginRender)(HSFX handle, HSTREAM hStream, HDC hDC); //only sonique, bassbox, or WMP
BOOL		SFXDEF(BASS_SFX_PluginClicked)(HSFX handle, int x, int y);
BOOL		SFXDEF(BASS_SFX_PluginResize)(HSFX handle, int nWidth, int nHeight);
BOOL		SFXDEF(BASS_SFX_PluginFree)(HSFX handle);
BOOL		SFXDEF(BASS_SFX_Free)();

	
#ifdef __cplusplus
}
#endif