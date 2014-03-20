; -----------------------------------------------------------------------------
; AES Machine Code UDF Example
; Purpose: Provide Machine Code Version of AES Algorithm In AutoIt
; Author: Ward
; -----------------------------------------------------------------------------

#Include "AES.au3"

Dim $Key = Binary('0x11111111111111111111111111111111')
Dim $Data = Binary('0x000102030405060708090A0B0C0D0E0F000102030405060708090A0B0C0D0E0F')
Dim $Encrypt = _AesEncryptECB(_AesEncryptKey($Key), $Data)
Dim $Decrypt = _AesDecryptECB(_AesDecryptKey($Key), $Encrypt)
ConsoleWrite('=== Encrypt Two Block With AES128 ECB Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x11111111111111111111111111111111')
Dim $IV = Binary('0x00000000000000000000000000000000')
Dim $Data = Binary('0x000102030405060708090A0B0C0D0E0F000102030405060708090A0B0C0D0E0F')
Dim $Encrypt = _AesEncryptCBC(_AesEncryptKey($Key), $IV, $Data)
Dim $IV = Binary('0x0000000000000000')
Dim $Decrypt = _AesDecryptCBC(_AesDecryptKey($Key), $IV, $Encrypt)
ConsoleWrite('=== Encrypt Two Block With AES128 CBC Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x11111111111111111111111111111111')
Dim $IV = Binary('0x00000000000000000000000000000000')
Dim $Data = Binary('0x000102030405060708090A0B0C0D0E0F000102030405060708090A0B0C0D0E0FFF')
Dim $Encrypt = _AesEncryptCBC_Pad(_AesEncryptKey($Key), $IV, $Data)
Dim $IV = Binary('0x0000000000000000')
Dim $Decrypt = _AesDecryptCBC_Pad(_AesDecryptKey($Key), $IV, $Encrypt)
ConsoleWrite('=== Encrypt Two Block + 1 Byte With AES128 CBC Bit Padding Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x11111111111111111111111111111111')
Dim $IV = Binary('0x00000000000000000000000000000000')
Dim $Data = Binary('0x000102030405060708090A0B0C0D0E0F000102030405060708090A0B0C0D0E0FFF')
Dim $Encrypt = _AesEncryptCFB(_AesEncryptKey($Key), $IV, $Data)
Dim $IV = Binary('0x0000000000000000')
Dim $Decrypt = _AesDecryptCFB(_AesEncryptKey($Key), $IV, $Encrypt)
ConsoleWrite('=== Encrypt Two Block + 1 Byte With AES128 CFB Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x11111111111111111111111111111111')
Dim $IV = Binary('0x00000000000000000000000000000000')
Dim $Data = Binary('0x000102030405060708090A0B0C0D0E0F000102030405060708090A0B0C0D0E0FFF')
Dim $Encrypt = _AesCryptOFB(_AesEncryptKey($Key), $IV, $Data)
Dim $IV = Binary('0x0000000000000000')
Dim $Decrypt = _AesCryptOFB(_AesEncryptKey($Key), $IV, $Encrypt)
ConsoleWrite('=== Encrypt Two Block + 1 Byte With AES128 OFB Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x111111111111111111111111111111112222222222222222')
Dim $IV = Binary('0x00000000000000000000000000000000')
Dim $Data = Binary('0x000102030405060708090A0B0C0D0E0F000102030405060708090A0B0C0D0E0FFF')
Dim $Encrypt = _AesEncryptCBC_Pad(_AesEncryptKey($Key), $IV, $Data)
Dim $IV = Binary('0x0000000000000000')
Dim $Decrypt = _AesDecryptCBC_Pad(_AesDecryptKey($Key), $IV, $Encrypt)
ConsoleWrite('=== Encrypt Two Block + 1 Byte With AES192 CBC Bit Padding Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)

Dim $Key = Binary('0x1111111111111111111111111111111122222222222222223333333333333333')
Dim $IV = Binary('0x00000000000000000000000000000000')
Dim $Data = Binary('0x000102030405060708090A0B0C0D0E0F000102030405060708090A0B0C0D0E0FFF')
Dim $Encrypt = _AesEncryptCBC_Pad(_AesEncryptKey($Key), $IV, $Data)
Dim $IV = Binary('0x0000000000000000')
Dim $Decrypt = _AesDecryptCBC_Pad(_AesDecryptKey($Key), $IV, $Encrypt)
ConsoleWrite('=== Encrypt Two Block + 1 Byte With AES256 CBC Bit Padding Mode ===' & @CRLF)
ConsoleWrite('Encrypt: ' & $Encrypt & @CRLF & 'Decrypt: ' & $Decrypt & @CRLF & @CRLF)
