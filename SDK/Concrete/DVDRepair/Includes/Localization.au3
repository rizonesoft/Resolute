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
Global Const $LNG_COUNTCUSTOM = 102
Global Const $LNG_COUNTMENUS = 102
Global Const $LNG_COUNTMESSAGES2 = 102
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

	$g_aLangCustom[0]  = _Localization_Load("Custom", "Label_Status_Welcome", "If your DVD Drives is missing from %{Windows.Version} or it is not recognized by some applications, click '%s' and restart your computer. Remember to create a System Restore Point before you continue.")
	$g_aLangCustom[1]  = _Localization_Load("Custom", "Label_Status_Updates", "Checking for Updates")
	$g_aLangCustom[2]  = _Localization_Load("Custom", "Label_Status_Warning", "It may be necessary to reinstall any software designed to utilize BD/DVD/CD drives after running %{Program.Name}.")
	$g_aLangCustom[3]  = _Localization_Load("Custom", "Radio_Reset_Autorun", "Reset Autorun Options")
	$g_aLangCustom[4]  = _Localization_Load("Custom", "Checkbox_Just_Repair", "Just Repair")
	$g_aLangCustom[5]  = _Localization_Load("Custom", "Tip_Nothing_Title", "Disable reset and protect options.")
	$g_aLangCustom[6]  = _Localization_Load("Custom", "Tip_Nothing_Message", "Disable extra processing")
	$g_aLangCustom[7]  = _Localization_Load("Custom", "Radio_Protect", "Protect against Autorun Malware")
	$g_aLangCustom[8]  = _Localization_Load("Custom", "Tip_Protect_Message", "This option disables autorun functionality for all removable drives!\rnSelect '%s' to enable autorun.")
	$g_aLangCustom[9]  = _Localization_Load("Custom", "Tip_Protect_Title", "Warning!")
	$g_aLangCustom[10] = _Localization_Load("Custom", "Checkbox_Include_Local", "Including Local Machine")
	$g_aLangCustom[11] = _Localization_Load("Custom", "Button_Repair", "Repair DVD drives")

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
	$g_aLangMenus[5]  = _Localization_Load("Menus", "File_Reboot", "&Reboot Windows")
	$g_aLangMenus[6]  = _Localization_Load("Menus", "File_Close", "&Close\tAlt+F4")
	$g_aLangMenus[7]  = _Localization_Load("Menus", "Troubleshoot", "Trouble&shoot")
	$g_aLangMenus[8]  = _Localization_Load("Menus", "Troubleshoot_Hardware", "Troubleshoot problems using &hardware")
	$g_aLangMenus[9]  = _Localization_Load("Menus", "Tools", "T&ools")
	$g_aLangMenus[10] = _Localization_Load("Menus", "Tools_System_Restore", "&Create a Windows Restore Point")
	$g_aLangMenus[11] = _Localization_Load("Menus", "Tools_Device_Manager", "&Device Manager")
	$g_aLangMenus[12] = _Localization_Load("Menus", "Tools_Update_Firmware", "Update &Firmware (FirmwareHQ.com)")
	$g_aLangMenus[13] = _Localization_Load("Menus", "Help", "&Help")
	$g_aLangMenus[14] = _Localization_Load("Menus", "Help_Update", "Check for &updates")
	$g_aLangMenus[15] = _Localization_Load("Menus", "Help_Home", "%{Company.Name} &Home")
	$g_aLangMenus[16] = _Localization_Load("Menus", "Help_Downloads", "More &Downloads")
	$g_aLangMenus[17] = _Localization_Load("Menus", "Help_Support", "&Get Support")
	$g_aLangMenus[18] = _Localization_Load("Menus", "Help_Issue", "Create an &issue")
	$g_aLangMenus[19] = _Localization_Load("Menus", "Help_Donate", "Donate to &our Cause")
	$g_aLangMenus[20] = _Localization_Load("Menus", "Help_About", "About %{Program.Name}")

EndFunc


