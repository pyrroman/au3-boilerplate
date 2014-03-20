/*
	ASIO version of the BASS simple console player
	Copyright (c) 1999-2008 Un4seen Developments Ltd.
*/

#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include "bassasio.h"
#include "bass.h"

// display error messages
void Error(const char *text) 
{
	printf("Error(%d/%d): %s\n",BASS_ErrorGetCode(),BASS_ASIO_ErrorGetCode(),text);
	BASS_ASIO_Free();
	BASS_Free();
	exit(0);
}

// ASIO function
DWORD CALLBACK AsioProc(BOOL input, DWORD channel, void *buffer, DWORD length, void *user)
{
	DWORD c=BASS_ChannelGetData((DWORD)user,buffer,length);
	if (c==-1) c=0; // an error, no data
	return c;
}

void main(int argc, char **argv)
{
	DWORD chan,time;
	BOOL ismod;
	QWORD pos;
	int a;
	BASS_CHANNELINFO i;

	printf("Simple console mode BASS+ASIO example : MOD/MPx/OGG/WAV player\n"
			"--------------------------------------------------------------\n");

	// check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
		printf("An incorrect version of BASS was loaded");
		return;
	}

	if (argc!=2) {
		printf("\tusage: contest <file>\n");
		return;
	}

	// not playing anything via BASS, so don't need an update thread
	BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD,0);
	// setup BASS - "no sound" device
	BASS_Init(0,48000,0,0,NULL);

	// try streaming the file/url
	if ((chan=BASS_StreamCreateFile(FALSE,argv[1],0,0,BASS_SAMPLE_LOOP|BASS_STREAM_DECODE|BASS_SAMPLE_FLOAT))
		|| (chan=BASS_StreamCreateURL(argv[1],0,BASS_SAMPLE_LOOP|BASS_STREAM_DECODE|BASS_SAMPLE_FLOAT,0,0))) {
		pos=BASS_ChannelGetLength(chan,BASS_POS_BYTE);
		if (BASS_StreamGetFilePosition(chan,BASS_FILEPOS_DOWNLOAD)!=-1) {
			// streaming from the internet
			if (pos!=-1)
				printf("streaming internet file [%I64u bytes]",pos);
			else
				printf("streaming internet file");
		} else
			printf("streaming file [%I64u bytes]",pos);
		ismod=FALSE;
	} else {
		// try loading the MOD (with looping, sensitive ramping, and calculate the duration)
		if (!(chan=BASS_MusicLoad(FALSE,argv[1],0,0,BASS_SAMPLE_LOOP|BASS_STREAM_DECODE|BASS_SAMPLE_FLOAT|BASS_MUSIC_RAMPS|BASS_MUSIC_PRESCAN,0)))
			// not a MOD either
			Error("Can't play the file");
		{ // count channels
			float dummy;
			for (a=0;BASS_ChannelGetAttribute(chan,BASS_ATTRIB_MUSIC_VOL_CHAN+a,&dummy);a++);
		}
		printf("playing MOD music \"%s\" [%u chans, %u orders]",
			BASS_ChannelGetTags(chan,BASS_TAG_MUSIC_NAME),a,BASS_ChannelGetLength(chan,BASS_POS_MUSIC_ORDER));
		pos=BASS_ChannelGetLength(chan,BASS_POS_BYTE);
		ismod=TRUE;
	}

	// display the time length
	if (pos!=-1) {
		time=(DWORD)BASS_ChannelBytes2Seconds(chan,pos);
		printf(" %u:%02u\n",time/60,time%60);
	} else // no time length available
		printf("\n");

	// setup ASIO stuff
	if (!BASS_ASIO_Init(0))
		Error("Can't initialize ASIO device");
	BASS_ChannelGetInfo(chan,&i);
	BASS_ASIO_ChannelEnable(0,0,&AsioProc,(void*)chan); // enable 1st output channel...
	for (a=1;a<i.chans;a++)
		BASS_ASIO_ChannelJoin(0,a,0); // and join the next channels to it
	BASS_ASIO_ChannelSetFormat(0,0,BASS_ASIO_FORMAT_FLOAT); // set the source format (float)
	BASS_ASIO_ChannelSetRate(0,0,i.freq); // set the source rate
	BASS_ASIO_SetRate(i.freq); // try to set the device rate too (saves resampling)
	if (!BASS_ASIO_Start(0)) // start output using default buffer/latency
		Error("Can't start ASIO output");

	while (!_kbhit() && BASS_ChannelIsActive(chan)) {
		// display some stuff and wait a bit
		pos=BASS_ChannelGetPosition(chan,BASS_POS_BYTE);
		time=BASS_ChannelBytes2Seconds(chan,pos);
		printf("pos %09I64u",pos);
		if (ismod) {
			pos=BASS_ChannelGetPosition(chan,BASS_POS_MUSIC_ORDER);
			printf(" (%03u:%03u)",LOWORD(pos),HIWORD(pos));
		}
		printf(" - %u:%02u - L ",time/60,time%60);
		{
			DWORD level=BASS_ASIO_ChannelGetLevel(0,0)*32768; // left channel level
			for (a=27204;a>200;a=a*2/3) putchar(level>=a?'*':'-');
			putchar(' ');
			if (BASS_ASIO_ChannelIsActive(0,1))
				level=BASS_ASIO_ChannelGetLevel(0,1)*32768; // right channel level
			for (a=210;a<32768;a=a*3/2) putchar(level>=a?'*':'-');
		}
		printf(" R - cpu %.2f%%  \r",BASS_ASIO_GetCPU());
		fflush(stdout);
		Sleep(50);
	}
	printf("                                                                             \r");

	{ // wind the frequency and volume down...
		float freq=BASS_ASIO_ChannelGetRate(0,0),f=1;
		for (;f>0;f-=0.04) {
			BASS_ASIO_ChannelSetRate(0,0,freq*f); // set sample rate
			for (a=0;a<i.chans;a++) // set volume for all channels...
				BASS_ASIO_ChannelSetVolume(0,a,f);
			Sleep(20);
		}
	}

	BASS_ASIO_Free();
	BASS_Free();
}
