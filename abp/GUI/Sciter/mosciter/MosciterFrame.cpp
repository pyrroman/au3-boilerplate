// MosciterFrame.cpp : implementation of the CMosciterFrame class
//
/////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "resourceppc.h"

#include "aboutdlg.h"
#include "MosciterFrame.h"

BOOL CMosciterFrame::PreTranslateMessage(MSG* pMsg)
{
	return CFrameWindowImpl<CMosciterFrame>::PreTranslateMessage(pMsg);
}

bool CMosciterFrame::AppHibernate( bool bHibernate)
{
	// Insert your code here or delete member if not relevant
	return bHibernate;
}

bool CMosciterFrame::AppNewInstance( LPCTSTR lpstrCmdLine)
{
	// Insert your code here or delete member if not relevant
	return false;
}

void CMosciterFrame::AppSave()
{
	CAppInfo info;
	info.Save( m_bFullScreen, L"Full");
	// Insert your code here
}

BOOL CMosciterFrame::OnIdle()
{
	UIUpdateToolBar();
	return FALSE;
}

LRESULT CMosciterFrame::OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
{
	CAppInfo info;

	// Full screen mode delayed restoration 
	bool bFull = false;
	info.Restore(bFull, L"Full");
	if (bFull)
		PostMessage(WM_COMMAND, ID_VIEW_FULLSCREEN);

	CreateSimpleCEMenuBar(IDR_MAINFRAME, 0, IDR_MAINFRAME, 7);
	UIAddToolBar(m_hWndCECommandBar);

	// register object for message filtering and idle updates
	CMessageLoop* pLoop = _Module.GetMessageLoop();
	ATLASSERT(pLoop != NULL);
	pLoop->AddMessageFilter(this);
	pLoop->AddIdleHandler(this);

	return 0;
}

LRESULT CMosciterFrame::OnFileExit(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	PostMessage(WM_CLOSE);
	return 0;
}

LRESULT CMosciterFrame::OnFileNew(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	// TODO: add code to initialize document

	return 0;
}

LRESULT CMosciterFrame::OnFullScreen(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	SetFullScreen( !m_bFullScreen );
	UISetCheck( ID_VIEW_FULLSCREEN, m_bFullScreen);
	return TRUE;
}

LRESULT CMosciterFrame::OnAppAbout(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
{
	CAboutDlg dlg;
	FSDoModal(dlg);
	return 0;
}

