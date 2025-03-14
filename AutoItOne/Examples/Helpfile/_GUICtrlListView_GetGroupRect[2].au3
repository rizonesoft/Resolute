#include "WinAPISysWin.au3"
#include <GuiListView.au3>
#include <WinAPISysWin.au3>

Example() ; A ListView control created with an external ListView

Func Example()
	Local $sExternalScript = StringReplace(@ScriptName, "[2]", "")
	Local $iPID = Run(@AutoItExe & " " & $sExternalScript)
	Local $hWin = WinWaitActive("ListView Get Group Info", "")

	Local $hListView = _WinAPI_EnumChildWindows($hWin)[1][0]

	; Get rect of Group ID 2
	Local $aInfo = _GUICtrlListView_GetGroupRect($hListview, 2)
	MsgBox($MB_SYSTEMMODAL, "Information (external)", "Rect :" & @TAB & @TAB & @TAB & @CRLF & _
			@TAB & "Left..: " & $aInfo[0] & @CRLF & _
			@TAB & "Top...: " & $aInfo[1] & @CRLF & _
			@TAB & "Right.: " & $aInfo[2] & @CRLF & _
			@TAB & "Bottom: " & $aInfo[3])

	ProcessClose($iPID)

EndFunc   ;==>Example
