#NoTrayIcon
#OnAutoItStartRegister "_ReBarStartUp"

#Region AutoIt3Wrapper Directives Dection

#AutoIt3Wrapper_If_Run

	;===============================================================================================================
	; AutoIt3 Settings
	;===============================================================================================================
	#AutoIt3Wrapper_UseX64=Y										;~ (Y/N) Use AutoIt3_x64 or Aut2Exe_x64. Default=N
	#AutoIt3Wrapper_Run_Debug_Mode=N								;~ (Y/N) Run Script with console debugging. Default=N
	#AutoIt3Wrapper_Run_SciTE_Minimized=Y 							;~ (Y/N) Minimize SciTE while script is running. Default=N
	#AutoIt3Wrapper_Run_SciTE_OutputPane_Minimized=N				;~ (Y/N) Minimize SciTE output pane at run time. Default=N
	;===============================================================================================================
	; Tidy Settings
	;===============================================================================================================
	#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
	#AutoIt3Wrapper_Tidy_Stop_OnError=N								;~ (Y/N) Continue when only Warnings. Default=Y
	;#Tidy_Parameters= 												;~ Tidy Parameters...see SciTE4AutoIt3 Helpfile for options
	;===============================================================================================================
	; AU3Check settings
	;===============================================================================================================
	#AutoIt3Wrapper_Run_AU3Check=Y									;~ (Y/N) Run au3check before compilation. Default=Y
	;#AutoIt3Wrapper_AU3Check_Parameters=							;~ Au3Check parameters...see SciTE4AutoIt3 Helpfile for options
	;#AutoIt3Wrapper_AU3Check_Stop_OnWarning=						;~ (Y/N) Continue/Stop on Warnings.(Default=N)

#Autoit3Wrapper_If_Compile

	#AutoIt3Wrapper_ShowProgress=Y									;~ (Y/N) Show ProgressWindow during Compile. Default=Y
	;===============================================================================================================
	; AutoIt3 Settings
	;===============================================================================================================
	#AutoIt3Wrapper_UseX64=Y										;~ (Y/N) Use AutoIt3_x64 or Aut2Exe_x64. Default=N
	#AutoIt3Wrapper_Version=B                        				;~ (B/P) Use Beta or Production for AutoIt3 and Aut2Eex. Default is P
	#AutoIt3Wrapper_Run_Debug_Mode=N								;~ (Y/N) Run Script with console debugging. Default=N
	;#AutoIt3Wrapper_Autoit3Dir=									;~ Optionally override the AutoIt3 install directory to use.
	;#AutoIt3Wrapper_Aut2exe=										;~ Optionally override the Aut2exe.exe to use for this script
	;#AutoIt3Wrapper_AutoIt3=										;~ Optionally override the Autoit3.exe to use for this script
	;===============================================================================================================
	; Aut2Exe Settings
	;===============================================================================================================
	#AutoIt3Wrapper_Icon=Themes\Icons\Ownership.ico						;~ Filename of the Ico file to use for the compiled exe
	#AutoIt3Wrapper_OutFile_Type=exe									;~ exe=Standalone executable (Default); a3x=Tokenised AutoIt3 code file
	#AutoIt3Wrapper_OutFile=Ownership.exe								;~ Target exe/a3x filename.
	#AutoIt3Wrapper_OutFile_X64=Ownership_X64.exe						;~ Target exe filename for X64 compile.
	;#AutoIt3Wrapper_Compression=4										;~ Compression parameter 0-4  0=Low 2=normal 4=High. Default=2
	;#AutoIt3Wrapper_UseUpx=Y											;~ (Y/N) Compress output program.  Default=Y
	;#AutoIt3Wrapper_UPX_Parameters=									;~ Override the default settings for UPX.
	#AutoIt3Wrapper_Change2CUI=N										;~ (Y/N) Change output program to CUI in stead of GUI. Default=N
	#AutoIt3Wrapper_Compile_both=Y										;~ (Y/N) Compile both X86 and X64 in one run. Default=N
	;===============================================================================================================
	; Target Program Resource info
	;===============================================================================================================
	#AutoIt3Wrapper_Res_Comment=Ownership								;~ Comment field
	#AutoIt3Wrapper_Res_Description=Take Ownership Shell Extension      ;~ Description field
	#AutoIt3Wrapper_Res_Fileversion=1.0.2.280
	#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y  					;~ (Y/N/P) AutoIncrement FileVersion. Default=N
	#AutoIt3Wrapper_Res_FileVersion_First_Increment=N					;~ (Y/N) AutoIncrement Y=Before; N=After compile. Default=N
	#AutoIt3Wrapper_Res_HiDpi=Y                      					;~ (Y/N) Compile for high DPI. Default=N
	#AutoIt3Wrapper_Res_ProductVersion=0             					;~ Product Version
	#AutoIt3Wrapper_Res_Language=2057									;~ Resource Language code . Default 2057=English (United Kingdom)
	#AutoIt3Wrapper_Res_LegalCopyright=© 2017 Rizonesoft				;~ Copyright field
	#AutoIt3Wrapper_res_requestedExecutionLevel=highestAvailable		;~ asInvoker, highestAvailable, requireAdministrator or None (remove the trsutInfo section).  Default is the setting from Aut2Exe (asInvoker)
	#AutoIt3Wrapper_res_Compatibility=Vista,Win7,Win8,Win81				;~ Vista/Windows7/win7/win8/win81 allowed separated by a comma     (Default=Win81)
	;#AutoIt3Wrapper_Res_SaveSource=N									;~ (Y/N) Save a copy of the Script_source in the EXE resources. Default=N
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
	#AutoIt3Wrapper_Res_Field=ProductName|Ownership
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
	#AutoIt3Wrapper_Res_Icon_Add=Themes\Icons\OwnershipH.ico
	#AutoIt3Wrapper_Res_Icon_Add=Themes\Icons\update.ico

	#AutoIt3Wrapper_Res_Icon_Add=Themes\Icons\Donate.ico

	#AutoIt3Wrapper_Res_Icon_Add=Themes\Icons\Menus\update.ico
	;===============================================================================================================
	; Tidy Settings
	;===============================================================================================================
	#AutoIt3Wrapper_Run_Tidy=N										;~ (Y/N) Run Tidy before compilation. Default=N
	;#AutoIt3Wrapper_Tidy_Stop_OnError=              				;~ (Y/N) Continue when only Warnings. Default=Y
	;#Tidy_Parameters=                               				;~ Tidy Parameters...see SciTE4AutoIt3 Helpfile for options
	;===============================================================================================================
	; Au3Stripper Settings
	;===============================================================================================================
	#AutoIt3Wrapper_Run_Au3Stripper=N								;~ (Y/N) Run Au3Stripper before compilation. default=N
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


