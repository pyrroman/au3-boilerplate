// minimal.cpp : Defines the entry point for the application.
//

#include "stdafx.h"

UINT GetResource(LPCWSTR uri, /*out*/LPCBYTE& pb, /*out*/UINT& cb);
UINT CALLBACK MinimalHostCallback( LPSCITER_CALLBACK_NOTIFICATION pns, LPVOID callbackParam );

HINSTANCE ghInstance = 0;

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{

  ghInstance = hInstance;

  HWND hwnd = CreateWindow(
    SciterClassNameT(), 
    TEXT("Sciter"), 
    WS_OVERLAPPEDWINDOW | WS_VISIBLE, 
    CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
    NULL, NULL, hInstance, 0);

  SciterSetCallback(hwnd, MinimalHostCallback, 0 /*cbParam is not ised in this sample*/ );
  LPCBYTE pb = 0;
  UINT   cb = 0;
  GetResource(L"default.html",pb,cb);
  assert( pb && cb );
  SciterLoadHtml(hwnd, pb,cb, NULL ); 

  // Main message loop:
  MSG msg;
  while (IsWindow(hwnd) && GetMessage(&msg, NULL, 0, 0)) 
  {
    if(!SciterTranslateMessage(&msg))
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }
  return 0;
}

UINT GetResource(LPCWSTR uri, /*out*/LPCBYTE& pb, /*out*/UINT& cb)
  {
    if (!uri || !uri[0]) return LOAD_DISCARD;

    // Retrieve url specification into a local storage since FindResource() expects 
    // to find its parameters on stack rather then on the heap under Win9x/Me

    WCHAR url[MAX_PATH]; wcsncpy(url, uri, MAX_PATH);
    
    LPCWSTR name = url;

    // Separate extension if any

    LPWSTR ext = (LPWSTR)wcschr(name, L'.'); if (ext) *ext++ = L'\0';

    // Find specified resource and leave if failed. Note that we use extension
    // as the custom resource type specification or assume standard HTML resource 
    // if no extension is specified

    HRSRC hrsrc = 0;
    bool  isHtml = false;
    if( ext == 0 || wcsicmp(ext, L"HTML") == 0)
    {
      hrsrc = ::FindResourceW(ghInstance, name, (LPCWSTR)RT_HTML);
      isHtml = true;
    }
    else
      hrsrc = ::FindResourceW(ghInstance, name, ext);

    if (!hrsrc) return LOAD_OK; // resource not found here - proceed with default loader

    // Load specified resource and check if ok

    HGLOBAL hgres = ::LoadResource(ghInstance, hrsrc);
    if (!hgres) return LOAD_DISCARD;

    // Retrieve resource data and check if ok

    pb = (LPCBYTE)::LockResource(hgres); if (!pb) return LOAD_DISCARD;
    cb = ::SizeofResource(ghInstance, hrsrc); if (!cb) return LOAD_DISCARD;

    // Report data ready

    return LOAD_OK;
  }

  static UINT OnLoadData(LPSCN_LOAD_DATA pns)
  {
    if( wcsncmp(pns->uri, L"app:", 4) == 0) // we are using basic:name.ext schema to refer to resources contained in this exe.
      return GetResource( pns->uri + 4, pns->outData, pns->outDataSize );

    return LOAD_OK; // proceed with the default loader.
  }

  static UINT OnCallbackHost(LPSCN_CALLBACK_HOST pns)
  {
    if( pns->channel == 1 || pns->channel == 2) // stdout and stderr
    {
      static bool console_allocated = false;
      if(!console_allocated)
      {
        console_allocated = true;
        AllocConsole();
        freopen("conin$", "r", stdin);
        freopen("conout$", "w", stdout);
        freopen("conout$", "w", stderr);
      }
      std::wstring s = pns->p1.to_string();
      printf("%S", s.c_str());
    }
    return 0;
  }

  /* callback function used in SciterSetCallback */

  UINT CALLBACK MinimalHostCallback( LPSCITER_CALLBACK_NOTIFICATION pns, LPVOID callbackParam )
  {
    callbackParam; // we are not using callbackParam in the sample, use it when you need this to be a method of some class
    switch(pns->code)  
    {
      case SC_LOAD_DATA: return OnLoadData(LPSCN_LOAD_DATA(pns));
    //case SC_DATA_LOADED: return OnDataLoad(LPSCN_DATA_LOADED(pns));
    //...
      case SC_CALLBACK_HOST: 
        return OnCallbackHost(LPSCN_CALLBACK_HOST(pns));
    }
    return 0;
  }

