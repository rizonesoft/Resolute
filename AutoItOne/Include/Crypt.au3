#include-once

#include "FileConstants.au3"
#include "WinAPIError.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crypt
; AutoIt Version : 3.3.16.1
; Language ......: English
; Description ...: Functions for encrypting and hashing data.
; Author(s) .....: Andreas Karlsson (monoceres), jchd
; Dll(s) ........: Advapi32.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _Crypt_DecryptData
; _Crypt_DecryptFile
; _Crypt_DeriveKey
; _Crypt_DestroyKey
; _Crypt_EncryptData
; _Crypt_EncryptFile
; _Crypt_GenRandom
; _Crypt_HashData
; _Crypt_HashFile
; _Crypt_Shutdown
; _Crypt_Startup
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; __Crypt_Context
; __Crypt_ContextSet
; __Crypt_DllHandle
; __Crypt_DllHandleSet
; __Crypt_GetCalgFromCryptKey
; __Crypt_RefCount
; __Crypt_RefCountDec
; __Crypt_RefCountInc
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $PROV_RSA_FULL = 0x1
Global Const $PROV_RSA_AES = 24
Global Const $CRYPT_VERIFYCONTEXT = 0xF0000000
Global Const $HP_HASHSIZE = 0x0004
Global Const $HP_HASHVAL = 0x0002
Global Const $CRYPT_EXPORTABLE = 0x00000001
Global Const $CRYPT_USERDATA = 1
Global Const $KP_ALGID = 0x00000007

Global Const $CALG_MD2 = 0x00008001
Global Const $CALG_MD4 = 0x00008002
Global Const $CALG_MD5 = 0x00008003
Global Const $CALG_SHA1 = 0x00008004
Global Const $CALG_SHA_256 = 0x0000800c
Global Const $CALG_SHA_384 = 0x0000800d
Global Const $CALG_SHA_512 = 0x0000800e
Global Const $CALG_3DES = 0x00006603
Global Const $CALG_AES_128 = 0x0000660e
Global Const $CALG_AES_192 = 0x0000660f
Global Const $CALG_AES_256 = 0x00006610
Global Const $CALG_DES = 0x00006601
Global Const $CALG_RC2 = 0x00006602
Global Const $CALG_RC4 = 0x00006801

Global Const $CALG_USERKEY = 0

; #VARIABLES# ===================================================================================================================
Global $__g_aCryptInternalData[3]

; #FUNCTION# ====================================================================================================================
; Author ........: Andreas Karlsson (monoceres)
; Modified ......: jpm
; ===============================================================================================================================
Func _Crypt_Startup()
	If __Crypt_RefCount() = 0 Then
		Local $hAdvapi32 = DllOpen("Advapi32.dll")
		If $hAdvapi32 = -1 Then Return SetError(1001, 0, False)
		__Crypt_DllHandleSet($hAdvapi32)
		Local $iProviderID = $PROV_RSA_AES
		Local $aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptAcquireContext", "handle*", 0, "ptr", 0, "ptr", 0, "dword", $iProviderID, "dword", $CRYPT_VERIFYCONTEXT)
		If @error Or Not $aCall[0] Then
			Local $iError = @error + 1002, $iExtended = @extended
			If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
			DllClose(__Crypt_DllHandle())
			Return SetError($iError, $iExtended, False)
		Else
			__Crypt_ContextSet($aCall[1])
			; Fall through to success.
		EndIf
	EndIf
	__Crypt_RefCountInc()
	Return True
EndFunc   ;==>_Crypt_Startup

; #FUNCTION# ====================================================================================================================
; Author ........: Andreas Karlsson (monoceres)
; Modified ......:
; ===============================================================================================================================
Func _Crypt_Shutdown()
	__Crypt_RefCountDec()
	If __Crypt_RefCount() = 0 Then
		DllCall(__Crypt_DllHandle(), "bool", "CryptReleaseContext", "handle", __Crypt_Context(), "dword", 0)
		DllClose(__Crypt_DllHandle())
	EndIf
EndFunc   ;==>_Crypt_Shutdown

