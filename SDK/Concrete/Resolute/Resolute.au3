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
#AutoIt3Wrapper_Icon=..\..\Resources\Icons\Resolute.ico			;~ Filename of the Ico file to use for the compiled exe
#AutoIt3Wrapper_OutFile_Type=exe								;~ exe=Standalone executable (Default); a3x=Tokenised AutoIt3 code file
#AutoIt3Wrapper_OutFile=..\..\..\Resolute.exe					;~ Target exe/a3x filename.
#AutoIt3Wrapper_OutFile_X64=..\..\..\Resolute_X64.exe			;~ Target exe filename for X64 compile.
;#AutoIt3Wrapper_Compression=4									;~ Compression parameter 0-4  0=Low 2=normal 4=High. Default=2
;#AutoIt3Wrapper_UseUpx=Y										;~ (Y/N) Compress output program.  Default=Y
;#AutoIt3Wrapper_UPX_Parameters=								;~ Override the default settings for UPX.
#AutoIt3Wrapper_Change2CUI=N									;~ (Y/N) Change output program to CUI in stead of GUI. Default=N
#AutoIt3Wrapper_Compile_both=Y									;~ (Y/N) Compile both X86 and X64 in one run. Default=N
;===============================================================================================================
; Target Program Resource info
;===============================================================================================================
#AutoIt3Wrapper_Res_Comment=Resolute Power Tools				;~ Comment field
#AutoIt3Wrapper_Res_Description=Resolute Power Tools		    ;~ Description field
#AutoIt3Wrapper_Res_Fileversion=23.2.0.857
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
#AutoIt3Wrapper_Res_Field=ProductName|Resolute
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
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\ResoluteH.ico					; 201

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
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\ComIntRep.ico				; 281
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\DVDRepair.ico				; 282
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\USBRepair.ico				; 283
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\BiosCodes.ico				; 284
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\PixRepair.ico				; 285
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Ownership.ico				; 286
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\DeviceMan.ico				; 287
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Eventvwr.ico				; 288
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\ControlPanel.ico			; 289
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\WindowsDefender.ico		; 290
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\BackupRestore.ico			; 291
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\TaskManager.ico			; 292
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Focus.ico					; 293
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Autorun.ico				; 294
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Windows.ico				; 295
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\AutorunPlus.ico			; 296
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\AutorunMinus.ico			; 297
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Minimize.ico				; 298
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Accessibility.ico			; 299
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Magnifier.ico				; 300
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\OnScreenKeyboard.ico		; 301
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Narrator.ico				; 302
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Contrast.ico				; 303
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Command.ico				; 304
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Notepad3.ico				; 305
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Calculator.ico				; 306
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\System.ico					; 307
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\SystemProperties.ico		; 308

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\ComputerName.ico			; 309
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Hardware.ico				; 310
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Properties.ico				; 311
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\SystemRestore.ico			; 312
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Menus\Remote.ico					; 313

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\Go.ico						; 314
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\GoH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\Memory.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\MemoryH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\Drive.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\DriveH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\Caps.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\CapsD.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\Num.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\NumD.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\Scrl.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\ScrlD.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\32bit.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\32bitH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\64bit.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\64bitH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\USBD.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\USB.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\USBH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\Bin.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\BinH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\BinFull.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\BinFullH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\Computer.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\ComputerH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\Repair.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\Accessories.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Start\System.ico

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\SysProperties.ico			; 342
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\SysPropertiesH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\TaskManager.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\TaskManagerH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\MSConfig.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\MSConfigH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\MSInfo.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\MSInfoH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\DiskCleanup.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\DiskCleanupH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Defrag.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\DefragH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Performance.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\PerformanceH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Tasks.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\TasksH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\ControlPanel.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\ControlPanelH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Command.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\CommandH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\RegEdit.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\RegEditH.ico

#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\ComIntRep.ico				; 364
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\ComIntRepH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Firemin.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\FireminH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BiosCodes.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BiosCodesH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\PixRepair.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\PixRepairH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\DVDRepair.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\DVDRepairH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\USBRepair.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\USBRepairH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Ownership.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\OwnershipH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Rescue.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\RescueH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Notepad3.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Notepad3H.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\CarbonCD.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\CarbonCDH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Blank.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\BlankH.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\Calculator.ico
#AutoIt3Wrapper_Res_Icon_Add=..\..\Resources\Icons\Tools\CalculatorH.ico

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
#include "..\..\Includes\WinVerEx.au3"

#include "Includes\Localization.au3"

;~ Developer Constants
Global Const $DEBUG_UPDATE		= False

;~ Constants
Global Const $CNT_MENUICONS		= 999
Global Const $CNT_LOGICONS		= 7
Global Const $CNT_LANGICONS		= 35
Global Const $STATE_INACTIVE 	= 0
Global Const $STATE_ACTIVE 		= 1

;~ General Settings
Global $g_sCompanyName			= "Rizonesoft"
Global $g_sProgShortName		= "Resolute"
Global $g_sProgShortName_X64	= $g_sProgShortName & "_X64"
Global $g_sProgName				= "Resolute"
Global $g_iSingleton			= True
Global $g_IsWin10_2004_OrAbove  = False

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
Global $g_sRootDir			= @ScriptDir & "\Resolute"
Global $g_sBinDir			= $g_sRootDir & "\Bin"
Global $g_sBin86Dir			= $g_sBinDir & "\x86"
Global $g_sBin64Dir			= $g_sBinDir & "\x64"
Global $g_sPathIni			= $g_sRootDir & "\" & $g_sProgShortName & ".ini" 					;~ Full Path to the Configuaration file
Global $g_sAppDataRoot		= @AppDataDir & "\" & $g_sCompanyName & "\" & $g_sProgShortName
Global $g_sResourcesDir		= _PathFull(@ScriptDir & "\..\..\Resources")
Global $g_sProcessDir		= $g_sRootDir &	"\Processing"										;~ Processing Directory
Global $g_sDocsDir			= $g_sRootDir & "\Documents\" & $g_sProgShortName 					;~ Documentation Directory
Global $g_sCommandDir		= $g_sRootDir &	"\Command\"
Global $g_sDocHelpFile		= $g_sDocsDir & "\" & $g_sProgShortName & ".chm"
Global $g_sDocChanges		= $g_sDocsDir & "\Changes.txt"
Global $g_sDocLicense		= $g_sDocsDir & "\License.txt"
Global $g_sDocReadme		= $g_sDocsDir & "\Readme.txt"

If Not @Compiled Then
	$g_sProcessDir = _PathFull(@ScriptDir & "\..\..\..\Resolute\Processing")
EndIf

;~ General Settings
Global $g_iHideOnMinimize   = True

;~ Logging Settings
Global $g_sLoggingRoot		= $g_sRootDir & "\Logging\" & $g_sProgShortName
Global $g_sLoggingPath		= $g_sLoggingRoot & "\" & $g_sProgShortName & ".log"
Global $g_GuiLogBoxHeight	= 120
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
Global $g_iStartIconStart				= 314
Global $g_iArchIconStart				= $g_iStartIconStart + 12
Global $g_iToolsIconStart				= 342
Global $g_iPowerToolsIconStart			= 364

Global $g_aCoreIcons[3]
Global $g_iGuiIconSize					= 128
Global $g_iGuiAniSize					= 64
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
Global $g_iCoreGuiWidth		= 690
Global $g_iCoreGuiHeight	= 590
Global $g_iMsgBoxTimeOut	= 60

;~ About Dialog
Global $g_sAboutCredits		= "Derick Payne (Rizonesoft), Brian J Christy (Beege), " & _
							"G Sandler (MrCreatoR), Holger Kotsch, KaFu, LarsJ, nickston, ProgAndy, Yashied"
Global $g_sProgramTitle = _GUIGetTitle($g_sProgName)	;~ Get Program Ttile, including version.
Global $g_hCoreGui										;~ Main GUI
Global $g_hGuiIcon										;~ Main Icon
Global $g_hAniUpdate
Global $g_hAniUpdate16
Global $g_hAniProcessing
Global $g_hAniProcess16
Global $g_hMenuFile
Global $g_hMenuAccessories
Global $g_hMenuAdmin
Global $g_hMenuMaintenance
Global $g_hMenuOptimize
Global $g_hMenuRepair
Global $g_hMenuHardware
Global $g_hMenuSecurity, $g_hMiSecAutorun
Global $g_hMenuSystem
Global $g_hMenuDevelopment
Global $g_hMenuHelp
Global $g_hMenuDebug
Global $g_hUpdateMenuItem
Global $g_hSubHeading
Global $g_hTrayMinimize
Global $g_hTrayClose

Global $g_OldSystemParam								;~ Used when resizing the main GUI
Global $g_hSubHeading
Global $g_hBtnRepair

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
Global $g_sResolutePath			= @ScriptDir & "\Resolute\"

Const $SC_MOVE = 0xF010
Const $SC_SIZE = 0xF000

Global $i_DRAGFULLWINDOWS_Current
Global $i_DRAGFULLWINDOWS_Initial = _SPI_GETDRAGFULLWINDOWS()

Global Const $CNT_SYSTEMTOOLS	= 11
Global Const $CNT_POWERTOOLS	= 22
Global Const $TOOLICON_SIZE 	= 48
Global Const $TOOLGAP_STTOP		= 215
Global Const $TOOLGAP_PTTOP		= 305
Global Const $TOOLGAP_PTLEFT    = 15
Global Const $TOOLGAP_BETWEEN	= 10

Global $g_hStatus
Global $g_aStartIcons[3]
Global $g_hGroupSystemTools
Global $g_hSystemIcon[$CNT_SYSTEMTOOLS][3]
Global $g_hPowerIcon[$CNT_POWERTOOLS][3]
Global $g_aSystemTooltips[$CNT_SYSTEMTOOLS] = [	"System (About)", "Task Manager", "System Configuration (MSConfig)", "Computer Information (MSInfo)",  _
												"Disk Cleanup", "Optimize Drives", "Resource Monitor", "Task Manager", "Control Panel", "Command Prompt", "Registry Editor"]
Global $g_aSysIconContext[$CNT_SYSTEMTOOLS]
Global $g_aPowerTooltips[$CNT_POWERTOOLS] 	= [	"Complete Internet Repair", "Firemin", "BIOS Beep Codes Viewer", _
												"Frozen Pixel Repair", "DVD Repair", "USB Repair", "Install Take Ownership Shell Extension", "Rescue Antivirus", _
												"Notepad3", "Carbon CD", "Coming Soon!", "Coming Soon!", "Coming Soon!", "Coming Soon!", "Coming Soon!", _
												"Coming Soon!", "Coming Soon!", "Calculator"]
Global $g_IsCursorOverTool = False
Global $g_hUsageProg[6]
Global $g_hUsageLabel[4]
Global $g_aUsageBuffers[4]
Global $g_hStartButton, $g_hStartMenu
Global $g_hStartTime, $g_iTimeBuffer
Global $g_hStartDate, $g_iDateBuffer
Global $g_hDateTimeBack, $g_IsDateTimeHover
Global $g_hToolDescription
Global $g_hArchIcon, $g_iArchIcon, $g_iArchIconBuffer = $STATE_ACTIVE
Global $g_hCapsIcon, $g_hNumIcon, $g_hScrlIcon
Global $g_KeysBuffer[3] = [-1, -1, -1]
Global $g_iAutorunProtection

_Localization_Messages()   		;~ Load Message Language Strings
$g_sSplashAniPath		= $g_sProcessDir & "\32\Stroke.ani"
$g_iSplashDelay			= 100
_Splash_Start($g_aLangMessages[7])

If _Singleton($g_sProgramTitle, 1) = 0 And $g_iSingleton = True Then
	MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, $g_aLangMessages[3], $g_aLangMessages[4], $g_iMsgBoxTimeOut)
	Local $currPID = @AutoItPID
	ProcessClose($currPID)
EndIf

; Check if the OS is unsupported
If _IsUnsupportedOS() Then
	_ExecuteOrExit($g_aLangMessages[3], StringFormat($g_aLangMessages[5], _Link_Split($g_sUrlSupport, 2)), $g_sUrlSupport)
Else
	; Check if the script is running in a 64-bit environment
	If Not @AutoItX64 And @OSArch = "X64" Then
		Local $s64BitExePath = @ScriptDir & "\" & $g_sProgShortName_X64 & ".exe"

		; Execute the 64-bit version if it exists
		If FileExists($s64BitExePath) Then
			_ShellExecuteCheck($s64BitExePath)
		Else
			_ExecuteOrExit($g_aLangMessages[3], StringFormat($g_aLangMessages[6], _Link_Split($g_sUrlDownloads, 2)), $g_sUrlDownloads)
		EndIf
	Else
		; Initialize the program
		_InitializeProgram()
	EndIf
EndIf


; Function to handle the repetitive pattern of execute or exit
Func _ExecuteOrExit($sTitle, $sMessage, $sUrl)
	Local $iMsgBoxResult = MsgBox($MB_YESNO + $MB_ICONERROR + $MB_TOPMOST, $sTitle, $sMessage, $g_iMsgBoxTimeOut)
	Switch $iMsgBoxResult
		Case $IDYES
			_ShellExecuteCheck(_Link_Split($sUrl))
		Case -1, $IDNO
	EndSwitch
	Exit
EndFunc


; Function to handle ShellExecute and check for errors
Func _ShellExecuteCheck($sFile)
	Local $iSuccess = ShellExecute($sFile)
	If @error Then
		; Handle the error (logging, message box, etc.)
	EndIf
	Return $iSuccess
EndFunc


; Function to Initialize the program
Func _InitializeProgram()

	OnAutoItExitRegister("_TerminateProgram")
	$g_IsWin10_2004_OrAbove = _IsWindows10_2004_OrAbove()
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

EndFunc


Func _SetHotKeys()
	HotKeySet("{ESC}", "_MinimizeProgram")
EndFunc


