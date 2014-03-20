/*
	ASIO version of BASS full-duplex test
	Copyright (c) 2002-2008 Un4seen Developments Ltd.
*/

#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include <math.h>
#include "bass.h"
#include "bassasio.h"

HWND win=NULL;

#define MESS(id,m,w,l) SendDlgItemMessage(win,id,m,(WPARAM)w,(LPARAM)l)

HSTREAM fxchan;	// FX stream
HFX fx[4]={0};	// FX handles
int input=0;	// current input source

void Error(const char *es)
{
	char mes[200];
	sprintf(mes,"%s\n(error code: %d/%d)",es,BASS_ErrorGetCode(),BASS_ASIO_ErrorGetCode());
	MessageBox(win,mes,"Error",0);
}

DWORD CALLBACK AsioProc(BOOL input, DWORD channel, void *buffer, DWORD length, void *user)
{
	static float buf[100000]; // input buffer - 100000 should be enough :)
	if (input) {
		memcpy(buf,buffer,length);
	} else {
		memcpy(buffer,buf,length);
		BASS_ChannelGetData(fxchan,buffer,length); // apply FX
	}
	return length;
}


static BOOL Initialize()
{
	// not playing anything via BASS, so don't need an update thread
	BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD,0);
	// init BASS (for the FX)
	BASS_Init(0,44100,0,0,NULL);

	// init ASIO - first device
	if (!BASS_ASIO_Init(0)) {
		BASS_Free();
		Error("Can't initialize ASIO");
		return FALSE;
	}

	{ // get list of inputs (assuming channels are all ordered in left/right pairs)
		int c;
		BASS_ASIO_CHANNELINFO i,i2;
		for (c=0;BASS_ASIO_ChannelGetInfo(TRUE,c,&i);c+=2) {
			char name[200];
			if (!BASS_ASIO_ChannelGetInfo(TRUE,c+1,&i2)) break; // no "right" channel
			sprintf(name,"%s + %s",i.name,i2.name);
			MESS(10,CB_ADDSTRING,0,name);
			BASS_ASIO_ChannelJoin(TRUE,c+1,c); // join the pair of channels
		}
		MESS(10,CB_SETCURSEL,input,0);
	}

	// create a dummy stream to apply FX
	fxchan=BASS_StreamCreate(BASS_ASIO_GetRate(),2,BASS_SAMPLE_FLOAT|BASS_STREAM_DECODE,STREAMPROC_DUMMY,0);

	// enable first inputs
	BASS_ASIO_ChannelEnable(TRUE,input,&AsioProc,0);
	// enable first outputs
	BASS_ASIO_ChannelEnable(FALSE,0,&AsioProc,0);
	BASS_ASIO_ChannelJoin(FALSE,1,0);
	// set input and output to floating-point
	BASS_ASIO_ChannelSetFormat(TRUE,input,BASS_ASIO_FORMAT_FLOAT);
	BASS_ASIO_ChannelSetFormat(FALSE,0,BASS_ASIO_FORMAT_FLOAT);
	// start with output volume at 0 (in case of nasty feedback)
	BASS_ASIO_ChannelSetVolume(FALSE,0,0);
	BASS_ASIO_ChannelSetVolume(FALSE,1,0);
	// start it (using default buffer size)
	if (!BASS_ASIO_Start(0)) {
		BASS_ASIO_Free();
		BASS_Free();
		Error("Can't initialize recording device");
		return FALSE;
	}

	{ // display total (input+output) latency
		char buf[20];
		sprintf(buf,"%.1fms",(BASS_ASIO_GetLatency(FALSE)+BASS_ASIO_GetLatency(TRUE))*1000/BASS_ASIO_GetRate());
		MESS(15,WM_SETTEXT,0,buf);
	}

	return TRUE;
}

BOOL CALLBACK dialogproc(HWND h,UINT m,WPARAM w,LPARAM l)
{
	switch (m) {
		case WM_COMMAND:
			switch (LOWORD(w)) {
				case IDCANCEL:
					DestroyWindow(h);
					return 1;
				case 10:
					if (HIWORD(w)==CBN_SELCHANGE) { // input selection changed
						int i;
						BASS_ASIO_Stop(); // stop ASIO processing
						BASS_ASIO_ChannelEnable(TRUE,input,NULL,0); // disable old inputs
						input=MESS(10,CB_GETCURSEL,0,0)*2; // get the selection
						BASS_ASIO_ChannelEnable(TRUE,input,&AsioProc,0); // enable new inputs
						BASS_ASIO_ChannelSetFormat(TRUE,input,BASS_ASIO_FORMAT_FLOAT);
						BASS_ASIO_Start(0); // resume ASIO processing
					}
					return 1;
				case 20: // toggle chorus
					if (fx[0]) {
						BASS_ChannelRemoveFX(fxchan,fx[0]);
						fx[0]=0;
					} else
						fx[0]=BASS_ChannelSetFX(fxchan,BASS_FX_DX8_CHORUS,0);
					return 1;
				case 21: // toggle gargle
					if (fx[1]) {
						BASS_ChannelRemoveFX(fxchan,fx[1]);
						fx[1]=0;
					} else
						fx[1]=BASS_ChannelSetFX(fxchan,BASS_FX_DX8_GARGLE,0);
					return 1;
				case 22: // toggle reverb
					if (fx[2]) {
						BASS_ChannelRemoveFX(fxchan,fx[2]);
						fx[2]=0;
					} else
						fx[2]=BASS_ChannelSetFX(fxchan,BASS_FX_DX8_REVERB,0);
					return 1;
				case 23: // toggle flanger
					if (fx[3]) {
						BASS_ChannelRemoveFX(fxchan,fx[3]);
						fx[3]=0;
					} else
						fx[3]=BASS_ChannelSetFX(fxchan,BASS_FX_DX8_FLANGER,0);
					return 1;
			}
			break;
		case WM_HSCROLL:
			if (l) {
				float level=SendMessage((HWND)l,TBM_GETPOS,0,0)/100.0f; // get level
				BASS_ASIO_ChannelSetVolume(FALSE,0,level); // set left output level
				BASS_ASIO_ChannelSetVolume(FALSE,1,level); // set right output level
			}
			return 1;
		case WM_INITDIALOG:
			win=h;
			MESS(11,TBM_SETRANGE,FALSE,MAKELONG(0,100)); // initialize input level slider
			MessageBox(win,
				"Do not set the input to 'WAVE' / 'What you hear' (etc...) with\n"
				"the level set high, as that is likely to result in nasty feedback.\n",
				"Feedback warning",MB_ICONWARNING);
			if (!Initialize()) {
				DestroyWindow(win);
				return 1;
			}
			return 1;

		case WM_DESTROY:
			// release it all
			BASS_ASIO_Free();
			BASS_Free();
			return 1;
	}
	return 0;
}

int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,LPSTR lpCmdLine, int nCmdShow)
{
	// check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
		MessageBox(0,"An incorrect version of BASS.DLL was loaded",0,MB_ICONERROR);
		return 0;
	}

	{ // enable trackbar support (for the level control)
		INITCOMMONCONTROLSEX cc={sizeof(cc),ICC_BAR_CLASSES};
		InitCommonControlsEx(&cc);
	}

	DialogBox(hInstance,(char*)1000,0,&dialogproc);

	return 0;
}
