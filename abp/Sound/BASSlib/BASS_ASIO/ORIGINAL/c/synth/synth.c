/*
	ASIO version of BASS simple synth
	Copyright (c) 2001-2008 Un4seen Developments Ltd.
*/

#include <stdio.h>
#include <conio.h>
#include <math.h>
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


#define PI 3.14159265358979323846
#define TABLESIZE 2048
int sinetable[TABLESIZE];	// sine table
#define KEYS 20
const WORD keys[KEYS]={
	'Q','2','W','3','E','R','5','T','6','Y','7','U',
	'I','9','O','0','P',219,187,221
};
#define MAXVOL	4000	// higher value = longer fadeout
int vol[KEYS]={0},pos[KEYS];	// keys' volume & pos
float samrate;


// ASIO function
DWORD CALLBACK AsioProc(BOOL input, DWORD channel, void *buffer, DWORD length, void *user)
{
	DWORD c=BASS_ChannelGetData((DWORD)user,buffer,length);
	if (c==-1) c=0; // an error, no data
	return c;
}

// stream writer
DWORD CALLBACK WriteStream(HSTREAM handle, short *buffer, DWORD length, void *user)
{
	int n,s;
	DWORD c;
	float f;
	memset(buffer,0,length);
	for (n=0;n<KEYS;n++) {
		if (!vol[n]) continue;
		f=pow(2.0,(n+3)/12.0)*TABLESIZE*440.0/samrate;
		for (c=0;c<length/4 && vol[n];c++) {
			s=sinetable[(int)((pos[n]++)*f)&(TABLESIZE-1)]*vol[n]/MAXVOL;
			s+=(int)buffer[c*2];
			if (s>32767) s=32767;
			else if (s<-32768) s=-32768;
			buffer[c*2+1]=buffer[c*2]=s; // left and right channels are the same
			if (vol[n]<MAXVOL) vol[n]--;
		}
	}
	return length;
}

void main(int argc, char **argv)
{
	BASS_ASIO_INFO info;
	HSTREAM str;
	const char *fxname[9]={"CHORUS","COMPRESSOR","DISTORTION","ECHO",
		"FLANGER","GARGLE","I3DL2REVERB","PARAMEQ","REVERB"};
	HFX fx[9]={0}; // effect handles
	INPUT_RECORD keyin;
	DWORD r,buflen;

	printf("BASS+ASIO Simple Sinewave Synth\n"
			"-------------------------------\n");

	// check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
		printf("An incorrect version of BASS was loaded");
		return;
	}

	// not playing anything via BASS, so don't need an update thread
	BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD,0);
	// setup BASS - "no sound" device
	BASS_Init(0,48000,0,0,NULL);

	// build sine table
	for (r=0;r<TABLESIZE;r++)
		sinetable[r]=(int)(sin(2.0*PI*(double)r/TABLESIZE)*7000.0);

	// setup ASIO - first device
	if (!BASS_ASIO_Init(0))
		Error("Can't initialize ASIO device");

	// start device info for buffer size range, begin with default
	BASS_ASIO_GetInfo(&info);
	buflen=info.bufpref;

	samrate=BASS_ASIO_GetRate();

	// create a stream, stereo so that effects sound nice
	str=BASS_StreamCreate(samrate,2,BASS_STREAM_DECODE,(STREAMPROC*)WriteStream,0);

	BASS_ASIO_ChannelEnable(0,0,&AsioProc,(void*)str); // enable 1st output channel...
	BASS_ASIO_ChannelJoin(0,1,0); // and join the next channel to it (stereo)
	BASS_ASIO_ChannelSetFormat(0,0,BASS_ASIO_FORMAT_16BIT); // set the source format (16-bit)

	// start the ASIO device
	if (!BASS_ASIO_Start(buflen))
		Error("Can't start ASIO device");

	printf("press these keys to play:\n\n"
			"  2 3  5 6 7  9 0  =\n"
			" Q W ER T Y UI O P[ ]\n\n"
			"press -/+ to de/increase the buffer\n"
			"press spacebar to quit\n\n");
	printf("press F1-F9 to toggle effects\n\n");

	printf("buffer = %d (%.1fms latency)\r",buflen,1000*BASS_ASIO_GetLatency(0)/samrate);

	while (ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE),&keyin,1,&r)) {
		int key;
		if (keyin.EventType!=KEY_EVENT) continue;
		if (keyin.Event.KeyEvent.wVirtualKeyCode==VK_SPACE) break;
		if (keyin.Event.KeyEvent.bKeyDown) {
			if (keyin.Event.KeyEvent.wVirtualKeyCode==VK_SUBTRACT
				|| keyin.Event.KeyEvent.wVirtualKeyCode==VK_ADD) {
				// restart the device with smaller/larger buffer
				DWORD newlen;
				BASS_ASIO_Stop();
				if (keyin.Event.KeyEvent.wVirtualKeyCode==VK_SUBTRACT) {
					if (info.bufgran==-1)
						buflen>>=1; // halve the buffer
					else
						newlen=buflen-(DWORD)samrate/1000; // reduce buffer by 1ms
					if (newlen<info.bufmin) newlen=info.bufmin;
				} else {
					if (info.bufgran==-1)
						buflen<<=1; // double the buffer
					else
						newlen=buflen+(DWORD)samrate/1000; // increase buffer by 1ms
					if (newlen>info.bufmax) newlen=info.bufmax;
				}
				if (BASS_ASIO_Start(newlen)) { // successfully changed buffer size
					buflen=newlen;
					printf("buffer = %d (%.1fms latency)\t\t\r",buflen,1000*BASS_ASIO_GetLatency(0)/samrate);
				} else // failed... 
					BASS_ASIO_Start(buflen); // reuse the previous buffer size
			}
			if (keyin.Event.KeyEvent.wVirtualKeyCode>=VK_F1
				&& keyin.Event.KeyEvent.wVirtualKeyCode<=VK_F9) {
				r=keyin.Event.KeyEvent.wVirtualKeyCode-VK_F1;
				if (fx[r]) {
					BASS_ChannelRemoveFX(str,fx[r]);
					fx[r]=0;
					printf("effect %s = OFF\t\t\r",fxname[r]);
				} else {
					// set the effect, not bothering with parameters (use defaults)
					if (fx[r]=BASS_ChannelSetFX(str,BASS_FX_DX8_CHORUS+r,0))
						printf("effect %s = ON\t\t\r",fxname[r]);
				}
			}
		}
		for (key=0;key<KEYS;key++)
			if (keyin.Event.KeyEvent.wVirtualKeyCode==keys[key]) break;
		if (key==KEYS) continue;
		if (keyin.Event.KeyEvent.bKeyDown && vol[key]!=MAXVOL) {
			pos[key]=0;
			vol[key]=MAXVOL; // start key
		} else if (!keyin.Event.KeyEvent.bKeyDown && vol[key])
			vol[key]--; // trigger key fadeout
	}

	BASS_ASIO_Free();
	BASS_Free();
}
