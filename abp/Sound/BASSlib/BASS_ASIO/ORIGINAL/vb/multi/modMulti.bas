Attribute VB_Name = "modMulti"
'////////////////////////////////////////////////////////////////////////
' modMulti.bas - Copyright (c) 2005 JOBnik! [Arthur Aminov, ISRAEL]
'                                   e-mail: jobnik@jobnik.tk
'
' Other source: frmMulti.frm & frmDevice.frm
'
' ASIO version of BASS multiple output example
' Originally translated from - multi.c - Example of Ian Luck
'////////////////////////////////////////////////////////////////////////

Option Explicit

'ASIO function
Function AsioProc_(ByVal input_ As Long, ByVal channel As Long, ByVal buffer As Long, ByVal length As Long, ByVal user As Long) As Long
    Dim c As Long

    c = BASS_ChannelGetData(user, ByVal buffer, length)
    If (c = -1) Then c = 0
    AsioProc_ = c
End Function
