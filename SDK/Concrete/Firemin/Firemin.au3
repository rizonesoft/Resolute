#NoTrayIcon
#OnAutoItStartRegister "_ReBarStartUp"


#Region AutoIt3Wrapper Directives Section

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
#AutoIt3Wrapper_Icon=..\..\Resources\Icons\Firemin.ico			;~ Filename of the Ico file to use for the compiled exe
#AutoIt3Wrapper_OutFile_Type=exe								;~ exe=Standalone executable (Default); a3x=Tokenised AutoIt3 code file
#AutoIt3Wrapper_OutFile=..\..\..\Resolute\Firemin.exe			;~ Target exe/a3x filename.
#AutoIt3Wrapper_OutFile_X64=..\..\..\Resolute\Firemin_X64.exe	;~ Target exe filename for X64 compile.
;#AutoIt3Wrapper_Compression=4									;~ Compression parameter 0-4  0=Low 2=normal 4=High. Default=2
;#AutoIt3Wrapper_UseUpx=Y										;~ (Y/N) Compress output program.  Default=Y
;#AutoIt3Wrapper_UPX_Parameters=								;~ Override the default settings for UPX.
#AutoIt3Wrapper_Change2CUI=N									;~ (Y/N) Change output program to CUI in stead of GUI. Default=N
#AutoIt3Wrapper_Compile_both=Y									;~ (Y/N) Compile both X86 and X64 in one run. Default=N
;===============================================================================================================
; Target Program Resource info
;===============================================================================================================
#AutoIt3Wrapper_Res_Comment=Firemin									;~ Comment field
#AutoIt3Wrapper_Res_Description=Firemin						      	;~ Description field
#AutoIt3Wrapper_Res_Fileversion=9.5.3.8029
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y  					;~ (Y/N/P) AutoIncrement FileVersion. Default=N
#AutoIt3Wrapper_Res_FileVersion_First_Increment=N					;~ (Y/N) AutoIncrement Y=Before; N=After compile. Default=N
#AutoIt3Wrapper_Res_HiDpi=N                      					;~ (Y/N) Compile for high DPI. Default=N
#AutoIt3Wrapper_Res_ProductVersion=8             					;~ Product Version
#AutoIt3Wrapper_Res_Language=2057									;~ Resource Language code . Default 2057=English (United Kingdom)
#AutoIt3Wrapper_Res_LegalCopyright=© 2022 Rizonesoft				;~ Copyright field
#AutoIt3Wrapper_res_requestedExecutionLevel=asInvoker				;~ asInvoker, highestAvailable, requireAdministrator or None (remove the trsutInfo section).  Default is the setting from Aut2Exe (asInvoker)
#AutoIt3Wrapper_res_Compatibility=Vista,Win7,Win8,Win81,Win10		;~ Vista/Windows7/win7/win8/win81 allowed separated by a comma     (Default=Win81)
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
#AutoIt3Wrapper_Res_Field=ProductName|Firemin
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
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\FireminH.ico						; 201

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Information.ico			; 202
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Complete.ico				; 203
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Cross.ico				; 204
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Exclamation.ico			; 205
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Smiley-Glass.ico			; 206
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Skull.ico				; 207
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Snowman.ico				; 208

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Update.ico						; 209
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Error.ico						; 210

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Dialogs\Check.ico				; 211
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Dialogs\Error.ico				; 212
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Dialogs\Gear.ico					; 213
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Dialogs\Information.ico			; 214
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Dialogs\Love.ico					; 215

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\PayPal.ico					; 216
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\PayPalH.ico				; 217
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\sa.ico						; 218
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\saH.ico					; 219
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\Facebook.ico				; 220
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\FacebookH.ico				; 221
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\Twitter.ico				; 222
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\TwitterH.ico				; 223
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\LinkedIn.ico				; 224
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\LinkedInH.ico				; 225
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\GitHub.ico					; 226
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\GitHubH.ico	 			; 227

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\en.ico						; 228
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\af.ico						; 229
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ar.ico						; 230
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\bg.ico						; 231
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\cs.ico						; 232
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\da.ico						; 233
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\de.ico						; 234
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\el.ico						; 235
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\es.ico						; 236
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\fr.ico						; 237
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\hi.ico						; 238
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\hr.ico						; 239
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\hu.ico						; 240
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\id.ico						; 241
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ir.ico						; 242
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\is.ico						; 243
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\it.ico						; 244
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\iw.ico						; 245
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ja.ico						; 246
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ko.ico						; 247
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\nl.ico						; 248
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\no.ico						; 249
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\pl.ico						; 250
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\pt.ico						; 251
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\pt-BR.ico					; 252
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ro.ico						; 253
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ru.ico						; 254
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\sl.ico						; 255
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\sk.ico						; 256
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\sv.ico						; 257
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\th.ico						; 258
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\tr.ico						; 259
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\vi.ico						; 260
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\zh-CN.ico					; 261
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\zh-TW.ico					; 262

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-0.ico				; 263
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-1.ico				; 264
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-2.ico				; 265
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-3.ico				; 266
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-4.ico				; 267
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-5.ico				; 268

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Gear.ico					; 269
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Logbook.ico				; 270
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Close.ico					; 271
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Update.ico					; 272
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Home.ico					; 273
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Support.ico				; 274
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\GitHub.ico					; 275
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\About.ico					; 276

;===============================================================================================================
; Tidy Settings
;===============================================================================================================
;#AutoIt3Wrapper_Run_Tidy=N										;~ (Y/N) Run Tidy before compilation. Default=N
;#AutoIt3Wrapper_Tidy_Stop_OnError=              				;~ (Y/N) Continue when only Warnings. Default=Y
;#Tidy_Parameters=                               				;~ Tidy Parameters...see SciTE4AutoIt3 Helpfile for options
;===============================================================================================================
; Au3Stripper Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Au3Stripper=N								;~ (Y/N) Run Au3Stripper before compilation. default=N
#Au3Stripper_Parameters=/MergeOnly								;~ Au3Stripper parameters...see SciTE4AutoIt3 Helpfile for options
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

#EndRegion AutoIt3Wrapper Directives Section


Opt("CaretCoordMode", 1)			;~ 1=absolute, 0=relative, 2=client
Opt("ExpandEnvStrings", 1)			;~ 0=don't expand, 1=do expand
Opt("ExpandVarStrings", 1)			;~ 0=don't expand, 1=do expand
; Opt("GUICloseOnESC", 0)			;~ 1=ESC  closes, 0=ESC won't close
Opt("GUICoordMode", 1)				;~ 1=absolute, 0=relative, 2=cell
Opt("GUIDataSeparatorChar", "|")	;~ "|" is the default
Opt("GUIOnEventMode", 1)			;~ 0=disabled, 1=OnEvent mode enabled
Opt("GUIResizeMode", 802)			;~ 0=no resizing, <1024 special resizing
Opt("GUIEventOptions", 0)			;~ 0=default, 1=just notification, 2=GUICtrlRead tab index
Opt("MouseClickDelay", 10)			;~ 10 milliseconds
Opt("MouseClickDownDelay", 10)		;~ 10 milliseconds
Opt("MouseClickDragDelay", 250)		;~ 250 milliseconds
Opt("MouseCoordMode", 1)			;~ 1=absolute, 0=relative, 2=client
Opt("MustDeclareVars", 1)			;~ 0=no, 1=require pre-declaration
Opt("PixelCoordMode", 1)			;~ 1=absolute, 0=relative, 2=client
Opt("SendAttachMode", 0)			;~ 0=don't attach, 1=do attach
Opt("SendCapslockMode", 1)			;~ 1=store and restore, 0=don't
Opt("SendKeyDelay", 5)				;~ 5 milliseconds
Opt("SendKeyDownDelay", 1)			;~ 1 millisecond
Opt("TCPTimeout", 100)				;~ 100 milliseconds
Opt("TrayIconDebug", 0)
Opt("TrayIconHide", 0)
Opt("TrayAutoPause", 0)				;~ 0=no pause, 1=Pause
Opt("TrayMenuMode", 3)				;~ 0=append, 1=no default menu, 2=no automatic check, 4=menuitemID  not return
Opt("TrayOnEventMode", 1)			;~ 0=disable, 1=enable
Opt("WinDetectHiddenText", 0)		;~ 0=don't detect, 1=do detect
Opt("WinSearchChildren", 1)			;~ 0=no, 1=search children also
Opt("WinTextMatchMode", 1)			;~ 1=complete, 2=quick
Opt("WinTitleMatchMode", 4)			;~ 1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
Opt("WinWaitDelay", 250)			;~ 250 milliseconds


Func _ReBarStartUp()
EndFunc   ;==>_ReBarStartUp


#include <Array.au3>
#include <GuiConstantsEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <GuiToolBar.au3>
#include <Process.au3>
#include <TrayConstants.au3>
#include <Misc.au3>
#include <WinAPIProc.au3>
#include <WinAPITheme.au3>
#include <WindowsConstants.au3>

#include "..\..\Includes\About.au3"
#include "..\..\Includes\Donate.au3"
#include "..\..\Includes\GuiMenuEx.au3"
#include "..\..\Includes\ImageListEx.au3"
#include "..\..\Includes\Link.au3"
#include "..\..\Includes\StringEx.au3"
#include "..\..\Includes\Update.au3"
#include "..\..\Includes\Versioning.au3"

#include "Includes\Localization.au3"


;~ Developer Constants
Global Const $DEBUG_UPDATE		= False

;~ Constants
Global Const $CNT_MENUICONS		= 8
Global Const $CNT_LOGICONS		= 7
Global Const $CNT_LANGICONS		= 35

;~ General Settings
Global $g_sCompanyName			= "Rizonesoft"
Global $g_sProgShortName		= "Firemin"
Global $g_sProgShortName_X64	= $g_sProgShortName & "_X64"
Global $g_sProgName				= "Firemin"
Global $g_iSingleton			= True
Global $g_iCoreGuiLoaded		= False

