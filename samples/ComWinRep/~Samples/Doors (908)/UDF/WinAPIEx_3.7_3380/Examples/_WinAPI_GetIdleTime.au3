#Include <WinAPIEx.au3>

While 1
	ConsoleWrite('Idle time (ms): ' & _WinAPI_GetIdleTime() & @CR)
	Sleep(1000)
WEnd
