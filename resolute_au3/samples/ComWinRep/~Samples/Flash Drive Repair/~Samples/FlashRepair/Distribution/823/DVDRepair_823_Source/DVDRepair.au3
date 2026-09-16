#NoTrayIcon
#OnAutoItStartRegister "_ReBarStartUp"

#Region AutoIt3Wrapper Directives Dection

#AutoIt3Wrapper_If_Run

	;===============================================================================================================
	; AutoIt3 Settings
	;===============================================================================================================
	#AutoIt3Wrapper_UseX64=Y										 ;~ (Y/N) Use AutoIt3_x64 or Aut2Exe_x64. Default=N
	#AutoIt3Wrapper_Run_Debug_Mode=N								 ;~ (Y/N) Run Script with console debugging. Default=N
	#AutoIt3Wrapper_Run_SciTE_Minimized=Y 							 ;~ (Y/N) Minimize SciTE while script is running. Default=N
	#AutoIt3Wrapper_Run_SciTE_OutputPane_Minimized=N				 ;~ (Y/N) Minimize SciTE output pane at run time. Default=N
	;===============================================================================================================
	; Tidy Settings
	;===============================================================================================================
	#AutoIt3Wrapper_Run_Tidy=Y										 ;~ (Y/N) Run Tidy before compilation. Default=N
	#AutoIt3Wrapper_Tidy_Stop_OnError=N								 ;~ (Y/N) Continue when only Warnings. Default=Y
	;#Tidy_Parameters= 												;~ Tidy Parameters...see SciTE4AutoIt3 Helpfile for options
	;===============================================================================================================
	; AU3Check settings
	;===============================================================================================================
	#AutoIt3Wrapper_Run_AU3Check=Y									 ;~ (Y/N) Run au3check before compilation. Default=Y
	;#AutoIt3Wrapper_AU3Check_Parameters=							;~ Au3Check parameters...see SciTE4AutoIt3 Helpfile for options
	;#AutoIt3Wrapper_AU3Check_Stop_OnWarning=						;~ (Y/N) Continue/Stop on Warnings.(Default=N)

