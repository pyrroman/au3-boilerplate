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
#include "AutoItWrapElement.h"
#include "dll.h"

AutoItWrapElement::AutoItWrapElement(void): types(NULL),name(NULL),index((DWORD)-1), specparamcount(0), swtypes(NULL)
{
}

AutoItWrapElement::AutoItWrapElement(wchar_t* new_name,wchar_t* new_types,unsigned long new_index)
{
	this->SetName(new_name);
	this->SetTypes(new_types);
	this->index = new_index;
}

AutoItWrapElement::~AutoItWrapElement(void)
{
	if (this->name) delete [] this->name;
	if (this->specparamcount)
	{
		delete [] this->swtypes;
        delete [] this->types; // line above clears what's inside too
	}
}

wchar_t* AutoItWrapElement::GetName()
{
	return this->name;
}

void AutoItWrapElement::SetName(wchar_t* new_name)
{
	if (this->name) delete [] this->name;
	this->name = new wchar_t[lstrlenW(new_name)+1];
	lstrcpyW(this->name,new_name);
}

LPWSTR* AutoItWrapElement::GetTypes()
{
	return this->types;
}

void AutoItWrapElement::SetTypes(wchar_t* wtypes)
{
	if (this->specparamcount)
	{
		delete [] this->swtypes;
        delete [] this->types; // line above clears what's inside too
	}
	INT iparams=0;
	INT len=0;
	while (wtypes[len]!='\0') // till null-terminator encountered
	{
		if (wtypes[len]==';')
		{
			if (wtypes[len+1]!='\0')
			{
				++iparams; // one more param detected
			}
			else
			{
				wtypes[len]='\0'; // replacing ';\0' with '\0\0' if that's occurred
			}
		}
		++len;
	}
	if (len) ++iparams; // real number of params is +1
	// If there are params specified make and fill array of string pointers
	if (iparams)
	{
		this->specparamcount=iparams;
		this->swtypes = new wchar_t[len+1];
        lstrcpyW(this->swtypes, wtypes);
		this->types = new LPWSTR[iparams];
		types[0] = this->swtypes;
		INT iparam=1;
		INT i=0;
		while (this->swtypes[i]!='\0') // till null-terminator encountered
		{
			if (this->swtypes[i]==';')
			{
				this->swtypes[i]='\0'; // replacing with null-terminator (separator)
				types[iparam] = this->swtypes+i+1; // moving pointer forward and set it to types
				++iparam;
			}
			++i;
		}
	}
	else
	{
		this->specparamcount=0;
	}
}

unsigned long AutoItWrapElement::GetIndex()
{
	return this->index;
}

void AutoItWrapElement::SetIndex(unsigned long new_index)
{
	this->index = new_index;
}
