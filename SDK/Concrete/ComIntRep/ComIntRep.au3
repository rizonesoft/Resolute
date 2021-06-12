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
#AutoIt3Wrapper_Icon=..\..\Resources\Icons\ComIntRep.ico		;~ Filename of the Ico file to use for the compiled exe
#AutoIt3Wrapper_OutFile_Type=exe								;~ exe=Standalone executable (Default); a3x=Tokenised AutoIt3 code file
#AutoIt3Wrapper_OutFile=..\..\..\Resolute\ComIntRep.exe			;~ Target exe/a3x filename.
#AutoIt3Wrapper_OutFile_X64=..\..\..\Resolute\ComIntRep_X64.exe	;~ Target exe filename for X64 compile.
;#AutoIt3Wrapper_Compression=4									;~ Compression parameter 0-4  0=Low 2=normal 4=High. Default=2
;#AutoIt3Wrapper_UseUpx=Y										;~ (Y/N) Compress output program.  Default=Y
;#AutoIt3Wrapper_UPX_Parameters=								;~ Override the default settings for UPX.
#AutoIt3Wrapper_Change2CUI=N									;~ (Y/N) Change output program to CUI in stead of GUI. Default=N
#AutoIt3Wrapper_Compile_both=Y									;~ (Y/N) Compile both X86 and X64 in one run. Default=N
;===============================================================================================================
; Target Program Resource info
;===============================================================================================================
#AutoIt3Wrapper_Res_Comment=Complete Internet Repair			;~ Comment field
#AutoIt3Wrapper_Res_Description=Complete Internet Repair      	;~ Description field
#AutoIt3Wrapper_Res_Fileversion=8.1.3.5261
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y  				;~ (Y/N/P) AutoIncrement FileVersion. Default=N
#AutoIt3Wrapper_Res_FileVersion_First_Increment=N				;~ (Y/N) AutoIncrement Y=Before; N=After compile. Default=N
#AutoIt3Wrapper_Res_HiDpi=N                      				;~ (Y/N) Compile for high DPI. Default=N
#AutoIt3Wrapper_Res_ProductVersion=8             				;~ Product Version
#AutoIt3Wrapper_Res_Language=2057								;~ Resource Language code . Default 2057=English (United Kingdom)
#AutoIt3Wrapper_Res_LegalCopyright=© 2021 Rizonesoft			;~ Copyright field
#AutoIt3Wrapper_res_requestedExecutionLevel=highestAvailable	;~ asInvoker, highestAvailable, requireAdministrator or None (remove the trsutInfo section).  Default is the setting from Aut2Exe (asInvoker)
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
#AutoIt3Wrapper_Res_Field=ProductName|Complete Internet Repair
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
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRepH.ico					; 201

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

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Information1.ico		; 269
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Information2.ico		; 270
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Run1.ico				; 271
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Run2.ico				; 272
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Complete.ico			; 273
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Cross.ico				; 274

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-0.ico			; 275
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-1.ico			; 276
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-2.ico			; 277
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-3.ico			; 278
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-4.ico			; 279
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-5.ico			; 280
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-6.ico			; 281
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-7.ico			; 282
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-8.ico			; 283
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-9.ico			; 284
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-10.ico			; 285
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-11.ico			; 286
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-12.ico			; 287
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ComIntRep\Repair-13.ico			; 288

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Eventvwr.ico				; 289
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Gear.ico					; 269
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Logbook.ico				; 270
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Close.ico					; 271
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Update.ico					; 272
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Home.ico					; 273
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Support.ico				; 274
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\GitHub.ico					; 275
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\About.ico					; 276
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\IPProperties.ico			; 292
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\RestorePoint.ico			; 294
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\NdWeb.ico					; 295
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\NdNetworkAdapter.ico		; 296
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\InternetDiagnostic.ico		; 297
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\NdInbound.ico				; 298
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\HomeGroupDiag.ico			; 299
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\NdFileShare.ico			; 300
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\WinUpdateDiag.ico			; 301
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\SpeedTest.ico				; 302
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\RouterPass.ico				; 303
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\RemoteDesktop.ico			; 304
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\InternetProperties.ico		; 305

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\SelectAll.ico			; 311
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Commands\Save.ico				; 312


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
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <Process.au3>
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
#include "..\..\Includes\Logging.au3"
#include "..\..\Includes\Registry.au3"
#include "..\..\Includes\Splash.au3"
#include "..\..\Includes\StringEx.au3"
#include "..\..\Includes\Update.au3"
#include "..\..\Includes\Versioning.au3"

#include "Includes\Localization.au3"


;~ Developer Constants
Global Const $DEBUG_UPDATE		= False
;~ Constants
Global Const $CNT_MENUICONS		= 25
Global Const $CNT_LOGICONS		= 7
Global Const $CNT_LANGICONS		= 35
Global Const $CNT_COMMICONS		= 20

Global Const $CNT_REPAIR 		= 14
Global Const $SPACING_LINE		= 20

Global Const $CNT_NOTICE		= 3

;~ General Settings
Global $g_sCompanyName			= "Rizonesoft"
Global $g_sProgShortName		= "ComIntRep"
Global $g_sProgShortName_X64	= $g_sProgShortName & "_X64"
Global $g_sProgName				= "Complete Internet Repair"
Global $g_iSingleton			= True

;~ Links
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
Global $g_sUrlProgPage			= "https://www.rizonesoft.com/downloads/complete-internet-repair/|www.rizonesoft.com/downloads/complete-internet-repair"
Global $g_sUrlUpdate			= "https://www.rizonesoft.com/downloads/update/?id=comintrep|www.rizonesoft.com/downloads/update/"
Global $g_sUrlWinRepair         = "https://www.rizonesoft.com/downloads/complete-windows-repair/|www.rizonesoft.com/downloads/complete-windows-repair/"

;~ Path Settings
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
Global $g_sDataStore 		= @WindowsDir & "\SoftwareDistribution\DataStore"
Global $g_sDataStoreOld 	= @WindowsDir & "\SoftwareDistribution\DataStore.Old"
Global $g_sSoftDisDown		= @WindowsDir & "\SoftwareDistribution\Download"
Global $g_sSoftDisDownOld 	= @WindowsDir & "\SoftwareDistribution\Download.Old"
Global $g_sCatroot 			= @WindowsDir & "\System32\CatRoot"
Global $g_sCatrootOld 		= @WindowsDir & "\System32\CatRoot.Old"
Global $g_sCatroot2 		= @WindowsDir & "\System32\CatRoot2"
Global $g_sCatroot2Old 		= @WindowsDir & "\System32\CatRoot2.Old"

;~ Configuration Settings
Global $g_iBackupData		= 0
Global $g_iBackupIPData 	= 1

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
Global $g_iLangIconStart				= 228
Global $g_iPowerIconsStart				= 263
Global $g_iComIconStart					= 269
Global $g_iMenuIconsStart				= 289

Global $g_aCoreIcons[3]
Global $g_iSizeIcon						= 64
Global $g_aLognIcons[$CNT_LOGICONS]
Global $g_aLanguageIcons[$CNT_LANGICONS]
Global $g_aMenuIcons[$CNT_MENUICONS]
Global $g_aCommIcons[$CNT_COMMICONS]
Global $g_sSelectAllIcon
Global $g_sSaveIcon
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
Global $g_iDonateTimeSet	= 10800 ; 10800 = 3 Hours | 86400 = Day | 259200 = 3 Days (Default) | 432000 = 5 Days

;~ Title Settings
Global $g_TitleShowAdmin	= False	;~ Show whether program is running as Administrator
Global $g_TitleShowArch		= True	;~ Show program architecture
Global $g_TitleShowVersion	= True	;~ Show program version
Global $g_TitleShowBuild	= True	;~ Show program build
Global $g_TitleShowAutoIt	= False	;~ Show AutoIt version

;~ Interface Settings
Global $g_iCoreGuiWidth		= 488
Global $g_iCoreGuiHeight	= 500
Global $g_iMsgBoxTimeOut	= 60

Global $g_sAboutCredits		= "Derick Payne (Rizonesoft), Brian J Christy (Beege), " & _
							"G Sandler (MrCreatoR), Holger Kotsch, KaFu, LarsJ, nickston, ProgAndy, Yashied"
Global $g_sProgramTitle = _GUIGetTitle($g_sProgName)	;~ Get Program Ttile, including version.
Global $g_hCoreGui, $g_hCoreGuiHandle					;~ Main GUI
Global $g_hGuiIcon										;~ Main Icon
Global $g_AniUpdate
Global $g_AniProcessing
Global $g_hMenuFile
Global $g_hMenuMaintenance
Global $g_hMenuTrouble
Global $g_miTrouble[10]
Global $g_miExport[4]
Global $g_hMenuTools
Global $g_hMenuHelp, $g_hUpdateMenuItem
Global $g_hMenuDebug
Global $g_hSubHeading
Global $g_hSubNotice
Global $g_hCoreGuiCoords, $g_hBtnExtend, $g_hGuiExpanded = True

If Not IsDeclared("g_iParentState") Then Global $g_iParentState
If Not IsDeclared("g_iParent") Then Global $g_iParent

Global $g_hOptionsGui
Global $g_hOIconPower
Global $g_hOComboPower
Global $g_hOChkSaveRealtime
Global $g_hOChkReduceMemory
Global $g_hOChkBackupData
Global $g_hOChkExportIP
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
Global $g_hPicNotice

Global $g_iProcessPriority 		= 3
Global $g_iSaveRealtime			= 0
Global $g_iReduceMemory 		= 1
Global $g_iReduceEveryMill 		= 300
Global $g_iMaxSysMemoryPerc 	= 80
;~ Global $g_iSaveSelection		= 4

Global $g_aRepair[$CNT_REPAIR][8]
Global $g_aRepairHovering[$CNT_REPAIR][2]
Global $g_aRepairState[$CNT_REPAIR][3]

Global $g_hBtnGo, $g_IntExplVersion
Global $g_hChkSelectAll
;~ Global $g_hChkSaveSelection
Global $g_iCancel, $g_iSoloProcess = True
Global $g_iRebootRequired
Global $g_iResetWinsock = True
Global $g_iClearWinUpdate = True
Global $g_iResetProxy = True
Global $g_iResetFirewall = True
Global $g_iShowCwrMessage = False
Global $g_bRandomNotice = 0

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
		_Localization_File()		;~ Load File Language Strings
		_Splash_Update($g_aLangMessages[9], 6)
		_SetResources()
		_Splash_Update($g_aLangMessages[11], 9)
		_LoadConfiguration()
		_Splash_Update($g_aLangMessages[12], 12)
		_Logging_Initialize($g_sProgName)
		_Splash_Update($g_aLangMessages[13], 15)
		_SetHotKeys()
		_Splash_Update($g_aLangMessages[14], 18)
		_StartCoreGui()

	EndIf

EndIf


Func _SetHotKeys()

	HotKeySet("{ESC}", "_MinimizeProgram")
	HotKeySet("^a", "_SelectAllHot")

EndFunc


Func _SelectAllHot()

	If GUICtrlRead($g_hChkSelectAll) = $GUI_CHECKED Then
		GUICtrlSetState($g_hChkSelectAll, $GUI_UNCHECKED)
	Else
		GUICtrlSetState($g_hChkSelectAll, $GUI_CHECKED)
	EndIf
	_SelectAll()

EndFunc


