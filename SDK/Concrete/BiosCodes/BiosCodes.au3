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
#AutoIt3Wrapper_Icon=..\..\Resources\Icons\BiosCodes.ico		;~ Filename of the Ico file to use for the compiled exe
#AutoIt3Wrapper_OutFile_Type=exe								;~ exe=Standalone executable (Default); a3x=Tokenised AutoIt3 code file
#AutoIt3Wrapper_OutFile=..\..\..\Resolute\BiosCodes.exe			;~ Target exe/a3x filename.
#AutoIt3Wrapper_OutFile_X64=..\..\..\Resolute\BiosCodes_X64.exe	;~ Target exe filename for X64 compile.
;#AutoIt3Wrapper_Compression=4									;~ Compression parameter 0-4  0=Low 2=normal 4=High. Default=2
;#AutoIt3Wrapper_UseUpx=Y										;~ (Y/N) Compress output program.  Default=Y
;#AutoIt3Wrapper_UPX_Parameters=								;~ Override the default settings for UPX.
#AutoIt3Wrapper_Change2CUI=N									;~ (Y/N) Change output program to CUI in stead of GUI. Default=N
#AutoIt3Wrapper_Compile_both=Y									;~ (Y/N) Compile both X86 and X64 in one run. Default=N
;===============================================================================================================
; Target Program Resource info
;===============================================================================================================
#AutoIt3Wrapper_Res_Comment=Beep Codes Viewer					;~ Comment field
#AutoIt3Wrapper_Res_Description=Beep Codes Viewer				;~ Description field
#AutoIt3Wrapper_Res_Fileversion=11.1.1.1960
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y  				;~ (Y/N/P) AutoIncrement FileVersion. Default=N
#AutoIt3Wrapper_Res_FileVersion_First_Increment=N				;~ (Y/N) AutoIncrement Y=Before; N=After compile. Default=N
#AutoIt3Wrapper_Res_HiDpi=N                      				;~ (Y/N) Compile for high DPI. Default=N
#AutoIt3Wrapper_Res_ProductVersion=11             				;~ Product Version
#AutoIt3Wrapper_Res_Language=2057								;~ Resource Language code . Default 2057=English (United Kingdom)
#AutoIt3Wrapper_Res_LegalCopyright=© 2023 Rizonesoft			;~ Copyright field
#AutoIt3Wrapper_res_requestedExecutionLevel=asInvoker			;~ asInvoker, highestAvailable, requireAdministrator or None (remove the trsutInfo section).  Default is the setting from Aut2Exe (asInvoker)
;#AutoIt3Wrapper_res_Compatibility=Vista,Win7,Win8,Win81			;~ Vista/Windows7/win7/win8/win81 allowed separated by a comma     (Default=Win81)
;#AutoIt3Wrapper_Res_SaveSource=N								;~ (Y/N) Save a copy of the Script_source in the EXE resources. Default=N
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
#AutoIt3Wrapper_Res_Field=ProductName|Beep Codes Viewer
#AutoIt3Wrapper_Res_Field=HomePage|https://rizonesoft.com
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
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\BiosCodesH.ico					; 201

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Information.ico			; 202
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Complete.ico				; 203
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\logging\Cross.ico			 	; 204
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
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\Twitter.ico				; 220
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\TwitterH.ico				; 221
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\Facebook.ico				; 222
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\FacebookH.ico				; 223
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\Reddit.ico					; 224
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\RedditH.ico				; 225
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\LinkedIn.ico				; 226
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\LinkedInH.ico				; 227
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\GitHub.ico					; 228
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\GitHubH.ico	 			; 229
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\WhatsApp.ico				; 230
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\About\WhatsAppH.ico	 			; 231

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\en.ico						; 232
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\af.ico						; 233
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ar.ico						; 234
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\bg.ico						; 235
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\cs.ico						; 236
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\da.ico						; 237
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\de.ico						; 238
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\el.ico						; 239
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\es.ico						; 240
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\fr.ico						; 241
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\hi.ico						; 242
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\hr.ico						; 243
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\hu.ico						; 244
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\id.ico						; 245
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ir.ico						; 246
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\is.ico						; 247
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\it.ico						; 248
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\iw.ico						; 249
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ja.ico						; 250
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ko.ico						; 251
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\nl.ico						; 252
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\no.ico						; 253
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\pl.ico						; 254
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\pt.ico						; 255
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\pt-BR.ico					; 256
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ro.ico						; 257
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\ru.ico						; 258
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\sl.ico						; 259
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\sk.ico						; 260
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\sv.ico						; 261
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\th.ico						; 262
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\tr.ico						; 263
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\vi.ico						; 264
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\zh-CN.ico					; 265
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Flags\zh-TW.ico					; 266

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-0.ico				; 267
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-1.ico				; 268
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-2.ico				; 269
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-3.ico				; 270
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-4.ico				; 271
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Power\Power-5.ico				; 272

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Gear.ico					; 273
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Logbook.ico				; 274
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Close.ico					; 275
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Update.ico					; 276
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Home.ico					; 277
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Support.ico				; 278
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\GitHub.ico					; 279
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\About.ico					; 280

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\List\Info.ico					; 281
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\List\No.ico						; 282
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\List\Yes.ico						; 283

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
;#Au3Stripper_Parameters=/MergeOnly								;~ Au3Stripper parameters...see SciTE4AutoIt3 Helpfile for options
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
; Opt("GUICloseOnESC", 0)				;~ 1=ESC  closes, 0=ESC won't close
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
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <Process.au3>
#include <TabConstants.au3>
#include <WinAPITheme.au3>
#include <WinAPIProc.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>

#include "..\..\Includes\About.au3"
#include "..\..\Includes\Donate.au3"
#include "..\..\Includes\GDIPlusEx.au3"
#include "..\..\Includes\FileEx.au3"
#include "..\..\Includes\GuiMenuEx.au3"
#include "..\..\Includes\ImageListEx.au3"
#include "..\..\Includes\Link.au3"
#include "..\..\Includes\Registry.au3"
#include "..\..\Includes\Splash.au3"
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
Global Const $CNT_BIOSBUTTONS	 = 8
Global Const $SIZE_BUTTONSTART 	 = 108
Global Const $SIZE_BUTTONSHEIGHT = 33

;~ General Settings
Global $g_sCompanyName			= "Rizonesoft"
Global $g_sProgShortName		= "BiosCodes"
Global $g_sProgShortName_X64	= $g_sProgShortName & "_X64"
Global $g_sProgName				= "Beep Codes Viewer"
Global $g_iSingleton			= True

;~ Links
Global $g_sUrlCompHomePage		= "https://rizonesoft.com|www.rizonesoft.com"														; https://rizonesoft.com
Global $g_sUrlSupport			= "https://rizonesoft.com/contact-us/|www.rizonesoft.com/contact-us"								; https://rizonesoft.com/contact-us
Global $g_sUrlWhatsApp			= "https://api.whatsapp.com/send?phone=27849630169&text=Hi,&source=&data="
Global $g_sUrlDownloads			= "https://rizonesoft.com/downloads/|/www.rizonesoft.com/downloads/"								; https://rizonesoft.com/downloads/
Global $g_sUrlTwitter			= "https://twitter.com/rizonesoft|Twitter.com/Rizonesoft"												; https://twitter.com/Rizonesoft
Global $g_sUrlFacebook			= "https://www.facebook.com/rizonesoft|Facebook.com/rizonesoft"											; https://www.facebook.com/rizonesoft
Global $g_sUrlReddit			= "https://www.reddit.com/user/rizonesoft|Reddit.com/user/rizonesoft"									; https://www.reddit.com/user/rizonesoft
Global $g_sUrlLinkedIn	 		= "https://www.linkedin.com/in/rizonetech|LinkedIn.com/in/rizonetech" 									; https://www.linkedin.com/in/rizonetech
Global $g_sUrlGitHub			= "https://github.com/rizonesoft/Resolute|GitHub.com/rizonesoft/Resolute"								; https://github.com/rizonesoft/Resolute
Global $g_sUrlGitHubIssues		= "https://github.com/rizonesoft/Resolute/issues|GitHub.com/rizonesoft/Resolute/issues"					; https://github.com/rizonesoft/Resolute/issues
Global $g_sUrlRSS				= "https://rizonesoft.com/feed|www.rizonesoft.com/feed"												; https://rizonesoft.com/feed
Global $g_sUrlPayPal			= "https://www.paypal.com/donate/?hosted_button_id=7UGGCSDUZJPFE|PayPal.com/donate"						; https://www.paypal.com/donate/?hosted_button_id=7UGGCSDUZJPFE
Global $g_sUrlSA				= "https://en.wikipedia.org/wiki/South_Africa|Wikipedia.org/wiki/South_Africa"							; https://en.wikipedia.org/wiki/South_Africa
Global $g_sUrlProgPage			= "https://rizonesoft.com/downloads/resolute/|www.rizonesoft.com/downloads/resolute/"
Global $g_sUrlUpdate			= "https://rizonesoft.com/downloads/resolute/update/"
Global $g_sUrlUpdateServer		= "https://cdn2.rizonesoft.com/update/"

;~ Path Settings
Global $g_sRootDir			= @ScriptDir
Global $g_sWorkingDir		= $g_sRootDir ;~ Working Directory
Global $g_sPathIni			= $g_sWorkingDir & "\" & $g_sProgShortName & ".ini" ;~ Full Path to the Configuaration file
Global $g_sAppDataRoot		= @AppDataDir & "\" & $g_sCompanyName & "\" & $g_sProgShortName
Global $g_sResourcesDir		= _PathFull(@ScriptDir & "\..\..\Resources")
Global $g_sProcessDir		= $g_sRootDir &	"\Processing"
Global $g_sDocsDir			= $g_sRootDir & "\Documents\" & $g_sProgShortName ;~ Documentation Directory
Global $g_sDocHelpFile		= $g_sDocsDir & "\" & $g_sProgShortName & ".chm"
Global $g_sDocChanges		= $g_sDocsDir & "\Changes.txt"
Global $g_sDocLicense		= $g_sDocsDir & "\License.txt"
Global $g_sDocReadme		= $g_sDocsDir & "\Readme.txt"

If Not @Compiled Then
	$g_sProcessDir = _PathFull(@ScriptDir & "\..\..\..\Resolute\Processing")
EndIf

;~ Logging Settings
Global $g_sLoggingRoot		= $g_sWorkingDir & "\Logging\" & $g_sProgShortName
Global $g_sLoggingPath		= $g_sLoggingRoot & "\" & $g_sProgShortName & ".log"
Global $g_sLogIpResetPath	= $g_sLoggingRoot & "\IP_Reset.log"
Global $g_GuiLogBoxHeight	= 125
Global $g_iLogIconStart		= -202
Global $g_iUpdateSubStatus	= True

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
Global $g_iLangIconStart				= 232
Global $g_iPowerIconsStart				= 267
Global $g_iMenuIconsStart				= 273
Global $g_iBiosInfoIconStart			= 281

Global $g_aCoreIcons[3]
; Global $g_aDonateIcons[3]
Global $g_iSizeIcon						= 64
Global $g_aLognIcons[$CNT_LOGICONS]
Global $g_aLanguageIcons[$CNT_LANGICONS]
Global $g_aMenuIcons[$CNT_MENUICONS]
Global $g_sDlgOptionsIcon

