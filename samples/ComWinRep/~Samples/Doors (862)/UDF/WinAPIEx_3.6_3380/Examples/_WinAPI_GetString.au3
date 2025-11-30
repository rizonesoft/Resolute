#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $WM_MYMESSAGE = _WinAPI_RegisterWindowMessage('MyMessage')

Global $hForm, $Msg, $Button, $Input, $pString

$hForm = GUICreate('MyGUI', 400, 93)
$Input = GUICtrlCreateInput('', 20, 20, 360, 20)
$Button = GUICtrlCreateButton('Send', 165, 59, 70, 23)
GUIRegisterMsg($WM_MYMESSAGE, 'WM_MYMESSAGE')
GUISetState()

While 1
    $Msg = GUIGetMsg()
    Switch $Msg
        Case -3
            ExitLoop
        Case $Button
			$pString = _WinAPI_CreateString(GUICtrlRead($Input))
			_WinAPI_SetMessageExtraInfo($pString)
			_SendMessage($hForm, $WM_MYMESSAGE, 1, 255)
			_WinAPI_FreeMemory($pString)
    EndSwitch
WEnd

Func WM_MYMESSAGE($hWnd, $iMsg, $wParam, $lParam)

	Local $pString = _WinAPI_GetMessageExtraInfo()

	If _WinAPI_IsMemory($pString) Then
		ConsoleWrite('WM_MYMESSAGE | WP = ' & Number($wParam) & ' | LP = ' & Number($lParam) & ' | EXTRA = "' & _WinAPI_GetString($pString) & '"' & @CR)
	EndIf
EndFunc   ;==>WM_MYMESSAGE
