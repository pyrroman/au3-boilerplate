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
#include "AutoItElement.h"
#include "dll.h"

AutoItElement::AutoItElement(void): type(NOTHING),name(NULL)
{
	VariantInit(&data);
}

AutoItElement::AutoItElement(wchar_t* name,VARIANT *src)
{
	SetName(name);
	VariantCopy(&data,src);
}

AutoItElement::~AutoItElement(void)
{
	if (name) delete [] name;
	VariantClear(&data);
}

wchar_t* AutoItElement::GetName()
{
	return this->name;
}

VARIANT* AutoItElement::GetData()
{
	return &this->data;
}

AutoItElement::TYPE AutoItElement::GetType() const
{
	return this->type;
}

void AutoItElement::SetType(AutoItElement::TYPE new_type)
{
	this->type = new_type;
}

AutoItElement::SCOPE AutoItElement::GetScope() const
{
	return this->scope;
}

void AutoItElement::SetScope(AutoItElement::SCOPE new_scope)
{
	this->scope = new_scope;
}


void AutoItElement::SetData(LPCWSTR new_data)
{
	if (this->data.vt!=VT_EMPTY) VariantClear(&this->data);
	this->data.vt = VT_BSTR;

	this->data.bstrVal = SysAllocString(new_data);
}

void AutoItElement::SetData(VARIANT *new_variant)
{
	VariantCopy(&this->data,new_variant);
}

void AutoItElement::SetName(wchar_t* new_name)
{
	if (name) delete [] name;
	this->name = new wchar_t[lstrlenW(new_name)+1];
	lstrcpyW(name,new_name);
}
