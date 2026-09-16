#Include <GUIConstantsEx.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Msg, $Button

$hForm = GUICreate('MyGUI', 400, 400)
$Button = GUICtrlCreateButton('About', 165, 366, 70, 23)
GUISetState()

While 1
    $Msg = GUIGetMsg()
    Switch $Msg
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case $Button
            _WinAPI_AboutDlg('About', 'About Dialog Box Test', 'Simple Text', _WinAPI_ShellExtractIcons(@SystemDir & '\shell32.dll', 130, 32, 32), $hForm)
    EndSwitch
WEnd
