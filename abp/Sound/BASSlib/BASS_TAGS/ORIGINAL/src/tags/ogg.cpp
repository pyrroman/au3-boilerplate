//////////////////////////////////////////////////////////////////////////
//
// ogg.cpp - ogg tag reader implementation
//
// Author: Wraith, 2k5-2k6
// Public domain. No warranty.
// 
// (internal)
//

#include "tag_preproc.h"

namespace{

	typedef preproc_reader::vpair vpair;
	vpair remap[] = 
	{
		vpair("TITL", "TITLE"),
		vpair("ARTI", "ARTIST"),
		vpair("ALBM", "ALBUM"),
		vpair("GNRE", "GENRE"),
		vpair("YEAR", "DATE"),
		vpair("CMNT", "COMMENT"),
		vpair("TRCK", "TRACKNUMBER"),
		vpair("COMP", "COMPOSER"),
		vpair("COPY", "COPYRIGHT"),
		vpair("SUBT", "SUBTITLE"),
		vpair("AART", "ALBUMARTIST|ALBUM ARTIST"),
	};
} // anon namespace

tag_reader* reader_ogg( DWORD handle )
{
	return new preproc_reader( 
		BASS_ChannelGetTags( handle, BASS_TAG_OGG ),
		"OGG: bad tag format", remap, SIZE_OF_ARRAY(remap), '=', 0 );
}
