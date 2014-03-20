Attribute VB_Name = "BASSASIO"
' BASSASIO 1.0 Visual Basic module
' Copyright (c) 2005-2009 Un4seen Developments Ltd.
'
' See the BASSASIO.CHM file for more detailed documentation

Global Const BASSASIOVERSION = &H100    'API version

' error codes returned by BASS_ASIO_ErrorGetCode
Global Const BASS_OK = 0                 ' all is OK
Global Const BASS_ERROR_DRIVER = 3       ' can't find a free/valid driver
Global Const BASS_ERROR_FORMAT = 6       ' unsupported sample format
Global Const BASS_ERROR_INIT = 8         ' BASS_ASIO_Init has not been successfully called
Global Const BASS_ERROR_START = 9        ' BASS_ASIO_Start has/hasn't been called
Global Const BASS_ERROR_ALREADY = 14     ' already initialized/started
Global Const BASS_ERROR_NOCHAN = 18      ' no channels are enabled
Global Const BASS_ERROR_ILLPARAM = 20    ' an illegal parameter was specified
Global Const BASS_ERROR_DEVICE = 23      ' illegal device number
Global Const BASS_ERROR_NOTAVAIL = 37    ' not available
Global Const BASS_ERROR_UNKNOWN = -1     ' some other mystery error

' device info structure
Type BASS_ASIO_DEVICEINFO
        name As Long          ' description
        driver As Long        ' driver
End Type

Type BASS_ASIO_INFO
        name_ As String * 32  'driver name
        version As Long       'driver version
        inputs As Long        'number of inputs
        outputs As Long       'number of outputs
        bufmin As Long        'minimum buffer length
        bufmax As Long        'maximum buffer length
        bufpref As Long       'preferred/default buffer length
        bufgran As Long       'buffer length granularity
End Type

Type BASS_ASIO_CHANNELINFO
        group As Long
        format_ As Long       'sample format (BASS_ASIO_FORMAT_xxx)
        name_ As String * 32  'channel name
End Type

' sample formats
Global Const BASS_ASIO_FORMAT_16BIT = 16 '16-bit integer
Global Const BASS_ASIO_FORMAT_24BIT = 17 '24-bit integer
Global Const BASS_ASIO_FORMAT_32BIT = 18 '32-bit integer
Global Const BASS_ASIO_FORMAT_FLOAT = 19 '32-bit floating-point

' BASS_ASIO_ChannelReset flags
Global Const BASS_ASIO_RESET_ENABLE = 1  'disable channel
Global Const BASS_ASIO_RESET_JOIN = 2    'unjoin channel
Global Const BASS_ASIO_RESET_PAUSE = 4   'unpause channel
Global Const BASS_ASIO_RESET_FORMAT = 8  'reset sample format to native format
Global Const BASS_ASIO_RESET_RATE = 16   'reset sample rate to device rate
Global Const BASS_ASIO_RESET_VOLUME = 32 'reset volume to 1.0

' BASS_ASIO_ChannelIsActive return values
Global Const BASS_ASIO_ACTIVE_DISABLED = 0
Global Const BASS_ASIO_ACTIVE_ENABLED = 1
Global Const BASS_ASIO_ACTIVE_PAUSED = 2

// driver notifications
Global Const BASS_ASIO_NOTIFY_RATE = 1   'sample rate change
Global Const BASS_ASIO_NOTIFY_RESET = 2  'reset (reinitialization) request


