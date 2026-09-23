#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path = 'C:\Documents\'

ConsoleWrite('Before: ' & $Path & @CR)
ConsoleWrite('After : ' & _WinAPI_PathRemoveBackslash($Path) & @CR)
