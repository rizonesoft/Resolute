#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <WindowsConstants.au3>

Global $g_idMemo

Example()

Func Example()
	; Create GUI
	Local $hGUI = GUICreate("StatusBar Get Height/Width (v" & @AutoItVersion & ")", 400, 300)

	Local $hStatus = _GUICtrlStatusBar_Create($hGUI)
	Local $aParts[3] = [75, 150, -1]
	_GUICtrlStatusBar_SetParts($hStatus, $aParts)

	; Create memo control
	$g_idMemo = GUICtrlCreateEdit("", 2, 2, 396, 274, $WS_VSCROLL)
	GUICtrlSetFont($g_idMemo, 9, 400, 0, "Courier New")
	GUISetState(@SW_SHOW)

	; Get parts height/width
	MemoWrite("Height of parts .: " & _GUICtrlStatusBar_GetHeight($hStatus))
	MemoWrite("Width of part 0 .: " & _GUICtrlStatusBar_GetWidth($hStatus, 0))
	MemoWrite("Width of part 1 .: " & _GUICtrlStatusBar_GetWidth($hStatus, 1))
	MemoWrite("Width of part 2 .: " & _GUICtrlStatusBar_GetWidth($hStatus, 2))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example

; Write message to memo
Func MemoWrite($sMessage = "")
	GUICtrlSetData($g_idMemo, $sMessage & @CRLF, 1)
EndFunc   ;==>MemoWrite
