#Include <Misc.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

Global $hTimerProc = DllCallbackRegister('_TimerProc', 'none', 'hwnd;uint;uint_ptr;dword')
Global $TimerID, $Count = 0

$TimerID = _WinAPI_SetTimer(0, 0, 1000, DllCallBackGetPtr($hTimerProc))

Do
	Sleep(100)
Until _IsPressed('1B')

_WinAPI_KillTimer(0, $TimerID)
DllCallbackFree($hTimerProc)

Func _TimerProc($hWnd, $iMsg, $iTimerId, $iTime)
	ConsoleWrite($Count & @CR)
	$Count += 1
EndFunc   ;==>_TimerProc
