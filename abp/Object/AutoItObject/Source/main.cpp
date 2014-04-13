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
#include <windows.h>
#include "dll.h"
#include "stdio.h"
#include "AutoItObjectClass.h"
#include "AutoItObject.h"
#include "AutoItWrapObject.h"
#include "AutoItEnumObject.h"
#include <OCIdl.h>

BOOL WINAPI DllMain(HINSTANCE hinstDLL,DWORD fdwReason,LPVOID lpvReserved)
{
	switch (fdwReason)
	{
	case DLL_PROCESS_ATTACH:
		// Do something...
		break;
	case DLL_PROCESS_DETACH:
		// Clean up?
		break;
	case DLL_THREAD_ATTACH:
		break;
	case DLL_THREAD_DETACH:
		break;
	}

	return TRUE;
}


#ifdef _RELEASE
EXTERN_C BOOL WINAPI main(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
	return TRUE;
}
#endif


EXPORT(AutoItObjectClass*) CreateAutoItObjectClass()
{

	return new AutoItObjectClass;
}


EXPORT(AutoItObject*) CreateAutoItObject()
{

	return new AutoItObject;
}


EXPORT(AutoItObject*) CloneAutoItObject(AutoItObject* old)
{

	return new AutoItObject(old);
}


EXPORT(void) Initialize(AUTOITFUNCTIONPROXY autoitfunctionproxy, AUTOITENUMFUNCTIONPROXY autoitenumfunctionproxy)
{
	AutoItObject::Init(autoitfunctionproxy);
	AutoItEnumObject::Init(autoitenumfunctionproxy);
}


EXPORT(void) AddMethod(AutoItObject* object, wchar_t* method, wchar_t* value, AutoItElement::SCOPE new_scope)
{
	object->AddMethod(method, value, new_scope);
}


EXPORT(void) RemoveMember(AutoItObject* object, wchar_t* member)
{
	object->RemoveMember(member);
}


EXPORT(void) AddEnum(AutoItObject* object, wchar_t* function_next, wchar_t* function_reset, wchar_t* function_skip)
{
	object->AddEnum(function_next, function_reset, function_skip);
}


EXPORT(void) AddProperty(AutoItObject* object, wchar_t* property_name,  AutoItElement::SCOPE new_scope, VARIANT* property_value)
{
	object->AddProperty(property_name, new_scope, property_value);
}


EXPORT(AutoItWrapObject*) CreateWrapperObject(IUnknown* object, bool fNoUnknown)
{
	return new AutoItWrapObject(object, fNoUnknown);
}


EXPORT(AutoItWrapObject*) CreateWrapperObjectEx(IUnknown* object, wchar_t* sMethods, bool fNoUnknown, bool fCallFree)
{
	return new AutoItWrapObject(object, sMethods, fNoUnknown, fCallFree);
}


EXPORT(void) WrapperAddMethod(AutoItWrapObject* object, wchar_t* method, wchar_t* types, unsigned long index)
{
	AutoItWrapElement* elem = new AutoItWrapElement;
	elem->SetName(method);
	elem->SetIndex(index);
	elem->SetTypes(types);
	object->AddMember(elem);
}


