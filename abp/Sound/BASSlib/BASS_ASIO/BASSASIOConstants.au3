#include-once

Global Const $BASSASIOVERSION = 0x100 		;API version

;error codes returned by BASS_ASIO_ErrorGetCode
#cs
Global Const $BASS_OK = 0 					;all is OK
Global Const $BASS_ERROR_DRIVER = 3 		;can't find a free/valid driver
Global Const $BASS_ERROR_FORMAT = 6 		;unsupported sample format
Global Const $BASS_ERROR_INIT = 8 			;BASS_ASIO_Init has not been successfully called
Global Const $BASS_ERROR_START = 9 			;BASS_ASIO_Start has/hasn't been called
Global Const $BASS_ERROR_ALREADY = 14 		;already initialized/started
Global Const $BASS_ERROR_NOCHAN = 18 		;no channels are enabled
Global Const $BASS_ERROR_ILLPARAM = 20 		;an illegal parameter was specified
Global Const $BASS_ERROR_DEVICE = 23 		;illegal device number
Global Const $BASS_ERROR_NOTAVAIL = 37 		;not available
Global Const $BASS_ERROR_UNKNOWN = -1 		;some other mystery error
#ce

;sample formats
Global Const $BASS_ASIO_FORMAT_16BIT = 16 	;16-bit integer
Global Const $BASS_ASIO_FORMAT_24BIT = 17 	;24-bit integer
Global Const $BASS_ASIO_FORMAT_32BIT = 18 	;32-bit integer
Global Const $BASS_ASIO_FORMAT_FLOAT = 19 	;32-bit floating-point

;BASS_ASIO_ChannelReset flags
Global Const $BASS_ASIO_RESET_ENABLE = 1 	;disable channel
Global Const $BASS_ASIO_RESET_JOIN = 2 		;unjoin channel
Global Const $BASS_ASIO_RESET_PAUSE = 4 	;unpause channel
Global Const $BASS_ASIO_RESET_FORMAT = 8 	;reset sample format to native format
Global Const $BASS_ASIO_RESET_RATE = 16 	;reset sample rate to device rate
Global Const $BASS_ASIO_RESET_VOLUME = 32 	;reset volume to 1.0

;BASS_ASIO_ChannelIsActive return values
Global Const $BASS_ASIO_ACTIVE_DISABLED = 0
Global Const $BASS_ASIO_ACTIVE_ENABLED = 1
Global Const $BASS_ASIO_ACTIVE_PAUSED = 2

;device info structure
Global Const $BASS_ASIO_DEVICEINFO = 'ptr;' & _		;description
		'ptr;' ;driver

Global Const $BASS_ASIO_INFO = 'char[31];' & _			;driver name
		'dword;' & _									;driver version
		'dword;' & _									;inputs
		'dword;' & _									;outputs
		'dword;' & _									;bufmin
		'dword;' & _									;bufmax
		'dword;' & _									;bufpref
		'int;' ;bufgran

Global Const $BASS_ASIO_CHANNELINFO = 'dword;' & _ 		;Group
		'dword;' & _									;sample format (BASS_ASIO_FORMAT_xxx)
		'char[31];' ;channel name