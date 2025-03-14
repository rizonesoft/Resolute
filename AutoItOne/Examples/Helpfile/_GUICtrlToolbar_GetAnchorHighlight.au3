#include <GuiToolbar.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	Run("explorer.exe /root, ,::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
	WinWaitActive("My Computer", "", 1)
	Sleep(1000)
	Local $hToolbar = _GUICtrlToolbar_FindToolbar("[CLASS:CabinetWClass]", "&File")
	Local $bEnabled = _GUICtrlToolbar_GetAnchorHighlight($hToolbar)
	MsgBox($MB_SYSTEMMODAL, "Information", "Anchor highlight enabled: " & $bEnabled)
	_GUICtrlToolbar_SetAnchorHighlight($hToolbar, Not $bEnabled)
	MsgBox($MB_SYSTEMMODAL, "Information", "Anchor highlight enabled: " & _GUICtrlToolbar_GetAnchorHighlight($hToolbar))
EndFunc   ;==>Example