#include <ButtonConstants.au3>
#include <GuiConstantsEx.au3>
#include <Misc.au3>
#include <StaticConstants.au3>

#include "..\..\Includes\GuiMenuEx.au3"
#include "..\..\Includes\Update.au3"
#include "..\..\Includes\Versioning.au3"


Global Const $SET_COMPNAME = "Rizonesoft"
Global Const $SET_PROGNAME = "Ownership"
Global Const $SET_PROGSHORTNAME = "Ownership"
Global Const $SET_PROGSHORTNAME_X64 = $SET_PROGSHORTNAME & "_X64"
Global Const $SET_DOWNLOADURL = "http://www.rizonesoft.com/downloads/"
Global Const $SET_CONTACTURL = "http://www.rizonesoft.com/contact/"
Global Const $SET_UPDATEURL = "http://www.rizonesoft.com/update/" & $SET_PROGSHORTNAME & ".ru"
Global Const $SET_UPDATEANI = @ScriptDir & "\Themes\Processing\64\Update.ani"
Global Const $SET_SINGLETON = 1
Global Const $SET_ENABLECACHE = 1
Global Const $SET_MSGTIMEOUT = 60

Global $g_sWorkingDir = @ScriptDir ;~ Root Directory
Global $g_sPathIni = $g_sWorkingDir & "\" & $SET_PROGSHORTNAME & ".ini" ;~ Full Path to the Configuaration file
Global $g_sAppDataRoot = @AppDataDir & "\" & $SET_COMPNAME & "\" & $SET_PROGSHORTNAME
Global $g_sCacheRoot = $g_sWorkingDir & "\Cache\" & $SET_PROGSHORTNAME

Global $g_CoreGui, $g_CoreGuiHandle, $g_GuiIcon, $g_AniUpdate, $g_IconHovering = 0
Global $g_sProgramTitle = _GUIGetTitle($SET_PROGNAME)
Global $g_sIcoProgram = @ScriptFullPath
Global $g_sIcoProgHover = @ScriptFullPath
Global $g_IcoHovering = 1
Global $g_BtnInstall, $g_ChkInstallPause, $g_LblDescription
Global $g_MenuFile, $g_MenuHelp


Func _ProgramStartUp()
EndFunc   ;==>_ProgramStartUp


If _Singleton($g_sProgramTitle, 1) = 0 And $SET_SINGLETON = 1 Then
	MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, "Warning", "Another occurence of " & $SET_PROGNAME & _
			" is already running. This message will self-destruct in " & $SET_MSGTIMEOUT & " seconds.", $SET_MSGTIMEOUT)
	Exit
EndIf


