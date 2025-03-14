#pragma compile(AutoItExecuteAllowed, true)
Global Const $VERSION = "21.316.1639.0"
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=SciTEConfig.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Configure SciTE For AutoIt3
#AutoIt3Wrapper_Res_Description=Configure SciTE For AutoIt3
#AutoIt3Wrapper_Res_Fileversion=21.316.1639.0
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_LegalCopyright=Copyright © 2021 Jos van der Zande
#AutoIt3Wrapper_Res_Field=Made By|Jos van der Zande
#AutoIt3Wrapper_Res_Field=Email|jdeb at autoitscript dot com
#AutoIt3Wrapper_Res_Field=Credits|Melba23 - Abbrev and Calltip Managers, modifications and testing.
#AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_Run_After_Admin=y
#AutoIt3Wrapper_Run_After=for %I in ("%in%" "AbbrevMan.au3" "Scite_Reload_Props.au3" "StringSize.au3" "Get_AU3_RegistrySettings.au3" "UCTMan.au3" ) do copy %I "C:\Program Files (x86)\autoit3\SciTE\SciTEConfig"
;#AutoIt3Wrapper_Run_Tidy=y
;#Tidy_Parameters=/sf
#AutoIt3Wrapper_AU3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_Run_au3stripper=y
#au3stripper_Parameters=/so /pe
#AutoIt3Wrapper_Versioning=v
#AutoIt3Wrapper_Versioning_Parameters=/Comments %fileversionnew%
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;Opt("TrayIconDebug", 1)
#Region ; Includes
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>
#include <Date.au3>
#include <file.au3>
#include <Color.au3>
#include <ListviewConstants.au3>
#include <EditConstants.au3>
#include <GUIComboBox.au3>
#include <GUIListView.au3>
#include <Constants.au3>
#include <Array.au3>
#include <StringSize.au3>
#include <ButtonConstants.au3>
#include <GuiEdit.au3>
#include <WinAPIGdi.au3>
#EndRegion ; Includes
#Region ; Declare
Global $AutoIT3_Dir = ""
Global $SciTEDir
Global $SciTEUserDir
Global $SciTEUserDirInstall = ""
Global $SciTEUser_Content
Global $gCTM_cListView = 9999, $gCTM_cDblClick = 9999
Global $gABM_cListView = 9999, $gABM_cClicked = 9999, $gABM_cSelChange = 9999
; Use Appdata @LocalAppDataDir & "\AutoIt v3\SciTE\Au3toIt3Wrappe"
Global $SciTEConfig_UserData
; Check for SCITE_USERHOME Env variable and used that when specified.
; Else when OS is better than Winxp we use the INI from LocalAPPDATA
If EnvGet("SCITE_USERHOME") <> "" And FileExists(EnvGet("SCITE_USERHOME") & "\SciTEConfig") Then
	$SciTEConfig_UserData = EnvGet("SCITE_USERHOME") & "\SciTEConfig"
	$SciTEUserDir = EnvGet("SCITE_USERHOME")
ElseIf EnvGet("SCITE_HOME") <> "" And FileExists(EnvGet("SCITE_HOME") & "\SciTEConfig") Then
	$SciTEConfig_UserData = EnvGet("SCITE_HOME") & "\SciTEConfig"
	$SciTEUserDir = EnvGet("SCITE_HOME")
Else
	$SciTEConfig_UserData = @ScriptDir
	If EnvGet("SCITE_HOME") <> "" And FileExists(EnvGet("SCITE_HOME")) Then
		$SciTEUserDir = EnvGet("SCITE_HOME")
	Else
		$SciTEUserDir = _PathFull(@ScriptDir & "..\..")
;~ 			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $SciTEUserDir = ' & $SciTEUserDir & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
	EndIf
EndIf
;~ 	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $SciTEUserDir = ' & $SciTEUserDir & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
;
If EnvGet("SCITE_HOME") <> "" And FileExists(EnvGet("SCITE_HOME")) Then
	$SciTEDir = EnvGet("SCITE_HOME")
Else
;~ 	$SciTEDir = @ScriptDir
EndIf
#EndRegion ; Declare
#Region ; Commandline lexing
; retrieve commandline parameters
;-------------------------------------------------------------------------------------------
; save current dir
Global $S_CurDir = @WorkingDir
For $x = 1 To $CMDLINE[0]
	Global $T_Var = StringLower($CMDLINE[$x])
	Select
		Case $T_Var = "/Installer"
			; Process to be ran by the installer to preset some in SciTEUser.Properties
			; Get content SciTEUser and ensure we are on a newline at the end of the content
			$SciTEUserDirInstall = $CMDLINE[$x+1]
			$SciTEUser_Content = StringStripWS(FileRead($SciTEUserDir & "\SciTEUser.properties"), 3)
			If StringRight($SciTEUser_Content, 2) <> @CRLF Then $SciTEUser_Content &= @CRLF
			;Ensure these lines are in the SciTEUSer.properties
			Update_SciTE_UserContent("UpdateLine", "import au3.UserUdfs")
			Update_SciTE_UserContent("UpdateLine", "import au3.keywords.user.abbreviations")
			Update_SciTE_UserContent("Save")
			If $AutoIT3_Dir = "" Or Not FileExists($AutoIT3_Dir) Then
				; set directory to AutoIt3 directory
				FileChangeDir(@ScriptDir)
				If FileExists(@ScriptDir & "\Autoit3.exe") Then
					$AutoIT3_Dir = @ScriptDir
				Else
					FileChangeDir("..")
					If FileExists("Autoit3.exe") Then
						$AutoIT3_Dir = @WorkingDir
					Else
						FileChangeDir("..")
						If FileExists("Autoit3.exe") Then
							$AutoIT3_Dir = @WorkingDir
						Else
							$AutoIT3_Dir = RegRead("HKLM\Software\AutoIt v3\Autoit", 'InstallDir')
						EndIf
					EndIf
				EndIf
				; Restore saved current directory
				FileChangeDir($S_CurDir)
			EndIf
			Create_IncludeFile_AutoComplete()
			; Exit script
			Exit
		Case $T_Var = "/Autoit3Dir"
			$x = $x + 1
			If FileExists($CMDLINE[$x]) Then $AutoIT3_Dir = $CMDLINE[$x]
	EndSelect
Next
#EndRegion ; Commandline lexing
#Region ; Initialisation
;
; determine the SciTE and AutoIt3 Directories
;
If $AutoIT3_Dir = "" Or Not FileExists($AutoIT3_Dir) Then
	; save current dir
	; set directory to AutoIt3 directory
	FileChangeDir(@ScriptDir)
	If FileExists(@ScriptDir & "\Autoit3.exe") Then
		$AutoIT3_Dir = @ScriptDir
	Else
		FileChangeDir("..")
		If FileExists("Autoit3.exe") Then
			$AutoIT3_Dir = @WorkingDir
		Else
			FileChangeDir("..")
			If FileExists("Autoit3.exe") Then
				$AutoIT3_Dir = @WorkingDir
			Else
				$AutoIT3_Dir = RegRead("HKLM\Software\AutoIt v3\Autoit", 'InstallDir')
			EndIf
		EndIf
	EndIf
	; Restore saved current directory
	FileChangeDir($S_CurDir)
EndIf
;
;
; Find SciTE Directory
Global $SciTECmd
Global $SciTE_hwnd = WinGetHandle("DirectorExtension")
If @error Then
	MsgBox(0 + 16 + 262144, "SciTEConfig", "SciTEConfig ending because SciTE is not running.")
	Exit ;exit when Scite isn't running
