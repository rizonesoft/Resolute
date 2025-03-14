; == Example 2 : _GUICtrlEdit_SetText()

#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <WinAPIConv.au3>
#include <WindowsConstants.au3>

Global $g_hEdit

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("Edit Create (v" & @AutoItVersion & ")", 400, 300)
	$g_hEdit = _GUICtrlEdit_Create($hGUI, "", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

	_GUICtrlEdit_SetText($g_hEdit, "This is a test" & @CRLF & "Another Line")

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg
	Local $hWndEdit = $g_hEdit
	If Not IsHWnd($g_hEdit) Then $hWndEdit = GUICtrlGetHandle($g_hEdit)
	Local $hWndFrom = $lParam
	Local $iIDFrom = _WinAPI_LoWord($wParam)
	Local $iCode = _WinAPI_HiWord($wParam)
	Switch $hWndFrom
		Case $g_hEdit, $hWndEdit
			Switch $iCode
				Case $EN_ALIGN_LTR_EC ; Sent when the user has changed the edit control direction to left-to-right
					_WM_NOTIFY_DebugInfo("$EN_ALIGN_LTR_EC", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $EN_ALIGN_RTL_EC ; Sent when the user has changed the edit control direction to right-to-left
					_WM_NOTIFY_DebugInfo("$EN_ALIGN_RTL_EC", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $EN_CHANGE ; Sent when the user has taken an action that may have altered text in an edit control
					_WM_NOTIFY_DebugInfo("$EN_CHANGE", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $EN_ERRSPACE ; Sent when an edit control cannot allocate enough memory to meet a specific request
					_WM_NOTIFY_DebugInfo("$EN_ERRSPACE", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $EN_HSCROLL ; Sent when the user clicks an edit control's horizontal scroll bar
					_WM_NOTIFY_DebugInfo("$EN_HSCROLL", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $EN_KILLFOCUS ; Sent when an edit control loses the keyboard focus
					_WM_NOTIFY_DebugInfo("$EN_KILLFOCUS", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $EN_MAXTEXT ; Sent when the current text insertion has exceeded the specified number of characters for the edit control
					_WM_NOTIFY_DebugInfo("$EN_MAXTEXT", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; This message is also sent when an edit control does not have the $ES_AUTOHSCROLL style and the number of characters to be
					; inserted would exceed the width of the edit control.
					; This message is also sent when an edit control does not have the $ES_AUTOVSCROLL style and the total number of lines resulting
					; from a text insertion would exceed the height of the edit control

					; no return value
				Case $EN_SETFOCUS ; Sent when an edit control receives the keyboard focus
					_WM_NOTIFY_DebugInfo("$EN_SETFOCUS", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $EN_UPDATE ; Sent when an edit control is about to redraw itself
					_WM_NOTIFY_DebugInfo("$EN_UPDATE", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $EN_VSCROLL ; Sent when the user clicks an edit control's vertical scroll bar or when the user scrolls the mouse wheel over the edit control
					_WM_NOTIFY_DebugInfo("$EN_VSCROLL", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND
