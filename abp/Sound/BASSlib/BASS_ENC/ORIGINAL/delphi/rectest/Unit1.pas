unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Bass, bassenc, mmsystem, ExtCtrls, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    lLevel: TLabel;
    cbInput: TComboBox;
    tbLevel: TTrackBar;
    gbFormat: TGroupBox;
    rbOGG: TRadioButton;
    rbMP3: TRadioButton;
    bRecord: TButton;
    bPlay: TButton;
    stStatus: TStaticText;
    Timer1: TTimer;
    rbACM: TRadioButton;
    procedure GetEncoder(Sender: TOBject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure bRecordClick(Sender: TObject);
    procedure bPlayClick(Sender: TObject);
    procedure cbInputClick(Sender: TObject);
    procedure tbLevelChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

const
  // with this you can dedected if the  WaveFormatEx.wFormatTag is a Mp3 or OGG (e.g for the FileExtension
  
  ACM_CODEC_MP3_Tag = 85; // Lame or Fraunhofer Mp3 Codec
  ACM_CODEC_OGG_Tag = 26481; // Vorbis ACM Codec


var
  Form1: TForm1;
  win: HWND = 0;
  input: integer;
  encoder: integer; // current encoder
  acmForm: PWaveFormatEx;
  acmformlen: DWORD = 0;
  rchan: HRECORD = 0;
  chan: HSTREAM = 0;
  (* encoder command-lines and output files *)
  commands: array[0..1] of pAnsiChar = (
    'oggenc.exe -o bass.ogg -', // oggenc (OGG)
    'lame.exe --alt-preset standard - bass.mp3' // lame (MP3)
    );

  files: array[0..2] of pAnsiChar = ('bass.ogg', 'bass.mp3', 'bass.wav');

implementation

{$R *.dfm}

// display error messages

procedure Error(es: string);
var
  mes: string;
begin
  mes := format('%s' + #10 + '(error code: %d)', [es, BASS_ErrorGetCode()]);
  MessageBox(win, PChar(mes), 'Error', MB_OK);
end; //Error

function RecordingCallback(channel: HRECORD; buffer: Pointer; length, user: DWORD): Boolean; stdcall;
begin
  Result := Bool(BASS_Encode_IsActive(channel)); // continue recording if encoder is alive
end;

procedure StartRecording();
begin
  if (chan <> 0) then // free old recording
  begin
    BASS_StreamFree(chan);
    chan := 0;
    Form1.bPlay.Enabled := False;
  end;
  // start recording @ 44100hz 16-bit stereo (paused to add encoder first)
  rchan := BASS_RecordStart(44100, 2, BASS_RECORD_PAUSE, @RecordingCallback, 0);
  if rchan = 0 then
  begin
    Error('Couldn''t start recording');
    Exit;
  end;
  // start encoding

  if encoder = 2 then
  begin
    // Check the needed Length for the AcmFormLen
    acmFormLen := BASS_Encode_GetACMFormat(0, nil, 0, nil, 0);
    // allocate the format buffer
    acmForm := AllocMem(acmFormLen);
    // select the ACM Format
    BASS_Encode_GetACMFormat(RChan, acmForm, acmFormLen, nil, BASS_ACM_DEFAULT);
    // a little Check if the ACM Dialog was cancel
    if Bass_ErrorGetCode = BASS_ERROR_ACM_CANCEL then
      exit;

    if BASS_Encode_StartACMFile(rchan, acmform, BASS_ENCODE_AUTOFREE, Files[2]) = 0 then
    begin
      Error('Couldn''t start encoding');
      BASS_ChannelStop(rchan);
      rchan := 0;
      exit;
    end;
    FreeMem(acmForm);
  end
  else
  begin
    if (BASS_Encode_Start(rchan, commands[encoder], BASS_ENCODE_AUTOFREE, nil, 0) = 0) then
    begin
      Error('Couldn''t start encoding...' + #10
        + 'Make sure OGGENC.EXE (if encoding to OGG) is in the same' + #10
        + 'direcory as this RECTEST, or LAME.EXE (if encoding to MP3).');
      BASS_ChannelStop(rchan);
      rchan := 0;
      Exit;
    end;
  end; //StartRecording
  BASS_ChannelPlay(rchan, FALSE); // resume recoding
  Form1.bRecord.Caption := 'Stop';
  Form1.rbOgg.Enabled := False;
  Form1.rbMp3.Enabled := False;
  Form1.rbACM.Enabled := False;
end;

procedure StopRecording();
begin
  // stop recording & encoding
  BASS_ChannelStop(rchan);
  rchan := 0;
  // create a stream from the recording

  chan := BASS_StreamCreateFile(FALSE, files[encoder], 0, 0, 0);
  if (chan <> 0) then
    Form1.bPlay.Enabled := True; // enable "play" button;
  Form1.bRecord.Caption := 'Record';
  Form1.rbOgg.Enabled := True;
  Form1.rbMp3.Enabled := True;
  Form1.rbACM.Enabled := true;
end; //StopRecording

procedure UpdateInputInfo();
var
  _type: string;
  it: integer;
  level: Single;
begin
  it := BASS_RecordGetInput(input, level); // get info on the input
  Form1.tbLevel.Position := level * 100; // set the level slider
  case (it and BASS_INPUT_TYPE_MASK) of
    BASS_INPUT_TYPE_DIGITAL: _type := 'digital';
    BASS_INPUT_TYPE_LINE: _type := 'line-in';
    BASS_INPUT_TYPE_MIC: _type := 'microphone';
    BASS_INPUT_TYPE_SYNTH: _type := 'midi synth';
    BASS_INPUT_TYPE_CD: _type := 'analog cd';
    BASS_INPUT_TYPE_PHONE: _type := 'telephone';
    BASS_INPUT_TYPE_SPEAKER: _type := 'pc speaker';
    BASS_INPUT_TYPE_WAVE: _type := 'wave/pcm';
    BASS_INPUT_TYPE_AUX: _type := 'aux';
    BASS_INPUT_TYPE_ANALOG: _type := 'analog';
  else
    _type := 'undefined';
  end;
  Form1.lLevel.Caption := _type; // display the type
end; //UpdateInputInfo

procedure TForm1.GetEncoder(Sender: TOBject);
begin
  Encoder := TRadioButton(Sender).Tag;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  c: integer;
  i: PChar;
  level: Single;
begin
  Caption := 'BASS recording to OGG/MP3 test';

	// check the correct BASS was loaded
	if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
	begin
		MessageBox(0,'An incorrect version of BASS.DLL was loaded',0,MB_ICONERROR);
		Halt;
	end;

  win := Handle;
  // setup recording and output devices (using default devices)
  if (not BASS_RecordInit(-1)) or (not BASS_Init(-1, 44100, 0, win, nil)) then
  begin
    Error('Can''t initialize device');
    Close();
  end
  else // get list of inputs
  begin
    tbLevel.Min := 0;
    tbLevel.Max := 100; // initialize input level slider
    c := 0;
    i := BASS_RecordGetInputName(c);
    while i <> nil do
    begin
      cbInput.Items.Add(StrPas(i));
      if (BASS_RecordGetInput(c, level) and BASS_INPUT_OFF) = 0 then // this 1 is currently "on"
      begin
        input := c;
        cbInput.ItemIndex := c;
        UpdateInputInfo(); // display info
      end;
      inc(c);
      i := BASS_RecordGetInputName(c);
    end; //while
    rbACM.Checked := True; // set default encoder to OGG
    Timer1.Interval := 200; // timer to update the position display
  end;
  stStatus.Caption := '';
  bPlay.Enabled := False;
end; //FormCreate

procedure TForm1.Timer1Timer(Sender: TObject);
var
  text: string;
begin
  // update the recording/playback counter
  if (rchan <> 0) then // recording/encoding
    text := Format('%d', [BASS_ChannelGetPosition(rchan, BASS_POS_BYTE)])
  else if (chan <> 0) then
  begin
    if (BASS_ChannelIsActive(chan) <> 0) then // playing
      text := Format('%d / %d', [BASS_ChannelGetPosition(chan, BASS_POS_BYTE), BASS_ChannelGetLength(chan, BASS_POS_BYTE)])
    else
      text := Format('%d', [BASS_ChannelGetLength(chan, BASS_POS_BYTE)]);
  end;
  stStatus.Caption := text;
end;

procedure TForm1.bRecordClick(Sender: TObject);
begin
  if (rchan = 0) then
    StartRecording()
  else
    StopRecording();
end;

procedure TForm1.bPlayClick(Sender: TObject);
begin
  BASS_ChannelPlay(chan, TRUE); // play the recorded data
end;

procedure TForm1.cbInputClick(Sender: TObject);
var
  i: Integer;
begin
  input := cbInput.ItemIndex; // get the selection
  // enable the selected input
  i := 0;
  while BASS_RecordSetInput(i, BASS_INPUT_OFF, -1) do
    inc(i); // 1st disable all inputs, then...
  BASS_RecordSetInput(input, BASS_INPUT_ON, -1); // enable the selected
  UpdateInputInfo(); // update info
end;

procedure TForm1.tbLevelChange(Sender: TObject);
begin
  BASS_RecordSetInput(input, 0, tbLevel.Position / 100);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  // release all BASS stuff
  BASS_RecordFree();
  BASS_Free();
end;

end.

