Attribute VB_Name = "modCast"
'////////////////////////////////////////////////////////////////////////
' modCast.bas - Copyright (c) 2006 (: JOBnik! :) [Arthur Aminov, ISRAEL]
'                                                [http://www.jobnik.org]
'                                                [  jobnik@jobnik.org  ]
' Other source: frmCast.frm
'
' BASSenc Cast example
' Originally Translated from - cast.c - Example of Ian Luck
'////////////////////////////////////////////////////////////////////////

Option Explicit

Public input_ As Long           ' current input source
Public rchan As Long            ' recording/encoding channel
Public encoder As Long

Public bitrates() As Variant    ' available bitrates

Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Public Declare Function MessageBox Lib "user32" Alias "MessageBoxA" (ByVal hwnd As Long, ByVal lpText As String, ByVal lpCaption As String, ByVal wType As Long) As Long

' display error messages
Public Sub Error_(ByVal es As String)
    Call MsgBox(es & vbCrLf & vbCrLf & "error code: " & BASS_ErrorGetCode, vbExclamation, "Error")
End Sub

Public Function RecordingCallback(ByVal handle As Long, ByVal buffer As Long, ByVal length As Long, ByVal user As Long) As Long
    RecordingCallback = BASS_Encode_IsActive(handle)   ' continue recording if encoder is alive
End Function

' encoder death notification
Public Sub EncoderNotify(ByVal handle As Long, ByVal status As Long, ByVal user As Long)
    If (status < &H10000) Then ' encoder/connection died
        Call Stop_ ' free the recording and encoder
        If (frmCast.chkReconnect.value) Then    ' auto-reconnect...
            frmCast.btnStart.Enabled = False
            Call Sleep(1000) ' wait a sec
            Call Start
            frmCast.btnStart.Enabled = True
        Else
            Call MessageBox(frmCast.hwnd, IIf(status = BASS_ENCODE_NOTIFY_CAST, "The server connection died!", "The encoder died!"), "Error", 0)
        End If
    End If
End Sub

Public Sub Start()
    Dim com As String, server As String, pass As String, name As String, url As String, genre As String, _
        desc As String, content As String
    Dim bitrate As Long, pub As Long

    ' start recording @ 44100hz 16-bit stereo (paused to setup encoder first)
    rchan = BASS_RecordStart(44100, 2, BASS_RECORD_PAUSE, AddressOf RecordingCallback, 0)
    
    If (rchan = 0) Then
        Call Error_("Couldn't start recording")
        Exit Sub
    End If
    
    With frmCast
        bitrate = bitrates(.cmbBitrate.ListIndex) ' get bitrate
        ' setup encoder command-line (raw PCM data to avoid length limit)
        If (.Options(0).value) Then  ' MP3
            com = "lame -r -x -s 44100 -b " & bitrate & " -"
            content = BASS_ENCODE_TYPE_MP3
        Else  ' OGG
            com = "oggenc -r -R 44100 -b " & bitrate & " -m 16 -"
            content = BASS_ENCODE_TYPE_OGG
        End If
        encoder = BASS_Encode_Start(rchan, com, BASS_ENCODE_NOHEAD Or BASS_ENCODE_AUTOFREE, 0, 0) ' start the encoder
        If (encoder = 0) Then
            Call Error_("Couldn't start encoding..." & vbCrLf & _
                "Make sure OGGENC.EXE (if encoding to OGG) is in the same" & vbCrLf & _
                "direcory as this RECTEST, or LAME.EXE (if encoding to MP3).")
            Call BASS_ChannelStop(rchan)
            rchan = 0
            Exit Sub
        End If
        ' setup cast
        server = .txtServer.Text
        pass = .txtPassword.Text
        name = .txtName.Text
        url = .txtURL.Text
        genre = .txtGenre.Text
        desc = .txtDescription.Text
        pub = .chkPublic.value
        If (BASS_Encode_CastInit(encoder, server, pass, content, name, url, genre, desc, vbNullString, bitrate, pub) = 0) Then
            Call Error_("Couldn't setup connection with server")
            Call BASS_ChannelStop(rchan)
            rchan = 0
            Exit Sub
        End If
        Call BASS_ChannelPlay(rchan, False) ' resume recording
        .btnStart.Caption = "Stop"
        Call EnableControl(.txtServer, False, True)
        Call EnableControl(.txtPassword, False, True)
        Call EnableControl(.chkPublic, False, False)
        Call EnableControl(.txtName, False, True)
        Call EnableControl(.txtURL, False, True)
        Call EnableControl(.txtGenre, False, True)
        Call EnableControl(.txtDescription, False, True)
        Call EnableControl(.Options(0), False, False)
        Call EnableControl(.Options(1), False, False)
        Call EnableControl(.cmbBitrate, False, True)
        Call EnableControl(.txtTrack, True, True)
        Call BASS_Encode_SetNotify(encoder, AddressOf EncoderNotify, 0) ' notify of dead encoder/connection
    End With
End Sub

Public Sub Stop_()
    ' stop recording & encoding
    Call BASS_ChannelStop(rchan)
    rchan = 0
    With frmCast
        .btnStart.Caption = "Start"
        Call EnableControl(.txtServer, True, True)
        Call EnableControl(.txtPassword, True, True)
        Call EnableControl(.chkPublic, True, False)
        Call EnableControl(.txtName, True, True)
        Call EnableControl(.txtURL, True, True)
        Call EnableControl(.txtGenre, True, True)
        Call EnableControl(.txtDescription, True, True)
        Call EnableControl(.Options(0), True, False)
        Call EnableControl(.Options(1), True, False)
        Call EnableControl(.cmbBitrate, True, True)
        Call EnableControl(.txtTrack, False, True)
        .Caption = "Cast test"
    End With
End Sub

Public Sub EnableControl(ByVal ctrl As Control, ByVal enable As Boolean, ByVal changecol As Boolean)
    ctrl.Enabled = enable
    If (changecol) Then ctrl.BackColor = IIf(enable, vbWhite, vbButtonFace)
End Sub
