#include-once


#cs ----------------------------------------------------------------------------

 AutoIt Version:  3.3.12.0
 Author:          Derick Payne (Rizonesoft)
 Home Page:       www.rizonesoft.com
 Email:			  support@rizonesoft.com

 Script Function:

	Doors Splash Screen.

 License:

    Copyright (C) 2015 Rizonesoft

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.

#ce ----------------------------------------------------------------------------


#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <GuiConstantsEx.au3>

#include "CoreConstants.au3"


Global $SPLASH_FORM
Global $SPLASH_MESSAGE
Global $SPLASH_STATUSBAR

Func _SplashStart($sMessage = "Loading Message")

	$SPLASH_FORM = GUICreate("", 250, 150, -1, -1, BitOr($WS_POPUP, $WS_BORDER), $WS_EX_TOPMOST)
	GuiSetFont(9, -1, -1, "Tahoma", $SPLASH_FORM, 5)
	GUICtrlCreateIcon($FILE_PROCANI, -1, (250 - 32) / 2, 15, 32, 32)
	$SPLASH_MESSAGE = GuiCtrlCreateLabel($sMessage, 1, 65, 248, -1, $SS_CENTER)

	;~ StatusBar Background
	GUICtrlCreateLabel("", 9, 99, 232, 12)
	GUICtrlSetBkColor(-1, 0x000000)
	GUICtrlCreateLabel("", 10, 100, 230, 10)
	GUICtrlSetBkColor(-1, 0xC0C0C0)
	;~ StatusBar
	$SPLASH_STATUSBAR = GUICtrlCreateLabel("", 11, 101, 1, 8)
	GUICtrlSetBkColor($SPLASH_STATUSBAR, 0x000000)
	GUICtrlSetState($SPLASH_STATUSBAR, $GUI_HIDE)

	GUISetState(@SW_SHOW, $SPLASH_FORM)

EndFunc


Func _SplashUpdate($sMessage, $iPerc)

	If $iPerc > -1 Then
		If $iPerc > 100 Then $iPerc = 100
		If $iPerc = 0 Then
			GUICtrlSetState($SPLASH_STATUSBAR, $GUI_HIDE)
		Else
			If BitAND(GUICtrlGetState($SPLASH_STATUSBAR), 32) = 32 Then
				GUICtrlSetState($SPLASH_STATUSBAR, $GUI_SHOW)
			EndIf
			GUICtrlSetPos($SPLASH_STATUSBAR, 11, 101, 228 * $iPerc / 100)
		EndIf

		If StringStripWS($sMessage, $STR_STRIPALL) <> "" Then
			GUICtrlSetData($SPLASH_MESSAGE, $sMessage)
		EndIf

	EndIf

	If $iPerc = 100 Then
		GUIDelete($SPLASH_FORM)
	EndIf

EndFunc