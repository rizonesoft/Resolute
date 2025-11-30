#Include <APIConstants.au3>
#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hKey, $Count

$hKey = _WinAPI_RegOpenKey($HKEY_CLASSES_ROOT, 'CLSID', $KEY_READ)
If @error Then
	MsgBox(16, @extended, _WinAPI_GetErrorMessage(@extended))
	Exit
EndIf
$Count = _WinAPI_RegQueryInfoKey($hKey)
Dim $aKey[$Count[0]]
For $i = 0 To UBound($aKey) - 1
	$aKey[$i] = _WinAPI_RegEnumKey($hKey, $i)
Next

_WinAPI_RegCloseKey($hKey)

_ArrayDisplay($aKey, '_WinAPI_RegEnumKey')
