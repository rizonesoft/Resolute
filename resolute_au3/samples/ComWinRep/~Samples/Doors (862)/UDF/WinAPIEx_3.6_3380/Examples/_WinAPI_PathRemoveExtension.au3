#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path = 'C:\Documents\Test.txt'

ConsoleWrite('Before: ' & $Path & @CR)
ConsoleWrite('After : ' & _WinAPI_PathRemoveExtension($Path) & @CR)
