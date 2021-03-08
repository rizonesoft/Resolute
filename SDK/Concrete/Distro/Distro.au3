#NoTrayIcon
#OnAutoItStartRegister "_ReBarStartUp"

#Region AutoIt3Wrapper Directives Section

#AutoIt3Wrapper_ShowProgress=Y									;~ (Y/N) Show ProgressWindow during Compile. Default=Y
;===============================================================================================================
; AutoIt3 Settings
;===============================================================================================================
#AutoIt3Wrapper_UseX64=Y										;~ (Y/N) Use AutoIt3_x64 or Aut2Exe_x64. Default=N
#AutoIt3Wrapper_Version=P                        				;~ (B/P) Use Beta or Production for AutoIt3 and Aut2Eex. Default is P
#AutoIt3Wrapper_Run_Debug_Mode=N								;~ (Y/N) Run Script with console debugging. Default=N
;#AutoIt3Wrapper_Autoit3Dir=									;~ Optionally override the AutoIt3 install directory to use.
;#AutoIt3Wrapper_Aut2exe=										;~ Optionally override the Aut2exe.exe to use for this script
;#AutoIt3Wrapper_AutoIt3=										;~ Optionally override the Autoit3.exe to use for this script
;===============================================================================================================
; Aut2Exe Settings
;===============================================================================================================
#AutoIt3Wrapper_Icon=..\..\Resources\Icons\Distro.ico			;~ Filename of the Ico file to use for the compiled exe
#AutoIt3Wrapper_OutFile_Type=exe								;~ exe=Standalone executable (Default); a3x=Tokenised AutoIt3 code file
#AutoIt3Wrapper_OutFile=..\..\..\SDK\Distro.exe						;~ Target exe/a3x filename.
#AutoIt3Wrapper_OutFile_X64=..\..\..\SDK\Distro_X64.exe				;~ Target exe filename for X64 compile.
;#AutoIt3Wrapper_Compression=4									;~ Compression parameter 0-4  0=Low 2=normal 4=High. Default=2
;#AutoIt3Wrapper_UseUpx=Y										;~ (Y/N) Compress output program.  Default=Y
;#AutoIt3Wrapper_UPX_Parameters=								;~ Override the default settings for UPX.
#AutoIt3Wrapper_Change2CUI=N									;~ (Y/N) Change output program to CUI in stead of GUI. Default=N
#AutoIt3Wrapper_Compile_both=Y									;~ (Y/N) Compile both X86 and X64 in one run. Default=N
;===============================================================================================================
; Target Program Resource info
;===============================================================================================================
#AutoIt3Wrapper_Res_Comment=Distro Building Environment				;~ Comment field
#AutoIt3Wrapper_Res_Description=Distro Building Environment	      	;~ Description field
#AutoIt3Wrapper_Res_Fileversion=8.0.2.3617
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y  					;~ (Y/N/P) AutoIncrement FileVersion. Default=N
#AutoIt3Wrapper_Res_FileVersion_First_Increment=N					;~ (Y/N) AutoIncrement Y=Before; N=After compile. Default=N
#AutoIt3Wrapper_Res_HiDpi=N                      					;~ (Y/N) Compile for high DPI. Default=N
#AutoIt3Wrapper_Res_ProductVersion=8             					;~ Product Version
#AutoIt3Wrapper_Res_Language=2057									;~ Resource Language code . Default 2057=English (United Kingdom)
#AutoIt3Wrapper_Res_LegalCopyright=© 2021 Rizonesoft				;~ Copyright field
#AutoIt3Wrapper_res_requestedExecutionLevel=asInvoker				;~ asInvoker, highestAvailable, requireAdministrator or None (remove the trsutInfo section).  Default is the setting from Aut2Exe (asInvoker)
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
#AutoIt3Wrapper_Res_Field=ProductName|Distro Building Environment
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
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\\DistroH.ico					; 201

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\\logging\Information.ico		; 202
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Complete.ico			; 203
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Cross.ico			; 204
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Exclamation.ico		; 205
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Smiley-Glass.ico		; 206
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Skull.ico			; 207
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Snowman.ico			; 208

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Update.ico					; 209
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Error.ico					; 210

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Dialogs\Check.ico			; 211
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Dialogs\Error.ico			; 212
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Dialogs\Gear.ico				; 213
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Dialogs\Information.ico		; 214
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Dialogs\Love.ico				; 215

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\PayPal.ico				; 216
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\PayPalH.ico			; 217
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\sa.ico					; 218
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\saH.ico				; 219
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\Facebook.ico			; 220
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\FacebookH.ico			; 221
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\Twitter.ico			; 222
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\TwitterH.ico			; 223
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\LinkedIn.ico			; 224
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\LinkedInH.ico			; 225
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\GitHub.ico				; 226
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\GitHubH.ico			; 227

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\en.ico					; 228
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\af.ico					; 229
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ar.ico					; 230
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\bg.ico					; 231
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\cs.ico					; 232
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\da.ico					; 233
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\de.ico					; 234
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\el.ico					; 235
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\es.ico					; 236
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\fr.ico					; 237
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\hi.ico					; 238
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\hr.ico					; 239
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\hu.ico					; 240
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\id.ico					; 241
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ir.ico					; 242
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\is.ico					; 243
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\it.ico					; 244
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\iw.ico					; 245
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ja.ico					; 246
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ko.ico					; 247
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\nl.ico					; 248
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\no.ico					; 249
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\pl.ico					; 250
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\pt.ico					; 251
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\pt-BR.ico				; 252
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ro.ico					; 253
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ru.ico					; 254
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\sl.ico					; 255
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\sk.ico					; 256
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\sv.ico					; 257
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\th.ico					; 258
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\tr.ico					; 259
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\vi.ico					; 260
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\zh-CN.ico				; 261
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\zh-TW.ico				; 262

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-0.ico			; 263
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-1.ico			; 264
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-2.ico			; 265
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-3.ico			; 266
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-4.ico			; 267
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-5.ico			; 268

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Information1.ico	; 269
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Information2.ico	; 270
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Run1.ico			; 271
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Run2.ico			; 272
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Complete.ico		; 273
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Cross.ico			; 274
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Tick.ico			; 275
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Shortcut1.ico		; 276
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Shortcut2.ico		; 277
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Arrows1.ico			; 278
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Arrows2.ico			; 279

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Distro\Build-0.ico			; 280
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Distro\Build-1.ico			; 281
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Distro\Build-2.ico			; 282
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Distro\Build-3.ico			; 283
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Distro\Distribute-0.ico		; 284
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Distro\Distribute-1.ico		; 285
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Distro\Distribute-2.ico		; 286
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Distro\Distribute-3.ico		; 287
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Distro\Distribute-4.ico		; 288
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Distro\Distribute-5.ico		; 289

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Gear.ico				; 290
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Logbook.ico			; 291
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Close.ico				; 292
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Update.ico				; 293
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Home.ico				; 294
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Support.ico			; 295
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\GitHub.ico				; 296
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\About.ico				; 397
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Solution.ico			; 398


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
Opt("GUICloseOnESC", 0)				;~ 1=ESC  closes, 0=ESC won't close
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
Opt("TrayAutoPause", 1)				;~ 0=no pause, 1=Pause
Opt("TrayIconDebug", 1)				;~ 0=no info, 1=debug line info
Opt("TrayIconHide", 1)				;~ 0=show, 1=hide tray icon
Opt("TrayMenuMode", 1)				;~ 0=append, 1=no default menu, 2=no automatic check, 4=menuitemID  not return
Opt("TrayOnEventMode", 1)			;~ 0=disable, 1=enable
Opt("WinDetectHiddenText", 0)		;~ 0=don't detect, 1=do detect
Opt("WinSearchChildren", 1)			;~ 0=no, 1=search children also
Opt("WinTextMatchMode", 1)			;~ 1=complete, 2=quick
Opt("WinTitleMatchMode", 4)			;~ 1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
Opt("WinWaitDelay", 250)			;~ 250 milliseconds


Func _ReBarStartUp()
EndFunc   ;==>_ReBarStartUp


#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>

#include <WinAPITheme.au3>

#include "..\..\Includes\About.au3"
#include "..\..\Includes\Donate.au3"
#include "..\..\Includes\FileEx.au3"
#include "..\..\Includes\GuiMenuEx.au3"
#include "..\..\Includes\ImageListEx.au3"
#include "..\..\Includes\Link.au3"
#include "..\..\Includes\Logging.au3"
#include "..\..\Includes\Messages.au3"
#include "..\..\Includes\ProcessEx.au3"
#include "..\..\Includes\Splash.au3"
#include "..\..\Includes\StringEx.au3"
#include "..\..\Includes\Update.au3"
#include "..\..\Includes\Versioning.au3"

#include "..\..\UDF\Localization.au3"


;~ Developer Constants
Global Const $DEBUG_UPDATE		= False

; Constants
Global Const $CNT_MENUICONS		= 9
Global Const $CNT_LOGICONS		= 7
Global Const $CNT_LANGICONS		= 35
Global Const $CNT_COMMICONS		= 24

Global Const $CNT_BUILD			= 4
Global Const $CNT_DISTRIBUTE	= 6
Global Const $CNT_PREREQUISITES = 5
Global Const $CNT_PREREQINFO	= 10

Global Const $SPACER_BUILDLINE	= 20
Global Const $SPACER_PREREQLINE = 22

; General Settings
Global $g_sCompanyName			= "Rizonesoft"
Global $g_sProgShortName		= "Distro"
Global $g_sProgShortName_X64	= $g_sProgShortName & "_X64"
Global $g_sProgName				= "Rizonesoft SDK"
Global $g_iSingleton			= True
Global $g_sUrlCompHomePage		= "https://www.rizonesoft.com|www.rizonesoft.com"												; https://www.rizonesoft.com
Global $g_sUrlSupport			= "https://www.rizonesoft.com|www.rizonesoft.com"												; https://www.rizonesoft.com
Global $g_sUrlDownloads			= "https://www.rizonesoft.com|www.rizonesoft.com"												; https://www.rizonesoft.com/downloads/
Global $g_sUrlFacebook			= "https://www.facebook.com/rizonesoft|Facebook.com/rizonesoft"									; https://www.facebook.com/rizonesoft
Global $g_sUrlTwitter			= "https://twitter.com/rizonesoft|Twitter.com/Rizonesoft"										; https://twitter.com/Rizonesoft
Global $g_sUrlLinkedIn	 		= "https://www.linkedin.com/in/rizonetech|LinkedIn.com/in/rizonetech" 							; https://www.linkedin.com/in/rizonetech
Global $g_sUrlRSS				= "https://www.rizonesoft.com/feed|www.rizonesoft.com/feed"										; https://www.rizonesoft.com/feed
Global $g_sUrlPayPal			= "https://www.paypal.me/rizonesoft|PayPal.me/rizonesoft"										; https://www.paypal.me/rizonesoft
Global $g_sUrlGitHub			= "https://github.com/rizonesoft/Resolute|GitHub.com/rizonesoft/Resolute"						; https://github.com/rizonesoft/Resolute
Global $g_sUrlGitHubIssues		= "https://github.com/rizonesoft/Resolute/issues|GitHub.com/rizonesoft/Resolute/issues"			; https://github.com/rizonesoft/Resolute/issues
Global $g_sUrlSA				= "https://en.wikipedia.org/wiki/South_Africa|Wikipedia.org/wiki/South_Africa"					; https://en.wikipedia.org/wiki/South_Africa
Global $g_sUrlProgPage			= "https://www.rizonesoft.com/downloads/resolute/|www.rizonesoft.com/downloads/resolute/"
Global $g_sUrlUpdate			= "https://www.rizonesoft.com/downloads/resolute/update/|www.rizonesoft.com/downloads/resolute/update/"

;~ Path Settings
Global $g_sRootDir
Global $g_sDistroRoot

If Not @Compiled Then
	$g_sRootDir			= _PathFull(@ScriptDir & "..\..\..\..\Resolute")
	$g_sDistroRoot		= _PathFull(@ScriptDir & "..\..\..\..\SDK")
Else
	$g_sRootDir			= _PathFull(@ScriptDir & "..\..\Resolute")
	$g_sDistroRoot		= @ScriptDir
EndIf

Global $g_sWorkingDir		= $g_sRootDir
Global $g_sPathIni			= $g_sWorkingDir & "\" & $g_sProgShortName & ".ini" ;~ Full Path to the Configuaration file
Global $g_sAppDataRoot		= @AppDataDir & "\" & $g_sCompanyName & "\" & $g_sProgShortName
Global $g_sResourcesDir		= _PathFull(@ScriptDir & "..\..\Resources")
Global $g_sProcessDir		= $g_sRootDir &	"\Processing"
Global $g_sProcessSim		= $g_sRootDir & "\Processing\16\Process.ani"
Global $g_sDocsDir			= $g_sRootDir & "\Documents\" & $g_sProgShortName ;~ Documentation Directory
Global $g_sDocHelpFile		= $g_sDocsDir & "\" & $g_sProgShortName & ".chm"
Global $g_sDocChanges		= $g_sDocsDir & "\Changes.txt"
Global $g_sDocLicense		= $g_sDocsDir & "\License.txt"
Global $g_sDocReadme		= $g_sDocsDir & "\Readme.txt"
Global $g_sConcreteRoot		= $g_sDistroRoot & "\Concrete"
Global $g_sCertificateRoot	= $g_sDistroRoot & "\Signing"
Global $g_sWebRoot			= $g_sDistroRoot & "\www"
Global $g_sUpdateRoot		= $g_sWebRoot & "\update"


;~ Logging Settings
Global $g_sLoggingRoot		= $g_sWorkingDir & "\Logging\" & $g_sProgShortName
Global $g_sLoggingPath		= $g_sLoggingRoot & "\" & $g_sProgShortName & ".log"
Global $g_GuiLogBoxHeight	= 150
Global $g_iLogIconStart		= -202
Global $g_iUpdateSubStatus	= True

;~ Working Directories needs to be set before language is loaded.
_SetWorkingDirectories()

;~ Language Settings
Global $g_sLanguageDir		= $g_sRootDir & "\Language\" & $g_sProgShortName
Global $g_sSelectedLanguage = IniRead($g_sPathIni, $g_sProgShortName, "Language", "en")
Global $g_tSelectedLanguage = $g_sSelectedLanguage
Global $g_sLanguageFile		= $g_sLanguageDir & "\" & $g_sSelectedLanguage & ".ini"

; Resources
Global $g_iUpdateIconStart				= 209
Global $g_iDialogIconStart				= 211
Global $g_iAboutIconStart				= 216
Global $g_iLangIconStart				= 228
Global $g_iPowerIconsStart				= 263
Global $g_iComIconStart					= 269
Global $g_iMenuIconsStart				= 290

Global $g_aCoreIcons[3]
Global $g_iSizeIcon						= 48
Global $g_aLognIcons[$CNT_LOGICONS]
Global $g_aLanguageIcons[$CNT_LANGICONS]
Global $g_aMenuIcons[$CNT_MENUICONS]
Global $g_aCommIcons[$CNT_COMMICONS]
Global $g_sSelectAllIcon
Global $g_sDlgOptionsIcon

;~ Splash Page Settings
Global $g_sSplashAniPath
Global $g_iSplashDelay

;~ Update Notification Settings
Global $g_sUpdateAnimation	= $g_sProcessDir & "\" & $g_iSizeIcon & "\Globe.ani"
Global $g_sProcessingAnimation  = $g_sProcessDir & "\" & $g_iSizeIcon & "\Stroke.ani"
If $DEBUG_UPDATE = True Then
	Global $g_sRemoteUpdateFile	= "https://www.rizonesoft.com/update/" & $g_sProgShortName & ".ruz"
Else
	Global $g_sRemoteUpdateFile	= "https://www.rizonesoft.com/update/" & $g_sProgShortName & ".ru"
EndIf
Global $g_iCheckForUpdates	= 4

;~ Donate Time
Global $g_iUptimeMonitor	= 0
Global $g_iDonateTime		= 0
Global $g_iDonateTimeSet	= 259200 ; 10800 = 3 Hours | 86400 = Day | 259200 = 3 Days (Default) | 432000 = 5 Days

;~ Title Settings
Global $g_TitleShowAdmin	= True	;~ Show whether program is running as Administrator
Global $g_TitleShowArch		= True	;~ Show program architecture
Global $g_TitleShowVersion	= True	;~ Show program version
Global $g_TitleShowBuild	= True	;~ Show program build
Global $g_TitleShowAutoIt	= True	;~ Show AutoIt version

;~ Interface Settings
Global $g_iCoreGuiWidth		= 790
Global $g_iCoreGuiHeight	= 585
Global $g_iMsgBoxTimeOut	= 60

;~ About Dialog
Global $g_sAboutCredits		= "Derick Payne (Rizonesoft), Brian J Christy (Beege), " & _
							"G Sandler (MrCreatoR), Holger Kotsch, KaFu, LarsJ, nickston, ProgAndy, Yashied"

Global $g_sProgramTitle = _GUIGetTitle($g_sProgName)	;~ Get Program Ttile, including version.
Global $g_hCoreGui										;~ Main GUI
Global $g_hGuiIcon										;~ Main Icon
Global $g_AniUpdate
Global $g_AniProcessing
Global $g_hMenuFile, $g_hCreateSlnMItem, $g_hMenuFileLog
Global $g_hMenuHelp, $g_hUpdateMenuItem
Global $g_hMenuDebug
Global $g_OldSystemParam								;~ Used when resizing the main GUI
Global $g_hSubHeading
Global $g_hListSolutions
Global $g_ImgSolutions
Global $g_BtnProcessAll
Global $g_hTabLogging

Global $g_aBuild[$CNT_DISTRIBUTE][2][8]
Global $g_aBuildHovering[$CNT_DISTRIBUTE][2][2]
Global $g_aBuildState[$CNT_DISTRIBUTE][2][3] ;~ $g_aBuildState[ Option ][ Column ][ Prerequisite State, Module State, Checked]
Global $g_aPrerequisites[$CNT_PREREQUISITES + 1][4][2]
Global $g_aPrereqHovering[$CNT_PREREQUISITES][2]
Global $g_aPrereqInfo[$CNT_PREREQUISITES][10]
Global $g_IcoRefresh, $g_IcoRefreshHovering

Global $g_SelectedSolution	= 0
Global $g_SelSolutionTemp	= 0
Global $g_SolutionsCount	= 0
Global $g_SoloProcess		= True

Global $g_aAutoIt3[$CNT_PREREQINFO]
Global $g_aAutoIt3Beta[$CNT_PREREQINFO]
Global $g_aScite4AutoIt[$CNT_PREREQINFO]
Global $g_aUPX[$CNT_PREREQINFO]
Global $g_aSigntool[$CNT_PREREQINFO]
Global $g_a7Zip[$CNT_PREREQINFO]
Global $g_aInnoSetup[$CNT_PREREQINFO]
Global $g_cTidy 			= ""
Global $g_cAut2Exe 			= ""
Global $g_cAutoItWrapper 	= ""
Global $g_cSignTool 		= ""

