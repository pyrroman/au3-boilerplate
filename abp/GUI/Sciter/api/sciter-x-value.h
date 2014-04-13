/*
 * Terra Informatica Sciter Engine
 * http://terrainformatica.com/sciter
 * 
 * Sciter value class. 
 * 
 * The code and information provided "as-is" without
 * warranty of any kind, either expressed or implied.
 * 
 * (C) 2003-2004, Andrew Fedoniouk (andrew@terrainformatica.com)
 */

/**\file
 * \brief value, aka variant, aka discriminated union
 **/

#ifndef __sciter_x_value_h__
#define __sciter_x_value_h__

#pragma once

#include <string>

#include "sciter-x-aux.h"

#define HAS_TISCRIPT

#include "value.h"

#if defined(__cplusplus) && !defined( PLAIN_API_ONLY )
  typedef json::value SCITER_VALUE;
#else
  typedef VALUE SCITER_VALUE;
#endif

#endif
