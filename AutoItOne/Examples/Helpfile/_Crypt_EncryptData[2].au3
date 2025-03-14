#include <Crypt.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Encrypt text using a generic password.
	Local $dEncrypted = StringEncrypt(True, 'Encrypt this data.', 'securepassword')

	; Display the encrypted text.
	MsgBox($MB_SYSTEMMODAL, 'Encrypted', $dEncrypted)

	; Decrypt the encrypted text using the generic password.
	Local $sDecrypted = StringEncrypt(False, $dEncrypted, 'securepassword')

	; Display the decrypted text.
	MsgBox($MB_SYSTEMMODAL, 'Decrypted', $sDecrypted)
EndFunc   ;==>Example

Func StringEncrypt($bEncrypt, $sData, $sPassword)
	_Crypt_Startup() ; Start the Crypt library.
	Local $vReturn = ''
	If $bEncrypt Then ; If the flag is set to True then encrypt, otherwise decrypt.
		$vReturn = _Crypt_EncryptData($sData, $sPassword, $CALG_RC4)
	Else
		$vReturn = BinaryToString(_Crypt_DecryptData($sData, $sPassword, $CALG_RC4))
	EndIf
	_Crypt_Shutdown() ; Shutdown the Crypt library.
	Return $vReturn
EndFunc   ;==>StringEncrypt
