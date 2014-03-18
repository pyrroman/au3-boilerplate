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
#ifndef AUTOITENUMOBJECT_H_INCLUDED
#define AUTOITENUMOBJECT_H_INCLUDED
#include <Objbase.h>
#include "AutoItObject.h"

class AutoItEnumObject: public IEnumVARIANT
{
public:
    enum ACTION {
        NEXT,
        SKIP,
        RESET
    };
	AutoItEnumObject(AutoItObject *object, wchar_t* function_next, wchar_t* function_reset, wchar_t* function_skip);
	~AutoItEnumObject(void);
	HRESULT STDMETHODCALLTYPE QueryInterface(const IID &riid,void **ppvObject);
	ULONG STDMETHODCALLTYPE AddRef();
	ULONG STDMETHODCALLTYPE Release();
	HRESULT STDMETHODCALLTYPE Next(unsigned long celt, VARIANT *rgvar,  unsigned long *pceltFetched);
	HRESULT STDMETHODCALLTYPE Skip(unsigned long celt);
    HRESULT STDMETHODCALLTYPE Reset();
    HRESULT STDMETHODCALLTYPE Clone(IEnumVARIANT **ppenum);

	static void Init(AUTOITENUMFUNCTIONPROXY proxy_function);
private:
	ULONG ref_count;
	AutoItObject *autoit_object;
	wchar_t *enumfn_next, *enumfn_reset, *enumfn_skip;
	VARIANT current;
	static AUTOITENUMFUNCTIONPROXY AutoItFunctionProxy;
};

#endif // AUTOITENUMOBJECT_H_INCLUDED
