#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Value = 0x1122

ConsoleWrite('0x' & Hex($Value, 4) & @CR)
ConsoleWrite('0x' & Hex(_WinAPI_SwapWord($Value), 4) & @CR)
