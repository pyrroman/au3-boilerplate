#include "stdafx.h"

#include "sciter-x.h"
#include "sciter-x-behavior.h"

#include <windows.h>
#include <commctrl.h>
#include <shellapi.h>

namespace sciter 
{

/*
BEHAVIOR: shell-icon
    goal: Renders icon associated with the file with the given extension.
TYPICAL USE CASE:
    <img class="shell-icon" filename="something.png" /> 
    will render icon for the png files registered in system if style of such image will be defined as:
STYLE:
    img.shell-icon { width:18px; height:18px; behavior:shell-icon;  } 
*/

struct shellicon: 
     public event_handler, 
     public behavior_factory // we do not create separate instances 
{
    // ctor
    shellicon(): behavior_factory("shell-icon") {}

    virtual event_handler* create(HELEMENT he) 
    {
       return this; 
    }
    
    virtual bool handle_draw   (HELEMENT he, DRAW_PARAMS& params )
    { 
      if( params.cmd != DRAW_CONTENT )
        return false; /*do default draw*/ 

      dom::element el = he;
      const wchar_t* path = el.get_attribute("filename");
      if( !path )
        return false;  // no such attribute at all.

      const wchar_t* filename = wcsrchr(path,'/') ;
      if( !filename ) filename = path;

      SHFILEINFOW sfi; memset(&sfi,0,sizeof(sfi));
#ifdef UNDER_CE
      HIMAGELIST hlist = (HIMAGELIST) SHGetFileInfo( filename, 0, &sfi, sizeof(sfi), SHGFI_USEFILEATTRIBUTES | SHGFI_SYSICONINDEX | SHGFI_SMALLICON );
#else
      HIMAGELIST hlist = (HIMAGELIST) SHGetFileInfoW( filename, 0, &sfi, sizeof(sfi), SHGFI_USEFILEATTRIBUTES | SHGFI_SYSICONINDEX | SHGFI_SMALLICON );
#endif
      if(!hlist)
        return FALSE;
      
      int szx = 16;
      int szy = 16;
      ImageList_GetIconSize(hlist, &szx, &szy);

      RECT rc_padding = el.get_location( ROOT_RELATIVE | PADDING_BOX );
      RECT rc_content = el.get_location( ROOT_RELATIVE | CONTENT_BOX );

      // we are drawing the icon in paddin area of the element.
      int x = rc_padding.left;// + (rc_content.left - rc_padding.left - szx) / 2;
      int y = rc_content.top + (rc_content.bottom - rc_content.top - szy) / 2;

      ImageList_Draw(hlist, sfi.iIcon, params.hdc, x, y, ILD_TRANSPARENT); 
           
      return false; /*do default draw on top of this*/ 
    }
   
};

// instantiating and attaching it to the global list
shellicon shellicon_instance;

} // htmlayout namespace


