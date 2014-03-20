// sciter.cpp : main source file for sciter.exe
//

#include "stdafx.h"

#include "mainfrm.h"

CAppModule _Module;

class CSciterThreadManager
{
public:
	// thread init param
	struct _RunData
	{
    json::string cmdLine;
    json::value  param;
		int          cmdShow;
	};

	// thread proc
	static DWORD WINAPI RunThread(LPVOID lpData)
	{
    OleInitialize(0);
		CMessageLoop theLoop;
		_Module.AddMessageLoop(&theLoop);

		_RunData* pData = (_RunData*)lpData;
		CMainFrame wndFrame;
    wndFrame.fileToLoad = pData->cmdLine;
    wndFrame.paramToPass = pData->param;

		if(wndFrame.CreateEx() == NULL)
		{
			ATLTRACE(_T("Frame window creation failed!\n"));
			return 0;
		}

		wndFrame.ShowWindow(pData->cmdShow);
		::SetForegroundWindow(wndFrame);	// Win95 needs this
		delete pData;

		int nRet = theLoop.Run();

		_Module.RemoveMessageLoop();
    ::OleUninitialize();
		return nRet;
	}

	DWORD m_dwCount;
	HANDLE m_arrThreadHandles[MAXIMUM_WAIT_OBJECTS - 1];

	CSciterThreadManager() : m_dwCount(0)
	{ }

// Operations
  DWORD AddThread(const json::string& cmdLine, int cmdShow, json::value param = json::value())
	{
		if(m_dwCount == (MAXIMUM_WAIT_OBJECTS - 1))
		{
			::MessageBox(NULL, _T("ERROR: Cannot create ANY MORE threads!!!"), _T("sciter"), MB_OK);
			return 0;
		}

		_RunData* pData = new _RunData;
		pData->cmdLine = cmdLine;
		pData->cmdShow = cmdShow;
    pData->param   = param;
		DWORD dwThreadID;
		HANDLE hThread = ::CreateThread(NULL, 0, RunThread, pData, 0, &dwThreadID);
		if(hThread == NULL)
		{
			::MessageBox(NULL, _T("ERROR: Cannot create thread!!!"), _T("sciter"), MB_OK);
			return 0;
		}

		m_arrThreadHandles[m_dwCount] = hThread;
		m_dwCount++;
		return dwThreadID;
	}

	void RemoveThread(DWORD dwIndex)
	{
		::CloseHandle(m_arrThreadHandles[dwIndex]);
		if(dwIndex != (m_dwCount - 1))
			m_arrThreadHandles[dwIndex] = m_arrThreadHandles[m_dwCount - 1];
		m_dwCount--;
	}

  bool FindScapp(std::wstring &filename_r)
  {
    /* Check scapp file presence */
    wchar_t path[MAX_PATH];
    bool result = false;
    GetModuleFileName(_Module.GetModuleInstance(), path, MAX_PATH);
    wchar_t *psl = max(wcsrchr(path,'\\'),wcsrchr(path,'/'));
    if( psl )
    {
      WIN32_FIND_DATA fd;
      wcscpy(psl + 1, L"*.scapp");
      HANDLE hFind;
      if( (hFind = FindFirstFile(path, &fd )) != INVALID_HANDLE_VALUE )
      {
        wcscpy(psl + 1, fd.cFileName);

        aux::mm_file file;
        if( file.open(path) )
        {
          json::value val;
          std::string s((char*)file.data(), file.size());
          if( !ValueFromString(&val, aux::a2w(s.c_str()), UINT(s.size()), CVT_JSON_LITERAL) )
          {
            // get name of the file
            json::value filename = val[L"main"];
            if( filename.is_string() && !filename.is_null() && !filename.is_undefined() )
            {
              wcscpy(psl + 1, filename.to_string().c_str());
              for( wchar_t* p = path; *p; ++p )
                if( *p == '/' ) *p = '\\';

              if( GetFileAttributes(path) != 0xFFFFFFFF )
              {
                filename_r = path;
                result = true;
              }
            }
          }
        }
        FindClose(hFind);
      }
    }
    return result;
  }

  #define BREAK_INTO_DEBUGGER()  __asm { int 3 }

	int Run(LPTSTR lpstrCmdLine, int nCmdShow)
	{
		MSG msg;
		// force message queue to be created
		::PeekMessage(&msg, NULL, WM_USER, WM_USER, PM_NOREMOVE);

    if(lpstrCmdLine && *lpstrCmdLine=='"')
    {
      ++lpstrCmdLine; lpstrCmdLine[ _tcslen(lpstrCmdLine) - 1 ] = 0;
      //BREAK_INTO_DEBUGGER();
    }


    std::wstring filename;
    if( FindScapp(filename) )
      AddThread(filename.c_str(), nCmdShow);
    else
		  AddThread(lpstrCmdLine, nCmdShow);

		int nRet = m_dwCount;
		DWORD dwRet;
		while(m_dwCount > 0)
		{
			dwRet = ::MsgWaitForMultipleObjects(m_dwCount, m_arrThreadHandles, FALSE, INFINITE, QS_ALLEVENTS);

			if(dwRet == 0xFFFFFFFF)
			{
				::MessageBox(NULL, _T("ERROR: Wait for multiple objects failed!!!"), _T("sciter"), MB_OK);
			}
			else if(dwRet >= WAIT_OBJECT_0 && dwRet <= (WAIT_OBJECT_0 + m_dwCount - 1))
			{
				RemoveThread(dwRet - WAIT_OBJECT_0);
			}
			else if(dwRet == (WAIT_OBJECT_0 + m_dwCount))
			{
				if(::PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
				{
					if(msg.message == WM_USER)
						AddThread(TEXT(""), SW_SHOWNORMAL);
				}
			}
			else
			{
				::MessageBeep((UINT)-1);
			}
		}

		return nRet;
	}
};

CSciterThreadManager threads;

DWORD OpenNewSciter( const json::string& cmdLine, int nCmdShow, json::value param )
{
  return threads.AddThread(cmdLine, nCmdShow, param);
}


int WINAPI _tWinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPTSTR lpstrCmdLine, int nCmdShow)
{
	HRESULT hRes = ::OleInitialize(NULL);
// If you are running on NT 4.0 or higher you can use the following call instead to 
// make the EXE free threaded. This means that calls come in on a random RPC thread.
//	HRESULT hRes = ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
	ATLASSERT(SUCCEEDED(hRes));

	// this resolves ATL window thunking problem when Microsoft Layer for Unicode (MSLU) is used
	::DefWindowProc(NULL, 0, 0, 0L);

  // SciterAppendMasterCSS test, adding <checkbox>text</checkbox> element.
  const char* def = "checkbox { display:inline-block; display-model:inline-inside; style-set: \"std-checkbox\"; }";
  SciterAppendMasterCSS((const byte*)def,strlen(def)); 

	AtlInitCommonControls(ICC_BAR_CLASSES | ICC_LISTVIEW_CLASSES);	// add flags to support other controls

	hRes = _Module.Init(NULL, hInstance);
	ATLASSERT(SUCCEEDED(hRes));

	int nRet = 0;
	// BLOCK: Run application
	{
		nRet = threads.Run(lpstrCmdLine, nCmdShow);
	}

	_Module.Term();
	::OleUninitialize();

	return nRet;
}
