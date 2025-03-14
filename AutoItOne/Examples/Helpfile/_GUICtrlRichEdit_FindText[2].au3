#include <GuiRichEdit.au3>

Local $sText = "First line" & @CR & @CR & "Last line" & @CR
Local $iStart, $iEnd, $sLine, $i
Local $iTextLen
Local $iFindTextError, $iGetTextError
Local $sMsgBuff = ""

Local $hGUI = GUICreate("Find Text Test", 300, 300)
Local $hRichEdit = _GUICtrlRichEdit_Create($hGUI, "", 10, 10, 280, 280)
GUISetState(@SW_SHOW, $hGUI)

_GUICtrlRichEdit_SetText($hRichEdit, $sText)
$iStart = 0
$iTextLen = _GUICtrlRichEdit_GetTextLength($hRichEdit, True, True)
$sMsgBuff = $iTextLen & " characters in Rich Edit box"

For $i = 1 To 6
	If Not _GUICtrlRichEdit_GotoCharPos($hRichEdit, $iStart) Then
;~ 		MsgBox(0, "", "False from GotoCharPos")
		ExitLoop
	EndIf
	$iEnd = _GUICtrlRichEdit_FindText($hRichEdit, @CR) ; Find the next CR
	If $iEnd = -1 Then ExitLoop
	$iFindTextError = @error
	If $iEnd = $iStart Then
		$sLine = "" ; end = start just means a blank line
		$iGetTextError = 0
	Else
		$sLine = _GUICtrlRichEdit_GetTextInRange($hRichEdit, $iStart, $iEnd) ; the line is all characters between start and end
		$iGetTextError = @error
	EndIf
	$sMsgBuff &= @CRLF & $i & ": Start = " & $iStart & ", End = " & $iEnd & ": <" & $sLine & ">  (@errors = " & $iFindTextError & ", " & $iGetTextError & ")" ; accumulate results
	$iStart = $iEnd + 1 ; Next search starts one character after the last found CR
Next
MsgBox(0, "Test results", $sMsgBuff)
_GUICtrlRichEdit_Destroy($hRichEdit)
GUIDelete($hGUI)
Exit
