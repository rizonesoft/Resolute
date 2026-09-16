#include-once

#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										 ;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								 ;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


; #INDEX# =======================================================================================================================
; Title .........: Localization
; AutoIt Version : 3.3.15.0
; Language ......: English
; Description ...: Localization Functions.
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $LNG_COUNTABOUT = 23
Global Const $LNG_COUNTDONATE = 10
Global Const $LNG_COUNTFILE = 25
Global Const $LNG_COUNTLOGGING = 99
Global Const $LNG_COUNTMESSAGES = 50
Global Const $LNG_COUNTUPDATE = 12
Global Const $LNG_COUNTVERSIONING = 4
Global Const $LNG_COUNTBIOSINFO = 102
Global Const $LNG_COUNTBEEPINFO = 502
Global Const $LNG_COUNTCUSTOM = 102
Global Const $LNG_COUNTMENUS = 102
Global Const $LNG_COUNTMESSAGES2 = 202
Global Const $LNG_COUNTPREFERENCES = 102
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
If Not IsDeclared("g_sLanguageFile") Then Global $g_sLanguageFile
If Not IsDeclared("g_sCompanyName") Then Global $g_sCompanyName
If Not IsDeclared("g_sProgShortName") Then Global $g_sProgShortName
If Not IsDeclared("g_sProgShortName_X64") Then Global $g_sProgShortName_X64
If Not IsDeclared("g_sProgName") Then Global $g_sProgName
If Not IsDeclared("g_aLangAbout") Then Global $g_aLangAbout[$LNG_COUNTABOUT]
If Not IsDeclared("g_aLangDonate") Then Global $g_aLangDonate[$LNG_COUNTDONATE]
If Not IsDeclared("g_aLangFile") Then Global $g_aLangFile[$LNG_COUNTFILE]
If Not IsDeclared("g_aLangLogging") Then Global $g_aLangLogging[$LNG_COUNTLOGGING]
If Not IsDeclared("g_aLangMessages") Then Global $g_aLangMessages[$LNG_COUNTMESSAGES]
If Not IsDeclared("g_aLangUpdate") Then Global $g_aLangUpdate[$LNG_COUNTUPDATE]
If Not IsDeclared("g_aLangVersioning") Then Global $g_aLangVersioning[$LNG_COUNTVERSIONING]
If Not IsDeclared("g_aLangBIOSInfo") Then Global $g_aLangBIOSInfo[$LNG_COUNTBIOSINFO]
If Not IsDeclared("g_aLangBeepInfo") Then Global $g_aLangBeepInfo[$LNG_COUNTBEEPINFO]
If Not IsDeclared("g_sLanguageFile") Then Global $g_sLanguageFile
If Not IsDeclared("g_aLangCustom") Then Global $g_aLangCustom[$LNG_COUNTCUSTOM]
If Not IsDeclared("g_aLangMenus") Then Global $g_aLangMenus[$LNG_COUNTMENUS]
If Not IsDeclared("g_aLangMessages2") Then Global $g_aLangMessages2[$LNG_COUNTMESSAGES2]
If Not IsDeclared("g_aLangPreferences") Then Global $g_aLangPreferences[$LNG_COUNTMESSAGES2]
; ===============================================================================================================================

; Cache for replaced variables
Global $g_aLocalizationCache[1][3]  ; [key][section, original, replaced]
Global $g_iLocalizationCacheSize = 0
Global $g_sLocalizationCacheKey = ""
; #CURRENT# =====================================================================================================================
; ===============================================================================================================================


Func _Localization_About()

	;~ Check if the language strings is already loaded. Because we do not want to load the language strings twice.
	If StringLen($g_aLangAbout[0]) > 0 Then
		Return
	EndIf

	$g_aLangAbout[0]  = _Localization_Load("About", "Window_Title", "About %{Program.Name}")
	$g_aLangAbout[1]  = _Localization_Load("About", "Label_Version", "Version")
	$g_aLangAbout[2]  = _Localization_Load("About", "Label_AutoIt", "Build with AutoIt version")
	$g_aLangAbout[3]  = _Localization_Load("About", "Label_Copyright", "Copyright")
	$g_aLangAbout[4]  = _Localization_Load("About", "Tip_Title_Donate", "Donate")
	$g_aLangAbout[5]  = _Localization_Load("About", "Tip_Message_Donate", "Would you consider a small gift of $10 to help us\rnkeep the lights on and make quality free software? Click here to donate.")
	$g_aLangAbout[6]  = _Localization_Load("About", "Label_Home", "Homepage")
	$g_aLangAbout[7]  = _Localization_Load("About", "Label_License", "License")
	$g_aLangAbout[8]  = _Localization_Load("About", "Label_Support", "Get Support")
	$g_aLangAbout[9]  = _Localization_Load("About", "Tip_Title_Country", "Made in South Africa")
	$g_aLangAbout[10] = _Localization_Load("About", "Tip_Message_Country", "%{Program.Name} was born in South Africa.")
	$g_aLangAbout[11] = _Localization_Load("About", "Label_Contributors", "Contributors")
	$g_aLangAbout[12] = _Localization_Load("About", "Tip_Facebook", "Like us on Facebook.")
	$g_aLangAbout[13] = _Localization_Load("About", "Tip_GitHub", "%{Program.Name} on GitHub.")
	$g_aLangAbout[14] = _Localization_Load("About", "Button_Ok", "Ok")
	$g_aLangAbout[15] = _Localization_Load("About", "Label_RAM", "(RAM) %d MB FREE OF %d MB (%d%)")
	$g_aLangAbout[16] = _Localization_Load("About", "Label_HDD", "(%s) %.2f GB FREE OF %.2f GB (%d%)")

EndFunc   ;==>_Localization_About


Func _Localization_Donate()

	If StringLen($g_aLangDonate[0]) > 0 Then
		Return
	EndIf

	$g_aLangDonate[0] = _Localization_Load("Donate", "Label_Heading", "%{Program.Name} has been serving you for over %d hours. Now, how about a small donation?")
	$g_aLangDonate[1] = _Localization_Load("Donate", "Label_Message", "Click on the PayPal button below, choose an amount, and send us the donation. Your donation will be used to improve our software and keep everything free on Rizonesoft. A $20 donation will keep us going for at least a month.")
	$g_aLangDonate[2] = _Localization_Load("Donate", "Label_Donate", "Would you consider a small gift of $10 to help us improve %{Program.Name} and keep the lights on?")

EndFunc


Func _Localization_File()

	If StringLen($g_aLangFile[0]) > 0 Then
		Return
	EndIf

	$g_aLangFile[0]  = _Localization_Load("File", "Backup_Saving", "Saving '%s'.")
	$g_aLangFile[1]  = _Localization_Load("File", "Backup_Success", "The directory was successfully saved to '%s'.")
	$g_aLangFile[2]  = _Localization_Load("File", "Backup_Continue", "We will now continue with removing it.")
	$g_aLangFile[3]  = _Localization_Load("File", "Backup_Error_01", "'%s' could not be saved.")
	$g_aLangFile[4]  = _Localization_Load("File", "Backup_Error_02", "To avoid data loss, this directory will not be removed.")
	$g_aLangFile[5]  = _Localization_Load("File", "CleanDir_Clearing", "Clearing '%s'.")
	$g_aLangFile[6]  = _Localization_Load("File", "CleanDir_Error_01", "Directory Path")
	$g_aLangFile[7]  = _Localization_Load("File", "CleanDir_Error_02", "Nothing Here '%s'")
	$g_aLangFile[8]  = _Localization_Load("File", "CleanDir_Error_03", "'%s' could not be removed.")
	$g_aLangFile[9]  = _Localization_Load("File", "CleanDir_Attributes", "Setting attributes for '%s'.")
	$g_aLangFile[10] = _Localization_Load("File", "CleanDir_Success", "Successfully removed '%s'.")
	$g_aLangFile[11] = _Localization_Load("File", "Delete_Removing", "Removing '%s'.")
	$g_aLangFile[12] = _Localization_Load("File", "Delete_Success", "The file was successfully deleted.")
	$g_aLangFile[13] = _Localization_Load("File", "Delete_Error", "An error occurred whilst deleting the file.")
	$g_aLangFile[14] = _Localization_Load("File", "OpenText_Opening", "Opening '%s'")
	$g_aLangFile[15] = _Localization_Load("File", "OpenText_Success", "Showing '%s' file.")
	$g_aLangFile[16] = _Localization_Load("File", "OpenText_Error", "Could not find the '%s' file.")

EndFunc


