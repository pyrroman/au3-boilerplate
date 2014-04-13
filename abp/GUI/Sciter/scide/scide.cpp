// scide.cpp : main source file for scide.exe
//

#include "stdafx.h"

#include <atlframe.h>
#include <atlctrls.h>
#include <atldlgs.h>

#include "resource.h"

#include "scideView.h"
#include "aboutdlg.h"
#include "MainFrm.h"
#include <string>
#include <sstream>

CAppModule _Module;

#ifdef _DEBUG
sciter::debug_output_console dbgcon;
#endif

CMainFrame*   CMainFrame::rootFrame = 0;

class CScideThreadManager
{
public:
  // thread init param

  // thread proc
  static DWORD WINAPI RunThread(LPVOID lpData)
  {
    HRESULT hRes = ::OleInitialize(NULL);
    CMessageLoop theLoop;
    _Module.AddMessageLoop(&theLoop);

    NewSciterParams* pData = (NewSciterParams*)lpData;
    CMainFrame wndFrame(pData);

    int nCmdShow         = pData->cmd_show;

    if(wndFrame.CreateEx() == NULL)
    {
      ATLTRACE(_T("Frame window creation failed!\n"));
      return 0;
    }
    
    wndFrame.ShowWindow(nCmdShow);
    ::SetForegroundWindow(wndFrame);  // Win95 needs this
    
    int nRet = theLoop.Run();

    _Module.RemoveMessageLoop();
    ::OleUninitialize();
    return nRet;
  }

  CScideThreadManager()
  { }

// Operations
  HANDLE AddThread(NewSciterParams* params)
  {
    DWORD dwThreadID;
    HANDLE hThread = ::CreateThread(NULL, 0, RunThread, params, 0, &dwThreadID);
    if(hThread == NULL)
    {
      ::MessageBox(NULL, _T("ERROR: Cannot create thread!!!"), _T("scide"), MB_OK);
      return 0;
    }

    // What this piece was for?
    //
    //if( !ide )  
    //{
    //  ::CloseHandle(hThread); // we do not need this further
    //  return 0;
    //}
    return hThread;
  }

  int Run(LPTSTR lpstrCmdLine, int nCmdShow, bool ide)
  {
    MSG msg;
    // force message queue to be created
    ::PeekMessage(&msg, NULL, WM_USER, WM_USER, PM_NOREMOVE);

    NewSciterParams* params = new NewSciterParams;
    params->cmd_line = lpstrCmdLine;
    params->cmd_show = SW_SHOW;

    // thread of IDE main window
    HANDLE hThread = AddThread(params);

    if( hThread )
    {
      for(;;)
      {
        DWORD dwRet = ::MsgWaitForMultipleObjects(1, &hThread, FALSE, INFINITE, QS_ALLINPUT);

        if(dwRet == 0xFFFFFFFF)
        {
          ::MessageBox(NULL, _T("ERROR: Wait for multiple objects failed!!!"), _T("scide"), MB_OK);
        }
        else if(dwRet == WAIT_OBJECT_0)
        {
          break;
        }
        else if(dwRet == (WAIT_OBJECT_0 + 1))
        {
          if(::PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
          {
          }
        }
        else
        {
          ::MessageBeep((UINT)-1);
        }
      }
    }

    return 0;
  }
};

CScideThreadManager mgr;

HANDLE OpenNewSciter( NewSciterParams* params )
{
  return mgr.AddThread(params);
}

int WINAPI _tWinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPTSTR lpstrCmdLine, int nCmdShow)
{
  HRESULT hRes = ::CoInitialize(NULL);
// If you are running on NT 4.0 or higher you can use the following call instead to 
// make the EXE free threaded. This means that calls come in on a random RPC thread.
//  HRESULT hRes = ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
  ATLASSERT(SUCCEEDED(hRes));

  // this resolves ATL window thunking problem when Microsoft Layer for Unicode (MSLU) is used
  ::DefWindowProc(NULL, 0, 0, 0L);

  AtlInitCommonControls(ICC_BAR_CLASSES); // add flags to support other controls

  hRes = _Module.Init(NULL, hInstance);
  ATLASSERT(SUCCEEDED(hRes));

  int nRet = 0;
  // BLOCK: Run application
  {
    nRet = mgr.Run(lpstrCmdLine, nCmdShow, true);
  }

  _Module.Term();
  ::CoUninitialize();


  return nRet;
}
