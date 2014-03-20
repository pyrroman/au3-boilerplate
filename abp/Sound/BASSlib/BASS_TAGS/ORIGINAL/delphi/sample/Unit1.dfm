object Form1: TForm1
  Left = 507
  Top = 184
  Width = 320
  Height = 308
  Caption = 'Simple Delphi (Tags.dll) Example'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 312
    Height = 281
    Align = alClient
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 40
      Width = 45
      Height = 13
      Caption = 'TrackNr :'
    end
    object Label2: TLabel
      Left = 8
      Top = 64
      Width = 45
      Height = 13
      Caption = 'Interpret :'
    end
    object Label3: TLabel
      Left = 8
      Top = 88
      Width = 26
      Height = 13
      Caption = 'Title :'
    end
    object Label4: TLabel
      Left = 8
      Top = 136
      Width = 35
      Height = 13
      Caption = 'Genre :'
    end
    object Label5: TLabel
      Left = 8
      Top = 184
      Width = 50
      Height = 13
      Caption = 'Comment :'
    end
    object Label6: TLabel
      Left = 8
      Top = 112
      Width = 35
      Height = 13
      Caption = 'Album :'
    end
    object Label7: TLabel
      Left = 8
      Top = 160
      Width = 28
      Height = 13
      Caption = 'Year :'
    end
    object Button1: TButton
      Left = 0
      Top = 0
      Width = 305
      Height = 25
      Caption = 'Click here to open a File ....'
      TabOrder = 0
      OnClick = Button1Click
    end
    object edTrackNr: TEdit
      Left = 64
      Top = 36
      Width = 233
      Height = 21
      TabOrder = 1
    end
    object edInterpret: TEdit
      Left = 64
      Top = 60
      Width = 233
      Height = 21
      TabOrder = 2
    end
    object edTitle: TEdit
      Left = 64
      Top = 84
      Width = 233
      Height = 21
      TabOrder = 3
    end
    object edAlbum: TEdit
      Left = 64
      Top = 108
      Width = 233
      Height = 21
      TabOrder = 4
    end
    object Memo_Comments: TMemo
      Left = 64
      Top = 184
      Width = 233
      Height = 89
      TabOrder = 5
    end
    object edGenre: TEdit
      Left = 64
      Top = 132
      Width = 233
      Height = 21
      TabOrder = 6
    end
    object edYear: TEdit
      Left = 64
      Top = 156
      Width = 57
      Height = 21
      TabOrder = 7
    end
  end
  object OpenDialog1: TOpenDialog
    FileName = ''
    Filter = 'AudioFiles|*.mp3;*.wav;*wma;*.ogg'
    Left = 216
  end
end
