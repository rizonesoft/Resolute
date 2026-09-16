#Include <APIConstants.au3>
#Include <Date.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tFILETIME, $hFile, $aInfo

$hFile = _WinAPI_CreateFile(@ScriptFullPath, 2, 0, 6)
$aInfo = _WinAPI_GetFileInformationByHandle($hFile)
If IsArray($aInfo) Then
	For $i = 1 To 3
		If IsDllStruct($aInfo[$i]) Then
			$tFILETIME = _Date_Time_FileTimeToLocalFileTime(DllStructGetPtr($aInfo[$i]))
			$aInfo[$i] = _Date_Time_FileTimeToSystemTime(DllStructGetPtr($tFILETIME))
			$aInfo[$i] = _Date_Time_SystemTimeToDateTimeStr($aInfo[$i])
		Else
			$aInfo[$i] = 'Unknown'
		EndIf
	Next
	ConsoleWrite('Path:          ' & _WinAPI_GetFinalPathNameByHandle($hFile) & @CR)
	ConsoleWrite('Attributes:    0x' & Hex($aInfo[0]) & @CR)
	ConsoleWrite('Created:       ' & $aInfo[1] & @CR)
	ConsoleWrite('Accessed:      ' & $aInfo[2] & @CR)
	ConsoleWrite('Modified:      ' & $aInfo[3] & @CR)
	ConsoleWrite('Volume serial: ' & $aInfo[4] & @CR)
	ConsoleWrite('Size:          ' & $aInfo[5] & @CR)
	ConsoleWrite('Links:         ' & $aInfo[6] & @CR)
	ConsoleWrite('ID:            ' & $aInfo[7] & @CR)
EndIf
_WinAPI_CloseHandle($hFile)
