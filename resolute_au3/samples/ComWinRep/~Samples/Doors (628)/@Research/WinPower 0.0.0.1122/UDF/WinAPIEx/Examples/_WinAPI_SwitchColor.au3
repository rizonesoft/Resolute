#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Color = 0xAADDFF

$Color = _WinAPI_SwitchColor($Color)
ConsoleWrite('0x' & Hex($Color, 6) & @CR)
$Color = _WinAPI_SwitchColor($Color)
ConsoleWrite('0x' & Hex($Color, 6) & @CR)