#Autoit3Wrapper_If_Compile

	#AutoIt3Wrapper_ShowProgress=Y									 ;~ (Y/N) Show ProgressWindow during Compile. Default=Y
	;===============================================================================================================
	; AutoIt3 Settings
	;===============================================================================================================
	#AutoIt3Wrapper_UseX64=Y										 ;~ (Y/N) Use AutoIt3_x64 or Aut2Exe_x64. Default=N
	#AutoIt3Wrapper_Version=B                        				 ;~ (B/P) Use Beta or Production for AutoIt3 and Aut2Eex. Default is P
	#AutoIt3Wrapper_Run_Debug_Mode=N								 ;~ (Y/N) Run Script with console debugging. Default=N
	;#AutoIt3Wrapper_Autoit3Dir=									;~ Optionally override the AutoIt3 install directory to use.
	;#AutoIt3Wrapper_Aut2exe=										;~ Optionally override the Aut2exe.exe to use for this script
	;#AutoIt3Wrapper_AutoIt3=										;~ Optionally override the Autoit3.exe to use for this script
	;===============================================================================================================
	; Aut2Exe Settings
	;===============================================================================================================
	#AutoIt3Wrapper_Icon=Themes\Icons\DVDRepair.ico					 ;~ Filename of the Ico file to use for the compiled exe
	#AutoIt3Wrapper_OutFile_Type=exe								 ;~ exe=Standalone executable (Default); a3x=Tokenised AutoIt3 code file
	#AutoIt3Wrapper_OutFile=DVDRepair.exe							 ;~ Target exe/a3x filename.
	#AutoIt3Wrapper_OutFile_X64=DVDRepair_X64.exe					 ;~ Target exe filename for X64 compile.
	;#AutoIt3Wrapper_Compression=4									;~ Compression parameter 0-4  0=Low 2=normal 4=High. Default=2
	;#AutoIt3Wrapper_UseUpx=Y										;~ (Y/N) Compress output program.  Default=Y
	;#AutoIt3Wrapper_UPX_Parameters=								;~ Override the default settings for UPX.
	#AutoIt3Wrapper_Change2CUI=N									 ;~ (Y/N) Change output program to CUI in stead of GUI. Default=N
	#AutoIt3Wrapper_Compile_both=Y									 ;~ (Y/N) Compile both X86 and X64 in one run. Default=N
	;===============================================================================================================
	; Target Program Resource info
	;===============================================================================================================
	#AutoIt3Wrapper_Res_Comment=DVD Drive Repair								 	 ;~ Comment field
	#AutoIt3Wrapper_Res_Description=Rizonesoft DVD Drive Repair				      	 ;~ Description field
	#AutoIt3Wrapper_Res_Fileversion=1.0.2.824
	#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y  					 			 ;~ (Y/N/P) AutoIncrement FileVersion. Default=N
	#AutoIt3Wrapper_Res_FileVersion_First_Increment=N					 			 ;~ (Y/N) AutoIncrement Y=Before; N=After compile. Default=N
	#AutoIt3Wrapper_Res_HiDpi=Y                      					 			 ;~ (Y/N) Compile for high DPI. Default=N
	#AutoIt3Wrapper_Res_ProductVersion=0             					 			 ;~ Product Version
	#AutoIt3Wrapper_Res_Language=2057									 			 ;~ Resource Language code . Default 2057=English (United Kingdom)
	#AutoIt3Wrapper_Res_LegalCopyright=© 2016 Rizonesoft				 			 ;~ Copyright field
	#AutoIt3Wrapper_res_requestedExecutionLevel=highestAvailable		 			 ;~ asInvoker, highestAvailable, requireAdministrator or None (remove the trsutInfo section).  Default is the setting from Aut2Exe (asInvoker)
	#AutoIt3Wrapper_res_Compatibility=Vista,Win7,Win8,Win81,Win10				 	 ;~ Vista/Windows7/win7/win8/win81 allowed separated by a comma     (Default=Win81)
	;#AutoIt3Wrapper_Res_SaveSource=N												;~ (Y/N) Save a copy of the Script_source in the EXE resources. Default=N
	; If _Res_SaveSource=Y the content of Script_source depends on the _Run_Au3Stripper and #Au3Stripper_parameters directives:
	;    If _Run_Au3Stripper=Y then
	;        If #Au3Stripper_parameters=/STRIPONLY then Script_source is stripped script & stripped includes
	;        If #Au3Stripper_parameters=/STRIPONLYINCLUDES then Script_source is original script & stripped includes
	;       With any other parameters, the SaveSource directive is ignored as obfuscation is intended to protect the source
	;   If _Run_Au3Stripper=N or is not set then
	;       Scriptsource is original script only
	; AutoIt3Wrapper indicates the SaveSource action taken in the SciTE console during compilation
	; See SciTE4AutoIt3 Helpfile for more detail on Au3Stripper parameters
	;===============================================================================================================
	; Free form resource fields ... max 15
	;===============================================================================================================
	; You can use the following variables:
	;	%AutoItVer% which will be replaced with the version of AutoIt3
	;	%date% = PC date in short date format
	;	%longdate% = PC date in long date format
	;	%time% = PC timeformat
	;	eg: #AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
	#AutoIt3Wrapper_Res_Field=CompanyName|Rizonesoft
	#AutoIt3Wrapper_Res_Field=ProductName|DVD Drive Repair
	#AutoIt3Wrapper_Res_Field=HomePage|https://www.rizonesoft.com
	#AutoIt3Wrapper_Res_Field=AutoItVersion|%AutoItVer%
	; Add extra ICO files to the resources
	; Use full path of the ico files to be added
	; ResNumber is a numeric value used to access the icon: TraySetIcon(@ScriptFullPath, ResNumber)
	; If no ResNumber is specified, the added icons are numbered from 201 up
	; #AutoIt3Wrapper_Res_Icon_Add=                   				;~ Filename[,ResNumber[,LanguageCode]] of ICO to be added.
	; #AutoIt3Wrapper_Res_File_Add=                   				;~ Filename[,Section [,ResName[,LanguageCode]]] to be added.
	; Add files to the resources - can be compressed
	; #AutoIt3Wrapper_Res_Remove=
	; Remove resources
	#AutoIt3Wrapper_Res_Icon_Add=Themes\Icons\DVDRepairH.ico
	;===============================================================================================================
	; Tidy Settings
	;===============================================================================================================
	#AutoIt3Wrapper_Run_Tidy=N										;~ (Y/N) Run Tidy before compilation. Default=N
	;#AutoIt3Wrapper_Tidy_Stop_OnError=              				;~ (Y/N) Continue when only Warnings. Default=Y
	;#Tidy_Parameters=                               				;~ Tidy Parameters...see SciTE4AutoIt3 Helpfile for options
	;===============================================================================================================
	; Au3Stripper Settings
	;===============================================================================================================
	#AutoIt3Wrapper_Run_Au3Stripper=Y								;~ (Y/N) Run Au3Stripper before compilation. default=N
	;#Au3Stripper_Parameters=										;~ Au3Stripper parameters...see SciTE4AutoIt3 Helpfile for options
	;#Au3Stripper_Ignore_Variables=
	;===============================================================================================================
	; AU3Check settings
	;===============================================================================================================
	#AutoIt3Wrapper_Run_AU3Check=Y									;~ (Y/N) Run au3check before compilation. Default=Y
	;#AutoIt3Wrapper_AU3Check_Parameters=							;~ Au3Check parameters...see SciTE4AutoIt3 Helpfile for options
	#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y 						;~ (Y/N) Continue/Stop on Warnings.(Default=N)
	;===============================================================================================================
	; Versioning Settings
	;===============================================================================================================
	;#AutoIt3Wrapper_Versioning=V									;~ (Y/N/V) Run Versioning to update the script source. default=N
	;	V=only run when fileversion is increased by #AutoIt3Wrapper_Res_FileVersion_AutoIncrement.
	;#AutoIt3Wrapper_Versioning_Parameters=/NoPrompt				;~ /NoPrompt  : Will skip the Comments prompt
	;	/Comments  : Text to added in the Comments. It can also contain the below variables.
	;===============================================================================================================
	; RUN BEFORE AND AFTER definitions
	;===============================================================================================================
	;The following directives can contain: these variables
	;	%in% , %out%, %outx64%, %icon% which will be replaced by the fullpath\filename.
	;	%scriptdir% same as @ScriptDir and %scriptfile% = filename without extension.
	;	%fileversion% is the information from the #AutoIt3Wrapper_Res_Fileversion directive
	;	%scitedir% will be replaced by the SciTE program directory
	;	%autoitdir% will be replaced by the AutoIt3 program directory
	;#AutoIt3Wrapper_Run_Before_Admin=               				;~ (Y/N) Run subsequent Run_Before statements with #RequireAdmin. Default=N
	;#AutoIt3Wrapper_Run_After_Admin=                				;~ (Y/N) Run subsequent Run_After statements with #RequireAdmin. Default=N
	;#AutoIt3Wrapper_Run_Before=                     				;~ process to run before compilation - multiple records will be processed in sequence
	;#AutoIt3Wrapper_Run_After=                      				;~ process to run after compilation - multiple records will be processed in sequence
	;===============================================================================================================

