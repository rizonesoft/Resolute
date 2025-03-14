#include <APIRegConstants.au3>
#include <Date.au3>
#include <Debug.au3>
#include <WinAPIError.au3>
#include <WinAPIReg.au3>

Example()

Func Example()
	Local $hKey = _WinAPI_RegOpenKey($HKEY_CLASSES_ROOT, 'CLSID', $KEY_READ)
	If @error Then
		_DebugSetup(Default, True)
		_DebugReport("! RegOpenKey @error =" & @error & @CRLF & @TAB & _WinAPI_GetErrorMessage(@extended))
		Exit
	EndIf
	Local $iCount = _WinAPI_RegQueryInfoKey($hKey)
	Local $aKey[$iCount[0]][2], $tLocalFILETIME, $tFileWriteTime
	For $i = 0 To UBound($aKey) - 1
		$aKey[$i][0] = _WinAPI_RegEnumKey($hKey, $i)
		$tFileWriteTime = @extended
		If $tFileWriteTime Then
			$tLocalFILETIME = _Date_Time_FileTimeToLocalFileTime($tFileWriteTime)
			$aKey[$i][1] = _Date_Time_FileTimeToStr($tLocalFILETIME, 1)
		EndIf
	Next

	_WinAPI_RegCloseKey($hKey)

	_DebugArrayDisplay($aKey, '_WinAPI_RegEnumKey')

EndFunc   ;==>Example
