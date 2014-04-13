// Sciter.h : Declaration of the CSciter
#pragma once
#include "resource.h"       // main symbols
#include <atlctl.h>
#include <atlcomcli.h>
#include "AxSciter.h"
#include "_ISciterEvents_CP.h"
#include "comutil.h"
#include "sciter-x.h"
#include "sciter-x-host-callback.h"


#if defined(_WIN32_WCE) && !defined(_CE_DCOM) && !defined(_CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA)
#error "Single-threaded COM objects are not properly supported on Windows CE platform, such as the Windows Mobile platforms that do not include full DCOM support. Define _CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA to force ATL to support creating single-thread COM object's and allow use of it's single-threaded COM object implementations. The threading model in your rgs file was set to 'Free' as that is the only threading model supported in non DCOM Windows CE platforms."
#endif

extern HINSTANCE ghInstance;

#define CHAIN_TO_SCITER() \
    { \
        BOOL bHandled = FALSE; \
        lResult = ::SciterProcND(hWnd,uMsg, wParam, lParam, &bHandled); \
        if(bHandled) return TRUE; \
    }


// CSciter
class ATL_NO_VTABLE CSciter :
	public CComObjectRootEx<CComSingleThreadModel>,
	public IDispatchImpl<ISciter, &IID_ISciter, &LIBID_AxSciterLib, /*wMajor =*/ 1, /*wMinor =*/ 0>,
	public IPersistStreamInitImpl<CSciter>,
	public IOleControlImpl<CSciter>,
	public IOleObjectImpl<CSciter>,
	public IOleInPlaceActiveObjectImpl<CSciter>,
	public IViewObjectExImpl<CSciter>,
	public IOleInPlaceObjectWindowlessImpl<CSciter>,
	public ISupportErrorInfo,
	public IConnectionPointContainerImpl<CSciter>,
	public CProxy_ISciterEvents<CSciter>,
	public IPersistStorageImpl<CSciter>,
	public ISpecifyPropertyPagesImpl<CSciter>,
	public IQuickActivateImpl<CSciter>,
#ifndef _WIN32_WCE
	public IDataObjectImpl<CSciter>,
#endif
	public IProvideClassInfo2Impl<&CLSID_Sciter, &__uuidof(_ISciterEvents), &LIBID_AxSciterLib>,
#ifdef _WIN32_WCE // IObjectSafety is required on Windows CE for the control to be loaded correctly
	public IObjectSafetyImpl<CSciter, INTERFACESAFE_FOR_UNTRUSTED_CALLER>,
#endif
	public CComCoClass<CSciter, &CLSID_Sciter>,
	public CComControl<CSciter>,
  public sciter::notification_handler<CSciter>,
  public sciter::event_handler
{
  CComPtr<IDispatch> m_methods;
  bool m_isInsideOnLoadData;
public:


	CSciter()
	{
    m_isInsideOnLoadData = false;
    m_bWindowOnly = TRUE;
	}

  HWND      get_hwnd() { return m_hWnd; }
  HINSTANCE get_resource_instance() { return ghInstance; }

DECLARE_OLEMISC_STATUS(OLEMISC_RECOMPOSEONRESIZE |
	OLEMISC_CANTLINKINSIDE |
	OLEMISC_INSIDEOUT |
	OLEMISC_ACTIVATEWHENVISIBLE |
	OLEMISC_SETCLIENTSITEFIRST
)

DECLARE_REGISTRY_RESOURCEID(IDR_SCITER)


BEGIN_COM_MAP(CSciter)
	COM_INTERFACE_ENTRY(ISciter)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(IViewObjectEx)
	COM_INTERFACE_ENTRY(IViewObject2)
	COM_INTERFACE_ENTRY(IViewObject)
	COM_INTERFACE_ENTRY(IOleInPlaceObjectWindowless)
	COM_INTERFACE_ENTRY(IOleInPlaceObject)
	COM_INTERFACE_ENTRY2(IOleWindow, IOleInPlaceObjectWindowless)
	COM_INTERFACE_ENTRY(IOleInPlaceActiveObject)
	COM_INTERFACE_ENTRY(IOleControl)
	COM_INTERFACE_ENTRY(IOleObject)
	COM_INTERFACE_ENTRY(IPersistStreamInit)
	COM_INTERFACE_ENTRY2(IPersist, IPersistStreamInit)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IConnectionPointContainer)
	COM_INTERFACE_ENTRY(ISpecifyPropertyPages)
	COM_INTERFACE_ENTRY(IQuickActivate)
	COM_INTERFACE_ENTRY(IPersistStorage)
#ifndef _WIN32_WCE
	COM_INTERFACE_ENTRY(IDataObject)
#endif
	COM_INTERFACE_ENTRY(IProvideClassInfo)
	COM_INTERFACE_ENTRY(IProvideClassInfo2)
#ifdef _WIN32_WCE // IObjectSafety is required on Windows CE for the control to be loaded correctly
	COM_INTERFACE_ENTRY_IID(IID_IObjectSafety, IObjectSafety)