;~ Links
Global $g_sUrlCompHomePage		= "https://www.rizonesoft.com|www.rizonesoft.com"												; https://www.rizonesoft.com
Global $g_sUrlSupport			= "https://www.rizonesoft.com/#contact|www.rizonesoft.com/#contact"								; https://www.rizonesoft.com/contact
Global $g_sUrlDownloads			= "https://www.rizonesoft.com/downloads/|/www.rizonesoft.com/downloads/"						; https://www.rizonesoft.com/downloads/
Global $g_sUrlFacebook			= "https://www.facebook.com/rizonesoft|Facebook.com/rizonesoft"									; https://www.facebook.com/rizonesoft
Global $g_sUrlTwitter			= "https://twitter.com/rizonesoft|Twitter.com/Rizonesoft"										; https://twitter.com/Rizonesoft
Global $g_sUrlLinkedIn	 		= "https://www.linkedin.com/in/rizonetech|LinkedIn.com/in/rizonetech" 							; https://www.linkedin.com/in/rizonetech
Global $g_sUrlRSS				= "https://www.rizonesoft.com/feed|www.rizonesoft.com/feed"										; https://www.rizonesoft.com/feed
Global $g_sUrlPayPal			= "https://www.paypal.com/donate/?hosted_button_id=7UGGCSDUZJPFE|PayPal.com/donate"				; https://www.paypal.com/donate/?hosted_button_id=7UGGCSDUZJPFE
Global $g_sUrlGitHub			= "https://github.com/rizonesoft/Resolute|GitHub.com/rizonesoft/Resolute"						; https://github.com/rizonesoft/Resolute
Global $g_sUrlGitHubIssues		= "https://github.com/rizonesoft/Resolute/issues|GitHub.com/rizonesoft/Resolute/issues"			; https://github.com/rizonesoft/Resolute/issues
Global $g_sUrlSA				= "https://en.wikipedia.org/wiki/South_Africa|Wikipedia.org/wiki/South_Africa"					; https://en.wikipedia.org/wiki/South_Africa
Global $g_sUrlProgPage			= "https://www.rizonesoft.com/downloads/firemin/|www.rizonesoft.com/downloads/firemin/"			; https://www.rizonesoft.com/downloads/firemin/
Global $g_sUrlUpdate			= "UpdateURL=https://www.rizonesoft.com/downloads/update/?id=fireminwww.rizonesoft.com/downloads/update"

;~ Path Variables
Global $g_sRootDir			= @ScriptDir
Global $g_sWorkingDir		= $g_sRootDir ;~ Working Directory
Global $g_sPathIni			= $g_sWorkingDir & "\" & $g_sProgShortName & ".ini" ;~ Full Path to the Configuaration file
Global $g_sAppDataRoot		= @AppDataDir & "\" & $g_sCompanyName & "\" & $g_sProgShortName
Global $g_sResourcesDir		= _PathFull(@ScriptDir & "\..\..\Resources")
Global $g_sProcessDir		= $g_sRootDir &	"\Processing"
Global $g_sProcessSim		= $g_sProcessDir & "\16\Process.ani"
Global $g_sExportRoot		= $g_sWorkingDir & "\Export\" & $g_sProgShortName
Global $g_sDocsDir			= $g_sRootDir & "\Documents\" & $g_sProgShortName ;~ Documentation Directory
Global $g_sDocHelpFile		= $g_sDocsDir & "\" & $g_sProgShortName & ".chm"
Global $g_sDocChanges		= $g_sDocsDir & "\Changes.txt"
Global $g_sDocLicense		= $g_sDocsDir & "\License.txt"
Global $g_sDocReadme		= $g_sDocsDir & "\Readme.txt"

; Configuration Settings
Global $g_iBoostMill		 = 1000
Global $g_iCleanLimit		 = 200
Global $g_sBrowserName
Global $g_sBrowserPath		 = @ProgramFilesDir & "\Mozilla Firefox\firefox.exe"
Global $g_sExtendedProcs	 = "plugin-container.exe"
Global $g_sCoreProcess
Global $g_iCoreProcessUsage	 = 0
Global $g_iCoreProcessPeak	 = 0
Global $g_iExtendedProcUsage     = 0
Global $g_iBoostEnabled		 = 1
Global $g_iLimitEnabled		 = 1
Global $g_iStartBrowser		 = 0
Global $g_iExtProcsEnabled	 = 1
Global $g_iShowNotifications = 0

If Not @Compiled Then
	$g_sProcessDir = _PathFull(@ScriptDir & "\..\..\..\Resolute\Processing")
EndIf

;~ Working Directories needs to be set before language is loaded.
_SetWorkingDirectories()

;~ Language Settings
Global $g_sLanguageDir		= $g_sRootDir & "\Language\" & $g_sProgShortName
Global $g_sSelectedLanguage = IniRead($g_sPathIni, $g_sProgShortName, "Language", "en")
Global $g_tSelectedLanguage = $g_sSelectedLanguage
Global $g_sLanguageFile		= $g_sLanguageDir & "\" & $g_sSelectedLanguage & ".ini"

;~ Resources
Global $g_iUpdateIconStart				= 209
Global $g_iDialogIconStart				= 211
Global $g_iAboutIconStart				= 216
Global $g_iLangIconStart				= 228
Global $g_iPowerIconsStart				= 263
Global $g_iMenuIconsStart				= 269

Global $g_aCoreIcons[3]
Global $g_iSizeIcon						= 64
Global $g_aLognIcons[$CNT_LOGICONS]
Global $g_aLanguageIcons[$CNT_LANGICONS]
Global $g_aMenuIcons[$CNT_MENUICONS]
Global $g_sDlgOptionsIcon

;~ Update Notification Settings
Global $g_sUpdateAnimation	= $g_sProcessDir & "\" & $g_iSizeIcon & "\Globe.ani"
If $DEBUG_UPDATE = True Then
	Global $g_sRemoteUpdateFile	= "https://www.rizonesoft.com/update/" & $g_sProgShortName & ".ruz"
Else
	Global $g_sRemoteUpdateFile	= "https://www.rizonesoft.com/update/" & $g_sProgShortName & ".ru"
EndIf
Global $g_iCheckForUpdates	= 4

;~ Donate
Global $g_sDonateName = "Unknown"
Global $g_iDonateBuild = 13

;~ Title Settings
Global $g_TitleShowAdmin	= True	;~ Show whether program is running as Administrator
Global $g_TitleShowArch		= True	;~ Show program architecture
Global $g_TitleShowVersion	= True	;~ Show program version
Global $g_TitleShowBuild	= True	;~ Show program build
Global $g_TitleShowAutoIt	= True	;~ Show AutoIt version

;~ Interface Settings
Global $g_iCoreGuiWidth		= 500
Global $g_iCoreGuiHeight	= 560
Global $g_iMsgBoxTimeOut	= 60

;~ About Dialog
Global $g_sAboutCredits		= "Derick Payne (Rizonesoft), Brian J Christy (Beege), " & _
							"G Sandler (MrCreatoR), Holger Kotsch, KaFu, LarsJ, nickston, ProgAndy, Yashied"
Global $g_sProgramTitle 	= _GUIGetTitle($g_sProgName)	;~ Get Program Ttile, including version.
Global $g_hCoreGui										;~ Main GUI
Global $g_hGuiIcon										;~ Main Icon
Global $g_AniUpdate
Global $g_hMenuFile
Global $g_hMenuHelp, $g_hUpdateMenuItem
Global $g_OldSystemParam								;~ Used when resizing the main GUI
Global $g_hSubHeading
Global $g_IconProfile
Global $g_hIconProfile
Global $g_hLblPrflTitle
Global $g_hLblPrflPublisher
Global $g_hLblPrflPathCaption
Global $g_hLblPrflPathExe
Global $g_hLblProcessUsage
Global $g_hLblProcessPeak
Global $g_hLblExtendUsage
Global $g_hBtnPrflBrowse
Global $g_hChkReduceEnabled
Global $g_hComboReduceMill
Global $g_hChkCleanLimit
Global $g_hComboCleanLimit
Global $g_hChkBrowserAutoStart
Global $g_hChkExtendedProcs
Global $g_hBtnExtendedProcs
Global $g_hChkStartWindows
Global $g_hLblUpdated
Global $g_hLblTimeStatus
Global $g_hBtnSave
Global $g_hBtnCancel

;~ Tray menu items
Global $g_hTrItemAbout
Global $g_hTrItemOpenCore
Global $g_hTrItemExProcs
Global $g_hTrItemOptimize
Global $g_hTrItemBrsrRun
Global $g_hTrItemBrsrRunSafe

If Not IsDeclared("g_iParentState") Then Global $g_iParentState
If Not IsDeclared("g_iParent") Then Global $g_iParent

Global $g_hOptionsGui
Global $g_hOChkShowTrayTips
Global $g_hOEditExtProcs
Global $g_hOEditExtProcsTemp 		= ""
Global $g_hOIconPower
Global $g_hOComboPower
Global $g_hOChkSaveRealtime
Global $g_hOChkReduceMemory
Global $g_hOListLanguage
Global $g_hOImgLanguage
Global $g_hOIconLanguage
Global $g_hOLblLanguage
Global $g_hOLblPrefsUpdated
Global $g_hOBtnSave
Global $g_hOBtnCancel

Global $g_iProcessPriority 		= 3
Global $g_iSaveRealtime			= 0
Global $g_iReduceMemory 		= 1
Global $g_iReduceEveryMill 		= 300
Global $g_iMaxSysMemoryPerc 	= 80
Global $g_iProcessesCount		= 0
Global $g_iExtendedProcessUsage = 0
Global $g_iExtendedProcessPeak	= 0

Global $g_hFireTrayHandle

_Localization_Messages()   		;~ Load Message Language Strings
If _Singleton($g_sProgramTitle, 1) = 0 And $g_iSingleton = True Then
	MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, $g_aLangMessages[3], $g_aLangMessages[4], $g_iMsgBoxTimeOut)
	Local $currPID = @AutoItPID
	ProcessClose($currPID)
EndIf

If @OSVersion = "WIN_2000" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then
	Local $iMsgBoxResult = MsgBox($MB_YESNO + $MB_ICONERROR + $MB_TOPMOST, $g_aLangMessages[3], StringFormat($g_aLangMessages[5], _
				_Link_Split($g_sUrlSupport, 2)), $g_iMsgBoxTimeOut)
	Switch $iMsgBoxResult
		Case $IDYES
			ShellExecute(_Link_Split($g_sUrlSupport))
			Exit
		Case -1, $IDNO
			Exit
	EndSwitch
Else

	If Not @AutoItX64 And @OSArch = "X64" Then

		Local $s64BitExePath = @ScriptDir & "\" & $g_sProgShortName_X64 & ".exe"

		If FileExists($s64BitExePath) Then
			ShellExecute($s64BitExePath)
			Exit
		Else

			Local $iMsgBoxResult = MsgBox($MB_YESNO + $MB_ICONWARNING + $MB_TOPMOST, $g_aLangMessages[3], StringFormat($g_aLangMessages[6], _
					_Link_Split($g_sUrlDownloads, 2)), $g_iMsgBoxTimeOut)

			Switch $iMsgBoxResult
				Case $IDYES
					ShellExecute(_Link_Split($g_sUrlDownloads))
					Exit
				Case -1, $IDNO
					Exit
			EndSwitch

		EndIf

	Else

		_LoadConfiguration()

		;If Not IsAdmin() Then
			;MsgBox(0, "", "")
		;EndIf

		OnAutoItExitRegister("_TerminateProgram")

		_Localization_Menus()		;~ Load Menu Language Strings
		_Localization_Custom()		;~ Load Custom Language Strings
		_Localization_About()		;~ Load About Language Strings
		_SetResources()
		_SetHotKeys()
		_StartCore()

	EndIf

EndIf