;~ Splash Page Settings
Global $g_sSplashAniPath
Global $g_iSplashDelay

;~ Update Notification Settings
Global $g_sUpdateAnimation	= $g_sProcessDir & "\" & $g_iSizeIcon & "\Globe.ani"
Global $g_sProcessingAnimation  = $g_sProcessDir & "\" & $g_iSizeIcon & "\Stroke.ani"
If $DEBUG_UPDATE = True Then
	Global $g_sRemoteUpdateFile	= $g_sUrlUpdateServer & $g_sProgShortName & ".ruz"
Else
	Global $g_sRemoteUpdateFile	= $g_sUrlUpdateServer & $g_sProgShortName & ".ru"
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
Global $g_iCoreGuiWidth		= 780
Global $g_iCoreGuiHeight	= 580
Global $g_iMsgBoxTimeOut	= 60

;~ About Dialog
Global $g_sAboutCredits		= "Derick Payne (Rizonesoft), Brian J Christy (Beege), " & _
							"G Sandler (MrCreatoR), Holger Kotsch, KaFu, LarsJ, nickston, ProgAndy, Yashied"
Global $g_sProgramTitle = _GUIGetTitle($g_sProgName)	;~ Get Program Ttile, including version.
Global $g_hCoreGui										;~ Main GUI
Global $g_hGuiIcon										;~ Main Icon
Global $g_AniUpdate
Global $g_AniProcessing
Global $g_hMenuFile
Global $g_hMenuHelp, $g_hUpdateMenuItem
Global $g_hMenuDebug

Global $g_OldSystemParam								;~ Used when resizing the main GUI
Global $g_hSubHeading
Global $g_hBtnRepair
Global $g_aBiosButtons[$CNT_BIOSBUTTONS]
Global $g_aBiosTabs[$CNT_BIOSBUTTONS]
Global $g_aBiosGroups[$CNT_BIOSBUTTONS]
Global $g_aBiosInfoButtons[3]
Global $g_hListBiosInfo
Global $g_hImgBiosInfo

If Not IsDeclared("g_iParentState") Then Global $g_iParentState
If Not IsDeclared("g_iParent") Then Global $g_iParent

If Not IsDeclared("g_iParentState") Then Global $g_iParentState
If Not IsDeclared("g_iParent") Then Global $g_iParent

Global $g_hOptionsGui
Global $g_hOIconPower
Global $g_hOComboPower
Global $g_hOChkSaveRealtime
Global $g_hOChkReduceMemory
Global $g_hOChkLogEnabled
Global $g_hOInLogSize
Global $g_hOInLogSizeTemp
Global $g_hOLblLogSize
Global $g_hOBtnLogClear
Global $g_hOListLanguage
Global $g_hOImgLanguage
Global $g_hOIconLanguage
Global $g_hOLblLanguage
Global $g_hOLblPrefsUpdated
Global $g_hOBtnSave
Global $g_hOBtnCancel

Global $g_hIconDonate
Global $g_hLblDonate

Global $g_iProcessPriority 		= 3
Global $g_iSaveRealtime			= 0
Global $g_iReduceMemory 		= 1
Global $g_iReduceEveryMill 		= 300
Global $g_iMaxSysMemoryPerc 	= 80
Global $g_iDonateLabelHover		= 1

Global $g_hEditDetails
Global $g_hListAMI
Global $g_hListAST
Global $g_hListAward
Global $g_hListCompaq
Global $g_hListDell
Global $g_hListIBM
Global $g_hListIntel
Global $g_hListInsyde
Global $g_hLabelTime

Const $SC_MOVE = 0xF010
Const $SC_SIZE = 0xF000

Global $TimeBuffer[2]

Global $i_DRAGFULLWINDOWS_Current
Global $i_DRAGFULLWINDOWS_Initial = _SPI_GETDRAGFULLWINDOWS()

OnAutoItExitRegister("_Reset_DRAGFULLWINDOWS")

Dim $g_aBaseBoardInfo[1][28], $g_aBIOSInfo[1][30], $g_aBiosCharacteristics
Global $oMyError = ObjEvent("AutoIt.Error","MyErrFunc")

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

		OnAutoItExitRegister("_TerminateProgram")

		$g_sSplashAniPath		= $g_sProcessDir & "\32\Stroke.ani"
		$g_iSplashDelay			= 100
		_Splash_Start($g_aLangMessages[7])
		_Splash_Update($g_aLangMessages[8], 3)
		_Localization_Messages2()	;~ Load Custom Message Language Strings
		_Localization_Menus()		;~ Load Menu Language Strings
		_Localization_Custom()		;~ Load Custom Language Strings
		_Localization_About()		;~ Load About Language Strings
		_Localization_Donate()		;~ Load Donate Language Strings
		_Localization_BIOSInformation() 	;~ Load BIOS information Language Strings
		_Localization_BeepInformation()
		_Splash_Update($g_aLangMessages[9], 6)
		_SetResources()
		_Splash_Update($g_aLangMessages[10], 9)
		_SetWorkingDirectories()
		_Splash_Update($g_aLangMessages[11], 12)
		_LoadConfiguration()
		_Splash_Update($g_aLangMessages[12], 15)
		_Logging_Initialize($g_sProgName)
		_Splash_Update($g_aLangMessages[13], 18)
		_SetHotKeys()
		__GetBiosInformation()
		_Splash_Update($g_aLangMessages[14], 21)
		_StartCoreGui()

	EndIf

EndIf


Func _SetHotKeys()
	HotKeySet("{ESC}", "_MinimizeProgram")
EndFunc


Func _StartCoreGui()

	Local $miFileOptions, $mnuFileLog, $miLogOpenFile, $miLogOpenRoot, $miFileReboot, $miFileClose
	Local $miHelpHome, $miHelpDownloads, $miHelpSupport, $miHelpGitHub, $miHelpDonate, $miHelpAbout
	Local $hHeading

	$g_hCoreGui = GUICreate($g_sProgramTitle, $g_iCoreGuiWidth, $g_iCoreGuiHeight, -1, -1, $WS_OVERLAPPEDWINDOW)
	If Not @Compiled Then GUISetIcon($g_aCoreIcons[0])
	GUISetFont(Default, Default, Default, "Verdana", $g_hCoreGui, $CLEARTYPE_QUALITY)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ShutdownProgram", $g_hCoreGui)

	GUIRegisterMsg($WM_GETMINMAXINFO, "WM_GETMINMAXINFO")
	GUIRegisterMsg($WM_EXITSIZEMOVE, "WM_EXITSIZEMOVE")
	GUIRegisterMsg($WM_SYSCOMMAND, "WM_SYSCOMMAND")

	$g_hMenuFile = GUICtrlCreateMenu($g_aLangMenus[0])
	$g_hMenuHelp = GUICtrlCreateMenu($g_aLangMenus[6])

	_GuiCtrlMenuEx_SetMenuIconBkColor(0xF0F0F0)
	_GuiCtrlMenuEx_SetMenuIconBkGrdColor(0xFFFFFF)

	$miFileOptions = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[1], $g_hMenuFile, $g_aMenuIcons[0], $g_iMenuIconsStart)
	$mnuFileLog = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[2], $g_hMenuFile)
	$miLogOpenFile = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[3], $mnuFileLog, $g_aMenuIcons[1], $g_iMenuIconsStart + 1)
	$miLogOpenRoot = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[4], $mnuFileLog)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuFile)
	$miFileClose = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[5], $g_hMenuFile, $g_aMenuIcons[2], $g_iMenuIconsStart + 2)

	$g_hUpdateMenuItem = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[7], $g_hMenuHelp, $g_aMenuIcons[3], $g_iMenuIconsStart + 3)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpHome = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[8], $g_hMenuHelp, $g_aMenuIcons[4], $g_iMenuIconsStart + 4)
	$miHelpDownloads = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[9], $g_hMenuHelp)
	$miHelpSupport = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[10], $g_hMenuHelp, $g_aMenuIcons[5], $g_iMenuIconsStart + 5)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpGitHub = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[11], $g_hMenuHelp, $g_aMenuIcons[6], $g_iMenuIconsStart + 6)
	$miHelpDonate = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[12], $g_hMenuHelp)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpAbout = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[13], $g_hMenuHelp, $g_aMenuIcons[7], $g_iMenuIconsStart + 7)

	GUICtrlSetOnEvent($miFileOptions, "_ShowPreferencesDlg")
	GUICtrlSetOnEvent($miLogOpenFile, "_Logging_OpenFile")
	GUICtrlSetOnEvent($miLogOpenRoot, "_Logging_OpenDirectory")
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
	; $g_AniProcessing = GUICtrlCreateIcon($g_sProcessingAnimation, 0, 10, 10, $g_iSizeIcon, $g_iSizeIcon)
	GUICtrlSetState($g_AniUpdate, $GUI_HIDE)
	; GUICtrlSetState($g_AniProcessing, $GUI_HIDE)
	$hHeading = GUICtrlCreateLabel($g_sProgName & " " & _GetProgramVersion(1), $g_iSizeIcon + 22, 15, 300, 35)
	GUICtrlSetFont($hHeading, 12)
	$g_hSubHeading = GUICtrlCreateLabel(StringFormat($g_aLangCustom[0], $g_aLangCustom[3]), $g_iSizeIcon + 22, 38, $g_iCoreGuiWidth - ($g_iSizeIcon + 60), 70)
	GUICtrlSetColor($g_hSubHeading, 0x555555)
	GUICtrlSetFont($g_hSubHeading, 9)
	GUICtrlSetResizing($g_hSubHeading, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKWIDTH))

	For $iBB = 0 To $CNT_BIOSBUTTONS - 1
		$g_aBiosButtons[$iBB] = GUICtrlCreateCheckbox(Chr(32) & Chr(32) & $g_aLangCustom[$iBB +2], 10, _
			$SIZE_BUTTONSTART + ($iBB * ($SIZE_BUTTONSHEIGHT + 3)), 160, $SIZE_BUTTONSHEIGHT, BitOR($BS_PUSHLIKE, $BS_LEFT))
		GUICtrlSetOnEvent($g_aBiosButtons[$iBB], "_SelectBiosPage")
	Next
	GUICtrlSetState($g_aBiosButtons[0], $GUI_CHECKED)


	GUICtrlCreateTab(200, -50, 600, 800, $TCS_BUTTONS)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))

	$g_aBiosTabs[0] = GUICtrlCreateTabItem($g_aLangCustom[2])
	$g_aBiosGroups[0] = GUICtrlCreateGroup($g_aLangCustom[2], 180, 80, 580, 465)

	$g_aBiosInfoButtons[0] = GUICtrlCreateCheckbox($g_aLangBIOSInfo[0], 195, 108, 150, 28, $BS_PUSHLIKE)
	$g_aBiosInfoButtons[1] = GUICtrlCreateCheckbox($g_aLangBIOSInfo[1], 348, 108, 150, 28, $BS_PUSHLIKE)
	$g_aBiosInfoButtons[2] = GUICtrlCreateCheckbox($g_aLangBIOSInfo[2], 501, 108, 150, 28, $BS_PUSHLIKE)
	For $iBI = 0 To 2
		GUICtrlSetOnEvent($g_aBiosInfoButtons[$iBI], "__BiosInfoButtonClick")
	Next

	$g_hListBiosInfo = GUICtrlCreateListView("", 195, 145, 550, 215)
	_GUICtrlListView_SetExtendedListViewStyle($g_hListBiosInfo, BitOR($LVS_EX_FULLROWSELECT, _
			$LVS_EX_SUBITEMIMAGES, $LVS_EX_DOUBLEBUFFER, $WS_EX_CLIENTEDGE, _
			$LVS_EX_FLATSB, $LVS_EX_INFOTIP))
	_WinAPI_SetWindowTheme(GUICtrlGetHandle($g_hListBiosInfo), "Explorer")
