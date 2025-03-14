#include <Extras\WM_NOTIFY.au3>
#include <GuiComboBoxEx.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Global $g_hCombo

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("ComboBoxEx Create (v" & @AutoItVersion & ")", 400, 300)
	$g_hCombo = _GUICtrlComboBoxEx_Create($hGUI, "This is a test|Line 2", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	_WM_NOTIFY_Register()

	_GUICtrlComboBoxEx_AddString($g_hCombo, "Some More Text")
	_GUICtrlComboBoxEx_InsertString($g_hCombo, "Text to be deleted", 1)
	_GUICtrlComboBoxEx_DeleteString($g_hCombo, 1)
	_GUICtrlComboBoxEx_InsertString($g_hCombo, "Inserted Text", 1)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
EndFunc   ;==>Example

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	Local $tInfo
	Switch $hWndFrom
		Case $g_hCombo
			Switch $iCode
				Case $CBEN_BEGINEDIT ; Sent when the user activates the drop-down list or clicks in the control's edit box.
					_WM_NOTIFY_DebugEvent("$CBEN_BEGINEDIT", $tagNMHDR, $lParam, "hWndFrom,IDFrom")
					Return 0
				Case $CBEN_DELETEITEM
					_WM_NOTIFY_DebugEvent("$CBEN_DELETEITEM", $tagNMCOMBOBOXEX, $lParam, "IDFrom,,Mask,Item,*Text,TextMax,Indent,Image,SelectedImage,OverlayImage,Param")
					Return 0
				Case $CBEN_DRAGBEGINA, $CBEN_DRAGBEGINW
					$tInfo = DllStructCreate($tagNMCBEDRAGBEGIN, $lParam)
					If DllStructGetData($tInfo, "ItemID") Then
						_WM_NOTIFY_DebugEvent("$CBEN_DRAGBEGIN", $tagNMCOMBOBOXEX, $lParam, "IDFrom,,Mask,Item,*Text,TextMax,Indent,Image,SelectedImage,OverlayImage,Param")
					EndIf
					_WM_NOTIFY_DebugEvent("$CBEN_DRAGBEGIN", $tagNMCBEDRAGBEGIN, $lParam, "IDFrom,,ItemID,Text")
					; return is ignored
				Case $CBEN_ENDEDITA, $CBEN_ENDEDITW ; Sent when the user has concluded an operation within the edit box or has selected an item from the control's drop-down list.
					_WM_NOTIFY_DebugEvent("$CBEN_ENDEDIT", $tagNMCBEENDEDIT, $lParam, "IDFrom,,fChanged,NewSelection,Text,Why")
					Return False ; accept the notification and allow the control to display the selected item
					; Return True  ; otherwise
				Case $CBEN_GETDISPINFOA, $CBEN_GETDISPINFOW ; Sent to retrieve display information about a callback item
					_WM_NOTIFY_DebugEvent("$CBEN_GETDISPINFOW", $tagNMCOMBOBOXEX, $lParam, "IDFrom,,Mask,Item,*Text,TextMax,Indent,Image,SelectedImage,OverlayImage,Param")
					Return 0
				Case $CBEN_INSERTITEM
					_WM_NOTIFY_DebugEvent("$CBEN_INSERTITEM", $tagNMCOMBOBOXEX, $lParam, "IDFrom,,Mask,Item,*Text,TextMax,Indent,Image,SelectedImage,OverlayImage,Param")
					Return 0
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