Func _StartCoreGui()

	Local $miFileEventLog, $miFileOptions, $mnuFileLog, $miLogOpenFile, $miLogOpenRoot, $miTcpResLog, $miFileClose, $miFileReboot
	Local $mnuFileExport, $miExportIP, $miExportLSP, $miExportARP, $miExportNetBIOS, $miMaintRestore
	Local $miTroubleHomeGroup, $miNdFileShare, $miTroubleUpdate, $miTroubleIEDiag, $miTroubleIESecDiag, $miTroubleSpeed, $miTroubleRoutPass
	Local $miToolsInIP6, $miToolsUnIP6, $miToolsWorkGroups, $miToolsRDP, $miToolsIEP
	Local $miHelpHome, $miHelpDownloads, $miHelpSupport, $miHelpGitHub, $miHelpDonate, $miHelpAbout
	Local $hHeading

	If @DesktopHeight <= 768 Then
		$g_hGuiExpanded = False
	EndIf

	$g_hCoreGui = GUICreate($g_sProgramTitle, $g_iCoreGuiWidth, $g_iCoreGuiHeight, -1, -1)
	If Not @Compiled Then GUISetIcon($g_aCoreIcons[0])
	GUISetFont(8.5, 400, -1, "Verdana", $g_hCoreGui, $CLEARTYPE_QUALITY)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ShutdownProgram", $g_hCoreGui)

	$g_hMenuFile = GUICtrlCreateMenu($g_aLangMenus[0])
	GUICtrlSetFont($g_hMenuFile, 8.5)
	$g_hMenuMaintenance = GUICtrlCreateMenu($g_aLangMenus[14])
	$g_hMenuTrouble = GUICtrlCreateMenu($g_aLangMenus[16])
	$g_hMenuTools = GUICtrlCreateMenu($g_aLangMenus[29])
	$g_hMenuHelp = GUICtrlCreateMenu($g_aLangMenus[35])

	$g_hCoreGuiHandle = WinGetHandle($g_hCoreGui)
	$g_hCoreGuiCoords = WinGetPos($g_hCoreGuiHandle)

	_GuiCtrlMenuEx_SetMenuIconBkColor(0xF0F0F0)
	_GuiCtrlMenuEx_SetMenuIconBkGrdColor(0xFFFFFF)

	$miFileEventLog = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[1], $g_hMenuFile, $g_aMenuIcons[0], $g_iMenuIconsStart)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuFile)
	$miFileOptions = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[2], $g_hMenuFile, $g_aMenuIcons[1], $g_iMenuIconsStart + 1)
	$mnuFileLog = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[3], $g_hMenuFile)
	$miLogOpenFile = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[4], $mnuFileLog, $g_aMenuIcons[2], $g_iMenuIconsStart + 2)
	$miLogOpenRoot = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[5], $mnuFileLog)
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_2003" Then
		_GuiCtrlMenuEx_CreateMenuItem("", $mnuFileLog)
		$miTcpResLog = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[6], $mnuFileLog)
	EndIf
	$mnuFileExport = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[7], $g_hMenuFile, $g_aMenuIcons[3], $g_iMenuIconsStart + 9)
	$g_miExport[0] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[8], $mnuFileExport)
	$g_miExport[1] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[9], $mnuFileExport)
	$g_miExport[2] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[10], $mnuFileExport)
	$g_miExport[3] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[11], $mnuFileExport)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuFile)
	$miFileReboot = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[12], $g_hMenuFile)
	$miFileClose = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[13], $g_hMenuFile, $g_aMenuIcons[4], $g_iMenuIconsStart + 3)

	GUICtrlSetOnEvent($miFileEventLog, "_StartEventLog")
	GUICtrlSetOnEvent($miFileOptions, "_ShowPreferencesDlg")
	GUICtrlSetOnEvent($miLogOpenFile, "_Logging_OpenFile")
	GUICtrlSetOnEvent($miLogOpenRoot, "_Logging_OpenDirectory")

	For $e = 0 To UBound($g_miExport) - 1
		GUICtrlSetOnEvent($g_miExport[$e], "_ExportCommand")
	Next

	GUICtrlSetOnEvent($miFileReboot, "_Reboot")
	GUICtrlSetOnEvent($miFileClose, "_ShutdownProgram")

	$miMaintRestore = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[15], $g_hMenuMaintenance, $g_aMenuIcons[5], $g_iMenuIconsStart + 10)
	GUICtrlSetOnEvent($miMaintRestore, "_OpenWindowsSystemRestore")

	If @OSVersion <> "WIN_XP" And @OSVersion <> "WIN_2003" Then

		$g_miTrouble[0] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[17], $g_hMenuTrouble, $g_aMenuIcons[6], $g_iMenuIconsStart + 11)
		$g_miTrouble[1] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[18], $g_hMenuTrouble, $g_aMenuIcons[7], $g_iMenuIconsStart + 12)
		$g_miTrouble[2] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[19], $g_hMenuTrouble, $g_aMenuIcons[8], $g_iMenuIconsStart + 13)
		$g_miTrouble[3] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[20], $g_hMenuTrouble, $g_aMenuIcons[9], $g_iMenuIconsStart + 14)
		$g_miTrouble[4] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[21], $g_hMenuTrouble, $g_aMenuIcons[10], $g_iMenuIconsStart + 15)
		$g_miTrouble[5] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[22], $g_hMenuTrouble, $g_aMenuIcons[11], $g_iMenuIconsStart + 16)
		_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuTrouble)
		$g_miTrouble[6] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[23], $g_hMenuTrouble)
		$g_miTrouble[7] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[24], $g_hMenuTrouble, $g_aMenuIcons[12], $g_iMenuIconsStart + 17)
		_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuTrouble)
		$g_miTrouble[8] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[25], $g_hMenuTrouble)
		$g_miTrouble[9] = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[26], $g_hMenuTrouble)
		_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuTrouble)

		For $x = 0 To UBound($g_miTrouble) - 1
			GUICtrlSetOnEvent($g_miTrouble[$x], "_OpenTroubleshootingID")
		Next

		If Not _GetTroubleshootingInstalled("NetworkDiagnostics_1_Web") Then GUICtrlSetState($g_miTrouble[0], $GUI_DISABLE)
		If Not _GetTroubleshootingInstalled("NetworkDiagnostics_4_NetworkAdapter") Then GUICtrlSetState($g_miTrouble[1], $GUI_DISABLE)
		If Not _GetTroubleshootingInstalled("InternetDiagnostic") Then GUICtrlSetState($g_miTrouble[2], $GUI_DISABLE)
		If Not _GetTroubleshootingInstalled("NetworkDiagnostics_5_Inbound") Then GUICtrlSetState($g_miTrouble[3], $GUI_DISABLE)
		If Not _GetTroubleshootingInstalled("NetworkDiagnostics_3_HomeGroup") Then GUICtrlSetState($g_miTrouble[4], $GUI_DISABLE)
		If Not _GetTroubleshootingInstalled("NetworkDiagnostics_2_FileShare") Then GUICtrlSetState($g_miTrouble[5], $GUI_DISABLE)
		If Not _GetTroubleshootingInstalled("BITSDiagnostic") Then GUICtrlSetState($g_miTrouble[6], $GUI_DISABLE)
		If Not _GetTroubleshootingInstalled("WindowsUpdateDiagnostic") Then GUICtrlSetState($g_miTrouble[7], $GUI_DISABLE)
		If Not _GetTroubleshootingInstalled("IEDiagnostic") Then GUICtrlSetState($g_miTrouble[8], $GUI_DISABLE)
		If Not _GetTroubleshootingInstalled("IESecurityDiagnostic") Then GUICtrlSetState($g_miTrouble[9], $GUI_DISABLE)

	EndIf

	$miTroubleSpeed = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[27], $g_hMenuTrouble, $g_aMenuIcons[13], $g_iMenuIconsStart + 18)
	$miTroubleRoutPass = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[28], $g_hMenuTrouble, $g_aMenuIcons[14], $g_iMenuIconsStart + 19)
	GUICtrlSetOnEvent($miTroubleSpeed, "_SpeedTest")
	GUICtrlSetOnEvent($miTroubleRoutPass, "_GetRouterPasswords")

	$miToolsRDP = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[30], $g_hMenuTools, $g_aMenuIcons[15], $g_iMenuIconsStart + 20)
	$miToolsIEP = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[31], $g_hMenuTools, $g_aMenuIcons[16], $g_iMenuIconsStart + 21)

	GUICtrlSetOnEvent($miToolsRDP, "_OpenRDP")
	GUICtrlSetOnEvent($miToolsIEP, "_OpenIEProperties")

	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_2003" Then

		_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuTools)
		$miToolsInIP6 = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[32], $g_hMenuTools)
		$miToolsUnIP6 = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[33], $g_hMenuTools)
		_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuTools)
		$miToolsWorkGroups = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[34], $g_hMenuTools)

		GUICtrlSetOnEvent($miToolsInIP6, "_InstallIP6")
		GUICtrlSetOnEvent($miToolsUnIP6, "_UnInstallIP6")
		GUICtrlSetOnEvent($miToolsWorkGroups, "_RepairWorkGroups")

	EndIf

	$g_hUpdateMenuItem = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[36], $g_hMenuHelp, $g_aMenuIcons[17], $g_iMenuIconsStart + 4)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpHome = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[37], $g_hMenuHelp, $g_aMenuIcons[18], $g_iMenuIconsStart + 5)
	; $miHelpDownloads = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[38], $g_hMenuHelp)
	$miHelpSupport = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[39], $g_hMenuHelp, $g_aMenuIcons[19], $g_iMenuIconsStart + 6)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpGitHub = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[40], $g_hMenuHelp, $g_aMenuIcons[20], $g_iMenuIconsStart + 7)
	$miHelpDonate = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[41], $g_hMenuHelp)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuHelp)
	$miHelpAbout = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[42], $g_hMenuHelp, $g_aMenuIcons[21], $g_iMenuIconsStart + 8)

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
			$g_aLangAbout[3] & " Â© " & @YEAR & " " & $g_sCompanyName, _
			$g_aLangAbout[0], $TIP_INFOICON)
	GUICtrlSetCursor($g_hGuiIcon, 0)
	GUICtrlSetOnEvent($g_hGuiIcon, "_About_ShowDialog")
	$g_AniUpdate = GUICtrlCreateIcon($g_sUpdateAnimation, 0, 10, 5, $g_iSizeIcon, $g_iSizeIcon)
	$g_AniProcessing = GUICtrlCreateIcon($g_sProcessingAnimation, 0, 10, 5, $g_iSizeIcon, $g_iSizeIcon)
	GUICtrlSetState($g_AniUpdate, $GUI_HIDE)
	GUICtrlSetState($g_AniProcessing, $GUI_HIDE)
	$hHeading = GUICtrlCreateLabel($g_sProgName & " " & _GetProgramVersion(1), $g_iSizeIcon + 22, 10, 300, 25)
	GUICtrlSetFont($hHeading, 12)

	$g_hSubHeading = GUICtrlCreateLabel($g_aLangCustom[0], $g_iSizeIcon + 22, 33, 350, 50)
	GUICtrlSetFont($g_hSubHeading, 10)
	GUICtrlSetColor($g_hSubHeading, 0x353535)

	If $g_iShowCwrMessage Then
		$g_hSubNotice = GUICtrlCreateLabel($g_aLangCustom[35], $g_iSizeIcon + 22, 38, $g_iCoreGuiWidth - 45 - $g_iSizeIcon, 50)
		GUICtrlSetColor($g_hSubNotice, 0xC80B0B)
		GUICtrlSetCursor($g_hSubNotice, 0)
		GUICtrlSetOnEvent($g_hSubNotice, "_GoTo_WinRepair")
	Else
		$g_hSubNotice = GUICtrlCreateLabel($g_aLangCustom[0], $g_iSizeIcon + 22, 38, $g_iCoreGuiWidth - 45 - $g_iSizeIcon, 50)
		GUICtrlSetColor($g_hSubNotice, 0xD24925)
	EndIf
	GUICtrlSetFont($g_hSubNotice, 10)
	GUICtrlSetState($g_hSubHeading, $GUI_HIDE)

	$g_IntExplVersion = _GetInternetExplorerVersion()

	GUICtrlCreateIcon($g_sSelectAllIcon, 311, 20, 93, 16, 16)
	$g_hChkSelectAll = GUICtrlCreateCheckbox(Chr(32) & $g_aLangCustom[37], 43, 93, 155, 16)
;~ 	GUICtrlCreateIcon($g_sSaveIcon, 312, 198, 93, 16, 16)
;~ 	$g_hChkSaveSelection = GUICtrlCreateCheckbox(Chr(32) & "Save Selection on Exit", 221, 93, 250, 16)
;~ 	GUICtrlSetOnEvent($g_hChkSaveSelection, "_SetSaveSelection")

	GUICtrlCreateGroup("", 10, 110, $g_iCoreGuiWidth - 20, 305)
	For $iR = 0 To $CNT_REPAIR - 1

		$g_aRepair[$iR][0] = GUICtrlCreateIcon($g_aCommIcons[$iR + 6], $g_iComIconStart + 6 + $iR, 20, 128 + ($iR * $SPACING_LINE), 16, 16)
		$g_aRepair[$iR][1] = GUICtrlCreateCheckbox(Chr(32) & $g_aLangCustom[$iR + 2], 43, 128 + ($iR * $SPACING_LINE), 325, 16)
		$g_aRepair[$iR][2] = GUICtrlCreateIcon($g_aCommIcons[0], $g_iComIconStart, 423, 128 + ($iR * $SPACING_LINE), 16, 16)
		GUICtrlSetCursor($g_aRepair[$iR][2], 0)
		$g_aRepair[$iR][3] = GUICtrlCreateIcon($g_aCommIcons[2], $g_iComIconStart + 2, 443, 128 + ($iR * $SPACING_LINE), 16, 16)
		GUICtrlSetCursor($g_aRepair[$iR][3], 0)
		$g_aRepair[$iR][4] = 145 + ($iR * $SPACING_LINE)
		$g_aRepair[$iR][5] = GUICtrlCreateLabel("", 43, $g_aRepair[$iR][4], 380, 1)
		GUICtrlSetBkColor($g_aRepair[$iR][5], 0xD9D9D9)
		$g_aRepair[$iR][6] = GUICtrlCreateLabel("", 43, $g_aRepair[$iR][4], 1, 1)
		GUICtrlSetBkColor($g_aRepair[$iR][6], 0x3399FF)
		GUICtrlSetState($g_aRepair[$iR][6], $GUI_HIDE)

		GUICtrlSetOnEvent($g_aRepair[$iR][1], "_TestSelectAll")
		GUICtrlSetOnEvent($g_aRepair[$iR][2], "_ShowRepairInfo")
		GUICtrlSetOnEvent($g_aRepair[$iR][3], "_RunSelectedOption")

	Next

	GUICtrlSetData($g_aRepair[5][1],  Chr(32) & StringFormat($g_aLangCustom[7], $g_IntExplVersion))
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

