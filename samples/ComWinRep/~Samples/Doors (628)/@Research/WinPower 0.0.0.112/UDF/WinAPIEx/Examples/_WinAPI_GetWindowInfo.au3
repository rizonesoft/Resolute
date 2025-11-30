#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tWINDOWINFO = _WinAPI_GetWindowInfo(_WinAPI_GetDesktopWindow())

ConsoleWrite('Left:   ' & DllStructGetData($tWINDOWINFO, 'rWindow', 1) & @CR)
ConsoleWrite('Top:    ' & DllStructGetData($tWINDOWINFO, 'rWindow', 2) & @CR)
ConsoleWrite('Right:  ' & DllStructGetData($tWINDOWINFO, 'rWindow', 3) & @CR)
ConsoleWrite('Bottom: ' & DllStructGetData($tWINDOWINFO, 'rWindow', 4) & @CR)