; #FUNCTION# ====================================================================================================================
; Author ........: Andreas Karlsson (monoceres)
; Modified ......: jpm
; ===============================================================================================================================
Func _Crypt_DeriveKey($vPassword, $iAlgID, $iHashPasswordID = $CALG_MD5)
	Local $aCall, _
			$tBuff = 0, $hCryptHash = 0, _
			$iError = 0, $iExtended = 0, _
			$vReturn = 0

	_Crypt_Startup()
	If @error Then Return SetError(@error, @extended, -1)

	Do
		; Create Hash object
		$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptCreateHash", "handle", __Crypt_Context(), "uint", $iHashPasswordID, "ptr", 0, "dword", 0, "handle*", 0)
		If @error Or Not $aCall[0] Then
			$iError = @error + 10
			$iExtended = @extended
			If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
			$vReturn = -1
			ExitLoop
		EndIf

		$hCryptHash = $aCall[5]
		$tBuff = DllStructCreate("byte[" & BinaryLen($vPassword) & "]")
		DllStructSetData($tBuff, 1, $vPassword)
		$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptHashData", "handle", $hCryptHash, "struct*", $tBuff, "dword", DllStructGetSize($tBuff), "dword", $CRYPT_USERDATA)
		If @error Or Not $aCall[0] Then
			$iError = @error + 20
			$iExtended = @extended
			If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
			$vReturn = -1
			ExitLoop
		EndIf

		; Create key
		$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptDeriveKey", "handle", __Crypt_Context(), "uint", $iAlgID, "handle", $hCryptHash, "dword", $CRYPT_EXPORTABLE, "handle*", 0)
		If @error Or Not $aCall[0] Then
			$iError = @error + 30
			$iExtended = @extended
			If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
			$vReturn = -1
			ExitLoop
		EndIf
		$vReturn = $aCall[5]
	Until True
	If $hCryptHash <> 0 Then DllCall(__Crypt_DllHandle(), "bool", "CryptDestroyHash", "handle", $hCryptHash)

	Return SetError($iError, $iExtended, $vReturn)
EndFunc   ;==>_Crypt_DeriveKey

; #FUNCTION# ====================================================================================================================
; Author ........: Andreas Karlsson (monoceres)
; Modified ......: jpm
; ===============================================================================================================================
Func _Crypt_DestroyKey($hCryptKey)
	Local $aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptDestroyKey", "handle", $hCryptKey)
	Local $iError = @error
	If $iError Or Not $aCall[0] Then
		Return SetError($iError + 10, _WinAPI_GetLastError(), False)
	Else
		_Crypt_Shutdown()
		Return True
	EndIf
EndFunc   ;==>_Crypt_DestroyKey

; #FUNCTION# ====================================================================================================================
; Author ........: Andreas Karlsson (monoceres)
; Modified ......: jchd, jpm
; ===============================================================================================================================
Func _Crypt_EncryptData($vData, $vCryptKey, $iAlgID, $bFinal = True)

	Switch $iAlgID
		Case $CALG_USERKEY
			Local $iCalgUsed = __Crypt_GetCalgFromCryptKey($vCryptKey)
			If @error Then Return SetError(@error, @extended, -1)
			If $iCalgUsed = $CALG_RC4 Then ContinueCase
		Case $CALG_RC4
			If BinaryLen($vData) = 0 Then Return SetError(0, 0, Binary(''))
	EndSwitch

	Local $iReqBuffSize = 0, _
			$aCall, _
			$tBuff = 0, _
			$iError = 0, $iExtended = 0, _
			$vReturn = 0

	_Crypt_Startup()
	If @error Then Return SetError(@error, @extended, -1)

	Do
		If $iAlgID <> $CALG_USERKEY Then
			$vCryptKey = _Crypt_DeriveKey($vCryptKey, $iAlgID)
			If @error Then
				$iError = @error
				$iExtended = @extended
				$vReturn = -1
				ExitLoop
			EndIf
		EndIf

		$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptEncrypt", "handle", $vCryptKey, "handle", 0, "bool", $bFinal, "dword", 0, "ptr", 0, _
				"dword*", BinaryLen($vData), "dword", 0)
		If @error Or Not $aCall[0] Then
			$iError = @error + 50
			$iExtended = @extended
			If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
			$vReturn = -1
			ExitLoop
		EndIf

		$iReqBuffSize = $aCall[6]
		$tBuff = DllStructCreate("byte[" & $iReqBuffSize + 1 & "]")
		DllStructSetData($tBuff, 1, $vData)
		$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptEncrypt", "handle", $vCryptKey, "handle", 0, "bool", $bFinal, "dword", 0, "struct*", $tBuff, _
				"dword*", BinaryLen($vData), "dword", $iReqBuffSize)
		If @error Or Not $aCall[0] Then
			$iError = @error + 60
			$iExtended = @extended
			If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
			$vReturn = -1
			ExitLoop
		EndIf
		$vReturn = BinaryMid(DllStructGetData($tBuff, 1), 1, $iReqBuffSize)
	Until True

	If $iAlgID <> $CALG_USERKEY Then _Crypt_DestroyKey($vCryptKey)
	_Crypt_Shutdown()

	Return SetError($iError, $iExtended, $vReturn)
