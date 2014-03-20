/*
	BASSenc cast example
	Copyright (c) 2006-2009 Un4seen Developments Ltd.
*/

#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include "bass.h"
#include "bassenc.h"

HWND win;

HRECORD rchan=0;	// recording/encoding channel
HENCODE encoder;

DWORD bitrates[14]={32,40,48,56,64,80,96,112,128,160,192,224,256,320}; // available bitrates

// display error messages
void Error(const char *es)
{
	char mes[200];
	sprintf(mes,"%s\n(error code: %d)",es,BASS_ErrorGetCode());
	MessageBox(win,mes,0,0);
}

// messaging macros
#define MESS(id,m,w,l) SendDlgItemMessage(win,id,m,(WPARAM)(w),(LPARAM)(l))
#define DLGITEM(id) GetDlgItem(win,id)

BOOL CALLBACK RecordingCallback(HRECORD handle, const void *buffer, DWORD length, void *user)
{
	return BASS_Encode_IsActive(handle); // continue recording if encoder is alive
}

void Start();
void Stop();

// encoder death notification
void CALLBACK EncoderNotify(HENCODE handle, DWORD status, void *user)
{
	if (status<0x10000) { // encoder/connection died
		Stop(); // free the recording and encoder
		if (MESS(51,BM_GETCHECK,0,0)) { // auto-reconnect...
			EnableWindow(DLGITEM(50),FALSE);
			Sleep(1000); // wait a sec
			Start();
			EnableWindow(DLGITEM(50),TRUE);
		} else
			MessageBox(win,status==BASS_ENCODE_NOTIFY_CAST?"The server connection died!":"The encoder died!",0,0);
	}
}

void Start()
{
	char com[100],server[100],pass[100],name[100],url[100],genre[100],desc[100],*content;
	DWORD bitrate,pub;
	// start recording @ 44100hz 16-bit stereo (paused to setup encoder first)
	if (!(rchan=BASS_RecordStart(44100,2,BASS_RECORD_PAUSE,&RecordingCallback,0))) {
		Error("Couldn't start recording");
		return;
	}
	bitrate=bitrates[MESS(35,CB_GETCURSEL,0,0)]; // get bitrate
	// setup encoder command-line (raw PCM data to avoid length limit)
	if (MESS(30,BM_GETCHECK,0,0)) { // MP3
		sprintf(com,"lame -r -s 44100 -b %d -",bitrate); // add "-x" for LAME versions pre-3.98
		content=BASS_ENCODE_TYPE_MP3;
	} else { // OGG
		sprintf(com,"oggenc -r -R 44100 -b %d -m %d -",bitrate,16);
		content=BASS_ENCODE_TYPE_OGG;
	}
	encoder=BASS_Encode_Start(rchan,com,BASS_ENCODE_NOHEAD|BASS_ENCODE_AUTOFREE,NULL,0); // start the encoder
	if (!encoder) {
		Error("Couldn't start encoding...\n"
			"Make sure OGGENC.EXE (if encoding to OGG) is in the same\n"
			"direcory as this RECTEST, or LAME.EXE (if encoding to MP3).");
		BASS_ChannelStop(rchan);
		rchan=0;
		return;
	}
	// setup cast
	GetWindowText(DLGITEM(10),server,sizeof(server));
	GetWindowText(DLGITEM(11),pass,sizeof(pass));
	GetWindowText(DLGITEM(15),name,sizeof(name));
	GetWindowText(DLGITEM(16),url,sizeof(url));
	GetWindowText(DLGITEM(17),genre,sizeof(genre));
	GetWindowText(DLGITEM(18),desc,sizeof(desc));
	pub=MESS(12,BM_GETCHECK,0,0);
	if (!BASS_Encode_CastInit(encoder,server,pass,content,name,url,genre,desc,NULL,bitrate,pub)) {
		Error("Couldn't setup connection with server");
		BASS_ChannelStop(rchan);
		rchan=0;
		return;
	}
	BASS_ChannelPlay(rchan,FALSE); // resume recording
	MESS(50,WM_SETTEXT,0,"Stop");
	EnableWindow(DLGITEM(10),FALSE);
	EnableWindow(DLGITEM(11),FALSE);
	EnableWindow(DLGITEM(12),FALSE);
	EnableWindow(DLGITEM(15),FALSE);
	EnableWindow(DLGITEM(16),FALSE);
	EnableWindow(DLGITEM(17),FALSE);
	EnableWindow(DLGITEM(18),FALSE);
	EnableWindow(DLGITEM(30),FALSE);
	EnableWindow(DLGITEM(31),FALSE);
	EnableWindow(DLGITEM(35),FALSE);
	EnableWindow(DLGITEM(60),TRUE);
	BASS_Encode_SetNotify(encoder,EncoderNotify,0); // notify of dead encoder/connection 
}

