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

#ifndef __SCITER_X_AUX_H__
#define __SCITER_X_AUX_H__

#include <stdio.h>
#include <stdlib.h>

#include "aux-cvt.h"
#include "aux-slice.h"

//
// This file is a part of 
// Terra Informatica Lightweight Embeddable HTMEngine control SDK
// Created by Andrew Fedoniouk @ TerraInformatica.com
//

//
// Auxiliary classes and functions
//

/** Oputput stream function type.
 *   
 **/
typedef int CALLBACK OutputStreamFunction( LPVOID p, LPCVOID data, UINT length );

#endif
