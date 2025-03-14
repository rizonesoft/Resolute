#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiDateTimePicker.au3>
#include <WindowsConstants.au3>

Global $g_hDTP

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("DateTimePick Create (v" & @AutoItVersion & ")", 400, 300)
	$g_hDTP = _GUICtrlDTP_Create($hGUI, 2, 6, 190)
	GUISetState(@SW_SHOW)

	_WM_NOTIFY_Register()

	; Set the display format
	_GUICtrlDTP_SetFormat($g_hDTP, "ddd MMM dd, yyyy hh:mm ttt")

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam

	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $g_hDTP
			Switch $iCode
				Case $DTN_CLOSEUP ; Sent by a date and time picker (DTP) control when the user closes the drop-down month calendar
					_WM_NOTIFY_DebugEvent("$DTN_CLOSEUP", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
					; The return value for this notification is not used
				Case $DTN_DATETIMECHANGE ; Sent by a date and time picker (DTP) control whenever a change occurs
					_WM_NOTIFY_DebugEvent("$DTN_DATETIMECHANGE", $tagNMDATETIMECHANGE, $lParam, "IDFrom,,Flag,Year,Month,DOW,Day,,Hour,Minute,Second,MSecond")
					Return 0
				Case $DTN_DROPDOWN ; Sent by a date and time picker (DTP) control when the user activates the drop-down month calendar
					_WM_NOTIFY_DebugEvent("$DTN_DROPDOWN", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
					; The return value for this notification is not used
				Case $DTN_FORMAT, $DTN_FORMATW ; Sent by a date and time picker (DTP) control to request text to be displayed in a callback field
					_WM_NOTIFY_DebugEvent("$DTN_FORMAT", $tagNMDATETIMEFORMAT, $lParam, "IDFrom,,*Format,Year,Month,DOW,Day,,Hour,Minute,Second,MSecond,*pDisplay")
					Return 0
				Case $DTN_FORMATQUERY, $DTN_FORMATQUERYW ; Sent by a date and time picker (DTP) control to retrieve the maximum allowable size of the string that will be displayed in a callback field
					_WM_NOTIFY_DebugEvent("$DTN_FORMATQUERY", $tagNMDATETIMEFORMATQUERY, $lParam, "IDFrom,,*Format,SizeX,SizeY")
					Local $tInfo = DllStructCreate($tagNMDATETIMEFORMATQUERY, $lParam)
					DllStructSetData($tInfo, "SizeX", 64)
					DllStructSetData($tInfo, "SizeY", 10)
					Return 0
				Case $DTN_USERSTRING, $DTN_USERSTRINGW ; Sent by a date and time picker (DTP) control when a user finishes editing a string in the control
					_WM_NOTIFY_DebugEvent("$DTN_USERSTRING", $tagNMDATETIMESTRING, $lParam, "IDFrom,,*UserString,Year,Month,DOW,Day,,Hour,Minute,Second,MSecond,Flags")
					Return 0
				Case $DTN_WMKEYDOWN, $DTN_WMKEYDOWNW ; Sent by a date and time picker (DTP) control when the user types in a callback field
					_WM_NOTIFY_DebugEvent("$DTN_WMKEYDOWN", $tagNMDATETIMEFORMATQUERY, $lParam, "IDFrom,,VirtKey,*Format,Year,Month,DOW,Day,,Hour,Minute,Second,MSecond")
					Return 0
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
