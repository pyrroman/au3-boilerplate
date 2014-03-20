{
Delphi ASIO version of BASS simple DSP Test by Chris Troesken
Orginal dsptest.c Example by Ian Luck
Orginal fdptest.frm Example by JOBnik!
}

unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Bass, Bassasio, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    OpenDialog1: TOpenDialog;
    Open_Button: TButton;
    chk_Rotate: TCheckBox;
    chk_Echo: TCheckBox;
    chk_Flanger: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chk_RotateClick(Sender: TObject);
    procedure chk_EchoClick(Sender: TObject);
    procedure chk_FlangerClick(Sender: TObject);
    procedure Open_ButtonClick(Sender: TObject);
  private
    { Private-Deklarationen }

  public
    { Public-Deklarationen }
  end;
const
  ECHBUFLEN = 1200; // buffer length
  FLABUFLEN = 350; // buffer length

var
  Form1: TForm1;
  Chan: HStream;
  rotdsp: HDSP = 0;
  echdsp: HDSP = 0;
  fladsp: HDSP = 0;
  swpdsp: HDSP = 0;
  rotpos: Single; // cur.pos
  echbuf: array[0..ECHBUFLEN - 1, 0..1] of Single; // buffer
  echpos: Integer; // cur.pos
  flabuf: array[0..FLABUFLEN - 1, 0..1] of Single; // buffer
  flapos: Integer; // cur.pos
  flas, flasinc: Single; // sweep pos/increment

implementation

{$R *.dfm}

function fmod(a, b: Single): Single;
begin
  Result := a - (b * Trunc(a / b));
end;

{****************AsioCallBack************}

function AsioProc(input: BOOL; channel: DWORD; buffer: Pointer; length: DWORD;
  user: Pointer): DWORD; stdcall;
begin
var
  c: DWORD;
begin
  c := Bass_ChannelGetData(chan, buffer, length);
  if (c = -1) then c := 0;
  Result := c;
end;
{****************AsioCallBackEND************}

{****************CallBacks***************}

procedure Rotate(handle: HDSP; channel: DWORD; buffer: Pointer; length: DWORD;
  user: Pointer); stdcall;
var
  a: DWORD;
  d: PSingle;
begin
  d := buffer;

  a := 0;
  while (a < (length div 4)) do
  begin
    d^ := d^ * Abs(Sin(rotpos));
    Inc(d);
    d^ := d^ * Abs(Cos(rotpos));

    rotpos := fmod(rotpos + 0.00003, Pi);

    Inc(d);
    a := a + 2;
  end;
end;

procedure Echo(handle: HDSP; channel: DWORD; buffer: Pointer; length: DWORD;
  user: Pointer); stdcall;
var
  a: DWORD;
  d: PSingle;
  l, r: Single;
begin
  d := buffer;

  a := 0;
  while (a < (length div 4)) do
  begin
    l := d^ + (echbuf[echpos, 1] / 2);
    Inc(d);
    r := d^ + (echbuf[echpos, 0] / 2);
    Dec(d);

    d^ := l;
    echbuf[echpos, 0] := l;
    Inc(d);
    d^ := r;
    echbuf[echpos, 1] := r;
    echpos := echpos + 1;
    if (echpos = ECHBUFLEN) then
      echpos := 0;

    Inc(d);
    a := a + 2;
  end;
end;

procedure Flange(handle: HDSP; channel: DWORD; buffer: Pointer; length: DWORD;
  user: Pointer); stdcall;
var
  a: DWORD;
  d: PSingle;
  f, s: Single;
  p1, p2: Integer;
