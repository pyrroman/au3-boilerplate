// MosciterFrame.h : interface of the CMosciterFrame class
//
/////////////////////////////////////////////////////////////////////////////

#pragma once

class CMosciterFrame : 
	public CFrameWindowImpl<CMosciterFrame>, 
	public CUpdateUI<CMosciterFrame>,
	public CAppWindow<CMosciterFrame>,
	public CFullScreenFrame<CMosciterFrame>,
	public CMessageFilter, public CIdleHandler
{
public:
	DECLARE_APP_FRAME_CLASS(NULL, IDR_MAINFRAME, L"Software\\WTL\\Mosciter")

	virtual BOOL PreTranslateMessage(MSG* pMsg);

// CAppWindow operations
	bool AppHibernate( bool bHibernate);

	bool AppNewInstance( LPCTSTR lpstrCmdLine);

	void AppSave();

	virtual BOOL OnIdle();

	BEGIN_UPDATE_UI_MAP(CMosciterFrame)
		UPDATE_ELEMENT(ID_VIEW_FULLSCREEN, UPDUI_MENUPOPUP)
	END_UPDATE_UI_MAP()

	BEGIN_MSG_MAP(CMosciterFrame)
		MESSAGE_HANDLER(WM_CREATE, OnCreate)
		COMMAND_ID_HANDLER(ID_APP_EXIT, OnFileExit)
		COMMAND_ID_HANDLER(ID_FILE_NEW, OnFileNew)
		COMMAND_ID_HANDLER(ID_VIEW_FULLSCREEN, OnFullScreen)
		COMMAND_ID_HANDLER(ID_APP_ABOUT, OnAppAbout)
		CHAIN_MSG_MAP(CAppWindow<CMosciterFrame>)
		CHAIN_MSG_MAP(CFullScreenFrame<CMosciterFrame>)
		CHAIN_MSG_MAP(CUpdateUI<CMosciterFrame>)
		CHAIN_MSG_MAP(CFrameWindowImpl<CMosciterFrame>)
	END_MSG_MAP()

// Handler prototypes (uncomment arguments if needed):
//	LRESULT MessageHandler(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
//	LRESULT CommandHandler(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
//	LRESULT NotifyHandler(int /*idCtrl*/, LPNMHDR /*pnmh*/, BOOL& /*bHandled*/)

	LRESULT OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/);

	LRESULT OnFileExit(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);

	LRESULT OnFileNew(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);

	LRESULT OnFullScreen(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);

	LRESULT OnAppAbout(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/);
};
