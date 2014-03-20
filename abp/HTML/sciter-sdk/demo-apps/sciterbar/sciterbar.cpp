// basic.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "resource.h"
#include "sciterbarhook.h"


// Global Variables:
HINSTANCE     gInstance;                      // current instance
LPCTSTR       szTitle = "SciterBar";          // The title bar text
LPCTSTR       szWindowClass = "SciterBar";    // The title bar class

SetHookFunc   pfSetHook = 0;
SetSideFunc   pfSetSide = 0;
HMODULE       hHookDLL = 0;
DOCK_SIDE     dockSide = DOCK_LEFT;
UINT          animationTime = 0;
HWND          ghWnd = 0;

// Foward declarations of functions included in this code module:
ATOM              RegisterWindowClass(HINSTANCE hInstance);
BOOL              InitInstance(HINSTANCE, int);
LRESULT CALLBACK  WndProc(HWND, UINT, WPARAM, LPARAM);
LRESULT CALLBACK  About(HWND, UINT, WPARAM, LPARAM);

// Init scripting classes
VOID              InitNativeClasses(HWND hwnd); 

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
  // TODO: Place code here.
  MSG msg;
  HACCEL hAccelTable;

  RegisterWindowClass(hInstance);


  // Perform application initialization:
  if (!InitInstance (hInstance, nCmdShow)) 
  {
    return FALSE;
  }

  hAccelTable = LoadAccelerators(hInstance, (LPCTSTR)IDC_SCITERBAR);

  // Main message loop:
  while (GetMessage(&msg, NULL, 0, 0)) 
  {
    if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg)) 
    {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
    }
  }

  return msg.wParam;
}



//
//  FUNCTION: RegisterWindowClass()
//
//  PURPOSE: Registers the window class.
//
//  COMMENTS:
//
//    This function and its usage is only necessary if you want this code
//    to be compatible with Win32 systems prior to the 'RegisterClassEx'
//    function that was added to Windows 95. It is important to call this function
//    so that the application will get 'well formed' small icons associated
//    with it.
//
ATOM RegisterWindowClass(HINSTANCE hInstance)
{
  WNDCLASS wcex;

  wcex.style          = CS_HREDRAW | CS_VREDRAW;
  wcex.lpfnWndProc    = (WNDPROC)WndProc;
  wcex.cbClsExtra     = 0;
  wcex.cbWndExtra     = 0;
  wcex.hInstance      = hInstance;
  wcex.hIcon          = LoadIcon(hInstance, (LPCTSTR)IDI_SCITERBAR);
  wcex.hCursor        = LoadCursor(NULL, IDC_ARROW);
  wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
  wcex.lpszMenuName   = (LPCSTR)IDC_SCITERBAR;
  wcex.lpszClassName  = szWindowClass;

  return RegisterClass(&wcex);
}

//
//   FUNCTION: InitInstance(HANDLE, int)
//
//   PURPOSE: Saves instance handle and creates main window
//
//   COMMENTS:
//
//        In this function, we save the instance handle in a global variable and
//        create and display the main program window.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
  HWND hWnd;
  gInstance = hInstance; // Store instance handle in our global variable

  hWnd = CreateWindowEx(WS_EX_TOOLWINDOW | WS_EX_TOPMOST,szWindowClass, szTitle, WS_POPUP,
    CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);

  if (!hWnd)
  {
    return FALSE;
  }

  ShowWindow(hWnd, SW_HIDE);
  //UpdateWindow(hWnd);

  hHookDLL = ::LoadLibrary("sciterbarhook.dll"); // Load DLL
  if (!hHookDLL)
  {
FAILURE:
     DestroyWindow(hWnd);
     if( hHookDLL ) ::FreeLibrary(hHookDLL);        
     hHookDLL = 0;
     return FALSE;
  }

  ghWnd = hWnd;

  pfSetHook = (SetHookFunc)::GetProcAddress(hHookDLL, "SetHook");   // Load function
  pfSetSide = (SetSideFunc)::GetProcAddress(hHookDLL, "SetSide");   // Load function
  if (pfSetHook) 
  {                       
    if (!pfSetHook(hWnd, dockSide)) 
       goto FAILURE;
    else
    {
      ::PostMessage(hWnd, WM_SHOW_SIDEBAR, 0,0); // indication that we are up and running
      ::PostMessage(hWnd, WM_HIDE_SIDEBAR, 0,0);
      return TRUE;
    }
  }
  else 
    goto FAILURE;

  return TRUE;
}

