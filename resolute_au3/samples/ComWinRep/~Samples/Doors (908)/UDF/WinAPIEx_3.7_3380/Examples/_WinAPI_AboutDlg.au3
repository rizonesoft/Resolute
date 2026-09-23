#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Button

$hForm = GUICreate('MyGUI', 400, 400)
$Button = GUICtrlCreateButton('About', 165, 366, 70, 23)
GUISetState()

While 1
    $Msg = GUIGetMsg()
    Switch $Msg
        Case -3
            ExitLoop
        Case $Button
            _WinAPI_AboutDlg('About', 'About Dialog Box Test', 'Simple Text', _WinAPI_ShellExtractIcon(@AutoItExe, 0, 32, 32), $hForm)
    EndSwitch
WEnd
