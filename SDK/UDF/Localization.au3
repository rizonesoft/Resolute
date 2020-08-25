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


#include "..\Includes\Localization.au3"


; #CONSTANTS# ===================================================================================================================
Global Const $LNG_COUNTCUSTOM = 102
Global Const $LNG_COUNTMENUS = 102
Global Const $LNG_COUNTMESSAGES2 = 100
Global Const $LNG_COUNTPREREQUISITES = 10
Global Const $LNG_COUNTSOLUTIONS = 11
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
If Not IsDeclared("g_sLanguageFile") Then Global $g_sLanguageFile
If Not IsDeclared("g_aLangCustom") Then Global $g_aLangCustom[$LNG_COUNTCUSTOM]
If Not IsDeclared("g_aLangMenus") Then Global $g_aLangMenus[$LNG_COUNTMENUS]
If Not IsDeclared("g_aLangMessages2") Then Global $g_aLangMessages2[$LNG_COUNTMESSAGES2]
If Not IsDeclared("g_aLangPrerequisites") Then Global $g_aLangPrerequisites[$LNG_COUNTPREREQUISITES]
If Not IsDeclared("g_aLangSolutions") Then Global $g_aLangSolutions[$LNG_COUNTSOLUTIONS]
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
	$g_aLangCustom[2]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.01", "Build Solution"))
	$g_aLangCustom[3]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.02", "Compress Program Executables"))
	$g_aLangCustom[4]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.03", "Sign Program Executables"))
	$g_aLangCustom[5]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.04", "Generate Documentation"))
	$g_aLangCustom[6]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.05", "Import External Dependencies"))
	$g_aLangCustom[7]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.06", "Create Distribution"))
	$g_aLangCustom[8]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.07", "Create Portable Package"))
	$g_aLangCustom[9]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.08", "Create Installation"))
	$g_aLangCustom[10] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.09", "Sign Installation"))
	$g_aLangCustom[11] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.11", "Distribute Source Code"))
	$g_aLangCustom[12] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.12", "Create Source Code Package"))
	$g_aLangCustom[13] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.13", "Source Code to GitHub"))


	$g_aLangCustom[14] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Commands.14", "Create Update File"))
	$g_aLangCustom[15] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Build", "Build"))
	$g_aLangCustom[16] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Distribution", "Distribution"))
	$g_aLangCustom[17] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Button.Process", "Process"))
	$g_aLangCustom[18] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Custom", "Tab.Logging", "Logging"))


EndFunc   ;==>_Localization_Custom


Func _Localization_Menus()

	If StringLen($g_aLangMenus[0]) > 0 Then
		Return
	EndIf

	$g_aLangMenus[0]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File", "&File"))
	$g_aLangMenus[1]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File.Solution", "&New Solution"))
	$g_aLangMenus[2]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File.Preferences", "&Preferences"))
	$g_aLangMenus[3]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File.Logging", "&Logging"))
	$g_aLangMenus[4]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File.Log.OpenFile", "Open &log File"))
	$g_aLangMenus[5]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File.Log.OpenDir", "Open log &Directory"))
	$g_aLangMenus[6]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "File.Close", "Close\tAlt+F4"))
	$g_aLangMenus[7]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help", "&Help"))
	$g_aLangMenus[8]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Update", "Check for &updates"))
	$g_aLangMenus[9]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Home", "%{Company.Name} &Home"))
	$g_aLangMenus[10] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Forums", "Product Support &Forums"))
	$g_aLangMenus[11] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Downloads", "More &Downloads"))
	$g_aLangMenus[12] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Contact", "&Contact %{Company.Name}"))
	$g_aLangMenus[13] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Issue", "Create an &issue"))
	$g_aLangMenus[14] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.Donate", "Donate to &our Cause"))
	$g_aLangMenus[15] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Help.About", "About %{Program.Name}"))
	$g_aLangMenus[16] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Menus", "Debug", "&Debug"))

EndFunc   ;==>_Localization_Menus


Func _Localization_Messages2()

	If StringLen($g_aLangMessages2[0]) > 0 Then
		Return
	EndIf

	$g_aLangMessages2[0]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Load.Solutions", "Loading Solutions"))
	$g_aLangMessages2[1]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Load.States", "Initializing States"))
	$g_aLangMessages2[2]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Load.Prerequasites", "Checking Prerequasites"))
	$g_aLangMessages2[3]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Concrete.Error", "SDK root is not writable, so we moved the Concrete directory to: %s"))
	$g_aLangMessages2[4]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Select.Something.Title", "Select Something"))
	$g_aLangMessages2[5]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Select.Something", "How about selecting something?"))
	$g_aLangMessages2[6]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Building.Start", "Building %s..."))
	$g_aLangMessages2[7]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Building.Finished", "Finished building %s."))
	$g_aLangMessages2[8]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Building.Error1", "Could not find AutoIt at '%s'!"))
	$g_aLangMessages2[9]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Building.Error2", "Please install AutoIt before you continue."))
	$g_aLangMessages2[10] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Building.Error3", "Could not find a script to Build at '%s'!"))
	$g_aLangMessages2[11] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Compression.Start", "Compressing %s"))
	$g_aLangMessages2[12] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Compression.Finished", "Finished compressing executables."))
	$g_aLangMessages2[13] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Compression.Compress", "Compressing: %s"))
	$g_aLangMessages2[14] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Compression.Parameters", "Parameters: %s"))
	$g_aLangMessages2[15] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Compression.Error1", "Failed to UPX the executable."))
	$g_aLangMessages2[16] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Compression.Error2", "UPX is required to compress the file."))
	$g_aLangMessages2[17] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Compression.Error3", "'%s' does not exist."))
	$g_aLangMessages2[18] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.Start", "Signing %s"))
	$g_aLangMessages2[19] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.Finished", "Finished signing %s."))
	$g_aLangMessages2[20] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.Internet.Required", "Please note that a connection to the Internet is required for signing."))
	$g_aLangMessages2[21] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.SDKError1", "SignTool.exe is required for signing %s!"))
	$g_aLangMessages2[22] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.SDKError2", "Please install the Windows Standalone SDK for Windows 10 or"))
	$g_aLangMessages2[23] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.SDKError3", "the Windows Software Development Kit (SDK) for Windows 8.1."))
	$g_aLangMessages2[24] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.CertError1", "Could not load Certificate Information!"))
	$g_aLangMessages2[25] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.CertError2", "Looked for Certificate Information file at '%s'."))
	$g_aLangMessages2[26] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.CertError3", "Could not load code signing Certificate!"))
	$g_aLangMessages2[27] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.CertError4", "Looked for Certificate at '%s'."))
	$g_aLangMessages2[28] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.InstallError1", "Could not find Setup file at '%s'"))
	$g_aLangMessages2[29] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.InstallError2", "Try creating a setup file first."))
	$g_aLangMessages2[30] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.CertInfo.Loaded", "Certificate Information loaded from '%s'"))
	$g_aLangMessages2[31] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Signing.Cert.Loaded", "Certificate loaded: '%s'"))
	$g_aLangMessages2[32] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Create.Documents", "Generating Documentation for %s"))
	$g_aLangMessages2[33] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Tpls.Dir", "Template directory found at: '%s'"))
	$g_aLangMessages2[34] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Tpls.Files", "%02i templates %s found."))
	$g_aLangMessages2[35] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Tpls.Process", "Processing: %s"))
	$g_aLangMessages2[36] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Error1", "Invalid document template path."))
	$g_aLangMessages2[37] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Error2", "Looked for the template directory at '%s'"))
	$g_aLangMessages2[38] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Error3", "No template %s (*tpl) were found."))
	$g_aLangMessages2[39] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Error4", "Could not find the specified document template."))
	$g_aLangMessages2[40] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Error5", "Could not create document file."))
	$g_aLangMessages2[41] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Error6", "Document Template: %s"))
	$g_aLangMessages2[42] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Error7", "Document File: %s"))
	$g_aLangMessages2[43] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Tpls.Success", "Document created successfuly."))
	$g_aLangMessages2[44] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Docs.Tpls.Finished", "All document templates processed."))
	$g_aLangMessages2[45] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Distribute.Start", "Distributing %s."))
	$g_aLangMessages2[46] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Distribute.Dir.Error", "Could not create directory:"))
	$g_aLangMessages2[47] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Distribute.Dir", "Directory created: '%s'"))
	$g_aLangMessages2[48] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Distribute.File.Error1", "The Source File does not exist!"))
	$g_aLangMessages2[49] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Distribute.File.Error2", "Could not create file!"))
	$g_aLangMessages2[50] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Distribute.File", "Could not create file!"))
	$g_aLangMessages2[51] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Distribute.Finished", "%s Distribution Created."))
	$g_aLangMessages2[52] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Distribute.Return", "Missing Distribution File!"))
	$g_aLangMessages2[53] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Zip.Error1", "Could not create Zip package!"))
	$g_aLangMessages2[54] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Zip.Error2", "The distribution is Incomplete."))
	$g_aLangMessages2[55] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Zip.Error3", "Check the Build configuration file and recreate the Distribution."))
	$g_aLangMessages2[56] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Zip.Start", "Creating Zip Package for %s."))
	$g_aLangMessages2[57] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Zip.Finished", "Zip Package created."))
	$g_aLangMessages2[58] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Install.Start", "Creating installation for %s"))
	$g_aLangMessages2[59] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Install.Error", "Could not create installation!"))
	$g_aLangMessages2[60] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Install.Finished", "Created installation for %s."))
	$g_aLangMessages2[61] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Install.Script.Error", "An error occurred whilst generating the setup script."))
	$g_aLangMessages2[62] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Tidy.Start", "Tidying Source Code"))
	$g_aLangMessages2[63] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Tidy.Error1", "Could not find source code!"))
	$g_aLangMessages2[64] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Tidy.Error2", "Could not find Tidy!"))
	$g_aLangMessages2[65] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Tidy.Error3", "Something went wrong! Could not run Tidy."))
	$g_aLangMessages2[66] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Tidy.Finished", "Source code should be pretty now."))
	$g_aLangMessages2[67] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Source.Start", "Distributing Source Code."))
	$g_aLangMessages2[68] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Source.Finished", "Source Code Distribution created."))
	$g_aLangMessages2[69] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Source.Script", "Processing Core Script."))
	$g_aLangMessages2[70] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Script.Error1", "Could not find the specified script!"))
	$g_aLangMessages2[71] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Script.Error2", "Could not write to the output script!"))
	$g_aLangMessages2[72] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Processing.UDFs", "Processing 'User Defined Functions'."))
	$g_aLangMessages2[73] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "UDFs.Error1", "Invalid 'User Defined Functions' Path."))
	$g_aLangMessages2[74] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "UDFs.Error2", "Nothing here!"))
	$g_aLangMessages2[75] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "UDFs.Found", "Found %02i 'User Defined Functions'."))
	$g_aLangMessages2[76] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "GitHub.Start", "Distributing GitHub Repository."))
	$g_aLangMessages2[77] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "GitHub.Finish", "Distributed %s Source Code to the GitHub Repository."))
	$g_aLangMessages2[78] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "GitHub.Copied", "Source Code Directory copied: '%s'"))
	$g_aLangMessages2[79] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "GitHub.Error1", "Invalid Source Code Path!"))
	$g_aLangMessages2[80] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "GitHub.Error2", "No Source Code files found!"))
	$g_aLangMessages2[81] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "GitHub.Error3", "The Source Code Directory could not be copied!"))
	$g_aLangMessages2[82] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "GitHub.Error4", "Invalid GitHub Path!"))
	$g_aLangMessages2[83] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Documents.Create", "Creating the 'Documents' directory."))
	$g_aLangMessages2[84] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Documents.Help", "Importing Help (.chm) file from '%s'."))
	$g_aLangMessages2[85] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Documents.Error1", "Could create the 'Documents' directory."))
	$g_aLangMessages2[86] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Messages2", "Documents.Error2", "Could not import the Help (.chm) file."))

