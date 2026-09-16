#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <GUIRichEdit.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sText = 'AutoIt v3 is a freeware BASIC-like scripting language designed for automating the Windows GUI and general scripting. It uses a combination of simulated keystrokes, mouse movement and window/control manipulation in order to automate tasks in a way not possible or reliable with other languages (e.g. VBScript and SendKeys). AutoIt is also very small, self-contained and will run on all versions of Windows out-of-the-box with no annoying "runtimes" required!' & @CRLF & @CRLF & _
                      'AutoIt was initially designed for PC "roll out" situations to reliably automate and configure thousands of PCs. Over time it has become a powerful language that supports complex expressions, user functions, loops and everything else that veteran scripters would expect.'

Global $hForm, $hDlg, $hRichEdit, $hFont, $Msg, $Menu, $ExitItem, $FindItem, $ReplaceItem, $Text, $Lenght

; Create GUI
$hForm = GUICreate('MyGUI', 800, 600)

; Create main menu
$Menu = GUICtrlCreateMenu('&File')
$ExitItem = GUICtrlCreateMenuItem('E&xit...', $Menu)
$Menu = GUICtrlCreateMenu('&Edit')
$FindItem = GUICtrlCreateMenuItem('&Find...', $Menu)
$ReplaceItem = GUICtrlCreateMenuItem('R&eplace...', $Menu)

; Create Rich Edit control with always visible text selection, and set "Courier New" font to the control
$hRichEdit = _GUICtrlRichEdit_Create($hForm, $sText, 0, 0, 800, 600, BitOR($ES_AUTOVSCROLL, $ES_NOHIDESEL, $ES_MULTILINE, $WS_VSCROLL), 0)
$hFont = _WinAPI_CreateFont(17, 0, 0, 0, $FW_NORMAL , 0, 0, 0, $DEFAULT_CHARSET, $OUT_DEFAULT_PRECIS, $CLIP_DEFAULT_PRECIS, $ANTIALIASED_QUALITY, $DEFAULT_PITCH, 'Courier New')
_SendMessage($hRichEdit, $WM_SETFONT, $hFont, 1)
_SendMessage($hRichEdit, $EM_SETSEL)

; Register FINDMSGSTRING message to receive the messages from the dialog box
GUIRegisterMsg(_WinAPI_RegisterWindowMessage('commdlg_FindReplace'), 'WM_FINDMSGSTRING')

; Show GUI
GUISetState()

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case $GUI_EVENT_CLOSE, $ExitItem
			ExitLoop
		Case $FindItem, $ReplaceItem
			$Text = _GUICtrlRichEdit_GetSelText($hRichEdit)
			If @error Then
				$Text = ''
			EndIf
			; Disable "Find..." and "Replace..." menu items, otherwise, the script maay crash
			GUICtrlSetState($FindItem, $GUI_DISABLE)
			GUICtrlSetState($ReplaceItem, $GUI_DISABLE)
			Switch $Msg
				Case $FindItem
					$hDlg = _WinAPI_FindTextDlg($hForm, $Text, $FR_DOWN, 0, $hRichEdit)
				Case $ReplaceItem
					$hDlg = _WinAPI_ReplaceTextDlg($hForm, $Text, '', 0, 0, $hRichEdit)
			EndSwitch
		Case $ReplaceItem
	EndSwitch
WEnd

GUIDelete()

Func _IsMatchSelection($hWnd, $sText, $iBehavior)

	Local $Pos

	$Pos = _GUICtrlRichEdit_GetSel($hWnd)
	If @error Then
		Return 0
	EndIf
	$Pos = _GUICtrlRichEdit_FindTextInRange($hWnd, $sText, $Pos[0], $Pos[1], BitAND($iBehavior, $FR_MATCHCASE) = $FR_MATCHCASE, BitAND($iBehavior, $FR_WHOLEWORD) = $FR_WHOLEWORD, BitAND($iBehavior, BitOR($FR_MATCHALEFHAMZA, $FR_MATCHDIAC, $FR_MATCHKASHIDA)))
	If ($Pos[0] = -1) Or ($Pos[1] = -1) Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>_IsMatchSelection

Func WM_FINDMSGSTRING($hWnd, $iMsg, $wParam, $lParam)

	Local $tFINDREPLACE = DllStructCreate($tagFINDREPLACE, $lParam)
	Local $sReplace = _WinAPI_GetString(DllStructGetData($tFINDREPLACE, 'ReplaceWith'))
	Local $sFind = _WinAPI_GetString(DllStructGetData($tFINDREPLACE, 'FindWhat'))
	Local $hRichEdit = Ptr(DllStructGetData($tFINDREPLACE, 'lParam'))
	Local $Flags = DllStructGetData($tFINDREPLACE, 'Flags')
	Local $Pos, $Cur = -1

	Select
		; The user clicked the "Replace" button in a Replace dialog box
		Case BitAND($Flags, $FR_REPLACE)
			If _IsMatchSelection($hRichEdit, $sFind, $Flags) Then
				_GUICtrlRichEdit_ReplaceText($hRichEdit, $sReplace)
			EndIf
			ContinueCase
		; The user clicked the "Find Next" button in a Find or Replace dialog box
		Case BitAND($Flags, $FR_FINDNEXT)
			$Pos = _GUICtrlRichEdit_GetSel($hRichEdit)
			If @error Then
				Return
			EndIf
			If BitAND($Flags, $FR_DOWN) Then
				$Pos = _GUICtrlRichEdit_FindTextInRange($hRichEdit, $sFind, $Pos[1],-1, BitAND($Flags, $FR_MATCHCASE) = $FR_MATCHCASE, BitAND($Flags, $FR_WHOLEWORD) = $FR_WHOLEWORD)
			Else
				$Pos = _GUICtrlRichEdit_FindTextInRange($hRichEdit, $sFind, $Pos[0], 0, BitAND($Flags, $FR_MATCHCASE) = $FR_MATCHCASE, BitAND($Flags, $FR_WHOLEWORD) = $FR_WHOLEWORD, BitAND($Flags, $FR_DOWN))
			EndIf
			If ($Pos[0] = -1) Or ($Pos[1] = -1) Then
				MsgBox(64, WinGetTitle($hDlg), 'Cannot find "' & $sFind & '"', 0, $hDlg)
				Return
			EndIf
			; Here and below used the EM_SETSEL message directly because _GUICtrlRichEdit_SetSel() sets a focus to the Rich Edit control
			_SendMessage($hRichEdit, $EM_SETSEL, $Pos[0], $Pos[1])
;			_GUICtrlRichEdit_ScrollToCaret($hRichEdit)
		; The user clicked the "Replace All" button in a Replace dialog box
		Case BitAND($Flags, $FR_REPLACEALL)
			Dim $Pos[2] = [0, -1]
			While 1
				$Pos = _GUICtrlRichEdit_FindTextInRange($hRichEdit, $sFind, $Pos[0],-1, BitAND($Flags, $FR_MATCHCASE) = $FR_MATCHCASE, BitAND($Flags, $FR_WHOLEWORD) = $FR_WHOLEWORD)
				If ($Pos[0] = -1) Or ($Pos[1] = -1) Then
					If $Cur = -1 Then
						MsgBox(64, WinGetTitle($hDlg), 'Cannot find "' & $sFind & '"', 0, $hDlg)
						Return
					EndIf
					ExitLoop
				EndIf
				If $Cur = -1 Then
					_GUICtrlRichEdit_PauseRedraw($hRichEdit)
				EndIf
				_SendMessage($hRichEdit, $EM_SETSEL, $Pos[0], $Pos[1])
				If _GUICtrlRichEdit_ReplaceText($hRichEdit, $sReplace) Then
					$Cur = $Pos[0] + StringLen($sReplace)
				Else
					ExitLoop
				EndIf
			WEnd
			_SendMessage($hRichEdit, $EM_SETSEL, $Cur, $Cur)
;			_GUICtrlRichEdit_ScrollToCaret($hRichEdit)
			_GUICtrlRichEdit_ResumeRedraw($hRichEdit)
		; The dialog box is closing
		Case BitAND($Flags, $FR_DIALOGTERM)
			; Destroy internal buffer, and free allocated memory
			_WinAPI_FlushFRBuffer()
			; Enable "Find..." and "Replace..." menu items
			GUICtrlSetState($ReplaceItem, $GUI_ENABLE)
			GUICtrlSetState($FindItem, $GUI_ENABLE)
	EndSelect
EndFunc   ;==>WM_FINDMSGSTRING
