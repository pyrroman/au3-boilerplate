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
 * \brief \link sciter_dom.h DOM \endlink C++ wrapper
 **/

#ifndef __sciter_dom_hpp__
#define __sciter_dom_hpp__

#include <assert.h>
#include <stdio.h> // for vsnprintf

//#include <string> 
#include "sciter-x-aux.h"
#include "tiscript.h"

#pragma warning(disable:4786) //identifier was truncated...
#pragma warning(disable:4996) //'strcpy' was declared deprecated
#pragma warning(disable:4100) //unreferenced formal parameter 

#pragma once

/**Type of the result value for Sciter DOM functions.
 * Possible values are:
 * - \b SCDOM_OK - function completed successfully
 * - \b SCDOM_INVALID_HWND - invalid HWND
 * - \b SCDOM_INVALID_HANDLE - invalid HELEMENT
 * - \b SCDOM_PASSIVE_HANDLE - attempt to use HELEMENT which is not marked by 
 *   #Sciter_UseElement()
 * - \b SCDOM_INVALID_PARAMETER - parameter is invalid, e.g. pointer is null
 * - \b SCDOM_OPERATION_FAILED - operation failed, e.g. invalid html in 
 *   #SciterSetElementHtml()
 **/

#define SCDOM_RESULT INT 

#define SCDOM_OK 0
#define SCDOM_INVALID_HWND 1 
#define SCDOM_INVALID_HANDLE 2
#define SCDOM_PASSIVE_HANDLE 3
#define SCDOM_INVALID_PARAMETER 4
#define SCDOM_OPERATION_FAILED 5
#define SCDOM_OK_NOT_HANDLED (-1)

struct METHOD_PARAMS;
struct REQUEST_PARAM { LPCWSTR name; LPCWSTR value; };

EXTERN_C SCDOM_RESULT SCAPI Sciter_UseElement(HELEMENT he);

/**Marks DOM object as unused (a.k.a. Release).
 * Get handle of every element's child element.
 * \param[in] he \b #HELEMENT
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 * 
 * Application should call this function when it does not need element's 
 * handle anymore.
 * \sa #Sciter_UseElement()
 **/
EXTERN_C SCDOM_RESULT SCAPI Sciter_UnuseElement(HELEMENT he);

/**Get root DOM element of HTML document.
 * \param[in] hwnd \b HWND, Sciter window for which you need to get root 
 * element
 * \param[out ] phe \b #HELEMENT*, variable to receive root element
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 * 
 * Root DOM object is always a 'HTML' element of the document.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetRootElement(HWND hwnd, HELEMENT *phe);

/**Get focused DOM element of HTML document.
 * \param[in] hwnd \b HWND, Sciter window for which you need to get focus 
 * element
 * \param[out ] phe \b #HELEMENT*, variable to receive focus element
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 * 
 * phe can have null value (0).
 *
 * COMMENT: To set focus on element use SciterSetElementState(STATE_FOCUS,0)
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetFocusElement(HWND hwnd, HELEMENT *phe);

/**Find DOM element by coordinate.
 * \param[in] hwnd \b HWND, Sciter window for which you need to find  
 * elementz
 * \param[in] pt \b POINT, coordinates, window client area relative.  
 * \param[out ] phe \b #HELEMENT*, variable to receive found element handle.
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 * 
 * If element was not found then *phe will be set to zero.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterFindElement(HWND hwnd, POINT pt, HELEMENT* phe);

/**Get number of child elements.
 * \param[in] he \b #HELEMENT, element which child elements you need to count
 * \param[out] count \b UINT*, variable to receive number of child elements 
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 *
 * \par Example:
 * for paragraph defined as
 * \verbatim <p>Hello <b>wonderfull</b> world!</p> \endverbatim
 * count will be set to 1 as the paragraph has only one sub element: 
 * \verbatim <b>wonderfull</b> \endverbatim
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetChildrenCount(HELEMENT he, UINT* count);

/**Get handle of every element's child element.
 * \param[in] he \b #HELEMENT
 * \param[in] n \b UINT, number of the child element
 * \param[out] phe \b #HELEMENT*, variable to receive handle of the child 
 * element
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 *
 * \par Example:
 * for paragraph defined as
 * \verbatim <p>Hello <b>wonderfull</b> world!</p> \endverbatim
 * *phe will be equal to handle of &lt;b&gt; element:
 * \verbatim <b>wonderfull</b> \endverbatim
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetNthChild(HELEMENT he, UINT n, HELEMENT* phe);

/**Get parent element.
 * \param[in] he \b #HELEMENT, element which parent you need
 * \param[out] p_parent_he \b #HELEMENT*, variable to recieve handle of the 
 * parent element
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetParentElement(HELEMENT he, HELEMENT* p_parent_he);

/** Get html representation of the element.
 * \param[in] he \b #HELEMENT
 * \param[out] utf8bytes \b pointer to byte address receiving UTF8 encoded HTML 
 * \param[in] outer \b BOOL, if TRUE will retunr outer HTML otherwise inner.  
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 * OBSOLETE: use SciterGetElementHtmlCB instead
 */
OBSOLETE EXTERN_C SCDOM_RESULT SCAPI SciterGetElementHtml(HELEMENT he, LPBYTE* utf8bytes, BOOL outer);

/**Callback function used with #SciterGetElementHtmlCB().*/
typedef VOID CALLBACK LPCBYTE_RECEIVER( LPCBYTE bytes, UINT num_bytes, LPVOID param );

/** Get html representation of the element.
 * \param[in] he \b #HELEMENT
 * \param[in] outer \b BOOL, if TRUE will retunr outer HTML otherwise inner.  
 * \param[in] rcv \b pointer to function receiving UTF8 encoded HTML.
 * \param[in] rcv_param \b parameter that passed to rcv as it is. 
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 */
EXTERN_C SCDOM_RESULT SCAPI SciterGetElementHtmlCB(HELEMENT he, BOOL outer, LPCBYTE_RECEIVER* rcv, LPVOID rcv_param);

 /**Get inner text of the element as LPWSTR (utf16 words).
 * \param[in] he \b #HELEMENT
 * \param[out] utf16words \b pointer to byte address receiving UTF16 encoded plain text 
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 * OBSOLETE! use SciterGetElementTextCB instead
 */
 OBSOLETE EXTERN_C SCDOM_RESULT SCAPI SciterGetElementText(HELEMENT he, LPWSTR* utf16);


 /**Callback function used with #SciterGetElementTextCB().*/
 typedef VOID CALLBACK LPCWSTR_RECEIVER( LPCWSTR str, UINT str_length, LPVOID param );

 /**Get inner text of the element as LPCWSTR (utf16 words).
 * \param[in] he \b #HELEMENT
 * \param[in] rcv \b pointer to the function receiving UTF16 encoded plain text 
 * \param[in] rcv_param \b param passed that passed to LPCWSTR_RECEIVER "as is"
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 */

 EXTERN_C SCDOM_RESULT SCAPI SciterGetElementTextCB(HELEMENT he, LPCWSTR_RECEIVER* rcv, LPVOID rcv_param);


/**Set inner text of the element from LPCWSTR buffer (utf16 words).
 * \param[in] he \b #HELEMENT
 * \param[in] utf16words \b pointer, UTF16 encoded plain text 
 * \param[in] length \b UINT, number of words in utf16words sequence
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 */
 EXTERN_C SCDOM_RESULT SCAPI SciterSetElementText(HELEMENT he, LPCWSTR utf16, UINT length);