;~ 	GUICtrlSetState($g_hChkSaveSelection, $g_iSaveSelection)
;~ 	If $g_iSaveSelection = 1 Then
		_LoadSelection()
;~ 	EndIf
	_TestSelectAll()

	$g_hBtnExtend = GUICtrlCreateCheckbox(6, 10, 443, 30, 28, $BS_PUSHLIKE)
	GUICtrlSetFont($g_hBtnExtend, 10, 400, 0, "Webdings")
	GUICtrlSetTip($g_hBtnExtend, $g_aLangCustom[16])
	$g_hBtnGo = GUICtrlCreateButton($g_aLangCustom[18], 280, 428, 190, 43)
	GUICtrlSetState($g_hBtnGo, $GUI_FOCUS)
	GUICtrlSetFont($g_hBtnGo, 11, 400, 0, "Verdana")

	GUICtrlSetOnEvent($g_hBtnGo, "_RunSelectedOption")
	GUICtrlSetOnEvent($g_hBtnExtend, "_GUIExtender")
	GUICtrlSetOnEvent($g_hChkSelectAll, "_SelectAll")

	$g_hListStatus = GUICtrlCreateListView("", 10, 485, _
			$g_iCoreGuiWidth - 20, $g_GuiLogBoxHeight, BitOR($LVS_REPORT, $LVS_NOCOLUMNHEADER))
	_GUICtrlListView_SetExtendedListViewStyle($g_hListStatus, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_DOUBLEBUFFER, _
			$LVS_EX_SUBITEMIMAGES, $LVS_EX_INFOTIP, $WS_EX_CLIENTEDGE))
	_GUICtrlListView_AddColumn($g_hListStatus, "", 680)
	_WinAPI_SetWindowTheme(GUICtrlGetHandle($g_hListStatus), "Explorer")
	GUICtrlSetFont($g_hListStatus, 9, -1, -1, "Courier New")
	GUICtrlSetColor($g_hListStatus, 0x333333)
	GUICtrlSetState($g_hListStatus, $GUI_HIDE)

	$g_hImgStatus = _GUIImageList_Create(16, 16, 5, 1, 8, 8)
	For $iLx = 0 To $CNT_LOGICONS - 1
		_ImageListEx_AddBlankIcon($g_hImgStatus, $g_hListStatus, $g_aLognIcons[$iLx], $g_iLogIconStart - $iLx)
	Next
	_GUIImageList_Add($g_hImgStatus, _GUICtrlListView_CreateSolidBitMap($g_hListStatus, 0xFFFFFF, 16, 16))
	_GUICtrlListView_SetImageList($g_hListStatus, $g_hImgStatus, 1)

	$g_hEditInfo = GUICtrlCreateEdit("", 10, 485, $g_iCoreGuiWidth - 20, $g_GuiLogBoxHeight, BitOR($WS_VSCROLL, $ES_READONLY, $ES_AUTOVSCROLL))
	GUICtrlSetBkColor($g_hEditInfo, 0xE8FFCC)
	GUICtrlSetFont($g_hEditInfo, 9)
	GUICtrlSetData($g_hEditInfo, StringFormat($g_aLangCustom[20], $g_aLangCustom[18]))

	_Splash_Update("Initializing States", 99)
	_InitializeStates()

	_Splash_Update("", 100)
	GUISetState(@SW_SHOW, $g_hCoreGui)
	GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")
	AdlibRegister("_OnIconsHover", 65)
	AdlibRegister("_UptimeMonitor", 1000)
	If @Compiled Then
		AdlibRegister("_ReduceMemory", $g_iReduceEveryMill)
	EndIf

	_GUIExtender()
	SoundPlay(@ScriptDir & "\Sounds\Welcome.wav")

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

Func MY_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)

	Switch BitAND($wParam, 0xFFFF) ;LoWord = IDFrom
		Case $g_hBtnGo
			Switch BitShift($wParam, 16) ;HiWord = Code
				Case $BN_CLICKED
					If GUICtrlRead($g_hBtnGo) = $g_aLangCustom[19] Then
						$g_iCancel = True
						GUICtrlSetState($g_hBtnGo, $GUI_DISABLE)
						GUICtrlSetData($g_hSubHeading, $g_aLangMessages2[2])
						GUICtrlSetColor($g_hSubHeading, 0xC80B0B)
					Else
						$g_iCancel = False
					EndIf
			EndSwitch
	EndSwitch

	Return $GUI_RUNDEFMSG
EndFunc   ;==>MY_WM_COMMAND


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

		For $iRi = 0 To 1
			For $iRr = 0 To $CNT_REPAIR - 1
				If $iCursor[4] = $g_aRepair[$iRr][2 + $iRi] And $g_aRepairHovering[$iRr][$iRi] = 1 And _
						$g_aRepairState[$iRr][0] <> $GUI_DISABLE And _
						$g_aRepairState[$iRr][1] <> $GUI_DISABLE Then

					$g_aRepairHovering[$iRr][$iRi] = 0
					GUICtrlSetImage($g_aRepair[$iRr][2 + $iRi], $g_aCommIcons[1 + ($iRi * 2)], $g_iComIconStart + 1 + ($iRi * 2))

				ElseIf $iCursor[4] <> $g_aRepair[$iRr][2 + $iRi] And $g_aRepairHovering[$iRr][$iRi] = 0 Then
					$g_aRepairHovering[$iRr][$iRi] = 1
					GUICtrlSetImage($g_aRepair[$iRr][2 + $iRi], $g_aCommIcons[0 + ($iRi * 2)], $g_iComIconStart + ($iRi * 2))
				EndIf
			Next
		Next

	EndIf

EndFunc   ;==>_OnIconsHover

Func _GUIExtender()
	If IsArray($g_hCoreGuiCoords) Then
		If $g_hGuiExpanded = False Then
			_GUIRetract()
		ElseIf $g_hGuiExpanded = True Then
			_GUIExpand(140)
		EndIf
	EndIf
EndFunc   ;==>_GUIExtender


Func _GUIRetract()

	WinMove($g_hCoreGuiHandle, "", Default, Default, $g_hCoreGuiCoords[2], $g_hCoreGuiCoords[3])
	GUICtrlSetData($g_hBtnExtend, 6)
	GUICtrlSetState($g_hBtnExtend, $GUI_UNCHECKED)
	GUICtrlSetTip($g_hBtnExtend, $g_aLangCustom[16])
	$g_hGuiExpanded = True

EndFunc   ;==>_GUIRetract


Func _GUIExpand($iSize)

	WinMove($g_hCoreGuiHandle, "", Default, Default, $g_hCoreGuiCoords[2], $g_hCoreGuiCoords[3] + $iSize)
	GUICtrlSetData($g_hBtnExtend, 5)
	GUICtrlSetState($g_hBtnExtend, $GUI_CHECKED)
	GUICtrlSetTip($g_hBtnExtend, $g_aLangCustom[17])
	$g_hGuiExpanded = False

EndFunc   ;==>_GUIExpand


Func _SelectAll()

	If GUICtrlRead($g_hChkSelectAll) = $GUI_CHECKED Then
		For $iS = 0 To $CNT_REPAIR - 1
			GUICtrlSetState($g_aRepair[$iS][1], $GUI_CHECKED)
		Next
		GUICtrlSetData($g_hChkSelectAll, Chr(32) & $g_aLangCustom[38])
	Else
		For $iS = 0 To $CNT_REPAIR - 1
			GUICtrlSetState($g_aRepair[$iS][1], $GUI_UNCHECKED)
		Next
		GUICtrlSetData($g_hChkSelectAll, Chr(32) & $g_aLangCustom[37])
	EndIf

EndFunc


Func _TestSelectAll()

	Local $x = 0

	For $iSel = 0 To $CNT_REPAIR - 1
		If GUICtrlRead($g_aRepair[$iSel][1]) = $GUI_CHECKED Then
			$x += 1
		Else
			$x -= 1
		EndIf
	Next

	If $x = $CNT_REPAIR Then
		GUICtrlSetState($g_hChkSelectAll, $GUI_CHECKED)
		GUICtrlSetData($g_hChkSelectAll, Chr(32) & $g_aLangCustom[38])
	Else
		GUICtrlSetState($g_hChkSelectAll, $GUI_UNCHECKED)
		GUICtrlSetData($g_hChkSelectAll, Chr(32) & $g_aLangCustom[37])
	EndIF

EndFunc


;~ Func _SetSaveSelection()
;~ 	$g_iSaveSelection = GUICtrlRead($g_hChkSaveSelection)
;~ EndFunc

#EndRegion "Events"


#Region "States"

Func _InitializeStates()

	For $iRr = 0 To $CNT_REPAIR - 1
		$g_aRepairState[$iRr][0] = $GUI_ENABLE
		$g_aRepairState[$iRr][1] = $GUI_ENABLE
		$g_aRepairState[$iRr][2] = $GUI_CHECKED
	Next

EndFunc

#EndRegion "States"


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

		For $iCi = 0 To $CNT_COMMICONS - 1
			$g_aCommIcons[$iCi] = @ScriptFullPath
		Next

		$g_sDlgOptionsIcon = @ScriptFullPath
		$g_sSelectAllIcon = @ScriptFullPath
		$g_sSaveIcon = @ScriptFullPath

	Else

		$g_aCoreIcons[0] = "..\..\..\SDK\Resources\Icons\" & $g_sProgShortName & ".ico"
		$g_aCoreIcons[1] = "..\..\..\SDK\Resources\Icons\" & $g_sProgShortName & "H.ico"

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

		$g_aMenuIcons[0]  = "..\..\..\SDK\Resources\Icons\Menus\Eventvwr.ico"
		$g_aMenuIcons[1]  = "..\..\..\SDK\Resources\Icons\Menus\Gear.ico"
		$g_aMenuIcons[2]  = "..\..\..\SDK\Resources\Icons\Menus\Logbook.ico"
		$g_aMenuIcons[3]  = "..\..\..\SDK\Resources\Icons\Menus\IPProperties.ico"
		$g_aMenuIcons[4]  = "..\..\..\SDK\Resources\Icons\Menus\Close.ico"
		$g_aMenuIcons[5]  = "..\..\..\SDK\Resources\Icons\Menus\RestorePoint.ico"
		$g_aMenuIcons[6]  = "..\..\..\SDK\Resources\Icons\Menus\NdWeb.ico"
		$g_aMenuIcons[7]  = "..\..\..\SDK\Resources\Icons\Menus\NdNetworkAdapter.ico"
		$g_aMenuIcons[8]  = "..\..\..\SDK\Resources\Icons\Menus\InternetDiagnostic.ico"
		$g_aMenuIcons[9]  = "..\..\..\SDK\Resources\Icons\Menus\NdInbound.ico"
		$g_aMenuIcons[10] = "..\..\..\SDK\Resources\Icons\Menus\HomeGroupDiag.ico"
		$g_aMenuIcons[11] = "..\..\..\SDK\Resources\Icons\Menus\NdFileShare.ico"
		$g_aMenuIcons[12] = "..\..\..\SDK\Resources\Icons\Menus\WinUpdateDiag.ico"
		$g_aMenuIcons[13] = "..\..\..\SDK\Resources\Icons\Menus\SpeedTest.ico"
		$g_aMenuIcons[14] = "..\..\..\SDK\Resources\Icons\Menus\RouterPass.ico"
		$g_aMenuIcons[15] = "..\..\..\SDK\Resources\Icons\Menus\RemoteDesktop.ico"
		$g_aMenuIcons[16] = "..\..\..\SDK\Resources\Icons\Menus\InternetProperties.ico"
		$g_aMenuIcons[17] = "..\..\..\SDK\Resources\Icons\Menus\Update.ico"
		$g_aMenuIcons[18] = "..\..\..\SDK\Resources\Icons\Menus\Home.ico"
		$g_aMenuIcons[19] = "..\..\..\SDK\Resources\Icons\Menus\Support.ico"
		$g_aMenuIcons[20] = "..\..\..\SDK\Resources\Icons\Menus\GitHub.ico"
		$g_aMenuIcons[21] = "..\..\..\SDK\Resources\Icons\Menus\About.ico"

		$g_aCommIcons[0]  = "..\..\..\SDK\Resources\Icons\Commands\InformationH.ico"
		$g_aCommIcons[1]  = "..\..\..\SDK\Resources\Icons\Commands\Information.ico"
		$g_aCommIcons[2]  = "..\..\..\SDK\Resources\Icons\Commands\RunH.ico"
		$g_aCommIcons[3]  = "..\..\..\SDK\Resources\Icons\Commands\Run.ico"
		$g_aCommIcons[4]  = "..\..\..\SDK\Resources\Icons\Commands\Complete.ico"
		$g_aCommIcons[5]  = "..\..\..\SDK\Resources\Icons\Commands\Cross.ico"
		$g_aCommIcons[6]  = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-0.ico"
		$g_aCommIcons[7]  = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-1.ico"
		$g_aCommIcons[8]  = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-2.ico"
		$g_aCommIcons[9]  = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-3.ico"
		$g_aCommIcons[10] = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-4.ico"
		$g_aCommIcons[11] = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-5.ico"
		$g_aCommIcons[12] = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-6.ico"
		$g_aCommIcons[13] = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-7.ico"
		$g_aCommIcons[14] = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-8.ico"
		$g_aCommIcons[15] = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-9.ico"
		$g_aCommIcons[16] = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-10.ico"
		$g_aCommIcons[17] = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-11.ico"
		$g_aCommIcons[18] = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-12.ico"
		$g_aCommIcons[19] = "..\..\..\SDK\Resources\Icons\ComIntRep\Repair-13.ico"

		$g_sDlgOptionsIcon = "..\..\..\SDK\Resources\Icons\Dialogs\Gear.ico"
		$g_sSelectAllIcon = "..\..\..\SDK\Resources\Icons\SelectAll.ico"
		$g_sSaveIcon = "..\..\..\SDK\Resources\Icons\Save.ico"

	EndIf

	$g_aCoreIcons[2] = 1

