// stdafx.h : include file for standard system include files,
//  or project specific include files that are used frequently, but
//      are changed infrequently
//

#if !defined(AFX_STDAFX_H__E3814BE7_526F_4B2F_A800_81817E5AD0E5__INCLUDED_)
#define AFX_STDAFX_H__E3814BE7_526F_4B2F_A800_81817E5AD0E5__INCLUDED_

// Change these values to use different versions
#define WINVER    0x0400
//#define _WIN32_WINNT  0x0400
#define _WIN32_IE 0x0400
#define _RICHEDIT_VER 0x0100

#include <atlbase.h>
#include <atlapp.h>

extern CAppModule _Module;

#define WM_COMMITLOG (WM_USER + 10501)

#include <atlwin.h>

#include <sciter-x.h>
#include <sciter-x-host-callback.h>

#if defined _M_IX86
  #pragma comment(linker, "/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='x86' publicKeyToken='6595b64144ccf1df' language='*'\"")
#elif defined _M_IA64
  #pragma comment(linker, "/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='ia64' publicKeyToken='6595b64144ccf1df' language='*'\"")
#elif defined _M_X64
  #pragma comment(linker, "/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='amd64' publicKeyToken='6595b64144ccf1df' language='*'\"")
#else
  #pragma comment(linker, "/manifestdependency:\"type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")
#endif

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__E3814BE7_526F_4B2F_A800_81817E5AD0E5__INCLUDED_)