/**Get number of element's attributes.
 * \param[in] he \b #HELEMENT
 * \param[out] p_count \b LPUINT, variable to receive number of element 
 * attributes.
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
 EXTERN_C SCDOM_RESULT SCAPI SciterGetAttributeCount(HELEMENT he, LPUINT p_count);

/**Get value of any element's attribute by attribute's number.
 * \param[in] he \b #HELEMENT 
 * \param[in] n \b UINT, number of desired attribute
 * \param[out] p_name \b LPCSTR*, will be set to address of the string 
 * containing attribute name
 * \param[out] p_value \b LPCWSTR*, will be set to address of the string 
 * containing attribute value
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetNthAttribute(HELEMENT he, UINT n, LPCSTR* p_name, LPCWSTR* p_value);

/**Get value of any element's attribute by name.
 * \param[in] he \b #HELEMENT 
 * \param[in] name \b LPCSTR, attribute name
 * \param[out] p_value \b LPCWSTR*, will be set to address of the string 
 * containing attribute value
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetAttributeByName(HELEMENT he, LPCSTR name, LPCWSTR* p_value);

/**Set attribute's value.
 * \param[in] he \b #HELEMENT 
 * \param[in] name \b LPCSTR, attribute name
 * \param[in] value \b LPCWSTR, new attribute value or 0 if you want to remove attribute.
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterSetAttributeByName(HELEMENT he, LPCSTR name, LPCWSTR value);

/**Remove all attributes from the element.
 * \param[in] he \b #HELEMENT 
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterClearAttributes(HELEMENT he);

/**Get element index. 
 * \param[in] he \b #HELEMENT 
 * \param[out] p_index \b LPUINT, variable to receive number of the element 
 * among parent element's subelements.
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetElementIndex(HELEMENT he, LPUINT p_index);

/**Get element's type.
 * \param[in] he \b #HELEMENT 
 * \param[out] p_type \b LPCSTR*, receives name of the element type.
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 * 
 * \par Example:
 * For &lt;div&gt; tag p_type will be set to "div".
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetElementType(HELEMENT he, LPCSTR* p_type);

/**Get element's style attribute.
 * \param[in] he \b #HELEMENT 
 * \param[in] name \b LPCSTR, name of the style attribute
 * \param[out] p_value \b LPCWSTR*, variable to receive value of the style attribute.
 *
 * Style attributes are those that are set using css. E.g. "font-face: arial" or "display: block".
 *
 * \sa #SciterSetStyleAttribute()
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetStyleAttribute(HELEMENT he, LPCSTR name, LPCWSTR* p_value);

/**Get element's style attribute.
 * \param[in] he \b #HELEMENT 
 * \param[in] name \b LPCSTR, name of the style attribute
 * \param[out] value \b LPCWSTR, value of the style attribute.
 *
 * Style attributes are those that are set using css. E.g. "font-face: arial" or "display: block".
 *
 * \sa #SciterGetStyleAttribute()
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterSetStyleAttribute(HELEMENT he, LPCSTR name, LPCWSTR value);

/*Get bounding rectangle of the element.
 * \param[in] he \b #HELEMENT 
 * \param[out] p_location \b LPRECT, receives bounding rectangle of the element
 * \param[in] rootRelative \b BOOL, if TRUE function returns location of the 
 * element relative to Sciter window, otherwise the location is given 
 * relative to first scrollable container.
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/

enum ELEMENT_AREAS 
{
  ROOT_RELATIVE = 0x01,       // - or this flag if you want to get HTMLayout window relative coordinates,
                              //   otherwise it will use nearest windowed container e.g. popup window.
  SELF_RELATIVE = 0x02,       // - "or" this flag if you want to get coordinates relative to the origin
                              //   of element iself.
  CONTAINER_RELATIVE = 0x03,  // - position inside immediate container.
  VIEW_RELATIVE = 0x04,       // - position relative to view - HTMLayout window

  CONTENT_BOX = 0x00,   // content (inner)  box
  PADDING_BOX = 0x10,   // content + paddings
  BORDER_BOX  = 0x20,   // content + paddings + border
  MARGIN_BOX  = 0x30,   // content + paddings + border + margins 
  
  BACK_IMAGE_AREA = 0x40, // relative to content origin - location of background image (if it set no-repeat)
  FORE_IMAGE_AREA = 0x50, // relative to content origin - location of foreground image (if it set no-repeat)

  SCROLLABLE_AREA = 0x60,   // scroll_area - scrollable area in content box 

};

EXTERN_C SCDOM_RESULT SCAPI SciterGetElementLocation(HELEMENT he, LPRECT p_location, UINT areas /*ELEMENT_AREAS*/);

enum SCITER_SCROLL_FLAGS
{
  SCROLL_TO_TOP = 0x01,
  SCROLL_SMOOTH = 0x10,
};

/*Scroll to view.
 * \param[in] he \b #HELEMENT 
 * \param[in] SciterScrollFlags \b #UINT, combination of SCITER_SCROLL_FLAGS above or 0 
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterScrollToView(HELEMENT he, UINT SciterScrollFlags);


/**Apply changes and refresh element area in its window.
 * \param[in] he \b #HELEMENT 
 * \param[in] doRelayout \b BOOL, TRUE forces call of UpdateWindow(hwnd).
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterUpdateElement(HELEMENT he, BOOL forceUpdateWindow);

/**refresh element area in its window.
 * \param[in] he \b #HELEMENT 
 * \param[in] rc \b RECT, rect to refresh.
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterRefreshElementArea(HELEMENT he, RECT rc);

/**Set the mouse capture to the specified element.
 * \param[in] he \b #HELEMENT 
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 *
 * After call to this function all mouse events will be targeted to the element.
 * To remove mouse capture call ReleaseCapture() function. 
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterSetCapture(HELEMENT he);
EXTERN_C SCDOM_RESULT SCAPI SciterReleaseCapture(HELEMENT he);

/**Get HWND of containing window.
 * \param[in] he \b #HELEMENT 
 * \param[out] p_hwnd \b HWND*, variable to receive window handle
 * \param[in] rootWindow \b BOOL, handle of which window to get:
 * - TRUE - Sciter window
 * - FALSE - nearest parent element having overflow:auto or :scroll
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetElementHwnd(HELEMENT he, HWND* p_hwnd, BOOL rootWindow);



/**Combine given URL with URL of the document element belongs to.
 * \param[in] he \b #HELEMENT
 * \param[in, out] szUrlBuffer \b LPWSTR, at input this buffer contains 
 * zero-terminated URL to be combined, after function call it contains 
 * zero-terminated combined URL
 * \param[in] UrlBufferSize \b DWORD, size of the buffer pointed by 
 * \c szUrlBuffer
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 *
 * This function is used for resolving relative references.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterCombineURL(HELEMENT he, LPWSTR szUrlBuffer, DWORD UrlBufferSize);

/**Callback function used with #SciterVisitElement().*/
typedef BOOL CALLBACK SciterElementCallback( HELEMENT he, LPVOID param );

/**Call specified function for every element in a DOM that meets specified 
 * CSS selectors.
 * See list of supported selectors: http://terrainformatica.com/htmlayout/selectors.whtm
 * \param[in] he \b #HELEMENT
 * \param[in] selector \b LPCSTR, comma separated list of CSS selectors, e.g.: div, #id, div[align="right"].
 * \param[in] callback \b #SciterElementCallback*, address of callback 
 * function being called on each element found.
 * \param[in] param \b LPVOID, additional parameter to be passed to callback 
 * function.
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 *
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterSelectElements(
          HELEMENT  he, 
          LPCSTR    CSS_selectors,
          SciterElementCallback* 
                    callback, 
          LPVOID    param);

EXTERN_C SCDOM_RESULT SCAPI SciterSelectElementsW(
          HELEMENT  he, 
          LPCWSTR   CSS_selectors,
          SciterElementCallback* 
                    callback, 
          LPVOID    param);


/**Find parent of the element by CSS selector. 
 * ATTN: function will test first element itself. 
 * See list of supported selectors: http://terrainformatica.com/htmlayout/selectors.whtm
 * \param[in] he \b #HELEMENT
 * \param[in] selector \b LPCSTR, comma separated list of CSS selectors, e.g.: div, #id, div[align="right"].
 * \param[out] heFound \b #HELEMENT*, address of result HELEMENT 
 * \param[in] depth \b LPVOID, depth of search, if depth == 1 then it will test only element itself. 
 *                     Use depth = 1 if you just want to test he element for matching given CSS selector(s). 
 *                     depth = 0 will scan the whole child parent chain up to the root.
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 *
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterSelectParent(
          HELEMENT  he, 
          LPCSTR    selector,
          UINT      depth,
          /*out*/ HELEMENT* heFound);

EXTERN_C SCDOM_RESULT SCAPI SciterSelectParentW(
          HELEMENT  he, 
          LPCWSTR   selector,
          UINT      depth,
          /*out*/ HELEMENT* heFound);


enum SET_ELEMENT_HTML
{
  SIH_REPLACE_CONTENT     = 0, 
  SIH_INSERT_AT_START     = 1,
  SIH_APPEND_AFTER_LAST   = 2, 
  SOH_REPLACE             = 3,
  SOH_INSERT_BEFORE       = 4,
  SOH_INSERT_AFTER        = 5  
};

/**Set inner or outer html of the element.
 * \param[in] he \b #HELEMENT
 * \param[in] html \b LPCBYTE, UTF-8 encoded string containing html text
 * \param[in] htmlLength \b DWORD, length in bytes of \c html.
 * \param[in] where \b UINT, possible values are:
 * - SIH_REPLACE_CONTENT - replace content of the element
 * - SIH_INSERT_AT_START - insert html before first child of the element
 * - SIH_APPEND_AFTER_LAST - insert html after last child of the element
 *
 * - SOH_REPLACE - replace element by html, a.k.a. element.outerHtml = "something"
 * - SOH_INSERT_BEFORE - insert html before the element
 * - SOH_INSERT_AFTER - insert html after the element
 *   ATTN: SOH_*** operations do not work for inline elements like <SPAN>
 *
 * \return /b #EXTERN_C SCDOM_RESULT SCAPI
  **/

EXTERN_C SCDOM_RESULT SCAPI SciterSetElementHtml(HELEMENT he, const BYTE* html, DWORD htmlLength, UINT where);


/** Element UID support functions.
 *  
 *  Element UID is unique identifier of the DOM element. 
 *  UID is suitable for storing it in structures associated with the view/document.
 *  Access to the element using HELEMENT is more effective but table space of handles is limited.
 *  It is not recommended to store HELEMENT handles between function calls.
 **/