Global $g_iau2exeSimPos 	= 0
Global $g_iMagicNumber		= 25
Global $g_aEnvironment
Global $g_GuiCreateSln


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
			_TerminateProgram()
		Case -1, $IDNO
			_TerminateProgram()
	EndSwitch
Else

	If Not @AutoItX64 And @OSArch = "X64" Then

		Local $s64BitExePath = $g_sRootDir & "\" & $g_sProgShortName_X64 & ".exe"

		If FileExists($s64BitExePath) Then
			ShellExecute($s64BitExePath)
			_TerminateProgram()
		Else

			Local $iMsgBoxResult = MsgBox($MB_YESNO + $MB_ICONWARNING + $MB_TOPMOST, $g_aLangMessages[3], StringFormat($g_aLangMessages[6], _
					_Link_Split($g_sUrlDownloads, 2)), $g_iMsgBoxTimeOut)

			Switch $iMsgBoxResult
				Case $IDYES
					ShellExecute(_Link_Split($g_sUrlDownloads))
					_TerminateProgram()
				Case -1, $IDNO
					_TerminateProgram()
			EndSwitch

		EndIf

	Else

		$g_sSplashAniPath	= $g_sProcessDir & "\32\Stroke.ani"
		$g_iSplashDelay		= 100

		_Splash_Start($g_aLangMessages[7])
		_Splash_Update($g_aLangMessages[8], 2)
		_Localization_Solutions()		;~ Load Solutions Language Strings
		_Localization_Prerequisites()	;~ Load Prerequisites Language Strings
		_Localization_Messages2()		;~ Load Custom Message Language Strings
		_Localization_Menus()			;~ Load Menu Language Strings
		_Localization_Custom()			;~ Load Custom Language Strings
		_Localization_About()			;~ Load Language Strings
		_Splash_Update($g_aLangMessages[9], 4)
		_SetResources()
		_Splash_Update($g_aLangMessages[10], 6)
		_SetWorkingDirectories()
		_Splash_Update($g_aLangMessages[11], 8)
		_Logging_Initialize($g_sProgName)
		_Splash_Update($g_aLangMessages[12], 10)
		_LoadConfiguration()
		_Splash_Update($g_aLangMessages[13], 12)
		_SetHotKeys()
		_Splash_Update($g_aLangMessages[14], 14)
		_StartCoreGui()

	EndIf

EndIf


Func _SetHotKeys()
	HotKeySet("{ESC}", "_MinimizeProgram")
EndFunc


Func _StartCoreGui()

	Local $miFileOptions, $miLogOpenFile, $miLogOpenRoot, $miFileClose
	Local $miHelpHome, $miHelpDownloads, $miHelpContact, $miHelpGitHub, $miHelpDonate, $miHelpAbout
	Local $hHeading
	Local $aPrereqdevider[6]

	$g_hCoreGui = GUICreate($g_sProgramTitle, $g_iCoreGuiWidth, $g_iCoreGuiHeight, -1, 25, $WS_OVERLAPPEDWINDOW)
	If Not @Compiled Then GUISetIcon($g_aCoreIcons[0])
	GUISetFont(8.5, 400, -1, "Verdana", $g_hCoreGui, $CLEARTYPE_QUALITY)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ShutdownProgram", $g_hCoreGui)

	GUIRegisterMsg($WM_GETMINMAXINFO, "WM_GETMINMAXINFO")
	GUIRegisterMsg($WM_EXITSIZEMOVE, "WM_EXITSIZEMOVE")
	GUIRegisterMsg($WM_SYSCOMMAND, "WM_SYSCOMMAND")
	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

	$g_hMenuFile = GUICtrlCreateMenu($g_aLangMenus[0])
	$g_hMenuHelp = GUICtrlCreateMenu($g_aLangMenus[7])
	$g_hMenuDebug = GUICtrlCreateMenu($g_aLangMenus[16])

	_GuiCtrlMenuEx_SetMenuIconBkColor(0xF0F0F0)
	_GuiCtrlMenuEx_SetMenuIconBkGrdColor(0xFFFFFF)

	$g_hCreateSlnMItem = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[1], $g_hMenuFile, $g_aMenuIcons[7], $g_iMenuIconsStart + 8)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuFile)
	$miFileOptions = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[2], $g_hMenuFile, $g_aMenuIcons[8], $g_iMenuIconsStart)
	$g_hMenuFileLog = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[3], $g_hMenuFile)
	$miLogOpenFile = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[4], $g_hMenuFileLog, $g_aMenuIcons[5], $g_iMenuIconsStart + 1)
	$miLogOpenRoot = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[5], $g_hMenuFileLog)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuFile)
	$miFileClose = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[6], $g_hMenuFile, $g_aMenuIcons[6], $g_iMenuIconsStart + 2)

	$g_hUpdateMenuItem = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[8], $g_hMenuHelp, $g_aMenuIcons[0], $g_iMenuIconsStart + 3)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpHome = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[9], $g_hMenuHelp, $g_aMenuIcons[1], $g_iMenuIconsStart + 4)
	$miHelpDownloads = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[11], $g_hMenuHelp)
	$miHelpContact = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[12], $g_hMenuHelp, $g_aMenuIcons[2], $g_iMenuIconsStart + 5)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpGitHub = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[13], $g_hMenuHelp, $g_aMenuIcons[3], $g_iMenuIconsStart + 6)
	$miHelpDonate = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[14], $g_hMenuHelp)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpAbout = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[15], $g_hMenuHelp, $g_aMenuIcons[4], $g_iMenuIconsStart + 7)

	GUICtrlSetOnEvent($g_hCreateSlnMItem, "_CreateNewSolutionDlg")
	GUICtrlSetOnEvent($miLogOpenFile, "_Logging_OpenFile")
	GUICtrlSetOnEvent($miLogOpenRoot, "_Logging_OpenDirectory")
	GUICtrlSetOnEvent($miFileClose, "_ShutdownProgram")

	GUICtrlSetOnEvent($g_hUpdateMenuItem, "_CheckForUpdates")
	GUICtrlSetOnEvent($miHelpHome, "_About_HomePage")
	GUICtrlSetOnEvent($miHelpDownloads, "_About_Downloads")
	GUICtrlSetOnEvent($miHelpContact, "_About_Support")
	GUICtrlSetOnEvent($miHelpGitHub, "_About_GitHubIssues")
	GUICtrlSetOnEvent($miHelpDonate, "_About_PayPal")
	GUICtrlSetOnEvent($miHelpAbout, "_About_ShowDialog")

	$g_hGuiIcon = GUICtrlCreateIcon($g_aCoreIcons[0], 99, 10, 10, $g_iSizeIcon, $g_iSizeIcon)
	GUICtrlSetTip($g_hGuiIcon, $g_aLangAbout[1] & Chr(32) & _GetProgramVersion(0) & @CRLF & _
			$g_aLangAbout[2] & Chr(32) & @AutoItVersion & @CRLF & _
			$g_aLangAbout[3] & " © " & @YEAR & " " & $g_sCompanyName, _
			$g_aLangAbout[0], $TIP_INFOICON, $TIP_BALLOON)
	GUICtrlSetCursor($g_hGuiIcon, 0)
	GUICtrlSetOnEvent($g_hGuiIcon, "_About_ShowDialog")
	$g_AniUpdate = GUICtrlCreateIcon($g_sUpdateAnimation, 0, 10, 10, $g_iSizeIcon, $g_iSizeIcon)
	GUICtrlSetState($g_AniUpdate, $GUI_HIDE)
	$hHeading = GUICtrlCreateLabel($g_sProgName & " " & _GetProgramVersion(1), $g_iSizeIcon + 22, 15, 300, 35)
	GUICtrlSetFont($hHeading, 12)
	$g_hSubHeading = GUICtrlCreateLabel($g_aLangCustom[0], $g_iSizeIcon + 22, 38, 380, 35)
	GUICtrlSetFont($g_hSubHeading, 10)
	GUICtrlSetColor($g_hSubHeading, 0x353535)
	GUICtrlSetResizing($g_hSubHeading, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKTOP))

	$g_hListSolutions = GUICtrlCreateListView("", 10, 74, 450, 255)
	_GUICtrlListView_SetExtendedListViewStyle($g_hListSolutions, BitOR($LVS_EX_BORDERSELECT, _
			$LVS_EX_FLATSB, $LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, _
			$LVS_EX_SUBITEMIMAGES, $LVS_EX_DOUBLEBUFFER, _
			$WS_EX_CLIENTEDGE, $LVS_EX_FLATSB, $LVS_EX_INFOTIP))
	_GUICtrlListView_BeginUpdate($g_hListSolutions)
	_GUICtrlListView_AddColumn($g_hListSolutions, Chr(32) & $g_aLangSolutions[0], 500)
	_GUICtrlListView_AddColumn($g_hListSolutions, Chr(32) & $g_aLangSolutions[1], 600)
	_GUICtrlListView_EndUpdate($g_hListSolutions)
	_WinAPI_SetWindowTheme(GUICtrlGetHandle($g_hListSolutions), "Explorer")
	GUICtrlSetResizing($g_hListSolutions, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))

	$g_BtnProcessAll = GUICtrlCreateButton($g_aLangCustom[14], 270, 340, 190, 40)
	GUICtrlSetFont($g_BtnProcessAll, 11, 400)
	GUICtrlSetResizing($g_BtnProcessAll, BitOR($GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKSIZE))
	GUICtrlSetOnEvent($g_BtnProcessAll, "_RunSelectedOption")

	GUICtrlCreateGroup($g_aLangCustom[12], 470, 10, 300, 120)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlSetFont(-1, 10, 700, 2)

	For $iBr = 0 To $CNT_BUILD - 1

		$g_aBuild[$iBr][0][0] = GUICtrlCreateIcon($g_aCommIcons[$iBr + 11], $g_iComIconStart + 11 + $iBr, 480, 38 + ($iBr * $SPACER_BUILDLINE), 16, 16)
		$g_aBuild[$iBr][0][1] = GUICtrlCreateCheckbox(" Building...", 503, 38 + ($iBr * $SPACER_BUILDLINE), 215, 16)
		$g_aBuild[$iBr][0][2] = GUICtrlCreateIcon($g_aCommIcons[0], $g_iComIconStart, 718, 38 + ($iBr * $SPACER_BUILDLINE), 16, 16)
		GUICtrlSetCursor($g_aBuild[$iBr][0][2], 0)
		$g_aBuild[$iBr][0][3] = GUICtrlCreateIcon($g_aCommIcons[2], $g_iComIconStart + 2, 738, 38 + ($iBr * $SPACER_BUILDLINE), 16, 16)
		GUICtrlSetCursor($g_aBuild[$iBr][0][3], 0)
		$g_aBuild[$iBr][0][4] = 55 + ($iBr * $SPACER_BUILDLINE)
		$g_aBuild[$iBr][0][5] = GUICtrlCreateLabel("", 503, $g_aBuild[$iBr][0][4], 215, 1)
		GUICtrlSetBkColor($g_aBuild[$iBr][0][5], 0xD9D9D9)
		$g_aBuild[$iBr][0][6] = GUICtrlCreateLabel("", 503, $g_aBuild[$iBr][0][4], 10, 1)
		GUICtrlSetBkColor($g_aBuild[$iBr][0][6], 0x3399FF)
		GUICtrlSetState($g_aBuild[$iBr][0][6], $GUI_HIDE)

		For $iBltCtrl = 0 To UBound($g_aBuild, 3) - 1
			GUICtrlSetResizing($g_aBuild[$iBr][0][$iBltCtrl], BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
		Next
		GUICtrlSetOnEvent($g_aBuild[$iBr][0][3], "_RunSelectedOption")

	Next

	GUICtrlSetData($g_aBuild[0][0][1], Chr(32) & $g_aLangCustom[2])
	GUICtrlSetData($g_aBuild[1][0][1], Chr(32) & $g_aLangCustom[3])
	GUICtrlSetData($g_aBuild[2][0][1], Chr(32) & $g_aLangCustom[4])
	GUICtrlSetData($g_aBuild[3][0][1], Chr(32) & $g_aLangCustom[5])

	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	GUICtrlCreateGroup($g_aLangCustom[13], 470, 140, 300, 240)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKBOTTOM, $GUI_DOCKWIDTH))
	GUICtrlSetFont(-1, 10, 700, 2)

	For $iDr = 0 To $CNT_DISTRIBUTE - 1

		$g_aBuild[$iDr][1][0] = GUICtrlCreateIcon($g_aCommIcons[$iDr + 15], $g_iComIconStart + 15 + $iDr, 480, 168 + ($iDr * $SPACER_BUILDLINE), 16, 16)
		$g_aBuild[$iDr][1][1] = GUICtrlCreateCheckbox(" Distribution...", 503, 168 + ($iDr * $SPACER_BUILDLINE), 215, 16)
		$g_aBuild[$iDr][1][2] = GUICtrlCreateIcon($g_aCommIcons[0], $g_iComIconStart, 718, 168 + ($iDr * $SPACER_BUILDLINE), 16, 16)
		GUICtrlSetCursor($g_aBuild[$iDr][1][2], 0)
		$g_aBuild[$iDr][1][3] = GUICtrlCreateIcon($g_aCommIcons[2], $g_iComIconStart + 2, 738, 168 + ($iDr * $SPACER_BUILDLINE), 16, 16)
		GUICtrlSetCursor($g_aBuild[$iDr][1][3], 0)
		$g_aBuild[$iDr][1][4] = 185 + ($iDr * $SPACER_BUILDLINE)
		$g_aBuild[$iDr][1][5] = GUICtrlCreateLabel("", 503, $g_aBuild[$iDr][1][4], 215, 1)
		GUICtrlSetBkColor($g_aBuild[$iDr][1][5], 0xD9D9D9)
		$g_aBuild[$iDr][1][6] = GUICtrlCreateLabel("", 503, $g_aBuild[$iDr][1][4], 10, 1)
		GUICtrlSetBkColor($g_aBuild[$iDr][1][6], 0x3399FF)
		GUICtrlSetState($g_aBuild[$iDr][1][6], $GUI_HIDE)

		For $iDisCtrl = 0 To UBound($g_aBuild, 3) - 1
			GUICtrlSetResizing($g_aBuild[$iDr][1][$iDisCtrl], BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
		Next
		GUICtrlSetOnEvent($g_aBuild[$iDr][1][3], "_RunSelectedOption")

	Next

	GUICtrlSetData($g_aBuild[0][1][1], Chr(32) & $g_aLangCustom[6])
	GUICtrlSetData($g_aBuild[1][1][1], Chr(32) & $g_aLangCustom[7])
	GUICtrlSetData($g_aBuild[2][1][1], Chr(32) & $g_aLangCustom[8])
	GUICtrlSetData($g_aBuild[3][1][1], Chr(32) & $g_aLangCustom[9])
	GUICtrlSetData($g_aBuild[4][1][1], Chr(32) & $g_aLangCustom[10])
	GUICtrlSetData($g_aBuild[5][1][1], Chr(32) & $g_aLangCustom[11])

	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	GUICtrlCreateTab(10, 390, 760, 160)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKSIZE))
	GUICtrlCreateTabItem(Chr(32) & $g_aLangPrerequisites[0] & Chr(32))

	$aPrereqdevider[0] = GUICtrlCreateLabel("", 20, 425, 1, 111)
	$aPrereqdevider[1] = GUICtrlCreateLabel("", 325, 425, 1, 111)
	$aPrereqdevider[2] = GUICtrlCreateLabel("", 360, 425, 1, 111)

	For $iPc = 0 To 1
		For $iPl = 0 To $CNT_PREREQUISITES
			$g_aPrerequisites[$iPl][0][$iPc] = GUICtrlCreateLabel("", 20 + ($iPc * 355), 425 + ($iPl * $SPACER_PREREQLINE), 341, 1)
			GUICtrlSetBkColor($g_aPrerequisites[$iPl][0][$iPc], 0xD9D9D9)
			GUICtrlSetResizing($g_aPrerequisites[$iPl][0][$iPc], BitOR($GUI_DOCKLEFT, $GUI_DOCKBOTTOM, $GUI_DOCKSIZE))
		Next
		For $iPr = 0 To $CNT_PREREQUISITES - 1

			$g_aPrerequisites[$iPr][1][$iPc] = GUICtrlCreateIcon($g_aCommIcons[5], $g_iComIconStart + 5, 25 + ($iPc * 355), 428 + ($iPr * $SPACER_PREREQLINE), 16, 16)
			$g_aPrerequisites[$iPr][2][$iPc] = GUICtrlCreateLabel("Prerequisite", 50 + ($iPc * 355), 429 + ($iPr * $SPACER_PREREQLINE), 250, 16)
			$g_aPrerequisites[$iPr][3][$iPc] = GUICtrlCreateIcon($g_aCommIcons[7], $g_iComIconStart + 7, 335 + ($iPc * 355), 428 + ($iPr * $SPACER_PREREQLINE), 16, 16)

			For $iX = 1 To 3
				GUICtrlSetCursor($g_aPrerequisites[$iPr][$iX][$iPc], 0)
				GUICtrlSetResizing($g_aPrerequisites[$iPr][$iX][$iPc], BitOR($GUI_DOCKLEFT, $GUI_DOCKBOTTOM, $GUI_DOCKSIZE))
			Next

		Next
	Next

	$aPrereqdevider[3] = GUICtrlCreateLabel("", 375, 425, 1, 111)
	$aPrereqdevider[4] = GUICtrlCreateLabel("", 680, 425, 1, 111)
	$aPrereqdevider[5] = GUICtrlCreateLabel("", 715, 425, 1, 111)

	For $iPDr = 0 To UBound($aPrereqdevider) - 1
		GUICtrlSetBkColor($aPrereqdevider[$iPDr], 0xD9D9D9)
		GUICtrlSetResizing($aPrereqdevider[$iPDr], BitOR($GUI_DOCKLEFT, $GUI_DOCKBOTTOM, $GUI_DOCKSIZE))
	Next

	$g_IcoRefresh = GUICtrlCreateIcon($g_aCommIcons[9], $g_iComIconStart + 9, 743, 423, 16, 16)
	GUICtrlSetResizing($g_IcoRefresh, BitOR($GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKSIZE))
	GUICtrlSetCursor($g_IcoRefresh, 0)
	GUICtrlSetTip($g_IcoRefresh, $g_aLangPrerequisites[1], Chr(32) & $g_aLangPrerequisites[0], $TIP_INFOICON, $TIP_BALLOON)
	GUICtrlSetOnEvent($g_IcoRefresh, "_CheckPrerequisites")

	$g_hTabLogging = GUICtrlCreateTabItem(Chr(32) & $g_aLangCustom[15] & Chr(32))
	$g_ImgSolutions = _GUIImageList_Create(16, 16, 5, 3, 0, 250)
	_GUICtrlListView_SetImageList($g_hListSolutions, $g_ImgSolutions, 1)

	$g_hListStatus = GUICtrlCreateListView("", 20, 425, 720, 111, BitOR($LVS_REPORT, $LVS_NOCOLUMNHEADER))
	_GUICtrlListView_SetExtendedListViewStyle($g_hListStatus, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_DOUBLEBUFFER, _
			$LVS_EX_SUBITEMIMAGES, $LVS_EX_INFOTIP, $WS_EX_CLIENTEDGE))
	_GUICtrlListView_AddColumn($g_hListStatus, "", 680)
	_WinAPI_SetWindowTheme(GUICtrlGetHandle($g_hListStatus), "Explorer")
	GUICtrlSetResizing($g_hListStatus, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKHEIGHT))
	GUICtrlSetFont($g_hListStatus, 9, -1, -1, "Courier New")
	GUICtrlSetColor($g_hListStatus, 0x333333)

	GUICtrlCreateTabItem("") ; end tabitem definition

	$g_hImgStatus = _GUIImageList_Create(16, 16, 5, 1, 8, 8)
	For $iLx = 0 To $CNT_LOGICONS - 1
		_ImageListEx_AddBlankIcon($g_hImgStatus, $g_hListStatus, $g_aLognIcons[$iLx], $g_iLogIconStart - $iLx)
	Next
	_GUIImageList_Add($g_hImgStatus, _GUICtrlListView_CreateSolidBitMap($g_hListStatus, 0xFFFFFF, 16, 16))
	_GUICtrlListView_SetImageList($g_hListStatus, $g_hImgStatus, 1)

	_Splash_Update($g_aLangMessages2[0], 94)
	_PopulateSolutions()

	;~ States must be initialized after solutions are populated and before prerequisites are loaded.
	_Splash_Update($g_aLangMessages2[1], 96)
	_InitializeStates()

	_Splash_Update($g_aLangMessages2[2], 98)
	_CheckPrerequisites()

	_Splash_Update("", 100)
	GUISetState(@SW_SHOW, $g_hCoreGui)

	If $g_SelectedSolution = -1 Or $g_SelectedSolution > ($g_SolutionsCount - 1) Or $g_SolutionsCount <= 0 Then
		_SetAllOptionStates($GUI_DISABLE)
		_SetAllOptionsChecked($GUI_UNCHECKED)
	Else
		_GUICtrlListView_SetItemSelected($g_hListSolutions, Int($g_SelectedSolution))
		_SetModules($g_SelectedSolution)
	EndIf

	AdlibRegister("_OnIconsHover", 80)
	AdlibRegister("_UptimeMonitor", 1000)

	If $g_iCheckForUpdates == 4 Then
		_SoftwareUpdateCheck()
	EndIf

	While 1
		Sleep(30)
	WEnd

