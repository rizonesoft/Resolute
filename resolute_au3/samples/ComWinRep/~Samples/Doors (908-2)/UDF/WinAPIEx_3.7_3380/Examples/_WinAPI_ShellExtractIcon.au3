#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172

Global $hForm, $Msg, $Button, $Icon, $hIcon, $Index = 0, $Total = _WinAPI_ExtractIconEx(@SystemDir & '\shell32.dll', -1, 0, 0, 0)

$hForm = GUICreate('MyGUI', 160, 160)
$Button = GUICtrlCreateButton('Next', 50, 130, 70, 23)
$Icon = GUICtrlCreateIcon(@SystemDir & '\shell32.dll', 0, 69, 54, 32, 32)
$hIcon = GUICtrlGetHandle(-1)
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case -3
			ExitLoop
		Case $Button
			$Index += 1
			IF $Index > $Total - 1 Then
				$Index = 0
			EndIF
			_WinAPI_DestroyIcon(_SendMessage($hIcon, $STM_SETIMAGE, 1, _WinAPI_ShellExtractIcon(@SystemDir & '\shell32.dll', $Index, 32, 32)))
	EndSwitch
WEnd
