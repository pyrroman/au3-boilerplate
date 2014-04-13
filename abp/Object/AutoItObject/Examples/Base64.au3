; -----------------------------------------------------------------------------
; Base64 Machine Code UDF
; Purpose: Provide  Machine Code Version of Base64 Encoder/Decoder In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include-once
#Include <Memory.au3>

Global $_B64E_CodeBuffer, $_B64E_CodeBufferMemory, $_B64E_Init, $_B64E_EncodeData, $_B64E_EncodeEnd
Global $_B64D_CodeBuffer, $_B64D_CodeBufferMemory, $_B64D_Init, $_B64D_DecodeData

Func _B64E_Exit()
	$_B64E_CodeBuffer = 0
	_MemVirtualFree($_B64E_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc

Func _B64D_Exit()
	$_B64D_CodeBuffer = 0
	_MemVirtualFree($_B64D_CodeBufferMemory, 0, $MEM_RELEASE)
EndFunc

Func _Base64EncodeInit($LineBreak = 76)
	If Not IsDllStruct($_B64E_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Opcode = '0x89C08D42034883EC0885D2C70100000000C64104000F49C2C7410800000000C1F80283E20389410C740683C00189410C4883C408C389C94883EC3848895C242848897424304889CB8B0A83F901742083F9024889D87444C6000A4883C001488B74243029D8488B5C24284883C438C30FB67204E803020000BA3D0000004080FE3F7F08480FBEF60FB614308813C643013D488D4303C643023DEBBC0FB67204E8D7010000BA3D0000004080FE3F7F08480FBEF60FB614308813C643013D488D4302EB9489DB4883EC68418B014863D248895C242848897424304C89C348897C24384C896424484C89CE83F80148896C24404C896C24504C897424584C897C24604C8D2411410FB6790474434D89C64989CD0F82F700000083F8024C89C5747B31C0488B5C2428488B742430488B7C2438488B6C24404C8B6424484C8B6C24504C8B7424584C8B7C24604883C468C34C89C54989CF4D39E70F840B010000450FBE374D8D6F014489F025F0000000C1F80409C7E8040100004080FF3FBA3D0000007F08480FBEFF0FB614384489F78855004883C50183E70FC1E7024D39E50F84B2000000450FB675004983C5014489F025C0000000C1F80609C7E8BD0000004080FF3FBA3D0000007F08480FBEFF0FB61438BF3F0000008855004421F74C8D7502E896000000480FBED70FB604108845018B460883C0013B460C89460875104C8D7503C645020AC7460800000000904D39E5742E410FBE7D004D8D7D01498D6E01E8560000004889FA83E70348C1EA02C1E70483E23F0FB60410418806E913FFFFFF4489F040887E04C7060000000029D8E9CCFEFFFF89E840887E04C7060200000029D8E9B9FEFFFF89E840887E04C7060100000029D8E9A6FEFFFFE8400000004142434445464748494A4B4C4D4E4F505152535455565758595A6162636465666768696A6B6C6D6E6F707172737475767778797A303132333435363738392B2F58C3'
		Else
			Local $Opcode = '0x89C08B4C24088B44240489CAC1FA1FC1EA1E01CAC1FA0283E103C70000000000C6400400C740080000000089500C740683C20189500CC2100089C983EC0C8B4C2414895C24048B5C2410897424088B1183FA01741D83FA0289D87443C6000A83C0018B74240829D88B5C240483C40CC210000FB67104E80C020000BA3D00000089F180F93F7F0989F20FBEF20FB6143088138D4303C643013DC643023DEBBD0FB67104E8DF010000BA3D00000089F180F93F7F0989F20FBEF20FB6143088138D4302C643013DEB9489DB83EC3C895C242C8B5C244C896C24388B542440897424308B6C2444897C24348B030FB6730401D583F801742D8B4C24488954241C0F820101000083F80289CF747D31C08B5C242C8B7424308B7C24348B6C243883C43CC210008B4C244889D739EF0F84400100008D57010FBE3F89542418894C241489F825F0000000C1F80409C6897C241CE8330100008B542418C644240C3D8B4C241489C789F03C3F7F0B0FBEF00FB604378844240C0FB644240C8D790188018B74241C83E60FC1E60239EA0F84CB0000000FB60A83C2018954241C89C825C0000000C1F80609C6884C2414E8D8000000BA3D0000000FB64C24148944240C89F03C3F7F0B0FBEF08B44240C0FB6143083E13F881789CEE8AD00000089F10FBED18D4F020FB604108847018B430883C0013B430C894308750EC647020A8D4F03C7430800000000396C241C743A8B44241C8B7C241C0FBE30894C241483C701E8650000008B4C241489F283E60381E2FC000000C1EA02C1E6040FB60410880183C101E9E4FEFFFF89F088430489C8C703000000002B442448E9B2FEFFFF89F189F8884B04C703020000002B442448E99CFEFFFF89F088430489C8C703010000002B442448E986FEFFFFE8400000004142434445464748494A4B4C4D4E4F505152535455565758595A6162636465666768696A6B6C6D6E6F707172737475767778797A303132333435363738392B2F58C3'
		EndIf
		$_B64E_Init = (StringInStr($Opcode, "89C0") - 3) / 2
		$_B64E_EncodeData = (StringInStr($Opcode, "89DB") - 3) / 2
		$_B64E_EncodeEnd = (StringInStr($Opcode, "89C9") - 3) / 2
		$Opcode = Binary($Opcode)

		$_B64E_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_B64E_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_B64E_CodeBufferMemory)
		DllStructSetData($_B64E_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_B64E_Exit")
	EndIf

	Local $State = DllStructCreate("byte[16]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_B64E_CodeBuffer) + $_B64E_Init, _
													"ptr", DllStructGetPtr($State), _
													"uint", $LineBreak, _
													"int", 0, _
													"int", 0)
	Return $State
EndFunc

Func _Base64EncodeData(ByRef $State, $Data)
	If Not IsDllStruct($_B64E_CodeBuffer) Or Not IsDllStruct($State) Then Return SetError(1, 0, "")

	$Data = Binary($Data)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)

	Local $OputputLen = Ceiling(BinaryLen($Data) * 1.4) + 3
	Local $Output = DllStructCreate("char[" & $OputputLen & "]")

	DllCall("user32.dll", "int", "CallWindowProc", "ptr", DllStructGetPtr($_B64E_CodeBuffer) + $_B64E_EncodeData, _
													"ptr", DllStructGetPtr($Input), _
													"uint", $InputLen, _
													"ptr", DllStructGetPtr($Output), _
													"ptr", DllStructGetPtr($State))

	Return DllStructGetData($Output, 1)
EndFunc

Func _Base64EncodeEnd(ByRef $State)
	If Not IsDllStruct($_B64E_CodeBuffer) Or Not IsDllStruct($State) Then Return SetError(1, 0, "")

	Local $Output = DllStructCreate("char[5]")
	DllCall("user32.dll", "int", "CallWindowProc", "ptr", DllStructGetPtr($_B64E_CodeBuffer) + $_B64E_EncodeEnd, _
													"ptr", DllStructGetPtr($Output), _
													"ptr", DllStructGetPtr($State), _
													"int", 0, _
													"int", 0)


	Return DllStructGetData($Output, 1)
EndFunc

Func _Base64DecodeInit()
	If Not IsDllStruct($_B64D_CodeBuffer) Then
		If @AutoItX64 Then
			Local $Opcode = '0x89C04883EC08C70100000000C64104004883C408C389DB4156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8B501000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E85301000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E80C01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8CC00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFFE8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
		Else
			Local $Opcode = '0x89C08B442404C70000000000C6400400C2100089DB5557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8890100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8300100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E8EA0000008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8A80000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB99E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3'
		EndIf
		$_B64D_Init = (StringInStr($Opcode, "89C0") - 3) / 2
		$_B64D_DecodeData = (StringInStr($Opcode, "89DB") - 3) / 2
		$Opcode = Binary($Opcode)
		

		$_B64D_CodeBufferMemory = _MemVirtualAlloc(0, BinaryLen($Opcode), $MEM_COMMIT, $PAGE_EXECUTE_READWRITE)
		$_B64D_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_B64D_CodeBufferMemory)
		DllStructSetData($_B64D_CodeBuffer, 1, $Opcode)
		OnAutoItExitRegister("_B64D_Exit")
	EndIf

	Local $State = DllStructCreate("byte[16]")
	DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($_B64D_CodeBuffer) + $_B64D_Init, _
													"ptr", DllStructGetPtr($State), _
													"int", 0, _
													"int", 0, _
													"int", 0)
	Return $State
EndFunc

Func _Base64DecodeData(ByRef $State, $Data)
	If Not IsDllStruct($_B64D_CodeBuffer) Or Not IsDllStruct($State) Then Return SetError(1, 0, Binary(""))

	$Data = String($Data)
	Local $Length = StringLen($Data)
	Local $Output = DllStructCreate("byte[" & $Length & "]")

	Local $Ret = DllCall("user32.dll", "int", "CallWindowProc", "ptr", DllStructGetPtr($_B64D_CodeBuffer) + $_B64D_DecodeData, _
													"str", $Data, _
													"uint", $Length, _
													"ptr", DllStructGetPtr($Output), _
													"ptr", DllStructGetPtr($State))
	Return BinaryMid(DllStructGetData($Output, 1), 1, $Ret[0])
EndFunc

Func _Base64Encode($Data, $LineBreak = 76)
	Local $State = _Base64EncodeInit($LineBreak)
	Return _Base64EncodeData($State, $Data) & _Base64EncodeEnd($State)
EndFunc

Func _Base64Decode($Data)
	Local $State = _Base64DecodeInit()
	Return _Base64DecodeData($State, $Data)
EndFunc