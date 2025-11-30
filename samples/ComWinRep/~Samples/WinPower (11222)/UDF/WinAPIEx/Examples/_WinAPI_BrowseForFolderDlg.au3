#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $Flags = BitOR($BIF_RETURNONLYFSDIRS, $BIF_EDITBOX, $BIF_VALIDATE)
Global Const $InitDir = @ProgramFilesDir

Global $hBrowseProc = DllCallbackRegister('_BrowseProc','int', 'hwnd;uint;long;ptr')
Global $tData = DllStructCreate('wchar[' & (StringLen($InitDir) + 1)& ']')
Global $Path

DllStructSetData($tData, 1, $InitDir)
$Path = _WinAPI_BrowseForFolderDlg(StringLeft($InitDir, 3), 'Select a folder from the list below.', $Flags, DllCallbackGetPtr($hBrowseProc), DllStructGetPtr($tData))
If $Path Then
	ConsoleWrite('--------------------------------------------------' & @CR)
	ConsoleWrite($Path & @CR)
EndIf

DllCallbackFree($hBrowseProc)

Func _BrowseProc($hWnd, $iMsg, $wParam, $lParam)

	Local $tData

	Switch $iMsg
		Case $BFFM_INITIALIZED
			_WinAPI_SetWindowText($hWnd, 'Select Folder')
			_SendMessage($hWnd, $BFFM_SETSELECTION, 1, $lParam)
		Case $BFFM_SELCHANGED
			ConsoleWrite(_WinAPI_ShellGetPathFromIDList($wParam) & @CR)
		Case $BFFM_VALIDATEFAILED
			$tData = DllStructCreate('wchar[' & (_WinAPI_StrLen($wParam) + 1) & ']', $wParam)
			MsgBox(16, 'Error', DllStructGetData($tData, 1) & ' is invalid.', 0, $hWnd)
			Return 1
	EndSwitch
    Return 0
EndFunc ;==> _BrowseProc