Func _StartCoreGui()

	Local $miFileOptions, $mnuFileLog, $miLogOpenFile, $miLogOpenRoot, $miFileReboot, $miFileMinimize, $miFileClose
	Local $miHelpHome, $miHelpDownloads, $miHelpSupport, $miHelpGitHub, $miHelpDonate, $miHelpAbout, $hHeading
	Local $miNetScan, $micStatus
	Local $menuAccAccess, $miAccAccOptions, $miAccMagnifier, $miAccOnScreenKey, $miAccNarrator, $miAccHighContrast
	Local $miAccCommand, $miAccTerminal, $miAccNotepad3, $miAccCalculator
	Local $menuAccessibility, $miAdmControlPanelG, $miAdmEventViewer
	Local $miMntBackupRestore
	Local $miRepComIntRep, $miRepDVDRepair, $miRepUSBRepair
	Local $smRepHardware, $miHardBiosCodes, $miHardPixelRep
	Local $miSecWinSec
	Local $miSystem, $miSystemProperties, $miTaskManger, $miSysWinVersion

	Local $hBtnScanSysFiles, $hBtnDISM

	$g_hCoreGui = GUICreate($g_sProgramTitle, $g_iCoreGuiWidth, $g_iCoreGuiHeight, -1, -1, $WS_OVERLAPPEDWINDOW, $WS_EX_COMPOSITED)
	If Not @Compiled Then GUISetIcon($g_aCoreIcons[0])
	GUISetFont(Default, Default, Default, "Verdana", $g_hCoreGui, $CLEARTYPE_QUALITY)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_ShutdownProgram", $g_hCoreGui)

	GUIRegisterMsg($WM_GETMINMAXINFO, "WM_GETMINMAXINFO")
	GUIRegisterMsg($WM_EXITSIZEMOVE, "WM_EXITSIZEMOVE")
	GUIRegisterMsg($WM_SYSCOMMAND, "WM_SYSCOMMAND")

	GUICtrlCreateLabel("", -50, 0, 800, 1)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKWIDTH, $GUI_DOCKSIZE))
	GUICtrlSetBkColor(-1, 0xd9d9d9)

	$g_hStartButton = GUICtrlCreateIcon(@ScriptFullPath, $g_iStartIconStart, 0, 1, 48, 48)
	GUICtrlSetCursor($g_hStartButton, 0)
	$g_aStartIcons[2] = $STATE_ACTIVE
	GUICtrlSetOnEvent($g_hStartButton, "_StartMenu")

	GUICtrlCreateLabel("", 49, 0, 1, 50)
	GUICtrlSetBkColor(-1, 0xd9d9d9)

	GUICtrlCreateIcon(@ScriptFullPath, $g_iStartIconStart + 2, 80, 8, 16, 16)
	$g_hUsageProg[1] = GuiCtrlCreateLabel("", 106, 9, 10, 8)
	GUICtrlSetBkColor(-1, 0x68CEFA)
	$g_hUsageProg[0] = GuiCtrlCreateLabel("", 105, 8, 100, 10)
	GUICtrlSetBkColor(-1, 0x071320)
	$g_hUsageLabel[0] = GuiCtrlCreateLabel("100%", 210, 6, 50, 11)
	GuiCtrlSetFont($g_hUsageLabel[0], 7)
	$g_hUsageProg[3] = GuiCtrlCreateLabel("", 106, 21, 50, 8)
	GUICtrlSetBkColor(-1, 0xFABA00)
	$g_hUsageProg[2] = GuiCtrlCreateLabel("", 105, 20, 100, 10)
	GUICtrlSetBkColor(-1, 0x071320)
	$g_hUsageLabel[1] = GuiCtrlCreateLabel("100%", 210, 19, 50, 11)
	GuiCtrlSetFont($g_hUsageLabel[1], 7)

	GUICtrlCreateIcon(@ScriptFullPath, $g_iStartIconStart + 4, 260, 8, 16, 16)
	$g_hUsageProg[5] = GuiCtrlCreateLabel("", 286, 9, 50, 8)
	GUICtrlSetBkColor(-1, 0x7CCC7C)
	$g_hUsageProg[4] = GuiCtrlCreateLabel("", 285, 8, 100, 10)
	GUICtrlSetBkColor(-1, 0x071320)
	$g_hUsageLabel[2] = GuiCtrlCreateLabel("(C)", 390, 6, 150, 11)
	GuiCtrlSetFont($g_hUsageLabel[2], 8)

	$g_hCapsIcon = GUICtrlCreateIcon(@ScriptFullPath, $g_iStartIconStart + 7, 390, 30, 16, 16)
	GUICtrlSetResizing($g_hCapsIcon, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	$g_hNumIcon = GUICtrlCreateIcon(@ScriptFullPath, $g_iStartIconStart + 9, 410, 30, 16, 16)
	GUICtrlSetResizing($g_hNumIcon, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	$g_hScrlIcon = GUICtrlCreateIcon(@ScriptFullPath, $g_iStartIconStart + 11, 430, 30, 16, 16)
	GUICtrlSetResizing($g_hScrlIcon, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlCreateLabel("", 450, 30, 1, 16)
	GUICtrlSetBkColor(-1, 0xd9d9d9)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlCreateIcon(@ScriptFullPath, $g_iStartIconStart + 19, 455, 30, 16, 16)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlCreateIcon(@ScriptFullPath, $g_iStartIconStart + 23, 475, 30, 16, 16)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))

	If _IsScriptOnRemovableDrive() Then
		GUICtrlCreateIcon(@ScriptFullPath, $g_iStartIconStart + 17, 495, 30, 16, 16)
	Else
		GUICtrlCreateIcon(@ScriptFullPath, $g_iStartIconStart + 16, 495, 30, 16, 16)
	EndIf
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))

	GUICtrlCreateLabel("", 515, 30, 1, 16)
	GUICtrlSetBkColor(-1, 0xd9d9d9)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))

	If @OSArch == "X64" Then
		$g_iArchIcon = 2
	EndIf
	$g_hArchIcon = GUICtrlCreateIcon(@ScriptFullPath, $g_iArchIconStart + $g_iArchIcon, 520, 30, 16, 16)
	GUICtrlSetResizing($g_hArchIcon, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlSetCursor($g_hArchIcon, 0)

	$g_hAniProcess16 = GUICtrlCreateIcon($g_sProcessDir & "\16\Process.ani", 0, 520, 5, 16, 16)
	GUICtrlSetState($g_hAniProcess16, $GUI_HIDE)

	GUICtrlCreateLabel("", 540, 0, 1, 50)
	GUICtrlSetBkColor(-1, 0xd9d9d9)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))

	$g_IsDateTimeHover = $STATE_ACTIVE
	$g_hStartTime = GUICtrlCreateLabel("8:50 PM", 580, 12, 100, 16, $SS_RIGHT)
	GUICtrlSetResizing($g_hStartTime, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GuiCtrlSetFont($g_hStartTime, 8)
	$g_hStartDate = GUICtrlCreateLabel("10/13/2023", 560, 28, 120, 16, $SS_RIGHT)
	GUICtrlSetResizing($g_hStartDate, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GuiCtrlSetFont($g_hStartDate, 8)
	$g_hDateTimeBack = GUICtrlCreateLabel("", 541, 1, 200, 48)
	GUICtrlSetResizing($g_hDateTimeBack, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))

	GUICtrlCreateLabel("", -50, 50, 800, 1) ;~ Bottom Bar
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKWIDTH, $GUI_DOCKSIZE))
	GUICtrlSetBkColor(-1, 0xd9d9d9)

	; Create context menu
	$g_hStartMenu = GUICtrlCreateContextMenu($g_hStartButton)
	_GuiCtrlMenuEx_SetMenuIconBkColor(0xF0F0F0)
	_GuiCtrlMenuEx_SetMenuIconBkGrdColor(0xFFFFFF)

	$g_hMenuFile = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[0], $g_hStartMenu)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hStartMenu)
	$g_hMenuAccessories = _GuiCtrlMenuEx_CreateMenu("Accessories", $g_hStartMenu, @ScriptFullPath, $g_iStartIconStart + 26)
	$g_hMenuAdmin = _GuiCtrlMenuEx_CreateMenu("Administration", $g_hStartMenu)
	$g_hMenuMaintenance = _GuiCtrlMenuEx_CreateMenu("Maintenance", $g_hStartMenu)
	$g_hMenuHardware = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[18], $g_hStartMenu)
	$g_hMenuOptimize = _GuiCtrlMenuEx_CreateMenu("Optimize", $g_hStartMenu)
	$g_hMenuRepair = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[17], $g_hStartMenu, @ScriptFullPath, $g_iStartIconStart + 25)
	$g_hMenuSecurity = _GuiCtrlMenuEx_CreateMenu("Security", $g_hStartMenu)
	$g_hMenuSystem = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[19], $g_hStartMenu, @ScriptFullPath, $g_iStartIconStart + 27)
	$g_hMenuDevelopment = _GuiCtrlMenuEx_CreateMenu("Development", $g_hStartMenu)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hStartMenu)
	$g_hMenuHelp = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[6], $g_hStartMenu)

	$miFileOptions = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[1], $g_hMenuFile, $g_aMenuIcons[0], $g_iMenuIconsStart)
	$mnuFileLog = _GuiCtrlMenuEx_CreateMenu($g_aLangMenus[2], $g_hMenuFile)
	$miLogOpenFile = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[3], $mnuFileLog, $g_aMenuIcons[1], $g_iMenuIconsStart + 1)
	$miLogOpenRoot = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[4], $mnuFileLog)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuFile)
	$miFileMinimize = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[21], $g_hMenuFile, $g_aMenuIcons[25], $g_iMenuIconsStart + 25)
	$miFileClose = _GuiCtrlMenuEx_CreateMenuItem($g_aLangMenus[5], $g_hMenuFile, $g_aMenuIcons[2], $g_iMenuIconsStart + 2)

	GUICtrlSetOnEvent($miFileOptions, "_ShowPreferencesDlg")
	GUICtrlSetOnEvent($miLogOpenFile, "_Logging_OpenFile")
	GUICtrlSetOnEvent($miLogOpenRoot, "_Logging_OpenDirectory")
	GUICtrlSetOnEvent($miFileClose, "_ShutdownProgram")

	$menuAccAccess = _GuiCtrlMenuEx_CreateMenu("&Accessibility", $g_hMenuAccessories, $g_aMenuIcons[26], $g_iMenuIconsStart + 26)
	$miAccAccOptions = _GuiCtrlMenuEx_CreateMenuItem("&Accessibility Options", $menuAccAccess, $g_aMenuIcons[26], $g_iMenuIconsStart + 26)
	_GuiCtrlMenuEx_CreateMenuItem("", $menuAccAccess)
	$miAccMagnifier = _GuiCtrlMenuEx_CreateMenuItem("&Magnifier", $menuAccAccess, $g_aMenuIcons[27], $g_iMenuIconsStart + 27)
	$miAccOnScreenKey = _GuiCtrlMenuEx_CreateMenuItem("&On-Screen &Keyboard", $menuAccAccess, $g_aMenuIcons[28], $g_iMenuIconsStart + 28)
	$miAccNarrator = _GuiCtrlMenuEx_CreateMenuItem("Start &Narrator", $menuAccAccess, $g_aMenuIcons[29], $g_iMenuIconsStart + 29)
	$miAccHighContrast = _GuiCtrlMenuEx_CreateMenuItem("High &Contrast Settings", $menuAccAccess, $g_aMenuIcons[30], $g_iMenuIconsStart + 30)
	$miAccCalculator = _GuiCtrlMenuEx_CreateMenuItem("&Calculator", $g_hMenuAccessories, $g_aMenuIcons[33], $g_iMenuIconsStart + 33)
	$miAccNotepad3 = _GuiCtrlMenuEx_CreateMenuItem("&Notepad3" & @TAB & _GetBinToolVersionNumber("Notepad3", "Notepad3.exe"), $g_hMenuAccessories, $g_aMenuIcons[32], $g_iMenuIconsStart + 32)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuAccessories)
	$miAccCommand = _GuiCtrlMenuEx_CreateMenuItem("Command &Prompt", $g_hMenuAccessories, $g_aMenuIcons[31], $g_iMenuIconsStart + 31)
	If $g_IsWin10_2004_OrAbove Then
		$miAccTerminal = _GuiCtrlMenuEx_CreateMenuItem("Windows &Terminal" & @TAB & _GetBinToolVersionNumber("Terminal", "wt.exe"), $g_hMenuAccessories, $g_aMenuIcons[31], $g_iMenuIconsStart + 31)
		GUICtrlSetOnEvent($miAccTerminal, "_OpenWindowsTerminal")
	EndIf

	GUICtrlSetOnEvent($miAccAccOptions, "_OpenAccessibilityOptions")
	GUICtrlSetOnEvent($miAccMagnifier, "_StartMagnifier")
	GUICtrlSetOnEvent($miAccOnScreenKey, "_StartOnScreenKeyboard")
	GUICtrlSetOnEvent($miAccNarrator, "_StartNarrator")
	GUICtrlSetOnEvent($miAccHighContrast, "_OpenHighContrastSettings")
	GUICtrlSetOnEvent($miAccNotepad3, "_OpenNotepad3")
	GUICtrlSetOnEvent($miAccCommand, "_OpenCommandPrompt")

	$miAdmControlPanelG = _GuiCtrlMenuEx_CreateMenuItem("Control Panel (all tasks)", $g_hMenuAdmin, $g_aMenuIcons[16], $g_iMenuIconsStart + 16)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuAdmin)
	$miAdmEventViewer = _GuiCtrlMenuEx_CreateMenuItem("Event Viewer", $g_hMenuAdmin, $g_aMenuIcons[15], $g_iMenuIconsStart + 15)

	GUICtrlSetOnEvent($miAdmControlPanelG, "_OpenControlPanelG")
	GUICtrlSetOnEvent($miAdmEventViewer, "_OpenEventViewer")

	$miMntBackupRestore = _GuiCtrlMenuEx_CreateMenuItem("Backup and Restore (Windows)", $g_hMenuMaintenance, $g_aMenuIcons[18], $g_iMenuIconsStart + 18)

	GUICtrlSetOnEvent($miMntBackupRestore, "_OpenBackupRestore")

	$miRepComIntRep = _GuiCtrlMenuEx_CreateMenuItem("Complete Internet Repair", $g_hMenuRepair, $g_aMenuIcons[8], $g_iMenuIconsStart + 8)
	$miHardBiosCodes = _GuiCtrlMenuEx_CreateMenuItem("BIOS Beep Codes Viewer", $g_hMenuRepair, $g_aMenuIcons[11], $g_iMenuIconsStart + 11)
	$miHardPixelRep = _GuiCtrlMenuEx_CreateMenuItem("Frozen Pixel Repair", $g_hMenuRepair, $g_aMenuIcons[12], $g_iMenuIconsStart + 12)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuRepair)
	$miRepDVDRepair = _GuiCtrlMenuEx_CreateMenuItem("DVD Drive Repair", $g_hMenuRepair, $g_aMenuIcons[9], $g_iMenuIconsStart + 9)
	$miRepUSBRepair = _GuiCtrlMenuEx_CreateMenuItem("USB Repair", $g_hMenuRepair, $g_aMenuIcons[10], $g_iMenuIconsStart + 10)

	GUICtrlSetOnEvent($miHardBiosCodes, "_StartBiosCodes")
	GUICtrlSetOnEvent($miHardPixelRep, "_StartPixelRepair")
	GUICtrlSetOnEvent($miRepComIntRep, "_StartComIntRep")
	GUICtrlSetOnEvent($miRepDVDRepair, "_StartDVDRepair")
	GUICtrlSetOnEvent($miRepUSBRepair, "_StartUSBRepair")

	$miSecWinSec = _GuiCtrlMenuEx_CreateMenuItem("Windows Security", $g_hMenuSecurity, $g_aMenuIcons[17], $g_iMenuIconsStart + 17)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuSecurity)
	$g_hMiSecAutorun = _GuiCtrlMenuEx_CreateMenuItem(_GetAutorunProtectionStatus(), $g_hMenuSecurity, $g_aMenuIcons[23], $g_iMenuIconsStart + 23)

	GUICtrlSetOnEvent($miSecWinSec, "_OpenActionCenter")
	GUICtrlSetOnEvent($g_hMiSecAutorun, "_AutorunProtection")

	$miSystem = _GuiCtrlMenuEx_CreateMenuItem("System (About)", $g_hMenuSystem, $g_aMenuIcons[34], $g_iMenuIconsStart + 34)
	$miSystemProperties = _GuiCtrlMenuEx_CreateMenuItem("System Properties", $g_hMenuSystem, $g_aMenuIcons[35], $g_iMenuIconsStart + 35)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuSystem)
	$miTaskManger = _GuiCtrlMenuEx_CreateMenuItem("Windows Task Manager", $g_hMenuSystem, $g_aMenuIcons[19], $g_iMenuIconsStart + 19)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_hMenuSystem)
	$miSysWinVersion = _GuiCtrlMenuEx_CreateMenuItem("About Windows", $g_hMenuSystem, $g_aMenuIcons[22], $g_iMenuIconsStart + 22)

	GUICtrlSetOnEvent($miSystem, "_CLSID_SystemAbout")
	GUICtrlSetOnEvent($miSystemProperties, "_CMD_SystemProperties")
	GUICtrlSetOnEvent($miTaskManger, "_CMD_TaskManager")
	GUICtrlSetOnEvent($miSysWinVersion, "_OpenWindowsVersion")

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

	GUICtrlSetOnEvent($g_hUpdateMenuItem, "_CheckForUpdates")
	GUICtrlSetOnEvent($miHelpHome, "_About_HomePage")
	GUICtrlSetOnEvent($miHelpDownloads, "_About_Downloads")
	GUICtrlSetOnEvent($miHelpSupport, "_About_Support")
	GUICtrlSetOnEvent($miHelpGitHub, "_About_GitHubIssues")
	GUICtrlSetOnEvent($miHelpDonate, "_About_PayPal")
	GUICtrlSetOnEvent($miHelpAbout, "_About_ShowDialog")

	$g_hGuiIcon = GUICtrlCreateIcon($g_aCoreIcons[0], 99, 10, 60, $g_iGuiIconSize, $g_iGuiIconSize)
	GUICtrlSetTip($g_hGuiIcon, 	"Version " & _GetProgramVersion(0) & @CRLF & _
								"Build with AutoIt version " & @AutoItVersion & @CRLF & _
								"Copyright © " & @YEAR & " " & $g_sCompanyName, _
								"About " & $g_sProgName, $TIP_INFOICON, $TIP_BALLOON)
	GUICtrlSetCursor($g_hGuiIcon, 0)
	GUICtrlSetOnEvent($g_hGuiIcon, "_About_ShowDialog")

	$g_hAniUpdate = GUICtrlCreateIcon($g_sUpdateAnimation, 0, 10, 60, $g_iGuiAniSize, $g_iGuiAniSize)
	$g_hAniProcessing = GUICtrlCreateIcon($g_sProcessingAnimation, 0, 10, 60, $g_iGuiAniSize, $g_iGuiAniSize)
	GUICtrlSetState($g_hAniUpdate, $GUI_HIDE)
	GUICtrlSetState($g_hAniProcessing, $GUI_HIDE)
	$hHeading = GUICtrlCreateLabel($g_sProgName & " " & _GetProgramVersion(1), $g_iGuiIconSize + 22, 65, 300, 23)
	GUICtrlSetFont($hHeading, 12)
	GUICtrlCreateCheckBox(Chr(0x61), $g_iGuiIconSize + 322, 65, 25, 25, $BS_PUSHLIKE)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlSetFont(-1, 12, 400, 0, "Webdings")
	$g_hSubHeading = GUICtrlCreateLabel($g_aLangCustom[0], $g_iGuiIconSize + 22, 88, 300, 35)
	GUICtrlSetFont($g_hSubHeading, 10)
	GUICtrlSetColor($g_hSubHeading, 0x353535)

	$g_hToolDescription = GUICtrlCreateLabel("", $g_iGuiIconSize + 22, $g_iGuiIconSize + 50, 300, 35, $SS_RIGHT)
	GUICtrlSetResizing($g_hToolDescription, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlSetFont($g_hToolDescription, 9)
	GUICtrlSetColor($g_hToolDescription, 0x353535)

	GUICtrlCreateGroup("System Repair", 480, 60, 200, 150)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	$hBtnScanSysFiles = GUICtrlCreateButton("Scan System Files", 490, 80, 180, 33)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlCreateButton("Check Health (Dism)", 490, 123, 180, 33)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	$hBtnDISM = GUICtrlCreateButton("Restore Health", 490, 156, 180, 33)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Create System Tools group
	$g_hGroupSystemTools = GUICtrlCreateGroup("System Tools", 10, $g_iCoreGuiHeight - 380, $g_iCoreGuiWidth - 20, 85)
	GUICtrlSetFont(-1, 10, 700)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKHEIGHT))

	; Create system tool icons
	For $s = 0 To $CNT_SYSTEMTOOLS - 1
		; Calculate icon position
		Local $iconLeft = $TOOLGAP_PTLEFT + $TOOLGAP_BETWEEN + ($s * $TOOLICON_SIZE) + ($s * $TOOLGAP_BETWEEN) + 1
		Local $iconTop = $TOOLGAP_STTOP + $TOOLGAP_BETWEEN * 2 + 2
		; Create icon
		$g_hSystemIcon[$s][0] = GUICtrlCreateIcon(@ScriptFullPath, $g_iToolsIconStart + $s * 2, $iconLeft, $iconTop, $TOOLICON_SIZE, $TOOLICON_SIZE, $SS_NOTIFY)
		GUICtrlSetResizing($g_hSystemIcon[$s][0], BitOR($GUI_DOCKLEFT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
		GuiCtrlSetCursor($g_hSystemIcon[$s][0], 0)
		GUICtrlSetOnEvent($g_hSystemIcon[$s][0], "_StartLaunchPadTools")
		$g_hSystemIcon[$s][1] = $STATE_ACTIVE
		$g_hSystemIcon[$s][2] = "Coming Soon!"
	Next
	GUICtrlSetTip($g_hSystemIcon[9][0],  "Command Prompt")
	GUICtrlSetTip($g_hSystemIcon[10][0], "Registry Editor")
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	Local $cmiSystem, $cmiSystemProperties
	Local $cmiSysPropName, $cmiSysPropHardware, $cmiSysPropAdvanced, $cmiSysPropProtection, $cmiSysPropRemote

	$g_aSysIconContext[0] = GUICtrlCreateContextMenu($g_hSystemIcon[0][0])
	$cmiSystem = _GuiCtrlMenuEx_CreateMenuItem("System (&About)", $g_aSysIconContext[0], $g_aMenuIcons[34], $g_iMenuIconsStart + 34)
	_GuiCtrlMenuEx_CreateMenuItem("", $g_aSysIconContext[0])
;~ 	$cmiSystemProperties = _GuiCtrlMenuEx_CreateMenuItem("&System Properties", $g_aSysIconContext[0], $g_aMenuIcons[35], $g_iMenuIconsStart + 35)
	$cmiSysPropName = _GuiCtrlMenuEx_CreateMenuItem("Change Computer &Name", $g_aSysIconContext[0], $g_aMenuIcons[36], $g_iMenuIconsStart + 36)
	$cmiSysPropHardware = _GuiCtrlMenuEx_CreateMenuItem("Manage &Hardware", $g_aSysIconContext[0], $g_aMenuIcons[37], $g_iMenuIconsStart + 37)
	$cmiSysPropAdvanced = _GuiCtrlMenuEx_CreateMenuItem("&Advanced Settings", $g_aSysIconContext[0], $g_aMenuIcons[38], $g_iMenuIconsStart + 38)
	$cmiSysPropProtection = _GuiCtrlMenuEx_CreateMenuItem("Configure System &Protection", $g_aSysIconContext[0], $g_aMenuIcons[39], $g_iMenuIconsStart + 39)
	$cmiSysPropRemote = _GuiCtrlMenuEx_CreateMenuItem("&Remote Options", $g_aSysIconContext[0], $g_aMenuIcons[40], $g_iMenuIconsStart + 40)

	GUICtrlSetOnEvent($cmiSystem, "_CLSID_SystemAbout")
	GUICtrlSetOnEvent($cmiSystemProperties, "_CMD_SystemProperties")
	GUICtrlSetOnEvent($cmiSysPropName, "_CMD_SystemPropName")
	GUICtrlSetOnEvent($cmiSysPropHardware , "_CMD_SystemPropHardware")
	GUICtrlSetOnEvent($cmiSysPropAdvanced, "_CMD_SystemPropAdvanced")
	GUICtrlSetOnEvent($cmiSysPropProtection, "_CMD_SystemPropProtection")
	GUICtrlSetOnEvent($cmiSysPropRemote, "_CMD_SystemPropRemote")

	GUICtrlCreateGroup("Power Tools", 10, $g_iCoreGuiHeight - $g_GuiLogBoxHeight * 2 - 49, $g_iCoreGuiWidth - 20, 140)
	GUICtrlSetFont(-1, 10, 700)
	GUICtrlSetResizing(-1, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKTOP, $GUI_DOCKHEIGHT))

	For $a = 0 To $CNT_POWERTOOLS - 1
		If $a < $CNT_POWERTOOLS / 2 Then
			$g_hPowerIcon[$a][0] = GUICtrlCreateIcon(@ScriptFullPath, $g_iPowerToolsIconStart + $a * 2, $TOOLGAP_PTLEFT + $TOOLGAP_BETWEEN + ($a * $TOOLICON_SIZE) + ($a * $TOOLGAP_BETWEEN) + 1, _
												$TOOLGAP_PTTOP + 2 * $TOOLGAP_BETWEEN + 2, $TOOLICON_SIZE, $TOOLICON_SIZE, $SS_NOTIFY)
		Else
			Local $b = $a - Round($CNT_POWERTOOLS / 2)
			$g_hPowerIcon[$a][0] = GUICtrlCreateIcon(@ScriptFullPath, $g_iPowerToolsIconStart + $a * 2, $TOOLGAP_PTLEFT + $TOOLGAP_BETWEEN + ($b * $TOOLICON_SIZE) + ($b * $TOOLGAP_BETWEEN) + 1, _
												$TOOLGAP_PTTOP + 3 * $TOOLGAP_BETWEEN + $TOOLICON_SIZE + 2, $TOOLICON_SIZE, $TOOLICON_SIZE, $SS_NOTIFY)
		EndIf
		GUICtrlSetResizing($g_hPowerIcon[$a][0], BitOR($GUI_DOCKLEFT, $GUI_DOCKTOP, $GUI_DOCKSIZE))
		GuiCtrlSetCursor($g_hPowerIcon[$a][0], 0)
		GUICtrlSetOnEvent($g_hPowerIcon[$a][0], "_StartLaunchPadTools")
		$g_hPowerIcon[$a][1] = $STATE_ACTIVE
	Next
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$g_hListStatus = GUICtrlCreateListView("", 10, $g_iCoreGuiHeight - $g_GuiLogBoxHeight - 15, _
			$g_iCoreGuiWidth - 20, $g_GuiLogBoxHeight, BitOR($LVS_REPORT, $LVS_NOCOLUMNHEADER))
	_GUICtrlListView_SetExtendedListViewStyle($g_hListStatus, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_DOUBLEBUFFER, _
			$LVS_EX_SUBITEMIMAGES, $LVS_EX_INFOTIP, $WS_EX_CLIENTEDGE))
	_GUICtrlListView_AddColumn($g_hListStatus, "", 680)
	_WinAPI_SetWindowTheme(GUICtrlGetHandle($g_hListStatus), "Explorer")
	GUICtrlSetResizing($g_hListStatus, BitOR($GUI_DOCKLEFT, $GUI_DOCKRIGHT, $GUI_DOCKBOTTOM, $GUI_DOCKTOP))
	GUICtrlSetFont($g_hListStatus, 9, -1, -1, "Courier New")
	GUICtrlSetColor($g_hListStatus, 0x333333)

	GUICtrlSetOnEvent($hBtnScanSysFiles, "_RunSystemFileScanner")
	GUICtrlSetOnEvent($hBtnDISM, "_RunDISM")

	$g_hImgStatus = _GUIImageList_Create(16, 16, 5, 1, 8, 8)
	For $iLx = 0 To $CNT_LOGICONS - 1
		_ImageListEx_AddBlankIcon($g_hImgStatus, $g_hListStatus, $g_aLognIcons[$iLx], $g_iLogIconStart - $iLx)
	Next
	_GUIImageList_Add($g_hImgStatus, _GUICtrlListView_CreateSolidBitMap($g_hListStatus, 0xFFFFFF, 16, 16))
	_GUICtrlListView_SetImageList($g_hListStatus, $g_hImgStatus, 1)

	$g_hTrayMinimize  = TrayCreateItem($g_aLangMenus[21])
	$g_hTrayClose  = TrayCreateItem($g_aLangMenus[5])

	TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "_MinimizeClicked")
	TrayItemSetOnEvent($g_hTrayMinimize, "_MinimizeClicked")
	TrayItemSetOnEvent($g_hTrayClose, "_ShutdownProgram")

	TraySetState($TRAY_ICONSTATE_SHOW)
	TraySetToolTip($g_sProgramTitle)
	TraySetClick($TRAY_CLICK_SECONDARYDOWN)

	_GetResourceUsage()
	_GetStartTime()
	_CheckSpecialKeys()
	_Splash_Update("", 100)

	GUISetState(@SW_SHOW, $g_hCoreGui)
	AdlibRegister("_OnIconsHover", 13)
	AdlibRegister("_GetStartTime", 1000)
	AdlibRegister("_CheckSpecialKeys", 10)

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


#Region "Tray Interface"

Func _MinimizeClicked()
	If $g_iHideOnMinimize = True Then
		_HideShowMainForm()
	Else
		If TrayItemGetText($g_hTrayMinimize) = $g_aLangMenus[21] Then
			TrayItemSetText($g_hTrayMinimize, $g_aLangMenus[22])
			GUISetState(@SW_MINIMIZE, $g_hCoreGui)
		Else
			TrayItemSetText($g_hTrayMinimize, $g_aLangMenus[21])
			GUISetState(@SW_RESTORE, $g_hCoreGui)
		EndIf
	EndIf
EndFunc

Func _HideShowMainForm()
	If TrayItemGetText($g_hTrayMinimize) = $g_aLangMenus[21] Then
		GUISetState(@SW_HIDE, $g_hCoreGui)
		TrayItemSetText($g_hTrayMinimize, $g_aLangMenus[22])
		TrayTip(StringFormat($g_aLangCustom[2], $g_sProgName), StringFormat($g_aLangCustom[3], $g_sProgName, $g_aLangMenus[22]), 15, $TIP_ICONASTERISK)
	Else
		GUISetState(@SW_SHOW, $g_hCoreGui)
		GUISetState(@SW_RESTORE, $g_hCoreGui)
		TrayItemSetText($g_hTrayMinimize, $g_aLangMenus[21])
	EndIf
