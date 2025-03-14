; Create an ownerdrawn/colored button

#include <ButtonConstants.au3>
#include <FrameConstants.au3>
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>

Example()

Func Example()
	Local $hGUI = GUICreate("Ownerdrawn Created Button", 300, 200)

	Local $idButton = GUICtrlCreateButton("", 90, 50, 120, 30)
	GUICtrlSetStyle($idButton, BitOR($WS_TABSTOP, $BS_NOTIFY, $BS_OWNERDRAW)) ; Set the ownerdrawn flag

	Local $idButton2 = GUICtrlCreateButton("Normal Button", 90, 110, 120, 30)

	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

	; WM_DRAWITEM has to be registered before showing GUI otherwise the initial drawing is not done
	GUIRegisterMsg($WM_DRAWITEM, "WM_DRAWITEM")

	GUISetState(@SW_SHOW, $hGUI)

	Local $iMsg
	While 1
		$iMsg = GUIGetMsg()

		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idButton
				; Normally should not fire because of our WM_COMMAND function
				MsgBox($MB_SYSTEMMODAL, "Info", "Button pressed")

			Case $idButton2
				; Normally should not fire because of our WM_COMMAND function
				MsgBox($MB_SYSTEMMODAL, "Info", "Button2 pressed")

		EndSwitch
	WEnd

	GUIDelete()
EndFunc   ;==>Example

; React on a button click
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	Local $nNotifyCode = _WinAPI_HiWord($wParam)
	Local $iId = _WinAPI_LoWord($wParam)
	Local $hCtrl = $lParam

	If $iId <> 2 And $nNotifyCode = 0 Then ; Check for IDCANCEL - 2
		; Ownerdrawn buttons do not send a message when pressing ENTER
		; So if IDOK - 1 comes up, now check for the control that has the current focus
		If $iId = 1 Then
			Local $hFocus = _WinAPI_GetFocus()
			Local $idControl = _WinAPI_GetDlgCtrlId($hFocus)
			PostButtonClick($hWnd, $idControl)
		Else
			MsgBox($MB_SYSTEMMODAL, "WM_COMMAND", "GUIHWnd" & @TAB & ":" & $hWnd & @CRLF & _
					"MsgId" & @TAB & ":" & $iMsg & @CRLF & _
					"wParam" & @TAB & ":" & $wParam & @CRLF & _
					"lParam" & @TAB & ":" & $lParam & @CRLF & @CRLF & _
					"WM_COMMAND - Infos:" & @CRLF & _
					"-----------------------------" & @CRLF & _
					"Code" & @TAB & ":" & $nNotifyCode & @CRLF & _
					"CtrlId" & @TAB & ":" & $iId & @CRLF & _
					"CtrlHWnd" & @TAB & ":" & $hCtrl)
		EndIf
		Return 0 ; Only workout clicking on the button
	EndIf

	; On exit the default AutoIt3 internal message handler will run
	; It will also run if "Return" returns $GUI_RUNDEFMSG as below
	; Using "Return" with any other value (or no value at all) means the AutoIt handler
	; will not run
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

; RePost a WM_COMMAND message to a ctrl in a gui window
Func PostButtonClick($hWnd, $idControl)
	DllCall("user32.dll", "int", "PostMessage", _
			"hwnd", $hWnd, _
			"int", $WM_COMMAND, _
			"int", _WinAPI_LoWord($idControl), _
			"hwnd", GUICtrlGetHandle($idControl))
EndFunc   ;==>PostButtonClick

