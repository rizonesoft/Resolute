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
#AutoIt3Wrapper_Icon=Doors\Themes\Icons\WinRepair.ico			;~ Filename of the Ico file to use for the compiled exe
#AutoIt3Wrapper_OutFile_Type=exe								;~ exe=Standalone executable (Default); a3x=Tokenised AutoIt3 code file
#AutoIt3Wrapper_OutFile=WinRepair.exe							;~ Target exe/a3x filename.
#AutoIt3Wrapper_OutFile_X64=WinRepair_X64.exe					;~ Target exe filename for X64 compile.
;#AutoIt3Wrapper_Compression=4									;~ Compression parameter 0-4  0=Low 2=normal 4=High. Default=2
;#AutoIt3Wrapper_UseUpx=Y										;~ (Y/N) Compress output program.  Default=Y
;#AutoIt3Wrapper_UPX_Parameters=								;~ Override the default settings for UPX.
#AutoIt3Wrapper_Change2CUI=N									;~ (Y/N) Change output program to CUI in stead of GUI. Default=N
#AutoIt3Wrapper_Compile_both=Y									;~ (Y/N) Compile both X86 and X64 in one run. Default=N
;===============================================================================================================
; Target Program Resource info
;===============================================================================================================
#AutoIt3Wrapper_Res_Comment=Complete Windows Repair					;~ Comment field
#AutoIt3Wrapper_Res_Description=Complete Windows Repair			    ;~ Description field
#AutoIt3Wrapper_Res_Fileversion=1.0.0.339
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y  					;~ (Y/N/P) AutoIncrement FileVersion. Default=N
#AutoIt3Wrapper_Res_FileVersion_First_Increment=N					;~ (Y/N) AutoIncrement Y=Before; N=After compile. Default=N
#AutoIt3Wrapper_Res_HiDpi=N                      					;~ (Y/N) Compile for high DPI. Default=N
#AutoIt3Wrapper_Res_ProductVersion=5             					;~ Product Version
#AutoIt3Wrapper_Res_Language=2057									;~ Resource Language code . Default 2057=English (United Kingdom)
#AutoIt3Wrapper_Res_LegalCopyright=© 2018 Rizonesoft				;~ Copyright field
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
#AutoIt3Wrapper_Res_Field=ProductName|Complete Windows Repair
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
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\WinRepairH.ico					; 201

#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\logging\Information.ico			; 202
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\logging\Complete.ico			; 203
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\logging\Cross.ico				; 204
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\logging\Exclamation.ico			; 205
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\logging\Smiley-Glass.ico		; 206
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\logging\Skull.ico				; 207
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\logging\Snowman.ico				; 208

#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Update.ico						; 209
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Error.ico						; 210

#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Dialogs\Check.ico				; 211
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Dialogs\Error.ico				; 212
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Dialogs\Gear.ico				; 213
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Dialogs\Information.ico			; 214
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Dialogs\Love.ico				; 215

#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\PayPal.ico				; 216
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\PayPalH.ico				; 217
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\sa.ico					; 218
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\saH.ico					; 219
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\Facebook.ico				; 220
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\FacebookH.ico				; 221
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\Twitter.ico				; 222
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\TwitterH.ico				; 223
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\GooglePlus.ico			; 224
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\GooglePlusH.ico			; 225
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\GitHub.ico				; 226
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\About\GitHubH.ico				; 227

#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Power\Power-01.ico				; 228
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Power\Power-02.ico				; 229
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Power\Power-03.ico				; 230
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Power\Power-04.ico				; 231
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Power\Power-05.ico				; 232
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Power\Power-06.ico				; 233

#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\af.ico					; 234
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\ar.ico					; 235
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\bg.ico					; 236
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\cs.ico					; 237
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\da.ico					; 238
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\de.ico					; 239
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\el.ico					; 240
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\en.ico					; 241
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\es.ico					; 242
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\fr.ico					; 243
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\hi.ico					; 244
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\hr.ico					; 245
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\id.ico					; 246
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\is.ico					; 247
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\it.ico					; 248
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\iw.ico					; 249
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\ja.ico					; 250
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\ko.ico					; 251
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\nl.ico					; 252
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\no.ico					; 253
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\pl.ico					; 254
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\pt.ico					; 255
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\ro.ico					; 256
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\ru.ico					; 257
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\sk.ico					; 258
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\sv.ico					; 259
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\th.ico					; 260
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\tr.ico					; 261
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\vi.ico					; 262
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Flags\zh-CN.ico					; 263

#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Run.ico					; 264
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Complete.ico			; 265
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Cross.ico				; 266
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Note.ico				; 267
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Impact_01.ico			; 268
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Impact_02.ico			; 269
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Impact_03.ico			; 270
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Impact_04.ico			; 271

#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\System_01.ico			; 272
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_00.ico			; 273
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_01.ico			; 274
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_02.ico			; 275
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_03.ico			; 276
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_04.ico			; 277
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_05.ico			; 278
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_06.ico			; 279
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_07.ico			; 280
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_08.ico			; 281
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_09.ico			; 282
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_10.ico			; 283
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_11.ico			; 284
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Repairs\Internet_12.ico			; 285

#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Menus\Update.ico				; 286
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Menus\Home.ico					; 287
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Menus\Mail.ico					; 288
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Menus\GitHub.ico				; 289
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Menus\About.ico					; 290
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Menus\Logbook.ico				; 291
#AutoIt3Wrapper_Res_Icon_Add=Doors\Themes\Icons\Menus\Close.ico					; 292

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
#include <Process.au3>
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
#include "..\..\Includes\ProgressBar.au3"
#include "..\..\Includes\Registry.au3"
#include "..\..\Includes\Splash.au3"
#include "..\..\Includes\StringEx.au3"
#include "..\..\Includes\Update.au3"
#include "..\..\Includes\Versioning.au3"

#include "UDF\Localization.au3"


;~ Constants
Global Const $CNT_MENUICONS		= 8
Global Const $CNT_LOGICONS		= 7

;~ General Settings
Global $g_sCompanyName			= "Rizonesoft"
Global $g_sProgShortName		= "WinRepair"
Global $g_sProgShortName_X64	= $g_sProgShortName & "_X64"
Global $g_sProgName				= "Complete Windows Repair"
Global $g_iSingleton			= True
Global $g_iShowSubErrors		= False

;~ Links
Global $g_sUrlCompHomePage		= "https://goo.gl/m4Bhqe|www.rizonesoft.com"							; https://www.rizonesoft.com
Global $g_sUrlContact			= "https://goo.gl/X1kR2a|www.rizonesoft.com/contact"					; https://www.rizonesoft.com/contact
Global $g_sUrlDownloads			= "https://goo.gl/BWhZ4G|www.rizonesoft.com/downloads"					; https://www.rizonesoft.com/downloads/
Global $g_sUrlFacebook			= "https://goo.gl/o1wRdC|Facebook.com/rizonesoft"						; https://www.facebook.com/rizonesoft
Global $g_sUrlTwitter			= "https://goo.gl/Rcc5Wz|Twitter.com/Rizonesoft"						; https://twitter.com/Rizonesoft
Global $g_sUrlGooglePlus		= "https://goo.gl/oNirJT|Plus.google.com/+Rizonesoftsa" 				; https://plus.google.com/+Rizonesoftsa/posts
Global $g_sUrlRSS				= "https://goo.gl/s1kUi4|www.rizonesoft.com/feed"						; https://www.rizonesoft.com/feed
Global $g_sUrlPayPal			= "https://goo.gl/WkkaUm|PayPal.me/rizonesoft"							; https://www.paypal.me/rizonesoft
Global $g_sUrlGitHub			= "https://goo.gl/xSVA2p|GitHub.com/rizonesoft/SDK"						; https://github.com/rizonesoft/SDK
Global $g_sUrlGitHubIssues		= "https://goo.gl/AYwYWv|GitHub.com/rizonesoft/SDK/issues"				; https://github.com/rizonesoft/SDK/issues
Global $g_sUrlSA				= "https://goo.gl/Fn6UKQ|Wikipedia.org/wiki/South_Africa"				; https://en.wikipedia.org/wiki/South_Africa
Global $g_sUrlProgPage			= "https://goo.gl/2oGi56|www.rizonesoft.com/downloads/rizonesoft-sdk/"	; https://www.rizonesoft.com/downloads/rizonesoft-sdk/

