// SciterBarHook.cpp : Mouse hook DLL 

#include "windows.h"
#include "sciterbarhook.h"

//-----------------------------------------------------------------------------------
// Shared data segment
#pragma data_seg(".sciterbarhook")
  HWND        gWnd = 0;                // HWND of bar window
  int         gWidth = 0;              // width of the bar
  DOCK_SIDE   gDockSide = DOCK_LEFT;   // docking side
#pragma data_seg()
#pragma comment(linker, "/SECTION:.sciterbarhook,RWS")
//-----------------------------------------------------------------------------------

// Exported functions declaration
extern "C" BOOL __declspec(dllexport) SetHook(HWND hwndBar, DOCK_SIDE side);
extern "C" VOID __declspec(dllexport) SetSide(DOCK_SIDE side);

// Internal functions declaration
BOOL RemoveHook();

// hook function (will be called by other processes)
static LRESULT CALLBACK MouseProc(int nCode, WPARAM wParam, LPARAM lParam);

// globals
HINSTANCE gInstance;   // current instance
HHOOK     gHook;       // hook

//------------------------------------------------------------------------------------
// Function:  DllMain - Main DLL entry, called either when loading or unloading DLL
// Arguments: hInstance - Handler of DLL instance
//            ul_reason_for_call 
// Returns:   Always TRUE
//------------------------------------------------------------------------------------

BOOL APIENTRY DllMain(HINSTANCE hInstance, DWORD  ul_reason_for_call, LPVOID lpReserved)
{ 
    switch (ul_reason_for_call)
  {
    case DLL_PROCESS_ATTACH:
      gInstance = hInstance;  // Store current instance handler
      gHook = NULL;           // Set Hook handle to null
    case DLL_PROCESS_DETACH:
      RemoveHook();            // Remove hook from chain
      break;
    }
    return TRUE;
}

//------------------------------------------------------------------------------------
// Returns:   FALSE if it was already hooked
//            TRUE if hook has been created 
//------------------------------------------------------------------------------------
BOOL SetHook(HWND hwndBar, DOCK_SIDE side)
{
  if (gWnd)
    return FALSE;   // Already hooked!

  gDockSide   = side;
  gHook       = ::SetWindowsHookEx(WH_MOUSE, (HOOKPROC)MouseProc, gInstance, 0);
  gWnd        = hwndBar;
  return TRUE;   // Hook has been created correctly
}

//------------------------------------------------------------------------------------
// SetSide external func used by sidebar to change doc position of the bar
//------------------------------------------------------------------------------------
VOID SetSide(DOCK_SIDE side)
{
  gDockSide   = side;
}


//-------------------------------------------------------------------------------------
// Function:  RemoveHook - Removes hook from chain
// Arguments: none
// Returns:   False if not hook pending to delete (no thread ID defined)
//            True if hook has been removed. Also returns true if there is not hook
//                handler, this can occur if Init failed when called in second instance
//-------------------------------------------------------------------------------------
BOOL RemoveHook()
{
  if (!gWnd) 
    return FALSE; // There is no hook pending to close

  if (gHook) 
  { 
    ::UnhookWindowsHookEx(gHook);
    gWnd  = NULL;
    gHook = NULL; 
  }
  return TRUE;    // Hook has been removed
}

bool IsOnSciterWindow(POINT pt)
{
  HWND hw = ::WindowFromPoint( pt );
  while( ::IsWindow(hw) )
  {
    if( hw == gWnd ) return true;
    hw = GetParent(hw);
  }
  return false;
}


//-------------------------------------------------------------------------------------
// Function:  MouseProc - Callback function for mouse hook
// Arguments: nCode  - action code, according to MS documentation, must return 
//                     inmediatly if less than 0
//            wParam - not used
//            lParam - not used
// Returns:   result from next hook in chain
//-------------------------------------------------------------------------------------

static LRESULT CALLBACK MouseProc(int nCode, WPARAM wParam, LPARAM lParam)
{
  POINT   pt;      

  if (nCode < 0 && gHook) 
  {
    ::CallNextHookEx(gHook, nCode, wParam, lParam);  // Call next hook in chain
    return 0;
  }

  if (gWnd) 
  {
    // get cursor screen coordinates
    ::GetCursorPos(&pt);
    // get window rect
    RECT wrc;
    ::GetWindowRect(gWnd, &wrc);
    int width = wrc.right - wrc.left;

    BOOL isVisible = ::IsWindowVisible(gWnd);

    switch( gDockSide )
    {
    case DOCK_LEFT:
      {
        if ( !isVisible && pt.x < 1 )
          ::PostMessage(gWnd, WM_SHOW_SIDEBAR, 0, 0);  // request to show
        else if ( isVisible && pt.x > width && !IsOnSciterWindow(pt) )
          ::PostMessage(gWnd, WM_HIDE_SIDEBAR, 0, 0);  // request to hide
      } break;
    case DOCK_RIGHT:      
      {
        int lastx = ::GetSystemMetrics(SM_CXSCREEN) - 1;
        if ( !isVisible && pt.x >= lastx )
          ::PostMessage(gWnd, WM_SHOW_SIDEBAR, 0, 0);  // request to show
        else if ( isVisible && pt.x < (lastx - width) && !IsOnSciterWindow(pt))
          ::PostMessage(gWnd, WM_HIDE_SIDEBAR, 0, 0);  // request to hide
      } break;
    }
  }
  return ::CallNextHookEx(gHook, nCode, wParam, lParam);  // Call next hook in chain

}
