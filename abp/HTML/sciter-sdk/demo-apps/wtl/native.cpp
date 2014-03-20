#include "stdafx.h"

#include "sciter-x.h"
#include "sciter-x-script.h"

#include "tiscript.hpp"


//WtlApp package.
//By definition WtlApp is a singleton, so no constructor implied.

HWND ghWnd = 0;

// Forward declarations

VOID CALLBACK WtlApp_ctor( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval );
VOID CALLBACK WtlApp_exit( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval );
VOID CALLBACK WtlApp_area( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval );

VOID CALLBACK WtlApp_version( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val );
VOID CALLBACK WtlApp_caption( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val );


// method list of package WtlApp
static SciterNativeMethodDef  WtlApp_methods[] =
{
  { "this",     &WtlApp_ctor },
  { "exit",     &WtlApp_exit },
  { "area",     &WtlApp_area },
  { 0, 0 }     // zero terminated, sic!
};

// method list of package Utils
static SciterNativePropertyDef  WtlApp_properties[] =
{
  { "version",  &WtlApp_version },
  { "caption",  &WtlApp_caption },
  { 0, 0 } // zero terminated, sic!
};

// WtlApp package definition
SciterNativeClassDef WtlAppPackage = 
{
  "WtlApp",
  WtlApp_methods,
  WtlApp_properties, 
  0  // no destructor
};




// implementation per se

VOID CALLBACK WtlApp_exit( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval )
{
  ::PostMessage(::GetParent(ghWnd), WM_CLOSE,0,0);
}

// constructor
VOID CALLBACK WtlApp_ctor( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval )
{
   self->set_object_data(ghWnd);
}


VOID CALLBACK WtlApp_area( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval )
{
  if(argc != 2)
     SciterNativeThrow( hvm, L"area(x,y)" );
  int x = argv[0].get(0);
  int y = argv[1].get(0);
  *retval = SCITER_VALUE(x * y); 

}


VOID CALLBACK WtlApp_version( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val )
{
   if( set )
   {
      //unsigned int v =  val->get(0);
      //if( v >= DOCK_SIDE_MAX)
      SciterNativeThrow( hvm, L"Read only property" );
      //SetBarSide( (DOCK_SIDE) v );
   }
   else //get
   {
      *val = SCITER_VALUE(L"1.0.0.1");
   }
}

VOID CALLBACK WtlApp_caption( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val )
{
   //HWND hwnd = ghWnd; // <<< use this if you want this property to be class property rather than instance property.
   HWND hwnd = (HWND) self->get_object_data();
   if( !hwnd )
     SciterNativeThrow( hvm, L"This is instance only property" );

   if( set )
   {
      SetWindowTextW(::GetParent(ghWnd), val->get(L"").c_str());
   }
   else //get
   {
     wchar_t buf[256];
     GetWindowTextW(::GetParent(ghWnd), buf, 256);
     *val = SCITER_VALUE(buf);
   }
}


//#include "TSTestNative.h"

static int counter = 0;

tiscript_value TISAPI TSTestNativeDef_ctor(tiscript_VM* vm)
{
  tiscript::pinned self;
  tiscript_value retVal;
  try
  {
    tiscript::args(vm)
      >> self // this.
      >> tiscript::args::skip; // skip 'super'
    retVal = self; 
  } 
  catch (tiscript::args::error &e)
  {
    tiscript::throw_error(vm, e.msg());
    retVal = tiscript::v_null(); 
  };
  return retVal;
};

tiscript_value TISAPI TSTestNativeDef_test(tiscript_VM* vm)
{
  tiscript::pinned self;
  tiscript_value retVal;
  try
  {
    tiscript::args(vm)
      >> self // this.
      >> tiscript::args::skip; // skip 'super'
    if(counter < 100)
    {
      counter += 1;
      retVal = tiscript::v_int(counter);
    }
    else
    {
      tiscript::throw_error(vm, L"counter limit 1000");
      retVal = tiscript::v_undefined();
    }; 
  } 
  catch (tiscript::args::error &e)
  {
    tiscript::throw_error(vm, e.msg());
    retVal = tiscript::v_null(); 
  };
  return retVal;
};

tiscript_value TISAPI TSTestNativeDef_testArrayOfObjects(tiscript_VM* vm)
{
  tiscript::array_ref records(vm);
  records.create();
  for (int i = 0; i < 10; i++)
  {
     tiscript::object_ref record(vm);
     record.create();
     record.set("Data", tiscript::v_string(vm,aux::itow(i)) );
     record.set("Text", tiscript::v_string(vm,aux::itow(i)) );
     records.push(record); //<- !!!AV
  }
  return records;
};


tiscript_value TISAPI TSTestNativeDef_setcounter(tiscript_VM* vm)
{
  tiscript::pinned self;
  tiscript_value retVal;
  try
  {
    tiscript::args(vm)
      >> self // this.
      >> tiscript::args::skip; // skip 'super'
    counter = 1000;
    retVal = tiscript::v_undefined(); 
  } 
  catch (tiscript::args::error &e)
  {
    tiscript::throw_error(vm, e.msg());
    retVal = tiscript::v_undefined(); 
  };
  return retVal;
};

tiscript_value TSTestNativeDef_get_test1(tiscript_VM * vm, tiscript_value self)
{ 
  tiscript_value retVal;
  if(counter < 100)
  {
    counter += 1;
    retVal = tiscript::v_int(counter);
  }
  else
  {
    tiscript::throw_error(vm, L"counter limit 1000");
    retVal = tiscript::v_undefined();
  };
  return retVal;
};



static tiscript::prop_def TSTestNativeDef_props[] = 
{
  tiscript::prop_def("test1", &TSTestNativeDef_get_test1, 0),
  tiscript::prop_def()
};

static tiscript::method_def TSTestNativeDef_methods[] = 
{
  tiscript::method_def("this", TSTestNativeDef_ctor),
  tiscript::method_def("test", TSTestNativeDef_test),
  tiscript::method_def("arrayOfObjects", TSTestNativeDef_testArrayOfObjects),
  tiscript::method_def("setcounter", TSTestNativeDef_setcounter),
  tiscript::method_def()
};

tiscript_class_def TSTestNativeDef = 
{
  "TSTestNative",
  TSTestNativeDef_methods,
  TSTestNativeDef_props, 
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
};


// Init scripting classes
VOID InitNativeClasses(HWND hwnd)
{
  ghWnd = hwnd;
  HVM hvm = SciterGetVM(hwnd);
  assert(hvm);
  
  SciterNativeDefineClass(hvm, &WtlAppPackage);
  tiscript::define_class(hvm, &TSTestNativeDef);
}