Func _SetHotKeys()
	HotKeySet("+!{F4}", "_ShutdownProgram")
EndFunc


Func _StartCore()

	Local $trmnuClose

	$g_hTrItemAbout = TrayCreateItem(StringFormat($g_aLangMenus[11], _GetProgramVersion()))
	TrayCreateItem("")
	$g_hTrItemOpenCore = TrayCreateItem($g_aLangMenus[12])
	$g_hTrItemExProcs = TrayCreateItem($g_aLangMenus[13])
	TrayCreateItem("")
	; $g_hTrItemOptimize = TrayCreateItem("Mozbase Optimizer")
	; TrayCreateItem("")
	$g_hTrItemBrsrRun = TrayCreateItem(StringFormat($g_aLangMenus[14], $g_sBrowserName))
	$g_hTrItemBrsrRunSafe = TrayCreateItem(StringFormat($g_aLangMenus[15], $g_sBrowserName))
	TrayCreateItem("")
	$trmnuClose = TrayCreateItem($g_aLangMenus[2])

	TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "_StartCoreGui")

	TrayItemSetState($g_hTrItemBrsrRunSafe, $GUI_DISABLE)
	TrayItemSetState($g_hTrItemOpenCore, $TRAY_DEFAULT)

	TrayItemSetOnEvent($g_hTrItemAbout, "_About_ShowDialog")
	TrayItemSetOnEvent($g_hTrItemOpenCore, "_StartCoreGui")
	TrayItemSetOnEvent($g_hTrItemExProcs, "_ShowPreferencesDlg")
	TrayItemSetOnEvent($g_hTrItemBrsrRun, "_RunBrowser")
	TrayItemSetOnEvent($g_hTrItemBrsrRunSafe, "_RunBrowserSafe")
	TrayItemSetOnEvent($trmnuClose, "_ShutdownProgram")

	TraySetState($TRAY_ICONSTATE_SHOW)
	TraySetToolTip($g_sProgramTitle)
	TraySetClick(8)

	If $g_iStartBrowser Then
		_RunBrowser()
	EndIf

	; AdlibRegister("_ReduceMemory", 300)
	AdlibRegister("_ClearProcessesWorkingSet", $g_iBoostMill)

	_SetTrayItemStates()

	If Int(IniRead($g_sPathIni, $g_sProgShortName, "FirstRun", 1)) = 1 Then
		IniWrite($g_sPathIni, $g_sProgShortName, "FirstRun", 0)
		_StartCoreGui()
	EndIf

	If $g_iCheckForUpdates == 4 Then
		_SoftwareUpdateCheck()
    EndIf

    If @Compiled Then
		; AdlibRegister("_ReduceMemory", $g_iReduceEveryMill)
	EndIf

	TraySetToolTip($g_sProgramTitle)
	While 1
		Sleep(55)
	WEnd



EndFunc   ;==>_StartCoreGUI


Func _StartCoreGui()

	If $g_iCoreGuiLoaded = True Then
		Return
	EndIf

	Local $miFileOptions, $miFileClose
	Local $miHelpHome, $miHelpDownloads, $miHelpSupport, $miHelpGitHub, $miHelpDonate, $miHelpAbout
	Local $hHeading

	TrayItemSetState($g_hTrItemOpenCore, $GUI_DISABLE)
	$g_iCoreGuiLoaded = True

	$g_hCoreGui = GUICreate($g_sProgramTitle, $g_iCoreGuiWidth, $g_iCoreGuiHeight, -1, -1)
	If Not @Compiled Then GUISetIcon($g_aCoreIcons[0])
	GUISetFont(8.5, 400, -1, "Verdana", $g_hCoreGui, $CLEARTYPE_QUALITY)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseCoreGui", $g_hCoreGui)
	;~ GUISetOnEvent($GUI_EVENT_CLOSE, "_ShutdownProgram", $g_hCoreGui)

	$g_hMenuFile = GUICtrlCreateMenu($g_aLangMenus[0])
	$g_hMenuHelp = GUICtrlCreateMenu($g_aLangMenus[3])

	_GuiCtrlMenuEx_SetMenuIconBkColor(0xF0F0F0)
	_GuiCtrlMenuEx_SetMenuIconBkGrdColor(0xFFFFFF)

	$miFileOptions = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[1], $g_hMenuFile, $g_aMenuIcons[0], $g_iMenuIconsStart)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuFile)
	$miFileClose = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[2], $g_hMenuFile, $g_aMenuIcons[2], $g_iMenuIconsStart + 2)

	$g_hUpdateMenuItem = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[4], $g_hMenuHelp, $g_aMenuIcons[3], $g_iMenuIconsStart + 3)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpHome = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[5], $g_hMenuHelp, $g_aMenuIcons[4], $g_iMenuIconsStart + 4)
	$miHelpDownloads = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[6], $g_hMenuHelp)
	$miHelpSupport = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[7], $g_hMenuHelp, $g_aMenuIcons[5], $g_iMenuIconsStart + 5)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpGitHub = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[8], $g_hMenuHelp, $g_aMenuIcons[6], $g_iMenuIconsStart + 6)
	$miHelpDonate = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[9], $g_hMenuHelp)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpAbout = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[10], $g_hMenuHelp, $g_aMenuIcons[7], $g_iMenuIconsStart + 7)
	GUICtrlSetOnEvent($miFileOptions, "_ShowPreferencesDlg")
	GUICtrlSetOnEvent($miFileClose, "_ShutdownProgram")

	GUICtrlSetOnEvent($g_hUpdateMenuItem, "_CheckForUpdates")
	GUICtrlSetOnEvent($miHelpHome, "_About_HomePage")
	GUICtrlSetOnEvent($miHelpDownloads, "_About_Downloads")
	GUICtrlSetOnEvent($miHelpSupport, "_About_Support")
	GUICtrlSetOnEvent($miHelpGitHub, "_About_GitHubIssues")
	GUICtrlSetOnEvent($miHelpDonate, "_About_PayPal")
	GUICtrlSetOnEvent($miHelpAbout, "_About_ShowDialog")

	$g_hGuiIcon = GUICtrlCreateIcon($g_aCoreIcons[0], 99, 10, 10, $g_iSizeIcon, $g_iSizeIcon)
	GUICtrlSetTip($g_hGuiIcon, $g_aLangAbout[1] & Chr(32) & _GetProgramVersion(0) & @CRLF & _
			$g_aLangAbout[2] & Chr(32) & @AutoItVersion & @CRLF & _
			$g_aLangAbout[3] & " © " & @YEAR & " " & $g_sCompanyName, _
			$g_aLangAbout[0], $TIP_INFOICON)
	GUICtrlSetCursor($g_hGuiIcon, 0)
	GUICtrlSetOnEvent($g_hGuiIcon, "_About_ShowDialog")
	$g_AniUpdate = GUICtrlCreateIcon($g_sUpdateAnimation, 0, 10, 10, $g_iSizeIcon, $g_iSizeIcon)
	GUICtrlSetState($g_AniUpdate, $GUI_HIDE)
	$hHeading = GUICtrlCreateLabel($g_sProgName & " " & _GetProgramVersion(1), $g_iSizeIcon + 22, 15, 300, 35)
	GUICtrlSetFont($hHeading, 12)
	$g_hSubHeading = GUICtrlCreateLabel($g_aLangCustom[0], $g_iSizeIcon + 22, 38, _
		$g_iCoreGuiWidth - $g_iSizeIcon - 42, 50)
	GUICtrlSetFont($g_hSubHeading, 9)

	GUICtrlCreateGroup($g_aLangCustom[2], 10, 95, 480, 210)
	GUICtrlSetFont(-1, 10, 700, 2)
	$g_IconProfile = GUICtrlCreateIcon($g_aCoreIcons[0], 99, 20, 120, 48, 48)
	$g_hIconProfile = GUICtrlGetHandle($g_IconProfile)
	$g_hLblPrflTitle = GUICtrlCreateLabel(FileGetVersion($g_sBrowserPath, $FV_PRODUCTNAME) & " " & _
		FileGetVersion($g_sBrowserPath), 78, 125, 350, 20)
	GUICtrlSetFont($g_hLblPrflTitle, 10)
	$g_hLblPrflPublisher = GUICtrlCreateLabel(FileGetVersion($g_sBrowserPath, $FV_COMPANYNAME), 78, 145, 350, 15)
	GUICtrlSetColor($g_hLblPrflPublisher, 0x555555)
	$g_hLblPrflPathCaption = GUICtrlCreateLabel(StringFormat($g_aLangCustom[3], $g_sCoreProcess), 20, 180, 350, 18)
	GUICtrlSetColor($g_hLblPrflPathCaption, 0x555555)
	$g_hLblPrflPathExe = GUICtrlCreateLabel($g_sBrowserPath, 20, 200, 350, 35)
	GUICtrlSetColor($g_hLblPrflPathExe, 0x086896)
	GUICtrlSetCursor($g_hLblPrflPathExe, 0)
	GUICtrlCreateLabel($g_aLangCustom[4] & Chr(32), 20, 235, 130, 18, $SS_RIGHT)
	GUICtrlSetColor(-1, 0x555555)
	$g_hLblProcessUsage = GUICtrlCreateLabel("0 MB / 0 MB", 150, 235, 180, 18)
	GUICtrlCreateLabel($g_aLangCustom[5]& Chr(32), 20, 253, 130, 18, $SS_RIGHT)
	GUICtrlSetColor(-1, 0x555555)
	$g_hLblProcessPeak = GUICtrlCreateLabel("0 MB", 150, 253, 100, 18)

	GUICtrlCreateLabel("Extended Usage:" & Chr(32), 20, 283, 130, 18, $SS_RIGHT)
	GUICtrlSetColor(-1, 0x555555)
	$g_hLblExtendUsage = GUICtrlCreateLabel("0 MB", 150, 283, 200, 18)

	$g_hBtnPrflBrowse = GUICtrlCreateButton($g_aLangCustom[6], 370, 235, 110, 30)
	GUICtrlSetState($g_hBtnPrflBrowse, $GUI_DEFBUTTON)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	GUICtrlSetOnEvent($g_hLblPrflPathExe, "_RunBrowser")

	GUICtrlCreateGroup($g_aLangCustom[7], 10, 315, 480, 160)
	GUICtrlSetFont(-1, 10, 700, 2)
	$g_hChkReduceEnabled = GUICtrlCreateCheckbox(Chr(32) & $g_aLangCustom[8], 20, 345, 180, 20)
	$g_hComboReduceMill = GUICtrlCreateCombo("", 210, 343, 110, 20)
	GUICtrlSetData($g_hComboReduceMill, "500|1000|2000|3000|4000|5000|6000|7000|8000|9000|10000|15000|30000|45000|60000|300000|600000|900000|1800000|2700000|3600000|7200000", $g_iBoostMill)
	GUICtrlCreateLabel($g_aLangCustom[9], 327, 348, 80, 20)

	$g_hChkCleanLimit = GUICtrlCreateCheckbox(Chr(32) & $g_aLangCustom[10], 20, 368, 270, 20)
	$g_hComboCleanLimit = GUICtrlCreateCombo("", 290, 369, 55, 20)
	GUICtrlSetData($g_hComboCleanLimit, "50|100|200|300|400|500|600|700|800|900|1000|1200|1400|1600|1800|2000|2300|2600|2900|3200|3500|3800|4100|4400|4700|5000", $g_iCleanLimit)
	GUICtrlCreateLabel("MB", 352, 371, 50, 20)
	$g_hChkBrowserAutoStart = GUICtrlCreateCheckbox(Chr(32) & StringFormat($g_aLangCustom[11], $g_sBrowserName), 20, 391, 320, 20)
	$g_hChkExtendedProcs = GUICtrlCreateCheckbox(Chr(32) & $g_aLangCustom[12], 20, 414, 220, 20)
	$g_hBtnExtendedProcs = GUICtrlCreateButton($g_aLangCustom[13], 300, 414, 180, 30)
	$g_hChkStartWindows = GUICtrlCreateCheckbox(Chr(32) & $g_aLangCustom[14], 20, 445, 320, 20)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	$g_hLblUpdated = GUICtrlCreateLabel($g_aLangCustom[15], 10, 485, 200, 20)
	GUICtrlSetColor($g_hLblUpdated, 0x008000)
	GUICtrlSetState($g_hLblUpdated, $GUI_HIDE)

	$g_hBtnCancel = GUICtrlCreateButton($g_aLangCustom[16], 285, 480, 100, 30)
	$g_hBtnSave = GUICtrlCreateButton($g_aLangCustom[17], 390, 480, 100, 30)
	GUICtrlSetState($g_hBtnSave, $GUI_DISABLE)
	GUICtrlSetOnEvent($g_hBtnSave, "_SaveFireminConfig")

	GUICtrlCreateLabel("", -10, 516, 500, 1)
	GUICtrlSetBkColor(-1, 0xD6D6D6)
	$g_hLblTimeStatus = GUICtrlCreateLabel("", 10, 523, 450, 25)
	GUICtrlSetColor($g_hLblTimeStatus, 0x333333)

	GUICtrlSetState($g_hChkReduceEnabled, $g_iBoostEnabled)
	GUICtrlSetState($g_hChkCleanLimit, $g_iLimitEnabled)
	GUICtrlSetState($g_hChkBrowserAutoStart, $g_iStartBrowser)
	GUICtrlSetState($g_hChkExtendedProcs, $g_iExtProcsEnabled)
	GUICtrlSetState($g_hChkStartWindows, FileExists(@StartupDir & "\Firemin.lnk"))

	GUICtrlSetOnEvent($g_hBtnPrflBrowse, "_FindBrowser")
	GUICtrlSetOnEvent($g_hChkReduceEnabled, "_SetBoost")
	GUICtrlSetOnEvent($g_hComboReduceMill, "_SetBoost")
	GUICtrlSetOnEvent($g_hChkCleanLimit, "_SetCleanLimit")
	GUICtrlSetOnEvent($g_hComboCleanLimit, "_SetCleanLimit")
	GUICtrlSetOnEvent($g_hChkExtendedProcs, "_SetExtendedProcsEnabled")
	GUICtrlSetOnEvent($g_hChkBrowserAutoStart, "_EnableSaveSettings")
	GUICtrlSetOnEvent($g_hChkStartWindows, "_EnableSaveSettings")
	GUICtrlSetOnEvent($g_hBtnExtendedProcs, "_ShowPreferencesDlg")

	GUICtrlSetOnEvent($g_hBtnCancel, "_CloseCoreGui")
	GUICtrlSetOnEvent($g_hBtnSave, "_SaveFireminConfig")

	_LoadBrowser($g_sBrowserPath)
	_SetControlStates()

	GUISetState(@SW_SHOW, $g_hCoreGui)
	AdlibRegister("_OnIconsHover", 65)
	; AdlibRegister("_GetCoreProcessPeak", 5000)

	GUICtrlSetState($g_hChkStartWindows, FileExists(@StartupDir & "\Firemin.lnk"))
	_SetBoostDescription()
	_GetCoreProcessUsage()
	; _GetCoreProcessPeak()

EndFunc   ;==>_StartCoreGui


Func _CloseCoreGui()

	TrayItemSetState($g_hTrItemOpenCore, $TRAY_ENABLE)
	$g_iCoreGuiLoaded = False

	GUIDelete($g_hCoreGui)

	If $g_iShowNotifications == 1 Then
		TrayTip($g_aLangCustom[24], StringFormat($g_aLangCustom[25], $g_sBrowserName), 20,  $TIP_ICONASTERISK)
	EndIf

	_LoadConfiguration()
	_SetTrayItemStates()

	AdlibUnRegister("_OnIconsHover")
	; AdlibUnRegister("_GetCoreProcessPeak")

EndFunc


Func _SetTrayItemStates()

	TrayItemSetText($g_hTrItemBrsrRun, StringFormat($g_aLangMenus[14], $g_sBrowserName))
	TrayItemSetText($g_hTrItemBrsrRunSafe, StringFormat($g_aLangMenus[15], $g_sBrowserName))

	If _ReturnSafeModeCommand() == "" Then
		TrayItemSetState($g_hTrItemBrsrRunSafe, $TRAY_DISABLE)
	Else
		TrayItemSetState($g_hTrItemBrsrRunSafe, $TRAY_ENABLE)
	EndIf

EndFunc


#Region "Events"

Func _OnIconsHover()

	Local $iCursor = GUIGetCursorInfo()
	If Not @error Then

		If $iCursor[4] = $g_hGuiIcon And $g_aCoreIcons[2] == 1 Then
			$g_aCoreIcons[2] = 0
			GUICtrlSetImage($g_hGuiIcon, $g_aCoreIcons[1], 201)
		ElseIf $iCursor[4] <> $g_hGuiIcon And $g_aCoreIcons[2] == 0 Then
			$g_aCoreIcons[2] = 1
			GUICtrlSetImage($g_hGuiIcon, $g_aCoreIcons[0], 99)
		EndIf

	EndIf

EndFunc   ;==>_OnIconsHover

;~ Func _NoticeClick()
;~ 	ShellExecute(_Link_Split($g_sUrlNotice))
;~ EndFunc

#EndRegion "Events"


#Region "Resources"

Func _SetResources()

	If @Compiled Then

		$g_aCoreIcons[0] = @ScriptFullPath
		$g_aCoreIcons[1] = @ScriptFullPath

		For $iLi = 0 To $CNT_LOGICONS - 1
			$g_aLognIcons[$iLi] = @ScriptFullPath
		Next

		For $iMi = 0 To $CNT_MENUICONS - 1
			$g_aMenuIcons[$iMi] = @ScriptFullPath
		Next

		For $iNi = 0 To $CNT_LANGICONS - 1
			$g_aLanguageIcons[$iNi] = @ScriptFullPath
		Next

		$g_sDlgOptionsIcon = @ScriptFullPath

	Else

		$g_aCoreIcons[0] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\" & $g_sProgShortName & ".ico"
		$g_aCoreIcons[1] = $g_sThemesDir & "\Icons\" & $g_sProgShortName & "H.ico"

		$g_aLognIcons[0] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\logging\Information.ico"
		$g_aLognIcons[1] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\logging\Complete.ico"
		$g_aLognIcons[2] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\logging\Cross.ico"
		$g_aLognIcons[3] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\logging\Exclamation.ico"
		$g_aLognIcons[4] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\logging\Smiley-Glass.ico"
		$g_aLognIcons[5] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\logging\Skull.ico"
		$g_aLognIcons[6] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\logging\Snowman.ico"

		$g_aLanguageIcons[0]  = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\en.ico"
		$g_aLanguageIcons[1]  = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\af.ico"
		$g_aLanguageIcons[2]  = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\ar.ico"
		$g_aLanguageIcons[3]  = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\bg.ico"
		$g_aLanguageIcons[4]  = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\cs.ico"
		$g_aLanguageIcons[5]  = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\da.ico"
		$g_aLanguageIcons[6]  = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\de.ico"
		$g_aLanguageIcons[7]  = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\el.ico"
		$g_aLanguageIcons[8]  = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\es.ico"
		$g_aLanguageIcons[9]  = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\fr.ico"
		$g_aLanguageIcons[10] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\hi.ico"
		$g_aLanguageIcons[11] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\hr.ico"
		$g_aLanguageIcons[12] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\hu.ico"
		$g_aLanguageIcons[13] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\id.ico"
		$g_aLanguageIcons[14] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\ir.ico"
		$g_aLanguageIcons[15] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\is.ico"
		$g_aLanguageIcons[16] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\it.ico"
		$g_aLanguageIcons[17] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\iw.ico"
		$g_aLanguageIcons[18] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\ja.ico"
		$g_aLanguageIcons[19] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\ko.ico"
		$g_aLanguageIcons[20] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\nl.ico"
		$g_aLanguageIcons[21] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\no.ico"
		$g_aLanguageIcons[22] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\pl.ico"
		$g_aLanguageIcons[23] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\pt.ico"
		$g_aLanguageIcons[24] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\pt-BR.ico"
		$g_aLanguageIcons[25] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\ro.ico"
		$g_aLanguageIcons[26] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\ru.ico"
		$g_aLanguageIcons[27] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\sl.ico"
		$g_aLanguageIcons[28] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\sk.ico"
		$g_aLanguageIcons[29] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\sv.ico"
		$g_aLanguageIcons[30] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\th.ico"
		$g_aLanguageIcons[31] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\tr.ico"
		$g_aLanguageIcons[32] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\vi.ico"
		$g_aLanguageIcons[33] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\zh-CN.ico"
		$g_aLanguageIcons[34] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Flags\zh-TW.ico"

		$g_aMenuIcons[0] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Menus\Gear.ico"
		$g_aMenuIcons[1] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Menus\Logbook.ico"
		$g_aMenuIcons[2] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Menus\Close.ico"
		$g_aMenuIcons[3] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Menus\Update.ico"
		$g_aMenuIcons[4] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Menus\Home.ico"
		$g_aMenuIcons[5] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Menus\Support.ico"
		$g_aMenuIcons[6] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Menus\GitHub.ico"
		$g_aMenuIcons[7] = $g_sThemesDir & "..\..\..\SDK\Resources\Icons\Menus\About.ico"

		$g_sDlgOptionsIcon = $g_sThemesDir & "\..\..\..\SDK\ResourcesIcons\Dialogs\Gear.ico"

	EndIf

	$g_aCoreIcons[2] = 1

EndFunc   ;==>_SetResources

#EndRegion "Resources"


#Region "Working Directories"

Func _ResetWorkingDirectories()
	$g_sPathIni = $g_sWorkingDir & "\" & $g_sProgShortName & ".ini"