#AutoIt3Wrapper_EndIf

#EndRegion AutoIt3Wrapper Directives Dection

Opt("CaretCoordMode", 1) ;~ 1=absolute, 0=relative, 2=client
Opt("ExpandEnvStrings", 1) ;~ 0=don't expand, 1=do expand
Opt("ExpandVarStrings", 1) ;~ 0=don't expand, 1=do expand
Opt("GUICloseOnESC", 1) ;~ 1=ESC  closes, 0=ESC won't close
Opt("GUICoordMode", 1) ;~ 1=absolute, 0=relative, 2=cell
Opt("GUIDataSeparatorChar", "|") ;~ "|" is the default
Opt("GUIOnEventMode", 1) ;~ 0=disabled, 1=OnEvent mode enabled
Opt("GUIResizeMode", 802) ;~ 0=no resizing, <1024 special resizing
Opt("GUIEventOptions", 0) ;~ 0=default, 1=just notification, 2=GUICtrlRead tab index
Opt("MouseClickDelay", 10) ;~ 10 milliseconds
Opt("MouseClickDownDelay", 10) ;~ 10 milliseconds
Opt("MouseClickDragDelay", 250) ;~ 250 milliseconds
Opt("MouseCoordMode", 1) ;~ 1=absolute, 0=relative, 2=client
Opt("MustDeclareVars", 1) ;~ 0=no, 1=require pre-declaration
Opt("PixelCoordMode", 1) ;~ 1=absolute, 0=relative, 2=client
Opt("SendAttachMode", 0) ;~ 0=don't attach, 1=do attach
Opt("SendCapslockMode", 1) ;~ 1=store and restore, 0=don't
Opt("SendKeyDelay", 5) ;~ 5 milliseconds
Opt("SendKeyDownDelay", 1) ;~ 1 millisecond
Opt("TCPTimeout", 100) ;~ 100 milliseconds
Opt("TrayAutoPause", 1) ;~ 0=no pause, 1=Pause
Opt("TrayIconDebug", 1) ;~ 0=no info, 1=debug line info
Opt("TrayIconHide", 1) ;~ 0=show, 1=hide tray icon
Opt("TrayMenuMode", 1) ;~ 0=append, 1=no default menu, 2=no automatic check, 4=menuitemID  not return
Opt("TrayOnEventMode", 1) ;~ 0=disable, 1=enable
Opt("WinDetectHiddenText", 0) ;~ 0=don't detect, 1=do detect
Opt("WinSearchChildren", 1) ;~ 0=no, 1=search children also
Opt("WinTextMatchMode", 1) ;~ 1=complete, 2=quick
Opt("WinTitleMatchMode", 1) ;~ 1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
Opt("WinWaitDelay", 250) ;~ 250 milliseconds


