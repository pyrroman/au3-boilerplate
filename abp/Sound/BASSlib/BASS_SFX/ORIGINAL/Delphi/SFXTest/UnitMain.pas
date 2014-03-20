
{ w3k 2009.04.08
 lcm5151@21cn.com }

unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, bass, bass_sfx, StdCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Button1: TButton;
    Button2: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  hSFX1 : HSFX = 0;
  hSFX2 : HSFX = 0;
  hSFX3 : HSFX = 0;
  Stream: HSTREAM = 0;
  hVisDC1 : HDC = 0;
  hVisDC2 : HDC = 0;
  hVisDC3 : HDC = 0;
  info : BASS_SFX_PLUGININFO;



implementation

{$R *.dfm}


procedure TForm1.FormCreate(Sender: TObject);
begin

  if BASS_Init(-1, 44100, 0, Handle, nil) then
  begin
    BASS_SFX_Init(HInstance, Handle);
    Stream:=BASS_StreamCreateFile(False, PChar('music\Matrix.mp3'), 0, 0, 0);
    BASS_ChannelPlay(Stream, False);

    hVisDC1 := GetDC(Panel1.Handle);
    hVisDC2 := GetDC(Panel2.Handle);
    hVisDC3 := GetDC(Panel3.Handle);


    hSFX1:=BASS_SFX_PluginCreate('plugins\sphere.svp', Panel1.Handle, Panel1.Width, Panel1.Height, 0); //sonique
    hSFX2:=BASS_SFX_PluginCreate('plugins\blaze.dll', Panel2.Handle, Panel2.Width, Panel2.Height, 0); //windows media player
    hSFX3:=BASS_SFX_PluginCreate('BBPlugin\oscillo.dll', Panel3.Handle, Panel3.Width, Panel3.Height, 0); //bassbox

    BASS_SFX_PluginStart(hSFX1);
    BASS_SFX_PluginStart(hSFX2);
    BASS_SFX_PluginStart(hSFX3);
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if (hSFX1 <> -1) then
  BASS_SFX_PluginRender(hSFX1, Stream, hVisDC1);
  if (hSFX2 <> -1) then
  BASS_SFX_PluginRender(hSFX2, Stream, hVisDC2);
  if (hSFX3 <> -1) then
  BASS_SFX_PluginRender(hSFX3, Stream, hVisDC3);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  BASS_StreamFree(Stream);
  BASS_SFX_Free;
  BASS_Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  BASS_SFX_PluginStop(hSFX1);
  BASS_SFX_PluginStop(hSFX2);
  BASS_SFX_PluginStop(hSFX3);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  BASS_SFX_PluginStart(hSFX1);
  BASS_SFX_PluginStart(hSFX2);
  BASS_SFX_PluginStart(hSFX3);
end;

end.
