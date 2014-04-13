// AboutDlg.cpp : implementation of the CAboutDlg class
//
/////////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "resourceppc.h"
#include "aboutdlg.h"

LRESULT CAboutDlg::OnInitDialog(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& bHandled)
{
	AtlCreateEmptyMenuBar(m_hWnd);

	return bHandled = FALSE;
}

