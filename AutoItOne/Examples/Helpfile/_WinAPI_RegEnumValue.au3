#include <APIRegConstants.au3>
#include <Debug.au3>
#include <WinAPIError.au3>
#include <WinAPIReg.au3>

Example()

Func Example()
	Local $hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Run', $KEY_READ)
	If @error Then
		_DebugSetup(Default, True)
		_DebugReport("! RegOpenKey @error =" & @error & @TAB & _WinAPI_GetErrorMessage(@extended) & @CRLF)
		Exit
	EndIf
	Local $iCount = _WinAPI_RegQueryInfoKey($hKey)
	Local $aKey[$iCount[2]]
	For $i = 0 To UBound($aKey) - 1
		$aKey[$i] = _WinAPI_RegEnumValue($hKey, $i)
	Next

	_WinAPI_RegCloseKey($hKey)

	_DebugArrayDisplay($aKey, '_WinAPI_RegEnumValue')

EndFunc   ;==>Example
