Attribute VB_Name = "modLiveFX"
'/////////////////////////////////////////////////////////////////////////
' modLiveFX.bas - Copyright (c) 2002-2005 JOBnik! [Arthur Aminov, ISRAEL]
'                                         e-mail: jobnik@jobnik.tk
'
' Other source: frmLiveFX.frm
'
' BASS ASIO version of full-duplex test
' Originally translated from - livefx.c - Example of Ian Luck
'/////////////////////////////////////////////////////////////////////////

Option Explicit

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (ByRef Destination As Any, ByRef Source As Any, ByVal length As Long)

Public fxchan As Long   'FX stream
Public fx(4) As Long    'FX handles
Public input_ As Long   'current input source

'display error message
Public Sub Error_(ByVal es As String)
    Call MsgBox(es & vbCrLf & vbCrLf & "Error Code: " & BASS_ASIO_ErrorGetCode & " " & BASS_ErrorGetCode, vbExclamation, "Error")
End Sub

Function AsioProc_(ByVal input_ As Long, ByVal channel As Long, ByVal buffer As Long, ByVal length As Long, ByVal user As Long) As Long
    Static buf(100000) As Single 'input buffer - 100000 should be enough :)
    If (input_) Then
        Call CopyMemory(buf(0), ByVal buffer, length)
    Else
        Call CopyMemory(ByVal buffer, buf(0), length)
        Call BASS_ChannelGetData(fxchan, ByVal buffer, length) 'apply FX
    End If
    AsioProc_ = length
End Function

Static Function Initialize() As Boolean
    'not playing anything via BASS, so don't need an update thread
    Call BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD, 0)
    'init BASS (for the FX)
    Call BASS_Init(0, 44100, 0, 0, 0)

    'init ASIO - first device
    If (BASS_ASIO_Init(0) = 0) Then
        Call BASS_Free
        Call Error_("Can't initialize ASIO")
        Initialize = False
        Exit Function
    End If

    'get list of inputs (assuming channels are all ordered in left/right pairs)
    Dim c As Integer
    Dim i As BASS_ASIO_CHANNELINFO, i2 As BASS_ASIO_CHANNELINFO
    Do While BASS_ASIO_ChannelGetInfo(1, c, i)
        Dim name_ As String
        If (BASS_ASIO_ChannelGetInfo(1, c + 1, i2) = 0) Then Exit Do 'no "right" channel
        name_ = Mid(i.name_, 1, InStr(1, i.name_, String(1, 0)) - 1)
        name_ = name_ & " + " & Mid(i2.name_, 1, InStr(1, i2.name_, String(1, 0)) - 1)
        frmLiveFX.cmbSelChange.AddItem name_
        Call BASS_ASIO_ChannelJoin(1, c + 1, c) 'join the pair of channels
        c = c + 2
    Loop

    'create a dummy stream to apply FX
    fxchan = BASS_StreamCreate(BASS_ASIO_GetRate(), 2, BASS_SAMPLE_FLOAT Or BASS_STREAM_DECODE, STREAMPROC_DUMMY, 0)

    'enable first inputs
    Call BASS_ASIO_ChannelEnable(1, input_, AddressOf AsioProc_, 0)
    'enable first outputs
    Call BASS_ASIO_ChannelEnable(0, 0, AddressOf AsioProc_, 0)
    Call BASS_ASIO_ChannelJoin(0, 1, 0)
    'set input and output to floating-point
    Call BASS_ASIO_ChannelSetFormat(1, input_, BASS_ASIO_FORMAT_FLOAT)
    Call BASS_ASIO_ChannelSetFormat(0, 0, BASS_ASIO_FORMAT_FLOAT)
    ' start with output volume at 0 (in case of nasty feedback)
    Call BASS_ASIO_ChannelSetVolume(0, 0, 0)
    Call BASS_ASIO_ChannelSetVolume(0, 1, 0)
    'start it (using default buffer size)
    If (BASS_ASIO_Start(0) = 0) Then
        Call BASS_ASIO_Free
        Call BASS_Free
        Call Error_("Can't initialize recording device")
        Initialize = False
        Exit Function
    End If

    'display total (input+output) latency
    frmLiveFX.lblLatency.Caption = CInt(((BASS_ASIO_GetLatency(BASSFALSE) + BASS_ASIO_GetLatency(BASSTRUE)) * 1000 / BASS_ASIO_GetRate()))

    If (frmLiveFX.cmbSelChange.ListCount) Then frmLiveFX.cmbSelChange.ListIndex = 0

    Initialize = True
End Function
