// AxSciter.cpp : Implementation of DLL Exports.


#include "stdafx.h"
#include "resource.h"
#include "AxSciter.h"

HINSTANCE ghInstance = 0;

class CAxSciterModule : public CAtlDllModuleT< CAxSciterModule >
{
public :
	DECLARE_LIBID(LIBID_AxSciterLib)
	DECLARE_REGISTRY_APPID_RESOURCEID(IDR_AXSCITER, "{C662EBBC-001C-452D-92B2-FFCD576AFF1C}")
};

CAxSciterModule _AtlModule;


#ifdef _MANAGED
#pragma managed(push, off)
#endif

// DLL Entry Point
extern "C" BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
{
	  ghInstance = hInstance;
    return _AtlModule.DllMain(dwReason, lpReserved); 
}

#ifdef _MANAGED
#pragma managed(pop)
#endif




// Used to determine whether the DLL can be unloaded by OLE
STDAPI DllCanUnloadNow(void)
{
    return _AtlModule.DllCanUnloadNow();
}


// Returns a class factory to create an object of the requested type
STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID* ppv)
{
    return _AtlModule.DllGetClassObject(rclsid, riid, ppv);
}


// DllRegisterServer - Adds entries to the system registry
STDAPI DllRegisterServer(void)
{
    // registers object, typelib and all interfaces in typelib
    HRESULT hr = _AtlModule.DllRegisterServer();
	return hr;
}


// DllUnregisterServer - Removes entries from the system registry
STDAPI DllUnregisterServer(void)
{
	HRESULT hr = _AtlModule.DllUnregisterServer();
	return hr;
}