EndFunc   ;==>_ResetWorkingDirectories


Func _SetAppDataDirectory()

	DirCreate($g_sAppDataRoot)

	$g_sWorkingDir = $g_sAppDataRoot

	_ResetWorkingDirectories()
	_GenerateIniFile($g_sPathIni, 0)

EndFunc   ;==>_SetAppDataDirectory


Func _SetWorkingDirectories()

	If IniRead($g_sPathIni, $g_sProgShortName, "PortableEdition", 1) = 0 Then
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
    ; MsgBox(0, "", $iniPath)
	$iResult = IniWrite($iniPath, $g_sProgShortName, "PortableEdition", $bPortable)
	Return $iResult

EndFunc   ;==>_GenerateIniFile

#EndRegion "Working Directories"


#Region "Configuration (Settings)"

Func _LoadConfiguration()

	$g_iCheckForUpdates = Int(IniRead($g_sPathIni, $g_sProgShortName, "CheckForUpdates", 4))
	$g_iProcessPriority = Int(IniRead($g_sPathIni, $g_sProgShortName, "ProcessPriority", 3))
	$g_iSaveRealtime = Int(IniRead($g_sPathIni, $g_sProgShortName, "SaveRealtime", 0))
	$g_iReduceMemory = Int(IniRead($g_sPathIni, $g_sProgShortName, "ReduceMemory", 1))
	$g_iReduceEveryMill = Int(IniRead($g_sPathIni, $g_sProgShortName, "ReduceEveryMill", 300))
	$g_iMaxSysMemoryPerc = Int(IniRead($g_sPathIni, $g_sProgShortName, "MinSysMemoryPerc", 80))
	$g_sDonateName = IniRead($g_sPathIni, "Donate", "DonateName", "Unknown")
	$g_iDonateBuild = Number(IniRead($g_sPathIni, "Donate", "DonateBuild", 13))
	$g_sBrowserPath = IniRead($g_sPathIni, $g_sProgShortName, "BrowserPath", @ProgramFilesDir & "\Mozilla Firefox\firefox.exe")
	$g_iBoostEnabled = Int(IniRead($g_sPathIni, $g_sProgShortName, "BoostEnabled", 1))
	$g_iBoostMill = Int(IniRead($g_sPathIni, $g_sProgShortName, "Boost", 500))
	$g_iLimitEnabled = Int(IniRead($g_sPathIni, $g_sProgShortName, "LimitEnabled", 1))
	$g_iCleanLimit = Int(IniRead($g_sPathIni, $g_sProgShortName, "ReduceLimit", 10))
	$g_iStartBrowser = Int(IniRead($g_sPathIni, $g_sProgShortName, "StartBrowser", 0))
	$g_iExtProcsEnabled = Int(IniRead($g_sPathIni, $g_sProgShortName, "EnableExtendedProcs", 1))
	$g_iShowNotifications = Int(IniRead($g_sPathIni, $g_sProgShortName, "ShowNotifications", 1))
	$g_sExtendedProcs = IniRead($g_sPathIni, $g_sProgShortName, "ExtendedProcs", "plugin-container.exe")

	_LoadBrowser($g_sBrowserPath)

	If @Compiled Then
		ProcessSetPriority(@ScriptName, $g_iProcessPriority)
	EndIf

EndFunc   ;==>_LoadConfiguration


Func _SaveFireminConfig()

	If GUICtrlRead($g_hChkBrowserAutoStart) = $GUI_CHECKED Then
		$g_iStartBrowser = 1
	Else
		$g_iStartBrowser  = 0
	EndIf

	IniWrite($g_sPathIni, $g_sProgShortName, "BrowserPath", $g_sBrowserPath)
	IniWrite($g_sPathIni, $g_sProgShortName, "BoostEnabled", $g_iBoostEnabled)
	IniWrite($g_sPathIni, $g_sProgShortName, "Boost", $g_iBoostMill)
	IniWrite($g_sPathIni, $g_sProgShortName, "LimitEnabled", $g_iLimitEnabled)
	IniWrite($g_sPathIni, $g_sProgShortName, "ReduceLimit", $g_iCleanLimit)
	IniWrite($g_sPathIni, $g_sProgShortName, "StartBrowser", $g_iStartBrowser)
	IniWrite($g_sPathIni, $g_sProgShortName, "EnableExtendedProcs", $g_iExtProcsEnabled)

	If GUICtrlRead($g_hChkStartWindows) = $GUI_CHECKED Then
		FileDelete(@StartupDir & "\Firemin.lnk")
		FileCreateShortcut(@ScriptFullPath, @StartupDir & "\Firemin.lnk", @StartupDir)
	Else
		FileDelete(@StartupDir & "\Firemin.lnk")
	EndIf

	GUICtrlSetState($g_hBtnSave, $GUI_DISABLE)
	GUICtrlSetState($g_hLblUpdated, $GUI_SHOW)

EndFunc


Func _SetBoost()

	If GUICtrlRead($g_hChkReduceEnabled) = $GUI_CHECKED Then
		$g_iBoostEnabled = 1
	Else
		$g_iBoostEnabled = 0
		GUICtrlSetColor($g_hLblProcessUsage, 0x000000)
	EndIf

	$g_iBoostMill = Int(GUICtrlRead($g_hComboReduceMill))
	AdlibUnRegister("_ClearProcessesWorkingSet")
	AdlibRegister("_ClearProcessesWorkingSet", $g_iBoostMill)

	_SetBoostDescription()
	_EnableSaveSettings()
	_SetControlStates()

EndFunc


Func _SetCleanLimit()

	If GUICtrlRead($g_hChkCleanLimit) = $GUI_CHECKED Then
		$g_iLimitEnabled = 1
	Else
		$g_iLimitEnabled = 0
	EndIf

	$g_iCleanLimit = Int(GUICtrlRead($g_hComboCleanLimit))
	_SetBoostDescription()
	_EnableSaveSettings()
	_SetControlStates()

EndFunc


Func _SetBoostDescription()

	Local $iTime = 0
	Local $sTimeVar = $g_aLangCustom[18]

	If $g_iBoostMill < 1000 Then
		$sTimeVar = $g_aLangCustom[18]
		$iTime = $g_iBoostMill
	ElseIf __iBetween(1000, 60000, $g_iBoostMill) Then
		$sTimeVar = $g_aLangCustom[19]
		$iTime = Round($g_iBoostMill / 1000)
	ElseIf __iBetween(60000, 3600000, $g_iBoostMill) Then
		$sTimeVar = $g_aLangCustom[20]
		$iTime = Round($g_iBoostMill / 60000)
	ElseIf $g_iBoostMill >= 3600000 Then
		$sTimeVar = $g_aLangCustom[21]
		$iTime = Round($g_iBoostMill / 3600000)
	EndIf

	GUICtrlSetData($g_hLblTimeStatus, StringFormat($g_aLangCustom[22], $iTime, $sTimeVar, $g_iCleanLimit))

EndFunc


Func __iBetween($iLower, $iUpper, $iNumber)

	If $iNumber >=  $iLower And $iNumber < $iUpper Then
		Return True
	Else
		Return False
	EndIf

EndFunc


Func _SetExtendedProcsEnabled()

	If GUICtrlRead($g_hChkExtendedProcs) = $GUI_CHECKED Then
		$g_iExtProcsEnabled = 1
	Else
		$g_iExtProcsEnabled = 0
	EndIf
	_EnableSaveSettings()

EndFunc


Func _SetControlStates()

	If GUICtrlRead($g_hChkReduceEnabled) = $GUI_CHECKED Then

		GUICtrlSetState($g_hComboReduceMill, $GUI_ENABLE)
		GUICtrlSetState($g_hChkCleanLimit, $GUI_ENABLE)
		GUICtrlSetState($g_hChkExtendedProcs, $GUI_ENABLE)

		If GUICtrlRead($g_hChkCleanLimit) = $GUI_CHECKED Then
			GUICtrlSetState($g_hComboCleanLimit, $GUI_ENABLE)
		Else
			GUICtrlSetState($g_hComboCleanLimit, $GUI_DISABLE)
		EndIf

	Else

		GUICtrlSetState($g_hComboReduceMill, $GUI_DISABLE)
		GUICtrlSetState($g_hChkCleanLimit, $GUI_DISABLE)
		GUICtrlSetState($g_hChkExtendedProcs, $GUI_DISABLE)
		GUICtrlSetState($g_hComboCleanLimit, $GUI_DISABLE)

	EndIf

EndFunc


Func _EnableSaveSettings()
	GUICtrlSetState($g_hBtnSave, $GUI_ENABLE)
	GUICtrlSetState($g_hLblUpdated, $GUI_HIDE)
EndFunc

#EndRegion "Configuration (Settings)"


Func _CheckForUpdates()

	_SetUpdateAnimationState($GUI_SHOW)
	_SoftwareUpdateCheck(True)
	_SetUpdateAnimationState($GUI_HIDE)

EndFunc   ;==>_CheckForUpdates


Func _ReduceMemory()

	Local $aMemStats = MemGetStats()

	If $aMemStats[0] > $g_iMaxSysMemoryPerc And $g_iReduceMemory = 1 Then
		_WinAPI_EmptyWorkingSet()
	EndIf

EndFunc


Func _SetUpdateAnimationState($iState)

	If $iState = 16 Then

		If FileExists($g_sUpdateAnimation) Then
			GUICtrlSetState($g_AniUpdate, $GUI_SHOW)
			GUICtrlSetState($g_hGuiIcon, $GUI_HIDE)
		EndIf
		_SetProcessingStates($GUI_DISABLE)
		GUICtrlSetData($g_hSubHeading, $g_aLangCustom[1])

	ElseIf $iState = 32 Then

		If FileExists($g_sUpdateAnimation) Then
			GUICtrlSetState($g_AniUpdate, $GUI_HIDE)
			GUICtrlSetState($g_hGuiIcon, $GUI_SHOW)
		EndIf
		_SetProcessingStates($GUI_ENABLE)
		GUICtrlSetData($g_hSubHeading, $g_aLangCustom[0])

	EndIf

EndFunc   ;==>_SetUpdateAnimationState


Func _SetProcessingStates($iState)

	GUICtrlSetState($g_hMenuFile, $iState)
	GUICtrlSetState($g_hMenuHelp, $iState)

EndFunc   ;==>_SetProcessingStates


Func _ShutdownProgram()

	AdlibUnRegister("_OnIconsHover")
	AdlibUnRegister("_ClearProcessesWorkingSet")
	If @Compiled Then
		AdlibUnRegister("_ReduceMemory")
	EndIf

	If StringCompare($g_sDonateName, @ComputerName, $STR_NOCASESENSEBASIC) <> 0 Or Number(_GetProgramVersion(4)) <> $g_iDonateBuild Then

		IniWrite($g_sPathIni, "Donate", "DonateName", @ComputerName)
		IniWrite($g_sPathIni, "Donate", "DonateBuild", _GetProgramVersion(4))
		_Donate_ShowDialog()

	Else
		WinSetTrans($g_hCoreGui, Default, 255)
		TraySetState($TRAY_ICONSTATE_HIDE)
		Exit
	EndIf

