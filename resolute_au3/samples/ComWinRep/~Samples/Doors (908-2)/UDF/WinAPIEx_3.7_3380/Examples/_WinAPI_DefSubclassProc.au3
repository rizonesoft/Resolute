#Include <WinAPIEx.au3>
#Include <Extras\WMDebug.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $hDll, $pDll

OnAutoItExitRegister('OnAutoItExit')

; Create GUI
$hForm = GUICreate('MyGUI')

; Register DLL callback that will be used as window subclass procedure
$hDll = DllCallbackRegister('_SubclassProc', 'lresult', 'hwnd;uint;wparam;lparam;uint_ptr;dword_ptr')
$pDll = DllCallbackGetPtr($hDll)

; Install window subclass callback
_WinAPI_SetWindowSubclass($hForm, $pDll, 1000, 0)

GUISetState()

Do
Until GUIGetMsg() = -3

Func _SubclassProc($hWnd, $iMsg, $wParam, $lParam, $ID, $pData)
	; Declared in WMDebug.au3
	_WM_Debug($hWnd, $iMsg, $wParam, $lParam)
	Return _WinAPI_DefSubclassProc($hWnd, $iMsg, $wParam, $lParam)
EndFunc   ;==>_SubclassProc

Func OnAutoItExit()
	_WinAPI_RemoveWindowSubclass($hForm, $pDll, 1000)
	DllCallbackFree($hDll)
EndFunc   ;==>OnAutoItExit