#endif
END_COM_MAP()

BEGIN_PROP_MAP(CSciter)
	PROP_DATA_ENTRY("_cx", m_sizeExtent.cx, VT_UI4)
	PROP_DATA_ENTRY("_cy", m_sizeExtent.cy, VT_UI4)
	// Example entries
	// PROP_ENTRY("Property Description", dispid, clsid)
	// PROP_PAGE(CLSID_StockColorPage)
END_PROP_MAP()

BEGIN_CONNECTION_POINT_MAP(CSciter)
	CONNECTION_POINT_ENTRY(__uuidof(_ISciterEvents))
END_CONNECTION_POINT_MAP()

BEGIN_MSG_MAP(CSciter)
  CHAIN_TO_SCITER()
  MESSAGE_HANDLER(WM_CREATE, OnCreate)
	CHAIN_MSG_MAP(CComControl<CSciter>)
	DEFAULT_REFLECTION_HANDLER()
END_MSG_MAP()
// Handler prototypes:
//  LRESULT MessageHandler(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
//  LRESULT CommandHandler(WORD wNotifyCode, WORD wID, HWND hWndCtl, BOOL& bHandled);
//  LRESULT NotifyHandler(int idCtrl, LPNMHDR pnmh, BOOL& bHandled);

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid)
	{
		static const IID* arr[] =
		{
			&IID_ISciter,
		};

		for (int i=0; i<sizeof(arr)/sizeof(arr[0]); i++)
		{
			if (InlineIsEqualGUID(*arr[i], riid))
				return S_OK;
		}
		return S_FALSE;
	}

// IViewObjectEx
	DECLARE_VIEW_STATUS(VIEWSTATUS_SOLIDBKGND | VIEWSTATUS_OPAQUE)

// ISciter
public:
/*		HRESULT OnDraw(ATL_DRAWINFO& di)
		{
		RECT& rc = *(RECT*)di.prcBounds;
		// Set Clip region to the rectangle specified by di.prcBounds
		HRGN hRgnOld = NULL;
		if (GetClipRgn(di.hdcDraw, hRgnOld) != 1)
			hRgnOld = NULL;
		bool bSelectOldRgn = false;

		HRGN hRgnNew = CreateRectRgn(rc.left, rc.top, rc.right, rc.bottom);

		if (hRgnNew != NULL)
		{
			bSelectOldRgn = (SelectClipRgn(di.hdcDraw, hRgnNew) != ERROR);
		}

		Rectangle(di.hdcDraw, rc.left, rc.top, rc.right, rc.bottom);
		SetTextAlign(di.hdcDraw, TA_CENTER|TA_BASELINE);
		LPCTSTR pszText = _T("ATL 8.0 : Sciter");
#ifndef _WIN32_WCE
		TextOut(di.hdcDraw,
			(rc.left + rc.right) / 2,
			(rc.top + rc.bottom) / 2,
			pszText,
			lstrlen(pszText));
#else
		ExtTextOut(di.hdcDraw,
			(rc.left + rc.right) / 2,
			(rc.top + rc.bottom) / 2,
			ETO_OPAQUE,
			NULL,
			pszText,
			ATL::lstrlen(pszText),
			NULL);
#endif

		if (bSelectOldRgn)
			SelectClipRgn(di.hdcDraw, hRgnOld);

		return S_OK;
	} */

  LRESULT OnCreate(UINT /*uMsg*/, WPARAM /*wParam*/, LPARAM /*lParam*/, BOOL& /*bHandled*/)
  {
    setup_callback();
    sciter::attach_dom_event_handler(m_hWnd, this); //  attach this sciter::event_handler
    load_file(L"res:facade.htm");
    return 0;
  }

  virtual LRESULT on_callback_host(LPSCN_CALLBACK_HOST pnmld);
  virtual LRESULT on_load_data(LPSCN_LOAD_DATA pnmld);
  virtual LRESULT on_data_loaded(LPSCN_DATA_LOADED pnmld);

  // event_handler
  virtual bool on_script_call(HELEMENT he, LPCSTR name, UINT argc, json::value* argv, json::value& retval);

	DECLARE_PROTECT_FINAL_CONSTRUCT()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
	}


  STDMETHOD(LoadHtml)(BSTR html, BSTR baseUrl);
  STDMETHOD(LoadUrl)(BSTR urlToLoad);
  STDMETHOD(get_Root)(IElement** pVal);
  STDMETHOD(Call)(BSTR name, SAFEARRAY ** params, VARIANT* rv);
  STDMETHOD(Eval)(BSTR script, VARIANT* rv);
  STDMETHOD(DataReady)(LONG requestId, BYTE* data, LONG dataLength);
  STDMETHOD(get_Methods)(IDispatch** pVal);
  STDMETHOD(putref_Methods)(IDispatch* newVal);
};

OBJECT_ENTRY_AUTO(__uuidof(Sciter), CSciter)
