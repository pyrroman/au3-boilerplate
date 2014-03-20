VERSION 5.00
Begin VB.Form frmCast 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Cast test"
   ClientHeight    =   3375
   ClientLeft      =   600
   ClientTop       =   990
   ClientWidth     =   5415
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   225
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   361
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox picLevelBar 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00C0C0C0&
      ForeColor       =   &H80000008&
      Height          =   770
      Left            =   5160
      ScaleHeight     =   49
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   6
      TabIndex        =   24
      Top             =   2520
      Width           =   120
   End
   Begin VB.Frame frameServer 
      Caption         =   " Server "
      Height          =   2175
      Left            =   120
      TabIndex        =   5
      Top             =   120
      Width           =   5175
      Begin VB.TextBox txtDescription 
         Height          =   315
         Left            =   1080
         TabIndex        =   22
         Top             =   1680
         Width           =   3975
      End
      Begin VB.TextBox txtGenre 
         Height          =   315
         Left            =   3600
         TabIndex        =   20
         Top             =   1320
         Width           =   1455
      End
      Begin VB.TextBox txtURL 
         Height          =   315
         Left            =   600
         TabIndex        =   18
         Top             =   1320
         Width           =   2295
      End
      Begin VB.TextBox txtName 
         Height          =   315
         Left            =   720
         TabIndex        =   16
         Text            =   "BASSenc test stream"
         Top             =   960
         Width           =   4335
      End
      Begin VB.TextBox txtPassword 
         Height          =   315
         Left            =   960
         TabIndex        =   14
         Text            =   "hackme"
         Top             =   600
         Width           =   2415
      End
      Begin VB.TextBox txtServer 
         Height          =   315
         Left            =   120
         TabIndex        =   6
         Text            =   "localhost:8000/bass"
         Top             =   240
         Width           =   2775
      End
      Begin VB.CheckBox chkPublic 
         Caption         =   "Public (directory)"
         Height          =   255
         Left            =   3480
         TabIndex        =   15
         Top             =   630
         Width           =   1575
      End
      Begin VB.Label lblDescription 
         AutoSize        =   -1  'True
         Caption         =   "Description:"
         Height          =   195
         Left            =   120
         TabIndex        =   23
         Top             =   1755
         Width           =   840
      End
      Begin VB.Label lblGenre 
         AutoSize        =   -1  'True
         Caption         =   "Genre:"
         Height          =   195
         Left            =   3000
         TabIndex        =   21
         Top             =   1400
         Width           =   480
      End
      Begin VB.Label lblURL 
         AutoSize        =   -1  'True
         Caption         =   "URL:"
         Height          =   195
         Left            =   120
         TabIndex        =   19
         Top             =   1395
         Width           =   375
      End
      Begin VB.Label lblName 
         AutoSize        =   -1  'True
         Caption         =   "Name:"
         Height          =   195
         Left            =   120
         TabIndex        =   17
         Top             =   1035
         Width           =   465
      End
      Begin VB.Label lblPassword 
         AutoSize        =   -1  'True
         Caption         =   "Password:"
         Height          =   195
         Left            =   120
         TabIndex        =   13
         Top             =   680
         Width           =   735
      End
      Begin VB.Label lblServer 
         AutoSize        =   -1  'True
         Caption         =   "Icecast = address:port/mount"
         Height          =   195
         Index           =   1
         Left            =   3000
         TabIndex        =   12
         Top             =   390
         Width           =   2085
      End
      Begin VB.Label lblServer 
         AutoSize        =   -1  'True
         Caption         =   "Shoutcast = address:port"
         Height          =   195
         Index           =   0
         Left            =   3000
         TabIndex        =   11
         Top             =   200
         Width           =   1770
      End
   End
   Begin VB.CheckBox chkReconnect 
      Caption         =   "Auto-reconnect"
      Height          =   255
      Left            =   3360
      TabIndex        =   9
      Top             =   2520
      Width           =   1695
   End
   Begin VB.Frame frameFormat 
      Caption         =   " Format "
      Height          =   900
      Left            =   120
      TabIndex        =   3
      Top             =   2400
      Width           =   2175
      Begin VB.ComboBox cmbBitrate 
         Height          =   315
         Left            =   960
         Style           =   2  'Dropdown List
         TabIndex        =   8
         Top             =   480
         Width           =   1095
      End
      Begin VB.OptionButton Options 
         Caption         =   "OGG"
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   4
         Top             =   560
         Width           =   700
      End
      Begin VB.OptionButton Options 
         Caption         =   "MP3"
         Height          =   210
         Index           =   0
         Left            =   120
         TabIndex        =   0
         Top             =   280
         Value           =   -1  'True
         Width           =   825
      End
      Begin VB.Label lblBitrate 
         Alignment       =   2  'Center
         Caption         =   "bitrate"
         Height          =   195
         Left            =   960
         TabIndex        =   7
         Top             =   240
         Width           =   1035
      End
   End
   Begin VB.Timer tmrCast 
      Interval        =   50
      Left            =   4680
      Top             =   2880
   End
   Begin VB.TextBox txtTrack 
      BackColor       =   &H8000000F&
      Enabled         =   0   'False
      Height          =   315
      Left            =   3240
      TabIndex        =   2
      TabStop         =   0   'False
      Top             =   2950
      Width           =   1815
   End
   Begin VB.CommandButton btnStart 
      Caption         =   "Start"
      Height          =   300
      Left            =   2400
      TabIndex        =   1
      Top             =   2520
      Width           =   855
   End
   Begin VB.Label lblTrack 
      AutoSize        =   -1  'True
      Caption         =   "Track title:"
      Height          =   195
      Left            =   2400
      TabIndex        =   10
      Top             =   3000
      Width           =   750
   End
