#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Value = Int('0x1111111122222222')

ConsoleWrite('0x' & Hex(_WinAPI_HiDWord($Value)) & @CR)
ConsoleWrite('0x' & Hex(_WinAPI_LoDWord($Value)) & @CR)
