// wtlView.cpp : implementation of the CSciterView class
//
/////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "resource.h"

#include "wtlView.h"

sciter::debug_output_console dbgcon;

BOOL CSciterView::PreTranslateMessage(MSG* pMsg)
{
  pMsg;
  return FALSE;
}
 
VOID InitNativeClasses(HWND hwnd);

LRESULT CSciterView::OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
{
  setup_callback();
  // Attach self as a "ground" handler of all DOM events, 
  // so we can handle all events dispatched to DOM element before and after them.
  sciter::attach_dom_event_handler(m_hWnd, this);

  InitNativeClasses(m_hWnd);

  LPCBYTE pb = 0;
  UINT   cb = 0;
  GetResource(L"default.html",pb,cb);
  assert( pb && cb );
  //LPCBYTE pb = (LPCBYTE)"<html><body>Hello world</body></html>";
  //UINT   cb = strlen((const char*)pb);
  BOOL r = SciterLoadHtml(m_hWnd, pb,cb, NULL );
  
  return 0;
}

LRESULT CSciterView::on_callback_host(LPSCN_CALLBACK_HOST pns)
{ 
  switch(pns->channel)  
  {
    case 0: // 0 - stdin, read from stdin requested, put string into pnmld->r 
      break;  
    case 1: // 1 - stdout, "stdout << something" requested, pnmld->p1 is 
            //     string to output.
      dbgcon.printf("stdout:%S\n", pns->p1.to_string().c_str() );
      break;  
    case 2: // 2 - stderr, "stderr << something" requested or error happened, 
            //     pnmld->p1 is string to output.
      dbgcon.printf("stderr:%S\n", pns->p1.to_string().c_str() );
      break;
    default:
      // view.callback(channel,p1,p2) call from script

      dbgcon.printf("callback on channel %d, values: %S,%S\n", pns->channel, pns->p1.to_string(CVT_JSON_LITERAL).c_str(), pns->p2.to_string(CVT_JSON_LITERAL).c_str() );
      // implement this if needed
      break;  
  }
  return 0; 
}


UINT CSciterView::GetResource(LPCWSTR uri, /*out*/LPCBYTE& pb, /*out*/UINT& cb)
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
      hrsrc = ::FindResourceW(_Module.GetResourceInstance(), name, (LPCWSTR)RT_HTML);
      isHtml = true;
    }
    else
      hrsrc = ::FindResourceW(_Module.GetResourceInstance(), name, ext);

    if (!hrsrc) return LOAD_OK; // resource not found here - proceed with default loader

    // Load specified resource and check if ok

    HGLOBAL hgres = ::LoadResource(_Module.GetResourceInstance(), hrsrc);
    if (!hgres) return LOAD_DISCARD;

    // Retrieve resource data and check if ok

    pb = (PBYTE)::LockResource(hgres); if (!pb) return LOAD_DISCARD;
    cb = ::SizeofResource(_Module.GetResourceInstance(), hrsrc); if (!cb) return LOAD_DISCARD;

    // Report data ready

    return LOAD_OK;
  }

  // CSciterView is also a sciter::event_handler - handler of DOM events
  bool CSciterView::handle_scripting_call(HELEMENT he, SCRIPTING_METHOD_PARAMS& params )
  {
    if( aux::streq(params.name, "applicationName") )
    {
      params.result = json::value(L"WTL demo");
      return true;
    }
    else if( aux::streq(params.name, "showValue") && params.argc == 1)
    {
      struct foreach_o: SCITER_VALUE::enum_cb
      {
         bool on(const SCITER_VALUE& key, const SCITER_VALUE& val) {
           dbgcon.printf("\t%S:%S\n", key.to_string().c_str(), val.to_string().c_str() );
           return true;
         }
      };
      struct foreach_a: SCITER_VALUE::enum_cb
      {
         bool on(const SCITER_VALUE& key, const SCITER_VALUE& val) {
           dbgcon.printf("\t%S\n", val.to_string().c_str() );
           return true;
         }
      };

      if( params.argv[0].is_map() || params.argv[0].is_object_object() )
      {
        dbgcon.printf("showValue(), map/object, fields=%d\n", params.argv[0].length());
        foreach_o fo; 
        params.argv[0].enum_elements(fo);
      }
      else if( params.argv[0].is_array() || params.argv[0].is_object_array() )
      {
        dbgcon.printf("showValue(), array, elements=%d\n", params.argv[0].length());
        foreach_a fa; 
        params.argv[0].enum_elements(fa);
      }
      else 
        dbgcon.printf("Error: CSciterView::showValue(), wrong type of parameter" );
      return true;
    }
    return false;
  }
