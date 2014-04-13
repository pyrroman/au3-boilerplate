#include-once
;~ ;/* Copyright (C) 2000 MySQL AB

;~    This program is free software; you can redistribute it and/or modify
;~    it under the terms of the GNU General Public License as published by
;~    the Free Software Foundation; version 2 of the License.

;~    This program is distributed in the hope that it will be useful,
;~    but WITHOUT ANY WARRANTY; without even the implied warranty of
;~    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;~    GNU General Public License for more details.

;~    You should have received a copy of the GNU General Public License
;~    along with this program; if not, write to the Free Software
;~    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA */

;~ ;/*
;~ ** Common definition between mysql server & client
;~ */

;~ #ifndef _mysql_com_h
;~ Global Const $_mysql_com_h

Global Const $NAME_LEN	= 64		;/* Field/table name length */
Global Const $HOSTNAME_LENGTH = 60
Global Const $USERNAME_LENGTH = 16
Global Const $SERVER_VERSION_LENGTH = 60
Global Const $SQLSTATE_LENGTH = 5

;~ ;/*
;~   USER_HOST_BUFF_SIZE -- length of string buffer, that is enough to contain
;~   username and hostname parts of the user identifier with trailing zero in
;~   MySQL standard format:
;~   user_name_part@host_name_part\0
;~ */
Global Const $USER_HOST_BUFF_SIZE = $HOSTNAME_LENGTH + $USERNAME_LENGTH + 2

Global Const $LOCAL_HOST	= "localhost"
Global Const $LOCAL_HOST_NAMEDPIPE = "."


If Not IsDeclared("_CUSTOMCONFIG_") Then
	Global Const $MYSQL_NAMEDPIPE = "MySQL"
	Global Const $MYSQL_SERVICENAME = "MySQL"
EndIf

;~ ;/*
;~   You should add new commands to the end of this list, otherwise old
;~   servers won't be able to handle them as 'unsupported'.
;~ */

;~ enum enum_server_command
Global Enum _
  $COM_SLEEP, $COM_QUIT, $COM_INIT_DB, $COM_QUERY, $COM_FIELD_LIST, _
  $COM_CREATE_DB, $COM_DROP_DB, $COM_REFRESH, $COM_SHUTDOWN, $COM_STATISTICS, _
  $COM_PROCESS_INFO, $COM_CONNECT, $COM_PROCESS_KILL, $COM_DEBUG, $COM_PING, _
  $COM_TIME, $COM_DELAYED_INSERT, $COM_CHANGE_USER, $COM_BINLOG_DUMP, _
  $COM_TABLE_DUMP, $COM_CONNECT_OUT, $COM_REGISTER_SLAVE, _
  $COM_STMT_PREPARE, $COM_STMT_EXECUTE, $COM_STMT_SEND_LONG_DATA, $COM_STMT_CLOSE, _
  $COM_STMT_RESET, $COM_SET_OPTION, $COM_STMT_FETCH, _
  $COM_END


;~ ;/*
;~   Length of random string sent by server on handshake; this is also length of
;~   obfuscated password, recieved from client
;~ */
Global Const $SCRAMBLE_LENGTH = 20
Global Const $SCRAMBLE_LENGTH_323 = 8
;~ ;/* length of password stored in the db: new passwords are preceeded with '*' */
Global Const $SCRAMBLED_PASSWORD_CHAR_LENGTH = ($SCRAMBLE_LENGTH*2+1)
Global Const $SCRAMBLED_PASSWORD_CHAR_LENGTH_323 = ($SCRAMBLE_LENGTH_323*2)


Global Const $NOT_NULL_FLAG	= 1		;/* Field can't be NULL */
Global Const $PRI_KEY_FLAG	= 2		;/* Field is part of a primary key */
Global Const $UNIQUE_KEY_FLAG = 4		;/* Field is part of a unique key */
Global Const $MULTIPLE_KEY_FLAG = 8		;/* Field is part of a key */
Global Const $BLOB_FLAG	= 16		;/* Field is a blob */
Global Const $UNSIGNED_FLAG	= 32		;/* Field is unsigned */
Global Const $ZEROFILL_FLAG	= 64		;/* Field is zerofill */
Global Const $BINARY_FLAG	= 128		;/* Field is binary   */