EXPORT(AutoItWrapObject*) AutoItObjectCreateObject(wchar_t* sCLSID, wchar_t* sIID, wchar_t* sMethods)
{
	CLSID clsid;
	HRESULT success;

	// IID job
	IID iid;
	if (sIID==NULL)
	{
		iid = IID_IDispatch; // default is IDispatch
	}
	else
	{
		success = IIDFromString(sIID, &iid); // converting from string representation of IID to IID
		if (success != NOERROR) return NULL;
	}

	// CLSID job
	success = CLSIDFromString(sCLSID, &clsid); // first try string representation of the CLSID
	if (success != NOERROR)
	{
		success = CLSIDFromProgID(sCLSID, &clsid); // if that didn't work try ProgID
		if (success != NOERROR)
		{
			// Maybe the user wants to get ROT object
			if (lstrlenW(sCLSID) > 4) // in that case there will be at least 5 charatrers in sCLSID string
			{
				if (CompareStringW(LOCALE_SYSTEM_DEFAULT, NORM_IGNORECASE, sCLSID, 4, L"cbi:", 4) == CSTR_EQUAL) // "COM beyond imaginable"
				{
					// GetActiveObject function works with "real" CLSIDs. Workaround follows...

					sCLSID += 4; // move pointer forward for 4 characters to skip "cbi:" moniker

					// First get IRunningObjectTable of the ROT
					IRunningObjectTable* pROT;
					success = GetRunningObjectTable(0, &pROT);
					if (success != S_OK) return NULL;

					// Create moniker out of passed identifier
					IMoniker* pMoniker;
					success = CreateFileMoniker(sCLSID, &pMoniker);
					if (success != S_OK)
					{
						pROT->Release();
						return NULL;
					}

					// Now get object identified by the moniker if possible
					IUnknown* pUnk = NULL;
					success = pROT->GetObject(pMoniker, &pUnk);

					// Release objects
					pMoniker->Release();
					pROT->Release();

					// If unsuccessful return failure
					if (success != S_OK) return NULL;

					// Format the output
					PVOID ppv;
					success = pUnk->QueryInterface(iid, &ppv);
					if (success == S_OK)
					{
						AutoItWrapObject* pRetObj = reinterpret_cast<AutoItWrapObject*>(ppv); // reinterpreting returned
						if (sMethods==NULL)
						{
							if (sIID==NULL) return pRetObj; // no sIID and no sMethods defined means 'classic' IDispatch
							else return new AutoItWrapObject(pRetObj, FALSE);
						}
						return new AutoItWrapObject(pRetObj, sMethods, FALSE);
					}
					// No object available
					return NULL; // return failure
				}
			}
		}
	}

	if (CoInitialize(0)==S_FALSE) CoUninitialize(); // just checking

	PVOID ppv;
	success = CoCreateInstance(clsid, NULL, CLSCTX_INPROC_SERVER, iid, &ppv);
	if (success != S_OK) return NULL;

	// Some objects (OLE controls) support and require persistance...
	ObjPersist(ppv);

	AutoItWrapObject* pRetObj = reinterpret_cast<AutoItWrapObject*>(ppv); // reinterpreting returned
	if (sMethods==NULL)
	{
		if (sIID==NULL) return pRetObj; // no sIID and no sMethods defined means 'classic' IDispatch, similar to AutoIt's ObjCreate function
		else return new AutoItWrapObject(pRetObj, FALSE);
	}
	return new AutoItWrapObject(pRetObj, sMethods, FALSE);
}