; Draw the button
Func WM_DRAWITEM($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg, $wParam, $lParam
	Local Const $tagDRAWITEMSTRUCT = "uint;uint;uint;uint;uint;hwnd;handle;long[4];ulong_ptr"
	Local $tDrawItem = DllStructCreate($tagDRAWITEMSTRUCT, $lParam)

	Local Const $ODT_BUTTON = 4

	Local $nCtlType = DllStructGetData($tDrawItem, 1)
	If $nCtlType = $ODT_BUTTON Then
		; Local $idControl = DllStructGetData($tDrawItem, 2)
		Local $nItemState = DllStructGetData($tDrawItem, 5)
		Local $hCtrl = DllStructGetData($tDrawItem, 6)
		Local $hDC = DllStructGetData($tDrawItem, 7)
		Local $iLeft = DllStructGetData($tDrawItem, 8, 1)
		Local $iTop = DllStructGetData($tDrawItem, 8, 2)
		Local $iRight = DllStructGetData($tDrawItem, 8, 3)
		Local $iBottom = DllStructGetData($tDrawItem, 8, 4)
		Local $sText = "Ownerdrawn Button"
		Local $nTextColor = 0x5555DD
		Local $nBackColor = 0xFFEEDD
		DrawButton($hWnd, $hCtrl, $hDC, $iLeft, $iTop, $iRight, $iBottom, $nItemState, $sText, $nTextColor, $nBackColor)
		$tDrawItem = 0
		Return 1 ; The internal AutoIt message handler will not run
	EndIf

	$tDrawItem = 0
	Return $GUI_RUNDEFMSG ; Run the default AutoIt internal message handler
EndFunc   ;==>WM_DRAWITEM

; The main drawing procedure
Func DrawButton($hWnd, $hCtrl, $hDC, $iLeft, $iTop, $iRight, $iBottom, $nItemState, $sText, $nTextColor, $nBackColor)
	#forceref $hWnd

	Local Const $ODS_SELECTED = 0x0001
	Local Const $ODS_GRAYED = 0x0002
	Local Const $ODS_DISABLED = 0x0004
	Local Const $ODS_FOCUS = 0x0010

	Local $bFocused = BitAND($nItemState, $ODS_FOCUS)
	Local $bGrayed = BitAND($nItemState, BitOR($ODS_GRAYED, $ODS_DISABLED))
	Local $bSelected = BitAND($nItemState, $ODS_SELECTED)

	Local $tRECT = DllStructCreate($tagRECT)
	DllStructSetData($tRECT, 'Left', $iLeft)
	DllStructSetData($tRECT, 'Top', $iTop)
	DllStructSetData($tRECT, 'Right', $iRight)
	DllStructSetData($tRECT, 'Bottom', $iBottom)

	Local $nClrTxt = 0
	If $bGrayed Then
		$nClrTxt = _WinAPI_SetTextColor($hDC, _WinAPI_GetSysColor($COLOR_HIGHLIGHTTEXT))
	ElseIf $nTextColor = -1 Then
		$nClrTxt = _WinAPI_SetTextColor($hDC, _WinAPI_GetSysColor($COLOR_BTNTEXT))
	Else
		$nClrTxt = _WinAPI_SetTextColor($hDC, $nTextColor)
	EndIf

	Local $hBrush, $nClrSel
	If $nBackColor = -1 Then
		$hBrush = _WinAPI_GetSysColorBrush($COLOR_BTNFACE)
		$nClrSel = _WinAPI_GetSysColor($COLOR_BTNFACE)
	Else
		$hBrush = _WinAPI_CreateSolidBrush($nBackColor)
		$nClrSel = $nBackColor;
	EndIf

	Local $nClrBk = _WinAPI_SetBkColor($hDC, $nClrSel)
	Local $hOldBrush = _WinAPI_SelectObject($hDC, $hBrush)

	Local $nTmpLeft = $iLeft
	Local $nTmpTop = $iTop
	Local $nTmpRight = $iRight
	Local $nTmpBottom = $iBottom

	If $bSelected Then
		InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -1, -1)
		Local $hBrushSel = _WinAPI_CreateSolidBrush(_WinAPI_GetSysColor($COLOR_BTNSHADOW))
		FrameRect($hDC, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, $hBrushSel)
		_WinAPI_DeleteObject($hBrushSel)
	Else
		If $bFocused And Not $bSelected Then InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -1, -1)
		DrawFrameControl($hDC, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, $DFC_BUTTON, $DFCS_BUTTONPUSH)
	EndIf

	$nTmpLeft = $iLeft
	$nTmpTop = $iTop
	$nTmpRight = $iRight
	$nTmpBottom = $iBottom

	If $bSelected Then
		InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -2, -2)
	Else
		If $bFocused And Not $bSelected Then
			InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -3, -3)
			$nTmpLeft -= 1
			$nTmpTop -= 1
		Else
			InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -2, -2)
			$nTmpLeft -= 1
			$nTmpTop -= 1
		EndIf
	EndIf

	FillRect($hDC, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, $hBrush)

	If $bSelected Or $bGrayed Then
		$nTmpLeft = $nTmpLeft + 2
		$nTmpTop = $nTmpTop + 2
	EndIf

	Local $iFlags = BitOR($DT_NOCLIP, $DT_CENTER, $DT_VCENTER)

	If Not BitAND(_WinAPI_GetWindowLong($hCtrl, $GWL_STYLE), $BS_MULTILINE) Then $iFlags = BitOR($iFlags, $DT_SINGLELINE)

	DrawText($hDC, $sText, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, $iFlags)

	If $bGrayed Then
		$nTmpLeft = $iLeft
		$nTmpTop = $iTop
		$nTmpRight = $iRight
		$nTmpBottom = $iBottom

		$nTmpLeft -= 1

		$nClrTxt = _WinAPI_SetTextColor($hDC, _WinAPI_GetSysColor($COLOR_GRAYTEXT))
		DrawText($hDC, $sText, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, BitOR($DT_NOCLIP, $DT_CENTER, $DT_VCENTER, $DT_SINGLELINE))
	EndIf

	$nTmpLeft = $iLeft
	$nTmpTop = $iTop
	$nTmpRight = $iRight
	$nTmpBottom = $iBottom

	If $bFocused Then
		$hBrush = _WinAPI_CreateSolidBrush(0)
		FrameRect($hDC, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, $hBrush)

		$nTmpLeft = $iLeft
		$nTmpTop = $iTop
		$nTmpRight = $iRight
		$nTmpBottom = $iBottom

		InflateRect($nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom, -4, -4)
		DrawFocusRect($hDC, $nTmpLeft, $nTmpTop, $nTmpRight, $nTmpBottom)
	EndIf

	_WinAPI_SelectObject($hDC, $hOldBrush)
	_WinAPI_DeleteObject($hBrush)
	_WinAPI_SetTextColor($hDC, $nClrTxt)
	_WinAPI_SetBkColor($hDC, $nClrBk)

	Return 1 ; The internal AutoIt message handler will not run
EndFunc   ;==>DrawButton

Func DrawFrameControl($hDC, $iLeft, $iTop, $iRight, $iBottom, $iType, $iState)
	Local $tRECT = DllStructCreate($tagRECT)

	DllStructSetData($tRECT, 'Left', $iLeft)
	DllStructSetData($tRECT, 'Top', $iTop)
	DllStructSetData($tRECT, 'Right', $iRight)
	DllStructSetData($tRECT, 'Bottom', $iBottom)

	_WinAPI_DrawFrameControl($hDC, $tRECT, $iType, $iState)
EndFunc   ;==>DrawFrameControl

Func DrawFocusRect($hDC, $iLeft, $iTop, $iRight, $iBottom)
	Local $tRECT = DllStructCreate($tagRECT)

	DllStructSetData($tRECT, 'Left', $iLeft)
	DllStructSetData($tRECT, 'Top', $iTop)
	DllStructSetData($tRECT, 'Right', $iRight)
	DllStructSetData($tRECT, 'Bottom', $iBottom)

	_WinAPI_DrawFocusRect($hDC, $tRECT)
EndFunc   ;==>DrawFocusRect

Func DrawText($hDC, $sText, $iLeft, $iTop, $iRight, $iBottom, $iFlags)
	Local $tRECT = DllStructCreate($tagRECT)

	DllStructSetData($tRECT, 'Left', $iLeft)
	DllStructSetData($tRECT, 'Top', $iTop)
	DllStructSetData($tRECT, 'Right', $iRight)
	DllStructSetData($tRECT, 'Bottom', $iBottom)

	_WinAPI_DrawText($hDC, $sText, $tRECT, $iFlags)
EndFunc   ;==>DrawText

Func FillRect($hDC, $iLeft, $iTop, $iRight, $iBottom, $hBrush)
	Local $tRECT = DllStructCreate($tagRECT)

	DllStructSetData($tRECT, 'Left', $iLeft)
	DllStructSetData($tRECT, 'Top', $iTop)
	DllStructSetData($tRECT, 'Right', $iRight)
	DllStructSetData($tRECT, 'Bottom', $iBottom)

	_WinAPI_FillRect($hDC, $tRECT, $hBrush)
EndFunc   ;==>FillRect

Func FrameRect($hDC, $iLeft, $iTop, $iRight, $iBottom, $hBrush)
	Local $tRECT = DllStructCreate($tagRECT)

	DllStructSetData($tRECT, 'Left', $iLeft)
	DllStructSetData($tRECT, 'Top', $iTop)
	DllStructSetData($tRECT, 'Right', $iRight)
	DllStructSetData($tRECT, 'Bottom', $iBottom)

	_WinAPI_FrameRect($hDC, $tRECT, $hBrush)
EndFunc   ;==>FrameRect

Func InflateRect(ByRef $iLeft, ByRef $iTop, ByRef $iRight, ByRef $iBottom, $iDX, $iDY)
	Local $tRECT = DllStructCreate($tagRECT)

	DllStructSetData($tRECT, 'Left', $iLeft)
	DllStructSetData($tRECT, 'Top', $iTop)
	DllStructSetData($tRECT, 'Right', $iRight)
	DllStructSetData($tRECT, 'Bottom', $iBottom)

	_WinAPI_InflateRect($tRECT, $iDX, $iDY)

	$iLeft = DllStructGetData($tRECT, 'Left')
	$iTop = DllStructGetData($tRECT, 'Top')
	$iRight = DllStructGetData($tRECT, 'Right')
	$iBottom = DllStructGetData($tRECT, 'Bottom')
EndFunc   ;==>InflateRect
