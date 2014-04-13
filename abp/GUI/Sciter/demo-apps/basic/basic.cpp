// basic.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "basic.h"
#include "resource.h"

#define MAX_LOADSTRING 100

// Global Variables:
HINSTANCE ghInstance;                   // current instance
TCHAR szTitle[MAX_LOADSTRING];          // The title bar text
TCHAR szWindowClass[MAX_LOADSTRING];    // The title bar text

// Foward declarations of functions included in this code module:
ATOM        MyRegisterClass(HINSTANCE hInstance);
BOOL        InitInstance(HINSTANCE, int);
LRESULT CALLBACK  WndProc(HWND, UINT, WPARAM, LPARAM);
LRESULT CALLBACK  About(HWND, UINT, WPARAM, LPARAM);

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
  // TODO: Place code here.
  MSG msg;
  HACCEL hAccelTable;

  // Initialize global strings
  LoadString(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
  LoadString(hInstance, IDC_BASIC, szWindowClass, MAX_LOADSTRING);
  MyRegisterClass(hInstance);

  // SciterAppendMasterCSS test, adding <checkbox>text</checkbox> element.
  const char* def = "checkbox { display:inline-block; display-model:inline-inside; style-set: \"std-checkbox\"; }";
  SciterAppendMasterCSS((const byte*)def,strlen(def)); 

  // Perform application initialization:
  if (!InitInstance (hInstance, nCmdShow)) 
  {
    return FALSE;
  }

  hAccelTable = LoadAccelerators(hInstance, (LPCTSTR)IDC_BASIC);

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
//  FUNCTION: MyRegisterClass()
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
ATOM MyRegisterClass(HINSTANCE hInstance)
{
  WNDCLASSEX wcex = {0}; 

  wcex.cbSize = sizeof(WNDCLASSEX); 

  wcex.style          = CS_HREDRAW | CS_VREDRAW | CS_DBLCLKS;
  wcex.lpfnWndProc    = (WNDPROC)WndProc;
  wcex.cbClsExtra     = 0;
  wcex.cbWndExtra     = 0;
  wcex.hInstance      = hInstance;
  wcex.hIcon          = LoadIcon(hInstance, (LPCTSTR)IDI_BASIC);
  wcex.hCursor        = LoadCursor(NULL, IDC_ARROW);
  wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
  wcex.lpszMenuName   = (LPCSTR)IDC_BASIC;
  wcex.lpszClassName  = szWindowClass;
  wcex.hIconSm        = LoadIcon(wcex.hInstance, (LPCTSTR)IDI_SMALL);

  return RegisterClassEx(&wcex);
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

   ghInstance = hInstance; // Store instance handle in our global variable

   hWnd = CreateWindow(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);

   //UINT style = WS_POPUP;// | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU | WS_SIZEBOX;
   //hWnd = CreateWindowEx( 0x00080000 /*WS_EX_LAYERED*/, szWindowClass, NULL, style ,
   //                             0, 0, 400, 1000, NULL, NULL, hInstance, NULL);


   if (!hWnd)
   {
      return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}

// Implementation of native function alert(msg) 

tiscript::value TISAPI native_alert(tiscript::VM* vm)
{
  tiscript::value retVal = tiscript::v_undefined(); 
  std::wstring msg;
  try
  {
    tiscript::args(vm)
      >> tiscript::args::skip // skip 'this' as this is a global function.
      >> tiscript::args::skip // skip 'super'
      >> msg;                 // it should be a string.
  } 
  catch (tiscript::args::error &e)
  {
    tiscript::throw_error(vm, e.msg());
    return retVal;
  };

  MessageBoxW(NULL,msg.c_str(),L"alert", MB_OK);  
  
  return retVal; 
  //multi return sample:
  //TISCRIPT_RETURN_2(vm, tiscript::v_int(12), tiscript::v_bool(true) );
};

static tiscript::method_def native_alert_md("alert",native_alert);


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
  int wmId, wmEvent;

//SCITER integration starts
  BOOL r, handled = FALSE;
  LRESULT lr = SciterProcND(hWnd,message,wParam,lParam, &handled);
  if( handled )
    return lr;
//SCITER integration ends

  switch (message) 
  {
    case WM_COMMAND:
      wmId    = LOWORD(wParam); 
      wmEvent = HIWORD(wParam); 
      // Parse the menu selections:
      switch (wmId)
      {
//SCITER integration starts         
        case IDM_ABOUT:
           SciterCall(hWnd,"About.show",0,0,0);
           break;
        case IDM_MSGBOX:
          {
            json::value ret;
            SciterEval(hWnd,L"A",1,&ret); assert(ret.is_object_function());
            SciterEval(hWnd,L"B",1,&ret); assert(ret.is_object_function());
            SciterEval(hWnd,L"C",1,&ret); assert(ret.is_object_function());

            json::value arg(L"Hello Sciter!");
            SciterCall(hWnd,"showMsgBox",1,&arg,&ret);
            ::MessageBoxW(hWnd,ret.to_string().c_str(),L"showMsgBox returned:", MB_OK);

          }
          break;

        case IDM_MSGBOX_TISCRIPT:
          {
            // same as above but using tiscript API
            sciter::dom::element root = sciter::dom::element::root_element(hWnd);
            tiscript::VM*        pvm  = SciterGetVM(hWnd);
            tiscript::value      msg  = tiscript::v_string(pvm, L"Hello Sciter!",13);
            tiscript::value      func = tiscript::get_prop(pvm, root.get_namespace(),"showMsgBox");

            assert( tiscript::is_function(func) );

            tiscript::call(pvm, func, &msg, 1);
          }
          break;


//SCITER integration ends
        case IDM_EXIT:
           DestroyWindow(hWnd);
           break;
        default:
           return DefWindowProc(hWnd, message, wParam, lParam);
      }
      break;

    case WM_CREATE:
//SCITER integration starts
      {
        SciterSetCallback(hWnd, BasicHostCallback, 0 /*cbParam is not ised in this sample*/ );
        // registering our global function:
        tiscript::VM* pvm = SciterGetVM(hWnd);
        tiscript::define_global_function(pvm,&native_alert_md);
        

        /* Creation of MyNS namespace.
        tiscript::class_def MyNS = {"MyNS"};
        tiscript::pinned gsObj(pvm), nsObj(pvm);
        gsObj = tiscript::get_global_ns(pvm);
        nsObj = tiscript::define_class(pvm,&MyNS,gsObj);
        */
       
        LPCBYTE pb = 0;
        UINT   cb = 0;
        GetResource(L"default.html",pb,cb);
        assert( pb && cb );
        r = SciterLoadHtml(hWnd, pb,cb, NULL ); 
      }
      assert(r);
//SCITER integration ends
      break;
    case WM_DESTROY:
      PostQuitMessage(0);
      break;
    default:
      return DefWindowProc(hWnd, message, wParam, lParam);
   }
   return 0;
}

// Mesage handler for about box.
LRESULT CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
  switch (message)
  {
    case WM_INITDIALOG:
        return TRUE;

    case WM_COMMAND:
      if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL) 
      {
        EndDialog(hDlg, LOWORD(wParam));
        return TRUE;
      }
      break;
  }
    return FALSE;
}
