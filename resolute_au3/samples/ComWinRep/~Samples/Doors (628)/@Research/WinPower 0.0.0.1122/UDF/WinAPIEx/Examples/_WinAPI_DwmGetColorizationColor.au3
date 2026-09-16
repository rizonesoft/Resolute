#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If Not _WinAPI_DwmIsCompositionEnabled() Then
	MsgBox(16, 'Error', 'Require Windows Vista or later with enabled Aero theme.')
	Exit
EndIf

Global $Color, $Blend

$Color = _WinAPI_DwmGetColorizationColor()
$Blend = @extended

ConsoleWrite('Color for glass composition: 0x' & Hex($Color) & @CR)
ConsoleWrite('Transparency: ' & (Not $Blend) & @CR)
