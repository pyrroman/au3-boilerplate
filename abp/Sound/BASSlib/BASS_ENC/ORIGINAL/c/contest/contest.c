/*
	BASSenc console transcoding example
	Copyright (c) 2003-2008 Un4seen Developments Ltd.
*/

#include <stdlib.h>
#include <stdio.h>
#include "bass.h"
#include "bassenc.h"

#ifdef _WIN32 // Windows
#include <conio.h>
#else // OSX
#include <sys/types.h>
#include <sys/time.h>
#include <termios.h>
#include <string.h>
#include <unistd.h>

int _kbhit()
{
	int r;
	fd_set rfds;
	struct timeval tv={0};
	struct termios term,oterm;
	tcgetattr(0,&oterm);
	memcpy(&term,&oterm,sizeof(term));
	cfmakeraw(&term);
	tcsetattr(0,TCSANOW,&term);
	FD_ZERO(&rfds);
	FD_SET(0,&rfds);
	r=select(1,&rfds,NULL,NULL,&tv);
	tcsetattr(0,TCSANOW,&oterm);
	return r;
}
#endif

// display error messages
void Error(const char *text) 
{
	printf("Error(%d): %s\n",BASS_ErrorGetCode(),text);
	BASS_Free();
	exit(0);
}

// encoder command-lines
#define ENCODERS 4
const char *commands[ENCODERS]={
	"bass.wav", // no encoder (WAV)
	"oggenc -o bass.ogg -", // oggenc (OGG)
	"lame --alt-preset standard - bass.mp3", // lame (MP3)
	"flac -f -o bass.flac -" // flac (FLAC)
};

void main(int argc, char **argv)
{
	DWORD chan;
	QWORD pos;
	DWORD encoder=0;

	printf("BASSenc example : MOD/WAV/OGG/MPx -> WAV/OGG/MP3/FLAC\n"
			"-----------------------------------------------------\n");

	if (argc==3) encoder=atoi(argv[2]);
	if ((argc!=2 && argc!=3) || encoder>=ENCODERS) {
		printf("\tusage: contest <file> [encoder]\n"
			"\t\tencoder: 0=wav (default), 1=oggenc, 2=lame, 3=flac\n");
		return;
	}

	// not playing anything, so don't need an update thread
	BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD,0);

	// setup output - "no sound" device, 44100hz, stereo, 16 bits
	if (!BASS_Init(0,44100,0,0,NULL))
		Error("Can't initialize device");

	// try streaming the file/url
	if ((chan=BASS_StreamCreateFile(FALSE,argv[1],0,0,BASS_STREAM_DECODE))
		|| (chan=BASS_StreamCreateURL(argv[1],0,BASS_STREAM_DECODE|BASS_STREAM_BLOCK,NULL,0))) {
		pos=BASS_ChannelGetLength(chan,BASS_POS_BYTE);
		if (BASS_StreamGetFilePosition(chan,BASS_FILEPOS_DOWNLOAD)!=-1) {
			// streaming from the internet
			if (pos!=-1)
#ifdef _WIN32
				printf("streaming internet file [%I64u bytes]",pos);
#else
				printf("streaming internet file [%llu bytes]",pos);
#endif
			else
				printf("streaming internet file");
		} else
#ifdef _WIN32
			printf("streaming file [%I64u bytes]",pos);
#else
			printf("streaming file [%llu bytes]",pos);
#endif
	} else {
		// try loading the MOD (with sensitive ramping, and calculate the duration)
		if (!(chan=BASS_MusicLoad(FALSE,argv[1],0,0,BASS_MUSIC_DECODE|BASS_MUSIC_RAMPS|BASS_MUSIC_PRESCAN,0)))
			Error("Can't play the file"); // not a MOD either
		printf("playing MOD music \"%s\" [%u orders]",BASS_ChannelGetTags(chan,BASS_TAG_MUSIC_NAME),BASS_ChannelGetLength(chan,BASS_POS_MUSIC_ORDER));
		pos=BASS_ChannelGetLength(chan,BASS_POS_BYTE);
	}

	// display the time length
	if (pos!=-1) {
		DWORD p=(DWORD)BASS_ChannelBytes2Seconds(chan,pos);
		printf(" %u:%02u\n",p/60,p%60);
	} else // no time length available
		printf("\n");

	// start the encoder
	if (!BASS_Encode_Start(chan,commands[encoder],encoder?0:BASS_ENCODE_PCM,NULL,0))
		Error("Can't start the encoder");

	while (!_kbhit() && BASS_ChannelIsActive(chan)) {
		char temp[20000];
		BASS_ChannelGetData(chan,temp,20000);
		if (!BASS_Encode_IsActive(chan)) {
			printf("Error: The encoder died!\n");
			break;
		}
		pos=BASS_ChannelGetPosition(chan,BASS_POS_BYTE);
#ifdef _WIN32
		printf("pos %09I64u\r",pos);
#else
		printf("pos %llu\r",pos);
#endif
		fflush(stdout);
	}

	BASS_Encode_Stop(chan);
	BASS_Free();
}
