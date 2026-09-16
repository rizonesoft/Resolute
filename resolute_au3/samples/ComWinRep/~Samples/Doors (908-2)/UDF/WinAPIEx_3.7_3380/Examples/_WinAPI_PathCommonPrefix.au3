#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path1 = 'C:\Documents\Test.txt'
Global $Path2 = 'C:\Documents\Archive\Sample.txt'

ConsoleWrite('Path1 : ' & $Path1 & @CR)
ConsoleWrite('Path2 : ' & $Path2 & @CR)
ConsoleWrite('Prefix: ' & _WinAPI_PathCommonPrefix($Path1, $Path2) & @CR)
