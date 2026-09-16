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
Global Const $LNG_COUNTPOWER = 10
Global Const $LNG_COUNTREPAIR = 102
Global Const $LNG_COUNTREPAIRINFO = 102
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
If Not IsDeclared("g_sLanguageFile") Then Global $g_sLanguageFile
If Not IsDeclared("g_aLangCustom") Then Global $g_aLangCustom[$LNG_COUNTCUSTOM]
If Not IsDeclared("g_aLangMenus") Then Global $g_aLangMenus[$LNG_COUNTMENUS]
If Not IsDeclared("g_aLangMessages2") Then Global $g_aLangMessages2[$LNG_COUNTMESSAGES2]
If Not IsDeclared("g_aLangPower") Then Global $g_aLangPower[$LNG_COUNTPOWER]
If Not IsDeclared("g_aLangRepair") Then Global $g_aLangRepair[$LNG_COUNTREPAIR]
If Not IsDeclared("g_aLangRepairInfo") Then Global $g_aLangRepairInfo[$LNG_COUNTREPAIRINFO]
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; ===============================================================================================================================


Func _Localization_Custom()

	;~ Check if the language strings is already loaded. Because we do not want to load the language strings twice.
	If StringLen($g_aLangCustom[0]) > 0 Then
		Return
	EndIf

	$g_aLangCustom[0]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Status.Welcome", "Welcome Buddies"))
	$g_aLangCustom[1]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Status.Updates", "Checking for Updates"))
	$g_aLangCustom[2]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Power.Heading", "Repair Options"))
	$g_aLangCustom[3]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Power.Level01", "Low"))
	$g_aLangCustom[4]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Power.Level02", "Below Normal"))
	$g_aLangCustom[5]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Power.Level03", "Normal"))
	$g_aLangCustom[6]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Power.Level04", "Above Normal"))
	$g_aLangCustom[7]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Power.Level05", "High"))
	$g_aLangCustom[8]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Power.Level06", "Realtime"))
	$g_aLangCustom[9]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Button.Scan.System.Files", "Scan System Files"))
	$g_aLangCustom[10] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Button.Restore.Health", "Restore Health (DISM)"))
	$g_aLangCustom[11] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Button.Run.One", ""))
	$g_aLangCustom[12] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Button.Run.All", "Go"))
	$g_aLangCustom[13] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Tab.Description", "Description"))
	$g_aLangCustom[14] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Tab.Logging", "Logging"))
	$g_aLangCustom[15] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "All.Complete", "All selected tasks Complete."))

EndFunc


Func _Localization_Menus()

	If StringLen($g_aLangMenus[0]) > 0 Then
		Return
	EndIf

	$g_aLangMenus[0]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File", "&File"))
	$g_aLangMenus[1]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File.Logging", "&Logging"))
	$g_aLangMenus[2]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File.Log.OpenFile", "Open &log File"))
	$g_aLangMenus[3]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File.Log.OpenDir", "Open log &Directory"))
	$g_aLangMenus[4]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File.Close", "Close\tAlt+F4"))
	$g_aLangMenus[5]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help", "&Help"))
	$g_aLangMenus[6]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Update", "Check for &updates"))
	$g_aLangMenus[7]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Home", "%{Company.Name} &Home"))
	$g_aLangMenus[8]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Forums", "Product Support &Forums"))
	$g_aLangMenus[9]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Downloads", "More &Downloads"))
	$g_aLangMenus[10] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Contact", "&Contact %{Company.Name}"))
	$g_aLangMenus[11] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Issue", "Create an &issue"))
	$g_aLangMenus[12] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Donate", "Donate to &our Cause"))
	$g_aLangMenus[13] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.About", "About %{Program.Name}"))
	$g_aLangMenus[14] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Debug", "&Debug"))

EndFunc


