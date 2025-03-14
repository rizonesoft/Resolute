#include <APIRegConstants.au3>
#include <Debug.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIError.au3>
#include <WinAPIReg.au3>

Local $hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, 'Software\AutoIt v3', $KEY_QUERY_VALUE)
If @error Then
	_DebugSetup(Default, True)
	_DebugReport("! RegOpenKey @error =" & @error & @CRLF & @TAB & _WinAPI_GetErrorMessage(@extended))
	Exit
EndIf

ConsoleWrite(_WinAPI_GetRegKeyNameByHandle($hKey) & @CRLF)

_WinAPI_RegCloseKey($hKey)
