#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Value = 0x11223344

ConsoleWrite('0x' & Hex($Value) & @CR)
ConsoleWrite('0x' & Hex(_WinAPI_SwapDWord($Value)) & @CR)
