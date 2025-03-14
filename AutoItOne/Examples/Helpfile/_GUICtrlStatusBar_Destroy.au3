#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("StatusBar Destroy (v" & @AutoItVersion & ")", 400, 300)

	; defaults to 1 part, no text
	Local $hStatus = _GUICtrlStatusBar_Create($hGUI)

	Local $aParts[3] = [75, 150, -1]
	_GUICtrlStatusBar_SetParts($hStatus, $aParts)
	_GUICtrlStatusBar_SetText($hStatus, "Part 0")
	_GUICtrlStatusBar_SetText($hStatus, "Part 1", 1)
	_GUICtrlStatusBar_SetText($hStatus, "Part 2", 2)

	GUISetState(@SW_SHOW)

	Local $hHandleBefore = $hStatus
	MsgBox($MB_SYSTEMMODAL, "Information", "Destroying the Control for Handle: " & $hStatus)
	MsgBox($MB_SYSTEMMODAL, "Information", "Control Destroyed: " & _GUICtrlStatusBar_Destroy($hStatus) & @CRLF & _
			"Handle Before Destroy: " & $hHandleBefore & @CRLF & _
			"Handle After Destroy: " & $hStatus)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
