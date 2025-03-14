#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <GuiStatusBar.au3>
#include <WindowsConstants.au3>

Global $g_idListView, $g_hStatusBar, $g_iIndex = -1

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("ListView Hit Test (v" & @AutoItVersion & ")", 400, 300)
	$g_idListView = GUICtrlCreateListView("", 2, 2, 394, 268)
	$g_idListView = GUICtrlGetHandle($g_idListView) ; get the handle for use in the notify events
	$g_hStatusBar = _GUICtrlStatusBar_Create($hGUI, -1, "")

	; Enable extended control styles
	_GUICtrlListView_SetExtendedListViewStyle($g_idListView, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES))
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($g_idListView, False)

	_WM_NOTIFY_Register()

	; Load images
	Local $hImage = _GUIImageList_Create()
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($g_idListView, 0xFF0000, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($g_idListView, 0x00FF00, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($g_idListView, 0x0000FF, 16, 16))
	_GUICtrlListView_SetImageList($g_idListView, $hImage, 1)

	; Add columns
	_GUICtrlListView_AddColumn($g_idListView, "Column 1", 100)
	_GUICtrlListView_AddColumn($g_idListView, "Column 2", 100)
	_GUICtrlListView_AddColumn($g_idListView, "Column 3", 100)

	; Add items
	_GUICtrlListView_AddItem($g_idListView, "Row 1: Col 1", 0)
	_GUICtrlListView_AddSubItem($g_idListView, 0, "Row 1: Col 2", 1, 1)
	_GUICtrlListView_AddSubItem($g_idListView, 0, "Row 1: Col 3", 2, 2)
	_GUICtrlListView_AddItem($g_idListView, "Row 2: Col 1", 1)
	_GUICtrlListView_AddSubItem($g_idListView, 1, "Row 2: Col 2", 1, 2)
	_GUICtrlListView_AddItem($g_idListView, "Row 3: Col 1", 2)

	; Loop until the user exits.
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd
	GUIDelete()
EndFunc   ;==>Example

Func _ListView_Click()
	Local $aHit

	$aHit = _GUICtrlListView_HitTest($g_idListView)
	If ($aHit[0] <> -1) And ($aHit[0] <> $g_iIndex) Then
		_GUICtrlStatusBar_SetText($g_hStatusBar, @TAB & StringFormat("HitTest Item: %d", $aHit[0]))
		$g_iIndex = $aHit[0]
	EndIf
EndFunc   ;==>_ListView_Click

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
				Case $LVN_KEYDOWN ; A key has been pressed
					_WM_NOTIFY_DebugEvent("$LVN_KEYDOWN", $tagNMLVKEYDOWN, $lParam, "IDFrom,,VKey,Flags")
					; No return value
				Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
					_WM_NOTIFY_DebugEvent("$NM_CLICK", $tagNMITEMACTIVATE, $lParam, "IDFrom,,Index,SubItem,NewState,OldState,Changed,ActionX,ActionY,lParam,KeyFlags")
					_ListView_Click()
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
