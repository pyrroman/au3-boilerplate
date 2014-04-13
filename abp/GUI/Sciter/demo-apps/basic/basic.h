
#if !defined(AFX_BASIC_H__735D9D00_0D61_471F_B9F5_BE1230A2FDBA__INCLUDED_)
#define AFX_BASIC_H__735D9D00_0D61_471F_B9F5_BE1230A2FDBA__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "resource.h"
#include "sciter-x.h"
#include "sciter-x-script.h"

extern HINSTANCE ghInstance;  // this instance

// basic_callback.cpp stuff
extern UINT CALLBACK BasicHostCallback( LPSCITER_CALLBACK_NOTIFICATION pns, LPVOID callbackParam );
extern UINT GetResource(LPCWSTR uri, /*out*/LPCBYTE& pb, /*out*/UINT& cb);



#endif // !defined(AFX_BASIC_H__735D9D00_0D61_471F_B9F5_BE1230A2FDBA__INCLUDED_)
