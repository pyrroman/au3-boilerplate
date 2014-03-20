// just in case we will want to expose some functions from the DLL:

#ifdef SCITERFERRY_EXPORTS
#define SCITERFERRY_API __declspec(dllexport)
#else
#define SCITERFERRY_API __declspec(dllimport)
#endif

#include "sciter-x.h"
#include <string>

using namespace sciter;

#define BEHAVIOR_NAME "editor"

struct editor : 
  // public ferry::...,
  public sciter::event_handler
{
  HELEMENT      self; // weak ref (not addrefed)

  std::wstring  text_to_draw;
  int xpos;
  int ypos;

  // this behavior has been attached to the DOM element
  virtual void attached  (HELEMENT he ) 
  {
    self = he;
    text_to_draw = dom::element(self).get_attribute("text",L"Hello world!");
    xpos = 0;
    ypos = 0;

  } 
  // this behavior has been detached from the DOM element (self) 
  virtual void detached  (HELEMENT he ) 
  { 
    self = 0;
    delete this; // 
  } 
 
  virtual bool handle_mouse  (HELEMENT he, MOUSE_PARAMS& params );
  virtual bool handle_key    (HELEMENT he, KEY_PARAMS& params );
  virtual bool handle_focus  (HELEMENT he, FOCUS_PARAMS& params );
  virtual bool handle_timer  (HELEMENT he,TIMER_PARAMS& params );
  virtual void handle_size   (HELEMENT he );
  virtual bool handle_scroll (HELEMENT he, SCROLL_PARAMS& params );
  virtual bool handle_draw   (HELEMENT he, DRAW_PARAMS& params );
  virtual bool handle_scripting_call(HELEMENT he, SCRIPTING_METHOD_PARAMS& params );

};