;~ Path Settings
Global $g_sWorkingDir		= @ScriptDir & "\Doors" ;~ Working Directory
Global $g_sRootDir			= @ScriptDir & "\Doors" ;~ Root Directory
Global $g_sPathIni			= $g_sWorkingDir & "\" & $g_sProgShortName & ".ini" ;~ Full Path to the Configuaration file
Global $g_sAppDataRoot		= @AppDataDir & "\" & $g_sCompanyName & "\" & $g_sProgShortName
Global $g_sThemesDir		= $g_sRootDir & "\Themes" ;~ Themes Directory
Global $g_sDocsDir			= $g_sRootDir & "\Documents\" & $g_sProgShortName ;~ Documentation Directory
Global $g_sDocHelpFile		= $g_sDocsDir & "\" & $g_sProgShortName & ".chm"
Global $g_sDocChanges		= $g_sDocsDir & "\Changes.txt"
Global $g_sDocLicense		= $g_sDocsDir & "\License.txt"
Global $g_sDocReadme		= $g_sDocsDir & "\Readme.txt"
Global $g_sDataStore 		= @WindowsDir & "\SoftwareDistribution\DataStore"
Global $g_sDataStoreOld 	= @WindowsDir & "\SoftwareDistribution\DataStore.Old"
Global $g_sSoftDisDown		= @WindowsDir & "\SoftwareDistribution\Download"
Global $g_sSoftDisDownOld 	= @WindowsDir & "\SoftwareDistribution\Download.Old"
Global $g_sCatroot2 		= @SystemDir  & "\CatRoot2"
Global $g_sCatroot2Old 		= @SystemDir  & "\CatRoot2.Old"

; Configuration Settings
Global $g_iSetBackupData	= 0

;~ Language Settings
Global $g_sLanguageDir		= $g_sRootDir & "\Language\" & $g_sProgShortName
Global $g_sLanguageFile		= $g_sLanguageDir & "\af.ini"

;~ Resources
Global $g_iUpdateIconStart				= 209
Global $g_iDialogIconStart				= 211
Global $g_iAboutIconStart				= 216
Global $g_iPowerIconStart				= 228
Global $g_iRepairIconStart				= 264
Global $g_iMenuIconsStart				= 286
Global $g_aCoreIcons[3]
Global $g_iSizeIcon						= 48
Global $g_aLognIcons[$CNT_LOGICONS]
Global $g_aMenuIcons[$CNT_MENUICONS]

;~ Logging Settings
Global $g_sLoggingRoot		= $g_sWorkingDir & "\Logging\" & $g_sProgShortName
Global $g_sLoggingPath		= $g_sLoggingRoot & "\" & $g_sProgShortName & ".log"
Global $g_sLogIpResetPath	= $g_sLoggingRoot & "\IP_Reset.log"
Global $g_GuiLogBoxHeight	= 110
Global $g_iLogIconStart		= -202
Global $g_iUpdateSubStatus	= True

;~ Cache Settings
Global $g_sCacheRoot		= $g_sWorkingDir & "\Cache\" & $g_sProgShortName
Global $g_iEnableCache		= 1

;~ Splash Page Settings
Global $g_SplashAnimation 	= $g_sThemesDir & "\Processing\32\Stroke.ani"
Global $g_iSplashDelay		= 100

;~ Update Notification Settings
Global $g_sUpdateAnimation	= $g_sThemesDir & "\Processing\" & $g_iSizeIcon & "\Globe.ani"
Global $g_sRemoteUpdateFile	= "https://www.rizonesoft.com/update/" & $g_sProgShortName & ".ru"
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
Global $g_iCoreGuiWidth		= 750
Global $g_iCoreGuiHeight	= 578
Global $g_iMsgBoxTimeOut	= 60

;~ About Dialog
Global $g_sAboutCredits		= "Derick Payne (Rizonesoft), Brian J Christy (Beege), " & _
							"G Sandler (MrCreatoR), Holger Kotsch, KaFu, LarsJ, nickston, ProgAndy, Yashied"
Global $g_sProgramTitle = _GUIGetTitle($g_sProgName)	;~ Get Program Ttile, including version.
Global $g_hCoreGui										;~ Main GUI
Global $g_hGuiIcon										;~ Main Icon
Global $g_AniUpdate
Global $g_hMenuFile, $g_hMenuFileLog
Global $g_hMenuHelp, $g_hUpdateMenuItem
Global $g_hMenuDebug
Global $g_OldSystemParam								;~ Used when resizing the main GUI
Global $g_hSubHeading
Global $g_hListRepairs
Global $g_hImgRepairs
Global $g_hBtnProcess
Global $g_hBtnProcessAll
Global $g_hProgressSolo
Global $g_hProgressAll
Global $g_hComboPower
Global $g_hIconPower
Global $g_hTabLogging
Global $g_iSelectedRepair = -1
Global $g_IntExplVersion
Global $g_iCancel, $g_iSoloProcess = True
Global $g_iRepairCount = 0
Global $g_iRebootRequired = False
Global $g_iResetWinsock = True
Global $g_iClearWinUpdate = True
Global $g_iResetProxy = True
Global $g_iResetFirewall = True


_Localization_Messages()   		;~ Load Message Language Strings
If _Singleton($g_sProgramTitle, 1) = 0 And $g_iSingleton = True Then
	MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, $g_aLangMessages[3], $g_aLangMessages[4], $g_iMsgBoxTimeOut)
	Exit
EndIf


If @OSVersion = "WIN_2000" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then
	Local $iMsgBoxResult = MsgBox($MB_YESNO + $MB_ICONERROR + $MB_TOPMOST, $g_aLangMessages[3], StringFormat($g_aLangMessages[5], _
				_Link_Split($g_sUrlContact, 2)), $g_iMsgBoxTimeOut)
	Switch $iMsgBoxResult
		Case $IDYES
			ShellExecute(_Link_Split($g_sUrlContact))
			_TerminateProgram()
		Case -1, $IDNO
			_TerminateProgram()
	EndSwitch