/** Get Element UID.
 * \param[in] he \b #HELEMENT
 * \param[out] puid \b UINT*, variable to receive UID of the element.
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 *
 * This function retrieves element UID by its handle.
 *
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterGetElementUID(HELEMENT he, UINT* puid);

/** Get Element handle by its UID.
 * \param[in] hwnd \b HWND, HWND of Sciter window
 * \param[in] uid \b UINT
 * \param[out] phe \b #HELEMENT*, variable to receive HELEMENT handle 
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 *
 * This function retrieves element UID by its handle.
 *
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterGetElementByUID(HWND hwnd, UINT uid, HELEMENT* phe);

/** Shows block element (DIV) in popup window.
 * \param[in] hePopup \b HELEMENT, element to show as popup
 * \param[in] heAnchor \b HELEMENT, anchor element - hePopup will be shown near this element
 * \param[in] placement \b UINT, values: 
 *     2 - popup element below of anchor
 *     8 - popup element above of anchor
 *     4 - popup element on left side of anchor
 *     6 - popup element on right side of anchor
 *     ( see numpad on keyboard to get an idea of the numbers)
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 *
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterShowPopup(HELEMENT hePopup, HELEMENT heAnchor, UINT placement);


/** Shows block element (DIV) in popup window at given position.
 * \param[in] hePopup \b HELEMENT, element to show as popup
 * \param[in] pos \b POINT, popup element position, relative to origin of Sciter window.
 * \param[in] mode \b BOOL, LOWORD=1 if animation is needed. HIWORD 1..9 - point of the popup that corresponds to pos 
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterShowPopupAt(HELEMENT hePopup, POINT pos, UINT mode);

/** Removes popup window.
 * \param[in] he \b HELEMENT, element which belongs to popup window or popup element itself
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterHidePopup(HELEMENT he);


/**Element callback function for all types of events. Similar to WndProc
 * \param tag \b LPVOID, tag assigned by SciterAttachElementProc function (like GWL_USERDATA)
 * \param he \b HELEMENT, this element handle (like HWND)
 * \param evtg \b UINT, group identifier of the event, value is one of EVENT_GROUPS
 * \param prms \b LPVOID, pointer to group specific parameters structure.
 * \return TRUE if event was handled, FALSE otherwise.
 **/

typedef BOOL CALLBACK ElementEventProc(LPVOID tag, HELEMENT he, UINT evtg, LPVOID prms );
typedef ElementEventProc* LPELEMENT_EVENT_PROC;

enum ELEMENT_STATE_BITS 
{
   STATE_LINK             = 0x00000001,
   STATE_HOVER            = 0x00000002,
   STATE_ACTIVE           = 0x00000004,
   STATE_FOCUS            = 0x00000008,
   STATE_VISITED          = 0x00000010,
   STATE_CURRENT          = 0x00000020,  // current (hot) item 
   STATE_CHECKED          = 0x00000040,  // element is checked (or selected)
   STATE_DISABLED         = 0x00000080,  // element is disabled
   STATE_READONLY         = 0x00000100,  // readonly input element 
   STATE_EXPANDED         = 0x00000200,  // expanded state - nodes in tree view 
   STATE_COLLAPSED        = 0x00000400,  // collapsed state - nodes in tree view - mutually exclusive with
   STATE_INCOMPLETE       = 0x00000800,  // one of fore/back images requested but not delivered
   STATE_ANIMATING        = 0x00001000,  // is animating currently
   STATE_FOCUSABLE        = 0x00002000,  // will accept focus
   STATE_ANCHOR           = 0x00004000,  // anchor in selection (used with current in selects)
   STATE_SYNTHETIC        = 0x00008000,  // this is a synthetic element - don't emit it's head/tail
   STATE_OWNS_POPUP       = 0x00010000,  // this is a synthetic element - don't emit it's head/tail
   STATE_TABFOCUS         = 0x00020000,  // focus gained by tab traversal
   STATE_EMPTY            = 0x00040000,  // empty - element is empty (text.size() == 0 && subs.size() == 0) 
                                         //  if element has behavior attached then the behavior is responsible for the value of this flag.
   STATE_BUSY             = 0x00080000,  // busy; loading
   
   STATE_DRAG_OVER        = 0x00100000,  // drag over the block that can accept it (so is current drop target). Flag is set for the drop target block
   STATE_DROP_TARGET      = 0x00200000,  // active drop target.
   STATE_MOVING           = 0x00400000,  // dragging/moving - the flag is set for the moving block.
   STATE_COPYING          = 0x00800000,  // dragging/copying - the flag is set for the copying block.
   STATE_DRAG_SOURCE      = 0x01000000,  // element that is a drag source.
   STATE_DROP_MARKER      = 0x02000000,  // element is drop marker
   
   STATE_PRESSED          = 0x04000000,  // pressed - close to active but has wider life span - e.g. in MOUSE_UP it 
                                         //   is still on; so behavior can check it in MOUSE_UP to discover CLICK condition.
   STATE_POPUP            = 0x08000000,  // this element is out of flow - popup 
   STATE_IS_LTR           = 0x10000000,  // the element or one of its containers has dir=ltr declared
   STATE_IS_RTL           = 0x20000000,  // the element or one of its containers has dir=rtl declared

};

  /** Get/set state bits, stateBits*** accept or'ed values above
   **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetElementState( HELEMENT he, UINT* pstateBits);

/**
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterSetElementState( HELEMENT he, UINT stateBitsToSet, UINT stateBitsToClear, BOOL updateView);

/** Create new element, the element is disconnected initially from the DOM.
    Element created with ref_count = 1 thus you \b must call Sciter_UnuseElement on returned handler.
 * \param[in] tagname \b LPCSTR, html tag of the element e.g. "div", "option", etc.
 * \param[in] textOrNull \b LPCWSTR, initial text of the element or NULL. text here is a plain text - method does no parsing.
 * \param[out ] phe \b #HELEMENT*, variable to receive handle of the element
  **/

EXTERN_C SCDOM_RESULT SCAPI SciterCreateElement( LPCSTR tagname, LPCWSTR textOrNull, /*out*/ HELEMENT *phe );

/** Create new element as copy of existing element, new element is a full (deep) copy of the element and
    is disconnected initially from the DOM.
    Element created with ref_count = 1 thus you \b must call Sciter_UnuseElement on returned handler.
 * \param[in] he \b #HELEMENT, source element.
 * \param[out ] phe \b #HELEMENT*, variable to receive handle of the new element. 
  **/
EXTERN_C SCDOM_RESULT SCAPI SciterCloneElement( HELEMENT he, /*out*/ HELEMENT *phe );

/** Insert element at \i index position of parent.
    It is not an error to insert element which already has parent - it will be disconnected first, but 
    you need to update elements parent in this case. 
 * \param index \b UINT, position of the element in parent collection. 
   It is not an error to provide index greater than elements count in parent -
   it will be appended.
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterInsertElement( HELEMENT he, HELEMENT hparent, UINT index );

/** Take element out of its container (and DOM tree). 
    Element will be destroyed when its reference counter will become zero
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterDetachElement( HELEMENT he );

/** Take element out of its container (and DOM tree) and force destruction of all behaviors. 
    Element will be destroyed when its reference counter will become zero
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterDeleteElement( HELEMENT he );


/** Start Timer for the element. 
    Element will receive on_timer event
    To stop timer call SciterSetTimer( he, 0 );
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterSetTimer( HELEMENT he, UINT milliseconds, UINT_PTR timer_id );

/** Attach/Detach ElementEventProc to the element 
    See htmlayout::event_handler.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterDetachEventHandler( HELEMENT he, LPELEMENT_EVENT_PROC pep, LPVOID tag );
/** Attach ElementEventProc to the element and subscribe it to events providede by subscription parameter
    See Sciter::attach_event_handler.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterAttachEventHandler( HELEMENT he, LPELEMENT_EVENT_PROC pep, LPVOID tag );


/** Attach/Detach ElementEventProc to the Sciter window. 
    All events will start first here (in SINKING phase) and if not consumed will end up here.
    You can install Window EventHandler only once - it will survive all document reloads.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterWindowAttachEventHandler( HWND hwndLayout, LPELEMENT_EVENT_PROC pep, LPVOID tag, UINT subscription );
EXTERN_C SCDOM_RESULT SCAPI SciterWindowDetachEventHandler( HWND hwndLayout, LPELEMENT_EVENT_PROC pep, LPVOID tag );


/** SendEvent - sends sinking/bubbling event to the child/parent chain of he element.
    First event will be send in SINKING mode (with SINKING flag) - from root to he element itself.
    Then from he element to its root on parents chain without SINKING flag (bubbling phase).

 * \param[in] he \b HELEMENT, element to send this event to.
 * \param[in] appEventCode \b UINT, event ID, see: #BEHAVIOR_EVENTS
 * \param[in] heSource \b HELEMENT, optional handle of the source element, e.g. some list item
 * \param[in] reason \b UINT, notification specific event reason code
 * \param[out] handled \b BOOL*, variable to receive TRUE if any handler handled it, FALSE otherwise.

 **/

EXTERN_C SCDOM_RESULT SCAPI SciterSendEvent(
          HELEMENT he, UINT appEventCode, HELEMENT heSource, UINT reason, /*out*/ BOOL* handled);

/** PostEvent - post sinking/bubbling event to the child/parent chain of he element.
 *  Function will return immediately posting event into input queue of the application. 
 *
 * \param[in] he \b HELEMENT, element to send this event to.
 * \param[in] appEventCode \b UINT, event ID, see: #BEHAVIOR_EVENTS
 * \param[in] heSource \b HELEMENT, optional handle of the source element, e.g. some list item
 * \param[in] reason \b UINT, notification specific event reason code

 **/

EXTERN_C SCDOM_RESULT SCAPI SciterPostEvent( HELEMENT he, UINT appEventCode, HELEMENT heSource, UINT reason);