EndFunc

#EndRegion "Tray Interface"


Func _StartLaunchPadTools()
	Switch @GUI_CtrlId
		Case  $g_hSystemIcon[0][0]
			_CLSID_SystemAbout()
		Case  $g_hSystemIcon[1][0]
			_CMD_TaskManager()
		Case  $g_hSystemIcon[2][0]
			_CMD_SystemConfig()
		Case  $g_hSystemIcon[3][0]
			_CMD_SystemInfo()
		Case  $g_hSystemIcon[4][0]
			_CMD_DiskCleaner()
		Case  $g_hSystemIcon[5][0]
			_CMD_DiskDefrag()
		Case  $g_hSystemIcon[6][0]
			_CMD_PerformanceMonitor()
		Case  $g_hSystemIcon[7][0]
			_CMD_TaskScheduler()
		Case  $g_hSystemIcon[8][0]
			 _OpenControlPanelG()
		Case  $g_hSystemIcon[9][0]
			_OpenWindowsTerminal()
		Case $g_hSystemIcon[10][0]
			_CMD_Regedit()
		Case $g_hPowerIcon[0][0]
			_StartComIntRep()
		Case $g_hPowerIcon[1][0]
		Case $g_hPowerIcon[2][0]
			_StartBiosCodes()
		Case $g_hPowerIcon[3][0]
			_StartPixelRepair()
		Case $g_hPowerIcon[4][0]
			_StartDVDRepair()
		Case $g_hPowerIcon[5][0]
			_StartUSBRepair()
		Case $g_hPowerIcon[6][0]
			_RTOOL_Ownership()
		Case $g_hPowerIcon[7][0]
			_RTOOL_Rescue()
		Case $g_hPowerIcon[8][0]
			_OpenNotepad3()
		Case $g_hPowerIcon[9][0]
	EndSwitch
EndFunc


#Region "System Tools"

Func _CLSID_SystemAbout()
	_ShellExecuteEx("shell:::{BB06C0E4-D293-4f75-8A90-CB05B6477EEE}", "System (About)")
EndFunc