begin
  d := buffer;

  a := 0;
  while (a < (length div 4)) do
  begin
    p1 := Trunc(flapos + flas) mod FLABUFLEN;
    p2 := (p1 + 1) mod FLABUFLEN;
    f := fmod(flas, 1);

    s := d^ + ((flabuf[p1, 0] * (1 - f)) + (flabuf[p2, 0] * f));
    flabuf[flapos, 0] := d^;
    d^ := s;

    Inc(d);
    s := d^ + ((flabuf[p1, 1] * (1 - f)) + (flabuf[p2, 1] * f));
    flabuf[flapos, 1] := d^;
    d^ := s;

    flapos := flapos + 1;
    if (flapos = FLABUFLEN) then
      flapos := 0;

    flas := flas + flasinc;
    if (flas < 0.0) or (flas > FLABUFLEN) then
      flasinc := -flasinc;

    Inc(d);
    a := a + 2;
  end;
end;

{****************Callbacks End***********}

function ShowErrorCode(aValue: string): string;
begin
  Result := aValue + ' - ' + 'ErrorCode : ' + inttostr(Bass_ErrorGetCode);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
	// check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
	begin
		MessageBox(0,'An incorrect version of BASS.DLL was loaded',0,MB_ICONERROR);
		Halt;
	end;

  BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD, 0);
  BASS_Init(0, 48000, 0, 0, nil);
  if not BASS_ASIO_Init(0) then
  begin
    BASS_Free();
    MessageBox(0, 'Error', 'Can''t initialize ASIO', 0);
    Halt;
  end;
  BASS_ASIO_ChannelEnable(false, Chan, @AsioProc, 0);
  BASS_ASIO_ChannelJoin(false, 1, 0);
  BASS_ASIO_ChannelSetFormat(false, 0, BASS_ASIO_FORMAT_FLOAT);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Bass_Asio_Free();
  Bass_Free();
end;

procedure TForm1.chk_RotateClick(Sender: TObject);
begin
  if chk_Rotate.Checked then
  begin
    rotpos := 0.7853981;
    rotdsp := BASS_ChannelSetDSP(chan, @Rotate, 0, 3);
  end
  else
    BASS_ChannelRemoveDSP(chan, rotdsp);
end;

procedure TForm1.chk_EchoClick(Sender: TObject);
begin
  if chk_Echo.Checked then
  begin
    echpos := 0;
    echdsp := BASS_ChannelSetDSP(chan, @Echo, 0, 2);
  end
  else
    BASS_ChannelRemoveDSP(chan, echdsp);
end;

procedure TForm1.chk_FlangerClick(Sender: TObject);
begin
  if chk_Flanger.Checked then
  begin
    flapos := 0;
    flas := FLABUFLEN / 2;
    flasinc := 0.002;
    fladsp := BASS_ChannelSetDSP(chan, @Flange, 0, 1);
  end
  else
    BASS_ChannelRemoveDSP(chan, fladsp)
end;

procedure TForm1.Open_ButtonClick(Sender: TObject);
var
  info: Bass_ChannelInfo;
begin
  if not opendialog1.Execute then
    exit;
  BASS_ASIO_Stop;
  BASS_StreamFree(chan);
  chan := BASS_StreamCreateFile(false, PChar(opendialog1.FileName), 0, 0,
    BASS_SAMPLE_FLOAT or BASS_STREAM_DECODE {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
  if Chan = 0 then
  begin
    Open_Button.Caption := 'click here to open a file...';
    ShowErrorCode('Can''t play the File');
    exit;
  end;
  Bass_ChannelGetInfo(Chan, info);
  if (info.chans <> 2) then
  begin // only stereo is allowed
    Open_Button.Caption := 'click here to open a file...';
    BASS_StreamFree(chan);
    ShowErrorCode('only stereo sources are supported');
    exit;
  end;
  Open_Button.Caption := ExtractFileName(opendialog1.FileName);
  chk_Rotate.OnClick(self);
  chk_Echo.OnClick(self);
  chk_Flanger.OnClick(self);
  BASS_ASIO_ChannelSetRate(false, 0, info.freq); //set the output channel rate
  BASS_ASIO_SetRate(info.freq);
    //try to set the device rate too (saves resampling)
  // Start the ASIO device
  BASS_ASIO_Start(0);
end;

end.