EndFunc   ;==>_Crypt_EncryptData

; #FUNCTION# ====================================================================================================================
; Author ........: Andreas Karlsson (monoceres)
; Modified ......: jchd, jpm
; ===============================================================================================================================
Func _Crypt_DecryptData($vData, $vCryptKey, $iAlgID, $bFinal = True)

	Switch $iAlgID
		Case $CALG_USERKEY
			Local $iCalgUsed = __Crypt_GetCalgFromCryptKey($vCryptKey)
			If @error Then Return SetError(@error, @extended, -1)
			If $iCalgUsed = $CALG_RC4 Then ContinueCase
		Case $CALG_RC4
			If BinaryLen($vData) = 0 Then Return SetError(0, 0, Binary(''))
	EndSwitch

	Local $aCall, _
			$tBuff = 0, $tTempStruct = 0, _
			$iError = 0, $iExtended = 0, $iPlainTextSize = 0, _
			$vReturn = 0

	_Crypt_Startup()
	If @error Then Return SetError(@error, @extended, -1)

	Do
		If $iAlgID <> $CALG_USERKEY Then
			$vCryptKey = _Crypt_DeriveKey($vCryptKey, $iAlgID)
			If @error Then
				$iError = @error
				$iExtended = @extended
				$vReturn = -1
				ExitLoop
			EndIf
		EndIf

		$tBuff = DllStructCreate("byte[" & BinaryLen($vData) + 1000 & "]")
		If BinaryLen($vData) > 0 Then DllStructSetData($tBuff, 1, $vData)
		$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptDecrypt", "handle", $vCryptKey, "handle", 0, "bool", $bFinal, "dword", 0, "struct*", $tBuff, "dword*", BinaryLen($vData))
		If @error Or Not $aCall[0] Then
			$iError = @error + 70
			$iExtended = @extended
			If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
			$vReturn = -1
			ExitLoop
		EndIf

		$iPlainTextSize = $aCall[6]
		$tTempStruct = DllStructCreate("byte[" & $iPlainTextSize + 1 & "]", DllStructGetPtr($tBuff))
		$vReturn = BinaryMid(DllStructGetData($tTempStruct, 1), 1, $iPlainTextSize)
	Until True

	If $iAlgID <> $CALG_USERKEY Then _Crypt_DestroyKey($vCryptKey)
	_Crypt_Shutdown()

	Return SetError($iError, $iExtended, $vReturn)
EndFunc   ;==>_Crypt_DecryptData

; #FUNCTION# ====================================================================================================================
; Author ........: Andreas Karlsson (monoceres)
; Modified ......: jpm
; ===============================================================================================================================
Func _Crypt_HashData($vData, $iAlgID, $bFinal = True, $hCryptHash = 0)
	Local $aCall, _
			$tBuff = 0, _
			$iError = 0, $iExtended = 0, $iHashSize = 0, _
			$vReturn = 0

	_Crypt_Startup()
	If @error Then Return SetError(@error, @extended, -1)

	Do
		If $hCryptHash = 0 Then
			; Create Hash object
			$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptCreateHash", "handle", __Crypt_Context(), "uint", $iAlgID, "ptr", 0, "dword", 0, "handle*", 0)
			If @error Or Not $aCall[0] Then
				$iError = @error + 10
				$iExtended = @extended
				If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
				$vReturn = -1
				ExitLoop
			EndIf
			$hCryptHash = $aCall[5]
		EndIf

		$tBuff = DllStructCreate("byte[" & BinaryLen($vData) & "]")
		DllStructSetData($tBuff, 1, $vData)

		$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptHashData", "handle", $hCryptHash, "struct*", $tBuff, "dword", DllStructGetSize($tBuff), "dword", $CRYPT_USERDATA)
		If @error Or Not $aCall[0] Then
			$iError = @error + 20
			$iExtended = @extended
			If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
			$vReturn = -1
			ExitLoop
		EndIf

		If $bFinal Then
			$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptGetHashParam", "handle", $hCryptHash, "dword", $HP_HASHSIZE, "dword*", 0, "dword*", 4, "dword", 0)
			If @error Or Not $aCall[0] Then
				$iError = @error + 30
				$iExtended = @extended
				If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
				$vReturn = -1
				ExitLoop
			EndIf
			$iHashSize = $aCall[3]

			; Get Hash
			$tBuff = DllStructCreate("byte[" & $iHashSize & "]")
			$aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptGetHashParam", "handle", $hCryptHash, "dword", $HP_HASHVAL, "struct*", $tBuff, "dword*", $iHashSize, "dword", 0)
			If @error Or Not $aCall[0] Then
				$iError = @error + 40
				$iExtended = @extended
				If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
				$vReturn = -1
				ExitLoop
			EndIf
			$vReturn = DllStructGetData($tBuff, 1)
		Else
			$vReturn = $hCryptHash
		EndIf
	Until True

	; Cleanup and return hash
	If $hCryptHash <> 0 And $bFinal Then DllCall(__Crypt_DllHandle(), "bool", "CryptDestroyHash", "handle", $hCryptHash)

	_Crypt_Shutdown()

	Return SetError($iError, $iExtended, $vReturn)
EndFunc   ;==>_Crypt_HashData

; #FUNCTION# ====================================================================================================================
; Author ........: Andreas Karlsson (monoceres)
; Modified ......: jpm
; ===============================================================================================================================
Func _Crypt_HashFile($sFilePath, $iAlgID)
	Local $dTempData = 0, _
			$hFile = 0, $hHashObject = 0, _
			$iError = 0, $iExtended = 0, _
			$vReturn = 0

	_Crypt_Startup()
	If @error Then Return SetError(@error, @extended, -1)

	Do
		$hFile = FileOpen($sFilePath, $FO_BINARY)
		If $hFile = -1 Then
			$iError = 1
			$iExtended = _WinAPI_GetLastError()
			$vReturn = -1
			ExitLoop
		EndIf

		Do
			$dTempData = FileRead($hFile, 512 * 1024)
			If @error Then
				$vReturn = _Crypt_HashData($dTempData, $iAlgID, True, $hHashObject)
				If @error Then
					$iError = @error
					$iExtended = @extended
					$vReturn = -1
					ExitLoop 2
				EndIf
				ExitLoop 2
			Else
				$hHashObject = _Crypt_HashData($dTempData, $iAlgID, False, $hHashObject)
				If @error Then
					$iError = @error + 100
					$iExtended = @extended
					$vReturn = -1
					ExitLoop 2
				EndIf
			EndIf
		Until False
	Until True

	_Crypt_Shutdown()
	If $hFile <> -1 Then FileClose($hFile)

	Return SetError($iError, $iExtended, $vReturn)
EndFunc   ;==>_Crypt_HashFile

