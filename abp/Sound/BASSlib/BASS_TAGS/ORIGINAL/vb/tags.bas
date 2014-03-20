' 
' TAGS VB header
' Author: Wraith, 2k5-2k6
' consult "tags-readme.txt" for details
'
'
Public Declare Function TAGS_Read Lib "tags.dll" Alias "TAGS_Read" (ByVal handle As Long, ByVal fmt As String) As Long
Public Declare Function TAGS_GetLastErrorDesc Lib "tags.dll" Alias "TAGS_GetLastErrorDesc" () As Long
Public Declare Function TAGS_GetVersion Lib "tags.dll" Alias "TAGS_GetVersion" () As Long
