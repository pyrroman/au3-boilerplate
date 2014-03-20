#include "stdafx.h"

#include "sciterbar.h"

extern HWND ghWnd;

//SciterBar package.
//By definition SciterBar is a singleton, so no constructor implied.

// Forward declarations

VOID CALLBACK SciterBar_exit( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval );
VOID CALLBACK SciterBar_side( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val ); 
VOID CALLBACK SciterBar_animationTime( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val ); 

// method list of package SciterBar
static SciterNativeMethodDef  SciterBar_methods[] =
{
  { "exit",     &SciterBar_exit },
  { 0, 0 }     // zero terminated, sic!
};

// method list of package Utils
static SciterNativePropertyDef  SciterBar_properties[] =
{
  { "side",           &SciterBar_side },
  { "animationTime",  &SciterBar_animationTime },
  { 0, 0 } // zero terminated, sic!
};

// SciterBar package definition
SciterNativeClassDef SciterBarPackage = 
{
  "SciterBar",
  SciterBar_methods,
  SciterBar_properties, 
  0  // no destructor
};


// Init scripting classes
VOID InitNativeClasses(HWND hwnd)
{
  HVM hvm = SciterGetVM(hwnd);
  assert(hvm);
  
  SciterNativeDefineClass(hvm, &SciterBarPackage);
}



// implementation per se

VOID CALLBACK SciterBar_exit( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval )
{
  ::PostMessage(ghWnd, WM_CLOSE, 0, 0);
}

VOID CALLBACK SciterBar_side( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val )
{
   if( set )
   {
      unsigned int v =  val->get(0);
      if( v >= DOCK_SIDE_MAX)
         SciterNativeThrow( hvm, L"Wrong value of 'side' property" );
      SetBarSide( (DOCK_SIDE) v );
   }
   else //get
   {
      *val = SCITER_VALUE((int)GetBarSide());
   }
}

VOID CALLBACK SciterBar_animationTime( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val )
{
   if( set )
   {
      unsigned int v =  val->get(0);
      if( v > 5000)
         SciterNativeThrow( hvm, L"Gonna sleep lilbit, eh?" );
      SetBarAnimationTime( v );
   }
   else //get
   {
      *val = SCITER_VALUE((int)GetBarAnimationTime());
   }
}
