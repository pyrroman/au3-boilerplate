/** \mainpage Terra Informatica Sciter engine.
 *
 * \section legal_sec In legalese
 *
 * The code and information provided "as-is" without
 * warranty of any kind, either expressed or implied.
 *
 * <a href="http://terrainformatica.com/Sciter">Sciter Home</a>
 *
 * (C) 2003-2006, Terra Informatica Software, Inc. and Andrew Fedoniouk
 *
 * \section structure_sec Structure of the documentation
 *
 * See <a href="files.html">Files</a> section.
 **/

/**\file
 * \brief Application defined scripting classes.
 **/

#ifndef __sciter_x_scripting_h__
#define __sciter_x_scripting_h__

#include "sciter-x.h"
#include "sciter-x-value.h"
#include "tiscript.h"

typedef tiscript_VM* HVM;

// Returns scripting VM assosiated with Sciter HWND.
EXTERN_C HVM   SCAPI SciterGetVM( HWND hwnd );

// Calls method 'function' of the object 'obj' with parameters given as VALUEs rather tiscript_value. 
// This method can be used in inter-thread/inter-vm communications. 
EXTERN_C BOOL  SCAPI SciterCall_V( HVM vm, tiscript_value obj, const char* methodName, 
                                  const SCITER_VALUE* argv, unsigned int argn, SCITER_VALUE* pretval);

// Converts tiscript value handle to the json::value (VALUE) with optional isolation.
// tiscript::value handle is a handle that specific for particular VM
// json::value can be passed across different VMs, threads and can be stored outside VM heap.
// isolate==true - will create value that can be passed across thread and VM boundaries.
EXTERN_C BOOL  SCAPI Sciter_v2V(HVM vm, tiscript_value tisv, SCITER_VALUE* jsonv, BOOL isolate);

// Backward vonversion
EXTERN_C BOOL  SCAPI Sciter_V2v(HVM vm, const SCITER_VALUE* jsonv, tiscript_value* tisv);

#if defined(__cplusplus) && !defined( PLAIN_API_ONLY )
  namespace sciter
  {
    inline json::value v2v(tiscript::VM* vm, tiscript::value val, bool isolate = true)
    {
      json::value v;
      BOOL r = Sciter_v2V(vm,val,&v, BOOL(isolate));
      assert(r); r;
      return v;
    }
    inline tiscript::value v2v(tiscript::VM* vm, const json::value& val)
    {
      tiscript::value v;
      BOOL r = Sciter_V2v(vm,&val,&v);
      assert(r); r;
      return v;
    }
  }
#endif


///////////////////////////////////////////////////
///////////////////////////////////////////////////
///////  REST OF THE FILE IS DEPRECATED ///////////
///////////////////////////////////////////////////
///////////////////////////////////////////////////

//
// typedef of C/C++ "native" functions to be called from script.
// Shall return TRUE if retval contains valid value, return FALSE toerror.
//
OBSOLETE typedef VOID CALLBACK SciterNativeMethod_t( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, /*out*/ SCITER_VALUE* retval );
OBSOLETE typedef VOID CALLBACK SciterNativeProperty_t( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val );
OBSOLETE typedef VOID CALLBACK SciterNativeDtor_t( HVM hvm, LPVOID* p_data_slot_value );

OBSOLETE struct SciterNativeMethodDef
{
  LPCSTR                  name;
  SciterNativeMethod_t*   method;
};

OBSOLETE struct SciterNativePropertyDef
{
  LPCSTR                  name;
  SciterNativeProperty_t* property;
};

OBSOLETE struct SciterNativeConstantDef
{
  LPCSTR                  name;
  SCITER_VALUE            value;
  SciterNativeConstantDef( LPCSTR n,SCITER_VALUE v = SCITER_VALUE() ):name(n),value(v) {}
};

OBSOLETE struct SciterNativeClassDef
{
  const char*               name;
  SciterNativeMethodDef*    methods;
  SciterNativePropertyDef*  properties;
  SciterNativeDtor_t*       dtor;
  SciterNativeConstantDef*  constants;
};



//
// SciterNativeDefineClass - register "native" class to for the script.
// 
// params: 
//   p_class_def - pointer to class defintion (above).
// returns:
//   TRUE - if class was added successfully to script namespace, FALSE otherwise.
//

OBSOLETE EXTERN_C BOOL SCAPI SciterNativeDefineClass( HVM hvm, SciterNativeClassDef* pClassDef);

//
// SciterSetExceptionValue - set thrown message for the exception that will be generated when method returns.
// 
// params: 
//   error, LPCWSTR - error message.
//

OBSOLETE EXTERN_C BOOL SCAPI SciterSetExceptionValue( HVM hvm, LPCWSTR errorMsg);

//
// SciterNativeThrow - throw exception with the error message.
// 
// params: 
//   errorMsg, LPCWSTR - error message.
//

#define SciterNativeThrow(hvm, errorMsg)  do {  SciterSetExceptionValue( hvm, errorMsg ); return; }  while(0)
#define SciterNativeThrowR(hvm, errorMsg, retval)  do {  SciterSetExceptionValue( hvm, errorMsg ); return retval; }  while(0)

//
// SciterVmEval
// 
// params: 
//   HVM hvm - handle of script VM;
//   LPCWSTR script, UINT scriptLength - script to execute;
//   SCITER_VALUE* pretval - out, return value.

OBSOLETE EXTERN_C BOOL SCAPI SciterVmEval( HVM hvm, LPCWSTR script, UINT scriptLength, SCITER_VALUE* pretval);

//
// SciterVmEval
// 
// params: 
//   HVM hvm - handle of script VM;
//   LPCWSTR className - full name of the class;
//   SCITER_VALUE* pretval - out, created instance.
//  
//   Use this function to create instances of native and scripting classes:
//      SCITER_VALUE inst; 
//      SciterCreateObject(...,&inst);
//      inst.call("this", ...params...)

OBSOLETE EXTERN_C BOOL SCAPI SciterCreateObject( HVM hvm, LPCWSTR className, SCITER_VALUE* pretval);

#endif
