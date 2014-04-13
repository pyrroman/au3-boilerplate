#include "stdafx.h"
#include "sciter-x-behavior.h"
#include "sciter-x-host-callback.h"

namespace sciter 
{
  /*
  BEHAVIOR: windowed-frame
     goal: child Sciter window
  COMMENTS: 
     <iframe style="behavior:windowed-frame" src="url of the document to load" />
  SAMPLE:
     sciter/sdk/samples/behaviors/behavior_windowed_frame.htm
  */

  struct windowed_frame: public notification_handler<windowed_frame>,
                         public event_handler, 
                         public behavior_factory
  {
    // ctor
    windowed_frame(): event_handler(), 
            behavior_factory("windowed-frame")
    {}

    // sciter::notification_handler pre-requisites
    // this method needed for on_load_data(LPSCN_LOAD_DATA pnmld) default handler
    HINSTANCE get_resource_instance() { return _Module.GetResourceInstance(); }

    // the only behavior_factory method:
    virtual event_handler* create(HELEMENT he) { return this; }

    // event_handler methods:
    virtual void attached  (HELEMENT he ) 
    { 
      dom::element self = he;
      json::string src = self.get_attribute("src",L"");
      
      HWND hwndParentSciter = self.get_element_hwnd(true); // get parent sciter

      HWND hwnd = ::CreateWindowEx(0, SciterClassNameT(), NULL, WS_CHILD | WS_VISIBLE,0,0,0,0,
                                   hwndParentSciter,0,_Module.GetModuleInstance(),0);
      ::SciterAttachHwndToElement(he,hwnd);

      //notification_handler::setup_callback() call:
      setup_callback(hwnd);

      if(src.length())
      {
        src = self.combine_url(src);
        ::SciterLoadFile(hwnd, src);
      }

    } 

    virtual void detached  (HELEMENT he ) 
    { 
      dom::element self = he;
      HWND hwnd = self.get_element_hwnd(false); // get HWND of this sciter instance attached to the element
      ::SciterAttachHwndToElement(he,0);
      ::DestroyWindow(hwnd);
    } 
  };

  // instantiating and attaching it to the global list
  windowed_frame windowed_frame_instance;
}
