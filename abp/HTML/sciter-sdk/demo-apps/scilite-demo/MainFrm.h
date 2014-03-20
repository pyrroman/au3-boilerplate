// MainFrm.h : interface of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////

//#include "dibdc.h"
#include "sciter-x-lite.h"
#include "sciter-x-host-callback.h" // for get_html_resource()
#include "sciter-x-behavior.h"

#pragma once

inline int  width(RECT r) { return r.right - r.left; }
inline int  height(RECT r) { return r.bottom - r.top; }

class CMainFrame : public CFrameWindowImpl<CMainFrame>, 
                   public CUpdateUI<CMainFrame>,
		               public CMessageFilter, 
                   public CIdleHandler,
                   public Scilite // it wraps windowless SciLite
{
  //dib_dc ddc;
  CRect     invalid;
  CSize     size;
  HBITMAP   bitmap;
  HCURSOR   hcursor;
public:
	DECLARE_FRAME_WND_CLASS(NULL, IDR_MAINFRAME)

  CMainFrame(): Scilite("screen,windowless")
  {
    bitmap  = 0;
    hcursor = 0;
  }

  HWND CreateIt()
  {
    CRect r(10, 10, 300, 300);
    return CreateEx(0,r,WS_OVERLAPPED,WS_EX_LAYERED);
  }

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
		MESSAGE_HANDLER(WM_CREATE,  OnCreate)
    MESSAGE_HANDLER(WM_PAINT,   OnPaint)
		MESSAGE_HANDLER(WM_DESTROY, OnDestroy)
    MESSAGE_HANDLER(WM_SIZE,    OnSize)
    MESSAGE_HANDLER(WM_TIMER,   OnTimer)
    MESSAGE_HANDLER(WM_NCHITTEST, OnHitTest)
    MESSAGE_HANDLER(WM_ERASEBKGND, OnErase) 
    MESSAGE_HANDLER(WM_MOUSEMOVE,  OnMouseMove)
    MESSAGE_HANDLER(WM_LBUTTONDOWN, OnMouse)
    MESSAGE_HANDLER(WM_LBUTTONUP, OnMouse)
    MESSAGE_HANDLER(WM_RBUTTONDOWN, OnMouse)
    MESSAGE_HANDLER(WM_RBUTTONUP, OnMouse)
    MESSAGE_HANDLER(WM_SETCURSOR, OnSetCursor)

    MESSAGE_HANDLER(WM_KEYDOWN, OnKey)
    MESSAGE_HANDLER(WM_CHAR, OnKey)
    MESSAGE_HANDLER(WM_KEYUP, OnKey)

    MESSAGE_HANDLER(WM_NCCALCSIZE, OnCalcSize)
		COMMAND_ID_HANDLER(ID_APP_EXIT, OnFileExit)
		COMMAND_ID_HANDLER(ID_FILE_OPEN, OnFileOpen)
		COMMAND_ID_HANDLER(ID_APP_ABOUT, OnAppAbout)
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

    LPCBYTE bytes;
    UINT    bytes_length;
    sciter::load_html_resource(_Module.get_m_hInst(),IDR_MAINFRAME, bytes, bytes_length);
    //const char* empty = "<html style='background-color:transparent'><body style='background:red'>hi!</body></html>";
    //Scilite::load((LPCBYTES)empty, strlen(empty));
    Scilite::load(bytes,bytes_length);
    Update();
		return 0;
	}


	LRESULT OnDestroy(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
	{
    Scilite::destroy();
		// unregister message filtering and idle updates
		CMessageLoop* pLoop = _Module.GetMessageLoop();
		ATLASSERT(pLoop != NULL);
		pLoop->RemoveMessageFilter(this);
		pLoop->RemoveIdleHandler(this);

		bHandled = FALSE;
		return 1;
	}

  void SetupBitmap()
  {
    CRect rc; 
    GetWindowRect(&rc);
    if(!bitmap || size.cx != rc.Width() || size.cy != rc.Height())
    {
      if(bitmap)
        DeleteObject(bitmap);

      size.cx = rc.Width();
      size.cy = rc.Height();
      // Create a Memory DC
      BITMAPINFO info = {0};
      info.bmiHeader.biSize   = sizeof(BITMAPINFOHEADER);
      info.bmiHeader.biWidth  = size.cx;
      info.bmiHeader.biHeight = size.cy;
      info.bmiHeader.biPlanes = 1;
      info.bmiHeader.biBitCount = 32;
      info.bmiHeader.biCompression = 0;
      info.bmiHeader.biSizeImage = 0;
      info.bmiHeader.biXPelsPerMeter = 0;
      info.bmiHeader.biYPelsPerMeter = 0;
      info.bmiHeader.biClrUsed = 0;
      info.bmiHeader.biClrImportant = 0;
      
      void*   ptr  = 0;
      HDC hdc = GetDC();
      bitmap = ::CreateDIBSection(hdc, &info, DIB_RGB_COLORS, &ptr, NULL, 0);
      ReleaseDC(hdc);
      COLORREF *pc = (COLORREF *)ptr;
      COLORREF *pce = pc + size.cx * size.cy;
      while(pc < pce)
        *pc++ = 0xff000000;
    }
  }
	LRESULT OnSize(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
	{
    SetupBitmap();
    CRect rc; 
    GetClientRect(&rc);
    if( rc.IsRectEmpty() )
      return 0;
    Scilite::replace(m_hWnd,0, 0, rc.Width(), rc.Height());
    invalid = rc;
    Update();
		return 0;
	}


	LRESULT OnPaint(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
    PAINTSTRUCT ps;
    HDC hdc = BeginPaint(&ps);
    EndPaint(&ps);
    Update();
		return 0;
	}
  
	LRESULT OnErase(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
	{
		return 1;
	}

  UINT GetButtons(WPARAM wp) 
  {
    int btns = 0;
    if(wp & MK_LBUTTON)
      btns |= MAIN_MOUSE_BUTTON;
    if(wp & MK_RBUTTON)
      btns |= PROP_MOUSE_BUTTON;
    return btns;
  }
  UINT GetKeys() {
    int alts = 0;
    if (GetAsyncKeyState(VK_SHIFT) < 0) alts |= SHIFT_KEY_PRESSED;
    if (GetAsyncKeyState(VK_CONTROL) < 0) alts |= CONTROL_KEY_PRESSED;
    if (GetAsyncKeyState(VK_MENU) < 0) alts |= ALT_KEY_PRESSED;
    return alts;
  }

  LRESULT OnKey(UINT uMsg, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
  {
    UINT keyCmd = 0;
    switch(uMsg)
    {
      case WM_KEYDOWN:  keyCmd = KEY_DOWN; break;
      case WM_KEYUP:    keyCmd = KEY_UP; break;
      case WM_CHAR:     keyCmd = KEY_CHAR; break;
    }
    if(traverseKeyboardEvent( keyCmd, wParam, GetKeys()))
    {
      Update();
      return 0;
    }
    bHandled = FALSE;
    return 0;
  }
  
  LRESULT OnHitTest(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
  {
    CPoint pt(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
    CString id;
    ::MapWindowPoints(HWND_DESKTOP,m_hWnd,&pt,1);
    sciter::dom::element elem = Scilite::find(pt);
    if( !elem.is_valid() )
      goto NOWHERE;
      //return HTNOWHERE;
    elem = elem.find_nearest_parent("body > .window-part");
    if( !elem.is_valid() )
      //return HTNOWHERE;
      goto NOWHERE;
    id = elem.get_attribute("id", L"");
    if( id == L"window-body" )
    {
      CRect rc = elem.get_location(VIEW_RELATIVE | CONTENT_BOX);
      if( rc.PtInRect(pt))
        return HTCLIENT;
      //CRect rcout = elem.get_location(VIEW_RELATIVE | BORDER_BOX);
      if(pt.y >= rc.bottom && pt.x >= rc.right)
        return HTBOTTOMRIGHT;
      if(pt.y >= rc.bottom && pt.x < rc.left)
        return HTBOTTOMLEFT;
      if(pt.y >= rc.bottom)
        return HTBOTTOM;
      if(pt.x >= rc.right)
        return HTRIGHT;
      if(pt.x < rc.left)
        return HTLEFT;
      return HTNOWHERE;
    }
    if( id == L"window-caption" )
      return HTCAPTION;
    if( id == L"window-collapse" )
      return HTMINBUTTON;
    if( id == L"window-close" )
      return HTCLOSE;
NOWHERE:
    if(traverseMouseEvent( MOUSE_MOVE, pt, GetButtons(wParam), GetKeys() )) 
      Update();
    return HTNOWHERE;
  }

  LRESULT OnCalcSize(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
  {
    return 0;
  }

  LRESULT OnMouseMove(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
  {
    CPoint pt(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
    if(traverseMouseEvent( MOUSE_MOVE, pt, GetButtons(wParam), GetKeys() )) 
    {
      Update();
      return 0;
    }
    bHandled = FALSE;
    return 0;
  }

  LRESULT OnMouse(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
  {
    CPoint pt(GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam));
    UINT cmd = 0;
    UINT button = 0;
    switch( uMsg )
    {
      case WM_LBUTTONDOWN: cmd = MOUSE_DOWN; button = MAIN_MOUSE_BUTTON; break;
      case WM_LBUTTONUP:   cmd = MOUSE_UP; button = MAIN_MOUSE_BUTTON; break;
      case WM_RBUTTONDOWN: cmd = MOUSE_DOWN; button = PROP_MOUSE_BUTTON; break;
      case WM_RBUTTONUP:   cmd = MOUSE_UP; button = PROP_MOUSE_BUTTON; break;
    }
    if(traverseMouseEvent( cmd, pt, button, GetKeys() )) 
    {
      Update();
      return 0;
    }
    bHandled = FALSE;
    return 0;
  }

  
	LRESULT OnFileExit(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	{
		PostMessage(WM_CLOSE);
		return 0;
	}

	LRESULT OnFileOpen(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	{
	  CFileDialog dlg(TRUE, L"htm", NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, 
    L"HTML Files (*.htm,*.html)\0*.HTM;*.HTML\0"
    L"All Files (*.*)\0*.*\0", m_hWnd);
    if(dlg.DoModal() == IDOK)
    {
      Scilite::load(dlg.m_szFileName);
      //SetTitle();
    }
		return 0;
	}

	LRESULT OnAppAbout(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
	{
		CAboutDlg dlg;
		dlg.DoModal();
		return 0;
	}
  

  LRESULT OnTimer(UINT /*uMsg*/, WPARAM wParam, LPARAM /*lParam*/, BOOL& bHandled)
  {
    BOOL cont = Scilite::traverseTimerEvent(wParam);
    if (!cont) 
      KillTimer(wParam);
    Update();
    return 0;
  }

  LRESULT OnSetCursor(UINT /*uMsg*/, WPARAM wParam, LPARAM lParam , BOOL& bHandled)
  {
    if((LOWORD(lParam) == HTCLIENT) && hcursor)
    {
      SetCursor(hcursor);
      return TRUE;
    }
    bHandled = FALSE;
    return FALSE;
  }

  // Scilite overridables

  virtual void handleRefreshArea( LPSCN_REFRESH_AREA pn )
  {
    ::UnionRect(&invalid,&invalid,&pn->area);
  }
  virtual void handleSetTimer( LPSCN_SET_TIMER pn )
  {
    if( pn->elapseTime )
      ::SetTimer(m_hWnd,pn->timerId,pn->elapseTime,0);
    else
      ::KillTimer(m_hWnd,pn->timerId);
  }

  virtual void handleSetCursor( LPSCN_SET_CURSOR pn )
  {
    static DWORD cursor_ids[] = 
    {
        (DWORD) IDC_ARROW,
        (DWORD) IDC_IBEAM,
        (DWORD) IDC_WAIT,
        (DWORD) IDC_CROSS,
        (DWORD) IDC_UPARROW,
        (DWORD) IDC_SIZENWSE,
        (DWORD) IDC_SIZENESW,
        (DWORD) IDC_SIZEWE,
        (DWORD) IDC_SIZENS,
        (DWORD) IDC_SIZEALL,
        (DWORD) IDC_NO,
        (DWORD) IDC_APPSTARTING,
        (DWORD) IDC_HELP,
        (DWORD) IDC_HAND,   
    };
    hcursor = LoadCursor(NULL,MAKEINTRESOURCE(cursor_ids[pn->cursorId]));
    SetCursor(hcursor);
  }

  void Update()
  {
    if( !invalid.IsRectEmpty() )
    {
      // we could improve performance and render only part of DOM if handeUpdate is allowed to use 
      // UpdateLayeredWindowIndirect that is only supported on Vista and higher
      RECT r;
      GetClientRect(&r);
      Scilite::render(bitmap, 0, 0, r.right, r.bottom);
      handleUpdate();
      invalid.SetRectEmpty();
    }
  }

  virtual void handleUpdate()
  {
    CRect wr;
    GetWindowRect(&wr);

    CPoint pos = wr.TopLeft(); // screen position of the layered window
    CSize  sz  = wr.Size();    // size of the layered window
    CPoint org(0,0);

    HDC hdcBmp = CreateCompatibleDC(0);
    HGDIOBJ tmpObj = SelectObject(hdcBmp, bitmap);

    BLENDFUNCTION bf;
    bf.BlendOp = AC_SRC_OVER;
    bf.AlphaFormat = AC_SRC_ALPHA;
    bf.BlendFlags = 0;
    bf.SourceConstantAlpha = 0xFF;

    BOOL r = UpdateLayeredWindow(
      m_hWnd,             // handle to layered window
      NULL,               // handle to screen DC
      &pos,               // new screen position
      &sz,                // new size of the layered window
      hdcBmp,             // handle to surface DC
      &org,               // layer position
      0,                  // color key
      &bf,                // blend function
      ULW_ALPHA           // options
    );
    if(!r)
    {
      DWORD er = GetLastError();
      er = er;
    }

    SelectObject(hdcBmp, tmpObj);
    DeleteDC(hdcBmp);
  }

};
