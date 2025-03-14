#RequireAdmin ; for this example to have sense

#include <MsgBoxConstants.au3>
#include <Security.au3>
#include <SecurityConstants.au3>
#include <WinAPIHObj.au3>

Example_GetTokInfo()

Example_SetTokInfo()

Func Example_GetTokInfo()
	Local $hProcess = _WinAPI_GetCurrentProcess()
	If @error Then Return ; check for possible errors

	Local $hToken = _Security__OpenProcessToken($hProcess, $TOKEN_ALL_ACCESS)
	; If token is get...
	If $hToken Then
		; Get information about the type of this token:
		Local $tInfo = _Security__GetTokenInformation($hToken, $TOKENTYPE)
		; The result will be raw binary data. For $TOKENTYPE it's TOKEN_TYPE value (enum value). Reinterpreting as "int" type therefore:
		Local $iTokenType = DllStructGetData(DllStructCreate("int", DllStructGetPtr($tInfo)), 1)

		MsgBox($MB_SYSTEMMODAL, "GetTokenInformation", "Token type is " & $iTokenType) ; Can be value of either $TOKENPRIMARY = 1 or $TOKENIMPERSONATION = 2

		; Close the token handle
		_WinAPI_CloseHandle($hToken)
	EndIf
EndFunc   ;==>Example_GetTokInfo

Func Example_SetTokInfo()
	Local $hProcess = _WinAPI_GetCurrentProcess()
	If @error Then Return ; check for possible errors

	Local $hToken = _Security__OpenProcessToken($hProcess, $TOKEN_ALL_ACCESS)

	; If token is get...
	If $hToken Then
		; Set Medium Integrity Level for this token.
		Local $tSID = _Security__StringSidToSid($SID_MEDIUM_MANDATORY_LEVEL)
		; Define TOKEN_MANDATORY_LABEL structure
		Local Const $tTOKEN_MANDATORY_LABEL = DllStructCreate("ptr Sid; dword Attributes")
		; Fill it with wanted data
		DllStructSetData($tTOKEN_MANDATORY_LABEL, "Sid", DllStructGetPtr($tSID, 1))
		DllStructSetData($tTOKEN_MANDATORY_LABEL, "Attributes", $SE_GROUP_INTEGRITY)

		If _Security__SetTokenInformation($hToken, $TOKENINTEGRITYLEVEL, $tTOKEN_MANDATORY_LABEL, DllStructGetSize($tTOKEN_MANDATORY_LABEL)) Then

			; Default IL is $SID_HIGH_MANDATORY_LEVEL, however...
			MsgBox($MB_SYSTEMMODAL, "SetTokenInformation", "$hToken = " & $hToken & @CRLF & "This token have non-default Medium Integrity Level")

			; ... Do something with token here ...

		EndIf
		; Close the token handle when no longer needed
		_WinAPI_CloseHandle($hToken)
	EndIf
EndFunc   ;==>Example_SetTokInfo