Func _Localization_Messages2()

	If StringLen($g_aLangMessages2[0]) > 0 Then
		Return
	EndIf

	$g_aLangMessages2[0]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Select.Something.Title", "Select Something"))
	$g_aLangMessages2[1]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Select.Something", "How about selecting something first?"))
	$g_aLangMessages2[2]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Stopping", "Stopping, Please wait!"))
	$g_aLangMessages2[3]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.01", "A system reboot may be required before the settings will take effect."))
	$g_aLangMessages2[4]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.02", "To Reboot or not to Reboot?"))
	$g_aLangMessages2[5]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.03", "You might need to reboot your computer before the settings will take effect. Would you like to reboot your computer now? Save your stuff, hold your breath and press Yes to reboot your computer. Or press No to ignore me."))
	$g_aLangMessages2[6]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.04", "^ You do not want to reboot your computer?"))
	$g_aLangMessages2[7]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.05", "^ Can't argue with that. It is your computer after all."))
	$g_aLangMessages2[8]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.06", "Click on File and then Reboot Windows to Reboot your computer later."))
	$g_aLangMessages2[9]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.07", "Rebooting Windows..."))
	$g_aLangMessages2[10] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.08", "Reboot!"))
	$g_aLangMessages2[11] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.09", "Your computer will reboot in %s seconds. This should give you enough time to save your stuff. Press Ok to reboot your computer now."))
	$g_aLangMessages2[12] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.10", "Your computer is restarting."))
	$g_aLangMessages2[13] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Boot.11", "Reboot Canceled."))
	$g_aLangMessages2[14] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "ResetIP.01", "Resetting all IP configurations."))
	$g_aLangMessages2[15] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "ResetIP.02", "TCP/IP Reset log located @ [%s]"))
	$g_aLangMessages2[16] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "ResetIP.03", "Resetting IP version 4 configurations."))
	$g_aLangMessages2[17] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "ResetIP.04", "Resetting IP version 6 configurations."))
	$g_aLangMessages2[18] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Winsock.01", "Attempting to reset Winsock catalog."))
	$g_aLangMessages2[19] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Winsock.02", "It is recommended that you install Windows XP Service Pack 2 or later."))
	$g_aLangMessages2[20] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Winsock.03", "Finished resetting Winsock catalog."))
	$g_aLangMessages2[21] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Winsock.04", "Resetting Winsock using Method 1."))
	$g_aLangMessages2[22] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Winsock.05", "Resetting Winsock using Method 2."))
	$g_aLangMessages2[23] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RenewIP.01", "Releasing and Renewing TCP/IP connections."))
	$g_aLangMessages2[24] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RenewIP.02", "Releasing TCP/IP connections."))
	$g_aLangMessages2[25] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RenewIP.03", "Renewing TCP/IP connections."))
	$g_aLangMessages2[26] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RenewIP.04", "Resetting Winsock."))
	$g_aLangMessages2[27] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RenewIP.05", "TCP/IP renewed"))
	$g_aLangMessages2[28] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "DNS.01", "Refreshing DNS Resolver Cache."))
	$g_aLangMessages2[29] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "DNS.02", "Flushing DNS"))
	$g_aLangMessages2[30] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "DNS.03", "Registering DNS"))
	$g_aLangMessages2[31] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "DNS.04", "DNS Refreshed"))
	$g_aLangMessages2[32] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "ARP.01", "Flushing ARP (Address Resolution Protocol) Cache."))
	$g_aLangMessages2[33] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "ARP.02", "ARP Cache Refreshed"))
	$g_aLangMessages2[34] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.01", "Repairing Internet Explorer version %s."))
	$g_aLangMessages2[35] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.02", "Closing Internet Explorer. Save your work before you press OK"))
	$g_aLangMessages2[36] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.03", "Repairing 'Open in new tab/window not working'."))
	$g_aLangMessages2[37] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.04", "Repairing 'Add-Ons-Manager menu entry is present but nothing happens'."))
	$g_aLangMessages2[38] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.05", "Repairing Simple HTML Mail API."))
	$g_aLangMessages2[39] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.06", "Repairing Group policy snap-in."))
	$g_aLangMessages2[40] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.07", "Repairing Smart Screen."))
	$g_aLangMessages2[41] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.08", "Repairing IEAK Branding."))
	$g_aLangMessages2[42] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.09", "Repairing Development Tools."))
	$g_aLangMessages2[43] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.10", "Repairing 'IE8 closes immediately on launch'."))
	$g_aLangMessages2[44] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.11", "Repairing License Manager."))
	$g_aLangMessages2[45] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.12", "Repairing Javascript links don't work (Robin Walker) .NET hub file."))
	$g_aLangMessages2[46] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.13", "Repairing VS Debugger."))
	$g_aLangMessages2[47] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.14", "Repairing Printing problems, open in new window."))
	$g_aLangMessages2[48] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.15", "Repairing 'Find on this page is blank'."))
	$g_aLangMessages2[49] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.16", "Repairing Process debug manager."))
	$g_aLangMessages2[50] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.17", "Repairing VML Renderer."))
	$g_aLangMessages2[51] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.18", "Fixing 'New tabs page cannot display content because it cannot access the controls'."))
	$g_aLangMessages2[52] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.19", "This is a result of a bug in shdocvw.dll."))
	$g_aLangMessages2[53] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.20", "Repairing Outlook Express."))
	$g_aLangMessages2[54] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "RepairIE.21", "Internet Explorer should function correctly now."))
	$g_aLangMessages2[55] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "ClearUpdate.01", "Clearing File Stores (Update History)."))
	$g_aLangMessages2[56] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "ClearUpdate.02", "Update History Cleared."))

EndFunc


Func _Localization_Power()

	If StringLen($g_aLangPower[0]) > 0 Then
		Return
	EndIf

	; $g_aLangPower[0] =

EndFunc


