#include-once

#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
;#AutoIt3Wrapper_Run_Tidy=Y										 ;~ (Y/N) Run Tidy before compilation. Default=N
;#AutoIt3Wrapper_Tidy_Stop_OnError=Y								 ;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


; #INDEX# =======================================================================================================================
; Title .........: Localization (Custom)
; AutoIt Version : 3.3.15.0
; Language ......: English
; Description ...: Localization Functions.
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================


#include "..\..\..\Includes\Localization.au3"


; #CONSTANTS# ===================================================================================================================
Global Const $LNG_COUNTCUSTOM = 10
Global Const $LNG_COUNTMENUS = 102
Global Const $LNG_COUNTMESSAGES2 = 10
Global Const $LNG_COUNTPREFERENCES = 102
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
If Not IsDeclared("g_sLanguageFile") Then Global $g_sLanguageFile
If Not IsDeclared("g_aLangCustom") Then Global $g_aLangCustom[$LNG_COUNTCUSTOM]
If Not IsDeclared("g_aLangMenus") Then Global $g_aLangMenus[$LNG_COUNTMENUS]
If Not IsDeclared("g_aLangMessages2") Then Global $g_aLangMessages2[$LNG_COUNTMESSAGES2]
If Not IsDeclared("g_aLangPreferences") Then Global $g_aLangPreferences[$LNG_COUNTPREFERENCES]
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; ===============================================================================================================================


Func _Localization_Custom()

	;~ Check if the language strings is already loaded. Because we do not want to load the language strings twice.
	If StringLen($g_aLangCustom[0]) > 0 Then
		Return
	EndIf

	$g_aLangCustom[0]  = _Localization_Load("Custom", "Label_Status_Welcome", "Welcome Buddies")
	$g_aLangCustom[1]  = _Localization_Load("Custom", "Label_Status_Updates", "Checking for Updates")

EndFunc


Func _Localization_Menus()

	If StringLen($g_aLangMenus[0]) > 0 Then
		Return
	EndIf

	$g_aLangMenus[0]  = _Localization_Load("Menus", "File", "&File")
	$g_aLangMenus[1]  = _Localization_Load("Menus", "File_Preferences", "&Preferences")
	$g_aLangMenus[2]  = _Localization_Load("Menus", "File_Logging", "&Logging")
	$g_aLangMenus[3]  = _Localization_Load("Menus", "File_Logging_Open_File", "Open &log File")
	$g_aLangMenus[4]  = _Localization_Load("Menus", "File_Logging_Open_Directory", "Open log &Directory")
	$g_aLangMenus[5]  = _Localization_Load("Menus", "File_Close", "&Close\tAlt+F4")
	$g_aLangMenus[6]  = _Localization_Load("Menus", "Help", "&Help")
	$g_aLangMenus[7]  = _Localization_Load("Menus", "Help_Update", "Check for &updates")
	$g_aLangMenus[8]  = _Localization_Load("Menus", "Help_Home", "%{Company.Name} &Home")
	$g_aLangMenus[9]  = _Localization_Load("Menus", "Help_Downloads", "More &Downloads")
	$g_aLangMenus[10] = _Localization_Load("Menus", "Help_Contact", "&Get Support")
	$g_aLangMenus[11] = _Localization_Load("Menus", "Help_Issue", "Create an &issue")
	$g_aLangMenus[12] = _Localization_Load("Menus", "Help_Donate", "Donate to &our Cause")
	$g_aLangMenus[13] = _Localization_Load("Menus", "Help_About", "About %{Program.Name}")

EndFunc


Func _Localization_Messages2()

	If StringLen($g_aLangMessages2[0]) > 0 Then
		Return
	EndIf

EndFunc


Func _Localization_Preferences()

	;~ Check if the language strings is already loaded. Because we do not want to load the language strings twice.
	If StringLen($g_aLangPreferences[0]) > 0 Then
		Return
	EndIf

	$g_aLangPreferences[0]  = _Localization_Load("Preferences", "Window_Title", "Preferences")
	$g_aLangPreferences[1]  = _Localization_Load("Preferences", "Tab_General", "General")
	$g_aLangPreferences[2]  = _Localization_Load("Preferences", "Tab_Cache", "Cache")
	$g_aLangPreferences[3]  = _Localization_Load("Preferences", "Tab_Performance", "Performance")
	$g_aLangPreferences[4]  = _Localization_Load("Preferences", "Tab_Language", "Language")
	$g_aLangPreferences[5]  = _Localization_Load("Preferences", "Group_Logging", "Logging")
	$g_aLangPreferences[6]  = _Localization_Load("Preferences", "Group_Priority", "Priority")
	$g_aLangPreferences[7]  = _Localization_Load("Preferences", "Group_Memory", "Memory")
	$g_aLangPreferences[8]  = _Localization_Load("Preferences", "Group_Language", "Language")
	$g_aLangPreferences[9]  = _Localization_Load("Preferences", "Checkbox_Enable_Logging", " Enable logging")
	$g_aLangPreferences[10] = _Localization_Load("Preferences", "Label_Log_Exceed", "Log size must not exceed :")
	$g_aLangPreferences[11] = _Localization_Load("Preferences", "Label_Logging_Size", "Logging Size: %s KB")
	$g_aLangPreferences[12] = _Localization_Load("Preferences", "Button_Logging_Clear", "Clear Logging")
	$g_aLangPreferences[13] = _Localization_Load("Preferences", "Label_SetPriority", "Set process priority:")
	$g_aLangPreferences[14] = _Localization_Load("Preferences", "Checkbox_SaveRealtime", "Save priority above high (not recommended).")
	$g_aLangPreferences[15] = _Localization_Load("Preferences", "Checkbox_ReduceMemory", "Reduce memory on low memory systems.")
	$g_aLangPreferences[16] = _Localization_Load("Preferences", "Label_Language_Message", "Select the language you prefer and press the %s button to continue. (Restart Required)")
	$g_aLangPreferences[17] = _Localization_Load("Preferences", "Button_Save", "Save")
	$g_aLangPreferences[18] = _Localization_Load("Preferences", "Button_Cancel", "Cancel")
	$g_aLangPreferences[19] = _Localization_Load("Preferences", "Label_Updated", "Preferences Updated")
	$g_aLangPreferences[20] = _Localization_Load("Preferences", "Label_Logging_Cleared", "Logging cleared")
	$g_aLangPreferences[21] = _Localization_Load("Preferences", "MsgBox_Language_Title", "Language Changed")
	$g_aLangPreferences[22] = _Localization_Load("Preferences", "MsgBox_Language_Message", "The selected language has changed. Complete Internet Repair should be restarted for the chosen language to take effect.")
	$g_aLangPreferences[23] = _Localization_Load("Preferences", "MsgBox_Closing_Title", "Closing %{Program.Name}")
	$g_aLangPreferences[24] = _Localization_Load("Preferences", "MsgBox_Closing_Message", "Would you like to close %{Program.Name} now?")

EndFunc