Func _CMD_SystemProperties()
	_ShellExecuteEx("sysdm.cpl", "System Properties")
EndFunc

Func _CMD_SystemPropName()
	_ShellExecuteEx("SystemPropertiesComputerName", "System Properties (Computer Name)")
EndFunc

Func _CMD_SystemPropHardware()
	_ShellExecuteEx("SystemPropertiesHardware", "System Properties (Hardware)")
EndFunc

Func _CMD_SystemPropAdvanced()
	_ShellExecuteEx("SystemPropertiesAdvanced", "System Properties (Advanced)")
EndFunc

Func _CMD_SystemPropProtection()
	_ShellExecuteEx("SystemPropertiesProtection", "System Properties (System Protection)")
EndFunc

Func _CMD_SystemPropRemote()
	_ShellExecuteEx("SystemPropertiesRemote", "System Properties (Remote)")
EndFunc

Func _CMD_TaskManager()
	_ShellExecuteEx("taskmgr", "Task Manager")
EndFunc

Func _CMD_SystemConfig()
	_ShellExecuteEx("msconfig", "System Configuration")
EndFunc

Func _CMD_SystemInfo()
	_ShellExecuteEx("msinfo32", "System Information")
EndFunc

Func _CMD_DiskCleaner()
	_ShellExecuteEx("cleanmgr", "Disk Cleanup")
EndFunc

Func _CMD_DiskDefrag()
	_ShellExecuteEx("dfrgui", "Optimize Drives")
EndFunc

Func _CMD_PerformanceMonitor()
	_ShellExecuteEx("perfmon.msc", "Performance Monitor", "/s")
EndFunc

Func _CMD_TaskScheduler()
	_ShellExecuteEx("taskschd.msc", "Task Scheduler", "/s")
EndFunc

Func _CMD_Regedit()
	_ShellExecuteEx("regedit", "Registry Editor")
EndFunc

Func _RTOOL_Ownership()
	_ExecuteResoluteTool("Ownership", "Ownership")
EndFunc



Func _RTOOL_Rescue()
	_ExecuteResoluteTool("Rescue", "Rescue Antivirus")
EndFunc

#EndRegion





#Region "Menu Commands"

Func _StartMenu()
	; Get the cursor position
	Local $cursorPos = MouseGetPos()
	; Show the context menu at the cursor position
	DllCall("user32.dll", "int", "TrackPopupMenu", "hwnd", GUICtrlGetHandle($g_hStartMenu), "int", 0, "int", $cursorPos[0], "int", $cursorPos[1], "int", 0, "hwnd", $g_hCoreGui, "ptr", 0)
EndFunc

Func _OpenControlPanelG()
	_ShellExecuteEx("shell:::{ED7BA470-8E54-465E-825C-99712043E01C}", "Control Panel (all tasks)")
EndFunc

Func _OpenEventViewer()
	_ShellExecuteEx("eventvwr", "Event Viewer")
EndFunc

Func _OpenBackupRestore()
	_ShellExecuteEx("shell:::{B98A2BEA-7D42-4558-8BD1-832F41BAC6FD}", "Backup and Restore")
EndFunc

Func _OpenActionCenter()
	_ShellExecuteEx("shell:::{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}", "Security and Maintenance")
EndFunc

Func _StartComIntRep()
	_ExecuteResoluteTool("ComIntRep", "Complete Internet Repair")
EndFunc

Func _StartDVDRepair()
	_ExecuteResoluteTool("DVDRepair", "DVD Drive Repair")
EndFunc

Func _StartUSBRepair()
	_ExecuteResoluteTool("USBRepair", "USB Repair")
EndFunc

Func _StartBiosCodes()
	_ExecuteResoluteTool("BiosCodes", "BIOS Beep Codes Viewer")
EndFunc

Func _StartPixelRepair()
	_ExecuteResoluteTool("PixRepair", "Pixel Repair")
EndFunc

#EndRegion "Menu Commands"


#Region "Menu Commands - Accessories"

Func _OpenAccessibilityOptions()
	_ShellExecuteEx("shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A}", "Accessibility Options")
EndFunc

Func _StartMagnifier()
	_ShellExecuteEx("magnify", "Magnifier")
EndFunc

Func _StartOnScreenKeyboard()
	_ShellExecuteEx("osk", "On-Screen Keyboard")
EndFunc

Func _StartNarrator()
	_ShellExecuteEx("narrator", "Narrator")
EndFunc

Func _OpenHighContrastSettings()
	_ShellExecuteEx("shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A}\pageEasierToSee", "High Contrast Settings")
EndFunc

#Region "Command Prompt"

Func _CheckCommandPrompt()

	_Logging_Start("Checking and repairing the Command Prompt.")
	If FileExists(@SystemDir & "\cmd.exe") Then

		If RegRead("HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System", "DisableCMD") = 1 Or _
		   RegRead("HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System", "DisableCMD") = 2 Then
			_Logging_EditWrite("We detected that the Command Prompt on your computer is disabled.", 3)
			_Logging_EditWrite("Enabling the Command Prompt")
			_Registry_Write("HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System", "DisableCMD", "REG_DWORD", 0)
			If Not @error Then
				_Logging_FinalMessage("Command Prompt enabled successfully.")
				Return
			Else
				_Logging_FinalMessage("Unknown error: The Command Prompt could not be enabled.")
				Return
			EndIf
		Else
			_Logging_FinalMessage("No Command Prompt issues detected.")
		EndIf

	EndIf

EndFunc

Func _OpenCommandPrompt()
	_ShellExecuteEx("cmd.exe", "Command Prompt", "/k title Resolute Console && prompt $T $B $P$G && color B", $g_sCommandDir)
EndFunc

Func _OpenWindowsTerminal()
	_ExecuteBinTool("Terminal", "wt.exe", "Windows Terminal", $g_sCommandDir)
EndFunc

#EndRegion "Command Prompt"

Func _OpenNotepad3()
	_ExecuteBinTool("Notepad3", "Notepad3.exe", "Rizonesoft Notepad3", $g_sRootDir)
EndFunc

#EndRegion "Menu Commands - Accessories"


#Region "Menu Commands - Security"


Func _CheckSpecialKeys()

	Local $capsState = _WinAPI_GetKeyState(0x14) ; Check Caps Lock state

	If $capsState <> $g_KeysBuffer[0] Then
		GUICtrlSetImage($g_hCapsIcon, @ScriptFullPath, $g_iStartIconStart + 7 - $capsState)
		$g_KeysBuffer[0] = $capsState
	EndIf

	Local $numState = _WinAPI_GetKeyState(0x90) ; Check Num Lock state
	If $numState <> $g_KeysBuffer[1] Then
		GUICtrlSetImage($g_hNumIcon, @ScriptFullPath, $g_iStartIconStart + 9 - $numState)
		$g_KeysBuffer[1] = $numState
	EndIf

	Local $scrollState = _WinAPI_GetKeyState(0x91) ; Check Scroll Lock state
	If $scrollState <> $g_KeysBuffer[2] Then
		GUICtrlSetImage($g_hScrlIcon, @ScriptFullPath, $g_iStartIconStart + 11 - $scrollState)
		$g_KeysBuffer[2] = $scrollState
	EndIf

EndFunc


Func _GetStartTime()
    ; Get the current local system time
    Local $SYSTEMTIME = _Date_Time_GetLocalTime()
    Local $currentTime = _Date_Time_SystemTimeToDateTimeStr($SYSTEMTIME)
    Local $hour24 = Number(StringMid($currentTime, 12, 2))
    Local $minutes = Number(StringMid($currentTime, 15, 2))

    If $minutes <> $g_iTimeBuffer Then
        ; Determine AM or PM
        Local $ampm = "AM"
        Local $hour12 = $hour24
        If $hour24 >= 12 Then
            $ampm = "PM"
            If $hour24 > 12 Then $hour12 = $hour24 - 12
        EndIf

        ; Handle the midnight case: 12:00 AM
        If $hour24 == 0 Then
            $hour12 = 12
        EndIf

        ; Pad minutes and set the Start time
        GUICtrlSetData($g_hStartTime, StringFormat("%d:%02d %s", $hour12, $minutes, $ampm))
        $g_iTimeBuffer = $minutes
        _GetStartDate()
    EndIf

EndFunc


Func _GetStartDate()

    ; Get the current local system time
    Local $SYSTEM_TIME = _Date_Time_GetLocalTime()
    Local $currentDate = _Date_Time_SystemTimeToDateTimeStr($SYSTEM_TIME)
    Local $day = StringMid($currentDate, 9, 2)

    If $day <> $g_iDateBuffer Then
        ; Extract the date in YYYY/MM/DD format and set the Start date
        Local $formattedDate = StringMid($currentDate, 1, 10)
        GUICtrlSetData($g_hStartDate, $formattedDate)
        $g_iDateBuffer = $day
		_SetDateTimeTooltip()
    EndIf

EndFunc


Func _SetDateTimeTooltip()
    Local $dayOfWeek = _DateDayOfWeek(@WDAY)
    Local $monthName = _DateToMonth(@MON) ; 1 = Full name
    Local $tooltipString = StringFormat("%s, %d %s, %d", $dayOfWeek, @MDAY, $monthName, @YEAR)

    ; Set the tooltip for the Start date and time controls
    GUICtrlSetTip($g_hDateTimeBack, $tooltipString)
EndFunc


