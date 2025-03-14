#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

Example()

Func Example()
	; Create GUI
	GUICreate("ComboBox Get/Set HorizontalExtent (v" & @AutoItVersion & ")", 420, 296)
	Local $idCombo = GUICtrlCreateCombo("", 2, 2, 416, 296, BitOR($CBS_SIMPLE, $CBS_DISABLENOSCROLL, $WS_HSCROLL))
	GUISetState(@SW_SHOW)

	; Add files
	_GUICtrlComboBox_BeginUpdate($idCombo)
	_GUICtrlComboBox_AddDir($idCombo, @WindowsDir & "\*.exe")
	_GUICtrlComboBox_EndUpdate($idCombo)

	; Get Horizontal Extent
	MsgBox($MB_SYSTEMMODAL, "Information", "Horizontal Extent: " & _GUICtrlComboBox_GetHorizontalExtent($idCombo))

	; Set Horizontal Extent
	_GUICtrlComboBox_SetHorizontalExtent($idCombo, 500)

	; Get Horizontal Extent
	MsgBox($MB_SYSTEMMODAL, "Information", "Horizontal Extent: " & _GUICtrlComboBox_GetHorizontalExtent($idCombo))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
