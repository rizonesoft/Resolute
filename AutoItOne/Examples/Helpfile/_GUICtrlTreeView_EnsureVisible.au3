#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <GuiTreeView.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

Example()

Func Example()

	GUICreate("TreeView Ensure Visible (v" & @AutoItVersion & ")", 400, 300)

	Local $iStyle = BitOR($TVS_EDITLABELS, $TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS)
	Local $idTreeView = GUICtrlCreateTreeView(2, 2, 396, 268, $iStyle, $WS_EX_CLIENTEDGE)
	GUISetState(@SW_SHOW)

	_GUICtrlTreeView_BeginUpdate($idTreeView)
	Local $ahItem[100]
	For $x = 0 To 99
		$ahItem[$x] = _GUICtrlTreeView_Add($idTreeView, 0, StringFormat("[%02d] New Item", $x))
	Next
	_GUICtrlTreeView_EndUpdate($idTreeView)

	Local $iRand = 64
	MsgBox($MB_SYSTEMMODAL, "Information", StringFormat("Index %d Visible: %s", $iRand, _GUICtrlTreeView_GetVisible($idTreeView, $ahItem[$iRand])))
	_GUICtrlTreeView_EnsureVisible($idTreeView, $ahItem[$iRand])
	MsgBox($MB_SYSTEMMODAL, "Information", StringFormat("Index %d Visible: %s", $iRand, _GUICtrlTreeView_GetVisible($idTreeView, $ahItem[$iRand])))

	; Loop until the user exits.
	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE
	GUIDelete()
EndFunc   ;==>Example
