#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hKey, $tData

$hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, 'Software\AutoIt v3', $KEY_QUERY_VALUE)
If @error Then
	MsgBox(16, @extended, _WinAPI_GetErrorMessage(@extended))
	Exit
EndIf

ConsoleWrite(_WinAPI_GetRegKeyNameByHandle($hKey) & @CR)

_WinAPI_RegCloseKey($hKey)