/** SciterCallMethod - calls behavior specific method.
 * \param[in] he \b HELEMENT, element - source of the event.
 * \param[in] params \b METHOD_PARAMS, pointer to method param block
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterCallBehaviorMethod(HELEMENT he, METHOD_PARAMS* params);

/** SciterRequestElementData  - request data download for the element.
 * \param[in] he \b HELEMENT, element to deleiver data to.
 * \param[in] url \b LPCWSTR, url to download data from.
 * \param[in] dataType \b UINT, data type, see SciterResourceType.
 * \param[in] hInitiator \b HELEMENT, element - initiator, can be NULL.

  event handler on the he element (if any) will be notified 
  when data will be ready by receiving HANDLE_DATA_DELIVERY event.

  **/

EXTERN_C SCDOM_RESULT SCAPI SciterRequestElementData(
          HELEMENT he, LPCWSTR url, UINT dataType, HELEMENT initiator );

/**
 *  SciterSendRequest - send GET or POST request for the element
 *
 * event handler on the 'he' element (if any) will be notified 
 * when data will be ready by receiving HANDLE_DATA_DELIVERY event.
 *
 **/ 

enum REQUEST_TYPE
{
  GET_ASYNC,  // async GET
  POST_ASYNC, // async POST
  GET_SYNC,   // synchronous GET 
  POST_SYNC   // synchronous POST 
};

//struct REQUEST_PARAM { LPCWSTR name; LPCWSTR value; };

EXTERN_C SCDOM_RESULT SCAPI SciterHttpRequest( 
          HELEMENT        he,           // element to deliver data 
          LPCWSTR         url,          // url 
          UINT            dataType,     // data type, see SciterResourceType.
          UINT            requestType,  // one of REQUEST_TYPE values
          REQUEST_PARAM*  requestParams,// parameters 
          UINT            nParams       // number of parameters 
          );

/** SciterGetScrollInfo  - get scroll info of element with overflow:scroll or auto.
 * \param[in] he \b HELEMENT, element.
 * \param[out] scrollPos \b LPPOINT, scroll position.
 * \param[out] viewRect \b LPRECT, position of element scrollable area, content box minus scrollbars.
 * \param[out] contentSize \b LPSIZE, size of scrollable element content.
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterGetScrollInfo( 
         HELEMENT he, LPPOINT scrollPos, LPRECT viewRect, LPSIZE contentSize );

/** SciterSetScrollPos  - set scroll position of element with overflow:scroll or auto.
 * \param[in] he \b HELEMENT, element.
 * \param[in] scrollPos \b POINT, new scroll position.
 * \param[in] smooth \b BOOL, TRUE - do smooth scroll.
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterSetScrollPos( 
         HELEMENT he, POINT scrollPos, BOOL smooth );

/** SciterGetElementIntrinsicWidths  - get min-intrinsic and max-intrinsic widths of the element.
 * \param[in] he \b HELEMENT, element.
 * \param[out] pMinWidth \b INT*, calculated min-intrinsic width.
 * \param[out] pMaxWidth \b INT*, calculated max-intrinsic width.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetElementIntrinsicWidths( HELEMENT he, INT* pMinWidth, INT* pMaxWidth );

/** SciterGetElementIntrinsicHeight  - get min-intrinsic height of the element calculated for forWidth.
 * \param[in] he \b HELEMENT, element.
 * \param[in] forWidth \b INT*, width to calculate intrinsic height for.
 * \param[out] pHeight \b INT*, calculated min-intrinsic height.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetElementIntrinsicHeight( HELEMENT he, INT forWidth, INT* pHeight );

/** SciterIsElementVisible - deep visibility, determines if element visible - has no visiblity:hidden and no display:none defined 
    for itself or for any its parents.
 * \param[in] he \b HELEMENT, element.
 * \param[out] pVisible \b LPBOOL, visibility state.
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterIsElementVisible( HELEMENT he, BOOL* pVisible);

/** SciterIsElementEnabled - deep enable state, determines if element enabled - is not disabled by itself or no one  
    of its parents is disabled.
 * \param[in] he \b HELEMENT, element.
 * \param[out] pEnabled \b LPBOOL, enabled state.
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterIsElementEnabled( HELEMENT he, BOOL* pEnabled );

/**Callback comparator function used with #SciterSortElements().
   Shall return -1,0,+1 values to indicate result of comparison of two elements
 **/
typedef INT CALLBACK ELEMENT_COMPARATOR( HELEMENT he1, HELEMENT he2, LPVOID param );

/** SciterSortElements - sort children of the element.
 * \param[in] he \b HELEMENT, element which children to be sorted.
 * \param[in] firstIndex \b UINT, first child index to start sorting from.
 * \param[in] lastIndex \b UINT, last index of the sorting range, element with this index will not be included in the sorting.
 * \param[in] cmpFunc \b ELEMENT_COMPARATOR, comparator function.
 * \param[in] cmpFuncParam \b LPVOID, parameter to be passed in comparator function.
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterSortElements( 
         HELEMENT he, UINT firstIndex, UINT lastIndex, 
         ELEMENT_COMPARATOR* cmpFunc, LPVOID cmpFuncParam );

/** SciterSwapElements - swap element positions.
 * Function changes "insertion points" of two elements. So it swops indexes and parents of two elements.
 * \param[in] he1 \b HELEMENT, first element.
 * \param[in] he2 \b HELEMENT, second element.
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterSwapElements( 
         HELEMENT he1, HELEMENT he2 );


/** SciterTraverseUIEvent - traverse (sink-and-bubble) MOUSE or KEY event.
 * \param[in] evt \b EVENT_GROUPS, either HANDLE_MOUSE or HANDLE_KEY code.
 * \param[in] eventCtlStruct \b LPVOID, pointer on either MOUSE_PARAMS or KEY_PARAMS structure.
 * \param[out] bOutProcessed \b LPBOOL, pointer to BOOL receiving TRUE if event was processed by some element and FALSE otherwise.
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterTraverseUIEvent( 
         UINT evt, LPVOID eventCtlStruct, LPBOOL bOutProcessed );

/** CallScriptingMethod - calls scripting method defined for the element.
 * \param[in] he \b HELEMENT, element which method will be callled.
 * \param[in] name \b LPCSTR, name of the method to call.
 * \param[in] argv \b SCITER_VALUE[], vector of arguments.
 * \param[in] argc \b UINT, number of arguments.
 * \param[out] retval \b SCITER_VALUE*, pointer to SCITER_VALUE receiving returning value of the function.
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterCallScriptingMethod( HELEMENT he, LPCSTR name, const VALUE* argv, UINT argc, VALUE* retval );

/** CallScriptingFunction - calls scripting function defined in the namespace of the element (a.k.a. global function).
 * \param[in] he \b HELEMENT, element which namespace will be used.
 * \param[in] name \b LPCSTR, name of the method to call.
 * \param[in] argv \b SCITER_VALUE[], vector of arguments.
 * \param[in] argc \b UINT, number of arguments.
 * \param[out] retval \b SCITER_VALUE*, pointer to SCITER_VALUE receiving returning value of the function.
 *
 * SciterCallScriptingFunction allows to call functions defined on global level of main document or frame loaded in it.
 *
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterCallScriptingFunction( HELEMENT he, LPCSTR name, const VALUE* argv, UINT argc, VALUE* retval );


/**Attach HWND to the element.
 * \param[in] he \b #HELEMENT 
 * \param[in] hwnd \b HWND, window handle to attach
 * \return \b #EXTERN_C SCDOM_RESULT SCAPI
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterAttachHwndToElement(HELEMENT he, HWND hwnd);

/** Control types.
 *  Control here is any dom element having appropriate behavior applied
 **/

enum CTL_TYPE
{
    CTL_NO,               ///< This dom element has no behavior at all.
    CTL_UNKNOWN = 1,      ///< This dom element has behavior but its type is unknown.
    CTL_EDIT,             ///< Single line edit box.
    CTL_NUMERIC,          ///< Numeric input with optional spin buttons.
    CTL_BUTTON,           ///< Command button.
    CTL_CHECKBOX,         ///< CheckBox (button).
    CTL_RADIO,            ///< OptionBox (button).
    CTL_SELECT_SINGLE,    ///< Single select, ListBox or TreeView.
    CTL_SELECT_MULTIPLE,  ///< Multiselectable select, ListBox or TreeView.
    CTL_DD_SELECT,        ///< Dropdown single select.
    CTL_TEXTAREA,         ///< Multiline TextBox.
    CTL_HTMLAREA,         ///< WYSIWYG HTML editor.
    CTL_PASSWORD,         ///< Password input element.
    CTL_PROGRESS,         ///< Progress element.
    CTL_SLIDER,           ///< Slider input element.  
    CTL_DECIMAL,          ///< Decimal number input element.
    CTL_CURRENCY,         ///< Currency input element.
    CTL_SCROLLBAR,
    
    CTL_HYPERLINK,
    
    CTL_MENUBAR,
    CTL_MENU,
    CTL_MENUBUTTON,

    CTL_CALENDAR,
    CTL_DATE,
    CTL_TIME,
    
    CTL_FRAME,
    CTL_FRAMESET,

    CTL_GRAPHICS,
    CTL_SPRITE,

    CTL_LIST,
    CTL_RICHTEXT,
    CTL_TOOLTIP,

    CTL_HIDDEN,
    CTL_URL,            ///< URL input element.
    CTL_TOOLBAR,

    CTL_FORM,

};

