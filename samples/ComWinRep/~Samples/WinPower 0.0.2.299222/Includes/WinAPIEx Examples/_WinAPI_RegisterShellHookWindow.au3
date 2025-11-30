#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm

$hForm = GUICreate('')
GUIRegisterMsg(_WinAPI_RegisterWindowMessage('SHELLHOOK'), '_ShellHookProc')
_WinAPI_RegisterShellHookWindow($hForm)

While 1
	Sleep(100)
WEnd

Func _ShellHookProc($hWnd, $iMsg, $wParam, $lParam)
	Switch $hWnd
		Case $hForm
			Switch $wParam
				Case $HSHELL_WINDOWACTIVATED

					Local $Title = WinGetTitle($lParam)

					If IsString($Title) Then
						ConsoleWrite('Activated: ' & $Title & @CR)
					EndIf
			EndSwitch
	EndSwitch
EndFunc   ;==>_ShellHookProc

Func OnAutoItExit()
	_WinAPI_DeregisterShellHookWindow($hForm)
EndFunc   ;==>OnAutoItExit