#include <ListviewConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <GuiConstantsEx.au3>
#include <EditConstants.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <Constants.au3>
#include <GDIPlus.au3>
#include <GuiMenu.au3>

#include "Includes\ReBar_Declarations.au3"
#include "Includes\ReBar_Versioning.au3"
#include "Includes\ReBar_Functions.au3"
#include "Includes\ReBar_Logging.au3"

#include "UDF\ReBar_Options.au3"

#include "Includes\ReBar_Registry.au3"
#include "Includes\ReBar_Process.au3"
#include "Includes\ReBar_Startup.au3"


;===============================================================================================================
; Declarations
;===============================================================================================================
Global $g_MenuFile, $g_MenuTools, $g_MenuHelp
Global $g_ChkResetAutorun, $g_ChkProtectAutorun, $g_BtnRepair, $g_InpStatus
Global $g_ChkResetMachine, $g_ChkProtectMachine, $g_ChkDoNothing
Global $g_SetResetAutorun = 0, $g_SetProtectAutorun = 0, $g_SetDisableExtras = 0
Global $g_SetResetMachine = 0, $g_SetProtectMachine = 0
;===============================================================================================================


If Not @AutoItX64 And @OSArch = "X64" Then

	If FileExists(@ScriptDir & "\DVDRepair_x64.exe") Then
		ShellExecute(@ScriptDir & "\DVDRepair_x64.exe")
		Exit
	Else

		MsgBox($MB_OK + $MB_ICONERROR, "Warning", "Unfortuantely " & _
				$g_ReBarProgName & " 32 Bit is not compatible " & _
				"with your Windows version. Please download " & _
				$g_ReBarProgName & " 64 Bit from " & $g_ReBarAboutHome, 60)
		ShellExecute($g_ReBarAboutHome)
		Exit

	EndIf

Else

	_ReBar_LoadPreferences()
	_LoadOptions()
	$g_SetResetMachine = IniRead($g_ReBarPathIni, "Options", "ResetAutorunMachine", 1)
	$g_SetProtectMachine = IniRead($g_ReBarPathIni, "Options", "ProtectAutorunMachine", 1)
	_SetWorkingDirectories()
	_LoggingInitialize()
	_CheckResources($g_ReBarResFugue)
	_CheckResources($g_ReBarResDoors)
	_StartCoreGUI()