If Not @AutoItX64 And @OSArch = "X64" Then

	Local $s64BitExePath = @ScriptDir & "\" & $SET_PROGSHORTNAME_X64 & ".exe"
	Local $iMsgBoxResult

	If FileExists($s64BitExePath) Then
		ShellExecute($s64BitExePath)
		_ShutdownProgram()
	Else

		$iMsgBoxResult = MsgBox($MB_YESNO + $MB_ICONWARNING + $MB_TOPMOST, "Warning", "Unfortuantely " & _
				$SET_PROGNAME & " 32 Bit is not compatible with your Windows version. Please download " & _
				$SET_PROGNAME & " 64 Bit from " & $SET_DOWNLOADURL, $SET_MSGTIMEOUT)

		Switch $iMsgBoxResult
			Case $IDYES
				ShellExecute($SET_DOWNLOADURL)
				_ShutdownProgram()
			Case -1, $IDNO
				_ShutdownProgram()
		EndSwitch

	EndIf

Else

	If @OSVersion = "WIN_2000" Or @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then
		$iMsgBoxResult = MsgBox($MB_YESNO + $MB_ICONERROR + $MB_TOPMOST, "Oops!", $SET_PROGNAME & " is not compatable with your version of windows. " & _
				"If you believe this to be an error, please feel free to leave a message at " & _
				$SET_CONTACTURL & " with all the details.", $SET_MSGTIMEOUT)
		Switch $iMsgBoxResult
			Case $IDYES
				ShellExecute($SET_CONTACTURL)
				_ShutdownProgram()
			Case -1, $IDNO
				_ShutdownProgram()
		EndSwitch
	Else
		_SetResources()
		_SetWorkingDirectories()
;~ 	_LoggingInitialize($SDK_PROGRAMNAME)
;~ 	_LoadConfiguration()
		_StartCoreGui()
	EndIf

EndIf


Func _StartCoreGui()

	Local $miHelpUdate
	Local $btnHelp, $icoDonate, $lblHomeLink

	$g_CoreGui = GUICreate($g_sProgramTitle, 350, 250, -1, 25, -1)
	If Not @Compiled Then GUISetIcon($g_sIcoProgram)
	GUISetHelp("hh.exe " & @ScriptDir & "\Documents\Ownership.chm", $g_CoreGui)

	GUISetFont(8.5, 400, -1, "Verdana", $g_CoreGui, $CLEARTYPE_QUALITY)
	$g_GuiIcon = GUICtrlCreateIcon($g_sIcoProgram, 99, 10, 10, 72, 72)
	GUICtrlSetTip($g_GuiIcon, "Version " & _GetProgramVersion(0) & @CRLF & _
			"Build with AutoIt version " & @AutoItVersion & @CRLF & _
			"Copyright © " & @YEAR & " " & $SET_COMPNAME, _
			"About " & $SET_PROGNAME, $TIP_INFOICON, $TIP_BALLOON)
	GUICtrlSetCursor($g_GuiIcon, 0)
	$g_AniUpdate = GUICtrlCreateIcon($SET_UPDATEANI, 0, 14, 14, 64, 64)
	GUICtrlSetState($g_AniUpdate, $GUI_HIDE)

	$g_MenuFile = GUICtrlCreateMenu("&File")
	$g_MenuHelp = GUICtrlCreateMenu("&Help")

	$miHelpUdate = _GuiCtrlMenuEx_CreateMenuItem("Check for updates", $g_MenuHelp, @ScriptFullPath, 204)

	GUICtrlSetOnEvent($miHelpUdate, "_CheckForUpdates")

	$g_LblDescription = GUICtrlCreateLabel("", 96, 15, 200, 40)
	$g_ChkInstallPause = GUICtrlCreateCheckbox("Install with Pause", 96, 68, 200, 20)

	$g_BtnInstall = GUICtrlCreateButton("Install " & $SET_PROGNAME, (350 - 200) / 2, 100, 200, 33, $BS_DEFPUSHBUTTON)
	GUICtrlSetFont($g_BtnInstall, 10)

	; $btnHelp = GUICtrlCreateButton("Help (F1)", 65, 100, 95, 33)
	GUICtrlCreateLabel("", 10, 150, 330, 2, $SS_ETCHEDHORZ)
	GUICtrlCreateLabel("© " & @YEAR & " Rizonesoft", 10, 188, 195, 18)
	GUICtrlSetColor(-1, 0x333333)
	$lblHomeLink = GUICtrlCreateLabel("www.rizonesoft.com", 10, 205, 195, 18)
	GUICtrlSetFont($lblHomeLink, 9, -1, 400, "", 5) ;Underlined
	GUICtrlSetColor($lblHomeLink, 0x0000FF)
	GUICtrlSetCursor($lblHomeLink, 0)

	$icoDonate = GUICtrlCreateIcon(@ScriptFullPath, 203, 265, 155, 64, 64)
	GUICtrlSetCursor($icoDonate, 0)

	GUISetState(@SW_SHOW, $g_CoreGui)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ShutdownProgram", $g_CoreGui)
	AdlibRegister("_OnIconsHover", 50)

	_SoftwareUpdateCheck($SET_PROGNAME, $SET_UPDATEURL, @ScriptFullPath, 202)

	While 1
		Sleep(35)
	WEnd

