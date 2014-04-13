#cs
	;/* Copyright (C) 2000-2003 MySQL AB

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

	;/*
	This file defines the client API to MySQL and also the ABI of the
	dynamically linked libmysqlclient.

	The ABI should never be changed in a released product of MySQL
	thus you need to take great care when changing the file. In case
	the file is changed so the ABI is broken, you must also
	update the SHAREDLIB_MAJOR_VERSION in configure.in .

	*/
#ce
;===================================================================================
;
; Script:   MySQL UDFs working with libmysql.dll
; Version:  1.0.0.2
; Author:   Prog@ndy
;
; YOU ARE NOT ALLOWED TO REMOVE THIS INFORMATION
;===================================================================================
#include-once
;~ #include "my_alloc.au3"
#include "mysql_version.au3"
#include "mysql_com.au3"
#include "MySQL_errmsg.au3"

Global Const $MYSQL_SUCCESS = 0
Global Const $MYSQL_OK = 0
Global Const $MYSQL_ERROR = True

; Prog@ndy
Func __MySQL_SIZEOF($tagStruct)
	Return DllStructGetSize(DllStructCreate($tagStruct, 1))
EndFunc   ;==>__MySQL_SIZEOF

Global Const $CLIENT_NET_READ_TIMEOUT = 365 * 24 * 3600 ;/* Timeout on read */
Global Const $CLIENT_NET_WRITE_TIMEOUT = 365 * 24 * 3600 ;/* Timeout on write */


;~ Global Const $IS_PRI_KEY(n)	((n) & PRI_KEY_FLAG)
;~ Global Const $IS_NOT_NULL(n)	((n) & NOT_NULL_FLAG)
;~ Global Const $IS_BLOB(n)	((n) & BLOB_FLAG)
;~ Global Const $IS_NUM(t)	((t) <= FIELD_TYPE_INT24 || (t) == FIELD_TYPE_YEAR || (t) == FIELD_TYPE_NEWDECIMAL)
;~ Global Const $IS_NUM_FIELD(f)	 ((f)->flags & NUM_FLAG)
;~ Global Const $INTERNAL_NUM_FIELD(f) (((f)->type <= FIELD_TYPE_INT24 && ((f)->type != FIELD_TYPE_TIMESTAMP || (f)->length == 14 || (f)->length == 8)) || (f)->type == FIELD_TYPE_YEAR)
;~ Global Const $IS_LONGDATA(t) ((t) >= MYSQL_TYPE_TINY_BLOB && (t) <= MYSQL_TYPE_STRING)
Func IS_PRI_KEY($n)
	Return (BitAND($n, $PRI_KEY_FLAG) = $PRI_KEY_FLAG)
EndFunc   ;==>IS_PRI_KEY
Func IS_NOT_NULL($n)
	Return (BitAND($n, $NOT_NULL_FLAG) = $NOT_NULL_FLAG)
EndFunc   ;==>IS_NOT_NULL
Func IS_BLOB($n)
	Return (BitAND($n, $BLOB_FLAG) = $BLOB_FLAG)
EndFunc   ;==>IS_BLOB
Func IS_NUM($t)
	Return ($t <= $MYSQL_TYPE_INT24 Or $t == $MYSQL_TYPE_YEAR Or $t == $MYSQL_TYPE_NEWDECIMAL)
EndFunc   ;==>IS_NUM
Func IS_NUM_FIELD(ByRef $f)
	Return (BitAND(DllStructGetData($f, "type"), $NUM_FLAG) = $NUM_FLAG)
EndFunc   ;==>IS_NUM_FIELD
Func INTERNAL_NUM_FIELD(ByRef $f)
	Local $type = DllStructGetData($f, "type")
	Return ($type <= $MYSQL_TYPE_INT24 And ($type <> $MYSQL_TYPE_TIMESTAMP Or DllStructGetData($f, "length") == 14 Or DllStructGetData($f, "length") == 8 Or $type = $MYSQL_TYPE_YEAR))
EndFunc   ;==>INTERNAL_NUM_FIELD
Func IS_LONGDATA($t)
	Return ($t >= $MYSQL_TYPE_TINY_BLOB And $t <= $MYSQL_TYPE_STRING)
EndFunc   ;==>IS_LONGDATA

