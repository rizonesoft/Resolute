#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path1 = 'C:\Documents\Text'
Global $Path2 = '..\Test.txt'

ConsoleWrite('Path1 : ' & $Path1 & @CR)
ConsoleWrite('Path2 : ' & $Path2 & @CR)
ConsoleWrite('Result: ' & _WinAPI_PathAppend($Path1, $Path2) & @CR)
