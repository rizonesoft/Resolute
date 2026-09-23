#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Pos = _WinAPI_GetPosFromRect(_WinAPI_CreateRectEx(10, 10, 100, 100))

ConsoleWrite('Left:   ' & $Pos[0] & @CR)
ConsoleWrite('Top:    ' & $Pos[1] & @CR)
ConsoleWrite('Width:  ' & $Pos[2] & @CR)
ConsoleWrite('Height: ' & $Pos[3] & @CR)
