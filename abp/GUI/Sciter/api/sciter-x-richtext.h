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

#ifndef __sciter_richtext_hpp__
#define __sciter_richtext_hpp__

#include <assert.h>
#include <stdio.h> // for vsnprintf

#include <windows.h>

#include "sciter-x.h"
#include "sciter-x-aux.h"
#include "sciter-x-dom.h"
#include "sciter-x-behavior.h"

#pragma warning(disable:4786) //identifier was truncated...
#pragma warning(disable:4996) //'strcpy' was declared deprecated
#pragma warning(disable:4100) //unreferenced formal parameter 

#pragma once

// handle of bookmark - position in the richtext

typedef void*  H_RT_BOOKMARK;
typedef void*  H_RT_RANGE;

struct RichtextApi
{
  SCDOM_RESULT (STDCALL *RangeFree)(H_RT_RANGE hbm, UINT where);
  SCDOM_RESULT (STDCALL *RangeGet)(HELEMENT hRichtext, H_RT_RANGE* hbm, BOOL selection/*FALSE: whole text*/);

  enum RANGE_TYPE 
  {
    EMPTY_RANGE = 0, // empty range - START == END == current caret position
    TEXT_RANGE = 1, // textual selection
    CELLS_RANGE = 2, // selection on table 
  };

  SCDOM_RESULT (STDCALL *RangeGetType)(H_RT_RANGE hbm, UINT* rangeType);

  enum MOVE_DIRECTION 
  {
    NEXT_POS,
    PREV_POS,
    NEXT_CARET_POS,
    PREV_CARET_POS,
    ELEMENT_START,
    ELEMENT_END,
    BLOCK_START,
    BLOCK_END,
    PARENT_BLOCK_START,
    PARENT_BLOCK_END,
    START,
    END,
  };
  
  SCDOM_RESULT (STDCALL *BookmarkCreate)(HELEMENT hRichtext,H_RT_BOOKMARK* phbm);
  SCDOM_RESULT (STDCALL *BookmarkFree)(H_RT_BOOKMARK hbm);

  SCDOM_RESULT (STDCALL *MoveBookmark)(H_RT_RANGE hbm, UINT where);

  enum POS_DESCRIPTION 
  {
    AT_BLOCK_START  = 0x01,
    AT_BLOCK_END    = 0x02,
    AT_CHAR_POS     = 0x10,
    AT_CARET_POS    = 0x20
  };
  SCDOM_RESULT (STDCALL *BookmarkWhere)(H_RT_BOOKMARK hbm, UINT* posDescription /*POS_DESCRIPTION*/);

  SCDOM_RESULT (STDCALL *ElementTag)(H_RT_BOOKMARK hbm, LPCSTR* tag);
  SCDOM_RESULT (STDCALL *ElementAttributesCount)(H_RT_BOOKMARK hbm, UINT* count);
  SCDOM_RESULT (STDCALL *ElementGetAttribute)(H_RT_BOOKMARK hbm, UINT idx, LPCSTR* name, LPCWSTR* value);
  SCDOM_RESULT (STDCALL *ElementSetAttribute)(H_RT_BOOKMARK hbm, LPCSTR name, LPCWSTR value);

  SCDOM_RESULT (STDCALL *GetCharAt)(H_RT_BOOKMARK hbm, UINT* puChar);
  SCDOM_RESULT (STDCALL *Compare)(H_RT_BOOKMARK hbm1, H_RT_BOOKMARK hbm2, INT* result/*-1,0,+1*/);

  SCDOM_RESULT (STDCALL *Select)(H_RT_BOOKMARK hbm1, H_RT_BOOKMARK hbm2);

  SCDOM_RESULT (STDCALL *SetHtmlU8)(H_RT_BOOKMARK hbm1, H_RT_BOOKMARK hbm2, LPCSTR htmlUTF8);
  SCDOM_RESULT (STDCALL *SetHtmlU16)(H_RT_BOOKMARK hbm1, H_RT_BOOKMARK hbm2, LPCWSTR htmlUTF16);

  SCDOM_RESULT (STDCALL *SpanIt)(H_RT_BOOKMARK hbm1, H_RT_BOOKMARK hbm2, BOOL fore, LPCSTR tag);
  SCDOM_RESULT (STDCALL *MarkIt)(H_RT_BOOKMARK hbm1, H_RT_BOOKMARK hbm2, UINT markType);
 

};

#endif