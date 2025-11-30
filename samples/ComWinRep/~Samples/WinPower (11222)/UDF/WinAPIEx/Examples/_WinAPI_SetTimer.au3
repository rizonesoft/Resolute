#Include <Misc.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

Global $hTimerProc = DllCallbackRegister('_TimerProc', 'none', 'hwnd;uint;uint_ptr;dword')
Global $Count = 0

_WinAPI_SetTimer(0, 0, 1000, DllCallBackGetPtr($hTimerProc))

Do
	Sleep(100)
Until _IsPressed('1B')

DllCallbackFree($hTimerProc)

Func _TimerProc($hWnd, $iMsg, $iTimerId, $iTime)
	$Count += 1
	ConsoleWrite($Count & @CR)
EndFunc   ;==>_TimerProc
