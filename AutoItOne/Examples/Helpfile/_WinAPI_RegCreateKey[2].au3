; example with key containing subkey

#include <Debug.au3>
#include <WinAPIReg.au3>

_DebugSetup(Default, True)

Example()

Func Example()
	Local $hKey = _WinAPI_RegCreateKey("HKEY_CURRENT_USER\Temp")
	If $hKey Then
		_DebugReport("- Key successfully Created" & @CRLF)
		Local $iDeleteKey = _WinAPI_RegDeleteKey($hKey)
		If $iDeleteKey Then
			_DebugReport("- Key successfully Deleted" & @CRLF)
		Else
			_DebugReport("! Key cannot be deleted @error = " & @error & @CRLF)
		EndIf
		_WinAPI_RegCloseKey($hKey)
		$iDeleteKey = _WinAPI_RegDeleteKey($hKey)
		If $iDeleteKey Then
			_DebugReport("! Key Close unsuccessful" & @CRLF)
		Else
			_DebugReport("- Key already deleted" & @CRLF)
		EndIf
	Else
		_DebugReport("! Key cannot be created @error = " & @error & @CRLF)
	EndIf

EndFunc   ;==>Example
