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
#AutoIt3Wrapper_Icon=..\..\Resources\Icons\MemBoost.ico			;~ Filename of the Ico file to use for the compiled exe
#AutoIt3Wrapper_OutFile_Type=exe								;~ exe=Standalone executable (Default); a3x=Tokenised AutoIt3 code file
#AutoIt3Wrapper_OutFile=..\..\..\Resolute\MemBoost.exe			;~ Target exe/a3x filename.
#AutoIt3Wrapper_OutFile_X64=..\..\..\Resolute\MemBoost_X64.exe	;~ Target exe filename for X64 compile.
;#AutoIt3Wrapper_Compression=4									;~ Compression parameter 0-4  0=Low 2=normal 4=High. Default=2
;#AutoIt3Wrapper_UseUpx=Y										;~ (Y/N) Compress output program.  Default=Y
;#AutoIt3Wrapper_UPX_Parameters=								;~ Override the default settings for UPX.
#AutoIt3Wrapper_Change2CUI=N									;~ (Y/N) Change output program to CUI in stead of GUI. Default=N
#AutoIt3Wrapper_Compile_both=Y									;~ (Y/N) Compile both X86 and X64 in one run. Default=N
;===============================================================================================================
; Target Program Resource info
;===============================================================================================================
#AutoIt3Wrapper_Res_Comment=Memory Booster						;~ Comment field
#AutoIt3Wrapper_Res_Description=Memory Booster			     	;~ Description field
#AutoIt3Wrapper_Res_Fileversion=11.1.1.2373
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y  				;~ (Y/N/P) AutoIncrement FileVersion. Default=N
#AutoIt3Wrapper_Res_FileVersion_First_Increment=N				;~ (Y/N) AutoIncrement Y=Before; N=After compile. Default=N
#AutoIt3Wrapper_Res_HiDpi=N                      				;~ (Y/N) Compile for high DPI. Default=N
#AutoIt3Wrapper_Res_ProductVersion=11             				;~ Product Version
#AutoIt3Wrapper_Res_Language=2057								;~ Resource Language code . Default 2057=English (United Kingdom)
#AutoIt3Wrapper_Res_LegalCopyright=© 2023 Rizonesoft			;~ Copyright field
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
#AutoIt3Wrapper_Res_Field=ProductName|Memory Booster
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
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoostH.ico					; 201

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

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\00.ico					; 281
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\01.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\02.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\03.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\04.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\05.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\06.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\07.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\08.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\09.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\10.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\11.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\12.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\13.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\14.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\15.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\16.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\17.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\18.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\19.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\20.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\21.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\22.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\23.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\24.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\25.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\26.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\27.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\28.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\29.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\30.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\31.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\32.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\33.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\34.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\35.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\36.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\37.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\38.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\39.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\40.ico

; Tray icons for dynamic memory display (explicit resource IDs 350-361, outside main icon range 201-321)
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\0.ico,350					; 350
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\1.ico,351					; 351
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\2.ico,352					; 352
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\3.ico,353					; 353
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\4.ico,354					; 354
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\5.ico,355					; 355
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\6.ico,356					; 356
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\7.ico,357					; 357
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\8.ico,358					; 358
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\9.ico,359					; 359
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\10.ico,360					; 360
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\MemBoost\Tray\11.ico,361					; 361

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
Opt("TrayIconHide", 0)				;~ 0=show, 1=hide tray icon
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
#include <WinAPISys.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>

#include "..\..\Includes\About.au3"
#include "..\..\Includes\Donate.au3"
#include "..\..\Includes\GDIPlusEx.au3"
#include "..\..\Includes\FileEx.au3"
#include "..\..\Includes\GuiMenuEx.au3"
#include "..\..\Includes\ImageListEx.au3"
#include "..\..\Includes\Link.au3"
#include "..\\..\\Includes\\Logging.au3"
#include "..\\..\\Includes\\GDIPlusProgressBar.au3"
#include "..\..\Includes\Registry.au3"
#include "..\..\Includes\Splash.au3"
#include "..\..\Includes\SSLG.au3"
#include "..\..\Includes\StringEx.au3"
#include "..\..\Includes\Update.au3"
#include "..\..\Includes\Versioning.au3"
#include "..\..\Includes\FFLabels.au3"

#include "Includes\Localization.au3"

;~ Developer Constants
Global Const $DEBUG_UPDATE		= False

;~ Constants
Global Const $CNT_MENUICONS		= 8
Global Const $CNT_LOGICONS		= 7
Global Const $CNT_LANGICONS		= 35

;~ General Settings
Global $g_sCompanyName			= "Rizonesoft"
Global $g_sProgShortName		= "MemBoost"
Global $g_sProgShortName_X64	= $g_sProgShortName & "_X64"
Global $g_sProgName				= "Memory Booster"
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
Global $g_sLanguageFile		= $g_sLanguageDir & "\" & $g_sSelectedLanguage & ".lng"

;~ Resources
Global $g_iUpdateIconStart				= 209
Global $g_iDialogIconStart				= 211
Global $g_iAboutIconStart				= 216
Global $g_iLangIconStart				= 232
Global $g_iPowerIconsStart				= 267
Global $g_iMenuIconsStart				= 273
Global $g_iMemStatIcoStart				= 281

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
Global $g_TitleShowAutoIt	= False	;~ Show AutoIt version

;~ Interface Settings
Global $g_iCoreGuiWidth		= 580
Global $g_iCoreGuiHeight	= 593  ; Increased by 43px for 2-row CPU section
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
Global $g_hBtnOptimize						;~ Optimize Memory button
Global $g_hBtnPreferences						;~ Preferences button
Global $g_hBtnClose							;~ Close (minimize to tray) button
Global $g_iOptimizing = 0						;~ Optimization in progress flag
Global $g_iOptimizeCount = 0					;~ Total optimization count

; Automatic optimization settings
Global $g_iAutoOptimize = 2					;~ Auto optimization mode (0=off, 1=intelligent, 2=every X seconds) - default to timer
Global $g_iAutoOptimizeSeconds = 60			;~ Auto optimize interval (seconds) - default to 60
Global $g_iTimerCountdown = 60					;~ Current countdown value
Global $g_hTimerAdlib = 0						;~ Timer adlib registration flag

; Process exclusion list for optimization
Global $g_aExcludeProcesses[0]				;~ Processes to exclude from optimization

; Memory history tracking for intelligent mode
Global $g_aMemoryHistory[10] = [0,0,0,0,0,0,0,0,0,0]	;~ Last 10 memory readings
Global $g_iMemoryHistoryIndex = 0			;~ Current history index

; Tray icon
Global $g_hTrayIcon								;~ Tray icon handle
Global $g_hTrayShowHide						;~ Show/Hide menu item
Global $g_hTrayOptimize						;~ Optimize menu item
Global $g_hTrayExit							;~ Exit menu item
Global $g_aTrayIcons[12]						;~ Tray icon array (0-11 for memory levels)

; Behavior settings
Global $g_iForceBehave = 0						;~ Force processes to behave (reduce priority)
Global $g_iStartWithWindows = 0				;~ Start with Windows
Global $g_iAlwaysOnTop = 0						;~ Always on top
Global $g_iShowNotifications = 1				;~ Show notifications
Global $g_iPlaySounds = 0						;~ Play event sounds
Global $g_iPlayWarnings = 0					;~ Play warning sounds
Global $g_iWarnEvery = 60						;~ Warning interval (seconds)
Global $g_iWarnIfLoad = 80						;~ Warning memory load threshold (%)

If Not IsDeclared("g_iParentState") Then Global $g_iParentState
If Not IsDeclared("g_iParent") Then Global $g_iParent

Global $g_hOptionsGui

