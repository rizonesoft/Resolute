#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $InitDir = @ProgramFilesDir

Global $hBrowseProc, $pBrowseProc, $pText, $Path

$hBrowseProc = DllCallbackRegister('_BrowseProc','int', 'hwnd;uint;long;ptr')
$pBrowseProc = DllCallbackGetPtr($hBrowseProc)

$pText = _WinAPI_CreateString($InitDir)
$Path = _WinAPI_BrowseForFolderDlg(_WinAPI_PathStripToRoot($InitDir), 'Select a folder from the list below.', BitOR($BIF_RETURNONLYFSDIRS, $BIF_EDITBOX, $BIF_VALIDATE), $pBrowseProc, $pText)
_WinAPI_FreeMemory($pText)

If $Path Then
	ConsoleWrite('--------------------------------------------------' & @CR)
	ConsoleWrite($Path & @CR)
EndIf

DllCallbackFree($hBrowseProc)

Func _BrowseProc($hWnd, $iMsg, $wParam, $lParam)

	Local $Path

	Switch $iMsg
		Case $BFFM_INITIALIZED
			_WinAPI_SetWindowText($hWnd, 'MyTitle')
			_SendMessage($hWnd, $BFFM_SETSELECTIONW, 1, $lParam)
		Case $BFFM_SELCHANGED
			$Path = _WinAPI_ShellGetPathFromIDList($wParam)
			If Not @error Then
				ConsoleWrite($Path & @CR)
			EndIf
		Case $BFFM_VALIDATEFAILED
			MsgBox(16, 'Error', _WinAPI_GetString($wParam) & ' is invalid.', 0, $hWnd)
			Return 1
	EndSwitch
    Return 0
EndFunc ;==> _BrowseProc
