; == Example : Created with UDF

#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiSlider.au3>
#include <WindowsConstants.au3>

Global $g_hSlider

Example()

Func Example()
	Local $hGUI

	; Create GUI
	$hGUI = GUICreate("Slider Create (v" & @AutoItVersion & ")", 400, 296)
	$g_hSlider = _GUICtrlSlider_Create($hGUI, 2, 2, 396, 20, BitOR($TBS_TOOLTIPS, $TBS_AUTOTICKS))
	GUISetState(@SW_SHOW)

	_WM_NOTIFY_Register()

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $hWndSlider = $g_hSlider
	If Not IsHWnd($g_hSlider) Then $hWndSlider = GUICtrlGetHandle($g_hSlider)

	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hWndSlider
			Switch $iCode
				Case $NM_RELEASEDCAPTURE ; The control is releasing mouse capture
					_WM_NOTIFY_DebugEvent("$NM_RELEASEDCAPTURE", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
					; No return value
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
