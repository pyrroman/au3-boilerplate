/**
 * @package	AutoItObject
 * @copyright	Copyright (C) The AutoItObject-Team. All rights reserved.
 * @license	Artistic License 2.0, see Artistic.txt
 * 
 * This file is part of AutoItObject.
 * 
 * AutoItObject is free software; you can redistribute it and/or modify
 * it under the terms of the Artistic License as published by Larry Wall,
 * either version 2.0, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the Artistic License for more details.
 * 
 * You should have received a copy of the Artistic License with this Kit,
 * in the file named "Artistic.txt".  If not, you can get a copy from
 * <http://www.perlfoundation.org/artistic_license_2_0> OR
 * <http://www.opensource.org/licenses/artistic-license-2.0.php>
 * 
 * A complete list of contributors is available in dll.h
 *
 */
#pragma once
#include <Objbase.h>
#include "vector.h"
#include "AutoItElement.h"
#include "AutoItCallbacks.h"

class AutoItObject: public IDispatch
{
public:
	AutoItObject(void);
	AutoItObject(AutoItObject* a);
	~AutoItObject(void);
	HRESULT STDMETHODCALLTYPE QueryInterface(const IID &riid,void **ppvObject);
	ULONG STDMETHODCALLTYPE AddRef();
	ULONG STDMETHODCALLTYPE Release();
	HRESULT STDMETHODCALLTYPE GetTypeInfoCount(UINT *pctinfo);
	HRESULT STDMETHODCALLTYPE GetTypeInfo(UINT iTInfo,LCID lcid,ITypeInfo **ppTInfo);
	HRESULT STDMETHODCALLTYPE GetIDsOfNames(const IID &riid,LPOLESTR *rgszNames,
											UINT cNames,LCID lcid,DISPID *rgDispId);
	HRESULT STDMETHODCALLTYPE Invoke(DISPID dispIdMember,const IID &riid,
										LCID lcid,WORD wFlags,DISPPARAMS *pDispParams,
										VARIANT *pVarResult,EXCEPINFO *pExcepInfo,UINT * puArgErr);
	void AddMember(AutoItElement*);
	void AddEnum(wchar_t* function_next, wchar_t* function_reset, wchar_t* function_skip);
	void RemoveMember(wchar_t* name);
    void AddMethod(wchar_t* method,wchar_t* value, AutoItElement::SCOPE new_scope);
    void AddProperty(wchar_t* property_name,  AutoItElement::SCOPE new_scope, VARIANT* property_value);
	static void Init(AUTOITFUNCTIONPROXY proxy_function);
private:
	ULONG ref_count;
	ULONG in_object;
	simple::vector<AutoItElement*> members;
	wchar_t *enumfn_next, *enumfn_reset, *enumfn_skip, *lastmethod;
	static AUTOITFUNCTIONPROXY AutoItFunctionProxy;
	DISPID FindMember(wchar_t* name);
	VARIANT v_paramarray, v_error, v_result, v_propcall;
};
