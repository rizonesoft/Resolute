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
Global Const $LNG_COUNTABOUT = 20
Global Const $LNG_COUNTDONATE = 10
Global Const $LNG_COUNTFILE = 25
Global Const $LNG_COUNTLOGGING = 36
Global Const $LNG_COUNTMESSAGES = 50
Global Const $LNG_COUNTUPDATE = 12
Global Const $LNG_COUNTVERSIONING = 4
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
; ===============================================================================================================================


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
	$g_aLangAbout[4]  = _Localization_Load("About", "Tip_Title_Donate", "Donate to our Cause")
	$g_aLangAbout[5]  = _Localization_Load("About", "Tip_Message_Donate", "When you donate, you help keep our software free\rnand enable us to acquire the tools and services\rnwe use to serve you.")
	$g_aLangAbout[6]  = _Localization_Load("About", "Label_Home", "Homepage")
	$g_aLangAbout[7]  = _Localization_Load("About", "Label_License", "License")
	$g_aLangAbout[8]  = _Localization_Load("About", "Label_Support", "Get Support")
	$g_aLangAbout[9]  = _Localization_Load("About", "Tip_Title_Country", "Made in South Africa")
	$g_aLangAbout[10] = _Localization_Load("About", "Tip_Message_Country", "%{Program.Name} was born in South Africa.")
	$g_aLangAbout[11] = _Localization_Load("About", "Label_Contributors", "Contributors")
	$g_aLangAbout[12] = _Localization_Load("About", "Tip_Facebook", "Like us on Facebook.")
	$g_aLangAbout[13] = _Localization_Load("About", "Tip_Twitter", "Follow us on Twitter.")
	$g_aLangAbout[14] = _Localization_Load("About", "Tip_GooglePlus", "Find us on Google.")
	$g_aLangAbout[15] = _Localization_Load("About", "Tip_GitHub", "%{Program.Name} on GitHub.")
	$g_aLangAbout[16] = _Localization_Load("About", "Button_Ok", "Ok")
	$g_aLangAbout[17] = _Localization_Load("About", "Label_RAM", "(RAM) %d MB FREE OF %d MB (%d%)")
	$g_aLangAbout[18] = _Localization_Load("About", "Tip_RAM", "Random Access Memory")
	$g_aLangAbout[19] = _Localization_Load("About", "Label_HDD", "(%s) %.2f GB FREE OF %.2f GB (%d%)")

EndFunc   ;==>_Localization_About


Func _Localization_Donate()

	If StringLen($g_aLangDonate[0]) > 0 Then
		Return
	EndIf

	$g_aLangDonate[0] = _Localization_Load("Donate", "Label_Heading", "%{Program.Name} has been serving you for over %d hours. Now, how about donating to our cause?")
	$g_aLangDonate[1] = _Localization_Load("Donate", "Label_Message", "Click on the PayPal button below or go to PayPal.me/rizonesoft, enter in the amount, and send us the donation. Because it's PayPal, you know it's easier and more secure than carrying cash. Don’t have a PayPal account? No worries, it's quick and easy to sign up.")

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


Func _Localization_Load($sSection, $sKey, $sDefault)

	Local $sCheckSpace = ""
	If StringCompare(StringLeft($sKey, 8), "Checkbox") = 0 Then
		$sCheckSpace = Chr(32)
	EndIf

	Return $sCheckSpace & _Localization_ReplaceVar(IniRead($g_sLanguageFile, $sSection, $sKey, $sDefault))

EndFunc


Func _Localization_ReplaceVar($sText)

	$sText = String($sText)
	Local $aReturn[8]

	$aReturn[0] = StringReplace($sText, "%{Company.Name}", $g_sCompanyName)
	$aReturn[1] = StringReplace($aReturn[0], "%{Program.Name.Short}", $g_sProgShortName)
	$aReturn[2] = StringReplace($aReturn[1], "%{Program.Name.Short.X64}", $g_sProgShortName_X64)
	$aReturn[3] = StringReplace($aReturn[2], "%{Program.Name}", $g_sProgName)
	$aReturn[4] = StringReplace($aReturn[3], "%{AutoIt.Version}", @AutoItVersion)
	$aReturn[5] = StringReplace($aReturn[4], "%{Windows.Version}", _GetWindowsVersion(1))
	$aReturn[6] = StringReplace($aReturn[5], "\rn", @CRLF)
	$aReturn[7] = StringReplace($aReturn[6], "\t", @TAB)

	Return $aReturn[7]
EndFunc   ;==>_Localization_ReplaceVar