;~ typedef struct st_mysql_field {
Global Const $st_mysql_field = _
		"ptr name;" & _                 ;/* Name of column */ [[char *
		"ptr orgName;" & _             ;/* Original column name, if an alias */ [[char *
		"ptr table;" & _                ;/* Table of column if column was a field */ [[char *
		"ptr orgTable;" & _            ;/* Org table name, if table was an alias */ [[char *
		"ptr db;" & _                   ;/* Database for table */ [[char *
		"ptr catalog;" & _	      ;/* Catalog for table */ [[char *
		"ptr def;" & _                  ;/* Default value (set by mysql_list_fields) */ [[char *
		"ulong length;" & _       ;/* Width of column (create length) */
		"ulong maxLength;" & _   ;/* Max width for selected set */
		"uint nameLength;" & _
		"uint orgNameLength;" & _
		"uint tableLength;" & _
		"uint orgTableLength;" & _
		"uint dbLength;" & _
		"uint catalogLength;" & _
		"uint defLength;" & _
		"uint flags;" & _         ;/* Div flags */
		"uint decimals;" & _      ;/* Number of decimals in field */
		"uint charsetnr;" & _     ;/* Character set */
		"int type;" & _ ;/* Type of field. See mysql_com.h for types */
		"ptr extension;"
;~ } MYSQL_FIELD;
Global Const $MYSQL_FIELD = $st_mysql_field

;~ typedef char **MYSQL_ROW;		;/* return data as array of strings */
Global Const $MYSQL_ROW = "ptr";		;/* return data as array of strings */
;~ typedef unsigned int MYSQL_FIELD_OFFSET; ;/* offset to current field */

;~ Global Const $MYSQL_COUNT_ERROR (~(my_ulonglong) 0)

;/* backward compatibility define - to be removed eventually */
;~ Global Const $ER_WARN_DATA_TRUNCATED = $WARN_DATA_TRUNCATED

Global Const $st_mysql_rows = _
		"ptr next;" & _		;/* list of rows */
		$MYSQL_ROW & " data;" & _
		"unsigned long length;"
Global Const $MYSQL_ROWS = $st_mysql_rows;

;~ typedef MYSQL_ROWS *MYSQL_ROW_OFFSET;	;/* offset to current row */

;~ typedef struct embedded_query_result EMBEDDED_QUERY_RESULT;
;~ typedef struct st_mysql_data {
;~ Global Const $st_mysql_data = _
;~ 		"uint64 rows;" & _
;~ 		"uint fields;" & _
;~ 		"ptr data;" & _
;~ 		"byte alloc[" & __MySQL_SIZEOF($MEM_ROOT) & "];" & _ ;MEM_ROOT alloc;
;~ 		"" & _ ;/* extra info for embedded library */
;~ 		"ptr embedded_info;" ;struct embedded_query_result *embedded_info;
;~ } MYSQL_DATA;

;~ enum mysql_option
Global Enum _
		$MYSQL_OPT_CONNECT_TIMEOUT, $MYSQL_OPT_COMPRESS, $MYSQL_OPT_NAMED_PIPE, _
		$MYSQL_INIT_COMMAND, $MYSQL_READ_DEFAULT_FILE, $MYSQL_READ_DEFAULT_GROUP, _
		$MYSQL_SET_CHARSET_DIR, $MYSQL_SET_CHARSET_NAME, $MYSQL_OPT_LOCAL_INFILE, _
		$MYSQL_OPT_PROTOCOL, $MYSQL_SHARED_MEMORY_BASE_NAME, $MYSQL_OPT_READ_TIMEOUT, _
		$MYSQL_OPT_WRITE_TIMEOUT, $MYSQL_OPT_USE_RESULT, _
		$MYSQL_OPT_USE_REMOTE_CONNECTION, $MYSQL_OPT_USE_EMBEDDED_CONNECTION, _
		$MYSQL_OPT_GUESS_CONNECTION, $MYSQL_SET_CLIENT_IP, $MYSQL_SECURE_AUTH, _
		$MYSQL_REPORT_DATA_TRUNCATION, $MYSQL_OPT_RECONNECT, _
		$MYSQL_OPT_SSL_VERIFY_SERVER_CERT
#cs
	struct st_mysql_options {
	unsigned int connect_timeout, read_timeout, write_timeout;
	unsigned int port, protocol;
	unsigned long client_flag;
	char *host,*user,*password,*unix_socket,*db;
	struct st_dynamic_array *init_commands;
	char *my_cnf_file,*my_cnf_group, *charset_dir, *charset_name;
	char *ssl_key;				;/* PEM key file */
	char *ssl_cert;				;/* PEM cert file */
	char *ssl_ca;					;/* PEM CA file */
	char *ssl_capath;				;/* PEM directory of CA-s? */
	char *ssl_cipher;				;/* cipher to use */
	char *shared_memory_base_name;
	unsigned long max_allowed_packet;
	my_bool use_ssl;				;/* if to use SSL or not */
	my_bool compress,named_pipe;
	;/*
	On connect, find out the replication role of the server, and
	establish connections to all the peers
	*/
	my_bool rpl_probe;
	;/*
	Each call to mysql_real_query() will parse it to tell if it is a read
	or a write, and direct it to the slave or the master
	*/
	my_bool rpl_parse;
	;/*
	If set, never read from a master, only from slave, when doing
	a read that is replication-aware
	*/
	my_bool no_master_reads;
	#if !defined(CHECK_EMBEDDED_DIFFERENCES) || defined(EMBEDDED_LIBRARY)
	my_bool separate_thread;
	#endif
	enum mysql_option methods_to_use;
	char *client_ip;
	;/* Refuse client connecting to server if it uses old (pre-4.1.1) protocol */
	my_bool secure_auth;
	;/* 0 - never report, 1 - always report (default) */
	my_bool report_data_truncation;

	;/* function pointers for local infile support */
	int (*local_infile_init)(void **, const char *, void *);
	int (*local_infile_read)(void *, char *, unsigned int);
	void (*local_infile_end)(void *);
	int (*local_infile_error)(void *, char *, unsigned int);
	void *local_infile_userdata;
	} MYSQL_OPTIONS;
#ce

;~ enum mysql_status
Global Enum _
		$MYSQL_STATUS_READY, $MYSQL_STATUS_GET_RESULT, $MYSQL_STATUS_USE_RESULT
;~ };

;~ enum mysql_protocol_type
Global Enum _
		$MYSQL_PROTOCOL_DEFAULT, $MYSQL_PROTOCOL_TCP, $MYSQL_PROTOCOL_SOCKET, _
		$MYSQL_PROTOCOL_PIPE, $MYSQL_PROTOCOL_MEMORY
;~ };
#cs
	There are three types of queries - the ones that have to go to
	the master, the ones that go to a slave, and the adminstrative
	type which must happen on the pivot connectioin
#ce
;~ enum mysql_rpl_type
Global Enum _
		$MYSQL_RPL_MASTER, $MYSQL_RPL_SLAVE, $MYSQL_RPL_ADMIN
;~ };

;~ typedef struct character_set
Global Const $MY_CHARSET_INFO = _
		"uint     number;" & _     ;/* character set number              */
		"uint     state;" & _      ;/* character set state               */
		"ptr 		csname;" & _     ;/* collation name                    */ const char        *
		"ptr 		name;" & _       ;/* character set name                */ const char        *
		"ptr 		comment;" & _    ;/* comment                           */ const char        *
		"ptr 		dir;" & _        ;/* character set directory           */ const char        *
		"uint     mbminlen;" & _   ;/* min. length for multibyte strings */
		"uint     mbmaxlen;" ;/* max. length for multibyte strings */

Global $ghMYSQL_LIBMYSQL = -1, $ghMYSQL_LIBMYSQL_COUNT=0
; Prog@ndy
Func __MySQL_DLLLoaded()
	Local $Ret = DllCall("kernel32.dll", "hwnd", "GetModuleHandle", "str", "libmysql.dll")
	If @error Then Return SetError(1, 0, False)
	Return ($Ret[0] <> HWnd(0))
EndFunc   ;==>__MySQL_DLLLoaded
;===============================================================================
;
; Function Name:   _MySQL_InitLibrary
; Description::    MYSQL starten, DLL im PATH (enth‰lt auch @ScriptDir), sonst Pfad zur DLL angeben. DLL muss libmysql.dll heiﬂen.
; Parameter(s):    $libmysqldll - Path to libMySQL.dll (if not in %PATH%)
;                  $Use_EmbeddedDLL - [optional] specifies wether libmysql.dll from libmysqldll.au3 should be used (default=FALSE)
; Requirement(s):  libmysql.dll
; Return Value(s): Zero if successful. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _MySQL_InitLibrary($libmysqldll = "", $Use_EmbeddedDLL = False)
	Select
		Case $ghMYSQL_LIBMYSQL <> -1 And _MySQL_Get_Client_Version() <> 0
			$ghMYSQL_LIBMYSQL_COUNT += 1
			Return 0
			; Nothing
		Case $libmysqldll <> ""
			$ghMYSQL_LIBMYSQL = DllOpen($libmysqldll)
			If $ghMYSQL_LIBMYSQL < 0 Then ContinueCase
		Case True
			$ghMYSQL_LIBMYSQL = DllOpen("libmysql.dll")
			If $ghMYSQL_LIBMYSQL < 0 And @AutoItX64 Then $ghMYSQL_LIBMYSQL = DllOpen("libmysql_x64.dll")
			If $ghMYSQL_LIBMYSQL < 0 Then
				Switch $Use_EmbeddedDLL
					Case True
						ContinueCase
					Case Else
						Return SetError(2, 0, 1)
				EndSwitch
			EndIf
		Case $Use_EmbeddedDLL = True
			Local $sx64 = ''
			If @AutoItX64 Then $sx64 = "_x64"
			Call("_" & "_MySQL_ExtractEmbeddedDLL" & $sx64, @TempDir & "\libmysql_au3"&$sx64&".dll")
			If @error Then Return SetError(3, 0, 1)
			$ghMYSQL_LIBMYSQL = DllOpen(@TempDir & "\libmysql_au3"&$sx64&".dll")
			If $ghMYSQL_LIBMYSQL < 0 Then Return SetError(4, 0, 1)
	EndSelect
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_server_init", "int", 0, "ptr", 0, "ptr", 0)
	If @error Then
		DllClose($ghMYSQL_LIBMYSQL)
		$ghMYSQL_LIBMYSQL = -1
		$ghMYSQL_LIBMYSQL_COUNT = 0
		Return SetError(5, 0, 1)
	EndIf
	$ghMYSQL_LIBMYSQL_COUNT = 1
	Return $mysql[0]
EndFunc   ;==>_MySQL_InitLibrary
;===============================================================================
;
; Function Name:   _MySQL_EndLibrary
; Description::    Closes MySQL DLL
;                  It has to be called to free memory used by MySQL
; Parameter(s):
; Requirement(s):  libmysql.dll
; Return Value(s):
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _MySQL_EndLibrary()
	If $ghMYSQL_LIBMYSQL = -1 Then Return
	$ghMYSQL_LIBMYSQL_COUNT -= 1
	If $ghMYSQL_LIBMYSQL_COUNT < 1 Then
		DllCall($ghMYSQL_LIBMYSQL, "none", "mysql_server_end")
		DllClose($ghMYSQL_LIBMYSQL)
		$ghMYSQL_LIBMYSQL = -1
		$ghMYSQL_LIBMYSQL_COUNT = 0
	EndIf
EndFunc   ;==>_MySQL_EndLibrary

;===============================================================================
;
; Function Name:   _MySQL_Affected_Rows
; Description::    After executing a statement with mysql_query() or mysql_real_query(),
;                  returns the number of rows changed (for UPDATE), deleted (for DELETE),
;                  or inserted (for INSERT). For SELECT statements, mysql_affected_rows()
;                  works like mysql_num_rows().
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): number of affected rows
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-affected-rows.html
;
;===============================================================================
;
Func _MySQL_Affected_Rows($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, -1)
	Local $row = DllCall($ghMYSQL_LIBMYSQL, "uint64", "mysql_affected_rows", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, -1)
	Return $row[0]
;~ 	Return __MySQL_ReOrderULONGLONG($row[0])
EndFunc   ;==>_MySQL_Affected_Rows

;===============================================================================
;
; Function Name:   _MySQL_AutoCommit
; Description::    Sets autocommit mode on if mode is 1, off if mode is 0.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $Mode - Autocommit (True / False)
; Requirement(s):  libmysql.dll
; Return Value(s): Zero if successful. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-autocommit.html
;
;===============================================================================
;
Func _MySQL_AutoCommit($MySQL_ptr, $Mode)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_autocommit", "ptr", $MySQL_ptr, "int", $Mode)
	If @error Then Return SetError(1, 0, 1)
	Return $mysql[0]
EndFunc   ;==>_MySQL_AutoCommit

;===============================================================================
;
; Function Name:   _MySQL_Change_User
; Description::    Changes the user and causes the database specified by db to
;                  become the default (current) database on the connection.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $User      - New username
;                  $Pass      - New password [default= none (empty string "")]
;                  $Database  - New default database [default= none (empty string "")]
; Requirement(s):  libmysql.dll
; Return Value(s): Zero for success. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-change-user.html
;
;===============================================================================
;
Func _MySQL_Change_User($MySQL_ptr, $User, $Pass, $Database = "")
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $PWType = "str", $DBType = "str"
	If $Pass = "" Then $PWType = "ptr"
	If $Database = "" Then $DBType = "ptr"
	Local $conn = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_change_user", "ptr", $MySQL_ptr, "str", $User, $PWType, $Pass, $DBType, $Database)
	If @error Then Return SetError(1, 0, 1)
	Return $conn[0]
EndFunc   ;==>_MySQL_Change_User

;===============================================================================
;
; Function Name:   _MySQL_Character_Set_Name
; Description::    Returns the default character set name for the current connection.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): The default character set name
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-character-set-name.html
;
;===============================================================================
;
Func _MySQL_Character_Set_Name($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, '')
	Local $conn = DllCall($ghMYSQL_LIBMYSQL, "str", "mysql_character_set_name", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, "")
	Return $conn[0]
EndFunc   ;==>_MySQL_Character_Set_Name

;===============================================================================
;
; Function Name:   _MySQL_Close
; Description::    Closes a previously opened connection
;                  if the MySQL struct was created with _MySQL_Init() without any parameter
;                  it will be deleted, too.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): none
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-close.html
;
;===============================================================================
;
Func _MySQL_Close($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	DllCall($ghMYSQL_LIBMYSQL, "none", "mysql_close", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_MySQL_Close

;===============================================================================
;
; Function Name:   _MySQL_Commit
; Description::    Commits the current transaction.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): Zero if successful. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-commit.html
;
;===============================================================================
;
Func _MySQL_Commit($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_commit", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 1)
	Return $mysql[0]
EndFunc   ;==>_MySQL_Commit

;###############################################################################
;
; _MySQL_Connect
; This function is deprecated. Use _MySQL_Real_Connect instead.
; --> http://dev.mysql.com/doc/refman/5.1/en/mysql-connect.html
;
;###############################################################################

;###############################################################################
;
; _MySQL_Create_DB
; This function is deprecated. Use mysql_query() to issue an SQL CREATE DATABASE statement instead.
; --> http://dev.mysql.com/doc/refman/5.1/en/mysql-create-db.html
;
;###############################################################################

;===============================================================================
;
; Function Name:   _MySQL_Data_Seek
; Description::    Seeks to an arbitrary row in a query result set.
;                  The offset value is a row number and should be in the range from 0 to mysql_num_rows(result)-1.
; Parameter(s):    $result - MySQL Result pointer
;                  $offset    - index of row
; Requirement(s):  libmysql.dll
; Return Value(s): None.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-data-seek.html
;
;===============================================================================
;
Func _MySQL_Data_Seek($result, $offset)
	If Not $result Then Return SetError(3, 0, 0)
	DllCall($ghMYSQL_LIBMYSQL, "none", "mysql_data_seek", "ptr", $result, "uint64", $offset)
	If @error Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_MySQL_Data_Seek

;===============================================================================
;
; Function Name:   _MySQL_Debug
; Description::    Does a DBUG_PUSH with the given string. mysql_debug() uses the
;                  Fred Fish debug library. To use this function, you must compile
;                  the client library to support debugging.
; Parameter(s):    $debug - Degub data (don't know format)
; Requirement(s):  libmysql.dll
; Return Value(s): None.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-debug.html
;
;===============================================================================
;
Func _MySQL_Debug($debug)
	DllCall($ghMYSQL_LIBMYSQL, "none", "mysql_debug", "str", $debug)
EndFunc   ;==>_MySQL_Debug


;###############################################################################
;
; _MySQL_Drop_DB
; This function is deprecated. Use mysql_query() to issue an SQL DROP DATABASE statement instead.
; --> http://dev.mysql.com/doc/refman/5.1/en/mysql-drop-db.html
;
;###############################################################################

;===============================================================================
;
; Function Name:   _MySQL_Dump_Debug_Info
; Description::    Instructs the server to write some debug information to the log.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): Zero if the command was successful. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-dump-debug-info.html
;
;===============================================================================
;
Func _MySQL_Dump_Debug_Info($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_dump_debug_info", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 1)
	Return $errors[0]
EndFunc   ;==>_MySQL_Dump_Debug_Info

;===============================================================================
;
; Function Name:   _MySQL_EOF
; Description::    This function is deprecated. mysql_errno() or mysql_error() may be used instead.
;                  mysql_eof() determines whether the last row of a result set has been read.
; Parameter(s):    $result - MySQL Result pointer
; Requirement(s):  libmysql.dll
; Return Value(s): Zero if no error occurred. Nonzero if the end of the result set has been reached.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-data-seek.html
;
;===============================================================================
;
Func _MySQL_EOF($result)
	If Not $result Then Return SetError(3, 0, 1)
	Local $eof = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_eof", "ptr", $result)
	If @error Then Return SetError(1, 0, 1)
	Return $eof[0]
EndFunc   ;==>_MySQL_EOF

;===============================================================================
;
; Function Name:   _MySQL_Errno
; Description::	   returns the error code for the most recently invoked API function that can succeed or fail
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): An error code value for the last mysql_xxx() call, if it failed. zero means no error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-errno.html
;
;===============================================================================
;
Func _MySQL_Errno($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "uint", "mysql_errno", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $errors[0]
EndFunc   ;==>_MySQL_Errno

;===============================================================================
;
; Function Name:   _MySQL_Error
; Description::    returns a null-terminated string containing the error message
;                  for the most recently invoked API function that failed.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A null-terminated character string that describes the error. An empty string if no error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-error.html
;
;===============================================================================
;
Func _MySQL_Error($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, '')
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "str", "mysql_error", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, "")
	Return $errors[0]
EndFunc   ;==>_MySQL_Error

;###############################################################################
;
; _MySQL_Escape_String
; You should use _mysql_real_escape_string()  instead!
; --> http://dev.mysql.com/doc/refman/5.1/en/mysql-escape-string.html
;
;###############################################################################

;===============================================================================
;
; Function Name:   _MySQL_Fetch_Field
; Description::    Returns the definition of one column of a result set as a MYSQL_FIELD structure.
; Parameter(s):    $result - MySQL Result pointer
; Requirement(s):  libmysql.dll
; Return Value(s): MySQL_FIELD-Structure. On error 0 (ZERO)
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-fetch-field.html
;
;===============================================================================
;
Func _MySQL_Fetch_Field($result)
	If Not $result Then Return SetError(3, 0, 0)
	Local $field = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_fetch_field", "ptr", $result)
	If @error Then Return SetError(1, 0, 0)
	$field = $field[0]
	Return DllStructCreate($MYSQL_FIELD, $field)
EndFunc   ;==>_MySQL_Fetch_Field

;===============================================================================
;
; Function Name:   _MySQL_Fetch_Field_Direct
; Description::    returns that column's field definition as a MYSQL_FIELD structure.
; Parameter(s):    $result  - MySQL Resut pointer returned from _MySQL_Real_Query
;                  $fieldnr - Index of field from which to fetch information
; Requirement(s):  libmysql.dll
; Return Value(s): The MYSQL_FIELD structure for the specified column. On error 0 (ZERO)
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-fetch-field-direct.html
;
;===============================================================================
;
Func _MySQL_Fetch_Field_Direct($result, $fieldnr)
	If Not $result Then Return SetError(3, 0, 0)
	Local $field = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_fetch_field_direct", "ptr", $result, "uint", $fieldnr)
	If @error Then Return SetError(1, 0, 0)
	$field = $field[0]
	Return DllStructCreate($MYSQL_FIELD, $field)
EndFunc   ;==>_MySQL_Fetch_Field_Direct


;===============================================================================
;
; Function Name:   _MySQL_Fetch_Fields
; Description::    Returns an array of all MYSQL_FIELD structures for a result set.
;                  Each structure provides the field definition for one column of the result set.
; Parameter(s):    $result         - MySQL Resut pointer returned from _MySQL_Real_Query
;                  $numberOfFields - [optional] The count of fields in the result set. (default: uses _MySQL_Num_Fields)
; Requirement(s):  libmysql.dll
; Return Value(s): Success: Array of MYSQL_FIELD structures
;                  Error: 0 (ZERO) and @error > 0
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-fetch-fields.html
;
;===============================================================================
;
Func _MySQL_Fetch_Fields($result, $numberOfFields = Default)
	If $numberOfFields = Default Then $numberOfFields = _MySQL_Num_Fields($result)
	If $numberOfFields = 0 Then Return SetError(1, 0, 0)
	Local $fields = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_fetch_fields", "ptr", $result)
	If @error Then Return SetError(2, 0, 0)
	$fields = $fields[0]
	Local $arFields[$numberOfFields]
	$arFields[0] = DllStructCreate($MYSQL_FIELD, $fields)
	For $i = 1 To $numberOfFields - 1
		$arFields[$i] = DllStructCreate($MYSQL_FIELD, $fields + (DllStructGetSize($arFields[0]) * $i))
	Next
	Return $arFields
EndFunc   ;==>_MySQL_Fetch_Fields

;===============================================================================
;
; Function Name:   _MySQL_Fetch_Fields_Names
; Description::    Fetches all captions of the colums of a result
; Parameter(s):    $result         - MySQL Resut pointer returned from _MySQL_Real_Query
;                  $numberOfFields - [optional] The count of fields in the result set. (default: uses _MySQL_Num_Fields)
; Requirement(s):  libmysql.dll
; Return Value(s): Array of fieldnames. On error returns 0 (ZERO)
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _MySQL_Fetch_Fields_Names($result, $numberOfFields = Default)
	If $numberOfFields = Default Then $numberOfFields = _MySQL_Num_Fields($result)
	If $numberOfFields = 0 Then Return SetError(1, 0, 0)
	Local $fields = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_fetch_fields", "ptr", $result)
	If @error Then Return SetError(1, 0, 0)
	$fields = $fields[0]
	Local $struct = DllStructCreate($MYSQL_FIELD, $fields)
	Local $arFields[$numberOfFields]
	For $i = 1 To $numberOfFields
		$arFields[$i - 1] = __MySQL_PtrStringRead(DllStructGetData($struct, 1))
		If $i = $numberOfFields Then ExitLoop
		$struct = DllStructCreate($MYSQL_FIELD, $fields + (DllStructGetSize($struct) * $i))
	Next
	Return $arFields
EndFunc   ;==>_MySQL_Fetch_Fields_Names

;===============================================================================
;
; Function Name:   _MySQL_Fetch_Lengths
; Description::    Returns the lengths of the columns of the current row within a result set.
; Parameter(s):    $result         - MySQL Resut pointer returned from _MySQL_Real_Query
;                  $numberOfFields - [optional] The count of fields in the result set. (default: uses _MySQL_Num_Fields)
; Requirement(s):  libmysql.dll
; Return Value(s): DLLStruct with ulong Array get data [ DLLStructGetData($struct,1, $n ) ]
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-fetch-lengths.html
;
;===============================================================================
;
Func _MySQL_Fetch_Lengths($result, $numberOfFields = Default)
	If $numberOfFields = Default Then $numberOfFields = _MySQL_Num_Fields($result)
	If $numberOfFields <= 0 Then Return SetError(1, 0, 0)

	Local $lengths = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_fetch_lengths", "ptr", $result)
	If @error Then Return SetError(1, 0, 0)

	Return DllStructCreate("ulong lengths[" & $numberOfFields & "]", $lengths[0])
EndFunc   ;==>_MySQL_Fetch_Lengths

;===============================================================================
;
; Function Name:   _MySQL_Fetch_Row
; Description::    Retrieves the next row of a result set.
; Parameter(s):    $result         - MySQL Resut pointer returned from _MySQL_Real_Query
;                  $numberOfFields - [optional] The count of fields in the result set. (default: uses _MySQL_Num_Fields)
; Requirement(s):  libmysql.dll
; Return Value(s): DLLStruct with pointers to data fields. On error 0 (ZERO)
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-fetch-row.html
;
;===============================================================================
;
Func _MySQL_Fetch_Row($result, $numberOfFields = Default)
	If $numberOfFields = Default Then $numberOfFields = _MySQL_Num_Fields($result)
	If $numberOfFields <= 0 Then Return SetError(1, 0, 0)

	Local $row = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_fetch_row", "ptr", $result)
	If @error Then Return SetError(1, 0, 0)

	Return DllStructCreate("ptr[" & $numberOfFields & "]", $row[0])
EndFunc   ;==>_MySQL_Fetch_Row

;===============================================================================
;
; Function Name:   _MySQL_Fetch_Row_StringArray
; Description::    Fetches one row to an array as strings
; Parameter(s):    $result         - MySQL Resut pointer returned from _MySQL_Real_Query
;                  $numberOfFields - [optional] The count of fields in the result set. (default: uses _MySQL_Num_Fields)
;                  $NULLasPtr0     - [optional] Specifies if NULL-value should be returned as Ptr(0) (default: False - empty string)
; Requirement(s):  libmysql.dll
; Return Value(s): Array with Strings. On error 0 (ZERO)
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _MySQL_Fetch_Row_StringArray($result, $fields = Default, $NULLasPtr0 = False)
	If $fields = Default Then $fields = _MySQL_Num_Fields($result)
	If $fields <= 0 Or $result = 0 Then Return SetError(1, 0, 0)

	Local $RowArr[$fields]

	Local $mysqlrow = _MySQL_Fetch_Row($result, $fields)
	If Not IsDllStruct($mysqlrow) Then Return SetError(1, 0, 0)

	Local $lenthsStruct = _MySQL_Fetch_Lengths($result)

	Local $length, $fieldPtr
	For $i = 1 To $fields
		$length = DllStructGetData($lenthsStruct, 1, $i)
		$fieldPtr = DllStructGetData($mysqlrow, 1, $i)
		Select
			Case $length ; if there is data
				$RowArr[$i - 1] = DllStructGetData(DllStructCreate("char[" & $length & "]", $fieldPtr), 1)
			Case $NULLasPtr0 And Not $fieldPtr ; is NULL and return NULL as Ptr(0)
				$RowArr[$i - 1] = Ptr(0)
;~ 			Case Else ; Empty String or NULL as empty string
				; Nothing needs to be done, since array entries are default empty string
;~ 				$RowArr[$i - 1] = ""
		EndSelect
	Next
	Return $RowArr
EndFunc   ;==>_MySQL_Fetch_Row_StringArray

;===============================================================================
;
; Function Name:   _MySQL_Fetch_Result_StringArray
; Description::    Gets the whole result into a 2D String array.
; Parameter(s):    $result         - MySQL Resut pointer returned from _MySQL_Real_Query
;                  $NULLasPtr0     - [optional] Specifies if NULL-value should be returned as Ptr(0) (default: False - empty string)
; Requirement(s):  libmysql.dll
; Return Value(s): 2D-Array On error 0 (ZERO)
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _MySQL_Fetch_Result_StringArray($result, $NULLasPtr0 = False)
	_MySQL_Data_Seek($result, 0)
	Local $fields = _MySQL_Num_Fields($result)
	Local $rows = _MySQL_Num_Rows($result)
	If $fields < 1 Or $rows < 1 Then Return SetError(1, 0, 0)
	Local $ResultArr[$rows + 1][$fields]
	Local $Names = _MySQL_Fetch_Fields_Names($result, $fields)
	For $i = 0 To $fields - 1
		$ResultArr[0][$i] = $Names[$i]
	Next
	Local $length, $fieldPtr, $rowPtr, $mysqlrow, $lengths, $lenthsStruct
	Local Const $NULLPTR = Ptr(0)
	For $j = 1 To $rows
		$mysqlrow = _MySQL_Fetch_Row($result, $fields)
		If Not IsDllStruct($mysqlrow) Then ExitLoop

		$lenthsStruct = _MySQL_Fetch_Lengths($result)

		For $i = 1 To $fields
			$length = DllStructGetData($lenthsStruct, 1, $i)
			$fieldPtr = DllStructGetData($mysqlrow, 1, $i)
			Select
				Case $length ; if there is data
					$ResultArr[$j][$i - 1] = DllStructGetData(DllStructCreate("char[" & $length & "]", $fieldPtr), 1)
				Case $NULLasPtr0 And Not $fieldPtr ; is NULL and return NULL as Ptr(0)
					$ResultArr[$j][$i - 1] = $NULLPTR
;~ 				Case Else ; Empty String or NULL as empty string
					; Nothing needs to be done, since array entries are default empty string
;~ 					$RowArr[$i - 1] = ""
			EndSelect
		Next
	Next
	Return $ResultArr
EndFunc   ;==>_MySQL_Fetch_Result_StringArray

;===============================================================================
;
; Function Name:   _MySQL_Field_Count
; Description::    Returns the number of columns for the most recent query on the connection.
; Parameter(s):    $result         - MySQL Resut pointer returned from _MySQL_Real_Query
; Requirement(s):  libmysql.dll
; Return Value(s): An unsigned integer representing the number of columns in a result set.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-field-count.html
;
;===============================================================================
;
Func _MySQL_Field_Count($result)
	Local $row = DllCall($ghMYSQL_LIBMYSQL, "uint", "mysql_field_count", "ptr", $result)
	If @error Then Return SetError(1, 0, 0)
	Return $row[0]
EndFunc   ;==>_MySQL_Field_Count

;===============================================================================
;
; Function Name:   _MySQL_Field_ReadValue
; Description::    Reads the specified value of a MYSQL_FIELD struct
; Parameter(s):    $field - MYSQL_FIELD
;                  $ValueName - the name of the value to read
; Requirement(s):  libmysql.dll
; Return Value(s): The value of the field.
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _MySQL_Field_ReadValue(ByRef $field, $ValueName)
	Local $Return = DllStructGetData($field, $ValueName)
	If @error Then Return SetError(1, 0, "")
	If IsPtr($Return) Then Return __MySQL_PtrStringRead($Return)
	Return $Return
EndFunc   ;==>_MySQL_Field_ReadValue

;===============================================================================
;
; Function Name:   _MySQL_Field_Seek
; Description::     Sets the field cursor to the given offset.
;                   The next call to mysql_fetch_field() retrieves the field
;                     definition of the column associated with that offset.
;                   To seek to the beginning of a row, pass an offset value of zero.
; Parameter(s):    $result - MySQL Result pointer
;                  $offset - Offset of the filed pointer
; Requirement(s):  libmysql.dll
; Return Value(s): The previous value of the field cursor.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-field-seek.html
;
;===============================================================================
;
Func _MySQL_Field_Seek($result, $offset)
	Local $row = DllCall($ghMYSQL_LIBMYSQL, "uint", "mysql_field_seek", "ptr", $result, "uint", $offset)
	If @error Then Return SetError(1, 0, 0)
	Return $row[0]
EndFunc   ;==>_MySQL_Field_Seek

;===============================================================================
;
; Function Name:   _MySQL_Field_Tell
; Description::    Returns the position of the field cursor used for the last mysql_fetch_field().
;                  This value can be used as an argument to mysql_field_seek().
; Parameter(s):    $result - MySQL Result pointer
; Requirement(s):  libmysql.dll
; Return Value(s): The previous value of the field cursor.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-field-seek.html
;
;===============================================================================
;
Func _MySQL_Field_Tell($result)
	Local $row = DllCall($ghMYSQL_LIBMYSQL, "uint", "mysql_field_tell", "ptr", $result)
	If @error Then Return SetError(1, 0, 0)
	Return $row[0]
EndFunc   ;==>_MySQL_Field_Tell

;===============================================================================
;
; Function Name:   _MySQL_Free_Result
; Description::    Frees the memory allocated for a result set by mysql_store_result(),
;                    mysql_use_result(), mysql_list_dbs(), and so forth. When you are
;                    done with a result set, you must free the memory it uses by
;                    calling mysql_free_result().
;                  Do not attempt to access a result set after freeing it.
; Parameter(s):    $result - MySQL Result pointer
; Requirement(s):  libmysql.dll
; Return Value(s): None.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-free-result.html
;
;===============================================================================
;
Func _MySQL_Free_Result($result)
	DllCall($ghMYSQL_LIBMYSQL, "none", "mysql_free_result", "ptr", $result)
	If @error Then Return SetError(1, 0, 0)
EndFunc   ;==>_MySQL_Free_Result

;===============================================================================
;
; Function Name:   _MySQL_Get_Character_Set_Info
; Description::    This function provides information about the default client character set.
;                  The default character set may be changed with the mysql_set_character_set() function.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): a $MY_CHARSET_INFO struct with the fetched values.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-get-character-set-info.html
;
;===============================================================================
;
Func _MySQL_Get_Character_Set_Info($MySQL_ptr)
	Local $charset = DllStructCreate($MY_CHARSET_INFO)
	DllCall($ghMYSQL_LIBMYSQL, "none", "mysql_get_character_set_info", "ptr", $MySQL_ptr, "ptr", DllStructGetPtr($charset))
	If @error Then Return SetError(1, 0, 0)
	Return $charset
EndFunc   ;==>_MySQL_Get_Character_Set_Info

;===============================================================================
;
; Function Name:   _MySQL_Get_Client_Info
; Description::    Returns a string that represents the client library version.
; Parameter(s):
; Requirement(s):  libmysql.dll
; Return Value(s): A character string that represents the MySQL client library version.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-get-client-info.html
;
;===============================================================================
;
Func _MySQL_Get_Client_Info()
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "str", "mysql_get_client_info")
	If @error Then Return SetError(1, 0, "")
	Return $errors[0]
EndFunc   ;==>_MySQL_Get_Client_Info

;===============================================================================
;
; Function Name:   _MySQL_Get_Client_Version
; Description::    Returns an integer that represents the client library version.
;                  The value has the format XYYZZ where X is the major version,
;                  YY is the release level, and ZZ is the version number within
;                  the release level. For example, a value of 40102 represents
;                  a client library version of 4.1.2.
; Parameter(s):
; Requirement(s):  libmysql.dll
; Return Value(s): An integer that represents the MySQL client library version.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-get-client-version.html
;
;===============================================================================
;
Func _MySQL_Get_Client_Version()
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "ulong", "mysql_get_client_version")
	If @error Then Return SetError(1, 0, 0)
	Return $errors[0]
EndFunc   ;==>_MySQL_Get_Client_Version

;===============================================================================
;
; Function Name:   _MySQL_Get_Host_Info
; Description::    Returns a string describing the type of connection in use, including the server hostname.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A character string representing the server hostname and the connection type.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-get-host-info.html
;
;===============================================================================
;
Func _MySQL_Get_Host_Info($MySQL_ptr)
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "str", "mysql_get_host_info", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, "")
	Return $errors[0]
EndFunc   ;==>_MySQL_Get_Host_Info

;===============================================================================
;
; Function Name:   _MySQL_Get_Proto_Info
; Description::    Returns the protocol version used by current connection.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): An unsigned integer representing the protocol version used by the current connection.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-get-proto-info.html
;
;===============================================================================
;
Func _MySQL_Get_Proto_Info($MySQL_ptr)
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "uint", "mysql_get_proto_info", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $errors[0]
EndFunc   ;==>_MySQL_Get_Proto_Info

;===============================================================================
;
; Function Name:   _MySQL_Get_Server_Info
; Description::    Returns a string that represents the server version number.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A character string that represents the server version number.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-get-server-info.html
;
;===============================================================================
;
Func _MySQL_Get_Server_Info($MySQL_ptr)
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "str", "mysql_get_server_info", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, "")
	Return $errors[0]
EndFunc   ;==>_MySQL_Get_Server_Info

;===============================================================================
;
; Function Name:   _MySQL_Get_Server_Version
; Description::    Returns the version number of the server as an integer.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A number that represents the MySQL server version in this format:
;                   [> major_version*10000 + minor_version *100 + sub_version <]
;                   For example, 5.1.5 is returned as 50105.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-get-server-version.html
;
;===============================================================================
;
Func _MySQL_Get_Server_Version($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "ulong", "mysql_get_server_version", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $errors[0]
EndFunc   ;==>_MySQL_Get_Server_Version

;===============================================================================
;
; Function Name:   _MySQL_Get_SSL_Cipher
; Description::    returns the SSL cipher used for the given connection to the server.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A string naming the SSL cipher used for the connection, or NULL if no cipher is being used.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-get-ssl-cipher.html
;
;===============================================================================
;
Func _MySQL_Get_SSL_Cipher($MySQL_ptr, $key, $cert, $ca, $capath, $cipher)
	If Not $MySQL_ptr Then Return SetError(3, 0, '')
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "str", "mysql_get_ssl_cipher", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, "")
	Return $errors[0]
EndFunc   ;==>_MySQL_Get_SSL_Cipher

;===============================================================================
;
; Function Name:   _MySQL_Hex_String
; Description::    Returns Hex value of a string
; Parameter(s):    $string - string to convert to Hex representation
;                  $Include0x - determines wether the string should include the sign "0x"
; Requirement(s):
; Return Value(s): String in Hex format
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _MySQL_Hex_String($string, $Include0x = False)
	Switch $Include0x
		Case True
			Return String(StringToBinary($string, 1))
		Case Else
			Return Hex(StringToBinary($string, 1))
	EndSwitch
EndFunc   ;==>_MySQL_Hex_String

;===============================================================================
;
; Function Name:   _MySQL_Info
; Description::    Retrieves a string providing information about the most
;                  recently executed statement, but only for the statements
;                  listed in weblink below.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A character string representing additional information about the most recently executed statement.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-info.html
;
;===============================================================================
;
Func _MySQL_Info($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $info = DllCall($ghMYSQL_LIBMYSQL, "str", "mysql_info", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, "")
	Return $info[0]
EndFunc   ;==>_MySQL_Info

;===============================================================================
;
; Function Name:   _MySQL_Init
; Description::    Initiates a new MySQL struct
; Parameter(s):    $MySQL_ptr - [optional] a pointer to a MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): Success: Pointer to the struct
;                  Error: 0 (if DLLCall failed @error set to 1)
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-init.html
;
;===============================================================================
;
Func _MySQL_Init($MySQL_ptr = 0)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_init", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $mysql[0]
EndFunc   ;==>_MySQL_Init

;===============================================================================
;
; Function Name:   _MySQL_Insert_ID
; Description::    Returns the value generated for an AUTO_INCREMENT column by the previous INSERT or UPDATE statement.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): Described on weblink
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-insert-id.html
;
;===============================================================================
;
Func _MySQL_Insert_ID($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $row = DllCall($ghMYSQL_LIBMYSQL, "uint64", "mysql_insert_id", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $row[0]
;~ 	Return __MySQL_ReOrderULONGLONG($row[0])
EndFunc   ;==>_MySQL_Insert_ID


;###############################################################################
;
; _MySQL_Kill
; This function is deprecated. Use mysql_real_query() to issue an SQL KILL statement instead
; --> http://dev.mysql.com/doc/refman/5.1/en/mysql-kill.html
;
;###############################################################################

;###############################################################################
;
; mysql_library_end
; Called by _MySQL_EndLibrary.
; --> http://dev.mysql.com/doc/refman/5.1/en/mysql-library-end.html
;
;###############################################################################

;###############################################################################
;
; mysql_library_init
; Called by _MySQL_InitLibrary.
; --> http://dev.mysql.com/doc/refman/5.1/en/mysql-library-init.html
;
;###############################################################################

;===============================================================================
;
; Function Name:   _MySQL_List_DBs
; Description::    Returns a result set consisting of database names on the server
;                  that match the simple regular expression specified by the wild parameter.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $wild      - database wildcard
; Requirement(s):  libmysql.dll
; Return Value(s): A MYSQL_RES result set for success. NULL if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-list-dbs.html
;
;===============================================================================
;
Func _MySQL_List_DBs($MySQL_ptr, $wild = "")
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $type = "str"
	If $wild = "" Then $type = "ptr"
	Local $query = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_list_dbs", "ptr", $MySQL_ptr, $type, $wild)
	If @error Then Return SetError(1, 0, 0)
	Return $query[0]
EndFunc   ;==>_MySQL_List_DBs

;===============================================================================
;
; Function Name:   _MySQL_List_Fields
; Description::     Note that it's recommended that you use SHOW COLUMNS FROM tbl_name instead of mysql_list_fields()
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $table     - Table to work on
;                  $wild      - fields wildcard
; Requirement(s):  libmysql.dll
; Return Value(s): A MYSQL_RES result set for success. NULL if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-list-fields.html
;
;===============================================================================
;
Func _MySQL_List_Fields($MySQL_ptr, $table, $wild = "")
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $type = "str"
	If $wild = "" Then $type = "ptr"
	Local $query = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_list_fields", "ptr", $MySQL_ptr, "str", $table, $type, $wild)
	If @error Then Return SetError(1, 0, 0)
	Return $query[0]
EndFunc   ;==>_MySQL_List_Fields

;===============================================================================
;
; Function Name:   _MySQL_List_DBs
; Description::    Returns a result set describing the current server threads.
;                   This is the same kind of information as that reported by
;                   mysqladmin processlist or a SHOW PROCESSLIST query.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A MYSQL_RES result set for success. NULL if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-list-processes.html
;
;===============================================================================
;
Func _MySQL_List_Processes($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $query = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_list_processes", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $query[0]
EndFunc   ;==>_MySQL_List_Processes

;===============================================================================
;
; Function Name:   _MySQL_List_Tables
; Description::    Returns a result set consisting of table names in the current
;                  database that match the simple regular expression specified by the wild parameter.
;                  You must free the result set with mysql_free_result().
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $wild      - table wildcard
; Requirement(s):  libmysql.dll
; Return Value(s): A MYSQL_RES result set for success. NULL if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-list-tables.html
;
;===============================================================================
;
Func _MySQL_List_Tables($MySQL_ptr, $wild = "")
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $type = "str"
	If $wild = "" Then $type = "ptr"
	Local $query = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_list_tables", "ptr", $MySQL_ptr, $type, $wild)
	If @error Then Return SetError(1, 0, 0)
	Return $query[0]
EndFunc   ;==>_MySQL_List_Tables

;===============================================================================
;
; Function Name:   _MySQL_More_Results
; Description::    This function is used when you execute multiple statements specified
;                  as a single statement string, or when you execute CALL statements,
;                  which can return multiple result sets.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): TRUE (1) if more results exist. FALSE (0) if no more results exist.
;                    In most cases, you can call mysql_next_result() instead to test
;                    whether more results exist and initiate retrieval if so.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-more-results.html
;
;===============================================================================
;
Func _MySQL_More_Results($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $result = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_more_results", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $result[0]
EndFunc   ;==>_MySQL_More_Results

;===============================================================================
;
; Function Name:   _MySQL_Next_Result
; Description::    This function is used when you execute multiple statements specified
;                  as a single statement string, or when you execute CALL statements,
;                  which can return multiple result sets.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): Return Value    Description
;                       0        Successful and there are more results
;                      -1        Successful and there are no more results
;                      >0        An error occurred
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-next-result.html
;
;===============================================================================
;
Func _MySQL_Next_Result($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $result = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_next_result", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 1)
	Return $result[0]
EndFunc   ;==>_MySQL_Next_Result

;===============================================================================
;
; Function Name:   _MySQL_Num_Fields
; Description::    Returns the number of columns in a result set.
; Parameter(s):    $result - - MySQL Result pointer
;                        (You can also use a $MySQL_ptr - Pointer to the MySQL struct)
; Requirement(s):  libmysql.dll
; Return Value(s): An unsigned integer representing the number of columns in a result set.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-num-fields.html
;
;===============================================================================
;
Func _MySQL_Num_Fields($result)
	If Not $result Then Return SetError(1, 0, 0)
	Local $row = DllCall($ghMYSQL_LIBMYSQL, "uint", "mysql_num_fields", "ptr", $result)
	If @error Then Return SetError(1, 0, 0)
	Return $row[0]
EndFunc   ;==>_MySQL_Num_Fields

;===============================================================================
;
; Function Name:   _MySQL_Num_Rows
; Description::    Returns the number of rows in the result set.
; Parameter(s):    $result - - MySQL Result pointer
; Requirement(s):  libmysql.dll
; Return Value(s): The number of rows in the result set.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-num-rows.html
;
;===============================================================================
;
Func _MySQL_Num_Rows($result)
	If Not $result Then Return SetError(3, 0, 0)
	Local $rows = DllCall($ghMYSQL_LIBMYSQL, "uint64", "mysql_num_rows", "ptr", $result)
	If @error Then Return SetError(1, 0, 0)
	Return $rows[0]
;~ 	Return __MySQL_ReOrderULONGLONG($rows[0])
EndFunc   ;==>_MySQL_Num_Rows

;===============================================================================
;
; Function Name:   _MySQL_Options
; Description::    Can be used to set extra connect options and affect behavior for a connection.
;                  This function may be called multiple times to set several options.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $option   - Option to set ($MYSQL_OPT_...)
;                  $arg      - [optional] Value to set for the option
;                  $type     - [optional] Type of the argument, must be set, if $arg is used
; Requirement(s):  libmysql.dll
; Return Value(s): Zero if successful. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-options.html
; Remarks:         The types for the options are:
;                     char *                  --> str
;                     unsigned int *          --> uint*
;                     pointer to unsigned int --> uint*
;                     my_bool *               --> int*
;
;===============================================================================
;
Func _MySQL_Options($MySQL_ptr, $option, $arg = 0, $type = "ptr")
	If @NumParams = 3 Then Return SetError(1, 0, 32)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_options", "ptr", $MySQL_ptr, "dword", $option, $type, $arg)
	If @error Then Return SetError(2, 0, 1)
	Return $mysql[0]
EndFunc   ;==>_MySQL_Options

;===============================================================================
;
; Function Name:   _MySQL_Ping
; Description::    Checks whether the connection to the server is working.
;                    If the connection has gone down and auto-reconnect is enabled
;                    an attempt to reconnect is made. If the connection is down and
;                    auto-reconnect is disabled, mysql_ping() returns an error.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): Zero if the connection to the server is alive. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-ping.html
;
;===============================================================================
;
Func _MySQL_Ping($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_ping", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 1)
	Return $mysql[0]
EndFunc   ;==>_MySQL_Ping

;===============================================================================
;
; Function Name:   _MySQL_Query
; Description::    Executes an SQL statement. Normally, the string must consist
;                    of a single SQL statement and you should not add a terminating
;                    semicolon (ì;î) or \g to the statement. If multiple-statement
;                    execution has been enabled, the string can contain several
;                    statements separated by semicolons.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $query     - Query to execute MUST NOT contain Chr(0)
;                               For binary data use _MySQL_Real_Query
; Requirement(s):  libmysql.dll
; Return Value(s): Zero if the statement was successful. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-query.html
;
;===============================================================================
;
Func _MySQL_Query($MySQL_ptr, $query)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_query", "ptr", $MySQL_ptr, "str", $query)
	If @error Then Return SetError(1, 0, 1)
	Return $mysql[0]
EndFunc   ;==>_MySQL_Query

;===============================================================================
;
; Function Name:   _MySQL_Real_Connect
; Description::    attempts to establish a connection to a MySQL database engine running on $Host.
;                    mysql_real_connect() must complete successfully before you can execute any
;                    other API functions that require a valid MYSQL connection handle structure.
; Parameter(s):    $MySQL_ptr   - Pointer to the MySQL struct
;                  $Host        - hostname or an IP address
;                  $User        - MySQL login ID
;                  $Pass        - password for user (no password: "" (empty string))
;                  $Database    - default database (no default db: "" (empty string))
;                  $Port        - If port is not 0, the value is used as the port number for the TCP/IP connection.
;                  $unix_socket - specifies the socket or named pipe that should be used. (no pipe: "" (empty string))
;                  $Client_Flag - flags to enable features
; Requirement(s):  libmysql.dll
; Return Value(s): A MYSQL* connection handle if the connection was successful, NULL if the connection
;                    was unsuccessful. For a successful connection, the return value is the same as the
;                    value of the first parameter.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-real-connect.html
;
;===============================================================================
;
Func _MySQL_Real_Connect($MySQL_ptr, $Host, $User, $Pass, $Database = "", $Port = 0, $unix_socket = "", $Client_Flag = 0)
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $PWType = "str", $DBType = "str", $UXSType = "str"
	If $Pass = "" Then $PWType = "ptr"
	If $Database = "" Then $DBType = "ptr"
	If $unix_socket = "" Then $UXSType = "ptr"
	Local $conn = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_real_connect", "ptr", $MySQL_ptr, "str", $Host, "str", $User, $PWType, $Pass, $DBType, $Database, "uint", $Port, $UXSType, $unix_socket, "ulong", $Client_Flag)
	If @error Then Return SetError(1, 0, 0)
	Return $conn[0]
EndFunc   ;==>_MySQL_Real_Connect

;===============================================================================
;
; Function Name:   _MySQL_Real_Escape_String
; Description::    This function is used to create a legal SQL string that you can use in an SQL statement.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $From      - String to escape
;                  $FromLen   - [optional] Length of the string
; Requirement(s):  libmysql.dll
; Return Value(s): the escaped string
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-real-escape-string.html
;
;===============================================================================
;
Func _MySQL_Real_Escape_String($MySQL_ptr, $From, $FromLen = Default)
	If Not $MySQL_ptr Then Return SetError(3, 0, '')
	If $FromLen <= 0 Or $FromLen = Default Then $FromLen = StringLen($From)
	Local $TO = DllStructCreate("char[" & $FromLen * 2 + 1 & "]")
	Local $query = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_real_escape_string", "ptr", $MySQL_ptr, "ptr", DllStructGetPtr($TO), "str", $From, "ulong", $FromLen)
	If @error Then Return SetError(1, 0, 0)
	Return StringLeft(DllStructGetData($TO, 1), $query[0])
EndFunc   ;==>_MySQL_Real_Escape_String

;===============================================================================
;
; Function Name:   _MySQL_Real_Query
; Description::    Executes the SQL statement pointed to by stmt_str, which should be a string length bytes long.
;                    Normally, the string must consist of a single SQL statement and you should not add a
;                    terminating semicolon (ì;î) or \g to the statement. If multiple-statement execution has been
;                    enabled, the string can contain several statements separated by semicolons.
;                    You can use Chr(0) in this Query
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): Zero if the statement was successful. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-real-query.html
;
;===============================================================================
;
Func _MySQL_Real_Query($MySQL_ptr, $querystring, $querystringlength = Default)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	If $querystringlength <= 0 Or $querystringlength = Default Then $querystringlength = StringLen($querystring)
	Local $query = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_real_query", "ptr", $MySQL_ptr, "str", $querystring, "ulong", $querystringlength)
	If @error Then Return SetError(1, 0, 1)
	Return $query[0]
EndFunc   ;==>_MySQL_Real_Query

;===============================================================================
;
; Function Name:   _MySQL_Refresh
; Description::    This function flushes tables or caches, or resets
;                  replication server information.
;                  The connected user must have the RELOAD privilege.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): Zero for success. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-refresh.html
;
;===============================================================================
;
Func _MySQL_Refresh($MySQL_ptr, $options)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_refresh", "ptr", $MySQL_ptr, "ulong", $options)
	If @error Then Return SetError(1, 0, 1)
	Return $mysql[0]
EndFunc   ;==>_MySQL_Refresh

;===============================================================================
;
; Function Name:   _MySQL_Reload
; Description::    Asks the MySQL server to reload the grant tables
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): Zero for success. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-reload.html
;
;===============================================================================
;
Func _MySQL_Reload($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_reload", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 1)
	Return $mysql[0]
EndFunc   ;==>_MySQL_Reload

;===============================================================================
;
; Function Name:   _MySQL_Rollback
; Description::    Rolls back the current transaction.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): Zero if successful. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-rollback.html
;
;===============================================================================
;
Func _MySQL_Rollback($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_rollback", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 1)
	Return $mysql[0]
EndFunc   ;==>_MySQL_Rollback


;===============================================================================
;
; Function Name:   _MySQL_Row_Seek
; Description::    Sets the row cursor to an arbitrary row in a query result set.
;                    The offset value is a row offset that should be a value returned
;                    from mysql_row_tell() or from mysql_row_seek(). This value is not
;                    a row number; if you want to seek to a row within a result set by
;                    number, use mysql_data_seek() instead.
; Parameter(s):    $result - MySQL Result pointer
;                  $offset    - pointer to row offset struct
; Requirement(s):  libmysql.dll
; Return Value(s): The previous value of the row cursor. This value may be passed to a subsequent call to mysql_row_seek()
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-row-seek.html
;
;===============================================================================
;
Func _MySQL_Row_Seek($result, $offset)
	If Not $result Then Return SetError(3, 0, 0)
	Local $seek = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_row_seek", "ptr", $result, "ptr", $offset)
	If @error Then Return SetError(1, 0, 0)
	Return $seek[0]
EndFunc   ;==>_MySQL_Row_Seek


;===============================================================================
;
; Function Name:   _MySQL_Row_Tell
; Description::    Returns the current position of the row cursor
;                    for the last mysql_fetch_row().
;                    This value can be used as an argument to mysql_row_seek().
; Parameter(s):    $result - MySQL Result pointer
;                  $offset    - pointer to row offset struct
; Requirement(s):  libmysql.dll
; Return Value(s): The current offset of the row cursor.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-row-tell.html
;
;===============================================================================
;
Func _MySQL_Row_Tell($result, $offset)
	If Not $result Then Return SetError(3, 0, 0)
	Local $seek = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_row_tell", "ptr", $result, "ptr", $offset)
	If @error Then Return SetError(1, 0, 0)
	Return $seek[0]
EndFunc   ;==>_MySQL_Row_Tell

;===============================================================================
;
; Function Name:   _MySQL_Select_DB
; Description::    Causes the database specified by db to become the default
;                    (current) database on the connection specified by mysql.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $Database  - The new default database name
; Requirement(s):  libmysql.dll
; Return Value(s): Zero for success. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-select-db.html
;
;===============================================================================
;
Func _MySQL_Select_DB($MySQL_ptr, $Database)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $conn = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_select_db", "ptr", $MySQL_ptr, "str", $Database)
	If @error Then Return SetError(1, 0, 1)
	Return $conn[0]
EndFunc   ;==>_MySQL_Select_DB

;===============================================================================
;
; Function Name:   _MySQL_Get_Character_Set_Info
; Description::    This function is used to set the default character set for the
;                    current connection. The string csname  specifies a valid character
;                    set name. The connection collation becomes the default collation
;                    of the character set.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $name      - Name of the new charset
; Requirement(s):  libmysql.dll
; Return Value(s): Zero for success. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-set-character-set.html
;
;===============================================================================
;
Func _MySQL_Set_Character_Set($MySQL_ptr, $name)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $charset = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_set_character_set", "ptr", $MySQL_ptr, "str", $name)
	If @error Then Return SetError(1, 0, 1)
	Return $charset[0]
EndFunc   ;==>_MySQL_Set_Character_Set

;===============================================================================
;
; Function Name:   _MySQL_Set_Server_Option
; Description::    Enables or disables an option for the connection.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $option   - option can have one of the following values:
;                         $MYSQL_OPTION_MULTI_STATEMENTS_ON  - Enable multiple-statement support
;                         $MYSQL_OPTION_MULTI_STATEMENTS_OFF - Disable multiple-statement support
; Requirement(s):  libmysql.dll
; Return Value(s): Zero for success. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-set-server-option.html
;
;===============================================================================
;
Func _MySQL_Set_Server_Option($MySQL_ptr, $option)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_set_server_option", "ptr", $MySQL_ptr, "dword", $option)
	If @error Then Return SetError(2, 0, 1)
	Return $mysql[0]
EndFunc   ;==>_MySQL_Set_Server_Option

;===============================================================================
;
; Function Name:   _MySQL_Shutdown
; Description::    Asks the database server to shut down. The connected user must
;                    have the SHUTDOWN privilege. MySQL 5.1 servers support only
;                    one type of shutdown; shutdown_level must be equal to $SHUTDOWN_DEFAULT.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $shutdown_level - shudown-level from  mysql_enum_shutdown_level enumeration
; Requirement(s):  libmysql.dll
; Return Value(s): Zero for success. Non-zero if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-shutdown.html
;
;===============================================================================
;
Func _MySQL_Shutdown($MySQL_ptr, $shutdown_level = $SHUTDOWN_DEFAULT)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $mysql = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_shutdown", "ptr", $MySQL_ptr, "dword", $shutdown_level)
	If @error Then Return SetError(2, 0, 1)
	Return $mysql[0]
EndFunc   ;==>_MySQL_Shutdown

;===============================================================================
;
; Function Name:   _MySQL_SQLState
; Description::    Returns a null-terminated string containing the SQLSTATE error code
;                    for the most recently executed SQL statement. The error code
;                    consists of five characters. '00000' means ìno errorî. The values
;                    are specified by ANSI SQL and ODBC.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A null-terminated character string containing the SQLSTATE error code.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-sqlstate.html
;
;===============================================================================
;
Func _MySQL_SQLState($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "str", "mysql_sqlstate", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, "")
	Return $errors[0]
EndFunc   ;==>_MySQL_SQLState

;===============================================================================
;
; Function Name:   _MySQL_SSL_Set
; Description::    used for establishing secure connections using SSL.
;                    It must be called before mysql_real_connect().
;                  mysql_ssl_set() does nothing unless OpenSSL support is
;                    enabled in the client library.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
;                  $key       - is the pathname to the key file.
;                  $cert      - is the pathname to the certificate file.
;                  $ca        - is the pathname to the certificate authority file.
;                  $capath    - is the pathname to a directory that contains trusted SSL CA certificates in pem format.
;                  $cipher    - is a list of allowable ciphers to use for SSL encryption.
;
;                  Any unused SSL parameters may be given as ""(empty string).
; Requirement(s):  libmysql.dll
; Return Value(s): This function always returns 0. If SSL setup is incorrect,
;                   mysql_real_connect() returns an error when you attempt to connect.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-ssl-set.html
;
;===============================================================================
;
Func _MySQL_SSL_Set($MySQL_ptr, $key, $cert, $ca, $capath, $cipher)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $KeyT = "str", $CertT = "str", $CaT = "str", $CapathT = "str", $CipherT = "str"
	If $key = "" Then $KeyT = "ptr"
	If $cert = "" Then $CertT = "ptr"
	If $ca = "" Then $CaT = "ptr"
	If $capath = "" Then $CapathT = "ptr"
	If $cipher = "" Then $CipherT = "ptr"

	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "int", "mysql_ssl_set", "ptr", $MySQL_ptr, $KeyT, $key, $CertT, $cert, $CaT, $ca, $CapathT, $capath, $CipherT, $cipher)
	If @error Then Return SetError(1, 0, 0)
	Return $errors[0]
EndFunc   ;==>_MySQL_SSL_Set

;===============================================================================
;
; Function Name:   _MySQL_Stat
; Description::    Returns a character string containing information similar to
;                    that provided by the mysqladmin status command. This includes
;                    uptime in seconds and the number of running threads, questions,
;                    reloads, and open tables.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A character string describing the server status. NULL if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-stat.html
;
;===============================================================================
;
Func _MySQL_Stat($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "str", "mysql_stat", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, "")
	Return $errors[0]
EndFunc   ;==>_MySQL_Stat

;===============================================================================
;
; Function Name:   _MySQL_Store_Result
; Description::    After invoking mysql_query() or mysql_real_query(), you must call
;                    mysql_store_result() or mysql_use_result() for every statement
;                    that successfully produces a result set (SELECT, SHOW, DESCRIBE,
;                    EXPLAIN, CHECK TABLE, and so forth). You must also call
;                    mysql_free_result() after you are done with the result set.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A MYSQL_RES result structure with the results. NULL (0) if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-store-result.html
;
;===============================================================================
;
Func _MySQL_Store_Result($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $result = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_store_result", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $result[0]
EndFunc   ;==>_MySQL_Store_Result

;===============================================================================
;
; Function Name:   _MySQL_Thread_Id
; Description::    Returns the thread ID of the current connection. This value
;                    can be used as an argument to mysql_kill() to kill the thread.
;                  If the connection is lost and you reconnect with mysql_ping(),
;                    the thread ID changes. This means you should not get the
;                    thread ID and store it for later. You should get it when you need it.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): The thread ID of the current connection.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-thread-id.html
;
;===============================================================================
;
Func _MySQL_Thread_Id($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $result = DllCall($ghMYSQL_LIBMYSQL, "ulong", "mysql_thread_id", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $result[0]
EndFunc   ;==>_MySQL_Thread_Id

;===============================================================================
;
; Function Name:   _MySQL_Use_Result
; Description::    After invoking mysql_query() or mysql_real_query(), you must call
;                    mysql_store_result() or mysql_use_result() for every statement
;                    that successfully produces a result set (SELECT, SHOW, DESCRIBE,
;                    EXPLAIN, CHECK TABLE, and so forth). You must also call
;                    mysql_free_result() after you are done with the result set.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): A MYSQL_RES result structure. NULL if an error occurred.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-use-result.html
;
;===============================================================================
;
Func _MySQL_Use_Result($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, $CR_NULL_POINTER)
	Local $result = DllCall($ghMYSQL_LIBMYSQL, "ptr", "mysql_use_result", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $result[0]
EndFunc   ;==>_MySQL_Use_Result

;===============================================================================
;
; Function Name:   _MySQL_Warning_Count
; Description::    Returns the number of warnings generated during execution of the previous SQL statement.
; Parameter(s):    $MySQL_ptr - Pointer to the MySQL struct
; Requirement(s):  libmysql.dll
; Return Value(s): The warning count.
; Author(s):       Prog@ndy
;
; Further Information: http://dev.mysql.com/doc/refman/5.1/en/mysql-warning-count.html
;
;===============================================================================
;
Func _MySQL_Warning_Count($MySQL_ptr)
	If Not $MySQL_ptr Then Return SetError(3, 0, 0)
	Local $errors = DllCall($ghMYSQL_LIBMYSQL, "uint", "mysql_warning_count", "ptr", $MySQL_ptr)
	If @error Then Return SetError(1, 0, 0)
	Return $errors[0]
EndFunc   ;==>_MySQL_Warning_Count

;###############################################################################


;===============================================================================
;
; Function Name:   __MySQL_ReOrderULONGLONG
; Description::    INTERNAL USE
; Parameter(s):
; Requirement(s):  libmysql.dll
; Return Value(s):
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func __MySQL_ReOrderULONGLONG($UINT64)
	If StringLeft(@AutoItVersion, 5) > "3.3.0" Then ConsoleWrite("! check, if __MySQL_ReOrderULONGLONG is still needed (int64 return fixed?)" & @CRLF)
	Local $int = DllStructCreate("uint64")
	Local $longlong = DllStructCreate("ulong;ulong", DllStructGetPtr($int))
	DllStructSetData($int, 1, $UINT64)
	Return 4294967296 * DllStructGetData($longlong, 1) + DllStructGetData($longlong, 2)
EndFunc   ;==>__MySQL_ReOrderULONGLONG

;===============================================================================
;
; Function Name:   __MySQL_PtrStringLen
; Description::    Gets length for a string by pointer
; Parameter(s):    $ptr       - Pointer to String
;                  $IsUniCode - Is a unicode string default. False
; Requirement(s):  libmysql.dll
; Return Value(s): Length of the string
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func __MySQL_PtrStringLen($ptr, $IsUniCode = False)
	Local $UniCodeFunc = ""
	If $IsUniCode Then $UniCodeFunc = "W"
	Local $Ret = DllCall("kernel32.dll", "int", "lstrlen" & $UniCodeFunc, "ptr", $ptr)
	If @error Then Return SetError(1, 0, -1)
	Return $Ret[0]
EndFunc   ;==>__MySQL_PtrStringLen

;===============================================================================
;
; Function Name:   __MySQL_PtrStringRead
; Description::    Reads a string by pointer
; Parameter(s):    $ptr       - Pointer to String
;                  $IsUniCode - Is a unicode string default. False
; Requirement(s):  libmysql.dll
; Return Value(s): read string
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func __MySQL_PtrStringRead($ptr, $IsUniCode = False, $StringLen = -1)
	Local $UniCodeString = ""
	If $IsUniCode Then $UniCodeString = "W"
	If $StringLen < 1 Then $StringLen = __MySQL_PtrStringLen($ptr, $IsUniCode)
	If $StringLen < 1 Then Return SetError(1, 0, "")
	Local $struct = DllStructCreate($UniCodeString & "char[" & ($StringLen + 1) & "]", $ptr)
	Return DllStructGetData($struct, 1)
EndFunc   ;==>__MySQL_PtrStringRead

#cs
	struct st_mysql_methods;
	struct st_mysql_stmt;

	typedef struct st_mysql
	{
	NET		net;			;/* Communication parameters */
	gptr		connector_fd;		;/* ConnectorFd for SSL */
	char		*host,*user,*passwd,*unix_socket,*server_version,*host_info,*info;
	char          *db;
	struct charset_info_st *charset;
	MYSQL_FIELD	*fields;
	MEM_ROOT	field_alloc;
	my_ulonglong affected_rows;
	my_ulonglong insert_id;		;/* id if insert on table with NEXTNR */
	my_ulonglong extra_info;		;/* Not used */
	unsigned long thread_id;		;/* Id for connection in server */
	unsigned long packet_length;
	unsigned int	port;
	unsigned long client_flag,server_capabilities;
	unsigned int	protocol_version;
	unsigned int	field_count;
	unsigned int 	server_status;
	unsigned int  server_language;
	unsigned int	warning_count;
	struct st_mysql_options options;
	enum mysql_status status;
	my_bool	free_me;		;/* If free in mysql_close */
	my_bool	reconnect;		;/* set to 1 if automatic reconnect */

	;/* session-wide random string */
	char	        scramble[SCRAMBLE_LENGTH+1];

	;/*
	Set if this is the original connection, not a master or a slave we have
	added though mysql_rpl_probe() or mysql_set_master()/ mysql_add_slave()
	*/
	my_bool rpl_pivot;
	;/*
	Pointers to the master, and the next slave connections, points to
	itself if lone connection.
	*/
	struct st_mysql* master, *next_slave;

	struct st_mysql* last_used_slave; ;/* needed for round-robin slave pick */
	;/* needed for send/read/store/use result to work correctly with replication */
	struct st_mysql* last_used_con;

	LIST  *stmts;                     ;/* list of all statements */
	const struct st_mysql_methods *methods;
	void *thd;
	;/*
	Points to boolean flag in MYSQL_RES  or MYSQL_STMT. We set this flag
	from mysql_stmt_close if close had to cancel result set of this object.
	*/
	my_bool *unbuffered_fetch_owner;
	#if defined(EMBEDDED_LIBRARY) || defined(EMBEDDED_LIBRARY_COMPATIBLE) || MYSQL_VERSION_ID >= 50100
	;/* needed for embedded server - no net buffer to store the 'info' */
	char *info_buffer;
	#endif
	} MYSQL;
#ce
#cs
	typedef struct st_mysql_res {
	my_ulonglong row_count;
	MYSQL_FIELD	*fields;
	MYSQL_DATA	*data;
	MYSQL_ROWS	*data_cursor;
	unsigned long *lengths;		;/* column lengths of current row */
	MYSQL		*handle;		;/* for unbuffered reads */
	MEM_ROOT	field_alloc;
	unsigned int	field_count, current_field;
	MYSQL_ROW	row;			;/* If unbuffered read */
	MYSQL_ROW	current_row;		;/* buffer to current row */
	my_bool	eof;			;/* Used by mysql_fetch_row */
	;/* mysql_stmt_close() had to cancel this result */
	my_bool       unbuffered_fetch_cancelled;
	const struct st_mysql_methods *methods;
	} MYSQL_RES;
#ce
Global Const $MAX_MYSQL_MANAGER_ERR = 256
Global Const $MAX_MYSQL_MANAGER_MSG = 256

Global Const $MANAGER_OK = 200
Global Const $MANAGER_INFO = 250
Global Const $MANAGER_ACCESS = 401
Global Const $MANAGER_CLIENT_ERR = 450
Global Const $MANAGER_INTERNAL_ERR = 500

;~ 	#if !defined(MYSQL_SERVER) && !defined(MYSQL_CLIENT)
;~ 	Global Const $MYSQL_CLIENT
;~ 	#endif

#cs

	typedef struct st_mysql_manager
	{
	NET net;
	char *host,*user,*passwd;
	unsigned int port;
	my_bool free_me;
	my_bool eof;
	int cmd_status;
	int last_errno;
	char* net_buf,*net_buf_pos,*net_data_end;
	int net_buf_size;
	char last_error[MAX_MYSQL_MANAGER_ERR];
	} MYSQL_MANAGER;
#ce
#cs
	typedef struct st_mysql_parameters
	{
	unsigned long *p_max_allowed_packet;
	unsigned long *p_net_buffer_length;
	} MYSQL_PARAMETERS;

	#if !defined(MYSQL_SERVER) && !defined(EMBEDDED_LIBRARY)
	Global Const $max_allowed_packet (*mysql_get_parameters()->p_max_allowed_packet)
	Global Const $net_buffer_length (*mysql_get_parameters()->p_net_buffer_length)
	#endif

	;/*
	Set up and bring down the server; to ensure that applications will
	work when linked against either the standard client library or the
	embedded server library, these functions should be called.
	*/
	int STDCALL mysql_server_init(int argc, char **argv, char **groups);
	void STDCALL mysql_server_end(void);
	;/*
	mysql_server_init/end need to be called when using libmysqld or
	libmysqlclient (exactly, mysql_server_init() is called by mysql_init() so
	you don't need to call it explicitely; but you need to call
	mysql_server_end() to free memory). The names are a bit misleading
	(mysql_SERVER* to be used when using libmysqlCLIENT). So we add more general
	names which suit well whether you're using libmysqld or libmysqlclient. We
	intend to promote these aliases over the mysql_server* ones.
	*/
	Global Const $mysql_library_init mysql_server_init
	Global Const $mysql_library_end mysql_server_end

	MYSQL_PARAMETERS *STDCALL mysql_get_parameters(void);

	;/*
	Set up and bring down a thread; these function should be called
	for each thread in an application which opens at least one MySQL
	connection.  All uses of the connection(s) should be between these
	function calls.
	*/
	my_bool STDCALL mysql_thread_init(void);
	void STDCALL mysql_thread_end(void);


	;/* perform query on master */
	my_bool		STDCALL mysql_master_query(MYSQL *mysql, const char *q,
	unsigned long length);
	my_bool		STDCALL mysql_master_send_query(MYSQL *mysql, const char *q,
	unsigned long length);
	;/* perform query on slave */
	my_bool		STDCALL mysql_slave_query(MYSQL *mysql, const char *q,
	unsigned long length);
	my_bool		STDCALL mysql_slave_send_query(MYSQL *mysql, const char *q,
	unsigned long length);
	void        STDCALL mysql_get_character_set_info(MYSQL *mysql,
	MY_CHARSET_INFO *charset);

	;/* local infile support */

	Global Const $LOCAL_INFILE_ERROR_LEN 512

	void
	mysql_set_local_infile_handler(MYSQL *mysql,
	int (*local_infile_init)(void **, const char *,
	void *),
	int (*local_infile_read)(void *, char *,
	unsigned int),
	void (*local_infile_end)(void *),
	int (*local_infile_error)(void *, char*,
	unsigned int),
	void *);

	void
	mysql_set_local_infile_default(MYSQL *mysql);


	;/*
	enable/disable parsing of all queries to decide if they go on master or
	slave
	*/
	void            STDCALL mysql_enable_rpl_parse(MYSQL* mysql);
	void            STDCALL mysql_disable_rpl_parse(MYSQL* mysql);
	;/* get the value of the parse flag */
	int             STDCALL mysql_rpl_parse_enabled(MYSQL* mysql);

	;/*  enable/disable reads from master */
	void            STDCALL mysql_enable_reads_from_master(MYSQL* mysql);
	void            STDCALL mysql_disable_reads_from_master(MYSQL* mysql);
	;/* get the value of the master read flag */
	my_bool		STDCALL mysql_reads_from_master_enabled(MYSQL* mysql);

	enum mysql_rpl_type     STDCALL mysql_rpl_query_type(const char* q, int len);

	;/* discover the master and its slaves */
	my_bool		STDCALL mysql_rpl_probe(MYSQL* mysql);

	;/* set the master, close/free the old one, if it is not a pivot */
	int             STDCALL mysql_set_master(MYSQL* mysql, const char* host,
	unsigned int port,
	const char* user,
	const char* passwd);
	int             STDCALL mysql_add_slave(MYSQL* mysql, const char* host,
	unsigned int port,
	const char* user,
	const char* passwd);


	char *		STDCALL mysql_odbc_escape_string(MYSQL *mysql,
	char *to,
	unsigned long to_length,
	const char *from,
	unsigned long from_length,
	void *param,
	char *
	(*extend_buffer)
	(void *, char *to,
	unsigned long *length));
	void 		STDCALL myodbc_remove_escape(MYSQL *mysql,char *name);
	unsigned int	STDCALL mysql_thread_safe(void);
	my_bool		STDCALL mysql_embedded(void);
	MYSQL_MANAGER*  STDCALL mysql_manager_init(MYSQL_MANAGER* con);
	MYSQL_MANAGER*  STDCALL mysql_manager_connect(MYSQL_MANAGER* con,
	const char* host,
	const char* user,
	const char* passwd,
	unsigned int port);
	void            STDCALL mysql_manager_close(MYSQL_MANAGER* con);
	int             STDCALL mysql_manager_command(MYSQL_MANAGER* con,
	const char* cmd, int cmd_len);
	int             STDCALL mysql_manager_fetch_line(MYSQL_MANAGER* con,
	char* res_buf,
	int res_buf_size);
	my_bool         STDCALL mysql_read_query_result(MYSQL *mysql);


	;/*
	The following definitions are added for the enhanced
	client-server protocol
	*/

	;/* statement state */
	enum enum_mysql_stmt_state
	{
	MYSQL_STMT_INIT_DONE= 1, MYSQL_STMT_PREPARE_DONE, MYSQL_STMT_EXECUTE_DONE,
	MYSQL_STMT_FETCH_DONE
	};


	;/*
	This structure is used to define bind information, and
	internally by the client library.
	Public members with their descriptions are listed below
	(conventionally `On input' refers to the binds given to
	mysql_stmt_bind_param, `On output' refers to the binds given
	to mysql_stmt_bind_result):

	buffer_type    - One of the MYSQL_* types, used to describe
	the host language type of buffer.
	On output: if column type is different from
	buffer_type, column value is automatically converted
	to buffer_type before it is stored in the buffer.
	buffer         - On input: points to the buffer with input data.
	On output: points to the buffer capable to store
	output data.
	The type of memory pointed by buffer must correspond
	to buffer_type. See the correspondence table in
	the comment to mysql_stmt_bind_param.

	The two above members are mandatory for any kind of bind.

	buffer_length  - the length of the buffer. You don't have to set
	it for any fixed length buffer: float, double,
	int, etc. It must be set however for variable-length
	types, such as BLOBs or STRINGs.

	length         - On input: in case when lengths of input values
	are different for each execute, you can set this to
	point at a variable containining value length. This
	way the value length can be different in each execute.
	If length is not NULL, buffer_length is not used.
	Note, length can even point at buffer_length if
	you keep bind structures around while fetching:
	this way you can change buffer_length before
	each execution, everything will work ok.
	On output: if length is set, mysql_stmt_fetch will
	write column length into it.

	is_null        - On input: points to a boolean variable that should
	be set to TRUE for NULL values.
	This member is useful only if your data may be
	NULL in some but not all cases.
	If your data is never NULL, is_null should be set to 0.
	If your data is always NULL, set buffer_type
	to MYSQL_TYPE_NULL, and is_null will not be used.

	is_unsigned    - On input: used to signify that values provided for one
	of numeric types are unsigned.
	On output describes signedness of the output buffer.
	If, taking into account is_unsigned flag, column data
	is out of range of the output buffer, data for this column
	is regarded truncated. Note that this has no correspondence
	to the sign of result set column, if you need to find it out
	use mysql_stmt_result_metadata.
	error          - where to write a truncation error if it is present.
	possible error value is:
	0  no truncation
	1  value is out of range or buffer is too small

	Please note that MYSQL_BIND also has internals members.
	*/

	typedef struct st_mysql_bind
	{
	unsigned long	*length;          ;/* output length pointer */
	my_bool       *is_null;	  ;/* Pointer to null indicator */
	void		*buffer;	  ;/* buffer to get/put data */
	;/* set this if you want to track data truncations happened during fetch */
	my_bool       *error;
	enum enum_field_types buffer_type;	;/* buffer type */
	;/* output buffer length, must be set when fetching str/binary */
	unsigned long buffer_length;
	unsigned char *row_ptr;         ;/* for the current data position */
	unsigned long offset;           ;/* offset position for char/binary fetch */
	unsigned long	length_value;     ;/* Used if length is 0 */
	unsigned int	param_number;	  ;/* For null count and error messages */
	unsigned int  pack_length;	  ;/* Internal length for packed data */
	my_bool       error_value;      ;/* used if error is 0 */
	my_bool       is_unsigned;      ;/* set if integer type is unsigned */
	my_bool	long_data_used;	  ;/* If used with mysql_send_long_data */
	my_bool	is_null_value;    ;/* Used if is_null is 0 */
	void (*store_param_func)(NET *net, struct st_mysql_bind *param);
	void (*fetch_result)(struct st_mysql_bind *, MYSQL_FIELD *,
	unsigned char **row);
	void (*skip_result)(struct st_mysql_bind *, MYSQL_FIELD *,
	unsigned char **row);
	} MYSQL_BIND;


	;/* statement handler */
	typedef struct st_mysql_stmt
	{
	MEM_ROOT       mem_root;             ;/* root allocations */
	LIST           list;                 ;/* list to keep track of all stmts */
	MYSQL          *mysql;               ;/* connection handle */
	MYSQL_BIND     *params;              ;/* input parameters */
	MYSQL_BIND     *bind;                ;/* output parameters */
	MYSQL_FIELD    *fields;              ;/* result set metadata */
	MYSQL_DATA     result;               ;/* cached result set */
	MYSQL_ROWS     *data_cursor;         ;/* current row in cached result */
	;/* copy of mysql->affected_rows after statement execution */
	my_ulonglong   affected_rows;
	my_ulonglong   insert_id;            ;/* copy of mysql->insert_id */
	;/*
	mysql_stmt_fetch() calls this function to fetch one row (it's different
	for buffered, unbuffered and cursor fetch).
	*/
	int            (*read_row_func)(struct st_mysql_stmt *stmt,
	unsigned char **row);
	unsigned long	 stmt_id;	       ;/* Id for prepared statement */
	unsigned long  flags;                ;/* i.e. type of cursor to open */
	unsigned long  prefetch_rows;        ;/* number of rows per one COM_FETCH */
	;/*
	Copied from mysql->server_status after execute/fetch to know
	server-side cursor status for this statement.
	*/
	unsigned int   server_status;
	unsigned int	 last_errno;	       ;/* error code */
	unsigned int   param_count;          ;/* input parameter count */
	unsigned int   field_count;          ;/* number of columns in result set */
	enum enum_mysql_stmt_state state;    ;/* statement state */
	char		 last_error[MYSQL_ERRMSG_SIZE]; ;/* error message */
	char		 sqlstate[SQLSTATE_LENGTH+1];
	;/* Types of input parameters should be sent to server */
	my_bool        send_types_to_server;
	my_bool        bind_param_done;      ;/* input buffers were supplied */
	unsigned char  bind_result_done;     ;/* output buffers were supplied */
	;/* mysql_stmt_close() had to cancel this result */
	my_bool       unbuffered_fetch_cancelled;
	;/*
	Is set to true if we need to calculate field->max_length for
	metadata fields when doing mysql_stmt_store_result.
	*/
	my_bool       update_max_length;
	} MYSQL_STMT;

	enum enum_stmt_attr_type
	{
	;/*
	When doing mysql_stmt_store_result calculate max_length attribute
	of statement metadata. This is to be consistent with the old API,
	where this was done automatically.
	In the new API we do that only by request because it slows down
	mysql_stmt_store_result sufficiently.
	*/
	STMT_ATTR_UPDATE_MAX_LENGTH,
	;/*
	unsigned long with combination of cursor flags (read only, for update,
	etc)
	*/
	STMT_ATTR_CURSOR_TYPE,
	;/*
	Amount of rows to retrieve from server per one fetch if using cursors.
	Accepts unsigned long attribute in the range 1 - ulong_max
	*/
	STMT_ATTR_PREFETCH_ROWS
	};


	typedef struct st_mysql_methods
	{
	my_bool (*read_query_result)(MYSQL *mysql);
	my_bool (*advanced_command)(MYSQL *mysql,
	enum enum_server_command command,
	const char *header,
	unsigned long header_length,
	const char *arg,
	unsigned long arg_length,
	my_bool skip_check,
	MYSQL_STMT *stmt);
	MYSQL_DATA *(*read_rows)(MYSQL *mysql,MYSQL_FIELD *mysql_fields,
	unsigned int fields);
	MYSQL_RES * (*use_result)(MYSQL *mysql);
	void (*fetch_lengths)(unsigned long *to,
	MYSQL_ROW column, unsigned int field_count);
	void (*flush_use_result)(MYSQL *mysql);
	#if !defined(MYSQL_SERVER) || defined(EMBEDDED_LIBRARY)
	MYSQL_FIELD * (*list_fields)(MYSQL *mysql);
	my_bool (*read_prepare_result)(MYSQL *mysql, MYSQL_STMT *stmt);
	int (*stmt_execute)(MYSQL_STMT *stmt);
	int (*read_binary_rows)(MYSQL_STMT *stmt);
	int (*unbuffered_fetch)(MYSQL *mysql, char **row);
	void (*free_embedded_thd)(MYSQL *mysql);
	const char *(*read_statistics)(MYSQL *mysql);
	my_bool (*next_result)(MYSQL *mysql);
	int (*read_change_user_result)(MYSQL *mysql, char *buff, const char *passwd);
	int (*read_rows_from_cursor)(MYSQL_STMT *stmt);
	#endif
	} MYSQL_METHODS;


	MYSQL_STMT * STDCALL mysql_stmt_init(MYSQL *mysql);
	int STDCALL mysql_stmt_prepare(MYSQL_STMT *stmt, const char *query,
	unsigned long length);
	int STDCALL mysql_stmt_execute(MYSQL_STMT *stmt);
	int STDCALL mysql_stmt_fetch(MYSQL_STMT *stmt);
	int STDCALL mysql_stmt_fetch_column(MYSQL_STMT *stmt, MYSQL_BIND *bind_arg,
	unsigned int column,
	unsigned long offset);
	int STDCALL mysql_stmt_store_result(MYSQL_STMT *stmt);
	unsigned long STDCALL mysql_stmt_param_count(MYSQL_STMT * stmt);
	my_bool STDCALL mysql_stmt_attr_set(MYSQL_STMT *stmt,
	enum enum_stmt_attr_type attr_type,
	const void *attr);
	my_bool STDCALL mysql_stmt_attr_get(MYSQL_STMT *stmt,
	enum enum_stmt_attr_type attr_type,
	void *attr);
	my_bool STDCALL mysql_stmt_bind_param(MYSQL_STMT * stmt, MYSQL_BIND * bnd);
	my_bool STDCALL mysql_stmt_bind_result(MYSQL_STMT * stmt, MYSQL_BIND * bnd);
	my_bool STDCALL mysql_stmt_close(MYSQL_STMT * stmt);
	my_bool STDCALL mysql_stmt_reset(MYSQL_STMT * stmt);
	my_bool STDCALL mysql_stmt_free_result(MYSQL_STMT *stmt);
	my_bool STDCALL mysql_stmt_send_long_data(MYSQL_STMT *stmt,
	unsigned int param_number,
	const char *data,
	unsigned long length);
	MYSQL_RES *STDCALL mysql_stmt_result_metadata(MYSQL_STMT *stmt);
	MYSQL_RES *STDCALL mysql_stmt_param_metadata(MYSQL_STMT *stmt);
	unsigned int STDCALL mysql_stmt_errno(MYSQL_STMT * stmt);
	const char *STDCALL mysql_stmt_error(MYSQL_STMT * stmt);
	const char *STDCALL mysql_stmt_sqlstate(MYSQL_STMT * stmt);
	MYSQL_ROW_OFFSET STDCALL mysql_stmt_row_seek(MYSQL_STMT *stmt,
	MYSQL_ROW_OFFSET offset);
	MYSQL_ROW_OFFSET STDCALL mysql_stmt_row_tell(MYSQL_STMT *stmt);
	void STDCALL mysql_stmt_data_seek(MYSQL_STMT *stmt, my_ulonglong offset);
	my_ulonglong STDCALL mysql_stmt_num_rows(MYSQL_STMT *stmt);
	my_ulonglong STDCALL mysql_stmt_affected_rows(MYSQL_STMT *stmt);
	my_ulonglong STDCALL mysql_stmt_insert_id(MYSQL_STMT *stmt);
	unsigned int STDCALL mysql_stmt_field_count(MYSQL_STMT *stmt);

	my_bool STDCALL mysql_commit(MYSQL * mysql);
	my_bool STDCALL mysql_rollback(MYSQL * mysql);
	my_bool STDCALL mysql_autocommit(MYSQL * mysql, my_bool auto_mode);
	my_bool STDCALL mysql_more_results(MYSQL *mysql);
	int STDCALL mysql_next_result(MYSQL *mysql);
	void STDCALL mysql_close(MYSQL *sock);


	;/* status return codes */
	Global Const $MYSQL_NO_DATA        = 100
	Global Const $MYSQL_DATA_TRUNCATED = 101

	Global Const $mysql_reload(mysql) mysql_refresh((mysql),REFRESH_GRANT)

	#ifdef USE_OLD_FUNCTIONS
	MYSQL *		STDCALL mysql_connect(MYSQL *mysql, const char *host,
	const char *user, const char *passwd);
	int		STDCALL mysql_create_db(MYSQL *mysql, const char *DB);
	int		STDCALL mysql_drop_db(MYSQL *mysql, const char *DB);
	#define	 mysql_reload(mysql) mysql_refresh((mysql),REFRESH_GRANT)
	#endif
	Global Const $HAVE_MYSQL_REAL_CONNECT
#ce
;~ ;/*
;~   The following functions are mainly exported because of mysqlbinlog;
;~   They are not for general usage
;~ */

;~ simple_command(mysql, command, arg, length, skip_check) \
;~   (*(mysql)->methods->advanced_command)(mysql, command, NullS,  \
;~                                         0, arg, length, skip_check, NULL)
;~ stmt_command(mysql, command, arg, length, stmt) \
;~   (*(mysql)->methods->advanced_command)(mysql, command, NullS,  \
;~                                         0, arg, length, 1, stmt)

;~ #ifdef __NETWARE__
;~ #pragma pack(pop)		;/* restore alignment */
;~ #endif