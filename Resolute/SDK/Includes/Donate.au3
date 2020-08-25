#include-once


#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include <ButtonConstants.au3>
#include <GuiEdit.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#include "About.au3"
#include "Icons.au3"
#include "Localization.au3"
#include "Versioning.au3"


; #INDEX# =======================================================================================================================
; Title .........: About
; AutoIt Version : 3.3.15.0
; Description ...: About Dialog
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $g_hDonateGui
Global $g_sDonateIcon = @ScriptFullPath
Global $g_aDonateIcons[3] = [@ScriptFullPath, @ScriptFullPath, 1]
Global $g_hDonateButton

If Not IsDeclared("g_hCoreGui") Then Global $g_hCoreGui
If Not IsDeclared("g_iParentState") Then Global $g_iParentState
If Not IsDeclared("g_iParent") Then Global $g_iParent
If Not IsDeclared("g_sProgName") Then Global $g_sProgName
If Not IsDeclared("g_iAboutIconStart") Then Global $g_iAboutIconStart
If Not IsDeclared("g_sUrlCompHomePage") Then Global $g_sUrlCompHomePage
If Not IsDeclared("g_iUptimeMonitor") Then Global $g_iUptimeMonitor
If Not IsDeclared("g_sThemesDir") Then Global $g_sThemesDir
If Not IsDeclared("g_iDialogIconStart") Then Global $g_iDialogIconStart
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _Donate_ShowDialog
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Author ........: Derick Payne (Rizonesoft)
; Modified.......:
; ===============================================================================================================================
Func _Donate_ShowDialog()

	__Donate_SetResources()
	_Localization_Donate()

	$g_iParentState = WinGetState($g_hCoreGui)
	If $g_iParentState > 0 Then
		GUISetState(@SW_DISABLE, $g_hCoreGui)
		$g_iParent = $g_hCoreGui
	Else
		$g_iParent = 0
	EndIf

	$g_hDonateGui = GUICreate("Donate", 400, 280, -1, -1, BitOR($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	GUISetFont(8.5, 400, 0, "Verdana", $g_hDonateGui, 5)
	If $g_iParentState > 0 Then GUISetIcon($g_sDonateIcon, $g_iDialogIconStart + 4, $g_hDonateGui)

	GUICtrlCreateLabel("", -10, -10, 420, 100)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlCreateIcon($g_sDonateIcon, $g_iDialogIconStart + 4, 20, 20, 48, 48)
	GUICtrlCreateLabel(StringFormat($g_aLangDonate[0], Round($g_iUptimeMonitor / 3600)), 80, 20, 280, 60)
	; GUICtrlCreateLabel($g_sProgName & " has been serving you for over " & Round($g_iUptimeMonitor / 3600) & " hours. " & _
			; "Now, how about donating to our cause?", 80, 20, 280, 60)
	GUICtrlSetFont(-1, 11)
	GUICtrlSetColor(-1, 0x0565C9)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

	GUICtrlCreateLabel("", -10, 90, 420, 1)
	GUICtrlSetBkColor(-1, 0xA0A0A0)
	GUICtrlCreateLabel("", -10, 91, 420, 1)
	GUICtrlSetBkColor(-1, 0xFFFFFF)

	GUICtrlCreateLabel($g_aLangDonate[1], 30, 105, 340, 100)
	GUICtrlSetFont(-1, 9)
	GUICtrlSetColor(-1, 0x555555)

	$g_hDonateButton = GUICtrlCreateIcon($g_aDonateIcons[0], $g_iAboutIconStart, 168, 200, 64, 64)
	GUICtrlSetTip($g_hDonateButton, "Donate to our cause.")
	GUICtrlSetCursor($g_hDonateButton, 0)

	GUISetOnEvent($GUI_EVENT_CLOSE, "__Donate_CloseDialog", $g_hDonateGui)

	GUICtrlSetOnEvent($g_hDonateButton, "_About_PayPal")
	GUISetState(@SW_SHOW, $g_hDonateGui)
	AdlibRegister("__Donate_OnIconsHover", 80)

EndFunc   ;==>_Donate_ShowDialog


Func __Donate_OnIconsHover()

	Local $iCursorAbout = GUIGetCursorInfo()
	If Not @error Then

		If $iCursorAbout[4] = $g_hDonateButton And $g_aDonateIcons[2] == 1 Then
			$g_aDonateIcons[2] = 0
			GUICtrlSetImage($g_hDonateButton, $g_aDonateIcons[1], $g_iAboutIconStart + 1)
		ElseIf $iCursorAbout[4] <> $g_hDonateButton And $g_aDonateIcons[2] == 0 Then
			$g_aDonateIcons[2] = 1
			GUICtrlSetImage($g_hDonateButton, $g_aDonateIcons[0], $g_iAboutIconStart)
		EndIf

	EndIf

EndFunc   ;==>__About_OnIconsHover


Func __Donate_CloseDialog()

	AdlibUnRegister("__Donate_OnIconsHover")
	If $g_iParentState > 0 Then GUISetState(@SW_ENABLE, $g_hCoreGui)
	GUIDelete($g_hDonateGui)
	Exit

EndFunc   ;==>__Donate_CloseDialog


Func __Donate_SetResources()

	If Not @Compiled Then
		$g_sDonateIcon = $g_sThemesDir & "\Icons\Dialogs\Love.ico"
		$g_aDonateIcons[0] = $g_sThemesDir & "\Icons\About\PayPal.ico"
		$g_aDonateIcons[1] = $g_sThemesDir & "\Icons\About\PayPalH.ico"
	EndIf

EndFunc   ;==>__Donate_SetResources
