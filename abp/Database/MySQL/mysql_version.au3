;~ /* Copyright Abandoned 1996, 1999, 2001 MySQL AB
;~    This file is public domain and comes with NO WARRANTY of any kind */

;~ /* Version numbers for protocol & mysqld */

If Not IsDeclared("_CUSTOMCONFIG_") Then
Global Const $PROTOCOL_VERSION		= 10
Global Const $MYSQL_SERVER_VERSION	= 	"5.1.37"
Global Const $MYSQL_BASE_VERSION	= 	"mysqld-5.1"
Global Const $MYSQL_SERVER_SUFFIX_DEF	= 	"-community-nt"
Global Const $FRM_VER				= 6
Global Const $MYSQL_VERSION_ID		= 50137
Global Const $MYSQL_PORT			= 3306
Global Const $MYSQL_UNIX_ADDR		= 	"/tmp/mysql.sock"
Global Const $MYSQL_CONFIG_NAME		= "my"
Global Const $MYSQL_COMPILATION_COMMENT	= "MySQL Community Edition (GPL)"
EndIf

;~ #ifndef LICENSE
;~ #define LICENSE				GPL
;~ #endif /* LICENSE */
