

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


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


/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 440
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __AxSciter_h__
#define __AxSciter_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IElements_FWD_DEFINED__
#define __IElements_FWD_DEFINED__
typedef interface IElements IElements;
#endif 	/* __IElements_FWD_DEFINED__ */


#ifndef __IElement_FWD_DEFINED__
#define __IElement_FWD_DEFINED__
typedef interface IElement IElement;
#endif 	/* __IElement_FWD_DEFINED__ */


#ifndef __ISciter_FWD_DEFINED__
#define __ISciter_FWD_DEFINED__
typedef interface ISciter ISciter;
#endif 	/* __ISciter_FWD_DEFINED__ */


#ifndef ___ISciterEvents_FWD_DEFINED__
#define ___ISciterEvents_FWD_DEFINED__
typedef interface _ISciterEvents _ISciterEvents;
#endif 	/* ___ISciterEvents_FWD_DEFINED__ */


#ifndef __Sciter_FWD_DEFINED__
#define __Sciter_FWD_DEFINED__

#ifdef __cplusplus
typedef class Sciter Sciter;
#else
typedef struct Sciter Sciter;
#endif /* __cplusplus */

#endif 	/* __Sciter_FWD_DEFINED__ */


#ifndef ___IElementEvents_FWD_DEFINED__
#define ___IElementEvents_FWD_DEFINED__
typedef interface _IElementEvents _IElementEvents;
#endif 	/* ___IElementEvents_FWD_DEFINED__ */


#ifndef __Element_FWD_DEFINED__
#define __Element_FWD_DEFINED__

#ifdef __cplusplus
typedef class Element Element;
#else
typedef struct Element Element;
#endif /* __cplusplus */

#endif 	/* __Element_FWD_DEFINED__ */


#ifndef __Elements_FWD_DEFINED__
#define __Elements_FWD_DEFINED__

#ifdef __cplusplus
typedef class Elements Elements;
#else
typedef struct Elements Elements;
#endif /* __cplusplus */

#endif 	/* __Elements_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

#ifdef __cplusplus
extern "C"{
#endif 

void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void * ); 


#ifndef __AxSciterLib_LIBRARY_DEFINED__
#define __AxSciterLib_LIBRARY_DEFINED__

/* library AxSciterLib */
/* [helpstring][version][uuid] */ 

typedef /* [public][public][public] */ 
enum __MIDL___MIDL_itf_AxSciter_0000_0001
    {	ContentBox	= 0,
	PaddingBox	= 0x10,
	BorderBox	= 0x20,
	MarginBox	= 0x30,
	BackImageArea	= 0x40,
	ForeImageArea	= 0x50,
	ScrollableArea	= 0x60
    } 	ElementBoxType;

typedef /* [public][public] */ 
enum __MIDL___MIDL_itf_AxSciter_0000_0002
    {	RootRelative	= 0x1,
	SelfRelative	= 0x2,
	ContainerRelative	= 0x3,
	ViewRelative	= 0x4
    } 	RelativeToType;

typedef /* [public][public][public] */ 
enum __MIDL___MIDL_itf_AxSciter_0000_0003
    {	DATA_HTML	= 0,
	DATA_IMAGE	= 1,
	DATA_STYLE	= 2,
	DATA_CURSOR	= 3,
	DATA_SCRIPT	= 4
    } 	ResourceType;

typedef /* [public] */ 
enum __MIDL___MIDL_itf_AxSciter_0000_0004
    {	MASK_BUBBLING	= 0,
	MASK_SINKING	= 0x8000,
	MASK_HANDLED	= 0x10000
    } 	PhaseMask;