;/* The following are only sent to new clients */
Global Const $ENUM_FLAG	= 256		;/* field is an enum */
Global Const $AUTO_INCREMENT_FLAG = 512		;/* field is a autoincrement field */
Global Const $TIMESTAMP_FLAG	= 1024		;/* Field is a timestamp */
Global Const $SET_FLAG	= 2048		;/* field is a set */
Global Const $NO_DEFAULT_VALUE_FLAG = 4096	;/* Field doesn't have default value */
Global Const $NUM_FLAG	= 32768		;/* Field is num (for clients) */
Global Const $PART_KEY_FLAG	= 16384		;/* Intern; Part of some key */
Global Const $GROUP_FLAG	= 32768		;/* Intern: Group field */
Global Const $UNIQUE_FLAG	= 65536		;/* Intern: Used by sql_yacc */
Global Const $BINCMP_FLAG	= 131072		;/* Intern: Used by sql_yacc */

Global Const $REFRESH_GRANT		= 1	;/* Refresh grant tables */
Global Const $REFRESH_LOG		= 2	;/* Start on new log file */
Global Const $REFRESH_TABLES		= 4	;/* close all tables */
Global Const $REFRESH_HOSTS		= 8	;/* Flush host cache */
Global Const $REFRESH_STATUS		= 16	;/* Flush status variables */
Global Const $REFRESH_THREADS		= 32	;/* Flush thread cache */
Global Const $REFRESH_SLAVE           = 64      ;/* Reset master info and restart slave thread */
Global Const $REFRESH_MASTER          = 128     ;/* Remove all bin logs in the index and truncate the index */

;/* The following can't be set with mysql_refresh() */
Global Const $REFRESH_READ_LOCK	= 16384	;/* Lock tables for read */
Global Const $REFRESH_FAST		= 32768	;/* Intern flag */

;/* RESET (remove all queries) from query cache */
Global Const $REFRESH_QUERY_CACHE	= 65536
Global Const $REFRESH_QUERY_CACHE_FREE = 0x20000 ;/* pack query cache */
Global Const $REFRESH_DES_KEY_FILE	= 0x40000
Global Const $REFRESH_USER_RESOURCES	= 0x80000

Global Const $CLIENT_LONG_PASSWORD	= 1	;/* new more secure passwords */
Global Const $CLIENT_FOUND_ROWS	= 2	;/* Found instead of affected rows */
Global Const $CLIENT_LONG_FLAG	= 4	;/* Get all column flags */
Global Const $CLIENT_CONNECT_WITH_DB	= 8	;/* One can specify db on connect */
Global Const $CLIENT_NO_SCHEMA	= 16	;/* Don't allow database.table.column */
Global Const $CLIENT_COMPRESS		= 32	;/* Can use compression protocol */
Global Const $CLIENT_ODBC		= 64	;/* Odbc client */
Global Const $CLIENT_LOCAL_FILES	= 128	;/* Can use LOAD DATA LOCAL */
Global Const $CLIENT_IGNORE_SPACE	= 256	;/* Ignore spaces before '(' */
Global Const $CLIENT_PROTOCOL_41	= 512	;/* New 4.1 protocol */
Global Const $CLIENT_INTERACTIVE	= 1024	;/* This is an interactive client */
Global Const $CLIENT_SSL              = 2048	;/* Switch to SSL after handshake */
Global Const $CLIENT_IGNORE_SIGPIPE   = 4096    ;/* IGNORE sigpipes */
Global Const $CLIENT_TRANSACTIONS	= 8192	;/* Client knows about transactions */
Global Const $CLIENT_RESERVED         = 16384   ;/* Old flag for 4.1 protocol  */
Global Const $CLIENT_SECURE_CONNECTION = 32768  ;/* New 4.1 authentication */
Global Const $CLIENT_MULTI_STATEMENTS = BitShift(1,-16) ;/* Enable/disable multi-stmt support */
Global Const $CLIENT_MULTI_RESULTS    = BitShift(1,-17) ;/* Enable/disable multi-results */

