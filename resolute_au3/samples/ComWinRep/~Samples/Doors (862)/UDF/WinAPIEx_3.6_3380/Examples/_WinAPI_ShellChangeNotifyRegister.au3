#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

Global Const $sPath = @ScriptDir & '\~TEST~'

Global $hWnd, $iMsg, $ID

DirCreate($sPath)
If Not FileExists($sPath) Then
	MsgBox(16, 'Error', 'Unable to create folder.')
	Exit
EndIf

OnAutoItExitRegister('OnAutoItExit')

$hWnd = GUICreate('')
$iMsg = _WinAPI_RegisterWindowMessage('SHELLCHANGENOTIFY')
GUIRegisterMsg($iMsg, '_ShellChangeNotifyProc')
$ID = _WinAPI_ShellChangeNotifyRegister($hWnd, $iMsg, $SHCNE_ALLEVENTS, BitOR($SHCNRF_INTERRUPTLEVEL, $SHCNRF_SHELLLEVEL, $SHCNRF_RECURSIVEINTERRUPT), $sPath, 1)
If @error Then
	MsgBox(16, 'Error', 'Window does not registered.')
	Exit
EndIf

While 1
    Sleep(1000)
WEnd

Func _ShellChangeNotifyProc($hWnd, $iMsg, $wParam, $lParam)

    Local $tData = DllStructCreate('dword Item1; dword Item2', $wParam)

    ConsoleWrite('Event: 0x' & Hex($lParam) & '   Path: ' & _WinAPI_ShellGetPathFromIDList(DllStructGetData($tData, 'Item1')) & @CR)
EndFunc   ;==>_ShellChangeNotifyProc

Func OnAutoItExit()
	_WinAPI_ShellChangeNotifyDeregister($ID)
;	DirRemove($sPath)
EndFunc   ;==>OnAutoItExit