typedef /* [public] */ 
enum __MIDL___MIDL_itf_AxSciter_0000_0005
    {	ME_MOUSE_ENTER	= 0,
	ME_MOUSE_LEAVE	= 1,
	ME_MOUSE_MOVE	= 2,
	ME_MOUSE_UP	= 3,
	ME_MOUSE_DOWN	= 4,
	ME_MOUSE_DCLICK	= 5,
	ME_MOUSE_WHEEL	= 6,
	ME_MOUSE_TICK	= 7,
	ME_MOUSE_IDLE	= 8,
	ME_DROP	= 9,
	ME_DRAG_ENTER	= 0xa,
	ME_DRAG_LEAVE	= 0xb,
	ME_DRAGGING	= 0x100
    } 	MouseEvents;

typedef /* [public] */ 
enum __MIDL___MIDL_itf_AxSciter_0000_0006
    {	BE_BUTTON_CLICK	= 0,
	BE_BUTTON_PRESS	= 1,
	BE_BUTTON_STATE_CHANGED	= 2,
	BE_EDIT_VALUE_CHANGING	= 3,
	BE_EDIT_VALUE_CHANGED	= 4,
	BE_SELECT_SELECTION_CHANGED	= 5,
	BE_SELECT_STATE_CHANGED	= 6,
	BE_POPUP_REQUEST	= 7,
	BE_POPUP_READY	= 8,
	BE_POPUP_DISMISSED	= 9,
	BE_MENU_ITEM_ACTIVE	= 0xa,
	BE_MENU_ITEM_CLICK	= 0xb,
	BE_CONTEXT_MENU_SETUP	= 0xf,
	BE_CONTEXT_MENU_REQUEST	= 0x10,
	BE_VISIUAL_STATUS_CHANGED	= 0x11,
	BE_HYPERLINK_CLICK	= 0x80,
	BE_TABLE_HEADER_CLICK	= BE_HYPERLINK_CLICK + 1,
	BE_TABLE_ROW_CLICK	= BE_TABLE_HEADER_CLICK + 1,
	BE_TABLE_ROW_DBL_CLICK	= BE_TABLE_ROW_CLICK + 1,
	BE_ELEMENT_COLLAPSED	= 0x90,
	BE_ELEMENT_EXPANDED	= BE_ELEMENT_COLLAPSED + 1,
	BE_ACTIVATE_CHILD	= BE_ELEMENT_EXPANDED + 1,
	BE_DO_SWITCH_TAB	= BE_ACTIVATE_CHILD,
	BE_INIT_DATA_VIEW	= BE_DO_SWITCH_TAB + 1,
	BE_ROWS_DATA_REQUEST	= BE_INIT_DATA_VIEW + 1,
	BE_UI_STATE_CHANGED	= BE_ROWS_DATA_REQUEST + 1,
	BE_FORM_SUBMIT	= BE_UI_STATE_CHANGED + 1,
	BE_FORM_RESET	= BE_FORM_SUBMIT + 1,
	BE_DOCUMENT_COMPLETE	= BE_FORM_RESET + 1,
	BE_HISTORY_PUSH	= BE_DOCUMENT_COMPLETE + 1,
	BE_HISTORY_DROP	= BE_HISTORY_PUSH + 1,
	BE_HISTORY_PRIOR	= BE_HISTORY_DROP + 1,
	BE_HISTORY_NEXT	= BE_HISTORY_PRIOR + 1,
	BE_HISTORY_STATE_CHANGED	= BE_HISTORY_NEXT + 1,
	BE_FIRST_APPLICATION_EVENT_CODE	= 0x100
    } 	BehaviorEvents;




EXTERN_C const IID LIBID_AxSciterLib;

#ifndef __IElements_INTERFACE_DEFINED__
#define __IElements_INTERFACE_DEFINED__

/* interface IElements */
/* [unique][helpstring][nonextensible][dual][uuid][object] */ 


