#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>

Global $g_hListView

Example()

Func Example()
	Local $hGUI, $hImage
	$hGUI = GUICreate("ListView Create (v" & @AutoItVersion & ")", 400, 300)

	$g_hListView = _GUICtrlListView_Create($hGUI, "", 2, 2, 394, 268)
	_GUICtrlListView_SetExtendedListViewStyle($g_hListView, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES))
	GUISetState(@SW_SHOW)

	_WM_NOTIFY_Register()

	; Load images
	$hImage = _GUIImageList_Create()
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($g_hListView, 0xFF0000, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($g_hListView, 0x00FF00, 16, 16))
	_GUIImageList_Add($hImage, _GUICtrlListView_CreateSolidBitMap($g_hListView, 0x0000FF, 16, 16))
	_GUICtrlListView_SetImageList($g_hListView, $hImage, 1)

	; Add columns
	_GUICtrlListView_InsertColumn($g_hListView, 0, "Column 1", 100)
	_GUICtrlListView_InsertColumn($g_hListView, 1, "Column 2", 100)
	_GUICtrlListView_InsertColumn($g_hListView, 2, "Column 3", 100)

	; Add items
	_GUICtrlListView_AddItem($g_hListView, "Row 1: Col 1", 0)
	_GUICtrlListView_AddSubItem($g_hListView, 0, "Row 1: Col 2", 1)
	_GUICtrlListView_AddSubItem($g_hListView, 0, "Row 1: Col 3", 2)
	_GUICtrlListView_AddItem($g_hListView, "Row 2: Col 1", 1)
	_GUICtrlListView_AddSubItem($g_hListView, 1, "Row 2: Col 2", 1)
	_GUICtrlListView_AddItem($g_hListView, "Row 3: Col 1", 2)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $hWndListView = $g_hListView
	If Not IsHWnd($g_hListView) Then $hWndListView = GUICtrlGetHandle($g_hListView)

	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hWndListView
			Switch $iCode
;~ 				Case $LVN_BEGINDRAG ; A drag-and-drop operation involving the left mouse button is being initiated
;~ 					_WM_NOTIFY_DebugEvent("$LVN_BEGINDRAG", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
;~ 				; No return value
;~				Case $LVN_BEGINLABELEDIT ; Start of label editing for an item
;~					_WM_NOTIFY_DebugEvent("$LVN_BEGINLABELEDIT", $tagNMLVDISPINFO, $lParam, "IDFrom,,Mask,Item,SubItem,State,StateMask,Image,Param,Indent,,GroupID,Columns,pColumns")
;~					Return False ; Allow the user to edit the label
;~					;Return True  ; Prevent the user from editing the label
;~ 				Case $LVN_BEGINRDRAG ; A drag-and-drop operation involving the right mouse button is being initiated
;~ 					_WM_NOTIFY_DebugEvent("$LVN_BEGINRDRAG", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
;~ 					; No return value
;~ 				Case $LVN_BEGINSCROLL ; A scrolling operation starts, Minium OS WinXP
;~ 					_WM_NOTIFY_DebugEvent("$LVN_BEGINSCROLL", $tagNMLVSCROLL, $lParam, "IDFrom,,DX,DY")
;~ 					; No return value
				Case $LVN_COLUMNCLICK ; A column was clicked
					_WM_NOTIFY_DebugEvent("$LVN_COLUMNCLICK", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
					; No return value
;~ 				Case $LVN_DELETEALLITEMS ; All items in the control are about to be deleted
;~ 					_WM_NOTIFY_DebugEvent("$LVN_DELETEALLITEMS", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
;~ 					Return True ; To suppress subsequent $LVN_DELETEITEM messages
;~ 					;Return False ; To receive subsequent $LVN_DELETEITEM messages
;~ 				Case $LVN_DELETEITEM ; An item is about to be deleted
;~ 					_WM_NOTIFY_DebugEvent("$LVN_DELETEITEM", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
;~ 					; No return value
;~ 				Case $LVN_ENDLABELEDIT ; The end of label editing for an item
;~ 					_WM_NOTIFY_DebugEvent("$LVN_ENDLABELEDIT", $tagNMLVDISPINFO, $lParam, "IDFrom,,Mask,Item,SubItem,State,StateMask,Image,Param,Indent,,GroupID,Columns,pColumns,,TextMax,*Text")
;~ 					; If Text is not empty, return True to set the item's label to the edited text, return false to reject it
;~ 					; If Text is empty the return value is ignored
;~ 					Return True
;~ 				Case $LVN_ENDSCROLL ; A scrolling operation ends, Minium OS WinXP
;~ 					_WM_NOTIFY_DebugEvent("$LVN_ENDSCROLL", $tagNMLVSCROLL, $lParam, "IDFrom,,DX,DY")
;~ 					; No return value
;~ 				Case $LVN_GETDISPINFO ; Provide information needed to display or sort a list-view item
;~ 					_WM_NOTIFY_DebugEvent("$LVN_GETDISPINFO", $tagNMLVDISPINFO, $lParam, "IDFrom,,Mask,Item,SubItem,State,StateMask,Image,Param,Indent,,GroupID,Columns,pColumns,,TextMax,*Text")
;~ 					; No return value
;~ 				Case $LVN_GETINFOTIP ; Sent by a large icon view list-view control that has the $LVS_EX_INFOTIP extended style
;~ 					_WM_NOTIFY_DebugEvent("$LVN_GETINFOTIP", $tagNMLVGETINFOTIP, $lParam, "IDFrom,,Flags,Item,SubItem,lParam,,TextMax, *Text")
;~ 					; No return value
;~ 				Case $LVN_HOTTRACK ; Sent by a list-view control when the user moves the mouse over an item
;~ 					_WM_NOTIFY_DebugEvent("$LVN_HOTTRACK", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
;~ 					Return 0 ; allow the list view to perform its normal track select processing.
;~ 					;Return 1 ; the item will not be selected.
;~ 				Case $LVN_INSERTITEM ; A new item was inserted
;~ 					_WM_NOTIFY_DebugEvent("$LVN_INSERTITEM", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
;~ 					; No return value
;~ 				Case $LVN_ITEMACTIVATE ; Sent by a list-view control when the user activates an item
;~ 					_WM_NOTIFY_DebugEvent("$LVN_ITEMACTIVATE", $tagNMITEMACTIVATE, $lParam, "IDFrom,,Index,SubItem,NewState,OldState,Changed,ActionX,ActionY,lParam,KeyFlags")
;~ 					Return 0
;~ 				Case $LVN_ITEMCHANGED ; An item has changed
;~ 					_WM_NOTIFY_DebugEvent("$LVN_ITEMCHANGED", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
;~ 					; No return value
;~ 				Case $LVN_ITEMCHANGING ; An item is changing
;~ 					_WM_NOTIFY_DebugEvent("$LVN_ITEMCHANGING", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
;~ 					Return True ; prevent the change
;~ 					;Return False ; allow the change
				Case $LVN_KEYDOWN ; A key has been pressed
					_WM_NOTIFY_DebugEvent("$LVN_KEYDOWN", $tagNMLVKEYDOWN, $lParam, "IDFrom,,VKey,Flags")
					; No return value
;~ 				Case $LVN_MARQUEEBEGIN ; A bounding box (marquee) selection has begun
;~ 					_WM_NOTIFY_DebugEvent("$LVN_MARQUEEBEGIN", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
;~ 					Return 0 ; accept the message
;~ 					;Return 1 ; quit the bounding box selection
;~				Case $LVN_SETDISPINFO ; Update the information it maintains for an item
;~					_WM_NOTIFY_DebugEvent("$LVN_SETDISPINFO", $tagNMLVDISPINFO, $lParam, "IDFrom,,Mask,Item,SubItem,State,StateMask,Image,Param,Indent,,GroupID,Columns,pColumns,,TextMax,*Text")
;~					; No return value
				Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
					_WM_NOTIFY_DebugEvent("$NM_CLICK", $tagNMITEMACTIVATE, $lParam, "IDFrom,,Index,SubItem,NewState,OldState,Changed,ActionX,ActionY,lParam,KeyFlags")
					; No return value
				Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
					_WM_NOTIFY_DebugEvent("$NM_DBLCLK", $tagNMITEMACTIVATE, $lParam, "IDFrom,,Index,SubItem,NewState,OldState,Changed,ActionX,ActionY,lParam,KeyFlags")
					; No return value
;~ 				Case $NM_HOVER ; Sent by a list-view control when the mouse hovers over an item
;~ 					_WM_NOTIFY_DebugEvent("$NM_HOVER", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
;~ 					Return 0 ; process the hover normally
;~ 					;Return 1 ; prevent the hover from being processed
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
