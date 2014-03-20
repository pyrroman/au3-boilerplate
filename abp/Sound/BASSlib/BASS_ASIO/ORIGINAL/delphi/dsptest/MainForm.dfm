object Form1: TForm1
  Left = 274
  Top = 194
  Width = 416
  Height = 125
  Caption = 'Asio DSP Example'
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
    Width = 408
    Height = 98
    Align = alClient
    TabOrder = 0
    object Open_Button: TButton
      Left = 8
      Top = 8
      Width = 393
      Height = 25
      Caption = 'Click here to open a file...'
      TabOrder = 0
      OnClick = Open_ButtonClick
    end
    object chk_Rotate: TCheckBox
      Left = 48
      Top = 56
      Width = 97
      Height = 17
      Caption = 'Rotate'
      TabOrder = 1
      OnClick = chk_RotateClick
    end
    object chk_Echo: TCheckBox
      Left = 176
      Top = 56
      Width = 97
      Height = 17
      Caption = 'Echo'
      TabOrder = 2
      OnClick = chk_EchoClick
    end
    object chk_Flanger: TCheckBox
      Left = 304
      Top = 56
      Width = 97
      Height = 17
      Caption = 'Flanger'
      TabOrder = 3
      OnClick = chk_FlangerClick
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'playable files|*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aif|All files|*.*'
    Left = 280
    Top = 8
  end
end
