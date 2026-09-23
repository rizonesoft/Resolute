#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $R, $G, $B, $RGB = 0xFF8040

$R = _WinAPI_GetRValue($RGB)
$G = _WinAPI_GetGValue($RGB)
$B = _WinAPI_GetBValue($RGB)

ConsoleWrite('Red:   0x' & Hex($R, 2) & @CR)
ConsoleWrite('Green: 0x' & Hex($G, 2) & @CR)
ConsoleWrite('Blue:  0x' & Hex($B, 2) & @CR)
ConsoleWrite('---------------' & @CR)
ConsoleWrite('RGB:   0x' & Hex(_WinAPI_RGB($R, $G, $B), 6) & @CR)
