object Form1: TForm1
  Left = 1038
  Top = 427
  BorderStyle = bsDialog
  Caption = 'SFXTest'
  ClientHeight = 257
  ClientWidth = 648
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 184
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 280
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 201
    Height = 169
    Color = clBackground
    TabOrder = 2
  end
  object Panel2: TPanel
    Left = 208
    Top = 0
    Width = 201
    Height = 169
    Color = clBackground
    TabOrder = 3
  end
  object Panel3: TPanel
    Left = 424
    Top = 0
    Width = 201
    Height = 169
    Color = clBackground
    TabOrder = 4
  end
  object Timer1: TTimer
    Interval = 10
    OnTimer = Timer1Timer
    Left = 280
    Top = 64
  end
end