void Stop()
{
	// stop recording & encoding
	BASS_ChannelStop(rchan);
	rchan=0;
	MESS(50,WM_SETTEXT,0,"Start");
	EnableWindow(DLGITEM(10),TRUE);
	EnableWindow(DLGITEM(11),TRUE);
	EnableWindow(DLGITEM(12),TRUE);
	EnableWindow(DLGITEM(15),TRUE);
	EnableWindow(DLGITEM(16),TRUE);
	EnableWindow(DLGITEM(17),TRUE);
	EnableWindow(DLGITEM(18),TRUE);
	EnableWindow(DLGITEM(30),TRUE);
	EnableWindow(DLGITEM(31),TRUE);
	EnableWindow(DLGITEM(35),TRUE);
	EnableWindow(DLGITEM(60),FALSE);
	SetWindowText(win,"Cast test");
}

BOOL CALLBACK dialogproc(HWND h,UINT m,WPARAM w,LPARAM l)
{
	switch (m) {
		case WM_TIMER:
			{ // draw the level bar
				static DWORD level=0;
				HWND w=DLGITEM(55);
				HDC dc=GetWindowDC(w);
				RECT r;
				level=level>1500?level-1500:0;
				if (rchan) {
					DWORD l=BASS_ChannelGetLevel(rchan); // get current level
					if (LOWORD(l)>level) level=LOWORD(l);
					if (HIWORD(l)>level) level=HIWORD(l);
				}
				GetClientRect(w,&r);
				InflateRect(&r,-1,-1);
				r.top=r.bottom*(32768-level)/32768;
				FillRect(dc,&r,GetStockObject(WHITE_BRUSH));
				r.bottom=r.top;
				r.top=1;
				FillRect(dc,&r,GetStockObject(LTGRAY_BRUSH));
				ReleaseDC(w,dc);
				if (rchan) { // check number of listeners
					static int updatelisten=0;
					if (!(++updatelisten%100)) { // only checking once every 5 seconds
						char text[50];
						const char *stats;
						int listeners=0;
						if (stats=BASS_Encode_CastGetStats(encoder,BASS_ENCODE_STATS_ICE,NULL)) {
							char *t=strstr(stats,"<Listeners>"); // Icecast listener count
							if (t) listeners=atoi(t+11);
						} else if (stats=BASS_Encode_CastGetStats(encoder,BASS_ENCODE_STATS_SHOUT,NULL)) {
							char *t=strstr(stats,"<CURRENTLISTENERS>"); // Shoutcast listener count
							if (t) listeners=atoi(t+18);
						} else break;
						sprintf(text,"Cast test (%d listeners)",listeners);
						SetWindowText(win,text);
					}
				}
			}
			break;

		case WM_COMMAND:
			switch (LOWORD(w)) {
				case IDCANCEL:
					DestroyWindow(h);
					break;
				case 50:
					if (!rchan)
						Start();
					else
						Stop();
					break;
				case 60:
					if (HIWORD(w)==EN_CHANGE) {
						char title[400];
						GetWindowText((HWND)l,title,sizeof(title));
						BASS_Encode_CastSetTitle(encoder,title,NULL);
					}
					break;
			}
			break;

		case WM_INITDIALOG:
			win=h;
			// setup default recording device
			if (!BASS_RecordInit(-1)) {
				Error("Can't initialize device");
				DestroyWindow(win);
			} else {
				int c;
				SetDlgItemText(win,10,"localhost:8000/bass");
				SetDlgItemText(win,11,"hackme");
				SetDlgItemText(win,15,"BASSenc test stream");
				MESS(30,BM_SETCHECK,BST_CHECKED,0); // set default encoder to MP3
				for (c=0;c<14;c++) {
					char temp[10];
					sprintf(temp,"%d",bitrates[c]);
					MESS(35,CB_ADDSTRING,0,temp);
				}
				MESS(35,CB_SETCURSEL,8,0); // default bitrate = 128kbps
				SetTimer(h,0,50,0); // timer to update the level display and listener count
				return 1;
			}
			break;

		case WM_DESTROY:
			// release all BASS stuff
			BASS_RecordFree();
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

	DialogBox(hInstance,(char*)1000,0,&dialogproc);

	return 0;
}
