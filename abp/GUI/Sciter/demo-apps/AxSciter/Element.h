// Element.h : Declaration of the CElement

#pragma once
#include "resource.h"       // main symbols

#include "AxSciter.h"
#include "_IElementEvents_CP.h"
#include "_ISciterEvents_CP.H"


#if defined(_WIN32_WCE) && !defined(_CE_DCOM) && !defined(_CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA)
#error "Single-threaded COM objects are not properly supported on Windows CE platform, such as the Windows Mobile platforms that do not include full DCOM support. Define _CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA to force ATL to support creating single-thread COM object's and allow use of it's single-threaded COM object implementations. The threading model in your rgs file was set to 'Free' as that is the only threading model supported in non DCOM Windows CE platforms."
#endif

using namespace sciter;


// CElement

class ATL_NO_VTABLE CElement 
  : public CComObjectRootEx<CComSingleThreadModel>
	, public CComCoClass<CElement, &CLSID_Element>
	, public IConnectionPointContainerImpl<CElement>
	, public CProxy_IElementEvents<CElement>
	, public IDispatchImpl<IElement, &IID_IElement, &LIBID_AxSciterLib, /*wMajor =*/ 1, /*wMinor =*/ 0>
  , public sciter::event_handler,
  public CProxy_ISciterEvents<CElement>
{
  dom::element self;
  bool         connected;
public:
  CElement(): connected(false)
	{
	}
  ~CElement() 
  { 
    if(connected && self.is_valid()) 
      self.detach_event_handler(this); 
  }

  static HRESULT create(HELEMENT he, IElement** iface)  
  {
    CComObject<CElement>* pElement; 
    HRESULT hr = CComObject<CElement>::CreateInstance(&pElement);
    if (SUCCEEDED(hr) && pElement)
    {   
      pElement->AddRef();
      pElement->self = he;
      pElement->QueryInterface(IID_IElement, reinterpret_cast<void**>(iface));
      pElement->Release();
    }
    return hr;
  }

  STDMETHOD(FindConnectionPoint)(REFIID riid, IConnectionPoint** ppCP)
  {
    HRESULT hr = IConnectionPointContainerImpl<CElement>::FindConnectionPoint(riid, ppCP);
    if(SUCCEEDED(hr))
    {
      if(!connected && self.is_valid())
      {
        connected = true;
        self.attach_event_handler(this );
      }
    }
    return hr;
  }



DECLARE_REGISTRY_RESOURCEID(IDR_ELEMENT)


BEGIN_COM_MAP(CElement)
	COM_INTERFACE_ENTRY(IElement)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(IConnectionPointContainer)
END_COM_MAP()

BEGIN_CONNECTION_POINT_MAP(CElement)
  CONNECTION_POINT_ENTRY(__uuidof(_ISciterEvents))
  CONNECTION_POINT_ENTRY(__uuidof(_IElementEvents))
END_CONNECTION_POINT_MAP()


	DECLARE_PROTECT_FINAL_CONSTRUCT()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
	}

  // htmlayout::event_handler events
  virtual bool on_mouse  (HELEMENT he, HELEMENT target, UINT event_type, POINT pt, UINT mouseButtons, UINT keyboardStates ) 
  { 
    if(!connected)
      return FALSE; 
    IElement* pTarget = 0;
    HRESULT hr = create(target,&pTarget);
    if( FAILED(hr) )
      return false;
    VARIANT_BOOL handled = 0;
    hr = this->Fire_OnMouse(pTarget, event_type, pt.x, pt.y, mouseButtons, keyboardStates, &handled );
    pTarget->Release();
    if( SUCCEEDED(hr) && handled )
      return TRUE;
    return FALSE; 
  }

  virtual bool on_key    (HELEMENT he, HELEMENT target, UINT event_type, UINT code, UINT keyboardStates ) 
  { 
    if(!connected)
      return FALSE; 
    IElement* pTarget = 0;
    HRESULT hr = create(target,&pTarget);
    if( FAILED(hr) )
      return false;
    VARIANT_BOOL handled = 0;
    hr = Fire_OnKey(pTarget, event_type, code, keyboardStates, &handled );
    pTarget->Release();
    if( SUCCEEDED(hr) && handled )
      return TRUE;
    return FALSE; 
  }

  virtual bool on_focus  (HELEMENT he, HELEMENT target, UINT event_type )
  { 
    if(!connected)
      return FALSE; 
    IElement* pTarget = 0;
    HRESULT hr = create(target,&pTarget);
    if( FAILED(hr) )
      return false;
    VARIANT_BOOL handled = 0;
    hr = Fire_OnFocus(pTarget, event_type, &handled );
    pTarget->Release();
    if( SUCCEEDED(hr) && handled )
      return TRUE;
    return FALSE; 
  }

  virtual bool on_timer  (HELEMENT he, LONG extTimerId ) 
  {
    if(!connected)
      return FALSE; 
    VARIANT_BOOL handled = 0;
    HRESULT hr = Fire_OnTimer(extTimerId, &handled );
    if( SUCCEEDED(hr) && handled )
      return TRUE;
    return FALSE; 
  }

  virtual bool handle_event (HELEMENT he, BEHAVIOR_EVENT_PARAMS& params )
  {
    if(!connected)
      return FALSE; 
    IElement* pTarget = 0;
    HRESULT hr = create(params.heTarget,&pTarget);
    if( FAILED(hr) )
      return false;
    VARIANT_BOOL handled = 0;

    IElement* pSource = 0;
    if( params.he )
      create(params.he,&pSource);
    hr = Fire_OnControlEvent(pTarget, params.cmd, params.reason, pSource, &handled );
    pTarget->Release();
    if( pSource ) pSource->Release();
    if( SUCCEEDED(hr) && handled )
      return TRUE;
    return FALSE; 
  }

  virtual bool on_scroll( HELEMENT he, HELEMENT target, SCROLL_EVENTS cmd, INT pos, BOOL isVertical )
  {
    if(!connected)
      return FALSE; 
    IElement* pTarget = 0;
    HRESULT hr = create(target,&pTarget);
    if( FAILED(hr) )
      return false;
    VARIANT_BOOL handled = 0;
    hr = Fire_OnScroll(pTarget, cmd, pos, isVertical, &handled );
    pTarget->Release();
    if( SUCCEEDED(hr) && handled )
      return true;
    return false; 
  }

  virtual void on_size( HELEMENT he )
  {
    if(connected)
      Fire_OnSize( );
  }

public:

  STDMETHOD(get_Tag)(BSTR* pVal);
  STDMETHOD(get_Value)(VARIANT* pVal);
  STDMETHOD(put_Value)(VARIANT newVal);
  STDMETHOD(Select)(BSTR cssSelector,IElement** el);
  STDMETHOD(SelectAll)(BSTR cssSelector, IElements** coll);
  STDMETHOD(get_Attr)(BSTR name, VARIANT* pVal);
  STDMETHOD(put_Attr)(BSTR name, VARIANT newVal);
  STDMETHOD(get_StyleAttr)(BSTR name, VARIANT* pVal);
  STDMETHOD(put_StyleAttr)(BSTR name, VARIANT newVal);
  STDMETHOD(Position)(LONG* x, LONG* y, ElementBoxType ofWhat, RelativeToType relTo);
  STDMETHOD(Dimension)(LONG* width, LONG* height, ElementBoxType ofWhat);
  STDMETHOD(Call)(BSTR methodName, SAFEARRAY ** params, VARIANT* rv);
  STDMETHOD(get_HELEMENT)(LONG* pVal);
};

OBJECT_ENTRY_AUTO(__uuidof(Element), CElement)