EXPORT(AutoItWrapObject*) AutoItObjectCreateObjectEx(wchar_t* sModule, wchar_t* sCLSID, wchar_t* sIID, wchar_t* sMethods, bool fWrapp, DWORD iTimeOut)
{
	CoFreeUnusedLibrariesEx(0, 0);

	HRESULT success;

	// IID job
	IID iid;
	if (sIID==NULL)
	{
		iid = IID_IDispatch; // default is IDispatch
	}
	else
	{
		success = IIDFromString(sIID, &iid); // converting from string representation of IID to IID
		if (success != NOERROR) return NULL;
	}

	// CLSID job
	CLSID clsid;
	success = CLSIDFromString(sCLSID, &clsid); // converting from string representation of CLSID to CLSID
	if (success != NOERROR)
	{
		if ((lstrlenW(sCLSID) > 4) && (CompareStringW(LOCALE_SYSTEM_DEFAULT, NORM_IGNORECASE, sCLSID, 4, L"cbi:", 4) == CSTR_EQUAL))
		{
			AutoItWrapObject* pRetObject = NULL;
			pRetObject = AutoItObjectCreateObject(sCLSID, sIID, sMethods);
			if (pRetObject == NULL)
			{
				LPWSTR sCommandLine = new WCHAR[32768];
				LPWSTR sExecutable = new WCHAR[32768];

				STARTUPINFO* pStartupInfo = new STARTUPINFO;
				PROCESS_INFORMATION* pProcInfo = new PROCESS_INFORMATION;

				pStartupInfo->cb = sizeof pStartupInfo;

				DWORD dwType;
				if (GetBinaryTypeW(sModule, &dwType) == 0)
				{
					// Script in some form is passed as argument. Executable in this case is "this process" module:
					GetModuleFileNameW(NULL, sExecutable, 32767);
					// Construct the command line:
					lstrcatW(sCommandLine, L" /AutoIt3ExecuteScript \"");
					lstrcatW(sCommandLine, sModule);
					lstrcatW(sCommandLine, L"\"");
				}
				else
				{
					// EXE module:
					lstrcpyW(sExecutable, sModule);
				}

				// Finalize the command line
				lstrcatW(sCommandLine, L" /StartServer");

				// Create new process
				BOOL created = CreateProcessW(sExecutable, sCommandLine, NULL, NULL, FALSE, 0, NULL, NULL, pStartupInfo, pProcInfo);

				// Free memory
				delete[] sCommandLine;
				delete[] sExecutable;

				if (created)
				{
					if (iTimeOut == 0) iTimeOut = 3000; // Default is 3000 ms.
					DWORD iRounds = iTimeOut/10; // will sleep for 10 ms in between attempts.
					DWORD iExitCode = 0; // for checking the state of created process

					for(DWORD i=0; i < iRounds; i++)
					{
						GetExitCodeProcess(pProcInfo->hProcess, &iExitCode);
						if (iExitCode != STILL_ACTIVE) break; // process no longer exists. No point in trying more.
						pRetObject = AutoItObjectCreateObject(sCLSID, sIID, sMethods);
						if (pRetObject != NULL) break; // This is good. The object is created.
						Sleep(10); // Sleep for 10 ms waiting.
					}

					if ((pRetObject == NULL) && (iExitCode == STILL_ACTIVE)) TerminateProcess(pProcInfo->hProcess, 0); // There is no object. Kill the created process.
					// Free resources
					CloseHandle(pProcInfo->hProcess);
					CloseHandle(pProcInfo->hThread);
					delete[] pStartupInfo;
					delete[] pProcInfo;
					// Return whatever the result is:
					return pRetObject;
				}

				// Process creation failed. Clean and return failure:
				delete[] pStartupInfo;
				delete[] pProcInfo;
				return NULL;
			}
			// There! All done, object is alive. Return reference:
			return pRetObject;
		}
		// Invalid moniker. Return failure:
		return NULL;
	}

	// Load the module
	HMODULE hDll = NULL;
	if (!fWrapp)
	{
		hDll = CoLoadLibrary(sModule, TRUE);
	}
	else
	{
		hDll = LoadLibraryW(sModule);
	}
	if (hDll==NULL) return NULL; // if it can't be loaded return failure

	// define DllGetClassObject function ( http://msdn.microsoft.com/en-us/library/ms680760(VS.85).aspx )
	typedef HRESULT (__stdcall *pDllGetClassObject)(IN REFCLSID, IN REFIID, OUT PVOID);
	// see if this module does export DllGetClassObject
	pDllGetClassObject GetClassObject = reinterpret_cast<pDllGetClassObject>(GetProcAddress(hDll, "DllGetClassObject"));
	if (GetClassObject==NULL) // if not
	{
		FreeLibrary(hDll); //  free the module
		return NULL; // and return failure
	}

	// If yes then call it
	IClassFactory* pIFactory;
	success = GetClassObject(clsid, IID_IClassFactory, &pIFactory);
	// check for failure
	if (success != S_OK)
	{
		FreeLibrary(hDll); //  free the module and return failure
		return NULL;
	}

	ITypeLib* pTypeLib;
	INT iRegFlag = 0;
	if (!fWrapp)
	{
		if (LoadTypeLibEx(sModule, REGKIND_NONE, &pTypeLib) == S_OK)
		{
			// Register TypeLib.
			if (RegisterTypeLib(pTypeLib, sModule, NULL) == S_OK)
			{
				iRegFlag = 2; // successfully registered
			}
			else
			{
				// In case of some error try registering on per-user level.
				if (RegisterTypeLibForUser(pTypeLib, sModule, NULL) == S_OK)
				{
					iRegFlag = 3; // per-user registration
				}
				else
				{
					iRegFlag = 1; // neither worked
				}
			}
		}
	}

	// Now call CreateInstance with IClassFactory object with specified iid
	PVOID ppv;
	success = pIFactory->CreateInstance(NULL, iid, &ppv);

	// Check for failure
	if (success != S_OK)
	{
		if (iRegFlag != 0)
		{
			TLIBATTR* pTLibAttrr;
			if (pTypeLib->GetLibAttr(&pTLibAttrr) == S_OK)
			{
				switch (iRegFlag)
				{
				case 2:
					UnRegisterTypeLib(pTLibAttrr->guid, pTLibAttrr->wMajorVerNum, pTLibAttrr->wMinorVerNum, pTLibAttrr->lcid, pTLibAttrr->syskind);
				case 3:
					UnRegisterTypeLibForUser(pTLibAttrr->guid, pTLibAttrr->wMajorVerNum, pTLibAttrr->wMinorVerNum, pTLibAttrr->lcid, pTLibAttrr->syskind);
				}
				// Free allocated memory
				pTypeLib->ReleaseTLibAttr(pTLibAttrr);
			}
			// Release ITypeLib:
			pTypeLib->Release();
		}
		// Release IClassFactory:
		pIFactory->Release();
		FreeLibrary(hDll); //  free the module
		return NULL; // and return failure
	}

	// TypeLib object is no longer needed, release it:
	if (iRegFlag != 0) pTypeLib->Release();

	// ClassFactory object is no longer needed, release it:
	pIFactory->Release();

	// Some objects (OLE controls) support and require persistance...
	ObjPersist(ppv);

	// Wrapp returned pointer as AutoItWrapObject object
	if (sMethods == NULL)
	{
		if (!fWrapp)
		{
			// FIXME: One DLL handle is left open here!
			return reinterpret_cast<AutoItWrapObject*>(ppv); // no sIID and no sMethods defined means 'classic' IDispatch
		}
		else
		{
			AutoItWrapObject* pRetObject = new AutoItWrapObject(reinterpret_cast<IUnknown*>(ppv), FALSE); // Methods will be added later
			pRetObject->SetParentDllHandle(hDll);
			return pRetObject;
		}
	}

	// Methods are specified
	AutoItWrapObject* pRetObject = new AutoItWrapObject(reinterpret_cast<IUnknown*>(ppv), sMethods, FALSE);
	pRetObject->SetParentDllHandle(hDll);
	return pRetObject;
}