EndFunc   ;==>_StartCoreGui


Func _OnIconsHover()

	Local $iCursor = GUIGetCursorInfo()
	If Not @error Then

		If $iCursor[4] = $g_GuiIcon And $g_IcoHovering = 1 Then
			$g_IcoHovering = 0
			GUICtrlSetImage($g_GuiIcon, $g_sIcoProgHover, 201)
		ElseIf $iCursor[4] <> $g_GuiIcon And $g_IcoHovering = 0 Then
			$g_IcoHovering = 1
			GUICtrlSetImage($g_GuiIcon, $g_sIcoProgram, 99)
		EndIf

	EndIf

EndFunc   ;==>_OnIconsHover


#Region "Resources"

Func _SetResources()

	If Not @Compiled Then
		$g_sIcoProgram = @ScriptDir & "\Themes\Icons\" & $SET_PROGSHORTNAME & ".ico"
		$g_sIcoProgHover = @ScriptDir & "\Themes\Icons\" & $SET_PROGSHORTNAME & "H.ico"
	EndIf

EndFunc   ;==>_SetResources

#EndRegion "Resources"


#Region "Working Directories"

Func _ResetWorkingDirectories()

	$g_sPathIni = $g_sWorkingDir & "\" & $SET_PROGSHORTNAME & ".ini"
	$g_sCacheRoot = $g_sWorkingDir & "\Cache\" & $SET_PROGSHORTNAME
	If $SET_ENABLECACHE == 1 Then DirCreate($g_sCacheRoot)

EndFunc   ;==>_ResetWorkingDirectories


Func _SetAppDataDirectory()

	DirCreate($g_sAppDataRoot)

	$g_sWorkingDir = $g_sAppDataRoot

	_ResetWorkingDirectories()
	_GenerateIniFile($g_sPathIni, 0)

EndFunc   ;==>_SetAppDataDirectory


Func _SetWorkingDirectories()

	If IniRead($g_sPathIni, $SET_PROGSHORTNAME, "PortableEdition", 1) = 0 Then
		_SetAppDataDirectory()
	Else
		If Not _GenerateIniFile($g_sPathIni) Then
			_SetAppDataDirectory()
		Else
			_ResetWorkingDirectories()
		EndIf
	EndIf

EndFunc   ;==>_SetWorkingDirectories


Func _GenerateIniFile($iniPath, $bPortable = 1)
	Local $iResult

	$iResult = IniWrite($iniPath, $SET_PROGSHORTNAME, "PortableEdition", $bPortable)
	Return $iResult
EndFunc   ;==>_GenerateIniFile

#EndRegion "Working Directories"


Func _CheckForUpdates()

	_SetUpdateAnimationState($GUI_SHOW)
	_SoftwareUpdateCheck($SET_PROGNAME, $SET_UPDATEURL, @ScriptFullPath, 202, True)
	_SetUpdateAnimationState($GUI_HIDE)

EndFunc


Func _SetUpdateAnimationState($iState)

	If FileExists($SET_UPDATEANI) Then
		If $iState = 16 Then

			GUICtrlSetState($g_AniUpdate, $GUI_SHOW)
			GUICtrlSetState($g_GuiIcon, $GUI_HIDE)
			_SetProcessingStates($GUI_DISABLE)

		ElseIf $iState = 32 Then

			GUICtrlSetState($g_AniUpdate, $GUI_HIDE)
			GUICtrlSetState($g_GuiIcon, $GUI_SHOW)
			_SetProcessingStates($GUI_ENABLE)

		EndIf
	EndIf

EndFunc


Func _SetProcessingStates($iState)

	GUICtrlSetState($g_MenuFile, $iState)
	GUICtrlSetState($g_MenuHelp, $iState)

EndFunc


Func _ShutdownProgram()

;~ If $g_ClearCacheOnExit == 1 Then DirRemove($g_CachePath, 1)
	WinSetTrans($g_CoreGui, Default, 255)
	If $SET_SINGLETON Then
		Local $iPID = ProcessExists(@ScriptName)
		If $iPID Then ProcessClose($iPID)
	EndIf
	Exit

EndFunc   ;==>_ShutdownProgram
