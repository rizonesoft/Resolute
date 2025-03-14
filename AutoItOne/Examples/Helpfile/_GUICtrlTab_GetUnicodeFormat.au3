#include <GUIConstantsEx.au3>
#include <GuiTab.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Create GUI
	GUICreate("Tab Control Get/Set Unicode Format (v" & @AutoItVersion & ")", 420, 300)
	Local $idTab = GUICtrlCreateTab(2, 2, 416, 296)
	GUISetState(@SW_SHOW)

	; Add tabs
	_GUICtrlTab_InsertItem($idTab, 0, "Tab 0")
	_GUICtrlTab_InsertItem($idTab, 1, "Tab 1")
	_GUICtrlTab_InsertItem($idTab, 2, "Tab 2")

	; Get/Set Unicode format
	Local $bFormat = _GUICtrlTab_GetUnicodeFormat($idTab)
	MsgBox($MB_SYSTEMMODAL, "Information", "Unicode format: " & $bFormat)
	_GUICtrlTab_SetUnicodeFormat($idTab, Not $bFormat)
	MsgBox($MB_SYSTEMMODAL, "Information", "Unicode format: " & _GUICtrlTab_GetUnicodeFormat($idTab))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
