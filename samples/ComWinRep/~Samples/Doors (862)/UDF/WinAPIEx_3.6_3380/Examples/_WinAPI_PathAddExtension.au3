#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Path[2] = ['C:\Documents\Test.txt', 'C:\Documents\Test']

For $i = 0 To 1
	ConsoleWrite($Path[$i] & ' => ' & _WinAPI_PathAddExtension($Path[$i], '.doc') & @CR)
Next