/** SciterControlGetType - get type of control - type of behavior assigned to the element.
 * \param[in] he \b HELEMENT, element.
 * \param[out] pType \b UINT*, pointer to variable receiving control type,
 *             for list of values see CTL_TYPE.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterControlGetType( HELEMENT he, /*CTL_TYPE*/ UINT *pType );


/** SciterGetValue - get value of the element. 'value' is value of correspondent behavior attached to the element or its text.
 * \param[in] he \b HELEMENT, element which value will be retrieved.
 * \param[out] pval \b VALUE*, pointer to VALUE that will get elements value. 
 *  ATTN: if you are not using json::value wrapper then you shall call ValueClear aginst the returned value
 *        otherwise memory will leak.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetValue( HELEMENT he, VALUE* pval );

/** SciterSetValue - set value of the element.
 * \param[in] he \b HELEMENT, element which value will be changed.
 * \param[in] pval \b VALUE*, pointer to the VALUE to set. 
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterSetValue( HELEMENT he, const VALUE* pval );

/** SciterGetExpando - get 'expando' of the element. 'expando' is a scripting object (of class Element) 
 *  that is assigned to the DOM element. 'expando' could be null as they are created on demand by script.
 * \param[in] he \b HELEMENT, element which expando will be retrieved.
 * \param[out] pval \b VALUE*, pointer to VALUE that will get value of type T_OBJECT/UT_OBJECT_NATIVE or null. 
 * \param[in] forceCreation \b BOOL, if there is no expando then when forceCreation==TRUE the function will create it.
 *  ATTN: if you are not using json::value wrapper then you shall call ValueClear aginst the returned value
 *        otherwise it will leak memory.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetExpando( HELEMENT he, VALUE* pval, BOOL forceCreation );

/** SciterGetObject - get 'expando' object of the element. 'expando' is a scripting object (of class Element) 
 *  that is assigned to the DOM element. 'expando' could be null as they are created on demand by script.
 * \param[in] he \b HELEMENT, element which expando will be retrieved.
 * \param[out] pval \b tiscript::value*, pointer to tiscript::value that will get reference to the scripting object associated wuth the element or null. 
 * \param[in] forceCreation \b BOOL, if there is no expando then when forceCreation==TRUE the function will create it.
 *
 *  ATTN!: if you plan to store the reference or use it inside code that calls script VM functions 
 *         then you should use tiscript::pinned holder for the value.
 **/
EXTERN_C SCDOM_RESULT SCAPI SciterGetObject( HELEMENT he, tiscript_value* pval, BOOL forceCreation );

/** SciterGetElementNamespace - get namespace of document of the DOM element.
 * \param[in] he \b HELEMENT, element which expando will be retrieved.
 * \param[out] pval \b tiscript::value*, pointer to tiscript::value that will get reference to the namespace scripting object. 
 *
 *  ATTN!: if you plan to store the reference or use it inside code that calls script VM functions 
 *         then you should use tiscript::pinned holder for the value.
 **/

EXTERN_C SCDOM_RESULT SCAPI SciterGetElementNamespace(  HELEMENT he, tiscript_value* pval);


#include "sciter-x-behavior.h"

