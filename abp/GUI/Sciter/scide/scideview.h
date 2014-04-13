// scideView.h : interface of the CScideView class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_SCIDEVIEW_H__AD8A2D15_9915_4C5F_BB86_B4A93F6B9010__INCLUDED_)
#define AFX_SCIDEVIEW_H__AD8A2D15_9915_4C5F_BB86_B4A93F6B9010__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

class CScideView : public CWindowImpl<CScideView>
{
public:
  DECLARE_WND_CLASS(NULL)

  BOOL PreTranslateMessage(MSG* pMsg)
  {
    pMsg;
    return FALSE;
  }

  BEGIN_MSG_MAP(CScideView)
    MESSAGE_HANDLER(WM_PAINT, OnPaint)
  END_MSG_MAP()

// Handler prototypes (uncomment arguments if needed):
//  LRESULT MessageHandler(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
//  LRESULT CommandHandler(WORD /*wNotifyCode*/, WORD /*wID*/, HWND /*hWndCtl*/, BOOL& /*bHandled*/)
//  LRESULT NotifyHandler(int /*idCtrl*/, LPNMHDR /*pnmh*/, BOOL& /*bHandled*/)

  LRESULT OnPaint(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
  {
    CPaintDC dc(m_hWnd);

    //TODO: Add your drawing code here

    return 0;
  }
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_SCIDEVIEW_H__AD8A2D15_9915_4C5F_BB86_B4A93F6B9010__INCLUDED_)
