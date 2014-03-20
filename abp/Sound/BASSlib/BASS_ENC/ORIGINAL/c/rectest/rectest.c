/*
	BASSenc recording example
	Copyright (c) 2003-2008 Un4seen Developments Ltd.
*/

#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include "bass.h"
#include "bassenc.h"

HWND win;

int input;				// current input source
int encoder;			// current encoder

WAVEFORMATEX *acmform=0;	// ACM codec format
DWORD acmformlen;			// ACM codec format size

HRECORD rchan=0;		// recording/encoding channel
HSTREAM chan=0;			// playback channel

// encoder command-lines and output files
const char *commands[2]={
	"oggenc -o bass.ogg -", // oggenc (OGG)
	"lame --alt-preset standard - bass.mp3" // lame (MP3)
};
const char *files[3]={"bass.ogg","bass.mp3","bass.wav"}; // OGG,MP3,ACM

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

void StartRecording()
{
	if (chan) { // free old recording
		BASS_StreamFree(chan);
		chan=0;
		EnableWindow(DLGITEM(11),FALSE);
		// close output device before recording incase of half-duplex device
		BASS_Free();
	}
	// start recording @ 44100hz 16-bit stereo (paused to add encoder first)
	if (!(rchan=BASS_RecordStart(44100,2,BASS_RECORD_PAUSE,&RecordingCallback,0))) {
		Error("Couldn't start recording");
		return;
	}
	// get selected encoder (0=OGG, 1=MP3, 2=ACM)
	if (MESS(18,BM_GETCHECK,0,0)) encoder=2;
	else encoder=MESS(17,BM_GETCHECK,0,0);
	if (encoder==2) {
		if (!BASS_Encode_GetACMFormat(rchan,acmform,acmformlen,NULL,BASS_ACM_DEFAULT) // select the ACM codec
			|| !BASS_Encode_StartACMFile(rchan,acmform,BASS_ENCODE_AUTOFREE,files[2])) { // start the ACM encoder
			Error("Couldn't start encoding");
			BASS_ChannelStop(rchan);
			rchan=0;
			return;
		}
	} else if (!BASS_Encode_Start(rchan,commands[encoder],BASS_ENCODE_AUTOFREE,NULL,0)) { // start the OGG/MP3 encoder
		Error("Couldn't start encoding...\n"
			"Make sure OGGENC.EXE (if encoding to OGG) is in the same\n"
			"direcory as this RECTEST, or LAME.EXE (if encoding to MP3).");
		BASS_ChannelStop(rchan);
		rchan=0;
		return;
	}

	BASS_ChannelPlay(rchan,FALSE); // resume recoding
	MESS(10,WM_SETTEXT,0,"Stop");
	EnableWindow(DLGITEM(16),FALSE);
	EnableWindow(DLGITEM(17),FALSE);
	EnableWindow(DLGITEM(18),FALSE);
}

void StopRecording()
{
	// stop recording & encoding
	BASS_ChannelStop(rchan);
	rchan=0;
	MESS(10,WM_SETTEXT,0,"Record");
	EnableWindow(DLGITEM(16),TRUE);
	EnableWindow(DLGITEM(17),TRUE);
	EnableWindow(DLGITEM(18),TRUE);
	// setup output device (using default device)
	if (!BASS_Init(-1,44100,0,win,NULL)) {
		Error("Can't initialize output device");
		return;
	}
	// create a stream from the recording
	if (chan=BASS_StreamCreateFile(FALSE,files[encoder],0,0,0))
		EnableWindow(DLGITEM(11),TRUE); // enable "play" button
	else 
		BASS_Free();
}

void UpdateInputInfo()
{
	char *type;
	float level;
	int it=BASS_RecordGetInput(input,&level); // get info on the input
	MESS(14,TBM_SETPOS,TRUE,level*100); // set the level slider
	switch (it&BASS_INPUT_TYPE_MASK) {
		case BASS_INPUT_TYPE_DIGITAL:
			type="digital";
			break;
		case BASS_INPUT_TYPE_LINE:
			type="line-in";
			break;
		case BASS_INPUT_TYPE_MIC:
			type="microphone";
			break;
		case BASS_INPUT_TYPE_SYNTH:
			type="midi synth";
			break;
		case BASS_INPUT_TYPE_CD:
			type="analog cd";
			break;
		case BASS_INPUT_TYPE_PHONE:
			type="telephone";
			break;
		case BASS_INPUT_TYPE_SPEAKER:
			type="pc speaker";
			break;
		case BASS_INPUT_TYPE_WAVE:
			type="wave/pcm";
			break;
		case BASS_INPUT_TYPE_AUX:
			type="aux";
			break;
		case BASS_INPUT_TYPE_ANALOG:
			type="analog";
			break;
		default:
			type="undefined";
	}
	MESS(15,WM_SETTEXT,0,type); // display the type
}