EndFunc   ;==>_SetResources

#EndRegion "Resources"


#Region "Working Directories"

Func _ResetWorkingDirectories()

	$g_sPathIni = $g_sWorkingDir & "\" & $g_sProgShortName & ".ini"
	$g_sExportRoot = $g_sWorkingDir & "\Export"
	$g_sLoggingRoot = $g_sWorkingDir & "\Logging\" & $g_sProgShortName
	$g_sLoggingPath = $g_sLoggingRoot & "\" & $g_sProgShortName & ".log"
	$g_sLogIpResetPath	= $g_sLoggingRoot & "\IP_Reset.log"

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

	$g_iBackupData = Int(IniRead($g_sPathIni, $g_sProgShortName, "BackupData", 0))
	$g_iBackupIPData  = Int(IniRead($g_sPathIni, $g_sProgShortName, "BackupIPData", 1))
	$g_iCheckForUpdates = Int(IniRead($g_sPathIni, $g_sProgShortName, "CheckForUpdates", 4))
	$g_iProcessPriority = Int(IniRead($g_sPathIni, $g_sProgShortName, "ProcessPriority", 3))
	$g_iSaveRealtime = Int(IniRead($g_sPathIni, $g_sProgShortName, "SaveRealtime", 0))
	$g_iReduceMemory = Int(IniRead($g_sPathIni, $g_sProgShortName, "ReduceMemory", 1))
	$g_iReduceEveryMill = Int(IniRead($g_sPathIni, $g_sProgShortName, "ReduceEveryMill", 300))
	$g_iMaxSysMemoryPerc = Int(IniRead($g_sPathIni, $g_sProgShortName, "MinSysMemoryPerc", 80))
	$g_iLoggingEnabled = Int(IniRead($g_sPathIni, $g_sProgShortName, "LoggingEnabled", 1))
	$g_iLoggingStorage = Int(IniRead($g_sPathIni, $g_sProgShortName, "LoggingStorageSize", 5242880))
	$g_iUptimeMonitor = Int(IniRead($g_sPathIni, "Donate", "Seconds", 0))
	$g_iDonateTime = Int(IniRead($g_sPathIni, "Donate", "DonateTime", 0))

;~ 	$g_iSaveSelection = Int(IniRead($g_sPathIni, $g_sProgShortName, "SaveSelection", 1))

	If @Compiled Then
		ProcessSetPriority(@ScriptName, $g_iProcessPriority)
	EndIf

EndFunc   ;==>_LoadConfiguration


Func _SaveConfiguration()

;~ 	$g_iSaveSelection = GUICtrlRead($g_hChkSaveSelection)
;~ 	IniWrite($g_sPathIni, $g_sProgShortName, "SaveSelection", $g_iSaveSelection)
;~ 	If $g_iSaveSelection = 1 Then
		_SaveSelection()
;~ 	EndIf

	IniWrite($g_sPathIni, "Donate", "Seconds", $g_iUptimeMonitor)
	IniWrite($g_sPathIni, "Donate", "Seconds", $g_iUptimeMonitor)

EndFunc


Func _LoadSelection()

	For $iSel = 0 To $CNT_REPAIR - 1
		GUICtrlSetState($g_aRepair[$iSel][1], Int(IniRead($g_sPathIni, "Selection", $iSel, 1)))
	Next

EndFunc

Func _SaveSelection()

	For $iSel = 0 To $CNT_REPAIR - 1
		If GUICtrlRead($g_aRepair[$iSel][1]) = $GUI_CHECKED Then
			IniWrite($g_sPathIni, "Selection", $iSel, $GUI_CHECKED)
		Else
			IniWrite($g_sPathIni, "Selection", $iSel, $GUI_UNCHECKED)
		EndIf
	Next

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
	GUICtrlSetState($g_hMenuDebug, $iState)

EndFunc   ;==>_SetProcessingStates


Func _ShutdownProgram()

	AdlibUnRegister("_OnIconsHover")
	AdlibUnRegister("_UptimeMonitor")
	If @Compiled Then
		AdlibUnRegister("_ReduceMemory")
	EndIf

	_SaveConfiguration()

	If $g_iUptimeMonitor > $g_iDonateTimeSet = True And _
			$g_iDonateTime == 0 Then
		IniWrite($g_sPathIni, "Donate", "DonateTime", $g_iUptimeMonitor)
		_Donate_ShowDialog()
	Else
		WinSetTrans($g_hCoreGui, Default, 255)
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


#Region "Menu Events"

Func _StartEventLog()
	_Logging_Start($g_aLangMessages2[97])
	ShellExecute("eventvwr")
	_Logging_FinalMessage($g_aLangMessages2[98])

EndFunc   ;==>_StartEventLog


Func _ExportCommand()

	If Not FileExists($g_sExportRoot) Then DirCreate($g_sExportRoot)

	Switch @GUI_CtrlId
		Case $g_miExport[0]
			__ExportIPConfiguration()
		Case $g_miExport[1]
			__ExportWinsockLSPs()
		Case $g_miExport[2]
			__ExportARPEntries()
		Case $g_miExport[3]
			__ExportNetBIOSStatistics()
	EndSwitch

	_Logging_FinalMessage()

EndFunc   ;==>_ShowWinsockLSPs


Func _OpenWindowsSystemRestore()
	Run("systempropertiesprotection")
EndFunc   ;==>_OpenWindowsSystemRestore


Func _OpenTroubleshootingID()

	Switch @GUI_CtrlId
		Case $g_miTrouble[0]
			Run("msdt.exe /id NetworkDiagnosticsWeb")
		Case $g_miTrouble[1]
			Run("msdt.exe /id NetworkDiagnosticsNetworkAdapter")
		Case $g_miTrouble[2]
			;Run("msdt.exe /id NetworkDiagnosticsDA")
			Run("msdt.exe /id InternetDiagnostic")
		Case $g_miTrouble[3]
			Run("msdt.exe /id NetworkDiagnosticsInbound")
		Case $g_miTrouble[4]
			Run("msdt.exe /id HomeGroupDiagnostic")
		Case $g_miTrouble[5]
			Run("msdt.exe /id NetworkDiagnosticsFileShare")
		Case $g_miTrouble[6]
			Run("msdt.exe /id BITSDiagnostic")
		Case $g_miTrouble[7]
			Run("msdt.exe /id WindowsUpdateDiagnostic")
		Case $g_miTrouble[8]
			Run("msdt.exe /id IEDiagnostic")
		Case $g_miTrouble[9]
			Run("msdt.exe /id IESecurityDiagnostic")
	EndSwitch

EndFunc   ;==>_OpenTroubleshootingID


Func _SpeedTest()
	ShellExecute("http://www.speedtest.net")
EndFunc   ;==>_SpeedTest


Func _GetRouterPasswords()
	ShellExecute("http://www.routerpasswords.com")
EndFunc   ;==>_GetRouterPasswords


Func _OpenRDP()

	_Logging_Start($g_aLangMessages2[111])
	ShellExecute("mstsc")
	If @error Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[112], "ERROR"))
	EndIf
	_Logging_FinalMessage($g_aLangMessages2[113])

EndFunc   ;==>_OpenRDP


Func _OpenIEProperties()

	_Logging_Start($g_aLangMessages2[114])
	ShellExecute("inetcpl.cpl")
	If @error Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[115], "ERROR"))
	EndIf
	_Logging_FinalMessage($g_aLangMessages2[116])

EndFunc   ;==>_OpenIEProperties


Func _InstallIP6()

	_Logging_Start($g_aLangMessages2[117])
	_RunCommand("netsh int ipv6 install")
	_Logging_FinalMessage()

EndFunc   ;==>_InstallIP6


Func _UnInstallIP6()

	_Logging_Start($g_aLangMessages2[118])
	_RunCommand("netsh int ipv6 uninstall")
	_Logging_FinalMessage()

EndFunc   ;==>_UnInstallIP6


Func _RepairWorkGroups()

	_Logging_Start($g_aLangMessages2[119])
	RegDelete("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\NetBt\Parameters", "NodeType")
	RegDelete("HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\NetBt\Parameters", "DhcpNodeType")
	_Logging_FinalMessage()

EndFunc   ;==>_RepairWorkGroups


Func _GetTroubleshootingInstalled($sID)
	If FileExists(@WindowsDir & "\diagnostics\index\" & $sID & ".xml") Then
		Return True
	Else
		Return False
	EndIf
EndFunc


Func __ExportIPConfiguration()

	Local $sTimeStamp =  @YEAR & @MON & @MDAY & @HOUR & @MIN
	Local $sExportPath = $g_sExportRoot & "\IP-" & $sTimeStamp & ".txt"

	If @GUI_CtrlId = $g_miExport[0] Then
		_Logging_Start($g_aLangMessages2[99])
	Else
		_Logging_EditWrite($g_aLangMessages2[99])
	EndIf

	RunWait(@ComSpec & " /c ipconfig /all >" & Chr(34) & $sExportPath & Chr(34), "", @SW_HIDE)

	If FileExists($sExportPath) Then
		_Logging_EditWrite(StringFormat($g_aLangMessages2[100], $sExportPath))
		If @GUI_CtrlId = $g_miExport[0] Then
			_FileEx_OpenTextFile($sExportPath)
		EndIf
	Else
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[101], "ERROR"))
	EndIf

EndFunc


Func __ExportWinsockLSPs()

	Local $sTimeStamp =  @YEAR & @MON & @MDAY & @HOUR & @MIN
	Local $sExportPath = $g_sExportRoot & "\LSP-" & $sTimeStamp & ".txt"
	_Logging_Start($g_aLangMessages2[102])
	RunWait(@ComSpec & " /c netsh winsock show catalog >" & Chr(34) & $sExportPath & Chr(34), "", @SW_HIDE)

	If FileExists($sExportPath) Then
		_Logging_EditWrite(StringFormat($g_aLangMessages2[103], $sExportPath))
		_FileEx_OpenTextFile($sExportPath)
	Else
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[104], "ERROR"))
	EndIf

EndFunc


Func __ExportARPEntries()

	Local $sTimeStamp =  @YEAR & @MON & @MDAY & @HOUR & @MIN
	Local $sExportPath = $g_sExportRoot & "\ARP-" & $sTimeStamp & ".txt"
	_Logging_Start($g_aLangMessages2[105])
	RunWait(@ComSpec & " /c arp -a >" & Chr(34) & $sExportPath & Chr(34), "", @SW_HIDE)

	If FileExists($sExportPath) Then
		_Logging_EditWrite(StringFormat($g_aLangMessages2[106], $sExportPath))
		_FileEx_OpenTextFile($sExportPath)
	Else
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[107], "ERROR"))
	EndIf

EndFunc


Func __ExportNetBIOSStatistics()

	Local $sTimeStamp =  @YEAR & @MON & @MDAY & @HOUR & @MIN
	Local $sExportPath = $g_sExportRoot & "\NBIOS-" & $sTimeStamp & ".txt"
	_Logging_Start($g_aLangMessages2[108])
	RunWait(@ComSpec & " /c Nbtstat.exe -r >" & Chr(34) & $sExportPath & Chr(34), "", @SW_HIDE)

	If FileExists($sExportPath) Then
		_Logging_EditWrite(StringFormat($g_aLangMessages2[109], $sExportPath))
		_FileEx_OpenTextFile($sExportPath)
	Else
		_Logging_EditWrite(_Logging_SetLevel($g_aLangMessages2[110], "ERROR"))
	EndIf

EndFunc

#EndRegion "Menu Events"


#Region "Processing"

