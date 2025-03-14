#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <GuiStatusBar.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

Global $g_idListView, $g_hStatus

Example()

Func Example()
	Local $hGUI = GUICreate("ListView Get/Set Hover Time (v" & @AutoItVersion & ")", 400, 300)
	$g_idListView = GUICtrlCreateListView("", 2, 2, 394, 268)
	_GUICtrlListView_SetExtendedListViewStyle($g_idListView, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, $LVS_EX_TRACKSELECT))
	$g_hStatus = _GUICtrlStatusBar_Create($hGUI)
	_GUICtrlStatusBar_SetSimple($g_hStatus, True)
	GUISetState(@SW_SHOW)

	; Add columns
	_GUICtrlListView_AddColumn($g_idListview, "Column 0", 100)
	_GUICtrlListView_AddColumn($g_idListview, "Column 1", 100)
	_GUICtrlListView_AddColumn($g_idListview, "Column 2", 100)

	_GUICtrlListView_InsertItem($g_idListview, "Row 0: Col 0", -1, 0)
	_GUICtrlListView_AddSubItem($g_idListview, 0, "Row 0: Col 1", 1, 1)
	_GUICtrlListView_AddSubItem($g_idListview, 0, "Row 0: Col 2", 2, 2)
	_GUICtrlListView_InsertItem($g_idListview, "Row 1: Col 0", -1, 1)
	_GUICtrlListView_AddSubItem($g_idListview, 1, "Row 1: Col 1", 1, 2)
	_GUICtrlListView_InsertItem($g_idListview, "Row 2: Col 0", -1, 2)

	;Register WM_NOTIFY  events
	_WM_NOTIFY_Register()

	; Get hover time
	MsgBox($MB_SYSTEMMODAL, "Information", "Previous Hover Time (milliseconds): " & _GUICtrlListView_GetHoverTime($g_idListView))

	; Set hover time
	_GUICtrlListView_SetHoverTime($g_idListView, 1234)
	MsgBox($MB_SYSTEMMODAL, "Information", "Hover Time (milliseconds): " & _GUICtrlListView_GetHoverTime($g_idListView))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example

Func ListView_HOTTRACK($iSubItem)
	Local $iHotItem = _GUICtrlListView_GetHotItem($g_idListView)
	If $iHotItem <> -1 Then _GUICtrlStatusBar_SetText($g_hStatus, "Hot Item: " & $iHotItem & " SubItem: " & $iSubItem)
EndFunc   ;==>ListView_HOTTRACK

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $hWndListView = $g_idListView
	If Not IsHWnd($g_idListView) Then $hWndListView = GUICtrlGetHandle($g_idListView)

	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hWndListView
			Switch $iCode
				Case $LVN_COLUMNCLICK ; A column was clicked
					_WM_NOTIFY_DebugEvent("$LVN_COLUMNCLICK", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
					; No return value
				Case $LVN_DELETEITEM ; An item is about to be deleted
					_WM_NOTIFY_DebugEvent("$LVN_DELETEITEM", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
					; No return value
				Case $LVN_HOTTRACK ; Sent by a list-view control when the user moves the mouse over an item
					Local $tInfo = DllStructCreate($tagNMLISTVIEW, $lParam)
					ListView_HOTTRACK(DllStructGetData($tInfo, "SubItem"))
;~ 					_WM_NOTIFY_DebugEvent("$LVN_HOTTRACK", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
					Return 0 ; allow the list view to perform its normal track select processing.
					;Return 1 ; the item will not be selected.
				Case $LVN_KEYDOWN ; A key has been pressed
					_WM_NOTIFY_DebugEvent("$LVN_KEYDOWN", $tagNMLVKEYDOWN, $lParam, "IDFrom,,VKey,Flags")
					; No return value
				Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
					_WM_NOTIFY_DebugEvent("$NM_CLICK", $tagNMITEMACTIVATE, $lParam, "IDFrom,,Index,SubItem,NewState,OldState,Changed,ActionX,ActionY,lParam,KeyFlags")
					; No return value
				Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
					_WM_NOTIFY_DebugEvent("$NM_DBLCLK", $tagNMITEMACTIVATE, $lParam, "IDFrom,,Index,SubItem,NewState,OldState,Changed,ActionX,ActionY,lParam,KeyFlags")
					; No return value
				Case $NM_KILLFOCUS ; The control has lost the input focus
					_WM_NOTIFY_DebugEvent("$NM_KILLFOCUS", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
					; No return value
				Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
					_WM_NOTIFY_DebugEvent("$NM_RCLICK", $tagNMITEMACTIVATE, $lParam, "IDFrom,,Index,SubItem,NewState,OldState,Changed,ActionX,ActionY,lParam,KeyFlags")
					;Return 1 ; not to allow the default processing
					Return 0 ; allow the default processing
				Case $NM_RDBLCLK ; Sent by a list-view control when the user double-clicks an item with the right mouse button
					_WM_NOTIFY_DebugEvent("$NM_RDBLCLK", $tagNMITEMACTIVATE, $lParam, "IDFrom,,Index,SubItem,NewState,OldState,Changed,ActionX,ActionY,lParam,KeyFlags")
					; No return value
				Case $NM_RETURN ; The control has the input focus and that the user has pressed the ENTER key
					_WM_NOTIFY_DebugEvent("$NM_RETURN", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
					; No return value
				Case $NM_SETFOCUS ; The control has received the input focus
					_WM_NOTIFY_DebugEvent("$NM_SETFOCUS", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
					; No return value
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
