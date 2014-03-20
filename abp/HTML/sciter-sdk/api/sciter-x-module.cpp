#include "sciter-x.h"

/**
 * Template file. Sciter Extender Module shall include following functions:
 */


/** Each sciter extension module shall include external function 
 *  SciterInitModule with the following signature
 */

EXTERN_C BOOL WINAPI SciterInitModule( SciterDomApi* pdomapi, VOID* p1, VOID* p2 )
{
  sciter::dom::element::api(pdomapi);
  return TRUE;
}

/** Each sciter extension module shall include function 
 */
EXTERN_C BOOL WINAPI SciterBehaviorFactory( LPCSTR, HELEMENT, SciterDomApi::LPELEMENT_EVENT_PROC*, LPVOID* )
{
  return FALSE;
}