EndFunc   ;==>_StartCoreGui


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

		For $iBi = 0 To 1
			For $iBr = 0 To $CNT_BUILD - 1
				If $iCursor[4] = $g_aBuild[$iBr][0][2 + $iBi] And $g_aBuildHovering[$iBr][0][$iBi] = 1 And _
						$g_aBuildState[$iBr][0][0] <> $GUI_DISABLE And _
						$g_aBuildState[$iBr][0][1] <> $GUI_DISABLE Then

					$g_aBuildHovering[$iBr][0][$iBi] = 0
					GUICtrlSetImage($g_aBuild[$iBr][0][2 + $iBi], $g_aCommIcons[1 + ($iBi * 2)], $g_iComIconStart + 1 + ($iBi * 2))

				ElseIf $iCursor[4] <> $g_aBuild[$iBr][0][2 + $iBi] And $g_aBuildHovering[$iBr][0][$iBi] = 0 Then
					$g_aBuildHovering[$iBr][0][$iBi] = 1
					GUICtrlSetImage($g_aBuild[$iBr][0][2 + $iBi], $g_aCommIcons[0 + ($iBi * 2)], $g_iComIconStart + ($iBi * 2))
				EndIf
			Next
		Next

		For $iDi = 0 To 1
			For $iDr = 0 To UBound($g_aBuild, 1) - 1
				If $iCursor[4] = $g_aBuild[$iDr][1][2 + $iDi] And $g_aBuildHovering[$iDr][1][$iDi] = 1 And _
						$g_aBuildState[$iDr][1][0] <> $GUI_DISABLE And _
						$g_aBuildState[$iDr][1][1] <> $GUI_DISABLE Then

					$g_aBuildHovering[$iDr][1][$iDi] = 0
					GUICtrlSetImage($g_aBuild[$iDr][1][2 + $iDi], $g_aCommIcons[1 + ($iDi * 2)], $g_iComIconStart + 1 + ($iDi * 2))

				ElseIf $iCursor[4] <> $g_aBuild[$iDr][1][2 + $iDi] And $g_aBuildHovering[$iDr][1][$iDi] = 0 Then
					$g_aBuildHovering[$iDr][1][$iDi] = 1
					GUICtrlSetImage($g_aBuild[$iDr][1][2 + $iDi], $g_aCommIcons[0 + ($iDi * 2)], $g_iComIconStart + ($iDi * 2))
				EndIf
			Next
		Next

		;~ 3 - Shortcut Icon
		For $iPc = 0 To 1
			For $iPr = 0 To $CNT_PREREQUISITES - 1

				If $iCursor[4] = $g_aPrerequisites[$iPr][3][$iPc] And $g_aPrereqHovering[$iPr][$iPc] = 1 Then
					$g_aPrereqHovering[$iPr][$iPc] = 0
					GUICtrlSetImage($g_aPrerequisites[$iPr][3][$iPc], $g_aCommIcons[8], $g_iComIconStart + 8)
				ElseIf $iCursor[4] <> $g_aPrerequisites[$iPr][3][$iPc] And $g_aPrereqHovering[$iPr][$iPc] = 0 Then
					$g_aPrereqHovering[$iPr][$iPc] = 1
					GUICtrlSetImage($g_aPrerequisites[$iPr][3][$iPc], $g_aCommIcons[7], $g_iComIconStart + 7)
				EndIf

			Next
		Next

		If $iCursor[4] = $g_IcoRefresh And $g_IcoRefreshHovering = 1 Then
			$g_IcoRefreshHovering = 0
			GUICtrlSetImage($g_IcoRefresh, $g_aCommIcons[10], $g_iComIconStart + 10)
		ElseIf $iCursor[4] <> $g_IcoRefresh And $g_IcoRefreshHovering = 0 Then
			$g_IcoRefreshHovering = 1
			GUICtrlSetImage($g_IcoRefresh, $g_aCommIcons[9], $g_iComIconStart + 9)
		EndIf

	EndIf

EndFunc   ;==>_OnIconsHover


;~ https://www.autoitscript.com/forum/topic/99603-resize-but-dont-get-smaller-than-original-size/#comment-714621
Func WM_GETMINMAXINFO($hWnd, $msg, $wParam, $lParam)
	Local $tagMaxinfo = DllStructCreate("int;int;int;int;int;int;int;int;int;int", $lParam)
	DllStructSetData($tagMaxinfo, 7, $g_iCoreGuiWidth) ; min X
	DllStructSetData($tagMaxinfo, 8, $g_iCoreGuiHeight) ; min Y
	Return 0
EndFunc   ;==>WM_GETMINMAXINFO


Func WM_SYSCOMMAND($hWnd, $msg, $wParam, $lParam)
	Switch BitAND($wParam, 0xFFF0)
		Case 0xF010, 0xF000
			Local $tBool = DllStructCreate("int")
			DllCall("user32.dll", "int", "SystemParametersInfo", "int", 38, "int", 0, "ptr", DllStructGetPtr($tBool), "int", 0)
			$g_OldSystemParam = DllStructGetData($tBool, 1)
			DllCall("user32.dll", "int", "SystemParametersInfo", "int", 37, "int", 0, "ptr", 0, "int", 2)
	EndSwitch
EndFunc   ;==>WM_SYSCOMMAND


Func WM_EXITSIZEMOVE($hWnd, $msg, $wParam, $lParam)
	DllCall("user32.dll", "int", "SystemParametersInfo", "int", 37, "int", $g_OldSystemParam, "ptr", 0, "int", 2)
EndFunc   ;==>WM_EXITSIZEMOVE

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo, $iLi
	; Local $tBuffer
	$hWndListView = $g_hListSolutions
	If Not IsHWnd($g_hListSolutions) Then $hWndListView = GUICtrlGetHandle($g_hListSolutions)

	$tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hWndListView
			Switch $iCode
				Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
					$g_SelectedSolution = DllStructGetData($tInfo, "Index")
					If _DetectSolutionIndexChange($g_SelSolutionTemp) Then
						$g_SelSolutionTemp = $g_SelectedSolution
						If $g_SelectedSolution = -1 Then
							_SetAllOptionStates($GUI_DISABLE)
							_SetAllOptionsChecked($GUI_UNCHECKED)
						Else
							_SetModules($g_SelectedSolution)
						EndIf

					EndIf

				Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
					;~ $g_SelectedSolution = DllStructGetData($tInfo, "Index")

				Case $NM_RCLICK ; Sent by a list-view control when the user clicks an item with the right mouse button
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
					;~ $g_SelectedSolution = DllStructGetData($tInfo, "Index")

			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

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

		For $iCi = 0 To $CNT_COMMICONS - 1
			$g_aCommIcons[$iCi] = @ScriptFullPath
		Next

	Else

		$g_aCoreIcons[0]  = $g_sThemesDir & "\Icons\" & $g_sProgShortName & ".ico"
		$g_aCoreIcons[1]  = $g_sThemesDir & "\Icons\" & $g_sProgShortName & "H.ico"

		$g_aLognIcons[0]  = $g_sThemesDir & "\Icons\logging\Information.ico"
		$g_aLognIcons[1]  = $g_sThemesDir & "\Icons\logging\Complete.ico"
		$g_aLognIcons[2]  = $g_sThemesDir & "\Icons\logging\Cross.ico"
		$g_aLognIcons[3]  = $g_sThemesDir & "\Icons\logging\Exclamation.ico"
		$g_aLognIcons[4]  = $g_sThemesDir & "\Icons\logging\Smiley-Glass.ico"
		$g_aLognIcons[5]  = $g_sThemesDir & "\Icons\logging\Skull.ico"
		$g_aLognIcons[6]  = $g_sThemesDir & "\Icons\logging\Snowman.ico"

		$g_aMenuIcons[0]  = $g_sThemesDir & "\Icons\Menus\Update.ico"
		$g_aMenuIcons[1]  = $g_sThemesDir & "\Icons\Menus\Home.ico"
		$g_aMenuIcons[2]  = $g_sThemesDir & "\Icons\Menus\Mail.ico"
		$g_aMenuIcons[3]  = $g_sThemesDir & "\Icons\Menus\GitHub.ico"
		$g_aMenuIcons[4]  = $g_sThemesDir & "\Icons\Menus\About.ico"
		$g_aMenuIcons[5]  = $g_sThemesDir & "\Icons\Menus\Logbook.ico"
		$g_aMenuIcons[6]  = $g_sThemesDir & "\Icons\Menus\Close.ico"
		$g_aMenuIcons[7]  = $g_sThemesDir & "\Icons\Menus\Solution.ico"
		$g_aMenuIcons[8] = $g_sThemesDir & "\Icons\Dialogs\Gear.ico"

		$g_aCommIcons[0]  = $g_sThemesDir & "\Icons\Commands\Information-D.ico"
		$g_aCommIcons[1]  = $g_sThemesDir & "\Icons\Commands\Information.ico"
		$g_aCommIcons[2]  = $g_sThemesDir & "\Icons\Commands\Run-D.ico"
		$g_aCommIcons[3]  = $g_sThemesDir & "\Icons\Commands\Run.ico"
		$g_aCommIcons[4]  = $g_sThemesDir & "\Icons\Commands\Complete.ico"
		$g_aCommIcons[5]  = $g_sThemesDir & "\Icons\Commands\Cross.ico"
		$g_aCommIcons[6]  = $g_sThemesDir & "\Icons\Commands\Tick.ico"
		$g_aCommIcons[7]  = $g_sThemesDir & "\Icons\Commands\Shortcut-D.ico"
		$g_aCommIcons[8]  = $g_sThemesDir & "\Icons\Commands\Shortcut.ico"
		$g_aCommIcons[9]  = $g_sThemesDir & "\Icons\Commands\Arrows-D.ico"
		$g_aCommIcons[10] = $g_sThemesDir & "\Icons\Commands\Arrows.ico"
		$g_aCommIcons[11] = $g_sThemesDir & "\Icons\Commands\Build-0.ico"
		$g_aCommIcons[12] = $g_sThemesDir & "\Icons\Commands\Build-1.ico"
		$g_aCommIcons[13] = $g_sThemesDir & "\Icons\Commands\Build-2.ico"
		$g_aCommIcons[14] = $g_sThemesDir & "\Icons\Commands\Build-3.ico"
		$g_aCommIcons[15] = $g_sThemesDir & "\Icons\Commands\Distribute-0.ico"
		$g_aCommIcons[16] = $g_sThemesDir & "\Icons\Commands\Distribute-1.ico"
		$g_aCommIcons[17] = $g_sThemesDir & "\Icons\Commands\Distribute-2.ico"
		$g_aCommIcons[18] = $g_sThemesDir & "\Icons\Commands\Distribute-3.ico"
		$g_aCommIcons[19] = $g_sThemesDir & "\Icons\Commands\Distribute-4.ico"
		$g_aCommIcons[20] = $g_sThemesDir & "\Icons\Commands\Distribute-5.ico"

	EndIf

	$g_aCoreIcons[2] = 1
	$g_IcoRefreshHovering = 1

EndFunc   ;==>_SetResources

#EndRegion "Resources"


#Region "Working Directories"

Func _ResetWorkingDirectories()

	$g_sPathIni = $g_sWorkingDir & "\" & $g_sProgShortName & ".ini"
	$g_sLoggingRoot = $g_sWorkingDir & "\Logging\" & $g_sProgShortName
	$g_sLoggingPath = $g_sLoggingRoot & "\" & $g_sProgShortName & ".log"

	DirCreate($g_sConcreteRoot)

EndFunc   ;==>_ResetWorkingDirectories


Func _SetAppDataDirectory()

	DirCreate($g_sAppDataRoot)

	$g_sConcreteRoot = $g_sAppDataRoot & "\Concrete"
	DirCreate($g_sConcreteRoot)
	MsgBox($MB_ICONERROR, $g_aLangMessages[2], StringFormat($g_aLangMessages2[3], $g_sConcreteRoot))

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

	$iResult = IniWrite($iniPath, $g_sProgShortName, "PortableEdition", $bPortable)
	Return $iResult
EndFunc   ;==>_GenerateIniFile

#EndRegion "Working Directories"


#Region "Configuration (Settings)"

Func _LoadConfiguration()

	$g_iCheckForUpdates = Int(IniRead($g_sPathIni, $g_sProgShortName, "CheckForUpdates", 4))
	$g_iUptimeMonitor = Int(IniRead($g_sPathIni, "Donate", "Seconds", 0))
	$g_iDonateTime = Int(IniRead($g_sPathIni, "Donate", "DonateTime", 0))
	$g_SelectedSolution = Int(IniRead($g_sPathIni, $g_sProgShortName, "SelectedSolution", 0))
	$g_SelSolutionTemp = $g_SelectedSolution

EndFunc   ;==>_LoadConfiguration


Func _SaveConfiguration()

	IniWrite($g_sPathIni, $g_sProgShortName, "SelectedSolution", $g_SelectedSolution)
	IniWrite($g_sPathIni, "Donate", "Seconds", $g_iUptimeMonitor)

EndFunc

#EndRegion "Configuration (Settings)"


Func _CheckForUpdates()

	_SetUpdateAnimationState($GUI_SHOW)
	_SoftwareUpdateCheck(True)
	_SetUpdateAnimationState($GUI_HIDE)

EndFunc   ;==>_CheckForUpdates


Func _UptimeMonitor()
	If $g_iUptimeMonitor < 2000000000 Then
		$g_iUptimeMonitor += 1
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
	GUICtrlSetState($g_hMenuDebug, $iState)

EndFunc   ;==>_SetProcessingStates


Func _ShutdownProgram()

	AdlibUnRegister("_OnIconsHover")
	AdlibUnRegister("_UptimeMonitor")

	_SaveConfiguration()

	If $g_iUptimeMonitor > $g_iDonateTimeSet = True And _
			$g_iDonateTime == 0 Then
		IniWrite($g_sPathIni, "Donate", "DonateTime", $g_iUptimeMonitor)
		_Donate_ShowDialog()
	Else
		;~ If $g_ClearCacheOnExit == 1 Then DirRemove($g_CachePath, 1)
		WinSetTrans($g_hCoreGui, Default, 255)
		_TerminateProgram()
	EndIf

EndFunc   ;==>_ShutdownProgram


Func _TerminateProgram()

	If $g_iSingleton Then
		Local $iPID = ProcessExists(@ScriptName)
		If $iPID Then ProcessClose($iPID)
	EndIf
	Exit

EndFunc


Func _MinimizeProgram()

	Local $iState = WinGetState($g_hCoreGui)

	If BitAND($iState, 4) Then
		WinSetState($g_hCoreGui, "", @SW_MINIMIZE)
	EndIf
EndFunc


#Region "States"

Func _DetectSolutionIndexChange($iSel)

	If $iSel <> $g_SelectedSolution Then
		Return True
	Else
		Return False
	EndIf

EndFunc

Func _InitializeStates()

	For $iBr = 0 To $CNT_BUILD
		$g_aBuildState[$iBr][0][0] = $GUI_ENABLE
		$g_aBuildState[$iBr][0][1] = $GUI_ENABLE
		$g_aBuildState[$iBr][0][2] = $GUI_CHECKED
	Next

	For $iDr = 0 To $CNT_DISTRIBUTE - 1
		$g_aBuildState[$iDr][1][0] = $GUI_ENABLE
		$g_aBuildState[$iDr][1][1] = $GUI_ENABLE
		$g_aBuildState[$iDr][1][2] = $GUI_CHECKED
	Next

EndFunc


