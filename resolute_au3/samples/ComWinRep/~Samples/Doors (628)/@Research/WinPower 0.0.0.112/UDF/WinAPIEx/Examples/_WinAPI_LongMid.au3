#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Value = 0x00FA0000

ConsoleWrite('0x' & Hex(_WinAPI_LongMid($Value, 16, 4)) & @CR)
ConsoleWrite('0x' & Hex(_WinAPI_LongMid($Value, 20, 4)) & @CR)
