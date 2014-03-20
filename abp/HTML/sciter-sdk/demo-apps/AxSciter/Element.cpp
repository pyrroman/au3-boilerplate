// Element.cpp : Implementation of CElement

#include "stdafx.h"
#include "Element.h"
#include "Elements.h"

// CElement

STDMETHODIMP CElement::get_Tag(BSTR* pVal)
{
  const char* tag = self.get_element_type();
  if( tag )
  {
    *pVal = SysAllocString(aux::a2w(tag));
    return S_OK;
  }
  return S_FALSE;
}

STDMETHODIMP CElement::get_Value(VARIANT *pVal)
{
  json::value jsv = self.get_value();
  *pVal = val2VAR(jsv);
  return S_OK;
}

STDMETHODIMP CElement::put_Value(VARIANT newVal)
{
  json::value jsv = VAR2val(newVal);
  self.set_value(jsv);
  return S_OK;
}


STDMETHODIMP CElement::Select(BSTR cssSelector,IElement** el)
{
  dom::element::find_first_callback find_first;
  self.select_elements( &find_first, aux::w2a(cssSelector)); 
  if( find_first.hfound )
    return CElement::create(find_first.hfound,el);
  return S_FALSE;
}

STDMETHODIMP CElement::SelectAll(BSTR cssSelector, IElements** coll)
{
  return CElements::create(self, cssSelector, coll); 
}

STDMETHODIMP CElement::get_Attr(BSTR name, VARIANT* pVal)
{
  const wchar_t* att = self.get_attribute(aux::w2a(name));
  if( att )
  {
    pVal->vt = VT_BSTR;
    pVal->bstrVal = SysAllocString(att);
  }
	else
  {
    VariantClear(pVal);
  }
	return S_OK;
}

STDMETHODIMP CElement::put_Attr(BSTR name, VARIANT newVal)
{
  if(newVal.vt == VT_BSTR)
    self.set_attribute(aux::w2a(name),newVal.bstrVal);
  else
    self.set_attribute(aux::w2a(name),0);
	return S_OK;
}

STDMETHODIMP CElement::get_StyleAttr(BSTR name, VARIANT* pVal)
{
  const wchar_t* att = self.get_style_attribute(aux::w2a(name));
  if( att )
  {
    pVal->vt = VT_BSTR;
    pVal->bstrVal = SysAllocString(att);
  }
	else
  {
    VariantClear(pVal);
  }
	return S_OK;
}

STDMETHODIMP CElement::put_StyleAttr(BSTR name, VARIANT newVal)
{
  if(newVal.vt == VT_BSTR)
    self.set_style_attribute(aux::w2a(name),newVal.bstrVal);
  else
    self.set_style_attribute(aux::w2a(name),0);
	return S_OK;
}

STDMETHODIMP CElement::Position(LONG* x, LONG* y, ElementBoxType ofWhat, RelativeToType relTo)
{
	RECT r = self.get_location( unsigned(ofWhat) | unsigned(relTo));
  *x = r.left;
  *y = r.top;
	return S_OK;
}

STDMETHODIMP CElement::Dimension(LONG* width, LONG* height, ElementBoxType ofWhat)
{
	RECT r = self.get_location( unsigned(ofWhat) | SELF_RELATIVE);
  *width = r.right - r.left;
  *height = r.bottom - r.top;
	return S_OK;
}

STDMETHODIMP CElement::Call(BSTR methodName, SAFEARRAY ** params, VARIANT* rv)
{
  HRESULT hr; 
  long lbound = 0, ubound = -1;
  
	hr = SafeArrayGetLBound(*params, 1, &lbound); 
  hr = SafeArrayGetUBound(*params, 1, &ubound); 
  
  aux::w2a aname(methodName);
  
  if( lbound <= ubound )
  {
    json::value *argv = new json::value[ubound - lbound + 1];
    int argc = 0;
    for(long n = lbound; n <= ubound; ++n)
    {
      CComVariant var;
      hr = SafeArrayGetElement(*params,&n, &var); 
      if(FAILED(hr))
        break;
      argv[argc++] = VAR2val(var);
    }
    json::value r = self.call_method(aname,argc,argv);
    *rv = val2VAR(r);
    delete [] argv;
  }  
  else
  {
    json::value r = self.call_method(aname,0,0);
    *rv = val2VAR(r);
  }
  return S_OK;
}

STDMETHODIMP CElement::get_HELEMENT(LONG* pVal)
{
  *pVal = (LONG)(HELEMENT)self; // not 64-bit compatible
  return S_OK;
}