Func _ResetOptionItemsChecked()

	For $iBr = 0 To $CNT_BUILD - 1
		If $g_aBuildState[$iBr][0][1] <> $GUI_DISABLE Then
			$g_aBuildState[$iBr][0][2] = $GUI_CHECKED
		Else
			$g_aBuildState[$iBr][0][2] = $GUI_UNCHECKED
		EndIf

		ConsoleWrite($g_aBuildState[$iBr][0][0] & " " & $g_aBuildState[$iBr][0][1] & " " & _
		$g_aBuildState[$iBr][0][2] & @CRLF)
	Next

	ConsoleWrite(@CRLF)

	For $iDr = 0 To $CNT_DISTRIBUTE - 1
		If $g_aBuildState[$iDr][1][1] <> $GUI_DISABLE Then
			$g_aBuildState[$iDr][1][2] = $GUI_CHECKED
		Else
			$g_aBuildState[$iDr][1][2] = $GUI_UNCHECKED
		EndIf

		ConsoleWrite($g_aBuildState[$iDr][1][0] & " " & $g_aBuildState[$iDr][1][1] & " " & _
		$g_aBuildState[$iDr][1][2] & @CRLF)
	Next

	_SetOptionsChecked()

EndFunc


Func _SetAllOptionStates($iState)

	For $iBr = 0 To $CNT_BUILD - 1
		_SetOptionsItemState($iState, $iBr, 0)
	Next

	For $iDr = 0 To $CNT_DISTRIBUTE - 1
		_SetOptionsItemState($iState, $iDr, 1)
	Next

EndFunc   ;==>_SetAllOptionStates


Func _SetAllOptionsChecked($iState)

	For $iBr = 0 To $CNT_BUILD - 1
		GUICtrlSetState($g_aBuild[$iBr][0][1], $iState)
	Next

	For $iDr = 0 To UBound($g_aBuild, 1) - 1
		GUICtrlSetState($g_aBuild[$iDr][1][1], $iState)
	Next

EndFunc   ;==>_SetAllOptionsChecked


Func _SetModules($iSel)

	Local $sSolIniPath = _GUICtrlListView_GetItemText($g_hListSolutions, $iSel, 1)
	If FileExists($sSolIniPath) Then

		Local $aModules = IniReadSection($sSolIniPath, "Modules")
		If Not @error Then

			For $iMr = 1 To $aModules[0][0]

				Switch $aModules[$iMr][0]
					Case "Build"
						_SetModuleStates($aModules[$iMr][1], 0, 0)
					Case "Compress"
						_SetModuleStates($aModules[$iMr][1], 1, 0)
					Case "Sign"
						_SetModuleStates($aModules[$iMr][1], 2, 0)
					Case "Documentation"
						_SetModuleStates($aModules[$iMr][1], 3, 0)
					Case "Import"
						_SetModuleStates($aModules[$iMr][1], 0, 1)
					Case "Distribute"
						_SetModuleStates($aModules[$iMr][1], 1, 1)
					Case "Portable"
						_SetModuleStates($aModules[$iMr][1], 2, 1)
					Case "Installation"
						_SetModuleStates($aModules[$iMr][1], 3, 1)
					Case "SignInstall"
						_SetModuleStates($aModules[$iMr][1], 4, 1)
					Case "UpdateFile"
						_SetModuleStates($aModules[$iMr][1], 5, 1)
					Case Else
						_SetAllOptionStates($GUI_ENABLE)
				EndSwitch

			Next

		EndIf

	EndIf

	_ResetOptionItemsChecked()

EndFunc


Func _SetModuleStates($iState, $iBDr, $iBDc)

	Local $iCalcState = 128 / ($iState + 1)

	For $iBDCtrl = 1 To 3
		GUICtrlSetState($g_aBuild[$iBDr][$iBDc][$iBDCtrl], $iCalcState)
	Next
	$g_aBuildState[$iBDr][$iBDc][1] = $iCalcState

EndFunc


Func _SetOptionsChecked()

	For $iBr = 0 To $CNT_BUILD - 1
		GUICtrlSetState($g_aBuild[$iBr][0][1], $g_aBuildState[$iBr][0][2])
	Next

	For $iDr = 0 To $CNT_DISTRIBUTE - 1
		GUICtrlSetState($g_aBuild[$iDr][1][1], $g_aBuildState[$iDr][1][2])
	Next

EndFunc


Func _SetOptionsItemState($iState, $iBDr, $iBDc)

	For $iBDCtrl = 1 To 3
		GUICtrlSetState($g_aBuild[$iBDr][$iBDc][$iBDCtrl], $iState)
	Next
	$g_aBuildState[$iBDr][$iBDc][1] = $iState

EndFunc


Func _SetPrerequisiteStates($iBDr, $iBDc, $iState)

	If $g_aBuildState[$iBDr][$iBDc][1] <> $GUI_DISABLE Then
		For $iBDCtrl = 1 To 3
			GUICtrlSetState($g_aBuild[$iBDr][$iBDc][$iBDCtrl], $iState)
		Next
	EndIf

	$g_aBuildState[$iBDr][$iBDc][0] = $iState

EndFunc   ;==>_SetPrerequisiteStates

#EndRegion "States"


#Region "Solutions"

Func _PopulateSolutions()

	_GUICtrlListView_BeginUpdate($g_hListSolutions)
	_GUICtrlListView_DeleteAllItems($g_hListSolutions)

	;~ Build Groups
	_GUICtrlListView_EnableGroupView($g_hListSolutions)
	_GUICtrlListView_InsertGroup($g_hListSolutions, -1, 1, $g_aLangSolutions[4])
	_GUICtrlListView_InsertGroup($g_hListSolutions, -1, 2, $g_aLangSolutions[5])
	_GUICtrlListView_InsertGroup($g_hListSolutions, -1, 3, $g_aLangSolutions[6])
	_GUICtrlListView_InsertGroup($g_hListSolutions, -1, 4, $g_aLangSolutions[7])
	_GUICtrlListView_InsertGroup($g_hListSolutions, -1, 5, $g_aLangSolutions[8])

	$g_SolutionsCount = 0
	Local $hSearch = FileFindFirstFile($g_sConcreteRoot & "\*.*")
	ConsoleWrite($g_sConcreteRoot & @CRLF)

	While 1

		Local $sFileName = FileFindNextFile($hSearch)
		;~ If there is no more file matching the search.
		If @error Then ExitLoop

		Local $sSolutionBase = $g_sConcreteRoot & "\" & $sFileName
		ConsoleWrite($sSolutionBase & @CRLF)

		If StringInStr(FileGetAttrib($sSolutionBase), "D") Then

			Local $hSolutionSearch = FileFindFirstFile($sSolutionBase & "\*.sni")

			While 1

				Local $sSolutionFile = FileFindNextFile($hSolutionSearch)
				; If there is no more file matching the search.
				If @error Then ExitLoop
				ConsoleWrite($sSolutionFile & @CRLF)

				Local $sSolIniPath = $sSolutionBase & "\" & $sSolutionFile
				ConsoleWrite($sSolIniPath & @CRLF)

				Local $sSolScript = IniRead($sSolIniPath, "Rizonesoft SDK", "Script", "")
				ConsoleWrite($sSolScript & @CRLF)

				Local $sAu3ScriptIn = $sSolutionBase & "\" & $sSolScript
				Local $sSolCompany = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_Field", "CompanyName")
				Local $sSolCompURL = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_Field", "HomePage")
				Local $sSolName = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_Comment")
				Local $sSolShortName = _AutoIt3Script_GetFilename($sAu3ScriptIn)
				Local $sSolProgDesc = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_Description")
				Local $sSolType = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Change2CUI")
				Local $sSolIcon = ""
				If @Compiled Then
					$sSolIcon = @ScriptDir & "\Resources\Icons\" & $sSolShortName & ".ico"
				Else
					$sSolIcon = _PathFull(_AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Icon"))
				EndIf
				Local $sSolVersion = _AutoIt3Script_GetVersion($sAu3ScriptIn, 0)
				Local $iSolMajor = _AutoIt3Script_GetVersion($sAu3ScriptIn, 1)
				Local $iSolMaintenance = _AutoIt3Script_GetVersion($sAu3ScriptIn, 3)
				Local $iSolBuild = _AutoIt3Script_GetVersion($sAu3ScriptIn, 4)
				Local $sUseBeta = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Version")
				Local $sUseX64 = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_UseX64")
				Local $sCompileBoth = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Compile_both")
				Local $sOutFile = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_OutFile")
				Local $sOutFileX64 = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_OutFile_X64")

				If $sOutFile = "" Then $sOutFile = $sSolShortName & ".exe"
				If $sOutFileX64 = "" Then $sOutFileX64 = $sSolShortName & "_X64.exe"

				Local $sOutFilePath = _PathFull(_FileEx_PathSplit($sAu3ScriptIn, 2) & $sOutFile)
				Local $sOutFileX64Path = _PathFull(_FileEx_PathSplit($sAu3ScriptIn, 2) & $sOutFileX64)
				Local $sDistributionPath = $sSolutionBase & "\Distribution\" & $iSolBuild
				Local $sDistributionName = $sSolShortName & "_" & $iSolBuild
				Local $sFullDistributionPath = $sDistributionPath & "\" & $sDistributionName
				Local $sDistroSourceName = $sSolShortName & "_" & $iSolBuild & "_Source"
				Local $sDistroSourceFullPath = $sDistributionPath & "\" & $sDistroSourceName

				If IniRead($sSolIniPath, "Rizonesoft SDK", "Compatibilty", "") = "Rizonesoft SDK " & _GetProgramVersion(1) Then

					_GUICtrlListView_AddItem($g_hListSolutions, " " & $sSolName & " " & $iSolMajor & " (Build " & $iSolBuild & ")", 0)
					_GUICtrlListView_AddSubItem($g_hListSolutions, $g_SolutionsCount, $sSolIniPath, 1)
					_GUICtrlListView_SetItemGroupID($g_hListSolutions, $g_SolutionsCount, $iSolMaintenance + 1)

					_GUIImageList_AddIcon($g_ImgSolutions, $sSolIcon, 0)
					If @error Then
						If StringInStr($sSolType, "Y") Then
							_ImageListEx_AddBlankIcon($g_ImgSolutions, $g_hListSolutions, @ScriptFullPath, -230)
						Else
							_ImageListEx_AddBlankIcon($g_ImgSolutions, $g_hListSolutions, @ScriptFullPath, -229)
						EndIf
					EndIf

					_GUICtrlListView_SetItemImage($g_hListSolutions, $g_SolutionsCount, $g_SolutionsCount, 0)

					$g_SolutionsCount += 1

				EndIf

				; Local $sSolCompany = StringRegExpReplace($sSolCompTemp, "([©|\(c\)|Copyright][\s][0-9]{4}[\s])", "")

				IniWrite($sSolIniPath, "Environment", "ScriptPath", $sAu3ScriptIn)
				IniWrite($sSolIniPath, "Environment", "Company", $sSolCompany)
				IniWrite($sSolIniPath, "Environment", "CompanyURL", $sSolCompURL)
				IniWrite($sSolIniPath, "Environment", "Name", $sSolName)
				IniWrite($sSolIniPath, "Environment", "ShortName", $sSolShortName)
				IniWrite($sSolIniPath, "Environment", "Description", $sSolProgDesc)
				IniWrite($sSolIniPath, "Environment", "Type", $sSolType)
				IniWrite($sSolIniPath, "Environment", "Icon", $sSolIcon)
				IniWrite($sSolIniPath, "Environment", "Version", $sSolVersion)
				IniWrite($sSolIniPath, "Environment", "VersionMajor", $iSolMajor)
				IniWrite($sSolIniPath, "Environment", "VersionMaintenance", $iSolMaintenance)
				IniWrite($sSolIniPath, "Environment", "VersionBuild", $iSolBuild)
				IniWrite($sSolIniPath, "Environment", "UseBeta", $sUseBeta)
				IniWrite($sSolIniPath, "Environment", "UseX64", $sUseX64)
				IniWrite($sSolIniPath, "Environment", "CompileBoth", $sCompileBoth)
				IniWrite($sSolIniPath, "Environment", "OutFile", StringReplace($sOutFile, "..\..\..\Resolute\", ""))
				IniWrite($sSolIniPath, "Environment", "OutFileX64", StringReplace($sOutFileX64, "..\..\..\Resolute\", ""))
				IniWrite($sSolIniPath, "Environment", "OutFilePath", $sOutFilePath)
				IniWrite($sSolIniPath, "Environment", "OutFileX64Path", $sOutFileX64Path)
				IniWrite($sSolIniPath, "Environment", "InstallScriptPath", 0)
				IniWrite($sSolIniPath, "Environment", "InstallOutputPath", 0)
				IniWrite($sSolIniPath, "Environment", "InstallSize", 0)
				IniWrite($sSolIniPath, "Environment", "DistributionPath", $sDistributionPath)
				IniWrite($sSolIniPath, "Environment", "DistributionName", $sDistributionName)
				IniWrite($sSolIniPath, "Environment", "FullDistributionPath", $sFullDistributionPath)
				IniWrite($sSolIniPath, "Environment", "DistroSourceName", $sDistroSourceName)
				IniWrite($sSolIniPath, "Environment", "DistroSourceFullPath", $sDistroSourceFullPath)

			WEnd

			FileClose($hSolutionSearch)

		EndIf

	WEnd

	FileClose($hSearch)

	_GUICtrlListView_SetColumn($g_hListSolutions, 0, $g_aLangSolutions[0] & " (" & _
		$g_SolutionsCount & Chr(32) & _StringEx_ReturnPlural($g_SolutionsCount, $g_aLangSolutions[2], $g_aLangSolutions[3]) & ")")
	_GUICtrlListView_EndUpdate($g_hListSolutions)

EndFunc   ;==>_PopulateSolutions

#EndRegion "Solutions"


#Region "Prerequisites"

Func _CheckPrerequisites()

	$g_aAutoIt3 = _CheckPrerequisite("AutoIt3\Uninstall.exe", "AutoIt 3.14 +", "AutoIt3.exe", 0, 0)
	$g_aAutoIt3Beta = _CheckPrerequisite("AutoIt3\Beta\Uninstall.exe", "AutoIt Beta 3.15 +", "AutoIt3.exe", 1, 0)
	$g_aScite4AutoIt = _CheckPrerequisite("AutoIt3\SciTE\uninst.exe", "Scite4AutoIt", "SciTE.exe", 2, 0)
	$g_aInnoSetup = _CheckPrerequisite("Inno Setup 6\unins000.exe", "Inno Setup 5", "ISCC.exe", 3, 0)
	$g_aSigntool = _CheckSignTool("Microsoft Signtool", 4, 0)
	$g_a7Zip = _CheckPrerequisite(@ScriptDir & "\Bin\x64\7za.exe", "7-Zip Extra 19.00", "", 0, 1, True)
	$g_aUPX = _CheckPrerequisite(@ScriptDir & "\Bin\x86\upx.exe", "UPX 3.93", "", 1, 1, True)

	_SetPrerequisiteStates(0, 0, 128 / ($g_aAutoIt3[0] + 1))
	_SetPrerequisiteStates(0, 0, 128 / ($g_aScite4AutoIt[0] + 1))
	_SetPrerequisiteStates(1, 0, 128 / ($g_aUPX[0] + 1))
	_SetPrerequisiteStates(3, 0, 128 / ($g_aSigntool[0] + 1))
	_SetPrerequisiteStates(4, 1, 128 / ($g_a7Zip[0] + 1))
	_SetPrerequisiteStates(3, 1, 128 / ($g_aInnoSetup[0] + 1))
	_SetPrerequisiteStates(4, 1, 128 / ($g_aSigntool[0] + 1))
	_SetPrerequisiteStates(5, 1, 128 / ($g_aAutoIt3[0] + 1))
	; _SetPrerequisiteStates(7, 1, 128 / ($g_a7Zip[0] + 1))

	$g_cAutoItWrapper = $g_aScite4AutoIt[8] & "AutoIt3Wrapper\AutoIt3Wrapper.au3"
	$g_cAut2Exe = $g_aAutoIt3[8] & "Aut2Exe\Aut2exe.exe"
	$g_cTidy = $g_aScite4AutoIt[8] & "\Tidy\Tidy.exe"

	;Hide unused Prerequisites
	For $iPc = 0 To 1
		For $iPr = 1 To $CNT_PREREQUISITES - 1

			If GUICtrlRead($g_aPrerequisites[$iPr][2][$iPc]) == "Prerequisite" Then
				For $iPrCtrl = 1 To 3
					GUICtrlSetState($g_aPrerequisites[$iPr][$iPrCtrl][$iPc], $GUI_HIDE)
				Next
			EndIf
		Next
	Next

EndFunc ;==>_CheckPrerequisites


Func _CheckPrerequisite($sSearch, $sExpectedName, $sExecutable, $iPr, $iPc, $iPortable = False, $sInfoURL = "")
	Local $aPrereqInfo = _GetInstalled($sSearch, $sExpectedName, $sExecutable, $iPortable, $sInfoURL)
	_SetPrerequisiteData($aPrereqInfo, $iPr, $iPc)
	Return $aPrereqInfo
EndFunc   ;==>_CheckPrerequisite


Func _CheckSignTool($sExpectedName, $iPr, $iPc, $sInfoURL = "")

	Local $aSignToolInfo[10]
	Local $aWinKit[5]
	Local $sWinKitsBase = ""

	If @OSArch == "X64" Then
		$sWinKitsBase = "%programfiles(x86)%"
	Else
		$sWinKitsBase = "%ProgramFiles%"
	EndIf

	$aWinKit[0] = $sWinKitsBase & "\Windows Kits\10\bin\10.0.19041.0\x86\signtool.exe"
	$aWinKit[1] = $sWinKitsBase & "\Windows Kits\10\bin\10.0.18362.0\x86\signtool.exe"
	$aWinKit[2] = $sWinKitsBase & "\Windows Kits\10\bin\10.0.16299.0\x86\signtool.exe"
	$aWinKit[3] = $sWinKitsBase & "\Windows Kits\10\bin\10.0.15063.0\x86\signtool.exe"
	$aWinKit[4] = $sWinKitsBase & "\Windows Kits\10\bin\10.0.14393.0\x86\signtool.exe"

	For $iSt = 0 To UBound($aWinKit) - 1
		If FileExists($aWinKit[$iSt]) Then
			$g_cSignTool = $aWinKit[$iSt]
			ExitLoop
		EndIf
	Next

	If FileExists($g_cSignTool) Then

			Local $sVersion = FileGetVersion($g_cSignTool)
			Local $sFileDescription = FileGetVersion($g_cSignTool, $FV_FILEDESCRIPTION)
			Local $sInstallLocation = _FileEx_RemoveFileName($g_cSignTool)

			$aSignToolInfo[0] = True
			$aSignToolInfo[1] = $g_iComIconStart + 6
			$aSignToolInfo[2] = $sInfoURL
			$aSignToolInfo[3] = ""
			$aSignToolInfo[4] = "Microsoft Signtool (" & $sVersion & ")"
			$aSignToolInfo[5] = $sVersion
			$aSignToolInfo[6] = "Microsoft"
			$aSignToolInfo[7] = $sInstallLocation ;RegRead($sFullK, "InstallLocation")
			$aSignToolInfo[8] = ""
			$aSignToolInfo[9] = $g_cSignTool

	Else

			$aSignToolInfo[0] = False
			$aSignToolInfo[1] = $g_iComIconStart + 5
			$aSignToolInfo[2] = $sInfoURL
			$aSignToolInfo[3] = ""
			$aSignToolInfo[4] = "Microsoft Signtool"
			$aSignToolInfo[5] = ""
			$aSignToolInfo[6] = "Microsoft"
			$aSignToolInfo[7] = ""
			$aSignToolInfo[8] = ""
			$aSignToolInfo[9] = ""

	EndIf

	_SetPrerequisiteData($aSignToolInfo, $iPr, $iPc)
	Return $aSignToolInfo

EndFunc


Func _SetPrerequisiteData($aPrereqInfo, $iPr, $iPc)

	For $iPrCtrl = 1 To 2
		GUICtrlSetTip($g_aPrerequisites[$iPr][$iPrCtrl][$iPc], _
			@CRLF & _
			StringFormat($g_aLangPrerequisites[4] & " %s", $aPrereqInfo[4]) & @CRLF & _
			StringFormat($g_aLangPrerequisites[5] & " %s", $aPrereqInfo[6]) & @CRLF & _
			StringFormat($g_aLangPrerequisites[6] & " %s", $aPrereqInfo[8]) & @CRLF & _
			StringFormat($g_aLangPrerequisites[7] & " %s", $aPrereqInfo[9]) & @CRLF & _
			StringFormat($g_aLangPrerequisites[8] & " %s", $aPrereqInfo[2]), _
			_BoolToTipTitle($aPrereqInfo[0]), _IconToTipIcon($aPrereqInfo[1]), $TIP_BALLOON)
	Next

	Local $iECC = ($aPrereqInfo[1] - $g_iComIconStart)
	If $iECC >= 0 And $iECC <= (UBound($g_aCommIcons) - 1) Then
		GUICtrlSetImage($g_aPrerequisites[$iPr][1][$iPc], $g_aCommIcons[$iECC], $aPrereqInfo[1])
	EndIf

	GUICtrlSetData($g_aPrerequisites[$iPr][2][$iPc], $aPrereqInfo[4])

EndFunc   ;==>_SetPrerequisiteData


Func _IconToTipIcon($ico)

	Local $iPreIcon = Int($ico - $g_iComIconStart)
	If $iPreIcon == 6 Then
		Return $TIP_INFOICON
	ElseIf $iPreIcon == 5 Then
		Return $TIP_ERRORICON
	EndIf

EndFunc


Func _BoolToTipTitle($bool)

	If $bool = True Then
		Return $g_aLangPrerequisites[2]
	ElseIf $bool = False Then
		Return $g_aLangPrerequisites[3]
	EndIf

EndFunc   ;==>_BoolToState


Func _GetInstalled($sSearch, $sExpectedName, $sExecutable, $iPortable = False, $sInfoURL = "")

	Local $aInfo[10]

	If Not $iPortable Then

		Local $sUninstallK[2] = ["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", _
				"HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"]
		Local $sSubK = ""

		For $x = 0 To 1

			For $iK1 = 1 To 999

				$sSubK = RegEnumKey($sUninstallK[$x], $iK1)
				If @error Then
					ExitLoop
				EndIf

				Local $sFullK = $sUninstallK[$x] & "\" & $sSubK
				Local $sDisplayName = RegRead($sFullK, "DisplayName")
				Local $sUninstallPath = RegRead($sFullK, "UninstallString")

				If StringInStr($sUninstallPath, $sSearch) Then

					$aInfo[0] = True
					$aInfo[1] = $g_iComIconStart + 6
					$aInfo[2] = $sInfoURL
					$aInfo[3] = RegRead($sFullK, "DisplayIcon")
					$aInfo[4] = $sDisplayName
					$aInfo[5] = RegRead($sFullK, "DisplayVersion")
					$aInfo[6] = RegRead($sFullK, "Publisher")
					$aInfo[7] = RegRead($sFullK, "InstallLocation")
					$aInfo[8] = _FileEx_RemoveFileName($sUninstallPath)
					$aInfo[9] = $aInfo[8] & $sExecutable

					ExitLoop

				Else

					$aInfo[0] = False
					$aInfo[1] = $g_iComIconStart + 5
					$aInfo[2] = $sInfoURL
					$aInfo[3] = ""
					$aInfo[4] = $sExpectedName
					$aInfo[5] = ""
					$aInfo[6] = ""
					$aInfo[7] = ""
					$aInfo[8] = ""

				EndIf

			Next

			If @OSArch = "X86" Then
				ExitLoop
			EndIf

		Next

	Else

		If FileExists($sSearch) Then

			Local $sVersion = FileGetVersion($sSearch)
			Local $sPublisher = FileGetVersion($sSearch, $FV_COMPANYNAME)
			Local $sProductName = FileGetVersion($sSearch, $FV_PRODUCTNAME)
			Local $sFileDescription = FileGetVersion($sSearch, $FV_FILEDESCRIPTION)
			Local $sInstallLocation = _FileEx_RemoveFileName($sSearch)
			Local $sFinalName = ""

			If $sProductName <> "" Then
				$sFinalName = $sProductName
			Else
				$sFinalName = $sFileDescription
			EndIf

			$aInfo[0] = True
			$aInfo[1] = $g_iComIconStart + 6
			$aInfo[2] = $sInfoURL
			$aInfo[3] = ""
			$aInfo[4] = $sFinalName & " (" & $sVersion & ")"
			$aInfo[5] = $sVersion
			$aInfo[6] = $sPublisher
			$aInfo[7] = ""
			$aInfo[8] = $sInstallLocation
			$aInfo[9] = $sSearch

		Else

			$aInfo[0] = False
			$aInfo[1] = $g_iComIconStart + 5
			$aInfo[2] = $sInfoURL
			$aInfo[3] = ""
			$aInfo[4] = $sExpectedName
			$aInfo[5] = ""
			$aInfo[6] = ""
			$aInfo[7] = ""
			$aInfo[8] = ""
			$aInfo[9] = ""

		EndIf

	EndIf

	Return $aInfo

EndFunc   ;==>_GetInstalled

#EndRegion "Prerequisites"


#Region "Processing"

Func _RunSelectedOption()

	$g_SoloProcess = True

	For $iBr = 0 To $CNT_BUILD - 1
		If @GUI_CtrlId = $g_aBuild[$iBr][0][3] Then
			_ProcessSelectedSolution($iBr)
		EndIf
	Next

	For $iDr = 0 To $CNT_DISTRIBUTE - 1
		If @GUI_CtrlId = $g_aBuild[$iDr][1][3] Then
			_ProcessSelectedSolution($iDr + $CNT_BUILD)
		EndIf
	Next

	If @GUI_CtrlId = $g_BtnProcessAll Then
		$g_SoloProcess = False
		_ProcessSelectedSolution(99)
	EndIf

EndFunc   ;==>_RunSelectedOption


Func _ProcessSelectedSolution($iAction)

	ConsoleWrite($iAction)

	Local $iSolutionCount = _GUICtrlListView_GetItemCount($g_hListSolutions)
	; ConsoleWrite($iSolutionCount & @CRLF)

	If $iSolutionCount > 0 And $g_SelectedSolution <> -1 Then

		_StartProcessing()
		Local $sRange = _GUICtrlListView_GetItemTextString($g_hListSolutions, $g_SelectedSolution)
		Local $sRangeSplit = StringSplit($sRange, "|")

		If Not @error Then

			Local $sSolutionName = $sRangeSplit[1]
			Local $sSolutionIniPath = $sRangeSplit[2]

			$g_aEnvironment = IniReadSection($sSolutionIniPath, "Environment")

			If Not @error Then

				If $g_aEnvironment[0][0] >= $g_iMagicNumber Then

					Switch $iAction
						Case 0
							_BuildSelected($sSolutionIniPath, 0, 0)
						Case 1
							_CompressExecutables($sSolutionIniPath, 1, 0)
						Case 2
							_SignExecutables($sSolutionIniPath, 2, 0)
						Case 3
							_GenerateDocumentation($sSolutionIniPath, 3, 0)
						Case 4

						Case 5
							_CreateDistribution($sSolutionIniPath, 1, 1)
						Case 6
							_CreateZipPackage($sSolutionIniPath, 2, 1)
						Case 7
							_CreateInstall($sSolutionIniPath, 3, 1)
						Case 8
							_SignExecutables($sSolutionIniPath, 4, 1, True)
						Case 9
							_CreateUpdateFiles($sSolutionIniPath, 5, 1)
						Case 99

							; ConsoleWrite(_ProcessCheckedCount() & @CRLF)
							If _ProcessCheckedCount() > 0 Then

								If GUICtrlRead($g_aBuild[0][0][1]) = $GUI_CHECKED Then _BuildSelected($sSolutionIniPath, 0, 0)
								If GUICtrlRead($g_aBuild[1][0][1]) = $GUI_CHECKED Then _CompressExecutables($sSolutionIniPath, 1, 0)
								If GUICtrlRead($g_aBuild[2][0][1]) = $GUI_CHECKED Then _SignExecutables($sSolutionIniPath, 2, 0)
								If GUICtrlRead($g_aBuild[3][0][1]) = $GUI_CHECKED Then _GenerateDocumentation($sSolutionIniPath, 3, 0)
								If GUICtrlRead($g_aBuild[1][1][1]) = $GUI_CHECKED Then _CreateDistribution($sSolutionIniPath, 1, 1)
								If GUICtrlRead($g_aBuild[2][1][1]) = $GUI_CHECKED Then _CreateZipPackage($sSolutionIniPath, 2, 1)
								If GUICtrlRead($g_aBuild[3][1][1]) = $GUI_CHECKED Then _CreateInstall($sSolutionIniPath, 3, 1)
								If GUICtrlRead($g_aBuild[4][1][1]) = $GUI_CHECKED Then _SignExecutables($sSolutionIniPath, 4, 1, True)
								If GUICtrlRead($g_aBuild[5][1][1]) = $GUI_CHECKED Then _CreateUpdateFiles($sSolutionIniPath, 5, 1)

								; Reset Build Icons
								For $iBr = 0 To $CNT_BUILD - 1
									_ResetProgress($iBr, 0)
									GUICtrlSetImage($g_aBuild[$iBr][0][0], $g_aCommIcons[$iBr + 11], $g_iComIconStart + 11 + $iBr)
								Next

								For $iDr = 0 To $CNT_DISTRIBUTE - 1
									_ResetProgress($iDr, 1)
									GUICtrlSetImage($g_aBuild[$iDr][1][0], $g_aCommIcons[$iDr + 15], $g_iComIconStart + 15 + $iDr)
								Next

							Else

								MsgBox(BitOr($MB_ICONWARNING, $MB_TOPMOST, $MB_APPLMODAL), _
									$g_aLangMessages2[4], $g_aLangMessages2[5], 60, $g_hCoreGui)

							EndIf

					EndSwitch

				Else

					MsgBox(BitOr($MB_ICONERROR, $MB_TOPMOST, $MB_APPLMODAL), _
						$g_aLangSolutions[9], $g_aLangSolutions[10], 60, $g_hCoreGui)

				EndIf

			EndIf

		EndIf

		_EndProcesssing()

	EndIf

EndFunc   ;==>_ProcessSelectedSolution


Func _BuildSelected($sSolutionIniPath, $iRow, $iCol)

	Local $sReleaseName = $g_aEnvironment[4][1]
	_Logging_Start(StringFormat($g_aLangMessages2[6], $sReleaseName))
	_StartSoloProcess($iRow, $iCol)

	Local $sAu3ScriptIn = $g_aEnvironment[1][1]

	If FileExists($sAu3ScriptIn) Then

		If FileExists($g_aAutoIt3[9]) And FileExists($g_cAutoItWrapper) Then

			Local $iWrapPID = Run(Chr(34) & $g_aAutoIt3[9] & Chr(34) & Chr(32) & Chr(34) & $g_cAutoItWrapper & Chr(34) & " /NoStatus /prod /in " & _
				Chr(34) & $sAu3ScriptIn & Chr(34), _FileEx_RemoveFileName($sAu3ScriptIn), @SW_SHOW, $STDOUT_CHILD)

			While 1

				Local $sWrapOutput = StdoutRead($iWrapPID)
				If @error Then ; Exit the loop if the process closes or StdoutRead returns an error.
					ExitLoop
				EndIf

				If StringLen($sWrapOutput) > 0 Then
					_AutoIt3Script_WrapperOutPut($sWrapOutput)
					_UpdateSoloProcess($iRow, $iCol, _AutoIt3Script_GetBuildProgress($sWrapOutput))
				EndIf

			WEnd

		Else
			_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangMessages2[8], $g_aAutoIt3[9]), "ERROR"))
			_Logging_EditWrite($g_aLangMessages2[9])
		EndIf

	Else
		_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangMessages2[10], $sAu3ScriptIn), "ERROR"))
	EndIf

	$g_iau2exeSimPos = 1

	_PopulateSolutions()

	_Logging_FinalMessage(StringFormat($g_aLangMessages2[7], $sReleaseName))
	_UpdateSoloProcess($iRow, $iCol, 100)

EndFunc   ;==>_BuildSelection


Func _AutoIt3Script_WrapperOutPut($sOutPut)

	If StringStripWS($sOutPut, 8) <> "" Then

		Local $sReplaceOut = StringReplace($sOutPut, "to:", "to: ")
		; $sReplaceOut = StringReplace($sReplaceOut, ">", "> ")
		$sReplaceOut = StringReplace($sReplaceOut, "Created program:", "Created program: ")
		$sReplaceOut = StringReplace($sReplaceOut, "ended.", "ended. ")
		; This shortcut will not be used in the Distro Building Environment, so we remove it.
		$sReplaceOut = StringReplace($sReplaceOut, "Press F4 to jump to next error.", "")
		$sReplaceOut = StringRegExpReplace($sReplaceOut, "([0-9]+):([0-5][0-9]):([0-5][0-9])", "")

		; If StringLeft($sReplaceOut, 1) == ">" Then $sReplaceOut = StringTrimLeft($sReplaceOut, 1)
		; If StringLeft($sReplaceOut, 1) == "-" Then $sReplaceOut = StringTrimLeft($sReplaceOut, 1)

		If StringInStr($sReplaceOut, "Environment") Then StringReplace($sReplaceOut, @CRLF, "")

		If StringInStr($sReplaceOut, @CRLF) Then
			Local $aOutSplt = StringSplit($sReplaceOut, @CRLF, $STR_ENTIRESPLIT)
			For $x = 1 To $aOutSplt[0] ; Loop through the array returned by StringSplit to display the individual values.
				If StringStripWS($aOutSplt[$x], 8) <> "" Then
					_Logging_EditWrite(StringStripWS($aOutSplt[$x], 7))
				EndIf
			Next
		Else
			If StringStripWS($sReplaceOut, 8) <> "" Then
				_Logging_EditWrite(StringStripWS($sReplaceOut, 7))
			EndIf
		EndIf

	EndIf

EndFunc


Func _AutoIt3Script_GetBuildProgress($sWrapOutput)

	$g_iau2exeSimPos += 5
	If $g_iau2exeSimPos > 99 Then $g_iau2exeSimPos = 99

	Return $g_iau2exeSimPos

EndFunc


Func _CompressExecutables($sSolutionIniPath, $iRow, $iCol)

	Local $sReleaseName = $g_aEnvironment[4][1]
	_Logging_Start(StringFormat($g_aLangMessages2[11], $sReleaseName))
	_StartSoloProcess($iRow, $iCol)

	Local $sOutFile = $g_aEnvironment[18][1]
	Local $sOutFileX64 = $g_aEnvironment[19][1]

	If FileExists($sOutFile) Then _CompressExecutable($sOutFile)
	_UpdateSoloProcess($iRow, $iCol, 50)
	If FileExists($sOutFileX64) Then _CompressExecutable($sOutFileX64)

	_Logging_FinalMessage(StringFormat($g_aLangMessages2[12], $sReleaseName))
	_UpdateSoloProcess($iRow, $iCol, 100)

EndFunc   ;==>_CompressExecutables


Func _CompressExecutable($sOutFilePath)

	Local $sUPXParam = "--best --no-backup --overlay=copy --compress-exports=1 --compress-resources=1 --strip-relocs=1"
	Local $iPID

	If FileExists($sOutFilePath) Then

		If FileExists($g_aUPX[9]) Then

			Local $sTempOutFile = Chr(34) & $sOutFilePath & Chr(34)
			Local $sTempUPX = Chr(34) & $g_aUPX[9] & Chr(34)

			_Logging_EditWrite(StringFormat($g_aLangMessages2[13], $sTempOutFile))
			_Logging_EditWrite(StringFormat($g_aLangMessages2[14], $sUPXParam))

			$iPID = Run($sTempUPX & Chr(32) & $sUPXParam & Chr(32) & $sTempOutFile, "", @SW_HIDE, $STDOUT_CHILD)
			If $iPID Then

				Local $pHandle = _ProcessEx_ExitCode($iPID), $iExitCode
				Local $sOutput = "", $aOutput

				ProcessWaitClose($iPID)
				$sOutput = StdoutRead($iPID)

				; Build Array
				$aOutput = StringSplit($sOutput, @CRLF, $STR_ENTIRESPLIT)

				For $i = 1 To $aOutput[0] ; Loop through the array returned by StringSplit to display the individual values.
					If StringStripWS($aOutput[$i], 8) <> "" Then
						_Logging_EditWrite($aOutput[$i])
					EndIf
				Next

				StdioClose($iPID)
				$iExitCode = _ProcessEx_ExitCode($iPID, $pHandle)
				_ProcessEx_CloseHandle($pHandle)

			Else
				_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[15], "ERROR"))
			EndIf

		Else
			_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[16], "ERROR"))
		EndIf

	Else
		_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangMessages2[17], $sOutFilePath), "ERROR"))
	EndIf

EndFunc   ;==>_CompressExecutable


