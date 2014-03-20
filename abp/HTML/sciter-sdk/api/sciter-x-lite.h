/** \mainpage Terra Informatica Sciter engine, windowless API.
 *
 * \section legal_sec In legalese
 *
 * The code and information provided "as-is" without
 * warranty of any kind, either expressed or implied.
 *
 * <a href="http://terrainformatica.com/sciter">Sciter Home</a>
 *
 * (C) 2003-2006, Terra Informatica Software, Inc. and Andrew Fedoniouk
 *
 * \section structure_sec Structure of the documentation
 *
 * See <a href="files.html">Files</a> section.
 **/

/*!\file
\brief SciterLite - Windowless but still interactive HTML/CSS/Scripting engine. 
*/


#ifndef __sciter_x_lite_h__
#define __sciter_x_lite_h__

#include "sciter-x.h"

struct LITE_CTL;
typedef LITE_CTL* SCILITE;

typedef enum tagSCLRESULT
{
  SCL_OK = 0,
  SCL_INVALID_HANDLE,
  SCL_INVALID_FORMAT,
  SCL_FILE_NOT_FOUND,
  SCL_INVALID_PARAMETER,
  SCL_INVALID_STATE, // attempt to do operation on empty document
} SCLRESULT;


/** REFRESH_AREA notification.
 *
 * - SC_REFRESH_AREA
 * 
 **/
#define SC_REFRESH_AREA 0xAFF + 0x20

typedef struct tagSCN_REFRESH_AREA : SCITER_CALLBACK_NOTIFICATION
{
    RECT      area;             /**< [in] area to refresh.*/
} SCN_REFRESH_AREA, FAR *LPSCN_REFRESH_AREA;

/** SC_SET_TIMER notification.
 *
 * - SC_SET_TIMER
 * 
 **/
#define SC_SET_TIMER 0xAFF + 0x21

typedef struct tagSCN_SET_TIMER : SCITER_CALLBACK_NOTIFICATION
{
    UINT_PTR  timerId;          /**< [in] id of the timer event.*/
    UINT      elapseTime;       /**< [in] elapseTime of the timer event, milliseconds. 
                                          If it is 0 then this timer has to be stoped. */
} SCN_SET_TIMER, FAR *LPSCN_SET_TIMER;


/** SC_SET_CURSOR notification.
 *
 * - SC_SET_CURSOR
 * 
 **/
#define SC_SET_CURSOR (0xAFF + 0x22)

typedef struct tagSCN_SET_CURSOR : SCITER_CALLBACK_NOTIFICATION
{
    UINT      cursorId;         /**< [in] id of the cursor, .*/

} SCN_SET_CURSOR, FAR *LPSCN_SET_CURSOR;


/** SC_UPDATE_UI notification.
 *
 * - SC_UPDATE_UI - host has to present rendering buffer to the user upon reciving of this notification.
 *                  The notification is used by animations.
 * 
 **/
#define SC_UPDATE_UI (0xAFF + 0x23)

/** Create instance of the engine 
 * \return \b SCILITE, instance handle of the engine.
 **/
EXTERN_C  SCILITE SCAPI SciliteCreateInstance();

/** Destroy instance of the engine
 * \param[in] hLite \b SCILITE, handle.
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteDestroyInstance(SCILITE hLite);

/** Set custom tag value to the instance of the engine.
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] tag \b LPVOID, any pointer.
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteSetTag(SCILITE hLite, LPVOID tag);

/** Get custom tag value from the instance of the engine.
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] tag \b LPVOID*, pointer to value receiving tag value.
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteGetTag(SCILITE hLite, LPVOID *tag);

/** Load HTML from file 
 * \param[in] hLite \b SCILITE, handle.
 * \param[out] path \b LPCWSTR, path or URL of the html file to load.
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteLoadFromFile(SCILITE hLite, LPCWSTR path);

/** Load HTML from memory buffer 
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] baseURI \b LPCWSTR, base url.
 * \param[in] dataptr \b LPCBYTE, pointer to the buffer
 * \param[in] datasize \b DWORD, length of the data in the buffer
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteLoadFromBytes(SCILITE hLite, LPCWSTR baseURI, LPCBYTES dataptr, UINT datasize);

/** Replace Sciter view on window
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] hwnd \b HWND, window handle hosting Scilite.
 * \param[in] viewX \b INT, horizontal position of the view area.
 * \param[in] viewY \b INT, vertical position of the view area.
 * \param[in] viewWidth \b INT, width of the view area.
 * \param[in] viewHeight \b INT, height of the view area.
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteReplace(SCILITE hLite, 
          HWND hwnd, INT viewX, INT viewY, INT viewWidth, INT viewHeight);

/** Render HTML
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] hdc \b HDC, device context
 * \param[in] x \b INT, x,y,sx and sy have the same meaning as rcPaint in PAINTSTRUCT
 * \param[in] y \b INT, 
 * \param[in] sx \b INT, 
 * \param[in] sy \b INT, "dirty" rectangle coordinates.
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteRender(SCILITE hLite, HDC hdc, 
          INT x,  // x position of area to render in pixels  
          INT y,  // y position of area to render in pixels  
          INT sx, // width of area to render in pixels  
          INT sy); // height of area to render in pixels  

/** Render HTML on 24bpp or 32bpp dib 
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] hbmp \b HBITMAP, device context
 * \param[in] x \b INT, 
 * \param[in] y \b INT, 
 * \param[in] sx \b INT, 
 * \param[in] sy \b INT, "dirty" rectangle coordinates.
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteRenderOnBitmap(SCILITE hLite, HBITMAP hbmp, 
          INT x,    // x position of area to render  
          INT y,    // y position of area to render  
          INT sx,   // width of area to render  
          INT sy);  // height of area to render  


/**This function is used in response to SC_LOAD_DATA request. 
 *
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] uri \b LPCWSTR, URI of the data requested by HTMLayout.
 * \param[in] data \b LPBYTE, pointer to data buffer.
 * \param[in] dataSize \b DWORD, length of the data in bytes.
 *
 **/