EndIf


Func _LoadPrefsExtended()
	; _ReBar_LoadPreferences Hook
EndFunc   ;==>_LoadPrefsExtended


Func _SavePrefsExtended()
	; _ReBar_SavePreferences Hook
EndFunc   ;==>_SavePrefsExtended


Func _LoadOptions()
	$g_SetResetAutorun = Int(IniRead($g_ReBarPathIni, $g_ReBarShortName, "ResetAutorun", 1))
	$g_SetProtectAutorun = Int(IniRead($g_ReBarPathIni, $g_ReBarShortName, "ProtectAutorun", 0))
	$g_SetProtectMachine = Int(IniRead($g_ReBarPathIni, $g_ReBarShortName, "ProtectAutorunMachine", 1))
	$g_SetDisableExtras = Int(IniRead($g_ReBarPathIni, $g_ReBarShortName, "DisableExtras", 0))
EndFunc   ;==>_LoadOptions


Func _SaveOptions()
	IniWrite($g_ReBarPathIni, $g_ReBarShortName, "ResetAutorun", $g_SetResetAutorun)
	IniWrite($g_ReBarPathIni, $g_ReBarShortName, "ProtectAutorun", $g_SetProtectAutorun)
	IniWrite($g_ReBarPathIni, $g_ReBarShortName, "ProtectAutorunMachine", $g_SetProtectMachine)
	IniWrite($g_ReBarPathIni, $g_ReBarShortName, "DisableExtras", $g_SetDisableExtras)
EndFunc   ;==>_SaveOptions


