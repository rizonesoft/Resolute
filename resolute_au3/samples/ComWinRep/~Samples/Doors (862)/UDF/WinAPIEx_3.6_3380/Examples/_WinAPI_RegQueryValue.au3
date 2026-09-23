#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hKey, $tData

$hKey = _WinAPI_RegOpenKey($HKEY_LOCAL_MACHINE, 'SOFTWARE\AutoIt v3\AutoIt', $KEY_QUERY_VALUE)
If @error Then
	MsgBox(16, @extended, _WinAPI_GetErrorMessage(@extended))
	Exit
EndIf
$tData = DllStructCreate('wchar[260]')
_WinAPI_RegQueryValue($hKey, 'InstallDir', $tData)
_WinAPI_RegCloseKey($hKey)

ConsoleWrite(DllStructGetData($tData, 1) & @CR)
