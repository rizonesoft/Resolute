#include <Crypt.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	_Crypt_Startup() ; To optimize performance start the crypt library, though the same results will be shown if it isn't.

	Local $sData = "..upon a time there was a language without any standardized cryptographic functions. That language is no more." ; Data that will be hashed.

	Local $sOutput = "The following results show the supported algorithms for retrieving the hash of the data." & @CRLF & @CRLF & _
			"Text: " & $sData & @CRLF & @CRLF & _
			"MD2 (128bit): " & _Crypt_HashData($sData, $CALG_MD2) & @CRLF & @CRLF & _
			"MD4 (128bit): " & _Crypt_HashData($sData, $CALG_MD4) & @CRLF & @CRLF & _
			"MD5 (128bit): " & _Crypt_HashData($sData, $CALG_MD5) & @CRLF & @CRLF & _
			"SHA1 (160bit): " & _Crypt_HashData($sData, $CALG_SHA1) & @CRLF & @CRLF & _
			"SHA_256: " & _Crypt_HashData($sData, $CALG_SHA_256) & @CRLF & @CRLF & _
			"SHA_384: " & _Crypt_HashData($sData, $CALG_SHA_384) & @CRLF & @CRLF & _
			"SHA_512: " & _Crypt_HashData($sData, $CALG_SHA_512)

	MsgBox($MB_SYSTEMMODAL, "Supported algorithms", $sOutput)

	_Crypt_Shutdown() ; Shutdown the crypt library.
EndFunc   ;==>Example