Else

	If Not @AutoItX64 And @OSArch = "X64" Then

		Local $s64BitExePath = @ScriptDir & "\" & $g_sProgShortName_X64 & ".exe"

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

		_Splash_Start($g_aLangMessages[7])
		_Splash_Update($g_aLangMessages[8], 2)
		_Localization_Messages()    ;~ Load Message Language Strings
		_Localization_Messages2()	;~ Load Custom Message Language Strings
		_Localization_Menus()		;~ Load Menu Language Strings
		_Localization_Custom()		;~ Load Custom Language Strings
		_Localization_About()		;~ Load About Language Strings
		_Localization_File()		;~ Load File Language Strings
		_Localization_Repair()		;~ Load Repair Options Language Strings
		_Localization_RepairInfo()
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

	Local Const $CNT_REPGROUPS = 18
	Local $aiRepLngStart[$CNT_REPGROUPS], $aiRepStart[$CNT_REPGROUPS], $aiRepCount[$CNT_REPGROUPS]

	Local $miFileOptions, $miLogOpenFile, $miLogOpenRoot, $miFileClose
	Local $miHelpHome, $miHelpDownloads, $miHelpContact, $miHelpGitHub, $miHelpDonate, $miHelpAbout
	Local $hHeading, $hBtnScanSysFiles

	$g_hCoreGui = GUICreate($g_sProgramTitle, $g_iCoreGuiWidth, $g_iCoreGuiHeight, -1, 25, $WS_OVERLAPPEDWINDOW)
	If Not @Compiled Then GUISetIcon($g_aCoreIcons[0])
	GUISetFont(8.5, 400, -1, "Verdana", $g_hCoreGui, $CLEARTYPE_QUALITY)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ShutdownProgram", $g_hCoreGui)

	GUIRegisterMsg($WM_GETMINMAXINFO, "WM_GETMINMAXINFO")
	GUIRegisterMsg($WM_EXITSIZEMOVE, "WM_EXITSIZEMOVE")
	GUIRegisterMsg($WM_SYSCOMMAND, "WM_SYSCOMMAND")
	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

	$g_hMenuFile = GUICtrlCreateMenu($g_aLangMenus[0])
	$g_hMenuHelp = GUICtrlCreateMenu($g_aLangMenus[5])
	$g_hMenuDebug = GUICtrlCreateMenu($g_aLangMenus[14])

	_GuiCtrlMenuEx_SetMenuIconBkColor(0xF0F0F0)
	_GuiCtrlMenuEx_SetMenuIconBkGrdColor(0xFFFFFF)

	$miFileOptions = _GuiCtrlMenuEx_CreateMenuItem("&Preferences", $g_hMenuFile, $g_aMenuIcons[7], $g_iDialogIconStart + 2)
	$g_hMenuFileLog = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[1], $g_hMenuFile)
	$miLogOpenFile = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[2], $g_hMenuFileLog, $g_aMenuIcons[5], $g_iMenuIconsStart + 5)
	$miLogOpenRoot = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[3], $g_hMenuFileLog)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuFile)
	$miFileClose = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[4], $g_hMenuFile, $g_aMenuIcons[6], $g_iMenuIconsStart + 6)

	$g_hUpdateMenuItem = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[6], $g_hMenuHelp, $g_aMenuIcons[0], $g_iMenuIconsStart)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpHome = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[7], $g_hMenuHelp, $g_aMenuIcons[1], $g_iMenuIconsStart + 1)
	$miHelpDownloads = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[9], $g_hMenuHelp)
	$miHelpContact = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[10], $g_hMenuHelp, $g_aMenuIcons[2], $g_iMenuIconsStart + 2)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpGitHub = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[11], $g_hMenuHelp, $g_aMenuIcons[3], $g_iMenuIconsStart + 3)
	$miHelpDonate = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[12], $g_hMenuHelp)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpAbout = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[13], $g_hMenuHelp, $g_aMenuIcons[4], $g_iMenuIconsStart + 4)

	GUICtrlSetOnEvent($miLogOpenFile, "_Logging_OpenFile")
	GUICtrlSetOnEvent($miLogOpenRoot, "_Logging_OpenDirectory")
	GUICtrlSetOnEvent($miFileClose, "_ShutdownProgram")

	GUICtrlSetOnEvent($g_hUpdateMenuItem, "_CheckForUpdates")
	GUICtrlSetOnEvent($miHelpHome, "_About_HomePage")
	GUICtrlSetOnEvent($miHelpDownloads, "_About_Downloads")
	GUICtrlSetOnEvent($miHelpContact, "_About_Contact")
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
	$hHeading = GUICtrlCreateLabel($g_sProgName & " " & _GetProgramVersion(1), $g_iSizeIcon + 22, 15, 330, 35)
	GUICtrlSetFont($hHeading, 12)
	$g_hSubHeading = GUICtrlCreateLabel($g_aLangCustom[0], $g_iSizeIcon + 22, 38, 400, 35)
	GUICtrlSetFont($g_hSubHeading, 10)
	GUICtrlSetColor($g_hSubHeading, 0x353535)

	$g_IntExplVersion = _GetInternetExplorerVersion()

	$aiRepLngStart[5] = 25
	$aiRepStart[5] = 0
	$aiRepCount[5] = 14

	$g_hListRepairs = GUICtrlCreateListView("", 10, 104, $g_iCoreGuiWidth - 200, 255)
	_GUICtrlListView_SetExtendedListViewStyle($g_hListRepairs, BitOR($LVS_EX_BORDERSELECT, _
			$LVS_EX_FLATSB, $LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, _
			$LVS_EX_SUBITEMIMAGES, $LVS_EX_DOUBLEBUFFER, $LVS_EX_CHECKBOXES, _
			$WS_EX_CLIENTEDGE, $LVS_EX_FLATSB, $LVS_EX_INFOTIP))
	;_GUICtrlListView_BeginUpdate($g_hListRepairs)

	$g_hImgRepairs = _GUIImageList_Create(16, 16, 5, 3)
	For $iRi = 0 To $aiRepCount[5] + 7
		_GUIImageList_AddIcon($g_hImgRepairs, @ScriptFullPath, 0 - $g_iRepairIconStart - $iRi)
	Next

	_GUICtrlListView_SetImageList($g_hListRepairs, $g_hImgRepairs, 1)
	_GUICtrlListView_AddColumn($g_hListRepairs, Chr(32) & $g_aLangRepair[0], 430)
	_GUICtrlListView_AddColumn($g_hListRepairs, Chr(32) & $g_aLangRepair[1], 150)
	_GUICtrlListView_AddColumn($g_hListRepairs, Chr(32) & $g_aLangRepair[6], 630)

	;~ Build Groups
	_GUICtrlListView_EnableGroupView($g_hListRepairs)
	;~ (01) --> Maintenance  				(02) --> Malware  		(03) --> System  		(04) --> Desktop  		(05) --> Explorer
	;~ (06) --> Internet and Networking  	(07) --> Hardware  		(08) --> Programs  		(09) --> Accociations  	(10) --> Security
	;~ (11) --> Performance  				(12) --> Miscellaneous  (13) --> Windows XP  	(14) --> Windows Vista 	(15) --> Windows 7
	;~ (16) --> Windows 8  					(17) --> Windows 8.1  	(18) --> Windows 10
	For $iG = 1 To $CNT_REPGROUPS
		_GUICtrlListView_InsertGroup($g_hListRepairs, -1, $iG,  $g_aLangRepair[$iG + 6])
	Next

	MsgBox(0, "", $g_aLangRepairInfo[1])
	For $iO = 0 To $aiRepCount[5] - 1

		Local $aOptionSplt = StringSplit($g_aLangRepair[$aiRepLngStart[5] + $iO], "|")
		_GUICtrlListView_AddItem($g_hListRepairs, Chr(32) & $aOptionSplt[1], 8 + $iO)
		_GUICtrlListView_AddSubItem($g_hListRepairs, $iO, $g_aLangRepair[2], 1, 4)

		If $aOptionSplt[0] > 1 Then
			_GUICtrlListView_SetItemText($g_hListRepairs, $iO, $g_aLangRepair[1 + $aOptionSplt[2]], 1)
			_GUICtrlListView_SetItemImage($g_hListRepairs, $iO, 3 + $aOptionSplt[2], 1)
		EndIf
		_GUICtrlListView_AddSubItem($g_hListRepairs, $iO, $g_aLangRepairInfo[$iO], 2, 3)
		If $aOptionSplt[0] > 2 Then
			_GUICtrlListView_SetItemGroupID($g_hListRepairs, 0 + $iO, $aOptionSplt[3])
		EndIf
		$g_iRepairCount += 1

	Next
	_GUICtrlListView_SetItemText($g_hListRepairs, $aiRepStart[5] + 5, Chr(32) & StringFormat($g_aLangRepair[$aiRepLngStart[5] + 5], $g_IntExplVersion))
	_GUICtrlListView_SetColumn($g_hListRepairs, 0, StringFormat($g_aLangRepair[0], $g_iRepairCount))

	_GUICtrlListView_EndUpdate($g_hListRepairs)
	_WinAPI_SetWindowTheme(GUICtrlGetHandle($g_hListRepairs), "Explorer")
	GUICtrlSetResizing($g_hListRepairs, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))

	GUICtrlCreateLabel($g_aLangCustom[2], 570, 104, 130, 22)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlSetFont(-1, 9)
	$g_hComboPower = GuiCtrlCreateCombo("", 570, 126, 130, 25)
	GUICtrlSetData($g_hComboPower, 	$g_aLangCustom[3] & "|" & $g_aLangCustom[4] & "|" & $g_aLangCustom[5] & "|" & _
									$g_aLangCustom[6] & "|" & $g_aLangCustom[7] & "|" & $g_aLangCustom[8], $g_aLangCustom[5])
	GUICtrlSetResizing($g_hComboPower, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlSetFont($g_hComboPower, 9)
	$g_hIconPower = GUICtrlCreateIcon(@ScriptFullPath, $g_iPowerIconStart, 700, 104, 48, 48)
	GUICtrlSetResizing($g_hIconPower, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlSetOnEvent($g_hComboPower, "_SetPower")

	$hBtnScanSysFiles = GUICtrlCreateButton($g_aLangCustom[9], 570, 170, 170, 35)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlCreateButton($g_aLangCustom[10], 570, 210, 170, 35)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))

	GUICtrlSetOnEvent($hBtnScanSysFiles, "_RunSystemFileScanner")

	$g_hBtnProcess = GUICtrlCreateButton("", 570, 325, 35, 35)
	GUICtrlSetResizing($g_hBtnProcess, BitOR($GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKSIZE))
	$g_hBtnProcessAll = GUICtrlCreateButton($g_aLangCustom[12], 605, 325, 135, 35)
	GUICtrlSetFont($g_hBtnProcessAll, 11, 400)
	GUICtrlSetResizing($g_hBtnProcessAll, BitOR($GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKSIZE))

	GUICtrlSetOnEvent($g_hBtnProcess, "_RunSelectedRepair")
	GUICtrlSetOnEvent($g_hBtnProcessAll, "_RunSelectedRepair")

	$g_hProgressSolo = GUICtrlCreateProgress(10, 365, $g_iCoreGuiWidth - 200, 18)
	GUICtrlSetResizing($g_hProgressSolo, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKHEIGHT))
	$g_hProgressAll = GUICtrlCreateProgress(570, 365, 170, 18)
	GUICtrlSetResizing($g_hProgressAll, BitOR($GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKSIZE))

	GUICtrlCreateTab(10, 393, $g_iCoreGuiWidth - 20, 155)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKSIZE))
	GUICtrlCreateTabItem(Chr(32) & $g_aLangCustom[13] & Chr(32))

	$g_hTabLogging = GUICtrlCreateTabItem(Chr(32) & $g_aLangCustom[14] & Chr(32))
	$g_hListStatus = GUICtrlCreateListView("", 20, $g_iCoreGuiHeight - $g_GuiLogBoxHeight - 38, _
			$g_iCoreGuiWidth - 40, $g_GuiLogBoxHeight, BitOR($LVS_REPORT, $LVS_NOCOLUMNHEADER))
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

	_Splash_Update("Setting Process Priority", 99)
	ProcessSetPriority(@ScriptName, 2)
	_SetProcessPriorityInfo()

	_Splash_Update("", 100)
	GUISetState(@SW_SHOW, $g_hCoreGui)
	AdlibRegister("_OnIconsHover", 65)
	AdlibRegister("_UptimeMonitor", 1000)

	If $g_iCheckForUpdates == 4 Then
		_SoftwareUpdateCheck()
	EndIf

	While 1
		Sleep(30)
	WEnd

EndFunc   ;==>_StartCoreGui


Func _TestLoggingSystem($sMessage, $iSleep)
	_Logging_EditWrite($sMessage)
	Sleep($iSleep)
EndFunc   ;==>_TestLoggingSystem


#Region "Events"

Func _OnIconsHover()

	Local $iCursor = GUIGetCursorInfo()
	If Not @error Then

		If $iCursor[4] = $g_hGuiIcon And $g_aCoreIcons[2] == 1 Then
			$g_aCoreIcons[2] = 0
			GUICtrlSetImage($g_hGuiIcon, $g_aCoreIcons[1], 99)
		ElseIf $iCursor[4] <> $g_hGuiIcon And $g_aCoreIcons[2] == 0 Then
			$g_aCoreIcons[2] = 1
			GUICtrlSetImage($g_hGuiIcon, $g_aCoreIcons[0], 201)
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
	$hWndListView = $g_hListRepairs
	If Not IsHWnd($g_hListRepairs) Then $hWndListView = GUICtrlGetHandle($g_hListRepairs)

	$tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	$hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	$iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
	$iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
		Case $hWndListView
			Switch $iCode
				Case $NM_CLICK ; Sent by a list-view control when the user clicks an item with the left mouse button
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
					$g_iSelectedRepair = DllStructGetData($tInfo, "Index")
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

	Else

		$g_aCoreIcons[0] = $g_sThemesDir & "\Icons\" & $g_sProgShortName & ".ico"
		$g_aCoreIcons[1] = $g_sThemesDir & "\Icons\" & $g_sProgShortName & "H.ico"

		$g_aLognIcons[0] = $g_sThemesDir & "\Icons\logging\Information.ico"
		$g_aLognIcons[1] = $g_sThemesDir & "\Icons\logging\Complete.ico"
		$g_aLognIcons[2] = $g_sThemesDir & "\Icons\logging\Cross.ico"
		$g_aLognIcons[3] = $g_sThemesDir & "\Icons\logging\Exclamation.ico"
		$g_aLognIcons[4] = $g_sThemesDir & "\Icons\logging\Smiley-Glass.ico"
		$g_aLognIcons[5] = $g_sThemesDir & "\Icons\logging\Skull.ico"
		$g_aLognIcons[6] = $g_sThemesDir & "\Icons\logging\Snowman.ico"

		$g_aMenuIcons[0] = $g_sThemesDir & "\Icons\Menus\Update.ico"
		$g_aMenuIcons[1] = $g_sThemesDir & "\Icons\Menus\Home.ico"
		$g_aMenuIcons[2] = $g_sThemesDir & "\Icons\Menus\Mail.ico"
		$g_aMenuIcons[3] = $g_sThemesDir & "\Icons\Menus\GitHub.ico"
		$g_aMenuIcons[4] = $g_sThemesDir & "\Icons\Menus\About.ico"
		$g_aMenuIcons[5] = $g_sThemesDir & "\Icons\Menus\Logbook.ico"
		$g_aMenuIcons[6] = $g_sThemesDir & "\Icons\Menus\Close.ico"
		$g_aMenuIcons[7] = $g_sThemesDir & "\Icons\Dialogs\Gear.ico"

	EndIf

	$g_aCoreIcons[2] = 1

EndFunc   ;==>_SetResources

#EndRegion "Resources"


#Region "Working Directories"

Func _ResetWorkingDirectories()

	$g_sPathIni = $g_sWorkingDir & "\" & $g_sProgShortName & ".ini"
	$g_sCacheRoot = $g_sWorkingDir & "\Cache\" & $g_sProgShortName
	$g_sLoggingRoot = $g_sWorkingDir & "\Logging\" & $g_sProgShortName
	$g_sLoggingPath = $g_sLoggingRoot & "\" & $g_sProgShortName & ".log"
	If $g_iEnableCache == 1 Then DirCreate($g_sCacheRoot)

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
	$g_iUptimeMonitor = Int(IniRead($g_sPathIni, "Donate", "Seconds", 0))
	$g_iDonateTime = Int(IniRead($g_sPathIni, "Donate", "DonateTime", 0))

EndFunc   ;==>_LoadConfiguration


Func _SaveConfiguration()

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


Func _SetPower()

	Local $iPower = 0

	Switch GuiCtrlRead($g_hComboPower)
		Case "Low"
			$iPower = 0
		Case "Below Normal"
			$iPower = 1
		Case "Normal"
			$iPower = 2
		Case "Above Normal"
			$iPower = 3
		Case "High"
			$iPower = 4
		Case "Realtime"
			$iPower = 5
	EndSwitch

	ProcessSetPriority(@ScriptName, $iPower)

	_SetProcessPriorityInfo()

EndFunc


Func _SetProcessPriorityInfo($PrName = @ScriptName)

	Local $iPID = ProcessExists($PrName) ;~ Will return the PID or 0 if the process isn't found.
	Local $iProcPriority = _ProcessGetPriority($iPID)
	For $xP = 0 To 5
		If $xP = $iProcPriority Then
			GUICtrlSetImage($g_hIconPower, @ScriptFullPath, $g_iPowerIconStart + $xP)
		EndIf
	Next
	Switch $iProcPriority
		Case 0
			GuiCtrlSetData($g_hComboPower, "Low")
		Case 1
			GuiCtrlSetData($g_hComboPower, "Below Normal")
		Case 2
			GuiCtrlSetData($g_hComboPower, "Normal")
		Case 3
			GuiCtrlSetData($g_hComboPower, "Above Normal")
		Case 4
			GuiCtrlSetData($g_hComboPower, "High")
		Case 5
			GuiCtrlSetData($g_hComboPower, "Realtime")
		Case Else
			GuiCtrlSetData($g_hComboPower, "Error")
	EndSwitch

EndFunc


#Region "Commands"

Func _RunSystemFileScanner()

	_Logging_Start("Scanning your system files")
	_Logging_EditWrite("^ This can take several minutes. Please do not close the command window!")
	ShellExecute("SFC", "/SCANNOW", "", "", @SW_SHOW)
	_Logging_FinalMessage("")

EndFunc

#EndRegion "Commands"


#Region "Processing"

Func _RunSelectedRepair()

	Local $iRepairCount = _GUICtrlListView_GetItemCount($g_hListRepairs)
	_SetCtrlStates($GUI_DISABLE)

	If @GUI_CtrlId = $g_hBtnProcess Then

		$g_iSoloProcess = True
		If $iRepairCount > 0 And $g_iSelectedRepair <> -1 Then
			_ProcessSelectedRepair($g_iSelectedRepair)
		EndIf

	ElseIf @GUI_CtrlId = $g_hBtnProcessAll Then

		Local $iRepairCheckedCount = 0, $iRepPos = 0

		If $iRepairCount > 0 Then

			$iRepairCheckedCount = _GetCheckedItemCount($g_hListRepairs)
			If $iRepairCheckedCount > 0 Then

				$g_iSoloProcess = False
				For $iS = 0 To $iRepairCount

					Local $iSelCount = _GUICtrlListView_GetItemChecked($g_hListRepairs, $iS)
					If $iSelCount = 1 Then
						_ProcessSelectedRepair($iS)
						$iRepPos += 1
						GUICtrlSetData($g_hProgressAll, Round(($iRepPos / $iRepairCheckedCount) * 100))
						; MsgBox(0, "", Round(($iRepPos / $iRepairCheckedCount) * 100))
					EndIf

				Next


			Else
				MsgBox(262176, $g_aLangMessages2[0], $g_aLangMessages2[1], 60)
			EndIf

		EndIf

		GUICtrlSetData($g_hSubHeading, $g_aLangCustom[15])
		_EndProcessing()
		$iRepPos = 0

	EndIf

EndFunc


Func _ProcessSelectedRepair($iAction)

	Switch $iAction
		Case 0
			_ResetTCPIP($iAction)
		Case 1
			_RepairWinsock($iAction)
		Case 2
			_ReleaseRenewIP($iAction)
		Case 3
			_FlushReDNS($iAction)
		Case 4
			_FlushARPCache($iAction)
		Case 5
			_RepairInternetExplorer($iAction)
		Case 6
			_ClearUpdateHistory($iAction)
		Case 7
			_RepairWindowsUpdate($iAction)
		Case 8
			_RepairCryptography($iAction)
		Case 9
			_ResetProxyServer($iAction)
		Case 10
			_ResetFirewall($iAction)
		Case 11
			_RestoreWindowsHosts($iAction)
		Case 12
			_RenewWinsClient($iAction)
	EndSwitch

EndFunc


Func _ResetTCPIP($iRow)

	; _RunCommand("netsh -c interface dump > C:\Users\derickp\Desktop\location.txt")

	_StartSoloProcess($iRow)
	_Logging_Start($g_aLangMessages2[14])
	If @OSVersion = "WIN_XP" And @OSVersion = "WIN_2003" Then
		_RunCommand("netsh interface ip reset " & Chr(34) & $g_sLogIpResetPath & Chr(34))
		_Logging_EditWrite(StringFormat($g_aLangMessages2[15], $g_sLogIpResetPath))
		GUICtrlSetData($g_hProgressSolo, 45)
		_Logging_EditWrite($g_aLangMessages2[16])
		_RunCommand("netsh interface reset all")
	Else
		GUICtrlSetData($g_hProgressSolo, 45)
		_Logging_EditWrite($g_aLangMessages2[16])
		_RunCommand("netsh interface ipv4 reset all")
	EndIf

	GUICtrlSetData($g_hProgressSolo, 90)
	_Logging_EditWrite($g_aLangMessages2[17])
	_RunCommand("netsh interface ipv6 reset all")
	GUICtrlSetData($g_hProgressSolo, 100)

	_Logging_FinalMessage()
	_EndSoloProcess($iRow)

