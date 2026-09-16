#Include <APIConstants.au3>
#Include <EditConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Input1, $Input2, $Hash

$hForm = GUICreate('MyGUI', 400, 96)
$Input1 = GUICtrlCreateInput('', 20, 20, 360, 20)
GUICtrlSetLimit(-1, 255)
$Input2 = GUICtrlCreateInput('', 20, 56, 360, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY))
GUIRegisterMsg($WM_COMMAND, 'WM_COMMAND')
GUISetState()

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	Switch $hWnd
		Case $hForm
			Switch _WinAPI_LoWord($wParam)
				Case $Input1
					Switch _WinAPI_HiWord($wParam)
						Case $EN_CHANGE
							$Hash = _WinAPI_HashString(GUICtrlRead($Input1), 0, 16)
							If Not @error Then
								GUICtrlSetData($Input2, $Hash)
							Else
								GUICtrlSetData($Input2, '')
							EndIf
					EndSwitch
			EndSwitch
	EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND
