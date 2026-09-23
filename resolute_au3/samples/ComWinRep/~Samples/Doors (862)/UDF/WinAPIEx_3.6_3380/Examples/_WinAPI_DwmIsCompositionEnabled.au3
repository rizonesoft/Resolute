#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.0' Then
	MsgBox(16, 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

Dim $State[2] = ['Disabled', 'Enabled']

ConsoleWrite('Aero is: ' & $State[_WinAPI_DwmIsCompositionEnabled()] & @CR)
