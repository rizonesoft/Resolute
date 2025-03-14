; == Example 2 : Created with UDF

#include <Extras\WM_NOTIFY.au3>
#include <GuiAVI.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Global $g_hAVI

Example()

Func Example()
	Local $hGUI

	; Create GUI
	$hGUI = GUICreate("AVI Create (v" & @AutoItVersion & ")", 300, 100)
	$g_hAVI = _GUICtrlAVI_Create($hGUI, @SystemDir & "\Shell32.dll", 150, 10, 10)
	GUISetState(@SW_SHOW)

	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

	; Play the sample AutoIt AVI
	_GUICtrlAVI_Play($g_hAVI)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	; Close AVI clip
	_GUICtrlAVI_Close($g_hAVI)

	GUIDelete()
EndFunc   ;==>Example

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg
	Local $hWndFrom = $lParam
	Local $iIDFrom = BitAND($wParam, 0xFFFF) ; Low Word
	Local $iCode = BitShift($wParam, 16) ; Hi Word
	Switch $hWndFrom
		Case $g_hAVI
			Switch $iCode
				Case $ACN_START ; Notifies an animation control's parent window that the associated AVI clip has started playing
					_WM_NOTIFY_DebugInfo("$ACN_START", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $ACN_STOP ; Notifies the parent window of an animation control that the associated AVI clip has stopped playing
					_WM_NOTIFY_DebugInfo("$ACN_STOP", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND
