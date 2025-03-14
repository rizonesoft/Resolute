#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiMonthCal.au3>
#include <WindowsConstants.au3>

Global $g_hMonthCal, $g_idMemo

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("Month Calendar Create (v" & @AutoItVersion & ")", 400, 300)
	$g_hMonthCal = _GUICtrlMonthCal_Create($hGUI, 4, 4, $WS_BORDER)

	; Create memo control
	$g_idMemo = GUICtrlCreateEdit("", 4, 168, 392, 128, 0)
	GUICtrlSetFont($g_idMemo, 9, 400, 0, "Courier New")
	GUISetState(@SW_SHOW)

	_WM_NOTIFY_Register($g_idMemo)

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
		Case $g_hMonthCal
			Switch $iCode
				Case $MCN_GETDAYSTATE ; Sent by a month calendar control to request information about how individual days should be displayed
					_WM_NOTIFY_DebugEvent("$MCN_GETDAYSTATE", $tagNMDAYSTATE, $lParam, "IDFrom,,Year,Month,DOW,Day,,Hour,Minute,Second,MSecond,DayState,pDayState")
					; Address of an array of MONTHDAYSTATE (DWORD bit field that holds the state of each day in a month)
					; Each bit (1 through 31) represents the state of a day in a month. If a bit is on, the corresponding day will
					; be displayed in bold; otherwise it will be displayed with no emphasis.
					; No return value
				Case $MCN_SELCHANGE ; Sent by a month calendar control when the currently selected date or range of dates changes
					_WM_NOTIFY_DebugEvent("$MCN_SELCHANGE", $tagNMSELCHANGE, $lParam, "IDFrom,,BegYear,BegMonth,BegDOW,BegDay,,BegHour,BegMinute,BegSecond,BegMSecond,,EndYear,EndMonth,EndDOW,EndDay,,EndHour,EndMinute,EndSecond,EndMSeconds")
				; No return value
				Case $MCN_SELECT ; Sent by a month calendar control when the user makes an explicit date selection within a month calendar control
					_WM_NOTIFY_DebugEvent("$MCN_SELECT", $tagNMSELCHANGE, $lParam, "IDFrom,,BegYear,BegMonth,BegDOW,BegDay,,BegHour,BegMinute,BegSecond,BegMSecond,,EndYear,EndMonth,EndDOW,EndDay,,EndHour,EndMinute,EndSecond,EndMSeconds")
				; No return value
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