; #FUNCTION# ====================================================================================================================
; Author ........: Andreas Karlsson (monoceres)
; Modified ......: jpm
; ===============================================================================================================================
Func _Crypt_EncryptFile($sSourceFile, $sDestinationFile, $vCryptKey, $iAlgID)
	Local $dTempData = 0, _
			$hInFile = 0, $hOutFile = 0, _
			$iError = 0, $iExtended = 0, $iFileSize = FileGetSize($sSourceFile), $iRead = 0, _
			$bReturn = True

	_Crypt_Startup()
	If @error Then Return SetError(@error, @extended, -1)

	Do
		If $iAlgID <> $CALG_USERKEY Then
			$vCryptKey = _Crypt_DeriveKey($vCryptKey, $iAlgID)
			If @error Then
				$iError = @error
				$iExtended = @extended
				$bReturn = False
				ExitLoop
			EndIf
		EndIf

		$hInFile = FileOpen($sSourceFile, $FO_BINARY)
		If $hInFile = -1 Then
			$iError = 2
			$iExtended = _WinAPI_GetLastError()
			$bReturn = False
			ExitLoop
		EndIf
		$hOutFile = FileOpen($sDestinationFile, $FO_OVERWRITE + $FO_CREATEPATH + $FO_BINARY)
		If $hOutFile = -1 Then
			$iError = 3
			$iExtended = _WinAPI_GetLastError()
			$bReturn = False
			ExitLoop
		EndIf

		Do
			$dTempData = FileRead($hInFile, 1024 * 1024)
			$iRead += BinaryLen($dTempData)
			If $iRead = $iFileSize Then
				$dTempData = _Crypt_EncryptData($dTempData, $vCryptKey, $CALG_USERKEY, True)
				If @error Then
					$iError = @error + 400
					$iExtended = @extended
					$bReturn = False
				EndIf
				FileWrite($hOutFile, $dTempData)
				ExitLoop 2
			Else
				$dTempData = _Crypt_EncryptData($dTempData, $vCryptKey, $CALG_USERKEY, False)
				If @error Then
					$iError = @error + 500
					$iExtended = @extended
					$bReturn = False
					ExitLoop 2
				EndIf
				FileWrite($hOutFile, $dTempData)
			EndIf
		Until False
	Until True

	If $iAlgID <> $CALG_USERKEY Then _Crypt_DestroyKey($vCryptKey)
	_Crypt_Shutdown()
	If $hInFile <> -1 Then FileClose($hInFile)
	If $hOutFile <> -1 Then FileClose($hOutFile)

	Return SetError($iError, $iExtended, $bReturn)
EndFunc   ;==>_Crypt_EncryptFile

; #FUNCTION# ====================================================================================================================
; Author ........: Andreas Karlsson (monoceres)
; Modified ......: jpm
; ===============================================================================================================================
Func _Crypt_DecryptFile($sSourceFile, $sDestinationFile, $vCryptKey, $iAlgID)
	Local $dTempData = 0, _
			$hInFile = 0, $hOutFile = 0, _
			$iError = 0, $iExtended = 0, $iFileSize = FileGetSize($sSourceFile), $iRead = 0, _
			$bReturn = True

	_Crypt_Startup()
	If @error Then Return SetError(@error, @extended, -1)

	Do
		If $iAlgID <> $CALG_USERKEY Then
			$vCryptKey = _Crypt_DeriveKey($vCryptKey, $iAlgID)
			If @error Then
				$iError = @error
				$iExtended = @extended
				$bReturn = False
				ExitLoop
			EndIf
		EndIf

		$hInFile = FileOpen($sSourceFile, $FO_BINARY)
		If $hInFile = -1 Then
			$iError = 2
			$iExtended = _WinAPI_GetLastError()
			$bReturn = False
			ExitLoop
		EndIf
		$hOutFile = FileOpen($sDestinationFile, $FO_OVERWRITE + $FO_CREATEPATH + $FO_BINARY)
		If $hOutFile = -1 Then
			$iError = 3
			$iExtended = _WinAPI_GetLastError()
			$bReturn = False
			ExitLoop
		EndIf

		Do
			$dTempData = FileRead($hInFile, 1024 * 1024)
			$iRead += BinaryLen($dTempData)
			If $iRead = $iFileSize Then
				$dTempData = _Crypt_DecryptData($dTempData, $vCryptKey, $CALG_USERKEY, True)
				If @error Then
					$iError = @error + 400
					$iExtended = @extended
					$bReturn = False
				EndIf
				FileWrite($hOutFile, $dTempData)
				ExitLoop 2
			Else
				$dTempData = _Crypt_DecryptData($dTempData, $vCryptKey, $CALG_USERKEY, False)
				If @error Then
					$iError = @error + 500
					$iExtended = @extended
					$bReturn = False
					ExitLoop 2
				EndIf
				FileWrite($hOutFile, $dTempData)
			EndIf
		Until False
	Until True

	If $iAlgID <> $CALG_USERKEY Then _Crypt_DestroyKey($vCryptKey)
	_Crypt_Shutdown()
	If $hInFile <> -1 Then FileClose($hInFile)
	If $hOutFile <> -1 Then FileClose($hOutFile)

	Return SetError($iError, $iExtended, $bReturn)
EndFunc   ;==>_Crypt_DecryptFile