EXTERN_C  SCLRESULT SCAPI SciliteSetDataReady(SCILITE hLite, LPCWSTR url, LPCBYTE data, DWORD dataSize);

/**Use this function outside of SC_LOAD_DATA request. This function is needed when you
 * you have your own http client implemented in your application.
 *
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] uri \b LPCWSTR, URI of the data requested by HTMLayout.
 * \param[in] data \b LPBYTE, pointer to data buffer.
 * \param[in] dataLength \b DWORD, length of the data in bytes.
 * \param[in] dataType \b UINT, type of resource to load. See HTMLayoutResourceType.
 * \return \b BOOL, TRUE if HTMLayout accepts the data or \c FALSE if error occured 
 **/

EXTERN_C  SCLRESULT SCAPI SciliteSetDataReadyAsync(SCILITE hLite, LPCWSTR uri, LPCBYTE data, DWORD dataSize, LPVOID requestId);

/**Get minimum width of loaded document 
 * ATTN: for this method to work document shall have following style:
 *    html { overflow: none; }
 * Otherwize consider to use
 *    HTMLayoutGetScrollInfo( root, ... , LPSIZE contentSize );  
 **/
EXTERN_C  SCLRESULT SCAPI SciliteGetDocumentMinWidth(SCILITE hLite, LPINT v);

/**Get minimum height of loaded document 
 **/
EXTERN_C  SCLRESULT SCAPI SciliteGetDocumentMinHeight(SCILITE hLite, LPINT v);

/**Set media type for CSS engine, use this before loading the document
 * \See: http://www.w3.org/TR/REC-CSS2/media.html 
 **/
EXTERN_C  SCLRESULT SCAPI SciliteSetMediaType(SCILITE hLite, LPCSTR mediatype);

/**Get root DOM element of loaded HTML document. 
 * \param[in] hLite \b SCILITE, handle.
 * \param[out] phe \b HELEMENT*, address of variable receiving handle of the root element (<html>).
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteGetRootElement(SCILITE hLite, HELEMENT* phe);


/** Find DOM element by point (x,y). 
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] x \b INT, x coordinate of the point.
 * \param[in] y \b INT, y coordinate of the point.
 * \param[in] phe \b HELEMENT*, address of variable receiving handle of the element or 0 if there are no such element.
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteFindElement(SCILITE hLite, INT x, INT y, HELEMENT* phe);

//|
//| Callback function type
//|
//| HtmLayout will call it for callbacks defined in sciter.h, e.g. NMHL_ATTACH_BEHAVIOR
//| 

typedef UINT CALLBACK SCILITE_CALLBACK(SCILITE hLite, SCITER_CALLBACK_NOTIFICATION* hdr);

/** Set callback function. 
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] cb \b SCILITE_CALLBACK, address of callback function.
 * \return \b SCLRESULT.
 **/
EXTERN_C  SCLRESULT SCAPI SciliteSetCallback(SCILITE hLite, SCILITE_CALLBACK* cb);

EXTERN_C  SCLRESULT SCAPI SciliteTraverseUIEvent(SCILITE hLite, UINT evt, LPVOID eventCtlStruct, LPBOOL bOutProcessed );

/** advance focuse to focusable element. 
 * \param[in] hLite \b SCILITE, handle.
 * \param[in] where \b FOCUS_ADVANCE_CMD, where to advance.
 * \param[out] pRes \b BOOL*, TRUE if focus was advanced, FLASE - otherwise.
 * \return \b SCLRESULT.
 **/
