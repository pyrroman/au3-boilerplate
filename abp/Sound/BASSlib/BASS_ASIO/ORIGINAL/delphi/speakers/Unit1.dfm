object Form1: TForm1
  Left = 411
  Top = 235
  Width = 492
  Height = 259
  Caption = 'Bass Asio Speaker Example'
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
    Width = 484
    Height = 232
    Align = alClient
    TabOrder = 0
    object GroupBox0: TGroupBox
      Left = 8
      Top = 8
      Width = 465
      Height = 49
      Enabled = False
      TabOrder = 0
      object lblStatus1: TLabel
        Left = 408
        Top = 14
        Width = 30
        Height = 26
        Alignment = taCenter
        Caption = 'Status'#13#10'Empty'
        WordWrap = True
      end
      object Button1: TButton
        Tag = 10
        Left = 8
        Top = 16
        Width = 273
        Height = 25
        Caption = 'click here to open a file ...'
        Enabled = False
        TabOrder = 0
        OnClick = OpenFile
      end
      object btnStatus1: TButton
        Left = 312
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Play / Stop'
        Enabled = False
        TabOrder = 1
        OnClick = SetStatus
      end
    end
    object GroupBox1: TGroupBox
      Tag = 1
      Left = 8
      Top = 64
      Width = 465
      Height = 49
      Enabled = False
      TabOrder = 1
      object lblStatus2: TLabel
        Left = 408
        Top = 14
        Width = 30
        Height = 26
        Alignment = taCenter
        Caption = 'Status'#13#10'Empty'
        WordWrap = True
      end
      object Button2: TButton
        Tag = 11
        Left = 8
        Top = 16
        Width = 273
        Height = 25
        Caption = 'click here to open a file ...'
        Enabled = False
        TabOrder = 0
        OnClick = OpenFile
      end
      object btnStatus2: TButton
        Tag = 1
        Left = 312
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Play / Stop'
        Enabled = False
        TabOrder = 1
        OnClick = SetStatus
      end
    end
    object GroupBox2: TGroupBox
      Tag = 2
      Left = 8
      Top = 120
      Width = 465
      Height = 49
      Enabled = False
      TabOrder = 2
      object lblStatus3: TLabel
        Left = 408
        Top = 14
        Width = 30
        Height = 26
        Alignment = taCenter
        Caption = 'Status'#13#10'Empty'
        WordWrap = True
      end
      object Button3: TButton
        Tag = 12
        Left = 8
        Top = 16
        Width = 273
        Height = 25
        Caption = 'click here to open a file ...'
        Enabled = False
        TabOrder = 0
        OnClick = OpenFile
      end
      object btnStatus3: TButton
        Tag = 2
        Left = 312
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Play / Stop'
        Enabled = False
        TabOrder = 1
        OnClick = SetStatus
      end
    end
    object GroupBox3: TGroupBox
      Tag = 3
      Left = 8
      Top = 176
      Width = 465
      Height = 49
      Enabled = False
      TabOrder = 3
      object lblStatus4: TLabel
        Left = 408
        Top = 14
        Width = 30
        Height = 26
        Alignment = taCenter
        Caption = 'Status'#13#10'Empty'
        WordWrap = True
      end
      object Button4: TButton
        Tag = 13
        Left = 8
        Top = 16
        Width = 273
        Height = 25
        Caption = 'click here to open a file ...'
        Enabled = False
        TabOrder = 0
        OnClick = OpenFile
      end
      object btnStatus4: TButton
        Tag = 3
        Left = 312
        Top = 16
        Width = 75
        Height = 25
        Caption = 'Play / Stop'
        Enabled = False
        TabOrder = 1
        OnClick = SetStatus
      end
    end
    object btnSwap1: TButton
      Tag = 20
      Left = 288
      Top = 52
      Width = 41
      Height = 25
      Caption = 'Swap'
      Enabled = False
      TabOrder = 4
      OnClick = OpenFile
    end
    object btnSwap2: TButton
      Tag = 21
      Left = 288
      Top = 108
      Width = 41
      Height = 25
      Caption = 'Swap'
      Enabled = False
      TabOrder = 5
      OnClick = OpenFile
    end
    object btnSwap3: TButton
      Tag = 22
      Left = 288
      Top = 164
      Width = 41
      Height = 25
      Caption = 'Swap'
      Enabled = False
      TabOrder = 6
      OnClick = OpenFile
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'Streamable Files|*.mp3;*.mp2;*.mp1;*.ogg;*.wav;*.aif|All Files|*.*'
    Options = [ofReadOnly, ofHideReadOnly, ofEnableSizing]
  end
end