Func _StartCoreGUI()

	_ReBar_LoadPreferences()

	$g_ReBarCoreGui = GUICreate($g_ReBarGuiTitle, $g_ReBarFormWidth, $g_ReBarFormHeight, -1, -1, -1)
	GUISetFont($g_ReBarFontSize, 400, -1, $g_ReBarFontName, $g_ReBarCoreGui, $CLEARTYPE_QUALITY)

	If Not @Compiled Then
		GUISetIcon($g_ReBarIcon, 0, $g_ReBarCoreGui)
	EndIf

	Local $miFileClose, $miFileReboot
	Local $miFilePrefs, $mnuLogging, $miLogDir, $miOpenLog
	Local $miSysRestore, $miFirmwareHQ
	Local $miMeteredPerm, $miUpdatePerm
	Local $miHlpHome, $miHlpSupport

	$g_MenuFile = GUICtrlCreateMenu("&File")
	$g_MenuTools = GUICtrlCreateMenu("&Tools")
	$g_MenuHelp = GUICtrlCreateMenu("&Help")

	$miFilePrefs = GUICtrlCreateMenuItem("&Preferences", $g_MenuFile)
	GUICtrlCreateMenuItem("", $g_MenuFile)
	$mnuLogging = GUICtrlCreateMenu("&Logging", $g_MenuFile)
	$miLogDir = GUICtrlCreateMenuItem("Open logging &Directory", $mnuLogging)
	$miOpenLog = GUICtrlCreateMenuItem("Open logging &File", $mnuLogging)
	GUICtrlCreateMenuItem("", $g_MenuFile)
	$miFileReboot = GUICtrlCreateMenuItem("&Reboot Windows", $g_MenuFile)
	$miFileClose = GUICtrlCreateMenuItem("&Close" & @TAB & "Esc", $g_MenuFile)

	GUICtrlSetOnEvent($miFilePrefs, "_ShowPreferencesDlg")
	GUICtrlSetOnEvent($miLogDir, "_OpenLoggingDirectory")
	GUICtrlSetOnEvent($miOpenLog, "_OpenLoggingFile")
	GUICtrlSetOnEvent($miFileReboot, "_ReBarRebootWindows")
	GUICtrlSetOnEvent($miFileClose, "_ShutdownProgram")

	$miSysRestore = GUICtrlCreateMenuItem("System &Restore", $g_MenuTools)
	$miFirmwareHQ = GUICtrlCreateMenuItem("Update &Firmware (FirmwareHQ.com)", $g_MenuTools)

	GUICtrlSetOnEvent($miSysRestore, "_OpenSystemProtection")
	GUICtrlSetOnEvent($miFirmwareHQ, "_OpenFirmwareHQ")

	$g_ReBarAboutMenu = GUICtrlCreateMenuItem("&About " & $g_ReBarProgName, $g_MenuHelp)
	GUICtrlCreateMenuItem("", $g_MenuHelp)
	$miHlpHome = GUICtrlCreateMenuItem($g_ReBarCompName & " &Home", $g_MenuHelp)
	GUICtrlCreateMenuItem("", $g_MenuHelp)
	$miHlpSupport = GUICtrlCreateMenuItem($g_ReBarCompName & " &Support", $g_MenuHelp)

	GUICtrlSetOnEvent($g_ReBarAboutMenu, "_ShowAboutDialog")
	GUICtrlSetOnEvent($miHlpHome, "_OpenHomePageLink")
	GUICtrlSetOnEvent($miHlpSupport, "_OpenSupportLink")

	$g_ReBarGuiIcon = GUICtrlCreateIcon($g_ReBarIcon, 99, 5, 0, 128, 128)
	GUICtrlSetTip($g_ReBarGuiIcon, "Version " & $g_ReBarRunVersion & @CRLF & _
			"Build with AutoIt version " & @AutoItVersion & @CRLF & _
			"Copyright © " & @YEAR & " " & $g_ReBarCompName, _
			"About " & $g_ReBarProgName, $TIP_INFOICON, $TIP_BALLOON)
	GUICtrlSetCursor($g_ReBarGuiIcon, 0)

	GUICtrlSetOnEvent($g_ReBarGuiIcon, "_ShowAboutDialog")

	GUICtrlCreateLabel("If your DVD Drives is missing from " & _GetWindowsVersion() & " or it is not recognized by" & _
			" some applications, click 'Repair DVD Drives' and restart your computer." & _
			" Remember to create a System Restore Point before you continue.", 140, 10, 285, 80)
	GUICtrlCreateLabel("It may be necessary to reinstall any software designed " & _
		"to utilize BD/DVD/CD drives after running " & $g_ReBarProgName & ".", 140, 90, 285, 65)
	GUICtrlSetColor(-1, 0xFB650D)
	$g_ChkResetAutorun = GUICtrlCreateCheckbox("Reset Autorun Options", 20, 160, 230, 15, $BS_AUTORADIOBUTTON)
	$g_ChkDoNothing = GUICtrlCreateCheckbox("Just Repair", 250, 160, 200, 15)
	GUICtrlSetTip($g_ChkDoNothing, "Disable reset and protect options.", _
			"Disable extra processing.", $TIP_INFOICON)
	$g_ChkProtectAutorun = GUICtrlCreateCheckbox("Protect against Autorun Malware", 20, 180, 230, 15, $BS_AUTORADIOBUTTON)
	GUICtrlSetTip($g_ChkProtectAutorun, "This option disables autorun functionality for all removable drives!" & @CRLF & _
			"Select " & Chr(34) & "Reset Autorun Options" & Chr(34) & " to enable autorun.", "Warning", $TIP_WARNINGICON)
	$g_ChkProtectMachine = GUICtrlCreateCheckbox("Including Local Machine", 250, 180, 200, 15)
	$g_BtnRepair = GUICtrlCreateButton("Repair DVD Drives", ($g_ReBarFormWidth - 250) / 2, 210, 250, 40)
	GUICtrlSetFont($g_BtnRepair, 10, 700, 2)
	GUICtrlSetState($g_BtnRepair, $GUI_DEFBUTTON)

	$g_ListStatus = GUICtrlCreateListView("", 10, 265, 430, 125, BitOR($LVS_REPORT, $LVS_NOCOLUMNHEADER))
	_GUICtrlListView_SetExtendedListViewStyle($g_ListStatus, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_DOUBLEBUFFER, _
			$LVS_EX_SUBITEMIMAGES, $LVS_EX_INFOTIP, _
			$WS_EX_CLIENTEDGE))
	_GUICtrlListView_AddColumn($g_ListStatus, "", 680)
	_WinAPI_SetWindowTheme(GUICtrlGetHandle($g_ListStatus), "Explorer")

	$g_ImgStatus = _GUIImageList_Create(16, 16, 5, 1, 8, 8)
	_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -103)
	_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -130)
	_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -122)
	_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -134)
	_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -133)
	_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -135)
	_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -136)
	_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -138)
	_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -159)
	_GUIImageList_AddIcon($g_ImgStatus, $g_ReBarResFugue, -999)
	_GUICtrlListView_SetImageList($g_ListStatus, $g_ImgStatus, 1)

	GUICtrlSetFont($g_ListStatus, 9, -1, -1, "Courier New")
	GUICtrlSetColor($g_ListStatus, 0x222222)

	GUICtrlSetOnEvent($g_BtnRepair, "_RepairDVDDrive")
	GUICtrlSetOnEvent($g_ReBarAboutButton, "_ShowAboutDialog")
	GUICtrlSetOnEvent($g_ChkResetAutorun, "_SetOptions")
	GUICtrlSetOnEvent($g_ChkDoNothing, "_SetOptions")
	GUICtrlSetOnEvent($g_ChkProtectAutorun, "_SetOptions")
	GUICtrlSetOnEvent($g_ChkProtectMachine, "_SetOptions")

	GUICtrlSetState($g_ChkResetAutorun, $g_SetResetAutorun)
	GUICtrlSetState($g_ChkDoNothing, $g_SetDisableExtras)
	GUICtrlSetState($g_ChkProtectAutorun, $g_SetProtectAutorun)
	GUICtrlSetState($g_ChkProtectMachine, $g_SetProtectMachine)

	_SetOptions()

	GUISetState(@SW_SHOW, $g_ReBarCoreGui)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ShutdownProgram", $g_ReBarCoreGui)

	; $g_ReBarUpdateRemote = $g_ReBarUpdateURLBase & "\Debug.ru"
	; $g_ReBarUpdateLocal = $g_ReBarCachePath & "\Debug.ru"
	AdlibRegister("_OnMainIconHover", 50)
	_SoftwareUpdateCheck()

	While 1
		; _OnMainIconHover()
		Sleep(55)
	WEnd