;~ 	GUICtrlSetResizing($g_hListBiosInfo, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKHEIGHT))
	GUICtrlSetResizing($g_hListBiosInfo, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
	_GUICtrlListView_AddColumn($g_hListBiosInfo, Chr(32) & $g_aLangBIOSInfo[3] & Chr(32), 200)
	_GUICtrlListView_AddColumn($g_hListBiosInfo, $g_aLangBIOSInfo[3], 300)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	$g_hImgBiosInfo = _GUIImageList_Create(16, 16, 5, 3)
	For $iBi = 0 To 2
		_GUIImageList_AddIcon($g_hImgBiosInfo, @ScriptFullPath, 0 - $g_iBiosInfoIconStart - $iBi)
	Next
	_GUICtrlListView_SetImageList($g_hListBiosInfo, $g_hImgBiosInfo, 1)
	__PopulateBiosInformation(1)

	$g_aBiosTabs[1] = GUICtrlCreateTabItem($g_aLangCustom[3])
	$g_aBiosGroups[1] = GUICtrlCreateGroup($g_aLangCustom[3], 180, 80, 580, 465)
	$g_hListAMI = GUICtrlCreateList("", 195, 108, 200, 255, $GUI_SS_DEFAULT_LIST)
	GUICtrlSetResizing($g_hListAMI, BitOR($GUI_DOCKLEFT, $GUI_DOCKWIDTH, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
	GUICtrlSetData($g_hListAMI, _ArrayToString($g_aLangBeepInfo, "|", 6, 20), $g_aLangBeepInfo[6])
	GUICtrlSetOnEvent($g_hListAMI, "_DisplayAMIBeepCodes")
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	$g_aBiosTabs[2] = GUICtrlCreateTabItem($g_aLangCustom[4])
	$g_aBiosGroups[2] = GUICtrlCreateGroup($g_aLangCustom[4], 180, 80, 580, 465)
	$g_hListAST = GUICtrlCreateList("", 195, 108, 200, 255, $GUI_SS_DEFAULT_LIST)
	GUICtrlSetResizing($g_hListAST, BitOR($GUI_DOCKLEFT, $GUI_DOCKWIDTH, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
	GUICtrlSetData($g_hListAST, _ArrayToString($g_aLangBeepInfo, "|", 36, 54), $g_aLangBeepInfo[36])
	GUICtrlSetOnEvent($g_hListAST, "_DisplayASTBeepCodes")
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	$g_aBiosTabs[3] = GUICtrlCreateTabItem($g_aLangCustom[5])
	$g_aBiosGroups[3] = GUICtrlCreateGroup($g_aLangCustom[5], 180, 80, 580, 465)
	$g_hListAward = GUICtrlCreateList("", 195, 108, 200, 255, $GUI_SS_DEFAULT_LIST)
	GUICtrlSetResizing($g_hListAward, BitOR($GUI_DOCKLEFT, $GUI_DOCKWIDTH, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
	GUICtrlSetData($g_hListAward, _ArrayToString($g_aLangBeepInfo, "|", 74, 78), $g_aLangBeepInfo[74])
	GUICtrlSetOnEvent($g_hListAward, "_DisplayAwardBeepCodes")
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	$g_aBiosTabs[4] = GUICtrlCreateTabItem($g_aLangCustom[6])
	$g_aBiosGroups[4] = GUICtrlCreateGroup($g_aLangCustom[6], 180, 80, 580, 465)
	$g_hListCompaq = GUICtrlCreateList("", 195, 108, 300, 255, $GUI_SS_DEFAULT_LIST)
	GUICtrlSetResizing($g_hListCompaq, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
	GUICtrlSetData($g_hListCompaq, _ArrayToString($g_aLangBeepInfo, "|", 84, 90), $g_aLangBeepInfo[84])
	GUICtrlSetOnEvent($g_hListCompaq, "_DisplayCompaqBeepCodes")
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	$g_aBiosTabs[5] = GUICtrlCreateTabItem($g_aLangCustom[7])
	$g_aBiosGroups[5] = GUICtrlCreateGroup($g_aLangCustom[7], 180, 80, 580, 465)
	$g_hListDell = GUICtrlCreateList("", 195, 108, 200, 255, $GUI_SS_DEFAULT_LIST)
	GUICtrlSetResizing($g_hListDell, BitOR($GUI_DOCKLEFT, $GUI_DOCKWIDTH, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
	GUICtrlSetData($g_hListDell, _ArrayToString($g_aLangBeepInfo, "|", 98, 104), $g_aLangBeepInfo[98])
	GUICtrlSetOnEvent($g_hListDell, "_DisplayDellBeepCodes")
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	$g_aBiosTabs[6] = GUICtrlCreateTabItem($g_aLangCustom[8])
	$g_aBiosGroups[6] = GUICtrlCreateGroup($g_aLangCustom[8], 180, 80, 580, 465)
	$g_hListIBM = GUICtrlCreateList("", 195, 108, 200, 255, $GUI_SS_DEFAULT_LIST)
	GUICtrlSetResizing($g_hListIBM, BitOR($GUI_DOCKLEFT, $GUI_DOCKWIDTH, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
	GUICtrlSetData($g_hListIBM, _ArrayToString($g_aLangBeepInfo, "|", 112, 121), $g_aLangBeepInfo[112])
	GUICtrlSetOnEvent($g_hListIBM, "_DisplayIBMBeepCodes")
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	$g_aBiosTabs[7] = GUICtrlCreateTabItem($g_aLangCustom[9])
	$g_aBiosGroups[7] = GUICtrlCreateGroup($g_aLangCustom[9], 180, 80, 580, 465)
	$g_hListIntel = GUICtrlCreateList("", 195, 108, 100, 255, $GUI_SS_DEFAULT_LIST)
	GUICtrlSetResizing($g_hListIntel, BitOR($GUI_DOCKLEFT, $GUI_DOCKWIDTH, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
	GUICtrlSetData($g_hListIntel, 	"1-1-1-3|1-1-2-1|1-1-2-3|1-1-3-1|1-1-3-2|1-1-3-3|1-1-4-1|1-1-4-3|1-2-1-1|1-2-1-2|1-2-1-3|1-2-2-1|" & _
									"1-2-2-3|1-2-3-1|1-2-3-3|1-2-4-1|1-3-1-1|1-3-1-3|1-3-2-1|1-3-3-1|1-3-3-3|1-3-4-1|1-3-4-3|1-4-1-3|" & _
									"1-4-2-1|1-4-2-4|1-4-3-1|1-4-3-2|1-4-3-3|1-4-4-1|1-4-4-2|2-1-1-1|2-1-1-3|2-1-2-1|2-1-2-3|2-1-2-3|" & _
									"2-1-3-1|2-1-3-2|2-1-3-3|2-1-4-1|2-1-4-3|2-2-1-1|2-2-1-3|2-2-2-1|2-2-2-3|2-2-3-1|2-2-3-3|2-2-4-1|" & _
									"2-3-1-1|2-3-1-3|2-3-2-1|2-3-2-3|2-3-3-1|2-3-3-3|2-3-4-1|2-3-4-3|2-4-1-1|2-4-1-3|2-4-2-1|2-4-2-3|" & _
									"2-4-4-1|2-4-4-3|3-1-1-1|3-1-1-3|3-1-2-1|3-1-2-3|3-1-3-1|3-1-3-3|3-1-4-1|3-2-1-1|3-2-1-2|3-2-1-3|" & _
									"3-2-2-1|3-2-2-3|3-2-3-1|3-2-3-3|3-2-4-1|3-2-4-3|3-3-1-1|3-3-1-3|3-3-3-1|3-3-3-3|3-3-4-1|3-3-4-3|" & _
									"3-4-1-1|3-4-1-3|3-4-2-1|3-4-2-3|3-4-3-1|3-4-4-1|3-4-4-3|3-4-4-4|4-1-1-1|4-2-1-1|4-2-1-3|4-2-2-1|" & _
									"4-2-2-3|4-2-3-1|4-2-3-3|4-2-4-1|4-2-4-3|4-3-1-3|4-3-1-4|4-3-2-1|4-3-2-2|4-3-2-3|4-3-2-4|4-3-3-1|" & _
									"4-3-3-2|4-3-3-3|4-3-3-4|4-3-4-1|4-3-4-2|4-3-4-3", "1-1-1-3")
	GUICtrlSetOnEvent($g_hListIntel, "_DisplayPhoenixBeepCodes")
	GUICtrlCreateLabel($g_aLangCustom[11], 310, 108, 400, 100)
	GUICtrlSetColor(-1, 0x333333)
	GUICtrlSetFont(-1, 9)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;~ 	$g_aBiosTabs[8] = GUICtrlCreateTabItem($g_aLangCustom[10])
;~ 	$g_aBiosGroups[8] = GUICtrlCreateGroup($g_aLangCustom[10], 180, 80, 580, 465)
;~ 	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	For $iBC = 0 To $CNT_BIOSBUTTONS - 1
		GUICtrlSetResizing($g_aBiosGroups[$iBC], BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
		GUICtrlSetFont($g_aBiosGroups[$iBC], 10, Default, 2)
	Next
	GUICtrlCreateTabItem("")

	$g_hEditDetails = GUICtrlCreateEdit($g_aLangBeepInfo[0], 195, 365, 550, 160, BitOR(0x00200000, 0x0800, 0x0040)) ;$WS_VSCROLL = 0x00200000 : $ES_READONLY = 0x0800 : $ES_AUTOVSCROLL = 0x0040
	GUICtrlSetBkColor($g_hEditDetails, 0xE5F3FB)
	GUICtrlSetColor($g_hEditDetails, 0x2C4F73)
	GUICtrlSetFont($g_hEditDetails, 9, Default, Default, "Verdana", $CLEARTYPE_QUALITY)
;~ 	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
	GUICtrlSetResizing($g_hEditDetails, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKHEIGHT))

	$g_hLabelTime = GUICtrlCreateLabel("", 10, 530, 150, 20)
	GUICtrlSetResizing($g_hLabelTime, BitOR($GUI_DOCKBOTTOM, $GUI_DOCKLEFT, $GUI_DOCKSIZE))
	_GetTheTime()

	$g_hIconDonate = GUICtrlCreateIcon($g_aDonateIcons[0], $g_iAboutIconStart, 10, 450, 64, 64)
	GUICtrlSetCursor($g_hIconDonate, 0)
	GUICtrlSetResizing($g_hIconDonate, BitOR($GUI_DOCKBOTTOM, $GUI_DOCKLEFT, $GUI_DOCKSIZE))
;~ 	$g_hLblDonate = GUICtrlCreateLabel($g_aLangDonate[2], 85, 420, $g_iCoreGuiWidth - 205, 32)
;~ 	GUICtrlSetCursor($g_hLblDonate, 0)
;~ 	GUICtrlSetColor($g_hLblDonate, 0x000000)
;~ 	GUICtrlSetResizing($g_hLblDonate, BitOR($GUI_DOCKBOTTOM, $GUI_DOCKLEFT, $GUI_DOCKSIZE))

;~ 	GUICtrlSetOnEvent($g_hIconDonate, "_About_PayPal")
;~ 	GUICtrlSetOnEvent($g_hLblDonate, "_About_PayPal")

	_Splash_Update("", 100)
	GUISetState(@SW_SHOW, $g_hCoreGui)
	AdlibRegister("_OnIconsHover", 65)
	If @Compiled Then
		AdlibRegister("_ReduceMemory", $g_iReduceEveryMill)
	EndIf
	AdlibRegister("_GetTheTime", 1000)

	If $g_iCheckForUpdates == 4 Then
		_SoftwareUpdateCheck()
	EndIf

	_TestLoggingSystem("This is a message.", 1000)
	_TestLoggingSystem("Error: This is an Error message!", 1000)
	_TestLoggingSystem("Warning: This is a Warning!", 1000)
	_TestLoggingSystem("Success: This message is successful.", 1000)
	_TestLoggingSystem("Finished testing logging system.", 1000)

	While 1
		Sleep(30)
	WEnd

EndFunc


Func _TestLoggingSystem($sMessage, $iSleep)
	_Logging_EditWrite($sMessage)
	Sleep($iSleep)
EndFunc   ;==>_TestLoggingSystem


Func _GetTheTime()

	Local $tLoc = _Date_Time_GetLocalTime()
	If $tLoc == $TimeBuffer[0] Then
		GUICtrlSetData($g_hLabelTime, _Date_Time_SystemTimeToDateTimeStr($tLoc))
		$TimeBuffer[0] = $tLoc
	EndIf

EndFunc


#Region "Beep Information"

Func _DisplayAMIBeepCodes()

	Local $aMap[99][2]
	$aMap[1][0]  = $g_aLangBeepInfo[6]
	$aMap[1][1]  = $g_aLangBeepInfo[21] & @CRLF & @CRLF & $g_aLangBeepInfo[2]
	$aMap[2][0]  = $g_aLangBeepInfo[7]
	$aMap[2][1]  = $g_aLangBeepInfo[22] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[3][0]  = $g_aLangBeepInfo[8]
	$aMap[3][1]  = $g_aLangBeepInfo[23] & @CRLF & @CRLF & $g_aLangBeepInfo[2]
	$aMap[4][0]  = $g_aLangBeepInfo[9]
	$aMap[4][1]  = $g_aLangBeepInfo[24] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[5][0]  = $g_aLangBeepInfo[10]
	$aMap[5][1]  = $g_aLangBeepInfo[25] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[6][0]  = $g_aLangBeepInfo[11]
	$aMap[6][1]  = $g_aLangBeepInfo[26] & @CRLF & @CRLF & $g_aLangBeepInfo[3]
	$aMap[7][0]  = $g_aLangBeepInfo[12]
	$aMap[7][1]  = $g_aLangBeepInfo[27] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[8][0]  = $g_aLangBeepInfo[13]
	$aMap[8][1]  = $g_aLangBeepInfo[28] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[9][0]  = $g_aLangBeepInfo[14]
	$aMap[9][1]  = $g_aLangBeepInfo[29] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[10][0] = $g_aLangBeepInfo[15]
	$aMap[10][1] = $g_aLangBeepInfo[30] & @CRLF & @CRLF & $g_aLangBeepInfo[4]
	$aMap[11][0] = $g_aLangBeepInfo[16]
	$aMap[11][1] = $g_aLangBeepInfo[31] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[12][0] = $g_aLangBeepInfo[17]
	$aMap[12][1] = $g_aLangBeepInfo[32] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[13][0] = $g_aLangBeepInfo[18]
	$aMap[13][1] = $g_aLangBeepInfo[33] & @CRLF & @CRLF & $g_aLangBeepInfo[2]
	$aMap[14][0] = $g_aLangBeepInfo[19]
	$aMap[14][1] = $g_aLangBeepInfo[34] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[15][0] = $g_aLangBeepInfo[20]
	$aMap[15][1] = $g_aLangBeepInfo[35]

	Local $sReadValue = GUICtrlRead($g_hListAMI)
	Local $sDataToSet = $g_aLangBeepInfo[0]

	For $i = 1 To UBound($aMap) - 1
		If $sReadValue == $aMap[$i][0] Then
			$sDataToSet = $aMap[$i][1]
			ExitLoop
		EndIf
	Next

	GUICtrlSetData($g_hEditDetails, $sDataToSet)

EndFunc

Func _DisplayASTBeepCodes()

	Local $aMap[99][2]
	$aMap[1][0]   = $g_aLangBeepInfo[36]
	$aMap[1][1]   = $g_aLangBeepInfo[55] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[2][0]   = $g_aLangBeepInfo[37]
	$aMap[2][1]   = $g_aLangBeepInfo[56] & @CRLF & @CRLF & $g_aLangBeepInfo[3]
	$aMap[3][0]   = $g_aLangBeepInfo[38]
	$aMap[3][1]   = $g_aLangBeepInfo[57] & @CRLF & @CRLF & $g_aLangBeepInfo[3]
	$aMap[4][0]   = $g_aLangBeepInfo[39]
	$aMap[4][1]   = $g_aLangBeepInfo[58] & @CRLF & @CRLF & $g_aLangBeepInfo[3]
	$aMap[5][0]   = $g_aLangBeepInfo[40]
	$aMap[5][1]   = $g_aLangBeepInfo[59] & @CRLF & @CRLF & $g_aLangBeepInfo[3]
	$aMap[6][0]   = $g_aLangBeepInfo[41]
	$aMap[6][1]   = $g_aLangBeepInfo[60] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[7][0]   = $g_aLangBeepInfo[42]
	$aMap[7][1]   = $g_aLangBeepInfo[61] & @CRLF & @CRLF & $g_aLangBeepInfo[4]
	$aMap[8][0]   = $g_aLangBeepInfo[43]
	$aMap[8][1]   = $g_aLangBeepInfo[62]
	$aMap[9][0]   = $g_aLangBeepInfo[44]
	$aMap[9][1]   = $g_aLangBeepInfo[63] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[10][0]  = $g_aLangBeepInfo[45]
	$aMap[10][1]  = $g_aLangBeepInfo[64] & @CRLF & @CRLF & $g_aLangBeepInfo[4]
	$aMap[11][0]  = $g_aLangBeepInfo[46]
	$aMap[11][1]  = $g_aLangBeepInfo[65] & @CRLF & @CRLF & $g_aLangBeepInfo[2]
	$aMap[12][0]  = $g_aLangBeepInfo[47]
	$aMap[12][1]  = $g_aLangBeepInfo[66] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[13][0]  = $g_aLangBeepInfo[48]
	$aMap[13][1]  = $g_aLangBeepInfo[67] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[14][0]  = $g_aLangBeepInfo[49]
	$aMap[14][1]  = $g_aLangBeepInfo[68] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[15][0]  = $g_aLangBeepInfo[50]
	$aMap[15][1]  = $g_aLangBeepInfo[69] & @CRLF & @CRLF & $g_aLangBeepInfo[2]
	$aMap[16][0]  = $g_aLangBeepInfo[51]
	$aMap[16][1]  = $g_aLangBeepInfo[70] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[17][0]  = $g_aLangBeepInfo[52]
	$aMap[17][1]  = $g_aLangBeepInfo[71] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[18][0]  = $g_aLangBeepInfo[53]
	$aMap[18][1]  = $g_aLangBeepInfo[72] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[19][0]  = $g_aLangBeepInfo[54]
	$aMap[19][1]  = $g_aLangBeepInfo[73] & @CRLF & @CRLF & $g_aLangBeepInfo[2]


	Local $sReadValue = GUICtrlRead($g_hListAST)
	Local $sDataToSet = $g_aLangBeepInfo[0]

	For $i = 1 To UBound($aMap) - 1
		If $sReadValue == $aMap[$i][0] Then
			$sDataToSet = $aMap[$i][1]
			ExitLoop
		EndIf
	Next

	GUICtrlSetData($g_hEditDetails, $sDataToSet)

EndFunc

Func _DisplayAwardBeepCodes()

	Local $aMap[99][2]
	$aMap[1][0]   = $g_aLangBeepInfo[74]
	$aMap[1][1]   = $g_aLangBeepInfo[79] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[2][0]   = $g_aLangBeepInfo[75]
	$aMap[2][1]   = $g_aLangBeepInfo[80] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[3][0]   = $g_aLangBeepInfo[76]
	$aMap[3][1]   = $g_aLangBeepInfo[81] & @CRLF & @CRLF & $g_aLangBeepInfo[2]
	$aMap[4][0]   = $g_aLangBeepInfo[77]
	$aMap[4][1]   = $g_aLangBeepInfo[82] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[5][0]   = $g_aLangBeepInfo[78]
	$aMap[5][1]   = $g_aLangBeepInfo[83] & @CRLF & @CRLF & $g_aLangBeepInfo[1]


	Local $sReadValue = GUICtrlRead($g_hListAward)
	Local $sDataToSet = $g_aLangBeepInfo[0]

	For $i = 1 To UBound($aMap) - 1
		If $sReadValue == $aMap[$i][0] Then
			$sDataToSet = $aMap[$i][1]
			ExitLoop
		EndIf
	Next

	GUICtrlSetData($g_hEditDetails, $sDataToSet)

EndFunc

Func _DisplayCompaqBeepCodes()

	Local $aMap[99][2]
	$aMap[1][0]   = $g_aLangBeepInfo[84]
	$aMap[1][1]   = $g_aLangBeepInfo[91]
	$aMap[2][0]   = $g_aLangBeepInfo[85]
	$aMap[2][1]   = $g_aLangBeepInfo[92] & @CRLF & @CRLF & $g_aLangBeepInfo[4]
	$aMap[3][0]   = $g_aLangBeepInfo[86]
	$aMap[3][1]   = $g_aLangBeepInfo[93] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[4][0]   = $g_aLangBeepInfo[87]
	$aMap[4][1]   = $g_aLangBeepInfo[94] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[5][0]   = $g_aLangBeepInfo[88]
	$aMap[5][1]   = $g_aLangBeepInfo[95]
	$aMap[6][0]   = $g_aLangBeepInfo[89]
	$aMap[6][1]   = $g_aLangBeepInfo[96] & @CRLF & @CRLF & $g_aLangBeepInfo[2]
	$aMap[7][0]   = $g_aLangBeepInfo[90]
	$aMap[7][1]   = $g_aLangBeepInfo[97] & @CRLF & @CRLF & $g_aLangBeepInfo[2]


	Local $sReadValue = GUICtrlRead($g_hListCompaq)
	Local $sDataToSet = $g_aLangBeepInfo[0]

	For $i = 1 To UBound($aMap) - 1
		If $sReadValue == $aMap[$i][0] Then
			$sDataToSet = $aMap[$i][1]
			ExitLoop
		EndIf
	Next

	GUICtrlSetData($g_hEditDetails, $sDataToSet)

EndFunc

Func _DisplayDellBeepCodes()

	Local $aMap[99][2]
	$aMap[1][0]   = $g_aLangBeepInfo[98]
	$aMap[1][1]   = $g_aLangBeepInfo[105] & @CRLF & @CRLF & $g_aLangBeepInfo[4]
	$aMap[2][0]   = $g_aLangBeepInfo[99]
	$aMap[2][1]   = $g_aLangBeepInfo[106] & @CRLF & @CRLF & $g_aLangBeepInfo[2]
	$aMap[3][0]   = $g_aLangBeepInfo[100]
	$aMap[3][1]   = $g_aLangBeepInfo[107] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[4][0]   = $g_aLangBeepInfo[101]
	$aMap[4][1]   = $g_aLangBeepInfo[108] & @CRLF & @CRLF & $g_aLangBeepInfo[2]
	$aMap[5][0]   = $g_aLangBeepInfo[102]
	$aMap[5][1]   = $g_aLangBeepInfo[109] & @CRLF & @CRLF & $g_aLangBeepInfo[4]
	$aMap[6][0]   = $g_aLangBeepInfo[103]
	$aMap[6][1]   = $g_aLangBeepInfo[110] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[7][0]   = $g_aLangBeepInfo[104]
	$aMap[7][1]   = $g_aLangBeepInfo[111] & @CRLF & @CRLF & $g_aLangBeepInfo[1]


	Local $sReadValue = GUICtrlRead($g_hListDell)
	Local $sDataToSet = $g_aLangBeepInfo[0]

	For $i = 1 To UBound($aMap) - 1
		If $sReadValue == $aMap[$i][0] Then
			$sDataToSet = $aMap[$i][1]
			ExitLoop
		EndIf
	Next

	GUICtrlSetData($g_hEditDetails, $sDataToSet)

EndFunc

Func _DisplayIBMBeepCodes()

	Local $aMap[99][2]
	$aMap[1][0]   = $g_aLangBeepInfo[112]
	$aMap[1][1]   = $g_aLangBeepInfo[122] & @CRLF & @CRLF & $g_aLangBeepInfo[5]
	$aMap[2][0]   = $g_aLangBeepInfo[113]
	$aMap[2][1]   = $g_aLangBeepInfo[123]
	$aMap[3][0]   = $g_aLangBeepInfo[114]
	$aMap[3][1]   = $g_aLangBeepInfo[124]
	$aMap[4][0]   = $g_aLangBeepInfo[115]
	$aMap[4][1]   = $g_aLangBeepInfo[125] & @CRLF & @CRLF & $g_aLangBeepInfo[5]
	$aMap[5][0]   = $g_aLangBeepInfo[116]
	$aMap[5][1]   = $g_aLangBeepInfo[126] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[6][0]   = $g_aLangBeepInfo[117]
	$aMap[6][1]   = $g_aLangBeepInfo[127] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[7][0]   = $g_aLangBeepInfo[118]
	$aMap[7][1]   = $g_aLangBeepInfo[128] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[8][0]   = $g_aLangBeepInfo[119]
	$aMap[8][1]   = $g_aLangBeepInfo[129] & @CRLF & @CRLF & $g_aLangBeepInfo[3]
	$aMap[9][0]   = $g_aLangBeepInfo[120]
	$aMap[9][1]   = $g_aLangBeepInfo[130] & @CRLF & @CRLF & $g_aLangBeepInfo[1]
	$aMap[10][0]  = $g_aLangBeepInfo[121]
	$aMap[10][1]  = $g_aLangBeepInfo[131] & @CRLF & @CRLF & $g_aLangBeepInfo[5]


	Local $sReadValue = GUICtrlRead($g_hListIBM)
	Local $sDataToSet = $g_aLangBeepInfo[0]

	For $i = 1 To UBound($aMap) - 1
		If $sReadValue == $aMap[$i][0] Then
			$sDataToSet = $aMap[$i][1]
			ExitLoop
		EndIf
	Next

	GUICtrlSetData($g_hEditDetails, $sDataToSet)

EndFunc

Func _DisplayPhoenixBeepCodes()
	Switch GUICtrlRead($g_hListIntel)
		Case "1-1-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[132])
		Case "1-1-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[133])
		Case "1-1-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[134])
		Case "1-1-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[135])
		Case "1-1-3-2"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[136])
		Case "1-1-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[137])
		Case "1-1-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[138])
		Case "1-1-4-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[139])
		Case "1-2-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[140])
		Case "1-2-1-2"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[141])
		Case "1-2-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[142])
		Case "1-2-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[143])
		Case "1-2-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[144])
		Case "1-2-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[145])
		Case "1-2-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[146])
		Case "1-2-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[147])
		Case "1-3-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[148])
		Case "1-3-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[149])
		Case "1-3-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[150])
		Case "1-3-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[151])
		Case "1-3-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[152])
		Case "1-3-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[153])
		Case "1-3-4-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[154])
		Case "1-4-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[155])
		Case "1-4-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[156])
		Case "1-4-2-4"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[157])
		Case "1-4-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[158])
		Case "1-4-3-2"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[159])
		Case "1-4-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[160])
		Case "1-4-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[161])
		Case "1-4-4-2"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[162])
		Case "2-1-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[163])
		Case "2-1-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[164])
		Case "2-1-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[165])
		Case "2-1-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[166])
		Case "2-1-2-4"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[167])
		Case "2-1-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[168])
		Case "2-1-3-2"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[169])
		Case "2-1-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[170])
		Case "2-1-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[171])
		Case "2-1-4-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[172])
		Case "2-2-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[173])
		Case "2-2-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[174])
		Case "2-2-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[175])
		Case "2-2-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[176])
		Case "2-2-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[177])
		Case "2-2-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[178])
		Case "2-2-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[179])
		Case "2-3-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[180])
		Case "2-3-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[181])
		Case "2-3-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[182])
		Case "2-3-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[183])
		Case "2-3-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[184])
		Case "2-3-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[185])
		Case "2-3-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[186])
		Case "2-3-4-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[187])
		Case "2-4-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[188])
		Case "2-4-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[189])
		Case "2-4-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[190])
		Case "2-4-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[191])
		Case "2-4-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[192])
		Case "2-4-4-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[193])
		Case "3-1-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[194])
		Case "3-1-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[195])
		Case "3-1-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[196])
		Case "3-1-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[197])
		Case "3-1-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[198])
		Case "3-1-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[199])
		Case "3-1-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[200])
		Case "3-2-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[201])
		Case "3-2-1-2"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[202])
		Case "3-2-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[203])
		Case "3-2-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[204])
		Case "3-2-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[205])
		Case "3-2-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[206])
		Case "3-2-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[207])
		Case "3-2-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[208])
		Case "3-2-4-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[209])
		Case "3-3-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[210])
		Case "3-3-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[211])
		Case "3-3-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[212])
		Case "3-3-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[213])
		Case "3-3-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[214])
		Case "3-3-4-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[215])
		Case "3-4-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[216])
		Case "3-4-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[217])
		Case "3-4-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[218])
		Case "3-4-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[219])
		Case "3-4-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[220])
		Case "3-4-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[221])
		Case "3-4-4-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[222])
		Case "3-4-4-4"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[223])
		Case "4-1-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[224])
		Case "4-2-1-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[225])
		Case "4-2-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[226])
		Case "4-2-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[227])
		Case "4-2-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[228])
		Case "4-2-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[229])
		Case "4-2-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[230])
		Case "4-2-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[231])
		Case "4-2-4-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[232])
		Case "4-3-1-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[233])
		Case "4-3-1-4"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[234])
		Case "4-3-2-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[235])
		Case "4-3-2-2"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[236])
		Case "4-3-2-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[237])
		Case "4-3-2-4"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[238])
		Case "4-3-3-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[239])
		Case "4-3-3-2"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[240])
		Case "4-3-3-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[241])
		Case "4-3-3-4"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[242])
		Case "4-3-4-1"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[243])
		Case "4-3-4-2"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[244])
		Case "4-3-4-3"
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[245])
		Case Else
			GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[0])
	EndSwitch

EndFunc

#EndRegion "Beep Information"


#Region "Bios Information"

Func __BiosInfoButtonClick()

	For $iBS = 0 To 2
		GUICtrlSetState($g_aBiosInfoButtons[$iBS], $GUI_UNCHECKED)
	Next

	Switch @GUI_CtrlId
		Case $g_aBiosInfoButtons[0]
			__PopulateBiosInformation(0)

		Case $g_aBiosInfoButtons[1]
			__PopulateBiosInformation(1)

		Case $g_aBiosInfoButtons[2]
			__PopulateBiosInformation(2)

	EndSwitch

EndFunc

Func __PopulateBiosInformation($iSection)

	If $iSection < 3 Then
		GUICtrlSetState($g_aBiosInfoButtons[$iSection], $GUI_CHECKED)
	EndIf

	_GUICtrlListView_BeginUpdate($g_hListBiosInfo)
	_GUICtrlListView_DeleteAllItems($g_hListBiosInfo)

	Switch $iSection
		Case 0
			GUICtrlSetState($g_aBiosInfoButtons[0], $GUI_CHECKED)
			_GUICtrlListView_SetColumnWidth($g_hListBiosInfo, 0, 200)
			_GUICtrlListView_SetColumnWidth($g_hListBiosInfo, 1, 300)

			For $i = 5 To 8
				_GUICtrlListView_AddItem($g_hListBiosInfo, $g_aLangBIOSInfo[$i], 0)
			Next

			Local $aSubItemMapping[4] = [9, 15, 25, 20]
			For $i = 0 To UBound($aSubItemMapping) - 1
				_GUICtrlListView_AddSubItem($g_hListBiosInfo, $i, $g_aBaseBoardInfo[1][$aSubItemMapping[$i]], 1)
			Next


		Case 1
			_GUICtrlListView_SetColumnWidth($g_hListBiosInfo, 0, 250)
			_GUICtrlListView_SetColumnWidth($g_hListBiosInfo, 1, 300)

			For $i = 9 To 19
				_GUICtrlListView_AddItem($g_hListBiosInfo, $g_aLangBIOSInfo[$i], 0)
			Next

			Local $aMapping[11][2] = [ [13, 1], [18, 1], [19, 1], [17, 1], [26, 27], [20, 21], [6, 7], [25, -1], [16, -1], [23, -1], [24, -1] ]
			Local $value1, $value2
			For $i = 0 To UBound($aMapping) - 1
				$value1 = $g_aBIOSInfo[1][$aMapping[$i][0]]
				$value2 = ""
				If $aMapping[$i][1] <> -1 Then
					$value2 = "." & $g_aBIOSInfo[1][$aMapping[$i][1]]
				EndIf
				_GUICtrlListView_AddSubItem($g_hListBiosInfo, $i, $value1 & $value2, 1)
			Next

		Case 2
			_GUICtrlListView_SetColumnWidth($g_hListBiosInfo, 0, 550)
			_GUICtrlListView_SetColumnWidth($g_hListBiosInfo, 1, 150)

			Local $decodeIndex
			For $i = 21 To 56
				$decodeIndex = $i - 17  ; Start from 4 (21 - 17)
				_GUICtrlListView_AddItem($g_hListBiosInfo, $g_aLangBIOSInfo[$i], Int(__DecodeBiosCharacteristic($decodeIndex)) + 1)
			Next

	EndSwitch

	_GUICtrlListView_EndUpdate($g_hListBiosInfo)

