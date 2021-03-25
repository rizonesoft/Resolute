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

	$g_aLangCustom[0]  = _Localization_Load("Custom", "Label_Status_Welcome", "Start with loading the browser (select the filename). %{Program.Name} will automatically detect the process from the executable you select.")
	$g_aLangCustom[1]  = _Localization_Load("Custom", "Label_Status_Updates", "Checking for Updates")
	$g_aLangCustom[2]  = _Localization_Load("Custom", "Group_Load_Browser", "Load Browser")
	$g_aLangCustom[3]  = _Localization_Load("Custom", "Label_Executable", "Executable Path (%s):")
	$g_aLangCustom[4]  = _Localization_Load("Custom", "Label_Process_Usage", "Usage | Peak:")
	$g_aLangCustom[5]  = _Localization_Load("Custom", "Label_Process_Count", "Process Count:")
	$g_aLangCustom[6]  = _Localization_Load("Custom", "Button_Browse", "&Browse")
	$g_aLangCustom[7]  = _Localization_Load("Custom", "Group_Options", "Options")
	$g_aLangCustom[8]  = _Localization_Load("Custom", "Checkbox_Reduce_Mem", "Reduce memory every :")
	$g_aLangCustom[9]  = _Localization_Load("Custom", "Label_Milliseconds", "milliseconds")
	$g_aLangCustom[10] = _Localization_Load("Custom", "Checkbox_Reduce_Limit", "Only reduce memory if usage is over :")
	$g_aLangCustom[11] = _Localization_Load("Custom", "Checkbox_Start_With", "Start %s when %{Program.Name} starts")
	$g_aLangCustom[12] = _Localization_Load("Custom", "Checkbox_Enable_Extended_Processes", "Enable extended processes")
	$g_aLangCustom[13] = _Localization_Load("Custom", "Button_Extended_Processes", "&Extended Processes")
	$g_aLangCustom[14] = _Localization_Load("Custom", "Checkbox_Start_Windows", "Start %{Program.Name} when Windows starts")
	$g_aLangCustom[15] = _Localization_Load("Custom", "Label_Settings_Updated", "Settings updated successfully.")
	$g_aLangCustom[16] = _Localization_Load("Custom", "Button_Cancel", "Cancel")
	$g_aLangCustom[17] = _Localization_Load("Custom", "Button_Save", "Save")
	$g_aLangCustom[18] = _Localization_Load("Custom", "Time_Unit_01", "milliseconds")
	$g_aLangCustom[19] = _Localization_Load("Custom", "Time_Unit_02", "seconds")
	$g_aLangCustom[20] = _Localization_Load("Custom", "Time_Unit_03", "minutes")
	$g_aLangCustom[21] = _Localization_Load("Custom", "Time_Unit_04", "hours")
	$g_aLangCustom[22] = _Localization_Load("Custom", "Label_Boost_Description", "Reduce every %s %s if usage over %s MB.")
	$g_aLangCustom[23] = _Localization_Load("Custom", "Title_Select_Browser", "Select Browser")
	$g_aLangCustom[24] = _Localization_Load("Custom", "Tip_Minimized_Title", "%{Program.Name} is still running!")
	$g_aLangCustom[25] = _Localization_Load("Custom", "Tip_Minimized_Message", "%{Program.Name} will continue to run to optimize %s's memory usage. Click the tray icon to change various optimization options.")

EndFunc


Func _Localization_Menus()

	If StringLen($g_aLangMenus[0]) > 0 Then
		Return
	EndIf

	$g_aLangMenus[0]  = _Localization_Load("Menus", "File", "&File")
	$g_aLangMenus[1]  = _Localization_Load("Menus", "File_Preferences", "&Preferences")
	$g_aLangMenus[2]  = _Localization_Load("Menus", "File_Close", "&Close\tShift+Alt+F4")
	$g_aLangMenus[3]  = _Localization_Load("Menus", "Help", "&Help")
	$g_aLangMenus[4]  = _Localization_Load("Menus", "Help_Update", "Check for &updates")
	$g_aLangMenus[5]  = _Localization_Load("Menus", "Help_Home", "%{Company.Name} &Home")
	$g_aLangMenus[6]  = _Localization_Load("Menus", "Help_Downloads", "More &Downloads")
	$g_aLangMenus[7]  = _Localization_Load("Menus", "Help_Support", "&Get Support")
	$g_aLangMenus[8]  = _Localization_Load("Menus", "Help_Issue", "Create an &issue")
	$g_aLangMenus[9]  = _Localization_Load("Menus", "Help_Donate", "Donate to &our Cause")
	$g_aLangMenus[10] = _Localization_Load("Menus", "Help_About", "About %{Program.Name}")
	$g_aLangMenus[11] = _Localization_Load("Menus", "Tray_About", "About %{Program.Name} %s")
	$g_aLangMenus[12] = _Localization_Load("Menus", "Tray_Open", "Open %{Program.Name}")
	$g_aLangMenus[13] = _Localization_Load("Menus", "Tray_Extended_Processes", "Extended Processes")
	$g_aLangMenus[14] = _Localization_Load("Menus", "Tray_Run", "Run %s")
	$g_aLangMenus[15] = _Localization_Load("Menus", "Tray_Run_Safemode", "Run %s in Safemode")

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
	$g_aLangPreferences[4]  = _Localization_Load("Preferences", "Group_Notifications", "Notifications")
	$g_aLangPreferences[5]  = _Localization_Load("Preferences", "Group_Extended_Processes", "Extended Processes")
	$g_aLangPreferences[6]  = _Localization_Load("Preferences", "Group_Priority", "Priority")
	$g_aLangPreferences[7]  = _Localization_Load("Preferences", "Group_Memory", "Memory")
	$g_aLangPreferences[8]  = _Localization_Load("Preferences", "Group_Language", "Language")
	$g_aLangPreferences[9]  = _Localization_Load("Preferences", "Checkbox_Notifications", "Show tray notifications")
	$g_aLangPreferences[10] = _Localization_Load("Preferences", "Label_Extended_Processes", "Language")
	$g_aLangPreferences[11] = _Localization_Load("Preferences", "Label_SetPriority", "Set process priority:")
	$g_aLangPreferences[12] = _Localization_Load("Preferences", "Checkbox_SaveRealtime", "Save priority above high (not recommended).")
	$g_aLangPreferences[13] = _Localization_Load("Preferences", "Checkbox_ReduceMemory", "Reduce memory on low memory systems.")
	$g_aLangPreferences[14] = _Localization_Load("Preferences", "Label_Language_Message", "Select the language you prefer and press the %s button to continue. (Restart Required)")
	$g_aLangPreferences[15] = _Localization_Load("Preferences", "Button_Save", "Save")
	$g_aLangPreferences[16] = _Localization_Load("Preferences", "Button_Cancel", "Cancel")
	$g_aLangPreferences[17] = _Localization_Load("Preferences", "Label_Updated", "Preferences Updated")
	$g_aLangPreferences[18] = _Localization_Load("Preferences", "MsgBox_Language_Title", "Language Changed")
	$g_aLangPreferences[19] = _Localization_Load("Preferences", "MsgBox_Language_Message", "The selected language has changed. Complete Internet Repair should be restarted for the chosen language to take effect.")
	$g_aLangPreferences[20] = _Localization_Load("Preferences", "MsgBox_Closing_Title", "Closing %{Program.Name}")
	$g_aLangPreferences[21] = _Localization_Load("Preferences", "MsgBox_Closing_Message", "Would you like to close %{Program.Name} now?")

EndFunc