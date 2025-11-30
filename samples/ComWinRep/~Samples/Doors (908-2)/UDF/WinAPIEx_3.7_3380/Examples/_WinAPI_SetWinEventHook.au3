#Include <APIConstants.au3>
#Include <GUIMenu.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hEventProc = DllCallbackRegister('_EventProc', 'none', 'ptr;dword;hwnd;long;long;dword;dword')
Global $tPOINT, $tRECT, $hEventHook, $Index, $hMenu = 0

OnAutoItExitRegister('OnAutoItExit')

$hEventHook = _WinAPI_SetWinEventHook($EVENT_SYSTEM_MENUPOPUPSTART, $EVENT_SYSTEM_MENUPOPUPEND, DllCallbackGetPtr($hEventProc))

Run(@SystemDir & '\notepad.exe')

While 1
	Sleep(1000)
WEnd

Func OnAutoItExit()
	_WinAPI_UnhookWinEvent($hEventHook)
	DllCallbackFree($hEventProc)
EndFunc   ;==>OnAutoItExit

Func _EventProc($hEventHook, $iEvent, $hWnd, $iObjectID, $iChildID, $iThreadID, $iEventTime)
	Switch $iEvent
		Case $EVENT_SYSTEM_MENUPOPUPSTART
			; Add "View - Calculator"
			$hMenu = _SendMessage($hWnd, $MN_GETHMENU)
			If (_GUICtrlMenu_IsMenu($hMenu)) And (StringInStr(_GUICtrlMenu_GetItemText($hMenu, 0), 'Status Bar')) And (StringInStr(_WinAPI_GetWindowFileName($hWnd), 'notepad.exe')) Then
				$Index = _GUICtrlMenu_GetItemCount($hMenu)
				_GUICtrlMenu_InsertMenuItem($hMenu, $Index, 'Calculator' & @TAB & ':-)')
				$tRECT = _GUICtrlMenu_GetItemRectEx($hWnd, $hMenu, $Index)
			Else
				$hMenu = 0
			EndIf
		Case $EVENT_SYSTEM_MENUPOPUPEND
			If $hMenu Then
				_GUICtrlMenu_DeleteMenu($hMenu, $Index)
				$tPOINT = _WinAPI_GetMousePos()
				If _WinAPI_PtInRect($tRECT, $tPOINT) Then
					Run(@SystemDir & '\calc.exe')
				EndIf
				$hMenu = 0
			EndIf
	EndSwitch
EndFunc   ;==>_EventProc