Global $g_hORADOptimMode[3]					;~ Optimization mode radio buttons
Global $g_hOComboAutSeconds					;~ Auto optimize seconds combo
Global $g_hOCheckForceBehave					;~ Force behave checkbox
Global $g_hOCheckStartWindows					;~ Start with Windows checkbox
Global $g_hOCheckOnTop						;~ Always on top checkbox
Global $g_hOCheckNotify						;~ Show notifications checkbox
Global $g_hOCheckPlayEvents					;~ Play event sounds checkbox
Global $g_hOCheckPlayWarnings					;~ Play warning sounds checkbox
Global $g_hOComboWarnEvery					;~ Warning frequency combo
Global $g_hOComboWarnIf						;~ Warning threshold combo

Global $g_iOptimizeMethod 	= 0
Global $g_iAutoCount		= 30
Global $g_iShowNotify		= 1
Global $g_iPlaySounds		= 1
Global $g_iPlayWarnings		= 0
Global $g_iPlayWarnEvery	= 3
Global $g_iPlayIfPerc		= 80

;~ Global $Initializing = 1, $SetStartMin, $SetOnTop, $SetForceBehave

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

Global $g_hOStartMinimized
Global $g_hOTopMost
Global $g_hONotification
Global $g_hOMethod
Global $g_hOForceBehave
Global $g_hOPlaySounds
Global $g_hOWarnings
Global $g_hOMemWarnings

Global $g_aMemStats
Global $g_aMemBuffers[8] = [-1, -1, -1, -1, -1, -1, -1, -1]  ; Initialize to -1 to force first update
Global $g_aPageBuffers[2]
Global $g_aVirtualBuffers[2]
Global $g_hIconMemStats
Global $g_hPanelRAMBox
Global $g_hPanelPagePerc
Global $g_hPanelCountPerc
Global $g_hLabelRAMPerc
Global $g_hLabelRAMTotal
Global $g_hLabelRAMUsed
Global $g_hLabelRAMFree
Global $g_hProgressCPU
Global $g_hLabelCPUPerc
Global $g_hLabelPagedPool
Global $g_hLabelNonPagedPool
Global $g_hLabelCachedTotal
Global $g_hLabelCachedUsed
Global $g_hLabelCachedFree
Global $g_hLabelCommittedTotal
Global $g_hLabelCommittedUsed
Global $g_hLabelCommittedFree
Global $g_hLabelCommittedPerc
Global $g_hProgressCommitted
Global $g_hLabelCountPerc
Global $g_hLabelProcs
Global $g_hLabelCount
Global $g_hLabelTimer
Global $g_hProgressProcs[2]
Global $bGraphColorChanged 		= False ; This will keep track of the graph color state
Global $Graph1


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

	$g_hCoreGui = GUICreate($g_sProgramTitle, $g_iCoreGuiWidth, $g_iCoreGuiHeight, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU, $WS_MINIMIZEBOX))
	If Not @Compiled Then GUISetIcon($g_aCoreIcons[0])
	GUISetFont(Default, Default, Default, "Verdana", $g_hCoreGui, $CLEARTYPE_QUALITY)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ShutdownProgram", $g_hCoreGui)

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
	$hHeading = GUICtrlCreateLabel($g_sProgName & " " & _GetProgramVersion(1), $g_iSizeIcon + 22, 15, 300)
	GUICtrlSetFont($hHeading, 12)
	$g_hSubHeading = GUICtrlCreateLabel(StringFormat($g_aLangCustom[0], $g_aLangCustom[3]), $g_iSizeIcon + 22, 38, 430, 50)
	GUICtrlSetFont($g_hSubHeading, 10)
	GUICtrlSetColor($g_hSubHeading, 0x353535)

	; Memory usage graph (narrowed to make room for CPU graph)
	$Graph1 = _SSLG_CreateGraph(133, 125, 420, 104, 0, 100, 500, 0x000F1318)
	_SSLG_SetLine($Graph1, 0x0013FF92, 1, 0x00085820)
	_SSLG_SetSmoothingMode($Graph1, 2)

	; === CPU ROW (Grid Row with 2-row span for percentage) ===
	; Col 1: CPU Label
	GUICtrlCreateGraphic(20, 236, 104, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("CPU", 20, 239, 104, 16, $SS_CENTER)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCtrlSetColor(-1, 0xFFFFFF)

	; Col 2-5: CPU Progress Bar (spans 4 columns)
	GUICtrlCreateGraphic(127, 236, 345, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	$g_hProgressCPU = GUICtrlCreateGraphic(129, 238, 341, 16)
	GUICtrlSetBkColor($g_hProgressCPU, 0x0F1318)

	; Col 6: CPU Percentage (rowspan=2, spans rows 236-279)
	Local $hPanelCPUPerc = GUICtrlCreateGraphic(475, 236, 84, 43)
	GUICtrlSetBkColor($hPanelCPUPerc, 0x0F1318)
	$g_hLabelCPUPerc = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelCPUPerc), "0%", 3, 4, 78, 36, 18, Default, 0, 1, 0xFF8000)
	_GUICtrlFFLabel_SetData($g_hLabelCPUPerc, "0%", 0x0F1318)

	GUICtrlCreateGraphic(-10, 90, $g_iCoreGuiWidth + 20, 338, $SS_ETCHEDFRAME) ; Increased from 295 to 338 (+43px)
	GUICtrlCreateGraphic(-12, 92, $g_iCoreGuiWidth + 24, 334)
	GUICtrlSetBkColor(-1, 0x151C23)

	$g_hPanelRAMBox = GUICtrlCreateGraphic(20, 125, 104, 108, -1)
	GUICtrlSetBkColor($g_hPanelRAMBox, 0x0F1318)
	$g_hIconMemStats = GUICtrlCreateIcon(@ScriptFullPath, $g_iMemStatIcoStart, 38, 140, 64, 64)
	$g_hLabelRAMPerc = _GUICtrlFFLabel_Create(GUICtrlGetHandle($g_hPanelRAMBox), "100%", 0, 83, 104, 16, 9, Default, 0, 1, 0x13FF92)
	_GUICtrlFFLabel_SetData($g_hLabelRAMPerc, "100%", 0x0F1318)

	GUICtrlCreateGraphic(127, 125, 432, 108)
	GUICtrlSetBkColor(-1, 0x0F1318)

	GUICtrlCreateGraphic(20, 102, 104, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("MEMORY", 20, 105, 104, 16, $SS_CENTER)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCtrlSetColor(-1, 0xCCCCCC)
	Local $hPanelRAMTotal = GUICtrlCreateGraphic(127, 102, 84, 20, -1)
	GUICtrlSetBkColor($hPanelRAMTotal, 0x0F1318)
	$g_hLabelRAMTotal = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelRAMTotal), "00.0 GB", 4, 3, 78, 16, 9, Default, 0, 0, 0x13FF92)
_GUICtrlFFLabel_SetData($g_hLabelRAMTotal, "00.0 GB", 0x0F1318)

	GUICtrlCreateGraphic(214, 102, 84, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("USED", 218, 105, 78, 16)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)
	Local $hPanelRAMUsed = GUICtrlCreateGraphic(301, 102, 84, 20)
	GUICtrlSetBkColor($hPanelRAMUsed, 0x0F1318)
	$g_hLabelRAMUsed = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelRAMUsed), "00.0 GB", 4, 3, 78, 16, 9, Default, 0, 0, 0x13FF92)
_GUICtrlFFLabel_SetData($g_hLabelRAMUsed, "00.0 GB", 0x0F1318)

	GUICtrlCreateGraphic(388, 102, 84, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("FREE", 392, 105, 78, 16)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)
	Local $hPanelRAMFree = GUICtrlCreateGraphic(475, 102, 84, 20)
	GUICtrlSetBkColor($hPanelRAMFree, 0x0F1318)
	$g_hLabelRAMFree = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelRAMFree), "00.0 GB", 4, 3, 78, 16, 9, Default, 0, 0, 0x13FF92)
_GUICtrlFFLabel_SetData($g_hLabelRAMFree, "00.0 GB", 0x0F1318)


	; === PAGED POOL ROW (Grid Row - matches 6-column structure) ===
	; Col 1: Paged Pool Label
	GUICtrlCreateGraphic(20, 259, 104, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("PAGED POOL", 20, 262, 104, 16, $SS_CENTER)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)

	; Col 2: Paged Pool Value
	Local $hPanelPagedPool = GUICtrlCreateGraphic(127, 259, 84, 20)
	GUICtrlSetBkColor($hPanelPagedPool, 0x0F1318)
	$g_hLabelPagedPool = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelPagedPool), "0.0 GB", 4, 3, 80, 16, 9, Default, 0, 0, 0xFFFF00)
_GUICtrlFFLabel_SetData($g_hLabelPagedPool, "0.0 GB", 0x0F1318)

	; Col 3: Non-Paged Label
	GUICtrlCreateGraphic(214, 259, 84, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("NON-PAGED", 218, 262, 80, 16)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)

	; Col 4: Non-Paged Value
	Local $hPanelNonPagedPool = GUICtrlCreateGraphic(301, 259, 84, 20)
	GUICtrlSetBkColor($hPanelNonPagedPool, 0x0F1318)
	$g_hLabelNonPagedPool = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelNonPagedPool), "0.0 GB", 4, 3, 80, 16, 9, Default, 0, 0, 0xFFFF00)
_GUICtrlFFLabel_SetData($g_hLabelNonPagedPool, "0.0 GB", 0x0F1318)

	; Col 5-6: Covered by CPU Percentage rowspan from above (no elements here)

	; Cached memory composition (23px gap from Paged Pool)
	Local $hPanelCachedHeader = GUICtrlCreateGraphic(20, 282, 104, 20)
	GUICtrlSetBkColor($hPanelCachedHeader, 0x0F1318)
	GUICtrlCreateLabel("CACHED", 20, 285, 104, 16, $SS_CENTER)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $hPanelCachedTotal = GUICtrlCreateGraphic(127, 282, 84, 20)
	GUICtrlSetBkColor($hPanelCachedTotal, 0x0F1318)
	$g_hLabelCachedTotal = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelCachedTotal), "00.0 GB", 4, 3, 80, 16, 9, Default, 0, 0, 0xFFFF00)
_GUICtrlFFLabel_SetData($g_hLabelCachedTotal, "00.0 GB", 0x0F1318)

	GUICtrlCreateGraphic(214, 282, 84, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("IN USE", 218, 285, 80, 16)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)

	Local $hPanelCachedUsed = GUICtrlCreateGraphic(301, 282, 84, 20)
	GUICtrlSetBkColor($hPanelCachedUsed, 0x0F1318)
	$g_hLabelCachedUsed = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelCachedUsed), "00.0 GB", 4, 3, 80, 16, 9, Default, 0, 0, 0xFFFF00)
_GUICtrlFFLabel_SetData($g_hLabelCachedUsed, "00.0 GB", 0x0F1318)

	GUICtrlCreateGraphic(388, 282, 84, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("CACHED", 392, 285, 80, 16)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)

	Local $hPanelCachedFree = GUICtrlCreateGraphic(475, 282, 84, 20)
	GUICtrlSetBkColor($hPanelCachedFree, 0x0F1318)
	$g_hLabelCachedFree = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelCachedFree), "00.0 GB", 4, 3, 80, 16, 9, Default, 0, 0, 0xFFFF00)
_GUICtrlFFLabel_SetData($g_hLabelCachedFree, "00.0 GB", 0x0F1318)

	; Committed memory mini-panel (23px gap from Cached)
	Local $hPanelCommittedHeader = GUICtrlCreateGraphic(20, 305, 104, 20)
	GUICtrlSetBkColor($hPanelCommittedHeader, 0x0F1318)
	GUICtrlCreateLabel("COMMITTED", 20, 308, 104, 16, $SS_CENTER)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlSetColor(-1, 0xFFFFFF)

	Local $hPanelCommittedTotal = GUICtrlCreateGraphic(127, 305, 84, 20)
	GUICtrlSetBkColor($hPanelCommittedTotal, 0x0F1318)
	$g_hLabelCommittedTotal = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelCommittedTotal), "00.0 GB", 4, 3, 80, 16, 9, Default, 0, 0, 0x00ACFF)
_GUICtrlFFLabel_SetData($g_hLabelCommittedTotal, "00.0 GB", 0x0F1318)

	GUICtrlCreateGraphic(214, 305, 84, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("USED", 218, 308, 80, 16)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)

	Local $hPanelCommittedUsed = GUICtrlCreateGraphic(301, 305, 84, 20)
	GUICtrlSetBkColor($hPanelCommittedUsed, 0x0F1318)
	$g_hLabelCommittedUsed = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelCommittedUsed), "00.0 GB", 4, 3, 80, 16, 9, Default, 0, 0, 0x00ACFF)
_GUICtrlFFLabel_SetData($g_hLabelCommittedUsed, "00.0 GB", 0x0F1318)

	GUICtrlCreateGraphic(388, 305, 84, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("FREE", 392, 308, 78, 16)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)

	Local $hPanelCommittedFree = GUICtrlCreateGraphic(475, 305, 84, 20)
	GUICtrlSetBkColor($hPanelCommittedFree, 0x0F1318)
	$g_hLabelCommittedFree = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelCommittedFree), "00.0 GB", 4, 3, 78, 16, 9, Default, 0, 0, 0x00ACFF)
_GUICtrlFFLabel_SetData($g_hLabelCommittedFree, "00.0 GB", 0x0F1318)

	Local $hPanelCommittedPerc = GUICtrlCreateGraphic(20, 328, 104, 20)
	GUICtrlSetBkColor($hPanelCommittedPerc, 0x0F1318)
	$g_hLabelCommittedPerc = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelCommittedPerc), "0%", 0, 2, 104, 16, 9, Default, 0, 1, 0x00ACFF)
_GUICtrlFFLabel_SetData($g_hLabelCommittedPerc, "0%", 0x0F1318)

	GUICtrlCreateGraphic(127, 328, 345, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	$g_hProgressCommitted = GUICtrlCreateGraphic(129, 330, 341, 16)
	GUICtrlSetBkColor($g_hProgressCommitted, 0x0F1318)

	; Processes / count / timer block (23px gap from Committed progress)
	GUICtrlCreateGraphic(20, 351, 104, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("PROCS", 20, 354, 104, 16, $SS_CENTER)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)
	Local $hPanelProcs = GUICtrlCreateGraphic(127, 351, 84, 20)
	GUICtrlSetBkColor($hPanelProcs, 0x0F1318)
	$g_hLabelProcs = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelProcs), "0", 4, 2, 80, 16, 9, Default, 0, 0, 0x13FF92)
_GUICtrlFFLabel_SetData($g_hLabelProcs, "0", 0x0F1318)

	GUICtrlCreateGraphic(214, 351, 84, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("COUNT", 218, 354, 80, 16)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)
	Local $hPanelCount = GUICtrlCreateGraphic(301, 351, 84, 20)
	GUICtrlSetBkColor($hPanelCount, 0x0F1318)
	$g_hLabelCount = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelCount), "0", 4, 2, 80, 16, 9, Default, 0, 0, 0x13FF92)
	_GUICtrlFFLabel_SetData($g_hLabelCount, "0", 0x0F1318)

	GUICtrlCreateGraphic(388, 351, 84, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GUICtrlCreateLabel("TIMER", 392, 354, 78, 16)
	GUICtrlSetBkColor(-1, 0x0F1318)
	GuiCTrlSetColor(-1, 0xCCCCCC)
	Local $hPanelTimer = GUICtrlCreateGraphic(475, 351, 84, 43)
	GUICtrlSetBkColor($hPanelTimer, 0x0F1318)
	$g_hLabelTimer = _GUICtrlFFLabel_Create(GUICtrlGetHandle($hPanelTimer), "30", 3, 4, 78, 36, 18, Default, 0, 1, 0x13FF92)
	_GUICtrlFFLabel_SetData($g_hLabelTimer, "30", 0x0F1318)

	$g_hPanelCountPerc = GUICtrlCreateGraphic(20, 374, 104, 20)
	GUICtrlSetBkColor($g_hPanelCountPerc, 0x0F1318)
	$g_hLabelCountPerc = _GUICtrlFFLabel_Create(GUICtrlGetHandle($g_hPanelCountPerc), "100%", 0, 2, 104, 16, 9, Default, 0, 1, 0x13FF92)
	_GUICtrlFFLabel_SetData($g_hLabelCountPerc, "100%", 0x0F1318)

	GUICtrlCreateGraphic(127, 374, 345, 20)
	GUICtrlSetBkColor(-1, 0x0F1318)
	$g_hProgressProcs[0] = GUICtrlCreateGraphic(129, 376, 341, 16)
	GUICtrlSetBkColor($g_hProgressProcs[0], 0x0F1318)

	; Buttons (Optimize, Preferences, Close) - moved down 43px
	$g_hBtnOptimize = GUICtrlCreateButton("Optimize Memory", 20, 461, 260, 30)
	GUICtrlSetOnEvent($g_hBtnOptimize, "_OptimizeMemory")

	$g_hBtnPreferences = GUICtrlCreateButton("Preferences", 290, 461, 140, 30)
	GUICtrlSetOnEvent($g_hBtnPreferences, "_ShowPreferencesDlg")

	Global $g_hBtnClose = GUICtrlCreateButton("Close", 440, 461, 120, 30)
	GUICtrlSetOnEvent($g_hBtnClose, "_MinimizeToTray")

	; Force behave checkbox - moved down 43px
	Global $g_hCheckForceBehave = GUICtrlCreateCheckbox(" Force malicious processes to behave", 20, 501, 540, 20)
	GUICtrlSetState($g_hCheckForceBehave, $g_iForceBehave)
	GUICtrlSetBkColor($g_hCheckForceBehave, $GUI_BKCOLOR_TRANSPARENT)
	GUICtrlSetColor($g_hCheckForceBehave, 0xFFFFFF)
	GUICtrlSetOnEvent($g_hCheckForceBehave, "_ToggleForceBehave")

	_Splash_Update("", 100)

	; Setup tray icon
	_SetupTrayIcon()

	; Show GUI first so FFLabels can properly initialize their graphics contexts
	GUISetState(@SW_SHOW, $g_hCoreGui)

	; Immediate initialization with double-update to survive WM_PAINT
	_UpdateMemoryStats()
	_UpdateTimer()
	_GUICtrlFFLabel_SetData($g_hLabelCount, String($g_iOptimizeCount), 0x0F1318)
	_GUICtrlFFLabel_Refresh()

	; Start all periodic updates AFTER window initialization complete
	AdlibRegister("_UpdateMemoryStats", 1000)
	AdlibRegister("_OnIconsHover", 65)
	AdlibRegister("_UpdateTimer", 1000) ; Timer countdown every second
	AdlibRegister("_UpdateTrayIcon", 5000) ; Update tray icon every 5 seconds

	If @Compiled Then
		AdlibRegister("_ReduceMemory", $g_iReduceEveryMill)
	EndIf

	If $g_iCheckForUpdates == 4 Then
		_SoftwareUpdateCheck()
	EndIf

	While 1
		Sleep(30)
	WEnd

EndFunc

Func _UpdateMemoryStatsFirst()

	Local $aPerfInfo = _WinAPI_GetPerformanceInfo()
	If IsArray($aPerfInfo) Then
		; Total physical memory (bytes -> MB -> GB)
		Local $iMemTotalMB = Floor($aPerfInfo[3] / 1024 / 1024)
		Local $iMemTotalGB = Round($iMemTotalMB / 1024, 1)
		_GUICtrlFFLabel_SetData($g_hLabelRAMTotal, StringFormat("%.1f GB", $iMemTotalGB), 0x0F1318)
	EndIf

	; Update process count
	Local $aProcessList = ProcessList()
	_GUICtrlFFLabel_SetData($g_hLabelProcs, String($aProcessList[0][0]), 0x0F1318)

EndFunc




Func _UpdateMemoryStats()

	; Query system performance info once and derive all memory stats from it
	Local $aPerfInfo = _WinAPI_GetPerformanceInfo()
	If Not IsArray($aPerfInfo) Then Return

	; Physical memory (bytes -> MB/GB)
	Local $iMemTotalMB = Floor($aPerfInfo[3] / 1024 / 1024)
	Local $iMemAvailMB = Floor($aPerfInfo[4] / 1024 / 1024)
	Local $iMemTotalGB = Round($iMemTotalMB / 1024, 1)
	Local $iMemAvailGB = Round($iMemAvailMB / 1024, 1)
	Local $iMemUsedMB = $iMemTotalMB - $iMemAvailMB
	If $iMemUsedMB < 0 Then $iMemUsedMB = 0
	Local $iMemUsedGB = Round($iMemUsedMB / 1024, 1)

	; RAM load (%) derived from PerfInfo (Task Manager style)
	Local $iMemLoad = 0
	If $iMemTotalMB > 0 Then $iMemLoad = Round(($iMemUsedMB / $iMemTotalMB) * 100)

	; Update total RAM label
	_GUICtrlFFLabel_SetData($g_hLabelRAMTotal, StringFormat("%.1f GB", $iMemTotalGB), 0x0F1318)

	Local $iIconIndex = 0
	If $iMemLoad > 0 Then
		$iIconIndex = Floor($iMemLoad / 2.5)
	EndIf

	; Only update icon if it changed to prevent flickering
	If $iMemLoad <> $g_aMemBuffers[$MEM_LOAD] Then
		GUICtrlSetImage($g_hIconMemStats, @ScriptFullPath, $g_iMemStatIcoStart + $iIconIndex)
	EndIf

	_GUICtrlFFLabel_SetData($g_hLabelRAMPerc, StringFormat("%d%", $iMemLoad), 0x0F1318)

	$g_aMemBuffers[$MEM_LOAD] = $iMemLoad

	; Update RAM usage and free space display when available RAM changes
	Local $iRAMFree = $iMemAvailGB
	Local $iRAMUsed = $iMemUsedGB

	_GUICtrlFFLabel_SetData($g_hLabelRAMUsed, StringFormat("%.1f GB", $iRAMUsed), 0x0F1318)
	_GUICtrlFFLabel_SetData($g_hLabelRAMFree, StringFormat("%.1f GB", $iRAMFree), 0x0F1318)
	$g_aMemBuffers[$MEM_AVAILPHYSRAM] = $iRAMFree

	; Update process count
	Local $aProcessList = ProcessList()
	_GUICtrlFFLabel_SetData($g_hLabelProcs, String($aProcessList[0][0]), 0x0F1318)

	; Cached and committed memory panels and kernel pools
	Local $iCachedMB = Floor($aPerfInfo[5] / 1024 / 1024)
	Local $iCachedGB = Round($iCachedMB / 1024, 1)
	; Cached % no longer shown

	Local $iCachedInUseGB = Round($iMemTotalGB - $iMemAvailGB - $iCachedGB, 1)
	If $iCachedInUseGB < 0 Then $iCachedInUseGB = 0

	Local $iCommitTotalMB = Floor($aPerfInfo[0] / 1024 / 1024)
	Local $iCommitLimitMB = Floor($aPerfInfo[1] / 1024 / 1024)
	Local $iCommitPerc = 0
	If $iCommitLimitMB > 0 Then $iCommitPerc = Round(($iCommitTotalMB / $iCommitLimitMB) * 100)

	Local $iCommitTotalGB = Round($iCommitTotalMB / 1024, 1)
	Local $iCommitLimitGB = Round($iCommitLimitMB / 1024, 1)
	Local $iCommitFreeGB = Round($iCommitLimitGB - $iCommitTotalGB, 1)
	If $iCommitFreeGB < 0 Then $iCommitFreeGB = 0

	; Update Paged and Non-Paged Pool
	Local $iPagedPoolMB = Floor($aPerfInfo[7] / 1024 / 1024)
	Local $iNonPagedPoolMB = Floor($aPerfInfo[8] / 1024 / 1024)
	Local $iPagedPoolGB = Round($iPagedPoolMB / 1024, 1)
	Local $iNonPagedPoolGB = Round($iNonPagedPoolMB / 1024, 1)

	_GUICtrlFFLabel_SetData($g_hLabelPagedPool, StringFormat("%.1f GB", $iPagedPoolGB), 0x0F1318)
	_GUICtrlFFLabel_SetData($g_hLabelNonPagedPool, StringFormat("%.1f GB", $iNonPagedPoolGB), 0x0F1318)

	; Cached section: TOTAL = physical RAM, IN USE = active memory, CACHED = system cache
	_GUICtrlFFLabel_SetData($g_hLabelCachedTotal, StringFormat("%.1f GB", $iMemTotalGB), 0x0F1318)
	_GUICtrlFFLabel_SetData($g_hLabelCachedUsed, StringFormat("%.1f GB", $iCachedInUseGB), 0x0F1318)
	_GUICtrlFFLabel_SetData($g_hLabelCachedFree, StringFormat("%.1f GB", $iCachedGB), 0x0F1318)

	; Committed: TOTAL = commit limit, USED = commit total, FREE = limit - total
	_GUICtrlFFLabel_SetData($g_hLabelCommittedTotal, StringFormat("%.1f GB", $iCommitLimitGB), 0x0F1318)
	_GUICtrlFFLabel_SetData($g_hLabelCommittedUsed, StringFormat("%.1f GB", $iCommitTotalGB), 0x0F1318)
	_GUICtrlFFLabel_SetData($g_hLabelCommittedFree, StringFormat("%.1f GB", $iCommitFreeGB), 0x0F1318)
	_GUICtrlFFLabel_SetData($g_hLabelCommittedPerc, StringFormat("%d%%", $iCommitPerc), 0x0F1318)
	_GDIPlusProgressBar_Draw($g_hProgressCommitted, $iCommitPerc, 0x0F1318, 0x00ACFF, 0x005174)

	; Update memory usage graph based on the PerfInfo-derived RAM load
	_SSLG_AddSample($Graph1, $iMemLoad)
	_SSLG_UpdateGraph($Graph1, False, True)

	; Update CPU usage progress bar (orange color)
	Local $iCPUUsage = _GetCPUUsage()
	_GUICtrlFFLabel_SetData($g_hLabelCPUPerc, StringFormat("%d%%", $iCPUUsage), 0x0F1318)
	_GDIPlusProgressBar_Draw($g_hProgressCPU, $iCPUUsage, 0x0F1318, 0xFF8000, 0x803000)  ; Orange bar with darker background


EndFunc   ;==>_UpdateMemoryStats


Func _GetCPUUsage()
	; Simple CPU usage calculation using processor time
	Static $lastIdleTime = 0, $lastKernelTime = 0, $lastUserTime = 0

	Local $aInfo = DllCall("kernel32.dll", "bool", "GetSystemTimes", "int64*", 0, "int64*", 0, "int64*", 0)
	If @error Or Not $aInfo[0] Then Return 0

	Local $idleTime = $aInfo[1]
	Local $kernelTime = $aInfo[2]
	Local $userTime = $aInfo[3]

	If $lastIdleTime = 0 Then
		$lastIdleTime = $idleTime
		$lastKernelTime = $kernelTime
		$lastUserTime = $userTime
		Return 0
	EndIf

	Local $idle = $idleTime - $lastIdleTime
	Local $kernel = $kernelTime - $lastKernelTime
	Local $user = $userTime - $lastUserTime
	Local $system = $kernel + $user

	$lastIdleTime = $idleTime
	$lastKernelTime = $kernelTime
	$lastUserTime = $userTime

	Local $iCPU = 0
	If $system > 0 Then
		$iCPU = Round((($system - $idle) / $system) * 100)
	EndIf

	If $iCPU < 0 Then $iCPU = 0
	If $iCPU > 100 Then $iCPU = 100

	Return $iCPU
EndFunc   ;==>_GetCPUUsage


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

	; New optimization and behavior settings
	$g_iAutoOptimize = Int(IniRead($g_sPathIni, $g_sProgShortName, "AutoOptimize", 2))
	$g_iAutoOptimizeSeconds = Int(IniRead($g_sPathIni, $g_sProgShortName, "AutoOptimizeSeconds", 60))
	$g_iForceBehave = Int(IniRead($g_sPathIni, $g_sProgShortName, "ForceBehave", 0))
	$g_iStartWithWindows = Int(IniRead($g_sPathIni, $g_sProgShortName, "StartWithWindows", 0))
	$g_iAlwaysOnTop = Int(IniRead($g_sPathIni, $g_sProgShortName, "AlwaysOnTop", 0))
	$g_iShowNotifications = Int(IniRead($g_sPathIni, $g_sProgShortName, "ShowNotifications", 1))
	$g_iPlaySounds = Int(IniRead($g_sPathIni, $g_sProgShortName, "PlaySounds", 0))
	$g_iPlayWarnings = Int(IniRead($g_sPathIni, $g_sProgShortName, "PlayWarnings", 0))
	$g_iWarnEvery = Int(IniRead($g_sPathIni, $g_sProgShortName, "WarnEvery", 60))
	$g_iWarnIfLoad = Int(IniRead($g_sPathIni, $g_sProgShortName, "WarnIfLoad", 80))

	; Initialize timer countdown
	If $g_iAutoOptimize = 2 Then
		$g_iTimerCountdown = $g_iAutoOptimizeSeconds
	EndIf

	; Apply always on top setting
	If $g_iAlwaysOnTop = 1 Then
		WinSetOnTop($g_hCoreGui, "", 1)
	EndIf

	If @Compiled Then
		ProcessSetPriority(@ScriptName, $g_iProcessPriority)
	EndIf
EndFunc   ;==>_LoadConfiguration


Func _SaveConfiguration()

	IniWrite($g_sPathIni, $g_sProgShortName, "CheckForUpdates", $g_iCheckForUpdates)
	IniWrite($g_sPathIni, $g_sProgShortName, "ProcessPriority", $g_iProcessPriority)
	IniWrite($g_sPathIni, $g_sProgShortName, "SaveRealtime", $g_iSaveRealtime)
	IniWrite($g_sPathIni, $g_sProgShortName, "ReduceMemory", $g_iReduceMemory)
	IniWrite($g_sPathIni, $g_sProgShortName, "LoggingEnabled", $g_iLoggingEnabled)
	IniWrite($g_sPathIni, $g_sProgShortName, "LoggingStorageSize", $g_iLoggingStorage)

	; Save new settings
	IniWrite($g_sPathIni, $g_sProgShortName, "AutoOptimize", $g_iAutoOptimize)
	IniWrite($g_sPathIni, $g_sProgShortName, "AutoOptimizeSeconds", $g_iAutoOptimizeSeconds)
	IniWrite($g_sPathIni, $g_sProgShortName, "ForceBehave", $g_iForceBehave)
	IniWrite($g_sPathIni, $g_sProgShortName, "StartWithWindows", $g_iStartWithWindows)
	IniWrite($g_sPathIni, $g_sProgShortName, "AlwaysOnTop", $g_iAlwaysOnTop)
	IniWrite($g_sPathIni, $g_sProgShortName, "ShowNotifications", $g_iShowNotifications)
	IniWrite($g_sPathIni, $g_sProgShortName, "PlaySounds", $g_iPlaySounds)
	IniWrite($g_sPathIni, $g_sProgShortName, "PlayWarnings", $g_iPlayWarnings)
	IniWrite($g_sPathIni, $g_sProgShortName, "WarnEvery", $g_iWarnEvery)
	IniWrite($g_sPathIni, $g_sProgShortName, "WarnIfLoad", $g_iWarnIfLoad)

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


Func _OptimizeMemory()

	If $g_iOptimizing = 1 Then Return ; Already optimizing

	$g_iOptimizing = 1
	$g_iOptimizeCount += 1

	; Reset timer countdown if auto-optimize is enabled
	If $g_iAutoOptimize = 2 Then
		$g_iTimerCountdown = $g_iAutoOptimizeSeconds
	EndIf

	; Disable buttons and menu during optimization
	GUICtrlSetState($g_hBtnOptimize, $GUI_DISABLE)
	GUICtrlSetState($g_hBtnPreferences, $GUI_DISABLE)
	_SetProcessingStates($GUI_DISABLE)

	; Get process list
	Local $aProcsList = ProcessList()
	Local $iTotalProcs = $aProcsList[0][0]

	; Update status
	_GUICtrlFFLabel_SetData($g_hLabelCount, String($g_iOptimizeCount), 0x0F1318)
	GUICtrlSetData($g_hSubHeading, $g_aLangCustom[2])

	; Double-update: ensures buffers fresh before and after WM_PAINT
	_UpdateMemoryStats()
	_WinAPI_UpdateWindow($g_hCoreGui)
	_UpdateMemoryStats()

	; Force full refresh of ALL labels to ensure count and timer stay visible
	_GUICtrlFFLabel_Refresh()

	; Loop through all processes and clear working set
	Local $iLastProgress = -1
	Local $iProcessedCount = 0
	For $i = 1 To $iTotalProcs
		; Skip our own process to prevent clearing our GDI resources
		If $aProcsList[$i][1] = @AutoItPID Then ContinueLoop

		; Skip excluded processes
		Local $bExcluded = False
		For $j = 0 To UBound($g_aExcludeProcesses) - 1
			If StringInStr($aProcsList[$i][0], $g_aExcludeProcesses[$j]) > 0 Then
				$bExcluded = True
				ExitLoop
			EndIf
		Next
		If $bExcluded Then ContinueLoop

		; Only optimize idle/low-activity processes (best practice from research)
		_WinAPI_EmptyWorkingSet($aProcsList[$i][1])
		$iProcessedCount += 1

		; Force behave: reduce priority of high-priority processes
		If $g_iForceBehave = 1 Then
			Local $iPriority = _ProcessGetPriority($aProcsList[$i][1])
			If $iPriority > 2 Then ; If priority is above Normal
				ProcessSetPriority($aProcsList[$i][0], 2) ; Set to Normal
			EndIf
		EndIf

		; Update progress on process counter bar (every 5% for better performance)
		Local $iProgress = Floor(($i / $iTotalProcs) * 100)
		If Mod($iProgress, 5) = 0 And $iProgress <> $iLastProgress Then
			_GUICtrlFFLabel_SetData($g_hLabelCountPerc, StringFormat("%d%%", $iProgress), 0x0F1318)
			_GDIPlusProgressBar_Draw($g_hProgressProcs[0], $iProgress, 0x0F1318, 0x13FF92, 0x085820)
			$iLastProgress = $iProgress
		EndIf

		; Sleep every 10 processes instead of every process (90% faster)
		If Mod($i, 10) = 0 Then Sleep(1)
	Next

	; Reset progress bar
	_GDIPlusProgressBar_Draw($g_hProgressProcs[0], 0, 0x0F1318, 0x13FF92, 0x085820)
	_GUICtrlFFLabel_SetData($g_hLabelCountPerc, "0%", 0x0F1318)

	; Update status with actual processed count
	GUICtrlSetData($g_hSubHeading, StringFormat($g_aLangCustom[3], $iProcessedCount))

	; Show completion notification
	If $g_iShowNotifications = 1 Then
		TrayTip("Optimization Complete", StringFormat("Optimized %d processes", $iProcessedCount), 3, $TIP_ICONASTERISK)
	EndIf

	; Re-enable buttons and menu
	GUICtrlSetState($g_hBtnOptimize, $GUI_ENABLE)
	GUICtrlSetState($g_hBtnPreferences, $GUI_ENABLE)
	_SetProcessingStates($GUI_ENABLE)

	; Update memory stats to show post-optimization results
	$g_iOptimizing = 0

	; Double-update pattern: ensures buffers and graphics survive WM_PAINT
	_UpdateMemoryStats()
	_WinAPI_UpdateWindow($g_hCoreGui)
	_UpdateMemoryStats()

	; Force full refresh of ALL labels to ensure count and timer stay visible
	_GUICtrlFFLabel_Refresh()

EndFunc   ;==>_OptimizeMemory


Func _UpdateTimer()

	; Handle automatic optimization modes
	If $g_iAutoOptimize = 1 Then ; Intelligent mode
		Local $aMemStats = MemGetStats()

		; Track memory history for trend detection
		$g_aMemoryHistory[$g_iMemoryHistoryIndex] = $aMemStats[$MEM_LOAD]
		$g_iMemoryHistoryIndex = Mod($g_iMemoryHistoryIndex + 1, 10)

		; Only optimize if memory is high AND increasing (smart detection)
		If $aMemStats[$MEM_LOAD] > 90 And _IsMemoryIncreasing() Then
			_OptimizeMemory()
		EndIf
		_GUICtrlFFLabel_SetData($g_hLabelTimer, "AUTO", 0x0F1318)

	ElseIf $g_iAutoOptimize = 2 Then ; Timer mode
		$g_iTimerCountdown -= 1

		If $g_iTimerCountdown <= 0 Then
			$g_iTimerCountdown = $g_iAutoOptimizeSeconds
			_OptimizeMemory()
		Else
			_GUICtrlFFLabel_SetData($g_hLabelTimer, String($g_iTimerCountdown), 0x0F1318)
		EndIf

	Else ; Manual mode
		_GUICtrlFFLabel_SetData($g_hLabelTimer, "OFF", 0x0F1318)
	EndIf

EndFunc   ;==>_UpdateTimer


Func _IsMemoryIncreasing()
	; Check if memory usage is trending upward over last 10 readings
	; Returns True if memory increased in majority of recent samples

	Local $iIncreaseCount = 0
	For $i = 1 To 9
		Local $iPrev = Mod(($g_iMemoryHistoryIndex + $i - 1 + 10), 10)
		Local $iCurr = Mod(($g_iMemoryHistoryIndex + $i), 10)
		If $g_aMemoryHistory[$iCurr] > $g_aMemoryHistory[$iPrev] Then
			$iIncreaseCount += 1
		EndIf
	Next

	; Return True if memory increased in at least 6 of last 9 intervals
	Return ($iIncreaseCount >= 6)
EndFunc   ;==>_IsMemoryIncreasing


Func _ReduceMemory()

	Local $aMemStats = MemGetStats()

	If $aMemStats[0] > $g_iMaxSysMemoryPerc And $g_iReduceMemory = 1 Then
		_WinAPI_EmptyWorkingSet()
	EndIf

EndFunc


Func _ShutdownProgram()

	; Unregister all periodic tasks
	AdlibUnRegister("_OnIconsHover")
	AdlibUnRegister("_UpdateMemoryStats")
	AdlibUnRegister("_UpdateTimer")
	AdlibUnRegister("_UpdateTrayIcon")

	If @Compiled Then
		AdlibUnRegister("_ReduceMemory")
	EndIf

	; Cleanup tray icon
	TraySetState($TRAY_ICONSTATE_HIDE)

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

	If $g_iSingleton Then
		Local $iPID = ProcessExists(@ScriptName)
		If $iPID Then ProcessClose($iPID)
	EndIf

EndFunc


Func _MinimizeProgram()

	Local $iState = WinGetState($g_hCoreGui)

	If BitAND($iState, 4) Then
		_MinimizeToTray()
	EndIf

EndFunc   ;==>_MinimizeProgram


Func _SetupTrayIcon()

	; Set tray mode
	Opt("TrayMenuMode", 3) ; No default items
	Opt("TrayOnEventMode", 1)

	; Load tray icons (for development mode only)
	For $i = 0 To 11
		$g_aTrayIcons[$i] = "..\..\Resources\Icons\MemBoost\Tray\" & $i & ".ico"
	Next

	; Set initial tray icon (0% = icon 0 = resource 350)
	If @Compiled Then
		TraySetIcon(@ScriptFullPath, 350)
	Else
		TraySetIcon($g_aTrayIcons[0])
	EndIf
	TraySetToolTip($g_sProgramTitle)

	; Create tray menu
	$g_hTrayShowHide = TrayCreateItem("Show/Hide Memory Booster")
	TrayItemSetOnEvent($g_hTrayShowHide, "_ToggleShowHide")
	TrayCreateItem("")
	$g_hTrayOptimize = TrayCreateItem("Optimize Memory Now")
	TrayItemSetOnEvent($g_hTrayOptimize, "_OptimizeMemory")
	TrayCreateItem("")
	$g_hTrayExit = TrayCreateItem("Exit")
	TrayItemSetOnEvent($g_hTrayExit, "_ShutdownProgram")

	TraySetState(1) ; Show tray icon

EndFunc   ;==>_SetupTrayIcon


Func _UpdateTrayIcon()

	$g_aMemStats = MemGetStats()
	Local $iMemLoad = $g_aMemStats[$MEM_LOAD]

	; OLD VERSION EXACT FORMULA: Local $OneDig = StringLeft($MemInfo[0], 1)
	; Gets first digit: 0-9% = "0", 10-19% = "1", 20-29% = "2", ..., 100% = "1"
	; Then: TraySetIcon(@ScriptFullPath, (-1 * ($OneDig + 6)))
	; So: 0-9% → -6, 10-19% → -7, 20-29% → -8, ..., 90-99% → -15, 100% → -7 (wraps)
	; New resources: 350 to 361 (12 icons for 0-100%), separate from main GUI icons (201-321)
	; Mapping: 0-9%=350, 10-19%=351, 20-29%=352, ..., 100%=360
	Local $iOneDig = Int(StringLeft(String($iMemLoad), 1))

	; Cap at 10 for 100% (shows icon 10), but we have 12 icons (0-11)
	If $iMemLoad = 100 Then $iOneDig = 10
	If $iOneDig > 11 Then $iOneDig = 11

	If @Compiled Then
		; Use explicit resource IDs 350-361 for tray icons
		TraySetIcon(@ScriptFullPath, 350 + $iOneDig)
	Else
		TraySetIcon($g_aTrayIcons[$iOneDig])
	EndIf

	; Tooltip: program title, separator, memory usage, plus key stats
	Local $iTotalRAMGB = Round($g_aMemStats[$MEM_TOTALPHYSRAM] / 1048576, 1)
	Local $iUsedRAMGB = Round(($g_aMemStats[$MEM_TOTALPHYSRAM] - $g_aMemStats[$MEM_AVAILPHYSRAM]) / 1048576, 1)
	Local $iTotalPageGB = Round($g_aMemStats[$MEM_TOTALPAGEFILE] / 1048576, 1)
	Local $iUsedPageGB = Round(($g_aMemStats[$MEM_TOTALPAGEFILE] - $g_aMemStats[$MEM_AVAILPAGEFILE]) / 1048576, 1)
	Local $aProcs = ProcessList()
	Local $iProcCount = $aProcs[0][0]

	TraySetToolTip($g_sProgramTitle & @CRLF & _
					"----------------------------------------" & @CRLF & _
					"Memory Usage: " & $iMemLoad & "%" & @CRLF & _
					"RAM: " & StringFormat("%.1f/%.1f GB used", $iUsedRAMGB, $iTotalRAMGB) & @CRLF & _
					"Pagefile: " & StringFormat("%.1f/%.1f GB used", $iUsedPageGB, $iTotalPageGB) & @CRLF & _
					"Processes: " & $iProcCount)

EndFunc   ;==>_UpdateTrayIcon


Func _MinimizeToTray()

	GUISetState(@SW_HIDE, $g_hCoreGui)

EndFunc   ;==>_MinimizeToTray


Func _ToggleShowHide()

	If BitAND(WinGetState($g_hCoreGui), 2) Then ; If visible
		GUISetState(@SW_HIDE, $g_hCoreGui)
	Else
		GUISetState(@SW_SHOW, $g_hCoreGui)
		WinActivate($g_hCoreGui)
	EndIf

EndFunc   ;==>_ToggleShowHide


Func _ToggleForceBehave()

	If GUICtrlRead($g_hCheckForceBehave) = $GUI_CHECKED Then
		$g_iForceBehave = 1
	Else
		$g_iForceBehave = 0
	EndIf

	; Save immediately
	IniWrite($g_sPathIni, $g_sProgShortName, "ForceBehave", $g_iForceBehave)

EndFunc   ;==>_ToggleForceBehave


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

	GUICtrlCreateTabItem($g_aLangPreferences[24])

	; Optimization Modes Group
	GUICtrlCreateGroup("Memory Optimization Modes", 25, 50, 400, 110)
	GUICtrlSetFont(-1, 10, Default, 2)
	$g_hORADOptimMode[0] = GUICtrlCreateRadio(" Intelligent memory optimization", 35, 75, 360, 20)
	$g_hORADOptimMode[1] = GUICtrlCreateRadio(" Automatically optimize memory every", 35, 100, 240, 20)
	$g_hOComboAutSeconds = GUICtrlCreateCombo("", 285, 98, 55, 20)
	GUICtrlSetData($g_hOComboAutSeconds, "5|10|15|20|25|30|35|40|45|50|55|60|90|120", String($g_iAutoOptimizeSeconds))
	GUICtrlCreateLabel(" seconds", 345, 100, 60, 20)
	$g_hORADOptimMode[2] = GUICtrlCreateRadio(" Don't automatically optimize memory", 35, 125, 360, 20)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Set current optimization mode
	If $g_iAutoOptimize = 1 Then
		GUICtrlSetState($g_hORADOptimMode[0], $GUI_CHECKED)
	ElseIf $g_iAutoOptimize = 2 Then
		GUICtrlSetState($g_hORADOptimMode[1], $GUI_CHECKED)
	Else
		GUICtrlSetState($g_hORADOptimMode[2], $GUI_CHECKED)
	EndIf

	; Behavior Group
	GUICtrlCreateGroup("Behavior", 25, 170, 400, 90)
	GUICtrlSetFont(-1, 10, Default, 2)
	$g_hOCheckForceBehave = GUICtrlCreateCheckbox(" Force malicious processes to behave", 35, 195, 360, 20)
	GUICtrlSetState($g_hOCheckForceBehave, $g_iForceBehave)
	$g_hOCheckStartWindows = GUICtrlCreateCheckbox(" Start Memory Booster when Windows starts", 35, 220, 360, 20)
	GUICtrlSetState($g_hOCheckStartWindows, $g_iStartWithWindows)
	$g_hOCheckOnTop = GUICtrlCreateCheckbox(" Show Memory Booster always on top", 35, 245, 360, 20)
	GUICtrlSetState($g_hOCheckOnTop, $g_iAlwaysOnTop)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Notifications Group
	GUICtrlCreateGroup("Notifications and Sounds", 25, 270, 400, 140)
	GUICtrlSetFont(-1, 10, Default, 2)
	$g_hOCheckNotify = GUICtrlCreateCheckbox(" Show program notifications", 35, 295, 360, 20)
	GUICtrlSetState($g_hOCheckNotify, $g_iShowNotifications)
	$g_hOCheckPlayEvents = GUICtrlCreateCheckbox(" Play sounds on program events", 35, 320, 360, 20)
	GUICtrlSetState($g_hOCheckPlayEvents, $g_iPlaySounds)
	$g_hOCheckPlayWarnings = GUICtrlCreateCheckbox(" Play warning every", 35, 345, 140, 20)
	GUICtrlSetState($g_hOCheckPlayWarnings, $g_iPlayWarnings)
	$g_hOComboWarnEvery = GUICtrlCreateCombo("", 180, 344, 50, 20)
	GUICtrlSetData($g_hOComboWarnEvery, "1|3|5|10|15|30|60|120", String($g_iWarnEvery))
	GUICtrlCreateLabel(" seconds", 235, 347, 60, 20)
	GUICtrlCreateLabel("       if memory load exceeds", 35, 372, 180, 20)
	$g_hOComboWarnIf = GUICtrlCreateCombo("", 220, 370, 50, 20)
	GUICtrlSetData($g_hOComboWarnIf, "50|60|70|80|90|95", String($g_iWarnIfLoad))
	GUICtrlCreateLabel("%", 275, 372, 20, 20)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Set event handlers
	GUICtrlSetOnEvent($g_hORADOptimMode[0], "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hORADOptimMode[1], "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hORADOptimMode[2], "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOComboAutSeconds, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOCheckForceBehave, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOCheckStartWindows, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOCheckOnTop, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOCheckNotify, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOCheckPlayEvents, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOCheckPlayWarnings, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOComboWarnEvery, "__CheckPreferenceChange")
	GUICtrlSetOnEvent($g_hOComboWarnIf, "__CheckPreferenceChange")

	GUICtrlCreateTabItem("") ; end tabitem definition

	GUICtrlCreateTabItem(StringFormat(" %s ", $g_aLangPreferences[1]))
	GUICtrlCreateGroup($g_aLangPreferences[4], 25, 250, 400, 160)
	GUICtrlSetFont(-1, 10, Default, 2)
	$g_hOChkLogEnabled = GUICtrlCreateCheckbox($g_aLangPreferences[8], 35, 290, 200, 20)
	GUICtrlSetState($g_hOChkLogEnabled, $g_iLoggingEnabled)
	GUICtrlCreateLabel($g_aLangPreferences[9], 35, 320, 180, 20)
	$g_hOInLogSize = GUICtrlCreateInput(Round($g_iLoggingStorage / 1024, 2), 215, 318, 100, 20)
	GUICtrlSetStyle($g_hOInLogSize, BitOr($ES_RIGHT, $ES_NUMBER))
	GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
	GUICtrlCreateLabel("KB", 325, 320, 50, 20)
	$g_hOInLogSizeTemp = Int(GUICtrlRead($g_hOInLogSize))
	$g_hOLblLogSize = GUICtrlCreateLabel(StringFormat($g_aLangPreferences[10], __GetLoggingSize()), 35, 360, 200, 20)
	GUICtrlSetColor($g_hOLblLogSize, 0x555555)
	$g_hOBtnLogClear = GUICtrlCreateButton($g_aLangPreferences[11], 255, 355, 150, 30)
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
	GUICtrlSetFont($g_hOComboPower, 9, 400)
	If @Compiled Then
		$g_hOIconPower = GUICtrlCreateIcon(@ScriptFullPath, $g_iPowerIconsStart, 350, 80, 48, 48)
	Else
		$g_hOIconPower = GUICtrlCreateIcon("..\..\..\SDK\Resources\Icons\Power\Power-0.ico", 0, 350, 80, 48, 48)
	EndIf
	$g_hOChkSaveRealtime = GUICtrlCreateCheckbox($g_aLangPreferences[13], 35, 145, 360, 20)
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

	Local $hLangSearch = FileFindFirstFile($g_sLanguageDir & "\*.lng")
	While 1
		Local $sLangFileName = FileFindNextFile($hLangSearch)
		;~ If there is no more file matching the search.
		If @error Then ExitLoop
		If $sLangFileName = "en.lng" Then ContinueLoop

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

	; Always enable Save button when any preference control is changed
	GUICtrlSetState($g_hOBtnSave, $GUI_ENABLE)
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

	; Read optimization mode
	If GUICtrlRead($g_hORADOptimMode[0]) = $GUI_CHECKED Then
		$g_iAutoOptimize = 1
	ElseIf GUICtrlRead($g_hORADOptimMode[1]) = $GUI_CHECKED Then
		$g_iAutoOptimize = 2
		$g_iAutoOptimizeSeconds = Int(GUICtrlRead($g_hOComboAutSeconds))
		$g_iTimerCountdown = $g_iAutoOptimizeSeconds
	Else
		$g_iAutoOptimize = 0
	EndIf

	; Read behavior checkboxes
	$g_iForceBehave = (GUICtrlRead($g_hOCheckForceBehave) = $GUI_CHECKED) ? 1 : 0
	$g_iStartWithWindows = (GUICtrlRead($g_hOCheckStartWindows) = $GUI_CHECKED) ? 1 : 0

	Local $iPrevOnTop = $g_iAlwaysOnTop
	$g_iAlwaysOnTop = (GUICtrlRead($g_hOCheckOnTop) = $GUI_CHECKED) ? 1 : 0

	; Apply always on top setting immediately
	If $iPrevOnTop <> $g_iAlwaysOnTop Then
		WinSetOnTop($g_hCoreGui, "", $g_iAlwaysOnTop)
	EndIf

	; Read notification and sound settings
	$g_iShowNotifications = (GUICtrlRead($g_hOCheckNotify) = $GUI_CHECKED) ? 1 : 0
	$g_iPlaySounds = (GUICtrlRead($g_hOCheckPlayEvents) = $GUI_CHECKED) ? 1 : 0
	$g_iPlayWarnings = (GUICtrlRead($g_hOCheckPlayWarnings) = $GUI_CHECKED) ? 1 : 0
	$g_iWarnEvery = Int(GUICtrlRead($g_hOComboWarnEvery))
	$g_iWarnIfLoad = Int(GUICtrlRead($g_hOComboWarnIf))

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

	; Save new optimization and behavior settings
	IniWrite($g_sPathIni, $g_sProgShortName, "AutoOptimize", $g_iAutoOptimize)
	IniWrite($g_sPathIni, $g_sProgShortName, "AutoOptimizeSeconds", $g_iAutoOptimizeSeconds)
	IniWrite($g_sPathIni, $g_sProgShortName, "ForceBehave", $g_iForceBehave)
	IniWrite($g_sPathIni, $g_sProgShortName, "StartWithWindows", $g_iStartWithWindows)
	IniWrite($g_sPathIni, $g_sProgShortName, "AlwaysOnTop", $g_iAlwaysOnTop)
	IniWrite($g_sPathIni, $g_sProgShortName, "ShowNotifications", $g_iShowNotifications)
	IniWrite($g_sPathIni, $g_sProgShortName, "PlaySounds", $g_iPlaySounds)
	IniWrite($g_sPathIni, $g_sProgShortName, "PlayWarnings", $g_iPlayWarnings)
	IniWrite($g_sPathIni, $g_sProgShortName, "WarnEvery", $g_iWarnEvery)
	IniWrite($g_sPathIni, $g_sProgShortName, "WarnIfLoad", $g_iWarnIfLoad)

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
