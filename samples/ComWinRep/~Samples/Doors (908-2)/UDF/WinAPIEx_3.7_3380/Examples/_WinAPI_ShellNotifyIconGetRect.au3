#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If _WinAPI_GetVersion() < '6.1' Then
	MsgBox(16, 'Error', 'Require Windows 7 or later.')
	Exit
EndIf

Global $tRECT, $Pos

$tRECT = _WinAPI_ShellNotifyIconGetRect(WinGetHandle(AutoItWinGetTitle()), 1)

If Not @error Then
	$Pos = _WinAPI_GetPosFromRect($tRECT)
	MouseMove($Pos[0] + 12, $Pos[1] + 12)
	MouseClick('left')
	While 1
		Sleep(1000)
	WEnd
EndIf