Func _Localization_Repair()

	If StringLen($g_aLangRepair[0]) > 0 Then
		Return
	EndIf

	$g_aLangRepair[0]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Repair.Options", "Repair Options (%s)"))
	$g_aLangRepair[1]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Repair.Impact", "Impact"))
	$g_aLangRepair[2]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Repair.Impact.1", "None"))
	$g_aLangRepair[3]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Repair.Impact.2", "Low"))
	$g_aLangRepair[4]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Repair.Impact.3", "Moderate"))
	$g_aLangRepair[5]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Repair.Impact.4", "High"))
	$g_aLangRepair[6]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Repair.Notes", "Notes"))
	$g_aLangRepair[7]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Maintenance", "Maintenance"))
	$g_aLangRepair[8]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Malware", "Malware"))
	$g_aLangRepair[9]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.System", "System"))
	$g_aLangRepair[10] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Desktop", "Desktop"))
	$g_aLangRepair[11] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Explorer", "Explorer"))
	$g_aLangRepair[12] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Internet", "Internet and Networking"))
	$g_aLangRepair[13] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Hardware", "Hardware"))
	$g_aLangRepair[14] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Programs", "Programs"))
	$g_aLangRepair[15] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Accociations", "Accociations"))
	$g_aLangRepair[16] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Security", "Security"))
	$g_aLangRepair[17] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Performance", "Performance"))
	$g_aLangRepair[18] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Miscellaneous", "Miscellaneous"))
	$g_aLangRepair[19] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.WindowsXP", "Windows XP"))
	$g_aLangRepair[20] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.WindowsVista", "Windows Vista"))
	$g_aLangRepair[21] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Windows7", "Windows 7"))
	$g_aLangRepair[22] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Windows8", "Windows 8"))
	$g_aLangRepair[23] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Windows81", "Windows 8.1"))
	$g_aLangRepair[24] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Repair", "Group.Windows10", "Windows 10"))

	$g_aLangRepair[25] = _Localization_Load("Repair", "System.01", "Register Windows System Dlls") & "|3|3"
	$g_aLangRepair[26] = _Localization_Load("Repair", "Internet.01", "Reset Internet Protocols (TCP/IP)") & "|4|6"
	$g_aLangRepair[27] = _Localization_Load("Repair", "Internet.02", "Repair Winsock (Reset Catalog)") & "|3|6"
	$g_aLangRepair[28] = _Localization_Load("Repair", "Internet.03", "Renew Internet Connections") & "|2|6"
	$g_aLangRepair[29] = _Localization_Load("Repair", "Internet.04", "Flush DNS Resolver Cache (Domain Name System)") & "|1|6"
	$g_aLangRepair[30] = _Localization_Load("Repair", "Internet.05", "Flush ARP Cache (Address Resolution Protocol)") & "|1|6"
	$g_aLangRepair[31] = _Localization_Load("Repair", "Internet.06", "Repair Internet Explorer %s") & "|1|6"
	$g_aLangRepair[32] = _Localization_Load("Repair", "Internet.07", "Clear Windows Update History") & "|1|6"
	$g_aLangRepair[33] = _Localization_Load("Repair", "Internet.08", "Repair Windows / Automatic Updates") & "|1|6"
	$g_aLangRepair[34] = _Localization_Load("Repair", "Internet.09", "Repair SSL / HTTPS / Cryptography") & "|1|6"
	$g_aLangRepair[35] = _Localization_Load("Repair", "Internet.10", "Reset Proxy Server Configuration") & "|1|6"
	$g_aLangRepair[36] = _Localization_Load("Repair", "Internet.11", "Reset Windows Firewall Configuration") & "|1|6"
	$g_aLangRepair[37] = _Localization_Load("Repair", "Internet.12", "Restore the default hosts file") & "|1|6"
	$g_aLangRepair[38] = _Localization_Load("Repair", "Internet.13", "Renew Wins Client Registrations") & "|1|6"


EndFunc


Func _Localization_RepairInfo()

	If StringLen($g_aLangRepairInfo[0]) > 0 Then
		Return
	EndIf

	$g_aLangRepairInfo[0]  = _Localization_Load("RepairInfo", "System.01", "")
	$g_aLangRepairInfo[1]  = _Localization_Load("RepairInfo", "Internet.01", "Static IP configuration may be lost!")
	$g_aLangRepairInfo[2]  = _Localization_Load("RepairInfo", "Internet.02", "Any pre-installed LSP's will need to be reinstalled.")
	$g_aLangRepairInfo[3]  = _Localization_Load("RepairInfo", "Internet.03", "")
	$g_aLangRepairInfo[4]  = _Localization_Load("RepairInfo", "Internet.04", "")
	$g_aLangRepairInfo[5]  = _Localization_Load("RepairInfo", "Internet.05", "")
	$g_aLangRepairInfo[6]  = _Localization_Load("RepairInfo", "Internet.06", "")
	$g_aLangRepairInfo[7]  = _Localization_Load("RepairInfo", "Internet.07", "")
	$g_aLangRepairInfo[8]  = _Localization_Load("RepairInfo", "Internet.08", "")
	$g_aLangRepairInfo[9]  = _Localization_Load("RepairInfo", "Internet.09", "")
	$g_aLangRepairInfo[10] = _Localization_Load("RepairInfo", "Internet.10", "")
	$g_aLangRepairInfo[11] = _Localization_Load("RepairInfo", "Internet.11", "")
	$g_aLangRepairInfo[12] = _Localization_Load("RepairInfo", "Internet.12", "")
	$g_aLangRepairInfo[13] = _Localization_Load("RepairInfo", "Internet.13", "")

EndFunc