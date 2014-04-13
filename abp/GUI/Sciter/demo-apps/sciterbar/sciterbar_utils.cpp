#include "stdafx.h"


static UINT OnLoadData(LPSCN_LOAD_DATA pns);

/* callback function used in SciterSetCallback */

UINT CALLBACK SciterCallback( LPSCITER_CALLBACK_NOTIFICATION pns, LPVOID callbackParam )
{
  callbackParam; // we are not using callbackParam in the sample, use it when you need this to be a method of some class
  switch(pns->code)  
  {
    case SC_LOAD_DATA: return OnLoadData(LPSCN_LOAD_DATA(pns));
    //case SC_DATA_LOADED: return OnDataLoad(LPSCN_DATA_LOADED(pns));
    //...
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
      hrsrc = ::FindResourceW(gInstance, name, (LPCWSTR)RT_HTML);
      isHtml = true;
    }
    else
      hrsrc = ::FindResourceW(gInstance, name, ext);

    if (!hrsrc) return LOAD_OK; // resource not found here - proceed with default loader

    // Load specified resource and check if ok

    HGLOBAL hgres = ::LoadResource(gInstance, hrsrc);
    if (!hgres) return LOAD_DISCARD;

    // Retrieve resource data and check if ok

    pb = (PBYTE)::LockResource(hgres); if (!pb) return LOAD_DISCARD;
    cb = ::SizeofResource(gInstance, hrsrc); if (!cb) return LOAD_DISCARD;

    // Report data ready

    return LOAD_OK;
  }

  static UINT OnLoadData(LPSCN_LOAD_DATA pns)
  {
    if( wcsncmp(pns->uri, L"app:", 6) == 0) // we are using app:name.ext schema to refer to resources contained in this exe.
      return GetResource( pns->uri + 6, pns->outData, pns->outDataSize );

    return LOAD_OK; // proceed with the default loader.
  }
