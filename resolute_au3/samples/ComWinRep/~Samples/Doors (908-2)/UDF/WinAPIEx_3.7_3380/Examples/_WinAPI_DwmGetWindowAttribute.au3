#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If Not _WinAPI_DwmIsCompositionEnabled() Then
	MsgBox(16, 'Error', 'Require Windows Vista or later with enabled Aero theme.')
	Exit
EndIf

Global $hWnd, $Pos

Run(@SystemDir & '\calc.exe')
$hWnd = WinWaitActive('Calculator', '', 3)
If Not $hWnd Then
	Exit
EndIf

$Pos = _WinAPI_GetPosFromRect(_WinAPI_DwmGetWindowAttribute($hWnd, $DWMWA_EXTENDED_FRAME_BOUNDS))

ConsoleWrite('Left:   ' & $Pos[0] & @CR)
ConsoleWrite('Top:    ' & $Pos[1] & @CR)
ConsoleWrite('Width:  ' & $Pos[2] & @CR)
ConsoleWrite('Height: ' & $Pos[3] & @CR)