Global Const $CLIENT_SSL_VERIFY_SERVER_CERT = BitShift(1,-30)
Global Const $CLIENT_REMEMBER_OPTIONS = BitShift(1,-31)


Global Const $SERVER_STATUS_IN_TRANS     = 1	;/* Transaction has started */
Global Const $SERVER_STATUS_AUTOCOMMIT   = 2	;/* Server in auto_commit mode */
Global Const $SERVER_MORE_RESULTS_EXISTS = 8    ;/* Multi query - next query exists */
Global Const $SERVER_QUERY_NO_GOOD_INDEX_USED = 16
Global Const $SERVER_QUERY_NO_INDEX_USED      = 32
;~ ;/*
;~   The server was able to fulfill the clients request and opened a
;~   read-only non-scrollable cursor for a query. This flag comes
;~   in reply to COM_STMT_EXECUTE and COM_STMT_FETCH commands.
;~ */
Global Const $SERVER_STATUS_CURSOR_EXISTS = 64
;~ ;/*
;~   This flag is sent when a read-only cursor is exhausted, in reply to
;~   COM_STMT_FETCH command.
;~ */
Global Const $SERVER_STATUS_LAST_ROW_SENT = 128
Global Const $SERVER_STATUS_DB_DROPPED        = 256 ;/* A database was dropped */
Global Const $SERVER_STATUS_NO_BACKSLASH_ESCAPES = 512

Global Const $MYSQL_ERRMSG_SIZE	= 512
Global Const $NET_READ_TIMEOUT	= 30		;/* Timeout on read */
Global Const $NET_WRITE_TIMEOUT	= 60		;/* Timeout on write */
Global Const $NET_WAIT_TIMEOUT	= 8*60*60		;/* Wait for new query */

Global Const $ONLY_KILL_QUERY         = 1

;~ struct st_vio;					;/* Only C */
;~ typedef struct st_vio Vio;

Global Const $MAX_TINYINT_WIDTH       = 3       ;/* Max width for a TINY w.o. sign */
Global Const $MAX_SMALLINT_WIDTH      = 5       ;/* Max width for a SHORT w.o. sign */
Global Const $MAX_MEDIUMINT_WIDTH     = 8       ;/* Max width for a INT24 w.o. sign */
Global Const $MAX_INT_WIDTH           = 10      ;/* Max width for a LONG w.o. sign */
Global Const $MAX_BIGINT_WIDTH        = 20      ;/* Max width for a LONGLONG */
Global Const $MAX_CHAR_WIDTH		= 255	;/* Max length for a CHAR colum */
Global Const $MAX_BLOB_WIDTH		= 8192	;/* Default width for blob */