enum FOCUS_ADVANCE_CMD 
{
  FOCUS_NEXT = 0,
  FOCUS_PREV = 1,
  FOCUS_HOME = 2,
  FOCUS_END = 3,
};
EXTERN_C  SCLRESULT SCAPI SciliteAdvanceFocus(SCILITE hLite, UINT where, BOOL* pRes );

/** Forces Scilite to process pending update requests. 
 * \param[in] hLite \b SCILITE, handle.
 **/
EXTERN_C       BOOL SCAPI SciliteUpdateView(SCILITE hLite );

#ifdef __cplusplus 

// C++ wrapper 

#include "sciter-x-behavior.h"

class  Scilite
{
  SCILITE                hLite;

  static UINT CALLBACK SciliteCB(SCILITE hLite, SCITER_CALLBACK_NOTIFICATION* hdr)
  {
    LPVOID tag = 0;
    SciliteGetTag(hLite,&tag);
    Scilite *pex = static_cast<Scilite*>(tag);
    assert(pex);

    switch( hdr->code )
    {
      case SC_LOAD_DATA: return pex->handleLoadUrlData( LPSCN_LOAD_DATA(hdr) ); 
      case SC_DATA_LOADED: return pex->handleUrlDataLoaded( LPSCN_DATA_LOADED(hdr) ); 
      case SC_ATTACH_BEHAVIOR: return pex->handleAttachBehavior( LPSCN_ATTACH_BEHAVIOR(hdr) ); 
      case SC_REFRESH_AREA: pex->handleRefreshArea( LPSCN_REFRESH_AREA(hdr) ); break;
      case SC_SET_TIMER: pex->handleSetTimer( LPSCN_SET_TIMER(hdr) ); break;
      case SC_SET_CURSOR: pex->handleSetCursor( LPSCN_SET_CURSOR(hdr) ); break;
      case SC_UPDATE_UI: pex->handleUpdate(); break;
    }
    return 0;
  }

public:
  Scilite(const char* mediaType = "screen"):hLite(0) 
  {
    hLite = SciliteCreateInstance();
    assert(hLite);
    if(hLite)
    {
      // set tag 
      SciliteSetTag(hLite,this);
      //set media type
      SciliteSetMediaType(hLite, mediaType);
      // register callback
      SciliteSetCallback(hLite, &SciliteCB );
    }
  }
  ~Scilite() { destroy(); }
  
  void destroy() 
  { 
    if(hLite) 
    {
      SciliteDestroyInstance(hLite);
      hLite = 0;
    }
  }
  bool load(LPCWSTR path)
  {
    SCLRESULT hr = SciliteLoadFromFile(hLite, path);
    assert(hr == SCL_OK);
    return hr == SCL_OK;
  }

  bool load(LPCBYTES dataptr, DWORD datasize, LPCWSTR baseURI = L"")
  {
    SCLRESULT hr = SciliteLoadFromBytes(hLite, baseURI, dataptr, datasize);
    assert(hr == SCL_OK);
    return hr == SCL_OK;
  }

  bool  replace(  HWND hwnd,
                  int viewX,      // horizontal position of Sciter area in device (physical) pixels, relative to window client origin.  
                  int viewY,      // vertical position of Sciter area in device (physical) pixels, relative to window client origin.  
                  int viewWidth,  // width of rendering area in device (physical) pixels 
                  int viewHeight) // height of rendering area in device (physical) pixels  
  {
    SCLRESULT hr = SciliteReplace(hLite, hwnd, viewX, viewY, viewWidth, viewHeight);
    //assert(hr == SCL_OK); 
    return hr == SCL_OK;
  }

  bool  render(HDC hdc, int x, int y, int width, int height)
  {
    SCLRESULT hr = SciliteRender(hLite, hdc, x, y, width, height);
    assert(hr == SCL_OK);
    return hr == SCL_OK;
  }

  bool  render(HBITMAP hbmp, int x, int y, int width, int height)
  {
    SCLRESULT hr = SciliteRenderOnBitmap(hLite, hbmp, x, y, width, height);
    assert(hr == SCL_OK);
    return hr == SCL_OK;
  }

  void  update() 
  {
    SciliteUpdateView(hLite);
  }

  bool  setDataReady(LPCBYTE data, DWORD dataSize)
  {
    SCLRESULT hr = SciliteSetDataReady(hLite, 0, data, dataSize);
    assert(hr == SCL_OK);
    return hr == SCL_OK;
  }

