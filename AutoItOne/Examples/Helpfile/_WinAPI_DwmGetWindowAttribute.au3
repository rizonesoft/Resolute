#include <MsgBoxConstants.au3>
#include <WinAPIGdi.au3>

If Not _WinAPI_DwmIsCompositionEnabled() Then
	MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), 'Error', 'Require Windows Vista or later with enabled Aero theme.')
	Exit
EndIf

Run(@SystemDir & '\calc.exe')
Local $hWnd = WinWaitActive("[CLASS:ApplicationFrameWindow]", '');, 3)
If Not $hWnd Then
	Exit
EndIf

Local $aPos = _WinAPI_GetPosFromRect(_WinAPI_DwmGetWindowAttribute($hWnd, $DWMWA_EXTENDED_FRAME_BOUNDS))

ConsoleWrite('Left:   ' & $aPos[0] & @CRLF)
ConsoleWrite('Top:    ' & $aPos[1] & @CRLF)
ConsoleWrite('Width:  ' & $aPos[2] & @CRLF)
ConsoleWrite('Height: ' & $aPos[3] & @CRLF)
