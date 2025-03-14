#include <Extras\WM_NOTIFY.au3>
#include <GuiButton.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Global $g_hBtn, $g_hRdo, $g_hChk, $g_idMemo

; Note: The handle from these buttons can NOT be read with GUICtrlRead

Example()

Func Example()
	Local $hGUI = GUICreate("Button Create (v" & @AutoItVersion & ")", 400, 400)
	$g_idMemo = GUICtrlCreateEdit("", 119, 10, 276, 374, $WS_VSCROLL)
	GUICtrlSetFont($g_idMemo, 9, 400, 0, "Courier New")

	$g_hBtn = _GUICtrlButton_Create($hGUI, "Button1", 10, 10, 90, 50)

	$g_hRdo = _GUICtrlButton_Create($hGUI, "Radio1", 10, 60, 90, 50, $BS_AUTORADIOBUTTON)

	$g_hChk = _GUICtrlButton_Create($hGUI, "Check1", 10, 120, 90, 50, $BS_AUTO3STATE)

	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
	_WM_NOTIFY_Register($g_idMemo)

	GUISetState(@SW_SHOW)

	MemoWrite("$g_hBtn handle: " & $g_hBtn)
	MemoWrite("$g_hRdo handle: " & $g_hRdo)
	MemoWrite("$g_hChk handle: " & $g_hChk & @CRLF)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	Exit
EndFunc   ;==>Example

; Write a line to the memo control
Func MemoWrite($sMessage)
	GUICtrlSetData($g_idMemo, $sMessage & @CRLF, 1)
EndFunc   ;==>MemoWrite

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local Const $BCN_HOTITEMCHANGE = -1249
	Local $tagNMBHOTITEM = $tagNMHDR & ";dword dwFlags"
	Local $tNMBHOTITEM = DllStructCreate($tagNMBHOTITEM, $lParam)
	Local $iCode = DllStructGetData($tNMBHOTITEM, "Code")
	Local $hWndFrom = DllStructGetData($tNMBHOTITEM, "hWndFrom")
	Local $iFlags = DllStructGetData($tNMBHOTITEM, "dwFlags")
	Local $sText = ""

	Switch $iCode
		Case $BCN_HOTITEMCHANGE ; Win XP and Above
			$sText = "Text=" & _GUICtrlButton_GetText($hWndFrom)
			If BitAND($iFlags, 0x10) = 0x10 Then
				_WM_NOTIFY_DebugEvent("$BCN_HOTITEMCHANGE - Entering", $tagNMBHOTITEM, $lParam, "IDFrom", $sText)
			ElseIf BitAND($iFlags, 0x20) = 0x20 Then
				_WM_NOTIFY_DebugEvent("$BCN_HOTITEMCHANGE - Leaving", $tagNMBHOTITEM, $lParam, "IDFrom", $sText)
			EndIf
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

; React on a button click
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg
	Local $iCode = BitShift($wParam, 16)
	Local $hCtrl = $lParam
	Local $sCode, $sText

	Switch $hCtrl
		Case $g_hBtn, $g_hRdo, $g_hChk
			Switch $iCode
				Case $BN_CLICKED
					$sCode = "$BN_CLICKED"
				Case $BN_PAINT
					$sCode = "$BN_PAINT"
				Case $BN_PUSHED
					$sCode = "$BN_PUSHED"
				Case $BN_HILITE
					$sCode = "$BN_HILITE"
				Case $BN_UNPUSHED
					$sCode = "$BN_UNPUSHED"
				Case $BN_UNHILITE
					$sCode = "$BN_UNHILITE"
				Case $BN_DISABLE
					$sCode = "$BN_DISABLE"
				Case $BN_DBLCLK
					$sCode = "$BN_DBLCLK"
				Case $BN_DOUBLECLICKED
					$sCode = "$BN_DOUBLECLICKED"
				Case $BN_SETFOCUS
					$sCode = "$BN_SETFOCUS"
				Case $BN_KILLFOCUS
					$sCode = "$BN_KILLFOCUS"
			EndSwitch
			$sText = "Text=" & _GUICtrlButton_GetText($hCtrl)
			_WM_NOTIFY_DebugEvent($sCode, $tagNMHDR, $lParam, "IDFrom", $sText)
			Return 0 ; Only workout clicking on the button
	EndSwitch
	; Proceed the default AutoIt3 internal message commands.
	; You also can complete let the line out.
	; !!! But only 'Return' (without any value) will not proceed
	; the default AutoIt3-message in the future !!!
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND
