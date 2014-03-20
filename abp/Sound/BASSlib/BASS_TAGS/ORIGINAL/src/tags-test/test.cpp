//////////////////////////////////////////////////////////////////////////
//
// test.cpp - library testing tool. Not a regression test however...
//
// Author: Wraith, 2k5-2k6
// Public domain. No warranty.
// 


#include "../basslib/bass.h"
#include "../tags/tags.h"

#include <iostream>

void try_file( const char* file, const char* fmt )
{
	std::cout<<"====== "<<file<<" =======\n";
	DWORD h = BASS_StreamCreateFile( false, (const void*)file, 0,0,BASS_STREAM_DECODE );
	if( h )
	{
		const char* t = TAGS_Read( h, fmt );
		if( *t )
			std::cout<<t<<std::endl;
		else
			std::cout<<"("<<TAGS_GetLastErrorDesc()<<")"<<std::endl;
		BASS_StreamFree( h );
	}else
		std::cout<<"(couldn't open)"<<std::endl;

}

void timing_test()
{
	std::cout<<"Timing test..."<<std::endl;
	const char* const fmt = "%IFV1(%ITRM(%TRCK),%ITRM(%TRCK). )%IFV2(%ITRM(%ARTI),%ICAP(%ITRM(%ARTI)),no artist) - %IFV2(%ITRM(%TITL),%ICAP(%ITRM(%TITL)),no title)%IFV1(%ITRM(%ALBM), - %IUPC(%ITRM(%ALBM)))%IFV1(%YEAR, %(%YEAR%))%IFV1(%ITRM(%GNRE), {%ITRM(%GNRE)})%IFV1(%ITRM(%CMNT), [%ITRM(%CMNT)])";
	DWORD h = BASS_StreamCreateFile( false, (const void*)"id3v2.mp3", 0,0,BASS_STREAM_DECODE );

	__int64 s,c,f;
	QueryPerformanceFrequency( (LARGE_INTEGER*) &f );
	QueryPerformanceCounter( (LARGE_INTEGER*) &s );

	float t = 0;
	int cnt = 0;
	const float duration = 3;

	while( t<duration )
	{
		const char* tag = TAGS_Read( h, fmt );

		QueryPerformanceCounter( (LARGE_INTEGER*)&c );
		t += float(c-s)/f;
		s = c;
		++cnt;
	}

	std::cout<<"\r                                                 \r";
	std::cout<<"Timing: "<<duration<<" sec., "<<cnt<<" calls, "<<duration/cnt<<" sec avg."<<std::endl;

	BASS_StreamFree( h );

}

int main()
{
	const char* fmt = "[%TITL|%ARTI|%ALBM|%GNRE|%YEAR|%CMNT|%TRCK]";
	BASS_Init( 0, 0, 0, 0, 0 );
	BASS_PluginLoad( "basswma.dll" );
	BASS_PluginLoad( "bass_ape.dll" );

	try_file( "id3v2.mp3", fmt );
	try_file( "id3v1.mp3", fmt );
	try_file( "id3-both.mp3", fmt  );
	try_file( "ogg.ogg", fmt  );
	try_file( "wma.wma", fmt );
	try_file( "ape.ape", fmt );
	try_file( "ofr.ofr", fmt );

	timing_test();

	BASS_Free();
}

