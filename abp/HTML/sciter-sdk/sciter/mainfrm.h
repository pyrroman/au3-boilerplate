// MainFrm.h : interface of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////

#include <atlframe.h>
#include <atlctrls.h>
#include <atldlgs.h>
#include "resource.h"
#include "aboutdlg.h"
#include "../scide/mm_file.h"

#include "sciter-x-host-callback.h"
#include "sciter-x-script.h"
#include "sciter-x-graphin.h"

#if !defined(AFX_MAINFRM_H__4F8E8A0E_0D97_486B_8742_F12CCAE5C4F1__INCLUDED_)
#define AFX_MAINFRM_H__4F8E8A0E_0D97_486B_8742_F12CCAE5C4F1__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#define CHAIN_TO_SCITER() \
    { \
        BOOL bHandled = FALSE; \
        lResult = ::SciterProcND(hWnd,uMsg, wParam, lParam, &bHandled); \
        if(bHandled) return TRUE; \
    }

class CMainFrame : 
    public CFrameWindowImpl<CMainFrame>, 
		public CMessageFilter, 
    public CIdleHandler,
    public sciter::notification_handler<CMainFrame>, // callback handler
    public sciter::event_handler // dom events handler

{
public:
  json::string   fileToLoad;
  json::value    paramToPass;
  sciter::image* pimg;
  typedef sciter::notification_handler<CMainFrame> super_handler;

  DECLARE_FRAME_WND_CLASS_EX(TEXT("Sciter.Frame"), IDR_MAINFRAME, CS_DBLCLKS, (HBRUSH)(COLOR_3DFACE + 1) )

  // sciter::notification_handler traits
  HWND      get_hwnd() { return m_hWnd; }
  HINSTANCE get_resource_instance() { return _Module.GetResourceInstance(); }

  // sciter::event_handler stuff
  virtual bool handle_scripting_call(HELEMENT he, SCRIPTING_METHOD_PARAMS& params ); 

  HVM VM() { return SciterGetVM(m_hWnd); }

  virtual LRESULT on_load_data(LPSCN_LOAD_DATA pnmld)
  {
    aux::wchars wu = aux::chars_of(pnmld->uri);

    
    if(wu.like(L"res:*"))
      return notification_handler::on_load_data(pnmld);

    if(!wu.like(L"file:*"))
      return LOAD_OK; // delegate it to default loader

    // we load here app://path/name.ext url that get translated into
    // [scide.exe home dir]/

    wchar_t path[MAX_PATH];
    wchar_t path2[MAX_PATH];
    wchar_t path3[MAX_PATH];

    GetModuleFileName(_Module.GetModuleInstance(), path, MAX_PATH);
    wchar_t *psl = max(wcsrchr(path,'\\'),wcsrchr(path,'/'));
    if(psl)
      *psl = 0;
    
    wcscpy(path2, path);
    wcscpy(path3, path);
    wcscat(path2, wu.start + 5);    
    wcscat(path3, wu.start);

    for( wchar_t* p = path2; *p; ++p )
      if( *p == '/' ) *p = '\\';

    for( wchar_t* p = path3; *p; ++p )
      if( *p == '/' ) *p = '\\';

    aux::mm_file file;
    // first check app:// path
    bool file1_exists = GetFileAttributes(path2) != 0xFFFFFFFF;
    // check path like sciter:lib/...
    bool file3_exists = GetFileAttributes(path3) != 0xFFFFFFFF;

    if(!(file1_exists && file.open(path2)) && !(file3_exists && file.open(path3)))
      return notification_handler::on_load_data(pnmld);

    ::SciterDataReady( pnmld->hwnd, pnmld->uri, (LPCBYTE)file.data(), DWORD(file.size()));
    return LOAD_OK;
  }

  virtual LRESULT on_data_loaded(LPSCN_DATA_LOADED pnmld)  
  { 
    return 0; 
  }

	virtual BOOL PreTranslateMessage(MSG* pMsg)
	{
		return CFrameWindowImpl<CMainFrame>::PreTranslateMessage(pMsg);
	}

	virtual BOOL OnIdle()
	{
		return FALSE;
	}

	BEGIN_MSG_MAP(CMainFrame)
    CHAIN_TO_SCITER() // this must be the very first item!
		MESSAGE_HANDLER(WM_CREATE, OnCreate)
    MESSAGE_HANDLER(WM_SYSCOMMAND, OnSysCommand)
		COMMAND_ID_HANDLER(ID_APP_EXIT, OnFileExit)
		COMMAND_ID_HANDLER(ID_FILE_NEW, OnFileNew)
		COMMAND_ID_HANDLER(ID_APP_ABOUT, OnAppAbout)
		CHAIN_MSG_MAP(CFrameWindowImpl<CMainFrame>)
	END_MSG_MAP()

  // functions accessible through view.funcname() from script:
  BEGIN_FUNCTION_MAP
    FUNCTION_V("debug", method_debug)
    FUNCTION_1("shellExec", method_shellExec)
  END_FUNCTION_MAP

  json::value method_debug(int argc, const json::value* argv)
  {
    sciter::debug_output_console dc;
    for(int n = 0; n < argc; ++n) 
      dc.printf("%S ", argv[n].to_string().c_str() );
    dc.printf("\n");
    return json::value(); // undefined, a.k.a. void value
  }

  json::value method_shellExec(const json::value& cmd)
  {
    ShellExecuteW(0, L"open", cmd.to_string().c_str(), NULL, NULL, SW_SHOWNORMAL);
    return json::value(); // undefined, a.k.a. void value
  }

// Handler prototypes (uncomment arguments if needed):
//	LRESULT MessageHandler(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
//	LRESULT CommandHandler(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
//	LRESULT NotifyHandler(int /*idCtrl*/, LPNMHDR /*pnmh*/, BOOL& /*bHandled*/)

	LRESULT OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{

		// register object for message filtering and idle updates
		CMessageLoop* pLoop = _Module.GetMessageLoop();
		ATLASSERT(pLoop != NULL);
		pLoop->AddMessageFilter(this);
		pLoop->AddIdleHandler(this);

    CMenu sm = GetSystemMenu(FALSE);
    CMenu wm = GetMenu();
          wm = wm.GetSubMenu(0);
    MergeMenu(sm,wm);
    SetMenu(NULL);

    setup_callback();
    sciter::attach_dom_event_handler(m_hWnd, this); //  attach this sciter::event_handler
    
    if(fileToLoad.length())
      load_file(fileToLoad);
    else
      load_file(L"res:default.htm");
    //else load_file(L"file://c:/sciter.trunk/sdk/samples/tests/basics/test-load-zip.zip");
    /*SetTitle();*/

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

    //pimg = sciter::image::create(100,100);
    //sciter::graphics gfx(pimg);
    //gfx.move_to(0,0,false);

		return 0;
	}

  void SetTitle()
  {
    sciter::dom::element root = sciter::dom::element::root_element(m_hWnd);
    sciter::dom::element title = root.find_first("title");
    if(title.is_valid())
    {
      json::string t = title.text();
      SetWindowText(t);
    }
  }

  // invokes view.something(...) method if that view.something is defined.
  // used for view events generation.
  json::value InvokeViewMethod(LPCWSTR name, unsigned argc = 0, json::value* argv = 0 )
  {
     WCHAR fullname[128];
     unsigned fullname_length = swprintf(fullname,L"view.%s",name);
     json::value m;
     SciterEval(m_hWnd,fullname,fullname_length,&m);
     if( m.is_object_function() )
     {
        return m.call(argc,argv);
     }
     return json::value();
  }


	LRESULT OnFileExit(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	{
		PostMessage(WM_CLOSE);
		return 0;
	}

	LRESULT OnFileNew(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	{
		// TODO: add code to initialize document

		return 0;
	}
	LRESULT OnFileOpen(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	{
	  CFileDialog dlg(TRUE, L"htm", NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, 
    L"HTML Files (*.htm,*.html)\0*.HTM;*.HTML\0"
    L"All Files (*.*)\0*.*\0", m_hWnd);
    if(dlg.DoModal() == IDOK)
    {
      USES_CONVERSION;
      load_file(dlg.m_szFileName);
      SetTitle();
    }
		return 0;
	}

	LRESULT OnAppAbout(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	{
		CAboutDlg dlg;
		dlg.DoModal();
		return 0;
	}

  LRESULT OnSysCommand(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
  {
    switch(wParam)
    {
      case ID_FILE_HOME:  load_file(L"res:default.htm"); return 0;
      case ID_FILE_OPEN:  return OnFileOpen(0, 0, NULL, bHandled);
      case ID_APP_EXIT:   return OnFileExit(0, 0, NULL, bHandled); 
      case ID_FILE_PRINT_SETUP:
      case ID_FILE_PRINT:    
      case ID_FILE_PRINT_PREVIEW:
        return 0;
    }
    bHandled = FALSE;
    return 0;
  }


  bool MergeMenu(CMenu& dst, CMenu& src, bool bTopLevel = false )
  {
      // Abstract:
      //      Merges two menus.
      //
      // Parameters:
      //      dst        - [in, retval] destination menu handle
      //      src        - [in] menu to merge
      //      bTopLevel  - [in] indicator for special top level behavior
      //
      // Return value:
      //      <false> in case of error.
      //
      // Comments:
      //      This function calles itself recursivley. If bTopLevel is set to true,
      //      we append popups at top level or we insert before <Window> or <Help>.

      // get the number menu items in the menus
      int iMenuAddItemCount = src.GetMenuItemCount();
      int iMenuDestItemCount = dst.GetMenuItemCount();
    
      // if there are no items return
      if( iMenuAddItemCount == 0 )
          return true;
    
      // if we are not at top level and the destination menu is not empty
      // -> we append a seperator
      if( !bTopLevel && iMenuDestItemCount > 0 )
          dst.AppendMenu(MF_SEPARATOR);
    
      // iterate through the top level of <PMENUADD>
      for( int iLoop = 0; iLoop < iMenuAddItemCount; iLoop++ )
      {
          // get the menu string from the add menu
          TCHAR sMenuAddString[64];
          src.GetMenuString( iLoop, sMenuAddString, 63, MF_BYPOSITION );
        
          // try to get the submenu of the current menu item
          CMenu subMenu = src.GetSubMenu(iLoop);
        
          // check if we have a sub menu
          if (!subMenu)
          {
              // normal menu item
              // read the source and append at the destination
              UINT nState = src.GetMenuState( iLoop, MF_BYPOSITION );
              UINT nItemID = src.GetMenuItemID( iLoop );
            
              if( dst.AppendMenu( nState, nItemID, sMenuAddString ))
              {
                  // menu item added, don't forget to correct the item count
                  iMenuDestItemCount++;
              }
              else
              {
                  //TRACE( "MergeMenu: AppendMenu failed!\n" );
                  return false;
              }
          }
          else
          {
              // create or insert a new popup menu item
            
              // default insert pos is like ap
              int iInsertPosDefault = -1;
            

              // if the top level search did not find a position append the menu
              if( iInsertPosDefault == -1 )
                  iInsertPosDefault = dst.GetMenuItemCount();
            
              // create a new popup and insert before <Window> or <Help>
              CMenu NewPopupMenu;
              if( !NewPopupMenu.CreatePopupMenu() )
              {
                  //TRACE( "MergeMenu: CreatePopupMenu failed!\n" );
                  return false;
              }
            
              // merge the new popup recursivly
              if( !MergeMenu( NewPopupMenu, subMenu ))
                  return false;
            
              // insert the new popup menu into the destination menu
              HMENU hNewMenu = NewPopupMenu;

              if( dst.InsertMenu( iInsertPosDefault,
                  MF_BYPOSITION | MF_POPUP | MF_ENABLED, 
                  (UINT)hNewMenu, sMenuAddString ))
              {
                  // don't forget to correct the item count
                  iMenuDestItemCount++;
              }
              else
              {
                  //ATL_TRACE( "MergeMenu: InsertMenu failed!\n" );
                  return false;
              }

              // don't destroy the new menu       
              NewPopupMenu.Detach();
          } 
      } 
      return true;
  }

  virtual LRESULT on_callback_host(LPSCN_CALLBACK_HOST pns) 
  { 
    static sciter::debug_output_console dbgcon;
    switch(pns->channel)  
    {
      case 0: // 0 - stdin, read from stdin requested, put string into pnmld->r 
        break;  
      case 1: // 1 - stdout, "stdout << something" requested, pnmld->p1 is 
              //     string to output.
        //dbgcon.printf("stdout:%S", pns->p1.to_string().c_str() );
        dbgcon.print("stdout:");
        dbgcon.print(pns->p1.to_string().c_str());
        break;  
      case 2: // 2 - stderr, "stderr << something" requested or error happened, 
              //     pnmld->p1 is string to output.
        //dbgcon.printf("stderr:%S", pns->p1.to_string().c_str() );
        dbgcon.print("stderr:");
        dbgcon.print(pns->p1.to_string().c_str());
        break;
      default:
        // view.callback(channel,p1,p2) call from script

        dbgcon.printf("callback on channel %d, values: %S,%S\n", pns->channel, pns->p1.to_string(CVT_JSON_LITERAL).c_str(), pns->p2.to_string(CVT_JSON_LITERAL).c_str() );
        // implement this if needed
        break;  
    }
    return 0; 
  }
  
  /* test of calling function on DOCUMENT_COMPLETE for the root document.
  virtual bool on_event (HELEMENT he, HELEMENT target, BEHAVIOR_EVENTS type, UINT_PTR reason ) 
  { 
    if( type == DOCUMENT_COMPLETE )
    {
      sciter::dom::element root = sciter::dom::element::root_element(m_hWnd);
      if( target == root )
      {
        tiscript::value v = tiscript::call(VM(), root.get_namespace(), "fn");
      }
    }
    return FALSE; 
  }*/



};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MAINFRM_H__4F8E8A0E_0D97_486B_8742_F12CCAE5C4F1__INCLUDED_)