Func _Localization_Logging()

	If StringLen($g_aLangLogging[0]) > 0 Then
		Return
	EndIf

	$g_aLangLogging[0]  = _Localization_Load("Logging", "Finished", "Finished")
	$g_aLangLogging[1]  = _Localization_Load("Logging", "success", "success")
	$g_aLangLogging[2]  = _Localization_Load("Logging", "Response_Received", "Response Received")
	$g_aLangLogging[3]  = _Localization_Load("Logging", "Successfully", "Successfully")
	$g_aLangLogging[4]  = _Localization_Load("Logging", "OK", "OK!")
	$g_aLangLogging[5]  = _Localization_Load("Logging", "Registration_succeeded", "Registration succeeded")
	$g_aLangLogging[6]  = _Localization_Load("Logging", "Initiated", "Initiated")
	$g_aLangLogging[7]  = _Localization_Load("Logging", "Error", "error")
	$g_aLangLogging[8]  = _Localization_Load("Logging", "Failed", "failed")
	$g_aLangLogging[9]  = _Localization_Load("Logging", "Access_Denied", "Access is denied")
	$g_aLangLogging[10] = _Localization_Load("Logging", "No_Operation_Performed", "No operation can be performed")
	$g_aLangLogging[11] = _Localization_Load("Logging", "VERSION", "VERSION")
	$g_aLangLogging[12] = _Localization_Load("Logging", "File_Not_Found", "Could not find the '%s' log File")
	$g_aLangLogging[13] = _Localization_Load("Logging", "Showing_File", "Showing '%s' log File.")
	$g_aLangLogging[14] = _Localization_Load("Logging", "Showing_Error", "Something went wrong: Process ID: %s")
	$g_aLangLogging[15] = _Localization_Load("Logging", "Opening_File", "Opening the log File")
	$g_aLangLogging[16] = _Localization_Load("Logging", "Opening_Directory", "Opening the log Folder...")
	$g_aLangLogging[17] = _Localization_Load("Logging", "Directory_Not_Found", "Could not find the '%s' log Directory")
	$g_aLangLogging[18] = _Localization_Load("Logging", "Showing_Directory", "Showing '%s' log Directory")
	$g_aLangLogging[19] = _Localization_Load("Logging", "Bool_Yes", "Yes")
	$g_aLangLogging[20] = _Localization_Load("Logging", "Bool_No", "No")
	$g_aLangLogging[21] = _Localization_Load("Logging", "Info_Date", "Date:")
	$g_aLangLogging[22] = _Localization_Load("Logging", "Info_Program", "Program:")
	$g_aLangLogging[23] = _Localization_Load("Logging", "Info_Program_Path", "Program Path:")
	$g_aLangLogging[24] = _Localization_Load("Logging", "Info_Compiled", "Compiled:")
	$g_aLangLogging[25] = _Localization_Load("Logging", "Info_AutoIt_Version", "AutoIt Version:")
	$g_aLangLogging[26] = _Localization_Load("Logging", "Info_AutoIt_64Bit", "AutoIt 64-Bit Version:")
	$g_aLangLogging[27] = _Localization_Load("Logging", "Info_Windows_Version", "Windows Version:")
	$g_aLangLogging[28] = _Localization_Load("Logging", "Info_System_Type", "System Type:")
	$g_aLangLogging[29] = _Localization_Load("Logging", "Info_Memory", "Memory (RAM):")
	$g_aLangLogging[30] = _Localization_Load("Logging", "Info_ProgramFiles", "Program Files Directory:")
	$g_aLangLogging[31] = _Localization_Load("Logging", "Info_Windows_Directory", "Windows Directory:")
	$g_aLangLogging[32] = _Localization_Load("Logging", "Level_Error", "Error:")
	$g_aLangLogging[33] = _Localization_Load("Logging", "Level_Warning", "Warning:")
	$g_aLangLogging[34] = _Localization_Load("Logging", "Level_Success", "Success:")
	$g_aLangLogging[35] = _Localization_Load("Logging", "Level_Finished", "Finished:")
	$g_aLangLogging[36] = _Localization_Load("Logging", "Level_Clean", "Clean:")

EndFunc


Func _Localization_Messages()

	If StringLen($g_aLangMessages[0]) > 0 Then
		Return
	EndIf

	$g_aLangMessages[0]  = _Localization_Load("Messages", "Info_Title", "Please Take Note")
	$g_aLangMessages[1]  = _Localization_Load("Messages", "Warning_Title", "Warning!")
	$g_aLangMessages[2]  = _Localization_Load("Messages", "Error_Title", "Oops! Something went wrong!")
	$g_aLangMessages[3]  = _Localization_Load("Messages", "Error_Oops", "Oops!")
	$g_aLangMessages[4]  = _Localization_Load("Messages", "Singleton", "Another occurence of %{Program.Name} is already running.")
	$g_aLangMessages[5]  = _Localization_Load("Messages", "Compatible", "%{Program.Name} is not compatable with your version of windows. If you believe this to be an error, please feel free to leave a message at '%s' with all the details.")
	$g_aLangMessages[6]  = _Localization_Load("Messages", "Compatible_Bit", "Unfortuantely %{Program.Name} 32 Bit is not compatible with your Windows version. Please download %{Program.Name} 64 Bit from '%s'")
	$g_aLangMessages[7]  = _Localization_Load("Messages", "Loading_Initializing", "Initializing %{Program.Name}")
	$g_aLangMessages[8]  = _Localization_Load("Messages", "Loading_Localizations", "Loading Localizations")
	$g_aLangMessages[9]  = _Localization_Load("Messages", "Loading_Resources", "Setting Resources")
	$g_aLangMessages[10] = _Localization_Load("Messages", "Loading_WorkingDirectories", "Setting Working Directories")
	$g_aLangMessages[11] = _Localization_Load("Messages", "Loading_Configuration", "Loading Configuration")
	$g_aLangMessages[12] = _Localization_Load("Messages", "Loading_Logging", "Initializing Logging")
	$g_aLangMessages[13] = _Localization_Load("Messages", "Loading_Shortcuts", "Setting Keyboard Shortcuts")
	$g_aLangMessages[14] = _Localization_Load("Messages", "Loading_Interface", "Starting Core Interface")
	$g_aLangMessages[15] = _Localization_Load("Messages", "Ping_Check_Connection", "Checking Internet Connection.")
	$g_aLangMessages[16] = _Localization_Load("Messages", "Ping_Response", "Response Received in %s milliseconds.")
	$g_aLangMessages[17] = _Localization_Load("Messages", "Ping_Host_Offline", "Host is Offline.")
	$g_aLangMessages[18] = _Localization_Load("Messages", "Ping_Host_Unreachable", "Host is Unreachable.")
	$g_aLangMessages[19] = _Localization_Load("Messages", "Ping_Host_Bad", "Bad Destination.")
	$g_aLangMessages[20] = _Localization_Load("Messages", "Ping_Host_No_Internet", "No Internet Connection.")
	$g_aLangMessages[21] = _Localization_Load("Messages", "Global_Errors", "Finished with (%02i) %s!")
	$g_aLangMessages[22] = _Localization_Load("Messages", "Global_Errors_Error", "error")
	$g_aLangMessages[23] = _Localization_Load("Messages", "Global_Errors_Errors", "errors")
	$g_aLangMessages[24] = _Localization_Load("Messages", "Global_Finished", "Completed selected task.")
	$g_aLangMessages[25] = _Localization_Load("Messages", "Global_File", "file")
	$g_aLangMessages[26] = _Localization_Load("Messages", "Global_Files", "files")
	$g_aLangMessages[27] = _Localization_Load("Messages", "RegisterDll_Success", "RegSvr32.exe > '%s' registration succeeded.")
	$g_aLangMessages[28] = _Localization_Load("Messages", "RegisterDll_Error_01", "RegSvr32.exe > '%s' To register a module, you must provide a binary name.")
	$g_aLangMessages[29] = _Localization_Load("Messages", "RegisterDll_Error_02", "RegSvr32.exe > '%s' Specified module not found.")
	$g_aLangMessages[30] = _Localization_Load("Messages", "RegisterDll_Error_03", "RegSvr32.exe > '%s' Module loaded but entry-point DllRegisterServer was not found.")
	$g_aLangMessages[31] = _Localization_Load("Messages", "RegisterDll_Error_04", "RegSvr32.exe > '%s' Error number: 0x80070005")
	$g_aLangMessages[32] = _Localization_Load("Messages", "Registry_Write_Error", "Could not write to '%s'")
	$g_aLangMessages[33] = _Localization_Load("Messages", "Registry_Error_01", "Unable to open requested key.")
	$g_aLangMessages[34] = _Localization_Load("Messages", "Registry_Error_02", "Unable to open requested main key.")
	$g_aLangMessages[35] = _Localization_Load("Messages", "Registry_Error_03", "Unable to open requested value.")
	$g_aLangMessages[36] = _Localization_Load("Messages", "Registry_Error_04", "Value type not supported.")
	$g_aLangMessages[37] = _Localization_Load("Messages", "Registry_Error_05", "Unable to delete requested value.")
	$g_aLangMessages[38] = _Localization_Load("Messages", "Registry_Error_06", "Unable to delete requested key/value.")

EndFunc


Func _Localization_Update()

	If StringLen($g_aLangUpdate[0]) > 0 Then
		Return
	EndIf

	$g_aLangUpdate[0]  = _Localization_Load("Update", "Window_Title_Available", "Update available")
	$g_aLangUpdate[1]  = _Localization_Load("Update", "Window_Title_Congratulations", "Congratulations")
	$g_aLangUpdate[2]  = _Localization_Load("Update", "Window_Title_Error", "Something went wrong!")
	$g_aLangUpdate[3]  = _Localization_Load("Update", "Label_Message_Update", "There is a new version of '%{Program.Name}' available.")
	$g_aLangUpdate[4]  = _Localization_Load("Update", "Label_Message_Latest", "You are using the latest version of '%{Program.Name}'.")
	$g_aLangUpdate[5]  = _Localization_Load("Update", "Label_Message_Error", "Information about the latest version of '%{Program.Name}' could not be retrieved.")
	$g_aLangUpdate[6]  = _Localization_Load("Update", "Label_Message_Internet", "Please check your Internet Connection and try again.")
	$g_aLangUpdate[7]  = _Localization_Load("Update", "Label_Build_Current", "Current Build:")
	$g_aLangUpdate[8]  = _Localization_Load("Update", "Label_Build_Update", "Update Build:")
	$g_aLangUpdate[9]  = _Localization_Load("Update", "CheckBox_NoUpdate", "Do not check for updates at startup.")
	$g_aLangUpdate[10] = _Localization_Load("Update", "Button_Update", "Read more")
	$g_aLangUpdate[11] = _Localization_Load("Update", "Button_Close", "Close")

