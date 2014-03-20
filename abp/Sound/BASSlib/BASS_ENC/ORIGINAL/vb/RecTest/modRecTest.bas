Attribute VB_Name = "modRecTest"
'////////////////////////////////////////////////////////////////////////////////
' modRecTest.bas - Copyright (c) 2002-2006 (: JOBnik! :) [Arthur Aminov, ISRAEL]
'                                                        [http://www.jobnik.org]
'                                                        [  jobnik@jobnik.org  ]
' Other source: frmRecTest.frm
'
' BASS Recording example
' Originally Translated from - rectest.c - Example of Ian Luck
'////////////////////////////////////////////////////////////////////////////////

Option Explicit

' encoder command-lines and output files
Public commands(2) As String    ' oggenc (OGG), lame (MP3)
Public files(3) As String       ' OGG,MP3,ACM

Public input_ As Long           ' current input source
Public encoder As Long          ' current encoder

Public acmform() As Byte        ' ACM codec format
Public acmformlen As Long       ' ACM codec format size

Public rchan As Long            ' recording/encoding channel
Public chan As Long             ' playback channel

' display error messages
Public Sub Error_(ByVal es As String)
    Call MsgBox(es & vbCrLf & vbCrLf & "error code: " & BASS_ErrorGetCode, vbExclamation, "Error")
End Sub

Public Function RecordingCallback(ByVal channel As Long, ByVal buffer As Long, ByVal length As Long, ByVal user As Long) As Long
    RecordingCallback = BASS_Encode_IsActive(channel)   ' continue recording if encoder is alive
End Function

' start recording
Public Sub StartRecording()
    ' free old recording
    If (chan) Then
        Call BASS_StreamFree(chan)
        chan = 0
        frmRecTest.btnPlay.Enabled = False
    End If
    
    ' Start recording @ 44100hz 16-bit stereo (paused to add encoder first)
    rchan = BASS_RecordStart(44100, 2, BASS_RECORD_PAUSE, AddressOf RecordingCallback, 0)
    
    If (rchan = 0) Then
        Call Error_("Couldn't start recording")
        Exit Sub
    End If

    ' start encoding
    ' get selected encoder (0=OGG, 1=MP3, 2=ACM)
    Dim i As Integer
    For i = 0 To 2
        If (frmRecTest.Options(i).value) Then encoder = i
    Next i
    
    If (encoder = 2) Then
        ' select the ACM codec
        If (BASS_Encode_GetACMFormat(rchan, VarPtr(acmform(0)), acmformlen, 0, BASS_ACM_DEFAULT) = 0 _
            Or BASS_Encode_StartACMFile(rchan, VarPtr(acmform(0)), BASS_ENCODE_AUTOFREE, files(2)) = 0) Then ' start the ACM encoder
            Call Error_("Couldn't start encoding")
            Call BASS_ChannelStop(rchan)
            rchan = 0
            Exit Sub
        End If
    ElseIf (BASS_Encode_Start(rchan, commands(encoder), BASS_ENCODE_AUTOFREE, 0, 0) = 0) Then ' start the OGG/MP3 encoder
        Call Error_("Couldn't start encoding..." & vbCrLf _
            & "Make sure OGGENC.EXE (if encoding to OGG) is in the same" & vbCrLf _
            & "direcory as this RECTEST, or LAME.EXE (if encoding to MP3).")
        Call BASS_ChannelStop(rchan)
        rchan = 0
        Exit Sub
    End If

    ' resume recoding
    Call BASS_ChannelPlay(rchan, BASSFALSE)
    frmRecTest.btnRecord.Caption = "Stop"
    frmRecTest.Options(0).Enabled = False
    frmRecTest.Options(1).Enabled = False
    frmRecTest.Options(2).Enabled = False
End Sub

' stop recording
Public Sub StopRecording()
    ' stop recording & encoding
    Call BASS_ChannelStop(rchan)
    rchan = 0

    ' create a stream from the recording
    chan = BASS_StreamCreateFile(BASSFALSE, StrPtr(files(encoder)), 0, 0, 0)
    If (chan) Then frmRecTest.btnPlay.Enabled = True          ' enable "play" button

    frmRecTest.btnRecord.Caption = "Record"
    frmRecTest.Options(0).Enabled = True
    frmRecTest.Options(1).Enabled = True
    frmRecTest.Options(2).Enabled = True
End Sub

Public Sub UpdateInputInfo()
    Dim it As Long
    Dim level As Single
    it = BASS_RecordGetInput(input_, level) ' get info on the input
    frmRecTest.sldInputLevel.value = level * 100 ' set the level slider
    
    Dim type_ As String
    Select Case (it And BASS_INPUT_TYPE_MASK)
        Case BASS_INPUT_TYPE_DIGITAL:
            type_ = "digital"
        Case BASS_INPUT_TYPE_LINE:
            type_ = "line-in"
        Case BASS_INPUT_TYPE_MIC:
            type_ = "microphone"
        Case BASS_INPUT_TYPE_SYNTH:
            type_ = "midi synth"
        Case BASS_INPUT_TYPE_CD:
            type_ = "analog cd"
        Case BASS_INPUT_TYPE_PHONE:
            type_ = "telephone"
        Case BASS_INPUT_TYPE_SPEAKER:
            type_ = "pc speaker"
        Case BASS_INPUT_TYPE_WAVE:
            type_ = "wave/pcm"
        Case BASS_INPUT_TYPE_AUX:
            type_ = "aux"
        Case BASS_INPUT_TYPE_ANALOG:
            type_ = "analog"
        Case Else:
            type_ = "undefined"
    End Select
    frmRecTest.lblInputType.Caption = type_ ' display the type
End Sub
