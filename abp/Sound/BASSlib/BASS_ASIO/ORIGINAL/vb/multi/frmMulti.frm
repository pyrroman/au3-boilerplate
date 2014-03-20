VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Begin VB.Form frmMulti 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "BASS+ASIO multiple output example"
   ClientHeight    =   1515
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   4575
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1515
   ScaleWidth      =   4575
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame frameMulti 
      Height          =   735
      Index           =   0
      Left            =   120
      TabIndex        =   0
      Top             =   0
      Width           =   4335
      Begin VB.CommandButton cmdOpen 
         Caption         =   "click here to open a file..."
         Height          =   375
         Index           =   0
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Width           =   4095
      End
   End
   Begin MSComDlg.CommonDialog cmd 
      Left            =   3960
      Top             =   960
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.Frame frameMulti 
      Height          =   735
      Index           =   1
      Left            =   120
      TabIndex        =   2
      Top             =   720
      Width           =   4335
      Begin VB.CommandButton cmdOpen 
         Caption         =   "click here to open a file..."
         Height          =   375
         Index           =   1
         Left            =   120
         TabIndex        =   3
         Top             =   240
         Width           =   4095
      End
   End
End
Attribute VB_Name = "frmMulti"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'////////////////////////////////////////////////////////////////////////
' frmMulti.frm - Copyright (c) 2003-2005 JOBnik! [Arthur Aminov, ISRAEL]
'                                        e-mail: jobnik@jobnik.tk
'
' Other source: frmDevice.frm & modMulti.bas
'
' ASIO version of BASS multiple output example
' Originally translated from - multi.c - Example of Ian Luck
'////////////////////////////////////////////////////////////////////////
 
Option Explicit

Dim outdev(2) As Long   'output devices
Dim chan(2) As Long     'the streams

'display error messages
Sub Error_(ByVal es As String)
    Call MsgBox(es & vbCrLf & vbCrLf & "(error code: " & BASS_ErrorGetCode & "/" & BASS_ASIO_ErrorGetCode & ")", vbExclamation, "Error")
End Sub

Private Sub Form_Load()
    'change and set the current path
    'so it won't ever tell you, that "bass.dll" isn't found
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

    'check if "bassasio.dll" is exists
    If (Not FileExists(RPP(App.Path) & "bassasio.dll")) Then
        Call MsgBox("BASSASIO.DLL does not exists", vbCritical, "BASSASIO.DLL")
        End
    End If

    'let the user choose the output devices
    With frmDevice
        .SelectDevice 1
        .Show vbModal, Me
        outdev(0) = .device
        .SelectDevice 2
        .Show vbModal, Me
        outdev(1) = .device
    End With

    'not playing anything via BASS, so don't need an update thread
    Call BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD, 0)

    'initialize BASS - "no sound" device
    Call BASS_Init(0, 48000, 0, 0, 0)

    'initialize ASIO devices
    If (BASS_ASIO_Init(outdev(0)) = 0) Then
        Call Error_("Can't initialize device 1")
        Unload Me
    End If
    If (BASS_ASIO_Init(outdev(1)) = 0) Then
        Call Error_("Can't initialize device 2")
        Unload Me
    End If

    With frameMulti
        Dim i As BASS_ASIO_DEVICEINFO
        Call BASS_ASIO_GetDeviceInfo(outdev(0), i)
        .Item(0).Caption = " " & VBStrFromAnsiPtr(i.name) & " "
        Call BASS_ASIO_GetDeviceInfo(outdev(1), i)
        .Item(1).Caption = " " & VBStrFromAnsiPtr(i.name) & " "
    End With
End Sub

Private Sub Form_Unload(Cancel As Integer)
    'release both ASIO devices and BASS
    Call BASS_ASIO_Free
    Call BASS_ASIO_Free
    Call BASS_Free
    End
End Sub

Private Sub cmdOpen_Click(index As Integer)
    On Local Error Resume Next    'if Cancel pressed...

    'open a file to play on selected device
    cmd.CancelError = True
    cmd.flags = cdlOFNExplorer Or cdlOFNFileMustExist Or cdlOFNHideReadOnly
    cmd.DialogTitle = "Open"
    cmd.Filter = "streamable files|*.mp3;*.mp2;*.mp1;*.ogg;*.wav|All files|*.*"
    cmd.ShowOpen

    'if cancel was pressed, exit the procedure
    If Err.Number = 32755 Then Exit Sub

    Call BASS_ASIO_SetDevice(outdev(index)) 'set the ASIO device to work with
    Call BASS_ASIO_Stop   'stop the device
        Call BASS_ASIO_ChannelReset(0, -1, BASS_ASIO_RESET_ENABLE Or BASS_ASIO_RESET_JOIN) 'disable & unjoin all output channels

    Call BASS_StreamFree(chan(index))

    chan(index) = BASS_StreamCreateFile(BASSFALSE, StrPtr(cmd.filename), 0, 0, BASS_SAMPLE_LOOP Or BASS_SAMPLE_FLOAT Or BASS_STREAM_DECODE)

    If (chan(index) = 0) Then
        cmdOpen(index).Caption = "click here to open a file..."
        Call Error_("Can't play the file")
        Exit Sub
    End If

    cmdOpen(index).Caption = GetFileName(cmd.filename)
    'start ASIO output
    Dim i As BASS_CHANNELINFO, a As Long
    Call BASS_ChannelGetInfo(chan(index), i)
    Call BASS_ASIO_ChannelEnable(0, 0, AddressOf AsioProc_, chan(index)) 'enable 1st output channel...
    For a = 1 To i.chans - 1
        Call BASS_ASIO_ChannelJoin(0, a, 0) 'and join the next channels to it
    Next a
    Call BASS_ASIO_ChannelSetFormat(0, 0, BASS_ASIO_FORMAT_FLOAT) 'set the source format (float)
    Call BASS_ASIO_ChannelSetRate(0, 0, i.freq) 'set the channel sample rate
    Call BASS_ASIO_SetRate(i.freq) 'try to set the device rate too (saves resampling)
    If (BASS_ASIO_Start(0) = 0) Then 'start output using default buffer/latency
        Call Error_("Can't start ASIO output")
    End If
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
