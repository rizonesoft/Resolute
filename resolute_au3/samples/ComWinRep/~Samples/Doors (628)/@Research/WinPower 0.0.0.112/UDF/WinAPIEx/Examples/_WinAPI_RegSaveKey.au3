#RequireAdmin

#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hKey

; Save "HKEY_CURRENT_USER\Software\AutoIt v3" to reg.dat
$hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, 'Software\AutoIt v3', $KEY_READ)
_WinAPI_RegSaveKey($hKey, @ScriptDir & '\reg.dat')
_WinAPI_RegCloseKey($hKey)
MsgBox(0, '', '"HKEY_CURRENT_USER\Software\AutoIt v3" has been saved to red.dat.')

; Restore "HKEY_CURRENT_USER\Software\AutoIt v3" to "HKEY_CURRENT_USER\Software\AutoIt v3 (Duplicate)"
$hKey = _WinAPI_RegCreateKey($HKEY_CURRENT_USER, 'Software\AutoIt v3 (Duplicate)', $KEY_WRITE)
_WinAPI_RegRestoreKey($hKey, @ScriptDir & '\reg.dat')
_WinAPI_RegCloseKey($hKey)
MsgBox(0, '', '"HKEY_CURRENT_USER\Software\AutoIt v3" has been restored to "HKEY_CURRENT_USER\Software\AutoIt v3 (Duplicate)".')

FileDelete(@ScriptDir & '\reg.dat')
