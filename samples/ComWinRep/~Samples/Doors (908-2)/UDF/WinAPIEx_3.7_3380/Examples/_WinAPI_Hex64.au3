#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Value = 9223372036854775807

ConsoleWrite('DEC: ' & $Value & @CR)
ConsoleWrite('HEX: 0x' & _WinAPI_Hex64($Value) & @CR)