Func _RunSelectedOption()

	$g_iSoloProcess = True

	For $iRepair = 0 To $CNT_REPAIR - 1
		If @GUI_CtrlId = $g_aRepair[$iRepair][3] Then
			_ProcessSelectedOption($iRepair)
		EndIf
	Next

	If @GUI_CtrlId = $g_hBtnGo Then

		If $g_iCancel = False Then

			If _ProcessCheckedCount() > 0 Then

				_StartProcessing()
				GUICtrlSetData($g_hBtnGo, $g_aLangCustom[19])
				$g_iSoloProcess = False

				For $iRun = 0 To $CNT_REPAIR - 1
					If GUICtrlRead($g_aRepair[$iRun][1]) = $GUI_CHECKED Then
						If $g_iCancel = False Then
							_ProcessSelectedOption($iRun)
						EndIf
					EndIf
				Next

				; Reset Build Icons
				For $iRepair = 0 To $CNT_REPAIR - 1
					Local $iXz = ($iRepair + 6)
					_ResetProgress($iRepair)
					GUICtrlSetImage($g_aRepair[$iRepair][0], $g_aCommIcons[$iXz], $g_iComIconStart + $iXz)
				Next

				GUICtrlSetData($g_hBtnGo, $g_aLangCustom[18])
				$g_iSoloProcess = True
				GUICtrlSetState($g_hBtnGo, $GUI_ENABLE)
				GUICtrlSetData($g_hSubHeading, $g_aLangCustom[36])
				_EndProcessing()

			Else

				MsgBox(BitOr($MB_ICONWARNING, $MB_TOPMOST, $MB_APPLMODAL), _
						$g_aLangMessages2[0], $g_aLangMessages2[1], 60, $g_hCoreGui)

			EndIf

		EndIf

	EndIf

EndFunc   ;==>_RunSelectedOption


Func _ProcessSelectedOption($iAction)

	If $g_iSoloProcess = True Then _StartProcessing()

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
		Case 13
			_MakeNetComputersVisible($iAction)
	EndSwitch

	If $g_iSoloProcess = True Then _EndProcessing()

EndFunc


Func _ResetTCPIP($iRow)

	_Logging_Start($g_aLangMessages2[14])
	_StartSoloProcess($iRow)
	If $g_iBackupIPData Then
		__ExportIPConfiguration()
	EndIf
	If @OSVersion = "WIN_XP" And @OSVersion = "WIN_2003" Then
		_RunCommand("netsh interface ip reset " & Chr(34) & $g_sLogIpResetPath & Chr(34))
		_Logging_EditWrite(StringFormat($g_aLangMessages2[15], $g_sLogIpResetPath))
		_UpdateSoloProcess($iRow, 45)
		_Logging_EditWrite($g_aLangMessages2[16])
		_RunCommand("netsh interface reset all")
	Else
		_UpdateSoloProcess($iRow, 45)
		_Logging_EditWrite($g_aLangMessages2[16])
		_RunCommand("netsh interface ipv4 reset all")
	EndIf

	_UpdateSoloProcess($iRow, 90)
	_Logging_EditWrite($g_aLangMessages2[17])
	_RunCommand("netsh interface ipv6 reset all")

	_Logging_FinalMessage()
	_UpdateSoloProcess($iRow, 100)

EndFunc


Func _RepairWinsock($iRow, $IsInnerProcess = False)

	If Not $IsInnerProcess Then
		_StartSoloProcess($iRow)
		_Logging_Start($g_aLangMessages2[18])
			Sleep(250)
		_UpdateSoloProcess($iRow, 50)
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
		_UpdateSoloProcess($iRow, 100)
		If $g_iSoloProcess Then _BootMessage()
		_Logging_FinalMessage($g_aLangMessages2[20])
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
	_UpdateSoloProcess($iRow, 30)
	_RunCommand("ipconfig /release")
	_Logging_EditWrite($g_aLangMessages2[25])
	_UpdateSoloProcess($iRow, 60)
	_RunCommand("ipconfig /renew")

	If $g_iResetWinsock Then
;~ 		_Logging_EditWrite($g_aLangMessages2[26])
;~ 		_UpdateSoloProcess($iRow, 80)
;~ 		_RepairWinsock($iRow, True)
;~ 		If $g_iSoloProcess = True Then _BootMessage()
	EndIf

	_Logging_FinalMessage($g_aLangMessages2[27])
	_UpdateSoloProcess($iRow, 100)

EndFunc


