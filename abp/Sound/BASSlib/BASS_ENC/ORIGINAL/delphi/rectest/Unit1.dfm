object Form1: TForm1
  Left = 203
  Top = 121
  Width = 384
  Height = 97
  Caption = 'BASSenc recording to OGG/MP3/ACM Demo'
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
    Width = 376
    Height = 70
    Align = alClient
    TabOrder = 0
    object lLevel: TLabel
      Left = 11
      Top = 33
      Width = 94
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'lLevel'
    end
    object cbInput: TComboBox
      Left = 8
      Top = 8
      Width = 97
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnClick = cbInputClick
    end
    object tbLevel: TTrackBar
      Left = 7
      Top = 48
      Width = 97
      Height = 17
      Orientation = trHorizontal
      Frequency = 1
      Position = 0
      SelEnd = 0
      SelStart = 0
      TabOrder = 1
      ThumbLength = 10
      TickMarks = tmBoth
      TickStyle = tsNone
      OnChange = tbLevelChange
    end
    object gbFormat: TGroupBox
      Left = 120
      Top = 2
      Width = 105
      Height = 57
      TabOrder = 2
      object rbOGG: TRadioButton
        Left = 8
        Top = 12
        Width = 51
        Height = 17
        Caption = 'OGG'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = GetEncoder
      end
      object rbMP3: TRadioButton
        Tag = 1
        Left = 56
        Top = 12
        Width = 41
        Height = 17
        Caption = 'MP3'
        TabOrder = 1
        OnClick = GetEncoder
      end
      object rbACM: TRadioButton
        Tag = 2
        Left = 8
        Top = 32
        Width = 89
        Height = 17
        Caption = 'ACM Codec'
        TabOrder = 2
        OnClick = GetEncoder
      end
    end
    object bRecord: TButton
      Left = 232
      Top = 8
      Width = 67
      Height = 25
      Caption = 'Record'
      TabOrder = 3
      OnClick = bRecordClick
    end
    object bPlay: TButton
      Left = 304
      Top = 8
      Width = 59
      Height = 25
      Caption = 'Play'
      TabOrder = 4
      OnClick = bPlayClick
    end
    object stStatus: TStaticText
      Left = 232
      Top = 38
      Width = 133
      Height = 20
      Alignment = taCenter
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = 'stStatus'
      TabOrder = 5
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 216
    Top = 8
  end
end
