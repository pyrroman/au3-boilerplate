// wtlView.h : interface of the CSciterView class
//
/////////////////////////////////////////////////////////////////////////////

#include "sciter-x.h"
#include "sciter-x-behavior.h"
#include "sciter-x-host-callback.h"

#if !defined(AFX_WTLVIEW_H__948B67ED_5801_4139_8684_34FE7004E8F7__INCLUDED_)
#define AFX_WTLVIEW_H__948B67ED_5801_4139_8684_34FE7004E8F7__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#define CHAIN_TO_SCITER() \
    { \
        BOOL bHandled = FALSE; \
        lResult = ::SciterProcND(hWnd,uMsg, wParam, lParam, &bHandled); \
        if(bHandled) return TRUE; \
    }



class CSciterView : 
  public CWindowImpl<CSciterView>,
  public sciter::event_handler,
  public sciter::notification_handler<CSciterView>
{
public:
  DECLARE_WND_CLASS(NULL)

  BOOL PreTranslateMessage(MSG* pMsg);

  HINSTANCE get_resource_instance() const { return _Module.GetResourceInstance(); }
  HWND      get_hwnd() const { return m_hWnd; }

  BEGIN_MSG_MAP(CSciterView)
    CHAIN_TO_SCITER() // this must be the very first item!
    MESSAGE_HANDLER(WM_CREATE, OnCreate)
  END_MSG_MAP()

// Handler prototypes (uncomment arguments if needed):
//  LRESULT MessageHandler(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
//  LRESULT CommandHandler(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
//  LRESULT NotifyHandler(int /*idCtrl*/, LPNMHDR /*pnmh*/, BOOL& /*bHandled*/)

  LRESULT OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/);


  virtual LRESULT on_load_data(LPSCN_LOAD_DATA pns)
  {
    if( wcsncmp(pns->uri, L"app:", 6) == 0) // we are using app:name.ext schema to refer to resources contained in this exe.
      return GetResource( pns->uri + 6, pns->outData, pns->outDataSize );
    return LOAD_OK; // proceed with the default loader.
  }
  virtual LRESULT on_callback_host(LPSCN_CALLBACK_HOST pns);

  virtual UINT GetResource(LPCWSTR uri, /*out*/LPCBYTE& pb, /*out*/UINT& cb);

  BOOL LoadFile(LPCWSTR url)
  {
    return SciterLoadFile(m_hWnd, url);
  }

  BOOL Call(LPCSTR functionName, UINT argc, const SCITER_VALUE* argv, SCITER_VALUE& retval)
  {
    return SciterCall(m_hWnd, functionName, argc, argv, &retval);
  }
  BOOL Eval(LPCWSTR script, UINT scriptLength, SCITER_VALUE& retval)
  {
    return SciterEval(m_hWnd, script, scriptLength, &retval);
  }

  // sciter::event_handler stuff, start,
  // override what is needed.
  virtual bool handle_mouse  (HELEMENT he, MOUSE_PARAMS& params )         { return false; }
  virtual bool handle_key    (HELEMENT he, KEY_PARAMS& params )           { return false; } 
  virtual bool handle_focus  (HELEMENT he, FOCUS_PARAMS& params )         { return false; }
  virtual bool handle_timer  (HELEMENT he )                               { return false; }
  virtual void handle_size   (HELEMENT he )                               { }
  virtual bool handle_draw   (HELEMENT he, DRAW_PARAMS& params )          { return false; }
  virtual bool handle_method_call (HELEMENT he, METHOD_PARAMS& params )   { return false; }
  virtual bool handle_event (HELEMENT he, BEHAVIOR_EVENT_PARAMS& params ) { return false; }
  virtual bool handle_data_arrived (HELEMENT he, DATA_ARRIVED_PARAMS& params ) { return false; }
  
  virtual bool handle_scripting_call(HELEMENT he, SCRIPTING_METHOD_PARAMS& params );

  // sciter::event_handler stuff, end

};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_WTLVIEW_H__948B67ED_5801_4139_8684_34FE7004E8F7__INCLUDED_)