; #FUNCTION# ====================================================================================================================
; Author ........: Erik Pilsits (wraithdu)
; Modified ......: jpm
; ===============================================================================================================================
Func _Crypt_GenRandom($pBuffer, $iSize)
	_Crypt_Startup()
	If @error Then Return SetError(@error, @extended, False)

	Local $aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptGenRandom", "handle", __Crypt_Context(), "dword", $iSize, "struct*", $pBuffer)
	Local $iError = @error, $iExtended = @extended
	If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
	_Crypt_Shutdown()
	If $iError Or (Not $aCall[0]) Then
		Return SetError($iError + 10, $iExtended, False)
	Else
		Return True
	EndIf
EndFunc   ;==>_Crypt_GenRandom

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Crypt_RefCount
; Description ...: Retrieves the internal reference count.
; Syntax.........: __Crypt_RefCount ( )
; Parameters ....:
; Return values .: The current internal reference count.
; Author ........: Valik
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Crypt_RefCount()
	Return $__g_aCryptInternalData[0]
EndFunc   ;==>__Crypt_RefCount

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Crypt_RefCountInc
; Description ...: Increments the internal reference count.
; Syntax.........: __Crypt_RefCountInc ( )
; Parameters ....:
; Return values .:
; Author ........: Valik
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Crypt_RefCountInc()
	$__g_aCryptInternalData[0] += 1
EndFunc   ;==>__Crypt_RefCountInc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Crypt_RefCountDec
; Description ...: Decrements the internal reference count.
; Syntax.........: __Crypt_RefCountDec ( )
; Parameters ....:
; Return values .:
; Author ........: Valik
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Crypt_RefCountDec()
	If $__g_aCryptInternalData[0] > 0 Then $__g_aCryptInternalData[0] -= 1
EndFunc   ;==>__Crypt_RefCountDec

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Crypt_DllHandle
; Description ...: Retrieves the internal DLL handle.
; Syntax.........: __Crypt_DllHandle ( )
; Parameters ....:
; Return values .: The current internal DLL handle.
; Author ........: Valik
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Crypt_DllHandle()
	Return $__g_aCryptInternalData[1]
EndFunc   ;==>__Crypt_DllHandle

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Crypt_DllHandleSet
; Description ...: Stores the internal DLL handle.
; Syntax.........: __Crypt_DllHandleSet ( $hAdvapi32 )
; Parameters ....: $hAdvapi32 - The new handle to store.
; Return values .:
; Author ........: Valik
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Crypt_DllHandleSet($hAdvapi32)
	$__g_aCryptInternalData[1] = $hAdvapi32
EndFunc   ;==>__Crypt_DllHandleSet

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Crypt_Context
; Description ...: Retrieves the internal crypt context.
; Syntax.........: __Crypt_Context ( )
; Parameters ....:
; Return values .: The current internal crypt context.
; Author ........: Valik
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Crypt_Context()
	Return $__g_aCryptInternalData[2]
EndFunc   ;==>__Crypt_Context

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Crypt_ContextSet
; Description ...: Stores the internal crypt context.
; Syntax.........: __Crypt_ContextSet ( $hCryptContext )
; Parameters ....: $hCryptContext - The new crypt context to store.
; Return values .:
; Author ........: Valik
; Modified.......:
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Crypt_ContextSet($hCryptContext)
	$__g_aCryptInternalData[2] = $hCryptContext
EndFunc   ;==>__Crypt_ContextSet

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Crypt_GetCalgFromCryptKey
; Description ...: Retrieves the crypto-algorithm use by a USERKEY.
; Syntax.........: __Crypt_GetCalgFromCryptKey($vCryptKey)
; Parameters ....: $vCryptKey - The USERKEY handle.
; Return values .:
; Author ........: jchd
; Modified.......: jpm
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __Crypt_GetCalgFromCryptKey($vCryptKey)
	Local $tAlgId = DllStructCreate("uint")
	Local $aCall = DllCall(__Crypt_DllHandle(), "bool", "CryptGetKeyParam", "handle", $vCryptKey, "dword", $KP_ALGID, "struct*", $tAlgId, "dword*", DllStructGetSize($tAlgId), "dword", 0)
	Local $iError = @error, $iExtended = @extended
	If Not $aCall[0] Then $iExtended = _WinAPI_GetLastError()
	If $iError Or Not $aCall[0] Then
		Return SetError($iError + 80, $iExtended, $CRYPT_USERDATA)
	Else
		Return DllStructGetData($tAlgId, 1)
	EndIf
EndFunc   ;==>__Crypt_GetCalgFromCryptKey