;~ typedef struct st_net {
;~ #if !defined(CHECK_EMBEDDED_DIFFERENCES) || !defined(EMBEDDED_LIBRARY)
;~   Vio* vio;
;~   unsigned char *buff,*buff_end,*write_pos,*read_pos;
;~   my_socket fd;					;/* For Perl DBI/dbd */
;~   unsigned long max_packet,max_packet_size;
;~   unsigned int pkt_nr,compress_pkt_nr;
;~   unsigned int write_timeout, read_timeout, retry_count;
;~   int fcntl;
;~   my_bool compress;
;~   ;/*
;~     The following variable is set if we are doing several queries in one
;~     command ( as in LOAD TABLE ... FROM MASTER ),
;~     and do not want to confuse the client with OK at the wrong time
;~   */
;~   unsigned long remain_in_buf,length, buf_length, where_b;
;~   unsigned int *return_status;
;~   unsigned char reading_or_writing;
;~   char save_char;
;~   my_bool no_send_ok;  ;/* For SPs and other things that do multiple stmts */
;~   my_bool no_send_eof; ;/* For SPs' first version read-only cursors */
;~   ;/*
;~     Set if OK packet is already sent, and we do not need to send error
;~     messages
;~   */
;~   my_bool no_send_error;
;~   ;/*
;~     Pointer to query object in query cache, do not equal NULL (0) for
;~     queries in cache that have not stored its results yet
;~   */
;~ #endif
;~   char last_error[MYSQL_ERRMSG_SIZE], sqlstate[SQLSTATE_LENGTH+1];
;~   unsigned int last_errno;
;~   unsigned char error;

;~   ;/*
;~     'query_cache_query' should be accessed only via query cache
;~     functions and methods to maintain proper locking.
;~   */
;~   gptr query_cache_query;

;~   my_bool report_error; ;/* We should report error (we have unreported error) */
;~   my_bool return_errno;
;~ } NET;

Global Const $st_net = _
  "ptr vio;" & _ ;
  "ptr buff;" & _ ;
  "ptr buffEnd;" & _ ;
  "ptr writePos;" & _ ;
  "ptr readPos;" & _ ;
  "int fd;" & _ ;					;/* For Perl DBI/dbd */
  "ulong maxPacket;" & _ ;
  "ulong maxPacketSize;" & _ ;
  "uint pktNr;" & _ ;
  "uint compressPktNr;" & _ ;
  "uint writeTimeout;" & _ ;
  "uint readTimeout;" & _ ;
  "uint retryCount;" & _ ;
  "int fcntl;" & _ ;
  "int compress;" & _ ;
    "" & _ ;The following variable is set if we are doing several queries in one
    "" & _ ;command ( as in LOAD TABLE ... FROM MASTER ),
    "" & _ ;and do not want to confuse the client with OK at the wrong time
  "ulong remainInBuf;" & _ ;
  "ulong length;" & _ ;
  "ulong bufLength;" & _ ;
  "ulong whereB;" & _ ;
  "ptr returnStatus;" & _ ;
  "ubyte readingOrWriting;" & _ ;
  "byte saveChar;" & _ ;
  "int noSendOk;" & _ ;  ;/* For SPs and other things that do multiple stmts */
  "int noSendEof;" & _ ; ;/* For SPs' first version read-only cursors */
    "" & _ ;Set if OK packet is already sent, and we do not need to send error
    "" & _ ;messages
  "int noSendError;" & _ ;
    "" & _ ;Pointer to query object in query cache, do not equal NULL (0) for
    "" & _ ;queries in cache that have not stored its results yet
  "char lastError[" & $MYSQL_ERRMSG_SIZE & "];" & _ ;
  "char sqlstate[" & $SQLSTATE_LENGTH+1 & "];" & _ ;
  "uint lastErrno;" & _ ;
  "ubyte error;" & _ ;
    "" & _ ;'query_cache_query' should be accessed only via query cache
    "" & _ ;functions and methods to maintain proper locking.
  "ptr queryCacheQuery;" & _ ;
  "int reportError;" & _ ; ;/* We should report error (we have unreported error) */
  "int returnErrno;"
;~ } NET;

;~ Global Const $packet_error (~(unsigned long) 0)