EndFunc   ;==>_ShutdownProgram


Func _TerminateProgram()

	If $g_iSingleton Then
		Local $iPID = ProcessExists(@ScriptName)
		If $iPID Then ProcessClose($iPID)
	EndIf

EndFunc


Func _MinimizeProgram()

	Local $iState = WinGetState($g_hCoreGui)

	If BitAND($iState, 4) Then
		WinSetState($g_hCoreGui, "", @SW_MINIMIZE)
	EndIf

EndFunc


Func _FindBrowser()

	Local $sBrowserOpenDlg = FileOpenDialog($g_aLangCustom[23], _WinAPI_PathRemoveFileSpec($g_sBrowserPath), _
		"Browser (*.exe)", $FD_FILEMUSTEXIST)
	If Not @error Then
		If $sBrowserOpenDlg <> $g_sBrowserPath Then
			GUICtrlSetState($g_hBtnSave, $GUI_ENABLE)
		EndIf
        _LoadBrowser($sBrowserOpenDlg)
		; _ResetProcessUsage()
		_SetTrayItemStates()
    EndIf

EndFunc


Func _LoadBrowser($sBrowserPath)

	If FileExists($sBrowserPath) Then

		$g_sBrowserPath = $sBrowserPath
		$g_sCoreProcess = _WinAPI_PathStripPath($g_sBrowserPath)
		$g_sBrowserName = FileGetVersion($g_sBrowserPath, $FV_PRODUCTNAME)

		GUICtrlSetData($g_hLblPrflPathCaption, StringFormat($g_aLangCustom[3], $g_sCoreProcess))
		GUICtrlSetData($g_hLblPrflTitle, $g_sBrowserName & " " & FileGetVersion($g_sBrowserPath))
		GUICtrlSetData($g_hLblPrflPublisher, FileGetVersion($g_sBrowserPath, $FV_COMPANYNAME))
		GUICtrlSetData($g_hLblPrflPathExe, $g_sBrowserPath)

		_WinAPI_DestroyIcon(_SendMessage($g_hIconProfile, $STM_SETIMAGE, 1, _WinAPI_ShellExtractIcon($g_sBrowserPath, 0, 48, 48)))

	Else

		_WinAPI_DestroyIcon(_SendMessage($g_hIconProfile, $STM_SETIMAGE, 1, _WinAPI_ShellExtractIcon($g_aCoreIcons[0], 0, 48, 48)))
		$sBrowserPath = @ProgramFilesDir & "\Mozilla Firefox\firefox.exe"
		;IniWrite($g_ReBarPathIni, $g_ReBarShortName, "BrowserPath", $sBrowserPath)

	EndIf

EndFunc


Func _RunBrowser()
	__RunBrowser()
EndFunc


Func _RunBrowserSafe()
	__RunBrowser(_ReturnSafeModeCommand())
EndFunc


Func __RunBrowser($sParam = "")
	If FileExists($g_sBrowserPath) Then
		If Not ProcessExists($g_sCoreProcess) Then
			ShellExecute($g_sBrowserPath, $sParam, $g_sBrowserPath)
		EndIf
	EndIf
EndFunc


Func _ReturnSafeModeCommand()

	Local $sParameters = ""
	Local $sSafeMode = IniRead($g_sPathIni, "Safemode", $g_sCoreProcess, "")
	Return $sSafeMode

EndFunc


Func _GetCoreProcessUsage()

EndFunc


Func _ClearProcessesWorkingSet()

	Local $aProcessList
	Local $iCleanLimit = 0

	$aProcessList = ProcessList($g_sCoreProcess)
	$g_iProcessesCount = $aProcessList[0][0]

	If Not @error Then

		For $i = 1 To $g_iProcessesCount
			$g_iCoreProcessUsage += _GetProcessUsage($aProcessList[$i][1], 2)
			$g_iCoreProcessPeak +=_GetProcessUsage($aProcessList[$i][1], 1)
		Next

		$g_iCoreProcessUsage = Round($g_iCoreProcessUsage / 1024 / 1024, 2)
		$g_iCoreProcessPeak = Round($g_iCoreProcessPeak / 1024 / 1024, 2)

		If $g_iBoostEnabled Then
			If $g_iLimitEnabled Then
				$iCleanLimit = $g_iCleanLimit
			Else
				$iCleanLimit = 0
			EndIf

			If $g_iCoreProcessUsage > $iCleanLimit Then
				For $x = 1 To $g_iProcessesCount
					_WinAPI_EmptyWorkingSet($aProcessList[$x][1])
				Next
			EndIf
		EndIf

	EndIf

	_ClearExtendedProcs()

EndFunc


Func _GetProcessUsage($iProcess, $iFlag = 0)

	Local $iProcessUsage = 0
	Local $aProcessStats = _WinAPI_GetProcessMemoryInfo($iProcess)
	If Not @error Then
		If IsArray($aProcessStats) Then
			$iProcessUsage = $aProcessStats[$iFlag]
		Else
			Return SetError(2, 0, 0)
		EndIf
	Else
		Return SetError(1, 0, 0)
	EndIf

	Return $iProcessUsage

EndFunc


Func _ClearExtendedProcs()

	If $g_iExtProcsEnabled Then

		Local $iExtendedProcess = 0
		Local $sCleanProc = ""
		Local $aProcs = StringSplit($g_sExtendedProcs, ",")
		For $x = 1 To $aProcs[0]
			$sCleanProc = StringStripCR(StringStripWS($aProcs[$x], 3))
			$iExtendedProcess = ProcessExists($sCleanProc)
			_WinAPI_EmptyWorkingSet($iExtendedProcess)

			$g_iExtendedProcessUsage += _GetProcessUsage($iExtendedProcess, 2)
			$g_iExtendedProcessPeak +=_GetProcessUsage($iExtendedProcess, 1)

		Next

		UpdateStatLabels()

	EndIf

EndFunc


Func UpdateStatLabels()

	GUICtrlSetData($g_hLblProcessUsage, $g_iCoreProcessUsage & " MB / " & $g_iCoreProcessPeak & " MB")
	GUICtrlSetData($g_hLblProcessPeak, $g_iProcessesCount)
	GUICtrlSetColor($g_hLblProcessUsage, 0x000000)

	If $g_iBoostEnabled Then
		If $g_iLimitEnabled Then
			If $g_iCoreProcessUsage > $g_iCleanLimit Then
				GUICtrlSetColor($g_hLblProcessUsage, 0xFF0000)
			EndIf
		EndIf
	EndIf

	$g_iExtendedProcessUsage = Round($g_iExtendedProcessUsage / 1024 / 1024, 2)
	$g_iExtendedProcessPeak = Round($g_iExtendedProcessPeak / 1024 / 1024, 2)

	GUICtrlSetData($g_hLblExtendUsage, $g_iExtendedProcessUsage & " MB / " & $g_iExtendedProcessPeak & " MB")

	$g_iCoreProcessUsage = 0
	$g_iCoreProcessPeak	= 0
	$g_iExtendedProcessUsage = 0
	$g_iExtendedProcessPeak = 0

EndFunc