EndFunc   ;==>_Localization_Update


Func _Localization_Versioning()

	If StringLen($g_aLangVersioning[0]) > 0 Then
		Return
	EndIf

	$g_aLangVersioning[0] = _Localization_Load("Versioning", "Administrator", "Administrator")
	$g_aLangVersioning[1] = _Localization_Load("Versioning", "Build", "Build")
	$g_aLangVersioning[2] = _Localization_Load("Versioning", "AutoIt_Version", "using AutoIt version %{AutoIt.Version}")
	$g_aLangVersioning[3] = _Localization_Load("Versioning", "Bit", "Bit")

EndFunc   ;==>_Localization_Versioning


Func _Localization_BIOSInformation()

	;~ Check if the language strings is already loaded. Because we do not want to load the language strings twice.
	If StringLen($g_aLangBIOSInfo[0]) > 0 Then
		Return
	EndIf

	$g_aLangBIOSInfo[0]   = _Localization_Load("BIOSInformation", "CheckBox_Motherboard", "Motherboard")
	$g_aLangBIOSInfo[1]   = _Localization_Load("BIOSInformation", "CheckBox_BIOS", "BIOS")
	$g_aLangBIOSInfo[2]   = _Localization_Load("BIOSInformation", "CheckBox_Characteristics", "Characteristics")
	$g_aLangBIOSInfo[3]   = _Localization_Load("BIOSInformation", "List_Column_Description", "Description")
	$g_aLangBIOSInfo[4]   = _Localization_Load("BIOSInformation", "List_Column_Data", "Data")
	$g_aLangBIOSInfo[5]   = _Localization_Load("BIOSInformation", "ListInfo_Motherboard_01", "Manufacturer")
	$g_aLangBIOSInfo[6]   = _Localization_Load("BIOSInformation", "ListInfo_Motherboard_02", "Product")
	$g_aLangBIOSInfo[7]   = _Localization_Load("BIOSInformation", "ListInfo_Motherboard_03", "Version")
	$g_aLangBIOSInfo[8]   = _Localization_Load("BIOSInformation", "ListInfo_Motherboard_04", "Serial Number")
	$g_aLangBIOSInfo[9]   = _Localization_Load("BIOSInformation", "ListInfo_BIOS_01", "BIOS Vendor")
	$g_aLangBIOSInfo[10]  = _Localization_Load("BIOSInformation", "ListInfo_BIOS_02", "Serial Number")
	$g_aLangBIOSInfo[11]  = _Localization_Load("BIOSInformation", "ListInfo_BIOS_03", "BIOS Version")
	$g_aLangBIOSInfo[12]  = _Localization_Load("BIOSInformation", "ListInfo_BIOS_04", "BIOS Date")
	$g_aLangBIOSInfo[13]  = _Localization_Load("BIOSInformation", "ListInfo_BIOS_05", "BIOS Release Version")
	$g_aLangBIOSInfo[14]  = _Localization_Load("BIOSInformation", "ListInfo_BIOS_06", "DMI Version")
	$g_aLangBIOSInfo[15]  = _Localization_Load("BIOSInformation", "ListInfo_BIOS_07", "Embedded Controller Version")
	$g_aLangBIOSInfo[16]  = _Localization_Load("BIOSInformation", "ListInfo_BIOS_08", "Status")
	$g_aLangBIOSInfo[17]  = _Localization_Load("BIOSInformation", "ListInfo_BIOS_09", "Primary BIOS")
	$g_aLangBIOSInfo[18]  = _Localization_Load("BIOSInformation", "ListInfo_BIOS_10", "Software Element ID")
	$g_aLangBIOSInfo[19]  = _Localization_Load("BIOSInformation", "ListInfo_BIOS_11", "Software Element State")
	$g_aLangBIOSInfo[21]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_01", "Supports ISA")
	$g_aLangBIOSInfo[22]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_02", "Supports MCA")
	$g_aLangBIOSInfo[23]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_03", "Supports EISA")
	$g_aLangBIOSInfo[24]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_04", "Supports PCI")
	$g_aLangBIOSInfo[25]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_05", "Supports PC Card (PCMCIA)")
	$g_aLangBIOSInfo[26]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_06", "Supports Plug and Play")
	$g_aLangBIOSInfo[27]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_07", "Supports APM")
	$g_aLangBIOSInfo[28]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_08", "Upgradeable (Flash) BIOS")
	$g_aLangBIOSInfo[29]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_09", "Allows BIOS shadowing")
	$g_aLangBIOSInfo[30]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_10", "Supports VL-VESA")
	$g_aLangBIOSInfo[31]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_11", "ESCD support is available")
	$g_aLangBIOSInfo[32]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_12", "Supports booting from CD-ROM")
	$g_aLangBIOSInfo[33]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_13", "Supports selectable boot")
	$g_aLangBIOSInfo[34]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_14", "BIOS ROM is socketed")
	$g_aLangBIOSInfo[35]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_15", "Supports booting from PC Card (PCMCIA)")
	$g_aLangBIOSInfo[36]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_16", "Supports EDD (Enhanced Disk Drive) Specification")
	$g_aLangBIOSInfo[37]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_17", "Supports Int 13h - Japanese Floppy for NEC 9800 1.2mb (3.5" & Chr(34) & ", 1k Bytes/Sector, 360 RPM)")
	$g_aLangBIOSInfo[38]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_18", "Supports Int 13h - Japanese Floppy for Toshiba 1.2mb (3.5" & Chr(34) & ", 360 RPM)")
	$g_aLangBIOSInfo[39]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_19", "Supports Int 13h - 5.25" & Chr(34) & " / 360 KB Floppy Services")
	$g_aLangBIOSInfo[40]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_20", "Supports Int 13h - 5.25" & Chr(34) & " / 1.2MB Floppy Services")
	$g_aLangBIOSInfo[41]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_21", "Supports Int 13h - 3.5" & Chr(34) & " / 720 KB Floppy Services")
	$g_aLangBIOSInfo[42]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_22", "Supports Int 13h - 3.5" & Chr(34) & " / 2.88 MB Floppy Services")
	$g_aLangBIOSInfo[43]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_23", "Supports Int 5h, Print Screen Service")
	$g_aLangBIOSInfo[44]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_24", "Supports Int 9h, 8042 Keyboard services")
	$g_aLangBIOSInfo[45]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_25", "Supports Int 14h, Serial Services")
	$g_aLangBIOSInfo[46]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_26", "Supports Int 17h, printer services")
	$g_aLangBIOSInfo[47]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_27", "Supports Int 10h, CGA/Mono Video Services")
	$g_aLangBIOSInfo[48]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_28", "NEC PC-98")
	$g_aLangBIOSInfo[49]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_29", "Supports ACPI")
	$g_aLangBIOSInfo[50]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_30", "Supports USB Legacy")
	$g_aLangBIOSInfo[51]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_31", "Supports AGP")
	$g_aLangBIOSInfo[52]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_32", "Supports I2O boot")
	$g_aLangBIOSInfo[53]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_33", "Supports LS-120 boot")
	$g_aLangBIOSInfo[54]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_34", "Supports ATAPI ZIP Drive boot")
	$g_aLangBIOSInfo[55]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_35", "Supports 1394 boot")
	$g_aLangBIOSInfo[56]  = _Localization_Load("BIOSInformation", "ListInfo_Characteristics_36", "Supports Smart Battery")

EndFunc


