{
******************************************************************************
* Bass _Asio Speaker Example by Chris Troesken                               *
* translated from the speaker.c Example of Ian Luck                          *
* Bass.dll Copyright by  Ian Luck                                            *
* Bassasio.dll Copyright by  Ian Luck                                        *
* Requires: BASS.DLL & BASS.PAS 2.1,,Bassasio.dll & Bassasio.pas             *
* available @ www.un4seen.com                                                *
******************************************************************************
This Example will show how set more than One Channel(s)
also it will show how to Play/Pause a separately Channel
}

{$BOOLEVAL OFF}

unit Unit1;

interface

uses
  Windows, SysUtils, Messages, Classes, Forms,
  Dialogs, ExtCtrls, StdCtrls, Controls, bass, bassasio;

type
  TPlayStatus = (isPlaying, isStopped);
  TForm1 = class(TForm)
    Panel1: TPanel;
    GroupBox0: TGroupBox;
    Button1: TButton;
    GroupBox1: TGroupBox;
    Button2: TButton;
    GroupBox2: TGroupBox;
    Button3: TButton;
    GroupBox3: TGroupBox;
    Button4: TButton;
    btnSwap1: TButton;
    btnSwap2: TButton;
    btnSwap3: TButton;
    OpenDialog: TOpenDialog;
    btnStatus1: TButton;
    btnStatus2: TButton;
    btnStatus3: TButton;
    btnStatus4: TButton;
    lblStatus1: TLabel;
    lblStatus2: TLabel;
    lblStatus3: TLabel;
    lblStatus4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure OpenFile(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SetStatus(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure Error(s: string);
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;
  MaxOutputs: DWORD = 0;
  Chan: array[0..3] of HStream;

implementation

{$R *.dfm}




function AsioProc(input: boolean; Channel: DWORD; Buffer: Pointer; Length: DWORD; User: Pointer): DWORD; stdcall;
begin
  {little reminder the "Channel: DWORD" in the Asio proc is the AsioChannel and not the Bass Channel Handle }
var
  c: DWORD;
begin
  c := Bass_ChannelGetData(Chan[DWORD(User)], buffer, Length);
  if (c = -1) then c := 0;
  Result := c;
end;

function GetStatus(StreamNr: DWORD): string;
begin

  Result := 'Status' + #13#10 + 'Empty';

  if (Bass_ChannelisActive(Chan[StreamNr]) <> 0) and
    (BASS_ASIO_ChannelIsActive(false, StreamNr * 2) = BASS_ASIO_ACTIVE_ENABLED) then
    Result := 'Status' + #13#10 + 'Playing'
  else
    if (Bass_ChannelisActive(Chan[StreamNr]) <> 0) and
      (BASS_ASIO_ChannelIsActive(false, StreamNr * 2) = BASS_ASIO_ACTIVE_Paused) then
      Result := 'Status' + #13#10 + 'Paused';

end;

procedure TForm1.SetStatus(Sender: TObject);
var
  i: integer;
begin
  i := TButton(Sender).Tag;
  if Bass_ChannelisActive(Chan[i]) = 0 then
    exit;
  if BASS_ASIO_ChannelIsActive(false, i * 2) = BASS_ASIO_ACTIVE_PAUSED then
    Bass_Asio_ChannelReset(false, i * 2, BASS_ASIO_RESET_PAUSE)
  else
    Bass_Asio_ChannelPause(false, i * 2);
  (FindComponent('lblStatus' + inttostr(i + 1)) as TLabel).Caption := GetStatus(i);
end;

function MinMaxInt(x, fmin, fmax: integer): integer;
begin
  if (X < fMin) then
    X := fMin
  else if (X > fMax) then
    X := fMax;
  Result := X;
end;



procedure TForm1.Error(s: string);
begin
  MessageBox(0, PChar(s + #13#10 +
    'BassError-Code = ' + inttostr(Bass_ErrorGetCode) + #13#10 +
    'BassAsioErrorCode = ' + inttostr(Bass_Asio_ErrorGetCode)), PChar('Error'),
    $00000010);

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  a: integer;
  i, i2: Bass_Asio_ChannelInfo;
  AsioInfo: Bass_Asio_Info;
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

  Bass_Asio_GetInfo(AsioInfo);
  // check how many output pairs are supports
  MaxOutputs := MinMaxInt(3, 0, AsioInfo.outputs); // // Check if the Maxoutputs  >= 4
  for a := 0 to MaxOutputs do
  begin
    if Bass_Asio_ChannelGetinfo(false, a * 2, i) and
      Bass_Asio_ChannelGetinfo(false, a * 2 + 1, i2) then
    begin
      (FindComponent('Groupbox' + inttostr(a)) as TGroupbox).Enabled := true;
      (FindComponent('Button' + inttostr(a + 1)) as TButton).Enabled := true;
      (FindComponent('btnStatus' + inttostr(a + 1)) as TButton).Enabled := true;
      (FindComponent('Groupbox' + inttostr(a)) as TGroupbox).Caption := i.name + ' + ' + i2.name;
      if a > 0 then
        (FindComponent('btnSwap' + inttostr(a)) as TButton).Enabled := true;
      // Set the Caption of the Groupboxes with the Driver Name(s)
      Bass_Asio_ChannelEnable(false, a * 2, @AsioProc, Pointer(a));
      Bass_Asio_ChannelJoin(false, a * 2 + 1, a * 2);
      Bass_Asio_ChannelSetFormat(false, a * 2, BASS_ASIO_FORMAT_FLOAT); // set as Format Float
      BASS_ASIO_ChannelPause(false, a * 2);
      // we will set all Asio Chans paused (we have at this Moment no Bass Channels Handles loaded
    end;
  end;

  if not BASS_ASIO_Start(0) then
    Error('Can''t start Asio Output');
end;

procedure TForm1.OpenFile(Sender: TObject);
var
  Output: integer;
  i: Bass_ChannelInfo;
  temp: HSTREAM;
  tmpValue: float;
  s1, s2: string;
begin
  Output := TButton(Sender).Tag - 10;
  if (Output >= 0) and (Output <= 3) then // Checking the different 2 Tag-Groups of the Open Buttons
  begin

    if not OpenDialog.Execute then
      exit;
    if not BASS_ASIO_ChannelIsActive(false, output * 2) = BASS_ASIO_ACTIVE_PAUSED then // little check if the Asio Channel will have the Status Pause
      BASS_ASIO_ChannelPause(false, output * 2); // Paused the Asio Channel
    Bass_StreamFree(Chan[Output]);
    Chan[Output] := Bass_StreamCreateFile(false, PChar(OpenDialog.FileName), 0, 0,
      BASS_STREAM_DECODE or BASS_SAMPLE_FLOAT or BASS_SAMPLE_LOOP {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
    if Chan[Output] = 0 then
    begin
      TButton(Sender).Caption := 'Click here to open a File ...';
      Error('Can''t play the File');
    end
    else
    begin

      Bass_ChannelGetInfo(Chan[Output], i);
      Bass_Asio_ChannelSetRate(false, Chan[Output], i.freq);
      BASS_ASIO_ChannelReset(false, output * 2, BASS_ASIO_RESET_PAUSE); // unpause the Asio Channel
      TButton(Sender).Caption := ExtractFileName(OpenDialog.FileName);


      (FindComponent('lblStatus' + inttostr(Output + 1)) as TLabel).Caption := GetStatus(Output);
    end;
  end
  else
  begin // Checking the Swap Buttons

    //swap the Channels
    Output := TButton(Sender).Tag - 20;
    temp := Chan[Output];
    Chan[Output] := Chan[Output + 1];
    Chan[Output + 1] := temp;
    // swap SampleRates
    tmpValue := Bass_Asio_ChannelGetRate(false, Output * 2);
    Bass_Asio_ChannelSetRate(false, Output * 2, Bass_Asio_ChannelGetRate(false,
      (Output + 1) * 2));
    Bass_Asio_ChannelSetRate(false, (Output + 1) * 2, tmpvalue);
    // Swap the Text

    s1 := (FindComponent('Button' + inttostr(Output + 1)) as TButton).Caption;
    s2 := (FindComponent('Button' + inttostr(Output + 2)) as TButton).Caption;
    (FindComponent('Button' + inttostr(Output + 1)) as TButton).Caption := s2;
    (FindComponent('Button' + inttostr(Output + 2)) as TButton).Caption := s1;
  end;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Bass_Asio_Free();
  Bass_Free();
end;

end.

