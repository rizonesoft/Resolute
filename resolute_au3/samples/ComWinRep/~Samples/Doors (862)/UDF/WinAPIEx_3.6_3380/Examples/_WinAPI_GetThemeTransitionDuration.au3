#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $BP_PUSHBUTTON = 1
Global Const $PBS_NORMAL = 1
Global Const $PBS_HOT = 2

Global $hTheme, $Val

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

$hTheme = _WinAPI_OpenThemeData(0, 'Button')
$Val = _WinAPI_GetThemeTransitionDuration($hTheme, $BP_PUSHBUTTON, $PBS_NORMAL, $PBS_HOT, $TMT_TRANSITIONDURATIONS)
_WinAPI_CloseThemeData($hTheme)

ConsoleWrite('Transition from "Hot" to "Normal" state: ' & $Val & ' ms' & @CR)
