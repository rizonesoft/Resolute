; == Example 3 for Handling non ANSI String

#include <Crypt.au3>
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>

Local $sPlaintext = "Hello! ជំរាបសួរ! Allô! Привет! 您好！مرحبا! હેલો! שלום! こんにちは！"

Local $dPlaintextUTF8 = StringToBinary($sPlaintext, $SB_UTF8) ; Convert to Binary string converting Unicode char as UTF8
;~ $dPlaintextUTF8 = $sPlaintext ; If Uncommented willshow why UTF8 conversion is needed

Local $iAlgorithm = $CALG_3DES
Local $hKey = _Crypt_DeriveKey("CryptPassword", $iAlgorithm)

Local $dEncrypted = _Crypt_EncryptData($dPlaintextUTF8, $hKey, $CALG_USERKEY) ; Encrypt the text with the new cryptographic key.

Local $dDecrypted = _Crypt_DecryptData($dEncrypted, $hKey, $CALG_USERKEY) ; Decrypt the data using the generic password string. The return value is a binary string.

Local $sDecrypted = BinaryToString($dDecrypted, $SB_UTF8) ; Convert the binary string using BinaryToString to display the initial data we encrypted.

If $sPlaintext = $sDecrypted Then
	MsgBox($MB_SYSTEMMODAL, "Decrypted data", $sDecrypted)
Else
	MsgBox($MB_SYSTEMMODAL, "BAD Decrypted data", $sPlaintext & @CRLF & "-->" & @CRLF & $sDecrypted)
EndIf
