#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

ConsoleWrite(_WinAPI_StrFromTimeInterval(_WinAPI_GetTickCount()) & @CR)
