#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

For $i = 1 To 3
	ConsoleWrite(_WinAPI_CreateGUID() & @CR)
Next