Func _SignExecutables($sSolutionIniPath, $iRow, $iCol, $iSignInstall = False)

	Local $iPing = 10
	Local $iPingError = 0

	Local $sReleaseName = $g_aEnvironment[4][1]
	_Logging_Start(StringFormat($g_aLangMessages2[18], $sReleaseName))
	_StartSoloProcess($iRow, $iCol)

	If FileExists($g_cSignTool) Then

		; _Logging_EditWrite("Checking connection to the Timestamp Server.")
		; Local $iPing = Ping("timestamp.comodoca.com", 5000)
		_Logging_EditWrite($g_aLangMessages[15])

		$iPing = Ping("8.8.8.8", 3000)
		$iPingError = @error

		If $iPing Then

			_Logging_EditWrite(StringFormat($g_aLangMessages[16], $iPing))
			_UpdateSoloProcess($iRow, $iCol, 20)

			Local $sCertSetIni = IniRead($sSolutionIniPath, "Signing", "CertificateSet", "Signing\Signing.ini")
			Local $sCertInfoPath = @ScriptDir & "\" & _FileEx_CleanDirectoryName($sCertSetIni)
			Local $sCertWorkPath = _FileEx_PathSplit($sCertInfoPath, 2)
			Local $sCertBaseName = IniRead($sCertInfoPath, "Certificate", "CertificateName", "Rizonesoft(test).pfx")
			Local $sCertPath = $sCertWorkPath & $sCertBaseName

			If FileExists($sCertInfoPath) Then
				_Logging_EditWrite(StringFormat($g_aLangMessages2[30], $sCertInfoPath))
				_UpdateSoloProcess($iRow, $iCol, 40)

				If FileExists($sCertPath) Then
					_Logging_EditWrite(StringFormat($g_aLangMessages2[31], $sCertPath))
					_UpdateSoloProcess($iRow, $iCol, 60)

					Local $sCertDescription = IniRead($sSolutionIniPath, "Signing", "Description", $g_sProgName)
					Local $sCertWebsite = IniRead($sSolutionIniPath, "Signing", "Website", _Link_Split($g_sUrlCompHomePage, 2))
					Local $sCertPassword = IniRead($sCertInfoPath, "Certificate", "Password", "Password")
					Local $sCertTimeServer = IniRead($sCertInfoPath, "Certificate", "Timestamp", "http://timestamp.verisign.com/scripts/timstamp.dll")

					If $iSignInstall = True Then

						Local $sInstallOutFile = IniRead($sSolutionIniPath, "Environment", "InstallOutputPath", "")
						If FileExists($sInstallOutFile) Then
							_RunSignCommand($sInstallOutFile, $sCertPath, $sCertDescription & " Setup", $sCertWebsite, $sCertPassword, $sCertTimeServer)
						Else
							_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangMessages2[28], $sInstallOutFile), "ERROR"))
							_Logging_EditWrite($g_aLangMessages2[29])
						EndIf

						_UpdateSoloProcess($iRow, $iCol, 80)

					Else

						Local $sOutFile = $g_aEnvironment[18][1]
						Local $sOutFileX64 = $g_aEnvironment[19][1]

						If FileExists($sOutFile) Then
							_RunSignCommand($sOutFile, $sCertPath, $sCertDescription, $sCertWebsite, $sCertPassword, $sCertTimeServer)
						EndIf

						_UpdateSoloProcess($iRow, $iCol, 80)

						If FileExists($sOutFileX64) Then
							_RunSignCommand($sOutFileX64, $sCertPath, $sCertDescription, $sCertWebsite, $sCertPassword, $sCertTimeServer)
						EndIf

					EndIf

				Else

					_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[26], "ERROR"))
					_Logging_EditWrite(StringFormat($g_aLangMessages2[27], $sCertPath))

				EndIf

			Else

				_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[24], "ERROR"))
				_Logging_EditWrite(StringFormat($g_aLangMessages2[25], $sCertInfoPath))

			EndIf

		Else

			; _Logging_EditWrite("Please note that a connection to the Timestamp Server is required for signing.")
			_Logging_EditWrite($g_aLangMessages2[20])
			_Logging_EditWrite(_Logging_SetLevel(_Message_ReturnConnectionError($iPingError), "ERROR"))

		EndIf

	Else

		; Windows SDK not is not installed
		_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangMessages2[21], $sReleaseName), "ERROR"))
		_Logging_EditWrite($g_aLangMessages2[22])
		_Logging_EditWrite($g_aLangMessages2[23])

	EndIf

	_Logging_FinalMessage(StringFormat($g_aLangMessages2[19], $sReleaseName))
	_UpdateSoloProcess($iRow, $iCol, 100)

EndFunc


Func _RunSignCommand($sOutputFile, $sCertPath, $sDescription, $sWebsite, $sPassword, $sCertTimeServer)

	;~ ====================================================================================================
	;~ Signcode.exe Parameters
	;~ ====================================================================================================
	;~ -$ authority		| Specifies the signing authority of the certificate, which must be either individual or commercial. By default, Signcode.exe uses the certificate's highest permission.
	;~ -a algorithm		| Specifies the hashing algorithm for signing, which must be either md5 (the default) or sha1.
	;~ -c file			| Specifies the file that contains the encoded software publishing certificate.
	;~ -cn name			| Specifies the common name of the certificate.
	;~ -i info			| Specifies a place to get more information on content (usually a URL).
	;~ -j dllName		| Specifies the name of a DLL that returns an array of authenticated attributes for signing files. You can specify more than one DLL by repeating the -j option.
	;~ -jp param		| Specifies a parameter to be passed for the preceding DLL. For example: -j dll1 -jp dll1Param. The tool allows only one parameter per DLL.
	;~ -k keyname		| Specifies the key container name.
	;~ -ky keytype		| Specifies the key type, which must be signature, exchange, or an integer (such as 4).
	;~ -n name			| Specifies a text name that represents the content of the file to sign.
	;~ -p provider		| Specifies the name of the cryptographic provider on the system.
	;~ -r location		| Specifies the location of the certificate store in the registry, which must be either currentuser (the default) or localmachine.
	;~ -s store			| Specifies the certificate store that contains the signing certificate. The default is my store.
	;~ -sha1 thumbprint	| Specifies the thumbprint, which is the sha1 hash of the signing certificate included in the certificate store.
	;~ -sp policy		| Sets the certificate store policy, which must be either spcStore (the default) or chain. If you specify chain, all certificates in the verification chain, including self-signed certificates, are added to the signature. If you specify spcStore, trusted, self-signed certificates are not included with the certificates in the chain that are added to the signature.
	;~ -spc file		| Specifies the SPC file that contains software publishing certificates.
	;~ -t URL			| Indicates that the file is to be timestamped by the timestamp server at the specified http address.
	;~ -tr number		| Specifies the maximum number of timestamp trials until success; defaults to 1.
	;~ -tw number		| Specifies the delay (in number of seconds) between each timestamp trial. Defaults to 0.
	;~ -v pvkFile		| Specifies the private key (.pvk) file name that contains the private key.
	;~ -x				| Timestamps, but does not sign, the file.
	;~ -y type			| Specifies the cryptographic provider type to use. A cryptographic provider contains implementations of cryptographic standards and algorithms. For a list of the default provider types, see "Microsoft Cryptographic Service Providers" in the Platform SDK.
	;~ -?				| Displays command syntax and options for the tool.


	Local $sPassMsk = ""
	Local $iPassLen = StringLen($sPassword)
	For $i = 1 To $iPassLen
		$sPassMsk &= "*"
	Next

	_Logging_EditWrite("Signing: " & $sOutputFile)
	_Logging_EditWrite("Description: " & $sDescription)
	_Logging_EditWrite("Website: " & $sWebsite)
	_Logging_EditWrite("Password: " & $sPassMsk)

	Local $sSignWorkingDir = _FileEx_PathSplit($g_cSignTool, 2)
	Local $sSignCommand = "signtool.exe sign /f " & Chr(34) & $sCertPath & Chr(34) & " /p " & $sPassword & _
			" /t " & $sCertTimeServer & Chr(32) & Chr(34) & $sOutputFile & Chr(34)

	_Logging_EditWrite("Command: " & $sSignCommand)
	_ProcessEx_RunCommand($sSignCommand, $sSignWorkingDir)

EndFunc   ;==>_RunSignCommand


Func _GenerateDocumentation($sSolutionIniPath, $iRow, $iCol)

	Local $sReleaseName = $g_aEnvironment[4][1]
	Local $sRelShortName = $g_aEnvironment[5][1]

	;;Local $sRelShortName = $g_aEnvironment[18][1]


	_Logging_Start(StringFormat($g_aLangMessages2[32], $sReleaseName))
	_StartSoloProcess($iRow, $iCol)

	Local $sHelpNDocOut = @MyDocumentsDir & "\HelpNDoc\Output\chm\" & $sReleaseName & ".chm"
	Local $sDocumentsRoot = _FileEx_PathSplit($sSolutionIniPath, 2)
	Local $sDocsTplRoot = $sDocumentsRoot & "Templates"
	If @Compiled Then
		Local $sDocOutputRoot = _PathFull("..\Resolute\Docs\" & $sRelShortName)
	Else

	EndIf
	Local $iSolInstallSize = _GetInstallSize($sSolutionIniPath, _FileEx_PathSplit($sSolutionIniPath, 2))
	Local $iSolInstSizeMB = Round($iSolInstallSize / 1024^2)

	If Not FileExists($sDocOutputRoot) Then
		_Logging_EditWrite($g_aLangMessages2[83])
		If Not DirCreate($sDocOutputRoot) Then
			_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[85], "ERROR"))
			_Logging_EditWrite(StringFormat("^ '%s'", $sDocOutputRoot))
		EndIf
	EndIf

    ; List all the files and folders in the desktop directory using the default parameters.
    Local $aTplFileList = _FileListToArray($sDocsTplRoot, "*.tpl")
    If @error = 1 Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[36], "ERROR"))
		_Logging_EditWrite(StringFormat("^ " & $g_aLangMessages2[37], $sDocsTplRoot))
	Else
		_Logging_EditWrite(StringFormat($g_aLangMessages2[33], $sDocsTplRoot))
		If @error = 4 Then
			_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangMessages2[38], _
					_StringEx_ReturnPlural($aTplFileList[0], $g_aLangMessages[25], $g_aLangMessages[26])), "ERROR"))
		Else

			Local $iTperc 			= 0
			Local $sTemplateInput 	= ""
			Local $sDocOutputFile 	= ""
			Local $sDocOutput		= ""

			_Logging_EditWrite(StringFormat($g_aLangMessages2[34], $aTplFileList[0], _
					_StringEx_ReturnPlural($aTplFileList[0], $g_aLangMessages[25], $g_aLangMessages[26])))
			For $iX = 1 To $aTplFileList[0]

				$sTemplateInput = $sDocsTplRoot & Chr(92) & $aTplFileList[$iX]
				$sDocOutputFile = StringReplace($aTplFileList[$iX], ".tpl", ".txt")
				$sDocOutput = $sDocOutputRoot & "\" & $sDocOutputFile

				_ProcessTemplateFile($sSolutionIniPath, $sTemplateInput, $sDocOutput, $iSolInstSizeMB)

				$iTperc = (($iX / $aTplFileList[0]) * 90)
				$iTperc = Round($iTperc)
				_UpdateSoloProcess($iRow, $iCol, $iTperc)

			Next

		EndIf

	EndIf

	If FileExists($sHelpNDocOut) Then
		_Logging_EditWrite($g_aLangMessages2[84])
		Local $sDocOutputChm = $sDocOutputRoot & "\" & $sRelShortName & ".chm"
		If Not FileCopy($sHelpNDocOut, $sDocOutputChm) Then
			_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[86], "ERROR"))
			_Logging_EditWrite(StringFormat("^ '%s'", $sDocOutputChm))
		EndIf
	EndIf

	IniWrite($sSolutionIniPath, "Environment", "InstallSize", $iSolInstallSize)
	_Logging_FinalMessage($g_aLangMessages2[44])
	_UpdateSoloProcess($iRow, $iCol, 100)

EndFunc   ;==>_GenerateDocumentation



Func _ProcessTemplateFile($sSolutionIniPath, $sDocTemplateIn, $sDocOutput, $iReleaseInstSize)

	Local $sReleasCompany = $g_aEnvironment[2][1]
	Local $sReleasURL = IniRead($sSolutionIniPath, "Links", "CompanyURL", "https://www.rizonesoft.com")
	Local $sReleasName = $g_aEnvironment[4][1]
	Local $sReleasDesc = $g_aEnvironment[6][1]
	Local $sReleasVersion = $g_aEnvironment[9][1]
	Local $sReleasInstSize = Round($g_aEnvironment[22][1] / 1024^2)
	Local $sReleasDocDay = @MDAY
	Local $sReleasDocMonth = _DateToMonth(@MON)
	Local $sReleasDocYear = @YEAR

	_Logging_EditWrite(StringFormat($g_aLangMessages2[35], $sDocTemplateIn))

	; Open the Solution Template file for reading and store the handle to a variable.
	Local $hTemplateOpen = FileOpen($sDocTemplateIn, $FO_READ)
	If $hTemplateOpen = -1 Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[39], "ERROR"))
		_Logging_EditWrite(StringFormat("^ " & $g_aLangMessages2[41], $sDocTemplateIn))
		Return SetError(1, 0, False)
	EndIf

	Local $sTemplateRead = FileRead($hTemplateOpen)
	$sTemplateRead = StringReplace($sTemplateRead, "%{RELEASE}", StringUpper($sReleasName))
	$sTemplateRead = StringReplace($sTemplateRead, "%{DESCRIPTION}", $sReleasDesc)
	$sTemplateRead = StringReplace($sTemplateRead, "%{COMPANY}", StringUpper($sReleasCompany))
	$sTemplateRead = StringReplace($sTemplateRead, "%{COMPANYURL}", $sReleasURL)
	$sTemplateRead = StringReplace($sTemplateRead, "%{VERSION}", $sReleasVersion)
	$sTemplateRead = StringReplace($sTemplateRead, "%{DAY}", $sReleasDocDay)
	$sTemplateRead = StringReplace($sTemplateRead, "%{MONTH}", StringUpper($sReleasDocMonth))
	$sTemplateRead = StringReplace($sTemplateRead, "%{YEAR}", $sReleasDocYear)
	$sTemplateRead = StringReplace($sTemplateRead, "%{INSTSIZE}", $iReleaseInstSize & " MB")

	; Close the handle returned by FileOpen.
	FileClose($hTemplateOpen)

	FileDelete($sDocOutput)
	If Not FileWrite($sDocOutput, $sTemplateRead) Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[40], "ERROR"))
		_Logging_EditWrite(StringFormat($g_aLangMessages2[42], $sDocOutput))
		Return SetError(3, 0, False)
	EndIf

	_Logging_EditWrite($g_aLangMessages2[43])
	_Logging_EditWrite(StringFormat($g_aLangMessages2[42], $sDocOutput))
	Return SetError(0, 0, True)

EndFunc   ;==>_ProcessTemplateFile


Func _CreateDistribution($sSolutionIniPath, $iRow, $iCol)

	Local $sInputPath = _FileEx_PathSplit($sSolutionIniPath, 2)
	Local $sOutputPath = $g_aEnvironment[25][1]
	Local $sReleasName = $g_aEnvironment[4][1]
	Local $iFilePerc = 0, $sOutputFile = ""

	_Logging_Start(StringFormat($g_aLangMessages2[45], $sReleasName))
	_StartSoloProcess($iRow, $iCol)

	Local $aFiles = IniReadSection($sSolutionIniPath, "Distribute")
	If Not @error Then
		For $xF = 1 To $aFiles[0][0]
			$sOutputFile = _CleanDestinationPath($sOutputPath & "\" & $aFiles[$xF][1])
			If StringInStr($aFiles[$xF][0], "Directory") Then
				_DistributeDirectory($sOutputFile)
			ElseIf StringInStr($aFiles[$xF][0], "File") Then
				_DistributeFile(_ReplacePathVariables($sInputPath, $aFiles[$xF][1]), $sOutputFile)
			EndIf
			$iFilePerc = ($xF / $aFiles[0][0]) * 100
			_UpdateSoloProcess($iRow, $iCol, $iFilePerc)
		Next
	EndIf

	_Logging_FinalMessage(StringFormat($g_aLangMessages2[51], $sReleasName))
	_UpdateSoloProcess($iRow, $iCol, 100)

EndFunc   ;==>_CreateDistribution


Func _DistributeDirectory($sDestPath)

	If Not FileExists($sDestPath) Then
		If Not DirCreate($sDestPath) Then
			_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[46], "ERROR"))
			_Logging_EditWrite("^ '" & $sDestPath & "'")
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	_Logging_EditWrite(StringFormat($g_aLangMessages2[47], StringReplace($sDestPath, @ScriptDir, "")))
	Return 1

EndFunc   ;==>_DistributeDirectory


Func _DistributeFile($sFilePath, $sDestPath)

	If Not FileExists($sFilePath) Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[48], "ERROR"))
		_Logging_EditWrite("^ '" & $sFilePath & "'")
		Return SetError(1, 0, 0)
	EndIf

	If Not FileCopy($sFilePath, $sDestPath, $FC_OVERWRITE + $FC_CREATEPATH) Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[49], "ERROR"))
		_Logging_EditWrite("^ '" & $sDestPath & "'")
		Return SetError(1, 0, 0)
	EndIf

	_Logging_EditWrite(StringFormat($g_aLangMessages2[51], StringReplace($sDestPath, @ScriptDir, "")))
	Return 1

EndFunc   ;==>_DistributeFile


Func _ReplacePathVariables($sInputPath, $sPath)

	Local $sReturnPath

	$sReturnPath = StringReplace($sPath, "%RootDir%", $g_sRootDir)
	$sReturnPath = StringReplace($sReturnPath, "%SourceDir%", $sInputPath)
	Return $sReturnPath

EndFunc


Func _CleanDestinationPath($sPath)

	Local $sReturnPath

	$sReturnPath = StringReplace($sPath, "%RootDir%\", "")
	$sReturnPath = StringReplace($sReturnPath, "%SourceDir%\", "")
	Return $sReturnPath

EndFunc


Func _CreateZipPackage($sSolutionIniPath, $iRow, $iCol)

	Local $sReleasName = $g_aEnvironment[4][1]
	Local $s7ZipWorkingDir = _FileEx_PathSplit($sSolutionIniPath, 2) & "\Distribution\" & $g_aEnvironment[12][1]
	Local $sZipFileName = $g_aEnvironment[5][1] & "_" & $g_aEnvironment[12][1] & ".zip"
	Local $sZipDirName = $g_aEnvironment[5][1] & "_" & $g_aEnvironment[12][1]
	Local $sZipCommand = ""

	_Logging_Start(StringFormat($g_aLangMessages2[56], $sReleasName))
	_StartSoloProcess($iRow, $iCol)

	If _ReturnDistributionState($sSolutionIniPath) > 0 Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[53], "ERROR"))
		_Logging_EditWrite("^ " & $g_aLangMessages2[54])
		_Logging_EditWrite($g_aLangMessages2[55])
	Else

		If FileExists($g_a7Zip[9]) Then
			$sZipCommand = Chr(34) & $g_a7Zip[9] & Chr(34) & " a -tzip " & $sZipFileName  & " " & $sZipDirName
			_ProcessEx_RunCommand($sZipCommand, $s7ZipWorkingDir)
		EndIf

	EndIf

	_Logging_FinalMessage($g_aLangMessages2[57])
	_UpdateSoloProcess($iRow, $iCol, 100)

EndFunc   ;==>_CreateZipPackage