EXPORT(AutoItWrapObject*) CreateDllCallObject(wchar_t* sModule, wchar_t* sMethods, DWORD iFlags = 0)
{
	// Load the module
	HMODULE hDll = LoadLibraryExW(sModule, NULL, iFlags);
	if (hDll==NULL) return NULL; // if it can't be loaded return failure

	AutoItWrapObject* pRetObject;
	if (sMethods == NULL)
	{
		pRetObject = new AutoItWrapObject(NULL, TRUE, TRUE);
	}
	else
	{
		pRetObject = new AutoItWrapObject(NULL, sMethods, TRUE, FALSE, TRUE);
	}
	pRetObject->SetParentDllHandle(hDll);
	return pRetObject;
}


EXPORT(DWORD) RegisterObject(AutoItObject* object, wchar_t* sCLSID)
{
	// It would be simpler to just call RegisterActiveObject, but that function accepts only "real" CLSIDs
	/*
	CLSID clsid;
	HRESULT success = CLSIDFromString(sCLSID, &clsid);

	DWORD iHandle = 0;
	success = RegisterActiveObject(reinterpret_cast<IUnknown*>(object), clsid, ACTIVEOBJECT_STRONG, &iHandle);
	return iHandle;
	*/

	// First get IRunningObjectTable of the ROT
	IRunningObjectTable* pROT;
	HRESULT success = GetRunningObjectTable(0, &pROT);
	if (success != S_OK) return NULL;

	// Create moniker out of passed identifier
	IMoniker* pMoniker;
	success = CreateFileMoniker(sCLSID, &pMoniker);
	if (success != S_OK)
	{
		pROT->Release();
		return NULL;
	}

	// Registers an object
	DWORD iHandle = 0;
	success = pROT->Register(ROTFLAGS_REGISTRATIONKEEPSALIVE, reinterpret_cast<IUnknown*>(object), pMoniker, &iHandle);

	pMoniker->Release();
	pROT->Release();

	// Return get handle...
	if (success == S_OK) return iHandle;
	// ...or failure
	return NULL;
}


EXPORT(bool) UnRegisterObject(DWORD iHandle)
{
	// First get IRunningObjectTable of the ROT
	IRunningObjectTable* pROT;
	HRESULT success = GetRunningObjectTable(0, &pROT);
	if (success != S_OK) return FALSE;

	// Call Revoke
	success = pROT->Revoke(iHandle);

	// Release object
	pROT->Release();

	// Return success...
	if (success == S_OK) return TRUE;
	// ...or failure
	return FALSE;
}


EXPORT(void) MemoryCallEntry(DWORD e, DWORD f)
{
	if (e == 0xDEAD && f == 0xBEEF) {
#ifdef _RELEASE
		HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
		DWORD dwWritten;
		WriteFile(hStdout, "Lol. You found the easter-egg. \r\n", sizeof "Lol. You found the easter-egg. \r\n", &dwWritten, NULL);
		FlushFileBuffers(hStdout);
#else
		printf("Lol. You found the easter-egg. \r\n"); fflush(stdout);
#endif
	}
}


EXPORT(ULONG) IUnknownAddRef(IUnknown* object)
{
	return object->AddRef();
}


EXPORT(ULONG) IUnknownRelease(IUnknown* object)
{
	return object->Release();
}


