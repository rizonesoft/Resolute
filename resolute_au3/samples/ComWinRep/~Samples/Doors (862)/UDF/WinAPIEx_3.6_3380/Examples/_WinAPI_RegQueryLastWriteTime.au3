#Include <APIConstants.au3>
#Include <Date.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hKey, $tFT, $tST

$hKey = _WinAPI_RegOpenKey($HKEY_LOCAL_MACHINE, 'SOFTWARE\AutoIt v3\AutoIt', $KEY_QUERY_VALUE)
If @error Then
	MsgBox(16, @extended, _WinAPI_GetErrorMessage(@extended))
	Exit
EndIf
$tFT = _WinAPI_RegQueryLastWriteTime($hKey)
$tFT = _Date_Time_FileTimeToLocalFileTime(DllStructGetPtr($tFT))
$tST = _Date_Time_FileTimeToSystemTime(DllStructGetPtr($tFT))
_WinAPI_RegCloseKey($hKey)

ConsoleWrite('Last modified at: ' & _WinAPI_GetDateFormat(0, $tST) & ' ' & _WinAPI_GetTimeFormat(0, $tST) & @CR)
