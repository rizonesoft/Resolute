#Region AutoIt3Wrapper directives section
;** This is a list of compiler directives used by AutoIt3Wrapper.exe.
;** comment the lines you don't need or else it will override the default settings
;===============================================================================================================
#Autoit3Wrapper_Testing=                        ;(Y/N) Skip Tidy, Au3Stripper and cvsWrapper for speed while testing. Default=N
#AutoIt3Wrapper_ShowProgress=                   ;(Y/N) Show ProgressWindow during Compile. Default=Y
#AutoIt3Wrapper_ShowGui=                        ;(Y/N) Show GUI when F7-Compiling like Ctrl+F7. Default=N
;===============================================================================================================
;** AutoIt3 settings
#AutoIt3Wrapper_UseX64=                         ;(Y/N) Use AutoIt3_x64 or Aut2Exe_x64. Default=N
#AutoIt3Wrapper_Version=                        ;(B/P) Use Beta or Production for AutoIt3 and Aut2Eex. Default is P
#AutoIt3Wrapper_Run_Debug_Mode=                 ;(Y/N) Run Script with console debugging. Default=N
#AutoIt3Wrapper_Run_Debug=                      ;(On/Off) Switch debugging on/off
#AutoIt3Wrapper_Run_SciTE_Minimized=            ;(Y/N) Minimize SciTE while script is running. Default=N
#AutoIt3Wrapper_Run_SciTE_OutputPane_Minimized= ;(Y/N) Minimize SciTE output pane at run time. Default=N
#AutoIt3Wrapper_Autoit3Dir=                     ;Optionally override the AutoIt3 install directory to use.
#AutoIt3Wrapper_Aut2exe=						;Optionally override the Aut2exe.exe to use for this script
#AutoIt3Wrapper_AutoIt3=                        ;Optionally override the Autoit3.exe to use for this script
;===============================================================================================================
;** Aut2Exe settings
#AutoIt3Wrapper_Icon=                           ;Filename of the Ico file to use for the compiled exe
#AutoIt3Wrapper_OutFile=                        ;Target exe/a3x filename.
#AutoIt3Wrapper_OutFile_Type=                   ;exe=Standalone executable (Default); a3x=Tokenised AutoIt3 code file
#AutoIt3Wrapper_OutFile_X64=                    ;Target exe filename for X64 compile.
#AutoIt3Wrapper_Compression=                    ;Compression parameter 0-4  0=Low 2=normal 4=High. Default=2
#AutoIt3Wrapper_UseUpx=                         ;(Y/N) Compress output program.  Default=Y
#AutoIt3Wrapper_UPX_Parameters=                 ;Override the default settings for UPX.
#AutoIt3Wrapper_Change2CUI=                     ;(Y/N) Change output program to CUI in stead of GUI. Default=N
#AutoIt3Wrapper_Compile_both=                   ;(Y/N) Compile both X86 and X64 in one run. Default=N
;===============================================================================================================
;** Target program Resource info
#AutoIt3Wrapper_Res_Comment=                    ;Comment field
#AutoIt3Wrapper_Res_CompanyName=                ;Company field
#AutoIt3Wrapper_Res_Description=                ;Description field
#AutoIt3Wrapper_Res_Fileversion=                ;File Version
#AutoIt3Wrapper_Res_Fileversion_Use_Template=   ;Use a template to generate the fileversion based on date info: %YYYY/%YY/%MO/%DD/%HH/%MI/%SE
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=  ;(Y/N/P) AutoIncrement FileVersion. Default=N
#AutoIt3Wrapper_Res_Fileversion_First_Increment=;(Y/N) AutoIncrement Y=Before; N=After compile. Default=N
#AutoIt3Wrapper_Res_HiDpi=                      ;(Y/N) Compile for high DPI. Default=N
#AutoIt3Wrapper_Res_ProductName=				;Product Name
#AutoIt3Wrapper_Res_ProductVersion=				;Product Version
#AutoIt3Wrapper_Res_Language=                   ;Resource Language code . Default 2057=English (United Kingdom)
#AutoIt3Wrapper_Res_LegalCopyright=             ;Copyright field
#AutoIt3Wrapper_Res_LegalTrademarks=            ;Trademark field
#AutoIt3Wrapper_res_requestedExecutionLevel=    ;asInvoker, highestAvailable, requireAdministrator or None (remove the trsutInfo section).  Default is the setting from Aut2Exe (asInvoker)
#AutoIt3Wrapper_res_Compatibility=              ;Vista/Windows7/win7/win8/win81/win10 allowed separated by a comma     (Default=Win10)
#AutoIt3Wrapper_Res_SaveSource=                 ;(Y/N) Save a copy of the Script_source in the EXE resources. Default=N
; If _Res_SaveSource=Y the content of Script_source depends on the _Run_Au3Stripper and #Au3Stripper_parameters directives:
;	 If _Run_Au3Stripper=Y then
;        If #Au3Stripper_parameters=/STRIPONLY then Script_source is stripped script & stripped includes
;        If #Au3Stripper_parameters=/STRIPONLYINCLUDES then Script_source is original script & stripped includes
;	    With any other parameters, the SaveSource directive is ignored as obfuscation is intended to protect the source
; 	 If _Run_Au3Stripper=N or is not set then
;    	Scriptsource is original script only
; AutoIt3Wrapper indicates the SaveSource action taken in the SciTE console during compilation
; See SciTE4AutoIt3 Helpfile for more detail on Au3Stripper parameters
;
;
; free form resource fields ... max 15
;     you can use the following variables:
;     %AutoItVer% which will be replaced with the version of AutoIt3
;     %date% = PC date in short date format
;     %longdate% = PC date in long date format
;     %time% = PC timeformat
;  eg: #AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Res_Field=                      ;Free format fieldname|fieldvalue
;
; Add extra ICO files to the resources which can be used with TraySetIcon(@ScriptFullPath, 5) etc
#AutoIt3Wrapper_Res_Icon_Add=                   ; Filename[,ResNumber[,LanguageCode]] of ICO to be added.
; Add extra ICO files to the resources
; Use full path of the ico files to be added
; ResNumber is a numeric value used to access the icon: TraySetIcon(@ScriptFullPath, ResNumber)
; If no ResNumber is specified, the added icons are numbered from 201 up
;
; Add extra CUR files to the resources which can be used with _WinAPI_LoadCursor($hInstance, 5) etc
#AutoIt3Wrapper_Res_Cursors_Add=                   ; Filename[,ResNumber[,LanguageCode]] of CUR to be added.
; Add extra CUR files to the resources
; ResNumber is a numeric value used to access the Cursor: _WinAPI_LoadCursor($hInstance, ResNumber)
; If no ResNumber is specified, the added cursors are numbered from 101 up
;
#AutoIt3Wrapper_Res_File_Add=                   ; Filename[,Section [,ResName[,LanguageCode]]] to be added.
; Add files to the resources - can be compressed
;
#AutoIt3Wrapper_Res_Remove=                     ; ResType, ResName [, LanguageCode]
; Remove resources
;===============================================================================================================
; Tidy Settings
#AutoIt3Wrapper_Run_Tidy=                       ;(Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=              ;(Y/N) Continue when only Warnings. Default=Y
#Tidy_Parameters=                               ;Tidy Parameters...see SciTE4AutoIt3 Helpfile for options
#Tidy_ILC_Pos=                                  ;Align the inline comments on this position going forward.
;===============================================================================================================
; Au3Stripper Settings
#AutoIt3Wrapper_Run_Au3Stripper=                 ;(Y/N) Run Au3Stripper before compilation. default=N
#Au3Stripper_Parameters=                         ; Au3Stripper parameters...see SciTE4AutoIt3 Helpfile for options
#AutoIt3Wrapper_Au3stripper_OnError=             ;(C/S/ForceUse) Continue/Stop on Errors/Continue using stripped source in Exe (Default=C)
;===============================================================================================================
; AU3Check settings
#AutoIt3Wrapper_Run_Au3Check=                   ;(Y/N) Run au3check before compilation. Default=Y
#AutoIt3Wrapper_Au3Check_Parameters=            ;Au3Check parameters...see SciTE4AutoIt3 Helpfile for options
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=        ;(Y/N) Continue/Stop on Warnings.(Default=N)
;===============================================================================================================
; Versioning settings
#AutoIt3Wrapper_Versioning= 	                ;(Y/N/V) Run Versioning to update the script source. default=N
;                                                 V=only run when fileversion is increased by #AutoIt3Wrapper_Res_FileVersion_AutoIncrement.
#AutoIt3Wrapper_Versioning_Parameters=          ; /NoPrompt  : Will skip the Comments prompt
;                                                 /Comments  : Text to added in the Comments. It can also contain the below variables.
;===============================================================================================================
; RUN BEFORE AND AFTER definitions
; The following directives can contain: these variables
; 	%in% , %out%, %outx64%, %icon% which will be replaced by the fullpath\filename.
; 	%scriptdir% same as @ScriptDir and %scriptfile% = filename without extension.
; 	%fileversion% is the information from the #AutoIt3Wrapper_Res_Fileversion directive
;   %scitedir% will be replaced by the SciTE program directory
;   %autoitdir% will be replaced by the AutoIt3 program directory
#AutoIt3Wrapper_Run_Stop_OnError=               ;(Y/N) Stop when Returncode <> 0
#AutoIt3Wrapper_Run_Before_Admin=               ;(Y/N) Run subsequent Run_Before statements with #RequireAdmin. Default=N
#AutoIt3Wrapper_Run_After_Admin=                ;(Y/N) Run subsequent Run_After statements with #RequireAdmin. Default=N
#AutoIt3Wrapper_Run_Before=                     ;process to run before compilation - multiple records will be processed in sequence
#AutoIt3Wrapper_Run_After=                      ;process to run after compilation - multiple records will be processed in sequence
;===============================================================================================================
; Add Constants
#AutoIt3Wrapper_Add_Constants=                  ;Add the needed standard constant include files. Will only run one time.
;===============================================================================================================
; Optional
; Use this format to have separate directive values for Run and Compile
#AutoIt3Wrapper_If_Run
    #AutoIt3Wrapper_Run_Au3Check=Y
    #AutoIt3Wrapper_Run_Tidy=Y
    [...]
#Autoit3Wrapper_If_Compile
    #AutoIt3Wrapper_Run_Au3Check=N
    #AutoIt3Wrapper_Run_Tidy=N
    [...]
#AutoIt3Wrapper_EndIf
#EndRegion