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
#include "AutoItWrapElement.h"
#include "AutoItCallbacks.h"

class AutoItWrapObject: public IDispatch
{
public:
	AutoItWrapObject(IUnknown*, bool no_unknown, bool fDLLCallObject = FALSE);
	AutoItWrapObject(IUnknown* new_object, wchar_t *methods, bool no_unknown, bool fFreeMem=FALSE, bool fDLLCallObject = FALSE);
	~AutoItWrapObject(void);
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
	VOID AddMember(AutoItWrapElement*);
	VOID SetParentDllHandle(HMODULE handle);

private:
	ULONG ref_count, in_object;;
	simple::vector<AutoItWrapElement*> members;
	IUnknown* wrapped_object;
	DISPID FindMember(wchar_t* name);
	VOID CleanOnInvoke(INT ifuncparams, PVOID* aux, VARIANTARG* subvariant, VARIANT* carrier, VARTYPE *prgvt, VARIANTARG** prgpvarg);
	LONGLONG StringToLonglong(BSTR bstr);
	DOUBLE StringToDouble(BSTR bstr);
	FLOAT StringToFloat(BSTR bstr);
	BOOL StringToBool(BSTR bstr);
	BYTE StringToByte(BSTR bstr);
	ULONG StringToDword(BSTR bstr);
	LONG StringToInt(BSTR bstr);
	USHORT StringToWord(BSTR bstr);
	SHORT StringToShort(BSTR bstr);
	BYTE DoubleToByte(DOUBLE dval);
	USHORT DoubleToWord(DOUBLE dval);
	SHORT DoubleToShort(DOUBLE dval);
	ULONG DoubleToDword(DOUBLE dval);
	FLOAT DoubleToFloat(DOUBLE dval);
	LONG DoubleToInt(DOUBLE dval);
	ULONGLONG DoubleToUlonglong(DOUBLE dval);
	LONGLONG DoubleToLonglong(DOUBLE dval);
	VOID FixDecimalSeparator(BSTR bstr, BOOL bflag=FALSE);
	BOOL CrackReturnType(LPWSTR wtype, BOOL *byrefedret, CALLCONV *callingConv, VARTYPE *rettype);
	BOOL SetFunctionName(LPWSTR sName);
	VARIANT v_paramarray;
	BOOL is_unkown;
	HMODULE hDLL;
	BOOL fCallFree;
	ULONG_PTR GetDllFunctionPointer();
	BOOL fDLLCallObject;
    LPWSTR sFunctionName;
};