Func _GetResourceUsage()

	Local $aRAMStats = MemGetStats()
	Local $iRAMPerc = Round($aRAMStats[$MEM_LOAD])
	Local $iPagePerc = Round(($aRAMStats[$MEM_AVAILPAGEFILE] / $aRAMStats[$MEM_TOTALPAGEFILE]) * 100)

	If IsArray($aRAMStats) Then
		If $iRAMPerc <> $g_aUsageBuffers[0] Then
			_ProgressBar_SetData($g_hCoreGui, $g_hUsageProg[1], $g_hUsageProg[1], 105, 8, 98, $iRAMPerc)
			GUICtrlSetData($g_hUsageLabel[0], StringFormat("%d%", $iRAMPerc))
			$g_aUsageBuffers[0] = $iRAMPerc
		EndIf

		If $iPagePerc <> $g_aUsageBuffers[1] Then
			_ProgressBar_SetData($g_hCoreGui, $g_hUsageProg[3], $g_hUsageProg[3], 105, 20, 98, $iPagePerc)
			GUICtrlSetData($g_hUsageLabel[1], StringFormat("%d%", $iPagePerc))
			$g_aUsageBuffers[1] = $iPagePerc
		EndIf

	EndIf

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	_PathSplit(@ScriptDir, $sDrive, $sDir, $sFileName, $sExtension)
	Local $iSpaceUsed = DriveSpaceTotal($sDrive) - DriveSpaceFree($sDrive)
	Local $iSpacePerc = Round(($iSpaceUsed / DriveSpaceTotal($sDrive)) * 100)

	If $iSpacePerc <> $g_aUsageBuffers[2] Then

		If $iSpacePerc > 90 Then
			_ProgressBar_ThemeModern_SetColors($g_hUsageProg[5], "Red")
		Else
			_ProgressBar_ThemeModern_SetColors($g_hUsageProg[5], "Green")
		EndIf

		_ProgressBar_SetData($g_hCoreGui, $g_hUsageProg[5], $g_hUsageProg[5], 285, 8, 98, $iSpacePerc)
		GUICtrlSetData($g_hUsageLabel[2], StringFormat("(%s) %d (%d GB)", StringTrimRight($sDrive, 1), Round($iSpaceUsed / 1024), Round(DriveSpaceTotal($sDrive) / 1024)))
		$g_aUsageBuffers[2] = $iSpacePerc

	EndIf

EndFunc


Func _IsScriptOnRemovableDrive()
    Local $sScriptPath = @ScriptDir ; This gives you the directory where the script is located.
    Local $sDriveLetter = StringLeft($sScriptPath, 1) & ":" ; Extract the drive letter from the path.

    ; Now use DriveGetType() to find out what type of drive this is.
    Local $sDriveType = DriveGetType($sDriveLetter)

    If $sDriveType = "REMOVABLE" Then
        Return True
    Else
        Return False
    EndIf
EndFunc


#EndRegion "Menu Commands - Security"

Func _GetAutorunProtectionStatus()

	If RegRead("HKLM\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume") = "1" Or _
		RegRead("HKCU\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume") = "1" Or _
		RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun") = "4" Or _
		RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers", "DisableAutoplay") = "1" Or _
		RegRead("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun") = "4" Or _
		RegRead("HKLM\Software\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf", "") = "@SYS:DoesNotExist" Then
		$g_iAutorunProtection = True
		_GuiCtrlMenuEx_SetMenuItemIcon($g_hMiSecAutorun, $g_aMenuIcons[24], $g_iMenuIconsStart + 24)
		Return "Remove &Autorun Protection"
	Else
		$g_iAutorunProtection = False
		_GuiCtrlMenuEx_SetMenuItemIcon($g_hMiSecAutorun, $g_aMenuIcons[23], $g_iMenuIconsStart + 23)
		Return "Protect against &Autorun parasites"
	EndIf

EndFunc

Func _AutorunProtection()

	_Logging_Start("Setting Autorun protection")
	If Not $g_iAutorunProtection Then
		_Registry_Write("HKLM\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume", "REG_DWORD", 1)
		_Registry_Write("HKCU\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume", "REG_DWORD", 1)
		_Registry_Write("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun", "REG_DWORD", 4)
		_Registry_Write("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun", "REG_DWORD", 4)
		_Registry_Write("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf", "", "REG_SZ", "@SYS:DoesNotExist")
		_Registry_Write("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers", "DisableAutoplay", "REG_DWORD", 1)
	Else
		_Registry_Delete("HKLM\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume")
		_Registry_Delete("HKCU\Software\Policies\Microsoft\Windows\Explorer", "NoAutoplayfornonVolume")
		_Registry_Delete("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf", "")
		_Registry_Delete("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun")
		_Registry_Delete("HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer", "NoDriveTypeAutoRun")
		_Registry_Write("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers", "DisableAutoplay", "REG_DWORD", 0)
	EndIf
	_Logging_FinalMessage("Autorun protection enabled successfully.")
	_GuiCtrlMenuEx_SetMenuItemText($g_hMiSecAutorun, _GetAutorunProtectionStatus())

EndFunc

#Region "Menu Commands - System"

Func _OpenWindowsVersion()
	__WinAPI_AboutDlg(	"About Windows", "Windows Version Information", _
						"System Type:" & @TAB & _ReturnWindowsArchName() & " operating system, " & @CPUArch & "-based processor", _
						_WinAPI_ShellExtractIcon(@ScriptFullPath, 0, 32, 32), $g_hCoreGui)

EndFunc

#EndRegion "Menu Commands - System"





#Region "Commands"

Func _RunSystemFileScanner()

	_Logging_Start("Scanning your system files")
	_Logging_EditWrite("^ This can take several minutes. Please do not close the command window!")
	ShellExecute("SFC", "/SCANNOW", "", "", @SW_SHOW)

EndFunc

Func _RunDISM()
	_Logging_Start("Repairing your system")
	_Logging_EditWrite("^ This process can take a little while, so make sure not to close the Command Prompt.")
	_Logging_EditWrite("^ It may look like it’s stuck, but this is normal behavior.")
	ShellExecute("DISM", "/online /cleanup-image /restorehealth", "", "", @SW_SHOW)
EndFunc

Func _ExecuteBinTool($sToolDir, $sExecutable, $sToolName, $sWorkingDir = "")

	Local $s64ExePath	= $g_sBin64Dir & "\" & $sToolDir & "\" & $sExecutable
	Local $s86ExePath	= $g_sBin86Dir & "\" & $sToolDir & "\" & $sExecutable

	If @OSArch = "X64" Then
		If FileExists($s64ExePath) Then
			_ShellExecuteTool($s64ExePath, $sToolName, $sWorkingDir)
			Return
		Else
			_ShellExecuteTool($s86ExePath, $sToolName, $sWorkingDir)
			Return
		EndIf
	Else
		_ShellExecuteTool($s86ExePath, $sToolName, $sWorkingDir)
	EndIf
EndFunc

Func _GetBinToolVersionNumber($sToolDir, $sExecutable, $sStringName = $FV_PRODUCTVERSION)

;~  $FV_COMMENTS ("Comments")
;~  $FV_COMPANYNAME ("CompanyName")
;~  $FV_FILEDESCRIPTION ("FileDescription")
;~  $FV_FILEVERSION ("FileVersion")
;~  $FV_INTERNALNAME ("InternalName")
;~  $FV_LEGALCOPYRIGHT ("LegalCopyright")
;~  $FV_LEGALTRADEMARKS ("LegalTrademarks")
;~  $FV_ORIGINALFILENAME ("OriginalFilename")
;~  $FV_PRODUCTNAME ("ProductName")
;~  $FV_PRODUCTVERSION ("ProductVersion")
;~  $FV_PRIVATEBUILD ("PrivateBuild")
;~  $FV_SPECIALBUILD ("SpecialBuild")

	Local $s64ExePath	= $g_sBin64Dir & "\" & $sToolDir & "\" & $sExecutable
	Local $s86ExePath	= $g_sBin86Dir & "\" & $sToolDir & "\" & $sExecutable
	If @OSArch = "X64" Then
		If FileExists($s64ExePath) Then
			Return FileGetVersion($s64ExePath)
		Else
			Return FileGetVersion($s86ExePath)
		EndIf
	Else
		Return FileGetVersion($s86ExePath)
	EndIf
EndFunc


Func _ExecuteResoluteTool($sExeName, $sProgramName = "Resolute Tool", $sPath = $g_sResolutePath)

	_Logging_Start(StringFormat($g_aLangMessages2[0], $sProgramName))
	Local $s64ExePath = $sPath & "\" & $sExeName & "_X64.exe"
	Local $s86ExePath = $sPath & "\" & $sExeName & ".exe"

	_Logging_EditWrite($g_aLangMessages2[1])
	_Logging_EditWrite(StringFormat($g_aLangMessages2[2], _ReturnWindowsArchName()))
	_Logging_EditWrite(StringFormat($g_aLangMessages2[3], $sProgramName))
	If @OSArch = "X64" Then
		If FileExists($s64ExePath) Then
			_ShellExecuteTool($s64ExePath, $sProgramName)
			Return
		Else
			_ShellExecuteTool($s86ExePath, $sProgramName)
			Return
		EndIf
	Else
		_ShellExecuteTool($s86ExePath, $sProgramName)
	EndIf

EndFunc

