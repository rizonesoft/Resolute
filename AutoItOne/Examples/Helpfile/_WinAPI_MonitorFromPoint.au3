#include <WinAPIGdi.au3>
#include <WinAPIMisc.au3>

; To check how this work on "Dual Monitor" just move your mouse to second monitor and run this script again
_Example()

Func _Example()
	; get mouse coordinates
	Local $tPos = _WinAPI_GetMousePos()
	ConsoleWrite('MouseX = ' & DllStructGetData($tPos, 1) & @CRLF)
    ConsoleWrite('MouseY = ' & DllStructGetData($tPos, 2) & @CRLF)

	; get $hMonitor from previously defined Mouse coordinates
	Local $hMonitor = _WinAPI_MonitorFromPoint($tPos)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hMonitor = ' & $hMonitor & @CRLF & '>Error code: ' & @error & '    Extended code: 0x' & Hex(@extended) & @CRLF) ;### Debug Console

	; get monitor $aData appropriate for previously defined coordinates
	Local $aData = _WinAPI_GetMonitorInfo($hMonitor)
	If Not @error Then
		ConsoleWrite('Handle:      ' & $hMonitor & @CRLF)
		ConsoleWrite('Rectangle:   ' & DllStructGetData($aData[0], 1) & ', ' & DllStructGetData($aData[0], 2) & ', ' & DllStructGetData($aData[0], 3) & ', ' & DllStructGetData($aData[0], 4) & @CRLF)
		ConsoleWrite('Work area:   ' & DllStructGetData($aData[1], 1) & ', ' & DllStructGetData($aData[1], 2) & ', ' & DllStructGetData($aData[1], 3) & ', ' & DllStructGetData($aData[1], 4) & @CRLF)
		ConsoleWrite('Primary:     ' & $aData[2] & @CRLF)
		ConsoleWrite('Device name: ' & $aData[3] & @CRLF)
	EndIf
EndFunc   ;==>_Example
