// MainFrm.cpp : implmentation of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "resource.h"

#include "aboutdlg.h"
#include "wtlView.h"
#include "MainFrm.h"

BOOL CMainFrame::PreTranslateMessage(MSG* pMsg)
{
  if(CFrameWindowImpl<CMainFrame>::PreTranslateMessage(pMsg))
    return TRUE;

  return m_view.PreTranslateMessage(pMsg);
}

BOOL CMainFrame::OnIdle()
{
  return FALSE;
}

LRESULT CMainFrame::OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
{

  m_hWndClient = m_view.Create(m_hWnd, rcDefault, NULL, WS_CHILD | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN, WS_EX_CLIENTEDGE);


  // register object for message filtering and idle updates
  CMessageLoop* pLoop = _Module.GetMessageLoop();
  ATLASSERT(pLoop != NULL);
  pLoop->AddMessageFilter(this);
  pLoop->AddIdleHandler(this);

  return 0;
}

LRESULT CMainFrame::OnFileExit(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
  PostMessage(WM_CLOSE);
  return 0;
}

LRESULT CMainFrame::OnFileOpen(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
  CFileDialog dlg(TRUE, "htm", NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, 
    "HTML Files (*.htm,*.html)\0*.HTM;*.HTML\0"
    "All Files (*.*)\0*.*\0", m_hWnd);
  if(dlg.DoModal() == IDOK)
  {
       USES_CONVERSION;
       m_view.LoadFile(T2W(dlg.m_szFileName));
  }
  return 0;
}

LRESULT CMainFrame::OnAppAbout(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
  CAboutDlg dlg;
  dlg.DoModal();
  return 0;
}

//static unsigned char test_bytes[1024*1024*8] = {0};

LRESULT CMainFrame::OnCallScript(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
  /* 
  one way of doing this: rv (method reference) could be stored for the later use.
  */

  aux::wchars script = const_wchars("Foo.bar");
  SCITER_VALUE rv, p1;
  SciterEval(m_view.m_hWnd,script.start, script.length,&rv);
  if(rv.is_object_function())  
  {
    p1 = SCITER_VALUE(L"<b>Hello</b> world!");
    rv.call(1,&p1);
  }
  
  // here is shorter way of calling functions in script: 
  /*SCITER_VALUE p1 = SCITER_VALUE(L"<b>Hello</b> world!");
  SciterCall(m_view.m_hWnd,"Foo.bar", 1, &p1,0);*/

  return 0;
}

