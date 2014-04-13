// MainFrm.h : interface of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////


#if !defined(AFX_MAINFRM_H__A25BCD13_C8D6_4E65_9CE4_09B347A146AA__INCLUDED_)
#define AFX_MAINFRM_H__A25BCD13_C8D6_4E65_9CE4_09B347A146AA__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#include <memory>
#include "sciter-x-host-callback.h"
#include "sciter-x-script.h"
#include "sciter-x-queue.h"
#include "mm_file.h"

#define MAX_LOG_MSG_COUNT 1024

#define CHAIN_TO_SCITER() \
    { \
        BOOL bHandled = FALSE; \
        lResult = ::SciterProcND(hWnd,uMsg, wParam, lParam, &bHandled); \
        if(bHandled) return TRUE; \
    }

UINT CALLBACK SciterCallback( LPSCITER_CALLBACK_NOTIFICATION pns, LPVOID callbackParam );

struct NewSciterParams
{
  tiscript::string cmd_line;
  tiscript::pinned std_in;
  tiscript::pinned std_out;
  tiscript::pinned std_err;
  int              cmd_show;
};


HANDLE OpenNewSciter( NewSciterParams* params );

#ifdef _DEBUG
extern sciter::debug_output_console dbgcon;
#endif

class CMainFrame : 
    public CFrameWindowImpl<CMainFrame>, 
    public CUpdateUI<CMainFrame>,
    public CMessageFilter, public CIdleHandler,
    public sciter::notification_handler<CMainFrame>,
    public sciter::queue<CMainFrame>,
    public sciter::event_handler
{
public:
  DECLARE_FRAME_WND_CLASS_EX(NULL, IDR_MAINFRAME, CS_DBLCLKS, COLOR_WINDOW)

  std::auto_ptr<NewSciterParams> params;

  CMainFrame(NewSciterParams* startParams):params(startParams) {}

  static CMainFrame*   rootFrame;

  //CScideView m_view;
  virtual BOOL PreTranslateMessage(MSG* pMsg)
  {
    if(CFrameWindowImpl<CMainFrame>::PreTranslateMessage(pMsg))
      return TRUE;
    //return m_view.PreTranslateMessage(pMsg);
    return FALSE;
  }

  virtual BOOL OnIdle()
  {
    return FALSE;
  }
  BEGIN_UPDATE_UI_MAP(CMainFrame)
  END_UPDATE_UI_MAP()

  BEGIN_MSG_MAP(CMainFrame)
    CHAIN_TO_SCITER() // this must be the very first item!
    MESSAGE_HANDLER(WM_CREATE, OnCreate)
    MESSAGE_HANDLER(WM_NULL, OnNull)
    CHAIN_MSG_MAP(CUpdateUI<CMainFrame>)
    CHAIN_MSG_MAP(CFrameWindowImpl<CMainFrame>)
  END_MSG_MAP()

// Handler prototypes (uncomment arguments if needed):
//  LRESULT MessageHandler(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
//  LRESULT CommandHandler(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
//  LRESULT NotifyHandler(int /*idCtrl*/, LPNMHDR /*pnmh*/, BOOL& /*bHandled*/)

  virtual LRESULT on_load_data(LPSCN_LOAD_DATA pnmld)
  {
    aux::wchars wu = aux::chars_of(pnmld->uri);

    if(wu.like(L"res:*") || wu.like(L"data:*") || wu.like(L"http:*") || wu.like(L"https:*"))
      return notification_handler::on_load_data(pnmld);

    // we load here app://path/name.ext url that get translated into
    // [scide.exe home dir]/

    wchar_t path[MAX_PATH];
    wchar_t path2[MAX_PATH];
    wchar_t path3[MAX_PATH];

    GetModuleFileName(_Module.GetModuleInstance(), path, MAX_PATH);
    wchar_t *psl = max(wcsrchr(path,'\\'),wcsrchr(path,'/'));
    if(psl)
      *psl = 0;

    if( (wcslen(path) + wu.length) >= (MAX_PATH-10) )
      return notification_handler::on_load_data(pnmld); // we are not handling long urls
    
    wcscpy(path2, path);
    wcscpy(path3, path);
    wcscat(path,TEXT("\\scapps\\sciter.ide\\"));
    wcscat(path, wu.start + 6); // what if wu.length > MAX_PATH ????????
    wcscat(path2, wu.start + 5);    
    wcscat(path3, wu.start);
    for( wchar_t* p = path; *p; ++p )
      if( *p == '/' ) *p = '\\';

    for( wchar_t* p = path2; *p; ++p )
      if( *p == '/' ) *p = '\\';

    for( wchar_t* p = path3; *p; ++p )
      if( *p == '/' ) *p = '\\';

    aux::mm_file file;
    // first check app:// path
    bool file1_exists = GetFileAttributes(path2) != 0xFFFFFFFF;
    // then \\scapps\\sciter.ide
    bool file2_exists = GetFileAttributes(path) != 0xFFFFFFFF;
    // check path like sciter:lib/...
    bool file3_exists = GetFileAttributes(path3) != 0xFFFFFFFF;

    if(!(file1_exists && file.open(path2)) && !(file2_exists && file.open(path)) && !(file3_exists && file.open(path3)))
      return notification_handler::on_load_data(pnmld);

    ::SciterDataReady( pnmld->hwnd, pnmld->uri, (LPCBYTE)file.data(), file.size());
    return LOAD_OK;
  }

  LRESULT OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
  {
    aux::wchars filename = aux::chars_of(params->cmd_line);
    if( filename.like(L"file://*") )
      filename.prune(7);

    //m_hWndClient = m_view.Create(m_hWnd, rcDefault, NULL, WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN, WS_EX_CLIENTEDGE);

    // register object for message filtering and idle updates
    CMessageLoop* pLoop = _Module.GetMessageLoop();
    ATLASSERT(pLoop != NULL);
    pLoop->AddMessageFilter(this);
    pLoop->AddIdleHandler(this);

    TCHAR path[MAX_PATH];

    GetModuleFileName(_Module.GetModuleInstance(), path, MAX_PATH);
    TCHAR *psl = max(wcsrchr(path,'\\'),wcsrchr(path,'/'));
    if(psl)
    {
      *(psl+1) = 0;

      //wcscat(path,TEXT("scapps\\sciter.ide\\"));
      //::SciterSetHomeURL(m_hWnd,t2w(path));
      ::SciterSetHomeURL(m_hWnd,L"\\");
    }

    setup_callback();
    sciter::attach_dom_event_handler(m_hWnd, this); //  attach this sciter::event_handler

    if(!rootFrame) 
    {
      rootFrame = this;
      // this is primary IDE window
      if(!load_file(L"app:///facade.htm"))
        load_file(L"res:default.html");
    }
    else
    {
      DWORD attributes = GetFileAttributesW(filename.start);
      if(  (attributes & FILE_ATTRIBUTE_DIRECTORY) || (attributes == 0xFFFFFFFF) )
      {
        aux::wostream s;
        s << L"File " << filename.start << L" not found! Consider creating index.htm for the current project.";
        ::MessageBox(0, s.data(), L"Scide error!", MB_OK | MB_ICONERROR | MB_APPLMODAL);
        load_file(L"res:default.html");
        return 0;
      }

      // this is an "alien" Window/VM started from the IDE, 
      HVM this_vm = SciterGetVM(m_hWnd);
      // redirect its std streams 
      tiscript::set_remote_std_streams(this_vm,params->std_in,params->std_out,params->std_err);
      if(params->cmd_line.length())
        load_file(params->cmd_line.c_str());
      else
        load_file(L"res:default.htm");
    }
    params.reset(); //don't need them anymore

    // SciterGetMinWidth does not work for cases with flex units
    sciter::dom::element root = sciter::dom::element::root_element(m_hWnd);
    sciter::dom::element body = root.find_first("body");
    RECT r = body.get_location(SELF_RELATIVE | MARGIN_BOX);
    int width = r.right - r.left + GetSystemMetrics(SM_CXFRAME) * 2;
    int height = r.bottom - r.top + GetSystemMetrics(SM_CYFRAME) * 2 + GetSystemMetrics(SM_CYCAPTION);
    if( width && height && width < GetSystemMetrics(SM_CXSCREEN) && height < GetSystemMetrics(SM_CYSCREEN))
    {
      int top = (GetSystemMetrics(SM_CYSCREEN) - height) / 2;
      int left = (GetSystemMetrics(SM_CXSCREEN) - width) / 2;
      MoveWindow(left, top, width, height);
    }


    return 0;
  }

  HWND      get_hwnd() { return m_hWnd; }
  HINSTANCE get_resource_instance() { return _Module.GetResourceInstance(); }

  LRESULT OnFileNewWindow(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
  {
    ::PostThreadMessage(_Module.m_dwMainThreadID, WM_USER, 0, 0L);
    return 0;
  }
  LRESULT OnNull(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
  {
    bHandled = FALSE;
    sciter::queue<CMainFrame>::execute(); 
    return 0;
  }

  LRESULT OnAppAbout(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
  {
    CAboutDlg dlg;
    dlg.DoModal();
    return 0;
  }

  /*UINT OnLoadData(LPSCN_LOAD_DATA pns)
  {
    if( wcsncmp(pns->uri, L"app:", 6) == 0) // we are using app:name.ext schema to refer to resources contained in this exe.
      return GetResource( pns->uri + 6, pns->outData, pns->outDataSize );
    return LOAD_OK; // proceed with the default loader.
  }*/

  // handler of custom global functions for CSSS! engine
  virtual bool on_script_call(HELEMENT he, LPCSTR name, UINT argc, json::value* argv, json::value& retval) 
  { 
    if( aux::streq(name, "debug") )
    {
      sciter::debug_output_console dc;
      for(int n = 0; n < int(argc); ++n) 
        dc.printf("%S ", argv[n].to_string().c_str() );
      dc.printf("\n");
      return TRUE;
    }
    if( aux::streq(name, "shell-exec") && argc >= 1)
    {
      ShellExecuteW(0, L"open", argv[0].to_string().c_str(), NULL, NULL, SW_SHOWNORMAL);
      return TRUE;
    }
    return FALSE; 
  }      

  HVM VM() { return SciterGetVM(m_hWnd); }

  bool handle_scripting_call(HELEMENT he, TISCRIPT_METHOD_PARAMS& params )
  {
    #define METHOD(NAME) if( params.tag == tiscript::v_symbol(#NAME) )

    METHOD(getMasterCSS) // view.getMasterCSS() - returns master css as string
    {
      HMODULE dll = LoadLibrary(L"sciter-x.dll");
      if( dll )
      {
        HRSRC h = FindResource(dll, L"MASTER-CSS", RT_HTML);
        if( h )
        {
          HGLOBAL hg = LoadResource(dll, h);
          LPVOID res = LockResource(hg);
          aux::utf2w ws((char*)res,SizeofResource(dll, h)); // HTML resoucres are stored in utf-8 encoding in PE files.
          params.result = tiscript::v_string(params.vm,ws,ws.length()); 
        }
        FreeLibrary(dll);
      }
      return true;
    }
    // initializerMethod here is a method that will be called on this VM to introduce alien VM to it
    METHOD(open) // view.open("url",[initializerMethod]) - opens new window in the new thread
    {
      tiscript::args args(params.vm);
      
      std::auto_ptr<NewSciterParams> ns_params(new NewSciterParams);
      ns_params->cmd_show = SW_SHOW;

      args >> tiscript::args::skip
           >> tiscript::args::skip
           >> ns_params->cmd_line
           >> tiscript::args::optional >> ns_params->std_in
           >> tiscript::args::optional >> ns_params->std_out
           >> tiscript::args::optional >> ns_params->std_err;

        params.result = tiscript::v_bool(OpenNewSciter( ns_params.release() ) != 0);
        return true;    
    }
    #undef METHOD
     return false;    
  }

  /*struct log_update: public sciter::gui_task<CMainFrame>
  {
     std::wstring msg;
     bool         err;
     log_update(const wchar_t* message, bool is_error): msg(message),err(is_error) {}
     virtual void exec(CMainFrame* pf)
     {
       sciter::dom::element log = pf->log_el();
       sciter::dom::element el;
       if(log.children_count() > MAX_LOG_MSG_COUNT)
       {
         el = log.child(0);
         el.set_attribute("class",err? L"error": L"message");
         el.set_text(msg.c_str());
         log.append(el);
       } else
       {
         el = sciter::dom::element::create("text",msg.c_str());
         el.set_attribute("class",err? L"error": L"message");
         log.append(el);
       }
       if(!next) // this the last log record i the queue, scroll on it
         el.scroll_to_view();
     }
  };


  virtual LRESULT on_callback_host(LPSCN_CALLBACK_HOST pnmld)  
  { 
    if(!rootFrame)
      return FALSE;
    if(pnmld->channel == 1 || pnmld->channel == 2)
    {
      //stdout, stderr
      rootFrame->push(new log_update(pnmld->p1.to_string().c_str(), pnmld->channel == 2));
#ifdef _DEBUG
      dbgcon.printf("%S",pnmld->p1.to_string().c_str());
#endif
      return TRUE;
    }
    return FALSE;
  }*/

  virtual LRESULT on_callback_host(LPSCN_CALLBACK_HOST pns) 
  { 
    static sciter::debug_output_console dbgcon;
    switch(pns->channel)  
    {
      case 0: // 0 - stdin, read from stdin requested, put string into pnmld->r 
        break;  
      case 1: // 1 - stdout, "stdout << something" requested, pnmld->p1 is 
              //     string to output.
        dbgcon.printf("stdout:%S", pns->p1.to_string().c_str() );
        break;  
      case 2: // 2 - stderr, "stderr << something" requested or error happened, 
              //     pnmld->p1 is string to output.
        dbgcon.printf("stderr:%S", pns->p1.to_string().c_str() );
        break;
      default:
        // view.callback(channel,p1,p2) call from script

        dbgcon.printf("callback on channel %d, values: %S,%S\n", pns->channel, pns->p1.to_string(CVT_JSON_LITERAL).c_str(), pns->p2.to_string(CVT_JSON_LITERAL).c_str() );
        // implement this if needed
        break;  
    }
    return 0; 
  }

};



/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MAINFRM_H__A25BCD13_C8D6_4E65_9CE4_09B347A146AA__INCLUDED_)