EndIf
; Get My GUI Handle numeric
Global $My_Hwnd = GUICreate("SciTE interface", 300, 620, Default, Default, Default, $WS_EX_TOPMOST)
Global $list = GUICtrlCreateEdit("", 1, 1, 290, 590)
Global $My_Dec_Hwnd = Dec(StringTrimLeft($My_Hwnd, 2))
;Register COPYDATA message.
GUIRegisterMsg($WM_COPYDATA, "MY_WM_COPYDATA")
; Get SciTE Directory from the SciTE Director interface
Global $SciTE_Dir = ""
$SciTE_Dir = StringReplace(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:SciteDefaultHome"), "\\", "\")
If Not FileExists($SciTE_Dir) Then
	MsgBox(0 + 16 + 262144, "SciTEConfig", "SciTEConfig ending because SciTE.exe not found.")
	Exit
EndIf
; Get content SciTEUser and ensure we are on a newline at the end of the content
Global $au3Prop = $SciTEUserDir & "\SciTEUser.properties"
$SciTEUser_Content = StringStripWS(FileRead($au3Prop), 3)
If StringRight($SciTEUser_Content, 2) <> @CRLF Then $SciTEUser_Content &= @CRLF
;
;~ 	$VERSION = StringLeft($VERSION, StringInStr($VERSION, ".", 0, -1) - 1)
;$VERSION = "1.3.0"
; Check if updates are available...
If StringInStr($cmdlineraw, "/CheckUpdates") Then
;~ 	CheckForUpdates(1)
	Exit
EndIf
;
; Get SciTE DirectorHandle
Opt("WinSearchChildren", 1)
;Global $WM_COPYDATA = 74
FileChangeDir($AutoIT3_Dir)
;
AutoItWinSetTitle("SciTE_Config_Window")
Global $Ahnd = WinGetHandle(AutoItWinGetTitle())
#EndRegion ; Initialisation
#Region ; GUI
;WinShow(AutoItWinGetTitle(),"",@SW_RESTORE)
; ----------------------------------------------------------------------------
; Script Start
; ----------------------------------------------------------------------------
Global $FontType = '"Courier New"'
Global $FontSize = "10"
Opt("GUICoordMode", 1)
Global $hSciTEConfig_GUI = GUICreate("SciTE Config for AutoIt3 ver:" & $VERSION, 410, 565, Default, Default, Default, $WS_EX_TOPMOST)
Global $NeedsSave = 0
Global $SaveNeeded = 0
;Global $check_NeedsSave = 0
Global $Background_Color = ""
Global $CaretLine_BkColor = ""
Global $CaretLine_BkColor_Alpha = ""
Global $Selection_Color = ""
Global $Selection_BkColor = ""
Global $Selection_Alpha = 50
Global $InLineDefault_Color = ""
Global $InLineDefault_BkColor = ""
Global $InLineWarning_Color = ""
Global $InLineWarning_BkColor = ""
Global $InLineError_Color = ""
Global $InLineError_BkColor = ""
Global $CurrentHilight_Color = ""
Global $Current_Alpha = 50
Global $CallTip_Color = ""
Global $CallTip_BkColor = ""
Global $ParamHilite_Color = ""
Global $ShowState = 0
Global $Backups = 0
Global $ProperCase = 1
Global $ErrorInline = 1
;~ Global $CheckuUpdatesSciTE4AutoIt3 = 0
Global $Use_Tabs = 1
Global $Tab_Size = 4
Global $Current_Highlight = 1
Global $Current_Style = 0
Global $Current_Autoselect = 0
Global $Current_Wholeword = 1
Global $Current_Case = 1
Global $Current_Minlength = 3
Global $CallTip_Above = 0
Global $SearchMargin = 15
Global $Syn_Label[19]
Global $Syn_bColor[19]
Global $Syn_bColor_Default[19]
Global $Syn_fColor[19]
Global $Syn_Bold[19]
Global $Syn_Italic[19]
Global $Syn_Underline[19]
Global $H_ProperCase
Global $H_InLineError_Display
;~ Global $H_CheckUpdatesSciTE4AutoIt3
Global $H_Use_Tabs
Global $H_Tab_Size
Global $H_SearchMargin
Global $H_Syn_Label[19]
Global $H_Syn_bColor[19]
Global $H_Syn_bColor_Standard[19]
Global $H_Syn_fColor[19]
Global $H_Syn_Bold[19]
Global $H_Syn_Italic[19]
Global $H_Syn_Underline[19]
;
Global $BaseX = 30
Global $BaseY = 40
Global $h_tab = GUICtrlCreateTab(10, 10, 390, 480)
Global $h_tab0 = GUICtrlCreateTabItem("General 1")
GUICtrlCreateGroup("Explorer .au3 File Setting.", $BaseX, $BaseY, 340, 45)
GUICtrlCreateLabel('Choose default action for .au3 files:', $BaseX + 10, $BaseY + 20)
Global $h_Edit = GUICtrlCreateRadio('Edit', $BaseX + 190, $BaseY + 20, 50, 15)
Global $h_Run = GUICtrlCreateRadio('Run', $BaseX + 240, $BaseY + 20, 50, 15)
Global $read = RegRead('HKEY_CLASSES_ROOT\AutoIt3Script\Shell', '')
If $read = 'Edit' Or $read = 'Open' Then
	GUICtrlSetState($h_Edit, $GUI_CHECKED)
Else
	GUICtrlSetState($h_Run, $GUI_CHECKED)
EndIf
Global $SYN_Font_Mono_ON = 1
Global $SYN_Font_Mono_Size = 8
Global $SYN_Font_Mono_Type = "Courier New"
Global $SYN_Font_Prop_Size = 8
Global $SYN_Font_Prop_Type = "Arial"
Get_Current_config()
;
$BaseY = 90
GUICtrlCreateGroup("Backup Strategy", $BaseX, $BaseY, 340, 45)
GUICtrlCreateLabel("Keep", $BaseX + 10, $BaseY + 20, 30, 20)
GUICtrlCreateLabel("BAK versions of the edited file (0=None):", $BaseX + 70, $BaseY + 20, 230, 20)
Global $h_Backups = GUICtrlCreateInput($Backups, $BaseX + 40, $BaseY + 17, 25, 20)
;~ $H_CheckUpdatesSciTE4AutoIt3 = GUICtrlCreateCheckbox("Check daily for Updates of SciTE4AutoIT3.", $BaseX + 10, $BaseY + 50)
;
$BaseY = 140
GUICtrlCreateGroup("AutoIt3 Folder:", $BaseX, $BaseY, 340, 90)
GUICtrlCreateInput($AutoIT3_Dir, $BaseX + 10, $BaseY + 18, 325, 20, $ES_READONLY)
Global $UserIncludeDirectory = RegRead("HKEY_CURRENT_USER\SOFTWARE\AutoIt v3\AutoIt", "Include")
If $UserIncludeDirectory = "" Then $UserIncludeDirectory = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt", "Include")
GUICtrlCreateLabel("User Include Folder:", $BaseX + 10, $BaseY + 45, 150, 20)
Global $h_UserIncludeDirectory = GUICtrlCreateInput($UserIncludeDirectory, $BaseX + 10, $BaseY + 60, 325, 20)
Global $h_UserIncludeDirectory_Button = GUICtrlCreateButton("...", $BaseX + 340, $BaseY + 60, 20, 20)
;
$BaseY = 235
GUICtrlCreateGroup("AutoIt Script Font", $BaseX, $BaseY, 340, 100)
Global $H_Syn_Mono_Change = GUICtrlCreateButton("Change", $BaseX + 10, $BaseY + 15, 50, 20)
Global $H_Syn_Mono = GUICtrlCreateCheckbox("Monospace Font:" & $SYN_Font_Mono_Type, $BaseX + 70, $BaseY + 15, 220, 20)
Global $H_Syn_Mono_Size = GUICtrlCreateLabel("Size:" & $SYN_Font_Mono_Size, $BaseX + 290, $BaseY + 17, 40, 20)
Global $H_Syn_Prop_Change = GUICtrlCreateButton("Change", $BaseX + 10, $BaseY + 45, 50, 20)
Global $H_Syn_Prop = GUICtrlCreateCheckbox("Proportional Font:" & $SYN_Font_Prop_Type, $BaseX + 70, $BaseY + 45, 220, 20)
Global $H_Syn_Prop_Size = GUICtrlCreateLabel("Size:" & $SYN_Font_Prop_Size, $BaseX + 290, $BaseY + 47, 40, 20)
Global $SYN_Font_Type, $SYN_Font_Size
If $SYN_Font_Mono_ON = 1 Then
	GUICtrlSetState($H_Syn_Mono, 1)
	GUICtrlSetState($H_Syn_Prop, 4)
	$SYN_Font_Type = $SYN_Font_Mono_Type
	$SYN_Font_Size = $SYN_Font_Mono_Size
Else
	GUICtrlSetState($H_Syn_Mono, 4)
	GUICtrlSetState($H_Syn_Prop, 1)
	$SYN_Font_Type = $SYN_Font_Prop_Type
	$SYN_Font_Size = $SYN_Font_Prop_Size
EndIf
;
$H_Use_Tabs = GUICtrlCreateCheckbox("Use Tabs", $BaseX + 10, $BaseY + 70)
GUICtrlCreateLabel("Tab Size:", $BaseX + 100, $BaseY + 74, 60, 20)
$H_Tab_Size = GUICtrlCreateInput($Tab_Size, $BaseX + 155, $BaseY + 72, 20, 20)
;
$BaseY = 340
;
GUICtrlCreateGroup("Miscellaneous", $BaseX, $BaseY, 340, 120)
$H_ProperCase = GUICtrlCreateCheckbox("Propercase Functions and Keywords.", $BaseX + 10, $BaseY + 20)
GUICtrlCreateLabel("Search result displayed", $BaseX + 10, $BaseY + 50, 115, 20)
GUICtrlCreateLabel("lines from upper/lower margin", $BaseX + 160, $BaseY + 50, 150, 20)
$H_SearchMargin = GUICtrlCreateInput($SearchMargin, $BaseX + 125, $BaseY + 47, 30, 20)
;
Global $h_tab1 = GUICtrlCreateTabItem("General 2")
$BaseY = 40
; Calltip colour
GUICtrlCreateGroup("Inline Errors", $BaseX, $BaseY, 340, 120)
$H_InLineError_Display = GUICtrlCreateCheckbox("Display inline errors in script.", $BaseX + 10, $BaseY + 20)
Global $H_InLineDefault_Label = GUICtrlCreateLabel("Inline Default Color", $BaseX + 5, $BaseY + 50, 150, 20, 0x0200)
Global $H_InLineWarning_Label = GUICtrlCreateLabel("Inline Warning Color", $BaseX + 5, $BaseY + 70, 150, 20, 0x0200)
Global $H_InLineError_Label = GUICtrlCreateLabel("Inline Error Color", $BaseX + 5, $BaseY + 90, 150, 20, 0x0200)
Global $H_InLineDefault_Color = GUICtrlCreateButton("Fore", $BaseX + 170, $BaseY + 50, 80, 20)
Global $H_InLineDefault_BkColor = GUICtrlCreateButton("Back", $BaseX + 170 + 80, $BaseY + 50, 80, 20)
Global $H_InLineWarning_Color = GUICtrlCreateButton("Fore", $BaseX + 170, $BaseY + 70, 80, 20)
Global $H_InLineWarning_BkColor = GUICtrlCreateButton("Back", $BaseX + 170 + 80, $BaseY + 70, 80, 20)
Global $H_InLineError_Color = GUICtrlCreateButton("Fore", $BaseX + 170, $BaseY + 90, 80, 20)
Global $H_InLineError_BkColor = GUICtrlCreateButton("Back", $BaseX + 170 + 80, $BaseY + 90, 80, 20)
;
$BaseY = 165
;
GUICtrlCreateGroup("Current Word Highlight", $BaseX, $BaseY, 340, 140)
Global $H_Current_Highlight = GUICtrlCreateCheckbox("Highlight current word throughout script", $BaseX + 10, $BaseY + 15)
Global $H_Current_AutoSel = GUICtrlCreateCheckbox("AutoSelect word", $BaseX + 10, $BaseY + 35, 120)
Global $H_Current_Wholeword = GUICtrlCreateCheckbox("Whole word", $BaseX + 10, $BaseY + 55, 120)
Global $H_Current_Style = GUICtrlCreateCheckbox("Match style", $BaseX + 210, $BaseY + 35, 120)
Global $H_Current_Case = GUICtrlCreateCheckbox("Match case", $BaseX + 210, $BaseY + 55, 120)
GUICtrlCreateLabel("Min Size:", $BaseX + 10, $BaseY + 82, 60, 20)
Global $H_Current_MinLength = GUICtrlCreateInput($Current_Minlength, $BaseX + 65, $BaseY + 80, 20, 20)
;
Global $H_CurrentHilight_Label = GUICtrlCreateLabel("Current Word Color", $BaseX + 5, $BaseY + 110, 150, 20, 0x0200)
Global $H_CurrentHilight_Color = GUICtrlCreateButton("Back", $BaseX + 170, $BaseY + 110, 80, 20)
GUICtrlCreateLabel("Alpha", $BaseX + 170 + 85, $BaseY + 112, 30, 20)
Global $H_CurrentHiLight_Alpha = GUICtrlCreateInput($Current_Alpha, $BaseX + 170 + 115, $BaseY + 110, 50, 20)
GUICtrlCreateUpdown(-1, 0x0005) ; $UDS_ALIGNRIGHT, $UDS_WRAP
GUICtrlSetLimit(-1, 255, 0)
;
$BaseY = 310
;
GUICtrlCreateGroup("Function CallTip and Parameter Highlight", $BaseX, $BaseY, 340, 100)
Global $H_CallTip_Above = GUICtrlCreateCheckbox("CallTip displayed above function", $BaseX + 10, $BaseY + 20)
Global $H_CallTip_Label = GUICtrlCreateLabel("CallTip Color", $BaseX + 5, $BaseY + 50, 150, 20, 0x0200)
Global $H_ParamHilite_Label = GUICtrlCreateLabel("Parameter Highlight", $BaseX + 5, $BaseY + 70, 150, 20, 0x0200)
Global $H_CallTip_Color = GUICtrlCreateButton("Fore", $BaseX + 170, $BaseY + 50, 80, 20)
Global $H_CallTip_BkColor = GUICtrlCreateButton("Back", $BaseX + 170 + 80, $BaseY + 50, 80, 20)
Global $H_ParamHilite_Color = GUICtrlCreateButton("Foreground", $BaseX + 170, $BaseY + 70, 160, 20)
;
$BaseY = 415
;
GUICtrlCreateGroup("", $BaseX, $BaseY, 340, 65)
;
; Color Tab
Global $h_tab2 = GUICtrlCreateTabItem("Editor Colors")
$BaseY = 60
;determine current loaded definition files for SciTE
;$BaseY = 148
Global $H_Background_Label = GUICtrlCreateLabel("Background Color", $BaseX + 5, $BaseY - 20, 150, 20, 0x0200) ; $SS_CENTERIMAGE
Global $H_CaretLine_Label = GUICtrlCreateLabel("Caret Line Color", $BaseX + 5, $BaseY, 150, 20, 0x0200) ; $GUI_BKCOLOR_TRANSPARENT
Global $H_Selection_Label = GUICtrlCreateLabel("Selected Text Color", $BaseX + 5, $BaseY + 20, 150, 20, 0x0200)
Global $H_Background_Color = GUICtrlCreateButton("Background", $BaseX + 170, $BaseY - 20, 190, 20)
GUICtrlCreateLabel("Alpha", $BaseX + 170 + 110, $BaseY + 2, 30, 20)
Global $H_CaretLine_BkColor = GUICtrlCreateButton("Background", $BaseX + 170, $BaseY, 100, 20)
Global $H_CaretLine_BkAlpha = GUICtrlCreateInput($CaretLine_BkColor_Alpha, $BaseX + 170 + 140, $BaseY, 50, 20)
GUICtrlCreateUpdown(-1, 0x0005) ; $UDS_ALIGNRIGHT, $UDS_WRAP
GUICtrlSetLimit(-1, 256, 0)
GUICtrlCreateLabel("Alpha", $BaseX + 170 + 110, $BaseY + 22, 30, 20)
Global $H_Selection_Color = GUICtrlCreateButton("Fore", $BaseX + 170, $BaseY + 20, 50, 20)
Global $H_Selection_BkColor = GUICtrlCreateButton("Back", $BaseX + 170 + 50, $BaseY + 20, 50, 20)
Global $H_Selection_Alpha = GUICtrlCreateInput($Selection_Alpha, $BaseX + 170 + 140, $BaseY + 20, 50, 20)
GUICtrlCreateUpdown(-1, 0x0005) ; $UDS_ALIGNRIGHT, $UDS_WRAP
GUICtrlSetLimit(-1, 256, 0)
$BaseY = $BaseY + 60
GUICtrlCreateLabel("B", $BaseX + 170, $BaseY, 20, 20)
GUICtrlSetFont(-1, $SYN_Font_Size, 900, 0, $SYN_Font_Type)
GUICtrlCreateLabel("I", $BaseX + 195, $BaseY, 20, 20)
GUICtrlSetFont(-1, $SYN_Font_Size, 400, 2, $SYN_Font_Type)
GUICtrlCreateLabel("U", $BaseX + 220, $BaseY, 20, 20)
GUICtrlSetFont(-1, $SYN_Font_Size, 400, 4, $SYN_Font_Type)
GUICtrlCreateLabel("Default BackColor", $BaseX + 280, $BaseY - 10, 50, 30)
For $x = 1 To 17
	$H_Syn_Label[$x] = GUICtrlCreateLabel($Syn_Label[$x], $BaseX + 5, $BaseY + 20 * $x, 150, 20)
	$H_Syn_Bold[$x] = GUICtrlCreateCheckbox("", $BaseX + 170, $BaseY + 20 * $x, 20, 20)
	$H_Syn_Italic[$x] = GUICtrlCreateCheckbox("", $BaseX + 195, $BaseY + 20 * $x, 20, 20)
	$H_Syn_Underline[$x] = GUICtrlCreateCheckbox("", $BaseX + 220, $BaseY + 20 * $x, 20, 20)
	$H_Syn_fColor[$x] = GUICtrlCreateButton("Fore", $BaseX + 245, $BaseY + 20 * $x, 40, 20)
	$H_Syn_bColor_Standard[$x] = GUICtrlCreateCheckbox("", $BaseX + 295, $BaseY + 20 * $x, 20, 20)
	$H_Syn_bColor[$x] = GUICtrlCreateButton("Back", $BaseX + 320, $BaseY + 20 * $x, 40, 20)
Next
Update_Window()
;
; Need these variables declared for the message loop
Global $file_au3properties, $h_treeview, $h_tab3, $Tool_Num, $Tool_Desc_Org, $Tool_Desc_Cur
Global $SciTEToolsSuffix[80]
Global $SciTETools[1]
If FileExists($AutoIT3_Dir & '\SciTE\Properties\au3.properties') Then
	$file_au3properties = $AutoIT3_Dir & '\SciTE\Properties\au3.properties'
	Global $comment = '#~ '
	$SciTETools = SciteToolsFileRead($file_au3properties)
	If @error Then
		ConsoleWrite('Error: FileRead ' & $file_au3properties & @CRLF)
	Else
		Global $checkbox[$SciTETools[0] + 1]
		; Create the Tools selection Tab
		$h_tab3 = GUICtrlCreateTabItem("Tools Selection")
		GUICtrlCreateLabel("Select items to enable them in SciTE Tools menu", 40, 35, 330)
		GUICtrlSetFont(Default, 9)
		$h_treeview = GUICtrlCreateTreeView(16, 55, 375, 400, BitOR($TVS_CHECKBOXES, $TVS_DISABLEDRAGDROP, $TVS_LINESATROOT), $WS_EX_CLIENTEDGE)
		; Create the TreeView Checkboxes
		For $i = 1 To $SciTETools[0]
			$Tool_Num = StringStripWS(Number(StringMid($SciTETools[$i], 3, 2)), 3)
			$Tool_Desc_Org = StringMid($SciTETools[$i], 6)
			$SciTEToolsSuffix[$i] = ".$(au3)"
			$Tool_Desc_Cur = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:command.name." & $Tool_Num & ".$(au3)")
			If $Tool_Desc_Cur = "" Then
				$SciTEToolsSuffix[$i] = ".*"
				$Tool_Desc_Cur = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:command.name." & $Tool_Num & ".*")
			EndIf
			If $Tool_Desc_Org <> '' Then
				$checkbox[$i] = GUICtrlCreateTreeViewItem($Tool_Desc_Org, $h_treeview)
				If $Tool_Desc_Cur = "" Then
					GUICtrlSetState($checkbox[$i], $GUI_UNCHECKED)
				Else
					GUICtrlSetState($checkbox[$i], $GUI_CHECKED)
				EndIf
				ContinueLoop
			EndIf
		Next
	EndIf
EndIf
;
Global $h_tab4 = GUICtrlCreateTabItem("Other Tools")
Global $H_RunAbbrevMgr = GUICtrlCreateButton("Run Abbrev Manager", 20, 40, 200, 30)
Global $H_RunUserCallTipMgr = GUICtrlCreateButton("Run User CallTip Manager", 20, 80, 200, 30)
Global $H_RunRegistry_Check = GUICtrlCreateButton("Run AutoIt3/SciTE check", 20, 120, 200, 30)
Global $H_Edit_AutoIt3WrapperINI = GUICtrlCreateButton("Open AutoIt3Wrapper.ini", 20, 160, 200, 30)
Global $H_Edit_TidyINI = GUICtrlCreateButton("Open Tidy.ini", 20, 200, 200, 30)
;
GUICtrlCreateTabItem("") ; end tabitem definition
;########## End tabs
$BaseY = 495
Global $g_idStatus_Msg = GUICtrlCreateLabel("", 10, $BaseY, 390, 14, $SS_SUNKEN)
GUICtrlSetBkColor(-1, 0xC0C0C0)
Global $g_idStatus_Msg_FileFullPath = GUICtrlCreateLabel("", 10, $BaseY + 17, 390, 15, $SS_SUNKEN)
GUICtrlSetBkColor(-1, 0xC0C0C0)
GUICtrlSetData(-1, $SciTEUserDir & "\SciTEUser.properties")
Global $H_Update = GUICtrlCreateButton("Save+Apply", 10, $BaseY + 35, 70)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetTip(-1, "Show changes in SciTE and save to SciTEUser.properties")
Global $H_NewScheme = GUICtrlCreateButton("Change Scheme", 90, $BaseY + 35, 100)
GUICtrlSetTip(-1, "Select a new Color&Font Scheme.")
GUICtrlSetState($H_NewScheme, $GUI_HIDE)
Global $H_Exit = GUICtrlCreateButton("Exit", 200, $BaseY + 35, 50) ; #######################################
Global $H_About = GUICtrlCreateButton("About", 350, $BaseY + 35, 50) ; #######################################
;~ $H_SciTE4AutoIT3Updates = GUICtrlCreateButton("Check for SciTE4Autoit3 Updates", 230, 490, 170)
;~ GUICtrlSetTip(-1, "Check for avaliable update for SciTE4AutoIT3")
GUISetState(@SW_SHOW)
; Process GUI Input
;-------------------------------------------------------------------------------------------
While 1
	Global $Msg = GUIGetMsg()
	;Sleep(10)
	If $Msg = $H_Exit Or $Msg = -3 Then
		If $SaveNeeded Then
			If 6 = MsgBox(4 + 262144, 'SciTE Config', 'Do you want to save the changes you made?') Then
				Update_SciTE_User()
				Reload_Config()
			EndIf
		EndIf
		Exit
	EndIf
	If $Msg = $H_About Then
		MsgBox(262208, "SciTEConfig v" & $VERSION, _
				"SciTEUser.Properties:""" & $SciTEUserDir & """" & @CRLF & @CRLF & "Copyright (c) Jos van der Zande.")
	EndIf
	If $Msg < 0 Then ContinueLoop
	; Cancel clicked
	Select
		Case $Msg = $h_tab
			Switch GUICtrlRead($h_tab)
				Case 2
					GUICtrlSetState($H_NewScheme, $GUI_SHOW)
				Case Else
					GUICtrlSetState($H_NewScheme, $GUI_HIDE)
			EndSwitch
		Case $Msg = $H_RunAbbrevMgr
			GUISetState(@SW_HIDE)
			_AbbrevManager()
			GUISetState(@SW_SHOW, $hSciTEConfig_GUI)
		Case $Msg = $H_RunUserCallTipMgr
			GUISetState(@SW_HIDE)
			_CallTipManager()
			GUISetState(@SW_SHOW, $hSciTEConfig_GUI)
		Case $Msg = $H_RunRegistry_Check
			GUISetState(@SW_HIDE)
			_Check_Au3_Registry()
			GUISetState(@SW_SHOW, $hSciTEConfig_GUI)
		Case $Msg = $H_Edit_AutoIt3WrapperINI
			GUISetState(@SW_HIDE)
			SendSciTE_Command(0, $SciTE_hwnd, "open:" & StringReplace($SciTEUserDir & "\AutoIt3Wrapper\AutoIt3Wrapper.ini", "\", "\\"))
			GUISetState(@SW_SHOW, $hSciTEConfig_GUI)
		Case $Msg = $H_Edit_TidyINI
			GUISetState(@SW_HIDE)
			SendSciTE_Command(0, $SciTE_hwnd, "open:" & StringReplace($SciTEUserDir & "\Tidy\Tidy.ini", "\", "\\"))
			GUISetState(@SW_SHOW, $hSciTEConfig_GUI)
		Case $Msg = $H_Update
			Update_SciTE_User()
			Reload_Config()
			Update_status("Configuration updated and reloaded.")
			Create_IncludeFile_AutoComplete()
			$NeedsSave = 0
			$SaveNeeded = 0
			GUICtrlSetState($H_Update, $GUI_DISABLE)
;~ 			MsgBox(262144 + 48, "SciTE config", "Updated Configuration")
			;
		Case $Msg = $H_NewScheme
			SelectNewScheme()
			Reload_Config()
			Get_Current_config()
			Update_Window()
			ContinueLoop
			;
		Case $Msg = $h_Edit
			RunReqAdmin("RegWrite('HKEY_CLASSES_ROOT\AutoIt3Script\Shell', '', 'REG_SZ', 'Open')")
			RunReqAdmin("RegWrite('HKEY_CLASSES_ROOT\AutoIt3ScriptBeta\Shell', '', 'REG_SZ', 'Open')")
			Update_status('Updated registry default to Open.')
			;
		Case $Msg = $h_Run
			RunReqAdmin("RegWrite('HKEY_CLASSES_ROOT\AutoIt3Script\Shell', '', 'REG_SZ', 'Run')")
			RunReqAdmin("RegWrite('HKEY_CLASSES_ROOT\AutoIt3ScriptBeta\Shell', '', 'REG_SZ', 'Run')")
			Update_status('Updated registry default to Run.')
		Case $Msg = $H_ProperCase
			$NeedsSave = 1
		Case $Msg = $H_InLineError_Display
			$ShowState = $GUI_DISABLE
			If GUICtrlRead($H_InLineError_Display) = 1 Then ; $GUI_CHECKED
				$ShowState = $GUI_ENABLE
			EndIf
			For $i = $H_InLineWarning_Label To $H_InLineError_BkColor
				GUICtrlSetState($i, $ShowState)
			Next
			$NeedsSave = 1
			;
		Case $Msg = $h_Backups
			$NeedsSave = 1
			;
		Case $Msg = $h_UserIncludeDirectory
			$NeedsSave = 1
		Case $Msg = $h_UserIncludeDirectory_Button
			GUISetState(@SW_HIDE)
			Global $NewDir = FileSelectFolder("Select the User Include folder:", "", 4, GUICtrlRead($h_UserIncludeDirectory))
			If @error = 0 Then
				GUICtrlSetData($h_UserIncludeDirectory, $NewDir)
				$NeedsSave = 1
			EndIf
			GUISetState(@SW_SHOW)
			;
		Case $Msg = $H_Use_Tabs
			$Use_Tabs = Not $Use_Tabs
			$NeedsSave = 1
		Case $Msg = $H_Syn_Mono Or $Msg = $H_Syn_Prop
			$SYN_Font_Mono_ON = Not $SYN_Font_Mono_ON
			Update_Window()
			$NeedsSave = 1
			;
		Case $Msg = $H_Syn_Mono_Change
			Global $Return = Select_Font($SYN_Font_Mono_Type, $SYN_Font_Mono_Size)
			Update_Window()
			$NeedsSave = 1
			;
		Case $Msg = $H_Syn_Prop_Change
			$Return = Select_Font($SYN_Font_Prop_Type, $SYN_Font_Prop_Size)
			Update_Window()
			$NeedsSave = 1
			;
		Case $Msg = $H_Current_Highlight
			$ShowState = $GUI_DISABLE
			If GUICtrlRead($H_Current_Highlight) = 1 Then ; $GUI_CHECKED
				$ShowState = $GUI_ENABLE
			EndIf
			For $i = $H_Current_AutoSel To $H_CurrentHiLight_Alpha
				GUICtrlSetState($i, $ShowState)
			Next
			$NeedsSave = 1
			;
		Case $Msg = $H_Current_AutoSel
			$Current_Autoselect = 0
			If GUICtrlRead($H_Current_AutoSel) = 1 Then ; GUI_Checked
				$Current_Autoselect = 1
			EndIf
			$NeedsSave = 1
			;
		Case $Msg = $H_Current_Wholeword
			$Current_Wholeword = 0
			If GUICtrlRead($H_Current_Wholeword) = 1 Then ; GUI_Checked
				$Current_Wholeword = 1
			EndIf
			$NeedsSave = 1
			;
		Case $Msg = $H_Current_Style
			$Current_Style = 0
			If GUICtrlRead($H_Current_Style) = 1 Then ; GUI_Checked
				$Current_Style = 1
			EndIf
			$NeedsSave = 1
			;
		Case $Msg = $H_Current_Case
			$Current_Case = 0
			If GUICtrlRead($H_Current_Case) = 1 Then ; GUI_Checked
				$Current_Case = 1
			EndIf
			$NeedsSave = 1
			;
		Case $Msg = $H_CallTip_Above
			$CallTip_Above = 0
			If GUICtrlRead($H_CallTip_Above) = 1 Then ; GUI_Checked
				$CallTip_Above = 1
			EndIf
			$NeedsSave = 1
			;
		Case $Msg = $H_Background_Color
			Global $tempcolor = SelectColor($Background_Color)
			If $tempcolor >= 0 Then $Background_Color = $tempcolor
			Update_Window()
			$NeedsSave = 1
			;
		Case $Msg = $H_CaretLine_BkColor
			$tempcolor = SelectColor($CaretLine_BkColor)
			If $tempcolor >= 0 Then $CaretLine_BkColor = $tempcolor
			GUICtrlSetBkColor($H_CaretLine_Label, _AlphaFactor($CaretLine_BkColor, $CaretLine_BkColor_Alpha))
			;GUICtrlSetData($H_CaretLine_Label, "Caret line Color: " & StringLower($CaretLine_BkColor))
			$NeedsSave = 1
			;
		Case $Msg = $H_Selection_Color
			$tempcolor = SelectColor($Selection_Color)
			If $tempcolor >= 0 Then $Selection_Color = $tempcolor
			GUICtrlSetColor($H_Selection_Label, $Selection_Color)
			$NeedsSave = 1
			;
		Case $Msg = $H_Selection_BkColor
			$tempcolor = SelectColor($Selection_BkColor)
			If $tempcolor >= 0 Then $Selection_BkColor = $tempcolor
			GUICtrlSetBkColor($H_Selection_Label, _AlphaFactor($Selection_BkColor, $Selection_Alpha))
			$NeedsSave = 1
			;
		Case $Msg = $H_InLineDefault_Color
			$tempcolor = SelectColor($InLineDefault_Color)
			If $tempcolor >= 0 Then $InLineDefault_Color = $tempcolor
			GUICtrlSetColor($H_InLineDefault_Label, $InLineDefault_Color)
			$NeedsSave = 1
			;
		Case $Msg = $H_InLineDefault_BkColor
			$tempcolor = SelectColor($InLineDefault_BkColor)
			If $tempcolor >= 0 Then $InLineDefault_BkColor = $tempcolor
			GUICtrlSetBkColor($H_InLineDefault_Label, $InLineDefault_BkColor)
			$NeedsSave = 1
			;
		Case $Msg = $H_InLineWarning_Color
			$tempcolor = SelectColor($InLineWarning_Color)
			If $tempcolor >= 0 Then $InLineWarning_Color = $tempcolor
			GUICtrlSetColor($H_InLineWarning_Label, $InLineWarning_Color)
			$NeedsSave = 1
			;
		Case $Msg = $H_InLineWarning_BkColor
			$tempcolor = SelectColor($InLineWarning_BkColor)
			If $tempcolor >= 0 Then $InLineWarning_BkColor = $tempcolor
			GUICtrlSetBkColor($H_InLineWarning_Label, $InLineWarning_BkColor)
			$NeedsSave = 1
			;
		Case $Msg = $H_InLineError_Color
			$tempcolor = SelectColor($InLineError_Color)
			If $tempcolor >= 0 Then $InLineError_Color = $tempcolor
			GUICtrlSetColor($H_InLineError_Label, $InLineError_Color)
			$NeedsSave = 1
			;
		Case $Msg = $H_InLineError_BkColor
			$tempcolor = SelectColor($InLineError_BkColor)
			If $tempcolor >= 0 Then $InLineError_BkColor = $tempcolor
			GUICtrlSetBkColor($H_InLineError_Label, $InLineError_BkColor)
			$NeedsSave = 1
			;
		Case $Msg = $H_CurrentHilight_Color
			$tempcolor = SelectColor($CurrentHilight_Color)
			If $tempcolor >= 0 Then $CurrentHilight_Color = $tempcolor
			GUICtrlSetBkColor($H_CurrentHilight_Label, _AlphaFactor($CurrentHilight_Color, $Current_Alpha))
			$NeedsSave = 1
			;
		Case $Msg = $H_CallTip_Color
			$tempcolor = SelectColor($CallTip_Color)
			If $tempcolor >= 0 Then $CallTip_Color = $tempcolor
			GUICtrlSetColor($H_CallTip_Label, $CallTip_Color)
			$NeedsSave = 1
			;
		Case $Msg = $H_CallTip_BkColor
			$tempcolor = SelectColor($CallTip_BkColor)
			If $tempcolor >= 0 Then $CallTip_BkColor = $tempcolor
			GUICtrlSetBkColor($H_CallTip_Label, $CallTip_BkColor)
			GUICtrlSetBkColor($H_ParamHilite_Label, $CallTip_BkColor)
			$NeedsSave = 1
			;
		Case $Msg = $H_ParamHilite_Color
			$tempcolor = SelectColor($ParamHilite_Color)
			If $tempcolor >= 0 Then $ParamHilite_Color = $tempcolor
			GUICtrlSetColor($H_ParamHilite_Label, $ParamHilite_Color)
			$NeedsSave = 1
			;
	EndSelect
	; Check if one of the checkboxes is clicked
	For $x = 1 To 17
		If $Msg = $H_Syn_bColor_Standard[$x] Then
			$Syn_bColor_Default[$x] = GUICtrlRead($H_Syn_bColor_Standard[$x])
			If GUICtrlRead($H_Syn_bColor_Standard[$x]) = $GUI_CHECKED Then
				GUICtrlSetState($H_Syn_bColor[$x], $GUI_DISABLE)
				$Syn_bColor[$x] = $Background_Color
				GUICtrlSetBkColor($H_Syn_Label[$x], $Syn_bColor[$x])
			Else
				GUICtrlSetState($H_Syn_bColor[$x], $GUI_ENABLE)
			EndIf
			$NeedsSave = 1
		EndIf
		If $Msg = $H_Syn_Bold[$x] Then
			$Syn_Bold[$x] = Not $Syn_Bold[$x]
			$NeedsSave = 1
		EndIf
		If $Msg = $H_Syn_Italic[$x] Then
			$Syn_Italic[$x] = Not $Syn_Italic[$x]
			$NeedsSave = 1
		EndIf
		If $Msg = $H_Syn_Underline[$x] Then
			$Syn_Underline[$x] = Not $Syn_Underline[$x]
			$NeedsSave = 1
		EndIf
		If $Msg = $H_Syn_fColor[$x] Then
			$tempcolor = SelectColor($Syn_fColor[$x])
			$Syn_fColor[$x] = $tempcolor
			GUICtrlSetColor($H_Syn_Label[$x], $Syn_fColor[$x])
			$NeedsSave = 1
		EndIf
		If $Msg = $H_Syn_bColor[$x] Then
			$tempcolor = SelectColor($Syn_bColor[$x])
			$Syn_bColor[$x] = $tempcolor
			GUICtrlSetBkColor($H_Syn_Label[$x], $Syn_bColor[$x])
			$NeedsSave = 1
		EndIf
		If $Msg = $H_Syn_Bold[$x] Or $Msg = $H_Syn_Italic[$x] Or $Msg = $H_Syn_Underline[$x] _
				Or $Msg = $H_Syn_fColor[$x] Or $Msg = $H_Syn_bColor[$x] Then
			GUICtrlSetFont($H_Syn_Label[$x], $SYN_Font_Size, 400 + $Syn_Bold[$x] * 200, $Syn_Italic[$x] * 2 + $Syn_Underline[$x] * 4, $SYN_Font_Type)
			$NeedsSave = 1
		EndIf
	Next
	; Check if tools are clicked
	For $i = 1 To $SciTETools[0]
		If $Msg = $checkbox[$i] Then
			$NeedsSave = 1
		EndIf
	Next
	; I would normally look for EN_CHANGE but thought this was less complicated
	If GUICtrlRead($H_Selection_Alpha) <> $Selection_Alpha Then
		$Selection_Alpha = GUICtrlRead($H_Selection_Alpha)
		GUICtrlSetBkColor($H_Selection_Label, _AlphaFactor($Selection_BkColor, $Selection_Alpha))
		GUICtrlSetColor($H_Selection_Label, _AlphaFactorForeground($Selection_Color, $Selection_BkColor, $Selection_Alpha))
		$NeedsSave = 1
	EndIf
	If GUICtrlRead($H_CaretLine_BkAlpha) <> $CaretLine_BkColor_Alpha Then
		$CaretLine_BkColor_Alpha = GUICtrlRead($H_CaretLine_BkAlpha)
		GUICtrlSetBkColor($H_CaretLine_Label, _AlphaFactor($CaretLine_BkColor, $CaretLine_BkColor_Alpha))
		GUICtrlSetColor($H_CaretLine_Label, _AlphaFactorForeground(0x000000, $CaretLine_BkColor, $CaretLine_BkColor_Alpha))
		$NeedsSave = 1
	EndIf
	If GUICtrlRead($H_CurrentHiLight_Alpha) <> $Current_Alpha Then
		$Current_Alpha = GUICtrlRead($H_CurrentHiLight_Alpha)
		GUICtrlSetBkColor($H_CurrentHilight_Label, _AlphaFactor($CurrentHilight_Color, $Current_Alpha))
		$NeedsSave = 1
	EndIf
	If GUICtrlRead($H_Current_MinLength) <> $Current_Minlength Then
		$Current_Minlength = GUICtrlRead($H_Current_MinLength)
		$NeedsSave = 1
	EndIf
	If GUICtrlRead($H_SearchMargin) <> $SearchMargin Then
		$SearchMargin = GUICtrlRead($H_SearchMargin)
		$NeedsSave = 1
	EndIf
	If GUICtrlRead($h_Backups) <> $Backups Then
		$Backups = GUICtrlRead($h_Backups)
		$NeedsSave = 1
	EndIf ; Set the save button
	If $NeedsSave Then
		Update_status('Change made. Press Save+Apply to store in SciTEUser properties.')
		GUICtrlSetState($H_Update, $GUI_ENABLE)
		$NeedsSave = 0
		$SaveNeeded = 1
	EndIf
WEnd
Exit
#EndRegion ; GUI
#Region ; Funcs
; This was my best attempt at getting the alpha value to correctly affect the background colour as it does in SciTE
Func _AlphaFactor($Colour, $iAlpha)
	;
	If $iAlpha = 256 Then
		Return $Colour
	EndIf
	;
	Local $iFactor = (255 - $iAlpha) / 255 + 0.0001 ; The .8 is a fudge to make the colour look right - probably a monitor thing
	Local $aColours[3]
	Local $iRed = _ColorGetRed($Colour)
	Local $iGreen = _ColorGetGreen($Colour)
	Local $iBlue = _ColorGetBlue($Colour)
	Local $Inc
	$Inc = (0xFF - $iRed) * $iFactor
	$aColours[0] = $iRed + $Inc
	$Inc = (0xFF - $iGreen) * $iFactor
	$aColours[1] = $iGreen + $Inc
	$Inc = (0xFF - $iBlue) * $iFactor
	$aColours[2] = $iBlue + $Inc
	Return _ColorSetRGB($aColours)
EndFunc   ;==>_AlphaFactor
Func _AlphaFactorForeground($Colour, $bcolour, $iAlpha)
	;
	If $iAlpha = 256 Then
		Return $Colour
	EndIf
	;
	Local $iFactor = $iAlpha ; The .8 is a fudge to make the colour look right - probably a monitor thing
	Local $aColours[3]
	Local $iRed = _ColorGetRed($Colour)
	Local $iGreen = _ColorGetGreen($Colour)
	Local $iBlue = _ColorGetBlue($Colour)
	Local $ibRed = _ColorGetRed($bcolour)
	Local $ibGreen = _ColorGetGreen($bcolour)
	Local $ibBlue = _ColorGetBlue($bcolour)
	Local $Inc = ($ibRed - $iRed) / 255 * $iFactor
	$aColours[0] = $iRed + $Inc
	$Inc = ($ibGreen - $iGreen) / 255 * $iFactor
	$aColours[1] = $iGreen + $Inc
	$Inc = ($ibBlue - $iBlue) / 255 * $iFactor
	$aColours[2] = $iBlue + $Inc
	Return _ColorSetRGB($aColours)
EndFunc   ;==>_AlphaFactorForeground
;
Func Write_installlog($text)
	FileWrite(@ScriptDir & "\..\install-includes.log",$text)
EndFunc
Func Create_IncludeFile_AutoComplete()
	if $SciTEUserDirInstall <> "" then $SciTEUserDir = $SciTEUserDirInstall
	Local $IncludeFile = $SciTEUserDir & "\includes.txt"
	Local $Fhinc = FileOpen($IncludeFile, 2)
	Local $UserIncludeDirs = StringSplit(RegRead("HKEY_CURRENT_USER\SOFTWARE\AutoIt v3\AutoIt", "Include"), ";")
	If $AutoIT3_Dir = "" Or Not FileExists($AutoIT3_Dir) Then
		Write_installlog("! Error: AutoIt3 directory empty (" & $AutoIT3_Dir & ")or none existent so can't create " & $IncludeFile & @CRLF)
		Return
	EndIf
	; First get the standard Includes
	Local $hSearch = FileFindFirstFile($AutoIT3_Dir & "\include\*.au3")
	If $hSearch = -1 Then
		; Directory not found?
		Write_installlog("! Error: No include files found in " & $AutoIT3_Dir & "\include\*.au3, so no valid " & $IncludeFile & @CRLF)
	Else
		; Assign a Local variable the empty string which will contain the files names found.
		Local $sFileName = ""
		Write_installlog("- Adding include files found in " & $AutoIT3_Dir & "\include\*.au3 to " & $IncludeFile & @CRLF)
		While 1
			$sFileName = FileFindNextFile($hSearch)
			; If there is no more file matching the search.
			If @error Then ExitLoop
			; Display the file name.
			FileWriteLine($Fhinc, $sFileName)
		WEnd
		; Close the search handle.
		FileClose($hSearch)
	EndIf
	; Then get the User Includes
	For $x = 1 To $UserIncludeDirs[0]
		$hSearch = FileFindFirstFile($UserIncludeDirs[$x] & "\*.au3")
		If $hSearch = -1 Then
			; Directory not found?
			Write_installlog("! Warning: No include files found in " & $UserIncludeDirs[$x] & "\*.au3. " & @CRLF)
		Else
			; Assign a Local variable the empty string which will contain the files names found.
			$sFileName = ""
			Write_installlog("- Adding include files found in " & $UserIncludeDirs[$x] & "\*.au3 to " & $IncludeFile & @CRLF)
			While 1
				$sFileName = FileFindNextFile($hSearch)
				; If there is no more file matching the search.
				If @error Then ExitLoop
				; Display the file name.
				FileWriteLine($Fhinc, $sFileName)
			WEnd
			; Close the search handle.
			FileClose($hSearch)
		EndIf
	Next
	FileClose($Fhinc)
EndFunc   ;==>Create_IncludeFile_AutoComplete
;
Func Get_Current_config()
	Local $z, $y, $x, $Style
	; Init background colors
	$Background_Color = "0xffffff"
	$CaretLine_BkColor = "0xFF0000"
	$CaretLine_BkColor_Alpha = 256
	$Selection_Color = ""
	$Selection_BkColor = ""
	$Selection_Alpha = 50
	; init array
	For $z = 1 To 17
		$Syn_fColor[$z] = "0x000000"
		$Syn_bColor[$z] = ""
		$Syn_Bold[$z] = 0
		$Syn_Italic[$z] = 0
		$Syn_Underline[$z] = 0
	Next
	;
	$Backups = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:backup.files"))
	$ProperCase = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:proper.case"))
	$ErrorInline = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:error.inline"))
;~ 	$CheckuUpdatesSciTE4AutoIt3 = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:check.updates.scite4autoit3"))
	$Use_Tabs = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:use.tabs"))
	$Tab_Size = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:tabsize"))
	$Current_Highlight = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:highlight.current.word"))
	$Current_Style = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:highlight.current.word.by.style"))
	$Current_Autoselect = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:highlight.current.word.autoselectword"))
	$Current_Wholeword = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:highlight.current.word.wholeword"))
	$Current_Case = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:highlight.current.word.matchcase"))
	$Current_Minlength = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:highlight.current.word.minlength"))
	;
	Local $rest = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:style.au3.32")
	If StringInStr($rest, "back:") Then
		$Background_Color = StringTrimLeft($rest, StringInStr($rest, "back:") + 4)
		$Background_Color = Get_HexColor($Background_Color)
	EndIf
	If $Background_Color = "" Then
		$rest = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:style.*.32")
		If StringInStr($rest, "back:") Then
			$Background_Color = StringTrimLeft($rest, StringInStr($rest, "back:") + 4)
			$Background_Color = Get_HexColor($Background_Color)
		EndIf
	EndIf
	$Selection_Color = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:selection.fore")
	$Selection_Color = Get_HexColor($Selection_Color)
	$Selection_BkColor = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:selection.back")
	$Selection_BkColor = Get_HexColor($Selection_BkColor)
	$Selection_Alpha = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:selection.alpha"))
	Local $InLineDefault_Prop = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:style.error.0")
	$InLineDefault_Color = "0X" & StringRegExpReplace($InLineDefault_Prop, ".*fore:#(.{6}).*", "$1")
	$InLineDefault_BkColor = "0X" & StringRegExpReplace($InLineDefault_Prop, ".*back:#(.{6}).*", "$1")
	Local $InLineWarning_Prop = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:style.error.1")
	$InLineWarning_Color = "0X" & StringRegExpReplace($InLineWarning_Prop, ".*fore:#(.{6}).*", "$1")
	$InLineWarning_BkColor = "0X" & StringRegExpReplace($InLineWarning_Prop, ".*back:#(.{6}).*", "$1")
	Local $InLineError_Prop = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:style.error.2")
	$InLineError_Color = "0X" & StringRegExpReplace($InLineError_Prop, ".*fore:#(.{6}).*", "$1")
	$InLineError_BkColor = "0X" & StringRegExpReplace($InLineError_Prop, ".*back:#(.{6}).*", "$1")
	$CurrentHilight_Color = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:highlight.current.word.colour")
	$CurrentHilight_Color = Get_HexColor($CurrentHilight_Color)
	$Current_Alpha = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:indicators.alpha"))
	Local $CallTip_Prop = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:style.au3.38")
	$CallTip_Color = "0X" & StringRegExpReplace($CallTip_Prop, ".*fore:#(.{6}).*", "$1")
	$CallTip_BkColor = "0X" & StringRegExpReplace($CallTip_Prop, ".*back:#(.{6}).*", "$1")
	$ParamHilite_Color = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:calltips.color.highlight")
	$ParamHilite_Color = Get_HexColor($ParamHilite_Color)
	$CaretLine_BkColor_Alpha = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:caret.line.back.alpha")
	If $CaretLine_BkColor_Alpha = "" Then $CaretLine_BkColor_Alpha = 256
	$CaretLine_BkColor = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:caret.line.back")
	$CaretLine_BkColor = Get_HexColor($CaretLine_BkColor)
	For $StyleNbr = 1 To 17
		$rest = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:style.au3." & $StyleNbr - 1)
		$Style = StringSplit(StringTrimLeft($rest, StringInStr($rest, "=")), ",")
		$Syn_Italic[$StyleNbr] = 0
		$Syn_Bold[$StyleNbr] = 0
		$Syn_Underline[$StyleNbr] = 0
		For $y = 1 To $Style[0]
			If $Style[$y] = "italics" Then $Syn_Italic[$StyleNbr] = 1
			If $Style[$y] = "bold" Then $Syn_Bold[$StyleNbr] = 1
			If $Style[$y] = "underlined" Then $Syn_Underline[$StyleNbr] = 1
			If StringLeft($Style[$y], 5) = "fore:" Then $Syn_fColor[$StyleNbr] = Get_HexColor($Style[$y])
			If StringLeft($Style[$y], 5) = "back:" Then $Syn_bColor[$StyleNbr] = Get_HexColor($Style[$y])
		Next
	Next
	$SearchMargin = Number(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:visible.policy.lines"))
	$CallTip_Above = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:calltips.set.above")
	; get the windows font section
	;font.base=font:Verdana,size:10,$(font.override)
	$rest = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:font.base")
	Local $param = StringSplit($rest, "=,")
	For $y = 1 To $param[0]
		If StringLeft($param[$y], 5) = "font:" Then $SYN_Font_Prop_Type = StringMid($param[$y], 6)
		If StringLeft($param[$y], 5) = "size:" Then $SYN_Font_Prop_Size = StringMid($param[$y], 6)
	Next
	;font.monospace=font:Courier New,size:10
	$rest = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:font.monospace")
	$param = StringSplit($rest, "=,")
	For $y = 1 To $param[0]
		If StringLeft($param[$y], 5) = "font:" Then $SYN_Font_Mono_Type = StringMid($param[$y], 6)
		If StringLeft($param[$y], 5) = "size:" Then $SYN_Font_Mono_Size = StringMid($param[$y], 6)
	Next
	;font.override=$(font.monospace)
	;font.base=font:Verdana,size:10,$(font.override)
	$rest = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:font.base")
	If StringInStr($rest, "$(font.override)") Then
		$SYN_Font_Mono_ON = 1
	Else
		$SYN_Font_Mono_ON = 0
	EndIf
	;******************************************************************************************************
	$Syn_Label[1] = "White space"
	$Syn_Label[2] = "Comment line"
	$Syn_Label[3] = "Comment block"
	$Syn_Label[4] = "Number"
	$Syn_Label[5] = "Function"
	$Syn_Label[6] = "Keyword"
	$Syn_Label[7] = "Macro"
	$Syn_Label[8] = "String"
	$Syn_Label[9] = "Operator"
	$Syn_Label[10] = "Variable"
	$Syn_Label[11] = "Sent keys"
	$Syn_Label[12] = "Pre-Processor"
	$Syn_Label[13] = "Special"
	$Syn_Label[14] = "Abbrev-Expand"
	$Syn_Label[15] = "Com Objects"
	$Syn_Label[16] = "Standard UDF's"
	$Syn_Label[17] = "User UDF's"
	; set the default background
	For $x = 1 To 17
		If $Syn_bColor[$x] = "" Or $Syn_bColor[$x] = $Background_Color Then
			$Syn_bColor[$x] = $Background_Color
			$Syn_bColor_Default[$x] = $GUI_CHECKED
		EndIf
	Next
EndFunc   ;==>Get_Current_config
; Convert #color to 0Xcolor
Func Get_HexColor($sField)
	Local $n = StringInStr($sField, ":#")
	$sField = StringReplace(StringMid($sField, $n + 1), "#", "0X", 1)
	$sField = StringRegExpReplace($sField, "[\\t]*[\s]*[;#].*", "")
	Return $sField
EndFunc   ;==>Get_HexColor
; Received Data from SciTE
Func MY_WM_COPYDATA($hWnd, $Msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $wParam
	Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr', $lParam)
	Local $SciTECmdLen = DllStructGetData($COPYDATA, 2)
	Local $CmdStruct = DllStructCreate('Char[255]', DllStructGetData($COPYDATA, 3))
	$SciTECmd = StringLeft(DllStructGetData($CmdStruct, 1), $SciTECmdLen)
	;ConsoleWrite('<--' & $SciTECmd & @lf )
	;GUICtrlSetData($list,GUICtrlRead($list) & '<--' & $SciTECmd & @CRLF )
EndFunc   ;==>MY_WM_COPYDATA
;
Func Reload_Config()
	Opt("WinSearchChildren", 1)
	;Send SciTE Director my GUI handle so it will report info back from SciTE
	SendSciTE_Command(0, $SciTE_hwnd, "reloadproperties:")
EndFunc   ;==>Reload_Config
;
Func Reset_Status()
	GUICtrlSetBkColor($g_idStatus_Msg, 0xF9FEB8)
	AdlibUnRegister("Reset_Status")
EndFunc   ;==>Reset_Status
;
Func RunReqAdmin($Autoit3Commands, $prompt = 1)
	Local $temp_Script = _TempFile(@TempDir, "~", ".au3")
	Local $temp_check = _TempFile(@TempDir, "~", ".chk")
	FileWriteLine($temp_check, 'TempFile')
	FileWriteLine($temp_Script, '#NoTrayIcon')
	If Not IsAdmin() Then
		FileWriteLine($temp_Script, '#RequireAdmin')
		If $prompt = 1 Then MsgBox(262144, "Need Admin mode", "Admin mode is needed for this update. Answer the following prompts to allow the update.")
	EndIf
	FileWriteLine($temp_Script, $Autoit3Commands)
	FileWriteLine($temp_Script, "FileDelete('" & $temp_check & "')")
	If @Compiled Then
		RunWait('"' & @ScriptFullPath & '" /AutoIt3ExecuteScript "' & $temp_Script & '"')
	Else
		RunWait('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $temp_Script & '"')
	EndIf
	; Wait for the script to finish
	While FileExists($temp_check)
		Sleep(50)
	WEnd
	FileDelete($temp_Script)
EndFunc   ;==>RunReqAdmin
;
Func SciTE_Update_Property($My_Hwnd, $SciTE_hwnd, $key, $value)
	$My_Dec_Hwnd = Dec(StringTrimLeft($My_Hwnd, 2))
	Local $sCmd = ":" & $My_Dec_Hwnd & ":" & "property:" & $key & "=" & $value
	SendSciTE_Command($My_Hwnd, $SciTE_hwnd, $sCmd)
EndFunc   ;==>SciTE_Update_Property
; Tools Selection Tab related
Func SciteToolsFileRead($file_au3properties)
	Local $comment = '#~ ', $handle_read, $line, $split, $total
	; Open Au3.properties for Read
	$handle_read = FileOpen($file_au3properties, 0)
	If $handle_read = -1 Then
		ConsoleWrite('Unable to open for read ' & $file_au3properties & @CRLF)
		Return SetError(1, 0, '')
	EndIf
	; Read Tools headers from Au3.properties
	While True
		$line = FileReadLine($handle_read)
		If @error Then ExitLoop
		$line = StringStripWS($line, 3)
		If Not $line Then
			ContinueLoop
		ElseIf StringRegExp($line, $comment & '# [0-9]{1,2}') Or StringRegExp($line, '# [0-9]{1,2}') Then
			$total &= $line & '|'
		EndIf
	WEnd
	FileClose($handle_read)
	; Remove last pipe char
	If StringRight($total, 1) = '|' Then
		$total = StringTrimRight($total, 1)
	EndIf
	; Split Tools headers into an Array
	$split = StringSplit($total, '|')
	Return SetError(@error, @extended, $split)
EndFunc   ;==>SciteToolsFileRead
;*****************************************************************************
; Font Selection part
;*****************************************************************************
Func Select_Font(ByRef $FontType, ByRef $FontSize)
	Local $a_font
	GUISetState(@SW_HIDE)
	$a_font = _ChooseFont($FontType, $FontSize)
	Local $rc = @error
	GUISetState(@SW_SHOW)
	If ($rc) Then Return 0
	$FontType = $a_font[2]
	$FontSize = $a_font[3]
	Return 1
EndFunc   ;==>Select_Font
;*****************************************************************************
; Color Selection Part
;*****************************************************************************
Func SelectColor($CurColor)
	Local $color
	GUISetState(@SW_HIDE)
	$color = _ChooseColor(2, $CurColor, 2)
	Local $rc = @error
	GUISetState(@SW_SHOW)
	If ($rc) Then Return $CurColor
	Return $color
EndFunc   ;==>SelectColor
;
Func SelectNewScheme()
	; Find all default scheme's
	Local $Schemes = " [NoChange]"
	Local $s_name
	Local $search = FileFindFirstFile($SciTEConfig_UserData & "\*.SciTEConfig")
	; Check if the search was successful
	If $search = -1 Then
		; No default schema's found so just remove the personal and revert to the au3.properties.
		Update_status('There are no *.SciTEConfig files available!', 0xFF0000)
;~ 		MsgBox(262144, 'SciTE Config', 'There are no *.SciTEConfig files available.')
		Return
	EndIf
	;
	While 1
		Local $file = FileFindNextFile($search)
		If @error Then ExitLoop
		$s_name = StringMid(FileReadLine($SciTEConfig_UserData & "\" & $file, 3), 3)
		If StringLeft($file, 2) = "[L" Then
			$Schemes &= "| " & StringReplace($file, ".SciteConfig", "") & " ==> Last modified User"
		Else
			$Schemes &= "|" & StringReplace($file, ".SciteConfig", "") & " ==> " & $s_name
		EndIf
	WEnd
	;
	FileClose($search)
	;
	Local $gui2 = GUICreate("Select new default Color/Font Scheme", 500, 100, -1, -1, $WS_CAPTION, $WS_EX_TOPMOST)
	GUICtrlCreateLabel("Select new default Color/Font Scheme.", 30, 10)
	Local $h_Scheme = GUICtrlCreateCombo("", 30, 35, 460, 80, $CBS_DROPDOWN + $CBS_AUTOHSCROLL + $WS_VSCROLL + $CBS_SORT)
	GUICtrlSetData(-1, $Schemes, " [NoChange]")
	Local $h_Ok = GUICtrlCreateButton("Ok", 155, 60, 80, 33, 0)
	GUICtrlSetState(-1, $GUI_DEFBUTTON)
	Local $h_Cancel = GUICtrlCreateButton("Cancel", 265, 60, 80, 33, 0)
	GUISetState(@SW_SHOW, $gui2)
	Local $rc
	Local $nMsg
	While 1
		$nMsg = GUIGetMsg()
		Select
			Case $nMsg = $GUI_EVENT_CLOSE Or $nMsg = $h_Cancel
				$rc = 9
				ExitLoop
			Case $nMsg = $h_Ok
				$rc = 1
				ExitLoop
		EndSelect
	WEnd
	Local $SchemeFile = GUICtrlRead($h_Scheme)
	GUIDelete($gui2)
	;
	If $rc = 9 Then Return
	;
	If StringInStr($SchemeFile, " ==> ") Then $SchemeFile = StringLeft($SchemeFile, StringInStr($SchemeFile, " ==> ") - 1) & ".SciteConfig"
	If $SchemeFile = " [NoChange]" Then Return
	;
	$SchemeFile = StringStripWS($SchemeFile, 3)
	Local $H_au3PropScheme = FileOpen($SciTEConfig_UserData & "\" & $SchemeFile, 0)
	; Update the SciTEUser Info
	Local $Irec, $Prop_KeyWord, $Prop_KeyWordVal
	If $H_au3PropScheme <> -1 Then
		While 1
			$Irec = FileReadLine($H_au3PropScheme)
			If @error = -1 Then ExitLoop
			If StringLeft($Irec, 1) <> "#" And StringInStr($Irec, "=") Then
				$Prop_KeyWord = StringLeft($Irec, StringInStr($Irec, "=") - 1)
				$Prop_KeyWordVal = StringMid($Irec, StringInStr($Irec, "=") + 1)
				Update_SciTE_UserContent("Update", $Prop_KeyWord, $Prop_KeyWordVal)
			EndIf
		WEnd
	EndIf
	Update_SciTE_UserContent("Save")
	Update_status('New Scheme is loaded and saved.')
EndFunc   ;==>SelectNewScheme
;
Func SendSciTE_Command($My_Hwnd, $SciTE_hwnd, $sCmd)
	Local $WM_COPYDATA = 74
	Local $CmdStruct = DllStructCreate('Char[' & StringLen($sCmd) + 1 & ']')
	;ConsoleWrite('-->' & $sCmd & @lf )
	DllStructSetData($CmdStruct, 1, $sCmd)
	Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
	DllStructSetData($COPYDATA, 1, 1)
	DllStructSetData($COPYDATA, 2, StringLen($sCmd) + 1)
	DllStructSetData($COPYDATA, 3, DllStructGetPtr($CmdStruct))
	DllCall('User32.dll', 'None', 'SendMessage', 'HWnd', $SciTE_hwnd, _
			'Int', $WM_COPYDATA, 'HWnd', $My_Hwnd, _
			'Ptr', DllStructGetPtr($COPYDATA))
EndFunc   ;==>SendSciTE_Command
;
;
Func SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, $sCmd)
	$My_Dec_Hwnd = Dec(StringTrimLeft($My_Hwnd, 2))
	$sCmd = ":" & $My_Dec_Hwnd & ":" & $sCmd
	$SciTECmd = ""
	SendSciTE_Command($My_Hwnd, $SciTE_hwnd, $sCmd)
	For $x = 1 To 10
		If $SciTECmd <> "" Then ExitLoop
		Sleep(20)
	Next
	$SciTECmd = StringTrimLeft($SciTECmd, StringLen(":" & $My_Dec_Hwnd & ":"))
	$SciTECmd = StringReplace($SciTECmd, "macro:stringinfo:", "")
	Return $SciTECmd
EndFunc   ;==>SendSciTE_GetInfo
;*****************************************************************************
; Save info to SciTEUser
;*****************************************************************************
Func Update_SciTE_User()
	If $SYN_Font_Mono_ON = 1 Then
		Update_SciTE_UserContent("Update", "font.base", "font:" & $SYN_Font_Prop_Type & ",size:" & $SYN_Font_Prop_Size & ",$(font.override)")
	Else
		Update_SciTE_UserContent("Update", "font.base", "font:" & $SYN_Font_Prop_Type & ",size:" & $SYN_Font_Prop_Size)
	EndIf
	Update_SciTE_UserContent("Update", "font.monospace", "font:" & $SYN_Font_Mono_Type & ",size:" & $SYN_Font_Mono_Size)
	;Backup Info
	Update_SciTE_UserContent("Update", "backup.files", "" & $Backups)
	;propercase info
	If GUICtrlRead($H_ProperCase) = 1 Then
		Update_SciTE_UserContent("Update", "proper.case", "1")
	Else
		Update_SciTE_UserContent("Update", "proper.case", "0")
	EndIf
	;Display inline error
	If GUICtrlRead($H_InLineError_Display) = 1 Then
		Update_SciTE_UserContent("Update", "error.inline", "1")
	Else
		Update_SciTE_UserContent("Update", "error.inline", "0")
	EndIf
	; Current word highlight
	If GUICtrlRead($H_Current_Highlight) = 1 Then
		Update_SciTE_UserContent("Update", "highlight.current.word", "1")
		Update_SciTE_UserContent("Update", "highlight.current.word.by.style", $Current_Style)
		Update_SciTE_UserContent("Update", "highlight.current.word.autoselectword", $Current_Autoselect)
		Update_SciTE_UserContent("Update", "highlight.current.word.wholeword", $Current_Wholeword)
		Update_SciTE_UserContent("Update", "highlight.current.word.matchcase", $Current_Case)
		Update_SciTE_UserContent("Update", "highlight.current.word.minlength", $Current_Minlength)
	Else
		Update_SciTE_UserContent("Update", "highlight.current.word", "0")
		; No point in updating other selections
	EndIf
	;Check for updates
;~ 	If GUICtrlRead($H_CheckUpdatesSciTE4AutoIt3) = 1 Then
;~ 		Update_SciTE_UserContent("Update", "check.updates.scite4autoit3","1")
;~ 	Else
;~ 		Update_SciTE_UserContent("Update", "check.updates.scite4autoit3","0")
;~ 	EndIf
	;Tabs info
	If $Use_Tabs = 1 Then
		Update_SciTE_UserContent("Update", "use.tabs", "1")
	Else
		Update_SciTE_UserContent("Update", "use.tabs", "0")
	EndIf
	$Tab_Size = GUICtrlRead($H_Tab_Size)
	If Number($Tab_Size) > 0 Then
		Update_SciTE_UserContent("Update", "indent.size", $Tab_Size)
		Update_SciTE_UserContent("Update", "indent.size.*.au3", $Tab_Size)
		Update_SciTE_UserContent("Update", "tabsize", $Tab_Size)
	EndIf
	; Background color
	Local $Orec = "style.*.32=$(font.base)"
	If $Background_Color <> "" And $Background_Color <> "0XFFFFFF" Then $Orec = $Orec & ",back:#" & StringTrimLeft($Background_Color, 2)
	Update_SciTE_UserContent("Update", "style.au3.32", $Orec)
	; caretline color
	If $CaretLine_BkColor <> "" And $CaretLine_BkColor <> "0XFFFFFF" Then
		Update_SciTE_UserContent("Update", "caret.line.back", "#" & StringTrimLeft($CaretLine_BkColor, 2))
	EndIf
	Update_SciTE_UserContent("Update", "caret.line.back.alpha", $CaretLine_BkColor_Alpha)
	; Selection color
	Update_SciTE_UserContent("Update", "selection.fore", "#" & StringTrimLeft($Selection_Color, 2))
	Update_SciTE_UserContent("Update", "selection.alpha", $Selection_Alpha)
	Update_SciTE_UserContent("Update", "selection.back", "#" & StringTrimLeft($Selection_BkColor, 2))
	; Inline warning/error color
	Update_SciTE_UserContent("Update", "style.error.0", "fore:#" & StringTrimLeft($InLineDefault_Color, 2) & ",back:#" & StringTrimLeft($InLineDefault_BkColor, 2))
	Update_SciTE_UserContent("Update", "style.error.1", "fore:#" & StringTrimLeft($InLineWarning_Color, 2) & ",back:#" & StringTrimLeft($InLineWarning_BkColor, 2))
	Update_SciTE_UserContent("Update", "style.error.2", "fore:#" & StringTrimLeft($InLineError_Color, 2) & ",back:#" & StringTrimLeft($InLineError_BkColor, 2))
	; Current word
	Update_SciTE_UserContent("Update", "highlight.current.word.colour", "#" & StringTrimLeft($CurrentHilight_Color, 2))
	Update_SciTE_UserContent("Update", "indicators.alpha", $Current_Alpha)
	; Calltip update the properties settings and force the change without restart of SciTE.
	Update_SciTE_UserContent("Update", "calltips.set.above", $CallTip_Above)
	If $CallTip_Above = 1 Then
		SendSciTE_Command(0, $SciTE_hwnd, "extender:dostring editor.CallTipPosition=true")
	Else
		SendSciTE_Command(0, $SciTE_hwnd, "extender:dostring editor.CallTipPosition=false")
	EndIf
	Update_SciTE_UserContent("Update", "style.au3.38", "fore:#" & StringTrimLeft($CallTip_Color, 2) & ",back:#" & StringTrimLeft($CallTip_BkColor, 2))
	Update_SciTE_UserContent("Update", "calltips.color.highlight", "#" & StringTrimLeft($ParamHilite_Color, 2))
	; Search margin
	Update_SciTE_UserContent("Update", "visible.policy.strict", 1)
	Update_SciTE_UserContent("Update", "visible.policy.lines", $SearchMargin)
	;Write bracket color
	Local $y = 6
	$Orec = "fore:#" & StringTrimLeft($Syn_fColor[$y], 2)
	If $Syn_Italic[$y] Then $Orec = $Orec & ",italics"
	If $Syn_Bold[$y] Then $Orec = $Orec & ",bold"
	If $Syn_Underline[$y] Then $Orec = $Orec & ",underlined"
	If $Syn_bColor[$y] <> "" And $Syn_bColor[$y] <> "0XFFFFFF" Then $Orec = $Orec & ",back:#" & StringTrimLeft($Syn_bColor[$y], 2)
	Update_SciTE_UserContent("Update", "style.au3.34", $Orec)
	$y = 2
	$Orec = "fore:#" & StringTrimLeft($Syn_fColor[$y], 2)
	If $Syn_Italic[$y] Then $Orec = $Orec & ",italics"
	If $Syn_Bold[$y] Then $Orec = $Orec & ",bold"
	If $Syn_Underline[$y] Then $Orec = $Orec & ",underlined"
	If $Syn_bColor[$y] <> "" And $Syn_bColor[$y] <> "0XFFFFFF" Then $Orec = $Orec & ",back:#" & StringTrimLeft($Syn_bColor[$y], 2)
	Update_SciTE_UserContent("Update", "style.au3.35", $Orec)
	For $y = 1 To 17
		$Orec = "fore:#" & StringTrimLeft($Syn_fColor[$y], 2)
		If $Syn_Italic[$y] Then $Orec = $Orec & ",italics"
		If $Syn_Bold[$y] Then $Orec = $Orec & ",bold"
		If $Syn_Underline[$y] Then $Orec = $Orec & ",underlined"
		$Orec = $Orec & ",back:#" & StringTrimLeft($Syn_bColor[$y], 2)
		Update_SciTE_UserContent("Update", "style.au3." & $y - 1, $Orec)
	Next
	; Tools
	Local $Prop_Key, $Tool_Desc_Beta
	For $i = 1 To $SciTETools[0]
		$Tool_Num = StringStripWS(Number(StringMid($SciTETools[$i], 3, 2)), 3)
		$Prop_Key = "command.name." & $Tool_Num & $SciTEToolsSuffix[$i]
		$Tool_Desc_Cur = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:command.name." & $Tool_Num & $SciTEToolsSuffix[$i])
		$Tool_Desc_Beta = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:command." & $Tool_Num & ".beta")
		If BitAND(GUICtrlRead($checkbox[$i]), $GUI_CHECKED) = $GUI_CHECKED Then
			Update_SciTE_UserContent("Delete", $Prop_Key)
			Update_SciTE_UserContent("Delete", "command." & $Tool_Num & ".beta")
		Else
			Update_SciTE_UserContent("Update", $Prop_Key, "")
			If $Tool_Desc_Beta <> "" Then
				Update_SciTE_UserContent("Update", "command." & $Tool_Num & ".beta", "")
			EndIf
		EndIf
	Next
	; Save personal Include directory
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\AutoIt v3\AutoIt", "Include", "REG_SZ", GUICtrlRead($h_UserIncludeDirectory))
	Update_SciTE_UserContent("Update", "openpath.$(au3)", "$(SciteDefaultHome)\..\include;" & GUICtrlRead($h_UserIncludeDirectory))
	; Save all changes to the SciTEUser file
	Update_SciTE_UserContent("Save")
EndFunc   ;==>Update_SciTE_User
;*****************************************************************************
; Save info to SciTEUser
;*****************************************************************************
Func Update_SciTE_UserContent($Task, $aKey = "", $aKeyValue = "")
	;
	Local $aCurKeyValue
	Local $RegKey = StringReplace($aKey, "$", "\$")
	$RegKey = StringReplace($RegKey, "(", "\(")
	$RegKey = StringReplace($RegKey, ")", "\)")
	Switch $Task
		Case "Update"
			$aCurKeyValue = StringRegExp(@CRLF & $SciTEUser_Content, "(?i)\r\n[\s]*" & $RegKey & "[\s]*=(.*?)\r\n", 3)
			If UBound($aCurKeyValue) Then
;~ 				ConsoleWrite("! Found Key: " & $RegKey & " with value:" & $aCurKeyValue[0])
				; exit when already in the file
				If $aCurKeyValue[0] = $aKeyValue Then
;~ 					ConsoleWrite(" ==> Nothing to change." & @CRLF)
				Else
					;
;~						ConsoleWrite(" ==> Updated to: " & $aKeyValue & @CRLF)
					$aKeyValue = StringReplace($aKeyValue, "\", "\\")
					$SciTEUser_Content = StringMid(StringRegExpReplace(@CRLF & $SciTEUser_Content, "(?i)\r\n[\s]*" & $RegKey & "[\s]*=(.*?)\r\n", @CRLF & $RegKey & "=" & $aKeyValue & @CRLF), 3)
				EndIf
			Else
				$SciTEUser_Content &= $aKey & "=" & $aKeyValue & @CRLF
;~				ConsoleWrite("! Added Key: " & $RegKey & " with value:" & $aKeyValue & @CRLF)
			EndIf
		Case "UpdateLine"
			$aCurKeyValue = StringRegExp(@CRLF & $SciTEUser_Content, "(?i)\r\n[\s]*" & $RegKey & "[\s]*\r\n", 0)
			If $aCurKeyValue Then
;~ 				ConsoleWrite("! Found line: " & $RegKey & @CRLF)
				; exit when already in the file
;~ 				ConsoleWrite(" ==> Nothing to change." & @CRLF)
			Else
				$SciTEUser_Content &= $aKey & @CRLF
;~ 				ConsoleWrite("! Added Line: " & $RegKey & @CRLF)
			EndIf
		Case "Delete"
			$aCurKeyValue = StringRegExp(@CRLF & $SciTEUser_Content, "(?i)\r\n[\s]*" & $RegKey & "[\s]*=(.*?)\r\n", 3)
			If UBound($aCurKeyValue) Then
;~ 				ConsoleWrite("! Deleted Key: " & $aKeyValue & @CRLF)
				$aKeyValue = StringReplace($aKeyValue, "\", "\\")
				$SciTEUser_Content = StringMid(StringRegExpReplace(@CRLF & $SciTEUser_Content, "(?i)\r\n[\s]*" & $RegKey & "[\s]*=(.*?)\r\n", @CRLF), 3)
			Else
;~ 				ConsoleWrite("! Key not Found: " & $aKeyValue & @CRLF)
			EndIf
		Case "Save"
			; Save to the SciTEUser.properties file
			FileRecycle($SciTEUserDir & "\SciTEUser.properties")
			Local $rc = FileWrite($SciTEUserDir & "\SciTEUser.properties", StringTrimRight($SciTEUser_Content, 2))
			If Not $rc Then ConsoleWrite("! Unable to write changes to " & $SciTEUserDir & "\SciTEUser.properties" & @CRLF)
	EndSwitch
EndFunc   ;==>Update_SciTE_UserContent
;
Func Update_status($NewText, $iColour = 0x00FF00)
	AdlibRegister("Reset_Status", 2000)
	GUICtrlSetBkColor($g_idStatus_Msg, $iColour)
	GUICtrlSetData($g_idStatus_Msg, $NewText)
EndFunc   ;==>Update_status
;
Func Update_User_Properties($Property, $value)
	Opt("WinSearchChildren", 1)
	; Get SciTE DirectorHandle
	$SciTE_hwnd = WinGetHandle("DirectorExtension")
	;Send SciTE Director my GUI handle so it will report info back from SciTE
	SendSciTE_Command(0, $SciTE_hwnd, "property:user:style.au3." & $Property & "=" & $value)
EndFunc   ;==>Update_User_Properties
;*****************************************************************************
; Update Window info
;*****************************************************************************
Func Update_Window()
	Local $x
	GUICtrlSetData($H_Syn_Mono, "Monospace Font:" & $SYN_Font_Mono_Type)
	GUICtrlSetData($H_Syn_Prop, "Proportional Font:" & $SYN_Font_Prop_Type)
	GUICtrlSetData($H_Syn_Mono_Size, "Size:" & $SYN_Font_Mono_Size)
	GUICtrlSetData($H_Syn_Prop_Size, "Size:" & $SYN_Font_Prop_Size)
	If $ProperCase = 1 Then
		GUICtrlSetState($H_ProperCase, 1)
	Else
		GUICtrlSetState($H_ProperCase, 4)
	EndIf
	If $ErrorInline = 1 Then
		GUICtrlSetState($H_InLineError_Display, 1)
		For $i = $H_InLineWarning_Label To $H_InLineError_BkColor
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
	Else
		GUICtrlSetState($H_InLineError_Display, 4)
		For $i = $H_InLineWarning_Label To $H_InLineError_BkColor
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
	If $SYN_Font_Mono_ON = 1 Then
		GUICtrlSetState($H_Syn_Mono, 1)
		GUICtrlSetState($H_Syn_Prop, 4)
		$SYN_Font_Type = $SYN_Font_Mono_Type
		$SYN_Font_Size = $SYN_Font_Mono_Size
	Else
		GUICtrlSetState($H_Syn_Mono, 4)
		GUICtrlSetState($H_Syn_Prop, 1)
		$SYN_Font_Type = $SYN_Font_Prop_Type
		$SYN_Font_Size = $SYN_Font_Prop_Size
	EndIf
	If $Use_Tabs = 1 Then
		GUICtrlSetState($H_Use_Tabs, 1)
	Else
		GUICtrlSetState($H_Use_Tabs, 4)
	EndIf
	If $Current_Highlight = 1 Then
		GUICtrlSetState($H_Current_Highlight, 1)
		For $i = $H_Current_AutoSel To $H_CurrentHiLight_Alpha
			GUICtrlSetState($i, $GUI_ENABLE)
		Next
	Else
		GUICtrlSetState($H_Current_Highlight, 4)
		For $i = $H_Current_AutoSel To $H_CurrentHiLight_Alpha
			GUICtrlSetState($i, $GUI_DISABLE)
		Next
	EndIf
	If $Current_Autoselect = 1 Then
		GUICtrlSetState($H_Current_AutoSel, 1)
	Else
		GUICtrlSetState($H_Current_AutoSel, 4)
	EndIf
	If $Current_Wholeword = 1 Then
		GUICtrlSetState($H_Current_Wholeword, 1)
	Else
		GUICtrlSetState($H_Current_Wholeword, 4)
	EndIf
	If $Current_Style = 1 Then
		GUICtrlSetState($H_Current_Style, 1)
	Else
		GUICtrlSetState($H_Current_Style, 4)
	EndIf
	If $Current_Case = 1 Then
		GUICtrlSetState($H_Current_Case, 1)
	Else
		GUICtrlSetState($H_Current_Case, 4)
	EndIf
	GUICtrlSetData($H_Current_MinLength, $Current_Minlength)
	GUICtrlSetBkColor($H_Background_Label, $Background_Color)
	GUICtrlSetBkColor($H_CaretLine_Label, $CaretLine_BkColor)
	GUICtrlSetColor($H_Selection_Label, $Selection_Color)
	GUICtrlSetBkColor($H_Selection_Label, _AlphaFactor($Selection_BkColor, $Selection_Alpha))
	GUICtrlSetColor($H_InLineDefault_Label, $InLineDefault_Color)
	GUICtrlSetBkColor($H_InLineDefault_Label, $InLineDefault_BkColor)
	GUICtrlSetColor($H_InLineWarning_Label, $InLineWarning_Color)
	GUICtrlSetBkColor($H_InLineWarning_Label, $InLineWarning_BkColor)
	GUICtrlSetColor($H_InLineError_Label, $InLineError_Color)
	GUICtrlSetBkColor($H_InLineError_Label, $InLineError_BkColor)
	GUICtrlSetBkColor($H_CurrentHilight_Label, $CurrentHilight_Color)
	If $CallTip_Above = 1 Then
		GUICtrlSetState($H_CallTip_Above, 1)
	Else
		GUICtrlSetState($H_CallTip_Above, 4)
	EndIf
	GUICtrlSetColor($H_CallTip_Label, $CallTip_Color)
	GUICtrlSetBkColor($H_CallTip_Label, $CallTip_BkColor)
	GUICtrlSetColor($H_ParamHilite_Label, $ParamHilite_Color)
	GUICtrlSetBkColor($H_ParamHilite_Label, $CallTip_BkColor)
	For $x = 1 To 17
		GUICtrlSetColor($H_Syn_Label[$x], $Syn_fColor[$x])
		If $Syn_bColor_Default[$x] = $GUI_CHECKED Then
			$Syn_bColor[$x] = $Background_Color
			GUICtrlSetState($H_Syn_bColor_Standard[$x], $GUI_CHECKED)
			GUICtrlSetState($H_Syn_bColor[$x], $GUI_DISABLE)
		Else
			GUICtrlSetState($H_Syn_bColor[$x], $GUI_UNCHECKED)
			GUICtrlSetState($H_Syn_bColor[$x], $GUI_ENABLE)
		EndIf
		GUICtrlSetBkColor($H_Syn_Label[$x], $Syn_bColor[$x])
		GUICtrlSetFont($H_Syn_Label[$x], $SYN_Font_Size, 400 + $Syn_Bold[$x] * 200, $Syn_Italic[$x] * 2 + $Syn_Underline[$x] * 4, $SYN_Font_Type)
		;GUICtrlSetFont($H_Syn_Label[$x], $SYN_Font_Size, 400 + $Syn_Bold[$x] * 200, $Syn_Italic[$x] * 2 + $Syn_Underline[$x] * 4, $SYN_Font_Type)
		If $Syn_Bold[$x] Then
			GUICtrlSetState($H_Syn_Bold[$x], 1)
		Else
			GUICtrlSetState($H_Syn_Bold[$x], 4)
		EndIf
		If $Syn_Italic[$x] Then
			GUICtrlSetState($H_Syn_Italic[$x], 1)
		Else
			GUICtrlSetState($H_Syn_Italic[$x], 4)
		EndIf
		If $Syn_Underline[$x] Then
			GUICtrlSetState($H_Syn_Underline[$x], 1)
		Else
			GUICtrlSetState($H_Syn_Underline[$x], 4)
		EndIf
	Next
EndFunc   ;==>Update_Window
#EndRegion ; Funcs
#Region Other Tools
#include "AbbrevMan.au3"
#include "UCTMan.au3"
#include "get_au3_registrysettings.au3"
#EndRegion Other Tools
