#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $aPrivileges[2] = [$SE_BACKUP_NAME, $SE_RESTORE_NAME]
Global $aAdjust, $hToken, $hKey

; Enable "SeBackupPrivilege" and "SeRestorePrivilege" privileges to save and restore registry hive
$hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
_WinAPI_AdjustTokenPrivileges($hToken, $aPrivileges, $SE_PRIVILEGE_ENABLED, $aAdjust)
If @error Or @extended Then
	MsgBox(16, 'Error', 'You do not have the required privileges.')
	Exit
EndIf

; Save "HKEY_CURRENT_USER\Software\AutoIt v3" to reg.dat
$hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, 'Software\AutoIt v3', $KEY_READ)
If _WinAPI_RegSaveKey($hKey, @ScriptDir & '\reg.dat', 1) Then
	MsgBox(64, '', '"HKEY_CURRENT_USER\Software\AutoIt v3" has been saved to reg.dat.')
Else
	MsgBox(16, '', _WinAPI_GetErrorMessage(@extended))
EndIf
_WinAPI_RegCloseKey($hKey)

; Restore "HKEY_CURRENT_USER\Software\AutoIt v3" to "HKEY_CURRENT_USER\Software\AutoIt v3 (Duplicate)"
$hKey = _WinAPI_RegCreateKey($HKEY_CURRENT_USER, 'Software\AutoIt v3 (Duplicate)', $KEY_WRITE)
If _WinAPI_RegRestoreKey($hKey, @ScriptDir & '\reg.dat') Then
	MsgBox(64, '', '"HKEY_CURRENT_USER\Software\AutoIt v3" has been restored to "HKEY_CURRENT_USER\Software\AutoIt v3 (Duplicate)".')
Else
	MsgBox(16, '', _WinAPI_GetErrorMessage(@extended))
EndIf
_WinAPI_RegCloseKey($hKey)

; Restore "SeBackupPrivilege" and "SeRestorePrivilege" privileges by default
_WinAPI_AdjustTokenPrivileges($hToken, $aAdjust, 0, $aAdjust)
_WinAPI_CloseHandle($hToken)

FileDelete(@ScriptDir & '\reg.dat')
