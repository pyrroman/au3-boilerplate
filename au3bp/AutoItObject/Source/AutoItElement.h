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
class AutoItElement
{
public:
	AutoItElement(void);
	AutoItElement(wchar_t* name,VARIANT*);
	~AutoItElement(void);
	enum TYPE
	{
		NOTHING, 
		METHOD,
		PROPERTY
	};
	TYPE GetType() const;
	void SetType(TYPE new_type);
	enum SCOPE
	{
		PUBLIC,
		READONLY,
		PRIVATE
	};
	SCOPE GetScope() const;
	void SetScope(SCOPE new_scope);
	void SetData(LPCWSTR);
	void SetData(VARIANT*);
	VARIANT* GetData();
	wchar_t* GetName();
	void SetName(wchar_t*);
private:
	wchar_t* name;
	VARIANT data;
	TYPE type;
	SCOPE scope;
};
