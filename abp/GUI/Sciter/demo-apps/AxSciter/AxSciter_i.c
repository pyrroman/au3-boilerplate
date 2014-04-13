

/* this ALWAYS GENERATED file contains the IIDs and CLSIDs */

/* link this file in with the server and any clients */


 /* File created by MIDL compiler version 6.00.0366 */
/* at Thu Mar 07 18:41:41 2013
 */
/* Compiler settings for .\AxSciter.idl:
    Oicf, W1, Zp8, env=Win32 (32b run)
    protocol : dce , ms_ext, c_ext
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
//@@MIDL_FILE_HEADING(  )

#pragma warning( disable: 4049 )  /* more than 64k source lines */


#ifdef __cplusplus
extern "C"{
#endif 


#include <rpc.h>
#include <rpcndr.h>

#ifdef _MIDL_USE_GUIDDEF_

#ifndef INITGUID
#define INITGUID
#include <guiddef.h>
#undef INITGUID
#else
#include <guiddef.h>
#endif

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
        DEFINE_GUID(name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8)

#else // !_MIDL_USE_GUIDDEF_

#ifndef __IID_DEFINED__
#define __IID_DEFINED__

typedef struct _IID
{
    unsigned long x;
    unsigned short s1;
    unsigned short s2;
    unsigned char  c[8];
} IID;

#endif // __IID_DEFINED__

#ifndef CLSID_DEFINED
#define CLSID_DEFINED
typedef IID CLSID;
#endif // CLSID_DEFINED

#define MIDL_DEFINE_GUID(type,name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) \
        const type name = {l,w1,w2,{b1,b2,b3,b4,b5,b6,b7,b8}}

#endif !_MIDL_USE_GUIDDEF_

MIDL_DEFINE_GUID(IID, LIBID_AxSciterLib,0x25D9681B,0x32F2,0x44C9,0xB9,0x4F,0x5E,0x82,0xE7,0xED,0x0C,0x75);


MIDL_DEFINE_GUID(IID, IID_IElements,0xC7171909,0x9F92,0x48D7,0x86,0x91,0xEF,0xB3,0x39,0x0D,0xEE,0x55);


MIDL_DEFINE_GUID(IID, IID_IElement,0x645B0717,0xC0AB,0x424D,0xB5,0x13,0xF0,0x83,0xAD,0x48,0x6B,0xF1);


MIDL_DEFINE_GUID(IID, IID_ISciter,0xFA63A755,0xC7B3,0x4DB6,0x83,0x3F,0x3D,0x5F,0xE1,0x02,0x49,0x5E);


MIDL_DEFINE_GUID(IID, DIID__ISciterEvents,0xED2316A7,0x3EB2,0x4C80,0x91,0x46,0x60,0x0B,0x40,0x8B,0x08,0xD8);


MIDL_DEFINE_GUID(CLSID, CLSID_Sciter,0x99829A7E,0x007E,0x4F60,0xAC,0x36,0x31,0xB6,0x46,0x89,0x65,0x93);


MIDL_DEFINE_GUID(IID, DIID__IElementEvents,0x2A8AAFD6,0x6E87,0x4967,0xBF,0x6D,0xC3,0xF6,0xBB,0x9B,0x3B,0xD1);


MIDL_DEFINE_GUID(CLSID, CLSID_Element,0x53FB239D,0x7857,0x4F0D,0x90,0x83,0x87,0x1D,0x8C,0x0E,0xAE,0x3A);


MIDL_DEFINE_GUID(CLSID, CLSID_Elements,0xB1C8635C,0x12B4,0x40F7,0x80,0x38,0x61,0x34,0xFC,0x5D,0x39,0x8F);

#undef MIDL_DEFINE_GUID

#ifdef __cplusplus
}
#endif



