#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiHeader.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

Global $g_hHeader

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("Header Destroy (v" & @AutoItVersion & ")", 400, 300)
	$g_hHeader = _GUICtrlHeader_Create($hGUI)
	_GUICtrlHeader_SetUnicodeFormat($g_hHeader, True)
	GUISetState(@SW_SHOW)

	_WM_NOTIFY_Register()

	; Add columns
	_GUICtrlHeader_AddItem($g_hHeader, "Column 0", 100)
	_GUICtrlHeader_AddItem($g_hHeader, "Column 1", 100)
	_GUICtrlHeader_AddItem($g_hHeader, "Column 2", 100)
	_GUICtrlHeader_AddItem($g_hHeader, "Column 3", 100)

	; Clear all filters
	_GUICtrlHeader_ClearFilterAll($g_hHeader)

	MsgBox($MB_SYSTEMMODAL, "Information", "About to Destroy Header")

	_GUICtrlHeader_Destroy($g_hHeader)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
EndFunc   ;==>Example

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $g_hHeader
			Switch $iCode
				Case $HDN_BEGINDRAG ; Sent by a header control when a drag operation has begun on one of its items
					_WM_NOTIFY_DebugEvent("$HDN_BEGINDRAG", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					Return False ; To allow the header control to automatically manage drag-and-drop operations
					; Return True  ; To indicate external (manual) drag-and-drop management allows the owner of the
					; control to provide custom services as part of the drag-and-drop process
				Case $HDN_BEGINTRACK, $HDN_BEGINTRACKW ; Notifies a header control's parent window that the user has begun dragging a divider in the control
					_WM_NOTIFY_DebugEvent("$HDN_BEGINTRACK", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					Return False ; To allow tracking of the divider
					; Return True  ; To prevent tracking
				Case $HDN_DIVIDERDBLCLICK, $HDN_DIVIDERDBLCLICKW ; Notifies a header control's parent window that the user double-clicked the divider area of the control
					_WM_NOTIFY_DebugEvent("$HDN_DIVIDERDBLCLICK", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					; no return value
				Case $HDN_ENDDRAG ; Sent by a header control when a drag operation has ended on one of its items
					_WM_NOTIFY_DebugEvent("$HDN_ENDDRAG", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					Return False ; To allow the control to automatically place and reorder the item
					; Return True  ; To prevent the item from being placed
				Case $HDN_ENDTRACK, $HDN_ENDTRACKW ; Notifies a header control's parent window that the user has finished dragging a divider
					_WM_NOTIFY_DebugEvent("$HDN_ENDTRACK", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					; no return value
				Case $HDN_FILTERBTNCLICK ; Notifies the header control's parent window when the filter button is clicked or in response to an $HDM_SETITEM message
					_WM_NOTIFY_DebugEvent("$HDN_FILTERBTNCLICK", $tagNMHDFILTERBTNCLICK, $lParam, "IDFrom,,Item,Left,Top,Right,Bottom")
					; Return True  ; An $HDN_FILTERCHANGE notification will be sent to the header control's parent window
					; This notification gives the parent window an opportunity to synchronize its user interface elements
					Return False ; If you do not want the notification sent
				Case $HDN_FILTERCHANGE ; Notifies the header control's parent window that the attributes of a header control filter are being changed or edited
					_WM_NOTIFY_DebugEvent("$HDN_FILTERCHANGE", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					; no return value
				Case $HDN_GETDISPINFO, $HDN_GETDISPINFOW ; Sent to the owner of a header control when the control needs information about a callback header item
					_WM_NOTIFY_DebugEvent("$HDN_GETDISPINFO", $tagNMHDDISPINFO, $lParam, "IDFrom,Item")
					; Return LRESULT
				Case $HDN_ITEMCHANGED, $HDN_ITEMCHANGEDW ; Notifies a header control's parent window that the attributes of a header item have changed
					_WM_NOTIFY_DebugEvent("$HDN_ITEMCHANGED", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					; no return value
				Case $HDN_ITEMCHANGING, $HDN_ITEMCHANGINGW ; Notifies a header control's parent window that the attributes of a header item are about to change
					_WM_NOTIFY_DebugEvent("$HDN_ITEMCHANGING", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					Return False ; To allow the changes
					; Return True  ; To prevent them
				Case $HDN_ITEMCLICK, $HDN_ITEMCLICKW ; Notifies a header control's parent window that the user clicked the control
					_WM_NOTIFY_DebugEvent("$HDN_ITEMCLICK", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					; no return value
				Case $HDN_ITEMDBLCLICK, $HDN_ITEMDBLCLICKW ; Notifies a header control's parent window that the user double-clicked the control
					_WM_NOTIFY_DebugEvent("$HDN_ITEMDBLCLICK", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					; no return value
				Case $HDN_TRACK, $HDN_TRACKW ; Notifies a header control's parent window that the user is dragging a divider in the header control
					_WM_NOTIFY_DebugEvent("$HDN_TRACK", $tagNMHEADER, $lParam, "IDFrom,,Item,Button")
					Return False ; To continue tracking the divider
					; Return True  ; To end tracking
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
