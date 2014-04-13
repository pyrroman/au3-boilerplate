// sciterferry.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include <stdlib.h>
#include "sciterferry.h"


/** Each sciter extension module shall include function 
 */
EXTERN_C BOOL WINAPI SciterBehaviorFactory( LPCSTR name, HELEMENT he, LPELEMENT_EVENT_PROC* func, LPVOID* tag )
{
  if(name && strcmp(name, BEHAVIOR_NAME) == 0) // << this DLL contains implementation of the "editor" behavior only
  {
    editor *wp = new editor();
    *func = editor::element_proc;
    *tag = (sciter::event_handler*)wp;
    return TRUE;
  }
  return FALSE;
}

bool editor::handle_mouse  (HELEMENT he, MOUSE_PARAMS& params )
{
  switch(params.cmd)
  {
    case MOUSE_ENTER:
    case MOUSE_LEAVE:
    case MOUSE_MOVE:
    case MOUSE_UP:
    case MOUSE_DOWN:
    case MOUSE_DCLICK:
    case MOUSE_WHEEL:
    case MOUSE_TICK: // mouse pressed ticks
    case MOUSE_IDLE: // mouse stay idle for some time
      return true;
  }
  return false;
}
bool editor::handle_key    (HELEMENT he, KEY_PARAMS& params )
{
  switch(params.cmd)
  {
    case KEY_DOWN: // aka WM_KEYDOWN
    case KEY_UP:   // aka WM_KEYUP
    case KEY_CHAR: // aka WM_CHAR, params.key_code == unicode of the char
      dom::element(self).refresh(); // refresh it as a whole
      return true;
  }
  return false;
}
bool editor::handle_focus  (HELEMENT he, FOCUS_PARAMS& params )
{
  switch(params.cmd)
  {
    case FOCUS_LOST:  dom::element(self).stop_timer(); return true;// for the demo purposes
    case FOCUS_GOT:   dom::element(self).start_timer(1000); return true; // for the demo purposes
  }
  return false;
}
bool editor::handle_timer  (HELEMENT he,TIMER_PARAMS& params )
{
  dom::element(self).refresh(); // refresh it as a whole
  return true; // to keep it ticking.
}
void editor::handle_size   (HELEMENT he )
{
  RECT rc = dom::element(self).get_location(SELF_RELATIVE | CONTENT_BOX); rc;
  // rc.right - rc.left == width
  // rc.bottom - rc.top == height
}
bool editor::handle_scroll (HELEMENT he, SCROLL_PARAMS& params )
{
  switch( params.cmd )
  {
  case SCROLL_HOME:
  case SCROLL_END:
  case SCROLL_STEP_PLUS:
  case SCROLL_STEP_MINUS:
  case SCROLL_PAGE_PLUS:
  case SCROLL_PAGE_MINUS: return true;
  case SCROLL_POS: if(params.vertical) ypos = params.pos; else  xpos = params.pos; 
                   dom::element(self).refresh();
                   return true; 
  }
  return false;
}
bool editor::handle_draw   (HELEMENT he, DRAW_PARAMS& params )
{
  if( params.cmd != DRAW_CONTENT) // we draw here only the content layer. 
    return false; 
  
  RECT  rc = dom::element(self).get_location(ROOT_RELATIVE | CONTENT_BOX);
  
  COLORREF clr = rand() & 0xFFFFFF;
  HBRUSH   brush = ::CreateSolidBrush(clr);
  HGDIOBJ  prev_brush = ::SelectObject(params.hdc,brush);
  ::FillRect(params.hdc,&rc,brush);
  ::SelectObject(params.hdc,prev_brush);
  ::DeleteObject(prev_brush);

  if(text_to_draw.length())
  {
    wchar_t buf[256];
    int n = swprintf(buf,L"%s x=%d y=%d", text_to_draw.c_str(), xpos, ypos );

    COLORREF pclr = ::SetTextColor(params.hdc, (~clr) & 0xFFFFFF);
    ::DrawTextW(params.hdc,
      buf, n,
      &rc,
      DT_SINGLELINE|DT_CENTER|DT_VCENTER);
    ::SetTextColor(params.hdc, pclr);
  }
  return true;
}

bool editor::handle_scripting_call(HELEMENT he, SCRIPTING_METHOD_PARAMS& params )
{
  #define ACTION(ARGC, NAME) if( params.argc == ARGC && aux::streqi(params.name,#NAME) )

  ACTION(0,textToDraw) // getter
  {
    params.result = SCITER_VALUE(text_to_draw.c_str());
    return true;
  }
  ACTION(1,textToDraw) // setter
  {
    text_to_draw = params.argv[0].to_string();
    dom::element(self).refresh(); // refresh it as a whole
    return true;
  }

  #undef ACTION
  return false;
}
