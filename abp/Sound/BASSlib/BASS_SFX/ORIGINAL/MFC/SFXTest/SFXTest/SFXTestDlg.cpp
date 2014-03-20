// SFXTestDlg.cpp : implementation file
//

#include "stdafx.h"
#include "SFXTest.h"
#include "SFXTestDlg.h"



#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
END_MESSAGE_MAP()


// CSFXTestDlg dialog




CSFXTestDlg::CSFXTestDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CSFXTestDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	hSFX4 = hSFX3 = hSFX2 = hSFX = 0;
	m_pVisDC[0] = m_pVisDC[1] = m_pVisDC[2] = 0;
}

void CSFXTestDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_VIS_PANEL, m_oVisPanel);
	DDX_Control(pDX, IDC_VIS_PANEL2, m_oVisPanel2);
	DDX_Control(pDX, IDC_START, m_oCreateStartBtn);
	DDX_Control(pDX, IDC_VIS_PANEL3, m_oVisPanel3);
}

BEGIN_MESSAGE_MAP(CSFXTestDlg, CDialog)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	//}}AFX_MSG_MAP
	ON_WM_TIMER()
	ON_WM_DESTROY()
	ON_BN_CLICKED(IDC_START, &CSFXTestDlg::OnBnClickedStart)
	ON_BN_CLICKED(IDC_STOp, &CSFXTestDlg::OnBnClickedStop)
	ON_BN_CLICKED(IDC_STARTIT, &CSFXTestDlg::OnBnClickedStartit)
END_MESSAGE_MAP()


// CSFXTestDlg message handlers

BOOL CSFXTestDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	
	/*m_oVisPanel2.SetWindowPos(NULL, 0,0, 320, 240, SWP_NOMOVE);
	m_oVisPanel.SetWindowPos(NULL, 0,0, 320, 240, SWP_NOMOVE);*/

	m_oVisPanel.GetClientRect(&rect[0]);
	m_oVisPanel2.GetClientRect(&rect[1]);
	m_oVisPanel3.GetClientRect(&rect[2]);

	m_pVisDC[0] = m_oVisPanel.GetDC();
	m_pVisDC[1] = m_oVisPanel2.GetDC();
	m_pVisDC[2] = m_oVisPanel3.GetDC();
	
	BASS_Init(-1, 44100, 0, m_hWnd, NULL);
	hStream = BASS_StreamCreateFile(0,"music\\matrix.mp3", 0,0,0);

	BASS_SFX_Init(AfxGetApp()->m_hInstance, m_hWnd);
	

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CSFXTestDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CSFXTestDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CSFXTestDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}


void CSFXTestDlg::OnTimer(UINT_PTR nIDEvent)
{
	if(hSFX)
		BASS_SFX_PluginRender(hSFX, hStream, m_pVisDC[0]->GetSafeHdc());

	if(hSFX2)
		BASS_SFX_PluginRender(hSFX2, hStream, m_pVisDC[1]->GetSafeHdc());

	if(hSFX4)
		BASS_SFX_PluginRender(hSFX4, hStream, m_pVisDC[2]->GetSafeHdc());

	CDialog::OnTimer(nIDEvent);
}

void CSFXTestDlg::OnDestroy()
{
	CDialog::OnDestroy();

	KillTimer(1);
	Sleep(28);

	ReleaseDC(m_pVisDC[0]);
	ReleaseDC(m_pVisDC[1]);
	ReleaseDC(m_pVisDC[2]);
	
	BASS_SFX_Free();
}

void CSFXTestDlg::OnBnClickedStart()
{
	KillTimer(1);
	Sleep(28);
	
	if(hSFX)
		BASS_SFX_PluginFree(hSFX); //very important. Always Release before creating
	
	if(hSFX2)
		BASS_SFX_PluginFree(hSFX2);//very important. Always Release before creating

	if(hSFX3)
		BASS_SFX_PluginFree(hSFX3); //very important. Always Release before creating

	if(hSFX4)
		BASS_SFX_PluginFree(hSFX4); //very important. Always Release before creating
	

	//create plugin if one doesnt exist
	if(!hSFX)
		hSFX = BASS_SFX_PluginCreate("plugins\\sphere.svp", m_oVisPanel.m_hWnd, rect[0].Width(), rect[0].Height(), 0);
	
	//create a WMP plugin if one doesnt exist
	if(!hSFX2)
		hSFX2 = BASS_SFX_PluginCreate("plugins\\blaze.dll", m_oVisPanel2.m_hWnd, rect[1].Width(), rect[1].Height(), 0);

	//also if you want to use a windows media player plugin that is internal to windows media player
	//such as Alchemy, you can just pass in the plugins CLSID or GUID to run it as follows
	//
	//These CLSID or GUID strings can be found in the following registry key
	//HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MediaPlayer\Objects\Effects\
	//
	//hSFX2 = BASS_SFX_PluginCreate("0AA02E8D-F851-4CB0-9F64-BBA9BE7A983D", rect.Width(), rect.Height());

	if(!hSFX3)
		hSFX3 = BASS_SFX_PluginCreate("plugins\\vis_avs.dll", 0,0,0,0);

	if(!hSFX4)
		hSFX4 = BASS_SFX_PluginCreate("BBPlugin\\Oscillo.dll",m_oVisPanel3.m_hWnd, rect[2].Width(),rect[2].Height(), 0);


	BASS_SFX_PluginSetStream(hSFX3, hStream);
	BASS_ChannelPlay(hStream, false);
	
	BASS_SFX_PluginStart(hSFX);
	BASS_SFX_PluginStart(hSFX2);
	BASS_SFX_PluginStart(hSFX3);
	BASS_SFX_PluginStart(hSFX4);

	
	SetTimer(1, 27, NULL);
	m_oCreateStartBtn.EnableWindow(FALSE);
}

void CSFXTestDlg::OnBnClickedStop()
{
	BASS_SFX_PluginStop(hSFX);
	BASS_SFX_PluginStop(hSFX2);
	BASS_SFX_PluginStop(hSFX3);
	BASS_SFX_PluginStop(hSFX4);

	this->m_oVisPanel3.RedrawWindow();
	this->m_oVisPanel3.Invalidate();

	this->m_oVisPanel2.RedrawWindow();
	this->m_oVisPanel2.Invalidate();

	this->m_oVisPanel.RedrawWindow();
	this->m_oVisPanel.Invalidate();
}

void CSFXTestDlg::OnBnClickedStartit()
{
	BASS_SFX_PluginStart(hSFX);
	BASS_SFX_PluginStart(hSFX2);
	BASS_SFX_PluginStart(hSFX3);
	BASS_SFX_PluginStart(hSFX4);
}