Func _ReturnDistributionState($sSolutionIniPath)

	Local $iReturn = 0
	Local $sFilePath = ""

	Local $sDistributionPath = $g_aEnvironment[25][1]

	Local $aFiles = IniReadSection($sSolutionIniPath, "Distribute")
	If Not @error Then
		For $xF = 1 To $aFiles[0][0]
			$sFilePath = _CleanDestinationPath($sDistributionPath & "\" & $aFiles[$xF][1])


			If Not FileExists($sFilePath) Then
				_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[52], "ERROR"))
				_Logging_EditWrite("^ '" & $sFilePath & "'")
				$iReturn += 1
			EndIf
		Next
	EndIf

	Return $iReturn

EndFunc   ;==>_ReturnDistributionState


Func _CreateInstall($sSolutionIniPath, $iRow, $iCol)

	Local $sReleasName = $g_aEnvironment[4][1]
	Local $sDistributionPath = $g_aEnvironment[23][1]
	Local $sInnoWorkingDir = $g_aInnoSetup[8]
	Local $cInnoSetup = _FileEx_PathSplit($g_aInnoSetup[9], 5)

	_Logging_Start(StringFormat($g_aLangMessages2[58], $sReleasName))
	_StartSoloProcess($iRow, $iCol)

	If _ReturnDistributionState($sSolutionIniPath) > 0 Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[59], "ERROR"))
		_Logging_EditWrite("^ " & $g_aLangMessages2[54])
		_Logging_EditWrite($g_aLangMessages2[55])
	Else

		_GenerateInstallationScript($sSolutionIniPath)

		Local $sInstallScriptPath = IniRead($sSolutionIniPath, "Environment", "InstallScriptPath", "")
		If FileExists($sInstallScriptPath) Then
			_ProcessEx_RunCommand($cInnoSetup & Chr(32) & Chr(34) & $sInstallScriptPath & Chr(34), $sInnoWorkingDir)
		EndIf

	EndIf

	_Logging_FinalMessage(StringFormat($g_aLangMessages2[60], $sReleasName))
	_UpdateSoloProcess($iRow, $iCol, 100)

EndFunc   ;==>_CreateInstall