EndFunc   ;==>_StartCoreGUI


Func _OpenSystemProtection()
	Run("systempropertiesprotection")
EndFunc   ;==>_OpenSystemProtection


Func _OpenFirmwareHQ()
	ShellExecute("http://www.firmwarehq.com")
EndFunc   ;==>_OpenFirmwareHQ


Func _SetOptions()

	If GUICtrlRead($g_ChkDoNothing) = $GUI_CHECKED Then

		GUICtrlSetState($g_ChkResetAutorun, $GUI_DISABLE)
		GUICtrlSetState($g_ChkProtectAutorun, $GUI_DISABLE)
		GUICtrlSetState($g_ChkProtectMachine, $GUI_DISABLE)
		$g_SetDisableExtras = 1
	Else

		GUICtrlSetState($g_ChkResetAutorun, $GUI_ENABLE)
		GUICtrlSetState($g_ChkProtectAutorun, $GUI_ENABLE)
		$g_SetDisableExtras = 0

		If GUICtrlRead($g_ChkResetAutorun) = $GUI_CHECKED Then
			$g_SetResetAutorun = 1
			$g_SetProtectAutorun = 0
			GUICtrlSetState($g_ChkProtectMachine, $GUI_DISABLE)
		ElseIf GUICtrlRead($g_ChkProtectAutorun) = $GUI_CHECKED Then
			$g_SetProtectAutorun = 1
			$g_SetResetAutorun = 0
			GUICtrlSetState($g_ChkProtectMachine, $GUI_ENABLE)
		EndIf

		If GUICtrlRead($g_ChkProtectMachine) = $GUI_CHECKED Then
			$g_SetProtectMachine = 1
		Else
			$g_SetProtectMachine = 0
		EndIf

	EndIf

