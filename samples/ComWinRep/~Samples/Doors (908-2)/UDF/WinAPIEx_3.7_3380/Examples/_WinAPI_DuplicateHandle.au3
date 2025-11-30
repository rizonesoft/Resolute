#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hPseudo = _WinAPI_GetCurrentProcess()
Global $hReal = _WinAPI_DuplicateHandle($hPseudo, $hPseudo, $hPseudo)

ConsoleWrite('Process name:  ' & _WinAPI_GetProcessName() & @CR)
ConsoleWrite('Process ID:    ' & @AutoItPID & @CR)
ConsoleWrite('Pseudo handle: ' & $hPseudo & @CR)
ConsoleWrite('Real handle:   ' & $hReal & @CR)

_WinAPI_CloseHandle($hReal)
