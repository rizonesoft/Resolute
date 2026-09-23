#include-once


Global $LOADER_FORM, $LOADER_STATUSBAR

Func _LoaderStart()

	$LOADER_FORM = GUICreate("", 250, 150, -1, -1, BitOr(0x80000000, 0x00800000), 0x00000008)
	;~ $WS_POPUP = 0x80000000, $WS_BORDER = 0x00800000, $WS_EX_TOPMOST = 0x00000008

	GUICtrlCreateIcon(@ScriptDir & "\Doors\Themes\Stroke.ani", -1, (250 - 32) / 2, 15, 32, 32)
	GuiCtrlCreateLabel("Loading Doors...",1 , 65, 248, -1, 0x1) ;~ $SS_CENTER = 0x1

	GuiCtrlSetFont(-1, 10, -1, -1, "Tahoma", 5)
	GUICtrlCreateLabel("", 9, 99, 232, 12)
	GUICtrlSetBkColor(-1, 0x000000)
	GUICtrlCreateLabel("", 10, 100, 230, 10)
	GUICtrlSetBkColor(-1, 0xC0C0C0)
	$LOADER_STATUSBAR = GUICtrlCreateLabel("", 11, 101, 0, 8)
	GUICtrlSetBkColor($LOADER_STATUSBAR, 0x000000)
	GUICtrlSetState($LOADER_STATUSBAR, 32) ;~ $GUI_HIDE = 32
	GUISetState(@SW_SHOW, $LOADER_FORM)

	Return 0

EndFunc


Func _LoaderUpdate($iStatusPercent)

	If $iStatusPercent > -1 Then

		If $iStatusPercent > 100 Then $iStatusPercent = 100

		If $iStatusPercent = 0 Then
			GUICtrlSetState($LOADER_STATUSBAR, 32) ;~ $GUI_HIDE = 32
		Else
			GUICtrlSetState($LOADER_STATUSBAR, 16) ;~ $GUI_SHOW = 16
			GUICtrlSetPos($LOADER_STATUSBAR, 11, 101, 228 * $iStatusPercent / 100)
		EndIf

		If $iStatusPercent = 100 Then
			GUIDelete($LOADER_FORM)
		EndIf

	EndIf

	Return 0

EndFunc