EndFunc


Func __GetBiosInformation()

	__WMI_BaseBoard($g_aBaseBoardInfo)
	If @error Then __ReturnWMIerror(@extended)

	__WMI_Bios($g_aBIOSInfo)
	If @error Then __ReturnWMIerror(@extended)

EndFunc


Func __WMI_BaseBoard(ByRef $g_aBaseBoardInfo)
	Local $colItems, $objWMIService, $objItem, $i = 1

	$objWMIService = ObjGet("winmgmts:\\" & @ComputerName & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_BaseBoard", "WQL", 0x30)

	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $g_aBaseBoardInfo[UBound($g_aBaseBoardInfo) + 1][28]
			$g_aBaseBoardInfo[$i][0]	= $objItem.Caption
			$g_aBaseBoardInfo[$i][1]	= __JoinExtendedInformation($objItem.ConfigOptions)
			$g_aBaseBoardInfo[$i][2]	= $objItem.CreationClassName
			$g_aBaseBoardInfo[$i][3]	= $objItem.Depth
			$g_aBaseBoardInfo[$i][4]	= $objItem.Description
			$g_aBaseBoardInfo[$i][5]	= $objItem.Height
			$g_aBaseBoardInfo[$i][6]	= $objItem.HostingBoard
			$g_aBaseBoardInfo[$i][7]	= $objItem.HotSwappable
			$g_aBaseBoardInfo[$i][8]	= __StringToDate($objItem.InstallDate)
			$g_aBaseBoardInfo[$i][9]	= $objItem.Manufacturer
			$g_aBaseBoardInfo[$i][10]	= $objItem.Model
			$g_aBaseBoardInfo[$i][11]	= $objItem.Name
			$g_aBaseBoardInfo[$i][12]	= $objItem.OtherIdentifyingInfo
			$g_aBaseBoardInfo[$i][13]	= $objItem.PartNumber
			$g_aBaseBoardInfo[$i][14]	= $objItem.PoweredOn
			$g_aBaseBoardInfo[$i][15]	= $objItem.Product
			$g_aBaseBoardInfo[$i][16]	= $objItem.Removable
			$g_aBaseBoardInfo[$i][17]	= $objItem.Replaceable
			$g_aBaseBoardInfo[$i][18]	= $objItem.RequirementsDescription
			$g_aBaseBoardInfo[$i][19]	= $objItem.RequiresDaughterBoard
			$g_aBaseBoardInfo[$i][20]	= $objItem.SerialNumber
			$g_aBaseBoardInfo[$i][21]	= $objItem.SKU
			$g_aBaseBoardInfo[$i][22]	= $objItem.SlotLayout
			$g_aBaseBoardInfo[$i][23]	= $objItem.Status
			$g_aBaseBoardInfo[$i][24]	= $objItem.Tag
			$g_aBaseBoardInfo[$i][25]	= $objItem.Version
			$g_aBaseBoardInfo[$i][26]	= $objItem.Weight
			$g_aBaseBoardInfo[$i][27]	= $objItem.Width

			$i += 1
		Next
		$g_aBaseBoardInfo[0][0] = UBound($g_aBaseBoardInfo) - 1
		If $g_aBaseBoardInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc ;_ComputerGetMotherboard


Func __WMI_Bios(ByRef $g_aBIOSInfo)
	Local $colItems, $objWMIService, $objItem, $i = 1

	$objWMIService = ObjGet("winmgmts:\\" & @ComputerName & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_BIOS", "WQL", 0x30)

	If IsObj($colItems) Then
		For $objItem In $colItems
			ReDim $g_aBIOSInfo[UBound($g_aBIOSInfo) + 1][30]

			$g_aBiosCharacteristics = $objItem.BiosCharacteristics
			$g_aBIOSInfo[$i][0]  = __JoinExtendedInformation($objItem.BIOSVersion)
			$g_aBIOSInfo[$i][1]  = $objItem.BuildNumber
			$g_aBIOSInfo[$i][2]  = $objItem.Caption
			$g_aBIOSInfo[$i][3]  = $objItem.CodeSet
			$g_aBIOSInfo[$i][4]  = $objItem.CurrentLanguage
			$g_aBIOSInfo[$i][5]  = $objItem.Description
			$g_aBIOSInfo[$i][6]  = $objItem.EmbeddedControllerMajorVersion
			$g_aBIOSInfo[$i][7]  = $objItem.EmbeddedControllerMinorVersion
			$g_aBIOSInfo[$i][8]  = $objItem.IdentificationCode
			$g_aBIOSInfo[$i][9]  = $objItem.InstallableLanguages
			$g_aBIOSInfo[$i][10] = __StringToDate($objItem.InstallDate)
			$g_aBIOSInfo[$i][11] = $objItem.LanguageEdition
			$g_aBIOSInfo[$i][12] = __JoinExtendedInformation($objItem.ListOfLanguages)
			$g_aBIOSInfo[$i][13] = $objItem.Manufacturer
			$g_aBIOSInfo[$i][14] = $objItem.Name
			$g_aBIOSInfo[$i][15] = $objItem.OtherTargetOS
			$g_aBIOSInfo[$i][16] = $objItem.PrimaryBIOS
			$g_aBIOSInfo[$i][17] = __StringToDate($objItem.ReleaseDate)
			$g_aBIOSInfo[$i][18] = $objItem.SerialNumber
			$g_aBIOSInfo[$i][19] = $objItem.SMBIOSBIOSVersion
			$g_aBIOSInfo[$i][20] = $objItem.SMBIOSMajorVersion
			$g_aBIOSInfo[$i][21] = $objItem.SMBIOSMinorVersion
			$g_aBIOSInfo[$i][22] = $objItem.SMBIOSPresent
			$g_aBIOSInfo[$i][23] = $objItem.SoftwareElementID
			$g_aBIOSInfo[$i][24] = __SoftwareElementState($objItem.SoftwareElementState)
			$g_aBIOSInfo[$i][25] = $objItem.Status
			$g_aBIOSInfo[$i][26] = $objItem.SystemBiosMajorVersion
			$g_aBIOSInfo[$i][27] = $objItem.SystemBiosMinorVersion
			$g_aBIOSInfo[$i][28] = $objItem.TargetOperatingSystem
			$g_aBIOSInfo[$i][29] = $objItem.Version
			$i += 1
		Next
		$g_aBIOSInfo[0][0] = UBound($g_aBIOSInfo) - 1
		If $g_aBIOSInfo[0][0] < 1 Then
			SetError(1, 1, 0)
		EndIf
	Else
		SetError(1, 2, 0)
	EndIf
EndFunc


Func __DecodeBiosCharacteristic($iCharacteristic)

	_ArraySearch($g_aBiosCharacteristics, $iCharacteristic)
	If @error Then
		Return False
	Else
		Return True
	EndIf

EndFunc


Func __ConvertBoolToYesNo($b)

	If $b = True Then
		Return "Yes"
	ElseIf $b = False Then
		Return "No"
	EndIf

EndFunc


Func __SoftwareElementState($sItem)

	Local $iItem = 99
	Local $sReturn = ""

	If IsNumber($sItem) Then
		$iItem = Int($sItem)
	EndIf

	Switch $iItem
		Case 0
			$sReturn = "Deployable"
		Case 1
			$sReturn = "Installable"
		Case 2
			$sReturn = "Executable"
		Case 3
			$sReturn = "Running"
		Case Else
			$sReturn = "Unknown"
	EndSwitch

	Return $sReturn

EndFunc


Func __StringToDate($dtmDate)
	Return (StringMid($dtmDate, 5, 2) & "/" & _
			StringMid($dtmDate, 7, 2) & "/" & StringLeft($dtmDate, 4) _
			& " " & StringMid($dtmDate, 9, 2) & ":" & StringMid($dtmDate, 11, 2) & ":" & StringMid($dtmDate,13, 2))
EndFunc


Func __JoinExtendedInformation($aArray, $sSeparator = " - ")

	Local $n, $sOut = ""

    If IsObj($aArray) Then
        For $value In $aArray
            $sOut &= $value & $sSeparator
        Next
        Return StringTrimRight($sOut, StringLen($sSeparator))
    Else
        For $n = 0 To UBound($aArray) - 1
            $sOut &= $aArray[$n] & $sSeparator
        Next
        Return StringTrimRight($sOut, StringLen($sSeparator))
    EndIf

EndFunc


Func __ReturnWMIError($sWMIError)

	Local $sErrorMessage = "Oops... Something went wrong!"
	If $sWMIError = 1 Then
		$sErrorMessage = "Array contains no information!"
	ElseIf $sWMIError = 2 Then
		$sErrorMessage = "$colItems isnt an object!"
	EndIf

	MsgBox($MB_ICONERROR,  "WMI Error!", $sErrorMessage)

EndFunc   ;==>_ReturnWMIerror


Func MyErrFunc()

	Local $sErrMessage = ""
	$sErrMessage &= "Error Number: " & Hex($oMyError.Number, 8) & @CRLF & @CRLF
	$sErrMessage &= "Description: " & @CRLF & $oMyError.WinDescription & @CRLF
	MsgBox($MB_ICONERROR, "Oops, something went wrong!", $sErrMessage)

	SetError(1)

Endfunc

#EndRegion "BIOS Information"


#Region "Events"

Func _SelectBiosPage()
    ; Handle the GUI state of buttons and tabs
    _HandleGuiState()
    ; Execute actions based on which button was clicked
    _ExecuteButtonAction()
EndFunc   ;==>_SelectBiosPage

Func _HandleGuiState()
    For $iBP = 0 To $CNT_BIOSBUTTONS - 1
        GUICtrlSetState($g_aBiosButtons[$iBP], $GUI_UNCHECKED)
        If @GUI_CtrlId = $g_aBiosButtons[$iBP] Then
            GUICtrlSetState($g_aBiosButtons[$iBP], $GUI_CHECKED)
            GUICtrlSetState($g_aBiosTabs[$iBP], $GUI_SHOW)
        EndIf
    Next
EndFunc   ;==>_HandleGuiState

Func _ExecuteButtonAction()
    Switch @GUI_CtrlId
        Case $g_aBiosButtons[1]
            _DisplayAMIBeepCodes()
        Case $g_aBiosButtons[2]
            _DisplayASTBeepCodes()
        Case $g_aBiosButtons[3]
            _DisplayAwardBeepCodes()
        Case $g_aBiosButtons[4]
            _DisplayCompaqBeepCodes()
        Case $g_aBiosButtons[5]
            _DisplayDellBeepCodes()
		Case $g_aBiosButtons[6]
			_DisplayIBMBeepCodes()
		Case $g_aBiosButtons[7]
			_DisplayPhoenixBeepCodes()
        Case Else
            GUICtrlSetData($g_hEditDetails, $g_aLangBeepInfo[0])
    EndSwitch
EndFunc   ;==>_ExecuteButtonAction

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

		If $iCursor[4] = $g_hIconDonate And $g_aDonateIcons[2] == 1 Then
			$g_aDonateIcons[2] = 0
			GUICtrlSetImage($g_hIconDonate, $g_aDonateIcons[1], $g_iAboutIconStart + 1)
		ElseIf $iCursor[4] <> $g_hIconDonate And $g_aDonateIcons[2] == 0 Then
			$g_aDonateIcons[2] = 1
			GUICtrlSetImage($g_hIconDonate, $g_aDonateIcons[0], $g_iAboutIconStart)
		EndIf

		If $iCursor[4] = $g_hLblDonate And $g_iDonateLabelHover == 1 Then
			$g_iDonateLabelHover = 0
			GUICtrlSetColor($g_hLblDonate, 0x0D559D)
		ElseIf $iCursor[4] <> $g_hLblDonate And $g_iDonateLabelHover == 0 Then
			$g_iDonateLabelHover = 1
			GUICtrlSetColor($g_hLblDonate, 0x000000)
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
		Case $SC_MOVE, $SC_SIZE
			$i_DRAGFULLWINDOWS_Current = _SPI_GETDRAGFULLWINDOWS()
			DllCall("user32.dll", "int", "SystemParametersInfo", "int", 37, "int", 0, "ptr", 0, "int", 2)
	EndSwitch
EndFunc   ;==>WM_SYSCOMMAND


Func WM_EXITSIZEMOVE($hWnd, $msg, $wParam, $lParam)
	DllCall("user32.dll", "int", "SystemParametersInfo", "int", 37, "int", $i_DRAGFULLWINDOWS_Current, "ptr", 0, "int", 2)
EndFunc   ;==>WM_EXITSIZEMOVE


Func _Reset_DRAGFULLWINDOWS()
	DllCall("user32.dll", "int", "SystemParametersInfo", "int", 37, "int", $i_DRAGFULLWINDOWS_Initial, "ptr", 0, "int", 2)
EndFunc   ;==>_Reset_DRAGFULLWINDOWS


Func _SPI_GETDRAGFULLWINDOWS()
	Local $tBool = DllStructCreate("int")
	DllCall("user32.dll", "int", "SystemParametersInfo", "int", 38, "int", 0, "ptr", DllStructGetPtr($tBool), "int", 0)
	Return DllStructGetData($tBool, 1)
EndFunc   ;==>_SPI_GETDRAGFULLWINDOWS

#EndRegion "Events"


#Region "Resources"

Func _SetResources()

	If @Compiled Then

		$g_aCoreIcons[0] 	= @ScriptFullPath
		$g_aCoreIcons[1] 	= @ScriptFullPath
		$g_aDonateIcons[0] 	= @ScriptFullPath
		$g_aDonateIcons[1] 	= @ScriptFullPath

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

		$g_aCoreIcons[0]   = "..\..\..\SDK\Resources\Icons\" & $g_sProgShortName & ".ico"
		$g_aCoreIcons[1]   = "..\..\..\SDK\Resources\Icons\" & $g_sProgShortName & "H.ico"
		$g_aDonateIcons[0] = "..\..\..\SDK\Resources\Icons\About\PayPal.ico"
		$g_aDonateIcons[1] = "..\..\..\SDK\Resources\Icons\About\PayPalH.ico"

		$g_aLognIcons[0] = "..\..\..\SDK\Resources\Icons\logging\Information.ico"
		$g_aLognIcons[1] = "..\..\..\SDK\Resources\Icons\logging\Complete.ico"
		$g_aLognIcons[2] = "..\..\..\SDK\Resources\Icons\logging\Cross.ico"
		$g_aLognIcons[3] = "..\..\..\SDK\Resources\Icons\logging\Exclamation.ico"
		$g_aLognIcons[4] = "..\..\..\SDK\Resources\Icons\logging\Smiley-Glass.ico"
		$g_aLognIcons[5] = "..\..\..\SDK\Resources\Icons\logging\Skull.ico"
		$g_aLognIcons[6] = "..\..\..\SDK\Resources\Icons\logging\Snowman.ico"

		$g_aLanguageIcons[0]  = "..\..\..\SDK\Resources\Icons\Flags\en.ico"
		$g_aLanguageIcons[1]  = "..\..\..\SDK\Resources\Icons\Flags\af.ico"
		$g_aLanguageIcons[2]  = "..\..\..\SDK\Resources\Icons\Flags\ar.ico"
		$g_aLanguageIcons[3]  = "..\..\..\SDK\Resources\Icons\Flags\bg.ico"
		$g_aLanguageIcons[4]  = "..\..\..\SDK\Resources\Icons\Flags\cs.ico"
		$g_aLanguageIcons[5]  = "..\..\..\SDK\Resources\Icons\Flags\da.ico"
		$g_aLanguageIcons[6]  = "..\..\..\SDK\Resources\Icons\Flags\de.ico"
		$g_aLanguageIcons[7]  = "..\..\..\SDK\Resources\Icons\Flags\el.ico"
		$g_aLanguageIcons[8]  = "..\..\..\SDK\Resources\Icons\Flags\es.ico"
		$g_aLanguageIcons[9]  = "..\..\..\SDK\Resources\Icons\Flags\fr.ico"
		$g_aLanguageIcons[10] = "..\..\..\SDK\Resources\Icons\Flags\hi.ico"
		$g_aLanguageIcons[11] = "..\..\..\SDK\Resources\Icons\Flags\hr.ico"
		$g_aLanguageIcons[12] = "..\..\..\SDK\Resources\Icons\Flags\hu.ico"
		$g_aLanguageIcons[13] = "..\..\..\SDK\Resources\Icons\Flags\id.ico"
		$g_aLanguageIcons[14] = "..\..\..\SDK\Resources\Icons\Flags\ir.ico"
		$g_aLanguageIcons[15] = "..\..\..\SDK\Resources\Icons\Flags\is.ico"
		$g_aLanguageIcons[16] = "..\..\..\SDK\Resources\Icons\Flags\it.ico"
		$g_aLanguageIcons[17] = "..\..\..\SDK\Resources\Icons\Flags\iw.ico"
		$g_aLanguageIcons[18] = "..\..\..\SDK\Resources\Icons\Flags\ja.ico"
		$g_aLanguageIcons[19] = "..\..\..\SDK\Resources\Icons\Flags\ko.ico"
		$g_aLanguageIcons[20] = "..\..\..\SDK\Resources\Icons\Flags\nl.ico"
		$g_aLanguageIcons[21] = "..\..\..\SDK\Resources\Icons\Flags\no.ico"
		$g_aLanguageIcons[22] = "..\..\..\SDK\Resources\Icons\Flags\pl.ico"
		$g_aLanguageIcons[23] = "..\..\..\SDK\Resources\Icons\Flags\pt.ico"
		$g_aLanguageIcons[24] = "..\..\..\SDK\Resources\Icons\Flags\pt-BR.ico"
		$g_aLanguageIcons[25] = "..\..\..\SDK\Resources\Icons\Flags\ro.ico"
		$g_aLanguageIcons[26] = "..\..\..\SDK\Resources\Icons\Flags\ru.ico"
		$g_aLanguageIcons[27] = "..\..\..\SDK\Resources\Icons\Flags\sl.ico"
		$g_aLanguageIcons[28] = "..\..\..\SDK\Resources\Icons\Flags\sk.ico"
		$g_aLanguageIcons[29] = "..\..\..\SDK\Resources\Icons\Flags\sv.ico"
		$g_aLanguageIcons[30] = "..\..\..\SDK\Resources\Icons\Flags\th.ico"
		$g_aLanguageIcons[31] = "..\..\..\SDK\Resources\Icons\Flags\tr.ico"
		$g_aLanguageIcons[32] = "..\..\..\SDK\Resources\Icons\Flags\vi.ico"
		$g_aLanguageIcons[33] = "..\..\..\SDK\Resources\Icons\Flags\zh-CN.ico"
		$g_aLanguageIcons[34] = "..\..\..\SDK\Resources\Icons\Flags\zh-TW.ico"

		$g_aMenuIcons[0]  = "..\..\..\SDK\Resources\Icons\Menus\Gear.ico"
		$g_aMenuIcons[1]  = "..\..\..\SDK\Resources\Icons\Menus\Logbook.ico"
		$g_aMenuIcons[2]  = "..\..\..\SDK\Resources\Icons\Menus\Close.ico"
		$g_aMenuIcons[3]  = "..\..\..\SDK\Resources\Icons\Menus\Update.ico"
		$g_aMenuIcons[4]  = "..\..\..\SDK\Resources\Icons\Menus\Home.ico"
		$g_aMenuIcons[5]  = "..\..\..\SDK\Resources\Icons\Menus\Support.ico"
		$g_aMenuIcons[6]  = "..\..\..\SDK\Resources\Icons\Menus\GitHub.ico"
		$g_aMenuIcons[7]  = "..\..\..\SDK\Resources\Icons\Menus\About.ico"

		$g_sDlgOptionsIcon = $g_sThemesDir & "\Icons\Dialogs\Gear.ico"

	EndIf

	$g_aCoreIcons[2] 	= 1
	$g_aDonateIcons[2]	= 1

EndFunc   ;==>_SetResources

#EndRegion "Resources"


#Region "Working Directories"

Func _ResetWorkingDirectories()

	$g_sPathIni = $g_sWorkingDir & "\" & $g_sProgShortName & ".ini"
	$g_sLoggingRoot = $g_sWorkingDir & "\Logging\" & $g_sProgShortName
	$g_sLoggingPath = $g_sLoggingRoot & "\" & $g_sProgShortName & ".log"

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
	$g_iLoggingEnabled = Int(IniRead($g_sPathIni, $g_sProgShortName, "LoggingEnabled", 1))
	$g_iLoggingStorage = Int(IniRead($g_sPathIni, $g_sProgShortName, "LoggingStorageSize", 5242880))
	$g_sDonateName = IniRead($g_sPathIni, "Donate", "DonateName", "Unknown")
	$g_iDonateBuild = Number(IniRead($g_sPathIni, "Donate", "DonateBuild", 13))

	If @Compiled Then
		ProcessSetPriority(@ScriptName, $g_iProcessPriority)
	EndIf
EndFunc   ;==>_LoadConfiguration


Func _SaveConfiguration()

	; _SaveSelection()

EndFunc

#EndRegion "Configuration (Settings)"


#Region "Updates"
Func _CheckForUpdates()

	_SetUpdateAnimationState($GUI_SHOW)
	_SoftwareUpdateCheck(True)
	_SetUpdateAnimationState($GUI_HIDE)
	GUICtrlSetColor($g_hSubHeading, 0x353535)

EndFunc   ;==>_CheckForUpdates


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
		GUICtrlSetData($g_hSubHeading, StringFormat($g_aLangCustom[0], $g_aLangCustom[11]))

	EndIf

EndFunc   ;==>_SetUpdateAnimationState

#EndRegion "Updates"


Func _SetProcessingStates($iState)

	GUICtrlSetState($g_hMenuFile, $iState)
	GUICtrlSetState($g_hMenuHelp, $iState)
	GUICtrlSetState($g_hMenuDebug, $iState)

EndFunc   ;==>_SetProcessingStates


Func _ReduceMemory()

	Local $aMemStats = MemGetStats()

	If $aMemStats[0] > $g_iMaxSysMemoryPerc And $g_iReduceMemory = 1 Then
		_WinAPI_EmptyWorkingSet()
	EndIf

EndFunc


Func _ShutdownProgram()

	AdlibUnRegister("_OnIconsHover")
	If @Compiled Then
		AdlibUnRegister("_ReduceMemory")
	EndIf

	_SaveConfiguration()

	If StringCompare($g_sDonateName, @ComputerName, $STR_NOCASESENSEBASIC) <> 0 Or Number(_GetProgramVersion(4)) <> $g_iDonateBuild Then

		IniWrite($g_sPathIni, "Donate", "DonateName", @ComputerName)
		IniWrite($g_sPathIni, "Donate", "DonateBuild", _GetProgramVersion(4))
		_Donate_ShowDialog()

	Else
		WinSetTrans($g_hCoreGui, Default, 255)
		Exit
	EndIf

EndFunc   ;==>_ShutdownProgram


Func _TerminateProgram()

	_Reset_DRAGFULLWINDOWS()

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

	$g_hOptionsGui = GUICreate($g_aLangPreferences[0], 450, 500, -1, -1, BitOR($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST, $g_iParent)
	GUISetFont(Default, Default, Default, "Verdana", $g_hOptionsGui, 5)
	If $g_iParentState > 0 Then GUISetIcon($g_sDlgOptionsIcon, $g_iDialogIconStart + 2, $g_hAboutGui)
	GUISetOnEvent($GUI_EVENT_CLOSE, "__CloseOptionsDlg", $g_hOptionsGui)
	GUIRegisterMsg($WM_NOTIFY, "__LanguageListEvents")

	GUICtrlCreateTab(10, 10, 430, 430)

	GUICtrlCreateTabItem(StringFormat(" %s ", $g_aLangPreferences[1]))
	GUICtrlCreateGroup($g_aLangPreferences[4], 25, 50, 400, 160)
	GUICtrlSetFont(-1, 10, Default, 2)
	$g_hOChkLogEnabled = GUICtrlCreateCheckbox($g_aLangPreferences[8], 35, 90, 200, 20)
	GUICtrlSetState($g_hOChkLogEnabled, $g_iLoggingEnabled)
	GUICtrlCreateLabel($g_aLangPreferences[9], 35, 120, 180, 20)
	$g_hOInLogSize = GUICtrlCreateInput(Round($g_iLoggingStorage / 1024, 2), 215, 118, 100, 20)
	GUICtrlSetStyle($g_hOInLogSize, BitOr($ES_RIGHT, $ES_NUMBER))
	GUICtrlSetFont(-1, 9, 400, 0, "Verdana")
	GUICtrlCreateLabel("KB", 325, 120, 50, 20)
	$g_hOInLogSizeTemp = Int(GUICtrlRead($g_hOInLogSize))
	$g_hOLblLogSize = GUICtrlCreateLabel(StringFormat($g_aLangPreferences[10], __GetLoggingSize()), 35, 160, 200, 20)
	GUICtrlSetColor($g_hOLblLogSize, 0x555555)
	$g_hOBtnLogClear = GUICtrlCreateButton($g_aLangPreferences[11], 255, 155, 150, 30)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	GUICtrlSetOnEvent($g_hOChkLogEnabled, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOBtnLogClear, "__RemoveLoggingFile")
		;GUICtrlSetState($g_ReBarChkLogEnabled, $g_ReBarLogEnabled)
	__CheckLoggingStateChanged()
	GUICtrlCreateTabItem("") ; end tabitem definition

	GUICtrlCreateTabItem(StringFormat(" %s ", $g_aLangPreferences[2]))
	GUICtrlCreateGroup($g_aLangPreferences[5], 25, 50, 400, 130)
	GUICtrlSetFont(-1, 10, Default, 2)
	GUICtrlCreateLabel($g_aLangPreferences[12], 35, 80, 300, 20)
	GUICTrlSetColor(-1, 0x555555)
	$g_hOComboPower = GUICtrlCreateCombo("", 35, 105, 200, 30)
	GUICtrlSetData($g_hOComboPower, "Low|Below Normal|Normal|Above Normal|High|Realtime", "Normal")
	GUICtrlSetFont($g_hOComboPower, 10, 400)
	If @Compiled Then
		$g_hOIconPower = GUICtrlCreateIcon(@ScriptFullPath, $g_iPowerIconsStart, 350, 80, 48, 48)
	Else
		$g_hOIconPower = GUICtrlCreateIcon("..\..\..\SDK\Resources\Icons\Power\Power-0.ico", 0, 350, 80, 48, 48)
	EndIf
	$g_hOChkSaveRealtime = GUICtrlCreateCheckbox($g_aLangPreferences[17], 35, 145, 360, 20)
	GUICtrlSetState($g_hOChkSaveRealtime, $g_iSaveRealtime)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	_SetProcessInfo()
	GUICtrlSetOnEvent($g_hOComboPower, "_SetProcessPriority")
	GUICtrlSetOnEvent($g_hOChkSaveRealtime, "__CheckPreferenceChange")

	GUICtrlCreateGroup($g_aLangPreferences[6], 25, 200, 400, 70)
	GUICtrlSetFont(-1, 10, Default, 2)
	$g_hOChkReduceMemory = GUICtrlCreateCheckbox($g_aLangPreferences[14], 35, 235, 360, 20)
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
	GUICtrlCreateGroup($g_aLangPreferences[7], 25, 50, 400, 350)
	GUICtrlSetFont(-1, 10, Default, 2)

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
	GUICtrlCreateLabel(StringFormat($g_aLangPreferences[15], $g_aLangPreferences[16]), 40, 350, 365, 35)
	GUICtrlSetColor(-1, 0x555555)
	GUICtrlSetFont(-1, 9)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
	GUICtrlCreateTabItem("") ; end tabitem definition

	$g_hOLblPrefsUpdated = GUICtrlCreateLabel($g_aLangPreferences[12], 25, 455, 200, 20)
	GUICtrlSetColor($g_hOLblPrefsUpdated, 0x008000)
	GUICtrlSetState($g_hOLblPrefsUpdated, $GUI_HIDE)
	$g_hOBtnSave = GUICtrlCreateButton($g_aLangPreferences[16], 210, 450, 100, 30)
	GUICtrlSetFont($g_hOBtnSave, 10)
	GUICtrlSetState($g_hOBtnSave, $GUI_FOCUS)
	GUICtrlSetState($g_hOBtnSave, $GUI_DISABLE)
	GUICtrlSetOnEvent($g_hOBtnSave, "__SavePreferences")

	$g_hOBtnCancel = GUICtrlCreateButton($g_aLangPreferences[17], 320, 450, 100, 30)
	GUICtrlSetFont($g_hOBtnCancel, 10)
	GUICtrlSetOnEvent($g_hOBtnCancel, "__CloseOptionsDlg")

	GUISetState(@SW_SHOW, $g_hOptionsGui)
	AdlibRegister("__CheckLoggingSizeChange", 500)

EndFunc


Func __RemoveLoggingFile()

	GUICtrlSetState($g_hOBtnLogClear, $GUI_DISABLE)
	DirRemove($g_sLoggingRoot, 1)

	If $g_iLoggingEnabled = 1 Then
		_Logging_Initialize()
	EndIf

	GUICtrlSetData($g_hOLblLogSize, StringFormat($g_aLangPreferences[10], __GetLoggingSize()))
	GUICtrlSetData($g_hOLblPrefsUpdated, $g_aLangPreferences[19])
	GUICtrlSetState($g_hOLblPrefsUpdated, $GUI_SHOW)
	GUICtrlSetState($g_hOBtnLogClear, $GUI_ENABLE)

EndFunc


Func __GetLoggingSize()

	If FileExists($g_sLoggingRoot) Then
		Return Round(DirGetSize($g_sLoggingRoot) / 1024, 2)
	Else
		Return 0
	EndIf

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

	If __CheckBoxChanged("LoggingEnabled", $g_hOChkLogEnabled) = True Or _
		__CheckBoxChanged("SaveRealtime", $g_hOChkSaveRealtime) = True Or _
		__CheckBoxChanged("ReduceMemory", $g_hOChkReduceMemory) = True Then
		GUICtrlSetState($g_hOBtnSave, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hOBtnSave, $GUI_DISABLE)
	EndIf

	__CheckLoggingStateChanged()
	GUICtrlSetState($g_hOLblPrefsUpdated, $GUI_HIDE)

EndFunc


Func __CheckLoggingStateChanged()

	If GUICtrlRead($g_hOChkLogEnabled) = $GUI_CHECKED Then
		GUICtrlSetState($g_hOInLogSize, $GUI_ENABLE)
		GUICtrlSetState($g_hOBtnLogClear, $GUI_ENABLE)
	Else
		GUICtrlSetState($g_hOInLogSize, $GUI_DISABLE)
		GUICtrlSetState($g_hOBtnLogClear, $GUI_DISABLE)
	EndIf

EndFunc


Func __CheckLoggingSizeChange()

	Local $iLogTemp = Int(GUICtrlRead($g_hOInLogSize))

	If $g_hOInLogSizeTemp <> $iLogTemp Then
		GUICtrlSetState($g_hOBtnSave, $GUI_ENABLE)
		$g_hOInLogSizeTemp = $iLogTemp
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

	If $g_tSelectedLanguage <> $g_sSelectedLanguage Then
		Local $iMsgBoxResult = MsgBox($MB_OKCANCEL + $MB_ICONINFORMATION, $g_aLangPreferences[20], $g_aLangPreferences[21], 0, $g_hOptionsGui)
		Switch $iMsgBoxResult
			Case 1
				IniWrite($g_sPathIni, $g_sProgShortName, "Language", $g_tSelectedLanguage)
				GUICtrlSetData($g_hOLblPrefsUpdated, $g_aLangPreferences[20])
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

	If GUICtrlRead($g_hOChkLogEnabled) = $GUI_CHECKED Then
		$g_iLoggingEnabled = 1
	ElseIf GUICtrlRead($g_hOChkLogEnabled) = $GUI_UNCHECKED Then
		$g_iLoggingEnabled = 0
	EndIf
	$g_iLoggingStorage = Int(GUICtrlRead($g_hOInLogSize)) * 1024

	If $g_iSaveRealtime = 0 And $g_iProcessPriority = 5 Then
		IniWrite($g_sPathIni, $g_sProgShortName, "ProcessPriority", 4)
	Else
		IniWrite($g_sPathIni, $g_sProgShortName, "ProcessPriority", $g_iProcessPriority)
	EndIf

	IniWrite($g_sPathIni, $g_sProgShortName, "SaveRealtime", $g_iSaveRealtime)
	IniWrite($g_sPathIni, $g_sProgShortName, "ReduceMemory", $g_iReduceMemory)
	IniWrite($g_sPathIni, $g_sProgShortName, "LoggingEnabled", $g_iLoggingEnabled)
	IniWrite($g_sPathIni, $g_sProgShortName, "LoggingStorageSize", $g_iLoggingStorage)

	If $iLangChanged = True Then
		$iMsgBoxResult = MsgBox($MB_OKCANCEL + $MB_ICONINFORMATION, $g_aLangPreferences[22], $g_aLangPreferences[23], 0, $g_hOptionsGui)
		Switch $iMsgBoxResult
			Case 1
				_ShutdownProgram()
			Case 2
				$iLangChanged = False
		EndSwitch
	Else
		GUICtrlSetData($g_hOLblPrefsUpdated, $g_aLangPreferences[18])
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

	If $g_iParentState > 0 Then
		WinSetTrans($g_hCoreGui, Default, 255)
		GUISetState(@SW_ENABLE, $g_hCoreGui)
	EndIf
	AdlibUnRegister("__CheckLoggingSizeChange")
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
