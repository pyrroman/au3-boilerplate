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
#include <ObjBase.h>
class AutoItWrapElement
{
public:
	AutoItWrapElement(void);
	AutoItWrapElement(wchar_t* ,wchar_t* ,unsigned long );
	~AutoItWrapElement(void);
	unsigned long GetIndex();
	void SetIndex(unsigned long );
	LPWSTR* GetTypes();
	UINT specparamcount;
	void SetTypes(wchar_t*);
	wchar_t* GetName();
	void SetName(wchar_t*);
private:
    wchar_t* name;
	LPWSTR* types;
    wchar_t* swtypes;
	unsigned long index;
};
