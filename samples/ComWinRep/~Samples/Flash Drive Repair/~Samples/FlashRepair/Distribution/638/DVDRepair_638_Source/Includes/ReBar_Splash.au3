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
Opt("MustDeclareVars", 1) ;~ 0=no, 1=require pre-declaration

#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <GuiConstantsEx.au3>

;#include "ReBar_Declarations.au3"


Global $g_SplashForm
Global $g_SplashMessage
Global $g_SplashProgress

If Not IsDeclared("g_ReBarSplashEnable") Then Global $g_ReBarSplashEnable = True
If Not IsDeclared("g_ReBarSplashAni") Then Global $g_ReBarSplashAni = ""

Func _SplashStart($sMessage = "Loading Message")

	If $g_ReBarSplashEnable = True Then

		$g_SplashForm = GUICreate("", 250, 150, -1, -1, BitOr($WS_POPUP, $WS_BORDER))
		GuiSetFont(9, -1, -1, "Tahoma", $g_SplashForm, 5)
		GUICtrlCreateIcon($g_ReBarSplashAni, -1, (250 - 32) / 2, 15, 32, 32)
		$g_SplashMessage = GuiCtrlCreateLabel($sMessage, 1, 65, 248, -1, $SS_CENTER)

		;~ StatusBar Background
		GUICtrlCreateLabel("", 9, 99, 232, 12)
		GUICtrlSetBkColor(-1, 0x000000)
		GUICtrlCreateLabel("", 10, 100, 230, 10)
		GUICtrlSetBkColor(-1, 0xC0C0C0)

		;~ StatusBar
		$g_SplashProgress = GUICtrlCreateLabel("", 11, 101, 1, 8)
		GUICtrlSetBkColor($g_SplashProgress, 0x000000)
		GUICtrlSetState($g_SplashProgress, $GUI_HIDE)

		GUISetState(@SW_SHOW, $g_SplashForm)

	EndIf

EndFunc


Func _SplashUpdate($sMessage, $iPerc, $bIsImportant = False)

	If $g_ReBarSplashEnable = True Then

		If $iPerc > -1 Then
			If $iPerc > 100 Then $iPerc = 100
			If $iPerc = 0 Then
				GUICtrlSetState($g_SplashProgress, $GUI_HIDE)
			Else
				If BitAND(GUICtrlGetState($g_SplashProgress), 32) = 32 Then
					GUICtrlSetState($g_SplashProgress, $GUI_SHOW)
				EndIf
				GUICtrlSetPos($g_SplashProgress, 11, 101, 228 * $iPerc / 100)
			EndIf

			If StringStripWS($sMessage, $STR_STRIPALL) <> "" Then
				GUICtrlSetData($g_SplashMessage, $sMessage)
				If $bIsImportant Then
					Sleep(1000)
				EndIf
			EndIf

		EndIf

		If $iPerc = 100 Then
			GUIDelete($g_SplashForm)
		EndIf

	EndIf

EndFunc