EXPORT(PVOID) ReturnThis(PVOID anything)
{
	return anything;
}



INT debugprintW(const wchar_t* format, ...)
{
#ifndef _RELEASE
	va_list args;
	va_start(args, format);
	int ret = vwprintf(format, args);
	va_end(args);
	fflush(stdout);
	return ret;
#endif
	return 0;
}


INT Compare(const wchar_t* sString1, const wchar_t* sString2)
{
	return CompareStringW(LOCALE_SYSTEM_DEFAULT, NORM_IGNORECASE, sString1, -1, sString2, -1) - CSTR_EQUAL;
}


VARTYPE VarType(VARTYPE vtype, LPCWSTR wtype)
{
	if (vtype != VT_BSTR) return VT_ERROR;

	// Array of type identifiers
	static LPWSTR sTypeArray[] = {
		L"none", // 0
		L"byte", // 1
		L"boolean", L"bool", // 2, 3
		L"short", // 4
		L"ushort", L"word", // 5, 6
		L"dword", L"ulong", L"uint", // 7, 8, 9
		L"long", L"int", // 10, 11
		L"variant", // 12
		L"int64", // 13
		L"uint64", // 14
		L"float", // 15
		L"double", // 16
		L"hresult", // 17
		L"str", // 18
		L"wstr", // 19
		L"bstr", // 20
		L"ptr", // 21
		L"handle", L"hwnd", // 22, 23
		L"int_ptr", L"long_ptr", L"lresult", L"lparam", // 24, 25, 26, 27
		L"uint_ptr", L"ulong_ptr", L"dword_ptr", L"wparam", // 28, 29, 30, 31,
		L"idispatch", L"object" // 32, 33
	};

	// Array of matching types
	static VARTYPE VarTypeArray[] = {
		VT_EMPTY, // none
		VT_UI1, // byte
		VT_BOOL, // boolean
		VT_BOOL, // bool
		VT_I2, // short
		VT_UI2, // ushort
		VT_UI2, // word
		VT_UI4, // dword
		VT_UI4, // ulong
		VT_UI4, // uint
		VT_I4, // long
		VT_I4, // int
		VT_VARIANT, // variant
		VT_I8,  // int64
		VT_UI8,  // uint64
		VT_R4, // float
		VT_R8, // double
		VT_UI4, // hresult
		VT_LPSTR, // str
		VT_LPWSTR, // wstr
		VT_BSTR, // bstr
#ifdef _M_X64
		VT_UI8, // ptr
		VT_UI8, // handle
		VT_UI8, // hwnd
		VT_I8, // int_ptr
		VT_I8, // long_ptr
		VT_I8, // lresult
		VT_I8, // lparam
		VT_UI8, // uint_ptr
		VT_UI8, // ulong_ptr
		VT_UI8, // dword_ptr
		VT_UI8, // wparam
#else
		VT_UI4, // ptr
		VT_UI4, // handle
		VT_UI4, // hwnd
		VT_I4, // int_ptr
		VT_I4, // long_ptr
		VT_I4, // lresult
		VT_I4, // lparam
		VT_UI4, // uint_ptr
		VT_UI4, // ulong_ptr
		VT_UI4, // dword_ptr
		VT_UI4, // wparam
#endif
		VT_DISPATCH, // idispatch
		VT_DISPATCH // object
	};

	static DWORD iBound = sizeof(sTypeArray) / sizeof(PVOID);

	// For every element...
	for(DWORD i=0; i < iBound; i++)
	{
		if (Compare(sTypeArray[i], wtype)==0) return VarTypeArray[i];
	}

	// No match if here
	return VT_ILLEGAL;
}


VOID ObjPersist(PVOID ppv)
{
	// Will replicate certain behavior of OleCreate function to support persistence if possible
	// More info at http://msdn.microsoft.com/en-us/library/ms974281.aspx

	IUnknown* pUnk = reinterpret_cast<IUnknown*>(ppv);
	PVOID ppObj;

	if (pUnk->QueryInterface(IID_IPersistStreamInit, &ppObj) == S_OK)
	{
		IPersistStreamInit* pPersistStreamInit = reinterpret_cast<IPersistStreamInit*>(ppObj);
		pPersistStreamInit->InitNew();
		pPersistStreamInit->Release();
	}
	else if (pUnk->QueryInterface(IID_IPersistStorage, &ppObj) == S_OK)
	{
		IPersistStorage* pPersistStorage = reinterpret_cast<IPersistStorage*>(ppObj);
		pPersistStorage->InitNew(NULL);
		pPersistStorage->Release();
	}
}