;~ enum enum_field_types { MYSQL_TYPE_DECIMAL, MYSQL_TYPE_TINY,
Global Enum $MYSQL_TYPE_DECIMAL, $MYSQL_TYPE_TINY, _
			$MYSQL_TYPE_SHORT,  $MYSQL_TYPE_LONG, _
			$MYSQL_TYPE_FLOAT,  $MYSQL_TYPE_DOUBLE, _
			$MYSQL_TYPE_NULL,   $MYSQL_TYPE_TIMESTAMP, _
			$MYSQL_TYPE_LONGLONG,$MYSQL_TYPE_INT24, _
			$MYSQL_TYPE_DATE,   $MYSQL_TYPE_TIME, _
			$MYSQL_TYPE_DATETIME, $MYSQL_TYPE_YEAR, _
			$MYSQL_TYPE_NEWDATE, $MYSQL_TYPE_VARCHAR, _
			$MYSQL_TYPE_BIT, _
                        $MYSQL_TYPE_NEWDECIMAL=246, _
			$MYSQL_TYPE_ENUM=247, _
			$MYSQL_TYPE_SET=248, _
			$MYSQL_TYPE_TINY_BLOB=249, _
			$MYSQL_TYPE_MEDIUM_BLOB=250, _
			$MYSQL_TYPE_LONG_BLOB=251, _
			$MYSQL_TYPE_BLOB=252, _
			$MYSQL_TYPE_VAR_STRING=253, _
			$MYSQL_TYPE_STRING=254, _
			$MYSQL_TYPE_GEOMETRY=255
;~ };

;/* For backward compatibility */
Global Const $CLIENT_MULTI_QUERIES  = $CLIENT_MULTI_STATEMENTS    
Global Const $FIELD_TYPE_DECIMAL    = $MYSQL_TYPE_DECIMAL
Global Const $FIELD_TYPE_NEWDECIMAL = $MYSQL_TYPE_NEWDECIMAL
Global Const $FIELD_TYPE_TINY       = $MYSQL_TYPE_TINY
Global Const $FIELD_TYPE_SHORT      = $MYSQL_TYPE_SHORT
Global Const $FIELD_TYPE_LONG       = $MYSQL_TYPE_LONG
Global Const $FIELD_TYPE_FLOAT      = $MYSQL_TYPE_FLOAT
Global Const $FIELD_TYPE_DOUBLE     = $MYSQL_TYPE_DOUBLE
Global Const $FIELD_TYPE_NULL       = $MYSQL_TYPE_NULL
Global Const $FIELD_TYPE_TIMESTAMP  = $MYSQL_TYPE_TIMESTAMP
Global Const $FIELD_TYPE_LONGLONG   = $MYSQL_TYPE_LONGLONG
Global Const $FIELD_TYPE_INT24      = $MYSQL_TYPE_INT24
Global Const $FIELD_TYPE_DATE       = $MYSQL_TYPE_DATE
Global Const $FIELD_TYPE_TIME       = $MYSQL_TYPE_TIME
Global Const $FIELD_TYPE_DATETIME   = $MYSQL_TYPE_DATETIME
Global Const $FIELD_TYPE_YEAR       = $MYSQL_TYPE_YEAR
Global Const $FIELD_TYPE_NEWDATE    = $MYSQL_TYPE_NEWDATE
Global Const $FIELD_TYPE_ENUM       = $MYSQL_TYPE_ENUM
Global Const $FIELD_TYPE_SET        = $MYSQL_TYPE_SET
Global Const $FIELD_TYPE_TINY_BLOB  = $MYSQL_TYPE_TINY_BLOB
Global Const $FIELD_TYPE_MEDIUM_BLOB= $MYSQL_TYPE_MEDIUM_BLOB
Global Const $FIELD_TYPE_LONG_BLOB  = $MYSQL_TYPE_LONG_BLOB
Global Const $FIELD_TYPE_BLOB       = $MYSQL_TYPE_BLOB
Global Const $FIELD_TYPE_VAR_STRING = $MYSQL_TYPE_VAR_STRING
Global Const $FIELD_TYPE_STRING     = $MYSQL_TYPE_STRING
Global Const $FIELD_TYPE_CHAR       = $MYSQL_TYPE_TINY
Global Const $FIELD_TYPE_INTERVAL   = $MYSQL_TYPE_ENUM
Global Const $FIELD_TYPE_GEOMETRY   = $MYSQL_TYPE_GEOMETRY
Global Const $FIELD_TYPE_BIT        = $MYSQL_TYPE_BIT


