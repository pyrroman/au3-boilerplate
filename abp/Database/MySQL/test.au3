#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.2.8.1 (beta)
	Author:         Prog@ndy
	
	Script Function:
	MySQL-Plugin Demo Script
	
#ce ----------------------------------------------------------------------------

#include <array.au3>
#include "mysql.au3"

; MYSQL starten, DLL im PATH (enthält auch @ScriptDir), sont Pfad zur DLL angeben. DLL muss libmysql.dll heißen.
_MySQL_InitLibrary()
If @error Then Exit MsgBox(0, '', "")
MsgBox(0, "DLL Version:",_MySQL_Get_Client_Version()&@CRLF& _MySQL_Get_Client_Info())

$MysqlConn = _MySQL_Init()

;Fehler Demo:
MsgBox(0,"Fehler-Demo","Fehler-Demo")
$connected = _MySQL_Real_Connect($MysqlConn,"localhostdfdf","droot","","cdcol")
If $connected = 0 Then
	$errno = _MySQL_errno($MysqlConn)
	MsgBox(0,"Error:",$errno & @LF & _MySQL_error($MysqlConn))
	If $errno = $CR_UNKNOWN_HOST Then MsgBox(0,"Error:","$CR_UNKNOWN_HOST" & @LF & $CR_UNKNOWN_HOST)
Endif

; XAMPP cdcol
MsgBox(0, "XAMPP-Cdcol-demo", "XAMPP-Cdcol-demo")

$connected = _MySQL_Real_Connect($MysqlConn, "localhost", "root", "", "cdcol")
If $connected = 0 Then Exit MsgBox(16, 'Connection Error', _MySQL_Error($MysqlConn))

$query = "SELECT * FROM cds"
_MySQL_Real_Query($MysqlConn, $query)


$res = _MySQL_Store_Result($MysqlConn)

$fields = _MySQL_Num_Fields($res)

$rows = _MySQL_Num_Rows($res)
MsgBox(0, "", $rows & "-" & $fields)

; Zugriff 1
MsgBox(0, '', "Zugriff Methode 1- Handarbeit")
Dim $array[$rows][$fields]
For $k = 1 To $rows
	$mysqlrow = _MySQL_Fetch_Row($res,$fields)

	$lenthsStruct = _MySQL_Fetch_Lengths($res)

	For $i = 1 To $fields
		$length = DllStructGetData($lenthsStruct, 1, $i)
		$fieldPtr = DllStructGetData($mysqlrow, 1, $i)
		$data = DllStructGetData(DllStructCreate("char[" & $length & "]", $fieldPtr), 1)
		$array[$k - 1][$i - 1] = $data
	Next
Next
_ArrayDisplay($array)

; Zugriff 2
MsgBox(0, '', "Zugriff Methode 2 - Reihe für Reihe")
_MySQL_Data_Seek($res, 0) ; nur zum zum Zurücksetzen an den Anfang der Abfrage
Do
$row1 = _MySQL_Fetch_Row_StringArray($res)
If @error Then ExitLoop
_ArrayDisplay($row1)
Until @error

MsgBox(0, '', "Zugriff Methode 3 - alles in ein 2D Array")
$array = _MySQL_Fetch_Result_StringArray($res)
_ArrayDisplay($array)

; Feldinformationen
MsgBox(0, '', "Zugriff Feldinformationen")
Dim $arFields[$fields][3]
For $i = 0 To $fields - 1
	$field = _MySQL_Fetch_Field_Direct($res, $i)
	$arFields[$i][0] = _MySQL_Field_ReadValue($field, "name")
	$arFields[$i][1] = _MySQL_Field_ReadValue($field, "table")
	$arFields[$i][2] = _MySQL_Field_ReadValue($field, "db")
Next
_ArrayDisplay($arFields)

; Abfrage freigeben
_MySQL_Free_Result($res)

; Verbindung beenden
_MySQL_Close($MysqlConn)
; MYSQL beenden
_MySQL_EndLibrary()