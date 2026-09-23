#Include <Constants.au3>
#Include <GUIConstantsEx.au3>
#Include <WindowsConstants.au3>
#Include <WinAPIEx.au3>

Global Const $WM_DROPFILES = 0x0233

Global $hForm, $Msg, $Check, $Label, $hLabel, $hDll, $pDll, $hProc

; Create GUI
$hForm = GUICreate('MyGUI', 400, 400)
$Check = GUICtrlCreateCheckbox('Enable Drag && Drop', 10, 370, 120, 19)
$Label = GUICtrlCreateLabel('', 100, 100, 200, 200)
$hLabel = GUICtrlGetHandle($Label)
GUICtrlSetBkColor(-1, 0xD3D8EF)
GUICtrlCreateLabel('Drop here', 175, 193, 50, 14)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

; Register label window proc
$hDll = DllCallbackRegister('_WinProc', 'ptr', 'hwnd;uint;wparam;lparam')
$pDll = DllCallbackGetPtr($hDll)
$hProc = _WinAPI_SetWindowLong($hLabel, $GWL_WNDPROC, $pDll)

GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Check
			_WinAPI_DragAcceptFiles($hLabel, GUICtrlRead($Check) = $GUI_CHECKED)
	EndSwitch
WEnd

Func _WinProc($hWnd, $iMsg, $wParam, $lParam)
	Switch $iMsg
		Case $WM_DROPFILES

			Local $FileList = _WinAPI_DragQueryFileEx($wParam)

			If IsArray($FileList) Then
				ConsoleWrite('--------------------------------------------------' & @CR)
				For $i = 1 To $FileList[0]
					ConsoleWrite($FileList[$i] & @CR)
				Next
			EndIf
			_WinAPI_DragFinish($wParam)
			Return 0
	EndSwitch
	Return _WinAPI_CallWindowProc($hProc, $hWnd, $iMsg, $wParam, $lParam)
EndFunc   ;==>_WinProc

Func OnAutoItExit()
	_WinAPI_SetWindowLong($hLabel, $GWL_WNDPROC, $hProc)
	DllCallbackFree($hDll)
EndFunc   ;==>OnAutoItExit
