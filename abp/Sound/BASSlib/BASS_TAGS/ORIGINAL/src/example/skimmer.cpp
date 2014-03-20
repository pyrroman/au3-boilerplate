//
// A simple tool to list tags from files in a directory tree
//
// Author: Wraith, 2k5-2k6
// Public domain. No warranty.
//

#include <vector>
#include <string>
#include <cassert>
#include <iostream>
#include <algorithm>
#include <io.h>
#include "../basslib/bass.h"
#include "../tags/tags.h"
using namespace std;

const char* const g_fmt = "%IFV1(%ITRM(%TRCK),%ITRM(%TRCK). )%IFV2(%ITRM(%ARTI),%ICAP(%ITRM(%ARTI)),no artist) - %IFV2(%ITRM(%TITL),%ICAP(%ITRM(%TITL)),no title)%IFV1(%ITRM(%ALBM), - %IUPC(%ITRM(%ALBM)))%IFV1(%YEAR, %(%YEAR%))%IFV1(%ITRM(%GNRE), {%ITRM(%GNRE)})%IFV1(%ITRM(%CMNT), [%ITRM(%CMNT)])";
float g_time = 0;

struct has_ext
{
	const string& m_str;
	has_ext( const string& r ): m_str(r) {}

	bool operator() ( const string& r ) const
	{
		return m_str.length() > r.length() && m_str.substr( m_str.length() - r.length(), r.length() ) == r;
	}
};


template< class I, class Fn >
int do_find_files( string path, I typesF, I typesL, Fn fp )
{
	cerr<<path<<"\r";
	int count = 0;
	vector< string > dirs;

	if( !path.empty() && *(path.end()-1) != '\\' && *(path.end()-1) != '/' )
	{
			path += '\\';
	}
	string spec( path + "*.*" );

	_finddata_t fd;
	int handle = (int)_findfirst( spec.c_str(), &fd );
	if( handle == -1 )
		return 0;

	bool exitflag = false;
	do{
		if( fd.attrib & _A_SUBDIR )
		{
			if( fd.name != string(".") && fd.name != string("..") )
				dirs.push_back( path + fd.name );
		}else
		{
			if( find_if( typesF, typesL, has_ext( fd.name ) ) != typesL )
			{
				if( !fp( path + fd.name ) )
				{
					exitflag = true;
					break;
				}
				++count;
			}
		}
	}while( !_findnext( handle, &fd ) );
	_findclose(handle );

	for(size_t i=0; i<path.length(); ++i )
		cerr<<' ';
	cerr<<'\r';

	if( !exitflag )
	{
		for( size_t i=0; i<dirs.size(); ++i )
			count += do_find_files( dirs[i], typesF, typesL, fp );
	}
	return count;
}

string ato( const char* s )
{
	static vector<char> temp;
	temp.resize( strlen( s ) + 1 );
	AnsiToOem( s, &temp[0] );
	return string( temp.begin(), temp.end() );
}

bool on_file( const string& r )
{
	static vector<char> temp(20);
	DWORD handle = BASS_StreamCreateFile( FALSE, r.c_str(), 0,0,BASS_STREAM_DECODE );

	if( !handle )
	{
		cout<<"ERROR: [stream] '"<<ato( r.c_str() )<<"'"<<endl;
		return true;
	}

	__int64 s,e,f;
	QueryPerformanceFrequency( (LARGE_INTEGER*)&f );
	QueryPerformanceCounter( (LARGE_INTEGER*)&s );
	const char* tags = TAGS_Read( handle, g_fmt );
	QueryPerformanceCounter( (LARGE_INTEGER*)&e );
	
	if( *tags  )
	{
		g_time += float(e-s)/f;
		cout<<"OK: ["<< ato( tags )<<"] '"<<ato(r.c_str())<<"'"<< endl;
	}else
		cout<<"FAIL: ["<<TAGS_GetLastErrorDesc()<<"] '"<<r<<"'"<<endl;
	BASS_StreamFree( handle );
	return true;
}


int main( int argc, char* argv[] )
{
	string types[] = 
	{
		".mp3",
		".mp2",
		".mp1",
		".ogg",
		".flac",
		".flc",
		".ape",
		".ofr",
		".mpa",
		".wma"
	};
	const int sz = sizeof(types) / sizeof(*types);

	BASS_Init( 0, 0, 0,0,0);
	BASS_PluginLoad( "basswma.dll" ) || cerr<<"no WMA support\n";
	BASS_PluginLoad( "bass_ape.dll" ) || cerr<<"no APE support\n";
	BASS_PluginLoad( "bassflac.dll" ) || cerr<<"no FLAC support\n";
	BASS_PluginLoad( "bass_ofr.dll" ) || cerr<<"no OFR support\n";

	int n = do_find_files( argc < 2 ? "" : argv[1], types, types + sz, on_file );
	cerr<<n<<" files, "<<g_time/n<<" sec./file on avg."<<endl;
	BASS_Free();

	return 0;
}
