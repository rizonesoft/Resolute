#Include <Misc.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hTimerFunc = DllCallbackRegister('_Timer', 'none', 'hwnd;uint;uint;dword')
Global $Count = 0

_WinAPI_SetTimer(0, 0, 1000, DllCallBackGetPtr($hTimerFunc))

Do
	Sleep(100)
Until _IsPressed('1B')

DllCallbackFree($hTimerFunc)

Func _Timer($hWnd, $iMsg, $iTimerId, $iTime)
	$Count += 1
	ConsoleWrite($Count & @CR)
EndFunc   ;==>_Timer
