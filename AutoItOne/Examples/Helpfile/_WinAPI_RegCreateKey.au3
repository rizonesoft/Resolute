#RequireAdmin

#include <Debug.au3>
#include <WinAPIReg.au3>

_DebugSetup(Default, True)

Example()

Func Example()
	Local $sKey = 'SOFTWARE\Temp'

	; must run with #RequireAdmin
	Local $sKeyroot = "HKEY_LOCAL_MACHINE"
;~ 	Local $sKeyroot = "HKEY_CURRENT_USER"

	_DebugReport("- Key Creation" & @TAB & $sKeyroot & "/" & $sKey & @CRLF & @CRLF)

	Local $hKey = _WinAPI_RegCreateKey($sKeyroot, $sKey)
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
		_DebugReport("! Key cannot be created @error = " & @error & '    Extended code: ' & @extended & ' (0x' & Hex(@extended) & ')' & @CRLF)
	EndIf

EndFunc   ;==>Example