EndFunc


Func _Localization_Prerequisites()

	If StringLen($g_aLangPrerequisites[0]) > 0 Then
		Return
	EndIf

	$g_aLangPrerequisites[0] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Prerequisites", "Tab.Prerequisites", "Prerequisites"))
	$g_aLangPrerequisites[1] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Prerequisites", "Refresh.Message", "Rescan your Computer for installed Prerequisites."))
	$g_aLangPrerequisites[2] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Prerequisites", "Installed", "Prerequisite installed"))
	$g_aLangPrerequisites[3] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Prerequisites", "Uninstalled", "Prerequisite not installed!"))
	$g_aLangPrerequisites[4] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Prerequisites", "TIP.Prerequisite", "Prerequisite :\t"))
	$g_aLangPrerequisites[5] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Prerequisites", "TIP.Publisher", "Publisher :\t"))
	$g_aLangPrerequisites[6] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Prerequisites", "TIP.Location", "Location :\t"))
	$g_aLangPrerequisites[7] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Prerequisites", "TIP.Executable", "Executable :\t"))
	$g_aLangPrerequisites[8] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Prerequisites", "TIP.URL", "URL :\t"))

EndFunc


Func _Localization_Solutions()

	If StringLen($g_aLangSolutions[0]) > 0 Then
		Return
	EndIf

	$g_aLangSolutions[0]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions", "Solutions"))
	$g_aLangSolutions[1]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions.Configuration", "Configuration File"))
	$g_aLangSolutions[2]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions.Item", "item"))
	$g_aLangSolutions[3]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions.Items", "items"))
	$g_aLangSolutions[4]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions.Prototype", "Prototype"))
	$g_aLangSolutions[5]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions.Beta", "Beta"))
	$g_aLangSolutions[6]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions.RC", "Release Candidate"))
	$g_aLangSolutions[7]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions.Final", "Final Release"))
	$g_aLangSolutions[8]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions.Unknown", "Unknown"))
	$g_aLangSolutions[9]  = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions.Error.Title", "Bad Solution!"))
	$g_aLangSolutions[10] = _Localization_ReplaceVar(IniRead($g_sLanguageFile, "Solutions", "Solutions.Error", "This does not seem to be a valid solution."))

EndFunc