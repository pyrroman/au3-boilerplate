#cs
/* Copyright (C) = 2000 MySQL AB

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA */

/* Error messages for MySQL clients */
/* (Error messages for the daemon are in share/language/errmsg.sys) */

//~ #ifdef	__cplusplus
//~ extern "C" {
//~ #endif
//~ void	init_client_errs(void);
//~ void	finish_client_errs(void);
//~ extern const char *client_errors[];	/* Error messages */
//~ #ifdef	__cplusplus
//~ }
//~ #endif
#ce
Global Const $CR_MIN_ERROR		= 2000	;/* For easier client code */
Global Const $CR_MAX_ERROR		= 2999
;~ #if defined(OS2) && defined(MYSQL_SERVER)
;~ Global Const $CER(X) client_errors[(X)-CR_MIN_ERROR]
;~ #elif !defined(ER)
;~ Global Const $ER(X) client_errors[(X)-CR_MIN_ERROR]
;~ #endif
;~ Global Const $CLIENT_ERRMAP		2	/* Errormap used by my_error() */

;~ /* Do not add error numbers before CR_ERROR_FIRST. */
;~ /* If necessary to add lower numbers, change CR_ERROR_FIRST accordingly. */
Global Const $CR_ERROR_FIRST  	= 2000 ;/*Copy first error nr.*/
Global Const $CR_UNKNOWN_ERROR	= 2000
Global Const $CR_SOCKET_CREATE_ERROR	= 2001
Global Const $CR_CONNECTION_ERROR	= 2002
Global Const $CR_CONN_HOST_ERROR	= 2003
Global Const $CR_IPSOCK_ERROR		= 2004
Global Const $CR_UNKNOWN_HOST		= 2005
Global Const $CR_SERVER_GONE_ERROR	= 2006
Global Const $CR_VERSION_ERROR	= 2007
Global Const $CR_OUT_OF_MEMORY	= 2008
Global Const $CR_WRONG_HOST_INFO	= 2009
Global Const $CR_LOCALHOST_CONNECTION = 2010
Global Const $CR_TCP_CONNECTION	= 2011
Global Const $CR_SERVER_HANDSHAKE_ERR = 2012
Global Const $CR_SERVER_LOST		= 2013
Global Const $CR_COMMANDS_OUT_OF_SYNC = 2014
Global Const $CR_NAMEDPIPE_CONNECTION = 2015
Global Const $CR_NAMEDPIPEWAIT_ERROR  = 2016
Global Const $CR_NAMEDPIPEOPEN_ERROR  = 2017
Global Const $CR_NAMEDPIPESETSTATE_ERROR = 2018
Global Const $CR_CANT_READ_CHARSET	= 2019
Global Const $CR_NET_PACKET_TOO_LARGE = 20= 20
Global Const $CR_EMBEDDED_CONNECTION	= 2021
Global Const $CR_PROBE_SLAVE_STATUS   = 2022
Global Const $CR_PROBE_SLAVE_HOSTS    = 2023
Global Const $CR_PROBE_SLAVE_CONNECT  = 2024
Global Const $CR_PROBE_MASTER_CONNECT = 2025
Global Const $CR_SSL_CONNECTION_ERROR = 2026
Global Const $CR_MALFORMED_PACKET     = 2027
Global Const $CR_WRONG_LICENSE	= 2028

;~ /* new 4.1 error codes */
Global Const $CR_NULL_POINTER		= 2029
Global Const $CR_NO_PREPARE_STMT	= 2030
Global Const $CR_PARAMS_NOT_BOUND	= 2031
Global Const $CR_DATA_TRUNCATED	= 2032
Global Const $CR_NO_PARAMETERS_EXISTS = 2033
Global Const $CR_INVALID_PARAMETER_NO = 2034
Global Const $CR_INVALID_BUFFER_USE	= 2035
Global Const $CR_UNSUPPORTED_PARAM_TYPE = 2036

Global Const $CR_SHARED_MEMORY_CONNECTION             = 2037
Global Const $CR_SHARED_MEMORY_CONNECT_REQUEST_ERROR  = 2038
Global Const $CR_SHARED_MEMORY_CONNECT_ANSWER_ERROR   = 2039
Global Const $CR_SHARED_MEMORY_CONNECT_FILE_MAP_ERROR = 2040
Global Const $CR_SHARED_MEMORY_CONNECT_MAP_ERROR      = 2041
Global Const $CR_SHARED_MEMORY_FILE_MAP_ERROR         = 2042
Global Const $CR_SHARED_MEMORY_MAP_ERROR              = 2043
Global Const $CR_SHARED_MEMORY_EVENT_ERROR     	= 2044
Global Const $CR_SHARED_MEMORY_CONNECT_ABANDONED_ERROR = 2045
Global Const $CR_SHARED_MEMORY_CONNECT_SET_ERROR      = 2046
Global Const $CR_CONN_UNKNOW_PROTOCOL 		= 2047
Global Const $CR_INVALID_CONN_HANDLE			= 2048
Global Const $CR_SECURE_AUTH                          = 2049
Global Const $CR_FETCH_CANCELED                       = 2050
Global Const $CR_NO_DATA                              = 2051
Global Const $CR_NO_STMT_METADATA                     = 2052
Global Const $CR_NO_RESULT_SET                        = 2053
Global Const $CR_NOT_IMPLEMENTED                      = 2054
Global Const $CR_SERVER_LOST_EXTENDED			= 2055
Global Const $CR_ERROR_LAST    = 2055 ; /*Copy last error nr:*/
;~ /* Add error numbers before CR_ERROR_LAST and change it accordingly. */