  bool  setDataReadyAsync(LPCWSTR url, LPCBYTE data, DWORD dataSize, LPVOID requestId)
  {
    SCLRESULT hr = SciliteSetDataReadyAsync(hLite, url, data, dataSize, requestId );
    assert(hr == SCL_OK);
    return hr == SCL_OK;
  }
  

  // Get current document measured height for width
  // given in measure scaledWidth/viewportWidth parameters.
  // ATTN: You need call first measure to get valid result.
  // retunrn value is in screen pixels.

  int getDocumentMinHeight()
  {
    int v;
    SCLRESULT hr = SciliteGetDocumentMinHeight(hLite, &v);
    assert(hr == SCL_OK); 
    return (hr == SCL_OK)? v:0;
  }

  // Get current document measured minimum (intrinsic) width.
  // ATTN: You need call first measure to get valid result.
  // return value is in screen pixels.

  int getDocumentMinWidth()
  {
    int v;
    SCLRESULT hr = SciliteGetDocumentMinWidth(hLite, &v);
    assert(hr == SCL_OK); 
    return (hr == SCL_OK)?v:0;
  }

  HELEMENT getRootElement()
  {
    HELEMENT v;
    SCLRESULT hr = SciliteGetRootElement(hLite, &v);
    assert(hr == SCL_OK); 
    return (hr == SCL_OK)?v:0;
  }

  HELEMENT find(POINT pt)
  {
    HELEMENT he = 0;
    SciliteFindElement(hLite,pt.x, pt.y,&he);
    return he;
  }
 

  // request to load data, override this if you need other data loading policy
  virtual UINT handleLoadUrlData(LPSCN_LOAD_DATA pn) 
  {
    return 0; // proceed with default image loader
  }

  // data loaded
  virtual UINT handleUrlDataLoaded(LPSCN_DATA_LOADED pn) 
  {
    return 0; // proceed with default image loader
  }

  // override this if you need other image loading policy
  virtual UINT handleAttachBehavior(LPSCN_ATTACH_BEHAVIOR pn) 
  {
    sciter::event_handler *pb = sciter::behavior_factory::create(pn->behaviorName, pn->element);
    if(pb) 
    {
      pn->elementTag = pb;
      pn->elementProc = sciter::event_handler::element_proc;
      return TRUE;
    }
    return FALSE; // proceed with default image loader
  }

  virtual void handleRefreshArea( LPSCN_REFRESH_AREA pn )
  {
    pn->area;//e.g. InvalidateRect(..., pn->area).
  }

  enum SCILITE_TIMER_ID
  {
    TIMER_IDLE_ID = 1, // nIDEvent in SetTimer cannot be zero
    TIMER_ANIMATION_ID = 2
  };

  virtual void handleSetTimer( LPSCN_SET_TIMER pn )
  {
    if( pn->elapseTime )
      ;// CreateTimerQueueTimer( this, pn->timerId, pn->elapseTime )
    else
      ;// DeleteTimerQueueTimer( .... )
  }

  virtual void handleSetCursor( LPSCN_SET_CURSOR pn )
  {
    // (CURSOR_TYPE) pn->cursorId;
  }

  virtual void handleUpdate( )
  {
    //e.g. copy invalid area of pixel buffer to the screen.
  }


  // process mouse event,
  // see MOUSE_PARAMS for the meaning of parameters
  BOOL traverseMouseEvent( UINT mouseCmd, POINT pt, UINT buttons, UINT alt_state ) 
  {
    MOUSE_PARAMS mp; memset(&mp, 0, sizeof(mp));
    mp.alt_state = alt_state;
    mp.button_state = buttons;
    mp.cmd = mouseCmd;
    mp.pos_view = pt;
    BOOL result = FALSE;
    SCDOM_RESULT hr = SciliteTraverseUIEvent(hLite, HANDLE_MOUSE, &mp, &result );
    assert(hr == SCDOM_OK); hr;
    return result;
  }

  // process keyboard event,
  // see KEY_PARAMS for the meaning of parameters
  BOOL traverseKeyboardEvent( UINT keyCmd, UINT code, UINT alt_state ) 
  {
    KEY_PARAMS kp; memset(&kp, 0, sizeof(kp));
    kp.alt_state = alt_state;
    kp.key_code = code;
    kp.cmd = keyCmd;
    BOOL result = FALSE;
    SCDOM_RESULT hr = SciliteTraverseUIEvent(hLite, HANDLE_KEY, &kp, &result );
    return result;
  }

  // process timer event,
  BOOL traverseTimerEvent( UINT_PTR timerId ) 
  {
    BOOL result = FALSE;
    SCDOM_RESULT hr = SciliteTraverseUIEvent(hLite, HANDLE_TIMER, &timerId, &result );
    return result; // host must destroy timer event if result is FALSE.
  }

  

};
#endif //__cplusplus 


#endif