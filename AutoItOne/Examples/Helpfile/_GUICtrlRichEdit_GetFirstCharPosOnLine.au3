#include <GUIConstantsEx.au3>
#include <GuiRichEdit.au3>
#include <WindowsConstants.au3>

Global $g_idLblMsg
Example()

Func Example()
	Local $hGui, $hRichEdit, $iLastLineNumber, $iCharPosition, $iMsg
	$hGui = GUICreate("Example (" & StringTrimRight(@ScriptName, StringLen(".exe")) & ")", 520, 350, -1, -1)
	$hRichEdit = _GUICtrlRichEdit_Create($hGui, "This is a test.", 10, 10, 500, 220, _
			BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL))
	$g_idLblMsg = GUICtrlCreateLabel("", 10, 235, 300, 60)
	GUISetState(@SW_SHOW)

	_GUICtrlRichEdit_AutoDetectURL($hRichEdit, True)
	_GUICtrlRichEdit_AppendText($hRichEdit, @CRLF & "http://www.autoitscript.com")

	$iLastLineNumber = _GUICtrlRichEdit_GetLineCount($hRichEdit)

	; get first char position of last line
	$iCharPosition = _GUICtrlRichEdit_GetFirstCharPosOnLine($hRichEdit, $iLastLineNumber)

	; select 4 chars - should be "http" word
	_GUICtrlRichEdit_SetSel($hRichEdit, $iCharPosition, $iCharPosition + 4)
	Report("Character attributes at start of line " & $iLastLineNumber & " are " & _
			_GUICtrlRichEdit_GetCharAttributes($hRichEdit))

	While True
		$iMsg = GUIGetMsg()
		Select
			Case $iMsg = $GUI_EVENT_CLOSE
				_GUICtrlRichEdit_Destroy($hRichEdit) ; needed unless script crashes
				; GUIDelete() 	; is OK too
				Exit
		EndSelect
	WEnd
EndFunc   ;==>Example

Func Report($sMsg)
	GUICtrlSetData($g_idLblMsg, $sMsg)
EndFunc   ;==>Report
