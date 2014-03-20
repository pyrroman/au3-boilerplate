// Elements.h : Declaration of the CElements

#pragma once
#include "resource.h"       // main symbols

#include <vector>
#include "AxSciter.h"
#include "Element.h"

#if defined(_WIN32_WCE) && !defined(_CE_DCOM) && !defined(_CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA)
#error "Single-threaded COM objects are not properly supported on Windows CE platform, such as the Windows Mobile platforms that do not include full DCOM support. Define _CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA to force ATL to support creating single-thread COM object's and allow use of it's single-threaded COM object implementations. The threading model in your rgs file was set to 'Free' as that is the only threading model supported in non DCOM Windows CE platforms."
#endif



// CElements

class ATL_NO_VTABLE CElements :
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CElements, &CLSID_Elements>,
	public IDispatchImpl<IElements, &IID_IElements, &LIBID_AxSciterLib, /*wMajor =*/ 1, /*wMinor =*/ 0>,
  public IEnumVARIANT,
  public dom::callback 
{
 // dom::callback
  virtual bool on_element(HELEMENT he)
  {
    elements.push_back(he);
    return false;
  }

public:
  std::vector<dom::element> elements;
  int                       next;
  CElements(): next(0)
  {
  }
DECLARE_REGISTRY_RESOURCEID(IDR_ELEMENTS)


BEGIN_COM_MAP(CElements)
	COM_INTERFACE_ENTRY(IElements)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(IEnumVARIANT)
END_COM_MAP()


// IEnumVARIANT
  STDMETHOD(Next)(ULONG celt, VARIANT * rgvar, ULONG * pceltFetched)
  {
    //if (pceltFetched == NULL)
    //  return E_POINTER;

    int n = 0;
    for(; n < celt && next < elements.size(); ++next )
    {
      IElement* el = 0;
      if(SUCCEEDED(CElement::create(elements[next],&el)))
      {
        rgvar->vt = VT_DISPATCH;
        rgvar->pdispVal = el;
        ++n;
        ++rgvar; 
      }
    }
    if (pceltFetched) *pceltFetched = n;
    return n == celt? S_OK : S_FALSE;
  }
  STDMETHOD(Skip)(ULONG celt)
  {
    next += celt;
    return S_OK;
  }
  STDMETHOD(Reset)()
  {
    next = 0;
    return S_OK;
  }
  STDMETHOD(Clone)(IEnumVARIANT ** ppenum)
  {
    if (ppenum == NULL)
      return E_POINTER;
   
    CComObject<CElements>* pElements; 
    HRESULT hr = CComObject<CElements>::CreateInstance(&pElements);
    if (SUCCEEDED(hr) && pElements)
    {   
      pElements->AddRef();
      pElements->elements = elements;
      pElements->QueryInterface(IID_IEnumVARIANT, reinterpret_cast<void**>(ppenum));
      pElements->Release();
    }
    return S_OK;
  }

  static HRESULT create(dom::element self, const wchar_t* selector, IElements** iface)  
  {
    CComObject<CElements>* pElements; 
    HRESULT hr = CComObject<CElements>::CreateInstance(&pElements);
    if (SUCCEEDED(hr) && pElements)
    {   
      pElements->AddRef();
      self.select_elements(pElements, aux::w2a(selector));
      pElements->QueryInterface(IID_IEnumVARIANT, reinterpret_cast<void**>(iface));
      pElements->Release();
    }
    return hr;
  }



	DECLARE_PROTECT_FINAL_CONSTRUCT()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
	}

public:

  STDMETHOD(_NewEnum)(IUnknown** coll);
  STDMETHOD(get_Count)(LONG* pVal);
  STDMETHOD(get_Item)(LONG index, IElement** el);
};

OBJECT_ENTRY_AUTO(__uuidof(Elements), CElements)
