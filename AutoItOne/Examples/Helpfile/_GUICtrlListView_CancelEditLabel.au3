#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>

Global $g_idListView

Example()

Func Example()
	GUICreate("ListView Cancel Edit (v" & @AutoItVersion & ")", 392, 322)
	$g_idListView = GUICtrlCreateListView("", 2, 2, 394, 268, BitOR($LVS_EDITLABELS, $LVS_REPORT))
	GUISetState(@SW_SHOW)

	_WM_NOTIFY_Register()

	; Load images
	Local $hImage = _GUIImageList_Create()
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap(GUICtrlGetHandle($g_idListView), 0xFF0000, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap(GUICtrlGetHandle($g_idListView), 0x00FF00, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap(GUICtrlGetHandle($g_idListView), 0x0000FF, 16, 16))
	_GUICtrlListView_SetImageList($g_idListView, $hImage, 1)

	; Add columns
	_GUICtrlListView_InsertColumn($g_idListView, 0, "Column 1", 100)
	_GUICtrlListView_InsertColumn($g_idListView, 1, "Column 2", 100)
	_GUICtrlListView_InsertColumn($g_idListView, 2, "Column 3", 100)

	; Add items
	_GUICtrlListView_AddItem($g_idListView, "Row 1: Col 1", 0)
	_GUICtrlListView_AddSubItem($g_idListView, 0, "Row 1: Col 2", 1)
	_GUICtrlListView_AddSubItem($g_idListView, 0, "Row 1: Col 3", 2)
	_GUICtrlListView_AddItem($g_idListView, "Row 2: Col 1", 1)
	_GUICtrlListView_AddSubItem($g_idListView, 1, "Row 2: Col 2", 1)
	_GUICtrlListView_AddItem($g_idListView, "Row 3: Col 1", 2)

	; Edit item 0 label with time out
	_GUICtrlListView_EditLabel($g_idListView, 0)
	Local $hTime = TimerInit()

	; Loop until the user exits.
	Do
		If _GUICtrlListView_GetEditControl($g_idListView) <> 0 Then
			If TimerDiff($hTime) > 3000 Then _GUICtrlListView_CancelEditLabel($g_idListView)
		EndIf
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example

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
				Case $LVN_ITEMCHANGING ; An item is changing
					_WM_NOTIFY_DebugEvent("$LVN_ITEMCHANGING", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
					Return True ; prevent the change
					;Return False ; allow the change
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