EndFunc


Func _RepairWinsock($iRow, $IsInnerProcess = False)

	If Not $IsInnerProcess Then
		_StartSoloProcess($iRow)
		_Logging_Start($g_aLangMessages2[18])
			Sleep(250)
		GUICtrlSetData($g_hProgressSolo, 50)
	EndIf

	If @OSVersion = "WIN_XP" Then
		If @OSServicePack = "Service Pack 1" Then
			_Logging_EditWrite($g_aLangMessages2[19])
			RegDelete("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Winsock")
			RegDelete("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Winsock2")
		Else
			__ResetWinsock()
		EndIf
	Else
		__ResetWinsock()
	EndIf

	If Not $IsInnerProcess Then
		If $g_iSoloProcess Then _BootMessage()
		_Logging_FinalMessage($g_aLangMessages2[20])
		_EndSoloProcess($iRow)
	Else
		_Logging_EditWrite($g_aLangMessages2[20])
	EndIf

	$g_iResetWinsock = False
	$g_iRebootRequired = True

EndFunc


Func _ReleaseRenewIP($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start($g_aLangMessages2[23])
		Sleep(100)
	_Logging_EditWrite($g_aLangMessages2[24])
	GUICtrlSetData($g_hProgressSolo, 30)
	_RunCommand("ipconfig /release")
	_Logging_EditWrite($g_aLangMessages2[25])
	GUICtrlSetData($g_hProgressSolo, 60)
	_RunCommand("ipconfig /renew")

	If $g_iResetWinsock Then
		_Logging_EditWrite($g_aLangMessages2[26])
		GUICtrlSetData($g_hProgressSolo, 80)
		_RepairWinsock($iRow, True)
		If $g_iSoloProcess = True Then _BootMessage()
	EndIf

	_Logging_FinalMessage($g_aLangMessages2[27])
	_EndSoloProcess($iRow)

EndFunc


Func _FlushReDNS($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start($g_aLangMessages2[28])
	GUICtrlSetData($g_hProgressSolo, 30)
	_Logging_EditWrite($g_aLangMessages2[29])
	_RunCommand("ipconfig /flushdns")
	GUICtrlSetData($g_hProgressSolo, 60)
	_Logging_EditWrite($g_aLangMessages2[30])
	_RunCommand("ipconfig /registerdns")
	_Logging_FinalMessage($g_aLangMessages2[31])
	_EndSoloProcess($iRow)

EndFunc


Func _FlushARPCache($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start($g_aLangMessages2[32])
	GUICtrlSetData($g_hProgressSolo, 50)
	_RunCommand("netsh interface ip delete arpcache")
	_Logging_FinalMessage($g_aLangMessages2[33])
	_EndSoloProcess($iRow)

EndFunc


Func _RepairInternetExplorer($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start(StringFormat($g_aLangMessages2[34], $g_IntExplVersion))
	Sleep(250)
	GUICtrlSetData($g_hProgressSolo, 1)
	If ProcessExists("iexplore.exe") Then
		MsgBox(48, "Internet Explorer", $g_aLangMessages2[35])
		ProcessClose("iexplore.exe")
	EndIf

	Local $sIEDlls = "custsat.dll|D3DCompiler_47.dll|diagnosticshub.datawarehouse.dll|DiagnosticsHub_is.dll|DiagnosticsTap.dll|"& _
			"F12.dll|f12resources.dll|F12Tools.dll|hmmapi.dll|iedvtool.dll|" & _
			"ieproxy.dll|IEShims.dll|jsdbgui.dll|jsdebuggeride.dll|JSProfilerCore.dll|jsprofilerui.dll|" & _
			"memoryanalyzer.dll|msdbg2.dll|networkinspection.dll|pdm.dll|pdmproxy100.dll|perf_nt.dll|perfcore.dll|sqmapi.dll|timeline.dll|Timeline_is.dll"

	Local $aIEDlls = StringSplit($sIEDlls, "|")
	Local $sProcTemp, $iDllCount = 0, $iDllPerc = 0, $iPercChange = 0

	For $x = 1 To $aIEDlls[0]

		__RegisterProgramFilesDll("internet explorer\" & $aIEDlls[$x])

		$iDllCount += 1
		$iDllPerc = Int($iDllCount / $aIEDlls[0] * 35)

		If $iDllPerc <> $iPercChange Then
			GUICtrlSetData($g_hProgressSolo, Round($iDllPerc))
			$iPercChange = $iDllPerc
		EndIf

	Next

;~ Symptom: open in new tab/window not working
	GUICtrlSetData($g_hProgressSolo, 37)
	_Logging_EditWrite($g_aLangMessages2[36])
	__RegisterSystemDll("acelpdec.ax")
	__RegisterSystemDll("actxprxy.dll")
	GUICtrlSetData($g_hProgressSolo, 38)
	__RegisterSystemDll("asctrls.ocx")
	__RegisterSystemDll("browseui.dll")
	__RegisterSystemDll("browseui.dll", "/s /i")
	GUICtrlSetData($g_hProgressSolo, 39)
	__RegisterSystemDll("browsewm.dll")
	__RegisterSystemDll("cdfview.dll")
	__RegisterSystemDll("comcat.dll")
	GUICtrlSetData($g_hProgressSolo, 40)
	__RegisterSystemDll("comctl32.dll")
	__RegisterSystemDll("comctl32.dll", "/s /i")
	__RegisterSystemDll("comctl32.dll", "/s /i /n")
	GUICtrlSetData($g_hProgressSolo, 41)
	__RegisterSystemDll("corpol.dll")
	__RegisterSystemDll("CRSWPP.DLL")
	GUICtrlSetData($g_hProgressSolo, 42)
	__RegisterSystemDll("CRYPTDLG.DLL")
	__RegisterSystemDll("cryptdlg.dll")
	__RegisterSystemDll("cryptext.dll")
	__RegisterSystemDll("CSSEQCHK.DLL")
	GUICtrlSetData($g_hProgressSolo, 43)
	__RegisterSystemDll("danim.dll")
	__RegisterSystemDll("datime.dll")
	__RegisterSystemDll("Daxctle.ocx")
	GUICtrlSetData($g_hProgressSolo, 44)
	__RegisterSystemDll("dhtmled.ocx")
	__RegisterSystemDll("digest.dll", "/i /s")
	__RegisterSystemDll("digest.dll", "/s /i /n")
	GUICtrlSetData($g_hProgressSolo, 45)
	__RegisterSystemDll("directdb.dll")
	__RegisterSystemDll("dispex.dll")
	__RegisterSystemDll("DSSENH.DLL")
	GUICtrlSetData($g_hProgressSolo, 46)
	__RegisterSystemDll("dxmasf.dll")
	__RegisterSystemDll("dxtmsft.dll")
	__RegisterSystemDll("dxtrans.dll")
	__RegisterSystemDll("elshyph.dll")

;~ Symptom: Add-Ons-Manager menu entry is present but nothing happens
	GUICtrlSetData($g_hProgressSolo, 47)
	_Logging_EditWrite($g_aLangMessages2[37])
	__RegisterSystemDll("extmgr.dll")
	GUICtrlSetData($g_hProgressSolo, 48)
	__RegisterSystemDll("FLUPL.OCX")
	__RegisterSystemDll("FPWPP.DLL")
	GUICtrlSetData($g_hProgressSolo, 49)
	__RegisterSystemDll("FTPWPP.DLL")
	__RegisterSystemDll("Gpkcsp.dll")
	__RegisterSystemDll("hhctrl.ocx")

;~ Simple HTML Mail API
	GUICtrlSetData($g_hProgressSolo, 50)
	_Logging_EditWrite($g_aLangMessages2[38])
	__RegisterSystemDll("hlink.dll")
	GUICtrlSetData($g_hProgressSolo, 51)
	__RegisterSystemDll("hmmapi.dll")

	__RegisterSystemDll("icardie.dll")
	__RegisterSystemDll("icmfilter.dll")
	__RegisterSystemDll("ieadvpack.dll")

;~ Group policy snap-in
	GUICtrlSetData($g_hProgressSolo, 52)
	_Logging_EditWrite($g_aLangMessages2[39])
	__RegisterSystemDll("ieaksie.dll")

;~ Smart Screen
	GUICtrlSetData($g_hProgressSolo, 53)
	_Logging_EditWrite($g_aLangMessages2[40])
	__RegisterSystemDll("ieapfltr.dll")

;~ IEAK Branding
	GUICtrlSetData($g_hProgressSolo, 54)
	_Logging_EditWrite($g_aLangMessages2[41])
	__RegisterSystemDll("iedkcs32.dll")

;~ Dev Tools
	GUICtrlSetData($g_hProgressSolo, 55)
	_Logging_EditWrite($g_aLangMessages2[42])
	__RegisterSystemDll("iedvtool.dll")
	__RegisterSystemDll("ieetwcollectorres.dll")
	__RegisterSystemDll("ieetwproxystub.dll")

;~ IE7 tabbed browser
	GUICtrlSetData($g_hProgressSolo, 56)
	__RegisterSystemDll("ieframe.dll", "/s /i /n")
	__RegisterSystemDll("iepeers.dll")

;~ Symptom: IE8 closes immediately on launch, missing from IE7
	GUICtrlSetData($g_hProgressSolo, 57)
	_Logging_EditWrite($g_aLangMessages2[43])
	__RegisterSystemDll("ieproxy.dll")
	__RegisterSystemDll("iernonce.dll")
	__RegisterSystemDll("iertutil.dll")
	__RegisterSystemDll("iesetup.dll", "/s /i")
	__RegisterSystemDll("iesysprep.dll")
	__RegisterSystemDll("system32\ieui.dll")

	__RegisterSystemDll("ils.dll")
	GUICtrlSetData($g_hProgressSolo, 58)
	__RegisterSystemDll("imgutil.dll")
	__RegisterSystemDll("inetcfg.dll")
	__RegisterSystemDll("inetcomm.dll")
	GUICtrlSetData($g_hProgressSolo, 59)
	__RegisterSystemDll("inetcpl.cpl", "/s /i")
	__RegisterSystemDll("inetcpl.cpl", "/s /i /n")
	GUICtrlSetData($g_hProgressSolo, 60)
	__RegisterSystemDll("initpki.dll", "/s /i:A")
	__RegisterSystemDll("inseng.dll", "/s /i")

	__RegisterSystemDll("javascriptcollectionagent.dll")
	__RegisterSystemDll("jscript.dll")
	__RegisterSystemDll("jscript9.dll")
	__RegisterSystemDll("jscript9diag.dll")
	__RegisterSystemDll("jsintl.dll")
	__RegisterSystemDll("jsproxy.dll")

	GUICtrlSetData($g_hProgressSolo, 61)
	__RegisterSystemDll("l3codecx.ax")
	__RegisterSystemDll("laprxy.dll")
	__RegisterSystemDll("licdll.dll")

;~ License Manager
	GUICtrlSetData($g_hProgressSolo, 62)
	_Logging_EditWrite($g_aLangMessages2[44])
	__RegisterSystemDll("licmgr10.dll")
	GUICtrlSetData($g_hProgressSolo, 63)
	__RegisterSystemDll("lmrt.dll")
	__RegisterSystemDll("migration\wininetplugin.dll")
	__RegisterSystemDll("mlang.dll")
	__RegisterSystemDll("mmefxe.ocx")
	GUICtrlSetData($g_hProgressSolo, 64)
	__RegisterSystemDll("mobsync.dll")
	__RegisterSystemDll("mpg4ds32.ax")
	__RegisterSystemDll("msapsspc.dll", "/SspcCreateSspiReg /s")

;~ Symptom: Javascript links don't work (Robin Walker) .NET hub file
	GUICtrlSetData($g_hProgressSolo, 65)
	_Logging_EditWrite($g_aLangMessages2[45])
	__RegisterSystemDll("mscoree.dll")
	__RegisterSystemDll("mscorier.dll")
	__RegisterSystemDll("mscories.dll")

	__RegisterSystemDll("msfeeds.dll")
	__RegisterSystemDll("msfeedsbs.dll")
	__RegisterSystemDll("mshtmldac.dll")

;~ VS Debugger
	GUICtrlSetData($g_hProgressSolo, 66)
	_Logging_EditWrite($g_aLangMessages2[46])
	__RegisterSystemDll("msdbg2.dll")
	GUICtrlSetData($g_hProgressSolo, 67)
	__RegisterSystemDll("msdxm.ocx")
	__RegisterSystemDll("mshta.exe")
	__RegisterSystemDll("mshtml.dll")
	GUICtrlSetData($g_hProgressSolo, 68)
	__RegisterSystemDll("mshtml.dll", "/s /i")
	__RegisterSystemDll("mshtmled.dll")
	__RegisterSystemDll("mshtmler.dll")
	__RegisterSystemDll("mshtmlmedia.dll")
	__RegisterSystemDll("msident.dll")
	GUICtrlSetData($g_hProgressSolo, 69)
	__RegisterSystemDll("msieftp.dll", "/s /i")
	__RegisterSystemDll("msls31.dll")
	__RegisterSystemDll("msnsspc.dll", "/SspcCreateSspiReg /s")
	__RegisterSystemDll("msoe.dll")
	GUICtrlSetData($g_hProgressSolo, 70)
	__RegisterSystemDll("msoeacct.dll")
	__RegisterSystemDll("msr2c.dll")
	__RegisterSystemDll("msrating.dll")
	GUICtrlSetData($g_hProgressSolo, 71)
	__RegisterSystemDll("MSTIME.DLL")
	__RegisterSystemDll("mstinit.exe /setup /s")
	__RegisterSystemDll("msxml.dll")
	GUICtrlSetData($g_hProgressSolo, 72)
	__RegisterSystemDll("oeimport.dll")
	__RegisterSystemDll("oemiglib.dll")

;~ Symptom: Printing problems, open in new window
	GUICtrlSetData($g_hProgressSolo, 73)
	_Logging_EditWrite($g_aLangMessages2[47])
	__RegisterSystemDll("ole32.dll")

;~ Symptom: Find on this page is blank
	GUICtrlSetData($g_hProgressSolo, 74)
	_Logging_EditWrite($g_aLangMessages2[48])
	__RegisterSystemDll("oleacc.dll")
	__RegisterSystemDll("occache.dll")
	__RegisterSystemDll("occache.dll", "/s /i")
	__RegisterSystemDll("oleaut32.dll")

;~ Process debug manager
	GUICtrlSetData($g_hProgressSolo, 75)
	_Logging_EditWrite($g_aLangMessages2[49])
	__RegisterSystemDll("plugin.ocx")
	__RegisterSystemDll("pngfilt.dll")
	GUICtrlSetData($g_hProgressSolo, 76)
	__RegisterSystemDll("POSTWPP.DLL")
	__RegisterSystemDll("proctexe.ocx")
	__RegisterSystemDll("regwizc.dll")
	GUICtrlSetData($g_hProgressSolo, 77)
	__RegisterSystemDll("rsabase.dll")
	__RegisterSystemDll("RSAENH.DLL")
	__RegisterSystemDll("Sccbase.dll")
	GUICtrlSetData($g_hProgressSolo, 78)
	__RegisterSystemDll("scrobj.dll", "/s /i")
	__RegisterSystemDll("scrrun.dll")
	__RegisterSystemDll("sendmail.dll")
	GUICtrlSetData($g_hProgressSolo, 79)
	__RegisterSystemDll("setupwbv.dll")
	__RegisterSystemDll("setupwbv.dll", "/s /i")
	__RegisterSystemDll("shdoc401.dll")
	GUICtrlSetData($g_hProgressSolo, 80)
	__RegisterSystemDll("shdoc401.dll", "/s /i")
	__RegisterSystemDll("shdocvw.dll")
	__RegisterSystemDll("shdocvw.dll", "/s /i")
	GUICtrlSetData($g_hProgressSolo, 81)
	__RegisterSystemDll("Slbcsp.dll")
	__RegisterSystemDll("softpub.dll")
	__RegisterSystemDll("tdc.ocx")
	GUICtrlSetData($g_hProgressSolo, 82)
	__RegisterSystemDll("thumbvw.dll")
	__RegisterSystemDll("trialoc.dll")
	__RegisterSystemDll("triedit.dll")
	GUICtrlSetData($g_hProgressSolo, 83)
	__RegisterSystemDll("url.dll")
	__RegisterSystemDll("urlmon.dll", "/s /i")
	__RegisterSystemDll("urlmon.dll,NI,HKLM", "/s /i")
	GUICtrlSetData($g_hProgressSolo, 84)
	__RegisterSystemDll("vbscript.dll")

;~ VML Renderer
	GUICtrlSetData($g_hProgressSolo, 85)
	_Logging_EditWrite($g_aLangMessages2[50])
	__RegisterSystemDll("vgx.dll")
	__RegisterSystemDll("voxmsdec.ax")
	GUICtrlSetData($g_hProgressSolo, 86)
	__RegisterSystemDll("wab32.dll")
	__RegisterSystemDll("wabfind.dll")
	__RegisterSystemDll("wabimp.dll")
	GUICtrlSetData($g_hProgressSolo, 87)
	__RegisterSystemDll("webcheck.dll", "/i /s")
	__RegisterSystemDll("webcheck.dll")
	__RegisterSystemDll("WEBPOST.DLL")
	GUICtrlSetData($g_hProgressSolo, 88)
	__RegisterSystemDll("wininet.dll")
	__RegisterSystemDll("wininet.dll", "/i /s")
	__RegisterSystemDll("wininet.dll", "/i /s /n")
	GUICtrlSetData($g_hProgressSolo, 89)
	__RegisterSystemDll("WINTRUST.DLL")
	__RegisterSystemDll("WPWIZDLL.DLL")
	__RegisterSystemDll("wshext.dll")
	__RegisterSystemDll("wshom.ocx")
	GUICtrlSetData($g_hProgressSolo, 90)
	__RegisterSystemDll("xmsconf.ocx")
	GUICtrlSetData($g_hProgressSolo, 91)

	If @OSVersion = "WIN_XP" Then

;~ Symptom: new tabs page cannot display content because it cannot access the controls (added 27. 3.2009)
;~ This is a result of a bug in shdocvw.dll (see above), probably only on Windows XP
		_Logging_EditWrite($g_aLangMessages2[51])
		_Logging_EditWrite($g_aLangMessages2[52])
		_Registry_Write("HKEY_CLASSES_ROOT\TypeLib\{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}\1.1\0\win32", "", "REG_SZ", "%SystemRoot%\system32\ieframe.dll")

		_Logging_EditWrite($g_aLangMessages2[53])
		__RegisterProgramFilesDll("Outlook Express\msoe.dll")
		__RegisterProgramFilesDll("Outlook Express\oeimport.dll")
		GUICtrlSetData($g_hProgressSolo, 92)
		__RegisterProgramFilesDll("Outlook Express\oemiglib.dll")
		__RegisterProgramFilesDll("Outlook Express\wabfind.dll")
		__RegisterProgramFilesDll("Outlook Express\wabimp.dll")
		GUICtrlSetData($g_hProgressSolo, 93)

	EndIf

	GUICtrlSetData($g_hProgressSolo, 94)
	__RegisterCommonProgramFilesDll("microsoft shared\vgx\vgx.dll")
	__RegisterCommonProgramFilesDll("system\directdb.dll")
	__RegisterCommonProgramFilesDll("system\wab32.dll")

	_Logging_FinalMessage($g_aLangMessages2[54])
	_EndSoloProcess($iRow)

EndFunc


Func _ClearUpdateHistory($iRow, $IsInnerProcess = False)

	If Not $IsInnerProcess Then
		_StartSoloProcess($iRow)
		_Logging_Start($g_aLangMessages2[55])
			Sleep(250)
		GUICtrlSetData($g_hProgressSolo, 25)
	Else
		_Logging_EditWrite($g_aLangMessages2[55])
	EndIf

	_FileEx_FileDelete(@AppDataCommonDir & "\Microsoft\Network\Downloader\qmgr*.dat")
	_FileEx_BackupRemoveDirectory($g_sSoftDisDown, $g_sSoftDisDownOld)
	If Not $IsInnerProcess Then GUICtrlSetData($g_hProgressSolo, 50)
	_FileEx_BackupRemoveDirectory($g_sDataStore, $g_sDataStoreOld)
	If Not $IsInnerProcess Then GUICtrlSetData($g_hProgressSolo, 75)
	_FileEx_BackupRemoveDirectory($g_sCatroot2, $g_sCatroot2Old)

	If Not $IsInnerProcess Then
			Sleep(100)
		_Logging_FinalMessage($g_aLangMessages2[56])
		_EndSoloProcess($iRow)
	Else
		_Logging_EditWrite($g_aLangMessages2[56])
	EndIf

	$g_iClearWinUpdate = False

EndFunc


Func _RepairWindowsUpdate($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start("Repairing Windows Update / Automatic Updates.")
		Sleep(100)

	GUICtrlSetData($g_hProgressSolo, 3)
	If _FileEx_ProgramFileExists(@ProgramFilesDir & "\Nero\Update\NASvc.exe") Then
		_Logging_EditWrite("Stopping the Nero Update Service.")
		_RunCommand("net stop NAUpdate")
	EndIf

	GUICtrlSetData($g_hProgressSolo, 6)
	_Logging_EditWrite("Stopping the BITS Service.")
	_RunCommand("net stop bits")

	GUICtrlSetData($g_hProgressSolo, 9)
	_Logging_EditWrite("Stopping the Automatic Updates Service.")
	_RunCommand("net stop wuauserv")

	GUICtrlSetData($g_hProgressSolo, 12)
	If $g_iClearWinUpdate Then _ClearUpdateHistory($iRow, True)

	GUICtrlSetData($g_hProgressSolo, 15)
	_Logging_EditWrite("Setting BITS Security Descriptor.")
	_RunCommand("sc sdset bits " & Chr(34) & "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" & Chr(34))

	GUICtrlSetData($g_hProgressSolo, 18)
	_Logging_EditWrite("Setting Automatic Updates Service Security Descriptor.")
	_RunCommand("sc sdset wuauserv " & Chr(34) & "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" & Chr(34))

	GUICtrlSetData($g_hProgressSolo, 21)
	_Logging_EditWrite("Configuring the Automatic Updates Service.")
	_Service_Configure("wuauserv", 2)
	_RunCommand("sc config wuauserv start= auto")

	GUICtrlSetData($g_hProgressSolo, 24)
	_Logging_EditWrite("Configuring BITS.")
	_Service_Configure("BITS", 2)
	_RunCommand("sc config bits start= auto")

	GUICtrlSetData($g_hProgressSolo, 27)
	_Logging_EditWrite("Registering Windows Updates Dlls.")

	Local $sWADlls = "actxprxy.dll|atl.dll|browseui.dll|corpol.dll|cryptdlg.dll|dispex.dll|dssenh.dll|gpkcsp.dll|initpki.dll|" & _
			"jscript.dll|mshtml.dll|msscript.ocx|msxml.dll|msxml2.dll|msxml3.dll|msxml4.dll|msxml6.dll|muweb.dll|" & _
			"ole.dll|ole32.dll|oleaut.dll|oleaut32.dll|qmgr.dll|qmgrprxy.dll|gpkcsp.dll|rsaenh.dll|sccbase.dll|scrobj.dll|" & _
			"scrrun.dll|shdocvw.dll|shell.dll|shell32.dll|slbcsp.dll|softpub.dll|urlmon.dll|vbscript.dll|winhttp.dll|" & _
			"wintrust.dll|wshext.dll|wuapi.dll|wuaueng.dll|wuaueng1.dll|wucltui.dll|wucltux.dll|wups.dll|wups2.dll|wuweb.dll|" & _
			"wuwebv.dll"

	Local $aWADlls = StringSplit($sWADlls, "|")
	Local $sProcTemp, $iDllCount = 0, $iDllPerc = 0, $iPercChange = 0

	For $x = 1 To $aWADlls[0]

		$iDllCount += 1
		$iDllPerc = Int($iDllCount / $aWADlls[0] * 33)

		If $iDllPerc <> $iPercChange Then
			GUICtrlSetData($g_hProgressSolo, Round($iDllPerc) + 27)
			$iPercChange = $iDllPerc
		EndIf

		__RegisterSystemDll($aWADlls[$x])

	Next

	GUICtrlSetData($g_hProgressSolo, 63)
	If $g_iResetWinsock Then _RepairWinsock($iRow, True)
	If $g_iResetProxy Then _ResetProxyServer($iRow, True)
	If $g_iResetFirewall Then _ResetFirewall($iRow, True)

	GUICtrlSetData($g_hProgressSolo, 66)
	_Logging_EditWrite("Restarting the Automatic Updates Service.")
	_RunCommand("net start wuauserv")

	GUICtrlSetData($g_hProgressSolo, 69)
	_Logging_EditWrite("Restarting the BITS Service.")
	_RunCommand("net start bits")

	GUICtrlSetData($g_hProgressSolo, 72)
	If _FileEx_ProgramFileExists(@ProgramFilesDir & "\Nero\Update\NASvc.exe") Then
		_Logging_EditWrite("Restarting the Nero Update Service.")
		_RunCommand("net start NAUpdate")
	EndIf

	GUICtrlSetData($g_hProgressSolo, 75)
	_Logging_EditWrite("Clean transactional metadata on next Transactional Resource Manager mount.")
	_RunCommand("fsutil resource setautoreset true " & @HomeDrive & ":\")

	If @OSVersion <> "WIN_XP" Then
		_Logging_EditWrite("Clearing the BITS queue.")
		_RunCommand("bitsadmin.exe /reset /allusers")
	EndIf

	GUICtrlSetData($g_hProgressSolo, 78)
	_Registry_Delete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\LocalUser\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate\DisableWindowsUpdateAccess")
	_Registry_Delete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoWindowsUpdate")
	_Registry_Delete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDevMgrUpdate")
	_Registry_Delete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate", "DisableWindowsUpdateAccess")
	_Registry_Delete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate")

	GUICtrlSetData($g_hProgressSolo, 81)
	_Registry_Delete("HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoWindowsUpdate")
	_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoUpdate")
	_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "AUOptions")
	_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "ScheduledInstallDay")
	_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "ScheduledInstallTime")
	_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoRebootWithLoggedOnUsers")
	_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "LastWaitTimeout")
	_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "DetectionStartTime")
	_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NextDetectionTime")
	_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallDate")

	GUICtrlSetData($g_hProgressSolo, 84)
	_Registry_Write("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NoAutoUpdate", "REG_DWORD", 0)
	_Registry_Write("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "AUOptions", "REG_DWORD", 4)
	_Registry_Write("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallDay", "REG_DWORD", 0)
	_Registry_Write("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallTime", "REG_DWORD", 3)
	_Registry_Write("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NoAutoRebootWithLoggedOnUsers", "REG_DWORD", 1)

	GUICtrlSetData($g_hProgressSolo, 87)
	_Registry_Write("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "NoUpdateCheck", "REG_DWORD", 0)

	GUICtrlSetData($g_hProgressSolo, 90)
	If Not @OSVersion = "WIN_10" Then
		_Logging_EditWrite("Initiating Windows Updates detection right away.")
		_RunCommand("wuauclt /detectnow")
	EndIf

	_Logging_FinalMessage("Windows Update should work now.")
	_EndSoloProcess($iRow)

EndFunc


Func _RepairCryptography($iRow)

EndFunc   ;==>_RepairCryptography


Func _ResetProxyServer($iRow, $IsInnerProcess = False)

EndFunc   ;==>_ResetProxyServer


Func _ResetFirewall($iRow, $IsInnerProcess = False)

EndFunc   ;==>_ResetFirewall


Func _RestoreWindowsHosts($iRow)

EndFunc


Func _RenewWinsClient($iRow)

EndFunc


Func _RepairWorkGroups($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start("Repairing Workgroup Computers view.")
	GUICtrlSetData($g_hProgressSolo, 50)
	_Registry_Delete("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\NetBt\Parameters", "NodeType")
	_Registry_Delete("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\NetBt\Parameters", "DhcpNodeType")
	GUICtrlSetData($g_hProgressSolo, 100)
		Sleep(100)
	_Logging_FinalMessage("Workgroup Computers View should work now.")

EndFunc   ;==>_RepairWorkGroups


Func _StartSoloProcess($iRow)
	_GUICtrlListView_SetItemImage($g_hListRepairs, $iRow, 0)
EndFunc


Func _EndSoloProcess($iRow)

	If $g_iSoloProcess = False Then
		_GUICtrlListView_SetItemChecked($g_hListRepairs, $iRow, False)
	EndIf

	If $g_iLoggingErrors > 0 Then
		_GUICtrlListView_SetItemImage($g_hListRepairs, $iRow, 2)
	Else
		_GUICtrlListView_SetItemImage($g_hListRepairs, $iRow, 1)
	EndIf

	GUICtrlSetData($g_hProgressSolo, 100)
	Sleep(1000)
	If $g_iSoloProcess = True Then
		Local $iXz = ($iRow + 8)
		_GUICtrlListView_SetItemImage($g_hListRepairs, $iRow, $iXz)
		_SetCtrlStates($GUI_ENABLE)
	EndIf

	_GUICtrlListView_SetItemFocused($g_hListRepairs, $iRow)
	_GUICtrlListView_EnsureVisible($g_hListRepairs, $iRow)
	GUICtrlSetData($g_hProgressSolo, 0)

EndFunc


Func _EndProcessing()

	Local $iRepairCount = _GUICtrlListView_GetItemCount($g_hListRepairs)
	For $i = 0 To $iRepairCount
		_GUICtrlListView_SetItemImage($g_hListRepairs, $i, 8 + $i)
	Next

	GUICtrlSetData($g_hProgressAll, 0)
	_SetCtrlStates($GUI_ENABLE)

EndFunc


Func _SetCtrlStates($iState)

	GUICtrlSetState($g_hMenuFile, $iState)
	GUICtrlSetState($g_hMenuHelp, $iState)
	GUICtrlSetState($g_hMenuDebug, $iState)
	GUICtrlSetState($g_hGuiIcon, $iState)
	GUICtrlSetState($g_hListRepairs, $iState)
	GUICtrlSetState($g_hComboPower, $iState)
	GUICtrlSetState($g_hBtnProcess, $iState)
	GUICtrlSetState($g_hBtnProcessAll, $iState)

EndFunc


Func _GetCheckedItemCount($hWnd)

	Local $iCheckedCount = 0
	Local $iRepairCount = _GUICtrlListView_GetItemCount($hWnd)

	If $iRepairCount > 0 Then

		For $i = 0 To $iRepairCount

			Local $iSelCount = _GUICtrlListView_GetItemChecked($hWnd, $i)
			If $iSelCount = 1 Then
				$iCheckedCount += 1
			EndIf
		Next

	EndIf

	Return $iCheckedCount


EndFunc   ;==>_GetCheckedItemCount


Func __ResetWinsock()

	_Logging_EditWrite($g_aLangMessages2[21])
	_RunCommand("netsh winsock reset catalog")
	_Logging_EditWrite($g_aLangMessages2[22])
	_RunCommand("netsh winsock reset")

EndFunc   ;==>_ResetWinsock


Func __RegisterProgramFilesDll($sDllName)

	_Dll_Register(Chr(34) & "%ProgramFiles%\" & $sDllName & Chr(34))
	If @OSArch = "X64" Then
		_Dll_Register(Chr(34) & "%ProgramFiles(x86)%\" & $sDllName & Chr(34))
	EndIf

EndFunc


Func __RegisterSystemDll($sDllName, $sParam = "/s")

	; Expand environment variables for this to work! - Opt("ExpandEnvStrings", 1)
	_Dll_Register(Chr(34) & "%SystemRoot%\system32\" & $sDllName & Chr(34), $sParam)
	If @OSArch = "X64" Then
		_Dll_Register(Chr(34) & "%SystemRoot%\SysWoW64\" & $sDllName & Chr(34), $sParam)
	EndIf

EndFunc


Func __RegisterCommonProgramFilesDll($sDllName, $sParam = "/s")

	_Dll_Register(Chr(34) & "%CommonProgramFiles%\" & $sDllName & Chr(34), $sParam)
	If @OSArch = "X64" Then
		_Dll_Register(Chr(34) & "%CommonProgramFiles(x86)%\" & $sDllName & Chr(34), $sParam)
	EndIf

EndFunc


Func _BootMessage()

	_Logging_EditWrite($g_aLangMessages2[3])

	If $g_ShowInterface Then

		If Not IsDeclared("iMsgResult") Then Local $iMsgResult
		$iMsgResult = MsgBox($MB_YESNO + $MB_ICONEXCLAMATION, $g_aLangMessages2[4], $g_aLangMessages2[5])
		Select
			Case $iMsgResult = $IDYES
				_Reboot()
			Case $iMsgResult = $IDNO
				_Logging_EditWrite($g_aLangMessages2[6])
				_Logging_EditWrite($g_aLangMessages2[7])
				_Logging_EditWrite(StringFormat($g_aLangMessages2[8], StringReplace($g_aLangMenus[0], "&", ""), _
					StringReplace($g_aLangMenus[6], "&", "")))

		EndSelect

	EndIf

EndFunc   ;==>_BootMessage


Func _Reboot()

	_Logging_Start($g_aLangMessages2[9])

	If Not IsDeclared("iMsgResult") Then Local $iMsgResult
	$iMsgResult = MsgBox($MB_OKCANCEL + $MB_ICONEXCLAMATION, $g_aLangMessages2[10], _
			StringFormat($g_aLangMessages2[11], $g_iMsgBoxTimeOut), $g_iMsgBoxTimeOut)

	If $iMsgResult = $IDOK Then
		_Logging_EditWrite($g_aLangMessages2[12])
		_Logging_End()
		Shutdown(18)
	Else
		_Logging_EditWrite($g_aLangMessages2[13])
		_Logging_End()
	EndIf

EndFunc   ;==>_Reboot

#EndRegion "Processing"


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


Func _RunCommand($sCommand)

	Local $iCMD = Run(@ComSpec & " /c " & $sCommand, @SystemDir, @SW_HIDE, $STDERR_MERGED)
	Local $sOutput, $sSuccess = ""

	While 1
		$sOutput = StdoutRead($iCMD)
		If @error Then
			ExitLoop
		EndIf

		Local $aOutput = StringSplit($sOutput, @CRLF)
		For $x = 1 To $aOutput[0]
			If __HasOutput($aOutput[$x]) Then
				_Logging_EditWrite(StringStripWS(__FormatRunOutput($aOutput[$x]), $STR_STRIPLEADING + $STR_STRIPTRAILING))
					Sleep(50)
			EndIf
		Next


	WEnd

EndFunc   ;==>_RunCommand


Func __HasOutput($sOutput)

	$sOutput = StringStripWS($sOutput, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

	Switch $sOutput
		Case "", ".", ".."
			Return False
		Case Else
			Return True
	EndSwitch

EndFunc   ;==>__HasOutput


Func __FormatRunOutput($sOutput)

	Local $sReturn = $sOutput
	Local $sBadStrings = "Resetting , failed.|Resetting , OK!|Sucessfully"
	Local $sGoodStrings = "Resetting, failed.|Resetting, OK!|Successfully"
	Local $aBadStrings = StringSplit($sBadStrings, "|")
	Local $aGoodStrings = StringSplit($sGoodStrings, "|")


	If $aBadStrings[0] = $aGoodStrings[0] Then
		For $x = 1 To $aBadStrings[0]
			$sReturn = StringReplace($sReturn, $aBadStrings[$x], $aGoodStrings[$x])
		Next
	EndIf

	Return $sReturn

EndFunc   ;==>__FormatRunOutput