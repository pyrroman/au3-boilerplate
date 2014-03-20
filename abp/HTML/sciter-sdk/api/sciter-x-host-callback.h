/** \mainpage Terra Informatica Sciter engine.
 *
 * \section legal_sec In legalese
 *
 * The code and information provided "as-is" without
 * warranty of any kind, either expressed or implied.
 *
 * <a href="http://terrainformatica.com/Sciter">Sciter Home</a>
 *
 * (C) 2003-2006, Terra Informatica Software, Inc. and Andrew Fedoniouk
 *
 * \section structure_sec Structure of the documentation
 *
 * See <a href="files.html">Files</a> section.
 **/

/**\file
 * \brief Standard implementation of the Sciter notificantion handler.
 **/

#ifndef __sciter_x_host_callback_h__
#define __sciter_x_host_callback_h__

#include "sciter-x.h"
#include "sciter-x-aux.h"
#include <assert.h>

#pragma warning(disable:4786) //identifier was truncated...
#pragma warning(disable:4996) //'strcpy' was declared deprecated
#pragma warning(disable:4100) //unreferenced formal parameter 

#pragma once

/**Sciter namespace.*/
namespace sciter
{

  bool load_resource_data(HINSTANCE hinst, LPCWSTR uri, LPCBYTE& pb, UINT& cb );
  bool load_html_resource(HINSTANCE hinst, UINT resId, LPCBYTE& pb, UINT& cb );

/** \struct notification_handler
 *  \brief standard implementation of SCITER_CALLBACK_NOTIFY handler.
 *  Supposed to be used as a C++ mixin, see: <a href="http://en.wikipedia.org/wiki/Curiously_Recurring_Template_Pattern">CRTP</a>
 **/

  //Base shall have two methods defined: 
  //  HWND      get_hwnd() 
  //  HINSTANCE get_resource_instance() 


  template <typename BASE>
    struct notification_handler
  {

      void setup_callback()
      {
        SciterSetCallback(static_cast< BASE* >(this)->get_hwnd(),callback, static_cast< BASE* >( this ) );
      }
      void setup_callback(HWND hwnd)
      {
        SciterSetCallback(hwnd,callback, static_cast< BASE* >( this ) );
      }

      // HTMLayout callback
      static UINT CALLBACK callback(LPSCITER_CALLBACK_NOTIFICATION pnm, LPVOID param)
      {
          assert(param);
          BASE* self = static_cast<BASE*>(param);
          return (UINT)self->handle_notification(pnm);
      }

      // notifiaction cracker
      LRESULT handle_notification(LPSCITER_CALLBACK_NOTIFICATION pnm)
      {
        // Crack and call appropriate method
    
        // here are all notifiactions
        switch(pnm->code) 
        {
          case SC_LOAD_DATA:         return on_load_data((LPSCN_LOAD_DATA) pnm);
          case SC_DATA_LOADED:       return on_data_loaded((LPSCN_DATA_LOADED)pnm);
          //case SC_DOCUMENT_COMPLETE: return on_document_complete();
          case SC_ATTACH_BEHAVIOR:   return on_attach_behavior((LPSCN_ATTACH_BEHAVIOR)pnm );
          case SC_CALLBACK_HOST:     return on_callback_host((LPSCN_CALLBACK_HOST)pnm );
        }
        return 0;
      }

      // Overridables 
      
      virtual LRESULT on_load_data(LPSCN_LOAD_DATA pnmld)
      {
        LPCBYTE pb = 0; UINT cb = 0;
        aux::wchars wu = aux::chars_of(pnmld->uri);
        if(wu.like(L"res:*"))
        {
          if(load_resource_data(static_cast< BASE* >(this)->get_resource_instance(), wu.start, pb, cb))
            ::SciterDataReady( pnmld->hwnd, pnmld->uri, pb,  cb);
        }
        return LOAD_OK;
      }

      virtual LRESULT on_data_loaded(LPSCN_DATA_LOADED pnmld)  { return 0; }
      //virtual LRESULT on_document_complete() { return 0; }

      virtual LRESULT on_callback_host(LPSCN_CALLBACK_HOST pnmld)  
      { 
        switch(pnmld->channel)  
        {
          case 0: // 0 - stdin, read from stdin requested, put string into pnmld->r 
            break;  
          case 1: // 1 - stdout, "stdout << something" requested, pnmld->p1 is 
                  //     string to output.
            break;  
          case 2: // 2 - stderr, "stderr << something" requested or error happened, 
                  //     pnmld->p1 is string to output.
            break;
          default:
                  // view.callback(channel,p1,p2) call from script
            break;  
        }
        return 0; 
      }

      virtual LRESULT on_attach_behavior( LPSCN_ATTACH_BEHAVIOR lpab )
      {
        return create_behavior(lpab);
        //return 0;
      }