#ifdef __cplusplus

  #include "tiscript.hpp"

  /**sciter namespace.*/
  namespace sciter
  {
    /**dom namespace.*/
    namespace dom 
    {

    /**callback structure.
     * Used with #sciter::dom::element::select() function. 
     **/
      struct callback 
      {
      /**Is called for every element that match criteria specified when calling to #sciter::dom::element::select() function.*/
        virtual bool on_element(HELEMENT he) = 0;
      };

    /**DOM element.*/
   
      class element
      {

      protected:
        HELEMENT he;

        void use(HELEMENT h) { he = ( Sciter_UseElement(h) == SCDOM_OK)? h: 0; }
        void unuse() { if(he) Sciter_UnuseElement(he); he = 0; }
        void set(HELEMENT h) { unuse(); use(h); }

      public:
      /**Construct \c undefined element .
       **/
        element(): he(0) { }

      /**Construct \c element from existing element handle.
       * \param h \b #HELEMENT
       **/
        element(HELEMENT h)       { use(h); }

      /**Copy constructor;
       * \param e \b #element
       **/
        element(const element& e) { use(e.he); }

        operator HELEMENT() const { return he; }

      /**Destructor.*/
        ~element()                { unuse(); }

      /**Assign \c element an \c #HELEMENT
       * \param h \b #HELEMENT
       * \return \b #element&
       **/
        element& operator = (HELEMENT h) { set(h); return *this; }

      /**Assign \c element another \c #element
       * \param e \b #element
       * \return \b #element&
       **/
        element& operator = (const element& e) { set(e.he); return *this; }

      /**Test equality of this and another \c #element's
       * \param rs \b const \b #element 
       * \return \b bool, true if elements are equal, false otherwise
       **/
        bool operator == (const element& rs ) const { return he == rs.he; }
        bool operator == (HELEMENT rs ) const { return he == rs; }

      /**Test equality of this and another \c #element's
       * \param rs \b const \b #element 
       * \return \b bool, true if elements are not equal, false otherwise
       **/
        bool operator != (const element& rs ) const { return he != rs.he; }

      /**Test whether element is valid.
       * \return \b bool, true if element is valid, false otherwise
       **/
        bool is_valid() const { return he != 0; }

      /**Get number of child elements.
       * \return \b int, number of child elements
       **/
        unsigned int children_count() const 
        { 
          UINT count = 0;
          SciterGetChildrenCount(he, &count);
          return count;
        }

      /**Get Nth child element.
       * \param index \b unsigned \b int, number of the child element
       * \return \b #HELEMENT, child element handle
       **/
        HELEMENT child( unsigned int index ) const 
        { 
          HELEMENT child = 0;
          SciterGetNthChild(he, index, &child);
          return child;
        }

      /**Get parent element.
       * \return \b #HELEMENT, handle of the parent element
       **/
        HELEMENT parent( ) const 
        { 
          HELEMENT hparent = 0;
          SciterGetParentElement(he, &hparent);
          return hparent;
        }

      /**Get index of this element in its parent collection.
       * \return \b unsigned \b int, index of this element in its parent collection
       **/
        unsigned int index( ) const 
        { 
          UINT index = 0;
          SciterGetElementIndex(he, &index);
          return index;
        }

      /**Get number of the attributes.
       * \return \b unsigned \b int, number of the attributes
       **/
        unsigned int get_attribute_count( ) const 
        { 
          UINT n = 0;
          SciterGetAttributeCount(he, &n);
          return n;
        }

      /**Get attribute value by its index.
       * \param n \b unsigned \b int, number of the attribute
       * \return \b const \b wchar_t*, value of the n-th attribute
       **/
        const wchar_t* get_attribute( unsigned int n ) const 
        { 
          LPCWSTR lpw = 0;
          SciterGetNthAttribute(he, n, 0, &lpw);
          return lpw;
        }

      /**Get attribute name by its index.
       * \param n \b unsigned \b int, number of the attribute
       * \return \b const \b char*, name of the n-th attribute
       **/
        const char* get_attribute_name( unsigned int n ) const 
        { 
          LPCSTR lpc = 0;
          SciterGetNthAttribute(he, n, &lpc, 0);
          return lpc;
        }

      /**Get attribute value by name.
       * \param name \b const \b char*, name of the attribute
       * \return \b const \b wchar_t*, value of the n-th attribute
       **/
        const wchar_t* get_attribute( const char* name, const wchar_t* def_value = 0 ) const 
        { 
          LPCWSTR lpw = 0;
          SciterGetAttributeByName(he, name, &lpw);
          return lpw? lpw: def_value;
        }

      /**Add or replace attribute.
       * \param name \b const \b char*, name of the attribute
       * \param value \b const \b wchar_t*, name of the attribute
       **/
      void set_attribute( const char* name, const wchar_t* value )
        { 
          SciterSetAttributeByName(he, name, value);
        }

      /**Get attribute integer value by name.
       * \param name \b const \b char*, name of the attribute
       * \return \b int , value of the attribute
       **/
        int get_attribute_int( const char* name, int def_val = 0 ) const 
        { 
          const wchar_t* txt = get_attribute(name);
          if(!txt) return def_val;
          return _wtoi(txt);
        }

      
      /**Remove attribute.
       * \param name \b const \b char*, name of the attribute
       **/
      void remove_attribute( const char* name ) 
        { 
          SciterSetAttributeByName(he, name, 0);
        }
      

      /**Get style attribute of the element by its name.
       * \param name \b const \b char*, name of the style attribute, e.g. "background-color"
       * \return \b const \b wchar_t*, value of the style attribute
       **/
      const wchar_t* get_style_attribute( const char* name ) const 
        { 
          LPCWSTR lpw = 0;
          SciterGetStyleAttribute(he, name, &lpw);
          return lpw;
        }

      /**Set style attribute.
       * \param name \b const \b char*, name of the style attribute
       * \param value \b const \b wchar_t*, value of the style attribute
       *
       * \par Example:
       * \code e.set_style_attribute("background-color", L"red"); \endcode
       **/
      void set_style_attribute( const char* name, const wchar_t* value ) const 
        { 
          SciterSetStyleAttribute(he, name, value);
        }

      /**Get root DOM element of the Sciter document.
       * \param hSciterWnd \b HWND, Sciter window
       * \return \b #HELEMENT, root element
       * \see also \b #root
       **/
        static HELEMENT root_element(HWND hSciterWnd)
        {
          HELEMENT h = 0;
          SciterGetRootElement(hSciterWnd,&h);
          return h;
        }

      /**Get focus DOM element of the Sciter document.
       * \param hSciterWnd \b HWND, Sciter window
       * \return \b #HELEMENT, focus element
       *
       * COMMENT: to set focus use: set_state(STATE_FOCUS)
       *
       **/
        static HELEMENT focus_element(HWND hSciterWnd)
        {
          HELEMENT h = 0;
          SciterGetFocusElement(hSciterWnd,&h);
          return h;
        }
     

      /**Find DOM element of the Sciter document by coordinates.
       * \param hSciterWnd \b HWND, Sciter window
       * \param clientPt \b POINT,  coordinates.
       * \return \b #HELEMENT, found element handle or zero
       **/
        static HELEMENT find_element(HWND hSciterWnd, POINT clientPt)
        {
          HELEMENT h = 0;
          SciterFindElement(hSciterWnd, clientPt, &h);
          return h;
        }

     
      /**Set mouse capture.
       * After call to this function all mouse events will be targeted to this element.
       * To remove mouse capture call #sciter::dom::element::release_capture().
       **/
        void set_capture() { SciterSetCapture(he); }

      /**Release mouse capture.
       * Mouse capture can be set with #element:set_capture()
       **/
        void release_capture() { SciterReleaseCapture(he); }

        inline static BOOL CALLBACK callback_func( HELEMENT he, LPVOID param )
        {
          callback *pcall = (callback *)param;
          return pcall->on_element(he)? TRUE:FALSE; // TRUE - stop enumeration
        }

        inline void select_elements( callback *pcall,  
                            const char* selectors // CSS selectors, comma separated list
                          ) const
        {
          SciterSelectElements( he, selectors, callback_func, pcall);
        }

 
       /**Get element by id.
       * \param id \b char*, value of the "id" attribute.
       * \return \b #HELEMENT, handle of the first element with the "id" attribute equal to given.
       **/
         HELEMENT get_element_by_id(const char* id) const
         {
            if(!id) return 0;
            return find_first( "[id='%s']", id );
         }

         HELEMENT get_element_by_id(const wchar_t* id) const
         {
            if(!id) return 0;
            return find_first( "[id='%S']", id );
         }

 
      /**Apply changes and refresh element area in its window.
       * \param[in] render_now \b bool, if true element will be redrawn immediately.
       **/
         void update( bool render_now = false ) const 
         { 
            SciterUpdateElement(he, render_now? TRUE:FALSE); 
         }

         void refresh( RECT rc ) const 
         { 
            SciterRefreshElementArea(he, rc); 
         }

         void refresh( ) const 
         { 
            RECT rc = get_location(SELF_RELATIVE | CONTENT_BOX);
            refresh( rc );
         }

 
      /**Get next sibling element.
       * \return \b #HELEMENT, handle of the next sibling element if it exists or 0 otherwise
       **/
         HELEMENT next_sibling() const 
         {
           unsigned int idx = index() + 1;
           element pel = parent();
           if(!pel.is_valid())
            return 0;
          if( idx >= pel.children_count() )
            return 0;
          return pel.child(idx);
        }

      /**Get previous sibling element.
       * \return \b #HELEMENT, handle of previous sibling element if it exists or 0 otherwise
       **/
        HELEMENT prev_sibling() const 
        {
          unsigned int idx = index() - 1;
          element pel = parent();
          if(!pel.is_valid())
            return 0;
          if( idx < 0 )
            return 0;
          return pel.child(idx);
        }

      /**Get first sibling element.
       * \return \b #HELEMENT, handle of the first sibling element if it exists or 0 otherwise
       **/
         HELEMENT first_sibling() const 
         {
           element pel = parent();
           if(!pel.is_valid())
            return 0;
          return pel.child(0);
        }

      /**Get last sibling element.
       * \return \b #HELEMENT, handle of last sibling element if it exists or 0 otherwise
       **/
        HELEMENT last_sibling() const 
        {
           element pel = parent();
           if(!pel.is_valid())
            return 0;
          return pel.child(pel.children_count() - 1);
        }


      /**Get root of the element
       * \return \b #HELEMENT, handle of document root element (html)
       **/
        HELEMENT root() const 
        {
          element pel = parent();
          if(pel.is_valid()) return pel.root();
          return he;
        }


      /**Get bounding rectangle of the element.
       * \param root_relative \b bool, if true function returns location of the 
       * element relative to Sciter window, otherwise the location is given 
       * relative to first scrollable container.
       * \return \b RECT, bounding rectangle of the element.
       **/
        RECT get_location(unsigned int area = ROOT_RELATIVE | CONTENT_BOX) const
        {
          RECT rc = {0,0,0,0};
          SciterGetElementLocation(he,&rc, area);
          return rc;
        }

        /** Test if point is inside shape rectangle of the element.
          client_pt - client rect relative point          
         **/
        bool is_inside( POINT client_pt ) const
        {
          RECT rc = get_location(ROOT_RELATIVE | BORDER_BOX);
          return PtInRect(&rc,client_pt) != FALSE;
        }

        /**Scroll this element to view.
         **/
        void scroll_to_view(bool toTopOfView = false)
        {
          SciterScrollToView(he,toTopOfView?TRUE:FALSE);
        }

        void get_scroll_info(POINT& scroll_pos, RECT& view_rect, SIZE& content_size)
        {
          SCDOM_RESULT r = SciterGetScrollInfo(he, &scroll_pos, &view_rect, &content_size);
          assert(r == SCDOM_OK); r;
        }
        void set_scroll_pos(POINT scroll_pos)
        {
          SCDOM_RESULT r = SciterSetScrollPos(he, scroll_pos, TRUE);
          assert(r == SCDOM_OK); r;
        }

        /** get min-intrinsic and max-intrinsic widths of the element. */
        void get_intrinsic_widths(int& min_width,int& max_width)
        {
          SCDOM_RESULT r = SciterGetElementIntrinsicWidths(he, &min_width, &max_width);
          assert(r == SCDOM_OK); r;
        }
        /** get min-intrinsic height of the element calculated for forWidth. */
        void get_intrinsic_height(int for_width, int& min_height)
        {
          SCDOM_RESULT r = SciterGetElementIntrinsicHeight(he, for_width, &min_height);
          assert(r == SCDOM_OK); r;
        }

        /**Get element's type.
       * \return \b const \b char*, name of the elements type
       * 
         * \par Example:
         * For &lt;div&gt; tag function will return "div".
       **/
        const char* get_element_type() const
        {
          LPCSTR str = 0;
          SciterGetElementType(he,&str);
          return str;
        }

      /**Get HWND of containing window.
       * \param root_window \b bool, handle of which window to get:
       * - true - Sciter window
       * - false - nearest windowed parent element. 
       * \return \b HWND
       **/
        HWND get_element_hwnd(bool root_window)
        {
          HWND hwnd = 0;
          SciterGetElementHwnd(he,&hwnd, root_window? TRUE : FALSE);
          return hwnd;
        }

        void attach_hwnd(HWND child)
        {
          SCDOM_RESULT r = SciterAttachHwndToElement(he,child);
          assert( r == SCDOM_OK ); 
        }
          

      /**Get element UID - identifier suitable for storage.
       * \return \b UID
       **/
        UINT get_element_uid()
        {
          UINT uid = 0;
          SciterGetElementUID(he,&uid);
          return uid;
        }

      /**Get element handle by its UID.
       * \param hSciterWnd \b HWND, Sciter window
       * \param uid \b UINT, uid of the element
       * \return \b #HELEMENT, handle of element with the given uid or 0 if not found
       **/
        static HELEMENT element_by_uid(HWND hSciterWnd, UINT uid)
        {
          HELEMENT h = 0;
          SciterGetElementByUID(hSciterWnd, uid,&h);
          return h;
        }

      /**Combine given URL with URL of the document element belongs to.
       * \param[in, out] inOutURL \b LPWSTR, at input this buffer contains 
       * zero-terminated URL to be combined, after function call it contains 
       * zero-terminated combined URL
       * \param bufferSize \b UINT, size of the buffer pointed by \c inOutURL
         **/
        void combine_url(LPWSTR inOutURL, UINT bufferSize)
        {
          SciterCombineURL(he,inOutURL,bufferSize);
        }

        json::string combine_url(const json::string& relative_url)
        {
          wchar_t buffer[4096] = {0};
          wcsncpy(buffer,relative_url,min(4096,relative_url.length()));
          SciterCombineURL(he,buffer,4096);
          return json::string(buffer);
        }

      /**Set inner or outer html of the element.
       * \param html \b const \b unsigned \b char*, UTF-8 encoded string containing html text
       * \param html_length \b size_t, length in bytes of \c html
       * \param where \b int, possible values are:
       * - SIH_REPLACE_CONTENT - replace content of the element
       * - SIH_INSERT_AT_START - insert html before first child of the element
       * - SIH_APPEND_AFTER_LAST - insert html after last child of the element
       **/
        void set_html( const unsigned char* html, size_t html_length, int where = SIH_REPLACE_CONTENT)
        { 
          if(html == 0 || html_length == 0)
            clear();
          else
          {
            SCDOM_RESULT r = SciterSetElementHtml(he, html, DWORD(html_length), where);
            assert(r == SCDOM_OK); r;
          }
        }

        static VOID CALLBACK _LPCBYTE2ASTRING( LPCBYTE bytes, UINT num_bytes, LPVOID param )
        {
           json::astring* s = (json::astring*)param;
           *s = aux::chars((const char*)bytes,num_bytes);
        }

        // html as utf8 bytes sequence
        json::astring 
            get_html( bool outer = true) const 
        { 
          json::astring s;
          SCDOM_RESULT r = SciterGetElementHtmlCB(he, outer? TRUE:FALSE, &_LPCBYTE2ASTRING,&s);
          assert(r == SCDOM_OK); r;
          return s;
        }

        static VOID CALLBACK _LPCWSTR2STRING( LPCWSTR str, UINT str_length, LPVOID param )
        {
           json::string* s = (json::string*)param;
           *s = aux::wchars(str,str_length);
        }

        // get text as json::string (utf16)
        json::string text() const
        {
          json::string s;
          SCDOM_RESULT r = SciterGetElementTextCB(he, &_LPCWSTR2STRING, &s);
          assert(r == SCDOM_OK); r;
          return s;
        }

        void  set_text(const wchar_t* utf16, size_t utf16_length)
        {
          SCDOM_RESULT r = SciterSetElementText(he, utf16, utf16_length);
          assert(r == SCDOM_OK); r;
        }

        void  set_text(const wchar_t* t)
        {
          assert(t);
          if( t ) set_text( t, wcslen(t) );
        }

        void clear() // clears content of the element
        {
          SCDOM_RESULT r = SciterSetElementText(he, L"", 0);
          assert(r == SCDOM_OK); r;
        }

        HELEMENT find_first( const char* selector, ... ) const
        {
          char buffer[2049]; buffer[0]=0;
          va_list args;
          va_start ( args, selector );
          int len = _vsnprintf( buffer, 2048, selector, args );
          va_end ( args );
          find_first_callback find_first;
          select_elements( &find_first, buffer); // find first element satisfying given CSS selector
          //assert(find_first.hfound);
          return find_first.hfound;
        }

        void find_all( callback* cb, const char* selector, ... ) const
        {
          char buffer[2049]; buffer[0]=0;
          va_list args;
          va_start ( args, selector );
          int len = _vsnprintf( buffer, 2048, selector, args );
          va_end ( args );
          select_elements( cb, buffer); // find all elements satisfying given CSS selector
          //assert(find_first.hfound);
        }

        // will find first parent satisfying given css selector(s)
        HELEMENT find_nearest_parent(const char* selector, ...) const
        {
          char buffer[2049]; buffer[0]=0;
          va_list args;
          va_start ( args, selector );
          int len = _vsnprintf( buffer, 2048, selector, args );
          va_end ( args );
        
          HELEMENT heFound = 0;
          SCDOM_RESULT r = SciterSelectParent(he, buffer, 0, &heFound);
          assert(r == SCDOM_OK); r;
          return heFound;
        }

        // test this element against CSS selector(s) 
        bool test(const char* selector, ...) const
        {
          char buffer[2049]; buffer[0]=0;
          va_list args;
          va_start ( args, selector );
          int len = _vsnprintf( buffer, 2048, selector, args );
          va_end ( args );
          HELEMENT heFound = 0;
          SCDOM_RESULT r = SciterSelectParent(he, buffer, 1, &heFound);
          assert(r == SCDOM_OK); r;
          return heFound != 0;
        }


      /**Get UI state bits of the element as set of ELEMENT_STATE_BITS 
       **/
        unsigned int get_state() const
        {
          UINT state = 0;
          SCDOM_RESULT r = SciterGetElementState(he,&state);
          assert(r == SCDOM_OK); r;
          return (ELEMENT_STATE_BITS) state;
        }

      /**Checks if particular UI state bits are set in the element.
       **/
        bool get_state(/*ELEMENT_STATE_BITS*/ unsigned int bits) const
        {
          UINT state = 0;
          SCDOM_RESULT r = SciterGetElementState(he,&state);
          assert(r == SCDOM_OK); r;
          return (state & bits) != 0;
        }


      /**Set UI state of the element with optional view update.
       **/
        void set_state(
          /*ELEMENT_STATE_BITS*/ unsigned int bitsToSet, 
          /*ELEMENT_STATE_BITS*/ unsigned int bitsToClear = 0, bool update = true )
        {
          SCDOM_RESULT r = SciterSetElementState(he,bitsToSet,bitsToClear, update?TRUE:FALSE);
          assert(r == SCDOM_OK); r;
        }

        /** "deeply enabled" **/
        bool enabled() 
        {
          BOOL b = FALSE;
          SCDOM_RESULT r = SciterIsElementEnabled(he,&b);
          assert(r == SCDOM_OK); r;
          return b != 0;
        }

        /** "deeply visible" **/
        bool visible() 
        {
          BOOL b = FALSE;
          SCDOM_RESULT r = SciterIsElementVisible(he,&b);
          assert(r == SCDOM_OK); r;
          return b != 0;
        }

        void start_timer(unsigned int ms, void* timer_id = 0)
        {
          SCDOM_RESULT r = SciterSetTimer(he,ms,UINT_PTR(timer_id));
          assert(r == SCDOM_OK); r;
        }
        void stop_timer(void* timer_id = 0)
        {
          if(he)
          {
            SCDOM_RESULT r = SciterSetTimer(he,0,UINT_PTR(timer_id));
            assert(r == SCDOM_OK); r;
          }
        }


      /** create brand new element with text (optional).
          Example:
             element div = element::create("div");
          - will create DIV element,
             element opt = element::create("option",L"Europe");
          - will create OPTION element with text "Europe" in it.
       **/
        static element create(const char* tagname, const wchar_t* text = 0)
        {
           element e(0);
           SCDOM_RESULT r = SciterCreateElement( tagname, text, &e.he ); // don't need 'use' here, as it is already "addrefed" 
           assert(r == SCDOM_OK); r;
           return e;
        }

      /** create brand new copy of this element. Element will be created disconected.
          You need to call insert to inject it in some container.
          Example:
             element select = ...;
             element option1 = ...;
             element option2 = option1.clone();
              select.insert(option2, option1.index() + 1);
          - will create copy of option1 element (option2) and insert it after option1,
       **/
        element clone()
        {
           element e(0);
           SCDOM_RESULT r = SciterCloneElement( he, &e.he ); // don't need 'use' here, as it is already "addrefed" 
           assert(r == SCDOM_OK); r;
           return e;
        }


      /** Insert element e at \i index position of this element.
       **/
        void insert( const element& e, unsigned int index )
        {
           SCDOM_RESULT r = SciterInsertElement( e.he, this->he, index );
           assert(r == SCDOM_OK); r;
        }

      /** Append element e as last child of this element.
       **/
        void append( const element& e ) { insert(e,0x7FFFFFFF); }


       /** detach - remove this element from its parent
        **/
        void detach()
        {
          SCDOM_RESULT r = SciterDetachElement( he );
          assert(r == SCDOM_OK); r;
        }

       /** destroy - remove this element from its parent and destroy all behaviors
        **/
        void destroy()
        {
		  HELEMENT t = he; he = 0;
          SCDOM_RESULT r = SciterDeleteElement( t );
          assert(r == SCDOM_OK); r;
        }


       /** swap two elements in the DOM
        **/
        void swap(HELEMENT with)
        {
           SCDOM_RESULT r = SciterSwapElements(he, with);
           assert(r == SCDOM_OK); r;
        }

        /** traverse event - send it by sinking/bubbling on the 
         * parent/child chain of this element
         **/
        bool send_event(unsigned int event_code, unsigned int reason = 0, HELEMENT heSource = 0)
        {
          BOOL handled = FALSE;
          SCDOM_RESULT r = SciterSendEvent(he, event_code, heSource? heSource: he, reason, &handled);
          assert(r == SCDOM_OK); r;
          return handled != 0;
        }

        /** post event - post it in the queue for later sinking/bubbling on the 
         * parent/child chain of this element.
         * method returns immediately
         **/
        void post_event(unsigned int event_code, unsigned int reason = 0, HELEMENT heSource = 0)
        {
          SCDOM_RESULT r = SciterPostEvent(he, event_code, heSource? heSource: he, reason);
          assert(r == SCDOM_OK); r;
        }

        /** call method, invokes method in all event handlers attached to the element
         **/
        bool call_behavior_method(METHOD_PARAMS* p)
        {
          if(!is_valid())
            return false;
          return SciterCallBehaviorMethod(he,p) == SCDOM_OK;
        }

        void load_html(const wchar_t* url, HELEMENT initiator = 0)
        {
          load_data(url,RT_DATA_HTML, initiator);
        }

        void load_data(const wchar_t* url, UINT dataType, HELEMENT initiator = 0)
        {
          SCDOM_RESULT r = SciterRequestElementData(he,url, dataType, initiator);
          assert(r == SCDOM_OK); r;
        }


        struct comparator 
        {
          virtual int compare(const sciter::dom::element& e1, const sciter::dom::element& e2) = 0;

          static INT CALLBACK scmp( HELEMENT he1, HELEMENT he2, LPVOID param )
          {
            sciter::dom::element::comparator* self = 
              static_cast<sciter::dom::element::comparator*>(param);

            sciter::dom::element e1 = he1;
            sciter::dom::element e2 = he2;

            return self->compare( e1,e2 );
          }
        };

        /** reorders children of the element using sorting order defined by cmp 
         **/
        void sort( comparator& cmp, int start = 0, int end = -1 )
        {
          if (end == -1)
            end = children_count();

          SCDOM_RESULT r = SciterSortElements(he, start, end, &comparator::scmp, &cmp);
          assert(r == SCDOM_OK); r;
        }

        // "manually" attach event_handler proc to the DOM element 
        void attach_event_handler(event_handler* p_event_handler )
        {
          SciterAttachEventHandler(he, &event_handler::element_proc, p_event_handler);
        }
  
        void detach_event_handler(event_handler* p_event_handler )
        {
          SciterDetachEventHandler(he, &event_handler::element_proc, p_event_handler);
        }

        // call scripting method attached to the element (directly or through of scripting behavior)  
        // Example, script:
        //   var elem = ...
        //   elem.foo = function() {...}
        // Native code: 
        //   dom::element elem = ...
        //   elem.call_method("foo");
        json::value  call_method(LPCSTR name, UINT argc, json::value* argv )
        {
          json::value rv;
          SCDOM_RESULT r = SciterCallScriptingMethod(he, name, argv,argc, &rv);
          assert(r == SCDOM_OK); r;
          return rv;
        }

        // flattened wrappers of the above. 
        json::value  call_method(LPCSTR name )
        {
          return call_method(name,0,0);
        }
        json::value  call_method(LPCSTR name, json::value arg0 )
        {
          return call_method(name,1,&arg0);
        }
        json::value  call_method(LPCSTR name, json::value arg0, json::value arg1 )
        {
          json::value argv[2]; argv[0] = arg0; argv[1] = arg1;
          return call_method(name,2,argv);
        }
        json::value  call_method(LPCSTR name, json::value arg0, json::value arg1, json::value arg2 )
        {
          json::value argv[3]; argv[0] = arg0; argv[1] = arg1; argv[2] = arg2;
          return call_method(name,3,argv);
        }
        json::value  call_method(LPCSTR name, json::value arg0, json::value arg1, json::value arg2, json::value arg3 )
        {
          json::value argv[4]; argv[0] = arg0; argv[1] = arg1; argv[2] = arg2; argv[3] = arg3;
          return call_method(name,4,argv);
        }

        // call scripting function defined on global level   
        // Example, script:
        //   function foo() {...}
        // Native code: 
        //   dom::element root = ... get root element of main document or some frame inside it
        //   root.call_function("foo"); // call the function

        json::value  call_function(LPCSTR name, UINT argc, json::value* argv )
        {
          json::value rv;
          SCDOM_RESULT r = SciterCallScriptingFunction(he, name, argv,argc, &rv);
          assert(r == SCDOM_OK); r;
          return rv;
        }

        // flattened wrappers of the above. note json::value is a json::value
        json::value  call_function(LPCSTR name )
        {
          return call_function(name,0,0);
        }
        // flattened wrappers of the above. note json::value is a json::value
        json::value  call_function(LPCSTR name, json::value arg0 )
        {
          return call_function(name,1,&arg0);
        }
        json::value  call_function(LPCSTR name, json::value arg0, json::value arg1 )
        {
          json::value argv[2]; argv[0] = arg0; argv[1] = arg1;
          return call_function(name,2,argv);
        }
        json::value  call_function(LPCSTR name, json::value arg0, json::value arg1, json::value arg2 )
        {
          json::value argv[3]; argv[0] = arg0; argv[1] = arg1; argv[2] = arg2;
          return call_function(name,3,argv);
        }
        json::value  call_function(LPCSTR name, json::value arg0, json::value arg1, json::value arg2, json::value arg3 )
        {
          json::value argv[4]; argv[0] = arg0; argv[1] = arg1; argv[2] = arg2; argv[3] = arg3;
          return call_function(name,4,argv);
        }

        CTL_TYPE get_ctl_type() const
        {
          UINT t = 0;
          SCDOM_RESULT r = ::SciterControlGetType(he,&t);
          assert(r == SCDOM_OK); r;
          return CTL_TYPE(t);
        }

        SCITER_VALUE get_value()
        {
          SCITER_VALUE rv;
          SCDOM_RESULT r = SciterGetValue(he, &rv);
          assert(r == SCDOM_OK); r;
          return rv;
        }

        void set_value(const SCITER_VALUE& v)
        {
          SCDOM_RESULT r = SciterSetValue(he, &v);
          assert(r == SCDOM_OK); r;
        }

        // get scripting object associated with this DOM element
        SCITER_VALUE get_expando(bool force_create = false)
        {
          SCITER_VALUE rv;
          SCDOM_RESULT r = SciterGetExpando(he, &rv, force_create);
          assert(r == SCDOM_OK); r;
          return rv;
        }

        // get scripting object associated with this DOM element
        tiscript::value get_object(bool force_create = false)
        {
          tiscript::value rv;
          SCDOM_RESULT r = SciterGetObject(he, &rv, force_create);
          assert(r == SCDOM_OK); r;
          return rv;
        }

        tiscript::value get_namespace()
        {
          tiscript::value rv;
          SCDOM_RESULT r = SciterGetElementNamespace(he, &rv);
          assert(r == SCDOM_OK); r;
          return rv;
        }
        

        struct find_first_callback: callback 
        {
          HELEMENT hfound;
          find_first_callback():hfound(0) {}
          inline bool on_element(HELEMENT he) { hfound = he; return true; /*stop enumeration*/ }
        };


      };

      #define STD_CTORS(T,PT) \
        T() { } \
        T(HELEMENT h): PT(h) { } \
        T(const element& e): PT(e) { } \
        T& operator = (HELEMENT h) { set(h); return *this; } \
        T& operator = (const element& e) { set(e); return *this; }

      class editbox: public element
      {
        
        public: 
          STD_CTORS(editbox, element)
        
          bool selection( int& start, int& end )
          {
            TEXT_EDIT_SELECTION_PARAMS sp(false);
            if(!call_behavior_method(&sp))
              return false;
            start = sp.selection_start;
            end = sp.selection_end;
            return true;
          }
          bool select( int start = 0, int end = 0xFFFF )
          {
            TEXT_EDIT_SELECTION_PARAMS sp(true);
            sp.selection_start = start;
            sp.selection_end = end;
            return call_behavior_method(&sp);
          }
          bool replace(const wchar_t* text, size_t text_length)
          {
            TEXT_EDIT_REPLACE_SELECTION_PARAMS sp;
            sp.text = text;
            sp.text_length = text_length;
            return call_behavior_method(&sp);
          }

          json::string text_value() const
          {
            TEXT_VALUE_PARAMS sp(false);
            if( const_cast<editbox*>(this)->call_behavior_method(&sp) && sp.text && sp.length)
            {
                return json::string(sp.text, sp.length);
            }
            return json::string();
          }

          void text_value(const wchar_t* text, size_t length)
          {
            TEXT_VALUE_PARAMS sp(true);
            sp.text = text;
            sp.length = length;
            call_behavior_method(&sp);
            update();
          }

          void text_value(const wchar_t* text)
          {
            TEXT_VALUE_PARAMS sp(true);
            sp.text = text;
            sp.length = text?wcslen(text):0;
            call_behavior_method(&sp);
            update();
          }

          void int_value( int v )
          {
             wchar_t buf[64]; int n = _snwprintf(buf,63,L"%d", v); buf[63] = 0;
             text_value(buf,n);
          }
        
          int int_value( ) const
          {
             return _wtoi( text_value().c_str() );
          }

          int char_pos_at_xy(int x, int y) const
          {
            TEXT_EDIT_CHAR_POS_AT_XY_PARAMS sp;
            sp.x = x;
            sp.y = y;
            if(!const_cast<editbox*>(this)->call_behavior_method(&sp))
              return -1;
            return sp.char_pos;
          }

      };
      
      class scrollbar: public element
      {
        public: 
          STD_CTORS(scrollbar, element)

          void get_values( int& val, int& min_val, int& max_val, int& page_val, int& step_val )
          {
            SCROLLBAR_VALUE_PARAMS sbvp;
            call_behavior_method(&sbvp);
            val       = sbvp.value;
            min_val   = sbvp.min_value;
            max_val   = sbvp.max_value;
            page_val  = sbvp.page_value; // page increment
            step_val  = sbvp.step_value; // step increment (arrow button click) 
          }

          void set_values( int val, int min_val, int max_val, int page_val, int step_val )
          {
            SCROLLBAR_VALUE_PARAMS sbvp(true);
            sbvp.value       = val;
            sbvp.min_value   = min_val;
            sbvp.max_value   = max_val; 
            sbvp.page_value  = page_val;
            sbvp.step_value  = step_val;
            call_behavior_method(&sbvp);
          }

          int   get_value()
          {
            SCROLLBAR_VALUE_PARAMS sbvp;
            call_behavior_method(&sbvp);
            return sbvp.value;
          }

          void  set_value( int v )
          {
            SCROLLBAR_VALUE_PARAMS sbvp;
            call_behavior_method(&sbvp);
            sbvp.value = v;
            sbvp.methodID = SCROLL_BAR_SET_VALUE;
            call_behavior_method(&sbvp);
          }
      };
      

    } // dom namespace

  } // sciter namespace
  
  #endif // __cplusplus


#endif
