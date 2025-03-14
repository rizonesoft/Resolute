#include <Misc.au3>
#include <WinAPISysWin.au3>

Opt('TrayAutoPause', 0)

Global $g_iCount = 0

_Example()

Func _Example()
	Local $hTimerProc = DllCallbackRegister('_TimerProc', 'none', 'hwnd;uint;uint_ptr;dword')

	Local $iTimerID = _WinAPI_SetTimer(0, 0, 1000, DllCallbackGetPtr($hTimerProc))

	Do
		Sleep(100)
	Until _IsPressed('1B')

	_WinAPI_KillTimer(0, $iTimerID)
	DllCallbackFree($hTimerProc)

EndFunc   ;==>_Example

Func _TimerProc($hWnd, $iMsg, $iTimerID, $iTime)
	#forceref $hWnd, $iMsg, $iTimerID, $iTime

	ConsoleWrite($g_iCount & @CRLF)
	$g_iCount += 1
EndFunc   ;==>_TimerProc
