#include <GUIConstantsEx.au3>
#include <GuiDateTimePicker.au3>

Example()

Func Example()
	Local $hDTP

	; Create GUI
	GUICreate("DateTimePick Set Format (v" & @AutoItVersion & ")", 400, 300)
	$hDTP = GUICtrlGetHandle(GUICtrlCreateDate("", 2, 6, 190))

	GUISetState(@SW_SHOW)

	; Set the display format
	Local $iRet = _GUICtrlDTP_SetFormat($hDTP, "ddd MMM dd, yyyy hh:mm ttt")
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $iRet = ' & $iRet & @CRLF & '>Error code: ' & @error & '    Extended code: ' & @extended & ' (0x' & Hex(@extended) & ')' & @CRLF) ;### Debug Console

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
