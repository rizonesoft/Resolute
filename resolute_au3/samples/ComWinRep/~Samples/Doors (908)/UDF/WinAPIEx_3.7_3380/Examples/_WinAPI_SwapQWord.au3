#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Value = _WinAPI_MakeQWord(0x55667788, 0x11223344)

ConsoleWrite('0x' & _WinAPI_Hex64($Value) & @CR)
ConsoleWrite('0x' & _WinAPI_Hex64(_WinAPI_SwapQWord($Value)) & @CR)
