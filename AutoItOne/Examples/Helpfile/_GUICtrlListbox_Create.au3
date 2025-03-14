; == Example : Created with UDF

#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiListBox.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

Global $g_hListBox

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("ListBox Create (v" & @AutoItVersion & ")", 400, 296)
	$g_hListBox = _GUICtrlListBox_Create($hGUI, "String upon creation", 2, 2, 396, 296)
	GUISetState(@SW_SHOW)

	MsgBox($MB_SYSTEMMODAL, "Information", "Adding Items")

	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

	; Add files
	_GUICtrlListBox_BeginUpdate($g_hListBox)
	_GUICtrlListBox_ResetContent($g_hListBox)
	_GUICtrlListBox_InitStorage($g_hListBox, 100, 4096)
	_GUICtrlListBox_Dir($g_hListBox, @WindowsDir & "\win*.exe")
	_GUICtrlListBox_AddFile($g_hListBox, @WindowsDir & "\notepad.exe")
	_GUICtrlListBox_Dir($g_hListBox, "", $DDL_DRIVES)
	_GUICtrlListBox_Dir($g_hListBox, "", $DDL_DRIVES, False)
	_GUICtrlListBox_EndUpdate($g_hListBox)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
EndFunc   ;==>Example

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg
	Local $hWndListBox = $g_hListBox
	If Not IsHWnd($g_hListBox) Then $hWndListBox = GUICtrlGetHandle($g_hListBox)
	Local $hWndFrom = $lParam
	Local $iIDFrom = BitAND($wParam, 0xFFFF) ; Low Word
	Local $iCode = BitShift($wParam, 16) ; Hi Word

	Switch $hWndFrom
		Case $g_hListBox, $hWndListBox
			Switch $iCode
				Case $LBN_DBLCLK ; Sent when the user double-clicks a string in a list box
					_WM_NOTIFY_DebugInfo("$LBN_DBLCLK", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $LBN_ERRSPACE ; Sent when a list box cannot allocate enough memory to meet a specific request
					_WM_NOTIFY_DebugInfo("$LBN_ERRSPACE", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $LBN_KILLFOCUS ; Sent when a list box loses the keyboard focus
					_WM_NOTIFY_DebugInfo("$LBN_KILLFOCUS", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $LBN_SELCANCEL ; Sent when the user cancels the selection in a list box
					_WM_NOTIFY_DebugInfo("$LBN_SELCANCEL", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $LBN_SELCHANGE ; Sent when the selection in a list box has changed
					_WM_NOTIFY_DebugInfo("$LBN_SELCHANGE", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
				Case $LBN_SETFOCUS ; Sent when a list box receives the keyboard focus
					_WM_NOTIFY_DebugInfo("$LBN_SETFOCUS", "hWndFrom,IDFrom", $hWndFrom, $iIDFrom)
					; no return value
			EndSwitch
	EndSwitch
	; Proceed the default AutoIt3 internal message commands.
	; You also can complete let the line out.
	; !!! But only 'Return' (without any value) will not proceed
	; the default AutoIt3-message in the future !!!
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND
