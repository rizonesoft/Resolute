#include <MsgBoxConstants.au3>
#include <WinAPIProc.au3>

_Example()

Func _Example()
	; disable ScreenSaver and other windows sleep features
	_WinAPI_SetThreadExecutionState(BitOR($ES_DISPLAY_REQUIRED, $ES_CONTINUOUS, $ES_SYSTEM_REQUIRED, $ES_AWAYMODE_REQUIRED))
	MsgBox($MB_OK, 'Testing', 'Close this tester window when you be sure that your ScreeSaver not runing.')

	; back to normal windows behavior
	_WinAPI_SetThreadExecutionState($ES_CONTINUOUS)
EndFunc   ;==>_Example
