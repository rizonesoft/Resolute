#Include <WinAPIEx.au3>

Opt('GUICloseOnESC', 0) 
Opt('MustDeclareVars', 1)

Global $Label, $Key, $Prev = Default

GUICreate('MyGUI', 200, 200)
$Label = GUICtrlCreateLabel('', 10, 59, 180, 82, 0x01)
GUICtrlSetFont(-1, 48, 400, 0, 'Tahoma')
GUISetState()

While 1
    Sleep(10)
    If GUIGetMsg() = -3 Then
        ExitLoop
    EndIf
    $Key = 0
	$Key = _WinAPI_IsPressed(0x08, 0xFF)
    If $Key <> $Prev Then
        GUICtrlSetData($Label, '0x' & Hex($Key, 2))
        $Prev = $Key
    EndIf
WEnd