      bool load_file(LPCWSTR uri)
      {
        if( wcsncmp(uri, L"res:", 4) == 0 )
        {
          LPCBYTE pb = 0; 
          UINT cb = 0;
          if(load_resource_data(static_cast< BASE* >(this)-> get_resource_instance(), uri+4, pb, cb ))
            return SciterLoadHtml(static_cast< BASE* >(this)->get_hwnd(),pb,cb, uri) != 0;
        }
        else 
          return SciterLoadFile(static_cast< BASE* >(this)->get_hwnd(), uri ) != 0;
        return false;
      }
      bool load_html(LPCBYTE pb, UINT cb, LPCWSTR uri = 0)
      {
        return SciterLoadHtml(static_cast< BASE* >(this)->get_hwnd(),pb,cb, uri) != 0;
      }

      // call scripting function defined in the global namespace
      SCITER_VALUE  call_function(LPCSTR name, UINT argc, SCITER_VALUE* argv )
      {
        HWND hwnd = static_cast< BASE* >(this)->get_hwnd();
        SCITER_VALUE rv;
        SCDOM_RESULT r = SciterCall(hwnd, name, argc, argv, &rv);
        assert(r == SCDOM_OK); r;
        return rv;
      }

      // flattened wrappers of the above. note SCITER_VALUE is a json::value
      SCITER_VALUE  call_function(LPCSTR name )
      {
        return call_function(name,0,0);
      }
      SCITER_VALUE  call_function(LPCSTR name, SCITER_VALUE arg0 )
      {
        return call_function(name,1,&arg0);
      }
      SCITER_VALUE  call_function(LPCSTR name, SCITER_VALUE arg0, SCITER_VALUE arg1 )
      {
        SCITER_VALUE argv[2]; argv[0] = arg0; argv[1] = arg1;
        return call_function(name,2,argv);
      }
      SCITER_VALUE  call_function(LPCSTR name, SCITER_VALUE arg0, SCITER_VALUE arg1, SCITER_VALUE arg2 )
      {
        SCITER_VALUE argv[3]; argv[0] = arg0; argv[1] = arg1; argv[2] = arg2;
        return call_function(name,3,argv);
      }
      SCITER_VALUE  call_function(LPCSTR name, SCITER_VALUE arg0, SCITER_VALUE arg1, SCITER_VALUE arg2, SCITER_VALUE arg3 )
      {
        SCITER_VALUE argv[4]; argv[0] = arg0; argv[1] = arg1; argv[2] = arg2; argv[3] = arg3;
        return call_function(name,4,argv);
      }

  };


  inline bool load_html_resource(HINSTANCE hinst, UINT resId, LPCBYTE& pb, UINT& cb )
  {
    HRSRC hrsrc = ::FindResource(hinst, MAKEINTRESOURCE(resId), MAKEINTRESOURCE(23));
    if (!hrsrc) return FALSE; // resource not found here - proceed with default loader
    // Load specified resource and check if ok
    HGLOBAL hgres = ::LoadResource(hinst, hrsrc);
    if (!hgres) return FALSE;
    // Retrieve resource data and check if ok
    pb = (PBYTE)::LockResource(hgres); if (!pb) return FALSE;
    cb = ::SizeofResource(hinst, hrsrc); if (!cb) return FALSE;
    return TRUE;
  }

  // loads data from resource section of hinst library.
  // accepts "name.ext" and "res:name.ext" uri's
  inline bool load_resource_data(HINSTANCE hinst,  LPCWSTR uri, LPCBYTE& pb, UINT& cb )
  {

    if (!uri || !uri[0]) 
      return false;
    // Retrieve url specification into a local storage since FindResource() expects 
    // to find its parameters on stack rather then on the heap under Win9x/Me

    if(wcsncmp(uri,L"res:",4) == 0)
      uri += 4;

    WCHAR achURL[MAX_PATH]; wcsncpy(achURL, uri, MAX_PATH);
  
    LPWSTR pszName = achURL;

    // Separate extension if any
    LPWSTR pszExt = wcsrchr(pszName, '.'); if (pszExt) *pszExt++ = '\0';

    // Find specified resource and leave if failed. Note that we use extension
    // as the custom resource type specification or assume standard HTML resource 
    // if no extension is specified

    HRSRC hrsrc = 0;
    bool  isHtml = false;
    if( pszExt == 0 || wcsicmp(pszExt,L"HTML") == 0 || wcsicmp(pszExt,L"HTM") == 0)
    {
      hrsrc = ::FindResourceW(hinst, pszName, MAKEINTRESOURCEW(23));
      isHtml = true;
    }
    else
      hrsrc = ::FindResourceW(hinst, pszName, pszExt);

    if (!hrsrc) return false; // resource not found here - proceed with default loader

    // Load specified resource and check if ok

    HGLOBAL hgres = ::LoadResource(hinst, hrsrc);
    if (!hgres) return false;

    // Retrieve resource data and check if ok

    pb = (PBYTE)::LockResource(hgres); if (!pb) return FALSE;
    cb = ::SizeofResource(hinst, hrsrc); if (!cb) return FALSE;

    // Report data ready
    
    return true;
  }


}

#endif