Func _GenerateInstallationScript($sSolutionIniPath)

	Local $sCompanyName = $g_aEnvironment[2][1]
	Local $sProgName = $g_aEnvironment[4][1]
	Local $sProgShortName = $g_aEnvironment[5][1]
	Local $sProgVersion = $g_aEnvironment[9][1]
	Local $sProgBuild = $g_aEnvironment[12][1]
	Local $sDistoPath = $g_aEnvironment[23][1]
	Local $sPackPathName = $g_aEnvironment[24][1]
	Local $sPackPath = $g_aEnvironment[25][1]
	Local $sOutputFile = $g_aEnvironment[16][1]
	Local $sOutput64Bit = $g_aEnvironment[17][1]
	Local $sProgBaseName = $sProgShortName & "_" & $sProgBuild
	Local $sOutputBaseName = $sProgBaseName & "_Setup.exe"
	Local $sScriptBaseName = $sProgBaseName & "_Setup.iss"
	Local $sOutputFullPath = $sDistoPath & "\" & $sOutputBaseName
	Local $sScriptFullPath = $sDistoPath & "\" & $sScriptBaseName
	Local $sIniBaseDir = IniRead($sSolutionIniPath, "Features", "IniBaseDir", "")
	Local $sIniFilBaseName = _FileEx_CleanDirectoryName($sIniBaseDir & "\" & $sProgShortName & ".ini")
	;~ Local $sVersionURL = "https://www.rizonesoft.com/update/" & $sProgShortName & ".rus"
	Local $sUpdateURL = IniRead($sSolutionIniPath, "Links", "UpdateURL", "https://www.rizonesoft.com")
	Local $sCompanyURL = IniRead($sSolutionIniPath, "Links", "CompanyURL", "https://www.rizonesoft.com")
	Local $sSupportURL = IniRead($sSolutionIniPath, "Links", "SupportURL", "https://www.rizonesoft.com")
	Local $sContactURL = IniRead($sSolutionIniPath, "Links", "ContactURL", "https://www.rizonesoft.com")

	Local $i64BitInstall = False
	If StringStripWS($sOutput64Bit, 8) <> "" Then
		$i64BitInstall = True
	EndIf

	If Not FileExists($sDistoPath) Then DirCreate($sDistoPath)
	If FileExists($sScriptFullPath) Then FileDelete($sScriptFullPath)

	If Not FileWrite($sScriptFullPath, ";* " & $sProgName & " - Installer script" & @CRLF) Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[61], "ERROR"))
		Return False
	EndIf

	;Open the file for writing (append to the end of a file) and store the handle to a variable.
	Local $hFileOpen = FileOpen($sScriptFullPath, $FO_APPEND)
	If $hFileOpen = -1 Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[61], "ERROR"))
		Return False
	EndIf

	FileWrite($hFileOpen, ";* Copyright (C) " & @YEAR & " " & $sCompanyName & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "; Requirements:" & @CRLF)
	FileWrite($hFileOpen, "; Inno Setup: http://www.jrsoftware.org/isdl.php" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "; Preprocessor related stuff" & @CRLF)
	FileWrite($hFileOpen, "#if VER < EncodeVer(5,5,9)" & @CRLF)
	FileWrite($hFileOpen, @TAB & "#error Update your Inno Setup version (5.5.9 or newer)" & @CRLF)
	FileWrite($hFileOpen, "#endif" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "#define distrodir " & Chr(34) & $sPackPathName & Chr(34) & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
;~ 	FileWrite($hFileOpen, "#ifnexist distrodir + " & Chr(34) & "\" & $sOutputFile & Chr(34) & @CRLF)
;~ 	FileWrite($hFileOpen, @TAB & "#error Compile " & $sOutputFile & " first." & @CRLF)
;~ 	FileWrite($hFileOpen, "#endif" & @CRLF)
;~ 	If $i64BitInstall = True Then
;~ 		FileWrite($hFileOpen, "" & @CRLF)
;~ 		FileWrite($hFileOpen, "#ifnexist distrodir + " & Chr(34) & "\" & $sOutput64Bit & Chr(34) & @CRLF)
;~ 		FileWrite($hFileOpen, @TAB & "#error Compile " & $sOutput64Bit & " first." & @CRLF)
;~ 		FileWrite($hFileOpen, "#endif" & @CRLF)
;~ 	EndIf

	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "#define app_version   " & Chr(34) & $sProgVersion & Chr(34) & @CRLF)
	FileWrite($hFileOpen, "#define app_name      " & Chr(34) & $sProgName & Chr(34) & @CRLF)
	FileWrite($hFileOpen, "#define app_copyright " & Chr(34) & "Copyright (C) " & @YEAR & " " & $sCompanyName & Chr(34) & @CRLF)
	FileWrite($hFileOpen, "#define quick_launch  " & Chr(34) & "{userappdata}\Microsoft\Internet Explorer\Quick Launch" & Chr(34) & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "[Setup]" & @CRLF)
	FileWrite($hFileOpen, "AppId={#app_name}" & @CRLF)
	FileWrite($hFileOpen, "AppName={#app_name}" & @CRLF)
	FileWrite($hFileOpen, "AppVersion={#app_version}" & @CRLF)
	FileWrite($hFileOpen, "AppVerName={#app_name} {#app_version}" & @CRLF)
	FileWrite($hFileOpen, "AppPublisher=" & $sCompanyName & @CRLF)
	FileWrite($hFileOpen, "AppPublisherURL=" & $sCompanyURL & @CRLF)
	FileWrite($hFileOpen, "AppSupportURL=" & $sSupportURL & @CRLF)
	FileWrite($hFileOpen, "AppUpdatesURL=" & $sUpdateURL & @CRLF)
	FileWrite($hFileOpen, "AppContact=" & $sContactURL & @CRLF)
	FileWrite($hFileOpen, "AppCopyright={#app_copyright}" & @CRLF)
	FileWrite($hFileOpen, "UninstallDisplayIcon={app}\" & $sOutputFile & @CRLF)
	FileWrite($hFileOpen, "UninstallDisplayName={#app_name} {#app_version}" & @CRLF)
	FileWrite($hFileOpen, "DefaultDirName={pf}\" & $sCompanyName & "\" & $sProgName & @CRLF)
	FileWrite($hFileOpen, "LicenseFile=" & $sPackPathName & "\Docs\" & $sProgShortName & "\License.txt" & @CRLF)
	FileWrite($hFileOpen, "OutputDir=." & @CRLF)
	FileWrite($hFileOpen, "OutputBaseFilename=" & StringReplace($sOutputBaseName, ".exe", "") & @CRLF)
	FileWrite($hFileOpen, "WizardImageFile=compiler:WizModernImage-IS.bmp" & @CRLF)
	FileWrite($hFileOpen, "Compression=lzma2/max" & @CRLF)
	FileWrite($hFileOpen, "InternalCompressLevel=max" & @CRLF)
	FileWrite($hFileOpen, "SolidCompression=yes" & @CRLF)
	FileWrite($hFileOpen, "EnableDirDoesntExistWarning=no" & @CRLF)
	FileWrite($hFileOpen, "AllowNoIcons=yes" & @CRLF)
	FileWrite($hFileOpen, "ShowTasksTreeLines=yes" & @CRLF)
	FileWrite($hFileOpen, "DisableDirPage=yes" & @CRLF)
	FileWrite($hFileOpen, "DisableProgramGroupPage=yes" & @CRLF)
	FileWrite($hFileOpen, "DisableReadyPage=yes" & @CRLF)
	FileWrite($hFileOpen, "DisableWelcomePage=yes" & @CRLF)
	FileWrite($hFileOpen, "AllowCancelDuringInstall=no" & @CRLF)
	FileWrite($hFileOpen, "MinVersion=6.0" & @CRLF)
	If $i64BitInstall <> "" Then
		FileWrite($hFileOpen, "ArchitecturesAllowed=x86 x64" & @CRLF)
		FileWrite($hFileOpen, "ArchitecturesInstallIn64BitMode=x64" & @CRLF)
	Else
		FileWrite($hFileOpen, "ArchitecturesAllowed=x86" & @CRLF)
	EndIf
	FileWrite($hFileOpen, "CloseApplications=force" & @CRLF)
	FileWrite($hFileOpen, "SetupMutex=" & Chr(34) & StringLower($sProgShortName) & "_setup_mutex" & Chr(34) & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)

	FileWrite($hFileOpen, "[Languages]" & @CRLF)
	FileWrite($hFileOpen, "Name: en; MessagesFile: compiler:Default.isl" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)

	FileWrite($hFileOpen, "[Messages]" & @CRLF)
	FileWrite($hFileOpen, "SetupAppTitle    =Setup - {#app_name}" & @CRLF)
	FileWrite($hFileOpen, "SetupWindowTitle =Setup - {#app_name}" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)

	FileWrite($hFileOpen, "[CustomMessages]" & @CRLF)
	FileWrite($hFileOpen, "en.msg_AppIsRunning          =Setup has detected that {#app_name} is currently running." & _
			"%n%nPlease close all instances of it now, then click OK to continue, or Cancel to exit." & @CRLF)
	FileWrite($hFileOpen, "en.msg_AppIsRunningUninstall =Uninstall has detected that {#app_name} is currently running." & _
			"%n%nPlease close all instances of it now, then click OK to continue, or Cancel to exit." & @CRLF)
	FileWrite($hFileOpen, "en.msg_DeleteSettings        =Do you also want to delete {#app_name}'s settings?%n%nIf you plan on installing " & _
			"{#app_name} again then you do not have to delete them." & @CRLF)
	FileWrite($hFileOpen, "en.tsk_AllUsers              =For all users" & @CRLF)
	FileWrite($hFileOpen, "en.tsk_CurrentUser           =For the current user only" & @CRLF)
	FileWrite($hFileOpen, "en.tsk_Other                 =Other tasks:" & @CRLF)
	FileWrite($hFileOpen, "en.tsk_ResetSettings         =Reset {#app_name}'s settings" & @CRLF)
	FileWrite($hFileOpen, "en.tsk_StartMenuIcon         =Create a Start Menu shortcut" & @CRLF)
	FileWrite($hFileOpen, "en.tsk_LaunchWelcomePage     =Read Important Release Information!" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)

	FileWrite($hFileOpen, "[Tasks]" & @CRLF)
	FileWrite($hFileOpen, "Name: desktopicon;        Description: {cm:CreateDesktopIcon};     GroupDescription: {cm:AdditionalIcons}; Flags: unchecked" & @CRLF)
	FileWrite($hFileOpen, "Name: desktopicon\user;   Description: {cm:tsk_CurrentUser};       GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive" & @CRLF)
	FileWrite($hFileOpen, "Name: desktopicon\common; Description: {cm:tsk_AllUsers};          GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive" & @CRLF)
	FileWrite($hFileOpen, "Name: startup_icon;       Description: {cm:tsk_StartMenuIcon};     GroupDescription: {cm:AdditionalIcons}" & @CRLF)
	FileWrite($hFileOpen, "Name: quicklaunchicon;    Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked;             OnlyBelowVersion: 6.01" & @CRLF)
	FileWrite($hFileOpen, "Name: reset_settings;     Description: {cm:tsk_ResetSettings};     GroupDescription: {cm:tsk_Other};       Flags: checkedonce unchecked; Check: SettingsExistCheck()" & @CRLF)

	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "[Files]" & @CRLF)

	If $i64BitInstall = True Then
		FileWrite($hFileOpen, "Source: {#distrodir}\" & $sOutput64Bit & "; DestDir: {app}; DestName: " & $sOutputFile & "; Flags: ignoreversion; Check: Is64BitInstallMode()" & @CRLF)
		FileWrite($hFileOpen, "Source: {#distrodir}\" & $sOutputFile & "; DestDir: {app}; Flags: ignoreversion; Check: not Is64BitInstallMode()" & @CRLF)
	Else
		FileWrite($hFileOpen, "Source: {#distrodir}\" & $sOutputFile & "; DestDir: {app}; Flags: ignoreversion" & @CRLF)
	EndIf

	FileWrite($hFileOpen, "Source: {#distrodir}\" & $sIniFilBaseName & "; DestDir: {userappdata}\" & $sCompanyName & "\" & $sProgShortName & "; Flags: onlyifdoesntexist uninsneveruninstall" & @CRLF)

	Local $sSourceName = "", $sDesDirName = "", $sCleanFileName = ""
	Local $aFiles = IniReadSection($sSolutionIniPath, "Distribute")
	If Not @error Then
		For $xF = 1 To $aFiles[0][0]
			If StringInStr($aFiles[$xF][0], "File") Then
				If StringCompare($aFiles[$xF][1], $sOutputFile) <> 0 And _
						StringCompare($aFiles[$xF][1], $sOutput64Bit) <> 0 And _
						Not StringInStr($aFiles[$xF][1], $sIniFilBaseName) Then

					$sCleanFileName = StringReplace($aFiles[$xF][1], "~", "")
					$sSourceName = _CleanDestinationPath(_FileEx_CleanDirectoryName($sCleanFileName))
					$sDesDirName = _CleanDestinationPath(_GetDestDirFromString($sSourceName))
					FileWrite($hFileOpen, "Source: {#distrodir}\" & $sSourceName & "; DestDir: {app}" & $sDesDirName & "; Flags: ignoreversion" & @CRLF)

				EndIf
			EndIf
		Next
	EndIf

	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "[Dirs]" & @CRLF)

	Local $aDir = IniReadSection($sSolutionIniPath, "Distribute")
	If Not @error Then
		For $xD = 1 To $aFiles[0][0]
			If StringInStr($aFiles[$xD][1], "Directory") Then
				FileWrite($hFileOpen, "Name: {userappdata}\" & $sCompanyName & "\" & $sProgShortName & "\" & $aFiles[$xD][1] & @CRLF)
			EndIf
		Next
	EndIf

	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "[Icons]" & @CRLF)
	FileWrite($hFileOpen, "Name: {commondesktop}\{#app_name}; Filename: {app}\" & $sOutputFile & "; Tasks: desktopicon\common; Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: " & $sProgShortName & "; IconFilename: {app}\" & $sOutputFile & "; IconIndex: 0" & @CRLF)
	FileWrite($hFileOpen, "Name: {userdesktop}\{#app_name};   Filename: {app}\" & $sOutputFile & "; Tasks: desktopicon\user;   Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: " & $sProgShortName & "; IconFilename: {app}\" & $sOutputFile & "; IconIndex: 0" & @CRLF)
	FileWrite($hFileOpen, "Name: {userstartmenu}\{#app_name}; Filename: {app}\" & $sOutputFile & "; Tasks: startup_icon;       Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: " & $sProgShortName & "; IconFilename: {app}\" & $sOutputFile & "; IconIndex: 0" & @CRLF)
	FileWrite($hFileOpen, "Name: {#quick_launch}\{#app_name}; Filename: {app}\" & $sOutputFile & "; Tasks: quicklaunchicon;    Comment: {#app_name} {#app_version}; WorkingDir: {app};                        					IconFilename: {app}\" & $sOutputFile & "; IconIndex: 0" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "[INI]" & @CRLF)
	FileWrite($hFileOpen, "Filename: {app}\" & $sIniFilBaseName & "; Section: " & $sProgShortName & "; Key: PortableEdition; String: 0" & @CRLF)
	FileWrite($hFileOpen, "Filename: {userappdata}\" & $sCompanyName & "\" & $sProgShortName & "\" & $sIniFilBaseName & "; Section: " & $sProgShortName & "; Key: PortableEdition; String: 0" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)

	FileWrite($hFileOpen, "[Run]" & @CRLF)
	FileWrite($hFileOpen, "Filename: {app}\" & $sOutputFile & "; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall shellexec skipifsilent unchecked" & @CRLF)

	FileWrite($hFileOpen, "" & @CRLF)

	FileWrite($hFileOpen, "[InstallDelete]" & @CRLF)
	FileWrite($hFileOpen, "Type: files;      Name: {userdesktop}\{#app_name}.lnk;   Check: not IsTaskSelected('desktopicon\user')   and IsUpgrade()" & @CRLF)
	FileWrite($hFileOpen, "Type: files;      Name: {commondesktop}\{#app_name}.lnk; Check: not IsTaskSelected('desktopicon\common') and IsUpgrade()" & @CRLF)
	FileWrite($hFileOpen, "Type: files;      Name: {userstartmenu}\{#app_name}.lnk; Check: not IsTaskSelected('startup_icon')       and IsUpgrade()" & @CRLF)
	FileWrite($hFileOpen, "Type: files;      Name: {#quick_launch}\{#app_name}.lnk; Check: not IsTaskSelected('quicklaunchicon')    and IsUpgrade(); OnlyBelowVersion: 6.01" & @CRLF)
	FileWrite($hFileOpen, "Type: files;      Name: {app}\" & $sIniFilBaseName & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "[UninstallDelete]" & @CRLF)
	FileWrite($hFileOpen, "Type: files;      Name: {app}\" & $sIniFilBaseName & @CRLF)
	FileWrite($hFileOpen, "Type: dirifempty; Name: {app}" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)

	FileWrite($hFileOpen, "[Code]" & @CRLF)
	FileWrite($hFileOpen, "function IsUpgrade(): Boolean;" & @CRLF)
	FileWrite($hFileOpen, @TAB & "var" & @CRLF)
	FileWrite($hFileOpen, @TAB & "sPrevPath: String;" & @CRLF)
	FileWrite($hFileOpen, "begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & "sPrevPath := WizardForm.PrevAppDir;" & @CRLF)
	FileWrite($hFileOpen, @TAB & "Result := (sPrevPath <> '');" & @CRLF)
	FileWrite($hFileOpen, "end;" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "// Check if " & $sProgName & "'s settings exist." & @CRLF)
	FileWrite($hFileOpen, "function SettingsExistCheck(): Boolean;" & @CRLF)
	FileWrite($hFileOpen, "begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & "if FileExists(ExpandConstant('{userappdata}\" & $sCompanyName & "\" & $sProgShortName & "\" & $sIniFilBaseName & "')) then begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & "Log('Custom Code: Settings are present');" & @CRLF)
	FileWrite($hFileOpen, @TAB & "Result := True;" & @CRLF)
	FileWrite($hFileOpen, @TAB & "end" & @CRLF)
	FileWrite($hFileOpen, @TAB & "else begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & @TAB & "Log('Custom Code: Settings are NOT present');" & @CRLF)
	FileWrite($hFileOpen, @TAB & @TAB & "Result := False;" & @CRLF)
	FileWrite($hFileOpen, @TAB & "end;" & @CRLF)
	FileWrite($hFileOpen, "end;" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "function ShouldSkipPage(PageID: Integer): Boolean;" & @CRLF)
	FileWrite($hFileOpen, "begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & "// Hide the license page if IsUpgrade()" & @CRLF)
	FileWrite($hFileOpen, @TAB & "if IsUpgrade() and (PageID = wpLicense) then" & @CRLF)
	FileWrite($hFileOpen, @TAB & "Result := True;" & @CRLF)
	FileWrite($hFileOpen, "end;" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "procedure CleanUpSettings();" & @CRLF)
	FileWrite($hFileOpen, "begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & "DeleteFile(ExpandConstant('{userappdata}\" & $sCompanyName & "\" & $sProgShortName & "\" & $sIniFilBaseName & "'));" & @CRLF)
	FileWrite($hFileOpen, @TAB & "RemoveDir(ExpandConstant('{userappdata}\" & $sCompanyName & "\" & $sProgShortName & "'));" & @CRLF)
	FileWrite($hFileOpen, "end;" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "procedure CurPageChanged(CurPageID: Integer);" & @CRLF)
	FileWrite($hFileOpen, "begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & "if CurPageID = wpSelectTasks then" & @CRLF)
	FileWrite($hFileOpen, @TAB & @TAB & "WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall)" & @CRLF)
	FileWrite($hFileOpen, @TAB & "else if CurPageID = wpFinished then" & @CRLF)
	FileWrite($hFileOpen, @TAB & @TAB & "WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish);" & @CRLF)
	FileWrite($hFileOpen, "end;" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "procedure CurStepChanged(CurStep: TSetupStep);" & @CRLF)
	FileWrite($hFileOpen, "begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & "if CurStep = ssInstall then begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & "if IsTaskSelected('reset_settings') then" & @CRLF)
	FileWrite($hFileOpen, @TAB & @TAB & "CleanUpSettings();" & @CRLF)
	FileWrite($hFileOpen, @TAB & "end;" & @CRLF)
	FileWrite($hFileOpen, "end;" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);" & @CRLF)
	FileWrite($hFileOpen, "begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & "// When uninstalling, ask the user to delete " & $sProgName & "'s settings." & @CRLF)
	FileWrite($hFileOpen, @TAB & "if CurUninstallStep = usUninstall then begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & @TAB & "if SettingsExistCheck() then begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & @TAB & @TAB & "if SuppressibleMsgBox(CustomMessage('msg_DeleteSettings'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2, IDNO) = IDYES then" & @CRLF)
	FileWrite($hFileOpen, @TAB & @TAB & @TAB & "CleanUpSettings();" & @CRLF)
	FileWrite($hFileOpen, @TAB & @TAB & "end;" & @CRLF)
	FileWrite($hFileOpen, @TAB & "end;" & @CRLF)
	FileWrite($hFileOpen, "end;" & @CRLF)
	FileWrite($hFileOpen, "" & @CRLF)
	FileWrite($hFileOpen, "procedure InitializeWizard();" & @CRLF)
	FileWrite($hFileOpen, "begin" & @CRLF)
	FileWrite($hFileOpen, @TAB & "WizardForm.SelectTasksLabel.Hide;" & @CRLF)
	FileWrite($hFileOpen, @TAB & "WizardForm.TasksList.Top    := 0;" & @CRLF)
	FileWrite($hFileOpen, @TAB & "WizardForm.TasksList.Height := PageFromID(wpSelectTasks).SurfaceHeight;" & @CRLF)
	FileWrite($hFileOpen, "end;" & @CRLF)

	FileClose($hFileOpen)

	IniWrite($sSolutionIniPath, "Environment", "InstallScriptPath", $sScriptFullPath)
	IniWrite($sSolutionIniPath, "Environment", "InstallOutputPath", $sOutputFullPath)

EndFunc   ;==>_GenerateInstallationScript


Func _GetDestDirFromString($sSourceName)

	Local $sReturn = ""

	If StringInStr($sSourceName, "\") Then
		Local $aFilesSplt = StringSplit($sSourceName, "\")
		For $x = 1 To $aFilesSplt[0] - 1
			$sReturn &= "\" & $aFilesSplt[$x]
		Next
	EndIf

	Return $sReturn

EndFunc   ;==>_GetDestDirFromString


Func _ProcessAutoItScript($sAu3ScriptIn, $sOutScript, $bIsUDF = False)

	Local $hScriptOpen = FileOpen($sAu3ScriptIn, $FO_READ)
	If $hScriptOpen = -1 Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[70], "ERROR"))
		_Logging_EditWrite(StringFormat("^ '%s'", $sAu3ScriptIn))
		Return SetError(1, 0, False)
	EndIf

	Local $sScriptRead = FileRead($hScriptOpen)
	If $bIsUDF = True Then
		$sScriptRead = StringReplace($sScriptRead, "..\..\..\Includes\", "..\Includes\")
	Else
		$sScriptRead = StringReplace($sScriptRead, "..\..\Includes\", "Includes\")
	EndIf
	; Close the handle returned by FileOpen.
	FileClose($hScriptOpen)

	FileDelete($sOutScript)
	If Not FileWrite($sOutScript, $sScriptRead) Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[71], "ERROR"))
		_Logging_EditWrite(StringFormat("^ '%s'", $sOutScript))
		Return SetError(3, 0, False)
	EndIf

	Return SetError(0, 0, True)

EndFunc   ;==>_ProcessAutoItScript


Func _CreateUpdateFiles($sSolutionIniPath, $iRow, $iCol)

	Local $sProgShortName = $g_aEnvironment[5][1]
	Local $sProgVersion = $g_aEnvironment[9][1]
	Local $sProgBuild = $g_aEnvironment[12][1]
	Local $sUpdateURL = IniRead($sSolutionIniPath, "Links", "UpdateURL", "https://rizone.tech/2Eoo9O1")
	Local $sUpdateFile = $g_sUpdateRoot & "\" & $sProgShortName & ".ru"
	Local $sUpdateSetupFile = $g_sUpdateRoot & "\" & $sProgShortName & ".rus"
	Local $iIniError = 1, $iFileWriteError = 1

	_Logging_Start("Creating update files.")
	_StartSoloProcess($iRow, $iCol)

	$iIniError = IniWrite($sUpdateFile, "Update", "LatestBuild", $sProgBuild)
	_UpdateSoloProcess($iRow, $iCol, 30)
	$iIniError = IniWrite($sUpdateFile, "Update", "UpdateURL", $sUpdateURL)
	_UpdateSoloProcess($iRow, $iCol, 60)

	If $iIniError = 0 Then
		_Logging_EditWrite(_Logging_SetLevel(StringFormat("Could not write to '%s'", $sUpdateFile), "ERROR"))
	Else
		_Logging_EditWrite(StringFormat("Successfully created '%s'", $sUpdateFile))
	EndIf

	; Open the file for writing (append to the end of a file) and store the handle to a variable.
	Local $hSUFileOpen = FileOpen($sUpdateSetupFile, $FO_OVERWRITE)
	If $hSUFileOpen = -1 Then
		_Logging_EditWrite(_Logging_SetLevel("Could not open Setup update file.", "ERROR"))
		Return False
	EndIf

	If FileWrite($hSUFileOpen, $sProgVersion) = 0 Then
		_Logging_EditWrite(_Logging_SetLevel(StringFormat("Could not write to '%s'", $sUpdateSetupFile), "ERROR"))
	Else
		_Logging_EditWrite(StringFormat("Successfully created '%s'", $sUpdateSetupFile))
	EndIf

	_UpdateSoloProcess($iRow, $iCol, 90)
	FileClose($hSUFileOpen)

	_Logging_FinalMessage("")
	_UpdateSoloProcess($iRow, $iCol, 100)

EndFunc


Func _StartSoloProcess($iRow, $iCol)

	GUICtrlSetImage($g_aBuild[$iRow][$iCol][0], $g_sProcessSim, 0)

EndFunc   ;==>_StartSoloProcess


Func _UpdateSoloProcess($iRow, $iCol, $iPerc)

	Local $aPbPos = ControlGetPos($g_hCoreGui, "", $g_aBuild[$iRow][$iCol][5])
	Local $iVisualError = $g_iComIconStart + 4

	If $iPerc > 0 Then
		_ProgressBar_DrawSizeFromPercentage($g_aBuild[$iRow][$iCol][6], $iPerc, _
			$aPbPos[0], $g_aBuild[$iRow][$iCol][4], $aPbPos[2], 1)
	EndIf

	If $iPerc = 100 Then

		If $g_SoloProcess = False Then
			GUICtrlSetState($g_aBuild[$iRow][$iCol][1], $GUI_UNCHECKED)
		EndIf

		If $g_iLoggingErrors > 0 Then
			$iVisualError = $g_iComIconStart + 5
			GUICtrlSetBkColor($g_aBuild[$iRow][$iCol][6], 0xC80B0B)
		Else
			$iVisualError = $g_iComIconStart + 4
		EndIf

		Local $iIcoFinalIndex = ($iVisualError - $g_iComIconStart)
		GUICtrlSetImage($g_aBuild[$iRow][$iCol][0], $g_aCommIcons[$iIcoFinalIndex], $iVisualError)

		Sleep(1000)

		If $g_SoloProcess = True Then

			Local $iXz = ($iRow + 11) + ($iCol * 4)

			_ResetProgress($iRow, $iCol)
			GUICtrlSetImage($g_aBuild[$iRow][$iCol][0], $g_aCommIcons[$iXz], $g_iComIconStart + $iXz)

		EndIf

	EndIf

EndFunc   ;==>_UpdateSoloProcess


Func _ResetProgress($iRow, $iCol)

	Local $aPbPos = ControlGetPos($g_hCoreGui, "", $g_aBuild[$iRow][$iCol][5])
	_ProgressBar_DrawSizeFromPercentage($g_aBuild[$iRow][$iCol][6], 2, _
				$aPbPos[0], $g_aBuild[$iRow][$iCol][4], $aPbPos[2], 1)

	GUICtrlSetState($g_aBuild[$iRow][$iCol][6], $GUI_HIDE)
	GUICtrlSetBkColor($g_aBuild[$iRow][$iCol][6], 0x3399FF)

EndFunc


Func _StartProcessing()

	GUICtrlSetState($g_hListSolutions, $GUI_DISABLE)
	GUICtrlSetState($g_BtnProcessAll, $GUI_DISABLE)
	GUICtrlSetState($g_hTabLogging, $GUI_SHOW)
	_SetAllOptionStates($GUI_DISABLE)

EndFunc   ;==>_StartProcessing


Func _EndProcesssing()

	GUICtrlSetState($g_hListSolutions, $GUI_ENABLE)
	GUICtrlSetState($g_BtnProcessAll, $GUI_ENABLE)

	If $g_SelectedSolution <> -1 Then
		_GUICtrlListView_SetItemSelected($g_hListSolutions, $g_SelectedSolution)
		_SetModules($g_SelectedSolution)
	EndIf

EndFunc   ;==>_EndProcesssing()


Func _ProcessCheckedCount()

	Local $iCount = 0

	For $iBr = 0 To $CNT_BUILD - 1
		If GUICtrlRead($g_aBuild[$iBr][0][1]) = $GUI_CHECKED Then
			$iCount += 1
		EndIf
	Next

	For $iDr = 0 To $CNT_DISTRIBUTE - 1
		If GUICtrlRead($g_aBuild[$iDr][0][1]) = $GUI_CHECKED Then
			$iCount += 1
		EndIf
	Next

	Return $iCount

EndFunc   ;==>_ProcessCheckedCount

#EndRegion "Processing"


#Region "General Functions"

Func _GetInstallSize($sSolutionIniPath, $sSolutionRoot)

	Local $aFileList = IniReadSection($sSolutionIniPath, "Distribute")
	Local $iReturnSize = 0, $iCurrSize

    ; Check if an error occurred.
    If Not @error Then
        For $iF = 1 To $aFileList[0][0]
			$iReturnSize += FileGetSize($sSolutionRoot & Chr(92) & $aFileList[$iF][1])
        Next
    EndIf

	Return $iReturnSize

EndFunc

#EndRegion "General Functions"


#Region "Create new Solution"

Func _CreateNewSolutionDlg()

	; GUICtrlSetState($g_MenuCreateSln, $GUI_DISABLE)
	; WinSetTrans($g_ReBarCoreGui, Default, 200)

	$g_GuiCreateSln = GUICreate("Create New Solution",650, 550, -1, -1, BitOR($WS_CAPTION, $WS_POPUPWINDOW))
	; GUISetIcon($g_ReBarResFugue, 140)
	; GUISetFont($g_ReBarFontSize, 400, -1, $g_ReBarFontName, $g_GuiCreateSln, $CLEARTYPE_QUALITY)

	; Local $snSolutionName = IniRead($g_ReBarPathIni, "Solution", "SolutionName", "ReBar")

	GUICtrlCreateTab(10, 10, 480, 450)

	GUICtrlCreateTabItem(" Program ")
	GUICtrlCreateGroup("Solution", 20, 50, 455, 210)
	GUICtrlSetFont(-1, 10, 700, 2)
	GUICtrlCreateLabel("Solution Name", 30, 80, 220, 18)
	; $NSD_NAME = GUICtrlCreateInput($snSolutionName, 30, 98, 410, 20)
	GUICtrlCreateLabel("Program Name", 30, 123, 220, 18)
	; $NSD_PROG_NAME = GUICtrlCreateInput("", 30, 141, 410, 20)
	GUICtrlCreateLabel("Program Description", 30, 166, 220, 18)
	; $NSD_PROG_DESC = GUICtrlCreateInput("", 30, 184, 410, 20)
	GUICtrlCreateLabel("Start Version", 30, 209, 220, 18)
	GUICtrlCreateInput("", 30, 227, 30, 20)
	GUICtrlCreateInput("", 65, 227, 30, 20)
	GUICtrlCreateInput("", 100, 227, 30, 20)
	GUICtrlCreateInput("", 135, 227, 60, 20)
	GUICtrlCreateLabel("Product Version", 250, 209, 220, 18)
	GUICtrlCreateInput("", 250, 227, 130, 20)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
	GUICtrlCreateGroup("Icon", 20, 270, 94, 140)
	GUICtrlSetFont(-1, 10, 700, 2)
	GUICtrlCreateIcon(@ScriptFullPath, 99, 35, 295, 64, 64)
	GUICtrlCreateButton("Browse", 30, 365, 74, 30)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
	GUICtrlCreateGroup("Compile Options", 130, 270, 345, 60)
	GUICtrlSetFont(-1, 10, 700, 2)
	GUICtrlCreateCheckbox(" Compile X86 Version", 140, 295, 160, 20)
	GUICtrlCreateCheckbox(" Compile X64 Version", 300, 295, 160, 20)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
	GUICtrlCreateTabItem("") ; end tabitem definition

	;$NSD_BTNCREATE = GUICtrlCreateButton("Create", 285, 510, 200, 35)
	;GUICtrlSetOnEvent($NSD_BTNCREATE, "_CreateNewSolution")

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseNewSolutionDialog", $g_GuiCreateSln)

	GUISetState(@SW_SHOW, $g_GuiCreateSln)

EndFunc   ;==>_CreateNewSolutionDialog


Func _CloseNewSolutionDialog()

	; GUICtrlSetState($g_MenuCreateSln, $GUI_ENABLE)
	GUIDelete($g_GuiCreateSln)
	; WinSetTrans($g_hCoreGui, Default, 255)

EndFunc   ;==>_CloseNewSolutionDialog


Func _CreateNewSolution()

;~ 	Local $sAu3ScriptIn = @ScriptDir & "\Concrete\ReBar\ReBar.au3"
;~ 	Local $sOldUseX64 = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_UseX64")
;~ 	Local $sOldBOrP = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Version")
;~ 	Local $sOldOutFile = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_OutFile")
;~ 	Local $sOldOutFileX64 = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_OutFile_X64")
;~ 	Local $sOldProgramName = _AutoIt3Script_GetDirectiveValue($sAu3ScriptIn, "#AutoIt3Wrapper_Res_Comment")

;~ 	Local $sNewSolName = GUICtrlRead($NSD_NAME)

;~ 	Local $hSolutionOpen = FileOpen($sAu3ScriptIn, $FO_READ)
;~ 	If $hSolutionOpen = -1 Then
;~ 		Return SetError(1, 0, 0)
;~ 	EndIf

;~ 	Local $sSolutionRead = FileRead($hSolutionOpen)
;~ 	;$sSolutionRead = StringReplace($sScriptRead, "..\..\Includes\ReBar_", "Includes\ReBar_")

;~ 	; Close the handle returned by FileOpen.
;~ 	FileClose($hSolutionOpen)

;~ 	Local $sOutputDir = @ScriptDir & "\Concrete\" & $sNewSolName
;~ 	Local $sOutputSol = $sOutputDir & "\" & $sNewSolName & ".au3"
;~ 	_DistributeDirectory($sOutputDir)


;~ 	If Not FileWrite($sOutputSol, $sSolutionRead) Then
;~ 		Return SetError(1, 0, 0)
;~ 	EndIf

;~ 	Return SetError(0, 0, 0)

EndFunc   ;==>_CreateNewSolution


#EndRegion "Create new Solution"