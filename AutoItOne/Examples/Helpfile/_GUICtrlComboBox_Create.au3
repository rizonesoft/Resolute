; == Example : Created with UDF

#include <Extras\WM_NOTIFY.au3>
#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

Global $g_hCombo

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("ComboBox Create (v" & @AutoItVersion & ")", 400, 296)
	$g_hCombo = _GUICtrlComboBox_Create($hGUI, "", 2, 2, 396, 296)
	GUISetState(@SW_SHOW)

	; Add files
	_GUICtrlComboBox_BeginUpdate($g_hCombo)
	_GUICtrlComboBox_AddDir($g_hCombo, "", $DDL_DRIVES, False)
	_GUICtrlComboBox_EndUpdate($g_hCombo)

	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg
	Local $hWndFrom = $lParam
	Local $iIDFrom = BitAND($wParam, 0xFFFF) ; Low Word
	Local $iCode = BitShift($wParam, 16) ; Hi Word
	Switch $hWndFrom
		Case $g_hCombo
			Switch $iCode
				Case $CBN_CLOSEUP ; Sent when the list box of a combo box has been closed
					_WM_NOTIFY_DebugInfo("$CBN_CLOSEUP", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $CBN_DBLCLK ; Sent when the user double-clicks a string in the list box of a combo box
					_WM_NOTIFY_DebugInfo("$CBN_DBLCLK", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $CBN_DROPDOWN ; Sent when the list box of a combo box is about to be made visible
					_WM_NOTIFY_DebugInfo("$CBN_DROPDOWN", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $CBN_EDITCHANGE ; Sent after the user has taken an action that may have altered the text in the edit control portion of a combo box
					_WM_NOTIFY_DebugInfo("$CBN_EDITCHANGE", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $CBN_EDITUPDATE ; Sent when the edit control portion of a combo box is about to display altered text
					_WM_NOTIFY_DebugInfo("$CBN_EDITUPDATE", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $CBN_ERRSPACE ; Sent when a combo box cannot allocate enough memory to meet a specific request
					_WM_NOTIFY_DebugInfo("$CBN_ERRSPACE", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $CBN_KILLFOCUS ; Sent when a combo box loses the keyboard focus
					_WM_NOTIFY_DebugInfo("$CBN_KILLFOCUS", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $CBN_SELCHANGE ; Sent when the user changes the current selection in the list box of a combo box
					_WM_NOTIFY_DebugInfo("$CBN_SELCHANGE", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $CBN_SELENDCANCEL ; Sent when the user selects an item, but then selects another control or closes the dialog box
					_WM_NOTIFY_DebugInfo("$CBN_SELENDCANCEL", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $CBN_SELENDOK ; Sent when the user selects a list item, or selects an item and then closes the list
					_WM_NOTIFY_DebugInfo("$CBN_SELENDOK", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $CBN_SETFOCUS ; Sent when a combo box receives the keyboard focus
					_WM_NOTIFY_DebugInfo("$CBN_SETFOCUS", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
			EndSwitch
		EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND
