#include "stdafx.h"

#include "mainfrm.h"

#include "sciter-x.h"
#include "sciter-x-script.h"

extern DWORD OpenNewSciter( const json::string& cmdLine, int nCmdShow, json::value param );

enum WINDOW_STATE 
{
  STATE_HIDDEN = 0,
  STATE_SHOWN,
  STATE_MINIMIZED,
  STATE_MAXIMIZED,
};


WINDOW_STATE getState(HWND hwnd)
{
   if(!::IsWindowVisible(hwnd))
     return STATE_HIDDEN;

   WINDOWPLACEMENT wpl = {sizeof(wpl)}; 
   GetWindowPlacement(hwnd,&wpl);
   switch(wpl.showCmd)
   {
      case SW_HIDE: return STATE_HIDDEN; 

      case SW_MINIMIZE:
      case SW_SHOWMINNOACTIVE: 
      case SW_SHOWMINIMIZED: return STATE_MINIMIZED;

      case SW_MAXIMIZE: return STATE_MAXIMIZED; 
   }
   return STATE_SHOWN;
}

void setState(HWND hwnd, WINDOW_STATE nst)
{
    WINDOW_STATE st = getState(hwnd);
    UINT cmd = SW_SHOW;
    switch(nst)
    {
      case STATE_SHOWN: 
        cmd = (st == STATE_MAXIMIZED || st == STATE_MINIMIZED)? SW_RESTORE:SW_SHOW; 
        break;
      case STATE_MAXIMIZED: 
        if(st == STATE_MAXIMIZED) return;
        cmd = SW_SHOWMAXIMIZED; 
        break;
      case STATE_MINIMIZED: 
        if(st == STATE_MINIMIZED) return;
        cmd = SW_SHOWMINIMIZED; 
        break;
      case STATE_HIDDEN: 
        if(st == STATE_HIDDEN) return;
        cmd = SW_HIDE; 
        break;
        //cmd = st == SW_SHOW; break;
    }
    ShowWindow(hwnd,cmd);
}

void TISAPI callback(tiscript_VM *c,void* prm)
{
  HWND hwnd = HWND(prm);
  sciter::dom::element root = sciter::dom::element::root_element(hwnd);
  tiscript::call(c,root.get_object(),"tick");
}

DWORD WINAPI ThreadProc(LPVOID lpParameter)
{
  HVM vm = SciterGetVM(HWND(lpParameter));
  for( int n = 0; n < 20; ++n )
  {
    tiscript::post(vm,callback,lpParameter);
    Sleep(1000);
  }
  return 0;
}

void TestThread(HWND hwnd)
{
  CreateThread(0,0,ThreadProc,hwnd,0,0);
}

bool CMainFrame::handle_scripting_call(HELEMENT he, SCRIPTING_METHOD_PARAMS& params )
{
   #define METHOD(ARGC, NAME) if( params.argc == ARGC && aux::streqi(params.name,#NAME) )

METHOD(1,open) // view.open("url") - opens new window in the new thread
    {
      if( !params.argv[0].is_string() )
        SciterNativeThrowR(VM(),L"url is not a string", false);
      OpenNewSciter( params.argv[0].to_string(), SW_SHOW, json::value());
      return true;    
    }
METHOD(2,open) // view.open("url", obj) - opens new window in the new thread with parematers (obj)
    {
      if( !params.argv[0].is_string() )
        SciterNativeThrowR(VM(),L"url is not a string", false);
      json::value p = params.argv[1]; 
      p.isolate(); // before passing to new thread...
      OpenNewSciter( params.argv[0].to_string(), SW_SHOW, p); 
      return true;
    }
METHOD(0,windowState) // getter, if(view.windowState() == #STATE_SHOWN)
    {
      WINDOW_STATE ws = getState(m_hWnd);
      switch( ws )
      {
        case STATE_SHOWN: params.result = json::value::symbol( const_wchars("STATE_SHOWN") ); break;
        case STATE_HIDDEN: params.result = json::value::symbol( const_wchars("STATE_HIDDEN") ); break;
        case STATE_MINIMIZED: params.result = json::value::symbol( const_wchars("STATE_MINIMIZED") ); break;
        case STATE_MAXIMIZED: params.result = json::value::symbol( const_wchars("STATE_MAXIMIZED") ); break;
      }
      return true;
    }
METHOD(1,windowState) // setter, view.windowState(#STATE_SHOWN);
    {
      WINDOW_STATE ws = STATE_SHOWN;
      if( !params.argv[0].is_string() )
        SciterNativeThrowR(VM(),L"state is not a symbol", false);

      json::string s = params.argv[0].get(L"");

      if( s == const_wchars("STATE_SHOWN") )
       ws = STATE_SHOWN;
      else if( s == const_wchars("STATE_HIDDEN") )
       ws = STATE_HIDDEN;
      else if( s == const_wchars("STATE_MINIMIZED") )
       ws = STATE_MINIMIZED;
      else if( s == const_wchars("STATE_MAXIMIZED") )
       ws = STATE_MAXIMIZED;
      else
        SciterNativeThrowR(VM(),L"bad type of state", false);
      setState( m_hWnd, ws );
      return true;
    }
METHOD(0,close) // view.close();
    {
      ::PostMessage(m_hWnd, WM_CLOSE,0,0); 
      return true; 
    }

METHOD(0,testThread) // view.close();
    {
      TestThread(m_hWnd);
      return true; 
    }
   
   #undef METHOD

  return event_handler::handle_scripting_call(he,params);

}



#if 00000000000 // not used for a while

// Window class.
// Forward declarations

//VOID CALLBACK Window_ctor( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval );
VOID CALLBACK Window_close( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval );
VOID CALLBACK Window_box( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval );
VOID CALLBACK Window_move( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval );

VOID CALLBACK Window_caption( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val );
VOID CALLBACK Window_icon( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val );
VOID CALLBACK Window_state( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val );

// method list of package WtlApp
static SciterNativeMethodDef  Window_methods[] =
{
//  { "this",      &Window_ctor },
  { "close",     &Window_close },
  { "move",      &Window_move },
  { "box",       &Window_box },
  { 0, 0 }     // zero terminated, sic!
};

// method list of package Utils
static SciterNativePropertyDef  Window_properties[] =
{
  { "caption",  &Window_caption },
  { "icon",     &Window_icon },
  { "state",    &Window_state },
  { 0, 0 } // zero terminated, sic!
};

static SciterNativeConstantDef  Window_constants[] =
{
  SciterNativeConstantDef("STATE_SHOWN",STATE_SHOWN),
  SciterNativeConstantDef("STATE_HIDDEN",STATE_HIDDEN),
  SciterNativeConstantDef("STATE_MINIMIZED",STATE_MINIMIZED),
  SciterNativeConstantDef("STATE_MAXIMIZED",STATE_MAXIMIZED),
  SciterNativeConstantDef(0) // zero terminated, sic!
};

// WtlApp package definition
SciterNativeClassDef WindowPackage = 
{
  "Window",
  Window_methods,
  Window_properties, 
  0, // no destructor
  Window_constants,
};

// Init scripting classes
VOID InitNativeClasses(HWND hwnd)
{
  HVM hvm = SciterGetVM(hwnd);
  assert(hvm);
  SciterNativeDefineClass(hvm, &WindowPackage);
}

// implementation per se

VOID CALLBACK Window_close( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval )
{
  HWND hwnd = (HWND)self->get_object_data();
  ::PostMessage(hwnd, WM_CLOSE,0,0);
}

// constructor
/*VOID CALLBACK Window_ctor( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval )
{
   self->set_object_data(ghWnd);
}*/


VOID CALLBACK Window_box( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval )
{
  if(argc != 2)
     SciterNativeThrow( hvm, L"area(x,y)" );
  int x = argv[0].get(0);
  int y = argv[1].get(0);
  *retval = SCITER_VALUE(x * y); 
}
VOID CALLBACK Window_move( HVM hvm, SCITER_VALUE* self, SCITER_VALUE* argv, INT argc, SCITER_VALUE* retval )
{
  if(argc != 2)
     SciterNativeThrow( hvm, L"area(x,y)" );
  int x = argv[0].get(0);
  int y = argv[1].get(0);
  *retval = SCITER_VALUE(x * y); 
}



VOID CALLBACK Window_icon( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val )
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

VOID CALLBACK Window_caption( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val )
{
   //HWND hwnd = ghWnd; // <<< use this if you want this property to be class property rather than instance property.
   HWND hwnd = (HWND) self->get_object_data();
   if( !hwnd )
     SciterNativeThrow( hvm, L"This is instance only property" );
   if( set )
   {
      SetWindowTextW(hwnd, val->get(L"").c_str());
   }
   else //get
   {
     wchar_t buf[256];
     GetWindowTextW(hwnd, buf, 256);
     *val = SCITER_VALUE(buf);
   }
}

VOID CALLBACK Window_state( HVM hvm, SCITER_VALUE* self, BOOL set, /*in-set/out-get*/ SCITER_VALUE* val )
{
   //HWND hwnd = ghWnd; // <<< use this if you want this property to be class property rather than instance property.
   HWND hwnd = (HWND) self->get_object_data();
   if( !hwnd )
     SciterNativeThrow( hvm, L"This is instance only property" );
   
   if( set )
   {
      WINDOW_STATE st = getState(hwnd);
      UINT cmd = 0;
      switch(val->get(STATE_SHOWN))
      {
        default:
        case STATE_SHOWN: 
          cmd = (st == STATE_MAXIMIZED || st == STATE_MINIMIZED)? SW_RESTORE:SW_SHOW; 
          break;
        case STATE_MAXIMIZED: 
          if(st == STATE_MAXIMIZED) return;
          cmd = SW_SHOWMAXIMIZED; 
          break;
        case STATE_MINIMIZED: 
          if(st == STATE_MINIMIZED) return;
          cmd = SW_SHOWMINIMIZED; 
          break;
        case STATE_HIDDEN: 
          if(st == STATE_HIDDEN) return;
          cmd = SW_HIDE; 
          break;
          //cmd = st == SW_SHOW; break;
      }
      ShowWindow(hwnd,cmd);
   }
   else //get
   {
     WINDOWPLACEMENT wpl = {sizeof(wpl)}; 
     GetWindowPlacement(hwnd,&wpl);
     switch(wpl.showCmd)
     {
        case SW_HIDE: *val = STATE_HIDDEN; break;

        case SW_MINIMIZE:
        case SW_SHOWMINNOACTIVE: 
        case SW_SHOWMINIMIZED: *val = STATE_MINIMIZED; break;

        case SW_MAXIMIZE: *val = STATE_MAXIMIZED; break;

        default:
          *val = STATE_SHOWN; break;
     }
   }
}

#endif //0