Func _FlushReDNS($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start($g_aLangMessages2[28])
	_UpdateSoloProcess($iRow, 30)
	_Logging_EditWrite($g_aLangMessages2[29])
	_RunCommand("ipconfig /flushdns")
	_UpdateSoloProcess($iRow, 60)
	_Logging_EditWrite($g_aLangMessages2[30])
	_RunCommand("ipconfig /registerdns")
	_Logging_FinalMessage($g_aLangMessages2[31])
	_UpdateSoloProcess($iRow, 100)

EndFunc


Func _FlushARPCache($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start($g_aLangMessages2[32])
	_UpdateSoloProcess($iRow, 50)
	_RunCommand("netsh interface ip delete arpcache")
	_Logging_FinalMessage($g_aLangMessages2[33])
	_UpdateSoloProcess($iRow, 100)

EndFunc


Func _RepairInternetExplorer($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start(StringFormat($g_aLangMessages2[34], $g_IntExplVersion))
	Sleep(250)
	_UpdateSoloProcess($iRow, 1)
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
			_UpdateSoloProcess($iRow, Round($iDllPerc))
			$iPercChange = $iDllPerc
		EndIf

	Next

;~ Symptom: open in new tab/window not working
	_UpdateSoloProcess($iRow, 37)
	_Logging_EditWrite($g_aLangMessages2[36])
	__RegisterSystemDll("acelpdec.ax")
	__RegisterSystemDll("actxprxy.dll")
	_UpdateSoloProcess($iRow, 38)
	__RegisterSystemDll("asctrls.ocx")
	__RegisterSystemDll("browseui.dll")
	__RegisterSystemDll("browseui.dll", "/s /i")
	_UpdateSoloProcess($iRow, 39)
	__RegisterSystemDll("browsewm.dll")
	__RegisterSystemDll("cdfview.dll")
	__RegisterSystemDll("comcat.dll")
	_UpdateSoloProcess($iRow, 40)
	__RegisterSystemDll("comctl32.dll")
	__RegisterSystemDll("comctl32.dll", "/s /i")
	__RegisterSystemDll("comctl32.dll", "/s /i /n")
	_UpdateSoloProcess($iRow, 41)
	__RegisterSystemDll("corpol.dll")
	__RegisterSystemDll("CRSWPP.DLL")
	_UpdateSoloProcess($iRow, 42)
	__RegisterSystemDll("CRYPTDLG.DLL")
	__RegisterSystemDll("cryptdlg.dll")
	__RegisterSystemDll("cryptext.dll")
	__RegisterSystemDll("CSSEQCHK.DLL")
	_UpdateSoloProcess($iRow, 43)
	__RegisterSystemDll("danim.dll")
	__RegisterSystemDll("datime.dll")
	__RegisterSystemDll("Daxctle.ocx")
	_UpdateSoloProcess($iRow, 44)
	__RegisterSystemDll("dhtmled.ocx")
	__RegisterSystemDll("digest.dll", "/i /s")
	__RegisterSystemDll("digest.dll", "/s /i /n")
	_UpdateSoloProcess($iRow, 45)
	__RegisterSystemDll("directdb.dll")
	__RegisterSystemDll("dispex.dll")
	__RegisterSystemDll("DSSENH.DLL")
	_UpdateSoloProcess($iRow, 46)
	__RegisterSystemDll("dxmasf.dll")
	__RegisterSystemDll("dxtmsft.dll")
	__RegisterSystemDll("dxtrans.dll")
	__RegisterSystemDll("elshyph.dll")

;~ Symptom: Add-Ons-Manager menu entry is present but nothing happens
	_UpdateSoloProcess($iRow, 47)
	_Logging_EditWrite($g_aLangMessages2[37])
	__RegisterSystemDll("extmgr.dll")
	_UpdateSoloProcess($iRow, 48)
	__RegisterSystemDll("FLUPL.OCX")
	__RegisterSystemDll("FPWPP.DLL")
	_UpdateSoloProcess($iRow, 49)
	__RegisterSystemDll("FTPWPP.DLL")
	__RegisterSystemDll("Gpkcsp.dll")
	__RegisterSystemDll("hhctrl.ocx")

;~ Simple HTML Mail API
	_UpdateSoloProcess($iRow, 50)
	_Logging_EditWrite($g_aLangMessages2[38])
	__RegisterSystemDll("hlink.dll")
	_UpdateSoloProcess($iRow, 51)
	__RegisterSystemDll("hmmapi.dll")

	__RegisterSystemDll("icardie.dll")
	__RegisterSystemDll("icmfilter.dll")
	__RegisterSystemDll("ieadvpack.dll")

;~ Group policy snap-in
	_UpdateSoloProcess($iRow, 52)
	_Logging_EditWrite($g_aLangMessages2[39])
	__RegisterSystemDll("ieaksie.dll")

;~ Smart Screen
	_UpdateSoloProcess($iRow, 53)
	_Logging_EditWrite($g_aLangMessages2[40])
	__RegisterSystemDll("ieapfltr.dll")

;~ IEAK Branding
	_UpdateSoloProcess($iRow, 54)
	_Logging_EditWrite($g_aLangMessages2[41])
	__RegisterSystemDll("iedkcs32.dll")

;~ Dev Tools
	_UpdateSoloProcess($iRow, 55)
	_Logging_EditWrite($g_aLangMessages2[42])
	__RegisterSystemDll("iedvtool.dll")
	__RegisterSystemDll("ieetwcollectorres.dll")
	__RegisterSystemDll("ieetwproxystub.dll")

;~ IE7 tabbed browser
	_UpdateSoloProcess($iRow, 56)
	__RegisterSystemDll("ieframe.dll", "/s /i /n")
	__RegisterSystemDll("iepeers.dll")

;~ Symptom: IE8 closes immediately on launch, missing from IE7
	_UpdateSoloProcess($iRow, 57)
	_Logging_EditWrite($g_aLangMessages2[43])
	__RegisterSystemDll("ieproxy.dll")
	__RegisterSystemDll("iernonce.dll")
	__RegisterSystemDll("iertutil.dll")
	__RegisterSystemDll("iesetup.dll", "/s /i")
	__RegisterSystemDll("iesysprep.dll")
	__RegisterSystemDll("system32\ieui.dll")

	__RegisterSystemDll("ils.dll")
	_UpdateSoloProcess($iRow, 58)
	__RegisterSystemDll("imgutil.dll")
	__RegisterSystemDll("inetcfg.dll")
	__RegisterSystemDll("inetcomm.dll")
	_UpdateSoloProcess($iRow, 59)
	__RegisterSystemDll("inetcpl.cpl", "/s /i")
	__RegisterSystemDll("inetcpl.cpl", "/s /i /n")
	_UpdateSoloProcess($iRow, 60)
	__RegisterSystemDll("initpki.dll", "/s /i:A")
	__RegisterSystemDll("inseng.dll", "/s /i")

	__RegisterSystemDll("javascriptcollectionagent.dll")
	__RegisterSystemDll("jscript.dll")
	__RegisterSystemDll("jscript9.dll")
	__RegisterSystemDll("jscript9diag.dll")
	__RegisterSystemDll("jsintl.dll")
	__RegisterSystemDll("jsproxy.dll")

	_UpdateSoloProcess($iRow, 61)
	__RegisterSystemDll("l3codecx.ax")
	__RegisterSystemDll("laprxy.dll")
	__RegisterSystemDll("licdll.dll")

;~ License Manager
	_UpdateSoloProcess($iRow, 62)
	_Logging_EditWrite($g_aLangMessages2[44])
	__RegisterSystemDll("licmgr10.dll")
	_UpdateSoloProcess($iRow, 63)
	__RegisterSystemDll("lmrt.dll")
	__RegisterSystemDll("migration\wininetplugin.dll")
	__RegisterSystemDll("mlang.dll")
	__RegisterSystemDll("mmefxe.ocx")
	_UpdateSoloProcess($iRow, 64)
	__RegisterSystemDll("mobsync.dll")
	__RegisterSystemDll("mpg4ds32.ax")
	__RegisterSystemDll("msapsspc.dll", "/SspcCreateSspiReg /s")

;~ Symptom: Javascript links don't work (Robin Walker) .NET hub file
	_UpdateSoloProcess($iRow, 65)
	_Logging_EditWrite($g_aLangMessages2[45])
	__RegisterSystemDll("mscoree.dll")
	__RegisterSystemDll("mscorier.dll")
	__RegisterSystemDll("mscories.dll")

	__RegisterSystemDll("msfeeds.dll")
	__RegisterSystemDll("msfeedsbs.dll")
	__RegisterSystemDll("mshtmldac.dll")

;~ VS Debugger
	_UpdateSoloProcess($iRow, 66)
	_Logging_EditWrite($g_aLangMessages2[46])
	__RegisterSystemDll("msdbg2.dll")
	_UpdateSoloProcess($iRow, 67)
	__RegisterSystemDll("msdxm.ocx")
	__RegisterSystemDll("mshta.exe")
	__RegisterSystemDll("mshtml.dll")
	_UpdateSoloProcess($iRow, 68)
	__RegisterSystemDll("mshtml.dll", "/s /i")
	__RegisterSystemDll("mshtmled.dll")
	__RegisterSystemDll("mshtmler.dll")
	__RegisterSystemDll("mshtmlmedia.dll")
	__RegisterSystemDll("msident.dll")
	_UpdateSoloProcess($iRow, 69)
	__RegisterSystemDll("msieftp.dll", "/s /i")
	__RegisterSystemDll("msls31.dll")
	__RegisterSystemDll("msnsspc.dll", "/SspcCreateSspiReg /s")
	__RegisterSystemDll("msoe.dll")
	_UpdateSoloProcess($iRow, 70)
	__RegisterSystemDll("msoeacct.dll")
	__RegisterSystemDll("msr2c.dll")
	__RegisterSystemDll("msrating.dll")
	_UpdateSoloProcess($iRow, 71)
	__RegisterSystemDll("MSTIME.DLL")
	__RegisterSystemDll("mstinit.exe /setup /s")
	__RegisterSystemDll("msxml.dll")
	_UpdateSoloProcess($iRow, 72)
	__RegisterSystemDll("oeimport.dll")
	__RegisterSystemDll("oemiglib.dll")

;~ Symptom: Printing problems, open in new window
	_UpdateSoloProcess($iRow, 73)
	_Logging_EditWrite($g_aLangMessages2[47])
	__RegisterSystemDll("ole32.dll")

;~ Symptom: Find on this page is blank
	_UpdateSoloProcess($iRow, 74)
	_Logging_EditWrite($g_aLangMessages2[48])
	__RegisterSystemDll("oleacc.dll")
	__RegisterSystemDll("occache.dll")
	__RegisterSystemDll("occache.dll", "/s /i")
	__RegisterSystemDll("oleaut32.dll")

;~ Process debug manager
	_UpdateSoloProcess($iRow, 75)
	_Logging_EditWrite($g_aLangMessages2[49])
	__RegisterSystemDll("plugin.ocx")
	__RegisterSystemDll("pngfilt.dll")
	_UpdateSoloProcess($iRow, 76)
	__RegisterSystemDll("POSTWPP.DLL")
	__RegisterSystemDll("proctexe.ocx")
	__RegisterSystemDll("regwizc.dll")
	_UpdateSoloProcess($iRow, 77)
	__RegisterSystemDll("rsabase.dll")
	__RegisterSystemDll("RSAENH.DLL")
	__RegisterSystemDll("Sccbase.dll")
	_UpdateSoloProcess($iRow, 78)
	__RegisterSystemDll("scrobj.dll", "/s /i")
	__RegisterSystemDll("scrrun.dll")
	__RegisterSystemDll("sendmail.dll")
	_UpdateSoloProcess($iRow, 79)
	__RegisterSystemDll("setupwbv.dll")
	__RegisterSystemDll("setupwbv.dll", "/s /i")
	__RegisterSystemDll("shdoc401.dll")
	_UpdateSoloProcess($iRow, 80)
	__RegisterSystemDll("shdoc401.dll", "/s /i")
	__RegisterSystemDll("shdocvw.dll")
	__RegisterSystemDll("shdocvw.dll", "/s /i")
	_UpdateSoloProcess($iRow, 81)
	__RegisterSystemDll("Slbcsp.dll")
	__RegisterSystemDll("softpub.dll")
	__RegisterSystemDll("tdc.ocx")
	_UpdateSoloProcess($iRow, 82)
	__RegisterSystemDll("thumbvw.dll")
	__RegisterSystemDll("trialoc.dll")
	__RegisterSystemDll("triedit.dll")
	_UpdateSoloProcess($iRow, 83)
	__RegisterSystemDll("url.dll")
	__RegisterSystemDll("urlmon.dll", "/s /i")
	__RegisterSystemDll("urlmon.dll,NI,HKLM", "/s /i")
	_UpdateSoloProcess($iRow, 84)
	__RegisterSystemDll("vbscript.dll")

;~ VML Renderer
	_UpdateSoloProcess($iRow, 85)
	_Logging_EditWrite($g_aLangMessages2[50])
	__RegisterSystemDll("vgx.dll")
	__RegisterSystemDll("voxmsdec.ax")
	_UpdateSoloProcess($iRow, 86)
	__RegisterSystemDll("wab32.dll")
	__RegisterSystemDll("wabfind.dll")
	__RegisterSystemDll("wabimp.dll")
	_UpdateSoloProcess($iRow, 87)
	__RegisterSystemDll("webcheck.dll", "/i /s")
	__RegisterSystemDll("webcheck.dll")
	__RegisterSystemDll("WEBPOST.DLL")
	_UpdateSoloProcess($iRow, 88)
	__RegisterSystemDll("wininet.dll")
	__RegisterSystemDll("wininet.dll", "/i /s")
	__RegisterSystemDll("wininet.dll", "/i /s /n")
	_UpdateSoloProcess($iRow, 89)
	__RegisterSystemDll("WINTRUST.DLL")
	__RegisterSystemDll("WPWIZDLL.DLL")
	__RegisterSystemDll("wshext.dll")
	__RegisterSystemDll("wshom.ocx")
	_UpdateSoloProcess($iRow, 90)
	__RegisterSystemDll("xmsconf.ocx")
	_UpdateSoloProcess($iRow, 91)

	If @OSVersion = "WIN_XP" Then

;~ Symptom: new tabs page cannot display content because it cannot access the controls (added 27. 3.2009)
;~ This is a result of a bug in shdocvw.dll (see above), probably only on Windows XP
		_Logging_EditWrite($g_aLangMessages2[51])
		_Logging_EditWrite($g_aLangMessages2[52])
		_Registry_Write("HKEY_CLASSES_ROOT\TypeLib\{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}\1.1\0\win32", "", "REG_SZ", "%SystemRoot%\system32\ieframe.dll")

		_Logging_EditWrite($g_aLangMessages2[53])
		__RegisterProgramFilesDll("Outlook Express\msoe.dll")
		__RegisterProgramFilesDll("Outlook Express\oeimport.dll")
		_UpdateSoloProcess($iRow, 92)
		__RegisterProgramFilesDll("Outlook Express\oemiglib.dll")
		__RegisterProgramFilesDll("Outlook Express\wabfind.dll")
		__RegisterProgramFilesDll("Outlook Express\wabimp.dll")
		_UpdateSoloProcess($iRow, 93)

	EndIf

	_UpdateSoloProcess($iRow, 94)
	__RegisterCommonProgramFilesDll("microsoft shared\vgx\vgx.dll")
	__RegisterCommonProgramFilesDll("system\directdb.dll")
	__RegisterCommonProgramFilesDll("system\wab32.dll")

	_Logging_FinalMessage($g_aLangMessages2[54])
	_UpdateSoloProcess($iRow, 100)

EndFunc


Func _ClearUpdateHistory($iRow, $IsInnerProcess = False)

	If Not $IsInnerProcess Then
		_StartSoloProcess($iRow)
		_Logging_Start($g_aLangMessages2[55])
			Sleep(250)
		_UpdateSoloProcess($iRow, 25)
	Else
		_Logging_EditWrite($g_aLangMessages2[55])
	EndIf

	_FileEx_FileDelete(@AppDataCommonDir & "\Microsoft\Network\Downloader\qmgr*.dat")
	_FileEx_BackupRemoveDirectory($g_sSoftDisDown, $g_sSoftDisDownOld)
	If Not $IsInnerProcess Then _UpdateSoloProcess($iRow, 50)
	_FileEx_BackupRemoveDirectory($g_sDataStore, $g_sDataStoreOld)
	If Not $IsInnerProcess Then _UpdateSoloProcess($iRow, 75)
	_FileEx_BackupRemoveDirectory($g_sCatroot2, $g_sCatroot2Old)

	If Not $IsInnerProcess Then
		_UpdateSoloProcess($iRow, 100)
		Sleep(100)
		_Logging_FinalMessage($g_aLangMessages2[56])
	Else
		_Logging_EditWrite($g_aLangMessages2[56])
	EndIf

	$g_iClearWinUpdate = False

EndFunc


Func _RepairWindowsUpdate($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start($g_aLangMessages2[57])
		Sleep(100)

	_UpdateSoloProcess($iRow, 3)
	If _FileEx_ProgramFileExists(@ProgramFilesDir & "\Nero\Update\NASvc.exe") Then
		_Logging_EditWrite($g_aLangMessages2[58])
		_RunCommand("net stop NAUpdate")
	EndIf

	_UpdateSoloProcess($iRow, 6)
	_Logging_EditWrite($g_aLangMessages2[59])
	_RunCommand("net stop bits")

	_UpdateSoloProcess($iRow, 9)
	_Logging_EditWrite($g_aLangMessages2[60])
	_RunCommand("net stop wuauserv")

	_UpdateSoloProcess($iRow, 12)
	If $g_iClearWinUpdate Then _ClearUpdateHistory(6, True)

	_UpdateSoloProcess($iRow, 15)
	_Logging_EditWrite($g_aLangMessages2[61])
	_RunCommand("sc sdset bits " & Chr(34) & "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" & Chr(34))

	_UpdateSoloProcess($iRow, 18)
	_Logging_EditWrite($g_aLangMessages2[62])
	_RunCommand("sc sdset wuauserv " & Chr(34) & "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" & Chr(34))

	_UpdateSoloProcess($iRow, 21)
	_Logging_EditWrite($g_aLangMessages2[63])
	_Service_Configure("wuauserv", 2)
	_RunCommand("sc config wuauserv start= auto")

	_UpdateSoloProcess($iRow, 24)
	_Logging_EditWrite($g_aLangMessages2[64])
	_Service_Configure("BITS", 2)
	_RunCommand("sc config bits start= auto")

	_UpdateSoloProcess($iRow, 27)
	_Logging_EditWrite($g_aLangMessages2[65])

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
			_UpdateSoloProcess($iRow, Round($iDllPerc) + 27)
			$iPercChange = $iDllPerc
		EndIf

		__RegisterSystemDll($aWADlls[$x])

	Next

	_UpdateSoloProcess($iRow, 63)
	If $g_iResetWinsock Then _RepairWinsock($iRow, True)
	If $g_iResetProxy Then _ResetProxyServer($iRow, True)
	If $g_iResetFirewall Then _ResetFirewall($iRow, True)

	_UpdateSoloProcess($iRow, 66)
	_Logging_EditWrite($g_aLangMessages2[66])
	_RunCommand("net start wuauserv")

	_UpdateSoloProcess($iRow, 69)
	_Logging_EditWrite($g_aLangMessages2[67])
	_RunCommand("net start bits")

	_UpdateSoloProcess($iRow, 72)
	If _FileEx_ProgramFileExists(@ProgramFilesDir & "\Nero\Update\NASvc.exe") Then
		_Logging_EditWrite($g_aLangMessages2[68])
		_RunCommand("net start NAUpdate")
	EndIf

	_UpdateSoloProcess($iRow, 75)
	_Logging_EditWrite($g_aLangMessages2[69])
	_RunCommand("fsutil resource setautoreset true " & @HomeDrive & ":\")

	If @OSVersion <> "WIN_XP" Then
		_Logging_EditWrite($g_aLangMessages2[70])
		_RunCommand("bitsadmin.exe /reset /allusers")
	EndIf

	_UpdateSoloProcess($iRow, 78)
	_Registry_Delete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\LocalUser\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate\DisableWindowsUpdateAccess")
	_Registry_Delete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoWindowsUpdate")
	_Registry_Delete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDevMgrUpdate")
	_Registry_Delete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate", "DisableWindowsUpdateAccess")
	_Registry_Delete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate")

	_UpdateSoloProcess($iRow, 81)
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

	_UpdateSoloProcess($iRow, 84)
	_Registry_Write("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NoAutoUpdate", "REG_DWORD", 0)
	_Registry_Write("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "AUOptions", "REG_DWORD", 4)
	_Registry_Write("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallDay", "REG_DWORD", 0)
	_Registry_Write("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "ScheduledInstallTime", "REG_DWORD", 3)
	_Registry_Write("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update", "NoAutoRebootWithLoggedOnUsers", "REG_DWORD", 1)

	_UpdateSoloProcess($iRow, 87)
	_Registry_Write("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "NoUpdateCheck", "REG_DWORD", 0)

	_UpdateSoloProcess($iRow, 90)
	If Not @OSVersion = "WIN_10" Then
		_Logging_EditWrite($g_aLangMessages2[71])
		_RunCommand("wuauclt /detectnow")
	EndIf

	_Logging_FinalMessage($g_aLangMessages2[72])
	_UpdateSoloProcess($iRow, 100)

EndFunc


Func _RepairNeroUpdate($iRow)

;~ 	_StartSoloProcess($iRow)
;~ 	_Logging_Start("Repairing Nero Update.")
;~ 		Sleep(100)
;~ 	_UpdateSoloProcess($iRow, 5)

;~ 	If _ProgramFileExists(@ProgramFilesDir & "\Nero\Update\NASvc.exe") Then

;~ 		_UpdateSoloProcess($iRow, 10)
;~ 		_Logging_EditWrite("Stopping the Nero Update Service.")
;~ 		_RunCommand("Echo Y|net stop NAUpdate")

;~ 		_UpdateSoloProcess($iRow, 15)
;~ 		_Logging_EditWrite("Configuring the Nero Update Service.")
;~ 		_RunCommand("sc config NAUpdate start= delayed-auto")

;~ 		_UpdateSoloProcess($iRow, 20)
;~ 		_Logging_EditWrite("Registering Nero Update DLLs.", 1, 1)
;~ 		_ReregisterDLL(@ProgramFilesDir & "\Nero\Update\NASvcPS.dll")
;~ 		_UpdateSoloProcess($iRow, 25)
;~ 		_ReregisterDLL(@ProgramFilesDir & "\Nero\Update\SolutionExplorer.dll")

;~ 		_Logging_EditWrite("Use global Nero Update Server to check for updates.")
;~ 		_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "UpdateRepository")
;~ 		_Logging_EditWrite("Removing fixed update check interval.")
;~ 		_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "CheckInterval")
;~ 		_Logging_EditWrite("Removing all other Nero update restrictions.")
;~ 		_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "DenyCheck")
;~ 		_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "DenyDownload")
;~ 		_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "DenyInstall")
;~ 		_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "DenyUI")
;~ 		_Registry_Delete("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Nero\Agent", "NoLocalCache")

;~ 		_UpdateSoloProcess($iRow, 95)
;~ 		_Logging_EditWrite("Restarting the Nero Update Service.")
;~ 		_RunCommand("net start NAUpdate")

;~ 	Else
;~ 		_Logging_EditWrite("It looks like Nero is not installed.", 1, 1)
;~ 	EndIf

;~ 	_UpdateSoloProcess($iRow, 100)
;~ 			Sleep(100)
;~ 	_Logging_FinalMessage("Nero Update should work now.")

EndFunc


Func _RepairCryptography($iRow)

;~ If Not $EVNTLOG_CONFIGURED Then _ConfigureEventLog()
	_StartSoloProcess($iRow)
	_Logging_Start($g_aLangMessages2[73])
		Sleep(100)

	_UpdateSoloProcess($iRow, 5)
	_Logging_EditWrite($g_aLangMessages2[74])
	_RunCommand("net stop CryptSvc")
	_UpdateSoloProcess($iRow, 10)
	_Logging_EditWrite($g_aLangMessages2[75])
	_Service_Configure("CryptSvc", 2)
	_RunCommand("sc config CryptSvc start= auto")

	_Logging_EditWrite(StringFormat($g_aLangMessages2[76], $g_sCatroot2))
	_FileEx_BackupRemoveDirectory($g_sCatroot2, $g_sCatroot2Old)

	_Logging_EditWrite(StringFormat($g_aLangMessages2[76], $g_sCatroot))
	_UpdateSoloProcess($iRow, 15)
	_FileEx_FileDelete($g_sCatroot & "\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}\tmp*.CAT")
	_UpdateSoloProcess($iRow, 20)
	_FileEx_FileDelete($g_sCatroot & "\{127D0A1D-4EF2-11D1-8608-00C04FC295EE}\tmp*.CAT")
	_UpdateSoloProcess($iRow, 25)
	_FileEx_FileDelete($g_sCatroot & "\{F750E6C3-38EE-11D1-85E5-00C04FC295EE}\KB*.CAT")
	_UpdateSoloProcess($iRow, 30)
	_FileEx_FileDelete($g_sCatroot & "\{127D0A1D-4EF2-11D1-8608-00C04FC295EE}\KB*.CAT")
	_UpdateSoloProcess($iRow, 33)
	_FileEx_FileDelete(@WindowsDir & "\inf\oem*.*")
	_Logging_EditWrite(StringFormat($g_aLangMessages2[77], $g_sCatroot))

	_Logging_EditWrite($g_aLangMessages2[78])
	Local $sCrptDlls = "cryptdlg.dll|cryptext.dll|cryptui.dll|dssenh.dll|gpkcsp.dll|initpki.dll|licdll.dll|" & _
			"mssign32.dll|mssip32.dll|regwizc.dll|rsaenh.dll|scardssp.dll|sccbase.dll|scecli.dll|slbcsp.dll|" & _
			"softpub.dll|winhttp.dll|wintrust.dll"

	Local $aCrptDlls = StringSplit($sCrptDlls, "|")
	Local $sProcTemp, $iDllCount = 0, $iDllPerc = 0, $iPercChange = 0

	For $x = 1 To $aCrptDlls[0]

		$iDllCount += 1
		$iDllPerc = Int($iDllCount / $aCrptDlls[0] * 33)

		If $iDllPerc <> $iPercChange Then
			_UpdateSoloProcess($iRow, Round($iDllPerc) + 33)
			$iPercChange = $iDllPerc
		EndIf

		__RegisterSystemDll($aCrptDlls[$x])

	Next
	_Logging_EditWrite($g_aLangMessages2[79])
	_UpdateSoloProcess($iRow, 50)

	_UpdateSoloProcess($iRow, 80)
	_Logging_EditWrite($g_aLangMessages2[80])
	_RunCommand("net start CryptSvc")

	_UpdateSoloProcess($iRow, 100)
		Sleep(100)
	_Logging_FinalMessage($g_aLangMessages2[81])

EndFunc


Func _ResetProxyServer($iRow, $IsInnerProcess = False)

	If Not $IsInnerProcess Then
		_StartSoloProcess($iRow)
		_Logging_Start($g_aLangMessages2[82])
			Sleep(100)
		_UpdateSoloProcess($iRow, 50)
	Else
		_Logging_EditWrite($g_aLangMessages2[82])
	EndIf

	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then
		_Logging_EditWrite($g_aLangMessages2[83])
		_RunCommand("proxycfg.exe -d")
	Else
		_RunCommand("netsh winhttp reset proxy")
	EndIf

	If Not $IsInnerProcess Then
		_UpdateSoloProcess($iRow, 100)
			Sleep(100)
		_Logging_FinalMessage($g_aLangMessages2[84])
	Else
		_Logging_EditWrite($g_aLangMessages2[84])
	EndIf

	$g_iResetProxy = False

EndFunc


Func _ResetFirewall($iRow, $IsInnerProcess = False)

	If Not $IsInnerProcess Then
		_StartSoloProcess($iRow)
		_Logging_Start($g_aLangMessages2[85])
			Sleep(100)
		_UpdateSoloProcess($iRow, 50)
	Else
		_Logging_EditWrite($g_aLangMessages2[85])
	EndIf

	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then
		_RunCommand("netsh firewall reset")
	Else
		_RunCommand("netsh advfirewall reset")
	EndIf

	If Not $IsInnerProcess Then
		_UpdateSoloProcess($iRow, 100)
			Sleep(100)
		_Logging_FinalMessage($g_aLangMessages2[86])
	Else
		_Logging_EditWrite($g_aLangMessages2[86])
	EndIf

	$g_iResetFirewall = False

EndFunc


Func _RestoreWindowsHosts($iRow)

	Local $sPathHOSTS = @WindowsDir & "\System32\drivers\etc\hosts"
	Local $sPathHOSTS_Backup = @WindowsDir & "\System32\drivers\etc\hosts.bak"

	_StartSoloProcess($iRow)
	_Logging_Start($g_aLangMessages2[87])
		Sleep(100)
	_UpdateSoloProcess($iRow, 10)

	FileSetAttrib($sPathHOSTS, "-RASHNOT")
	_UpdateSoloProcess($iRow, 20)
	FileCopy($sPathHOSTS, $sPathHOSTS_Backup)
	_UpdateSoloProcess($iRow, 30)
	_FileEx_FileDelete($sPathHOSTS)
	_UpdateSoloProcess($iRow, 50)

	Local $oHOSTS = FileOpen($sPathHOSTS, 1)

	If $sPathHOSTS = -1 Then
		_Logging_EditWrite($g_aLangMessages2[88])
	Else
		_Logging_EditWrite($g_aLangMessages2[89])

		FileWrite($oHOSTS, "# Copyright (c) 1993-2009 Microsoft Corp." & @CRLF)
		FileWrite($oHOSTS, "#" & @CRLF)
		FileWrite($oHOSTS, "# This is a sample HOSTS file used by Microsoft TCP/IP for Windows." & @CRLF)
		FileWrite($oHOSTS, "#" & @CRLF)
		FileWrite($oHOSTS, "# This file contains the mappings of IP addresses to host names. Each" & @CRLF)
		FileWrite($oHOSTS, "# entry should be kept on an individual line. The IP address should" & @CRLF)
		FileWrite($oHOSTS, "# be placed in the first column followed by the corresponding host name." & @CRLF)
		FileWrite($oHOSTS, "# The IP address and the host name should be separated by at least one" & @CRLF)
		FileWrite($oHOSTS, "# space." & @CRLF)
		FileWrite($oHOSTS, "#" & @CRLF)
		FileWrite($oHOSTS, "# Additionally, comments (such as these) may be inserted on individual" & @CRLF)
		FileWrite($oHOSTS, "# lines or following the machine name denoted by a '#' symbol." & @CRLF)
		FileWrite($oHOSTS, "#" & @CRLF)
		FileWrite($oHOSTS, "# For example:" & @CRLF)
		FileWrite($oHOSTS, "#" & @CRLF)
		FileWrite($oHOSTS, "#      102.54.94.97     rhino.acme.com          # source server" & @CRLF)
		FileWrite($oHOSTS, "#       38.25.63.10     x.acme.com              # x client host" & @CRLF)
		FileWrite($oHOSTS, "" & @CRLF)

		Switch @OSVersion
			Case "WIN_XP", "WIN_2003"
				FileWrite($oHOSTS, "127.0.0.1       localhost" & @CRLF)
			Case "WIN_VISTA", "WIN_2008"
				FileWrite($oHOSTS, "127.0.0.1       localhost" & @CRLF)
				FileWrite($oHOSTS, "::1             localhost" & @CRLF)
			Case Else
				FileWrite($oHOSTS, "# localhost name resolution is handled within DNS itself." & @CRLF)
				FileWrite($oHOSTS, "#       127.0.0.1       localhost" & @CRLF)
				FileWrite($oHOSTS, "#       ::1             localhost" & @CRLF)
		EndSwitch

		FileClose($oHOSTS)
		_Logging_EditWrite($g_aLangMessages2[90])

	EndIf

	_UpdateSoloProcess($iRow, 100)
		Sleep(100)
	_Logging_FinalMessage($g_aLangMessages2[91])

EndFunc


Func _RenewWinsClient($iRow)

	_StartSoloProcess($iRow)
	_Logging_Start($g_aLangMessages2[92])
	_UpdateSoloProcess($iRow, 33)
	_RunCommand("Nbtstat.exe -R")
	_UpdateSoloProcess($iRow, 66)
	_RunCommand("Nbtstat.exe -RR")
	_UpdateSoloProcess($iRow, 100)
		Sleep(100)
	_Logging_FinalMessage($g_aLangMessages2[93])

EndFunc


Func _MakeNetComputersVisible($iRow)

	_StartSoloProcess($iRow)
	_UpdateSoloProcess($iRow, 30)
	_Logging_Start($g_aLangMessages2[94])
	_RunCommand("net stop FDResPub")
	_UpdateSoloProcess($iRow, 60)
	_Logging_EditWrite($g_aLangMessages2[95])
	_Service_Configure("FDResPub", 2)
	_RunCommand("sc config FDResPub start= auto")
	_UpdateSoloProcess($iRow, 90)
	_RunCommand("net start FDResPub")
	_UpdateSoloProcess($iRow, 100)
		Sleep(100)
	_Logging_FinalMessage($g_aLangMessages2[96])

EndFunc


Func _StartSoloProcess($iRow)

	GUICtrlSetImage($g_aRepair[$iRow][0], $g_sProcessSim, 0)

EndFunc   ;==>_StartSoloProcess


Func _UpdateSoloProcess($iRow, $iPerc, $iSleep = 100)

	; Sleep($iSleep)
	Local $aPbPos = ControlGetPos($g_hCoreGui, "", $g_aRepair[$iRow][5])
	Local $iVisualError = $g_iComIconStart + 4

	If $iPerc > 0 Then
		_ProgressBar_DrawSizeFromPercentage($g_aRepair[$iRow][6], $iPerc, _
			$aPbPos[0], $g_aRepair[$iRow][4], $aPbPos[2], 1)
	EndIf

	If $iPerc = 100 Then

		If $g_iSoloProcess = False Then
			GUICtrlSetState($g_aRepair[$iRow][1], $GUI_UNCHECKED)
		EndIf

		If $g_iLoggingErrors > 0 Then
			$iVisualError = $g_iComIconStart + 5
			GUICtrlSetBkColor($g_aRepair[$iRow][6], 0xC80B0B)
		Else
			$iVisualError = $g_iComIconStart + 4
		EndIf

		Local $iIcoFinalIndex = ($iVisualError - $g_iComIconStart)
		GUICtrlSetImage($g_aRepair[$iRow][0], $g_aCommIcons[$iIcoFinalIndex], $iVisualError)

		Sleep(1000)
		If $g_iSoloProcess = True Then
			Local $iXz = ($iRow + 6)
			_ResetProgress($iRow)
			GUICtrlSetImage($g_aRepair[$iRow][0], $g_aCommIcons[$iXz], $g_iComIconStart + $iXz)
		EndIf

	EndIf

EndFunc   ;==>_UpdateSoloProcess


Func _ResetProgress($iRow)

	Local $aPbPos = ControlGetPos($g_hCoreGui, "", $g_aRepair[$iRow][5])
	_ProgressBar_DrawSizeFromPercentage($g_aRepair[$iRow][6], 2, _
				$aPbPos[0], $g_aRepair[$iRow][4], $aPbPos[2], 1)

	GUICtrlSetState($g_aRepair[$iRow][6], $GUI_HIDE)
	GUICtrlSetBkColor($g_aRepair[$iRow][6], 0x3399FF)

EndFunc


Func _StartProcessing()

	_SetAllOptionStates($GUI_DISABLE)
	GUICtrlSetState($g_hSubHeading, $GUI_SHOW)
	GUICtrlSetState($g_hSubNotice, $GUI_HIDE)
	GUICtrlSetState($g_hGuiIcon, $GUI_HIDE)
	GUICtrlSetState($g_AniProcessing, $GUI_SHOW)

EndFunc   ;==>_StartProcessing


Func _EndProcessing()

	_SetAllOptionStates($GUI_ENABLE)
	GUICtrlSetState($g_hGuiIcon, $GUI_SHOW)
	GUICtrlSetState($g_AniProcessing, $GUI_HIDE)

	; If $g_iCancel = False Then
		SoundPlay(@ScriptDir & "\Sounds\Complete.wav")
	; EndIf


EndFunc   ;==>_EndProcesssing()


Func _ProcessCheckedCount()

	Local $iCount = 0

	For $iRepair = 0 To $CNT_REPAIR - 1
		If GUICtrlRead($g_aRepair[$iRepair][1]) = $GUI_CHECKED Then
			$iCount += 1
		EndIf
	Next

	Return $iCount

EndFunc   ;==>_ProcessCheckedCount


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
					StringReplace($g_aLangMenus[12], "&", "")))

		EndSelect

	EndIf

EndFunc   ;==>_BootMessage


Func _Reboot()

	_Logging_Start($g_aLangMessages2[9])

	If Not IsDeclared("iMsgResult") Then Local $iMsgResult
	$iMsgResult = MsgBox($MB_OKCANCEL + $MB_ICONEXCLAMATION, $g_aLangMessages2[10], StringFormat($g_aLangMessages2[11], $g_iMsgBoxTimeOut), $g_iMsgBoxTimeOut)

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


Func _SetAllOptionStates($iState)

	For $iRepair = 0 To $CNT_REPAIR - 1
		For $iRepairCtrl = 1 To 3
			GUICtrlSetState($g_aRepair[$iRepair][$iRepairCtrl], $iState)
		Next
		$g_aRepairState[$iRepair][1] = $iState
	Next

EndFunc   ;==>_SetAllOptionStates


Func _ShowRepairInfo()

	GUICtrlSetState($g_hListStatus, $GUI_HIDE)
	GUICtrlSetState($g_hEditInfo, $GUI_SHOW)

	Switch @GUI_CtrlId
		Case $g_aRepair[0][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[21])
		Case $g_aRepair[1][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[22])
		Case $g_aRepair[2][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[23])
		Case $g_aRepair[3][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[24])
		Case $g_aRepair[4][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[25])
		Case $g_aRepair[5][2]
			GUICtrlSetData($g_hEditInfo, StringFormat($g_aLangCustom[26], $g_IntExplVersion))
		Case $g_aRepair[6][2]
			GUICtrlSetData($g_hEditInfo, StringFormat($g_aLangCustom[27], $g_sDataStore, $g_sSoftDisDown))
		Case $g_aRepair[7][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[28])
		Case $g_aRepair[8][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[29])
		Case $g_aRepair[9][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[30])
		Case $g_aRepair[10][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[31])
		Case $g_aRepair[11][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[32])
		Case $g_aRepair[12][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[33])
		Case $g_aRepair[13][2]
			GUICtrlSetData($g_hEditInfo, $g_aLangCustom[34])

	EndSwitch

