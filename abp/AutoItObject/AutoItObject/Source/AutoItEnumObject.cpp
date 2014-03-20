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
#include "AutoItEnumObject.h"


AUTOITENUMFUNCTIONPROXY AutoItEnumObject::AutoItFunctionProxy=NULL;

void AutoItEnumObject::Init(AUTOITENUMFUNCTIONPROXY proxy_function)
{
	AutoItFunctionProxy = proxy_function;
}

AutoItEnumObject::AutoItEnumObject(AutoItObject *object, wchar_t* function_next, wchar_t* function_reset, wchar_t* function_skip): ref_count(0)
{
    autoit_object = object;
    autoit_object->AddRef();

	enumfn_next = function_next;
    enumfn_reset = function_reset;
    enumfn_skip = function_skip;
	VariantInit(&current);
}

AutoItEnumObject::~AutoItEnumObject(void)
{
    // the enumfn... must not be freed since they are only references!
	VariantClear(&current);
    autoit_object->Release();
	autoit_object = NULL;
}

ULONG AutoItEnumObject::AddRef()
{

	return ++ref_count;
}

ULONG AutoItEnumObject::Release()
{

	if (!--ref_count)
	{
		// Commit suicide!
		// This may seems strange but it's ok as long as we don't touch ourself after the delete line.
		// More info: http://www.parashift.com/c++-faq-lite/freestore-mgmt.html#faq-16.15
		delete this;
		return 0;
	}
	return ref_count;
}

HRESULT AutoItEnumObject::QueryInterface(const IID &riid, void **ppvObject)
{
        IID un = {00000000,0000,0000, {0xC0,00, 00,00,00,00,00,0x46}}; // IID_IUnknown did not work
        IID va = {0x00020404, 0000, 0000, {0xC0, 00, 00, 00, 00, 00, 00, 0x46}}; // IID_IEnumVARIANT did not work
        // Match the interface and return the proper pointer
		if ( riid == un || riid == va ) {
			*ppvObject = this;
		} else {
			// It didn't match an interface
			*ppvObject = NULL;
			return E_NOINTERFACE;
		}

		// Increment refcount on the pointer we're about to return
		this->AddRef();
		// Return success
		return S_OK;

}

HRESULT AutoItEnumObject::Next(unsigned long celt, VARIANT *rgvar,  unsigned long *pceltFetched)
{
    *pceltFetched = this->AutoItFunctionProxy(AutoItEnumObject::NEXT , enumfn_next,autoit_object,&current, rgvar);
    if (*pceltFetched == 0) return S_FALSE;
    return S_OK;
}

HRESULT AutoItEnumObject::Skip(unsigned long celt)
{
    if (this->AutoItFunctionProxy(AutoItEnumObject::SKIP , enumfn_skip,autoit_object,&current, NULL))
        return S_OK;
	return S_FALSE;
}

HRESULT AutoItEnumObject::Reset()
{
	if (this->AutoItFunctionProxy(AutoItEnumObject::RESET , enumfn_reset,autoit_object,&current, NULL))
        return S_OK;
	return S_FALSE;
}
/*
HRESULT AutoItEnumObject::Invoke(DISPID dispIdMember, const IID &riid, LCID lcid, WORD wFlags, DISPPARAMS *pDispParams, VARIANT *pVarResult, EXCEPINFO *pExcepInfo, UINT *puArgErr)
{
	if ((dispIdMember<0) || (dispIdMember >= (DISPID)this->members.size()) ) return DISP_E_MEMBERNOTFOUND;
	AutoItElement *elem = this->members.at(dispIdMember);

	if ((wFlags & DISPATCH_METHOD) || (wFlags & DISPATCH_PROPERTYGET)) {

		switch (elem->GetType())
		{
			case AutoItElement::METHOD:
				if (!(elem->GetScope() == AutoItElement::PUBLIC) && (this->in_object == 0)) return DISP_E_MEMBERNOTFOUND;
				// Assume it's a BSTR
				this->in_object += 1;
				AutoItFunctionProxy(static_cast<LPCWSTR>(elem->GetData()->bstrVal),this,
									pDispParams->rgvarg,pDispParams->cArgs, pVarResult);
				this->in_object -= 1;
				return S_OK;
			case AutoItElement::PROPERTY:
				if ((elem->GetScope() == AutoItElement::PRIVATE) && (this->in_object == 0)) return DISP_E_MEMBERNOTFOUND;
				VariantCopy(pVarResult, elem->GetData());
				return S_OK;
		}
	} else if ((wFlags & DISPATCH_PROPERTYPUT) || (wFlags & DISPATCH_PROPERTYPUTREF)) {
		if (!(elem->GetScope() == AutoItElement::PUBLIC) && (this->in_object == 0)) return DISP_E_MEMBERNOTFOUND;
		elem->SetData(&pDispParams->rgvarg[0]);
		return S_OK;
	}


	return DISP_E_MEMBERNOTFOUND;
}
*/

HRESULT AutoItEnumObject::Clone(IEnumVARIANT **ppenum)
{
	return E_NOTIMPL;
}
