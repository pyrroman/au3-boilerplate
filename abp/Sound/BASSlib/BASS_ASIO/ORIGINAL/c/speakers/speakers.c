/*
	ASIO version of BASS multi-speaker example
	Copyright (c) 2003-2008 Un4seen Developments Ltd.
*/

#include <windows.h>
#include <stdio.h>

#include "bassasio.h"
#include "bass.h"

HWND win=NULL;

HSTREAM chan[4];

// display error messages
void Error(const char *es)
{
	char mes[200];
	sprintf(mes,"%s\n(error code: %d/%d)",es,BASS_ErrorGetCode(),BASS_ASIO_ErrorGetCode());
	MessageBox(win,mes,"Error",0);
}

// ASIO function
DWORD CALLBACK AsioProc(BOOL input, DWORD channel, void *buffer, DWORD length, void *user)
{
	DWORD c=BASS_ChannelGetData(chan[(int)user],buffer,length); // user = output #
	if (c==-1) c=0; // an error, no data
	return c;
}

#define MESS(id,m,w,l) SendDlgItemMessage(win,id,m,(WPARAM)(w),(LPARAM)(l))

BOOL CALLBACK dialogproc(HWND h,UINT m,WPARAM w,LPARAM l)
{
	static OPENFILENAME ofn;

	switch (m) {
		case WM_COMMAND:
			switch (LOWORD(w)) {
				case IDCANCEL:
					DestroyWindow(h);
					return 1;
				case 10: // open a file to play on #1
				case 11: // open a file to play on #2
				case 12: // open a file to play on #3
				case 13: // open a file to play on #4
					{
						int output=LOWORD(w)-10;
						char file[MAX_PATH]="";
						ofn.lpstrFile=file;
						if (GetOpenFileName(&ofn)) {
							BASS_ASIO_ChannelPause(0,output*2); // pause output channel
							BASS_StreamFree(chan[output]); // free old stream before opening new
							if (!(chan[output]=BASS_StreamCreateFile(FALSE,file,0,0,BASS_STREAM_DECODE|BASS_SAMPLE_FLOAT|BASS_SAMPLE_LOOP))) {
								MESS(10+output,WM_SETTEXT,0,"click here to open a file...");
								Error("Can't play the file");
							} else {
								BASS_CHANNELINFO i;
								BASS_ChannelGetInfo(chan[output],&i);
								BASS_ASIO_ChannelSetRate(0,output*2,i.freq); // set the output channel's sample rate
								BASS_ASIO_ChannelReset(0,output*2,BASS_ASIO_RESET_PAUSE); // unpause the channel
								MESS(10+output,WM_SETTEXT,0,file);
							}
						}
					}
					return 1;
				case 20: // swap #1 & #2
				case 21: // swap #2 & #3
				case 22: // swap #3 & #4
					{
						int output=LOWORD(w)-20;
						// pause the channels while swapping
						BASS_ASIO_ChannelPause(0,output*2);
						BASS_ASIO_ChannelPause(0,(output+1)*2);
						{ // swap handles
							HSTREAM temp=chan[output];
							chan[output]=chan[output+1];
							chan[output+1]=temp;
						}
						{ // swap sample rates
							double temp=BASS_ASIO_ChannelGetRate(0,output*2);
							BASS_ASIO_ChannelSetRate(0,output*2,BASS_ASIO_ChannelGetRate(0,(output+1)*2));
							BASS_ASIO_ChannelSetRate(0,(output+1)*2,temp);
						}
						// unpause channels
						if (BASS_ChannelIsActive(chan[output]))
							BASS_ASIO_ChannelReset(0,output*2,BASS_ASIO_RESET_PAUSE);
						if (BASS_ChannelIsActive(chan[output+1]))
							BASS_ASIO_ChannelReset(0,(output+1)*2,BASS_ASIO_RESET_PAUSE);
						{ // swap text
							char temp1[MAX_PATH],temp2[MAX_PATH];
							MESS(10+output,WM_GETTEXT,MAX_PATH,temp1);
							MESS(10+output+1,WM_GETTEXT,MAX_PATH,temp2);
							MESS(10+output,WM_SETTEXT,0,temp2);
							MESS(10+output+1,WM_SETTEXT,0,temp1);
						}
					}
					return 1;
			}
			break;

		case WM_INITDIALOG:
			win=h;
			memset(&ofn,0,sizeof(ofn));
			ofn.lStructSize=sizeof(ofn);
			ofn.hwndOwner=h;
			ofn.nMaxFile=MAX_PATH;
			ofn.Flags=OFN_HIDEREADONLY|OFN_EXPLORER;
			ofn.lpstrFilter="Streamable files\0*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aif\0All files\0*.*\0\0";
			// not playing anything via BASS, so don't need an update thread
			BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD,0);
			// initialize BASS - "no sound" device
			BASS_Init(0,48000,0,0,NULL);
			// initialize ASIO - default device
			if (!BASS_ASIO_Init(0)) {
				Error("Can't initialize device");
				DestroyWindow(win);
				break;
			}
			{ // check how many output pairs the device supports (up to 4)
				int a;
				BASS_ASIO_INFO i;
				BASS_ASIO_GetInfo(&i);
				for (a=0;a<4;a++) {
					BASS_ASIO_CHANNELINFO i,i2;
					if (BASS_ASIO_ChannelGetInfo(0,a*2,&i) && BASS_ASIO_ChannelGetInfo(0,a*2+1,&i2)) {
						char name[200];
						sprintf(name,"%s + %s",i.name,i2.name);
						MESS(30+a,WM_SETTEXT,0,name); // display channel names
						BASS_ASIO_ChannelEnable(0,a*2,&AsioProc,(void*)a); // enable the 1st channel...
						BASS_ASIO_ChannelJoin(0,a*2+1,a*2); // ...and join the next
						BASS_ASIO_ChannelSetFormat(0,a*2,BASS_ASIO_FORMAT_FLOAT); // set the source format (float)
						BASS_ASIO_ChannelPause(0,a*2); // not playing anything immediately, so pause the channel
					} else { // no more channels
						EnableWindow(GetDlgItem(h,10+a),FALSE);
						if (a) EnableWindow(GetDlgItem(h,19+a),FALSE);
					}
				}
			}
			// start output using default buffer/latency
			if (!BASS_ASIO_Start(0)) {
				Error("Can't start ASIO output");
				DestroyWindow(win);
			}
			return 1;

		case WM_DESTROY:
			BASS_ASIO_Free();
			BASS_Free();
			break;
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

	/* main dialog */
	DialogBox(hInstance,(char*)1000,0,&dialogproc);

	return 0;
}
