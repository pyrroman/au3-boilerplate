#pragma once

template<class T>
class CProxy_IElementEvents :
	public IConnectionPointImpl<T, &__uuidof(_IElementEvents)>
{
public:
	HRESULT Fire_OnMouse( IElement * target,  LONG eventType,  LONG x,  LONG y,  LONG buttons,  LONG keys,  VARIANT_BOOL * handled)
	{
		HRESULT hr = S_OK;
		T * pThis = static_cast<T *>(this);
		int cConnections = m_vec.GetSize();

		for (int iConnection = 0; iConnection < cConnections; iConnection++)
		{
			pThis->Lock();
			CComPtr<IUnknown> punkConnection = m_vec.GetAt(iConnection);
			pThis->Unlock();

			IDispatch * pConnection = static_cast<IDispatch *>(punkConnection.p);

			if (pConnection)
			{
				CComVariant avarParams[6];
				avarParams[5] = target;
				avarParams[4] = eventType;
				avarParams[4].vt = VT_I4;
				avarParams[3] = x;
				avarParams[3].vt = VT_I4;
				avarParams[2] = y;
				avarParams[2].vt = VT_I4;
				avarParams[1] = buttons;
				avarParams[1].vt = VT_I4;
				avarParams[0] = keys;
				avarParams[0].vt = VT_I4;
				CComVariant varResult;
				if(handled)
				{
					varResult.byref = handled;
					varResult.vt = VT_BOOL|VT_BYREF;
				}

				DISPPARAMS params = { avarParams, NULL, 6, 0 };
				hr = pConnection->Invoke(1, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD, &params, &varResult, NULL, NULL);
			}
		}
		return hr;
	}
	HRESULT Fire_OnKey( IElement * target,  LONG eventType,  LONG code,  LONG keys,  VARIANT_BOOL * handled)
	{
		HRESULT hr = S_OK;
		T * pThis = static_cast<T *>(this);
		int cConnections = m_vec.GetSize();

		for (int iConnection = 0; iConnection < cConnections; iConnection++)
		{
			pThis->Lock();
			CComPtr<IUnknown> punkConnection = m_vec.GetAt(iConnection);
			pThis->Unlock();

			IDispatch * pConnection = static_cast<IDispatch *>(punkConnection.p);

			if (pConnection)
			{
				CComVariant avarParams[4];
				avarParams[3] = target;
				avarParams[2] = eventType;
				avarParams[2].vt = VT_I4;
				avarParams[1] = code;
				avarParams[1].vt = VT_I4;
				avarParams[0] = keys;
				avarParams[0].vt = VT_I4;
				CComVariant varResult;
				if(handled)
				{
					varResult.byref = handled;
					varResult.vt = VT_BOOL|VT_BYREF;
				}

				DISPPARAMS params = { avarParams, NULL, 4, 0 };
				hr = pConnection->Invoke(2, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD, &params, &varResult, NULL, NULL);
			}
		}
		return hr;
	}
	HRESULT Fire_OnFocus( IElement * target,  LONG eventType,  VARIANT_BOOL * handled)
	{
		HRESULT hr = S_OK;
		T * pThis = static_cast<T *>(this);
		int cConnections = m_vec.GetSize();

		for (int iConnection = 0; iConnection < cConnections; iConnection++)
		{
			pThis->Lock();
			CComPtr<IUnknown> punkConnection = m_vec.GetAt(iConnection);
			pThis->Unlock();

			IDispatch * pConnection = static_cast<IDispatch *>(punkConnection.p);

			if (pConnection)
			{
				CComVariant avarParams[2];
				avarParams[1] = target;
				avarParams[0] = eventType;
				avarParams[0].vt = VT_I4;
				CComVariant varResult;
				if(handled)
				{
					varResult.byref = handled;
					varResult.vt = VT_BOOL|VT_BYREF;
				}

				DISPPARAMS params = { avarParams, NULL, 2, 0 };
				hr = pConnection->Invoke(3, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD, &params, &varResult, NULL, NULL);
			}
		}
		return hr;
	}
	HRESULT Fire_OnTimer( LONG timerId,  VARIANT_BOOL * handled)
	{
		HRESULT hr = S_OK;
		T * pThis = static_cast<T *>(this);
		int cConnections = m_vec.GetSize();

		for (int iConnection = 0; iConnection < cConnections; iConnection++)
		{
			pThis->Lock();
			CComPtr<IUnknown> punkConnection = m_vec.GetAt(iConnection);
			pThis->Unlock();

			IDispatch * pConnection = static_cast<IDispatch *>(punkConnection.p);

			if (pConnection)
			{
				CComVariant avarParams[1];
				avarParams[0] = timerId;
				avarParams[0].vt = VT_I4;
				CComVariant varResult;
				if(handled)
				{
					varResult.byref = handled;
					varResult.vt = VT_BOOL|VT_BYREF;
				}

				DISPPARAMS params = { avarParams, NULL, 1, 0 };
				hr = pConnection->Invoke(4, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD, &params, &varResult, NULL, NULL);
			}
		}
		return hr;
	}
	HRESULT Fire_OnSize()
	{
		HRESULT hr = S_OK;
		T * pThis = static_cast<T *>(this);
		int cConnections = m_vec.GetSize();

		for (int iConnection = 0; iConnection < cConnections; iConnection++)
		{
			pThis->Lock();
			CComPtr<IUnknown> punkConnection = m_vec.GetAt(iConnection);
			pThis->Unlock();

			IDispatch * pConnection = static_cast<IDispatch *>(punkConnection.p);

			if (pConnection)
			{
				CComVariant varResult;

				DISPPARAMS params = { NULL, NULL, 0, 0 };
				hr = pConnection->Invoke(5, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD, &params, &varResult, NULL, NULL);
			}
		}
		return hr;
	}
	HRESULT Fire_OnControlEvent( IElement * target,  LONG eventType,  LONG reason,  IElement * source,  VARIANT_BOOL * handled)
	{
		HRESULT hr = S_OK;
		T * pThis = static_cast<T *>(this);
		int cConnections = m_vec.GetSize();

		for (int iConnection = 0; iConnection < cConnections; iConnection++)
		{
			pThis->Lock();
			CComPtr<IUnknown> punkConnection = m_vec.GetAt(iConnection);
			pThis->Unlock();

			IDispatch * pConnection = static_cast<IDispatch *>(punkConnection.p);

			if (pConnection)
			{
				CComVariant avarParams[4];
				avarParams[3] = target;
				avarParams[2] = eventType;
				avarParams[2].vt = VT_I4;
				avarParams[1] = reason;
				avarParams[1].vt = VT_I4;
				avarParams[0] = source;
				CComVariant varResult;
				if(handled)
				{
					varResult.byref = handled;
					varResult.vt = VT_BOOL|VT_BYREF;
				}

				DISPPARAMS params = { avarParams, NULL, 4, 0 };
				hr = pConnection->Invoke(6, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD, &params, &varResult, NULL, NULL);
			}
		}
		return hr;
	}
	HRESULT Fire_OnScroll( IElement * target,  LONG eventType,  long pos,  VARIANT_BOOL isVertical,  VARIANT_BOOL * handled)
	{
		HRESULT hr = S_OK;
		T * pThis = static_cast<T *>(this);
		int cConnections = m_vec.GetSize();

		for (int iConnection = 0; iConnection < cConnections; iConnection++)
		{
			pThis->Lock();
			CComPtr<IUnknown> punkConnection = m_vec.GetAt(iConnection);
			pThis->Unlock();

			IDispatch * pConnection = static_cast<IDispatch *>(punkConnection.p);

			if (pConnection)
			{
				CComVariant avarParams[4];
				avarParams[3] = target;
				avarParams[2] = eventType;
				avarParams[2].vt = VT_I4;
				avarParams[1] = pos;
				avarParams[1].vt = VT_I4;
				avarParams[0] = isVertical;
				avarParams[0].vt = VT_BOOL;
				CComVariant varResult;
				if(handled)
				{
					varResult.byref = handled;
					varResult.vt = VT_BOOL|VT_BYREF;
				}

				DISPPARAMS params = { avarParams, NULL, 4, 0 };
				hr = pConnection->Invoke(7, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD, &params, &varResult, NULL, NULL);
			}
		}
		return hr;
	}
};

