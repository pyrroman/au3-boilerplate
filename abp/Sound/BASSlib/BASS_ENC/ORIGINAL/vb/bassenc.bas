Attribute VB_Name = "BASSenc"
' BASSenc 2.4 Visual Basic module
' Copyright (c) 2003-2009 Un4seen Developments Ltd.
'
' See the BASSENC.CHM file for more detailed documentation

' Additional error codes returned by BASS_ErrorGetCode
Global Const BASS_ERROR_ACM_CANCEL = 2000  ' ACM codec selection cancelled
Global Const BASS_ERROR_CAST_DENIED = 2100 ' access denied (invalid password)

' Additional BASS_SetConfig options
Global Const BASS_CONFIG_ENCODE_PRIORITY = &H10300
Global Const BASS_CONFIG_ENCODE_CAST_TIMEOUT = &H10310

' Additional BASS_SetConfigPtr options
Global Const BASS_CONFIG_ENCODE_CAST_PROXY = &H10311

' BASS_Encode_Start flags
Global Const BASS_ENCODE_NOHEAD = 1    ' do NOT send a WAV header to the encoder
Global Const BASS_ENCODE_FP_8BIT = 2   ' convert floating-point sample data to 8-bit integer
Global Const BASS_ENCODE_FP_16BIT = 4  ' convert floating-point sample data to 16-bit integer
Global Const BASS_ENCODE_FP_24BIT = 6  ' convert floating-point sample data to 24-bit integer
Global Const BASS_ENCODE_FP_32BIT = 8  ' convert floating-point sample data to 32-bit integer
Global Const BASS_ENCODE_BIGEND = 16   ' big-endian sample data
Global Const BASS_ENCODE_PAUSE = 32    ' start encording paused
Global Const BASS_ENCODE_PCM = 64      ' write PCM sample data (no encoder)
Global Const BASS_ENCODE_RF64 = 128    ' send an RF64 header
Global Const BASS_ENCODE_AUTOFREE = &H40000 ' free the encoder when the channel is freed

' BASS_Encode_GetACMFormat flags
Global Const BASS_ACM_DEFAULT = 1      ' use the format as default selection
Global Const BASS_ACM_RATE = 2         ' only list formats with same sample rate as the source channel
Global Const BASS_ACM_CHANS = 4        ' only list formats with same number of channels (eg. mono/stereo)
Global Const BASS_ACM_SUGGEST = 8      ' suggest a format (HIWORD=format tag)

' BASS_Encode_GetCount counts
Global Const BASS_ENCODE_COUNT_IN = 0  ' sent to encoder
Global Const BASS_ENCODE_COUNT_OUT = 1 ' received from encoder
Global Const BASS_ENCODE_COUNT_CAST = 2 ' sent to cast server

' BASS_Encode_CastInit content MIME types
Global Const BASS_ENCODE_TYPE_MP3 = "audio/mpeg"
Global Const BASS_ENCODE_TYPE_OGG = "application/ogg"
Global Const BASS_ENCODE_TYPE_AAC = "audio/aacp"

' BASS_Encode_CastGetStats types
Global Const BASS_ENCODE_STATS_SHOUT = 0    ' Shoutcast stats
Global Const BASS_ENCODE_STATS_ICE = 1      ' Icecast mount-point stats
Global Const BASS_ENCODE_STATS_ICESERV = 2  ' Icecast server stats

' Encoder notifications
Global Const BASS_ENCODE_NOTIFY_ENCODER = 1 ' encoder died
Global Const BASS_ENCODE_NOTIFY_CAST = 2    ' cast server connection died
Global Const BASS_ENCODE_NOTIFY_CAST_TIMEOUT = &H10000 ' cast timeout

Declare Function BASS_Encode_GetVersion Lib "bassenc.dll" () As Long

Declare Function BASS_Encode_Start Lib "bassenc.dll" (ByVal chan As Long, ByVal cmdline As String, ByVal flags As Long, ByVal proc As Long, ByVal user As Long) As Long
Declare Function BASS_Encode_StartLimit Lib "bassenc.dll" (ByVal chan As Long, ByVal cmdline As String, ByVal flags As Long, ByVal proc As Long, ByVal user As Long, ByVal limit As Long) As Long
Declare Function BASS_Encode_AddChunk Lib "bassenc.dll" (ByVal handle As Long, ByVal id As String, ByVal buffer As Long, ByVal length As Long) As Long
Declare Function BASS_Encode_IsActive Lib "bassenc.dll" (ByVal chan As Long) As Long
Declare Function BASS_Encode_Stop Lib "bassenc.dll" (ByVal chan As Long) As Long
Declare Function BASS_Encode_SetPaused Lib "bassenc.dll" (ByVal chan As Long, ByVal paused As Long) As Long
Declare Function BASS_Encode_Write Lib "bassenc.dll" (ByVal handle As Long, ByVal buffer As Long, ByVal length As Long) As Long
Declare Function BASS_Encode_SetNotify Lib "bassenc.dll" (ByVal handle As Long, ByVal proc As Long, ByVal user As Long) As Long
Declare Function BASS_Encode_GetCount Lib "bassenc.dll" (ByVal handle As Long, ByVal count As Long) As Long
Declare Function BASS_Encode_SetChannel Lib "bassenc.dll" (ByVal handle As Long, ByVal channel As Long) As Long
Declare Function BASS_Encode_GetChannel Lib "bassenc.dll" (ByVal handle As Long) As Long

Declare Function BASS_Encode_GetACMFormat Lib "bassenc.dll" (ByVal chan As Long, ByVal form As Any, ByVal formlen As Long, ByVal title As String, ByVal flags As Long) As Long
Declare Function BASS_Encode_StartACM Lib "bassenc.dll" (ByVal chan As Long, ByVal form As Any, ByVal flags As Long, ByVal proc As Long, ByVal user As Long) As Long
Declare Function BASS_Encode_StartACMFile Lib "bassenc.dll" (ByVal chan As Long, ByVal form As Any, ByVal flags As Long, ByVal filename As String) As Long

Declare Function BASS_Encode_CastInit Lib "bassenc.dll" (ByVal handle As Long, ByVal server As String, ByVal pass As String, ByVal content As String, ByVal name As String, ByVal url As String, ByVal genre As String, ByVal desc As String, ByVal headers As String, ByVal bitrate As Long, ByVal pub As Long) As Long
Declare Function BASS_Encode_CastSetTitle Lib "bassenc.dll" (ByVal handle As Long, ByVal title As String, ByVal url As String) As Long
Declare Function BASS_Encode_CastGetStats Lib "bassenc.dll" (ByVal handle As Long, ByVal stype As Long, ByVal pass As String) As Long


Sub ENCODEPROC(ByVal handle As Long, ByVal channel As Long, ByVal buffer As Long, ByVal length As Long, ByVal user As Long)
    
    ' CALLBACK FUNCTION !!!

    ' Encoding callback function.
    ' handle : The encoder
    ' channel: The channel handle
    ' buffer : Buffer containing the encoded data
    ' length : Number of bytes
    ' user   : The 'user' parameter value given when calling BASS_EncodeStart
    
End Sub

Sub ENCODENOTIFYPROC(ByVal handle As Long, ByVal status As Long, ByVal user As Long)
    
    ' CALLBACK FUNCTION !!!

    ' Encoder death notification callback function.
    ' handle : The encoder
    ' status : Notification (BASS_ENCODE_NOTIFY_xxx)
    ' user   : The 'user' parameter value given when calling BASS_Encode_SetNotify

End Sub