Func _Localization_BeepInformation()

	;~ Check if the language strings is already loaded. Because we do not want to load the language strings twice.
	If StringLen($g_aLangBeepInfo[0]) > 0 Then
		Return
	EndIf

	$g_aLangBeepInfo[0]    = _Localization_Load("BeepInformation", "Default_00", "The computer POST (Power On Self Test) tests the computer, insuring that it meets the necessary system requirements and that all hardware is working properly before starting the remainder of the boot process. If the computer passes the POST, the computer will have a single beep (with some computer BIOS manufacturers it may beep twice) as the computer starts and it will continue to start normally. However, if the computer fails the POST, the computer will either not beep at all or will generate a beep code, which tells the user the source of the problem." & _
																				 "\rn\rnEach time the computer boots up, it must past the POST. If it does not pass, your computer will receive an irregular POST. An irregular POST is a beep code that is different from the standard one or two beeps. This could either be no beeps at all or a combination of different beeps indicating what is causing the problem. You can try the following to resolve an irregular POST:")
	$g_aLangBeepInfo[1]    = _Localization_Load("BeepInformation", "Default_01", "(1) If any new hardware has been recently added to the computer, remove that hardware to make sure it is not the causing the issue. If after removing the new hardware and your computer works, it's likely that the computer is either not compatible with the new hardware device or a system setting needs to be changed to work with the new hardware." & _
																				 "\rn\rn(2) Remove any disks, CD's, DVD's that are in the computer and if any USB devices are connected disconnect all of them. Reboot the computer and see if anything changes." & _
																				 "\rn\rn(3) Make sure all fans are running in the computer. If a fan has failed (especially the heat sink fan for the CPU) your computer could be overheating and/or detecting the fan failure causing the computer not to boot." & _
																				 "\rn\rn(4) If the above recommendations still have not resolved the irregular POST, attempt to disconnect the Riser board (if applicable) and/or each of the expansion cards. If this resolves the issue or allows the computer to POST, connect one card at a time until you determine what card is causing the issue." & _
																				 "\rn\rn(5) Disconnect the IDE, SATA, SCSI, or other data cables of the CD-ROM, hard drive, and floppy drive from the Motherboard. If this resolves your irregular POST or you now get an error message attempt to re-connect each device one at a time to determine which device and/or cable is causing the issue. In some situations it can simply be a loose cable connection." & _
																				 "\rn\rn(6) In some situations a computer may have power related issues often caused by either the power supply and/or the Motherboard. To help determine if this is the cause of your issue try turning the computer on, off, and back on as fast as possible, making sure the computer power light goes on and off each time. In some situations you may be able to temporarily get the computer to boot." & _
																				 "\rn\rn(7) For users who are more comfortable working with the inside of their computer or who have built their computer, one last recommendation before assuming hardware is faulty, is to reseat the CPU by removing it and putting it back into the computer." & _
																				 "\rn\rnIf after doing all of the above, you continue to have the same issue, unfortunately it is likely that you have a faulty Motherboard, PSU, CPU, and/or RAM. The next step would be either to replace these components and/or have the computer serviced. If you plan on doing the repairs yourself or you are a repair shop it is suggested that you replace the Motherboard first, RAM, CPU, and then power supply in that order and/or try swappable parts from other computers.")
	$g_aLangBeepInfo[2]    = _Localization_Load("BeepInformation", "Default_02", "(1) If you've recently added or tried to add additional memory to the computer and have started getting these beeps. " & _
																				 "\rn\rn(2) Sometimes when the computer is moved and/or over time a memory stick can become loose causing the computer to be unable to read the memory or get errors as it's reading it. Try fixing this issue by opening the computer removing each of the memory sticks you have in the computer and then placing them back into the computer." & _
																				 "\rn\rn(3) If reseating the memory did not resolve the issue try swapping the location of the memory. If you have only one stick of memory in the computer try moving it to another slot and then boot the computer. If you have more than one stick of memory try removing all but one stick of memory and boot the computer. If this does not resolve the issue try removing that stick of memory and try one of the other sticks of memory." & _
																				 "\rn\rn(4) If you have access to another computer that uses the same type of memory try using its known good memory in your computer. If another computers memory works you know that you have faulty memory. If another computers memory does not work and it is compatible with your computer, unfortunately your motherboard and/or the slots on the motherboard are defective causing it to be unable to properly read the memory, which means the motherboard will have to be replaced.")
	$g_aLangBeepInfo[3]    = _Localization_Load("BeepInformation", "Default_03", "(1) Verify that the keyboard is connected properly to the computer by turning off your computer and then disconnecting and reconnecting the keyboard to the computer." & _
																				 "\rn\rn(2) Ensure that there are no stuck keys on the keyboard. If all keys appear to be ok and you have a standard desktop computer with keyboard, attempt to turn keyboard over and gently hit the back of the keyboard to loosen any dirt or hair that may be stuck in the keyboard." & _
																				 "\rn\rn(3) Try another keyboard on the computer to verify that the keyboard has not gone bad." & _
																				 "\rn\rnIf all of the above solutions are not able to resolve your issue it is likely that the port on the back of the computer may be bad and the Motherboard or I/O board may need to be replaced.")
	$g_aLangBeepInfo[4]    = _Localization_Load("BeepInformation", "Default_04", "If your computer is losing its time or date settings, or you are receiving a message CMOS Read Error, CMOS checksum error, or CMOS Battery Failure, first attempt to leave the computer on for 24 hours. In some cases this can charge the battery and resolve your issue. This often resolves CMOS battery related issues when a computer has been left off for several months. If this does not resolve your issue follow the steps below." & _
																				 "\rn\rn(1) Open the computer case and find the battery on the computer motherboard, verify that it will be accessible and that it can be removed. Most computers today use a coin cell CMOS battery.  If you are unable to locate your CMOS battery you will need to refer to your motherboard or computer documentation and/or contact your computer manufacturer for additional assistance in locating it." & _
																				 "\rn\rn(2) Unfortunately, most manufacturers will not list the exact type and model of your CMOS battery; therefore, once you have located the battery, write down all information about the battery (Voltage, chemistry, wiring, and packaging). If possible, remove the battery and take it to the location you plan on purchasing a new battery from." & _
																				 "\rn\rn(3) If you're computer is using a coin cell battery. Removing the battery is relatively simple. Simply use your fingers to grab on the edge of the battery and pull it up and out of the container holding it. Some motherboards have a clip holding the battery down. If your computer has this clip you may need to use one had to move the clip up and the other hand to pull the battery out. Unfortunately, not all CMOS batteries are removable; some manufactures will only allow a replacement battery to be added. If you're not using a coin cell battery and are not able to determine how to remove it refer to your motherboard or computer documentation and/or contact your computer manufacturer for additional assistance in removing the battery or how to insert a new replacement battery." & _
																				 "\rn\rn(4) Once you have purchased a new battery, remove the old battery (as instructed above) and replace it with the new battery." )
	$g_aLangBeepInfo[5]    = _Localization_Load("BeepInformation", "Default_05", "(1) Verify that the power connection is connected properly to the wall and the back of the computer. If the connections appear to be connected properly, attempt to disconnect and reconnection both ends of the cable. If you have a power strip (surge protector) or switch used to turn everything on at once, temporarily disconnect the computer from that switch and connect that cable directly to the wall. This will help verify that the strip or switch is not bad. Verify that the outlet works by connecting a different component to that switch." & _
																				 "\rn\rn(2) If additional hardware has been recently added to the computer it is recommend that you temporarily disconnect that device or devices from the computer to verify they are not preventing your computer from turning on." & _
																				 "\rn\rn(3) Verify that the cable supplying your computer is not bad or damaged by using another power cable. If you have a standard CRT monitor, this cable can be used in place of the computer power cable. If you have a portable computer or laptop, when the cables are plugged into the laptop you should see a power light or battery charge light. If this light is seen, this is a good indication that the power cable is good." & _
																				 "\rn\rn(4) If you are building your own computer or if the computer has never turned on since you purchased it, it is possible you are using a power supply that does not supply enough power and/or the incorrect type of power supply. Verify your power supply meets the requirements of your motherboard and processor." & _
																				 "\rn\rnIf, after following the above sections, your computer still receives no power, it is likely that a hardware component in the computer has failed. It is most likely that the power supply has failed. If you do not plan on replacing the power supply yourself or if you have a portable computer, we recommend having the computer serviced by your computer manufacturer or a local computer repair shop.")
	$g_aLangBeepInfo[6]    = _Localization_Load("BeepInformation", "List_AMI_01", "1 Short Beep")
	$g_aLangBeepInfo[7]    = _Localization_Load("BeepInformation", "List_AMI_02", "2 Short Beeps")
	$g_aLangBeepInfo[8]    = _Localization_Load("BeepInformation", "List_AMI_03", "3 Short Beeps")
	$g_aLangBeepInfo[9]    = _Localization_Load("BeepInformation", "List_AMI_04", "4 Short Beeps")
	$g_aLangBeepInfo[10]   = _Localization_Load("BeepInformation", "List_AMI_05", "5 Short Beeps")
	$g_aLangBeepInfo[11]   = _Localization_Load("BeepInformation", "List_AMI_06", "6 Short Beeps")
	$g_aLangBeepInfo[12]   = _Localization_Load("BeepInformation", "List_AMI_07", "7 Short Beeps")
	$g_aLangBeepInfo[13]   = _Localization_Load("BeepInformation", "List_AMI_08", "8 Short Beeps")
	$g_aLangBeepInfo[14]   = _Localization_Load("BeepInformation", "List_AMI_09", "9 Short Beeps")
	$g_aLangBeepInfo[15]   = _Localization_Load("BeepInformation", "List_AMI_10", "10 Short Beeps")
	$g_aLangBeepInfo[16]   = _Localization_Load("BeepInformation", "List_AMI_11", "11 Short Beeps")
	$g_aLangBeepInfo[17]   = _Localization_Load("BeepInformation", "List_AMI_12", "1 Long, 2 Short Beeps")
	$g_aLangBeepInfo[18]   = _Localization_Load("BeepInformation", "List_AMI_13", "1 Long, 3 Short Beeps")
	$g_aLangBeepInfo[19]   = _Localization_Load("BeepInformation", "List_AMI_14", "1 Long, 8 Short Beeps")
	$g_aLangBeepInfo[20]   = _Localization_Load("BeepInformation", "List_AMI_15", "1 Long Beep")
	$g_aLangBeepInfo[21]   = _Localization_Load("BeepInformation", "List_AMI_Info_01", "DRAM refresh failure - The programmable interrupt timer or programmable interrupt controller has probably failed. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[22]   = _Localization_Load("BeepInformation", "List_AMI_Info_02", "Parity circuit failure - A memory parity error has occurred in the first 64K of RAM. The RAM IC is probably bad. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[23]   = _Localization_Load("BeepInformation", "List_AMI_Info_03", "Base 64K RAM failure - A memory failure has occurred in the first 64K of RAM. The RAM IC is probably bad. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[24]   = _Localization_Load("BeepInformation", "List_AMI_Info_04", "System timer failure - The system clock/timer IC has failed or there is a memory error in the first bank of memory. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[25]   = _Localization_Load("BeepInformation", "List_AMI_Info_05", "Process failure - The system CPU has failed. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[26]   = _Localization_Load("BeepInformation", "List_AMI_Info_06", "Keyboard controller Gate A20 error - The keyboard controller IC has failed, which is not allowing Gate A20 to switch the processor to protected mode. Replace the keyboard controller or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[27]   = _Localization_Load("BeepInformation", "List_AMI_Info_07", "Virtual mode exception error - The CPU has generated an exception error because of a fault in the CPU or motherboard circuitry. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[28]   = _Localization_Load("BeepInformation", "List_AMI_Info_08", "Display memory Read/Write test failure - The system video adapter is missing or defective. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[29]   = _Localization_Load("BeepInformation", "List_AMI_Info_09", "ROM BIOS checksum failure - The contents of the system BIOS ROM does not match the expected checksum value. The BIOS ROM is probably defective and should be replaced or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[30]   = _Localization_Load("BeepInformation", "List_AMI_Info_10", "CMOS shutdown Read/Write error - The shutdown for the CMOS has failed. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[31]   = _Localization_Load("BeepInformation", "List_AMI_Info_11", "Cache Memory error - The L2 cache is faulty. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[32]   = _Localization_Load("BeepInformation", "List_AMI_Info_12", "Failure in video system - An error was encountered in the video BIOS ROM, or a horizontal retrace failure has been encountered. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[33]   = _Localization_Load("BeepInformation", "List_AMI_Info_13", "Conventional/Extended memory failure - A fault has been detected in memory above 64KB. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[34]   = _Localization_Load("BeepInformation", "List_AMI_Info_14", "Display/Retrace test failed - The video adapter is either missing or defective. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[35]   = _Localization_Load("BeepInformation", "List_AMI_Info_15", "POST has passed all tests - System is booting properly. Everything should be OK and your computer should continue booting.")
	$g_aLangBeepInfo[36]   = _Localization_Load("BeepInformation", "List_AST_01", "1 Short Beep")
	$g_aLangBeepInfo[37]   = _Localization_Load("BeepInformation", "List_AST_02", "2 Short Beeps")
	$g_aLangBeepInfo[38]   = _Localization_Load("BeepInformation", "List_AST_03", "3 Short Beeps")
	$g_aLangBeepInfo[39]   = _Localization_Load("BeepInformation", "List_AST_04", "4 Short Beeps")
	$g_aLangBeepInfo[40]   = _Localization_Load("BeepInformation", "List_AST_05", "5 Short Beeps")
	$g_aLangBeepInfo[41]   = _Localization_Load("BeepInformation", "List_AST_06", "6 Short Beeps")
	$g_aLangBeepInfo[42]   = _Localization_Load("BeepInformation", "List_AST_07", "9 Short Beeps")
	$g_aLangBeepInfo[43]   = _Localization_Load("BeepInformation", "List_AST_08", "10 Short Beeps")
	$g_aLangBeepInfo[44]   = _Localization_Load("BeepInformation", "List_AST_09", "11 Short Beeps")
	$g_aLangBeepInfo[45]   = _Localization_Load("BeepInformation", "List_AST_10", "12 Short Beeps")
	$g_aLangBeepInfo[46]   = _Localization_Load("BeepInformation", "List_AST_11", "1 Long, 1 Short Beep")
	$g_aLangBeepInfo[47]   = _Localization_Load("BeepInformation", "List_AST_12", "1 Long, 2 Short Beeps")
	$g_aLangBeepInfo[48]   = _Localization_Load("BeepInformation", "List_AST_13", "1 Long, 3 Short Beeps")
	$g_aLangBeepInfo[49]   = _Localization_Load("BeepInformation", "List_AST_14", "1 Long, 4 Short Beeps")
	$g_aLangBeepInfo[50]   = _Localization_Load("BeepInformation", "List_AST_15", "1 Long, 5 Short Beeps")
	$g_aLangBeepInfo[51]   = _Localization_Load("BeepInformation", "List_AST_16", "1 Long, 6 Short Beeps")
	$g_aLangBeepInfo[52]   = _Localization_Load("BeepInformation", "List_AST_17", "1 Long, 7 Short Beeps")
	$g_aLangBeepInfo[53]   = _Localization_Load("BeepInformation", "List_AST_18", "1 Long, 8 Short Beeps")
	$g_aLangBeepInfo[54]   = _Localization_Load("BeepInformation", "List_AST_19", "1 Long Beep")
	$g_aLangBeepInfo[55]   = _Localization_Load("BeepInformation", "List_AST_Info_01", "CPU register test failure - The CPU has failed. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[56]   = _Localization_Load("BeepInformation", "List_AST_Info_02", "Keyboard controller buffer failure - The keyboard controller has failed. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[57]   = _Localization_Load("BeepInformation", "List_AST_Info_03", "Keyboard controller reset failure - The keyboard controller has failed or the motherboard circuitry is faulty. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[58]   = _Localization_Load("BeepInformation", "List_AST_Info_04", "Keyboard communication failure - Either the keyboard controller IC or the associated circuitry has failed. Replace the keyboard first, then if it is still faulty, replace the keyboard controller IC or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[59]   = _Localization_Load("BeepInformation", "List_AST_Info_05", "Keyboard input failure - The keyboard controller IC has failed. Replace the IC or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[60]   = _Localization_Load("BeepInformation", "List_AST_Info_06", "System board chipset failure - The chipset on the motherboard has failed. motherboard or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[61]   = _Localization_Load("BeepInformation", "List_AST_Info_07", "BIOS ROM checksum error - The BIOS ROM has failed. If possible, replace the BIOS on the motherboard or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[62]   = _Localization_Load("BeepInformation", "List_AST_Info_08", "System timer test failure - The system clock IC has failed.")
	$g_aLangBeepInfo[63]   = _Localization_Load("BeepInformation", "List_AST_Info_09", "ASIC failure - Motherboard circuitry has failed. Replace the motherboard or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[64]   = _Localization_Load("BeepInformation", "List_AST_Info_10", "CMOS RAM shutdown register failure - The real time clock/CMOS IC failed. Replace the CMOS or motherboard. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[65]   = _Localization_Load("BeepInformation", "List_AST_Info_11", "DMA controller 1 failure - The DMA controller IC for channel 1 has failed. If possible, replace the IC or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[66]   = _Localization_Load("BeepInformation", "List_AST_Info_12", "Video vertical retrace failure - The video adapter has probably failed. Replace the video adapter or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[67]   = _Localization_Load("BeepInformation", "List_AST_Info_13", "Video memory test failure - The video adapter's memory has failed. Replace the video adapter or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[68]   = _Localization_Load("BeepInformation", "List_AST_Info_14", "Video adapter failure - The video adapter has failed. Replace the video adapter or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[69]   = _Localization_Load("BeepInformation", "List_AST_Info_15", "64KB memory failure - A failure has occurred in the base 64KB of memory. If possible, replace the RAM IC or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[70]   = _Localization_Load("BeepInformation", "List_AST_Info_16", "Unable to load interrupt vectors - The BIOS was unable to load the interrupt vectors into memory. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[71]   = _Localization_Load("BeepInformation", "List_AST_Info_17", "Unable to initialize video - This a video problem. Replace the video adapter first. If problem is still present, replace the motherboard or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[72]   = _Localization_Load("BeepInformation", "List_AST_Info_18", "Video memory failure - The is a failure in the video memory. Replace the video adapter first. If problem is still present, replace the motherboard or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[73]   = _Localization_Load("BeepInformation", "List_AST_Info_19", "DMA controller 0 failure - The DMA controller IC for channel 0 has failed. If possible, replace the IC or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[74]   = _Localization_Load("BeepInformation", "List_Award_01", "1 Long, 2 Short Beeps")
	$g_aLangBeepInfo[75]   = _Localization_Load("BeepInformation", "List_Award_02", "1 Long, 3 Short Beeps")
	$g_aLangBeepInfo[76]   = _Localization_Load("BeepInformation", "List_Award_03", "Repeating (Endless Loop)")
	$g_aLangBeepInfo[77]   = _Localization_Load("BeepInformation", "List_Award_04", "High Frequency Beeps")
	$g_aLangBeepInfo[78]   = _Localization_Load("BeepInformation", "List_Award_05", "Repeating High/Low")
	$g_aLangBeepInfo[79]   = _Localization_Load("BeepInformation", "List_Award_Info_01", "Video adapter error - Indicates a video error has occurred and the BIOS cannot initialize the video screen to display any additional information. Either the video adapter is bad or is not seated properly. Also, check to ensure the monitor cable is connected properly or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[80]   = _Localization_Load("BeepInformation", "List_Award_Info_02", "No video card or bad video RAM - Reseat or replace the video card. Alternatively, try the steps below to resolve your issue:")
	$g_aLangBeepInfo[81]   = _Localization_Load("BeepInformation", "List_Award_Info_03", "Memory error - Check for improperly seated or missing memory. Alternatively, try the steps below to resolve your issue:")
	$g_aLangBeepInfo[82]   = _Localization_Load("BeepInformation", "List_Award_Info_04", "Overheated CPU - Check the CPU fan for proper operation. Check the case for proper air flow or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[83]   = _Localization_Load("BeepInformation", "List_Award_Info_05", "CPU - Either the CPU is not seated properly or the CPU is damaged. May also be due to excess heat. Check the CPU fan or BIOS settings for proper fan speed. Alternatively, try the steps below to resolve your issue:")
	$g_aLangBeepInfo[84]   = _Localization_Load("BeepInformation", "List_Compaq_01", "1 Short Beep")
	$g_aLangBeepInfo[85]   = _Localization_Load("BeepInformation", "List_Compaq_02", "1 Long, 1 Short Beep")
	$g_aLangBeepInfo[86]   = _Localization_Load("BeepInformation", "List_Compaq_03", "2 Short Beeps")
	$g_aLangBeepInfo[87]   = _Localization_Load("BeepInformation", "List_Compaq_04", "1 Long, 2 Short Beeps")
	$g_aLangBeepInfo[88]   = _Localization_Load("BeepInformation", "List_Compaq_05", "7 Beeps (1L, 1S, 1L, 1S, Pause, 1L, 1S, 1S)")
	$g_aLangBeepInfo[89]   = _Localization_Load("BeepInformation", "List_Compaq_06", "1 Long Neverending Beep")
	$g_aLangBeepInfo[90]   = _Localization_Load("BeepInformation", "List_Compaq_07", "1 Short, 2 Long Beeps")
	$g_aLangBeepInfo[91]   = _Localization_Load("BeepInformation", "List_Compaq_Info_01", "No Error - System is booting properly. This is a good thing. Everything should be OK and your computer should continue booting.")
	$g_aLangBeepInfo[92]   = _Localization_Load("BeepInformation", "List_Compaq_Info_02", "IOS ROM checksum error - The contents of the BIOS ROM does not match the expected contents. If possible, reload the BIOS from the PAQ or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[93]   = _Localization_Load("BeepInformation", "List_Compaq_Info_03", "General error - Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[94]   = _Localization_Load("BeepInformation", "List_Compaq_Info_04", "Video error - Check the video adapter and ensure it's seated properly. If possible, replace the video adapter or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[95]   = _Localization_Load("BeepInformation", "List_Compaq_Info_05", "AGP video - The AGP video card is faulty. Reseat the card or replace it outright. These beeps pertain to Compaq Desktop systems.")
	$g_aLangBeepInfo[96]   = _Localization_Load("BeepInformation", "List_Compaq_Info_06", "Memory error - Replace and test or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[97]   = _Localization_Load("BeepInformation", "List_Compaq_Info_07", "Bad RAM - Reseat RAM then retest; replace RAM if failure continues or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[98]   = _Localization_Load("BeepInformation", "List_Dell_01", "1 Beep")
	$g_aLangBeepInfo[99]   = _Localization_Load("BeepInformation", "List_Dell_02", "2 Beeps")
	$g_aLangBeepInfo[100]  = _Localization_Load("BeepInformation", "List_Dell_03", "3 Beeps")
	$g_aLangBeepInfo[101]  = _Localization_Load("BeepInformation", "List_Dell_04", "4 Beeps")
	$g_aLangBeepInfo[102]  = _Localization_Load("BeepInformation", "List_Dell_05", "5 Beeps")
	$g_aLangBeepInfo[103]  = _Localization_Load("BeepInformation", "List_Dell_06", "6 Beeps")
	$g_aLangBeepInfo[104]  = _Localization_Load("BeepInformation", "List_Dell_07", "7 Beeps")
	$g_aLangBeepInfo[105]  = _Localization_Load("BeepInformation", "List_Dell_Info_01", "BIOS ROM corruption or failure:")
	$g_aLangBeepInfo[106]  = _Localization_Load("BeepInformation", "List_Dell_Info_02", "Memory (RAM) not detected:")
	$g_aLangBeepInfo[107]  = _Localization_Load("BeepInformation", "List_Dell_Info_03", "Motherboard failure:")
	$g_aLangBeepInfo[108]  = _Localization_Load("BeepInformation", "List_Dell_Info_04", "Memory (RAM) failure:")
	$g_aLangBeepInfo[109]  = _Localization_Load("BeepInformation", "List_Dell_Info_05", "CMOS battery failure:")
	$g_aLangBeepInfo[110]  = _Localization_Load("BeepInformation", "List_Dell_Info_06", "Video card failure:")
	$g_aLangBeepInfo[111]  = _Localization_Load("BeepInformation", "List_Dell_Info_07", "Bad processor (CPU):")
	$g_aLangBeepInfo[112]  = _Localization_Load("BeepInformation", "List_IBM_01", "No Beep")
	$g_aLangBeepInfo[113]  = _Localization_Load("BeepInformation", "List_IBM_02", "1 Short Beep")
	$g_aLangBeepInfo[114]  = _Localization_Load("BeepInformation", "List_IBM_03", "2 Short Beeps")
	$g_aLangBeepInfo[115]  = _Localization_Load("BeepInformation", "List_IBM_04", "Continuous Beeps")
	$g_aLangBeepInfo[116]  = _Localization_Load("BeepInformation", "List_IBM_05", "1 Long, 1 Short Beep")
	$g_aLangBeepInfo[117]  = _Localization_Load("BeepInformation", "List_IBM_06", "1 Long, 2 Short Beeps")
	$g_aLangBeepInfo[118]  = _Localization_Load("BeepInformation", "List_IBM_07", "1 Long, 3 Short Beeps")
	$g_aLangBeepInfo[119]  = _Localization_Load("BeepInformation", "List_IBM_08", "3 Long Beeps")
	$g_aLangBeepInfo[120]  = _Localization_Load("BeepInformation", "List_IBM_09", "1 Beep, Blank Screen")
	$g_aLangBeepInfo[121]  = _Localization_Load("BeepInformation", "List_IBM_10", "999s")
	$g_aLangBeepInfo[122]  = _Localization_Load("BeepInformation", "List_IBM_Info_01", "Power supply error - Replace the power supply or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[123]  = _Localization_Load("BeepInformation", "List_IBM_Info_02", "Normal POST - System is booting properly. This is a good thing. Everything should be OK and your computer should continue booting.")
	$g_aLangBeepInfo[124]  = _Localization_Load("BeepInformation", "List_IBM_Info_03", "Initialization error - Error code is displayed.")
	$g_aLangBeepInfo[125]  = _Localization_Load("BeepInformation", "List_IBM_Info_04", "Power supply error - Replace the power supply or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[126]  = _Localization_Load("BeepInformation", "List_IBM_Info_05", "Motherboard issue - Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[127]  = _Localization_Load("BeepInformation", "List_IBM_Info_06", "Video adapter error - Video (Mono/CGA Display Circuitry) issue. Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[128]  = _Localization_Load("BeepInformation", "List_IBM_Info_07", "EGA/VGA adapter error - Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[129]  = _Localization_Load("BeepInformation", "List_IBM_Info_08", "3270 keyboard adapter error - Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[130]  = _Localization_Load("BeepInformation", "List_IBM_Info_09", "Video Display Circuitry - Try the steps below to resolve your issue:")
	$g_aLangBeepInfo[131]  = _Localization_Load("BeepInformation", "List_IBM_Info_10", "Power supply error - Replace the power supply or try the steps below to resolve your issue:")
	$g_aLangBeepInfo[132]  = _Localization_Load("BeepInformation", "List_Intel_01", "Verify Real Mode.")
	$g_aLangBeepInfo[133]  = _Localization_Load("BeepInformation", "List_Intel_02", "Get CPU type.")
	$g_aLangBeepInfo[134]  = _Localization_Load("BeepInformation", "List_Intel_03", "Initialize system hardware.")
	$g_aLangBeepInfo[135]  = _Localization_Load("BeepInformation", "List_Intel_04", "Initialize chipset registers with initial POST values.")
	$g_aLangBeepInfo[136]  = _Localization_Load("BeepInformation", "List_Intel_05", "Set in POST flag.")
	$g_aLangBeepInfo[137]  = _Localization_Load("BeepInformation", "List_Intel_06", "Initialize CPU registers.")
	$g_aLangBeepInfo[138]  = _Localization_Load("BeepInformation", "List_Intel_07", "Initialize cache to initial POST values.")
	$g_aLangBeepInfo[139]  = _Localization_Load("BeepInformation", "List_Intel_08", "Initialize I/O.")
	$g_aLangBeepInfo[140]  = _Localization_Load("BeepInformation", "List_Intel_09", "Initialize Power Management.")
	$g_aLangBeepInfo[141]  = _Localization_Load("BeepInformation", "List_Intel_10", "Load alternate registers with initial POST values.")
	$g_aLangBeepInfo[142]  = _Localization_Load("BeepInformation", "List_Intel_11", "Jump to UserPatch0.")
	$g_aLangBeepInfo[143]  = _Localization_Load("BeepInformation", "List_Intel_12", "Initialize keyboard controller.")
	$g_aLangBeepInfo[144]  = _Localization_Load("BeepInformation", "List_Intel_13", "BIOS ROM checksum.")
	$g_aLangBeepInfo[145]  = _Localization_Load("BeepInformation", "List_Intel_14", "8254 timer initialization.")
	$g_aLangBeepInfo[146]  = _Localization_Load("BeepInformation", "List_Intel_15", "8237 DMA controller initialization.")
	$g_aLangBeepInfo[147]  = _Localization_Load("BeepInformation", "List_Intel_16", "Reset Programmable Interrupt Controller.")
	$g_aLangBeepInfo[148]  = _Localization_Load("BeepInformation", "List_Intel_17", "Test DRAM refresh.")
	$g_aLangBeepInfo[149]  = _Localization_Load("BeepInformation", "List_Intel_18", "Test 8742 Keyboard Controller.")
	$g_aLangBeepInfo[150]  = _Localization_Load("BeepInformation", "List_Intel_19", "Set ES segment to register to 4 GB.")
	$g_aLangBeepInfo[151]  = _Localization_Load("BeepInformation", "List_Intel_20", "28 Autosize DRAM.")
	$g_aLangBeepInfo[152]  = _Localization_Load("BeepInformation", "List_Intel_21", "Clear 512K base RAM.")
	$g_aLangBeepInfo[153]  = _Localization_Load("BeepInformation", "List_Intel_22", "Test 512 base address lines.")
	$g_aLangBeepInfo[154]  = _Localization_Load("BeepInformation", "List_Intel_23", "Test 512K base memory.")
	$g_aLangBeepInfo[155]  = _Localization_Load("BeepInformation", "List_Intel_24", "Test CPU bus-clock frequency.")
	$g_aLangBeepInfo[156]  = _Localization_Load("BeepInformation", "List_Intel_25", "CMOS RAM read/write failure (this commonly indicates a problem on the ISA bus such as a card not seated).")
	$g_aLangBeepInfo[157]  = _Localization_Load("BeepInformation", "List_Intel_26", "Reinitialize the chipset.")
	$g_aLangBeepInfo[158]  = _Localization_Load("BeepInformation", "List_Intel_27", "Shadow system BIOS ROM.")
	$g_aLangBeepInfo[159]  = _Localization_Load("BeepInformation", "List_Intel_28", "Reinitialize the cache.")
	$g_aLangBeepInfo[160]  = _Localization_Load("BeepInformation", "List_Intel_29", "Autosize cache.")
	$g_aLangBeepInfo[161]  = _Localization_Load("BeepInformation", "List_Intel_30", "Configure advanced chipset registers.")
	$g_aLangBeepInfo[162]  = _Localization_Load("BeepInformation", "List_Intel_31", "Load alternate registers with CMOS values.")
	$g_aLangBeepInfo[163]  = _Localization_Load("BeepInformation", "List_Intel_32", "Set Initial CPU speed.")
	$g_aLangBeepInfo[164]  = _Localization_Load("BeepInformation", "List_Intel_33", "Initialize interrupt vectors.")
	$g_aLangBeepInfo[165]  = _Localization_Load("BeepInformation", "List_Intel_34", "Initialize BIOS interrupts.")
	$g_aLangBeepInfo[166]  = _Localization_Load("BeepInformation", "List_Intel_35", "Check ROM copyright notice.")
	$g_aLangBeepInfo[167]  = _Localization_Load("BeepInformation", "List_Intel_36", "Initialize manager for PCI Options ROMs.")
	$g_aLangBeepInfo[168]  = _Localization_Load("BeepInformation", "List_Intel_37", "Check video configuration against CMOS.")
	$g_aLangBeepInfo[169]  = _Localization_Load("BeepInformation", "List_Intel_38", "Initialize PCI bus and devices.")
	$g_aLangBeepInfo[170]  = _Localization_Load("BeepInformation", "List_Intel_39", "Initialize all video adapters in system.")
	$g_aLangBeepInfo[171]  = _Localization_Load("BeepInformation", "List_Intel_40", "Shadow video BIOS ROM.")
	$g_aLangBeepInfo[172]  = _Localization_Load("BeepInformation", "List_Intel_41", "Display copyright notice.")
	$g_aLangBeepInfo[173]  = _Localization_Load("BeepInformation", "List_Intel_42", "Display CPU type and speed.")
	$g_aLangBeepInfo[174]  = _Localization_Load("BeepInformation", "List_Intel_43", "Test keyboard.")
	$g_aLangBeepInfo[175]  = _Localization_Load("BeepInformation", "List_Intel_44", "Set key click if enabled.")
	$g_aLangBeepInfo[176]  = _Localization_Load("BeepInformation", "List_Intel_45", "56 Enable keyboard.")
	$g_aLangBeepInfo[177]  = _Localization_Load("BeepInformation", "List_Intel_46", "Test for unexpected interrupts.")
	$g_aLangBeepInfo[178]  = _Localization_Load("BeepInformation", "List_Intel_47", "Display prompt Press F2 to enter SETUP.")
	$g_aLangBeepInfo[179]  = _Localization_Load("BeepInformation", "List_Intel_48", "Test RAM between 512 and 640k.")
	$g_aLangBeepInfo[180]  = _Localization_Load("BeepInformation", "List_Intel_49", "Test expanded memory.")
	$g_aLangBeepInfo[181]  = _Localization_Load("BeepInformation", "List_Intel_50", "Test extended memory address lines.")
	$g_aLangBeepInfo[182]  = _Localization_Load("BeepInformation", "List_Intel_51", "Jump to UserPatch1.")
	$g_aLangBeepInfo[183]  = _Localization_Load("BeepInformation", "List_Intel_52", "Configure advanced cache registers.")
	$g_aLangBeepInfo[184]  = _Localization_Load("BeepInformation", "List_Intel_53", "Enable external and CPU caches.")
	$g_aLangBeepInfo[185]  = _Localization_Load("BeepInformation", "List_Intel_54", "Display external cache size.")
	$g_aLangBeepInfo[186]  = _Localization_Load("BeepInformation", "List_Intel_55", "Display shadow message.")
	$g_aLangBeepInfo[187]  = _Localization_Load("BeepInformation", "List_Intel_56", "Display non-disposable segments.")
	$g_aLangBeepInfo[188]  = _Localization_Load("BeepInformation", "List_Intel_57", "Display error messages.")
	$g_aLangBeepInfo[189]  = _Localization_Load("BeepInformation", "List_Intel_58", "Check for configuration errors.")
	$g_aLangBeepInfo[190]  = _Localization_Load("BeepInformation", "List_Intel_59", "Test real-time clock.")
	$g_aLangBeepInfo[191]  = _Localization_Load("BeepInformation", "List_Intel_60", "Check for keyboard errors.")
	$g_aLangBeepInfo[192]  = _Localization_Load("BeepInformation", "List_Intel_61", "Set up hardware interrupts vectors.")
	$g_aLangBeepInfo[193]  = _Localization_Load("BeepInformation", "List_Intel_62", "Test coprocessor if present.")
	$g_aLangBeepInfo[194]  = _Localization_Load("BeepInformation", "List_Intel_63", "Disable onboard I/O ports.")
	$g_aLangBeepInfo[195]  = _Localization_Load("BeepInformation", "List_Intel_64", "Detect and install external RS232 ports.")
	$g_aLangBeepInfo[196]  = _Localization_Load("BeepInformation", "List_Intel_65", "Detect and install external parallel ports.")
	$g_aLangBeepInfo[197]  = _Localization_Load("BeepInformation", "List_Intel_66", "Re-initialize onboard I/O ports.")
	$g_aLangBeepInfo[198]  = _Localization_Load("BeepInformation", "List_Intel_67", "Initialize BIOS Data Area.")
	$g_aLangBeepInfo[199]  = _Localization_Load("BeepInformation", "List_Intel_68", "Initialize Extended BIOS Data Area.")
	$g_aLangBeepInfo[200]  = _Localization_Load("BeepInformation", "List_Intel_69", "Initialize floppy controller.")
	$g_aLangBeepInfo[201]  = _Localization_Load("BeepInformation", "List_Intel_70", "Initialize hard-disk controller.")
	$g_aLangBeepInfo[202]  = _Localization_Load("BeepInformation", "List_Intel_71", "Initialize local-bus hard-disk controller.")
	$g_aLangBeepInfo[203]  = _Localization_Load("BeepInformation", "List_Intel_72", "Jump to UserPatch2.")
	$g_aLangBeepInfo[204]  = _Localization_Load("BeepInformation", "List_Intel_73", "Disable A20 address line.")
	$g_aLangBeepInfo[205]  = _Localization_Load("BeepInformation", "List_Intel_74", "Clear huge ES segment register.")
	$g_aLangBeepInfo[206]  = _Localization_Load("BeepInformation", "List_Intel_75", "Search for option ROMs.")
	$g_aLangBeepInfo[207]  = _Localization_Load("BeepInformation", "List_Intel_76", "Shadow option ROMs.")
	$g_aLangBeepInfo[208]  = _Localization_Load("BeepInformation", "List_Intel_77", "Set up Power Management.")
	$g_aLangBeepInfo[209]  = _Localization_Load("BeepInformation", "List_Intel_78", "Enable hardware interrupts.")
	$g_aLangBeepInfo[210]  = _Localization_Load("BeepInformation", "List_Intel_79", "Set time of day.")
	$g_aLangBeepInfo[211]  = _Localization_Load("BeepInformation", "List_Intel_80", "Check key lock.")
	$g_aLangBeepInfo[212]  = _Localization_Load("BeepInformation", "List_Intel_81", "Erase F2 prompt.")
	$g_aLangBeepInfo[213]  = _Localization_Load("BeepInformation", "List_Intel_82", "Scan for F2 key stroke.")
	$g_aLangBeepInfo[214]  = _Localization_Load("BeepInformation", "List_Intel_83", "Enter SETUP.")
	$g_aLangBeepInfo[215]  = _Localization_Load("BeepInformation", "List_Intel_84", "Clear in-POST flag.")
	$g_aLangBeepInfo[216]  = _Localization_Load("BeepInformation", "List_Intel_85", "Check for errors.")
	$g_aLangBeepInfo[217]  = _Localization_Load("BeepInformation", "List_Intel_86", "POST done--prepare to boot operating system.")
	$g_aLangBeepInfo[218]  = _Localization_Load("BeepInformation", "List_Intel_87", "One beep.")
	$g_aLangBeepInfo[219]  = _Localization_Load("BeepInformation", "List_Intel_88", "Check password (optional).")
	$g_aLangBeepInfo[220]  = _Localization_Load("BeepInformation", "List_Intel_89", "Clear global descriptor table.")
	$g_aLangBeepInfo[221]  = _Localization_Load("BeepInformation", "List_Intel_90", "Clear parity checkers.")
	$g_aLangBeepInfo[222]  = _Localization_Load("BeepInformation", "List_Intel_91", "Clear screen (optional).")
	$g_aLangBeepInfo[223]  = _Localization_Load("BeepInformation", "List_Intel_92", "Check virus and backup reminders.")
	$g_aLangBeepInfo[224]  = _Localization_Load("BeepInformation", "List_Intel_93", "Try to boot with INT 19.")
	$g_aLangBeepInfo[225]  = _Localization_Load("BeepInformation", "List_Intel_94", "Interrupt handler error.")
	$g_aLangBeepInfo[226]  = _Localization_Load("BeepInformation", "List_Intel_95", "Unknown interrupt error.")
	$g_aLangBeepInfo[227]  = _Localization_Load("BeepInformation", "List_Intel_96", "Pending interrupt error.")
	$g_aLangBeepInfo[228]  = _Localization_Load("BeepInformation", "List_Intel_97", "Initialize option ROM error.")
	$g_aLangBeepInfo[229]  = _Localization_Load("BeepInformation", "List_Intel_98", "Shutdown error.")
	$g_aLangBeepInfo[230]  = _Localization_Load("BeepInformation", "List_Intel_99", "Extended Block Move.")
	$g_aLangBeepInfo[231]  = _Localization_Load("BeepInformation", "List_Intel_100", "Shutdown 10 error.")
	$g_aLangBeepInfo[232]  = _Localization_Load("BeepInformation", "List_Intel_101", "Keyboard Controller failure.")
	$g_aLangBeepInfo[233]  = _Localization_Load("BeepInformation", "List_Intel_102", "Initialize the chipset.")
	$g_aLangBeepInfo[234]  = _Localization_Load("BeepInformation", "List_Intel_103", "Initialize refresh counter.")
	$g_aLangBeepInfo[235]  = _Localization_Load("BeepInformation", "List_Intel_104", "Check for Forced Flash.")
	$g_aLangBeepInfo[236]  = _Localization_Load("BeepInformation", "List_Intel_105", "Check HW status of ROM.")
	$g_aLangBeepInfo[237]  = _Localization_Load("BeepInformation", "List_Intel_106", "BIOS ROM is OK.")
	$g_aLangBeepInfo[238]  = _Localization_Load("BeepInformation", "List_Intel_107", "Do a complete RAM test.")
	$g_aLangBeepInfo[239]  = _Localization_Load("BeepInformation", "List_Intel_108", "Do OEM initialization.")
	$g_aLangBeepInfo[240]  = _Localization_Load("BeepInformation", "List_Intel_109", "Initialize interrupt controller.")
	$g_aLangBeepInfo[241]  = _Localization_Load("BeepInformation", "List_Intel_110", "Read in bootstrap code.")
	$g_aLangBeepInfo[242]  = _Localization_Load("BeepInformation", "List_Intel_111", "Initialize all vectors.")
	$g_aLangBeepInfo[243]  = _Localization_Load("BeepInformation", "List_Intel_112", "Boot the Flash program.")
	$g_aLangBeepInfo[244]  = _Localization_Load("BeepInformation", "List_Intel_113", "Initialize the boot device.")
	$g_aLangBeepInfo[245]  = _Localization_Load("BeepInformation", "List_Intel_114", "Boot code was read OK.")

EndFunc


Func _Localization_Custom()

	;~ Check if the language strings is already loaded. Because we do not want to load the language strings twice.
	If StringLen($g_aLangCustom[0]) > 0 Then
		Return
	EndIf

	$g_aLangCustom[0]   = _Localization_Load("Custom", "Label_Status_Welcome", "Because of the wide variety of motherboard manufacturers, your beep codes may differ.")
	$g_aLangCustom[1]   = _Localization_Load("Custom", "Label_Status_Updates", "Checking for Updates")
	$g_aLangCustom[2]   = _Localization_Load("Custom", "Button_BIOS_Info", "Bios Information")
	$g_aLangCustom[3]   = _Localization_Load("Custom", "Button_BIOS_AMI", "AMI Codes")
	$g_aLangCustom[4]   = _Localization_Load("Custom", "Button_BIOS_AST", "AST Codes")
	$g_aLangCustom[5]   = _Localization_Load("Custom", "Button_BIOS_Award", "Award Codes")
	$g_aLangCustom[6]   = _Localization_Load("Custom", "Button_BIOS_Compaq", "Compaq Codes")
	$g_aLangCustom[7]   = _Localization_Load("Custom", "Button_BIOS_Dell", "Dell Codes")
	$g_aLangCustom[8]   = _Localization_Load("Custom", "Button_BIOS_IBM", "IBM Codes")
	$g_aLangCustom[9]   = _Localization_Load("Custom", "Button_BIOS_Intel", "Intel (Phoenix) Codes")
	$g_aLangCustom[10]  = _Localization_Load("Custom", "Button_BIOS_Insyde", "Insyde Codes")
	$g_aLangCustom[11]  = _Localization_Load("Custom", "Label_Intel_Desc", "These codes are a little more complicated. The BIOS emits three sets of beeps. For example, 1 -pause 3 -pause 3 -pause 3 -pause. This is a 1-3-3-3 combo and each set of beeps are seperated by a brief pause.")

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
	$g_aLangMenus[10] = _Localization_Load("Menus", "Help_Support", "&Get Support")
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
	$g_aLangPreferences[24] = _Localization_Load("Preferences", "Combo_Priority_0", "Low")
	$g_aLangPreferences[25] = _Localization_Load("Preferences", "Combo_Priority_1", "Below Normal")
	$g_aLangPreferences[26] = _Localization_Load("Preferences", "Combo_Priority_2", "Normal")
	$g_aLangPreferences[27] = _Localization_Load("Preferences", "Combo_Priority_3", "Above Normal")
	$g_aLangPreferences[28] = _Localization_Load("Preferences", "Combo_Priority_4", "High")
	$g_aLangPreferences[29] = _Localization_Load("Preferences", "Combo_Priority_5", "Realtime")

EndFunc


Func _Localization_Load($sSection, $sKey, $sDefault)
	Local $sCheckSpace = ""
	If StringCompare(StringLeft($sKey, 8), "Checkbox") = 0 Then
		$sCheckSpace = Chr(32)
	EndIf

	; Generate cache key
	Local $sCacheKey = $sSection & "|" & $sKey

	; Check cache first
	For $i = 0 To $g_iLocalizationCacheSize - 1
		If $g_aLocalizationCache[$i][0] = $sCacheKey Then
			Return $sCheckSpace & $g_aLocalizationCache[$i][2]
		EndIf
	Next

	; Not in cache, load from file
	Local $sText = IniRead($g_sLanguageFile, $sSection, $sKey, $sDefault)
	Local $sReplaced = _Localization_ReplaceVar($sText)

	; Add to cache
	_Localization_AddToCache($sCacheKey, $sText, $sReplaced)

	Return $sCheckSpace & $sReplaced
EndFunc


Func _Localization_AddToCache($sCacheKey, $sOriginal, $sReplaced)
	; Grow cache array if needed
	If $g_iLocalizationCacheSize >= UBound($g_aLocalizationCache) Then
		ReDim $g_aLocalizationCache[$g_iLocalizationCacheSize + 50][3]
	EndIf

	; Add to cache
	$g_aLocalizationCache[$g_iLocalizationCacheSize][0] = $sCacheKey
	$g_aLocalizationCache[$g_iLocalizationCacheSize][1] = $sOriginal
	$g_aLocalizationCache[$g_iLocalizationCacheSize][2] = $sReplaced
	$g_iLocalizationCacheSize += 1
EndFunc


Func _Localization_ReplaceVar($sText)
	$sText = String($sText)

	; Do all replacements in one pass
	$sText = StringReplace($sText, "%{Company.Name}", $g_sCompanyName)
	$sText = StringReplace($sText, "%{Program.Name.Short}", $g_sProgShortName)
	$sText = StringReplace($sText, "%{Program.Name.Short.X64}", $g_sProgShortName_X64)
	$sText = StringReplace($sText, "%{Program.Name}", $g_sProgName)
	$sText = StringReplace($sText, "%{AutoIt.Version}", @AutoItVersion)
	$sText = StringReplace($sText, "%{Windows.Version}", _GetWindowsVersion(1))
	$sText = StringReplace($sText, "\rn", @CRLF)
	$sText = StringReplace($sText, "\t", @TAB)

	Return $sText
EndFunc   ;==>_Localization_ReplaceVar