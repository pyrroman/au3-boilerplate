VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Begin VB.Form frmDSPtest 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "BASS+ASIO simple DSP test"
   ClientHeight    =   1185
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   4515
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1185
   ScaleWidth      =   4515
   StartUpPosition =   2  'CenterScreen
   Begin VB.CheckBox chkSwap 
      Caption         =   "swap"
      Height          =   315
      Left            =   3360
      TabIndex        =   4
      Top             =   720
      Width           =   855
   End
   Begin VB.CheckBox chkFlange 
      Caption         =   "flanger"
      Height          =   315
      Left            =   2280
      TabIndex        =   3
      Top             =   720
      Width           =   855
   End
   Begin VB.CheckBox chkEcho 
      Caption         =   "echo"
      Height          =   315
      Left            =   1200
      TabIndex        =   2
      Top             =   720
      Width           =   735
   End
   Begin MSComDlg.CommonDialog cmd 
      Left            =   3960
      Top             =   0
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.CheckBox chkRotate 
      Caption         =   "rotate"
      Height          =   315
      Left            =   240
      TabIndex        =   1
      Top             =   720
      Width           =   735
   End
   Begin VB.CommandButton cmdOpen 
      Caption         =   "click here to open a file..."
      Height          =   375
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   4335
   End
End
Attribute VB_Name = "frmDSPtest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'//////////////////////////////////////////////////////////////////////////
' frmDSPtest.frm - Copyright (c) 2003-2005 JOBnik! [Arthur Aminov, ISRAEL]
'                                          e-mail: jobnik@jobnik.tk
'
' Other source: modDSPtest.bas
'
' ASIO version of BASS simple DSP test
' Originally translated from - dsptest.c - Example of Ian Luck
'//////////////////////////////////////////////////////////////////////////

Option Explicit
 
'display error messages
Sub Error_(ByVal es As String)
    Call MsgBox(es & vbCrLf & vbCrLf & "Error Code: " & BASS_ErrorGetCode, vbExclamation, "Error")
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

    'not playing anything via BASS, so don't need an update thread
    Call BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD, 0)
    'initialize BASS - "no sound" device
    Call BASS_Init(0, 48000, 0, 0, 0)

    'initialize ASIO - first device
    If (BASS_ASIO_Init(0) = BASSFALSE) Then
        Call BASS_Free
        Call Error_("Can't initialize ASIO")
        Unload Me
    End If

    'only playing stereo, so may as well set that up now...
    Call BASS_ASIO_ChannelEnable(0, 0, AddressOf AsioProc_, 0) 'enable 1st output channel
    Call BASS_ASIO_ChannelJoin(0, 1, 0) 'and join the next channel to it
    'also always using floating-point, so set that up too...
    Call BASS_ASIO_ChannelSetFormat(0, 0, BASS_ASIO_FORMAT_FLOAT)

    rotdsp = 0
    echdsp = 0
    fladsp = 0
    swpdsp = 0
End Sub

Private Sub Form_Unload(Cancel As Integer)
     Call BASS_ASIO_Free
     Call BASS_Free
End Sub

'toggle "rotate"
Private Sub chkRotate_Click()
    If (chkRotate.value = vbChecked) Then
        rotpos = 0.7853981
        rotdsp = BASS_ChannelSetDSP(chan, AddressOf Rotate, 0, 3)
    Else
        Call BASS_ChannelRemoveDSP(chan, rotdsp)
    End If
End Sub

'toggle "echo"
Private Sub chkEcho_Click()
    If (chkEcho.value = vbChecked) Then
        echpos = 0
        echdsp = BASS_ChannelSetDSP(chan, AddressOf Echo, 0, 2)
    Else
        Call BASS_ChannelRemoveDSP(chan, echdsp)
    End If
End Sub

'toggle "flanger"
Private Sub chkFlange_Click()
    If (chkFlange.value = vbChecked) Then
        flapos = 0
        flas = FLABUFLEN / 2
        flasinc = 0.002
        fladsp = BASS_ChannelSetDSP(chan, AddressOf Flange, 0, 1)
    Else
        Call BASS_ChannelRemoveDSP(chan, fladsp)
    End If
End Sub

'toggle "swapper"
Private Sub chkSwap_Click()
    If (chkSwap.value = vbChecked) Then
        swpdsp = BASS_ChannelSetDSP(chan, AddressOf Swapper, 0, 0)
    Else
        Call BASS_ChannelRemoveDSP(chan, swpdsp)
    End If
End Sub

Private Sub cmdOpen_Click()
    On Local Error Resume Next    'if Cancel pressed...

    cmd.CancelError = True
    cmd.flags = cdlOFNExplorer Or cdlOFNFileMustExist Or cdlOFNHideReadOnly
    cmd.DialogTitle = "Open"
    cmd.Filter = "playable files|*.mo3;*.xm;*.mod;*.s3m;*.it;*.mtm;*.mp3;*.mp2;*.mp1;*.ogg;*.wav|All files|*.*"
    cmd.ShowOpen

    'if cancel was pressed, exit the procedure
    If Err.Number = 32755 Then Exit Sub

    'stop the ASIO device, and free both MOD and stream - it must be one of them! :)
    Call BASS_ASIO_Stop
    Call BASS_MusicFree(chan)
    Call BASS_StreamFree(chan)

    chan = BASS_StreamCreateFile(BASSFALSE, StrPtr(cmd.filename), 0, 0, BASS_SAMPLE_LOOP Or BASS_SAMPLE_FLOAT Or BASS_STREAM_DECODE)
    If (chan = 0) Then chan = BASS_MusicLoad(BASSFALSE, cmd.filename, 0, 0, BASS_MUSIC_LOOP Or BASS_MUSIC_RAMPS Or BASS_SAMPLE_FLOAT Or BASS_MUSIC_DECODE, 0)

    'whatever it is, it ain't playable
    If (chan = 0) Then
        cmdOpen.Caption = "click here to open a file..."
        Call Error_("Can't play the file")
        Exit Sub
    End If

    Dim info As BASS_CHANNELINFO
    Call BASS_ChannelGetInfo(chan, info)

    If (info.chans <> 2) Then ' only stereo is allowed
        cmdOpen.Caption = "click here to open a file..."
        Call BASS_MusicFree(chan)
        Call BASS_StreamFree(chan)
        Call Error_("only stereo sources are supported")
        Exit Sub
    End If
    
    cmdOpen.Caption = GetFileName(cmd.filename)
    
    'setup DSPs on new channel
    chkRotate_Click
    chkEcho_Click
    chkFlange_Click
    chkSwap_Click
    
    'set the ASIO sample rate
    Call BASS_ASIO_ChannelSetRate(0, 0, info.freq) 'set the output channel rate
    Call BASS_ASIO_SetRate(info.freq) 'try to set the device rate too (saves resampling)
    'start the ASIO device
    Call BASS_ASIO_Start(0)
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
