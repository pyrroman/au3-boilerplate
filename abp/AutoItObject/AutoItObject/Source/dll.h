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
* ------------------------ AutoItObject CREDITS: ------------------------
* Copyright (C) by:
* The AutoItObject-Team:
* 	Andreas Karlsson (monoceres)
* 	Dragana R. (trancexx)
* 	Dave Bakker (Kip)
* 	Andreas Bosch (progandy)
*
*/
#pragma warning( disable : 4244 ) // this to that; it's deliberate

#pragma once

#define EXPORT(TYPE) extern "C" __declspec(dllexport) TYPE __stdcall

#if defined(_M_IA64) || defined(_M_X64) || defined(_WIN64)
#define _X64 true
//#define _M_X64
#else
#define _X64 false
#endif

#define _RELEASE // comment-out this line if you want to initialize tlibc

INT Compare(const wchar_t *s1, const wchar_t *s2);

INT debugprintW(const wchar_t *format, ...);

VARTYPE VarType(VARTYPE vtype, LPCWSTR wtype);

VOID ObjPersist(LPVOID ppv);