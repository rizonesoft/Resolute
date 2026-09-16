#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

Global $hKey, $hEvent

$hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Run', $KEY_NOTIFY)
If @error Then
	MsgBox(16, @extended, _WinAPI_GetErrorMessage(@extended))
	Exit
EndIf
$hEvent = _WinAPI_CreateEvent()
If Not _WinAPI_RegNotifyChangeKeyValue($hKey, $REG_NOTIFY_CHANGE_LAST_SET, 0, 1, $hEvent) Then
    Exit
EndIf

While 1
    If Not _WinAPI_WaitForSingleObject($hEvent, 0) Then
		Run(@AutoItExe & ' /AutoIt3ExecuteLine "MsgBox(48, ''Registry'', ''The registry hive has been modified.'' & @CR & @CR & ''HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run'', 5)"')
		If Not _WinAPI_RegNotifyChangeKeyValue($hKey, $REG_NOTIFY_CHANGE_LAST_SET, 0, 1, $hEvent) Then
			ExitLoop
		EndIf
    EndIf
    Sleep(100)
WEnd

_WinAPI_CloseHandle($hEvent)
_WinAPI_RegCloseKey($hKey)