void InitSciterOn(HWND hWnd)
{
    SciterSetCallback(hWnd, SciterCallback, 0 /*cbParam is not ised in this sample*/ );
    InitNativeClasses(hWnd);

    // make sciter home path, all relative urls that start from sciter://... will be resolved 
    // against it.
    wchar_t buffer[_MAX_PATH];
    _wgetcwd( buffer, _MAX_PATH );
    wchar_t sciter_home_url[_MAX_PATH] = L"file://";
    wcsncat(sciter_home_url,buffer,_MAX_PATH);
    wcsncat(sciter_home_url,L"/content/",_MAX_PATH);

    SciterSetHomeURL(hWnd,sciter_home_url);

    // try to load default.htm from the /content/ folder
    //if(!SciterLoadFile(hWnd,L"sciter://default.htm"))
    {
      // no luck, load placeholder from resources
      LPCBYTE pb = 0;
      UINT   cb = 0;
      GetResource(L"default.html",pb,cb);
      assert( pb && cb );
      SciterLoadHtml(hWnd, pb,cb, NULL );
    }
}


//
//  FUNCTION: WndProc(HWND, unsigned, WORD, LONG)
//
//  PURPOSE:  Processes messages for the main window.
//
//  WM_COMMAND  - process the application menu
//  WM_PAINT  - Paint the main window
//  WM_DESTROY  - post a quit message and return
//
//

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
  //int wmId, wmEvent;

//SCITER integration starts
  BOOL handled = FALSE;
  LRESULT lr = SciterProcND(hWnd,message,wParam,lParam, &handled);
  if( handled )
    return lr;
//SCITER integration ends

  switch (message) 
  {
    case WM_CREATE:
//SCITER integration starts
      InitSciterOn(hWnd);
//SCITER integration ends
      break;
    case WM_CLOSE:
      ::DestroyWindow(hWnd);
      return 0;

    case WM_SHOW_SIDEBAR:
      {
        if( ::IsWindowVisible(hWnd))
          return 0;
        RECT drc;
        GetClientRect( GetDesktopWindow(),&drc);
        int x = 0;
        int y = 0;
        int width = SciterGetMinWidth(hWnd); if( width == 0 ) width = 300;
        int height = drc.bottom - drc.top;
        int flags = 0;//AW_SLIDE;
        switch( dockSide )
        {
          case DOCK_LEFT: x = 0; flags |= AW_HOR_POSITIVE; break;
          case DOCK_RIGHT: x = drc.right - width; flags |= AW_HOR_NEGATIVE; break;
        }
        MoveWindow(hWnd,x,y,width,height,FALSE);
        ::SendMessage(hWnd,WM_REDRAW,0,0);
        AnimateWindow(hWnd,animationTime,flags);
      }
      return 0;
    case WM_HIDE_SIDEBAR:
      {
        if( !::IsWindowVisible(hWnd))
          return 0;
        RECT drc;
        GetClientRect( GetDesktopWindow(),&drc);
        int x = 0;
        int y = 0;
        int width = 0;
        int height = drc.bottom - drc.top;
        int flags = AW_HIDE; //AW_SLIDE | AW_HIDE;
        switch( dockSide )
        {
          case DOCK_LEFT:  flags |= AW_HOR_NEGATIVE; break;
          case DOCK_RIGHT: flags |= AW_HOR_POSITIVE; break;
        }
        AnimateWindow(hWnd,animationTime,flags);
      }
      return 0;

    case WM_DESTROY:
      PostQuitMessage(0);
      break;
    default:
      return DefWindowProc(hWnd, message, wParam, lParam);
   }
   return 0;
}

// ------------------------

void      SetBarSide(DOCK_SIDE side)
{
  ::SendMessage(ghWnd, WM_HIDE_SIDEBAR, 0, 0); // hide it first
  if(pfSetSide)
    pfSetSide(dockSide = side);

}

DOCK_SIDE GetBarSide()
{
  return dockSide;
}

void          SetBarAnimationTime(unsigned int milliseconds)
{
  animationTime = milliseconds;
}
unsigned int  GetBarAnimationTime()
{
  return animationTime;
}