;/* Shutdown/kill enums and constants */ 

;/* Bits for THD::killable. */
Global Const $MYSQL_SHUTDOWN_KILLABLE_CONNECT    =1;(unsigned char)(1 << 0)
Global Const $MYSQL_SHUTDOWN_KILLABLE_TRANS      =BitShift(1,-1);(unsigned char)(1 << 1)
Global Const $MYSQL_SHUTDOWN_KILLABLE_LOCK_TABLE =BitShift(1,-2);(unsigned char)(1 << 2)
Global Const $MYSQL_SHUTDOWN_KILLABLE_UPDATE     =BitShift(1,-3);(unsigned char)(1 << 3)

;~ enum mysql_enum_shutdown_level {
;~   ;/*
;~     We want levels to be in growing order of hardness (because we use number
;~     comparisons). Note that DEFAULT does not respect the growing property, but
;~     it's ok.
;~   */
  Global Const $SHUTDOWN_DEFAULT = 0
  ;/* wait for existing connections to finish */
  Global Const $SHUTDOWN_WAIT_CONNECTIONS= $MYSQL_SHUTDOWN_KILLABLE_CONNECT
  ;/* wait for existing trans to finish */
  Global Const $SHUTDOWN_WAIT_TRANSACTIONS= $MYSQL_SHUTDOWN_KILLABLE_TRANS
  ;/* wait for existing updates to finish (=> no partial MyISAM update) */
  Global Const $SHUTDOWN_WAIT_UPDATES= $MYSQL_SHUTDOWN_KILLABLE_UPDATE
  ;/* flush InnoDB buffers and other storage engines' buffers*/
  Global Const $SHUTDOWN_WAIT_ALL_BUFFERS= BitShift($MYSQL_SHUTDOWN_KILLABLE_UPDATE , -1)
  ;/* don't flush InnoDB buffers, flush other storage engines' buffers*/
  Global Const $SHUTDOWN_WAIT_CRITICAL_BUFFERS= BitShift($MYSQL_SHUTDOWN_KILLABLE_UPDATE , -1) + 1
  ;/* Now the 2 levels of the KILL command */
;~ #if MYSQL_VERSION_ID >= 50000
  Global Const $KILL_QUERY= 254
;~ #endif
  Global Const $KILL_CONNECTION= 255
;~ };


;~ enum enum_cursor_type
;~ {
  Global Const $CURSOR_TYPE_NO_CURSOR= 0
  Global Const $CURSOR_TYPE_READ_ONLY= 1
  Global Const $CURSOR_TYPE_FOR_UPDATE= 2
  Global Const $CURSOR_TYPE_SCROLLABLE= 4
;~ };


;/* options for mysql_set_option */
;~ enum enum_mysql_set_option
Global Enum _
  $MYSQL_OPTION_MULTI_STATEMENTS_ON, _
  $MYSQL_OPTION_MULTI_STATEMENTS_OFF
;~ };
#cs
Func net_new_transaction(ByRef $net)
	DllStructSetData($net,"pktNr",0)
EndFunc

Func my_net_init(ByRef $net, ByRef $vio)
;~ 	my_bool	my_net_init(NET *net, Vio* vio);
	Local $ret = DllCall("libmysql.dll","int","my_net_init","ptr",DllStructGetPtr($net),"ptr",DllStructGetPtr($vio))
	Return $ret[0]
EndFunc

void	my_net_local_init(NET *net);
void	net_end(NET *net);
void	net_clear(NET *net);
my_bool net_realloc(NET *net, unsigned long length);
my_bool	net_flush(NET *net);
my_bool	my_net_write(NET *net,const char *packet,unsigned long len);
my_bool	net_write_command(NET *net,unsigned char command,
			  const char *header, unsigned long head_len,
			  const char *packet, unsigned long len);
int	net_real_write(NET *net,const char *packet,unsigned long len);
unsigned long my_net_read(NET *net);

#ifdef _global_h
void my_net_set_write_timeout(NET *net, uint timeout);
void my_net_set_read_timeout(NET *net, uint timeout);
#endif

;/*
  The following function is not meant for normal usage
  Currently it's used internally by manager.c
*/
struct sockaddr;
int my_connect(my_socket s, const struct sockaddr *name, unsigned int namelen,
	       unsigned int timeout);

struct rand_struct {
  unsigned long seed1,seed2,max_value;
  double max_value_dbl;
};


  ;/* The following is for user defined functions */

enum Item_result {STRING_RESULT=0, REAL_RESULT, INT_RESULT, ROW_RESULT,
                  DECIMAL_RESULT};

typedef struct st_udf_args
{
  unsigned int arg_count;		;/* Number of arguments */
  enum Item_result *arg_type;		;/* Pointer to item_results */
  char **args;				;/* Pointer to argument */
  unsigned long *lengths;		;/* Length of string arguments */
  char *maybe_null;			;/* Set to 1 for all maybe_null args */
  char **attributes;                    ;/* Pointer to attribute name */
  unsigned long *attribute_lengths;     ;/* Length of attribute arguments */
} UDF_ARGS;

  ;/* This holds information about the result */

typedef struct st_udf_init
{
  my_bool maybe_null;			;/* 1 if function can return NULL */
  unsigned int decimals;		;/* for real functions */
  unsigned long max_length;		;/* For string functions */
  char	  *ptr;				;/* free pointer for function data */
  my_bool const_item;			;/* 0 if result is independent of arguments */
} UDF_INIT;

  ;/* Constants when using compression */
Global Const $NET_HEADER_SIZE 4		;/* standard header size */
Global Const $COMP_HEADER_SIZE 3		;/* compression header extra size */

  ;/* Prototypes to password functions */

;/*
  These functions are used for authentication by client and server and
  implemented in sql/password.c
*/

void randominit(struct rand_struct *, unsigned long seed1,
                unsigned long seed2);
double my_rnd(struct rand_struct *);
void create_random_string(char *to, unsigned int length, struct rand_struct *rand_st);

void hash_password(unsigned long *to, const char *password, unsigned int password_len);
void make_scrambled_password_323(char *to, const char *password);
void scramble_323(char *to, const char *message, const char *password);
my_bool check_scramble_323(const char *, const char *message,
                           unsigned long *salt);
void get_salt_from_password_323(unsigned long *res, const char *password);
void make_password_from_salt_323(char *to, const unsigned long *salt);

void make_scrambled_password(char *to, const char *password);
void scramble(char *to, const char *message, const char *password);
my_bool check_scramble(const char *reply, const char *message,
                       const unsigned char *hash_stage2);
void get_salt_from_password(unsigned char *res, const char *password);
void make_password_from_salt(char *to, const unsigned char *hash_stage2);
char *octet2hex(char *to, const char *str, unsigned int len);

;/* end of password.c */

char *get_tty_password(char *opt_message);
const char *mysql_errno_to_sqlstate(unsigned int mysql_errno);

;/* Some other useful functions */

my_bool my_init(void);
extern int modify_defaults_file(const char *file_location, const char *option,
                                const char *option_value,
                                const char *section_name, int remove_option);
int load_defaults(const char *conf_file, const char **groups,
		  int *argc, char ***argv);
my_bool my_thread_init(void);
void my_thread_end(void);

#ifdef _global_h
ulong STDCALL net_field_length(uchar **packet);
my_ulonglong net_field_length_ll(uchar **packet);
char *net_store_length(char *pkg, ulonglong length);
#endif

;~ Global Const $NULL_LENGTH ((unsigned long) ~0) ;/* For net_store_length */
Global Const $MYSQL_STMT_HEADER       = 4
Global Const $MYSQL_LONG_DATA_HEADER  = 6
#ce