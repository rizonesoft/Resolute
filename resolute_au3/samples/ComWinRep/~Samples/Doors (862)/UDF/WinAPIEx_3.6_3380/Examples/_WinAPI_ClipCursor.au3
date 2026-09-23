#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

_WinAPI_ClipCursor(_WinAPI_CreateRectEx(0, 0, 400, 400))
Sleep(5000)
_WinAPI_ClipCursor(0)