EXTERN_C const IID IID_IElements;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("C7171909-9F92-48D7-8691-EFB3390DEE55")
    IElements : public IDispatch
    {
    public:
        virtual /* [restricted][helpstring][id] */ HRESULT STDMETHODCALLTYPE _NewEnum( 
            /* [retval][out] */ IUnknown **coll) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_Count( 
            /* [retval][out] */ LONG *pVal) = 0;
        
        virtual /* [defaultcollelem][helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_Item( 
            /* [in] */ LONG index,
            /* [retval][out] */ IElement **el) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IElementsVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IElements * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IElements * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IElements * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IElements * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IElements * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IElements * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IElements * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        /* [restricted][helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *_NewEnum )( 
            IElements * This,
            /* [retval][out] */ IUnknown **coll);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_Count )( 
            IElements * This,
            /* [retval][out] */ LONG *pVal);
        
        /* [defaultcollelem][helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_Item )( 
            IElements * This,
            /* [in] */ LONG index,
            /* [retval][out] */ IElement **el);
        
        END_INTERFACE
    } IElementsVtbl;

    interface IElements
    {
        CONST_VTBL struct IElementsVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IElements_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IElements_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IElements_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IElements_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IElements_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IElements_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IElements_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define IElements__NewEnum(This,coll)	\
    (This)->lpVtbl -> _NewEnum(This,coll)

#define IElements_get_Count(This,pVal)	\
    (This)->lpVtbl -> get_Count(This,pVal)

#define IElements_get_Item(This,index,el)	\
    (This)->lpVtbl -> get_Item(This,index,el)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [restricted][helpstring][id] */ HRESULT STDMETHODCALLTYPE IElements__NewEnum_Proxy( 
    IElements * This,
    /* [retval][out] */ IUnknown **coll);


void __RPC_STUB IElements__NewEnum_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IElements_get_Count_Proxy( 
    IElements * This,
    /* [retval][out] */ LONG *pVal);


void __RPC_STUB IElements_get_Count_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [defaultcollelem][helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IElements_get_Item_Proxy( 
    IElements * This,
    /* [in] */ LONG index,
    /* [retval][out] */ IElement **el);


void __RPC_STUB IElements_get_Item_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IElements_INTERFACE_DEFINED__ */


#ifndef __IElement_INTERFACE_DEFINED__
#define __IElement_INTERFACE_DEFINED__

/* interface IElement */
/* [unique][helpstring][nonextensible][dual][uuid][object] */ 


EXTERN_C const IID IID_IElement;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("645B0717-C0AB-424D-B513-F083AD486BF1")
    IElement : public IDispatch
    {
    public:
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_Tag( 
            /* [retval][out] */ BSTR *pVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_Value( 
            /* [retval][out] */ VARIANT *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_Value( 
            /* [in] */ VARIANT newVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Select( 
            /* [in] */ BSTR cssSelector,
            /* [retval][out] */ IElement **el) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE SelectAll( 
            /* [in] */ BSTR cssSelector,
            /* [retval][out] */ IElements **coll) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_Attr( 
            BSTR name,
            /* [retval][out] */ VARIANT *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_Attr( 
            BSTR name,
            /* [in] */ VARIANT newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_StyleAttr( 
            BSTR name,
            /* [retval][out] */ VARIANT *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_StyleAttr( 
            BSTR name,
            /* [in] */ VARIANT newVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Position( 
            /* [out] */ LONG *x,
            /* [out] */ LONG *y,
            /* [in] */ ElementBoxType ofWhat,
            /* [in] */ RelativeToType relTo) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Dimension( 
            /* [out] */ LONG *width,
            /* [out] */ LONG *height,
            ElementBoxType ofWhat) = 0;
        
        virtual /* [vararg][helpstring][id] */ HRESULT STDMETHODCALLTYPE Call( 
            /* [in] */ BSTR methodName,
            /* [in] */ SAFEARRAY * *params,
            /* [retval][out] */ VARIANT *rv) = 0;
        
        virtual /* [nonbrowsable][helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_HELEMENT( 
            /* [retval][out] */ LONG *pVal) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IElementVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IElement * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IElement * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IElement * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IElement * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IElement * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IElement * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IElement * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_Tag )( 
            IElement * This,
            /* [retval][out] */ BSTR *pVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_Value )( 
            IElement * This,
            /* [retval][out] */ VARIANT *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_Value )( 
            IElement * This,
            /* [in] */ VARIANT newVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Select )( 
            IElement * This,
            /* [in] */ BSTR cssSelector,
            /* [retval][out] */ IElement **el);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *SelectAll )( 
            IElement * This,
            /* [in] */ BSTR cssSelector,
            /* [retval][out] */ IElements **coll);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_Attr )( 
            IElement * This,
            BSTR name,
            /* [retval][out] */ VARIANT *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_Attr )( 
            IElement * This,
            BSTR name,
            /* [in] */ VARIANT newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_StyleAttr )( 
            IElement * This,
            BSTR name,
            /* [retval][out] */ VARIANT *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_StyleAttr )( 
            IElement * This,
            BSTR name,
            /* [in] */ VARIANT newVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Position )( 
            IElement * This,
            /* [out] */ LONG *x,
            /* [out] */ LONG *y,
            /* [in] */ ElementBoxType ofWhat,
            /* [in] */ RelativeToType relTo);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Dimension )( 
            IElement * This,
            /* [out] */ LONG *width,
            /* [out] */ LONG *height,
            ElementBoxType ofWhat);
        
        /* [vararg][helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Call )( 
            IElement * This,
            /* [in] */ BSTR methodName,
            /* [in] */ SAFEARRAY * *params,
            /* [retval][out] */ VARIANT *rv);
        
        /* [nonbrowsable][helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_HELEMENT )( 
            IElement * This,
            /* [retval][out] */ LONG *pVal);
        
        END_INTERFACE
    } IElementVtbl;

    interface IElement
    {
        CONST_VTBL struct IElementVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IElement_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IElement_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IElement_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IElement_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IElement_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IElement_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IElement_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define IElement_get_Tag(This,pVal)	\
    (This)->lpVtbl -> get_Tag(This,pVal)

#define IElement_get_Value(This,pVal)	\
    (This)->lpVtbl -> get_Value(This,pVal)

#define IElement_put_Value(This,newVal)	\
    (This)->lpVtbl -> put_Value(This,newVal)

#define IElement_Select(This,cssSelector,el)	\
    (This)->lpVtbl -> Select(This,cssSelector,el)

#define IElement_SelectAll(This,cssSelector,coll)	\
    (This)->lpVtbl -> SelectAll(This,cssSelector,coll)

#define IElement_get_Attr(This,name,pVal)	\
    (This)->lpVtbl -> get_Attr(This,name,pVal)

#define IElement_put_Attr(This,name,newVal)	\
    (This)->lpVtbl -> put_Attr(This,name,newVal)

#define IElement_get_StyleAttr(This,name,pVal)	\
    (This)->lpVtbl -> get_StyleAttr(This,name,pVal)

#define IElement_put_StyleAttr(This,name,newVal)	\
    (This)->lpVtbl -> put_StyleAttr(This,name,newVal)

#define IElement_Position(This,x,y,ofWhat,relTo)	\
    (This)->lpVtbl -> Position(This,x,y,ofWhat,relTo)

#define IElement_Dimension(This,width,height,ofWhat)	\
    (This)->lpVtbl -> Dimension(This,width,height,ofWhat)

#define IElement_Call(This,methodName,params,rv)	\
    (This)->lpVtbl -> Call(This,methodName,params,rv)

#define IElement_get_HELEMENT(This,pVal)	\
    (This)->lpVtbl -> get_HELEMENT(This,pVal)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IElement_get_Tag_Proxy( 
    IElement * This,
    /* [retval][out] */ BSTR *pVal);


void __RPC_STUB IElement_get_Tag_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IElement_get_Value_Proxy( 
    IElement * This,
    /* [retval][out] */ VARIANT *pVal);


void __RPC_STUB IElement_get_Value_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IElement_put_Value_Proxy( 
    IElement * This,
    /* [in] */ VARIANT newVal);


void __RPC_STUB IElement_put_Value_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IElement_Select_Proxy( 
    IElement * This,
    /* [in] */ BSTR cssSelector,
    /* [retval][out] */ IElement **el);


void __RPC_STUB IElement_Select_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IElement_SelectAll_Proxy( 
    IElement * This,
    /* [in] */ BSTR cssSelector,
    /* [retval][out] */ IElements **coll);


void __RPC_STUB IElement_SelectAll_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IElement_get_Attr_Proxy( 
    IElement * This,
    BSTR name,
    /* [retval][out] */ VARIANT *pVal);


void __RPC_STUB IElement_get_Attr_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IElement_put_Attr_Proxy( 
    IElement * This,
    BSTR name,
    /* [in] */ VARIANT newVal);


void __RPC_STUB IElement_put_Attr_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IElement_get_StyleAttr_Proxy( 
    IElement * This,
    BSTR name,
    /* [retval][out] */ VARIANT *pVal);


void __RPC_STUB IElement_get_StyleAttr_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IElement_put_StyleAttr_Proxy( 
    IElement * This,
    BSTR name,
    /* [in] */ VARIANT newVal);


void __RPC_STUB IElement_put_StyleAttr_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IElement_Position_Proxy( 
    IElement * This,
    /* [out] */ LONG *x,
    /* [out] */ LONG *y,
    /* [in] */ ElementBoxType ofWhat,
    /* [in] */ RelativeToType relTo);


void __RPC_STUB IElement_Position_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IElement_Dimension_Proxy( 
    IElement * This,
    /* [out] */ LONG *width,
    /* [out] */ LONG *height,
    ElementBoxType ofWhat);


void __RPC_STUB IElement_Dimension_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [vararg][helpstring][id] */ HRESULT STDMETHODCALLTYPE IElement_Call_Proxy( 
    IElement * This,
    /* [in] */ BSTR methodName,
    /* [in] */ SAFEARRAY * *params,
    /* [retval][out] */ VARIANT *rv);


void __RPC_STUB IElement_Call_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [nonbrowsable][helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IElement_get_HELEMENT_Proxy( 
    IElement * This,
    /* [retval][out] */ LONG *pVal);


void __RPC_STUB IElement_get_HELEMENT_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IElement_INTERFACE_DEFINED__ */


#ifndef __ISciter_INTERFACE_DEFINED__
#define __ISciter_INTERFACE_DEFINED__

/* interface ISciter */
/* [unique][helpstring][nonextensible][dual][uuid][object] */ 


EXTERN_C const IID IID_ISciter;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("FA63A755-C7B3-4DB6-833F-3D5FE102495E")
    ISciter : public IDispatch
    {
    public:
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE LoadHtml( 
            /* [in] */ BSTR html,
            /* [in] */ BSTR baseUrl) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE LoadUrl( 
            /* [in] */ BSTR urlToLoad) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_Root( 
            /* [retval][out] */ IElement **pVal) = 0;
        
        virtual /* [vararg][helpstring][id] */ HRESULT STDMETHODCALLTYPE Call( 
            /* [in] */ BSTR name,
            /* [in] */ SAFEARRAY * *params,
            /* [retval][out] */ VARIANT *rv) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Eval( 
            /* [in] */ BSTR script,
            /* [retval][out] */ VARIANT *rv) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE DataReady( 
            /* [in] */ LONG requestId,
            /* [in] */ BYTE *data,
            /* [in] */ LONG dataLength) = 0;
        
        virtual /* [nonbrowsable][helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_Methods( 
            /* [retval][out] */ IDispatch **pVal) = 0;
        
        virtual /* [nonbrowsable][helpstring][id][propputref] */ HRESULT STDMETHODCALLTYPE putref_Methods( 
            /* [in] */ IDispatch *newVal) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct ISciterVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            ISciter * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            ISciter * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            ISciter * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            ISciter * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            ISciter * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            ISciter * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            ISciter * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *LoadHtml )( 
            ISciter * This,
            /* [in] */ BSTR html,
            /* [in] */ BSTR baseUrl);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *LoadUrl )( 
            ISciter * This,
            /* [in] */ BSTR urlToLoad);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_Root )( 
            ISciter * This,
            /* [retval][out] */ IElement **pVal);
        
        /* [vararg][helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Call )( 
            ISciter * This,
            /* [in] */ BSTR name,
            /* [in] */ SAFEARRAY * *params,
            /* [retval][out] */ VARIANT *rv);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Eval )( 
            ISciter * This,
            /* [in] */ BSTR script,
            /* [retval][out] */ VARIANT *rv);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *DataReady )( 
            ISciter * This,
            /* [in] */ LONG requestId,
            /* [in] */ BYTE *data,
            /* [in] */ LONG dataLength);
        
        /* [nonbrowsable][helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_Methods )( 
            ISciter * This,
            /* [retval][out] */ IDispatch **pVal);
        
        /* [nonbrowsable][helpstring][id][propputref] */ HRESULT ( STDMETHODCALLTYPE *putref_Methods )( 
            ISciter * This,
            /* [in] */ IDispatch *newVal);
        
        END_INTERFACE
    } ISciterVtbl;

    interface ISciter
    {
        CONST_VTBL struct ISciterVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ISciter_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ISciter_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ISciter_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ISciter_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define ISciter_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define ISciter_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define ISciter_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define ISciter_LoadHtml(This,html,baseUrl)	\
    (This)->lpVtbl -> LoadHtml(This,html,baseUrl)

#define ISciter_LoadUrl(This,urlToLoad)	\
    (This)->lpVtbl -> LoadUrl(This,urlToLoad)

#define ISciter_get_Root(This,pVal)	\
    (This)->lpVtbl -> get_Root(This,pVal)

#define ISciter_Call(This,name,params,rv)	\
    (This)->lpVtbl -> Call(This,name,params,rv)

#define ISciter_Eval(This,script,rv)	\
    (This)->lpVtbl -> Eval(This,script,rv)

#define ISciter_DataReady(This,requestId,data,dataLength)	\
    (This)->lpVtbl -> DataReady(This,requestId,data,dataLength)

#define ISciter_get_Methods(This,pVal)	\
    (This)->lpVtbl -> get_Methods(This,pVal)

#define ISciter_putref_Methods(This,newVal)	\
    (This)->lpVtbl -> putref_Methods(This,newVal)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE ISciter_LoadHtml_Proxy( 
    ISciter * This,
    /* [in] */ BSTR html,
    /* [in] */ BSTR baseUrl);


void __RPC_STUB ISciter_LoadHtml_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE ISciter_LoadUrl_Proxy( 
    ISciter * This,
    /* [in] */ BSTR urlToLoad);


void __RPC_STUB ISciter_LoadUrl_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISciter_get_Root_Proxy( 
    ISciter * This,
    /* [retval][out] */ IElement **pVal);


void __RPC_STUB ISciter_get_Root_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [vararg][helpstring][id] */ HRESULT STDMETHODCALLTYPE ISciter_Call_Proxy( 
    ISciter * This,
    /* [in] */ BSTR name,
    /* [in] */ SAFEARRAY * *params,
    /* [retval][out] */ VARIANT *rv);


void __RPC_STUB ISciter_Call_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE ISciter_Eval_Proxy( 
    ISciter * This,
    /* [in] */ BSTR script,
    /* [retval][out] */ VARIANT *rv);


void __RPC_STUB ISciter_Eval_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE ISciter_DataReady_Proxy( 
    ISciter * This,
    /* [in] */ LONG requestId,
    /* [in] */ BYTE *data,
    /* [in] */ LONG dataLength);


void __RPC_STUB ISciter_DataReady_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [nonbrowsable][helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISciter_get_Methods_Proxy( 
    ISciter * This,
    /* [retval][out] */ IDispatch **pVal);


void __RPC_STUB ISciter_get_Methods_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [nonbrowsable][helpstring][id][propputref] */ HRESULT STDMETHODCALLTYPE ISciter_putref_Methods_Proxy( 
    ISciter * This,
    /* [in] */ IDispatch *newVal);


void __RPC_STUB ISciter_putref_Methods_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __ISciter_INTERFACE_DEFINED__ */


#ifndef ___ISciterEvents_DISPINTERFACE_DEFINED__
#define ___ISciterEvents_DISPINTERFACE_DEFINED__

/* dispinterface _ISciterEvents */
/* [helpstring][uuid] */ 


EXTERN_C const IID DIID__ISciterEvents;

#if defined(__cplusplus) && !defined(CINTERFACE)

    MIDL_INTERFACE("ED2316A7-3EB2-4C80-9146-600B408B08D8")
    _ISciterEvents : public IDispatch
    {
    };
    
#else 	/* C style interface */

    typedef struct _ISciterEventsVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            _ISciterEvents * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            _ISciterEvents * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            _ISciterEvents * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            _ISciterEvents * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            _ISciterEvents * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            _ISciterEvents * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            _ISciterEvents * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        END_INTERFACE
    } _ISciterEventsVtbl;

    interface _ISciterEvents
    {
        CONST_VTBL struct _ISciterEventsVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define _ISciterEvents_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define _ISciterEvents_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define _ISciterEvents_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define _ISciterEvents_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define _ISciterEvents_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define _ISciterEvents_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define _ISciterEvents_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)

#endif /* COBJMACROS */


#endif 	/* C style interface */


#endif 	/* ___ISciterEvents_DISPINTERFACE_DEFINED__ */


EXTERN_C const CLSID CLSID_Sciter;

#ifdef __cplusplus

class DECLSPEC_UUID("99829A7E-007E-4F60-AC36-31B646896593")
Sciter;
#endif

#ifndef ___IElementEvents_DISPINTERFACE_DEFINED__
#define ___IElementEvents_DISPINTERFACE_DEFINED__

/* dispinterface _IElementEvents */
/* [helpstring][uuid] */ 


EXTERN_C const IID DIID__IElementEvents;

#if defined(__cplusplus) && !defined(CINTERFACE)

    MIDL_INTERFACE("2A8AAFD6-6E87-4967-BF6D-C3F6BB9B3BD1")
    _IElementEvents : public IDispatch
    {
    };
    
#else 	/* C style interface */

    typedef struct _IElementEventsVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            _IElementEvents * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            _IElementEvents * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            _IElementEvents * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            _IElementEvents * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            _IElementEvents * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            _IElementEvents * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            _IElementEvents * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        END_INTERFACE
    } _IElementEventsVtbl;

    interface _IElementEvents
    {
        CONST_VTBL struct _IElementEventsVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define _IElementEvents_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define _IElementEvents_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define _IElementEvents_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define _IElementEvents_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define _IElementEvents_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define _IElementEvents_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define _IElementEvents_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)

#endif /* COBJMACROS */


#endif 	/* C style interface */


#endif 	/* ___IElementEvents_DISPINTERFACE_DEFINED__ */


EXTERN_C const CLSID CLSID_Element;

#ifdef __cplusplus

class DECLSPEC_UUID("53FB239D-7857-4F0D-9083-871D8C0EAE3A")
Element;
#endif

EXTERN_C const CLSID CLSID_Elements;

#ifdef __cplusplus

class DECLSPEC_UUID("B1C8635C-12B4-40F7-8038-6134FC5D398F")
Elements;
#endif
#endif /* __AxSciterLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