End
Attribute VB_Name = "frmCast"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'////////////////////////////////////////////////////////////////////////
' frmCast.frm - Copyright (c) 2006 (: JOBnik! :) [Arthur Aminov, ISRAEL]
'                                                [http://www.jobnik.org]
'                                                [  jobnik@jobnik.org  ]
' Other source: modCast.bas
'
' BASSenc Cast example
' Originally Translated from - cast.c - Example of Ian Luck
'////////////////////////////////////////////////////////////////////////

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

    ' setup default recording device
    If (BASS_RecordInit(-1) = 0) Then
        Call Error_("Can't initialize device")
        End
    Else
        Dim c As Integer
        bitrates = Array(32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320)  ' available bitrates

        txtServer.Text = "localhost:8000/bass"
        txtPassword.Text = "hackme"
        txtName.Text = "BASSenc test stream"
        Options(0).value = True ' set default encoder to MP3

        For c = 0 To 13
            cmbBitrate.AddItem bitrates(c)
        Next c
        cmbBitrate.ListIndex = 8    ' default bitrate = 128kbps
        tmrCast.Interval = 50  ' timer to update the level display and listener count
    End If
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ' release all BASS stuff
    Call BASS_RecordFree
End Sub

Private Sub btnStart_Click()
    If (rchan = 0) Then
        Call Start
    Else
        Call Stop_
    End If
End Sub

Private Sub tmrCast_Timer()
    ' draw the level bar
    Static level As Long
    level = IIf(level > 1500, level - 1500, 0)
    If (rchan) Then
        Dim l As Long
        l = BASS_ChannelGetLevel(rchan) ' get current level
        If (LoWord(l) > level) Then level = LoWord(l)
        If (HiWord(l) > level) Then level = HiWord(l)
    End If
    picLevelBar.Cls
    picLevelBar.Line (picLevelBar.Width, picLevelBar.Height)-(0, picLevelBar.Height * (32768 - level) / 32768), vbWhite, BF:
    ' check number of listeners
    Static updatelisten As Integer
    updatelisten = updatelisten + 1
    If ((updatelisten Mod 100) = 0) Then ' only checking once every 5 seconds
        Dim stats As String, listeners As Integer, t As Integer
        listeners = 0
        stats = VBStrFromAnsiPtr(BASS_Encode_CastGetStats(encoder, BASS_ENCODE_STATS_ICE, vbNullString))
        If (stats <> "") Then
            t = InStr(1, stats, "<Listeners>")  ' Icecast listener count
            If (t <> 0) Then listeners = Val(Mid(stats, t + 11))
        Else
            stats = VBStrFromAnsiPtr(BASS_Encode_CastGetStats(encoder, BASS_ENCODE_STATS_SHOUT, vbNullString))
            If (stats <> "") Then
                t = InStr(1, stats, "<CURRENTLISTENERS>")   ' Shoutcast listener count
                If (t <> 0) Then listeners = Val(Mid(stats, t + 18))
            Else
                Exit Sub
            End If
        End If
        Me.Caption = "Cast test (" & listeners & " listeners)"
    End If
End Sub

Private Sub txtTrack_Change()
    Call BASS_Encode_CastSetTitle(encoder, txtTrack.Text, vbNullString)
End Sub
