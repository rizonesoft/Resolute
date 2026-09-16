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
GUIRegisterMsg($iMsg, 'WM_SHELLCHANGENOTIFY')
$ID = _WinAPI_ShellChangeNotifyRegister($hWnd, $iMsg, $SHCNE_ALLEVENTS, BitOR($SHCNRF_INTERRUPTLEVEL, $SHCNRF_SHELLLEVEL, $SHCNRF_RECURSIVEINTERRUPT), $sPath, 1)
If @error Then
	MsgBox(16, 'Error', 'Window does not registered.')
	Exit
EndIf

While 1
    Sleep(1000)
WEnd

Func WM_SHELLCHANGENOTIFY($hWnd, $iMsg, $wParam, $lParam)

	Local $Path = _WinAPI_ShellGetPathFromIDList(DllStructGetData(DllStructCreate('dword Item1; dword Item2', $wParam), 'Item1'))

	If $Path Then
		ConsoleWrite('Event: 0x' & Hex($lParam) & ' | Path: ' & $Path & @CR)
	Else
		ConsoleWrite('Event: 0x' & Hex($lParam) & @CR)
	EndIf
EndFunc   ;==>WM_SHELLCHANGENOTIFY

Func OnAutoItExit()
	If $ID Then
		_WinAPI_ShellChangeNotifyDeregister($ID)
	EndIf
;	DirRemove($sPath)
EndFunc   ;==>OnAutoItExit
