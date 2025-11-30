#include-once
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>

Global $LoaderForm
Global $LOADER_STATUSBAR

Func _LoaderStart()
	$LoaderForm = GUICreate("", 150, 100, -1, -1, $WS_POPUPWINDOW, $WS_EX_TOPMOST)
	GUISetBkColor(0x000000)
	$GPowAni = GUICtrlCreateIcon(@ScriptDir & "\Themes\Loader.ani", -1, (150 - 32) / 2, 10, 32, 32)
	$LOADER_STATUSBAR = GUICtrlCreateLabel("", 10, 75, 0, 5)
	GUICtrlSetBkColor(-1, 0xFFD500)
	GUICtrlSetState($LOADER_STATUSBAR, $GUI_HIDE)
	GUISetState(@SW_SHOW, $LoaderForm)
	Return 0
EndFunc

Func _LoaderUpdate($iStatusPercent)
	If $iStatusPercent > -1 Then
		If $iStatusPercent > 100 Then $iStatusPercent = 100
		If $iStatusPercent = 0 Then
			GUICtrlSetState($LOADER_STATUSBAR, $GUI_HIDE)
		Else
			GUICtrlSetState($LOADER_STATUSBAR, $GUI_SHOW)
			GUICtrlSetPos($LOADER_STATUSBAR, 10, 75, 130 * $iStatusPercent / 100)
		EndIf
		If $iStatusPercent = 100 Then
			GUIDelete($LoaderForm)
		EndIf
	EndIf
	Return 0
EndFunc
