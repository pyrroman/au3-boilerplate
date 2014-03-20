//////////////////////////////////////////////////////////////////////////
//
// tags.cpp - library exports implementation
//
// Author: Wraith, 2k5-2k6
// Public domain. No warranty.
//
// (internal)
// 

#include <memory>
#include <windows.h>
#include "tags.h"
#include "tags_impl.h"
#include "keywords.h"

std::string g_err;
std::string g_cache;

const char*  _stdcall TAGS_GetLastErrorDesc()
{
	return g_err.c_str();
}


const char*  _stdcall TAGS_Read( DWORD dwHandle, const char* fmt )
{
	std::auto_ptr< tag_reader > reader( create_tag_reader( dwHandle ) ); // although i'm not sure if this exception-safety worth it... parser::expr is nothrow, others throw, but are likely to crash anyway
	if( reader.get() )
	{
		std::string str(fmt);
		std::string::const_iterator beg = str.begin();
		g_cache = parser::expr( beg, str.end(), reader.get() );
		return g_cache.c_str();
	}
	return TAGS_MAIN_ERROR_RETURN_VALUE;
}

DWORD _stdcall TAGS_GetVersion()
{
	return TAGS_VERSION;
}
