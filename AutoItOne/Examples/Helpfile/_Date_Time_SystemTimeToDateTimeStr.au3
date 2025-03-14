#include <Date.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Global $g_idMemo

Example()

Func Example()
	Local $tTime

	; Create GUI
	GUICreate("Date/Time", 500, 300)
	$g_idMemo = GUICtrlCreateEdit("", 2, 2, 496, 296, $WS_VSCROLL)
	GUICtrlSetFont($g_idMemo, 9, 400, 0, "Courier New")
	GUISetState(@SW_SHOW)

	; Show system date/time
	$tTime = _Date_Time_GetSystemTime()
	MemoWrite("System date/time (0)       : " & _Date_Time_SystemTimeToDateTimeStr($tTime))
	MemoWrite("System date/time (1)       : " & _Date_Time_SystemTimeToDateTimeStr($tTime, 1))
	MemoWrite("System date/time (ISO8601) : " & _Date_Time_SystemTimeToDateTimeStr($tTime, 3, 1))
	MemoWrite("System date/time (GMT)     : " & _Date_Time_SystemTimeToDateTimeStr($tTime, 2, 1))
	; Show local date/time
	$tTime = _Date_Time_GetLocalTime()
	MemoWrite("Local  date/time (GMT)     : " & _Date_Time_SystemTimeToDateTimeStr($tTime, 2))
	MemoWrite("Local  date/time (ISO8601) : " & _Date_Time_SystemTimeToDateTimeStr($tTime, 3))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
EndFunc   ;==>Example

; Write a line to the memo control
Func MemoWrite($sMessage)
	GUICtrlSetData($g_idMemo, $sMessage & @CRLF, 1)
EndFunc   ;==>MemoWrite
