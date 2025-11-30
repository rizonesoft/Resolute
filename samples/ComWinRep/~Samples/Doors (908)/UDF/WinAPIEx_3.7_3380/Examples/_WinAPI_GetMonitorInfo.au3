#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hMonitor, $Data

$hMonitor = _WinAPI_MonitorFromPoint(_WinAPI_GetMousePos())
If @error Then
	Exit
EndIf

$Data = _WinAPI_GetMonitorInfo($hMonitor)
If IsArray($Data) Then
	ConsoleWrite('Handle:      ' & $hMonitor & @CR)
	ConsoleWrite('Rectangle:   ' & DllStructGetData($Data[0], 1) & ', ' & DllStructGetData($Data[0], 2) & ', ' & DllStructGetData($Data[0], 3) & ', ' & DllStructGetData($Data[0], 4) & @CR)
	ConsoleWrite('Work area:   ' & DllStructGetData($Data[1], 1) & ', ' & DllStructGetData($Data[1], 2) & ', ' & DllStructGetData($Data[1], 3) & ', ' & DllStructGetData($Data[1], 4) & @CR)
	ConsoleWrite('Primary:     ' & $Data[2] & @CR)
	ConsoleWrite('Device name: ' & $Data[3] & @CR)
EndIf
