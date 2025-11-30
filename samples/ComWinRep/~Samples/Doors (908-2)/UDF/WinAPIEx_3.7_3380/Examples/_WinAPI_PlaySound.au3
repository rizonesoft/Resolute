#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sWav = @ScriptDir & '\Extras\Airplane.wav'

Global $hForm, $Msg, $Button, $bWav, $tWav, $pWav, $Play = False

; Read Airplane.wav to memory
$bWav = FileRead($sWav)
If @error Then
	MsgBox(16, 'Error', 'Unable to read "' & $sWav & '"')
	Exit
EndIf
$tWav = DllStructCreate('byte[' & BinaryLen($bWav) & ']')
DllStructSetData($tWav, 1, $bWav)
$pWav = DllStructGetPtr($tWav)

; Create GUI
$hForm = GUICreate('MyGUI', 200, 200)
$Button = GUICtrlCreateButton('Play', 70, 70, 60, 60)
GUISetState()

While 1
    $Msg = GUIGetMsg()
    Switch $Msg
        Case -3
            ExitLoop
        Case $Button
            $Play = Not $Play
            If $Play Then
                _WinAPI_PlaySound($pWav, BitOR($SND_ASYNC, $SND_LOOP, $SND_MEMORY))
                GUICtrlSetData($Button, 'Stop')
            Else
                _WinAPI_PlaySound('')
                GUICtrlSetData($Button, 'Play')
            EndIf
    EndSwitch
WEnd
