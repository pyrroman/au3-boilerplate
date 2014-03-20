object Form1: TForm1
  Left = 568
  Top = 358
  BorderStyle = bsSingle
  Caption = 'Cast test'
  ClientHeight = 228
  ClientWidth = 358
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label9: TLabel
    Left = 160
    Top = 202
    Width = 47
    Height = 13
    Caption = 'Track title'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 345
    Height = 148
    Caption = 'Server'
    TabOrder = 0
    object Label1: TLabel
      Left = 200
      Top = 12
      Width = 118
      Height = 13
      Caption = 'Shoutcast = address port'
    end
    object Label2: TLabel
      Left = 200
      Top = 26
      Width = 139
      Height = 13
      Caption = 'Icecast = address port/mount'
    end
    object Label3: TLabel
      Left = 8
      Top = 46
      Width = 49
      Height = 13
      Caption = 'Password:'
    end
    object Label4: TLabel
      Left = 8
      Top = 72
      Width = 31
      Height = 13
      Caption = 'Name:'
    end
    object Label5: TLabel
      Left = 8
      Top = 98
      Width = 25
      Height = 13
      Caption = 'URL:'
    end
    object Label6: TLabel
      Left = 208
      Top = 98
      Width = 32
      Height = 13
      Caption = 'Genre:'
    end
    object Label7: TLabel
      Left = 8
      Top = 124
      Width = 56
      Height = 13
      Caption = 'Description:'
    end
    object ed_server: TEdit
      Tag = 1
      Left = 8
      Top = 16
      Width = 185
      Height = 21
      TabOrder = 0
      Text = 'localhost:8000/bass'
    end
    object ed_Password: TEdit
      Tag = 1
      Left = 64
      Top = 42
      Width = 169
      Height = 21
      TabOrder = 1
      Text = 'hackme'
    end
    object chk_public: TCheckBox
      Left = 240
      Top = 48
      Width = 100
      Height = 17
      Caption = 'Public (directory)'
      TabOrder = 2
    end
    object ed_Name: TEdit
      Tag = 1
      Left = 48
      Top = 68
      Width = 289
      Height = 21
      TabOrder = 3
      Text = 'BASSenc test stream'
    end
    object ed_url: TEdit
      Tag = 1
      Left = 40
      Top = 94
      Width = 161
      Height = 21
      TabOrder = 4
    end
    object ed_genre: TEdit
      Tag = 1
      Left = 248
      Top = 94
      Width = 89
      Height = 21
      TabOrder = 5
    end
    object ed_desc: TEdit
      Tag = 1
      Left = 72
      Top = 120
      Width = 265
      Height = 21
      TabOrder = 6
    end
  end
  object grp_Format: TGroupBox
    Left = 8
    Top = 160
    Width = 145
    Height = 60
    Caption = 'Format'
    TabOrder = 1
    object Label8: TLabel
      Left = 82
      Top = 12
      Width = 29
      Height = 13
      Caption = 'bitrate'
    end
    object chk_Mp3: TRadioButton
      Left = 8
      Top = 16
      Width = 49
      Height = 17
      Caption = 'MP3'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object chk_ogg: TRadioButton
      Left = 8
      Top = 34
      Width = 49
      Height = 17
      Caption = 'OGG'
      TabOrder = 1
    end
    object cb_Bitrate: TComboBox
      Left = 64
      Top = 30
      Width = 73
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 8
      TabOrder = 2
      Text = '128'
      Items.Strings = (
        '32'
        '40'
        '48'
        '56'
        '64'
        '80'
        '96'
        '112'
        '128'
        '160'
        '192'
        '224'
        '256'
        '320')
    end
  end
  object btn_start: TButton
    Left = 162
    Top = 168
    Width = 65
    Height = 25
    Caption = 'Start'
    TabOrder = 2
    OnClick = btn_startClick
  end
  object chk_AutoReconnect: TCheckBox
    Left = 240
    Top = 170
    Width = 97
    Height = 17
    Caption = 'Auto-reconnect'
    TabOrder = 3
    OnClick = chk_AutoReconnectClick
  end
  object ed_TrackTitle: TEdit
    Left = 216
    Top = 200
    Width = 120
    Height = 21
    Color = clBtnFace
    Enabled = False
    TabOrder = 4
    OnChange = ed_TrackTitleChange
  end
  object Pr_level: TProgressBar
    Left = 344
    Top = 166
    Width = 9
    Height = 57
    Min = 0
    Max = 32768
    Orientation = pbVertical
    Smooth = True
    TabOrder = 5
  end
  object LevelTimer: TTimer
    Enabled = False
    Interval = 50
    OnTimer = LevelTimerTimer
  end
end
