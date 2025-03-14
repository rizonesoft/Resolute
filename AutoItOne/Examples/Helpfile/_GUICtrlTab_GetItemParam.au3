; == Example Created with UDF

#include <GUIConstantsEx.au3>
#include <GuiTab.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("Tab Get/Set Item Param (v" & @AutoItVersion & ")", 400, 300)
	Local $hTab = _GUICtrlTab_Create($hGUI, 2, 2, 396, 296)
;~ 	Local $hTab = GUICtrlCreateTab(2, 2, 396, 296) ; if creation by builtin
	GUISetState(@SW_SHOW)

	; Add tabs
	_GUICtrlTab_InsertItem($hTab, 0, "Tab 0")
	_GUICtrlTab_InsertItem($hTab, 1, "Tab 1")
	_GUICtrlTab_InsertItem($hTab, 2, "Tab 2")

	; Get/Set tab 0 parameter
	_GUICtrlTab_SetItemParam($hTab, 0, 1234)
	MsgBox($MB_SYSTEMMODAL, "Information", "Tab 0 parameter: " & _GUICtrlTab_GetItemParam($hTab, 0))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