Declare Function BASS_ASIO_GetVersion Lib "bassasio.dll" () As Long
Declare Function BASS_ASIO_ErrorGetCode Lib "bassasio.dll" () As Long
Declare Function BASS_ASIO_GetDeviceInfo Lib "bassasio.dll" (ByVal device As Long, ByRef info As BASS_ASIO_DEVICEINFO) As Long
Declare Function BASS_ASIO_SetDevice Lib "bassasio.dll" (ByVal device As Long) As Long
Declare Function BASS_ASIO_GetDevice Lib "bassasio.dll" () As Long
Declare Function BASS_ASIO_Init Lib "bassasio.dll" (ByVal device As Long) As Long
Declare Function BASS_ASIO_Free Lib "bassasio.dll" () As Long
Declare Function BASS_ASIO_SetNotify Lib "bassasio.dll" (ByVal proc As Long, ByVal user As Long) As Long
Declare Function BASS_ASIO_ControlPanel Lib "bassasio.dll" () As Long
Declare Function BASS_ASIO_GetInfo Lib "bassasio.dll" (ByRef info As BASS_ASIO_INFO) As Long
Declare Function BASS_ASIO_SetRate Lib "bassasio.dll" (ByVal rate_ As Double) As Long
Declare Function BASS_ASIO_GetRate Lib "bassasio.dll" () As Double
Declare Function BASS_ASIO_Start Lib "bassasio.dll" (ByVal buflen As Long) As Long
Declare Function BASS_ASIO_Stop Lib "bassasio.dll" () As Long
Declare Function BASS_ASIO_IsStarted Lib "bassasio.dll" () As Long
Declare Function BASS_ASIO_GetLatency Lib "bassasio.dll" (ByVal input_ As Long) As Long
Declare Function BASS_ASIO_GetCPU Lib "bassasio.dll" () As Single
Declare Function BASS_ASIO_Monitor Lib "bassasio.dll" (ByVal input_ As Long, ByVal output_ As Long, ByVal gain As Long, ByVal state As Long, ByVal pan As Long) As Long

Declare Function BASS_ASIO_ChannelGetInfo Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long, ByRef info As BASS_ASIO_CHANNELINFO) As Long
Declare Function BASS_ASIO_ChannelReset Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long, ByVal flags As Long) As Long
Declare Function BASS_ASIO_ChannelEnable Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long, ByVal proc As Long, ByVal user As Long) As Long
Declare Function BASS_ASIO_ChannelEnableMirror Lib "bassasio.dll" (ByVal channel As Long, ByVal input2 As Long, ByVal channel2 As Long) As Long
Declare Function BASS_ASIO_ChannelJoin Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long, ByVal channel2 As Long) As Long
Declare Function BASS_ASIO_ChannelPause Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long) As Long
Declare Function BASS_ASIO_ChannelIsActive Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long) As Long
Declare Function BASS_ASIO_ChannelSetFormat Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long, ByVal format_ As Long) As Long
Declare Function BASS_ASIO_ChannelGetFormat Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long) As Long
Declare Function BASS_ASIO_ChannelSetRate Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long, ByVal rate_ As Double) As Long
Declare Function BASS_ASIO_ChannelGetRate Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long) As Double
Declare Function BASS_ASIO_ChannelSetVolume Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long, ByVal volume As Single) As Long
Declare Function BASS_ASIO_ChannelGetVolume Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long) As Single
Declare Function BASS_ASIO_ChannelGetLevel Lib "bassasio.dll" (ByVal input_ As Long, ByVal channel As Long) As Single


Function ASIOPROC(ByVal input_ As Long, ByVal channel As Long, ByVal buffer As Long, ByVal length As Long, ByVal user As Long) As Long
    
    'CALLBACK FUNCTION !!!
    
    ' User stream callback function
    ' input_ : Input? else output
    ' channel: Channel number
    ' buffer : Buffer containing the sample data
    ' length : Number of bytes
    ' user   : The 'user' parameter given when calling BASS_ASIO_ChannelEnable
    ' RETURN : The number of bytes written (ignored with input channels)
    
End Function

Function ASIONOTIFYPROC(ByVal notify As Long, ByVal user As Long) As Long
    
    'CALLBACK FUNCTION !!!
    
    ' Driver notification callback function.
    ' notify : The notification (BASS_ASIO_NOTIFY_xxx)
    ' user   : The 'user' parameter given when calling BASS_ASIO_SetNotify
    
End Function
