#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $Hue, $Luminance, $Saturation

_WinAPI_ColorRGBToHLS(0xFF8000, $Hue, $Luminance, $Saturation)

ConsoleWrite('Hue: ' & $Hue & @CR)
ConsoleWrite('Sat: ' & $Saturation & @CR)
ConsoleWrite('Lum: ' & $Luminance & @CR)
