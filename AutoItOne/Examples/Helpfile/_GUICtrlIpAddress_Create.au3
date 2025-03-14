#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiIPAddress.au3>
#include <WindowsConstants.au3>

Global $g_hIPAddress, $g_idMemo

Example()

Func Example()
	Local $hGui = GUICreate("IP Address Create (v" & @AutoItVersion & ")", 400, 300)
	$g_hIPAddress = _GUICtrlIpAddress_Create($hGui, 10, 10)
	$g_idMemo = GUICtrlCreateEdit("", 2, 35, 396, 264, $WS_VSCROLL)
	GUICtrlSetFont($g_idMemo, 9, 400, 0, "Courier New")
	GUISetState(@SW_SHOW)

	_WM_NOTIFY_Register($g_idMemo)

	_GUICtrlIpAddress_Set($g_hIPAddress, "24.168.2.128")

	; Wait for user to close GUI
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
EndFunc   ;==>Example

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam

	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $g_hIPAddress
			Switch $iCode
				Case $IPN_FIELDCHANGED ; Sent when the user changes a field in the control or moves from one field to another
					_WM_NOTIFY_DebugEvent("$IPN_FIELDCHANGED", $tagNMIPADDRESS, $lParam, "IDFrom,,Field,Value")
					; The return value is ignored
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
