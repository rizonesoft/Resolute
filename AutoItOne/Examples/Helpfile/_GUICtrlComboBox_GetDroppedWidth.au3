#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Create GUI
	GUICreate("ComboBox Get/Set Dropped Width (v" & @AutoItVersion & ")", 420, 296)
	Local $idCombo = GUICtrlCreateCombo("", 2, 2, 416, 296)
	GUISetState(@SW_SHOW)

	; Add files
	_GUICtrlComboBox_BeginUpdate($idCombo)
	_GUICtrlComboBox_AddDir($idCombo, @WindowsDir & "\*.exe")
	_GUICtrlComboBox_EndUpdate($idCombo)

	; Set Dropped Width
	_GUICtrlComboBox_SetDroppedWidth($idCombo, 500)

	; Get Dropped Width
	MsgBox($MB_SYSTEMMODAL, "Information", "Dropped Width: " & _GUICtrlComboBox_GetDroppedWidth($idCombo))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
