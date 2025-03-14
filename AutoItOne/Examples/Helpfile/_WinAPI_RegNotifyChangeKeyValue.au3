#include <APIRegConstants.au3>
#include <Debug.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIError.au3>
#include <WinAPIHObj.au3>
#include <WinAPIProc.au3>
#include <WinAPIReg.au3>

Opt('TrayAutoPause', 0)

Example()

Func Example()
	Local $sKey = 'Software\AutoIt v3'
	Local $hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, $sKey, $KEY_NOTIFY)
	If @error Then
		_DebugSetup(Default, True)
		_DebugReport("! RegOpenKey @error =" & @error & @CRLF & @TAB &_WinAPI_GetErrorMessage(@extended))
		Exit
	EndIf
	Local $hEvent = _WinAPI_CreateEvent()
	If Not _WinAPI_RegNotifyChangeKeyValue($hKey, $REG_NOTIFY_CHANGE_LAST_SET, 0, 1, $hEvent) Then
		Exit
	EndIf

	RegWrite("HKCU\" & $sKey, "text", "REG_DWORD", 1) ; to simulate the change

	While 1
		If Not _WinAPI_WaitForSingleObject($hEvent, 0) Then
			Run(@AutoItExe & ' /AutoIt3ExecuteLine "MsgBox(4096, ''Registry'', ''The registry hive has been modified.'' & @CRLF & @CRLF & ''HKEY_CURRENT_USER\Software\AutoIt v3'', 5)"')
			ExitLoop
		EndIf
		Sleep(100)
	WEnd

	RegDelete("HKCU\" & $sKey, "text")
	_WinAPI_CloseHandle($hEvent)
	_WinAPI_RegCloseKey($hKey)

EndFunc   ;==>Example
