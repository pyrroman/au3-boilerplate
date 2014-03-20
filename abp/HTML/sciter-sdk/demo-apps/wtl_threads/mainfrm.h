// MainFrm.h : interface of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////

#pragma once

#define CHAIN_TO_SCITER() \
    { \
        BOOL bHandled = FALSE; \
        lResult = ::SciterProcND(hWnd,uMsg, wParam, lParam, &bHandled); \
        if(bHandled) return TRUE; \
    }

extern void init_Thread_class( HVM vm );

class CMainFrame : public CFrameWindowImpl<CMainFrame>, public CUpdateUI<CMainFrame>,
		public CMessageFilter, public CIdleHandler,
    public sciter::notification_handler<CMainFrame>, // callback handler
    public sciter::event_handler // dom events handler
{
public:
	DECLARE_FRAME_WND_CLASS(NULL, IDR_MAINFRAME)

  // sciter::notification_handler traits
  HWND      get_hwnd() { return m_hWnd; }
  HINSTANCE get_resource_instance() { return _Module.GetResourceInstance(); }

	virtual BOOL PreTranslateMessage(MSG* pMsg)
	{
		return CFrameWindowImpl<CMainFrame>::PreTranslateMessage(pMsg);
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
		MESSAGE_HANDLER(WM_DESTROY, OnDestroy)
		CHAIN_MSG_MAP(CUpdateUI<CMainFrame>)
		CHAIN_MSG_MAP(CFrameWindowImpl<CMainFrame>)
	END_MSG_MAP()

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

    setup_callback(); // attach sciter::notification_handler
    sciter::attach_dom_event_handler(m_hWnd, this); //  attach this sciter::event_handler

    // add our native class to the VM:
    init_Thread_class(SciterGetVM(m_hWnd));
    
    // load initial content:
    load_file(L"res:default.htm");

		return 0;
	}

	LRESULT OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
	{
		// unregister message filtering and idle updates
		CMessageLoop* pLoop = _Module.GetMessageLoop();
		ATLASSERT(pLoop != NULL);
		pLoop->RemoveMessageFilter(this);
		pLoop->RemoveIdleHandler(this);

		bHandled = FALSE;
		return 1;
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