Func _ShellExecuteTool($exePath, $exeName, $sWorkingDir = "", $sParameters = "")

    If FileExists($exePath) Then
        _Logging_EditWrite(StringFormat($g_aLangMessages2[4], $exePath))
        Local $iPID = ShellExecute($exePath, $sParameters, $sWorkingDir)
        If @error Then
            _Logging_EditWrite(StringFormat($g_aLangMessages2[5], @error))
        Else
            _Logging_EditWrite(StringFormat($g_aLangMessages2[6], $exeName, $iPID))
			_Logging_FinalMessage($g_aLangMessages2[10])
        EndIf
    Else
        _Logging_EditWrite(StringFormat($g_aLangMessages2[7], $exePath))
		_Logging_EditWrite($g_aLangMessages2[8])
    EndIf

EndFunc


Func _ReturnWindowsArchName()
	If @OSArch = "X64" Then
		Return "64 bit"
	Else
		Return "32 bit"
	EndIf
EndFunc


Func _ShellExecuteEx($sCommand, $sName, $sParameters = "", $sWorkingDir = "")

	If $sWorkingDir = "" Then
		Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
		Local $aPathSplit = _PathSplit($sCommand, $sDrive, $sDir, $sFileName, $sExtension)
		$sWorkingDir = $sDrive & $sDir
	EndIf

	_Logging_Start(StringFormat($g_aLangMessages2[0], $sName))
	ShellExecute($sCommand, $sParameters, $sWorkingDir)
	If @error Then
		_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangMessages2[5], $sName), "ERROR"))
	EndIf
	_Logging_EditWrite(StringFormat($g_aLangMessages2[9], $sCommand))
	_Logging_FinalMessage($g_aLangMessages2[10])

EndFunc

#EndRegion "Commands"


#Region "Events"

Func _OnIconsHover()

	Local $iCursor = GUIGetCursorInfo()
	If Not @error Then

		If ($iCursor[4] = $g_hDateTimeBack Or $iCursor[4] = $g_hStartTime Or $iCursor[4] = $g_hStartDate) And $g_IsDateTimeHover == $STATE_ACTIVE Then
			; Change background color for parent control
			GUICtrlSetBkColor($g_hDateTimeBack, 0xFEFEFE)
			; Change background color for child controls
			GUICtrlSetBkColor($g_hStartTime, 0xFEFEFE)
			GUICtrlSetBkColor($g_hStartDate, 0xFEFEFE)

			$g_IsDateTimeHover = $STATE_INACTIVE
		ElseIf ($iCursor[4] <> $g_hDateTimeBack And $iCursor[4] <> $g_hStartTime And $iCursor[4] <> $g_hStartDate) And $g_IsDateTimeHover == $STATE_INACTIVE Then
			; Reset background color for parent control
			GUICtrlSetBkColor($g_hDateTimeBack, $GUI_BKCOLOR_TRANSPARENT)
			; Reset background color for child controls
			GUICtrlSetBkColor($g_hStartTime, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetBkColor($g_hStartDate, $GUI_BKCOLOR_TRANSPARENT)

			$g_IsDateTimeHover = $STATE_ACTIVE
		EndIf

		If $iCursor[4] = $g_hStartButton And $g_aStartIcons[2] == $STATE_ACTIVE Then
			$g_aStartIcons[2] = $STATE_INACTIVE
			GUICtrlSetImage($g_hStartButton, $g_aStartIcons[1], $g_iStartIconStart + 1)
		ElseIf $iCursor[4] <> $g_hStartButton And $g_aStartIcons[2] == $STATE_INACTIVE Then
			$g_aStartIcons[2] = $STATE_ACTIVE
			GUICtrlSetImage($g_hStartButton, $g_aStartIcons[0], $g_iStartIconStart)
		EndIf

		If $iCursor[4] = $g_hArchIcon And $g_iArchIconBuffer == $STATE_ACTIVE Then
			$g_iArchIconBuffer = $STATE_INACTIVE
			GUICtrlSetImage($g_hArchIcon, @ScriptFullPath, $g_iArchIconStart + $g_iArchIcon + 1)
		ElseIf $iCursor[4] <> $g_hArchIcon And $g_iArchIconBuffer == $STATE_INACTIVE Then
			$g_iArchIconBuffer = $STATE_ACTIVE
			GUICtrlSetImage($g_hArchIcon, @ScriptFullPath, $g_iArchIconStart + $g_iArchIcon)
		EndIf

		; Loop through all system tools
		For $toolIndex = 0 To $CNT_SYSTEMTOOLS - 1
			; Detect if the cursor is over the current tool's icon
			If $iCursor[4] = $g_hSystemIcon[$toolIndex][0] And $g_hSystemIcon[$toolIndex][1] == $STATE_ACTIVE Then
				; Set the icon to inactive state
				GUICtrlSetData($g_hToolDescription, $g_aSystemTooltips[$toolIndex])
				GUICtrlSetImage($g_hSystemIcon[$toolIndex][0], @ScriptFullPath, $g_iToolsIconStart + $toolIndex * 2 + 1)
				$g_hSystemIcon[$toolIndex][1] = $STATE_INACTIVE
			; Detect if the cursor is not over the current tool's icon and it is in an inactive state
			ElseIf $iCursor[4] <> $g_hSystemIcon[$toolIndex][0] And $g_hSystemIcon[$toolIndex][1] == $STATE_INACTIVE Then
				; Set the icon to active state
				GUICtrlSetImage($g_hSystemIcon[$toolIndex][0], @ScriptFullPath, $g_iToolsIconStart + $toolIndex * 2)
				GUICtrlSetData($g_hToolDescription, "")
				$g_hSystemIcon[$toolIndex][1] = $STATE_ACTIVE
			EndIf
		Next

		; Loop through all power tools
		For $toolIndex = 0 To $CNT_POWERTOOLS - 1
			; Detect if the cursor is over the current tool's icon
			If $iCursor[4] = $g_hPowerIcon[$toolIndex][0] And $g_hPowerIcon[$toolIndex][1] == $STATE_ACTIVE Then
				; Set the icon to inactive state
				GUICtrlSetData($g_hToolDescription, $g_aPowerTooltips[$toolIndex])
				GUICtrlSetImage($g_hPowerIcon[$toolIndex][0], @ScriptFullPath, $g_iPowerToolsIconStart + $toolIndex * 2 + 1)
				$g_hPowerIcon[$toolIndex][1]= $STATE_INACTIVE
			ElseIf $iCursor[4] <> $g_hPowerIcon[$toolIndex][0] And $g_hPowerIcon[$toolIndex][1] == $STATE_INACTIVE Then
				; Set the icon to active state
				GUICtrlSetImage($g_hPowerIcon[$toolIndex][0], @ScriptFullPath, $g_iPowerToolsIconStart + $toolIndex * 2)
				GUICtrlSetData($g_hToolDescription, "")
				$g_hPowerIcon[$toolIndex][1]= $STATE_ACTIVE
			EndIf
		Next


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
		$g_aStartIcons[0] 	= @ScriptFullPath
		$g_aStartIcons[1] 	= @ScriptFullPath
		$g_aDonateIcons[1] 	= @ScriptFullPath
		$g_aDonateIcons[0] 	= @ScriptFullPath
		$g_aDonateIcons[1] 	= @ScriptFullPath

		For $iSTi = 0 To $CNT_SYSTEMTOOLS - 1
		Next

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

		$g_aCoreIcons[0]   = $g_sResourcesDir & "\Icons\" & $g_sProgShortName & ".ico"
		$g_aCoreIcons[1]   = $g_sResourcesDir & "\Icons\" & $g_sProgShortName & "H.ico"
		$g_aDonateIcons[0] = $g_sResourcesDir & "\Icons\About\PayPal.ico"
		$g_aDonateIcons[1] = $g_sResourcesDir & "\Icons\About\PayPalH.ico"

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

	$g_sPathIni = $g_sRootDir & "\" & $g_sProgShortName & ".ini"
	$g_sLoggingRoot = $g_sRootDir & "\Logging\" & $g_sProgShortName
	$g_sLoggingPath = $g_sLoggingRoot & "\" & $g_sProgShortName & ".log"

EndFunc   ;==>_ResetWorkingDirectories


Func _SetAppDataDirectory()

	DirCreate($g_sAppDataRoot)

	$g_sRootDir = $g_sAppDataRoot

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
			GUICtrlSetState($g_hAniUpdate, $GUI_SHOW)
			GUICtrlSetState($g_hGuiIcon, $GUI_HIDE)
		EndIf
		_SetProcessingStates($GUI_DISABLE)
		GUICtrlSetData($g_hSubHeading, $g_aLangCustom[1])

	ElseIf $iState = 32 Then

		If FileExists($g_sUpdateAnimation) Then
			GUICtrlSetState($g_hAniUpdate, $GUI_HIDE)
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
	GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
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


; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_AboutDlg
; Description....: Displays a Windows About dialog box.
; Syntax.........: _WinAPI_AboutDlg ( $sTitle, $sName, $sText [, $hIcon [, $hParent]] )
; Parameters.....: $sTitle  - The title of the Windows About dialog box.
;                  $sName   - The first line after the text "Microsoft".
;                  $sText   - The text to be displayed in the dialog box after the version and copyright information.
;                  $hIcon   - Handle to the icon that the function displays in the dialog box.
;                  $hParent - Handle to a parent window.
; Return values..: Success  - 1.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........: @@MsdnLink@@ ShellAbout
; Example........: Yes
; ===============================================================================================================================
Func __WinAPI_AboutDlg($sTitle, $sName, $sText, $hIcon = 0, $hParent = 0)

	Local $Ret = DllCall('shell32.dll', 'int', 'ShellAboutW', 'hwnd', $hParent, 'wstr', $sTitle & '#' & $sName, 'wstr', $sText, 'ptr', $hIcon)

	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_WinAPI_AboutDlg