BOOL CALLBACK dialogproc(HWND h,UINT m,WPARAM w,LPARAM l)
{
	switch (m) {
		case WM_TIMER:
			{ // update the recording/playback counter
				char text[30]="";
				if (rchan) // recording/encoding
					sprintf(text,"%I64d",BASS_ChannelGetPosition(rchan,BASS_POS_BYTE));
				else if (chan) {
					if (BASS_ChannelIsActive(chan)) // playing
						sprintf(text,"%I64d / %I64d",BASS_ChannelGetPosition(chan,BASS_POS_BYTE),BASS_ChannelGetLength(chan,BASS_POS_BYTE));
					else
						sprintf(text,"%I64d",BASS_ChannelGetLength(chan,BASS_POS_BYTE));
				}
				MESS(20,WM_SETTEXT,0,text);
			}
			break;

		case WM_COMMAND:
			switch (LOWORD(w)) {
				case IDCANCEL:
					DestroyWindow(h);
					break;
				case 10:
					if (!rchan)
						StartRecording();
					else
						StopRecording();
					break;
				case 11:
					BASS_ChannelPlay(chan,TRUE); // play the recorded data
					break;
				case 13:
					if (HIWORD(w)==CBN_SELCHANGE) { // input selection changed
						int i;
						input=MESS(13,CB_GETCURSEL,0,0); // get the selection
						// enable the selected input
						for (i=0;BASS_RecordSetInput(i,BASS_INPUT_OFF,-1);i++) ; // 1st disable all inputs, then...
						BASS_RecordSetInput(input,BASS_INPUT_ON,-1); // enable the selected
						UpdateInputInfo(); // update info
					}
					break;
			}
			break;

		case WM_HSCROLL:
			if (l) { // set input source level
				float level=SendMessage((HWND)l,TBM_GETPOS,0,0)/100.f;
				if (!BASS_RecordSetInput(input,0,level)) // failed to set input level
					BASS_RecordSetInput(-1,0,level); // try master level instead
			}
			break;

		case WM_INITDIALOG:
			win=h;
			// setup recording device (using default device)
			if (!BASS_RecordInit(-1)) {
				Error("Can't initialize device");
				DestroyWindow(win);
			} else { // get list of inputs
				int c;
				const char *i;
				MESS(14,TBM_SETRANGE,FALSE,MAKELONG(0,100)); // initialize input level slider
				for (c=0;i=BASS_RecordGetInputName(c);c++) {
					MESS(13,CB_ADDSTRING,0,i);
					if (!(BASS_RecordGetInput(c,NULL)&BASS_INPUT_OFF)) { // this 1 is currently "on"
						input=c;
						MESS(13,CB_SETCURSEL,input,0);
						UpdateInputInfo(); // display info
					}
				}
				MESS(16,BM_SETCHECK,BST_CHECKED,0); // set default encoder to OGG
				SetTimer(h,0,200,0); // timer to update the position display
				// allocate ACM format buffer, using suggested buffer size
				acmformlen=BASS_Encode_GetACMFormat(0,NULL,0,NULL,0);
				acmform=(WAVEFORMATEX*)malloc(acmformlen);
				memset(acmform,0,acmformlen);
				return 1;
			}
			break;

		case WM_DESTROY:
			// release all BASS stuff
			BASS_RecordFree();
			BASS_Free();
			free(acmform); // free ACM format buffer
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

	{ // enable trackbar support (for the level control)
		INITCOMMONCONTROLSEX cc={sizeof(cc),ICC_BAR_CLASSES};
		InitCommonControlsEx(&cc);
	}

	DialogBox(hInstance,(char*)1000,0,&dialogproc);

	return 0;
}
