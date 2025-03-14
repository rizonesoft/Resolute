#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <GuiStatusBar.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $sWow64 = ""
	If @AutoItX64 Then $sWow64 = "\Wow6432Node"
	Local $sFile = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE" & $sWow64 & "\AutoIt v3\AutoIt", "InstallDir") & "\include\_ReadMe_.txt"

	; Create GUI
	Local $hGUI = GUICreate("Edit Get/Set Modify (v" & @AutoItVersion & ")", 400, 300)
	Local $idEdit = GUICtrlCreateEdit("", 2, 2, 394, 268)
	Local $aPartRightSide[4] = [120, 248, 378, -1]
	Local $hStatusBar = _GUICtrlStatusBar_Create($hGUI, $aPartRightSide)
	_GUICtrlStatusBar_SetIcon($hStatusBar, 3, 97, "shell32.dll")
	GUISetState(@SW_SHOW)

	; Set Margins
	_GUICtrlEdit_SetMargins($idEdit, BitOR($EC_LEFTMARGIN, $EC_RIGHTMARGIN), 10, 10)

	; Add Text
	_GUICtrlEdit_SetText($idEdit, FileRead($sFile))
	_GUICtrlEdit_LineScroll($idEdit, 0, _GUICtrlEdit_GetLineCount($idEdit) * -1)
	; Get Modified Flag
	_GUICtrlStatusBar_SetText($hStatusBar, "Modified: " & _GUICtrlEdit_GetModify($idEdit), 1)
	Sleep(2000)

	_GUICtrlEdit_AppendText($idEdit, @CRLF & @CRLF & "Append text")
	; Get Modified Flag
	_GUICtrlStatusBar_SetText($hStatusBar, "Modified: " & _GUICtrlEdit_GetModify($idEdit), 1)
	Sleep(2000)

	; ReSet Modified Flag
	_GUICtrlEdit_SetModify($idEdit, False)
	; Get Modified Flag
	_GUICtrlStatusBar_SetText($hStatusBar, "Modified: " & _GUICtrlEdit_GetModify($idEdit), 1)

	MsgBox($MB_SYSTEMMODAL, "Information", "Set Modify Flag")
	; Set Modified Flag
	_GUICtrlEdit_SetModify($idEdit, True)

	; Get Modified Flag
	_GUICtrlStatusBar_SetText($hStatusBar, "Modified: " & _GUICtrlEdit_GetModify($idEdit), 1)

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
