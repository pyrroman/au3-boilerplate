//////////////////////////////////////////////////////////////////////////
//
// mp4.cpp - MP4 tag reader implementation
//
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
		vpair("TRCK", "TRACK"),
		vpair("COMP", "WRITER"),
		vpair("AART", "ALBUMARTIST"),
	};
} // anon namespace

tag_reader* reader_mp4( DWORD handle )
{
	return new preproc_reader( 
		BASS_ChannelGetTags( handle, BASS_TAG_MP4 ),
		"MP4: bad tag format", remap, SIZE_OF_ARRAY(remap), '=', 0 );
}
