#include <Extras\WM_NOTIFY.au3>
#include <GUIConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>

Global $g_hListView, $g_idMemo

Example()

Func Example()
	Local $hGui = GUICreate("ListView Edit Label (v" & @AutoItVersion & ")", 400, 300, Default, Default, Default, $WS_EX_CLIENTEDGE)
	$g_hListView = _GUICtrlListView_Create($hGui, "", 2, 2, 394, 118, BitOR($LVS_EDITLABELS, $LVS_REPORT))
	$g_idMemo = GUICtrlCreateEdit("", 2, 124, 396, 174, 0)
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($hListView, False)

	; Load images
	Local $hImage = _GUIImageList_Create()
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

	_WM_NOTIFY_Register($g_idMemo)

	; Edit item 0 label with time out
	Local $hEditLabel = _GUICtrlListView_EditLabel($g_hListView, 0)
	MemoWrite("Edit Label Handle = 0x" & Hex($hEditLabel) & " IsPtr = " & IsPtr($hEditLabel) & " IsHWnd = " & IsHWnd($hEditLabel))

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
				Case $LVN_BEGINLABELEDITA, $LVN_BEGINLABELEDITW ; Start of label editing for an item
					_WM_NOTIFY_DebugEvent("$LVN_BEGINLABELEDIT", $tagNMLVDISPINFO, $lParam, "IDFrom,,Mask,Item,SubItem,State,StateMask,Image,Param,Indent,,GroupID,Columns,pColumns")
					Return False ; Allow the user to edit the label
					; Return True  ; Prevent the user from editing the label
				Case $LVN_COLUMNCLICK ; A column was clicked
					_WM_NOTIFY_DebugEvent("$LVN_COLUMNCLICK", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
					; No return value
				Case $LVN_DELETEITEM ; An item is about to be deleted
					_WM_NOTIFY_DebugEvent("$LVN_DELETEITEM", $tagNMLISTVIEW, $lParam, "IDFrom,,Item,SubItem,NewState,OldState,Changed,ActionX,ActionY,Param")
					; No return value
				Case $LVN_ENDLABELEDITA, $LVN_ENDLABELEDITW ; The end of label editing for an item
					Local $tInfo = DllStructCreate($tagNMLVDISPINFO, $lParam)
					Local $pText = DllStructGetData($tInfo, "Text")
					If $pText <> 0 Then
						_WM_NOTIFY_DebugEvent("$LVN_ENDLABELEDIT", $tagNMLVDISPINFO, $lParam, "IDFrom,,Mask,Item,SubItem,State,StateMask,Image,Param,Indent,,GroupID,Columns,pColumns,,TextMax,*Text")
						Return True ; If Text is empty the return value is ignored
					EndIf
					; If Text is not empty, return True to set the item's label to the edited text, return false to reject it
					; If Text is empty the return value is ignored
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

; Write a line to the memo control
Func MemoWrite($sMessage)
	GUICtrlSetData($g_idMemo, $sMessage & @CRLF, 1)
EndFunc   ;==>MemoWrite
