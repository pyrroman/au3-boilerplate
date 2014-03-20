unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,Math,commctrl, Bass, bassenc;

const
  WM_StartBTN = WM_USER + 100;
  WM_Cast_Enable = WM_USER + 101;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    ed_server: TEdit;
    Label3: TLabel;
    ed_Password: TEdit;
    chk_public: TCheckBox;
    Label4: TLabel;
    ed_Name: TEdit;
    Label5: TLabel;
    ed_url: TEdit;
    Label6: TLabel;
    ed_genre: TEdit;
    Label7: TLabel;
    ed_desc: TEdit;
    grp_Format: TGroupBox;
    chk_Mp3: TRadioButton;
    chk_ogg: TRadioButton;
    Label8: TLabel;
    cb_Bitrate: TComboBox;
    btn_start: TButton;
    Label9: TLabel;
    chk_AutoReconnect: TCheckBox;
    ed_TrackTitle: TEdit;
    Pr_level: TProgressBar;
    LevelTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure chk_AutoReconnectClick(Sender: TObject);
    procedure btn_startClick(Sender: TObject);
    procedure LevelTimerTimer(Sender: TObject);
    procedure ed_TrackTitleChange(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure Start;
    procedure Stop;
  public
    procedure WndProc(var Msg: TMessage); override;
    { Public-Deklarationen }
  end;

var
  win: hwnd;
  levl: Integer = 0;
  levr: Integer = 0;

  rchan: HRECORD = 0; // recording/encoding channel
  encoder: HENCODE;
  AutoReconnect: boolean;
  UpdateCount: integer = 0;
  Form1: TForm1;

implementation

{$R *.dfm}

function Instr(const strSource: string; const strSubStr: string): Integer;
begin
  Result := Pos(strSubstr, strSource);
end;

procedure BassError(const es: Pchar);
begin
  MessageBox(win, es, PChar(Format('Error code: %d', [BASS_ErrorGetCode])), 0);
end;

function RecordingCallback(Channel: HRECORD; buffer: Pointer; length: DWORD; user: DWORD): BOOL;
  stdcall;
begin
  Result := BASS_Encode_IsActive(Channel) <> 0; // continue recording if encoder is alive
end;

procedure EncoderNotify(Enchandle: HENCODE; status, user: DWORD); stdcall;
begin
  if status < $10000 then // encoder/connection died
  begin
    if AutoReconnect then
    begin
      PostMessage(User, WM_Cast_Enable, 0, 0);
      PostMessage(User, WM_Startbtn, 0, 0);
      Sleep(1000);
      PostMessage(User, WM_Cast_Enable, 0, 1);
      PostMessage(User, WM_Startbtn, 0, 1);
    end
    else if Status = BASS_ENCODE_NOTIFY_CAST then
      MessageBox(User, 'The server connection died!', 'Info', 0)
    else
      MessageBox(User, 'The encoder died!', 'Info', 0);
    // Okay the Encoder or the Server Connection lost lets enable all controls
    PostMessage(User, WM_Cast_Enable, 0, 1);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  win := handle;
  if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
  begin
    MessageBox(win, 'An incorrect version of BASS.DLL was loaded', nil, MB_ICONERROR);
    Halt;
  end;
  if (not BASS_RecordInit(0)) then
  begin
    BassError('Can''t initialize device');
    Close();
  end;
  // lets Change the Color for the Level Progressbar to white
  SendMessage(pr_level.Handle, PBM_SETBARCOLOR, 0, clwhite);
end;

procedure TForm1.Start;
var
  Bitrate: DWORD;
  content: PChar;
  ComLine: PChar;
begin
  rchan := BASS_RecordStart(44100, 2, BASS_RECORD_PAUSE, @RecordingCallback, 0);
  if rchan = 0 then
  begin
    BassError('Couldn''t start recording!');
    exit;
  end;
  if cb_Bitrate.ItemIndex > -1 then
    Bitrate := strtointdef(cb_Bitrate.Items.Strings[cb_Bitrate.ItemIndex], 128)
  else
    Bitrate := 128;
  // setup encoder command-line (raw PCM data to avoid length limit)
  if chk_Mp3.Checked then
  begin
    Content := BASS_ENCODE_TYPE_MP3;
    Comline := PChar(Format('lame -r -x -s 44100 -b %d -', [bitrate]));
  end
  else
  begin
    Content := BASS_ENCODE_TYPE_OGG;
    Comline := PChar(Format('oggenc -r -R 44100 -b %d -m %d -', [bitrate, 16]));
      // for better Quality on ogg just use -q (-2.0 - 10.0}
  end;
  Encoder := BASS_Encode_Start(
    rchan, ComLine, BASS_ENCODE_NOHEAD or BASS_ENCODE_AUTOFREE, nil, 0); // start the encoder
  if Encoder = 0 then
  begin
    BassError('Couldn''t start encoding...' + #10
      + 'Make sure OGGENC.EXE (if encoding to OGG) is in the same' + #10
      + 'direcory as this RECTEST, or LAME.EXE (if encoding to MP3).');
    BASS_ChannelStop(rchan);
    rchan := 0;
    exit;
  end;
  // Info: to prevent freezing from the Application use a Thread for the Cast Stuff
  if not BASS_Encode_CastInit(Encoder, PChar(ed_server.text), PChar(ed_Password.text), content,
    PChar(ed_Name.text), PChar(ed_url.text), PChar(ed_Genre.text), PChar(ed_desc.Text), nil,
    bitrate, chk_Public.Checked) then
  begin
    BassError('Couldn''t setup connection with server');
    BASS_ChannelStop(rchan);
    rchan := 0;
    exit;
  end;
  btn_Start.Caption := 'Stop';
  BASS_ChannelPlay(rchan, FALSE); // resume recording
  ed_server.Enabled := false;
  ed_password.Enabled := false;
  ed_Name.Enabled := false;
  ed_genre.Enabled := false;
  ed_url.Enabled := false;
  ed_desc.Enabled := false;
  chk_public.Enabled := false;
  chk_MP3.Enabled := false;
  chk_OGG.Enabled := false;
  cb_Bitrate.Enabled := false;
  ed_TrackTitle.Enabled := true;
  ed_Tracktitle.Color := clwhite;
  LevelTimer.Enabled := true;
  BASS_Encode_SetNotify(encoder, @EncoderNotify, Win); // notify of dead encoder/connection
end;

procedure TForm1.Stop;
begin
  BASS_ChannelStop(rchan);
  rchan := 0;
  btn_Start.Caption := 'Start';
  ed_server.Enabled := true;
  ed_password.Enabled := true;
  ed_Name.Enabled := true;
  ed_genre.Enabled := true;
  ed_url.Enabled := true;
  ed_desc.Enabled := true;
  chk_public.Enabled := true;
  chk_MP3.Enabled := true;
  chk_OGG.Enabled := true;
  cb_Bitrate.Enabled := true;
  ed_TrackTitle.Color := clbtnFace;
  ed_TrackTitle.Enabled := false;
  LevelTimer.Enabled := false;
  Pr_level.Position := 0;
end;

procedure TForm1.WndProc(var Msg: TMessage);
begin
  inherited;
  case Msg.Msg of
    WM_StartBTN: btn_Start.Enabled := (Msg.LParam <> 0);
    WM_Cast_Enable: if msg.LParam = 0 then
        Start
      else
        Stop;
  end;
end;

procedure TForm1.chk_AutoReconnectClick(Sender: TObject);
begin
  AutoReconnect := chk_AutoReconnect.Checked;
end;

procedure TForm1.btn_startClick(Sender: TObject);
begin
  if RChan <> 0 then
    Stop
  else
    Start;
end;

procedure TForm1.LevelTimerTimer(Sender: TObject);
var
  stats: string;
  listeners: Integer;
  t: Integer;
  Level : DWORD;
begin
  // update level
  level := BASS_ChannelGetLevel(rchan);
  levl := levl - 1500;
  if (levl < 0) then
    levl := 0;
  levr := levr - 1500;
  if (levr < 0) then
    levr := 0;
  if (level <> DW_Error) then
  begin
    if (levl < LOWORD(level)) then
      levl := LOWORD(level);
    if (levr < HIWORD(level)) then
      levr := HIWORD(level);
  end;
  Pr_level.Position := Max(levl,levr);

  inc(UpdateCount);
  if (UpdateCount mod 100) = 0 then //only checking once every 5 seconds
  begin
    listeners := 0;
    stats := BASS_Encode_CastGetStats(encoder, BASS_ENCODE_STATS_ICE, nil);
    if (stats <> '') then
    begin
      t := InStr(stats, '<Listeners>'); //' Icecast listener count
      if (t <> 0) then
        Listeners := strtoIntdef(Copy(stats, t+11, 1), -1);
    end
    else
    begin
      stats := BASS_Encode_CastGetStats(encoder, BASS_ENCODE_STATS_SHOUT, nil);
      if (stats <> '') then
      begin
        t := InStr(stats, '<CURRENTLISTENERS>'); //' Icecast listener count
        if (t <> 0) then
          Listeners := strtoIntdef(Copy(stats, t+18, 1), -1);
      end
    end;
    Caption := Format('Cast test (%d listeners)', [listeners]);
  end;
end;

procedure TForm1.ed_TrackTitleChange(Sender: TObject);
begin
  BASS_Encode_CastSetTitle(encoder, PChar(ed_TrackTitle.text), nil);
end;

end.

