VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmLiveFX 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "BASS+ASIO full-duplex recording test with effects"
   ClientHeight    =   795
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   5865
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   795
   ScaleWidth      =   5865
   StartUpPosition =   2  'CenterScreen
   Begin VB.CheckBox chkFlanger 
      Caption         =   "Flanger"
      Height          =   195
      Left            =   4800
      TabIndex        =   7
      Top             =   480
      Width           =   975
   End
   Begin VB.CheckBox chkReverb 
      Caption         =   "Reverb"
      Height          =   195
      Left            =   4800
      TabIndex        =   6
      Top             =   120
      Width           =   975
   End
   Begin VB.CheckBox chkGargle 
      Caption         =   "Gargle"
      Height          =   195
      Left            =   3720
      TabIndex        =   5
      Top             =   480
      Width           =   975
   End
   Begin VB.CheckBox chkChorus 
      Caption         =   "Chorus"
      Height          =   195
      Left            =   3720
      TabIndex        =   4
      Top             =   120
      Width           =   975
   End
   Begin VB.ComboBox cmbSelChange 
      Height          =   315
      Left            =   120
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   120
      Width           =   2415
   End
   Begin MSComctlLib.Slider sLevel 
      Height          =   315
      Left            =   0
      TabIndex        =   1
      Top             =   480
      Width           =   2535
      _ExtentX        =   4471
      _ExtentY        =   556
      _Version        =   393216
      Max             =   100
      TickStyle       =   3
   End
   Begin VB.Label lblLatency 
      Alignment       =   2  'Center
      BorderStyle     =   1  'Fixed Single
      Height          =   315
      Left            =   2640
      TabIndex        =   3
      Top             =   315
      Width           =   885
   End
   Begin VB.Label lblLtc 
      Alignment       =   2  'Center
      AutoSize        =   -1  'True
      Caption         =   "latency"
      Height          =   195
      Left            =   2640
      TabIndex        =   2
      Top             =   45
      Width           =   885
   End
End
Attribute VB_Name = "frmLiveFX"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'/////////////////////////////////////////////////////////////////////////
' frmLiveFX.frm - Copyright (c) 2002-2005 JOBnik! [Arthur Aminov, ISRAEL]
'                                         e-mail: jobnik@jobnik.tk
'
' Other source: modLiveFX.bas
'
' BASS ASIO version of full-duplex test
' Originally translated from - livefx.c - Example of Ian Luck
'/////////////////////////////////////////////////////////////////////////

Option Explicit

Private Sub chkChorus_Click()
    If (fx(0)) Then
        Call BASS_ChannelRemoveFX(fxchan, fx(0))
        fx(0) = 0
    Else
        fx(0) = BASS_ChannelSetFX(fxchan, BASS_FX_DX8_CHORUS, 0)
    End If
End Sub

Private Sub chkGargle_Click()
    If (fx(1)) Then
        Call BASS_ChannelRemoveFX(fxchan, fx(1))
        fx(1) = 0
    Else
        fx(1) = BASS_ChannelSetFX(fxchan, BASS_FX_DX8_GARGLE, 0)
    End If
End Sub

Private Sub chkReverb_Click()
    If (fx(2)) Then
        Call BASS_ChannelRemoveFX(fxchan, fx(2))
        fx(2) = 0
    Else
        fx(2) = BASS_ChannelSetFX(fxchan, BASS_FX_DX8_REVERB, 0)
    End If
End Sub

Private Sub chkFlanger_Click()
    If (fx(3)) Then
        Call BASS_ChannelRemoveFX(fxchan, fx(3))
        fx(3) = 0
    Else
        fx(3) = BASS_ChannelSetFX(fxchan, BASS_FX_DX8_FLANGER, 0)
    End If
End Sub

'input selection changed
Private Sub cmbSelChange_Click()
    Dim i As Integer

    Call BASS_ASIO_Stop   'stop ASIO processing
    Call BASS_ASIO_ChannelEnable(1, input_, 0, 0) 'disable old inputs
    input_ = cmbSelChange.ListIndex * 2 'get the selection
    Call BASS_ASIO_ChannelEnable(1, input_, AddressOf AsioProc_, 0) 'enable new inputs
    Call BASS_ASIO_ChannelSetFormat(1, input_, BASS_ASIO_FORMAT_FLOAT)
    Call BASS_ASIO_Start(0) 'resume ASIO processing
End Sub

Private Sub Form_Load()
    'change and set the current path
    'so VB won't ever tell you, that "bass.dll" isn't found
    ChDrive App.Path
    ChDir App.Path
    
    'check if "bass.dll" is exists
    If (Not FileExists(RPP(App.Path) & "bass.dll")) Then
        Call MsgBox("BASS.DLL does not exists", vbCritical, "BASS.DLL")
        End
    End If
    
    ' check the correct BASS was loaded
    If (HiWord(BASS_GetVersion) <> BASSVERSION) Then
        Call MsgBox("An incorrect version of BASS.DLL was loaded", vbCritical)
        End
    End If

    Call MsgBox("Do not set the input to 'WAVE' / 'What you hear' (etc...) with" & vbCrLf & _
                "the level set high, as that is likely to result in nasty feedback.", vbExclamation, "Feedback warning")
                
    If (Not Initialize) Then Unload Me
End Sub

'set input level
Private Sub sLevel_Scroll()
    Dim level As Single
    level = sLevel.value / 100#
    Call BASS_ASIO_ChannelSetVolume(0, 0, level) ' set left output level
    Call BASS_ASIO_ChannelSetVolume(0, 1, level) ' set right output level
End Sub

Private Sub Form_Unload(Cancel As Integer)
    'release it all
    Call BASS_ASIO_Free
    Call BASS_Free
End Sub

'--------------------------
' some useful functions :)
'--------------------------

'check if any file exists
Public Function FileExists(ByVal fp As String) As Boolean
    FileExists = (Dir(fp) <> "")
End Function

'RPP = Return Proper Path
Function RPP(ByVal fp As String) As String
    RPP = IIf(Mid(fp, Len(fp), 1) <> "\", fp & "\", fp)
End Function

'get file name from file path
Public Function GetFileName(ByVal fp As String) As String
    GetFileName = Mid(fp, InStrRev(fp, "\") + 1)
End Function
