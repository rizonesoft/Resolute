#Include <Array.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $aValent[19][4], $hKey, $tData

; Note that if at least one of the following value names is not found in the specified registry key, the function fails!

; HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders

$aValent[0 ][0] = 'AppData'
$aValent[1 ][0] = 'Cache'
$aValent[2 ][0] = 'Cookies'
$aValent[3 ][0] = 'Desktop'
$aValent[4 ][0] = 'Favorites'
$aValent[5 ][0] = 'History'
$aValent[6 ][0] = 'Local AppData'
$aValent[7 ][0] = 'My Music'
$aValent[8 ][0] = 'My Pictures'
$aValent[9 ][0] = 'My Video'
$aValent[10][0] = 'NetHood'
$aValent[11][0] = 'Personal'
$aValent[12][0] = 'PrintHood'
$aValent[13][0] = 'Programs'
$aValent[14][0] = 'Recent'
$aValent[15][0] = 'SendTo'
$aValent[16][0] = 'Start Menu'
$aValent[17][0] = 'Startup'
$aValent[18][0] = 'Templates'

$hKey = _WinAPI_RegOpenKey($HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders', $KEY_QUERY_VALUE)
If @error Then
	ConsoleWrite(_WinAPI_GetErrorMessage(@extended) & @CR)
	Exit
EndIf
_WinAPI_RegQueryMultipleValues($hKey, $aValent, $tData)
If @error Then
	ConsoleWrite(_WinAPI_GetErrorMessage(@extended) & @CR)
	Exit
EndIf

_WinAPI_RegCloseKey($hKey)

_ArrayDisplay($aValent, '_WinAPI_RegQueryMultipleValues')

For $i = 0 To UBound($aValent) - 1
	$aValent[$i][2] = DllStructGetData(DllStructCreate('wchar[' & $aValent[$i][1] & ']', $aValent[$i][2]), 1)
Next

$tData = 0

_ArrayDisplay($aValent, '_WinAPI_RegQueryMultipleValues')
