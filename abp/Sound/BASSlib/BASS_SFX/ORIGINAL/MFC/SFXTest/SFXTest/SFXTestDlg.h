// SFXTestDlg.h : header file
//

#pragma once
#include "afxwin.h"
#include "bass.h"
#include "bass_sfx.h"

// CSFXTestDlg dialog
class CSFXTestDlg : public CDialog
{
// Construction
public:
	CSFXTestDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_SFXTEST_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;
	HSFX hSFX, hSFX2, hSFX3, hSFX4;
	HSTREAM hStream;
	CRect rect[3];

	CDC* m_pVisDC[3];

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	CStatic m_oVisPanel;
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	CStatic m_oVisPanel2;
	afx_msg void OnDestroy();
	afx_msg void OnBnClickedStart();
	afx_msg void OnBnClickedStop();
	afx_msg void OnBnClickedStartit();
	CButton m_oCreateStartBtn;
	CStatic m_oVisPanel3;
};
