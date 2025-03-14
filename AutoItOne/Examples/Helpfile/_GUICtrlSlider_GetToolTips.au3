#include <GUIConstantsEx.au3>
#include <GuiSlider.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	; Create GUI
	GUICreate("Slider Get/Set Tool Tips (v" & @AutoItVersion & ")", 400, 296)
	Local $idSlider = GUICtrlCreateSlider(2, 2, 396, 20, BitOR($TBS_TOOLTIPS, $TBS_AUTOTICKS, $TBS_ENABLESELRANGE))
	GUISetState(@SW_SHOW)

	; Get Tool Tips
	Local $hWndTT = _GUICtrlSlider_GetToolTips($idSlider)
	MsgBox($MB_SYSTEMMODAL, "Information", "Tool Tip Handle: " & $hWndTT)

	; Set Tool Tips
	_GUICtrlSlider_SetToolTips($idSlider, $hWndTT)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
