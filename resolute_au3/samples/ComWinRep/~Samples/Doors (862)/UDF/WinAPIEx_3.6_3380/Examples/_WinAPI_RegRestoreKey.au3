#RequireAdmin

#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hKey

; Save "HKEY_CURRENT_USER\Software\AutoIt v3" to reg.dat
$hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, 'Software\AutoIt v3', $KEY_READ)
If _WinAPI_RegSaveKey($hKey, @ScriptDir & '\reg.dat') Then
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

FileDelete(@ScriptDir & '\reg.dat')
