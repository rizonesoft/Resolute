#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <WindowsConstants.au3>

Global $g_hStatus

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("StatusBar Resize (v" & @AutoItVersion & ")", 400, 300, -1, -1, $WS_OVERLAPPEDWINDOW)

	; Set parts
	$g_hStatus = _GUICtrlStatusBar_Create($hGUI)
	Local $aParts[3] = [75, 150, -1]
	_GUICtrlStatusBar_SetParts($g_hStatus, $aParts)
	_GUICtrlStatusBar_SetText($g_hStatus, "Part 0")
	_GUICtrlStatusBar_SetText($g_hStatus, "Part 1", 1)
	_GUICtrlStatusBar_SetText($g_hStatus, "Part 2", 2)

	GUISetState(@SW_SHOW)

	GUIRegisterMsg($WM_SIZE, "WM_SIZE")

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example

; Resize the status bar when GUI size changes
Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	_GUICtrlStatusBar_Resize($g_hStatus)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE
