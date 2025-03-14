#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>
#include <SendMessage.au3>
#include <WinAPITheme.au3>
#include <WindowsConstants.au3>

Example()

Func Example()
	Local $hGUI = GUICreate("ListView Set Info Tip (v" & @AutoItVersion & ")", 400, 300)
	_WinAPI_SetThemeAppProperties($STAP_ALLOW_CONTROLS)
	_SendMessage($hGUI, $WM_THEMECHANGED)

	Local $idListview = GUICtrlCreateListView("", 2, 2, 394, 268)
	GUISetState(@SW_SHOW)

	; Set ANSI format
;~     _GUICtrlListView_SetUnicodeFormat($idListview, False)

	; Add columns
	_GUICtrlListView_AddColumn($idListview, "Items", 100)

	; Add items
	GUICtrlCreateListViewItem("Item 0", $idListview)
	GUICtrlCreateListViewItem("Item 1", $idListview)
	GUICtrlCreateListViewItem("Item 2", $idListview)

	; Change item 1
	_GUICtrlListView_SetInfoTip($idListview, 1, "InfoTip Item 1")

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
