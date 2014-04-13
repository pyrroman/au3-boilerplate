// Sciter.cpp : Implementation of CSciter
#include "stdafx.h"
#include "Sciter.h"
#include "aux-cvt.h"
#include "Element.h"

// CSciter

STDMETHODIMP CSciter::LoadHtml(BSTR html, BSTR baseUrl)
{
  aux::w2utf whtml(html); 
  return SciterLoadHtml(m_hWnd,whtml,whtml.length(),baseUrl)? S_OK : E_FAIL;
}

STDMETHODIMP CSciter::LoadUrl(BSTR urlToLoad)
{
  return SciterLoadFile(m_hWnd,urlToLoad)? S_OK : E_FAIL;
}


LRESULT CSciter::on_callback_host(LPSCN_CALLBACK_HOST pnmld)  
{ 
  switch(pnmld->channel)  
  {
    case 0: // 0 - stdin, read from stdin requested, put string into pnmld->r 
      break;  
    case 1: // 1 - stdout, "stdout << something" requested, pnmld->p1 is 
            //     string to output.
      this->Fire_onStdOut(_bstr_t(pnmld->p1.get(L"")));
      break;  
    case 2: // 2 - stderr, "stderr << something" requested or error happened, 
            //     pnmld->p1 is string to output.
      this->Fire_onStdErr(_bstr_t(pnmld->p1.get(L"")));
      break;
    default:
            // view.callback(channel,p1,p2) call from script
      break;  
  }
  return 0; 
}

LRESULT CSciter::on_load_data(LPSCN_LOAD_DATA pnmld)
{
  m_isInsideOnLoadData = true;
  _bstr_t url = pnmld->uri;
  VARIANT_BOOL discard = 0;
  this->Fire_OnLoadData(url,(ResourceType)pnmld->dataType,(LONG)(INT_PTR)pnmld->requestId,&discard);
  m_isInsideOnLoadData = false;
  if( discard ) 
    return LOAD_DISCARD;
  return LOAD_OK;
}

LRESULT CSciter::on_data_loaded(LPSCN_DATA_LOADED pnmld)
{
  _bstr_t url = pnmld->uri;
  this->Fire_OnDataLoaded(url,(ResourceType)pnmld->dataType,(BYTE*)pnmld->data, pnmld->dataSize,0);
  return 0;
}

bool CSciter::on_script_call(HELEMENT he, LPCSTR name, UINT argc, json::value* argv, json::value& retval)
{
  if( !m_methods )
    return false;
  _variant_t params[64];
  for( unsigned i = 0; i < min(64,argc); ++i )
    params[i] = val2VAR(argv[i]);
  _variant_t rv;
  HRESULT hr = m_methods.InvokeN(aux::a2w(name), params, argc, &rv);
  if( SUCCEEDED(hr) )
  {
    retval = VAR2val(rv);
    return true;
  }
  return false;
}

STDMETHODIMP CSciter::get_Root(IElement **pVal)
{
  HELEMENT he = 0;
  SciterGetRootElement(m_hWnd,&he);
  return CElement::create(he,pVal);
}

STDMETHODIMP CSciter::Call(BSTR name, SAFEARRAY ** params, VARIANT* rv)
{
  HRESULT hr; 
  long lbound = 0, ubound = -1;
  bool r = false;

	hr = SafeArrayGetLBound(*params, 1, &lbound); 
  hr = SafeArrayGetUBound(*params, 1, &ubound); 
  
  aux::w2a aname(name);
  
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
    json::value vr;
    r = SciterCall(m_hWnd,aname,argc,argv,&vr) != FALSE;
    *rv = val2VAR(vr);
    delete [] argv;
  }  
  else
  {
    json::value vr;
    r = SciterCall(m_hWnd,aname,0,0,&vr) != FALSE;
    *rv = val2VAR(vr);
  }
  return r? S_OK : S_FALSE;
}

STDMETHODIMP CSciter::Eval(BSTR script, VARIANT* rv)
{
  json::value vr;
  BOOL r = SciterEval(m_hWnd,script,SysStringLen(script),&vr);
  if(r) {
    *rv = val2VAR(vr);
    return S_OK;
  }
  return S_FALSE;
}

STDMETHODIMP CSciter::DataReady(LONG requestId, BYTE* data, LONG dataLength)
{
  if( m_isInsideOnLoadData )
    SciterDataReady(m_hWnd,0,data,dataLength);
  else if( requestId ) // outside of OnLoadData event, data have arrived asynchronously
    SciterDataReadyAsync(m_hWnd,0,data,dataLength,(LPVOID)(INT_PTR)requestId); // not 64-bit compatible, sic!
  else
    return S_FALSE;
  return S_OK;
}

STDMETHODIMP CSciter::get_Methods(IDispatch** pVal)
{
  *pVal = m_methods;
  return S_OK;
}

STDMETHODIMP CSciter::putref_Methods(IDispatch* newVal)
{
  m_methods = newVal;
  return S_OK;
}
