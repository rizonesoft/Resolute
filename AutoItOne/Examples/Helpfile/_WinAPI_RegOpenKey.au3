#include <APIRegConstants.au3>
#include <Date.au3>
#include <Debug.au3>
#include <WinAPIError.au3>
#include <WinAPILocale.au3>
#include <WinAPIReg.au3>

_DebugSetup(Default, True)

Example()

Func Example()
	Local $hKey = _WinAPI_RegOpenKey($HKEY_LOCAL_MACHINE, 'SOFTWARE\AutoIt v3\AutoIt', $KEY_QUERY_VALUE)
	If @error Then
		_DebugReport("! RegOpenKey @error =" & @error & @CRLF & @TAB &_WinAPI_GetErrorMessage(@extended) & @CRLF)
		Exit
	EndIf

	Local $tFT = _WinAPI_RegQueryLastWriteTime($hKey)
	$tFT = _Date_Time_FileTimeToLocalFileTime($tFT)
	Local $tST = _Date_Time_FileTimeToSystemTime($tFT)
	_WinAPI_RegCloseKey($hKey)

	_DebugReport('! Last modified at: ' & _WinAPI_GetDateFormat(0, $tST) & ' ' & _WinAPI_GetTimeFormat(0, $tST) & @CRLF)

EndFunc   ;==>Example
