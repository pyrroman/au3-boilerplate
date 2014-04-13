// MainFrm.h : interface of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_MAINFRM_H__55E97638_6B61_4433_B76F_390E90C91F29__INCLUDED_)
#define AFX_MAINFRM_H__55E97638_6B61_4433_B76F_390E90C91F29__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

class CMainFrame : public CFrameWindowImpl<CMainFrame>, public CUpdateUI<CMainFrame>,
    public CMessageFilter, public CIdleHandler
{
public:
  DECLARE_FRAME_WND_CLASS(NULL, IDR_MAINFRAME)

  CSciterView m_view;

  virtual BOOL PreTranslateMessage(MSG* pMsg);
  virtual BOOL OnIdle();

  BEGIN_UPDATE_UI_MAP(CMainFrame)
  END_UPDATE_UI_MAP()

  BEGIN_MSG_MAP(CMainFrame)
    MESSAGE_HANDLER(WM_CREATE, OnCreate)
    COMMAND_ID_HANDLER(ID_APP_EXIT, OnFileExit)
    COMMAND_ID_HANDLER(ID_FILE_OPEN, OnFileOpen)
    COMMAND_ID_HANDLER(ID_APP_ABOUT, OnAppAbout)
    COMMAND_ID_HANDLER(ID_CALL_METHOD, OnCallScript)
    
    CHAIN_MSG_MAP(CUpdateUI<CMainFrame>)
    CHAIN_MSG_MAP(CFrameWindowImpl<CMainFrame>)
  END_MSG_MAP()

// Handler prototypes (uncomment arguments if needed):
//  LRESULT MessageHandler(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
//  LRESULT CommandHandler(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
//  LRESULT NotifyHandler(int /*idCtrl*/, LPNMHDR /*pnmh*/, BOOL& /*bHandled*/)

  LRESULT OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/);
  LRESULT OnFileExit(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
  LRESULT OnFileOpen(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
  LRESULT OnAppAbout(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
  LRESULT OnCallScript(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MAINFRM_H__55E97638_6B61_4433_B76F_390E90C91F29__INCLUDED_)
