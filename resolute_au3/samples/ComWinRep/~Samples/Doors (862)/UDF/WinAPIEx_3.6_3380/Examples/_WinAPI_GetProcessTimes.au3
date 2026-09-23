#Include <Date.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $aFT, $tFT, $tST, $ID = ProcessExists('SciTE.exe')

If $ID Then
	$aFT = _WinAPI_GetProcessTimes($ID)
	$tFT = _Date_Time_FileTimeToLocalFileTime(DllStructGetPtr($aFT[0]))
	$tST = _Date_Time_FileTimeToSystemTime(DllStructGetPtr($tFT))
	ConsoleWrite('SciTE was run at: ' & _WinAPI_GetTimeFormat(0, $tST) & @CR)
EndIf