EndFunc   ;==>_ShowRepairInfo


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


Func _GoTo_WinRepair()
	ShellExecute(_Link_Split($g_sUrlWinRepair))
EndFunc   ;==>_About_Twitter


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
	GUICtrlCreateGroup($g_aLangPreferences[5], 25, 50, 400, 120)
	GUICtrlSetFont(-1, 10, 700, 2)
	$g_hOChkBackupData = GUICtrlCreateCheckbox($g_aLangPreferences[10], 35, 100, 300, 20)
	GUICtrlSetState($g_hOChkBackupData, $g_iBackupData)
	$g_hOChkExportIP = GUICtrlCreateCheckbox($g_aLangPreferences[11], 35, 120, 300, 20)
	GUICtrlSetState($g_hOChkExportIP, $g_iBackupIPData)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
	GUICtrlCreateTabItem("") ; end tabitem definition

	GUICtrlSetOnEvent($g_hOChkBackupData, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOChkExportIP, "__CheckPreferenceChange")

	GUICtrlCreateTabItem(StringFormat(" %s ", $g_aLangPreferences[2]))
	GUICtrlCreateGroup($g_aLangPreferences[6], 25, 50, 400, 160)
	GUICtrlSetFont(-1, 10, 700, 2)
	$g_hOChkLogEnabled = GUICtrlCreateCheckbox($g_aLangPreferences[12], 35, 90, 200, 20)
	GUICtrlSetState($g_hOChkLogEnabled, $g_iLoggingEnabled)
	GUICtrlCreateLabel($g_aLangPreferences[13], 35, 120, 180, 20)
	$g_hOInLogSize = GUICtrlCreateInput(Round($g_iLoggingStorage / 1024, 2), 215, 118, 100, 20)
	GUICtrlSetStyle($g_hOInLogSize, BitOr($ES_RIGHT, $ES_NUMBER))
	GUICtrlSetFont(-1, 9, 400, 0, "Verdana")
	GUICtrlCreateLabel("KB", 325, 120, 50, 20)
	$g_hOInLogSizeTemp = Int(GUICtrlRead($g_hOInLogSize))
	$g_hOLblLogSize = GUICtrlCreateLabel(StringFormat($g_aLangPreferences[14], __GetLoggingSize()), 35, 160, 200, 20)
	GUICtrlSetColor($g_hOLblLogSize, 0x555555)
	$g_hOBtnLogClear = GUICtrlCreateButton($g_aLangPreferences[15], 255, 155, 150, 30)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	GUICtrlSetOnEvent($g_hOChkLogEnabled, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOBtnLogClear, "__RemoveLoggingFile")
		;GUICtrlSetState($g_ReBarChkLogEnabled, $g_ReBarLogEnabled)
	__CheckLoggingStateChanged()
	GUICtrlCreateTabItem("") ; end tabitem definition

	GUICtrlCreateTabItem(StringFormat(" %s ", $g_aLangPreferences[3]))
	GUICtrlCreateGroup($g_aLangPreferences[7], 25, 50, 400, 130)
	GUICtrlSetFont(-1, 10, 700, 2)
	GUICtrlCreateLabel($g_aLangPreferences[16], 35, 80, 300, 20)
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

	GUICtrlCreateGroup($g_aLangPreferences[8], 25, 200, 400, 70)
	GUICtrlSetFont(-1, 10, 700, 2)
	$g_hOChkReduceMemory = GUICtrlCreateCheckbox($g_aLangPreferences[18], 35, 235, 360, 20)
	GUICtrlSetState($g_hOChkReduceMemory, $g_iReduceMemory)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group

	If Not @Compiled Then
		GUICtrlSetState($g_hOComboPower, $GUI_DISABLE)
		GUICtrlSetState($g_hOChkSaveRealtime, $GUI_DISABLE)
		GUICtrlSetState($g_hOChkReduceMemory, $GUI_DISABLE)
	EndIf

	GUICtrlSetOnEvent($g_hOChkReduceMemory, "__CheckPreferenceChange")
	GUICtrlCreateTabItem("") ; end tabitem definition

	GUICtrlCreateTabItem(StringFormat(" %s ", $g_aLangPreferences[4]))
	GUICtrlCreateGroup($g_aLangPreferences[9], 25, 50, 400, 350)
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
	GUICtrlCreateLabel(StringFormat($g_aLangPreferences[19], $g_aLangPreferences[20]), 40, 350, 365, 35)
	GUICtrlSetColor(-1, 0x555555)
	GUICtrlSetFont(-1, 9)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
	GUICtrlCreateTabItem("") ; end tabitem definition

	$g_hOLblPrefsUpdated = GUICtrlCreateLabel($g_aLangPreferences[22], 25, 455, 200, 20)
	GUICtrlSetColor($g_hOLblPrefsUpdated, 0x008000)
	GUICtrlSetState($g_hOLblPrefsUpdated, $GUI_HIDE)
	$g_hOBtnSave = GUICtrlCreateButton($g_aLangPreferences[20], 210, 450, 100, 30)
	GUICtrlSetFont($g_hOBtnSave, 10)
	GUICtrlSetState($g_hOBtnSave, $GUI_FOCUS)
	GUICtrlSetState($g_hOBtnSave, $GUI_DISABLE)
	GUICtrlSetOnEvent($g_hOBtnSave, "__SavePreferences")

	$g_hOBtnCancel = GUICtrlCreateButton($g_aLangPreferences[21], 320, 450, 100, 30)
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

	GUICtrlSetData($g_hOLblLogSize, StringFormat($g_aLangPreferences[14], __GetLoggingSize()))
	GUICtrlSetData($g_hOLblPrefsUpdated, $g_aLangPreferences[23])
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
			__CheckBoxChanged("BackupData", $g_hOChkBackupData) = True Or _
			__CheckBoxChanged("BackupIPData", $g_hOChkExportIP) = True Or _
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
		Local $iMsgBoxResult = MsgBox($MB_OKCANCEL + $MB_ICONINFORMATION, $g_aLangPreferences[24], $g_aLangPreferences[25], 0, $g_hOptionsGui)
		Switch $iMsgBoxResult
			Case 1
				IniWrite($g_sPathIni, $g_sProgShortName, "Language", $g_tSelectedLanguage)
				GUICtrlSetData($g_hOLblPrefsUpdated, $g_aLangPreferences[22])
				GUICtrlSetState($g_hOLblPrefsUpdated, $GUI_SHOW)
				GUICtrlSetState($g_hOBtnSave, $GUI_DISABLE)
				$iLangChanged = True
			Case 2
				GUICtrlSetState($g_hOBtnSave, $GUI_ENABLE)
				Return 0
		EndSwitch
	EndIf

	If GUICtrlRead($g_hOChkBackupData) = $GUI_CHECKED Then
		$g_iBackupData = 1
	ElseIf GUICtrlRead($g_hOChkBackupData) = $GUI_UNCHECKED Then
		$g_iBackupData = 0
	EndIf

	If GUICtrlRead($g_hOChkExportIP) = $GUI_CHECKED Then
		$g_iBackupIPData = 1
	ElseIf GUICtrlRead($g_hOChkExportIP) = $GUI_UNCHECKED Then
		$g_iBackupIPData = 0
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

	If $g_iSaveRealtime = 0 And $g_iProcessPriority = 5 Then
		IniWrite($g_sPathIni, $g_sProgShortName, "ProcessPriority", 4)
	Else
		IniWrite($g_sPathIni, $g_sProgShortName, "ProcessPriority", $g_iProcessPriority)
	EndIf

	$g_iLoggingStorage = Int(GUICtrlRead($g_hOInLogSize)) * 1024
	IniWrite($g_sPathIni, $g_sProgShortName, "SaveRealtime", $g_iSaveRealtime)
	IniWrite($g_sPathIni, $g_sProgShortName, "ReduceMemory", $g_iReduceMemory)
	IniWrite($g_sPathIni, $g_sProgShortName, "BackupData", $g_iBackupData)
	IniWrite($g_sPathIni, $g_sProgShortName, "BackupIPData", $g_iBackupIPData)
	IniWrite($g_sPathIni, $g_sProgShortName, "LoggingEnabled", $g_iLoggingEnabled)
	IniWrite($g_sPathIni, $g_sProgShortName, "LoggingStorageSize", $g_iLoggingStorage)

	If $iLangChanged = True Then
		$iMsgBoxResult = MsgBox($MB_OKCANCEL + $MB_ICONINFORMATION, $g_aLangPreferences[26], $g_aLangPreferences[27], 0, $g_hOptionsGui)
		Switch $iMsgBoxResult
			Case 1
				_ShutdownProgram()
			Case 2
				; GUICtrlSetState($g_hOBtnSave, $GUI_ENABLE)
				$iLangChanged = False
		EndSwitch
	Else
		GUICtrlSetData($g_hOLblPrefsUpdated, $g_aLangPreferences[22])
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
					GUICtrlSetImage($g_hOIconLanguage, $g_aLanguageIcons[$aSelLangInfo[1]], $g_iLangIconStart + $aSelLangInfo[1])
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