Func _ShowPreferencesDlg()

	_Localization_Preferences()	;~ Load Preferences Language Strings
	_LoadConfiguration()
	$g_sSelectedLanguage = IniRead($g_sPathIni, $g_sProgShortName, "Language", "en")
	Local $iLangCount = 1

	$g_iParentState = WinGetState($g_hCoreGui)
	If $g_iParentState > 0 Then
		$g_iParent = $g_hCoreGui
		WinSetTrans($g_hCoreGui, Default, 200)
		GUISetState(@SW_DISABLE, $g_hCoreGui)
	Else
		$g_iParent = 0
	EndIf

	TrayItemSetState($g_hTrItemExProcs, $TRAY_DISABLE)
	GUICtrlSetState($g_hBtnExtendedProcs, $GUI_DISABLE)

	$g_hOptionsGui = GUICreate($g_aLangPreferences[0], 450, 500, -1, -1, BitOR($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST, $g_iParent)
	GUISetFont(Default, Default, Default, "Verdana", $g_hOptionsGui, 5)
	If $g_iParentState > 0 Then GUISetIcon($g_sDlgOptionsIcon, $g_iDialogIconStart + 2, $g_hAboutGui)
	GUISetOnEvent($GUI_EVENT_CLOSE, "__CloseOptionsDlg", $g_hOptionsGui)
	GUIRegisterMsg($WM_NOTIFY, "__LanguageListEvents")

	GUICtrlCreateTab(10, 10, 430, 430)
	GUICtrlCreateTabItem(StringFormat(" %s ", $g_aLangPreferences[1]))
	GUICtrlCreateGroup($g_aLangPreferences[4], 25, 50, 400, 85)
	GUICtrlSetFont(-1, 10, 700, 2)
	$g_hOChkShowTrayTips = GUICtrlCreateCheckbox($g_aLangPreferences[9], 45, 80, 365, 20)
	GUICtrlSetState($g_hOChkShowTrayTips, $g_iShowNotifications)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
	GUICtrlCreateGroup($g_aLangPreferences[5], 25, 150, 400, 270)
	GUICtrlSetFont(-1, 10, 700, 2)
	GUICtrlCreateLabel($g_aLangPreferences[10], 45, 180, 365, 80)
	GUICtrlSetColor(-1, 0x555555)
	GUICtrlSetFont(-1, 9)
	$g_hOEditExtProcs = GUICtrlCreateEdit("", 45, 250, 365, 150, $WS_VSCROLL + $ES_AUTOVSCROLL)
	GUICtrlSetData($g_hOEditExtProcs, IniRead($g_sPathIni, $g_sProgShortName, "ExtendedProcs", "plugin-container.exe"))
	GUICtrlSetState($g_hOEditExtProcs, $GUI_NOFOCUS)
	GUICtrlSetFont($g_hOEditExtProcs, 9)
	Local $iSelLen = StringLen(GUICtrlRead($g_hOEditExtProcs))
	_GUICtrlEdit_SetSel($g_hOEditExtProcs, $iSelLen, $iSelLen)
	$g_hOEditExtProcsTemp = GUICtrlRead($g_hOEditExtProcs)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
	GUICtrlCreateTabItem("") ; end tabitem definition

	GUICtrlSetOnEvent($g_hOChkShowTrayTips, "__CheckPreferenceChange")

	GUICtrlCreateTabItem(StringFormat(" %s ", $g_aLangPreferences[2]))
	GUICtrlCreateGroup($g_aLangPreferences[6], 25, 50, 400, 130)
	GUICtrlSetFont(-1, 10, 700, 2)
	GUICtrlCreateLabel($g_aLangPreferences[11], 35, 80, 300, 20)
	GUICTrlSetColor(-1, 0x555555)
	$g_hOComboPower = GUICtrlCreateCombo("", 35, 105, 200, 30)
	GUICtrlSetData($g_hOComboPower, "Low|Below Normal|Normal|Above Normal|High|Realtime", "Normal")
	GUICtrlSetFont($g_hOComboPower, 10, 400)
	If @Compiled Then
		$g_hOIconPower = GUICtrlCreateIcon(@ScriptFullPath, $g_iPowerIconsStart, 350, 80, 48, 48)
	Else
		$g_hOIconPower = GUICtrlCreateIcon($g_sThemesDir & "\Icons\Power\Power-0.ico", 0, 350, 80, 48, 48)
	EndIf
	$g_hOChkSaveRealtime = GUICtrlCreateCheckbox($g_aLangPreferences[12], 35, 145, 360, 20)
	GUICtrlSetState($g_hOChkSaveRealtime, $g_iSaveRealtime)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	_SetProcessInfo()
	GUICtrlSetOnEvent($g_hOComboPower, "_SetProcessPriority")
	GUICtrlSetOnEvent($g_hOChkSaveRealtime, "__CheckPreferenceChange")

	GUICtrlCreateGroup($g_aLangPreferences[7], 25, 200, 400, 70)
	GUICtrlSetFont(-1, 10, 700, 2)
	$g_hOChkReduceMemory = GUICtrlCreateCheckbox($g_aLangPreferences[13], 35, 235, 360, 20)
	GUICtrlSetState($g_hOChkReduceMemory, $g_iReduceMemory)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	If Not @Compiled Then
		GUICtrlSetState($g_hOComboPower, $GUI_DISABLE)
		GUICtrlSetState($g_hOChkSaveRealtime, $GUI_DISABLE)
		GUICtrlSetState($g_hOChkReduceMemory, $GUI_DISABLE)
	EndIf

	GUICtrlSetOnEvent($g_hOChkReduceMemory, "__CheckPreferenceChange")
	GUICtrlCreateTabItem("") ; end tabitem definition

	GUICtrlCreateTabItem(StringFormat(" %s ", $g_aLangPreferences[3]))
	GUICtrlCreateGroup($g_aLangPreferences[8], 25, 50, 400, 350)
	GUICtrlSetFont(-1, 10, 700, 2)

	Local $aSelLangInfo = __ISO639CodeToIndex($g_sSelectedLanguage)
	$g_hOIconLanguage = GUICtrlCreateIcon(@ScriptFullPath, $g_iLangIconStart + $aSelLangInfo[1], 40, 90, 32, 32)
	$g_hOLblLanguage = GUICtrlCreateLabel($aSelLangInfo[0], 80, 98, 300)
	GUICtrlSetFont($g_hOLblLanguage, 11)

	$g_hOListLanguage = GUICtrlCreateListView("", 40, 135, 365, 200)
	_GUICtrlListView_SetExtendedListViewStyle($g_hOListLanguage, BitOR($LVS_EX_BORDERSELECT, _
			$LVS_EX_FLATSB, $LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, $LVS_EX_SUBITEMIMAGES, $LVS_EX_DOUBLEBUFFER, _
			$WS_EX_CLIENTEDGE, $LVS_EX_FLATSB, $LVS_EX_INFOTIP))

	$g_hOImgLanguage = _GUIImageList_Create(16, 16, 5, 3)
	For $l = 0 To $CNT_LANGICONS - 1
		_GUIImageList_AddIcon($g_hOImgLanguage, $g_aLanguageIcons[$l], 0 - $g_iLangIconStart - $l)
	Next
	_GUICtrlListView_SetImageList($g_hOListLanguage, $g_hOImgLanguage, 1)

	_GUICtrlListView_AddColumn($g_hOListLanguage, Chr(32) & "Language", 280)
	_GUICtrlListView_AddColumn($g_hOListLanguage, Chr(32) & "Code", 150)
	_WinAPI_SetWindowTheme(GUICtrlGetHandle($g_hOListLanguage), "Explorer")
	_GUICtrlListView_AddItem($g_hOListLanguage, Chr(32) & "English", 0)
	_GUICtrlListView_AddSubItem($g_hOListLanguage, 0, "en", 1)
	_GUICtrlListView_SetItemParam($g_hOListLanguage, 0, 3300)

	Local $hLangSearch = FileFindFirstFile($g_sLanguageDir & "\*.ini")
	While 1
		Local $sLangFileName = FileFindNextFile($hLangSearch)
		;~ If there is no more file matching the search.
		If @error Then ExitLoop
		If $sLangFileName = "en.ini" Then ContinueLoop

		Local $sLangIniPath = $g_sLanguageDir & "\" & $sLangFileName
		ConsoleWrite($sLangIniPath)

		Local $sLangName = IniRead($sLangIniPath, "Language", "Name", "")
		Local $sLangCode = IniRead($sLangIniPath, "Language", "Code", "")
		Local $sLangEncoding = IniRead($sLangIniPath, "Language", "Encoding", "")
		Local $aIndex = __ISO639CodeToIndex($sLangCode)
		Local $iLangIcon = $aIndex[1]

		_GUICtrlListView_AddItem($g_hOListLanguage, Chr(32) & $sLangName, $iLangIcon)
		_GUICtrlListView_AddSubItem($g_hOListLanguage, $iLangCount, $sLangCode, 1)
		_GUICtrlListView_SetItemParam($g_hOListLanguage, $iLangCount, 3300 + $iLangCount)
		$iLangCount += 1

	WEnd

	Local $iSelLangItem = __FindLanguageItem(3300 + $aSelLangInfo[1])
	_GUICtrlListView_SetItemSelected($g_hOListLanguage, $iSelLangItem, True, True)
	_GUICtrlListView_EnsureVisible($g_hOListLanguage, $iSelLangItem)
	GUICtrlCreateLabel(StringFormat($g_aLangPreferences[14], $g_aLangPreferences[15]), 40, 350, 365, 35)
	GUICtrlSetColor(-1, 0x555555)
	GUICtrlSetFont(-1, 9)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
	GUICtrlCreateTabItem("") ; end tabitem definition

	$g_hOLblPrefsUpdated = GUICtrlCreateLabel($g_aLangPreferences[17], 25, 455, 200, 20)
	GUICtrlSetColor($g_hOLblPrefsUpdated, 0x008000)
	GUICtrlSetState($g_hOLblPrefsUpdated, $GUI_HIDE)
	$g_hOBtnSave = GUICtrlCreateButton($g_aLangPreferences[15], 210, 450, 100, 30)
	GUICtrlSetFont($g_hOBtnSave, 10)
	GUICtrlSetState($g_hOBtnSave, $GUI_FOCUS)
	GUICtrlSetState($g_hOBtnSave, $GUI_DISABLE)
	GUICtrlSetOnEvent($g_hOBtnSave, "__SavePreferences")

	$g_hOBtnCancel = GUICtrlCreateButton($g_aLangPreferences[16], 320, 450, 100, 30)
	GUICtrlSetFont($g_hOBtnCancel, 10)
	GUICtrlSetOnEvent($g_hOBtnCancel, "__CloseOptionsDlg")

	GUISetState(@SW_SHOW, $g_hOptionsGui)
	AdlibUnRegister("__CheckExtendedProcsChange")
	AdlibRegister("__CheckExtendedProcsChange", 800)

EndFunc


Func _SetProcessPriority()

	Switch GuiCtrlRead($g_hOComboPower)
		Case "Low"
			$g_iProcessPriority = 0
		Case "Below Normal"
			$g_iProcessPriority = 1
		Case "Normal"
			$g_iProcessPriority = 2
		Case "Above Normal"
			$g_iProcessPriority = 3
		Case "High"
			$g_iProcessPriority = 4
		Case "Realtime"
			$g_iProcessPriority = 5
	EndSwitch

	ProcessSetPriority(@ScriptName, $g_iProcessPriority)
	_SetProcessInfo()

EndFunc


Func _SetProcessInfo($ProcessName = @ScriptName)

	Local $iPID = ProcessExists($ProcessName) ;~ Will return the PID or 0 if the process isn't found.
	Local $iProcessPriority = _ProcessGetPriority($iPID)
	Local $iTempPriority = Int(IniRead($g_sPathIni, $g_sProgShortName, "ProcessPriority", 2))

	For $p = 0 To 5
		If $p = $iProcessPriority Then
			GUICtrlSetImage($g_hOIconPower, @ScriptFullPath, $g_iPowerIconsStart + $p)
		EndIf
	Next

	Switch $iProcessPriority
		Case 0
			GuiCtrlSetData($g_hOComboPower, "Low")
		Case 1
			GuiCtrlSetData($g_hOComboPower, "Below Normal")
		Case 2
			GuiCtrlSetData($g_hOComboPower, "Normal")
		Case 3
			GuiCtrlSetData($g_hOComboPower, "Above Normal")
		Case 4
			GuiCtrlSetData($g_hOComboPower, "High")
		Case 5
			GuiCtrlSetData($g_hOComboPower, "Realtime")
		Case Else
			GuiCtrlSetData($g_hOComboPower, "Error")
	EndSwitch

	If $g_iProcessPriority = $iTempPriority Then
		GUICtrlSetState($g_hOBtnSave, $GUI_DISABLE)
	Else
		GUICtrlSetState($g_hOBtnSave, $GUI_ENABLE)
	EndIf

EndFunc


Func __CheckPreferenceChange()

	If __CheckBoxChanged("ShowNotifications", $g_hOChkShowTrayTips) = True Or _
		__CheckBoxChanged("SaveRealtime", $g_hOChkSaveRealtime) = True Or _
		__CheckBoxChanged("ReduceMemory", $g_hOChkReduceMemory) = True Then
		GUICtrlSetState($g_hOBtnSave, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hOBtnSave, $GUI_DISABLE)
	EndIf

	GUICtrlSetState($g_hOLblPrefsUpdated, $GUI_HIDE)

EndFunc


Func __CheckExtendedProcsChange()

	Local $sEPTemp = GUICtrlRead($g_hOEditExtProcs)

	If StringCompare($sEPTemp, $g_hOEditExtProcsTemp) <> 0 Then
		GUICtrlSetState($g_hOBtnSave, $GUI_ENABLE)
		$g_hOEditExtProcsTemp = $sEPTemp
	EndIf

EndFunc


Func __CheckBoxChanged($sPreference, $hCheckBox)

	Local $iTmp = IniRead($g_sPathIni, $g_sProgShortName, $sPreference, -1)
	If $iTmp > -1 Then
		If GUICtrlRead($hCheckBox) = $iTmp Or GUICtrlRead($hCheckBox) = ($iTmp + 4) Then
			Return False
		Else
			Return True
		EndIf
	Else
		Return True
	EndIf

EndFunc


Func __SavePreferences()

	Local $iLangChanged = False
	Local $sEPTemp = GUICtrlRead($g_hOEditExtProcs)
	Local $sEPSavedTemp = IniRead($g_sPathIni, $g_sProgShortName, "ExtendedProcs", "plugin-container.exe")

	If GUICtrlRead($g_hOChkShowTrayTips) = $GUI_CHECKED Then
		$g_iShowNotifications = 1
	ElseIf GUICtrlRead($g_hOChkShowTrayTips) = $GUI_UNCHECKED Then
		$g_iShowNotifications = 0
	EndIf

	IniWrite($g_sPathIni, $g_sProgShortName, "ShowNotifications", $g_iShowNotifications)

	If StringCompare($sEPTemp, $sEPSavedTemp) <> 0 Then
		IniWrite($g_sPathIni, $g_sProgShortName, "ExtendedProcs", GUICtrlRead($g_hOEditExtProcs))
	EndIf

	If $g_tSelectedLanguage <> $g_sSelectedLanguage Then
		Local $iMsgBoxResult = MsgBox($MB_OKCANCEL + $MB_ICONINFORMATION, $g_aLangPreferences[18], $g_aLangPreferences[19], 0, $g_hOptionsGui)
		Switch $iMsgBoxResult
			Case 1
				IniWrite($g_sPathIni, $g_sProgShortName, "Language", $g_tSelectedLanguage)
				GUICtrlSetData($g_hOLblPrefsUpdated, $g_aLangPreferences[17])
				GUICtrlSetState($g_hOLblPrefsUpdated, $GUI_SHOW)
				GUICtrlSetState($g_hOBtnSave, $GUI_DISABLE)
				$iLangChanged = True
			Case 2
				GUICtrlSetState($g_hOBtnSave, $GUI_ENABLE)
				Return 0
		EndSwitch
	EndIf

	If GUICtrlRead($g_hOChkSaveRealtime) = $GUI_CHECKED Then
		$g_iSaveRealtime = 1
	ElseIf GUICtrlRead($g_hOChkSaveRealtime) = $GUI_UNCHECKED Then
		$g_iSaveRealtime = 0
	EndIf

	If GUICtrlRead($g_hOChkReduceMemory) = $GUI_CHECKED Then
		$g_iReduceMemory = 1
	ElseIf GUICtrlRead($g_hOChkReduceMemory) = $GUI_UNCHECKED Then
		$g_iReduceMemory = 0
	EndIf

	If $g_iSaveRealtime = 0 And $g_iProcessPriority = 5 Then
		IniWrite($g_sPathIni, $g_sProgShortName, "ProcessPriority", 4)
	Else
		IniWrite($g_sPathIni, $g_sProgShortName, "ProcessPriority", $g_iProcessPriority)
	EndIf

	IniWrite($g_sPathIni, $g_sProgShortName, "SaveRealtime", $g_iSaveRealtime)
	IniWrite($g_sPathIni, $g_sProgShortName, "ReduceMemory", $g_iReduceMemory)

	If $iLangChanged = True Then
		$iMsgBoxResult = MsgBox($MB_OKCANCEL + $MB_ICONINFORMATION, $g_aLangPreferences[20], $g_aLangPreferences[21], 0, $g_hOptionsGui)
		Switch $iMsgBoxResult
			Case 1
				_ShutdownProgram()
			Case 2
				$iLangChanged = False
		EndSwitch
	Else
		GUICtrlSetData($g_hOLblPrefsUpdated, $g_aLangPreferences[17])
		GUICtrlSetState($g_hOLblPrefsUpdated, $GUI_SHOW)
		GUICtrlSetState($g_hOBtnSave, $GUI_DISABLE)
	EndIf

EndFunc


Func __CancelPreferences()
EndFunc


Func __FindLanguageItem($pItem)

	Local $tInfo, $iSelLangItem
	$tInfo = DllStructCreate($tagLVFINDINFO)
    DllStructSetData($tInfo, "Flags", $LVFI_PARAM)
    DllStructSetData($tInfo, "Param", $pItem)
    $iSelLangItem = _GUICtrlListView_FindItem($g_hOListLanguage, -1, $tInfo)
	Return $iSelLangItem

EndFunc


Func __CloseOptionsDlg()

	TrayItemSetState($g_hTrItemExProcs, $TRAY_ENABLE)
	GUICtrlSetState($g_hBtnExtendedProcs, $GUI_ENABLE)

	If $g_iParentState > 0 Then
		WinSetTrans($g_hCoreGui, Default, 255)
		GUISetState(@SW_ENABLE, $g_hCoreGui)
	EndIf
	AdlibUnRegister("__CheckExtendedProcsChange")
	GUIDelete($g_hOptionsGui)

EndFunc


Func __ISO639CodeToIndex($i639 = "en")

	Local $aLangInfo[3]

	Switch $i639
		Case "en"
			$aLangInfo[0] = "English"
			$aLangInfo[1] = 0 ; en.ico
		Case "af"
			$aLangInfo[0] = "Afrikaans"
			$aLangInfo[1] = 1 ; af.ico
		Case "ar"
			$aLangInfo[0] = "Arabic"
			$aLangInfo[1] = 2 ; ar.ico
		Case "bg"
			$aLangInfo[0] = "Bulgarian"
			$aLangInfo[1] = 3 ; bg.ico
		Case "cs"
			$aLangInfo[0] = "Czech"
			$aLangInfo[1] = 4 ; cs.ico
		Case "da"
			$aLangInfo[0] = "Danish"
			$aLangInfo[1] = 5 ; da.ico
		Case "de"
			$aLangInfo[0] = "German"
			$aLangInfo[1] = 6 ; de.ico
		Case "el"
			$aLangInfo[0] = "Greek"
			$aLangInfo[1] = 7 ; el.ico
		Case "es"
			$aLangInfo[0] = "Spanish"
			$aLangInfo[1] = 8 ; es.ico
		Case "fr"
			$aLangInfo[0] = "French"
			$aLangInfo[1] = 9 ; fr.ico
		Case "hi"
			$aLangInfo[0] = "Hindi"
			$aLangInfo[1] = 10 ; hi.ico
		Case "hr"
			$aLangInfo[0] = "Croatian"
			$aLangInfo[1] = 11 ; hr.ico
		Case "hu"
			$aLangInfo[0] = "Hungarian"
			$aLangInfo[1] = 12 ; hu.ico
		Case "id"
			$aLangInfo[0] = "Indonesian"
			$aLangInfo[1] = 13 ; id.ico
		Case "ir"
			$aLangInfo[0] = "Iran"
			$aLangInfo[1] = 14 ; ir.ico
		Case "is"
			$aLangInfo[0] = "Icelandic"
			$aLangInfo[1] = 15 ; is.ico
		Case "it"
			$aLangInfo[0] = "Italian"
			$aLangInfo[1] = 16 ; it.ico
		Case "iw"
			$aLangInfo[0] = "Hebrew"
			$aLangInfo[1] = 17 ; iw.ico
		Case "ja"
			$aLangInfo[0] = "Japanese"
			$aLangInfo[1] = 18 ; ja.ico
		Case "ko"
			$aLangInfo[0] = "Korean"
			$aLangInfo[1] = 19 ; ko.ico
		Case "nl"
			$aLangInfo[0] = "Dutch"
			$aLangInfo[1] = 20 ; nl.ico
		Case "no"
			$aLangInfo[0] = "Norwegian"
			$aLangInfo[1] = 21 ; no.ico
		Case "pl"
			$aLangInfo[0] = "Polish"
			$aLangInfo[1] = 22 ; pl.ico
		Case "pt"
			$aLangInfo[0] = "Portuguese"
			$aLangInfo[1] = 23 ; pt.ico
		Case "pt-BR"
			$aLangInfo[0] = "Portuguese (Brazil)"
			$aLangInfo[1] = 24 ; pt-BR.ico
		Case "ro"
			$aLangInfo[0] = "Romanian"
			$aLangInfo[1] = 25 ; ro.ico
		Case "ru"
			$aLangInfo[0] = "Russian"
			$aLangInfo[1] = 26 ; ru.ico
		Case "sl"
			$aLangInfo[0] = "Slovenian"
			$aLangInfo[1] = 27 ; sl.ico
		Case "sk"
			$aLangInfo[0] = "Slovak"
			$aLangInfo[1] = 28 ; sk.ico
		Case "sv"
			$aLangInfo[0] = "Swedish"
			$aLangInfo[1] = 29 ; sv.ico
		Case "th"
			$aLangInfo[0] = "Thai"
			$aLangInfo[1] = 30 ; th.ico
		Case "tr"
			$aLangInfo[0] = "Turkish"
			$aLangInfo[1] = 31 ; tr.ico
		Case "vi"
			$aLangInfo[0] = "Vietnamese"
			$aLangInfo[1] = 32 ; vi.ico
		Case "zh-CN"
			$aLangInfo[0] = "Simplified Chinese"
			$aLangInfo[1] = 33 ; zh-CN.ico
		Case "zh-TW"
			$aLangInfo[0] = "Traditional Chinese"
			$aLangInfo[1] = 34 ; zh-TW.ico
	EndSwitch

	Return $aLangInfo

EndFunc


Func __LanguageListEvents($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo, $iLi
	; Local $tBuffer
	$hWndListView = $g_hOListLanguage
	If Not IsHWnd($g_hOListLanguage) Then $hWndListView = GUICtrlGetHandle($g_hOListLanguage)

	$tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hWndListView
			Switch $iCode
				Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
					Local $iSelLang = DllStructGetData($tInfo, "Index")
					$g_tSelectedLanguage = _GUICtrlListView_GetItemText($g_hOListLanguage, $iSelLang, 1)
					Local $aSelLangInfo = __ISO639CodeToIndex($g_tSelectedLanguage)
					GUICtrlSetImage($g_hOIconLanguage, @ScriptFullPath, $g_iLangIconStart + $aSelLangInfo[1])
					GUICtrlSetData($g_hOLblLanguage, $aSelLangInfo[0])

					If $g_tSelectedLanguage <> $g_sSelectedLanguage Then
						GUICtrlSetState($g_hOBtnSave, $GUI_ENABLE)
					Else
						GUICtrlSetState($g_hOBtnSave, $GUI_DISABLE)
					EndIf

;~ 					$g_SelectedSolution = DllStructGetData($tInfo, "Index")
;~ 					If _DetectSolutionIndexChange($g_SelSolutionTemp) Then
;~ 						$g_SelSolutionTemp = $g_SelectedSolution
;~ 						If $g_SelectedSolution = -1 Then
;~ 							_SetAllOptionStates($GUI_DISABLE)
;~ 							_SetAllOptionsChecked($GUI_UNCHECKED)
;~ 						Else
;~ 							_SetModules($g_SelectedSolution)
;~ 						EndIf
;~ 					EndIf

				Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
;~ 					;~ $g_SelectedSolution = DllStructGetData($tInfo, "Index")

				Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
;~ 					;~ $g_SelectedSolution = DllStructGetData($tInfo, "Index")

			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY
