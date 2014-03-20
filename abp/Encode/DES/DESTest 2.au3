; -----------------------------------------------------------------------------
; DES/3DES Machine Code UDF Example
; Purpose: Provide Machine Code Version of DES/3DES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "DES.au3"

Dim $Key = Binary('0x1111111111111111')
Dim $Data = Binary('0x00010203040506070001020304050607')
Dim $Encrypt = _DesCryptECB(_DesEncryptKey($Key), $Data)
Dim $Decrypt = _DesCryptECB(_DesDecryptKey($Key), $Encrypt)
ConsoleWrite('=== Encrypt Two Block With DES ECB Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x1111111111111111')
Dim $IV = Binary('0x0000000000000000')
Dim $Data = Binary('0x00010203040506070001020304050607')
Dim $Encrypt = _DesEncryptCBC(_DesEncryptKey($Key), $IV, $Data)
Dim $IV = Binary('0x0000000000000000')
Dim $Decrypt = _DesDecryptCBC(_DesDecryptKey($Key), $IV, $Encrypt)
ConsoleWrite('=== Encrypt Two Block With DES CBC Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x1111111111111111')
Dim $IV = Binary('0x0000000000000000')
Dim $Data = Binary('0x00010203040506070001020304050607FF')
Dim $Encrypt = _DesEncryptCBC_Pad(_DesEncryptKey($Key), $IV, $Data)
Dim $IV = Binary('0x0000000000000000')
Dim $Decrypt = _DesDecryptCBC_Pad(_DesDecryptKey($Key), $IV, $Encrypt)
ConsoleWrite('=== Encrypt Two Block + 1 Byte With DES CBC Bit Padding Mode  ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x111111111111111122222222222222223333333333333333')
Dim $Data = Binary('0x00010203040506070001020304050607')
Dim $Encrypt = _3DesCryptECB(_3DesEncryptKey($Key), $Data)
Dim $Decrypt = _3DesCryptECB(_3DesDecryptKey($Key), $Encrypt)
ConsoleWrite('=== Encrypt Two Block With 3DES ECB Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x111111111111111122222222222222223333333333333333')
Dim $IV = Binary('0x0000000000000000')
Dim $Data = Binary('0x00010203040506070001020304050607')
Dim $Encrypt = _3DesEncryptCBC(_3DesEncryptKey($Key), $IV, $Data)
Dim $IV = Binary('0x0000000000000000')
Dim $Decrypt = _3DesDecryptCBC(_3DesDecryptKey($Key), $IV, $Encrypt)
ConsoleWrite('=== Encrypt Two Block With 3DES CBC Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x111111111111111122222222222222223333333333333333')
Dim $IV = Binary('0x0000000000000000')
Dim $Data = Binary('0x00010203040506070001020304050607FF')
Dim $Encrypt = _3DesEncryptCBC_Pad(_3DesEncryptKey($Key), $IV, $Data)
Dim $IV = Binary('0x0000000000000000')
Dim $Decrypt = _3DesDecryptCBC_Pad(_3DesDecryptKey($Key), $IV, $Encrypt)
ConsoleWrite('=== Encrypt Two Block + 1 Byte With 3DES CBC Bit Padding Mode  ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)