Func _Localization_Messages2()

	If StringLen($g_aLangMessages2[0]) > 0 Then
		Return
	EndIf

	$g_aLangMessages2[0]  = _Localization_Load("Messages2", "Boot_01", "A system reboot may be required before the settings will take effect.")
	$g_aLangMessages2[1]  = _Localization_Load("Messages2", "Boot_02", "To Reboot or not to Reboot?")
	$g_aLangMessages2[2]  = _Localization_Load("Messages2", "Boot_03", "You might need to reboot your computer before the settings will take effect. Would you like to reboot your computer now? Save your stuff, hold your breath and press Yes to reboot your computer. Or press No to ignore me.")
	$g_aLangMessages2[3]  = _Localization_Load("Messages2", "Boot_04", "^ You do not want to reboot your computer?")
	$g_aLangMessages2[4]  = _Localization_Load("Messages2", "Boot_05", "^ Can't argue with that. It is your computer after all.")
	$g_aLangMessages2[5]  = _Localization_Load("Messages2", "Boot_06", "Click on '%s' and then '%s' to Reboot your computer later.")
	$g_aLangMessages2[6]  = _Localization_Load("Messages2", "Boot_07", "Rebooting Windows...")
	$g_aLangMessages2[7]  = _Localization_Load("Messages2", "MsgBox_Boot_Title", "Reboot!")
	$g_aLangMessages2[8]  = _Localization_Load("Messages2", "MsgBox_Boot_Message", "Your computer will reboot in %s seconds. This should give you enough time to save your stuff. Press Ok to reboot your computer now.")
	$g_aLangMessages2[9]  = _Localization_Load("Messages2", "Boot_Restarting", "Your computer is restarting.")
	$g_aLangMessages2[10] = _Localization_Load("Messages2", "Boot_Canceled", "Reboot Canceled.")
	$g_aLangMessages2[11] = _Localization_Load("Messages2", "Repair_Drives_01", "Repairing DVD Drive.")
	$g_aLangMessages2[12] = _Localization_Load("Messages2", "Repair_Drives_02", "Resetting Upper and Lower Filters.")
	$g_aLangMessages2[13] = _Localization_Load("Messages2", "Repair_Drives_03", "Resetting Autorun Settings.")
	$g_aLangMessages2[14] = _Localization_Load("Messages2", "Repair_Drives_04", "Restoring the ATAPI disk interface.")
	$g_aLangMessages2[15] = _Localization_Load("Messages2", "Repair_Drives_05", "Hope that resolved your issues. If not, it could be a physical hardware problem.")

EndFunc


Func _Localization_Preferences()

	;~ Check if the language strings is already loaded. Because we do not want to load the language strings twice.
	If StringLen($g_aLangPreferences[0]) > 0 Then
		Return
	EndIf

	$g_aLangPreferences[0]  = _Localization_Load("Preferences", "Window_Title", "Preferences")
	$g_aLangPreferences[1]  = _Localization_Load("Preferences", "Tab_General", "General")
	$g_aLangPreferences[2]  = _Localization_Load("Preferences", "Tab_Performance", "Performance")
	$g_aLangPreferences[3]  = _Localization_Load("Preferences", "Tab_Language", "Language")
	$g_aLangPreferences[4]  = _Localization_Load("Preferences", "Group_Logging", "Logging")
	$g_aLangPreferences[5]  = _Localization_Load("Preferences", "Group_Priority", "Priority")
	$g_aLangPreferences[6]  = _Localization_Load("Preferences", "Group_Memory", "Memory")
	$g_aLangPreferences[7]  = _Localization_Load("Preferences", "Group_Language", "Language")
	$g_aLangPreferences[8]  = _Localization_Load("Preferences", "Checkbox_Enable_Logging", " Enable logging")
	$g_aLangPreferences[9]  = _Localization_Load("Preferences", "Label_Log_Exceed", "Log size must not exceed :")
	$g_aLangPreferences[10] = _Localization_Load("Preferences", "Label_Logging_Size", "Logging Size: %s KB")
	$g_aLangPreferences[11] = _Localization_Load("Preferences", "Button_Logging_Clear", "Clear Logging")
	$g_aLangPreferences[12] = _Localization_Load("Preferences", "Label_SetPriority", "Set process priority:")
	$g_aLangPreferences[13] = _Localization_Load("Preferences", "Checkbox_SaveRealtime", "Save priority above high (not recommended).")
	$g_aLangPreferences[14] = _Localization_Load("Preferences", "Checkbox_ReduceMemory", "Reduce memory on low memory systems.")
	$g_aLangPreferences[15] = _Localization_Load("Preferences", "Label_Language_Message", "Select the language you prefer and press the %s button to continue. (Restart Required)")
	$g_aLangPreferences[16] = _Localization_Load("Preferences", "Button_Save", "Save")
	$g_aLangPreferences[17] = _Localization_Load("Preferences", "Button_Cancel", "Cancel")
	$g_aLangPreferences[18] = _Localization_Load("Preferences", "Label_Updated", "Preferences Updated")
	$g_aLangPreferences[19] = _Localization_Load("Preferences", "Label_Logging_Cleared", "Logging cleared")
	$g_aLangPreferences[20] = _Localization_Load("Preferences", "MsgBox_Language_Title", "Language Changed")
	$g_aLangPreferences[21] = _Localization_Load("Preferences", "MsgBox_Language_Message", "The selected language has changed. Complete Internet Repair should be restarted for the chosen language to take effect.")
	$g_aLangPreferences[22] = _Localization_Load("Preferences", "MsgBox_Closing_Title", "Closing %{Program.Name}")
	$g_aLangPreferences[23] = _Localization_Load("Preferences", "MsgBox_Closing_Message", "Would you like to close %{Program.Name} now?")

EndFunc