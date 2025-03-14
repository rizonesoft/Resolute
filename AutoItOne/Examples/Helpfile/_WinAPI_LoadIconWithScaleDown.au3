#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <SendMessage.au3>
#include <StaticConstants.au3>
#include <WinAPIIcons.au3>
#include <WinAPISys.au3>

If Number(_WinAPI_GetVersion()) < 6.0 Then
	MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), 'Error', 'Require Windows Vista or later.')
	Exit
EndIf

GUICreate('Test ' & StringReplace(@ScriptName, '.au3', '()'), 324, 324)
GUICtrlCreateIcon('', 0, 64, 64, 196, 196)
Local $h_Icon = GUICtrlGetHandle(-1)
GUISetState(@SW_SHOW)

Local $hIcon = _WinAPI_LoadIconWithScaleDown(0, @ScriptDir & '\Extras\Soccer.ico', 196, 196)
Local $hPrev = _SendMessage($h_Icon, $STM_SETIMAGE, 1, $hIcon)
If $hPrev Then
	_WinAPI_DestroyIcon($hPrev)
EndIf

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE
