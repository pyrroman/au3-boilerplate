VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmRecTest 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "BASSenc recording to OGG/MP3/ACM test"
   ClientHeight    =   990
   ClientLeft      =   600
   ClientTop       =   990
   ClientWidth     =   5625
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   990
   ScaleWidth      =   5625
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   780
      Left            =   1680
      TabIndex        =   7
      Top             =   80
      Width           =   1575
      Begin VB.OptionButton Options 
         Caption         =   "ACM WAVE"
         Height          =   255
         Index           =   2
         Left            =   120
         TabIndex        =   9
         Top             =   480
         Width           =   1275
      End
      Begin VB.OptionButton Options 
         Caption         =   "MP3"
         Height          =   255
         Index           =   1
         Left            =   840
         TabIndex        =   8
         Top             =   200
         Width           =   700
      End
      Begin VB.OptionButton Options 
         Caption         =   "OGG"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   2
         Top             =   200
         Value           =   -1  'True
         Width           =   700
      End
   End
   Begin MSComctlLib.Slider sldInputLevel 
      Height          =   255
      Left            =   120
      TabIndex        =   1
      Top             =   720
      Width           =   1455
      _ExtentX        =   2566
      _ExtentY        =   450
      _Version        =   393216
      Max             =   100
      SelectRange     =   -1  'True
      TickStyle       =   3
   End
   Begin VB.ComboBox cmbInput 
      Height          =   315
      Left            =   120
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   160
      Width           =   1455
   End
   Begin MSComDlg.CommonDialog cmd 
      Left            =   4680
      Top             =   600
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.Timer tmrRecTest 
      Interval        =   200
      Left            =   4320
      Top             =   600
   End
   Begin VB.TextBox txtVR 
      Alignment       =   2  'Center
      BackColor       =   &H8000000F&
      Height          =   285
      Left            =   3360
      Locked          =   -1  'True
      TabIndex        =   5
      TabStop         =   0   'False
      Top             =   600
      Width           =   2175
   End
   Begin VB.CommandButton btnPlay 
      Caption         =   "Play"
      Enabled         =   0   'False
      Height          =   300
      Left            =   4680
      TabIndex        =   4
      Top             =   170
      Width           =   855
   End
   Begin VB.CommandButton btnRecord 
      Caption         =   "Record"
      Height          =   300
      Left            =   3360
      TabIndex        =   3
      Top             =   170
      Width           =   1215
   End
   Begin VB.Label lblInputType 
      Alignment       =   2  'Center
      Height          =   195
      Left            =   120
      TabIndex        =   6
      Top             =   480
      Width           =   1440
   End
End
Attribute VB_Name = "frmRecTest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'////////////////////////////////////////////////////////////////////////////////
' frmRecTest.frm - Copyright (c) 2002-2006 (: JOBnik! :) [Arthur Aminov, ISRAEL]
'                                                        [http://www.jobnik.org]
'                                                        [  jobnik@jobnik.org  ]
' Other source: modRecTest.bas
'
' BASS Recording example
' Originally Translated from - rectest.c - Example of Ian Luck
'////////////////////////////////////////////////////////////////////////////////

Option Explicit

Private Sub Form_Load()
    ' change and set the current path, to prevent from VB not finding BASS.DLL
    ChDrive App.Path
    ChDir App.Path

    ' check the correct BASS was loaded
    If (HiWord(BASS_GetVersion) <> BASSVERSION) Then
        Call MsgBox("An incorrect version of BASS.DLL was loaded", vbCritical)
        End
    End If

    ' setup recording and output devices (using default devices)
    If (BASS_RecordInit(-1) = 0) Or (BASS_Init(-1, 44100, 0, Me.hWnd, 0) = 0) Then
        Call Error_("Can't initialize device")
        End
    Else
        ' get list of inputs
        Dim c As Integer
        input_ = -1
        While BASS_RecordGetInputName(c)
            cmbInput.AddItem VBStrFromAnsiPtr(BASS_RecordGetInputName(c))
            If (BASS_RecordGetInput(c, ByVal 0) And BASS_INPUT_OFF) = 0 Then
                cmbInput.ListIndex = c  ' this 1 is currently "on"
                input_ = c
                Call UpdateInputInfo    ' display info
            End If
            c = c + 1
        Wend
    End If
    
    ' Set command-lines and output files
    commands(0) = "oggenc.exe -o bass.ogg -"                    ' oggenc (OGG)
    commands(1) = "lame.exe --alt-preset standard - bass.mp3"   ' lame (MP3)

    ' OGG, MP3, ACM
    files(0) = "bass.ogg"
    files(1) = "bass.mp3"
    files(2) = "bass.wav"

    ' allocate ACM format buffer, using suggested buffer size
    acmformlen = BASS_Encode_GetACMFormat(0, ByVal 0&, 0, 0, 0)
    ReDim acmform(acmformlen) As Byte
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ' release all BASS stuff
    Call BASS_RecordFree
    Call BASS_Free
    Erase acmform
End Sub

' input selection changed
Private Sub cmbInput_Click()
    If (input_ > -1) Then
        input_ = cmbInput.ListIndex
        ' enable the selected input
        Dim i As Integer
        For i = 0 To cmbInput.ListCount - 1
            Call BASS_RecordSetInput(i, BASS_INPUT_OFF, -1) ' 1st disable all inputs, then...
        Next i
        Call BASS_RecordSetInput(input_, BASS_INPUT_ON, -1) ' enable the selected input
        Call UpdateInputInfo
    End If
End Sub

Private Sub btnPlay_Click()
    Call BASS_ChannelPlay(chan, BASSTRUE) ' play the recorded data
End Sub

Private Sub btnRecord_Click()
    If (rchan = 0) Then
        Call StartRecording
    Else
        Call StopRecording
    End If
End Sub

' set input source level
Private Sub sldInputLevel_Scroll()
    Call BASS_RecordSetInput(input_, 0, sldInputLevel.value / 100)
End Sub

' update the recording/playback counter
Private Sub tmrRecTest_Timer()
    If (rchan) Then '  recording/encoding
        txtVR.Text = BASS_ChannelGetPosition(rchan, BASS_POS_BYTE)
    ElseIf (chan) Then
        If (BASS_ChannelIsActive(chan)) Then  ' playing
            txtVR.Text = BASS_ChannelGetPosition(chan, BASS_POS_BYTE) & " / " & BASS_ChannelGetLength(chan, BASS_POS_BYTE)
        Else
            txtVR.Text = BASS_ChannelGetLength(chan, BASS_POS_BYTE)
        End If
    End If
End Sub
