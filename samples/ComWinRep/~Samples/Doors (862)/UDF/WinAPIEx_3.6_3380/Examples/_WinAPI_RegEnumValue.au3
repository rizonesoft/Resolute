#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hKey, $Count

$hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Run', $KEY_READ)
If @error Then
	MsgBox(16, @extended, _WinAPI_GetErrorMessage(@extended))
	Exit
EndIf
$Count = _WinAPI_RegQueryInfoKey($hKey)
Dim $aKey[$Count[2]]
For $i = 0 To UBound($aKey) - 1
	$aKey[$i] = _WinAPI_RegEnumValue($hKey, $i)
Next

_WinAPI_RegCloseKey($hKey)

_ArrayDisplay($aKey, '_WinAPI_RegEnumValue')
