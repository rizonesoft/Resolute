#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Value = 4294967295

ConsoleWrite(_WinAPI_DWordToInt($Value) & @CR)