EndFunc   ;==>_SetOptions


Func _OnMainIconHover()

	Local $iCursor = GUIGetCursorInfo()

	If Not @error Then
		If $iCursor[4] = $g_ReBarGuiIcon And $g_ReBarIcoHovering = 1 Then
			$g_ReBarIcoHovering = 0
			GUICtrlSetImage($g_ReBarGuiIcon, $g_ReBarIconHover, 201)
		ElseIf $iCursor[4] <> $g_ReBarGuiIcon And $g_ReBarIcoHovering = 0 Then
			$g_ReBarIcoHovering = 1
			GUICtrlSetImage($g_ReBarGuiIcon, $g_ReBarIcon, 99)
		EndIf
	EndIf

EndFunc   ;==>_OnMainIconHover


Func _RepairDVDDrive()

	Local $iBootMessage = 0

	GUICtrlSetState($g_BtnRepair, $GUI_DISABLE)
	GUICtrlSetState($g_ChkResetAutorun, $GUI_DISABLE)
	GUICtrlSetState($g_ChkProtectAutorun, $GUI_DISABLE)
	GUICtrlSetState($g_ChkDoNothing, $GUI_DISABLE)

	_StartLogging("Repairing DVD Drive ...")
	_ConfigureWindowsService("ShellHWDetection", 2)
	_RunCommand("sc config ShellHWDetection start= auto obj= LocalSystem")
	_RunCommand("net start ShellHWDetection")

	_EditLoggingWrite("Resetting Upper and Lower Filters")
	_RegistryDelete("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E965-E325-11CE-BFC1-08002BE10318}", "UpperFilters")
	_RegistryDelete("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E965-E325-11CE-BFC1-08002BE10318}", "LowerFilters")

	If $g_SetDisableExtras = 0 Then

		If $g_SetResetAutorun = 1 Then

			_EditLoggingWrite("Resetting Autorun Settings.")
			_RegistryWrite("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\CDRom", "AutoRun", "REG_DWORD", 1)

			_RegistryDelete("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DontSetAutoplayCheckbox")
			_RegistryDelete("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoAutorun")
			_RegistryDelete("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun")
			_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DontSetAutoplayCheckbox")
			_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoAutorun")
			_RegistryDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun")

			If @OSVersion = "WIN_XP" Then
				_RegistryDelete("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf", "")
			EndIf

		ElseIf $g_SetProtectAutorun = 1 Then

			_RegistryWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoAutorun", "REG_DWORD", 1)


			If @OSVersion = "WIN_XP" Then
				_RegistryWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf", _
						"", "REG_SZ", "@SYS:DoesNotExist")
			Else

				_RegistryWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DontSetAutoplayCheckbox", "REG_DWORD", 1)
				_RegistryWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun", "REG_DWORD", 255)

				If $g_SetProtectMachine = 1 Then
					_RegistryWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoAutorun", "REG_DWORD", 1)
					_RegistryWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "DontSetAutoplayCheckbox", "REG_DWORD", 1)
					_RegistryWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun", "REG_DWORD", 255)
				EndIf

			EndIf

		EndIf

	EndIf

	GUICtrlSetState($g_BtnRepair, $GUI_ENABLE)
	GUICtrlSetState($g_ChkResetAutorun, $GUI_ENABLE)
	GUICtrlSetState($g_ChkProtectAutorun, $GUI_ENABLE)
	GUICtrlSetState($g_ChkDoNothing, $GUI_ENABLE)

	_EditLoggingWrite("Processing Finished.")
	_EditLoggingWrite("Reboot required! File -> Reboot Windows.")
	_EndLogging()

EndFunc   ;==>_RepairDVDDrive


Func _OnCoreClosing()

	_SaveOptions()
	AdlibUnRegister("_OnMainIconHover")

EndFunc   ;==>_OnCoreClosing


#include "Includes\ReBar_Preferences.au3"
#include "Includes\ReBar_End.au3"
