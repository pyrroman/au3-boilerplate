{
For this Demo you will need Bass & Basswma available @www.un4seen.com
}
unit Unit1;

interface

uses
  Classes, Forms, tags, bass, basswma, Dialogs, StdCtrls, Controls,
  ExtCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    edTrackNr: TEdit;
    edInterpret: TEdit;
    edTitle: TEdit;
    edAlbum: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Memo_Comments: TMemo;
    Label6: TLabel;
    Label7: TLabel;
    edGenre: TEdit;
    edYear: TEdit;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;
  Channel: HStream;
implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Bass_StreamFree(Channel);
  edTrackNr.Text := '';
  edTitle.Text := '';
  edInterpret.Text := '';
  edAlbum.Text := '';
  edGenre.Text := '';
  edYear.Text := '';
  Memo_Comments.Lines.Clear;

  if not OpenDialog1.Execute then exit;
  Channel := Bass_StreamCreateFile(false, PChar(OpenDialog1.FileName), 0, 0, Bass_Stream_Decode);
  if Channel = 0 then
    Channel := Bass_WMA_StreamCreateFile(false, PChar(OpenDialog1.FileName), 0, 0, Bass_Stream_Decode);
  if Channel = 0 then
    exit;
  edTrackNr.Text := TAGS_Read(Channel, '%TRCK');
  edTitle.Text := TAGS_Read(Channel, '%TITL');
  edInterpret.Text := TAGS_Read(Channel, '%ARTI');
  edAlbum.Text := TAGS_Read(Channel, '%ALBM');
  edGenre.Text := TAGS_Read(Channel, '%GNRE');
  edYear.Text := TAGS_Read(Channel, '%YEAR');
  Memo_Comments.Lines.Add(TAGS_Read(Channel, '%CMNT'));
  

  // About the different possible FormatStrings please read the Comment in the tags.pas
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // we don`t need a Output
  Bass_Init(0, 44100, 0, handle, nil);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Bass_Free();
end;

end.

