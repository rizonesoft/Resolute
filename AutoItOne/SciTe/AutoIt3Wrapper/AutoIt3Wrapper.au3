#NoTrayIcon
Global Const $VERSION = "21.316.1639.1"
#cs
Description:	Compile,Run,Check,Tidy or Strip your AutoIt3 script including options to update the resource information.
	Credits:	wraithdu - Updating the Resource UDFs allowing other sections to be included.
				jchd - Added support for UTF files.
Copyright © 2021 Jos van der Zande
#ce
;~ #AutoIt3Wrapper_Res_Fileversion_Use_Template=   ;Use a template to generate the fileversion based on date info: %YYYY/%YY/%MO/%DD/%HH/%MI/%SE
;~ #AutoIt3Wrapper_Res_Fileversion_Use_Template=%YY.%MO%DD.%HH%MI.%SE
#AutoIt3Wrapper_Res_Fileversion=21.316.1639.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_Fileversion_First_Increment=y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#AutoIt3Wrapper_Run_After_Admin=y
#AutoIt3Wrapper_Run_After=for %I in ("%in%" "directives.au3") do copy %I "C:\Program Files (x86)\autoit3\SciTE\AutoIt3Wrapper"
#AutoIt3Wrapper_Versioning=v
#AutoIt3Wrapper_Versioning_Parameters=/Comments %fileversionnew%
#Tidy_ILC_Pos=70
#Au3Stripper_Parameters=/debug
#Region AutoIt General Settings & Includes
#include <Date.au3>
#include <File.au3>
#include <Misc.au3>
#include <GuiTab.au3>
#include <WinAPI.au3>
#include <WinAPIFiles.au3>
#include <Constants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <APIResConstants.au3>
#include <WinAPIProc.au3>
#include <Process.au3>
;
; get program version for display purpose
;~ $VERSION = StringLeft($VERSION, StringInStr($VERSION, ".", 0, -1) - 1)
OnAutoItExitRegister("OnAutoItExit")
#Region SciTE Director Init
; Try to update the file directly in SciTE in stead of externally by means of the Director interface.
Opt("WinSearchChildren", 1)
; Get My GUI Handle numeric
Global $My_Hwnd = GUICreate("SciTE interface", 300, 600, Default, Default, Default, $WS_EX_TOPMOST)
;~ Global $My_Dec_Hwnd = Dec(StringTrimLeft($My_Hwnd, 2))
Global $SciTE_Dir = _PathFull(@ScriptDir & "\..")
Global $FirstLineVisible, $LastCaretPos, $LastCaretLine
Global $RunBySciTE = "Unknown"
Global $RunByFull = "Unknown"
Global $RunBy = "Unknown"
RunBySciTE()

;
Global $Shell_RQA_Diff = 0                                           ; 0=run script on same level / 1= run Script on Admin and SciTE normal
Global $sMailSlotConsole = "\\.\mailslot\AutoIt3WrapperConsole"
Global $hMailSlot_Console
Global $RunAdminChkFile

Global $CurrentFile
Global $SciTECmd
Global $SciTE_hwnd = WinGetHandle("DirectorExtension")
If $RunBySciTE Then
	;Register COPYDATA message.
	GUIRegisterMsg($WM_COPYDATA, "MY_WM_COPYDATA")
	; test for correct SciTE instance
	; Retrieve a list of window handles.
	Global $aList = WinList("DirectorExtension")
	;
	; Default to the first found but Loop through all available instances of the SciTEDirector interface to select the correct one by comparing the Filename.
	For $i = 1 To $aList[0][0]
		$CurrentFile = StringReplace(SendSciTE_GetInfo($My_Hwnd, $aList[$i][1], "askfilename:"), "\\", "\")
		$CurrentFile = StringReplace($CurrentFile, "filename:", "")
		If StringInStr($cmdlineraw, $CurrentFile) Then
			; When the current filename is the same as the file being processed by AutoIt3wrapper. then select the handle
			$SciTE_hwnd = $aList[$i][1]
			ExitLoop
		EndIf
	Next
	;
	; Get SciTE program directory
	If Not FileExists($SciTE_Dir & "\SciTE.exe") Then
		$SciTE_Dir = StringReplace(SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:SciteDefaultHome"), "\\", "\")
		; When it still isn't found it is assumed that the path to the editor it one higher than the AutoIt3Wrapper script directory
		If Not FileExists($SciTE_Dir) Then
			$SciTE_Dir = _PathFull(@ScriptDir & "..\..")
		EndIf
	EndIf
Else

EndIf
#EndRegion SciTE Director Init
; Only show general info for the main script
If StringInStr($CMDLINERAW, "/runadmin") Then
	_MailSlotWrite($sMailSlotConsole, "#$#Started#$#" & @AutoItPID)  ;Tell Master script the eleveated run has started
	AutoItWinSetTitle("AutoIt3Wrapper_RunAdmin")
	__ConsoleWrite("-##>" & @HOUR & ":" & @MIN & ":" & @SEC & " Restarted AutoIt3Wrapper with #RequireAdmin. (pid=" & @AutoItPID & ")" & @CRLF)
ElseIf Not StringInStr($CMDLINERAW, "/watcher") _
		And Not StringInStr($CMDLINERAW, "/au3record") _
		And Not StringInStr($CMDLINERAW, "/au3info") _
		And Not StringInStr($CMDLINERAW, "/Jump2FirstError") _
		Then
	AutoItWinSetTitle("AutoIt3Wrapper_Main_" & @AutoItPID)
	__ConsoleWrite('+>' & @HOUR & ':' & @MIN & ':' & @SEC & ' Starting AutoIt3Wrapper (' & $VERSION & ')')
	__ConsoleWrite(' from:' & $RunBy & ' (' & FileGetVersion($RunByFull) & ')')
	__ConsoleWrite('  Keyboard:' & @KBLayout)
	__ConsoleWrite('  OS:' & @OSVersion & '/' & (@OSServicePack <> "" ? @OSServicePack : RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ReleaseId")))
	__ConsoleWrite('  CPU:' & @CPUArch & ' OS:' & @OSArch)
	__ConsoleWrite('  Environment(Language:' & @OSLang & ')')
	If $RunBySciTE Then
		__ConsoleWrite('  CodePage:' & SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:code.page"))
		__ConsoleWrite('  utf8.auto.check:' & SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:utf8.auto.check"))
	EndIf
	__ConsoleWrite("" & @CRLF)
EndIf
; Use Appdata @LocalAppDataDir & "\AutoIt v3\SciTE\Au3toIt3Wrapper"
Global $UserData
Global $AutoIt3WapperIni
; Check for SCITE_USERHOME Env variable and used that when specified.
; Else use Program directory
If EnvGet("SCITE_USERHOME") <> "" And FileExists(EnvGet("SCITE_USERHOME") & "\AutoIt3Wrapper") Then
	$AutoIt3WapperIni = EnvGet("SCITE_USERHOME") & "\AutoIt3Wrapper\AutoIt3Wrapper.ini"
	$UserData = EnvGet("SCITE_USERHOME") & "\AutoIt3Wrapper"
ElseIf EnvGet("SCITE_HOME") <> "" And FileExists(EnvGet("SCITE_HOME") & "\AutoIt3Wrapper") Then
	$AutoIt3WapperIni = EnvGet("SCITE_HOME") & "\AutoIt3Wrapper\AutoIt3Wrapper.ini"
	$UserData = EnvGet("SCITE_HOME") & "\AutoIt3Wrapper"
Else
	$AutoIt3WapperIni = @ScriptDir & "\AutoIt3Wrapper.ini"
	$UserData = @ScriptDir
EndIf
; Only display in case None of these tools are started
If $RunBySciTE _
		And Not StringInStr($CMDLINERAW, "/watcher") _
		And Not StringInStr($CMDLINERAW, "/runadmin") _
		And Not StringInStr($CMDLINERAW, "/au3record") _
		And Not StringInStr($CMDLINERAW, "/au3info") _
		And Not StringInStr($CMDLINERAW, "/Jump2FirstError") _
		Then
	__ConsoleWrite("+>         SciTEDir => " & $SciTE_Dir)
	__ConsoleWrite("   UserDir => " & $UserData)
	If EnvGet("SCITE_HOME") <> "" Then __ConsoleWrite('   SCITE_HOME => ' & EnvGet("SCITE_HOME") & " ")
	If EnvGet("SCITE_USERHOME") <> "" Then __ConsoleWrite('   SCITE_USERHOME => ' & EnvGet("SCITE_USERHOME") & " ")
	__ConsoleWrite("" & @CRLF)
EndIf
#EndRegion AutoIt General Settings & Includes
#Region Declare variables
Global $ShowGUI = 0
;
; RESOURCE CONSTANTS
;
; already defined in "WinAPIRes.au3"
;~ Global Enum $RT_CURSOR = 1, $RT_BITMAP, $RT_ICON, $RT_MENU, $RT_DIALOG, $RT_STRING, $RT_FONTDIR, $RT_FONT, $RT_ACCELERATOR, _
;~ 		$RT_RCDATA, $RT_MESSAGETABLE, $RT_GROUP_CURSOR, $RT_13, $RT_GROUP_ICON, $RT_15, $RT_VERSION, $RT_DLGINCLUDE, $RT_18, $RT_PLUGPLAY, _
;~ 		$RT_VXD, $RT_ANICURSOR, $RT_ANIICON, $RT_HTML, $RT_MANIFEST = 24
Global Const $aRESOURCE_TYPES[24] = ["RT_CURSOR", "RT_BITMAP", "RT_ICON", "RT_MENU", "RT_DIALOG", "RT_STRING", "RT_FONTDIR", "RT_FONT", "RT_ACCELERATOR", _
		"RT_RCDATA", "RT_MESSAGETABLE", "RT_GROUPCURSOR", "", "RT_GROUPICON", "", "RT_VERSION", "RT_DLGINCLUDE", "", "RT_PLUGPLAY", _
		"RT_VXD", "RT_ANICURSOR", "RT_ANIICON", "RT_HTML", "RT_MANIFEST"]
Global Const $IMAGE_DOS_SIGNATURE = 0x5A4D
Global Const $tagIMAGE_SECTION_HEADER = _
		"byte Name[8];" & _
		"dword Misc;" & _
		"dword VirtualAddress;" & _
		"dword SizeOfRawData;" & _
		"dword PointerToRawData;" & _
		"dword PointerToRelocations;" & _
		"dword PointerToLinenumber;" & _
		"ushort NumberOfRelocations;" & _
		"ushort NumberOfLinenumbers;" & _
		"dword Characteristics"
Global Const $tagIMAGE_DOS_HEADER = _
		"ushort emagic;" & _
		"ushort ecblp;" & _
		"ushort ecp;" & _
		"ushort ecrlc;" & _
		"ushort ecparhdr;" & _
		"ushort eminalloc;" & _
		"ushort emaxalloc;" & _
		"ushort ess;" & _
		"ushort esp;" & _
		"ushort ecsum;" & _
		"ushort eip;" & _
		"ushort ecs;" & _
		"ushort elfarlc;" & _
		"ushort eovno;" & _
		"ushort eres[4];" & _
		"ushort eoemid;" & _
		"ushort eoeminfo;" & _
		"ushort eres2[10];" & _
		"long elfanew"
Global Const $tagIMAGE_FILE_HEADER = _
		"ushort Machine;" & _
		"ushort NumberOfSections;" & _
		"dword TimeDateStamp;" & _
		"dword PointerToSymbolTable;" & _
		"dword NumberOfSymbols;" & _
		"ushort SizeOfOptionalHeader;" & _
		"ushort Characteristics"
Global $tagTEMP = _
		"ushort Magic;" & _                                          ; Standard fields
		"byte MajorLinkerVersion;" & _
		"byte MinorLinkerVersion;" & _
		"dword SizeOfCode;" & _
		"dword SizeOfInitializedData;" & _
		"dword SizeOfUninitializedData;" & _
		"dword AddressOfEntryPoint;" & _
		"dword BaseOfCode;" & _
		"dword BaseOfData;" & _
		"dword ImageBase;" & _                                       ; NT additional fields
		"dword SectionAlignment;" & _
		"dword FileAlignment;" & _
		"ushort MajorOperatingSystemVersion;" & _
		"ushort MinorOperatingSystemVersion;" & _
		"ushort MajorImageVersion;" & _
		"ushort MinorImageVersion;" & _
		"ushort MajorSubsystemVersion;" & _
		"ushort MinorSubsystemVersion;" & _
		"dword Win32VersionValue;" & _
		"dword SizeOfImage;" & _
		"dword SizeOfHeaders;" & _
		"dword CheckSum;" & _
		"ushort Subsystem;" & _
		"ushort DllCharacteristics;" & _
		"dword SizeOfStackReserve;" & _
		"dword SizeOfStackCommit;" & _
		"dword SizeOfHeapReserve;" & _
		"dword SizeOfHeapCommit;" & _
		"dword LoaderFlags;" & _
		"dword NumberOfRvaAndSizes"
; assign indexes to each IMAGE_DATA_DIRECTORY struct so we can find them later
For $i = 0 To 15
	$tagTEMP &= ";ulong VirtualAddress" & $i & ";ulong Size" & $i
Next
Global Const $tagIMAGE_OPTIONAL_HEADER = $tagTEMP
$tagTEMP = 0
; set dir for all temporary files, fall back to @TempDir if it doesn't exist
Global $TempDir = _WinAPI_ExpandEnvironmentStrings(IniRead($AutoIt3WapperIni, "Other", "TempDir", ""))
If Not FileExists($TempDir) Or $TempDir = "" Then
	$TempDir = @LocalAppDataDir & "\AutoIt v3\Aut2exe"
	If Not FileExists($TempDir) Then DirCreate($TempDir)
EndIf
Global $TempConsOut = __TempFile($TempDir, "~ConOut")
Global Const $tagIMAGE_NT_HEADERS = _
		"dword Signature;" & _
		$tagIMAGE_FILE_HEADER & ";" & _                              ; offset = 4
		$tagIMAGE_OPTIONAL_HEADER                                    ; offset = 24
Global $g_aResNamesAndLangs[1][2] = [[0, 0]]                         ; reset array
Global $rh, $hLangCallback
Global $aVersionInfo, $aManifestInfo, $aTemp
Global $IconFileInfo, $CursorFileInfo

Global $SourceFileNames[3][3]
Global $IncludeDirs[1]
Global $IncludeDirs_cnt

; use to store original & temp filenames for UTF named files
Global $ScriptFile_In = "", $ScriptFile_In_Ext = "", $ScriptFile_In_stripped = "", $ScriptFile_Out = "", $ScriptFile_Out_x86 = "", $ScriptFile_Out_x64 = "", $ScriptFile_Out_Type = ""
Global $ScriptFile_In_Org
Global $INP_Compile_Both = 0
Global $INP_Icon = "", $INP_Compression = "", $INP_AutoIt3_Version = ""
Global $AutoIt3_PGM = "", $AUT2EXE_PGM = "", $INP_AutoItDir = ""
Global $Pragma_Used = 0
Global $Pragma_Out = "", $Pragma_Icon = "n", $Pragma_RES_requestedExecutionLevel = "", $Pragma_UseUpx = "", $Pragma_Change2CUI = "", $Pragma_Compression = "", $Pragma_RES_Compatibility = ""
Global $Pragma_Out_x64 = "", $Pragma_Comment = "", $Pragma_CompanyName = "", $Pragma_Description = "", $Pragma_Fileversion = "", $Pragma_InternalName = "", $Pragma_LegalCopyright = "", $Pragma_LegalTradeMarks = ""
Global $Pragma_Productname = "", $Pragma_ProductVersion = ""
Global $INP_Run_Debug_Mode = 0, $INP_UseUpx = "", $INP_Upx_Parameters = "", $INP_UseAnsi = "n", $INP_UseX64 = "", $INP_Comment = "", $INP_CompanyName = "", $INP_Description = "", $INP_Res_SaveSource = ""
Global $INP_Res_Language = "", $INP_Res_requestedExecutionLevel = "", $INP_RES_HiDpi = "", $INP_Res_Compatibility = "", $INP_Fileversion = "", $INP_Fileversion_New = "", $INP_Fileversion_AutoIncrement = "", $INP_Fileversion_First_Increment = "", $INP_Fileversion_Use_Template = "", $INP_LegalCopyright = "", $INP_LegalTradeMarks = ""
Global $INP_ProductName = "", $INP_ProductVersion = "", $INP_CompiledScript = "", $INP_FieldName1 = "", $INP_FieldValue1 = "", $INP_FieldName2 = "", $INP_FieldValue2 = "", $INP_Res_FieldCount = 0, $INP_FieldName[16]
Global $INP_FieldValue[16], $INP_Run_Tidy = "", $INP_Run_Au3Stripper = "", $INP_Tidy_Stop_OnError = "Y", $INP_Run_AU3Check = "", $INP_Jump_To_First_Error = "Y", $INP_Add_Constants = "", $INP_Run_SciTE_Minimized = "n", $INP_Run_SciTE_OutputPane_Minimized = "n"
Global $INP_AU3Check_Stop_OnWarning, $INP_AU3Check_Parameters, $INP_Run_Stop_OnError = "N", $INP_Run_Before[2], $INP_Run_After[2], $INP_Run_Before_Admin[2], $INP_Run_After_Admin[2], $INP_Run_Versioning, $INP_Versioning_Parameters
Global $INP_Plugin, $INP_Change2CUI, $INP_Icons[1], $INP_Icons_cnt = 0, $INP_Cursors[1], $INP_Cursors_cnt = 0, $INP_Res_Files[1], $INP_Res_Files_Cnt = 0, $TempFile, $TempFile2
Global $INP_Au3check_Plugin, $INP_Tidy_Parameters = "", $INP_Au3Stripper_OnError = "", $INP_Au3Stripper_Parameters = "", $INP_AutoIt3Wrapper_LogFile = "", $INP_AutoIt3Wrapper_If = "", $INP_AutoIt3Wrapper_Testing = "N"
Global $INP_ShowStatus = ""
Global $H_Resource, $H_Comment, $H_CompanyName, $H_Description, $H_Fileversion, $H_Fileversion_AutoIncrement_n, $H_Fileversion_AutoIncrement_p, $H_Fileversion_AutoIncrement_y
Global $H_LegalCopyright, $H_LegalTradeMarks, $H_FieldNameEdit, $H_Res_Language, $H_ProductName, $H_ProductVersion
Global $IconResBase = 49
Global $CursorResBase = 49
Global $Au3StripperCmdLine
Global $DebugIcon = ""
Global $Parameter_Mode = 0
Global $Debug = 0
Global $Registry = "HKCU\Software\AutoIt v3"
Global $RegistryLM = "HKLM\Software\AutoIt v3\AutoIt"
Global $Option = "Compile"
Global $s_CMDLine = ""
Global $ToTalFile
Global $H_Outf
Global $CurSciTEFile, $CurSciTELine, $FindVer, $CurSelection
Global $dummy, $V_Arg, $T_Var, $H_Cmp, $H_au3, $rc, $Save_Workdir, $AUT2EXE_DIR, $AUT2EXE_PGM_N, $msg, $AUT2EXE_PGM_VER
Global $LSCRIPTDIR, $AutoIt_Icon, $INP_Icon_Temp, $AutoIt_Icon_Dir
Global $InputFileIsUTF8 = 0
Global $InputFileIsUTF16 = 0
Global $InputFileIsUTF32 = 0
Global $ProcessBar_Title
Global $Pid, $Handle, $Return_Text, $ExitCode
Global $sCmd
Global $SrceUnicodeFlag, $UTFtype
Global $Found_Old_ObfuscatorDirective = 0
;
Global $CurrentAutoIt_InstallDir = _PathFull(@ScriptDir & "..\..\..")
If StringLeft($SciTE_Dir, 3) = "\\\" Then $SciTE_Dir = StringMid($SciTE_Dir, 2)
If StringLeft($CurrentAutoIt_InstallDir, 3) = "\\\" Then $CurrentAutoIt_InstallDir = StringMid($CurrentAutoIt_InstallDir, 2)
;~ If StringInStr($SciTE_Dir, "\", '', -1) > 0 Then $SciTE_Dir = StringLeft($SciTE_Dir, StringInStr($SciTE_Dir, "\", '', -1) - 1)
;
#EndRegion Declare variables
#Region Commandline lexing
; retrieve commandline parameters
;-------------------------------------------------------------------------------------------
$V_Arg = "Valid Arguments are:" & @CRLF
$V_Arg &= "    /in  ScriptFile " & @CRLF
$V_Arg &= "    /out Targetfile " & @CRLF
$V_Arg &= "    /icon IconFile " & @CRLF
$V_Arg &= "    /comp 0 to 4  (Lowest to Highest) " & @CRLF
$V_Arg &= "    /nopack    Skip UPX step." & @CRLF
$V_Arg &= "    /pack      Run UPX (Default) " & @CRLF
$V_Arg &= "    /unicode   Default compile with Unocode support. " & @CRLF
$V_Arg &= "    /test      just run autoit3 or aut2exe and skip other options." & @CRLF
$V_Arg &= "    /x86       Compile for x86 OS." & @CRLF
$V_Arg &= "    /x64       Compile for x64 OS." & @CRLF
$V_Arg &= "    /console   Change output program to CUI" & @CRLF
$V_Arg &= "    /Gui       Default, output program will be GUI" & @CRLF
$V_Arg &= "    /NoStatus  Suppress the Progress window." & @CRLF
; switch on debug messages when requested
If StringInStr(" " & $CMDLINERAW & " ", " /debug ") Then $Debug = 1
;
If $Debug Then __ConsoleWrite("-debug cmdlineraw: " & $CMDLINERAW & @CRLF)

For $x = 1 To $CMDLINE[0]
	$T_Var = StringLower($CMDLINE[$x])
	If $Debug Then
		__ConsoleWrite("-debug argument: " & $CMDLINE[$x])
		If $x < $CMDLINE[0] Then __ConsoleWrite("     next argument: " & $CMDLINE[$x + 1])
		__ConsoleWrite(@CRLF)
	EndIf
	$Parameter_Mode = 1
	Select
		Case $T_Var = "/Watcher"
			AutoItWinSetTitle("AutoIt3Wrapper_Watcher")
			Global $H_Wintitle = "doesntexists"
			; Second AutoIt3Wrapper is lanched as watcher to see if the original AutoIt3Wrapper is canceled by Ctrl+Break or any other way.
			If $cmdline[0] > $x Then $H_Cmp = $CMDLINE[$x + 1]
			If $cmdline[0] > $x + 1 Then $H_au3 = $CMDLINE[$x + 2]
			While ProcessExists($H_Cmp) And ProcessExists($H_au3)
				Sleep(200)
			WEnd
			Sleep(200)
			; Clean up in case the original AutoIt3Wrapper termintated but AutoIt3 is still running
			If ProcessExists($H_au3) Then
				; first try closing nicely by sending WinClose to the windows of the PID of the running script
				Global $aData = _WinAPI_EnumProcessWindows($H_au3, False)
				For $x = 1 To $aData[0][0]
					WinClose($aData[$x][0])
				Next
				; Only force close when softclose didn't work
				Sleep(500)
				If ProcessExists($H_au3) Then
					ProcessClose($H_au3)
					Sleep(500)
					; cleanup any dead trayicons
					_RefreshSystemTray()
				EndIf
			EndIf
			Exit
		Case $T_Var = "/runadmin"
			$Option = "RunAdmin"
			$x = $x + 1
			$RunAdminChkFile = $CMDLINE[$x]                          ; This file is checked for existence and the process will end when it is not there anymore to allow to instruct the elevated process to kill itself.
		Case $T_Var = "/Jump2FirstError"
			; when AutoIt3Wrapper is launched for "Jump2FirstError" then wait till the original AutoIt3Wrapper is ended and after send "Next Message(F4)" command
			$H_Cmp = $CMDLINE[$x + 1]
			While ProcessExists($H_Cmp)
				Sleep(100)
			WEnd
			Sleep(200)
			SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "menucommand:306") ; IDM_NEXTMSG
			Exit
		Case $T_Var = "/au3info"
			; start the correct au3info version
			If $INP_AutoItDir <> "" Then
				$CurrentAutoIt_InstallDir = $INP_AutoItDir
			EndIf
			If @OSArch = "X64" Then
				Run($CurrentAutoIt_InstallDir & "\au3info_x64.exe")
			Else
				Run($CurrentAutoIt_InstallDir & "\au3info.exe")
			EndIf
			Exit
		Case $T_Var = "/versioning_Init"
			;
			VersioningINIinit("SVN", 1)
			Exit
		Case $T_Var = "/versioning_Commit"
			; Commit current source to versioning
			Retrieve_PreProcessor_Info()
			Versioning($ScriptFile_In, Convert_Variables($INP_Versioning_Parameters, 1))
			Exit
		Case $T_Var = "/versioning_ShowDiff"
			; Show Diff between current source and versioning version
			Versioning($ScriptFile_In, "/ShowDiff")
			Exit
		Case $T_Var = "/au3record"
			If $INP_AutoItDir <> "" Then
				$CurrentAutoIt_InstallDir = $INP_AutoItDir
			EndIf
			; start the correct au3record version
			If @OSArch = "X64" And FileExists($CurrentAutoIt_InstallDir & "\Extras\Au3Record\au3record_x64.exe") Then
				$Pid = Run($CurrentAutoIt_InstallDir & "\Extras\Au3Record\au3record_x64.exe /o", '', @SW_SHOW, $STDOUT_CHILD + $STDERR_CHILD)
			ElseIf FileExists($CurrentAutoIt_InstallDir & "\Extras\Au3Record\au3record.exe") Then
				$Pid = Run($CurrentAutoIt_InstallDir & "\Extras\Au3Record\au3record.exe /o", '', @SW_SHOW, $STDOUT_CHILD + $STDERR_CHILD)
			Else
				MsgBox(11, "Error", "! AU3record.exe is not available and needs to be downloaded separately from the AutoIt3 site." & @CRLF)
				Exit
			EndIf
			$Handle = _ProcessExitCode($Pid)
			$Return_Text = ShowStdOutErr($Pid)
			$ExitCode = _ProcessExitCode($Pid, $Handle)
			_ProcessCloseHandle($Handle)
			StdioClose($Pid)
			Exit
		Case $T_Var = "/?" Or $T_Var = "/help"
			MsgBox(1, "Compile Aut2EXE", "Compile an AutoIt3 Script." & @LF & "commandline argument: " & $T_Var & @LF & $V_Arg)
			Exit
		Case $T_Var = "/in"
			$x = $x + 1
			$ScriptFile_In = $CMDLINE[$x]
		Case $T_Var = "/out"
			$x = $x + 1
			$ScriptFile_Out = $CMDLINE[$x]
		Case $T_Var = "/icon"
			$x = $x + 1
			$INP_Icon = $CMDLINE[$x]
			$DebugIcon = $DebugIcon & "/icon: " & $INP_Icon & @CRLF
		Case $T_Var = "/pass"                                        ; Obsolete
			$x = $x + 1
		Case $T_Var = "/compress" Or $T_Var = "/comp" Or $T_Var = "/compression"
			$x = $x + 1
			$INP_Compression = Number($CMDLINE[$x])
		Case $T_Var = "/nodecompile"
;~ 			$INP_Allow_Decompile = "n"
		Case $T_Var = "/Pack"
			$INP_UseUpx = "y"
		Case $T_Var = "/NoPack"
			$INP_UseUpx = "n"
		Case $T_Var = "/Compression"
			$INP_Compression = "y"
		Case $T_Var = "/GUI"
;~ 			Just for compatibility sake
		Case $T_Var = "/Console"
			$INP_Change2CUI = "y"
		Case $T_Var = "/Unicode"
			$INP_UseAnsi = "n"
			$INP_UseX64 = "n"
		Case $T_Var = "/test"
			$INP_AutoIt3Wrapper_Testing = "y"
		Case $T_Var = "/x64"
			$INP_UseX64 = "y"
			$INP_UseAnsi = "n"
		Case $T_Var = "/x86"
			$INP_UseX64 = "n"
			$INP_UseAnsi = "n"
		Case $T_Var = "/run"
			$Option = "Run"
		Case $T_Var = "/debug"
			$Debug = 1
		Case $T_Var = "/au3check"
			$Option = "AU3Check"
		Case $T_Var = "/au3stripper"
			$Option = "AU3Stripper"
		Case $T_Var = "/tidy"
			$Option = "Tidy"
		Case $T_Var = "/RunAfter"
			; Undocumented feature for Update use while developing de code:
			; This option is MY workaround to still copy the Script, updating version and running SVN commit with Ctrl+Shift+C
			; Get Predefined settings from the Scriptfile itself. These will override all other settings
			Retrieve_PreProcessor_Info()
			; Set Variables
			$ScriptFile_In_Org = $ScriptFile_In
			; Check if the Version needs updating
			If $INP_Fileversion_Use_Template <> '' And $INP_Fileversion_AutoIncrement <> "p" Then
				$INP_Fileversion = Valid_FileVersion($INP_Fileversion)
			ElseIf $INP_Fileversion_AutoIncrement = "p" Then
				$INP_Fileversion = Valid_FileVersion($INP_Fileversion)
				If $INP_AutoIt3Wrapper_Testing = "n" And MsgBox(262144 + 4096 + 4, "AutoIt3Wrappper", "2.Do you want to increase the version number of the source to:" & @LF & $INP_Fileversion_New, 10) = 6 Then
					$INP_Fileversion_AutoIncrement = 'y'
				Else
					$INP_Fileversion_New = $INP_Fileversion
				EndIf
			EndIf
			; Update fileversion is requested before
			If ($INP_Fileversion_First_Increment = "y" And $INP_Fileversion_AutoIncrement = 'y') Or $INP_Fileversion_Use_Template <> '' Then Update_Version()
			;Process RunAfter Directives
			For $x = 1 To $INP_Run_After[0]
				If StringStripWS($INP_Run_After[$x], 3) <> "" Then
					; translate possible %..% to the actual values
					$INP_Run_After[$x] = Convert_Variables($INP_Run_After[$x])
					If $INP_Run_After_Admin[$x] Then
						__ConsoleWrite(RunReqAdminDosCommand($INP_Run_After[$x], 0, $TempConsOut))
					Else
						__ConsoleWrite(">Running AP:" & $INP_Run_After[$x] & @CRLF)
						$Pid = Run(@ComSpec & ' /C ' & $INP_Run_After[$x] & '', '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
						$Handle = _ProcessExitCode($Pid)
						ShowStdOutErr($Pid, 1, 0)
						$ExitCode = _ProcessExitCode($Pid, $Handle)
						_ProcessCloseHandle($Handle)
						__ConsoleWrite(">" & $INP_Run_After[$x] & " Ended   rc:" & $ExitCode & @CRLF)
					EndIf
				EndIf
			Next
			; Update fileversion is requested
			If $INP_Fileversion_First_Increment <> "y" And $INP_Fileversion_AutoIncrement = 'y' Then Update_Version()
			; run VersionWrapper when requested
			If ($INP_Run_Versioning = 'y' Or ($INP_Run_Versioning = 'v' And $INP_Fileversion_AutoIncrement = 'y')) And $INP_AutoIt3Wrapper_Testing = "n" Then
				Versioning($ScriptFile_In_Org, Convert_Variables($INP_Versioning_Parameters, 1))
			EndIf
			;Stop executing
			Exit
		Case $T_Var = "/compiledefaults"
			; $Option2 = "defaults"  ; Obsolete
		Case $T_Var = "/addconstants"
			Add_Constants()
		Case $T_Var = "/Alpha"
			$INP_AutoIt3_Version = "Alpha"
		Case $T_Var = "/Beta"
			$INP_AutoIt3_Version = "Beta"
		Case $T_Var = "/prod"
			$INP_AutoIt3_Version = "Prod"
		Case $T_Var = "/showgui"
			$ShowGUI = 1
		Case $T_Var = "/AutoIt3Dir"
			$x = $x + 1
			$INP_AutoItDir = _PathFull($CMDLINE[$x])
		Case $T_Var = "/NoStatus"
			$INP_ShowStatus = "n"
		Case $T_Var = "/UserParams"
			$s_CMDLine = StringTrimLeft($CMDLINERAW, StringInStr($CMDLINERAW, "/UserParams") + 11)
			ExitLoop
		Case Else
			; when /run then optional parameters are allowed
			If $Option = "Compile" Then
				MsgBox(1, "Compile Aut2EXE", "Wrong commandline argument: " & $T_Var & @LF & $V_Arg)
				Exit
			EndIf
			; Build the other params used for running autoit
			$s_CMDLine &= " " & $T_Var
	EndSelect
Next
#EndRegion Commandline lexing
#Region Input retrieval/validation
If FileExists(@TempDir & "\AutoIt3WrapperRunTmpFiles") Then
	$rc = FileDelete(@TempDir & "\AutoIt3WrapperRunTmpFiles\*.*")
	$rc = DirRemove(@TempDir & "\AutoIt3WrapperRunTmpFiles", 1)
EndIf

If $ScriptFile_In <> "" And FileExists($ScriptFile_In) And $Option <> "RunAdmin" Then
	$ScriptFile_In_Org = $ScriptFile_In
Else
	; check/request for input Script File
	;-------------------------------------------------------------------------------------------
	While Not FileExists($ScriptFile_In) And $Option <> "RunAdmin"
		$ScriptFile_In = FileOpenDialog("File not found, select scriptfile to " & $Option & " :", RegRead($Registry & "\Aut2Exe", "LastScriptDir"), "autoit3(*.au3)", 1)
		If @error = 1 Then
			$rc = MsgBox(4100, "AutoIt3 Compile", "do you want to stop the process?")
			If $rc = 6 Then Exit
		EndIf
	WEnd
	$ScriptFile_In_Org = $ScriptFile_In
EndIf

; Get the default values for this particular script from the ini when not specified on the commandline
;-----------------------------------------------------------------------------------------------------
If $ScriptFile_Out = "" Then
	$ScriptFile_Out = IniRead($ScriptFile_In & ".ini", "AutoIt", "outfile", "")
	$ScriptFile_Out_Type = IniRead($ScriptFile_In & ".ini", "AutoIt", "outfile_type", "")
Else
	$ScriptFile_Out_Type = StringRight($ScriptFile_Out, 3)
EndIf
If $INP_Icon = "" Then
	$INP_Icon = IniRead($ScriptFile_In & ".ini", "AutoIt", "icon", "")
	$DebugIcon = $DebugIcon & "INI icon: " & $INP_Icon & @CRLF
EndIf
; Retrieve Script defaults from its previous saved INI file
If FileExists($ScriptFile_In & ".ini") Then
	If IniRead($ScriptFile_In & ".ini", "General", "Convert2Directive", "") <> "N" Then
		If IniRead($ScriptFile_In & ".ini", "General", "Convert2Directive", "") = "Y" Or MsgBox(262144 + 4096 + 4, "AutoIt3Wrappper", "Found INI file containing AutoIt3Wrapper information." & @LF & _
				"Do you want to updated your script with the appropriate #Directives and Recycle the INI ?", 10) = 6 Then
			Convert_RES_INI_to_Directives()
		Else
			IniWrite($ScriptFile_In & ".ini", "General", "Convert2Directive", "N")
		EndIf
	EndIf
	If $INP_Compression = "" Then $INP_Compression = IniRead($ScriptFile_In & ".ini", "AutoIt", "Compression", "")
	If $INP_UseUpx = "" Then $INP_UseUpx = IniRead($ScriptFile_In & ".ini", "AutoIt", "UseUpx", "")
	If $INP_UseX64 = "" Then $INP_UseX64 = IniRead($ScriptFile_In & ".ini", "AutoIt", "Usex64", "")
	$INP_Comment = Convert_Variables(IniRead($ScriptFile_In & ".ini", "Res", "Comment", ""))
	$INP_Description = Convert_Variables(IniRead($ScriptFile_In & ".ini", "Res", "Description", ""))
	$INP_Fileversion = IniRead($ScriptFile_In & ".ini", "Res", "Fileversion", "")
	$INP_Fileversion_AutoIncrement = IniRead($ScriptFile_In & ".ini", "Res", "Fileversion_AutoIncrement", "")
	$INP_Fileversion_First_Increment = IniRead($ScriptFile_In & ".ini", "Res", "Fileversion_First_AutoIncrement", "")
	$INP_Fileversion_Use_Template = IniRead($ScriptFile_In & ".ini", "Res", "Fileversion_Use_Template", "")
	$INP_ProductName = IniRead($ScriptFile_In & ".ini", "Res", "ProductName", "")
	$INP_ProductVersion = IniRead($ScriptFile_In & ".ini", "Res", "ProductVersion", "")
	$INP_CompanyName = IniRead($ScriptFile_In & ".ini", "Res", "CompanyName", "")
	$INP_LegalCopyright = IniRead($ScriptFile_In & ".ini", "Res", "LegalCopyright", "")
	$INP_LegalTradeMarks = IniRead($ScriptFile_In & ".ini", "Res", "LegalTradeMarks", "")
	$INP_Res_SaveSource = IniRead($ScriptFile_In & ".ini", "Res", "SaveSource", "")
	$INP_FieldName1 = IniRead($ScriptFile_In & ".ini", "Res", "Field1Name", "")
	$INP_FieldValue1 = Convert_Variables(IniRead($ScriptFile_In & ".ini", "Res", "Field1Value", ""))
	$INP_FieldName2 = IniRead($ScriptFile_In & ".ini", "Res", "Field2Name", "")
	$INP_FieldValue2 = Convert_Variables(IniRead($ScriptFile_In & ".ini", "Res", "Field2Value", ""))
	$INP_Run_AU3Check = IniRead($ScriptFile_In & ".ini", "Other", "Run_AU3Check", "")
	$INP_Jump_To_First_Error = IniRead($ScriptFile_In & ".ini", "Other", "Jump_To_First_Error", "")
	$INP_AU3Check_Stop_OnWarning = IniRead($ScriptFile_In & ".ini", "Other", "AU3Check_Stop_OnWarning", "")
	$INP_AU3Check_Parameters = IniRead($ScriptFile_In & ".ini", "Other", "AU3Check_Parameter", "")
	$INP_Run_Stop_OnError = StringSplit(IniRead($ScriptFile_In & ".ini", "Other", "Run_Stop_OnError", ""), "")
	$INP_Tidy_Stop_OnError = StringSplit(IniRead($ScriptFile_In & ".ini", "Other", "Tidy_Stop_OnError", ""), "")
	$INP_Run_Before = StringSplit(IniRead($ScriptFile_In & ".ini", "Other", "Run_Before", ""), "|") ; left in there for backwards compatibility in case multiple commands are defined on one line delimited by |
	$INP_Run_After = StringSplit(IniRead($ScriptFile_In & ".ini", "Other", "Run_After", ""), "|")
	$INP_Run_Versioning = IniRead($ScriptFile_In & ".ini", "Other", "Run_Versioning", "")
	$INP_Versioning_Parameters = IniRead($ScriptFile_In & ".ini", "Other", "VersionWrapper_Parameter", "")
	$INP_Change2CUI = IniRead($ScriptFile_In & ".ini", "Other", "Change2CUI", "")
	$INP_ShowStatus = IniRead($ScriptFile_In & ".ini", "Other", "ShowProgress", "")
	$INP_Au3Stripper_OnError = IniRead($ScriptFile_In & ".ini", "Other", "Au3Stripper_OnError", "")
EndIf
;Retrieve AutoIt3Wrapper Defaults from AutoIt3Wrapper.INI
If $ScriptFile_Out_Type = "" Then $ScriptFile_Out_Type = IniRead($AutoIt3WapperIni, "AutoIt", "outfile_type", "")
If $INP_Icon = "" Then $INP_Icon = IniRead($AutoIt3WapperIni, "AutoIt", "icon", "")
If $INP_Compression = "" Then $INP_Compression = IniRead($AutoIt3WapperIni, "AutoIt", "Compression", "")
If $INP_UseUpx = "" Then $INP_UseUpx = IniRead($AutoIt3WapperIni, "AutoIt", "UseUpx", "")
If $INP_UseX64 = "" Then $INP_UseX64 = IniRead($AutoIt3WapperIni, "AutoIt", "UseX64", "")
If $INP_AutoItDir = "" Then $AUT2EXE_PGM = IniRead($AutoIt3WapperIni, "AutoIt", "aut2exe", "")
If $INP_Res_Language = "" Then $INP_Res_Language = IniRead($AutoIt3WapperIni, "Res", "Language", "")
If $INP_Res_Language = "" Then $INP_Res_Language = "2057"            ; to force default
If $INP_Res_requestedExecutionLevel = "" Then $INP_Res_requestedExecutionLevel = IniRead($AutoIt3WapperIni, "Res", "RequestedExecutionLevel", "")
If $INP_RES_HiDpi = "" Then $INP_RES_HiDpi = IniRead(@ScriptDir & "\AutoIt3Wrapper.ini", "Res", "HiDpi", "")
If $INP_Res_Compatibility = "" Then $INP_Res_Compatibility = IniRead($AutoIt3WapperIni, "Res", "Compatibility", "")
If $INP_Comment = "" Then $INP_Comment = Convert_Variables(IniRead($AutoIt3WapperIni, "Res", "Comment", ""))
If $INP_Description = "" Then $INP_Description = Convert_Variables(IniRead($AutoIt3WapperIni, "Res", "Description", ""))
If $INP_Fileversion = "" Then $INP_Fileversion = IniRead($AutoIt3WapperIni, "Res", "Fileversion", "")
If $INP_Fileversion_AutoIncrement = "" Then $INP_Fileversion_AutoIncrement = IniRead($AutoIt3WapperIni, "Res", "Fileversion_AutoIncrement", "")
If $INP_Fileversion_First_Increment = "" Then $INP_Fileversion_First_Increment = IniRead($AutoIt3WapperIni, "Res", "Fileversion_First_AutoIncrement", "")
If $INP_Fileversion_Use_Template = "" Then $INP_Fileversion_Use_Template = IniRead($AutoIt3WapperIni, "Res", "Fileversion_Use_Template", "")
If $INP_ProductName = "" Then $INP_ProductName = IniRead($AutoIt3WapperIni, "Res", "ProductName", "")
If $INP_ProductVersion = "" Then $INP_ProductVersion = IniRead($AutoIt3WapperIni, "Res", "ProductVersion", "")
If $INP_CompanyName = "" Then $INP_CompanyName = IniRead($AutoIt3WapperIni, "Res", "CompanyName", "")
If $INP_LegalCopyright = "" Then $INP_LegalCopyright = IniRead($AutoIt3WapperIni, "Res", "LegalCopyright", "")
If $INP_LegalTradeMarks = "" Then $INP_LegalTradeMarks = IniRead($AutoIt3WapperIni, "Res", "LegalTradeMarks", "")
If $INP_Res_SaveSource = "" Then $INP_Res_SaveSource = IniRead($AutoIt3WapperIni, "Res", "SaveSource", "")
If $INP_FieldName1 = "" Then $INP_FieldName1 = IniRead($AutoIt3WapperIni, "Res", "Field1Name", "")
If $INP_FieldValue1 = "" Then $INP_FieldValue1 = Convert_Variables(IniRead($AutoIt3WapperIni, "Res", "Field1Value", ""))
If $INP_FieldName2 = "" Then $INP_FieldName2 = IniRead($AutoIt3WapperIni, "Res", "Field2Name", "")
If $INP_FieldValue2 = "" Then $INP_FieldValue2 = Convert_Variables(IniRead($AutoIt3WapperIni, "Res", "Field2Value", ""))
If $INP_Run_Tidy = "" Then $INP_Run_Tidy = IniRead($AutoIt3WapperIni, "Other", "Run_Tidy", "")
If $INP_Tidy_Parameters = "" Then $INP_Tidy_Parameters = IniRead($AutoIt3WapperIni, "Other", "Tidy_Parameter", "")
If $INP_Run_Au3Stripper = "" Then $INP_Run_Au3Stripper = IniRead($AutoIt3WapperIni, "Other", "Run_Au3Stripper", "")
If $INP_Au3Stripper_Parameters = "" Then $INP_Au3Stripper_Parameters = IniRead($AutoIt3WapperIni, "Other", "Au3Stripper_Parameters", "")
If $INP_Run_AU3Check = "" Then $INP_Run_AU3Check = IniRead($AutoIt3WapperIni, "Other", "Run_AU3Check", "")
If $INP_Jump_To_First_Error = "" Then $INP_Run_AU3Check = IniRead($AutoIt3WapperIni, "Other", "Jump_To_First_Error", "")
If $INP_AU3Check_Stop_OnWarning = "" Then $INP_AU3Check_Stop_OnWarning = IniRead($AutoIt3WapperIni, "Other", "AU3Check_Stop_OnWarning", "")
If $INP_AU3Check_Parameters = "" Then $INP_AU3Check_Parameters = IniRead($AutoIt3WapperIni, "Other", "AU3Check_Parameter", "")
If $INP_Run_Stop_OnError = "" Then $INP_Run_Stop_OnError = StringSplit(IniRead($AutoIt3WapperIni, "Other", "Run_Stop_OnError", ""), "")
If $INP_Tidy_Stop_OnError = "" Then $INP_Tidy_Stop_OnError = StringSplit(IniRead($AutoIt3WapperIni, "Other", "Tidy_Stop_OnError", ""), "")
If $INP_Run_Before[1] = "" Then $INP_Run_Before = StringSplit(IniRead($AutoIt3WapperIni, "Other", "Run_Before", ""), "|")
If $INP_Run_Before[1] = "" Then $INP_Run_Before[0] = 0               ; Set to 0 when empty
If $INP_Run_After[1] = "" Then $INP_Run_After = StringSplit(IniRead($AutoIt3WapperIni, "Other", "Run_After", ""), "|")
If $INP_Run_Versioning = "" Then $INP_Run_Versioning = IniRead($AutoIt3WapperIni, "Other", "Run_Versioning", "")
If $INP_Versioning_Parameters = "" Then $INP_Versioning_Parameters = IniRead($AutoIt3WapperIni, "Other", "VersionWrapper_Parameter", "")
If $INP_Change2CUI = "" Then $INP_Change2CUI = IniRead($AutoIt3WapperIni, "Other", "Change2CUI", "")
If $INP_ShowStatus = "" Then $INP_ShowStatus = IniRead($AutoIt3WapperIni, "Other", "ShowProgress", "")
If $INP_Au3Stripper_OnError = "" Then $INP_Au3Stripper_OnError = IniRead($AutoIt3WapperIni, "Other", "Au3Stripper_OnError", "")
; Set Fields used to determine the extension
_PathSplit($ScriptFile_In, $dummy, $dummy, $dummy, $ScriptFile_In_Ext)
;-------------------------------------------------------------------------------------------
; Get Predefined settings from the Scriptfile itself. These will override all other settings
Retrieve_PreProcessor_Info()
;-------------------------------------------------------------------------------------------
; set proper defaults and translate/validate values
SetDefaults($INP_AutoIt3Wrapper_Testing, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
If $INP_AutoIt3Wrapper_Testing = "y" Then
	__ConsoleWrite("- *** Compile in Test mode skipping Tidy; Au3Stripper; Resource updating and Versioning to speed up the process. ***" & @CRLF)
EndIf
SetDefaults($INP_AutoIt3_Version, "Prod", "P=Prod;B=Beta;A=Alpha", "Prod;Beta;Alpha", 0)
SetDefaults($ScriptFile_Out_Type, "exe", "", "exe;a3x", 0)
; strip ending backslash
If StringRight($INP_AutoItDir, 1) = "\" Then $INP_AutoItDir = StringTrimRight($INP_AutoItDir, 1)
If Not ($INP_AutoItDir = "") And FileExists($INP_AutoItDir & "\AutoIt3.exe") Then
	$CurrentAutoIt_InstallDir = $INP_AutoItDir
	$Au3StripperCmdLine &= ' /autoit3dir "' & $INP_AutoItDir & '"'
EndIf
If Not FileExists($CurrentAutoIt_InstallDir & "\AutoIt3.exe") Then
	__ConsoleWrite("! Unable to determine the location of the AutoIt3 program directory! " & @CRLF & "  Directory:" & $CurrentAutoIt_InstallDir & " doesn't contain Autoit3.Exe" & @CRLF)
	Exit
EndIf
;
SetDefaults($INP_Compression, 2, "", "0;1;2;3;4", 1)
SetDefaults($INP_Compile_Both, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_UseUpx, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_Compile_Both, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
If @OSArch = "X86" Or StringInStr(RegRead("HKCR\AutoIt3Script\Shell\Run\Command", ""), "AutoIt3.exe") Then
	SetDefaults($INP_UseX64, "n", "auto=a;yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
Else
	SetDefaults($INP_UseX64, "y", "auto=a;yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
EndIf
SetDefaults($INP_Fileversion_AutoIncrement, "n", "prompt=p;yes=y;no=n;1=y;0=n;4=n", "y;n;p", 0, 0)
SetDefaults($INP_Fileversion_First_Increment, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_Run_AU3Check, "y", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_Jump_To_First_Error, "y", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_Run_Tidy, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_Run_Au3Stripper, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_Run_Versioning, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n;v", 0, 0)
SetDefaults($INP_AU3Check_Stop_OnWarning, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_RES_HiDpi, "n", "yes=y;no=n;PM=p;1=y;2=p;0=n;4=n", "y;n;p", 0, 0)
SetDefaults($INP_Res_SaveSource, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_Change2CUI, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_Add_Constants, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0)
SetDefaults($INP_Run_Stop_OnError, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0)
SetDefaults($INP_Tidy_Stop_OnError, "y", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0)
SetDefaults($INP_Au3Stripper_OnError, "c", "continue=c;stop=s;forceuse=f", "c;s;f", 0)
SetDefaults($ShowGUI, 0, "yes=1;no=0;y=1;n=0", "0;1", 0)
SetDefaults($INP_Run_SciTE_Minimized, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_Run_SciTE_OutputPane_Minimized, "n", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)
SetDefaults($INP_ShowStatus, "y", "yes=y;no=n;1=y;0=n;4=n", "y;n", 0, 0)

; Show GUI when requested but only during Compile
If $ShowGUI And $Option = "Compile" Then
	SciTE_SaveSession()
	GUI_Show()
EndIf
;
If $INP_AutoIt3_Version = "Beta" And FileExists($CurrentAutoIt_InstallDir & "\Beta\AutoIt3.exe") Then
	$CurrentAutoIt_InstallDir &= "\Beta"
	; Set Au3Stripper param to use /Beta too.
	If Not StringInStr($Au3StripperCmdLine, "/Beta") Then $Au3StripperCmdLine &= " /Beta"
EndIf
;
If $INP_AutoIt3_Version = "Alpha" And FileExists($CurrentAutoIt_InstallDir & "\Alpha\AutoIt3.exe") Then
	$CurrentAutoIt_InstallDir &= "\Alpha"
	; Set Au3Stripper param to use /Beta too.
	If Not StringInStr($Au3StripperCmdLine, "/Beta") Then $Au3StripperCmdLine &= " /Beta"
EndIf
;
If $ScriptFile_Out = StringRight($ScriptFile_In, StringLen($ScriptFile_In)) Then
	__ConsoleWrite("- Cannot specify the same output filename as the inputfile: " & $ScriptFile_Out & " ==> Changing to default (scriptname.exe)." & @CRLF)
	$ScriptFile_Out = ""
EndIf
;
;Set default for x86 exe
If $ScriptFile_Out = "" Then
	If $ScriptFile_Out_Type <> "" Then
		$ScriptFile_Out = StringTrimRight($ScriptFile_In, StringLen($ScriptFile_In_Ext)) & '.' & $ScriptFile_Out_Type
	Else
		$ScriptFile_Out = StringTrimRight($ScriptFile_In, StringLen($ScriptFile_In_Ext)) & '.exe'
	EndIf
EndIf
$ScriptFile_Out = _PathFull($ScriptFile_Out)
; fix _PathFull() problem
If StringLeft($ScriptFile_Out, 3) = "\\\" Then $ScriptFile_Out = StringMid($ScriptFile_Out, 2)
;
; Set default for x64 exe
If $ScriptFile_Out_x64 = "" Then
	If $INP_Compile_Both = "y" Then
		$ScriptFile_Out_x64 = StringReplace($ScriptFile_Out, ".", "_x64.", -1)
	Else
		$ScriptFile_Out_x64 = $ScriptFile_Out
	EndIf
EndIf
$ScriptFile_Out_x64 = _PathFull($ScriptFile_Out_x64)
; fix _PathFull() problem
If StringLeft($ScriptFile_Out_x64, 3) = "\\\" Then $ScriptFile_Out_x64 = StringMid($ScriptFile_Out_x64, 2)
;
; save current workdir for later use
$Save_Workdir = @WorkingDir
; retrieve aut3exe directory
;-------------------------------------------------------------------------------------------
If $Option = "Compile" Then
	If $AUT2EXE_PGM <> "" And FileExists($AUT2EXE_PGM) Then
		; support old override for AUT2EXE
	ElseIf $CurrentAutoIt_InstallDir <> "" And FileExists($CurrentAutoIt_InstallDir & "\aut2exe\aut2exe.exe") Then
		If @OSArch <> "x86" And FileExists($CurrentAutoIt_InstallDir & "\aut2exe\aut2exe_x64.exe") And StringInStr(RegRead("HKCR\AutoIt3Script\Shell\Compile\Command", ""), "aut2exe_x64.exe") Then
			$AUT2EXE_PGM = $CurrentAutoIt_InstallDir & "\aut2exe\aut2exe_x64.exe"
		Else
			$AUT2EXE_PGM = $CurrentAutoIt_InstallDir & "\aut2exe\aut2exe.exe"
		EndIf
	Else
		If @OSArch <> "x86" And FileExists($CurrentAutoIt_InstallDir & "\aut2exe\aut2exe_x64.exe") And StringInStr(RegRead("HKCR\AutoIt3Script\Shell\Compile\Command", ""), "aut2exe_x64.exe") Then
			$AUT2EXE_PGM = $CurrentAutoIt_InstallDir & "\aut2exe\aut2exe_x64.exe"
		Else
			$AUT2EXE_PGM = $CurrentAutoIt_InstallDir & '\aut2exe\Aut2Exe.exe'
		EndIf
	EndIf
	$AUT2EXE_DIR = StringLeft($AUT2EXE_PGM, StringInStr($AUT2EXE_PGM, "\", 0, -1))
	; check if aut2exe.exe files are all there
	;-------------------------------------------------------------------------------------------
	$AUT2EXE_PGM_N = ""
	; ensure the drive letter in part of the path to aut2exe
	; this is needed when aut2exe is specified as: "#AutoIt3Wrapper_AUT2EXE=\winutil\AutoIt3\Au3beta\aut2exe.exe"
	If FileExists($AUT2EXE_PGM) Then
		FileChangeDir($AUT2EXE_DIR)
		$AUT2EXE_DIR = @WorkingDir
		FileChangeDir($Save_Workdir)
	Else
		; Prompt for the location of AUT2EXE
		While (Not FileExists($AUT2EXE_PGM)) Or (Not FileExists($AUT2EXE_DIR & "\upx.exe"))
			If $AUT2EXE_PGM_N <> "" Then
				$msg = ""
				If Not FileExists($AUT2EXE_PGM) Then $msg = $AUT2EXE_PGM & " doesn exist." & @LF
				If Not FileExists($AUT2EXE_DIR & "\upx.exe") Then $msg = $AUT2EXE_DIR & "\upx.exe" & " doesn't exist." & @LF
				MsgBox(4096, "Error.", $msg)
			EndIf
			$AUT2EXE_PGM_N = FileOpenDialog("Select the correct directory with AUT2EXE and upx.exe ", $AUT2EXE_PGM, "aut2exe(*.*)", 1)
			If @error = 1 Then
				$rc = MsgBox(4100, "AutoIt3 Compile", "do you want to stop the process?")
				If $rc = 6 Then Exit
			EndIf
			$AUT2EXE_DIR = StringLeft($AUT2EXE_PGM_N, StringInStr($AUT2EXE_PGM_N, "\", 0, -1) - 1)
			$AUT2EXE_PGM = $AUT2EXE_DIR & "\Aut2Exe.exe"
		WEnd
	EndIf
	;get aut2exe fileversion
	;-------------------------------------------------------------------------------------------
	$AUT2EXE_PGM_VER = FileGetVersion($AUT2EXE_PGM)
	;#########################################################################################################
	; When Pragma is defined we override any other defined input from commandline of Autoit3Wrapper directives;
	;#########################################################################################################
	If $Pragma_Out <> "" Or $Pragma_Out_x64 <> "" Then
		If _VersionCompare($AUT2EXE_PGM_VER, "3.3.9.4") = 1 Then
			If $Pragma_Out <> "" Then
				$ScriptFile_Out = ""
				$ScriptFile_Out_x64 = ""
				$ScriptFile_Out_x86 = ""
				; Change the outputtype to the pragma Filename
				$ScriptFile_Out_Type = StringRight($Pragma_Out, 3)
				SetDefaults($ScriptFile_Out_Type, "exe", "", "exe;a3x", 0)
			EndIf
			$INP_Compile_Both = ""
			__ConsoleWrite("> #pragma Compile(out, YourFileName) and/or #pragma Compile(x64, true/false) found: " & @CRLF)
			__ConsoleWrite("-    Ignoring the following #AutoIt3Wrapper_#directives:" & @CRLF)
			__ConsoleWrite("-    ==> #AutoIt3Wrapper_OutFile*" & @CRLF)
			__ConsoleWrite("-    ==> #AutoIt3Wrapper_Compile_both" & @CRLF)
			If $Pragma_Out_x64 <> "" Then
				$INP_UseX64 = "N"
				__ConsoleWrite("-    ==> #AutoIt3Wrapper_UseX64" & @CRLF)
			EndIf
		Else
			$Pragma_Out = ""
			__ConsoleWrite("- Ignoring all #pragma Compile(out, YourFileName) because AutoIt3 version: " & $AUT2EXE_PGM_VER & " doesn't support it!" & @CRLF)
		EndIf
	EndIf
	;
	$LSCRIPTDIR = StringLeft($ScriptFile_In, StringInStr($ScriptFile_In, "\", 0, -1))
	; when just a file name is supplied it is assumed it's in the scriptdirectory or AutoIt ICO dir
	$AutoIt_Icon = RegRead("HKCR\AutoIt3Script\DefaultIcon", "")
	; When an ICON is specified in an INI/Commandline/Compiler directive it will check it here
	If $INP_Icon <> "" Then
		If Not StringInStr($INP_Icon, "\") Then
			$INP_Icon_Temp = $LSCRIPTDIR & $INP_Icon
			; check the scriptdir for the ICO file
			If Not FileExists($INP_Icon_Temp) Or StringInStr(FileGetAttrib($INP_Icon_Temp), "D") Then
				$AutoIt_Icon_Dir = StringLeft($AutoIt_Icon, StringInStr($AutoIt_Icon, "\", 0, -1))
				$INP_Icon_Temp = $AutoIt_Icon_Dir & $INP_Icon
				; check the AutoIt ICON dir for the ICO file
				If FileExists($INP_Icon_Temp) And StringInStr(FileGetAttrib($INP_Icon_Temp), "D") = 0 Then
					$INP_Icon = $INP_Icon_Temp
				Else
					If Not (StringRight($ScriptFile_Out, 4) = ".a3x") Then __ConsoleWrite("- Icon not found:  " & $INP_Icon & " ==> Changing to default ICON." & @CRLF)
					$INP_Icon = ""
				EndIf
			Else
				$INP_Icon = $INP_Icon_Temp
			EndIf
		Else
			If Not FileExists($INP_Icon) Then
				__ConsoleWrite("- Icon not found: " & $INP_Icon & " ==> Changing to default ICON." & @CRLF)
				$INP_Icon = ""
			EndIf
			If StringInStr(FileGetAttrib($INP_Icon), "D") Then
				__ConsoleWrite("- Icon is a Directory: " & $INP_Icon & " ==> Changing to default ICON." & @CRLF)
				$INP_Icon = ""
			EndIf
		EndIf
	EndIf
	; when icon is not specified then check if the lasticon used is valid
	If $INP_Icon = "" Then
		$INP_Icon = RegRead($Registry & "\Aut2exe", "LastIcon")
		; When LastIcon doesnt exists then use Default Icon
		If $INP_Icon <> "" And Not FileExists($INP_Icon) Then
			__ConsoleWrite("- LastUsed Icon not found: " & $INP_Icon & " ==> Changing to default ICON:" & $AutoIt_Icon & @CRLF)
			$INP_Icon = $AutoIt_Icon
		EndIf
	EndIf
	;
	; When the info doesn't come from preprocessor statements then Show progress bar
	$ProcessBar_Title = "(" & $VERSION & ") Processing : " & StringTrimLeft($ScriptFile_In, StringInStr($ScriptFile_In, "\", 0, -1))
	If $INP_ShowStatus = "y" Then ProgressOn($ProcessBar_Title, "Compile", "Starting", 50, 10, 18)
	; run process defined to be run before the compile process
	For $x = 1 To $INP_Run_Before[0]
		If StringStripWS($INP_Run_Before[$x], 3) <> "" Then
			$INP_Run_Before[$x] = Convert_Variables($INP_Run_Before[$x])
			If $INP_Run_Before_Admin[$x] Then
				__ConsoleWrite(RunReqAdminDosCommand($INP_Run_Before[$x], 0, $TempConsOut))
			Else
				__ConsoleWrite(">Running B:" & $INP_Run_Before[$x] & @CRLF)
				$Pid = Run(@ComSpec & ' /C ' & $INP_Run_Before[$x] & '', '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
				$Handle = _ProcessExitCode($Pid)
				ShowStdOutErr($Pid, 1, 0)
				$ExitCode = _ProcessExitCode($Pid, $Handle)
				_ProcessCloseHandle($Handle)
				; End process when requested through #AutoIt3Wrapper_Run_Stop_OnError  directive
				If $INP_Run_Stop_OnError = "Y" And $ExitCode Then
					__ConsoleWrite("!" & $INP_Run_Before[$x] & " Ended   rc:" & $ExitCode & @CRLF)
					Exit $ExitCode
				Else
					__ConsoleWrite(">" & $INP_Run_Before[$x] & " Ended   rc:" & $ExitCode & @CRLF)
				EndIf
			EndIf
		EndIf
	Next
	; Retrieve PreProcess again to get any updated information
	If $INP_Run_Before[0] > 0 Then
		Retrieve_PreProcessor_Info()
	EndIf
	;
	WinActivate($ProcessBar_Title)
ElseIf $Option = "AU3Check" Then
	$INP_Run_AU3Check = "y"
ElseIf $Option = "Tidy" Then
	$INP_Run_Tidy = "y"
Else                                                                 ; $Option = "Run"
	$ProcessBar_Title = "(" & $VERSION & ") Processing : " & StringTrimLeft($ScriptFile_In, StringInStr($ScriptFile_In, "\", 0, -1))
	; set AutoIt3.Exe to the AutoIt3dir specified on the commandline when supplied
	If $AutoIt3_PGM <> "" Then
		; use the autoit3.exe defined by the #autoit3wrapper_autoit3 directive
		Global $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
		_PathSplit($AutoIt3_PGM, $sDrive, $sDir, $sFileName, $sExtension)
		$CurrentAutoIt_InstallDir = $sDrive & StringTrimRight($sDir, 1)
	ElseIf $CurrentAutoIt_InstallDir <> "" And FileExists($CurrentAutoIt_InstallDir & "\autoit3.exe") Then
		If @OSArch <> "x86" And $INP_UseX64 = "y" And FileExists($CurrentAutoIt_InstallDir & "\autoit3_x64.exe") Then
			$AutoIt3_PGM = $CurrentAutoIt_InstallDir & "\autoit3_x64.exe"
		Else
			$AutoIt3_PGM = $CurrentAutoIt_InstallDir & "\autoit3.exe"
		EndIf
	Else
		If @OSArch <> "x86" And $INP_UseX64 = "y" And FileExists($CurrentAutoIt_InstallDir & "\autoit3_x64.exe") Then
			$AutoIt3_PGM = $CurrentAutoIt_InstallDir & "\autoit3_x64.exe"
		Else
			$AutoIt3_PGM = $CurrentAutoIt_InstallDir & '\autoit3.exe'
		EndIf
	EndIf
	; Check if AutoIt3 really exists
	If Not FileExists($AutoIt3_PGM) Then
		__ConsoleWrite('!>Error: program "' & $AutoIt3_PGM & '" is missing. Check your installation.' & @CRLF)
		Exit 999
	EndIf
	$AUT2EXE_PGM_VER = FileGetVersion($AutoIt3_PGM)
EndIf

#EndRegion Input retrieval/validation
#Region Fix Filenames and Includes
; -----------------------------------------
; Check filenames on Unicde characters
; -----------------------------------------
_CheckAllSourceFileNames($ScriptFile_In)
If $INP_Add_Constants = "y" Then Add_Constants()
#EndRegion Fix Filenames and Includes
#Region Run Tidy
; Run Tidy when requested.
If $Option <> "RunAdmin" And $Option <> "AU3Check" And $INP_AutoIt3Wrapper_Testing = "n" And $INP_Run_Tidy = "y" Then
	If $InputFileIsUTF16 Or $InputFileIsUTF32 Then
;~ 		__ConsoleWrite("! *************************************************************************************" & @CRLF)
		__ConsoleWrite("! Input file is UTF" & $UTFtype & " encoded. Tidy does not support this and will be skipped." & @CRLF)
;~ 		__ConsoleWrite("! *************************************************************************************" & @CRLF)
	Else
		; Clear Annotation in case there are Warnings or Errors on ptrevious run
		If RunBySciTE() Then SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "extender:dostring scite.SendEditor(SCI_ANNOTATIONCLEARALL)")
		Global $TidypgmVer = ""
		Global $Tidypgm = $SciTE_Dir & "\tidy\Tidy.exe"
		Global $Tidypgmdir
		If FileExists($Tidypgm) Then
			$Tidypgmdir = $SciTE_Dir & "\tidy"
			$TidypgmVer = FileGetVersion($Tidypgm)
			If $TidypgmVer = "0.0.0.0" Then
				$TidypgmVer = ""
			Else
				$TidypgmVer = "(" & $TidypgmVer & ")"
			EndIf
			ProgressSet(7, "Running Tidy ...")
			__ConsoleWrite(">Running Tidy " & $TidypgmVer & "  from:" & $Tidypgmdir & "  " & $ScriptFile_In & @CRLF)
			;---- uses the Beta STDOUT fuunctionality ------------------------------------------
			;$Pid = Run(@ComSpec & ' /c ""' & $Tidypgm & '" "' & $ScriptFile_In & '""', '', @SW_HIDE, 2)
			$Pid = Run('"' & $Tidypgm & '" "' & $ScriptFile_In & '" /q', '', @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
			$Handle = _ProcessExitCode($Pid)
			$Return_Text = ShowStdOutErr($Pid, 1, 1)
			$ExitCode = _ProcessExitCode($Pid, $Handle)
			_ProcessCloseHandle($Handle)
			StdioClose($Pid)
			; Show the Errors in a MSGBox
			If $ExitCode <> 0 And $ExitCode <> -1 Then
				;__ConsoleWrite(">Tidy Ended with Error(s). rc:" & $exitcode & @crlf)
				Write_RC_Console_Msg("Tidy ended.", $ExitCode)
				If RunBySciTE() Then Run('"' & @AutoItExe & '" "' & @ScriptFullPath & '" /Jump2FirstError ' & @AutoItPID)
				If $Option <> "Tidy" Then
					If $INP_Tidy_Stop_OnError = "y" And StringInStr($Return_Text, " error(s)") > 0 Then
						Exit
					EndIf
				EndIf
			Else
				If $ExitCode = -1 Then
					Write_RC_Console_Msg("Tidy ended, no changes made. ", $ExitCode)
				Else
					Write_RC_Console_Msg("Tidy ended.", $ExitCode)
					If $SourceFileNames[1][2] <> "" Then
						; copy original include filenames back into the temp file
						Global $TSourceCode = FileRead($SourceFileNames[1][2])
						;  Replace the tempfilename with the original filename
						For $x = 2 To UBound($SourceFileNames) - 1
							If $SourceFileNames[$x][2] <> "" Then
								$TSourceCode = StringReplace($TSourceCode, '"' & $SourceFileNames[$x][2] & '"', $SourceFileNames[$x][1])
							EndIf
						Next
						FileRecycle($SourceFileNames[1][0])
						FileWrite($SourceFileNames[1][0], $TSourceCode)
						ConsoleWrite("->Main script updated by AutoIt3Wrapper tempfile." & @CRLF)
					EndIf
				EndIf
			EndIf
		Else
			__ConsoleWrite("! *** Tidy Error: *** Skipping Tidy: " & $Tidypgm & " Not Found !" & @CRLF & @CRLF)
		EndIf
	EndIf
	If $Option = "Tidy" Then Exit
EndIf
#EndRegion Run Tidy
#Region Run AU3Check
; Run AU3Check when requested.
Global $TempScript
; Do not run AU3Check when option is RunAdmin as it is already run before the RunAdmin step
If $INP_Run_AU3Check = "y" And $Option <> "RunAdmin" Then
	Run_Au3Check($ScriptFile_In)
EndIf
; if AU3Check parameter was specified than stop the process.
If $Option = "AU3Check" Then Exit
#EndRegion Run AU3Check
#Region Version update before au3stripper & Compile
; Check if Version need to be incremented before Compilation
If $Option = "Compile" And ($INP_Fileversion_First_Increment = "y" Or $INP_Fileversion_Use_Template) Then
	$INP_Fileversion = Valid_FileVersion($INP_Fileversion)
	If $INP_Fileversion_Use_Template <> '' And $INP_Fileversion_AutoIncrement <> "p" Then
		$INP_Fileversion_New = $INP_Fileversion
		$INP_Fileversion = ""
	ElseIf $INP_Fileversion_AutoIncrement = "p" Then
		If $INP_AutoIt3Wrapper_Testing = "n" And MsgBox(262144 + 4096 + 4, "AutoIt3Wrappper", "Do you want to increase the version number of the source to:" & @LF & $INP_Fileversion_New, 10) = 6 Then
			$INP_Fileversion_AutoIncrement = 'y'
		Else
			$INP_Fileversion_New = $INP_Fileversion
		EndIf
	EndIf
	; Process when there is something to update
	If $INP_Fileversion_New <> "" And $INP_Fileversion <> $INP_Fileversion_New Then
		; Set the Fileversion to the new one before compilation
		$INP_Fileversion = $INP_Fileversion_New
		; Update the sourcefile
		Update_Version()
	EndIf
EndIf
#EndRegion Version update before au3stripper & Compile
#Region Run Au3Stripper
; Run Au3Stripper when requested.
;~ If $Option = "Compile" And $INP_Run_Au3Stripper = "y" And $INP_AutoIt3Wrapper_Testing = "n" And _VersionCompare($AUT2EXE_PGM_VER, "3.3.9.4") = 1 Then
;~ 	__ConsoleWrite("-> Skipping Au3Stripper: Current version doesn't support the AutoIt3 v 3.3.9.5+ syntax." & @LF)
;~ ElseIf $Option = "Compile" And $INP_Run_Au3Stripper = "y" And $INP_AutoIt3Wrapper_Testing = "n" Then
If $Option = "AU3Stripper" Or ($Option = "Compile" And $INP_Run_Au3Stripper = "y" And $INP_AutoIt3Wrapper_Testing = "n") Then
	If $InputFileIsUTF16 Or $InputFileIsUTF32 Then
;~ 		__ConsoleWrite("! *************************************************************************************" & @CRLF)
		__ConsoleWrite("! Input file is UTF" & $UTFtype & " encoded. Au3Stripper does not support this and will be skipped." & @CRLF)
;~ 		__ConsoleWrite("! *************************************************************************************" & @CRLF)
		$INP_Run_Au3Stripper = "n"
	Else
		Global $Au3StripperpgmVer = ""
		Global $Au3Stripperpgm = $SciTE_Dir & "\Au3Stripper\Au3Stripper.exe"
		Global $Au3Stripperpgmdir
		If FileExists($Au3Stripperpgm) Then
			$Au3Stripperpgmdir = $SciTE_Dir & "\Au3Stripper"
			$Au3StripperpgmVer = FileGetVersion($Au3Stripperpgm)
			If $Au3StripperpgmVer = "0.0.0.0" Then
				$Au3StripperpgmVer = ""
			Else
				$Au3StripperpgmVer = "(" & $Au3StripperpgmVer & ")"
			EndIf
			$ScriptFile_In_stripped = StringTrimRight($ScriptFile_In, StringLen($ScriptFile_In_Ext)) & '_stripped' & $ScriptFile_In_Ext
			FileDelete($ScriptFile_In_stripped)
			ProgressSet(7, "Running Au3Stripper ...")
			__ConsoleWrite(">Running Au3Stripper " & $Au3StripperpgmVer & "  from:" & $Au3Stripperpgmdir & " cmdline:" & $Au3StripperCmdLine & @CRLF)
			$Pid = Run('"' & $Au3Stripperpgm & '" "' & $ScriptFile_In & '" ' & $Au3StripperCmdLine, '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
			$Handle = _ProcessExitCode($Pid)
			$Return_Text = ShowStdOutErr($Pid)
			$ExitCode = _ProcessExitCode($Pid, $Handle)
			_ProcessCloseHandle($Handle)
			StdioClose($Pid)
			; Show the Errors in a MSGBox
			;
			If $ExitCode <> 0 And $INP_Au3Stripper_OnError = "S" Then
				Write_RC_Console_Msg("Au3Stripper ended with errors so stopping compile process.", $ExitCode)
				__DelTempFile($TempFile)
				__DelTempFile($TempScript)
				Exit $ExitCode
			ElseIf $ExitCode <> 0 And $INP_Au3Stripper_OnError = "F" Then
				Write_RC_Console_Msg("--------------------------------------------------------------------------------------------", "", "!")
				Write_RC_Console_Msg("Au3Stripper ended with errors but ForceUse defined, so using it anyway (your own risk!)", $ExitCode, "!")
				Write_RC_Console_Msg("--------------------------------------------------------------------------------------------", "", "!")
			ElseIf $ExitCode <> 0 Then
				Write_RC_Console_Msg("---------------------------------------------------------------", "", "!")
				Write_RC_Console_Msg("Au3Stripper ended with errors, using original scriptfile.", $ExitCode, "!")
				Write_RC_Console_Msg("---------------------------------------------------------------", "", "!")
				$ScriptFile_In_stripped = $ScriptFile_In
				$INP_Run_Au3Stripper = "n"
			Else
				Write_RC_Console_Msg("Au3Stripper ended.", $ExitCode)
			EndIf
			; If for whatever reason the strippedfile is missing we use the origial file.
			If Not FileExists($ScriptFile_In_stripped) Then
				Write_RC_Console_Msg("Au3Stripper outputfile missing. Using original input file.", 1)
				$ScriptFile_In_stripped = $ScriptFile_In
				$INP_Run_Au3Stripper = "n"
			EndIf
			; Run au3check on the stripped source
			If $ExitCode > -1 And $ExitCode < 999 And $INP_Run_AU3Check = "y" Then
				Run_Au3Check($ScriptFile_In_stripped)
			EndIf
		Else
			__ConsoleWrite("! *** Au3Stripper Error: *** Skipping Au3Stripper: " & $Au3Stripperpgm & " Not Found !" & @CRLF & @CRLF)
			$ScriptFile_In_stripped = $ScriptFile_In
			$INP_Run_Au3Stripper = "n"
		EndIf
		If $SourceFileNames[1][2] <> "" Then
			Global $nScriptFile_In_stripped = StringTrimRight($SourceFileNames[1][0], StringLen($ScriptFile_In_Ext)) & '_stripped' & $ScriptFile_In_Ext
			FileCopy($ScriptFile_In_stripped, $nScriptFile_In_stripped, 1)
			$ScriptFile_In_stripped = $nScriptFile_In_stripped
			ConsoleWrite("->copied stripped file back to:" & $ScriptFile_In_stripped & @CRLF)
		EndIf
		$ScriptFile_In = $ScriptFile_In_stripped
	EndIf
EndIf
#EndRegion Run Au3Stripper
#Region Compile the script
; If Compile is the option then
If $Option = "Compile" Then
	#Region Run AUT2EXE/RESUPD/UPX
	;Use the explicit x86 or x64 outputfile when specified.
	Global $TempOutFile
	If $Pragma_Out <> "" Then
		$TempOutFile = $Pragma_Out
	Else
		$TempOutFile = __TempFile($TempDir, "~AU3", "." & $ScriptFile_Out_Type)
	EndIf
	If $Pragma_UseUpx = "true" And $Pragma_Out_x64 <> "true" And _Check_Res_Updates_Defined() Then
		;Comment out the #pragma Compile(UPX, true) line to avoid problems with resource update and UPX.
		$ToTalFile = @CRLF & FileRead($ScriptFile_In)
		$H_Outf = FileOpen($ScriptFile_In, 2 + $SrceUnicodeFlag)
		$ToTalFile = StringRegExpReplace($ToTalFile, '(?i)' & @CRLF & '(\h*?#pragma\h+compile\h*\(\h*?UPX.*?\)).*?' & @CRLF, @CRLF & ';~ \1  ; Commented out by AutoIt3Wrapper to be able to do the requested resource updates' & @CRLF)
		FileWrite($H_Outf, StringMid($ToTalFile, 3))
		FileClose($H_Outf)
		$INP_UseUpx = "y"
		$Pragma_UseUpx = ""
		__ConsoleWrite('- Commented "#pragma Compile(UPX, true)" because AutoIt3Wrapper needs to do resource updates after which UPX will be ran!' & @CRLF)
	EndIf
	; Compile x86 version
	If $INP_Compile_Both = "y" Or $INP_UseX64 = 'n' Then
		Compile_Run_AUT2EXE('x86', $TempOutFile)
		If $INP_AutoIt3Wrapper_Testing <> "y" Then
			; Move the created EXE by AUT2EXE to a tempdir to be able to add the resources and UPX without conflicts
			If $Pragma_Out <> "" Then
				$TempOutFile = __TempFile($TempDir, "~AU3", "." & $ScriptFile_Out_Type)
				FileCopy($Pragma_Out, $TempOutFile, 1)
				__DelTempFile($Pragma_Out)
			EndIf
			If Compile_Upd_res($TempOutFile) And $INP_UseUpx = "y" Then
				; ########################################################################################
				; Check if Pragma is used for UPX updates and supported
				; ########################################################################################
				If $Pragma_UseUpx <> "" Then
					If _VersionCompare($AUT2EXE_PGM_VER, "3.3.9.4") = 1 Then
						__ConsoleWrite("> #pragma Compile(UPX, true/false) found." & @CRLF)
						__ConsoleWrite("-    Ignoring all #AutoIt3Wrapper_UseUPX #directive!" & @CRLF)
						$INP_Res_requestedExecutionLevel = ""
						$INP_Res_Compatibility = ""
					Else
						__ConsoleWrite("- Ignoring all #pragma Compile(UPX, true/false) because AutoIt3 version: " & $AUT2EXE_PGM_VER & " doesn't support it!" & @CRLF)
						If $INP_UseUpx = "y" Then Compile_UPX($TempOutFile)
					EndIf
				Else
					If $Pragma_UseUpx <> "" Then __ConsoleWrite("- Ignoring all #pragma Compile(UPX, true/false) because AutoIt3 version: " & $AUT2EXE_PGM_VER & " doesn't support it!" & @CRLF)
					If $INP_UseUpx = "y" Then Compile_UPX($TempOutFile)
				EndIf
			EndIf
		EndIf
		If $Pragma_Out <> "" Then
			; Move the tempfile back Use FileCopy&FileDelete to inherit the File permissions
			FileCopy($TempOutFile, $Pragma_Out, 1)
			__DelTempFile($TempOutFile)
			If FileExists($Pragma_Out) Then
				Write_RC_Console_Msg("Created program (pragma):" & $Pragma_Out, "", "+")
				$ScriptFile_Out = $Pragma_Out
			Else
				Write_RC_Console_Msg("AUT2EXE did not created program:" & $Pragma_Out, "", "!")
			EndIf
		ElseIf FileCopy($TempOutFile, $ScriptFile_Out, 1) Then
			__DelTempFile($TempOutFile)
			Write_RC_Console_Msg("Created program:" & $ScriptFile_Out, "", "+")
		Else
			Write_RC_Console_Msg("Problem copying file from: " & $TempOutFile & " To :" & $ScriptFile_Out, "", "!")
			Exit 999
		EndIf
	EndIf
	; Compile x64 version
	If $INP_Compile_Both = "y" Or $INP_UseX64 <> 'n' Then
		Compile_Run_AUT2EXE('x64', $TempOutFile)
		If $INP_AutoIt3Wrapper_Testing <> "y" Then
			; Move the created EXE by AUT2EXE to a tempdir to be able to add the resources and UPX without conflicts
			If $Pragma_Out <> "" Then
				$TempOutFile = __TempFile($TempDir, "~AU3", "." & $ScriptFile_Out_Type)
				FileCopy($Pragma_Out, $TempOutFile, 1)
				__DelTempFile($Pragma_Out)
			EndIf
			If Compile_Upd_res($TempOutFile) And $INP_UseUpx = "y" Then
				; ########################################################################################
				; Check if Pragma is used for UPX updates and supported
				; ########################################################################################
				If $Pragma_UseUpx <> "" Then
					If _VersionCompare($AUT2EXE_PGM_VER, "3.3.9.4") = 1 Then
						__ConsoleWrite("> #pragma Compile(UPX, true/false) found." & @CRLF)
						__ConsoleWrite("-    Ignoring all #AutoIt3Wrapper_UseUPX #directive!" & @CRLF)
						$INP_Res_requestedExecutionLevel = ""
						$INP_Res_Compatibility = ""
					Else
						__ConsoleWrite("- Ignoring all #pragma Compile(UPX, true/false) because AutoIt3 version: " & $AUT2EXE_PGM_VER & " doesn't support it!" & @CRLF)
						If $INP_UseUpx = "y" Then Compile_UPX($TempOutFile)
					EndIf
				Else
					If $Pragma_UseUpx <> "" Then __ConsoleWrite("- Ignoring all #pragma Compile(UPX, true/false) because AutoIt3 version: " & $AUT2EXE_PGM_VER & " doesn't support it!" & @CRLF)
					If $INP_UseUpx = "y" Then Compile_UPX($TempOutFile)
				EndIf
			EndIf
		EndIf
		If $Pragma_Out <> "" Then
			; Move the tempfile back Use FileCopy&FileDelete to inherit the File permissions
			FileCopy($TempOutFile, $Pragma_Out, 1)
			__DelTempFile($TempOutFile)
			If FileExists($Pragma_Out) Then
				Write_RC_Console_Msg("Created program (pragma):" & $Pragma_Out, "", "+")
				$ScriptFile_Out_x64 = $Pragma_Out
			Else
				Write_RC_Console_Msg("AUT2EXE did not created program:" & $Pragma_Out, "", "!")
			EndIf
		ElseIf FileCopy($TempOutFile, $ScriptFile_Out_x64, 1) Then
			__DelTempFile($TempOutFile)
			Write_RC_Console_Msg("Created program:" & $ScriptFile_Out_x64, "", "+")
		Else
			Write_RC_Console_Msg("Problem copying file from: " & $TempOutFile & " To :" & $ScriptFile_Out_x64, "", "!")
			Exit 999
		EndIf
	EndIf
	#EndRegion Run AUT2EXE/RESUPD/UPX
	#Region Run VersionWrapper
	; Check if the Version needs updating
	If $INP_Fileversion_First_Increment = "n" And $INP_Fileversion_AutoIncrement = "p" Then
		If $INP_AutoIt3Wrapper_Testing = "n" And MsgBox(262144 + 4096 + 4, "AutoIt3Wrappper", "2.Do you want to increase the version number of the source to:" & @LF & $INP_Fileversion_New, 10) = 6 Then
			$INP_Fileversion_AutoIncrement = 'y'
		Else
			$INP_Fileversion_New = $INP_Fileversion
		EndIf
	EndIf
	; run VersionWrapper
	If ($INP_Run_Versioning = 'y' Or ($INP_Run_Versioning = 'v' And $INP_Fileversion_AutoIncrement = 'y')) And $INP_AutoIt3Wrapper_Testing = "n" Then
		Versioning($ScriptFile_In_Org, Convert_Variables($INP_Versioning_Parameters, 1))
	EndIf
	#EndRegion Run VersionWrapper
	#Region Run RunAfter Steps
	WinActivate($ProcessBar_Title)
	For $x = 1 To $INP_Run_After[0]
		If StringStripWS($INP_Run_After[$x], 3) <> "" Then
			ProgressSet(95, "Running :" & $INP_Run_After[$x])
			; translate possible %..% to the actual values
			$INP_Run_After[$x] = Convert_Variables($INP_Run_After[$x])
			If $INP_Run_After_Admin[$x] Then
				__ConsoleWrite(RunReqAdminDosCommand($INP_Run_After[$x], 0, $TempConsOut))
			Else
				__ConsoleWrite(">Running A:" & $INP_Run_After[$x] & @CRLF)
				$Pid = Run(@ComSpec & ' /C ' & $INP_Run_After[$x] & '', '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
				$Handle = _ProcessExitCode($Pid)
				ShowStdOutErr($Pid)
				$ExitCode = _ProcessExitCode($Pid, $Handle)
				_ProcessCloseHandle($Handle)
				; End process when requested through #AutoIt3Wrapper_Run_Stop_OnError  directive
				If $INP_Run_Stop_OnError = "Y" And $ExitCode Then
					__ConsoleWrite("!" & $INP_Run_After[$x] & " Ended   rc:" & $ExitCode & @CRLF)
					Exit $ExitCode
				Else
					__ConsoleWrite(">" & $INP_Run_After[$x] & " Ended   rc:" & $ExitCode & @CRLF)
				EndIf
			EndIf
		EndIf
	Next
	#EndRegion Run RunAfter Steps
	#Region Update FileVersion
	;
	; Increment the #AutoIt3Wrapper_Res_Fileversion= value in the source file but only when not UTF8 wihtout BOM to avoid problems.
	If $INP_Fileversion_First_Increment = "N" And $INP_Fileversion_Use_Template = "" Then
		Update_Version()
	EndIf
	#EndRegion Update FileVersion
	;
	; update shell icons
	; $SHCNE_ASSOCCHANGED = 0x8000000
	; $SHCNF_FLUSH = 0x1000
	; $SHCNF_IDLIST = 0x0
	DllCall("shell32.dll", "none", "SHChangeNotify", "long", 0x8000000, "uint", BitOR(0x0, 0x1000), "ptr", 0, "ptr", 0)
	;
EndIf
#EndRegion Compile the script
#Region Run the Script
If $Option = "Run" Or $Option = "RunAdmin" Then
	ProgressOff()
	Run_the_Script("1")
	Exit $ExitCode                                                   ; exit with the returncode of the run script
EndIf
;
Func CTRL_BREAK_WRAPPER()
	; When the Script is running elevated, first send kill instruction
	If $Shell_RQA_Diff Then
		$rc = FileDelete($RunAdminChkFile)
		__ConsoleWrite('- Sending kill command to elevated script..' & @CRLF)
		For $x = 1 To 100
			If _ReadMessage($hMailSlot_Console) = 99 Then ExitLoop
			Sleep(10)
		Next
	EndIf
	__ConsoleWrite('! Program will be cancelled.' & @CRLF)
	Exit
EndFunc   ;==>CTRL_BREAK_WRAPPER
;
Func Run_the_Script($Init = 0)
	#forceref $Init
	; reset the filename back to the originalname and run the script
	$ScriptFile_In = $ScriptFile_In_Org
	; check if the script to run contains #requireAdmin, else skip this block
	If IsDeclared("Init") Then
		If Not $Shell_RQA_Diff Then
			__ConsoleWrite('>Running:(' & FileGetVersion($AutoIt3_PGM) & "):" & $AutoIt3_PGM & ' "' & $ScriptFile_In & '" ' & $s_CMDLine & @CRLF)
		EndIf
	Else
		If $Shell_RQA_Diff = 0 Then
			ProcessClose($Pid)
			For $x = 1 To 10
				If ProcessExists($Pid) Then
					Sleep(500)
				Else
					ExitLoop
				EndIf
			Next
		Else
			; Send kill message to elevated script
			$rc = FileDelete($RunAdminChkFile)
			__ConsoleWrite('- Sending kill command to elevated script..' & @CRLF)
			; read remaining messsage from elevated process
			For $x = 1 To 100
				If _ReadMessage($hMailSlot_Console) = 99 Then ExitLoop
				Sleep(10)
			Next
		EndIf
		Sleep(500)
		_RefreshSystemTray()
		__ConsoleWrite(@CRLF & '!Restarting :(' & FileGetVersion($AutoIt3_PGM) & "):" & $AutoIt3_PGM & ' "' & $ScriptFile_In & '" ' & $s_CMDLine & @CRLF)
	EndIf
	If Not FileExists($AutoIt3_PGM) Then
		__ConsoleWrite('!>Error: program "' & $AutoIt3_PGM & '" is missing. Check your installation.' & @CRLF)
		Exit 999
	EndIf
	$s_CMDLine = StringReplace($s_CMDLine, "/ErrorStdOut", "")
	;
	; Set hotkeys for StopExecute and Restart, but only for the Mainscript, not RunAdmin level scripts
	Local $hk1rc = 0
	Local $hk2rc = 0

	; Test Set hotkeys for StopExecute and Restart to see whether they will function later in ShowStdOutErr() and show the console info
	Local $INP_HotKey_Stop = IniRead($AutoIt3WapperIni, "Other", "SciTE_STOPEXECUTE", '^{BREAK}')
	Local $INP_HotKey_Restart = IniRead($AutoIt3WapperIni, "Other", "SciTE_RESTART", '^!{BREAK}')
	$hk1rc = HotKeySet($INP_HotKey_Stop, 'CTRL_BREAK_WRAPPER')
	$hk2rc = HotKeySet($INP_HotKey_Restart, 'Run_the_Script')
	Local $sSTOP = ''
	If $RunBySciTE And $hk1rc Then $sSTOP = (($INP_HotKey_Stop = '^{BREAK}') ? '^Break' : '^Break -or- ')
	$sSTOP = $INP_HotKey_Stop
	$sSTOP = StringReplace($sSTOP, "+", "Shift+")
	$sSTOP = StringReplace($sSTOP, "^", "Ctrl+")
	$sSTOP = StringReplace($sSTOP, "!", "Alt+")
	$sSTOP = StringReplace($sSTOP, "#", "Win+")
	$sSTOP = StringReplace($sSTOP, "{", "")
	$sSTOP = StringReplace($sSTOP, "}", "")
	Local $sRestart = ''
	If $hk2rc Then $sRestart = (($INP_HotKey_Restart = '^!{BREAK}') ? '^!Break' : $INP_HotKey_Restart)
	$sRestart = StringReplace($sRestart, "+", "Shift+")
	$sRestart = StringReplace($sRestart, "^", "Ctrl+")
	$sRestart = StringReplace($sRestart, "!", "Alt+")
	$sRestart = StringReplace($sRestart, "#", "Win+")
	$sRestart = StringReplace($sRestart, "{", "")
	$sRestart = StringReplace($sRestart, "}", "")
	; Disable Hotkeys untill they are set in ShowStdOutErr() when the Editor has the focus
	HotKeySet($INP_HotKey_Stop)
	HotKeySet($INP_HotKey_Restart)

	;
	;Add debug statements
	Local $sDebugFile = ""
	;
	; Run your script
	If $Shell_RQA_Diff And Not IsAdmin() Then
		__ConsoleWrite(($hk1rc And $hk2rc ? "+>Setting Hotkeys..." : "!>Failed Setting Hotkey(s)..."))
		__ConsoleWrite(($hk1rc ? '--> Press ' & $sRestart & ' to Restart or ' : '--> SetHotKey Restart failed, '))
		__ConsoleWrite(($hk2rc ? $sSTOP & ' to Stop.' & @CRLF : 'SetHotKey Stop failed.' & @CRLF))
		RestartReqAdmin()
	Else
		; Only offer the restart/kill option for none elevated scripts
		If $Option <> "RunAdmin" Then
			__ConsoleWrite(($hk1rc And $hk2rc ? "+>Setting Hotkeys..." : "!>Failed Setting Hotkey(s)..."))
			__ConsoleWrite(($hk1rc ? '--> Press ' & $sRestart & ' to Restart or ' : '--> SetHotKey Restart failed, '))
			__ConsoleWrite(($hk2rc ? $sSTOP & ' to Stop.' & @CRLF : 'SetHotKey Stop failed.' & @CRLF))
		Else
			; Allow for the main AutoIt3Wrapper to kill this evevated script)
			AdlibRegister("CheckInterrupt")
		EndIf
		;
		If $INP_Run_SciTE_Minimized = "y" Then
			WinSetState("[CLASS:SciTEWindow]", "", @SW_MINIMIZE)
		EndIf
		; Check for Debugmode.
		If $INP_Run_SciTE_OutputPane_Minimized = "y" Then
			SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "menucommand:409") ; IDM_TOGGLEOUTPUT
		EndIf

		If $INP_Run_Debug_Mode Then
			__ConsoleWrite('!> Starting in DebugMode..' & @CRLF)
			__ConsoleWrite('Line: @error-@extended: Line syntax' & @CRLF)
			RunAutoItDebug($ScriptFile_In, $sDebugFile)
			; Run your script in debug mode
			$Pid = Run('"' & $AutoIt3_PGM & '" /ErrorStdOut "' & $sDebugFile & '" ' & $s_CMDLine, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		Else
			$Pid = Run('"' & $AutoIt3_PGM & '" /ErrorStdOut "' & $ScriptFile_In & '" ' & $s_CMDLine, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		EndIf
		; Run second version as Watcher to kill this The running AutoItscript when AutoIt3Wrapper is killed.
		Run('"' & @AutoItExe & '" "' & @ScriptFullPath & '" /Watcher ' & @AutoItPID & " " & $Pid)
		$Handle = _ProcessExitCode($Pid)
		ShowStdOutErr($Pid, 1, 0, "", WinGetHandle("[ACTIVE]"), $INP_HotKey_Stop, $INP_HotKey_Restart)
		$ExitCode = _ProcessExitCode($Pid, $Handle)
		_ProcessCloseHandle($Handle)
		Write_RC_Console_Msg("AutoIt3.exe ended.", $ExitCode)
	EndIf
	;
	If $INP_Run_Debug_Mode Then FileRecycle($sDebugFile)
	;
	If $INP_Run_SciTE_Minimized = "y" Then
		WinSetState("[CLASS:SciTEWindow]", "", @SW_RESTORE)
	EndIf
	;
EndFunc   ;==>Run_the_Script
#EndRegion Run the Script
#Region End AutoIt3Wrapper
; End of the program
ProgressOff()
; Done
Exit
#EndRegion End AutoIt3Wrapper
#Region Functions
;
; Show UTF characters in a proper way with ConsoleWrite
; Author: jchd
Func __ConsoleWrite($s)
	ConsoleWrite(BinaryToString(StringToBinary($s, 4), 1))
	Local $UseMailSlot = StringInStr($CMDLINERAW, "/RunAdmin") <> 0
	If $s <> "" And $UseMailSlot Then
		_MailSlotWrite($sMailSlotConsole, BinaryToString(StringToBinary($s, 4), 1)) ;Used when shelled script uses #requireAdmin
	EndIf
EndFunc   ;==>__ConsoleWrite
; this deletes the files created with the __TempFile
Func __DelTempFile($Filename)
	If $Filename = "" Then
		Return
	EndIf
	Local $Filename2 = StringLeft($Filename, StringInStr($Filename, ".", 0, -1) - 1)
	For $x = 1 To 10
		If FileExists($Filename) Then
			FileDelete($Filename)
		EndIf
		If FileExists($Filename2) Then
			FileDelete($Filename2)
		EndIf
		If Not FileExists($Filename) And Not FileExists($Filename2) Then
			Return
		EndIf
		Sleep(200)
	Next
EndFunc   ;==>__DelTempFile
;
; this change is to ensure the file really is unique and none existent
Func __TempFile($sDirectoryName = @TempDir, $sFilePrefix = "~", $sFileExtension = ".tmp", $iRandomLength = 7)
	#forceref $iRandomLength
	$iRandomLength = 0                                               ; just there for backward compatibility
	; his will create 2 files but this is to avoid same name when ran multiple times
	Local $TempFile = _WinAPI_GetTempFileName($sDirectoryName, $sFilePrefix)
	If $sFileExtension <> ".tmp" Then
		FileCopy($TempFile, $TempFile & $sFileExtension, 1)
	Else
		$sFileExtension = ""
	EndIf
	Return $TempFile & $sFileExtension
EndFunc   ;==>__TempFile
;
Func _appendFileExtraData($fname, ByRef $extraData, ByRef $dwSize)
	Local $bytesWritten = 0
	If Not IsDllStruct($extraData) Or $dwSize = 0 Then Return SetError(1, 0, 0)
	Local $pextraData = DllStructGetPtr($extraData)
	Local $hFile = _WinAPI_CreateFile($fname, 2, 4)                  ; open for writing
	If Not $hFile Then Return SetError(2, 0, 0)
	Local $pos = _WinAPI_SetFilePointer($hFile, 0, 2)                ; set pointer to end of file
	If @error Or $pos = -1 Then
		_WinAPI_CloseHandle($hFile)
		Return SetError(3, 0, 0)
	EndIf
	Local $ret = _WinAPI_WriteFile($hFile, $pextraData, $dwSize, $bytesWritten, 0) ; write the extra data
	_WinAPI_CloseHandle($hFile)
	$extraData = 0                                                   ; release extra data
	If Not $ret Or $bytesWritten <> $dwSize Then Return SetError(4, 0, 0)
	Return 1
EndFunc   ;==>_appendFileExtraData
;
;Check if ResUpdates need to be performed
Func _Check_Res_Updates_Defined($type = 0)
	Local $INP_Resource = 0
	Local $INP_Resource_Version = 0
	;-------------------------------------------------------------------------------------------
	; check if VERSION resource update is required
	If $INP_RES_HiDpi <> "n" Then $INP_Resource = 1
	;
	If $INP_Comment & $INP_Description & $INP_Fileversion & $INP_ProductName & $INP_ProductVersion & $INP_LegalCopyright & $INP_CompanyName & $INP_LegalTradeMarks <> "" _
			Or $INP_Res_FieldCount > 0 _
			Or $INP_FieldValue1 & $INP_FieldValue2 <> "" _
			Or ($INP_Res_Language <> "" And $INP_Res_Language <> "2057") Then
		$INP_Resource_Version = 1
		$INP_Resource = 1
	EndIf
	If $type = 1 Then Return $INP_Resource_Version
	; check if other resources updates are required
	If $INP_Icons_cnt > 0 Or $INP_Cursors_cnt > 0 Or $INP_Res_Files_Cnt > 0 _
			Or $INP_Res_SaveSource = "y" _
			Or $INP_Res_requestedExecutionLevel <> "" _
			Or $INP_Res_Compatibility <> "" Then
		$INP_Resource = 1
	EndIf
	Return $INP_Resource
EndFunc   ;==>_Check_Res_Updates_Defined
;Helper function to compare the Version dates
Func _Compare_Date_GT($date1, $Date2)
	Local $Id1 = StringSplit($date1, "/")
	Local $Id2 = StringSplit($Date2, "/")
	ReDim $Id1[4]
	ReDim $Id2[4]
	$date1 = $Id1[3] & "/" & $Id1[1] & "/" & $Id1[2]
	$Date2 = $Id2[3] & "/" & $Id2[1] & "/" & $Id2[2]
	If Not _DateIsValid($date1) Then Return 0
	If Not _DateIsValid($Date2) Then Return 0
	Return _DateDiff("d", $Date2, $date1)
EndFunc   ;==>_Compare_Date_GT
;
Func _EnumResourceNamesAndLangs($fname, $RType)
	; reset content of the Array
	Dim $g_aResNamesAndLangs[1][2] = [[0, 0]]
	; enumerate resource names and languages to a global array
	Local $RType_Type
	; did we really get a number?
	If StringIsDigit($RType) Then $RType = Number($RType)
	; check for known resource types and convert to ordinal
	If IsString($RType) Then
		If StringLeft($RType, 3) <> 'RT_' Then $RType = 'RT_' & $RType
		For $k = 0 To UBound($aRESOURCE_TYPES) - 1
			If $RType = $aRESOURCE_TYPES[$k] Then
				$RType = $k + 1
				$RType_Type = "long"
			EndIf
		Next
	EndIf
	; set parameter types
	If IsString($RType) Then
		$RType_Type = "wstr"
		$RType = StringReplace(StringUpper($RType), "RT_", "")
	Else
		$RType_Type = "long"
	EndIf
	; load the file
	Local $hModule = _WinAPI_LoadLibraryEx($fname, 0x22)             ; LOAD_LIBRARY_AS_DATAFILE|LOAD_LIBRARY_AS_IMAGE_RESOURCE
	If @error Then
		Local $terror = @error
		Local $textended = @extended
		Write_RC_Console_Msg("WinAPI_GetLastError:" & _WinAPI_GetLastError(), "", "!")
		Write_RC_Console_Msg("WinAPI_GetLastErrorMessage:" & _WinAPI_GetLastErrorMessage(), "", "!")
		Write_RC_Console_Msg("Error: Failed _WinAPI_LoadLibraryEx   error:" & $terror & "   extended:" & $textended, "", "!")
	EndIf
	If Not $hModule Then Return SetError(1, 0, 0)
	; register callbacks
	Local $hNameCallback = DllCallbackRegister("_ResNameCallback", "int", "ptr;ptr;ptr;long_ptr")
	$hLangCallback = DllCallbackRegister("_ResLangCallback", "int", "ptr;ptr;ptr;ushort;long_ptr")
	; enum the names
	DllCall("kernel32.dll", "int", "EnumResourceNamesW", "ptr", $hModule, $RType_Type, $RType, "ptr", DllCallbackGetPtr($hNameCallback), "long_ptr", 0)
	; free resources
	_WinAPI_FreeLibrary($hModule)
	DllCallbackFree($hNameCallback)
	DllCallbackFree($hLangCallback)
	Return 1
EndFunc   ;==>_EnumResourceNamesAndLangs
;
Func _FIELD_OFFSET(ByRef $s, $element)
	If (Not IsDllStruct($s)) Or (Not IsString($element)) Then Return SetError(1, 0, 0)
	Local $s_ptr = DllStructGetPtr($s, 1)                            ; ptr to first byte of struct
	If @error Then Return SetError(2, 0, 0)
	Local $f_ptr = DllStructGetPtr($s, $element)                     ; ptr to first byte of element
	If @error Then Return SetError(3, 0, 0)
	Return Number($f_ptr - $s_ptr)                                   ; offset of element in struct
EndFunc   ;==>_FIELD_OFFSET
;
Func _GetBlockIDIdx(ByRef $aBlocks, $iBlock)
	Local $aBlock
	For $i = 1 To $aBlocks[0]
		$aBlock = $aBlocks[$i]
		If $aBlock[0] = $iBlock Then
			; found the block
			Return $i
		EndIf
	Next
	Return -1
EndFunc   ;==>_GetBlockIDIdx
;
Func _getFileExtraData($fname, ByRef $extraData, ByRef $dwSize)
	; get target file as binary struct
	Local $hFile = FileOpen($fname, 16)
	If $hFile = -1 Then Return SetError(1, 0, 0)
	Local $bin = FileRead($hFile)
	FileClose($hFile)
	Local $dataSize = BinaryLen($bin)
	Local $sdata = DllStructCreate("byte[" & $dataSize & "]")
	Local $data = DllStructGetPtr($sdata)                            ; ptr to data
	DllStructSetData($sdata, 1, $bin)
	; read the DOS header to make sure we have a valid file
	Local $dos_header = DllStructCreate($tagIMAGE_DOS_HEADER, $data)
	If DllStructGetData($dos_header, "emagic") <> $IMAGE_DOS_SIGNATURE Then
		__ConsoleWrite("Not a valid executable file." & @CRLF)
		Return SetError(2, 0, 0)
	EndIf
	; parse sections to calculate real data size
	Local $endOfImage = 0
	Local $psec = _IMAGE_FIRST_SECTION(DllStructGetPtr($dos_header) + DllStructGetData($dos_header, "elfanew")) ; ptr to first section
	Local $section = DllStructCreate($tagIMAGE_SECTION_HEADER, $psec) ; SECTION header
	Local $headers = DllStructCreate($tagIMAGE_NT_HEADERS, DllStructGetPtr($dos_header) + DllStructGetData($dos_header, "elfanew")) ; NT header
	Local $pRawData, $sizeRawData
	; loop through sections to get the end of image
	For $i = 0 To DllStructGetData($headers, "NumberOfSections") - 1
		$pRawData = DllStructGetData($section, "PointerToRawData")
		$sizeRawData = DllStructGetData($section, "SizeOfRawData")
		If $endOfImage < ($pRawData + $sizeRawData) Then _
				$endOfImage = $pRawData + $sizeRawData
		; get next section
		$psec += DllStructGetSize($section)
		$section = DllStructCreate($tagIMAGE_SECTION_HEADER, $psec)
	Next
	; copy extra data
	If $dataSize > $endOfImage Then
		; for some reason, SizeOfImage has a value that doesn't work for us, so we us the binary data length
		$dwSize = $dataSize - $endOfImage
		$extraData = DllStructCreate("byte[" & $dwSize & "]")
		; ptr to end of image - extra data
		_memcpy(DllStructGetPtr($extraData), $data + $endOfImage, $dwSize)
	Else
		Return SetError(3, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_getFileExtraData
;; #define IMAGE_FIRST_SECTION( ntheader ) ((PIMAGE_SECTION_HEADER)       \
;;    ((ULONG_PTR)ntheader +                                              \
;;     FIELD_OFFSET( IMAGE_NT_HEADERS, OptionalHeader ) +                 \
;;     ((PIMAGE_NT_HEADERS)(ntheader))->FileHeader.SizeOfOptionalHeader   \
;;    ))
Func _IMAGE_FIRST_SECTION($h)
	Local $header = DllStructCreate($tagIMAGE_NT_HEADERS, $h)
	; _FIELD_OFFSET of OptionalHeader ('Magic' field) in IMAGE_NT_HEADERS stucture = 24
	Return ($h + _FIELD_OFFSET($header, "Magic") + DllStructGetData($header, "SizeOfOptionalHeader"))
EndFunc   ;==>_IMAGE_FIRST_SECTION
;
Func _memcpy($dest, $src, $size)
	Local $ret = DllCall("msvcrt.dll", "ptr:cdecl", "memcpy", "ptr", $dest, "ptr", $src, "uint", $size)
	Return $ret[0]
EndFunc   ;==>_memcpy
;
Func _ProcessCloseHandle($h_Process)
	; Close the process handle of a PID
	DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $h_Process)
	If Not @error Then Return 1
	Return 0
EndFunc   ;==>_ProcessCloseHandle
;===============================================================================
;
; Function Name:    _ProcessExitCode()
; Description:      Returns a handle/exitcode from use of Run().
; Parameter(s):     $i_Pid        - ProcessID returned from a Run() execution
;                   $h_Process    - Process handle
; Requirement(s):   None
; Return Value(s):  On Success - Returns Process handle while Run() is executing
;                                (use above directly after Run() line with only PID parameter)
;                              - Returns Process Exitcode when Process does not exist
;                                (use above with PID and Process Handle parameter returned from first UDF call)
;                   On Failure - 0
; Author(s):        MHz (Thanks to DaveF for posting these DllCalls in Support Forum)
;
;===============================================================================
;
Func _ProcessExitCode($i_Pid, $h_Process = 0)
	; 0 = Return Process Handle of PID else use Handle to Return Exitcode of a PID
	Local $v_Placeholder
	If Not IsArray($h_Process) Then
		; Return the process handle of a PID
		$h_Process = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'int', 0x400, 'int', 0, 'int', $i_Pid)
		If Not @error Then Return $h_Process
	Else
		; Return Process Exitcode of PID
		$h_Process = DllCall('kernel32.dll', 'ptr', 'GetExitCodeProcess', 'ptr', $h_Process[0], 'int*', $v_Placeholder)
		If Not @error Then Return $h_Process[2]
	EndIf
	Return 0
EndFunc   ;==>_ProcessExitCode
;
; Removes any dead icons from the notification area.
; Parameters:
;    $nDelay - IN/OPTIONAL - The delay to wait for the notification area to expand with Windows XP's
;        "Hide Inactive Icons" feature (In milliseconds).
; Returns:
;    Sets @error on failure:
;        1 - Tray couldn't be found.
;        2 - DllCall error.
; ===================================================================
Func _RefreshSystemTray()
	; Save Opt settings
	Local $oldMatchMode = Opt("WinTitleMatchMode", 4)
	Local $oldChildMode = Opt("WinSearchChildren", 1)
	Local $error = 0
	Do                                                               ; Pseudo loop
		Local $HWindow = WinGetHandle("classname=TrayNotifyWnd")     ; Old
		If @error Then
			$error = 1
			ExitLoop
		EndIf
		; move mouse over trayicons in one pass
		Sleep(100)
		Local $posStart = MouseGetPos()
		Local $posWin = WinGetPos($HWindow)
		Local $y = $posWin[1] + 16
		Local $x = $posWin[0]
		While $x < $posWin[2] + $posWin[0]
			DllCall("user32.dll", "int", "SetCursorPos", "int", $x, "int", $y)
			Sleep(10)                                                ; sleep is required to make it work
			If @error Then
				$error = 2
				ExitLoop 2                                           ; Jump out of While/While/Do
			EndIf
			$x = $x + 8
		WEnd
		DllCall("user32.dll", "int", "SetCursorPos", "int", $posStart[0], "int", $posStart[1])
	Until 1
	; Restore Opt settings
	Opt("WinTitleMatchMode", $oldMatchMode)
	Opt("WinSearchChildren", $oldChildMode)
	SetError($error)
EndFunc   ;==>_RefreshSystemTray
;
Func _Res_Create_RTVersion(ByRef $OutResPath)
	; construct the Stringtable Entries in a Binary string for easy concatenation
	Local $Res_StringTable_Children = "0x"
;~ 	$Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry("CompiledScript", $INP_CompiledScript)
	$Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry("FileVersion", $INP_Fileversion)
	If $INP_Comment <> "" Then $Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry("Comments", $INP_Comment)
	If $INP_Description <> "" Then $Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry("FileDescription", $INP_Description)
	If $INP_ProductName <> "" Then $Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry("ProductName", $INP_ProductName)
	If $INP_ProductVersion <> "" Then $Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry("ProductVersion", $INP_ProductVersion)
	If $INP_CompanyName <> "" Then $Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry("CompanyName", $INP_CompanyName)
	If $INP_LegalCopyright <> "" Then $Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry("LegalCopyright", $INP_LegalCopyright)
	If $INP_LegalTradeMarks <> "" Then $Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry("LegalTradeMarks", $INP_LegalTradeMarks)
	If $INP_FieldName1 & $INP_FieldValue1 <> "" Then $Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry($INP_FieldName1, $INP_FieldValue1)
	If $INP_FieldName2 & $INP_FieldValue2 <> "" Then $Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry($INP_FieldName2, $INP_FieldValue2)
	For $U = 1 To $INP_Res_FieldCount
		If $INP_FieldName[$U] <> "" And $INP_FieldValue[$U] <> "" Then
			$INP_FieldValue[$U] = Convert_Variables($INP_FieldValue[$U])
			$Res_StringTable_Children &= _Res_Create_RTVersion_BuildStringTableEntry($INP_FieldName[$U], $INP_FieldValue[$U])
		EndIf
	Next
	;
	; construct the Stringtable
	Local $p_VS_StringTable = DllStructCreate( _
			"short   wLength;" & _                                   ;Specifies the length, in bytes, of this StringTable structure, including all structures indicated by the Children member.
			"short   wValueLength;" & _                              ;This member is always equal to zero.
			"short   wType;" & _                                     ;Specifies the type of data in the version resource. This member is 1 if the version resource contains text data and 0 if the version resource contains binary data.
			"byte    szKey[16];" & _                                 ;Specifies an 8-digit hexadecimal number stored as a Unicode string. The four most significant digits represent the language identifier. The four least significant digits represent the code page for which the data is formatted. Each Microsoft Standard Language identifier contains two parts: the low-order 10 bits specify the major language, and the high-order 6 bits specify the sublanguage. For a table of valid identifiers see .
			"byte    Padding[2];" & _                                ;Contains as many zero words as necessary to align the Children member on a 32-bit boundary.
			"byte    Children[" & (StringLen($Res_StringTable_Children) - 2) / 2 & "]") ;Specifies an array of one or more String structures.
	DllStructSetData($p_VS_StringTable, "Wlength", DllStructGetSize($p_VS_StringTable))
	DllStructSetData($p_VS_StringTable, "wValueLength", 0)
	DllStructSetData($p_VS_StringTable, "wType", 1)
	DllStructSetData($p_VS_StringTable, "szKey", StringToBinary(Hex($INP_Res_Language, 4) & '04b0', 2))
	DllStructSetData($p_VS_StringTable, "Children", Binary($Res_StringTable_Children))
	;
	; construct the StringFileInfo
	Local $p_VS_StringFileInfo = DllStructCreate( _
			"short  wLength;" & _                                    ;Specifies the length, in bytes, of the entire StringFileInfo block, including all structures indicated by the Children member.
			"short  wValueLength;" & _                               ;This member is always equal to zero.
			"short  wType;" & _                                      ;Specifies the type of data in the version resource. This member is 1 if the version resource contains text data and 0 if the version resource contains binary data.
			"WCHAR  szKey[15];" & _                                  ;Contains the Unicode string "StringFileInfo".
			"byte   Children[" & DllStructGetSize($p_VS_StringTable) & "]") ;Contains an array of one or mcore StringTable structures. Each StringTable structure's szKey member indicates the appropriate language and code page for displaying the text in that StringTable structure.
	DllStructSetData($p_VS_StringFileInfo, "Wlength", DllStructGetSize($p_VS_StringFileInfo))
	DllStructSetData($p_VS_StringFileInfo, "wValueLength", 0)
	DllStructSetData($p_VS_StringFileInfo, "wType", 1)
	DllStructSetData($p_VS_StringFileInfo, "szKey", "StringFileInfo")
	Local $p_VS_StringTable_Total = DllStructCreate("byte Children[" & DllStructGetSize($p_VS_StringTable) & "]", DllStructGetPtr($p_VS_StringTable))
	DllStructSetData($p_VS_StringFileInfo, "Children", DllStructGetData($p_VS_StringTable_Total, 1))
	;
	; construct the Var
	Local $p_VS_Var = DllStructCreate( _
			"short  wLength;" & _                                    ;Specifies the length, in bytes, of the Var structure.
			"short  wValueLength;" & _                               ;Specifies the length, in bytes, of the Value member.
			"short  wType;" & _                                      ;Specifies the type of data in the version resource. This member is 1 if the version resource contains text data and 0 if the version resource contains binary data.
			"WCHAR  szKey[12];" & _                                  ;Contains the Unicode string "Translation".
			"char  Padding[1];" & _                                  ;Contains as many zero words as necessary to align the Value member on a 32-bit boundary.
			"short  lang;" & _                                       ;Specifies an array of one or more values that are language and code page identifier pairs. For additional information, see the following Remarks section.
			"short  lang2")                                          ;Specifies an array of one or more values that are language and code page identifier pairs. For additional information, see the following Remarks section.
	DllStructSetData($p_VS_Var, "Wlength", DllStructGetSize($p_VS_Var))
	DllStructSetData($p_VS_Var, "wValueLength", 4)
	DllStructSetData($p_VS_Var, "wType", 0)
	DllStructSetData($p_VS_Var, "szKey", "Translation")
	DllStructSetData($p_VS_Var, "lang", $INP_Res_Language)
	DllStructSetData($p_VS_Var, "lang2", 0x04B0)
	;
	; construct the VarFileInfo
	Local $p_VS_VarFileInfo = DllStructCreate( _
			"short  wLength;" & _                                    ;Specifies the length, in bytes, of the entire VarFileInfo block, including all structures indicated by the Children member.
			"short  wValueLength;" & _                               ;This member is always equal to zero.
			"short  wType;" & _                                      ;Specifies the type of data in the version resource. This member is 1 if the version resource contains text data and 0 if the version resource contains binary data.
			"WCHAR szKey[12];" & _                                   ;Contains the Unicode string "VarFileInfo".
			"char  Padding[2];" & _                                  ;Contains as many zero words as necessary to align the Value member on a 32-bit boundary.
			"Byte   Children[" & DllStructGetSize($p_VS_Var) & "]")  ;Specifies a Var structure that typically contains a list of languages that the application or DLL supports.
	DllStructSetData($p_VS_VarFileInfo, "Wlength", DllStructGetSize($p_VS_VarFileInfo))
	DllStructSetData($p_VS_VarFileInfo, "wValueLength", 0)
	DllStructSetData($p_VS_VarFileInfo, "wType", 1)
	DllStructSetData($p_VS_VarFileInfo, "szKey", "VarFileInfo")
	Local $p_VS_Var_Total = DllStructCreate("byte Children[" & DllStructGetSize($p_VS_Var) & "]", DllStructGetPtr($p_VS_Var))
	DllStructSetData($p_VS_VarFileInfo, "Children", DllStructGetData($p_VS_Var_Total, 1))
	;
	; construct the FIXEDFILEINFO
	Local $p_VS_FIXEDFILEINFO = DllStructCreate( _
			"DWORD dwSignature;" & _
			"DWORD dwStrucVersion;" & _
			"DWORD dwFileVersionMS;" & _
			"DWORD dwFileVersionLS;" & _
			"DWORD dwProductVersionMS;" & _
			"DWORD dwProductVersionLS;" & _
			"DWORD dwFileFlagsMask;" & _
			"DWORD dwFileFlags;" & _
			"DWORD dwFileOS;" & _
			"DWORD dwFileType;" & _
			"DWORD dwFileSubtype;" & _
			"DWORD dwFileDateMS;" & _
			"DWORD dwFileDateLS")
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwSignature", 0xFEEF04BD)
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwStrucVersion", 0x00010000)
	$INP_Fileversion = Valid_FileVersion($INP_Fileversion)
	Local $tFileversion = StringSplit($INP_Fileversion, ".")
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwFileVersionMS", Number("0x" & Hex($tFileversion[1], 4) & Hex($tFileversion[2], 4)))
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwFileVersionLS", Number("0x" & Hex($tFileversion[3], 4) & Hex($tFileversion[4], 4)))
	$INP_ProductVersion = Valid_FileVersion($INP_ProductVersion, 0)
	$tFileversion = StringSplit($INP_ProductVersion, ".")
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwProductVersionMS", Number("0x" & Hex($tFileversion[1], 4) & Hex($tFileversion[2], 4)))
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwProductVersionLS", Number("0x" & Hex($tFileversion[3], 4) & Hex($tFileversion[4], 4)))
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwFileFlagsMask", 0)
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwFileFlags", 0)
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwFileOS", 0x00004)
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwFileType", 0)
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwFileSubtype", 0)
	DllStructSetData($p_VS_FIXEDFILEINFO, "dwFileDateLS", 0)
	;
	; construct the Final VERSIONINFO
	Local $p_VS_VERSIONINFO = DllStructCreate( _
			"short  wLength;" & _                                    ;Specifies the length, in bytes, of the VS_VERSIONINFO structure. This length does not include any padding that aligns any subsequent version resource data on a 32-bit boundary.
			"short  wValueLength;" & _                               ;Specifies the length, in bytes, of the Value member. This value is zero if there is no Value member associated with the current version structure.
			"short  wType;" & _                                      ;Specifies the type of data in the version resource. This member is 1 if the version resource contains text data and 0 if the version resource contains binary data.
			"wchar  szKey[16];" & _                                  ;Contains the Unicode string "VS_VERSION_INFO".
			"wchar  Padding1[1];" & _                                ;Contains as many zero words as necessary to align the Value member on a 32-bit boundary.
			"byte   value[" & DllStructGetSize($p_VS_FIXEDFILEINFO) & "];" & _ ;Contains a VS_FIXEDFILEINFO structure that specifies arbitrary data associated with this VS_VERSIONINFO structure. The wValueLength member specifies the length of this member; if wValueLength is zero, this member does not exist.
			"byte   Children[" & DllStructGetSize($p_VS_StringFileInfo) & "];" & _ ;Specifies an array of zero or one StringFileInfo structures, and
			"byte   Children2[" & DllStructGetSize($p_VS_VarFileInfo) & "]") ;          zero or one VarFileInfo structures that are children of the current VS_VERSIONINFO structure.
	DllStructSetData($p_VS_VERSIONINFO, "Wlength", DllStructGetSize($p_VS_VERSIONINFO))
	DllStructSetData($p_VS_VERSIONINFO, "wValueLength", DllStructGetSize($p_VS_FIXEDFILEINFO))
	DllStructSetData($p_VS_VERSIONINFO, "wType", 0)
	DllStructSetData($p_VS_VERSIONINFO, "szKey", "VS_VERSION_INFO")
	; Add the VS_FIXEDFILEINFO structure
	Local $p_VS_FIXEDFILEINFO_Total = DllStructCreate("byte Children[" & DllStructGetSize($p_VS_FIXEDFILEINFO) & "]", DllStructGetPtr($p_VS_FIXEDFILEINFO))
	DllStructSetData($p_VS_VERSIONINFO, "value", DllStructGetData($p_VS_FIXEDFILEINFO_Total, 1))
	; Add the VS_StringFileInfo structure
	Local $p_VS_StringFileInfo_Total = DllStructCreate("byte Children[" & DllStructGetSize($p_VS_StringFileInfo) & "]", DllStructGetPtr($p_VS_StringFileInfo))
	DllStructSetData($p_VS_VERSIONINFO, "Children", DllStructGetData($p_VS_StringFileInfo_Total, 1))
	; Add the VarFileInfo structure
	Local $p_VS_VarFileInfo_Total = DllStructCreate("byte Children[" & DllStructGetSize($p_VS_VarFileInfo) & "]", DllStructGetPtr($p_VS_VarFileInfo))
	DllStructSetData($p_VS_VERSIONINFO, "Children2", DllStructGetData($p_VS_VarFileInfo_Total, 1))
	; Write the Whole structure to a RES file
	Local $p_VS_VERSIONINFO_Total = DllStructCreate("byte Children[" & DllStructGetSize($p_VS_VERSIONINFO) & "]", DllStructGetPtr($p_VS_VERSIONINFO))
	#forceref $OutResPath
	If $OutResPath = "" Then $OutResPath = __TempFile($TempDir, "~", ".res")
	Local $Fh = FileOpen($OutResPath, 2 + 16)
	FileWrite($Fh, DllStructGetData($p_VS_VERSIONINFO_Total, 1))
	FileClose($Fh)
EndFunc   ;==>_Res_Create_RTVersion
;
Func _Res_Create_RTVersion_BuildStringTableEntry($Key, $value)
	Local $padding = 1 - Mod(6 + StringLen($Key) + 1, 2)
	Local $padding2 = 1 - Mod(6 + StringLen($Key) + 1 + $padding + StringLen($value) + 1, 2)
	Local $p_VS_String = DllStructCreate( _
			"short   wLength;" & _                                   ;Specifies the length, in bytes, of this String structure.
			"short   wValueLength;" & _                              ;Specifies the size, in words, of the Value member.
			"short   wType;" & _                                     ;Specifies the type of data in the version resource. This member is 1 if the version resource contains text data and 0 if the version resource contains binary data.
			"wchar   szKey[" & StringLen($Key) + 1 + $padding & "];" & _ ;Specifies an arbitrary Unicode string. The szKey member can be one or more of the following values. These values are guidelines only.
			"wchar   Value[" & StringLen($value) + 1 + $padding2 & "]") ;Specifies a zero-terminated string. See the szKey member description for more information.
	DllStructSetData($p_VS_String, "Wlength", DllStructGetSize($p_VS_String) - $padding2 * 2)
	DllStructSetData($p_VS_String, "wValueLength", StringLen($value) + 1)
	DllStructSetData($p_VS_String, "wType", 1)
	DllStructSetData($p_VS_String, "szKey", $Key)
	DllStructSetData($p_VS_String, "Value", $value)
	Return StringMid(DllStructGetData(DllStructCreate("byte[" & DllStructGetSize($p_VS_String) & "]", DllStructGetPtr($p_VS_String)), 1), 3)
EndFunc   ;==>_Res_Create_RTVersion_BuildStringTableEntry
;
; Call UpdateResource DllCalls to update the requested resource with the provided RES or ICO file.
Func _Res_Update($rh, $InpResFile, $RType, $RName, $RLanguage = 1033)
	Local $result, $hFile, $tSize, $tBuffer, $pBuffer, $oBuffer, $bread = 0
	Local $RType_Type, $RName_Type
	; did we really get a number?
	If StringIsDigit($RType) Then $RType = Number($RType)
	If StringIsDigit($RName) Then $RName = Number($RName)
	; check for known resource types and convert to ordinal
	If IsString($RType) Then
		If StringLeft($RType, 3) <> 'RT_' Then $RType = 'RT_' & $RType
		For $k = 0 To UBound($aRESOURCE_TYPES) - 1
			If $RType = $aRESOURCE_TYPES[$k] Then
				$RType = $k + 1
				$RType_Type = "long"
			EndIf
		Next
	EndIf
	; set parameter types
	If IsString($RType) Then
		$RType_Type = "wstr"
		$RType = StringReplace(StringUpper($RType), "RT_", "")
	Else
		$RType_Type = "long"
	EndIf
	If IsString($RName) Then
		$RName_Type = "wstr"
		$RName = StringUpper($RName)
	Else
		$RName_Type = "long"
	EndIf
	;
	; Remove requested Section from the program resources.
	If $InpResFile = "" Then
		; No resource file defined thus delete the existing resource
		$result = DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $rh, $RType_Type, $RType, $RName_Type, $RName, "ushort", $RLanguage, "ptr", 0, "dword", 0)
		If $result[0] <> 1 Then __ConsoleWrite("! Removal UpdateResource: " & $aRESOURCE_TYPES[$RType - 1] & "/" & $RName & " - LastError:" & _WinAPI_GetLastError() & ":" & _WinAPI_GetLastErrorMessage() & @CRLF)
		Return $result[0]
	EndIf
	; Make sure the input res file exists
	If Not FileExists($InpResFile) Then
		Write_RC_Console_Msg("Resource Update skipped: missing Resfile :" & $InpResFile, "", "+")
		Return 0
	EndIf
	;
	; Open the Resource File
	If ($RType <> 6) Then                                            ; not for RT_STRING
		$hFile = _WinAPI_CreateFile($InpResFile, 2, 2)
		If Not $hFile Then
			Write_RC_Console_Msg("Resource Update skipped: error opening Resfile :" & $InpResFile, "", "+")
			Return 0
		EndIf
	EndIf
	;
	; Process the different Update types
	Local $iResult = 0
	Switch $RType
		Case $RT_CURSOR                                              ; 1
			$tSize = FileGetSize($InpResFile)
			Local $tC_Input_Header = DllStructCreate("word res;word type;word ImageCount;byte rest[" & $tSize - 6 & "]") ; Create the buffer
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tC_Input_Header), FileGetSize($InpResFile), $bread, 0)
			If $hFile Then _WinAPI_CloseHandle($hFile)
			If $bread > 0 Then
				; Read input file header
				Local $CurType = DllStructGetData($tC_Input_Header, "Type")
				Local $CurCount = DllStructGetData($tC_Input_Header, "ImageCount")
				; Created CursorGroup Structure
				Local $tB_CurGroupHeader = DllStructCreate("align 2;word res;word type;word ImageCount;byte rest[" & $CurCount * 14 & "]") ; Create the buffer
				Local $pB_CurGroupHeader = DllStructGetPtr($tB_CurGroupHeader)
				DllStructSetData($tB_CurGroupHeader, "Res", 0)
				DllStructSetData($tB_CurGroupHeader, "Type", $CurType)
				DllStructSetData($tB_CurGroupHeader, "ImageCount", $CurCount)
				; process all internal Cursors
				For $x = 1 To $CurCount
					; Set pointer correct in the input struct
					Local $pB_Input_CurHeader = DllStructGetPtr($tC_Input_Header, "rest") + ($x - 1) * 16 ; 16 = size of input cursor header structure
					Local $tB_Input_CurHeader = DllStructCreate("byte Width;byte Height;byte Planes;byte res;word xHotspot;word yHotspot;dword ImageSize;dword ImageOffset", $pB_Input_CurHeader) ; Create the buffer
					; get info form the input
					Local $CurWidth = DllStructGetData($tB_Input_CurHeader, "Width")
					Local $CurHeight = DllStructGetData($tB_Input_CurHeader, "Height")
					Local $CurPlanes = DllStructGetData($tB_Input_CurHeader, "Planes")
					Local $xHotspot = DllStructGetData($tB_Input_CurHeader, "xHotspot")
					Local $yHotspot = DllStructGetData($tB_Input_CurHeader, "yHotspot")
					Local $CurImageSize = DllStructGetData($tB_Input_CurHeader, "ImageSize")
					Local $CurImageOffset = DllStructGetData($tB_Input_CurHeader, "ImageOffset")
					; get BitsPerPixel
					; this value is in the Dib header, located at the start of the image data
					Local $pB_CurData = DllStructGetPtr($tC_Input_Header) + $CurImageOffset
					Local $tDibHeader = DllStructCreate("dword Size;dword Width;dword Height;word Planes;word BitsPerPixel", $pB_CurData)
					Local $CurBitsPerPixel = DllStructGetData($tDibHeader, "BitsPerPixel")
					; Update the CUR Group header struct
					$pB_CurGroupHeader = DllStructGetPtr($tB_CurGroupHeader, "rest") + ($x - 1) * 14 ; 14 = size of resource structure
					Local $tB_GroupCur = DllStructCreate("align 2;word Width;word Height;word Planes;word BitsPerPixel;dword ImageSize;word ResourceID", $pB_CurGroupHeader) ; Create the buffer
					DllStructSetData($tB_GroupCur, "Width", $CurWidth)
					DllStructSetData($tB_GroupCur, "Height", $CurHeight)
					DllStructSetData($tB_GroupCur, "Planes", $CurPlanes)
					DllStructSetData($tB_GroupCur, "BitsPerPixel", $CurBitsPerPixel)
					DllStructSetData($tB_GroupCur, "ImageSize", $CurImageSize)
					$CursorResBase += 1
					DllStructSetData($tB_GroupCur, "ResourceID", $CursorResBase)
					; Create cursor data for resource
					Local $tCurData = DllStructCreate("short xHotspot;short yHotspot;byte data[" & $CurImageSize & "]")
					DllStructSetData($tCurData, "xHotspot", $xHotspot)
					DllStructSetData($tCurData, "yHotspot", $yHotspot)
					DllStructSetData($tCurData, "data", DllStructGetData(DllStructCreate("byte[" & $CurImageSize & "]", $pB_CurData), 1))
					; add Cursor
					$result = DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $rh, "long", $RT_CURSOR, "long", $CursorResBase, "ushort", $RLanguage, "ptr", DllStructGetPtr($tCurData), "dword", DllStructGetSize($tCurData))
					If $result[0] <> 1 Then __ConsoleWrite("- Cursor UpdateResources: $result[0] = " & $result[0] & " - LastError:" & _WinAPI_GetLastError() & ":" & _WinAPI_GetLastErrorMessage() & @CRLF)
					$iResult += $result[0]
				Next
				If $CurCount = $iResult Then
					$iResult = 1
				Else
					$iResult = 0
				EndIf
				; Add CursorGroup entry
				$pB_CurGroupHeader = DllStructGetPtr($tB_CurGroupHeader)
				$result = DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $rh, "long", $RT_GROUP_CURSOR, $RName_Type, $RName, "ushort", $RLanguage, "ptr", $pB_CurGroupHeader, "dword", DllStructGetSize($tB_CurGroupHeader))
				If $result[0] <> 1 Then
					__ConsoleWrite("! GroupCursor UpdateResources: $result[0] = " & $result[0] & " - LastError:" & _WinAPI_GetLastError() & ":" & _WinAPI_GetLastErrorMessage() & @CRLF)
					$iResult = 0
				Else
					If $iResult = 0 Then __ConsoleWrite("- GroupCursor UpdateResources: partially updated." & @CRLF)
				EndIf
			EndIf
			Return $iResult
		Case $RT_BITMAP                                              ; 2
			$tSize = FileGetSize($InpResFile) - 14                   ; file size minus the bitmap header
			$tBuffer = DllStructCreate("byte Text[" & $tSize & "]")  ; Create the buffer.
			$pBuffer = DllStructGetPtr($tBuffer)
			_WinAPI_SetFilePointer($hFile, 14)                       ; skip reading the bitmap header
			_WinAPI_ReadFile($hFile, $pBuffer, $tSize, $bread, 0)
			If $hFile Then _WinAPI_CloseHandle($hFile)
			If $bread > 0 Then
				$result = DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $rh, $RType_Type, $RType, $RName_Type, $RName, "ushort", $RLanguage, "ptr", $pBuffer, "dword", $tSize)
				If $result[0] <> 1 Then __ConsoleWrite("! UpdateResources other: $result[0] = " & $result[0] & " - LastError:" & _WinAPI_GetLastError() & ":" & _WinAPI_GetLastErrorMessage() & @CRLF)
				$iResult = $result[0]
			EndIf
			Return $iResult
		Case $RT_ICON                                                ; 3
			;ICO section
			$tSize = FileGetSize($InpResFile)
			Local $tI_Input_Header = DllStructCreate("word res;word type;word ImageCount;byte rest[" & $tSize - 6 & "]") ; Create the buffer
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tI_Input_Header), FileGetSize($InpResFile), $bread, 0)
			If $hFile Then _WinAPI_CloseHandle($hFile)
			If $bread > 0 Then
				; Read input file header
				Local $IconType = DllStructGetData($tI_Input_Header, "Type")
				Local $IconCount = DllStructGetData($tI_Input_Header, "ImageCount")
				; Created IconGroup Structure
				Local $tB_IconGroupHeader = DllStructCreate("align 2;word res;word type;word ImageCount;byte rest[" & $IconCount * 14 & "]") ; Create the buffer.
				Local $pB_IconGroupHeader = DllStructGetPtr($tB_IconGroupHeader)
				DllStructSetData($tB_IconGroupHeader, "Res", 0)
				DllStructSetData($tB_IconGroupHeader, "Type", $IconType)
				DllStructSetData($tB_IconGroupHeader, "ImageCount", $IconCount)
				; process all internal Icons
				For $x = 1 To $IconCount
					; Set pointer correct in the input struct
					Local $pB_Input_IconHeader = DllStructGetPtr($tI_Input_Header, "rest") + ($x - 1) * 16
					Local $tB_Input_IconHeader = DllStructCreate("byte Width;byte Height;byte Colors;byte res;word Planes;word BitsPerPixel;dword ImageSize;dword ImageOffset", $pB_Input_IconHeader) ; Create the buffer.
					; get info form the input
					Local $IconWidth = DllStructGetData($tB_Input_IconHeader, "Width")
					Local $IconHeight = DllStructGetData($tB_Input_IconHeader, "Height")
					Local $IconColors = DllStructGetData($tB_Input_IconHeader, "Colors")
					Local $IconPlanes = DllStructGetData($tB_Input_IconHeader, "Planes")
					Local $IconBitsPerPixel = DllStructGetData($tB_Input_IconHeader, "BitsPerPixel")
					Local $IconImageSize = DllStructGetData($tB_Input_IconHeader, "ImageSize")
					Local $IconImageOffset = DllStructGetData($tB_Input_IconHeader, "ImageOffset")
					; Update the ICO Group header struct
					$pB_IconGroupHeader = DllStructGetPtr($tB_IconGroupHeader, "rest") + ($x - 1) * 14
					Local $tB_GroupIcon = DllStructCreate("align 2;byte Width;byte Height;byte Colors;byte res;word Planes;word BitsPerPixel;dword ImageSize;word ResourceID", $pB_IconGroupHeader) ; Create the buffer.
					DllStructSetData($tB_GroupIcon, "Width", $IconWidth)
					DllStructSetData($tB_GroupIcon, "Height", $IconHeight)
					DllStructSetData($tB_GroupIcon, "Colors", $IconColors)
					DllStructSetData($tB_GroupIcon, "res", 0)
					DllStructSetData($tB_GroupIcon, "Planes", $IconPlanes)
					DllStructSetData($tB_GroupIcon, "BitsPerPixel", $IconBitsPerPixel)
					DllStructSetData($tB_GroupIcon, "ImageSize", $IconImageSize)
					$IconResBase += 1
					DllStructSetData($tB_GroupIcon, "ResourceID", $IconResBase)
					; Get data pointer
					Local $pB_IconData = DllStructGetPtr($tI_Input_Header) + $IconImageOffset
					; add Icon
					$result = DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $rh, "long", $RT_ICON, "long", $IconResBase, "ushort", $RLanguage, "ptr", $pB_IconData, "dword", $IconImageSize)
					If $result[0] <> 1 Then __ConsoleWrite("! Icon UpdateResources: $result[0] = " & $result[0] & " - LastError:" & _WinAPI_GetLastError() & ":" & _WinAPI_GetLastErrorMessage() & @CRLF)
					$iResult += $result[0]
				Next
				If $IconCount = $iResult Then
					$iResult = 1
				Else
					$iResult = 0
				EndIf
				; Add Icongroup entry
				$pB_IconGroupHeader = DllStructGetPtr($tB_IconGroupHeader)
				$result = DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $rh, "long", $RT_GROUP_ICON, $RName_Type, $RName, "ushort", $RLanguage, "ptr", $pB_IconGroupHeader, "dword", DllStructGetSize($tB_IconGroupHeader))
				If $result[0] <> 1 Then
					__ConsoleWrite("GroupIcon UpdateResources: $result[0] = " & $result[0] & " - LastError:" & _WinAPI_GetLastError() & ":" & _WinAPI_GetLastErrorMessage() & @CRLF)
					$iResult = 0
				Else
					If $iResult = 0 Then __ConsoleWrite("- GroupIcon UpdateResources: partially updated." & @CRLF)
				EndIf
			Else
				$iResult = 0
			EndIf
			Return $iResult
		Case $RT_STRING                                              ; 6
			Local $aLangs = IniReadSectionNames($InpResFile)
			If @error Then
				Write_RC_Console_Msg("Resource Update skipped: string file did not contain valid input", "", "+")
				Return 0
			EndIf
			; loop each language section
			Local $aStrings, $aBlocks, $aBlock
			Local $iBlock, $iIdx, $iID, $sStr, $iBlockIdx
			Local $iElem, $sStruct, $oStruct
			For $i = 1 To $aLangs[0]
				; aLangs[i] = current language
				$aStrings = IniReadSection($InpResFile, $aLangs[$i])
				If @error Then
					Write_RC_Console_Msg("Resource Update skipped: language '" & $aLangs[$i] & "' is not valid", "", "+")
					ContinueLoop
				EndIf
				; reset block array
				Dim $aBlocks[1] = [0]
				; loop strings, create blocks and update resources
				; string ID is as follows:
				; ID is a WORD (16 bits)
				; first 4 bits = string index in block, 0-15
				; top 12 bits = block ID, starting at 1
				; string IDX = BitAND(ID, 0xF)
				; block ID = BitAND(BitShift(ID, 4), 0xFFF) + 1
				;
				; aBlocks will contain all the string blocks
				; aBlocks[0] = count
				; aBlocks[n] = block array
				; aBlock[0] = block ID
				; aBlock[1] to [16] = string
				For $j = 1 To $aStrings[0][0]
					; iID = string ID
					; sStr = string
					; iBlock = block ID
					; iIdx = string index in block
					; iBlockIdx = string block index in aBlocks container array
					$iID = Number($aStrings[$j][0])
					$sStr = $aStrings[$j][1]
					$iBlock = BitAND(BitShift($iID, 4), 0xFFF) + 1
					$iIdx = BitAND($iID, 0xF)
					; check if we created the block that contains the string, if not, initialize it
					$iBlockIdx = _GetBlockIDIdx($aBlocks, $iBlock)
					If $iBlockIdx = -1 Then
						; initialize the block and resize aBlocks array
						Dim $aBlock[17] = [$iBlock]
						$aBlocks[0] += 1
						ReDim $aBlocks[$aBlocks[0] + 1]
						$iBlockIdx = $aBlocks[0]
					Else
						$aBlock = $aBlocks[$iBlockIdx]
					EndIf
					; we have the string block, set new string in block
					$aBlock[$iIdx + 1] = $sStr
					; set the updated array into aBlocks container
					$aBlocks[$iBlockIdx] = $aBlock
				Next
				; all string blocks for this language have been created, update the resource
				; create the data structure <word;text;word...>
				; empty strings have length 0
				$iResult = 0
				For $j = 1 To $aBlocks[0]
					; get each block
					$aBlock = $aBlocks[$j]
					; we have to loop each block twice, once to create the structure, then once to fill it
					; reset structure
					$sStruct = ""
					For $k = 1 To 16
						$sStruct &= "word;"
						If ($aBlock[$k] <> "") Then
							; there is a string
							$sStruct &= "wchar[" & StringLen($aBlock[$k]) & "];"
						EndIf
					Next
					; create the structure
					$oStruct = DllStructCreate($sStruct)
					; reset element counter
					$iElem = 1
					For $k = 1 To 16
						If ($aBlock[$k] <> "") Then
							; there is a string
							; set count
							DllStructSetData($oStruct, $iElem, StringLen($aBlock[$k]))
							; set string
							DllStructSetData($oStruct, $iElem + 1, $aBlock[$k])
							; increment counter
							$iElem += 2
						Else
							; no string, set count to 0 and increment counter
							DllStructSetData($oStruct, $iElem, 0)
							$iElem += 1
						EndIf
					Next
					; the block structure is created, update the resource
					; aLangs[i] is the language, aBlock[0] is the block ID
					$tSize = DllStructGetSize($oStruct)
					$pBuffer = DllStructGetPtr($oStruct)
					$result = DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $rh, $RType_Type, $RType, "long", $aBlock[0], "ushort", $aLangs[$i], "ptr", $pBuffer, "dword", $tSize)
					If $result[0] <> 1 Then __ConsoleWrite("String UpdateResources: $result[0] = " & $result[0] & " - LastError:" & _WinAPI_GetLastError() & ":" & _WinAPI_GetLastErrorMessage() & @CRLF)
					$iResult += $result[0]
				Next
				If $iResult = $aBlocks[0] Then
					$iResult = 1
				Else
					$iResult = 0
				EndIf
			Next
		Case -$RT_RCDATA                                             ; compressed RT_RCDATA = -10
			$tSize = FileGetSize($InpResFile)
			$tBuffer = DllStructCreate("byte Text[" & $tSize & "]")  ; Create the input buffer.
			_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $tSize, $bread, 0)
			If $hFile Then _WinAPI_CloseHandle($hFile)
			If $bread > 0 Then
				; compress the buffer
				$bread = _WinAPI_LZNTCompress($tBuffer, $oBuffer)
				If Not @error Then
					$result = DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $rh, "long", $RT_RCDATA, $RName_Type, $RName, "ushort", $RLanguage, "struct*", $oBuffer, "dword", $bread)
					If $result[0] <> 1 Then
						__ConsoleWrite("UpdateResources other: $result[0] = " & $result[0] & " - LastError:" & _WinAPI_GetLastError() & ":" & _WinAPI_GetLastErrorMessage() & @CRLF)
					Else
						$iResult = 1
					EndIf
				Else
					Write_RC_Console_Msg("Update Resource skipped: data compression failed - @error:" & @error & ", @extended:" & @extended, "", "+")
				EndIf
			EndIf
			Return $iResult
		Case Else                                                    ; 10, 16, 24 *** RT_RCDATA, RT_VERSION and RT_MANIFEST *** and Other
			$tSize = FileGetSize($InpResFile)
			$tBuffer = DllStructCreate("byte Text[" & $tSize & "]")  ; Create the buffer.
			$pBuffer = DllStructGetPtr($tBuffer)
			_WinAPI_ReadFile($hFile, $pBuffer, $tSize, $bread, 0)
			If $hFile Then _WinAPI_CloseHandle($hFile)
			If $bread > 0 Then
				$result = DllCall("kernel32.dll", "int", "UpdateResourceW", "ptr", $rh, $RType_Type, $RType, $RName_Type, $RName, "ushort", $RLanguage, "ptr", $pBuffer, "dword", $tSize)
				If $result[0] <> 1 Then __ConsoleWrite("+ UpdateResources other: $result[0] = " & $result[0] & " - LastError:" & _WinAPI_GetLastError() & ":" & _WinAPI_GetLastErrorMessage() & @CRLF)
				Return $result[0]
			EndIf
			Return 0
	EndSwitch
	;
EndFunc   ;==>_Res_Update
;
Func _ResLangCallback($hModule, $lpszType, $lpszName, $wLangID, $lParam)
	#forceref $hModule, $lpszType, $lpszName, $lParam
	If $g_aResNamesAndLangs[$g_aResNamesAndLangs[0][0]][1] = "" Then
		$g_aResNamesAndLangs[$g_aResNamesAndLangs[0][0]][1] &= $wLangID
	Else
		$g_aResNamesAndLangs[$g_aResNamesAndLangs[0][0]][1] &= "," & $wLangID
	EndIf
	Return 1                                                         ; continue
EndFunc   ;==>_ResLangCallback
;
Func _ResNameCallback($hModule, $lpszType, $lpszName, $lParam)
	#forceref $hModule, $lParam
	$g_aResNamesAndLangs[0][0] += 1
	ReDim $g_aResNamesAndLangs[UBound($g_aResNamesAndLangs) + 1][2]
	; get name
	If IS_INTRESOURCE($lpszName) Then
		;lpszName is an ordinal
		$g_aResNamesAndLangs[$g_aResNamesAndLangs[0][0]][0] = Number($lpszName)
	Else
		;lpszName is a pointer to a string
		Local $tName = DllStructCreate("wchar[256]", $lpszName)
		Local $sName = DllStructGetData($tName, 1)
		If StringLeft($sName, 1) = "#" Then
			;rest of string is an ordinal
			$g_aResNamesAndLangs[$g_aResNamesAndLangs[0][0]][0] = Number(StringTrimLeft($sName, 1))
		Else
			;regular string
			$g_aResNamesAndLangs[$g_aResNamesAndLangs[0][0]][0] = $sName
		EndIf
	EndIf
	; call language callback
	DllCall("kernel32.dll", "int", "EnumResourceLanguages", "ptr", $hModule, "ptr", $lpszType, "ptr", $lpszName, _
			"ptr", DllCallbackGetPtr($hLangCallback), "long_ptr", 0)
	Return 1                                                         ; continue enumerating
EndFunc   ;==>_ResNameCallback
; #FUNCTION# ====================================================================================================================
; Name...........:     _WinAPI_LZNTCompress
; Description....:     Compresses an input data.
; Syntax.........:     _WinAPI_LZNTCompress ( $tInput, ByRef $tOutput [, $fMaximum] )
; Parameters.....:     $tInput   - "byte[n]" or any other structure that contains the data to be compressed.
;                              $tOutput  - "byte[n]" structure that is created by this function, and contain the compressed data.
;                              $fMaximum - Specifies whether use a maximum data compression, valid values:
;                              |TRUE     - Uses an algorithm which provides maximum data compression but with relatively slower performance.
;                              |FALSE    - Uses an algorithm which provides a balance between data compression and performance. (Default)
; Return values..: Success   - The size of the compressed data, in bytes.
;                              Failure   - 0 and sets the @error flag to non-zero, @extended flag may contain the NTSTATUS code.
; Author.........:     trancexx
; Modified.......:     Yashied, UEZ
; Remarks........:     The input and output buffers must be different, otherwise, the function fails.
; Related........:
; Link...........:         @@MsdnLink@@ RtlCompressBuffer
; Example........:     Yes
; ===============================================================================================================================
Func _WinAPI_LZNTCompress(ByRef $tInput, ByRef $tOutput, $fMaximum = True)
	Local $tBuffer, $tWorkSpace, $ret
	Local $COMPRESSION_FORMAT_LZNT1 = 0x0002, $COMPRESSION_ENGINE_MAXIMUM = 0x0100
	If $fMaximum Then $COMPRESSION_FORMAT_LZNT1 = BitOR($COMPRESSION_FORMAT_LZNT1, $COMPRESSION_ENGINE_MAXIMUM)
	$tOutput = 0
	$ret = DllCall("ntdll.dll", "uint", "RtlGetCompressionWorkSpaceSize", "ushort", $COMPRESSION_FORMAT_LZNT1, "ulong*", 0, "ulong*", 0)
	If @error Then Return SetError(1, 0, 0)
	If $ret[0] Then Return SetError(2, $ret[0], 0)
	$tWorkSpace = DllStructCreate("byte[" & $ret[2] & "]")
	$tBuffer = DllStructCreate("byte[" & (2 * DllStructGetSize($tInput)) & "]")
	$ret = DllCall("ntdll.dll", "uint", "RtlCompressBuffer", "ushort", $COMPRESSION_FORMAT_LZNT1, "struct*", $tInput, "ulong", DllStructGetSize($tInput), "struct*", $tBuffer, "ulong", DllStructGetSize($tBuffer), "ulong", 4096, "ulong*", 0, "struct*", $tWorkSpace)
	If @error Then Return SetError(3, 0, 0)
	If $ret[0] Then Return SetError(4, $ret[0], 0)
	$tOutput = DllStructCreate("byte[" & $ret[7] & "]")
	DllCall("ntdll.dll", "none", "RtlMoveMemory", "struct*", $tOutput, "struct*", $tBuffer, "ulong_ptr", $ret[7])
	If @error Then
		$tOutput = 0
		Return SetError(5, 0, 0)
	EndIf
	Return $ret[7]
EndFunc   ;==>_WinAPI_LZNTCompress
;
; Add all needed standard Constants Include files
Func Add_Constants()
	__ConsoleWrite("+>Check for missing standard constants/udf include files:")
	Local $ScriptData, $Stripped_ScriptData
	Local $count = 0
	Local $Lines2Add
	; Read the script into a variable
	$ScriptData = @CRLF & FileRead($ScriptFile_In)
	; Strip all comments (pulled from Smoke_N example code)
	$Stripped_ScriptData = StringRegExpReplace($ScriptData & @CRLF, "(?s)(?i)(\s*#cs\s*.-\#ce\s*)(\r\n)", "\2")
	$Stripped_ScriptData = StringRegExpReplace($Stripped_ScriptData, "(?s)(?i)" & '("")|(".*?")|' & "('')|('.*?')|" & "(\s*;.*?)(\r\n)", "\1\2\3\4\6")
	$Stripped_ScriptData = StringRegExpReplace($Stripped_ScriptData, "(\r\n){2,}", @CRLF)
	;
	Local $includes = _FileListToArray($CurrentAutoIt_InstallDir & "\include", "*Constants*.au3")
	Local $AddInclude = 0
	For $i = 1 To UBound($includes) - 1
		; don't include GUIConstants.au3
		If $includes[$i] = "GUIConstants.au3" Then ContinueLoop
		; Skip already included Include files
		If StringRegExp($Stripped_ScriptData, "(?i)(?s)#include(\s*?)<" & $includes[$i] & ">", 0) Then ContinueLoop
		$AddInclude = 0
		; Get all Constants from include file into Array
		Local $ConstArray = StringRegExp(FileRead($CurrentAutoIt_InstallDir & "\include\" & $includes[$i]), "(?i)\n[\s]*Global[\s]*Const[\s]*(.*?) = ", 3)
		For $j = 0 To UBound($ConstArray) - 1
			If StringRegExp($Stripped_ScriptData, "(?i)(?s)\" & $ConstArray[$j] & "", 0) Then
				$count += 1
				$AddInclude = 1
				ExitLoop
			EndIf
		Next
		If $AddInclude Then $Lines2Add &= "#include <" & $includes[$i] & ">" & @CRLF
		;
	Next
	FileRecycle($ScriptFile_In)
	; sleep 500 ms to ensure SciTE detects the file was changed.
	Sleep(500)
	Local $H_Outf = FileOpen($ScriptFile_In, 2 + $SrceUnicodeFlag)
	If $count Then
		FileWriteLine($H_Outf, "; *** Start added by AutoIt3Wrapper ***")
		FileWrite($H_Outf, $Lines2Add)
		FileWriteLine($H_Outf, "; *** End added by AutoIt3Wrapper ***")
	EndIf
	; update directive to n to avoid running it each time
	$ScriptData = StringRegExpReplace($ScriptData, '(?i)' & @CRLF & '(\h?)#AutoIt3Wrapper_Add_Constants(\h*?)=(.*?)' & @CRLF, @CRLF & '#AutoIt3Wrapper_Add_Constants=n' & @CRLF)
	; strip extra leading and trailing CRLF's and write back to file
	FileWrite($H_Outf, StringMid($ScriptData, 3))
	FileClose($H_Outf)
	__ConsoleWrite(" " & $count & " include(s) were added" & @CRLF)
EndFunc   ;==>Add_Constants
;
Func Compile_Run_AUT2EXE($out_env, $ScriptFile_Out)
	Local $PgmVer = FileGetVersion($AUT2EXE_PGM)
	Local $s_CMDLine = ""
	;  Run aut2exe to compile the script
	ProgressSet(40, "Running Aut2exe.exe.")
	; Set the proper compile option
	; Set the CUI / GUI
	;-------------------------------------------------------------------------------------------
	; prepare all variables for the commandline programs and AUT2EXE
	;-------------------------------------------------------------------------------------------
	$s_CMDLine = ' /in "' & $ScriptFile_In & '"'
	If $ScriptFile_Out <> "" Then
		; Check it the target directory is valid
		$ScriptFile_Out = StringReplace($ScriptFile_Out, "/", "\")
		If StringInStr($ScriptFile_Out, "\", 0, -1) And Not FileExists(StringLeft($ScriptFile_Out, StringInStr($ScriptFile_Out, "\", 0, -1) - 1)) Then
			;$s_CMDLine = $s_CMDLine & ' /out "' & $ScriptFile_Out & '"'
			__ConsoleWrite("- Output path: " & StringLeft($ScriptFile_Out, StringInStr($ScriptFile_Out, "\", 0, -1) - 1) & " not found, changing it to:")
			$ScriptFile_Out = StringTrimRight($ScriptFile_In, StringLen($ScriptFile_In_Ext)) & '.exe'
			__ConsoleWrite($ScriptFile_Out & @CRLF)
		EndIf
		If $Pragma_Out = "" Then $s_CMDLine &= ' /out "' & $ScriptFile_Out & '"'
	EndIf
	If $ScriptFile_Out = "" Then $ScriptFile_Out = StringTrimRight($ScriptFile_In, StringLen($ScriptFile_In_Ext)) & '.exe'
	If $ScriptFile_In = $ScriptFile_Out Then
		__ConsoleWrite("! Input source file should never be equal to the target output file !" & @CRLF)
		Exit
	EndIf
	; we handle resources and UPX later, so no packing from compiler
	If $Pragma_UseUpx = "" Then $s_CMDLine &= ' /nopack'
	;
	If $INP_Icon <> "" Then $s_CMDLine &= ' /icon "' & $INP_Icon & '"'
	If $INP_Compression > -1 And $INP_Compression < 5 And $Pragma_Compression = "" Then $s_CMDLine &= ' /comp ' & $INP_Compression & ''
	If $INP_Change2CUI = "y" Then $s_CMDLine &= " /Console"
	; add flag to make x86 EXEs on x64 systems
	If $out_env = "x86" And StringInStr($AUT2EXE_PGM, "aut2exe_x64.exe") Then $s_CMDLine &= " /x86"
	; add flag to make x64 EXEs on x86 systems
	If $out_env = "x64" And StringInStr($AUT2EXE_PGM, "aut2exe.exe") Then $s_CMDLine &= " /x64"
	;
	If $Debug Then __ConsoleWrite(">*** AUT2EXE:" & '"' & $AUT2EXE_PGM & '"' & $s_CMDLine & " " & @CRLF)
	;
	__ConsoleWrite(">Running:(" & $PgmVer & "):" & $AUT2EXE_PGM & " " & $s_CMDLine & @CRLF)
	;effort to avoid the resource update issue when the Windows Explorer is open and has the output program selected
	;    by deleting the original file and give a little time to update.
	__DelTempFile($ScriptFile_Out)
	Sleep(600)
	$Pid = Run('"' & $AUT2EXE_PGM & '"' & $s_CMDLine, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	If $Pid Then
		$Handle = _ProcessExitCode($Pid)
		While ProcessExists($Pid)
			If WinExists("Aut2Exe Error", "Error adding file") Then
				Local $errtxt = StringReplace(WinGetText("Aut2Exe Error", "Error adding file"), @LF, " ")
				$errtxt = StringReplace($errtxt, "OK", "")
				WinClose("Aut2Exe Error", "Error adding file")
				Write_RC_Console_Msg("Aut2exe.exe encountered an error ended with error: " & $errtxt & ".", 2)
				Write_RC_Console_Msg("Target exe is not created, abandon build.", 2)
				Exit 1
			EndIf
			Sleep(100)
		WEnd
		ProcessWaitClose($Pid)
		; Show console output
		ShowStdOutErr($Pid)
		$ExitCode = _ProcessExitCode($Pid, $Handle)
		_ProcessCloseHandle($Handle)
		;__ConsoleWrite(">Aut2exe.exe ended.  rc:" & $exitcode & @crlf)
	EndIf
	;
	If Not $Pid Or Not FileExists($ScriptFile_Out) Then
		Write_RC_Console_Msg("Aut2exe.exe ended with errors because the target exe wasn't created, abandon build. (" & $ScriptFile_Out & ")", 2)
		Exit 1
	Else
		Write_RC_Console_Msg("Aut2exe.exe ended." & $ScriptFile_Out & ". ", $ExitCode)
	EndIf
EndFunc   ;==>Compile_Run_AUT2EXE
;
Func Compile_Upd_res($ScriptFile_Out)
	Local $ResUpdatePragmaSupported = 0
	Local $ResUpdateSuccess = 1
	; No need to retrieve the program resource after 3.3.9.x
	$ResUpdatePragmaSupported = _VersionCompare($AUT2EXE_PGM_VER, "3.3.9.4") = 1
	;-------------------------------------------------------------------------------------------
	; Update resources only if needed and the outfile is an EXE
	If _Check_Res_Updates_Defined() And StringRight($ScriptFile_Out, 4) = ".exe" Then
		ProgressSet(50, "Creating Resource file.")
		Write_RC_Console_Msg("Performing the Program Resource Update steps:")
		$ResUpdateSuccess = 0
		; get and save 'extra data' at end of script
		Local $extraData, $dwSize = 0
		If Not $ResUpdatePragmaSupported And (Not _getFileExtraData($ScriptFile_Out, $extraData, $dwSize) Or $dwSize = 0) Then
			; something went wrong
			Write_RC_Console_Msg("Error: Failed to get script data from end of target file.  Skipping resource update.", 2)
		Else
			; begin resource update
			$rh = DllCall("kernel32.dll", "ptr", "BeginUpdateResourceW", "wstr", $ScriptFile_Out, "int", 0)
			$rh = $rh[0]
			; set language default
			$INP_Res_Language = Number($INP_Res_Language)
			If $INP_Res_Language = 0 Then $INP_Res_Language = 2057
			; ########################################################################################
			; Check if Pragma is used for VERSION updates and supported
			; ########################################################################################
			If $Pragma_Comment <> "" Or $Pragma_CompanyName <> "" Or $Pragma_Description <> "" Or $Pragma_Fileversion <> "" Or $Pragma_InternalName <> "" Or $Pragma_LegalCopyright <> "" _
					Or $Pragma_LegalTradeMarks <> "" Or $Pragma_Productname <> "" Or $Pragma_ProductVersion <> "" Then
				If $ResUpdatePragmaSupported Then
					__ConsoleWrite("> #pragma Compile() found that updates the VERSION Resources." & @CRLF)
					__ConsoleWrite("-    Ignoring all #AutoIt3Wrapper_* #directives that would normally update the VERSION section!" & @CRLF)
;~ 					$INP_Res_Language = ""
					$INP_Comment = ""
					$INP_CompanyName = ""
					$INP_LegalTradeMarks = ""
					$INP_Description = ""
					$INP_Fileversion = $Pragma_Fileversion
					$INP_ProductName = ""
					$INP_ProductVersion = ""
					$INP_CompanyName = ""
					$INP_LegalCopyright = ""
					$INP_LegalTradeMarks = ""
					$INP_Res_FieldCount = 0
					$INP_FieldValue1 = ""
					$INP_FieldValue2 = ""
					$Pragma_Used = 1
				Else
					$Pragma_Used = 0
					__ConsoleWrite("- Ignoring all #pragma Compile() statements for VERSION update because AutoIt3 version: " & $AUT2EXE_PGM_VER & " doesn't support it!" & @CRLF)
				EndIf
			EndIf
			; create the source of the VERSION resource update file
			If Not $Pragma_Used And _Check_Res_Updates_Defined(1) Then
				Local $Version_Res_File = ""
				; enum RT_VERSION resources in target file
				If Not _EnumResourceNamesAndLangs($ScriptFile_Out, $RT_VERSION) Then ;
					; error, use default
					Write_RC_Console_Msg("Error: Failed to enumerate RT_VERSION resources, using defaults.", "", "!")
					Dim $aVersionInfo[2][2] = [[1, 0], [1, 2057]]
				Else
					$aVersionInfo = $g_aResNamesAndLangs
				EndIf
				; used for default version info only
				Local $AutoItBin = $AUT2EXE_DIR & "\AutoItSC.bin"
				; As of version 3.3.9.5 the AutoItSC.bin doesn't exists and is stored inside of aut2exe.exe
				If Not FileExists($AutoItBin) Then $AutoItBin = $AUT2EXE_DIR & "\Aut2exe.exe"
				; retrieve the current info when not all fields are filled to preserve those:
				If $INP_Comment = "" Then $INP_Comment = FileGetVersion($AutoItBin, "Comments")
				If $INP_Description = "" Then $INP_Description = FileGetVersion($AutoItBin, "FileDescription")
				If $INP_Fileversion = "" Then $INP_Fileversion = FileGetVersion($AutoItBin)
				If $INP_LegalCopyright = "" Then $INP_LegalCopyright = FileGetVersion($AutoItBin, "LegalCopyright")
				If $INP_ProductVersion = "" Then $INP_ProductVersion = FileGetVersion($AutoItBin)
				; Delete current resources for all but 1 and the input language
				For $y = 1 To $aVersionInfo[0][0]
					$aTemp = StringSplit($aVersionInfo[$y][1], ",")  ; create temp array of languages for this name
					For $z = 1 To $aTemp[0]
						; remove any version info that is not 1 or our input language
						If ($aVersionInfo[$y][0] <> 1) Or ($aTemp[$z] <> $INP_Res_Language) Then _
								_Res_Update($rh, "", $RT_VERSION, $aVersionInfo[$y][0], $aTemp[$z])
					Next
				Next
				_Res_Create_RTVersion($Version_Res_File)             ; Build the RT_VERSION structure
				_Res_Update($rh, $Version_Res_File, $RT_VERSION, 1, $INP_Res_Language) ; Update RT_VERSION in the Bin file
				__DelTempFile($Version_Res_File)
				Write_RC_Console_Msg("Updating Program Version information.", "", "...", 0)
			Else
				$INP_Fileversion = Valid_FileVersion($INP_Fileversion)
			EndIf
			;
			; ########################################################################################
			; Check if Pragma is used for MANIFEST updates and supported
			; ########################################################################################
			If $Pragma_RES_requestedExecutionLevel <> "" Or $Pragma_RES_Compatibility <> "" Then
				; No need to retrieve the program resource after 3.3.9.x
				If $ResUpdatePragmaSupported Then
					__ConsoleWrite("> #pragma Compile() found that updates the MANIFEST Resources." & @CRLF)
					__ConsoleWrite("-    Ignoring all #AutoIt3Wrapper_* #directives that would normally update the MANIFEST section!" & @CRLF)
					$INP_Res_requestedExecutionLevel = ""
					$INP_Res_Compatibility = ""
				Else
					__ConsoleWrite("- Ignoring all #pragma Compile() statements for MANIFEST update because AutoIt3 version: " & $AUT2EXE_PGM_VER & " doesn't support it!" & @CRLF)
				EndIf
			EndIf
			;Update manifest
			If $INP_Res_requestedExecutionLevel <> "" Or $INP_Res_Compatibility <> "" Or $INP_RES_HiDpi <> "n" Then
				; enum RT_MANIFEST resources in target file
				If Not _EnumResourceNamesAndLangs($ScriptFile_Out, $RT_MANIFEST) Then
					; error, use default
					Write_RC_Console_Msg("Error: Failed to enumerate RT_MANIFEST resources, using defaults.", "", "!")
					Dim $aManifestInfo[2][2] = [[1, 0], [1, 1033]]
				Else
					$aManifestInfo = $g_aResNamesAndLangs
				EndIf
				$TempFile2 = __TempFile($TempDir, "RHManifest", "", ".txt")
				Local $hTempFile2 = FileOpen($TempFile2, 2)
				FileWriteLine($hTempFile2, '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
				FileWriteLine($hTempFile2, '<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0" xmlns:asmv3="urn:schemas-microsoft-com:asm.v3" >')
				FileWriteLine($hTempFile2, '')
				Local $tRes_requestedExecutionLevel = $INP_Res_requestedExecutionLevel
				If $tRes_requestedExecutionLevel = "" Then
					$tRes_requestedExecutionLevel = "asInvoker"
				Else
					Write_RC_Console_Msg("Setting Program ExecutionLevel Manifest information to " & $tRes_requestedExecutionLevel, "", "...", 0)
				EndIf
				If $tRes_requestedExecutionLevel <> "None" Then
					FileWriteLine($hTempFile2, '	<!-- Identify the application security requirements. -->')
					FileWriteLine($hTempFile2, '	<trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">')
					FileWriteLine($hTempFile2, '		<security>')
					FileWriteLine($hTempFile2, '			<requestedPrivileges>')
					FileWriteLine($hTempFile2, '				<requestedExecutionLevel')
					FileWriteLine($hTempFile2, ' 					level="' & $tRes_requestedExecutionLevel & '"')
					FileWriteLine($hTempFile2, '					uiAccess="false"')
					FileWriteLine($hTempFile2, '				/>')
					FileWriteLine($hTempFile2, '			</requestedPrivileges>')
					FileWriteLine($hTempFile2, '		</security>')
					FileWriteLine($hTempFile2, '	</trustInfo>')
					FileWriteLine($hTempFile2, '')
				EndIf
				FileWriteLine($hTempFile2, '	<!-- Identify the application dependencies. -->')
				FileWriteLine($hTempFile2, '	<dependency>')
				FileWriteLine($hTempFile2, '		<dependentAssembly>')
				FileWriteLine($hTempFile2, '			<assemblyIdentity')
				FileWriteLine($hTempFile2, '				type="win32"')
				FileWriteLine($hTempFile2, '				name="Microsoft.Windows.Common-Controls"')
				FileWriteLine($hTempFile2, '				version="6.0.0.0"')
				FileWriteLine($hTempFile2, '				language="*"')
				FileWriteLine($hTempFile2, '				processorArchitecture="*"')
				FileWriteLine($hTempFile2, '				publicKeyToken="6595b64144ccf1df"')
				FileWriteLine($hTempFile2, '			/>')
				FileWriteLine($hTempFile2, '		</dependentAssembly>')
				FileWriteLine($hTempFile2, '	</dependency>')
				FileWriteLine($hTempFile2, '')
				If $INP_RES_HiDpi <> "n" Then
					FileWriteLine($hTempFile2, '	<asmv3:application>')
					FileWriteLine($hTempFile2, '    	<asmv3:windowsSettings>')
					If $INP_RES_HiDpi = "p" Then
						Write_RC_Console_Msg("Setting DPI awareness Manifest information to true/PM", "", "...", 0)
						FileWriteLine($hTempFile2, '		<dpiAware xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">True/PM</dpiAware>')
						FileWriteLine($hTempFile2, '		<dpiAwareness xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">PerMonitorV2,PerMonitor</dpiAwareness>')
					Else
						Write_RC_Console_Msg("Setting DPI awareness Manifest information to true", "", "...", 0)
						FileWriteLine($hTempFile2, '		<dpiAware xmlns="http://schemas.microsoft.com/SMI/2005/WindowsSettings">True</dpiAware>')
					EndIf
					FileWriteLine($hTempFile2, '    	</asmv3:windowsSettings>')
					FileWriteLine($hTempFile2, '	</asmv3:application>')
					FileWriteLine($hTempFile2, '')
				EndIf
				; ----- reverted this change as it is giving some issues. Needs investigation
				; SET DEFAULT TO WIN10 when not specified
				If $INP_Res_Compatibility = "" Then $INP_Res_Compatibility = "Win10"
				If $INP_Res_Compatibility <> "ignore" Then
					FileWriteLine($hTempFile2, '	<compatibility xmlns="urn:schemas-microsoft-com:compatibility.v1">')
					FileWriteLine($hTempFile2, '		<application>')
					If StringInStr($INP_Res_Compatibility, "Win10") Then
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows Vista -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{e2011457-1546-43c5-a5fe-008deee3d3f0}"/>')
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows 7 -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{35138b9a-5d96-4fbd-8e2d-a2440225f93a}"/>')
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows 8 -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{4a2f28e3-53b9-4441-ba9c-d69d4a4a6e38}"/>')
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows 8.1 -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{1f676c76-80e1-4239-95bb-83d0f6d0da78}"/>')
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows 10 -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a}"/>')
						Write_RC_Console_Msg("Setting Program Compatibility Manifest information to Windows10", "", "...", 0)
					ElseIf StringInStr($INP_Res_Compatibility, "Win81") Then
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows Vista -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{e2011457-1546-43c5-a5fe-008deee3d3f0}"/>')
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows 7 -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{35138b9a-5d96-4fbd-8e2d-a2440225f93a}"/>')
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows 8 -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{4a2f28e3-53b9-4441-ba9c-d69d4a4a6e38}"/>')
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows 8.1 -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{1f676c76-80e1-4239-95bb-83d0f6d0da78}"/>')
						Write_RC_Console_Msg("Setting Program Compatibility Manifest information to Windows8.1", "", "...", 0)
					ElseIf StringInStr($INP_Res_Compatibility, "Win8") Then
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows Vista -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{e2011457-1546-43c5-a5fe-008deee3d3f0}"/>')
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows 7 -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{35138b9a-5d96-4fbd-8e2d-a2440225f93a}"/>')
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows 8 -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{4a2f28e3-53b9-4441-ba9c-d69d4a4a6e38}"/>')
						Write_RC_Console_Msg("Setting Program Compatibility Manifest information to Windows7", "", "...", 0)
					ElseIf StringInStr($INP_Res_Compatibility, "Windows7") Or StringInStr($INP_Res_Compatibility, "Win7") Then
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows Vista -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{e2011457-1546-43c5-a5fe-008deee3d3f0}"/>')
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows 7 -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{35138b9a-5d96-4fbd-8e2d-a2440225f93a}"/>')
						Write_RC_Console_Msg("Setting Program Compatibility Manifest information to Windows7", "", "...", 0)
					ElseIf StringInStr($INP_Res_Compatibility, "Vista") Then
						FileWriteLine($hTempFile2, '			<!--The ID below indicates application support for Windows Vista -->')
						FileWriteLine($hTempFile2, '			<supportedOS Id="{e2011457-1546-43c5-a5fe-008deee3d3f0}"/>')
						Write_RC_Console_Msg("Setting Program Compatibility Manifest information to Vista.", "", "...", 0)
					EndIf
					FileWriteLine($hTempFile2, '		</application>')
					FileWriteLine($hTempFile2, '	</compatibility>')
				EndIf
				;
				FileWriteLine($hTempFile2, '</assembly>')
				FileClose($hTempFile2)
				For $y = 1 To $aManifestInfo[0][0]
					$aTemp = StringSplit($aManifestInfo[$y][1], ",") ; create temp array of languages for this name
					For $z = 1 To $aTemp[0]
						; remove any manifest that is not 1 or our input language
						If ($aManifestInfo[$y][0] <> 1) Or ($aTemp[$z] <> $INP_Res_Language) Then _
								_Res_Update($rh, "", $RT_MANIFEST, $aManifestInfo[$y][0], $aTemp[$z])
					Next
				Next
				_Res_Update($rh, $TempFile2, $RT_MANIFEST, 1, $INP_Res_Language)
;~ 				__DelTempFile($TempFile2)
				Write_RC_Console_Msg("Updating Program Manifest information.", "", "...", 0)
			EndIf
			;
			; Add original source to Resources    $ScriptFile_In_Org
			If $INP_Res_SaveSource = "y" Then
				Local $tempfilein
				If $INP_Run_Au3Stripper = "y" Then
					FileCopy(StringTrimRight($ScriptFile_In, StringLen($ScriptFile_In_Ext)) & '_stripped' & $ScriptFile_In_Ext, $TempDir & "\scriptin.tmp", 1)
					Write_RC_Console_Msg("Adding stripped Script source to RT_RCDATA,999 in the Output executable.", "", "...", 0)
				Else
					$tempfilein = _TempFile($TempDir)
					FileCopy($ScriptFile_In, $tempfilein, 1)
					Write_RC_Console_Msg("Adding original Script source to RT_RCDATA,999 in the Output executable.", "", "...", 0)
					_Res_Update($rh, $tempfilein, $RT_RCDATA, 999, $INP_Res_Language)
					__DelTempFile($tempfilein)
				EndIf
			EndIf
			;
			; Add ICO's to Resources
			For $x = 1 To $INP_Icons_cnt
				$IconFileInfo = StringSplit($INP_Icons[$x], ",")
				ReDim $IconFileInfo[4]
				If StringStripWS($IconFileInfo[2], 3) = "" Then $IconFileInfo[2] = 200 + $x
				If StringStripWS($IconFileInfo[3], 3) = "" Then $IconFileInfo[3] = $INP_Res_Language
				_Res_Update($rh, StringStripWS($IconFileInfo[1], 3), $RT_ICON, StringStripWS($IconFileInfo[2], 3), StringStripWS($IconFileInfo[3], 3))
			Next
			If $INP_Icons_cnt Then Write_RC_Console_Msg("Adding " & $INP_Icons_cnt & " Icon(s).", "", "...", 0)
			; Add Cursor's to Resources
			For $x = 1 To $INP_Cursors_cnt
				$CursorFileInfo = StringSplit($INP_Cursors[$x], ",")
				ReDim $CursorFileInfo[4]
				If StringStripWS($CursorFileInfo[2], 3) = "" Then $CursorFileInfo[2] = 100 + $x
				If StringStripWS($CursorFileInfo[3], 3) = "" Then $CursorFileInfo[3] = $INP_Res_Language
				_Res_Update($rh, StringStripWS($CursorFileInfo[1], 3), $RT_CURSOR, StringStripWS($CursorFileInfo[2], 3), StringStripWS($CursorFileInfo[3], 3))
			Next
			If $INP_Cursors_cnt Then Write_RC_Console_Msg("Adding " & $INP_Cursors_cnt & " Cursor(s).", "", "...", 0)
			; Add Files to Resources, or Remove Resources
			Local $ResFileInfo, $Res_Update_cnt = 0
			For $x = 1 To $INP_Res_Files_Cnt
				$ResFileInfo = StringSplit($INP_Res_Files[$x], ",")
				ReDim $ResFileInfo[5]
				If $ResFileInfo[2] = "" Then $ResFileInfo[2] = $RT_MESSAGETABLE
				If $ResFileInfo[3] = "" Then $ResFileInfo[3] = $x
				If $ResFileInfo[4] = "" Then $ResFileInfo[4] = $INP_Res_Language
				$ResFileInfo[1] = StringReplace($ResFileInfo[1], "\", "\\")
				$ResFileInfo[1] = StringReplace($ResFileInfo[1], "/", "\\")
				$Res_Update_cnt += _Res_Update($rh, StringStripWS($ResFileInfo[1], 3), StringStripWS($ResFileInfo[2], 3), StringStripWS($ResFileInfo[3], 3), StringStripWS($ResFileInfo[4], 3))
			Next
			If $INP_Res_Files_Cnt Then Write_RC_Console_Msg("Adding / Removing " & $Res_Update_cnt & "/" & $INP_Res_Files_Cnt & " resource(s).", "", "...", 0)
			; pause a little to minimise issues around file in use before closing the resource updating
			Sleep(500)
			; end resource update
			Local $result = DllCall("kernel32.dll", "int", "EndUpdateResourceW", "ptr", $rh, "int", 0)
			If $result[0] <> 1 Then
				$Return_Text = "Error: EndUpdateResource: Returncode = " & $result[0] & " - LastError:" & _WinAPI_GetLastError() & ":" & StringReplace(_WinAPI_GetLastErrorMessage(), @CRLF, "")
				Write_RC_Console_Msg($Return_Text, 2)
				Write_RC_Console_Msg("Error: Program Resource updating Failed. The output program will not contain the Resource updates!", 2)
				Show_Warnings("Resource Update errors", $Return_Text)
			Else
				; append 'extra data' back to end of updated script
				If Not $ResUpdatePragmaSupported And Not _appendFileExtraData($ScriptFile_Out, $extraData, $dwSize) Then
					; something ELSE went wrong
					Write_RC_Console_Msg("Error: Failed to append script data to end of updated executable. Try recompiling your script.", 2)
					Exit
				Else
					$ResUpdateSuccess = 1
					Write_RC_Console_Msg("Program Resource updating finished successfully.", "")
				EndIf
			EndIf
		EndIf
	Else
		; Also update the source for a3x compile
		$INP_Fileversion = Valid_FileVersion($INP_Fileversion)
		; set default to success
		$ResUpdateSuccess = 1
	EndIf
	Return $ResUpdateSuccess
	;
EndFunc   ;==>Compile_Upd_res
;
Func Compile_UPX($ScriptFile_Out)
	; run UPX if asked, and if outfile is x86 EXE
	If StringRight($ScriptFile_Out, 4) = ".exe" Then
		Local $UPX_Pgm = $AUT2EXE_DIR & "\upx.exe"
		Local $PgmVer = FileGetVersion($UPX_Pgm)
;~ 		If $INP_Upx_Parameters = "" Then $INP_Upx_Parameters = "--best --compress-icons=0 -qq"
		If $INP_Upx_Parameters = "" Then $INP_Upx_Parameters = "--best --compress-icons=0 --keep-resource=10/SCRIPT"
		If FileExists($UPX_Pgm) Then
			__ConsoleWrite(">Running:(" & $PgmVer & "):" & $UPX_Pgm & '" ' & $INP_Upx_Parameters & ' "' & $ScriptFile_Out & '"' & @CRLF)
			$Pid = Run('"' & $UPX_Pgm & '" ' & $INP_Upx_Parameters & ' "' & $ScriptFile_Out & '"', "", @SW_HIDE, $STDOUT_CHILD)
			If $Pid Then
				$Handle = _ProcessExitCode($Pid)
				ProcessWaitClose($Pid)
				__ConsoleWrite(StdoutRead($Pid))
				StdioClose($Pid)
				$ExitCode = _ProcessExitCode($Pid, $Handle)
				_ProcessCloseHandle($Handle)
				Write_RC_Console_Msg("UPX Ended: ", $ExitCode)
			Else
				Write_RC_Console_Msg("Error: Failed to UPX the executable.", 2)
			EndIf
		Else
			Write_RC_Console_Msg("Error: " & $UPX_Pgm & " is missing.", 2)
		EndIf
	EndIf
EndFunc   ;==>Compile_UPX
;
Func Convert_RES_GenDirective($section, $kword, $directive, $Def_Value, $translate, ByRef $directives)
	Local $tarray = StringSplit($translate, ";")
	Local $value = IniRead($ScriptFile_In & ".ini", $section, $kword, $Def_Value)
	Local $varray
	For $x = 1 To $tarray[0]
		$varray = StringSplit($tarray[$x], "=")
		If $varray[0] > 1 And $varray[1] = $value Then $value = $varray[2]
	Next
	If $value = "" Or $value = $Def_Value Then Return
	$directives &= $directive & "=" & IniRead($ScriptFile_In & ".ini", $section, $kword, $Def_Value) & @CRLF
EndFunc   ;==>Convert_RES_GenDirective
;
Func Convert_RES_INI_to_Directives()
	Local $directives = "#Region converted Directives from " & $ScriptFile_In & ".ini" & @CRLF
	Convert_RES_GenDirective("AutoIt", "aut2exe", "#AutoIt3Wrapper_aut2exe", "", "", $directives)
	Convert_RES_GenDirective("AutoIt", "icon", "#AutoIt3Wrapper_Icon", "", "", $directives)
	Convert_RES_GenDirective("AutoIt", "outfile", "#AutoIt3Wrapper_outfile", "", "", $directives)
	Convert_RES_GenDirective("AutoIt", "Compression", "#AutoIt3Wrapper_Compression", "2", "", $directives)
	Convert_RES_GenDirective("AutoIt", "PassPhrase", "#AutoIt3Wrapper_PassPhrase", "", "", $directives)
	Convert_RES_GenDirective("AutoIt", "UseUpx", "#AutoIt3Wrapper_UseUpx", "y", "1=y;0=n;4=n", $directives)
	Convert_RES_GenDirective("AutoIt", "UseAnsi", "#AutoIt3Wrapper_UseAnsi", "n", "1=y;0=n;4=n", $directives)
	Convert_RES_GenDirective("AutoIt", "UseX64", "#AutoIt3Wrapper_UseX64", "n", "1=y;0=n;4=n", $directives)
	Convert_RES_GenDirective("AutoIt", "Allow_Decompile", "#AutoIt3Wrapper_Allow_Decompile", "y", "1=y;0=n;4=n", $directives)
	;
	Convert_RES_GenDirective("Res", "Comment", "#AutoIt3Wrapper_Res_Comment", "", "", $directives)
	Convert_RES_GenDirective("Res", "Description", "#AutoIt3Wrapper_Res_Description", "", "", $directives)
	Convert_RES_GenDirective("Res", "Fileversion", "#AutoIt3Wrapper_Res_Fileversion", "", "", $directives)
	Convert_RES_GenDirective("Res", "Fileversion_AutoIncrement", "#AutoIt3Wrapper_Res_Fileversion_AutoIncrement", "", "", $directives)
	Convert_RES_GenDirective("Res", "Fileversion_First_AutoIncrement", "#AutoIt3Wrapper_Res_Fileversion_First_Increment", "", "", $directives)
	Convert_RES_GenDirective("Res", "Fileversion_Use_Template", "#AutoIt3Wrapper_Res_Fileversion_Use_Template", "", "", $directives)
	Convert_RES_GenDirective("Res", "ProductName", "#AutoIt3Wrapper_Res_ProductName", "", "", $directives)
	Convert_RES_GenDirective("Res", "ProductVersion", "#AutoIt3Wrapper_Res_ProductVersion", "", "", $directives)
	Convert_RES_GenDirective("Res", "LegalCopyright", "#AutoIt3Wrapper_Res_LegalCopyright", "", "", $directives)
	Convert_RES_GenDirective("Res", "Field1Name", "#AutoIt3Wrapper_Res_Field1Name", "", "", $directives)
	Convert_RES_GenDirective("Res", "Field2Name", "#AutoIt3Wrapper_Res_Field2Name", "", "", $directives)
	Convert_RES_GenDirective("Res", "Field1Value", "#AutoIt3Wrapper_Res_Field1Value", "", "", $directives)
	Convert_RES_GenDirective("Res", "Field2Value", "#AutoIt3Wrapper_Res_Field2Value", "", "", $directives)
	;
	Convert_RES_GenDirective("Other", "Run_AU3Check", "#AutoIt3Wrapper_Run_AU3Check", "y", "1=y;0=n;4=n", $directives)
	Convert_RES_GenDirective("Other", "AU3Check_Stop_OnWarning", "#AutoIt3Wrapper_AU3Check_Stop_OnWarning", "", "", $directives)
	Convert_RES_GenDirective("Other", "AU3Check_Parameter", "#AutoIt3Wrapper_AU3Check_Parameters", "", "", $directives)
	Convert_RES_GenDirective("Other", "Run_Before", "#AutoIt3Wrapper_Run_Before", "", "", $directives)
	Convert_RES_GenDirective("Other", "Run_After", "#AutoIt3Wrapper_Run_After", "", "", $directives)
	Convert_RES_GenDirective("Other", "Run_Versioning", "#AutoIt3Wrapper_Run_CVSWrapper", "", "", $directives)
	Convert_RES_GenDirective("Other", "VersionWrapper_Parameter", "#AutoIt3Wrapper_CVSWrapper_Parameters", "", "", $directives)
	Convert_RES_GenDirective("Other", "Run_Versioning", "#AutoIt3Wrapper_Versioning", "", "", $directives)
	Convert_RES_GenDirective("Other", "VersionWrapper_Parameter", "#AutoIt3Wrapper_Versioning_Parameters", "", "", $directives)
	;
	$directives &= "#EndRegion converted Directives from " & $ScriptFile_In & ".ini" & @CRLF & ";" & @CRLF
	$directives &= FileRead($ScriptFile_In)
	Local $Fh = FileOpen($ScriptFile_In, 2 + $SrceUnicodeFlag)
	FileWrite($Fh, $directives)
	FileClose($Fh)
	FileRecycle($ScriptFile_In & ".ini")
	__ConsoleWrite('->================================================================================================================' & @CRLF)
	__ConsoleWrite('->File:' & $ScriptFile_In & ".ini" & @CRLF)
	__ConsoleWrite('-> converted to #Directives at the top of the script and the file put into the recycleBin.' & @CRLF)
	__ConsoleWrite('->================================================================================================================' & @CRLF)
EndFunc   ;==>Convert_RES_INI_to_Directives
;
; Update Variables in a string.
Func Convert_Variables($I_String, $text = 0)
	$I_String = StringReplace($I_String, "%in%", $ScriptFile_In_Org)
	$I_String = StringReplace($I_String, "%out%", $ScriptFile_Out)
	$I_String = StringReplace($I_String, "%outx64%", $ScriptFile_Out_x64)
	$I_String = StringReplace($I_String, "%usex64%", $INP_UseX64)
	$I_String = StringReplace($I_String, "%icon%", $INP_Icon)
	$I_String = StringReplace($I_String, "%fileversion%", $INP_Fileversion)
	$I_String = StringReplace($I_String, "%fileversionnew%", $INP_Fileversion_New)
	Local $ScriptName = StringTrimLeft($ScriptFile_In_Org, StringInStr($ScriptFile_In_Org, "\", 0, -1))
	Local $ScriptDir = StringLeft($ScriptFile_In_Org, StringInStr($ScriptFile_In_Org, "\", 0, -1) - 1)
	$I_String = StringReplace($I_String, "%scriptfile%", StringReplace($ScriptName, $ScriptFile_In_Ext, ''))
	$I_String = StringReplace($I_String, "%scriptdir%", $ScriptDir)
	$I_String = StringReplace($I_String, "%scitedir%", $SciTE_Dir)
	$I_String = StringReplace($I_String, "%autoitdir%", $CurrentAutoIt_InstallDir)
	$I_String = StringReplace($I_String, "%AutoItVer%", $AUT2EXE_PGM_VER)
	$I_String = StringReplace($I_String, "%Date%", _NowDate())
	$I_String = StringReplace($I_String, "%LongDate%", _DateTimeFormat(_NowCalcDate(), 1))
	$I_String = StringReplace($I_String, "%Time%", _NowTime())
	; These should only be done on text Items, strings containing a File/Path will give problems
	If $text Then
		$I_String = StringReplace($I_String, "\n", @CRLF)
	EndIf
	; translater any environment variable in Directives
	$I_String = _WinAPI_ExpandEnvironmentStrings($I_String)
	;
	Return $I_String
EndFunc   ;==>Convert_Variables
;
Func IS_INTRESOURCE($r)
	Return (Not BitAND($r, 0xFFFF0000))
EndFunc   ;==>IS_INTRESOURCE
;
;
;
Func Language_Code(ByRef $code, ByRef $CountryTable, ByRef $Country, $task = 1)
	Local $CountryArray[120][2] = [["Afrikaans", "1078"], ["Albanian", "1052"], ["Arabic (Algeria)", "5121"], ["Arabic (Bahrain)", "15361"], _
			["Arabic (Egypt)", "3073"], ["Arabic (Iraq)", "2049"], ["Arabic (Jordan)", "11265"], ["Arabic (Kuwait)", "13313"], ["Arabic (Lebanon)", "12289"], _
			["Arabic (Libya)", "4097"], ["Arabic (Morocco)", "6145"], ["Arabic (Oman)", "8193"], ["Arabic (Qatar)", "16385"], ["Arabic (Saudi Arabia)", "1025"], _
			["Arabic (Syria)", "10241"], ["Arabic (Tunisia)", "7169"], ["Arabic (U.A.E.)", "14337"], ["Arabic (Yemen)", "9217"], ["Basque", "1069"], _
			["Belarusian", "1059"], ["Bulgarian", "1026"], ["Catalan", "1027"], ["Chinese (Hong Kong SAR)", "3076"], ["Chinese (PRC)", "2052"], _
			["Chinese (Singapore)", "4100"], ["Chinese (Taiwan)", "1028"], ["Croatian", "1050"], ["Czech", "1029"], ["Danish", "1030"], _
			["Dutch", "1043"], ["Dutch (Belgium)", "2067"], ["English (Australia)", "3081"], ["English (Belize)", "10249"], ["English (Canada)", "4105"], _
			["English (Ireland)", "6153"], ["English (Jamaica)", "8201"], ["English (New Zealand)", "5129"], ["English (South Africa)", "7177"], _
			["English (Trinidad)", "11273"], ["English (United Kingdom)", "2057"], ["English (United States)", "1033"], ["Estonian", "1061"], _
			["Faeroese", "1080"], ["Farsi", "1065"], ["Finnish", "1035"], ["French (Standard)", "1036"], ["French (Belgium)", "2060"], _
			["French (Canada)", "3084"], ["French (Luxembourg)", "5132"], ["French (Switzerland)", "4108"], ["Gaelic (Scotland)", "1084"], _
			["German (Standard)", "1031"], ["German (Austrian)", "3079"], ["German (Liechtenstein)", "5127"], ["German (Luxembourg)", "4103"], _
			["German (Switzerland)", "2055"], ["Greek", "1032"], ["Hebrew", "1037"], ["Hindi", "1081"], ["Hungarian", "1038"], ["Icelandic", "1039"], _
			["Indonesian", "1057"], ["Italian (Standard)", "1040"], ["Italian (Switzerland)", "2064"], ["Japanese", "1041"], ["Korean", "1042"], _
			["Latvian", "1062"], ["Lithuanian", "1063"], ["Macedonian (FYROM)", "1071"], ["Malay (Malaysia)", "1086"], ["Maltese", "1082"], _
			["Norwegian (Bokmål)", "1044"], ["Polish", "1045"], ["Portuguese (Brazil)", "1046"], ["Portuguese (Portugal)", "2070"], _
			["Raeto (Romance)", "1047"], ["Romanian", "1048"], ["Romanian (Moldova)", "2072"], ["Russian", "1049"], ["Russian (Moldova)", "2073"], _
			["Serbian (Cyrillic)", "3098"], ["Setsuana", "1074"], ["Slovak", "1051"], ["Slovenian", "1060"], ["Sorbian", "1070"], _
			["Spanish (Argentina)", "11274"], ["Spanish (Bolivia)", "16394"], ["Spanish (Chile)", "13322"], ["Spanish (Columbia)", "9226"], _
			["Spanish (Costa Rica)", "5130"], ["Spanish (Dominican Republic)", "7178"], ["Spanish (Ecuador)", "12298"], ["Spanish (El Salvador)", "17418"], _
			["Spanish (Guatemala)", "4106"], ["Spanish (Honduras)", "18442"], ["Spanish (Mexico)", "2058"], ["Spanish (Nicaragua)", "19466"], _
			["Spanish (Panama)", "6154"], ["Spanish (Paraguay)", "15370"], ["Spanish (Peru)", "10250"], ["Spanish (Puerto Rico)", "20490"], _
			["Spanish (Spain)", "1034"], ["Spanish (Uruguay)", "14346"], ["Spanish (Venezuela)", "8202"], ["Sutu", "1072"], _
			["Swedish", "1053"], ["Swedish (Finland)", "2077"], ["Thai", "1054"], ["Turkish", "1055"], ["Tsonga", "1073"], _
			["Ukranian", "1058"], ["Urdu (Pakistan)", "1056"], ["Vietnamese", "1066"], ["Xhosa", "1076"], ["Yiddish", "1085"], ["Zulu", "1077"]]
	$CountryTable = ""
	If $task = 1 And $code = 0 Then $code = 2057
	If $task = 2 And $Country = "" Then
		$code = 2057
		Return
	EndIf
	For $x = 0 To UBound($CountryArray) - 1
		Switch $task
			Case 1
				If $CountryArray[$x][0] <> "" Then
					$CountryTable &= $CountryArray[$x][0] & "|"
					If $CountryArray[$x][1] = $code Then
						$Country = $CountryArray[$x][0]
					EndIf
				EndIf
			Case 2
				If $CountryArray[$x][0] = $Country Then
					$code = $CountryArray[$x][1]
					ExitLoop
				EndIf
		EndSwitch
	Next
	; Default to UK English when specified name isn't found
	If $task = 2 And $code = 0 Then $code = 2057
EndFunc   ;==>Language_Code
;
Func OnAutoItExit()
	; only show this line for main script run not the Watcher
	SciTE_RestoreSession($ScriptFile_In)
	If StringInStr($CMDLINERAW, "/runadmin") Then
		__ConsoleWrite("-##<" & @HOUR & ":" & @MIN & ":" & @SEC & " #RequireAdmin AutoIt3Wrapper run of script Finished." & @CRLF)
	ElseIf Not StringInStr($CMDLINERAW, "/watcher") _
			And Not StringInStr($CMDLINERAW, "/au3record") _
			And Not StringInStr($CMDLINERAW, "/au3info") _
			And Not StringInStr($CMDLINERAW, "/Jump2FirstError") _
			Then
		Write_RC_Console_Msg("AutoIt3Wrapper Finished.", "", "+")
	EndIf
	; delete any used tempfiles
	__DelTempFile($TempConsOut)
	; Remove tempfiles when special characters are in path or filename
	If FileExists(@TempDir & "\AutoIt3WrapperRunTmpFiles") Then
		$rc = FileDelete(@TempDir & "\AutoIt3WrapperRunTmpFiles\*.*")
		$rc = DirRemove(@TempDir & "\AutoIt3WrapperRunTmpFiles", 1)
	EndIf
EndFunc   ;==>OnAutoItExit
;
; Retrieve the compiler settings from the scriptfile when available
Func Retrieve_PreProcessor_Info()
	; Reset the Res counter
	Local $I_Rec
	Local $In_File
	Local $hTest_UTF = FileOpen($ScriptFile_In, 16)
	Local $Test_UTF = FileRead($hTest_UTF, 4)
	Local $i_Rec_Param, $i_Rec_Value, $Temp_Val
	FileClose($hTest_UTF)
	$INP_Run_Before[0] = 0
	$INP_Run_After[0] = 0
	$INP_Icons_cnt = 0
	$INP_Cursors_cnt = 0
	$INP_Res_Files_Cnt = 0
	$INP_Res_FieldCount = 0
;~ 00 00 FE FF UTF-32, big-endian
;~ FF FE 00 00 UTF-32, little-endian
;~ FE FF UTF-16, big-endian
;~ FF FE UTF-16, little-endian
;~ EF BB BF UTF-8
	Select
		Case BinaryMid($Test_UTF, 1, 4) = '0x0000FEFF'               ; UTF-32 BE
			$UTFtype = '32BE'
			$SrceUnicodeFlag = 0
			$InputFileIsUTF32 = 1
		Case BinaryMid($Test_UTF, 1, 4) = '0xFFFE0000'               ; UTF-32 LE
			$UTFtype = '32LE'
			$SrceUnicodeFlag = 0
			$InputFileIsUTF32 = 1
		Case BinaryMid($Test_UTF, 1, 2) = '0xFEFF'                   ; UTF-16 BE
			$UTFtype = '16BE'
			$SrceUnicodeFlag = 64
			$InputFileIsUTF16 = 1
		Case BinaryMid($Test_UTF, 1, 2) = '0xFFFE'                   ; UTF-16 LE
			$UTFtype = '16LE'
			$SrceUnicodeFlag = 32
			$InputFileIsUTF16 = 1
		Case BinaryMid($Test_UTF, 1, 3) = '0xEFBBBF'                 ; UTF-8
			$UTFtype = '8'
			$SrceUnicodeFlag = 128
			$InputFileIsUTF8 = 1
		Case Else
			$UTFtype = ''
			$SrceUnicodeFlag = FileGetEncoding($ScriptFile_In, 1)
			$InputFileIsUTF8 = 0
			$InputFileIsUTF16 = 0
			$InputFileIsUTF32 = 0
	EndSelect
	; -------------------------------------------------------------------------------------------------------------------------------------------------------------
	Local $aFile
	Local $hFile = FileOpen($ScriptFile_In, 16384)
	If $hFile = -1 Then Return SetError(1, 0, 0)                     ;; unable to open the file
	; Read the file and dump into an Array and also check if the Filesize is different from the Read Characters which will be an indication of UTF8 without BOM
	Local $aFile_tot = FileRead($hFile)
;~ 	Local $aFile_len = @extended
	FileClose($hFile)
	; build Array
	If StringInStr($aFile_tot, @LF) Then
		$In_File = StringSplit(StringStripCR($aFile_tot), @LF)
	ElseIf StringInStr($aFile, @CR) Then                             ;; @LF does not exist so split on the @CR
		$In_File = StringSplit($aFile_tot, @CR)
	Else                                                             ;; unable to split the file
		If StringLen($aFile_tot) Then
			$aFile_tot &= @LF
			$In_File = StringSplit(StringStripCR($aFile_tot), @LF)
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf
	; -------------------------------------------------------------------------------------------------------------------------------------------------------------
	;
	Local $CommentBlock = False
	For $rcount = 1 To $In_File[0]
		$I_Rec = $In_File[$rcount]
		$I_Rec = StringStripWS($I_Rec, 1)
		; Ignore commentblocks
		If StringLeft($I_Rec, 3) = "#CS" Or StringLeft($I_Rec, 13) = "Comment_Start" Then $CommentBlock = True
		If StringLeft($I_Rec, 3) = "#CE" Or StringLeft($I_Rec, 11) = "Comment_End" Then $CommentBlock = False
		If $CommentBlock Then ContinueLoop
		; Ignore momented lines
		If StringLeft($I_Rec, 1) = ";" Then ContinueLoop
		; Read the Pragma Lines for later processing&decisions
		If StringLeft($I_Rec, 8) = "#Pragma " Then
;~ 			$Pragma_Used = 1
			Local $PragmaOption = StringRegExp($I_Rec, "(?i)#pragma\h+compile\h*\(\h*(.*?)\h*[,]\h*(.*?)\h*\)", 3)
			If Not @error Then
				If UBound($PragmaOption) < 2 Then ReDim $PragmaOption[2] ; avoid errors in case the parameter is not read fully.
				Switch $PragmaOption[0]
					Case "out"
						$Pragma_Out = $PragmaOption[1]
					Case "Icon"
						$Pragma_Icon = $PragmaOption[1]
					Case "ExecLevel"
						$Pragma_RES_requestedExecutionLevel = $PragmaOption[1]
					Case "UPX"
						$Pragma_UseUpx = $PragmaOption[1]
					Case "Console"
						$Pragma_Change2CUI = $PragmaOption[1]
					Case "Compression"
						$Pragma_Compression = $PragmaOption[1]
					Case "Compatibility"
						$Pragma_RES_Compatibility = $PragmaOption[1]
					Case "x64"
						$Pragma_Out_x64 = $PragmaOption[1]
					Case "inputboxres"
						;$pragma_ = $PragmaOption[1]
					Case "Comments"
						$Pragma_Comment = $PragmaOption[1]
					Case "CompanyName"
						$Pragma_CompanyName = $PragmaOption[1]
					Case "FileDescription"
						$Pragma_Description = $PragmaOption[1]
					Case "FileVersion"
						$Pragma_Fileversion = $PragmaOption[1]
					Case "InternalName"
						$Pragma_InternalName = $PragmaOption[1]
					Case "LegalCopyright"
						$Pragma_LegalCopyright = $PragmaOption[1]
					Case "LegalTrademarks"
						$Pragma_LegalTradeMarks = $PragmaOption[1]
					Case "OriginalFilename"
;~ 						$Pragma_ = $PragmaOption[1]
					Case "ProductName"
						$Pragma_Productname = $PragmaOption[1]
					Case "ProductVersion"
						$Pragma_ProductVersion = $PragmaOption[1]
					Case "AutoItExecuteAllowed"
						; Ignore
					Case Else
						__ConsoleWrite("- #pragma directive " & $PragmaOption[0] & " found but don't understand it so will ignore: " & $I_Rec & @CRLF)
				EndSwitch
				ContinueLoop
			EndIf
		EndIf
		; Show Consolemessage about running a script that required elevated rights not displaying anuy console messages
		If $Option = "Run" And $I_Rec = "#RequireAdmin" And Not IsAdmin() Then
			$Shell_RQA_Diff = 1
		EndIf
		;
		If StringLeft($I_Rec, 16) <> "#AutoIt3Wrapper_" _
				And StringLeft($I_Rec, 5) <> "#Run_" _
				And StringLeft($I_Rec, 6) <> "#Tidy_" _
				And StringLeft($I_Rec, 12) <> "#Obfuscator_" _
				And StringLeft($I_Rec, 13) <> "#Au3Stripper_" _
				Then ContinueLoop
		If StringInStr($I_Rec, ";") Then
			$I_Rec = StringLeft($I_Rec, StringInStr($I_Rec, ";") - 1)
		EndIf
		$I_Rec = StringStripWS($I_Rec, 3)
		$i_Rec_Param = StringLeft($I_Rec, StringInStr($I_Rec & "=", "=") - 1)
		$i_Rec_Param = StringStripWS($i_Rec_Param, 3)
		$i_Rec_Value = StringTrimLeft($I_Rec, StringInStr($I_Rec, "="))
		$i_Rec_Value = StringStripWS($i_Rec_Value, 3)
		; we added AutoIt3Wrapper_ for clearity to the compiler directives.
		If StringLeft($I_Rec, 12) = "#Obfuscator_" Then
			$Found_Old_ObfuscatorDirective = 1
			$i_Rec_Param = StringReplace($i_Rec_Param, "#Obfuscator", "#Au3Stripper")
		EndIf
		If StringLeft($I_Rec, 30) = "#AutoIt3Wrapper_Run_Obfuscator" Then
			$Found_Old_ObfuscatorDirective = 1
			$i_Rec_Param = StringReplace($i_Rec_Param, "#AutoIt3Wrapper_Run_Obfuscator", "#AutoIt3Wrapper_Run_Au3Stripper")
		EndIf
		Select
			; ================ Other  =========================================================================
			Case $i_Rec_Param = "#Au3Stripper_Parameters"
				$INP_Au3Stripper_Parameters = $i_Rec_Value
			Case StringLeft($I_Rec, 13) = "#Au3Stripper_"
				; skip other #Au3Stripper directives
			Case $i_Rec_Param = "#Tidy_Parameters"
				If $INP_AutoIt3Wrapper_If = "" Or $INP_AutoIt3Wrapper_If = $Option Then $INP_Tidy_Parameters = $i_Rec_Value
			Case StringLeft($I_Rec, 6) = "#Tidy_"
				; skip #Tidy directives
				; ================ AutoIt3/Aut2EXE  =========================================================================
			Case $i_Rec_Param = "#AutoIt3Wrapper_ShowProgress"
				$INP_ShowStatus = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Testing"
				$INP_AutoIt3Wrapper_Testing = $i_Rec_Value
				If $INP_AutoIt3Wrapper_Testing = "y" Then
					__ConsoleWrite("! Found #AutoIt3Wrapper_Testing=y directive => skipping Tidy, Au3Stripper, versionResourceupdate and Versioning for speed." & @CRLF)
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_If_Run"
				$INP_AutoIt3Wrapper_If = "Run"
				If $ShowGUI Then
					$ShowGUI = 0
					__ConsoleWrite("! *************************************************************************" & @CRLF)
					__ConsoleWrite("! * GUI mode not supported in combination with #AutoIt3Wrapper_If_Run     *" & @CRLF)
					__ConsoleWrite("! *************************************************************************" & @CRLF)
					Exit
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_If_AU3Check"
				$INP_AutoIt3Wrapper_If = "AU3Check"
				If $ShowGUI Then
					$ShowGUI = 0
					__ConsoleWrite("! ******************************************************************************" & @CRLF)
					__ConsoleWrite("! * GUI mode not supported in combination with #AutoIt3Wrapper_If_AU3Check     *" & @CRLF)
					__ConsoleWrite("! ******************************************************************************" & @CRLF)
					Exit
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_If_Compile"
				$INP_AutoIt3Wrapper_If = "Compile"
				If $ShowGUI Then
					$ShowGUI = 0
					__ConsoleWrite("! *****************************************************************************" & @CRLF)
					__ConsoleWrite("! * GUI mode not supported in combination with #AutoIt3Wrapper_If_Compile     *" & @CRLF)
					__ConsoleWrite("! *****************************************************************************" & @CRLF)
					Exit
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_EndIf"
				$INP_AutoIt3Wrapper_If = ""
			Case $i_Rec_Param = "#AutoIt3Wrapper_LogFile"
				$INP_AutoIt3Wrapper_LogFile = StringReplace($i_Rec_Value, '"', '')
			Case $i_Rec_Param = "#AutoIt3Wrapper_Prompt"
				; Obsolete..... Only override the command line when an actual value is given
			Case $i_Rec_Param = "#AutoIt3Wrapper_Compile_both"
				$INP_Compile_Both = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_OutFile"
				$ScriptFile_Out = Convert_Variables(StringReplace($i_Rec_Value, '"', ''))
			Case $i_Rec_Param = "#AutoIt3Wrapper_OutFile_x64"
				$ScriptFile_Out_x64 = Convert_Variables(StringReplace($i_Rec_Value, '"', ''))
			Case $i_Rec_Param = "#AutoIt3Wrapper_OutFile_x86"
				$ScriptFile_Out_x86 = Convert_Variables(StringReplace($i_Rec_Value, '"', ''))
			Case $i_Rec_Param = "#AutoIt3Wrapper_OutFile_Type"
				$ScriptFile_Out_Type = $i_Rec_Value
				If $ScriptFile_Out_Type <> "A3X" And $ScriptFile_Out_Type <> "EXE" Then
					$ScriptFile_Out_Type = ""
					__ConsoleWrite("- Skipping #AutoIt3Wrapper_OutFile_Type directive. Invalid type:" & $i_Rec_Value & ". Can only be A3X or EXE" & @CRLF)
				Else
					; Only use the "#AutoIt3Wrapper_OutFile_Type" when "#AutoIt3Wrapper_OutFile" isn't given
					If $ScriptFile_Out = "" Then
						$ScriptFile_Out = StringTrimRight($ScriptFile_In, StringLen($ScriptFile_In_Ext)) & '.' & $ScriptFile_Out_Type
					EndIf
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Icon"
				$INP_Icon = StringReplace($i_Rec_Value, '"', '')
				$DebugIcon = $DebugIcon & "Comp directive icon: " & $INP_Icon & @CRLF
			Case $i_Rec_Param = "#AutoIt3Wrapper_Compression"
				$INP_Compression = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Version"
				If $i_Rec_Value = "b" Or $i_Rec_Value = "Beta" Then
					$INP_AutoIt3_Version = "Beta"
				ElseIf $i_Rec_Value = "a" Or $i_Rec_Value = "Alpha" Then
					$INP_AutoIt3_Version = "Alpha"
				Else
					$INP_AutoIt3_Version = "prod"
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_AutoIt3Dir"
				If StringReplace($i_Rec_Value, '"', '') <> "" Then
					$INP_AutoItDir = StringReplace($i_Rec_Value, '"', '')
					If Not FileExists($INP_AutoItDir) Or Not StringInStr(FileGetAttrib($INP_AutoItDir), "D") Then
						__ConsoleWrite("! Skipping #AutoIt3Wrapper_AutoIt3Dir because the Directory is not found.  Specified:" & $INP_AutoItDir & @CRLF)
						$INP_AutoItDir = ""
					ElseIf Not FileExists($INP_AutoItDir & "\Autoit3.exe") Then
						__ConsoleWrite("! Skipping #AutoIt3Wrapper_AutoIt3Dir because the Directory doesn't contain AutoIt3.exe.   specified:" & $INP_AutoItDir & @CRLF)
						$INP_AutoItDir = ""
					EndIf
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_AutoIt3"
				If StringReplace($i_Rec_Value, '"', '') <> "" Then
					$AutoIt3_PGM = StringReplace($i_Rec_Value, '"', '')
					If Not FileExists($AutoIt3_PGM) Then
						__ConsoleWrite("- Skipping #AutoIt3Wrapper_AutoIt3 because the file is not found:" & $AutoIt3_PGM & @CRLF)
						$AutoIt3_PGM = ""
					EndIf
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_AU3Check_Dat"
				; Obsolete..... Only override the command line when an actual value is given
			Case $i_Rec_Param = "#AutoIt3Wrapper_AUT2EXE"
				If StringReplace($i_Rec_Value, '"', '') <> "" Then
					$AUT2EXE_PGM = StringReplace($i_Rec_Value, '"', '')
					If Not FileExists($AUT2EXE_PGM) Then
						__ConsoleWrite("- Skipping #AutoIt3Wrapper_AUT2EXE because the file is not found:" & $AUT2EXE_PGM & @CRLF)
						$AUT2EXE_PGM = ""
					EndIf
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_UseUpx"
				$INP_UseUpx = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_UPX_Parameters"
				$INP_Upx_Parameters = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_UseAnsi"
				__ConsoleWrite("- Skipping #AutoIt3Wrapper_UseAnsi directive because ANSI is not supported anymore." & @CRLF)
				$INP_UseAnsi = "N"
			Case $i_Rec_Param = "#AutoIt3Wrapper_UseX64"
				$INP_UseX64 = $i_Rec_Value
			Case $i_Rec_Param = "#Run_Debug_Mode" Or $i_Rec_Param = "#AutoIt3Wrapper_Run_Debug_Mode"
				If $i_Rec_Value = "y" Or $i_Rec_Value = 1 Then $INP_Run_Debug_Mode = 1
			Case $i_Rec_Param = "#AutoIt3Wrapper_run_debug"
				; debug on or off direction
				; ================ Resources  =========================================================================
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Language"
				$INP_Res_Language = Number($i_Rec_Value)
				If $INP_Res_Language = 0 Then $INP_Res_Language = 2057
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Comment"
				$INP_Comment = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_CompanyName"
				$INP_CompanyName = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Description"
				$INP_Description = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Fileversion"
				$INP_Fileversion = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_FileVersion_AutoIncrement"
				$INP_Fileversion_AutoIncrement = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Fileversion_First_Increment"
				$INP_Fileversion_First_Increment = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Fileversion_Use_Template"
				$INP_Fileversion_Use_Template = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_ProductName"
				$INP_ProductName = Convert_Variables($i_Rec_Value)
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_ProductVersion"
				$INP_ProductVersion = Convert_Variables($i_Rec_Value)
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_LegalCopyright"
				$INP_LegalCopyright = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_LegalTradeMarks"
				$INP_LegalTradeMarks = $i_Rec_Value
				; limited number of free format resource info fields
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Icon_Add"
				If $i_Rec_Value <> "" Then
					$INP_Icons_cnt += 1
					ReDim $INP_Icons[$INP_Icons_cnt + 1]
					$INP_Icons[$INP_Icons_cnt] = Convert_Variables(StringReplace($i_Rec_Value, '"', ''))
					$IconFileInfo = StringSplit($INP_Icons[$INP_Icons_cnt], ",")
					If Not FileExists($IconFileInfo[1]) Then
						__ConsoleWrite('- => Skipping #AutoIt3Wrapper_Res_Icon_Add because the Ico file is not found:"' & $INP_Icons[$INP_Icons_cnt] & '"' & @CRLF)
						$INP_Icons_cnt -= 1
					EndIf
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Cursor_Add"
				If $i_Rec_Value <> "" Then
					$INP_Cursors_cnt += 1
					ReDim $INP_Cursors[$INP_Cursors_cnt + 1]
					$INP_Cursors[$INP_Cursors_cnt] = Convert_Variables(StringReplace($i_Rec_Value, '"', ''))
					$CursorFileInfo = StringSplit($INP_Cursors[$INP_Cursors_cnt], ",")
					If Not FileExists($CursorFileInfo[1]) Then
						__ConsoleWrite('- => Skipping #AutoIt3Wrapper_Res_Cursor_Add because the Cursor file is not found:"' & $INP_Cursors[$INP_Cursors_cnt] & '"' & @CRLF)
						$INP_Cursors_cnt -= 1
					EndIf
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_File_Add"
				If $i_Rec_Value <> "" Then
					$INP_Res_Files_Cnt += 1
					ReDim $INP_Res_Files[$INP_Res_Files_Cnt + 1]
					$INP_Res_Files[$INP_Res_Files_Cnt] = Convert_Variables(StringReplace($i_Rec_Value, '"', ''))
					Local $ResFileInfo
					$ResFileInfo = StringSplit($INP_Res_Files[$INP_Res_Files_Cnt], ",")
					If Not FileExists($ResFileInfo[1]) Then
						__ConsoleWrite("- Skipping #AutoIt3Wrapper_Res_File_Add because the file is not found:" & $INP_Res_Files[$INP_Res_Files_Cnt] & @CRLF)
						$INP_Res_Files_Cnt -= 1
					EndIf
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Remove"
				If $i_Rec_Value <> "" Then
					$INP_Res_Files_Cnt += 1
					ReDim $INP_Res_Files[$INP_Res_Files_Cnt + 1]
					; add leading ',' so StringSplit during later processing creates empty array value
					; an empty value for input will remove the resource
					$INP_Res_Files[$INP_Res_Files_Cnt] = Convert_Variables(StringReplace("," & $i_Rec_Value, '"', ''))
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_SaveSource"
				$INP_Res_SaveSource = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Field"
				$Temp_Val = StringSplit($i_Rec_Value, "|")
				If $INP_Res_FieldCount > 14 Then
					__ConsoleWrite("- Skipping #AutoIt3Wrapper_Res_Field directive. You can only have 15 field max:" & $i_Rec_Value & @CRLF)
				ElseIf $Temp_Val[0] <> 2 Then
					__ConsoleWrite("- Skipping #AutoIt3Wrapper_Res_Field directive. Doesn't have a | in it:" & $i_Rec_Value & @CRLF)
				Else
					$INP_Res_FieldCount += 1
					$INP_FieldName[$INP_Res_FieldCount] = $Temp_Val[1]
					$INP_FieldValue[$INP_Res_FieldCount] = $Temp_Val[2]
				EndIf
				; Old format for Resource fields
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Field1Value"
				$INP_FieldValue1 = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Field1Name"
				$INP_FieldName1 = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Field2Value"
				$INP_FieldValue2 = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Field2Name"
				$INP_FieldName2 = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_requestedExecutionLevel"
				;None, asInvoker, highestAvailable or requireAdministrator   (default=None)"
				Switch $i_Rec_Value
					Case ""
						$INP_Res_requestedExecutionLevel = ""
					Case "asInvoker", "highestAvailable", "requireAdministrator", "None"
						$INP_Res_requestedExecutionLevel = $i_Rec_Value
					Case Else
						$INP_Res_requestedExecutionLevel = ""
						__ConsoleWrite("- Skipping #AutoIt3Wrapper_res_requestedExecutionLevel directive. Invalid value:" & $i_Rec_Value & @CRLF)
				EndSwitch
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_HiDpi"
				$INP_RES_HiDpi = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Res_Compatibility"
				$INP_Res_Compatibility = $i_Rec_Value
				$Temp_Val = StringSplit($i_Rec_Value, ",")
				For $x = 1 To $Temp_Val[0]
					;None, Vista, Windows7  (default=None)"
					Switch $Temp_Val[$x]
						Case "", "None"
							$INP_Res_Compatibility = ""
						Case "Vista", "Windows7", "win7", "win8", "win81", "win10", "ignore"
							;
						Case Else
							__ConsoleWrite("- Skipping #AutoIt3Wrapper_res_Compatibility directive invalid value:" & $Temp_Val[$x] & @CRLF)
					EndSwitch
				Next
				; ================ Other =========================================================================
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_AU3Check"
				If $INP_AutoIt3Wrapper_If = "" Or $INP_AutoIt3Wrapper_If = $Option Then
					$INP_Run_AU3Check = $i_Rec_Value
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Jump_To_First_Error"
				If $INP_AutoIt3Wrapper_If = "" Or $INP_AutoIt3Wrapper_If = $Option Then
					$INP_Jump_To_First_Error = $i_Rec_Value
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_AU3Check_Parameters"
				If $INP_AutoIt3Wrapper_If = "" Or $INP_AutoIt3Wrapper_If = $Option Then
					$INP_AU3Check_Parameters = $i_Rec_Value
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_AU3Check_Stop_OnWarning"
				If $INP_AutoIt3Wrapper_If = "" Or $INP_AutoIt3Wrapper_If = $Option Then
					$INP_AU3Check_Stop_OnWarning = $i_Rec_Value
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_Tidy"
				If $INP_AutoIt3Wrapper_If = "" Or $INP_AutoIt3Wrapper_If = $Option Then
					$INP_Run_Tidy = $i_Rec_Value
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Tidy_Stop_OnError"
				If $INP_AutoIt3Wrapper_If = "" Or $INP_AutoIt3Wrapper_If = $Option Then
					$INP_Tidy_Stop_OnError = $i_Rec_Value
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_Au3Stripper"
				$INP_Run_Au3Stripper = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Au3Stripper_OnError"
				If $INP_AutoIt3Wrapper_If = "" Or $INP_AutoIt3Wrapper_If = $Option Then
					$INP_Au3Stripper_OnError = $i_Rec_Value
					Switch $INP_Au3Stripper_OnError
						Case "s", "stop"
							$INP_Au3Stripper_OnError = "s"
						Case "c", "continue"
							$INP_Au3Stripper_OnError = "c"
						Case "f", "forceuse"
							$INP_Au3Stripper_OnError = "f"
						Case Else
							__ConsoleWrite('! Invalid #AutoIt3Wrapper_Au3Stripper_OnError Option:' & $i_Rec_Value & " should be one of these:S,C,F,Stop,Continue,ForceUse")
					EndSwitch
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_Stop_OnError"
				$INP_Run_Stop_OnError = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_Before"
				$INP_Run_Before[0] += 1
				ReDim $INP_Run_Before[$INP_Run_Before[0] + 1]
				ReDim $INP_Run_Before_Admin[$INP_Run_Before[0] + 1]
				$INP_Run_Before[$INP_Run_Before[0]] = $i_Rec_Value
				$INP_Run_Before_Admin[$INP_Run_Before[0]] = $INP_Run_Before_Admin[0]
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_After"
				$INP_Run_After[0] += 1
				ReDim $INP_Run_After[$INP_Run_After[0] + 1]
				ReDim $INP_Run_After_Admin[$INP_Run_After[0] + 1]
				$INP_Run_After[$INP_Run_After[0]] = $i_Rec_Value
				$INP_Run_After_Admin[$INP_Run_After[0]] = $INP_Run_After_Admin[0]
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_Before_Admin"
				; Set the [0] value to what we want to use for the subsequent run commands
				If $i_Rec_Value = "y" Or $i_Rec_Value = 1 Then
					$INP_Run_Before_Admin[0] = 1
				Else
					$INP_Run_Before_Admin[0] = 0
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_After_Admin"
				; Set the [0] value to what we want to use for the subsequent run commands
				If $i_Rec_Value = "y" Or $i_Rec_Value = 1 Then
					$INP_Run_After_Admin[0] = 1
				Else
					$INP_Run_After_Admin[0] = 0
				EndIf
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_CvsWrapper"
				$INP_Run_Versioning = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Versioning"
				$INP_Run_Versioning = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_CvsWrapper_Parameters"
				$INP_Versioning_Parameters = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Versioning_Parameters"
				$INP_Versioning_Parameters = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_PlugIn_Funcs"
				$INP_Plugin = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Change2CUI"
				$INP_Change2CUI = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Add_Constants"
				$INP_Add_Constants = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_ShowGui"
				$ShowGUI = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_SciTE_Minimized"
				$INP_Run_SciTE_Minimized = $i_Rec_Value
			Case $i_Rec_Param = "#AutoIt3Wrapper_Run_SciTE_OutputPane_Minimized"
				$INP_Run_SciTE_OutputPane_Minimized = $i_Rec_Value
			Case Else
				__ConsoleWrite('! Invalid AutoIt3Wrapper directive Keyword:' & $i_Rec_Param & ' with value:' & $i_Rec_Value & @CRLF)
		EndSelect
	Next
	If $Found_Old_ObfuscatorDirective Then
		__ConsoleWrite('! Obfuscator support has been discontinued and is replaced by Au3Stripper using "#Au3Stripper_" directives.' & @CRLF)
		__ConsoleWrite('! The directive to run Au3Stripper is: #AutoIt3Wrapper_Run_Au3Stripper=y  ; Default is n' & @CRLF)
		__ConsoleWrite('! #Au3Stripper_Parameters options are: ' & @CRLF & _
				"/pe  : Replace and reference to a Global Const variable with its actual value." & @CRLF & _
				"/tl  : Create Au3Stripper.Log with a trace of all actions." & @CRLF & _
				"/debug: add Debug information to Au3Stripper.Log." & @CRLF & _
				"/so : This is the default when no parameters are provided. same as /sf + /sv" & @CRLF & _
				"/sf : Strip all unused Func's" & @CRLF & _
				"/sv : Strip all unused Global var records." & @CRLF & _
				"/mo : Just merges the Include files into the source and strips the Comments." & @CRLF & _
				"      This is similar to aut2exe and helps finding the errorline." & @CRLF & _
				"/mi : Sets the maximum Iterations Au3Stripper will perform. Default is 5." & @CRLF & _
				"/rm : Rename Variables and Functions to a shorter name." & @CRLF & _
				"/rsln: Replace @ScriptLineNumber with the actual line number." & @CRLF & _
				"/Beta: Use Beta Includes." & @CRLF)
	EndIf
EndFunc   ;==>Retrieve_PreProcessor_Info
;
Func Run_Au3Check($ScriptFile_In)
	; copy the UTF encode file to a ANSI version for processing by AU3Check
	If $InputFileIsUTF16 Or $InputFileIsUTF32 Then
		; Tempfile needs to be in the Scriptdir for User includes to work properly!
		Local $dummy, $tScriptFileName, $tScriptFileNameExt
		_PathSplit($ScriptFile_In, $dummy, $dummy, $tScriptFileName, $tScriptFileNameExt)
		Local $nScriptFileName = @TempDir & "\AutoIt3WrapperRunTmpFiles\" & $tScriptFileName & $tScriptFileNameExt
		ConsoleWrite('!Main script  ' & $ScriptFile_In & ' contains Unicode characters so copy for processing to ' & $nScriptFileName & @CRLF)
		ConsoleWrite('!$ScriptFileName = ' & $ScriptFile_In & ' $nScriptFileName = ' & $nScriptFileName & @CRLF)
		; use [1] for original script info
		; use [2] for au3check script info
		$SourceFileNames[2][0] = $ScriptFile_In
		$SourceFileNames[2][1] = ""
		$SourceFileNames[2][2] = $nScriptFileName
		Local $h_Output = FileOpen($nScriptFileName, 2)
		FileWrite($h_Output, FileRead($ScriptFile_In))
		FileClose($h_Output)
	EndIf
	; New INclude logic with au3check in the AutoIt directory
	Local $Au3checkpgm = $CurrentAutoIt_InstallDir & "\au3check.exe"
	If FileExists($Au3checkpgm) Then
		Local $Au3checkpgmdir = $CurrentAutoIt_InstallDir
		Local $Au3checkpgmVer = FileGetVersion($Au3checkpgm)
		If $Au3checkpgmVer = "0.0.0.0" Then
			$Au3checkpgmVer = ""
		Else
			$Au3checkpgmVer = "(" & $Au3checkpgmVer & ")"
		EndIf
		;       ProgressSet(5, "Running AU3Check ...")
		$TempFile = $TempDir & '\au3check.log'
		; If PlugIn functions are specified then add that to the temp au3Check.dat
		If $INP_Plugin <> "" Then
			If FileCopy($Au3checkpgmdir & "\au3check.dat", $TempDir & "\au3check.dat", 1) Then
				$INP_Plugin = StringSplit($INP_Plugin, ",")
				For $x = 1 To $INP_Plugin[0]
					FileWriteLine($Au3checkpgmdir & "\au3check.dat", "!" & StringStripWS($INP_Plugin[$x], 3) & " 0 99")
				Next
			Else
				__ConsoleWrite("+> Unable to add PlugIn functions to the Au3Check tables" & @LF)
				$INP_Plugin = ""
			EndIf
		EndIf
		If $INP_AU3Check_Parameters <> "" Then
			__ConsoleWrite(">Running AU3Check " & $Au3checkpgmVer & "  params:" & $INP_AU3Check_Parameters & "  from:" & $Au3checkpgmdir & "  input:" & $ScriptFile_In & @CRLF)
		Else
			__ConsoleWrite(">Running AU3Check " & $Au3checkpgmVer & "  from:" & $Au3checkpgmdir & "  input:" & $ScriptFile_In & @CRLF)
		EndIf
		; Process the TEMPFILE in case of an UTF encoded file
		If $InputFileIsUTF16 Or $InputFileIsUTF32 Then
			$Pid = Run('"' & $Au3checkpgm & '" ' & $INP_AU3Check_Parameters & ' -q "' & $TempScript & '"', '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		Else
			$Pid = Run('"' & $Au3checkpgm & '" ' & $INP_AU3Check_Parameters & ' -q "' & $ScriptFile_In & '"', '', @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		EndIf
		;
		$Handle = _ProcessExitCode($Pid)
		; Replace the TEMPFILE name with Original Script file name when UNICODE
		If $SourceFileNames[1][2] <> "" Or $SourceFileNames[2][2] <> "" Then
			$Return_Text = ShowStdOutErr($Pid, 1, 1, $SourceFileNames)
		Else
			$Return_Text = ShowStdOutErr($Pid, 1, 1)
		EndIf
		;
		$ExitCode = _ProcessExitCode($Pid, $Handle)
		_ProcessCloseHandle($Handle)
		StdioClose($Pid)
		; Add Annotation in case there are Warnings or Errors
		If $INP_Plugin <> "" Then
			FileMove($TempDir & "\au3check.dat", $Au3checkpgmdir & "\au3check.dat", 1)
		EndIf
		; Show inline errros
		If $ExitCode Then
			; Jump to first Annotation in case there are Warnings or Errors
			If $INP_Jump_To_First_Error = "y" And RunBySciTE() Then
				Run('"' & @AutoItExe & '" "' & @ScriptFullPath & '" /Jump2FirstError ' & @AutoItPID)
			EndIf
		Else
			; Clear Annotation in case there are no Warnings or Errors anymore
			If RunBySciTE() Then SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "extender:dostring scite.SendEditor(SCI_ANNOTATIONCLEARALL)")
		EndIf
		If $Return_Text <> "" And $ExitCode <> 0 Then
			;__ConsoleWrite(">AU3Check Ended with Error(s). rc:" & $exitcode & @crlf)
			If RunBySciTE() Then
				Write_RC_Console_Msg("AU3Check ended. Press F4 to jump to next error.", $ExitCode)
			Else
				Write_RC_Console_Msg("AU3Check ended.", $ExitCode)
			EndIf
			;
			If $Option <> "AU3Check" Then
				If $INP_AU3Check_Stop_OnWarning = "y" Or StringInStr($Return_Text, " - 0 error(s)") = 0 Then
					__DelTempFile($TempFile)
					__DelTempFile($TempScript)
					Exit $ExitCode
;~ 					Show_Warnings("Au3Check errors", StringReplace($Return_Text, @CR, ""))
				EndIf
			EndIf
		Else
			; Clear Annotation in case there are no Warnings or Errors anymore
			If RunBySciTE() Then SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "extender:dostring scite.SendEditor(SCI_ANNOTATIONCLEARALL)")
			Write_RC_Console_Msg("AU3Check ended.", $ExitCode)
		EndIf
	Else
		;__ConsoleWrite("*** AU3CHECK (1) : ERROR: *** Skipping AU3Check: " & $Au3checkpgm & " Not Found !" & @crlf & @crlf)
		__ConsoleWrite("! *** AU3CHECK Error: *** Skipping AU3Check: " & $Au3checkpgm & " Not Found !" & @CRLF & @CRLF)
	EndIf
	__DelTempFile($TempFile)
	__DelTempFile($TempScript)
EndFunc   ;==>Run_Au3Check
;
Func RunAutoItDebug($sFileToDebug, ByRef $sDebugFile)
	; Klaatu on AutoIt3 forum
	; DebugIt.au3  http://www.autoitscript.com/forum/index.php?s=&showtopic=35218&view=findpost&p=258014
	;
	; Version 1.0 - initial release
	;
	; Run an AutoIt script, outputing each line executed to a window.
	;
	; Syntax 1:
	;    AutoIt3 DebugIt.au3 yourscript.au3 params
	; Syntax 2:
	;    DebugIt.exe yourscript.au3 params
	;
	; Run DebugIt - choose a file - the script will then write out a file called
	; filename_DebugIt.au3 This file should be identical to your script except that
	; before every line of code there is an instruction to write out the original
	; script line to a control in a window we create.
	; If the script crashes out - or whatever - you just look at the the last line
	; written out to indicate where the script crashed.
	;
	; You can prevent any particular section of code (such as an AdLib function)
	; from having debug code added by placing a line with just ";debug" before and
	; after the section.
	;
	; NOTE: Requires AutoIt 3.2+!!!
	;
	Local $fhFileToDebug, $fhDebugFile
	Local $iLineNumber, $sCurrentLine, $sComment, $sModifiedLine, $bDebugging
	Local $iRandom = '', $sIndent, $sTitle, $x, $CaseFix
	Local $sDrive, $sDir, $sFName, $iSavedLine, $I_Rec, $i_Rec_Param, $i_Rec_Value
	#forceref $i_Rec_Param
	_PathSplit($sFileToDebug, $sDrive, $sDir, $sFName, $x)
	; The title of our debug window will be the filename portion only, but with "_DebugIt" added.
	$sTitle = $sFName & '_DebugIt'
	; Our temporary script will use this title for its name. We also make sure to create the
	; temporary script in the same folder as the original, in case it relies on other things
	; being found relative to where it is.
	$sDebugFile = _PathMake($sDrive, $sDir, $sTitle, $x)
	; We use a Random 8 character string for 2 purposes:
	;   1) to almost guarantee that the variables we add to the script don't conflict
	;      with the script's own variables, and
	;   2) to make sure we're communicating with one and only one debug window, as we
	;      look for this random string to be text in the window we want to communicate with.
	While StringLen($iRandom) < 8
		$iRandom &= Chr(Round(Random(97, 122), 0))
	WEnd
	$fhDebugFile = FileOpen($sDebugFile, 2)
	If @error Then
		MsgBox(0, @ScriptName, 'File ' & $sDebugFile & ' could not be opened')
		Exit (3)
	EndIf
	;
	FileWriteLine($fhDebugFile, "Global $__err" & $iRandom & "[2] = [0, 0]")
	$fhFileToDebug = FileOpen($sFileToDebug, 0)
	$iLineNumber = 1
	$bDebugging = True
	While True
		$iSavedLine = $iLineNumber
		$sCurrentLine = FileReadLine($fhFileToDebug)
		If @error = -1 Then ExitLoop
		; Handle continuation lines. This does need to be more sophisticated to handle
		; comments that follow line continuations; right now it's pretty basic.
		While StringRight($sCurrentLine, 2) = ' _'
			$sCurrentLine = StringTrimRight($sCurrentLine, 1)
			$iLineNumber += 1
			$sCurrentLine &= StringStripWS(FileReadLine($fhFileToDebug, $iLineNumber), 1)
			If @error = -1 Then ExitLoop
		WEnd
		; look for lines that tell us whether to stop or start adding debugging to the script
		; there's no special code to watch for #cs/#ce blocks, as it actually doesn't matter;
		; debug code will be added to these blocks, but so what?
		$I_Rec = StringStripWS($sCurrentLine, 3)
		If StringLeft($I_Rec, 26) = "#AutoIt3Wrapper_run_debug=" Then
			$i_Rec_Param = StringLeft($I_Rec, StringInStr($I_Rec, "=") - 1)
			$i_Rec_Param = StringStripWS($i_Rec_Param, 3)
			$i_Rec_Value = StringRegExpReplace($I_Rec, '(?is)(.*?=)(\s*)(\w+)(\V*)', '$3')
			Switch $i_Rec_Value
				Case "on"
					$bDebugging = 1
				Case "off"
					$bDebugging = 0
				Case Else
					__ConsoleWrite('! directive error, only [On/Off] is supported: ' & $I_Rec & @CRLF)
			EndSwitch
			$iLineNumber += 1
			FileWriteLine($fhDebugFile, $sCurrentLine)
			ContinueLoop
		EndIf
		If StringStripWS($sCurrentLine, 8) = ";debug" Then
			$bDebugging = Not $bDebugging
			$iLineNumber += 1
			FileWriteLine($fhDebugFile, $sCurrentLine)
			ContinueLoop
		EndIf
		; Don't write debugging statements between Switch and Case
		If $bDebugging And (StringLeft(StringStripWS($sCurrentLine, 8), 6) = "Switch" Or StringLeft(StringStripWS($sCurrentLine, 8), 6) = "Select") Then
			$bDebugging = 0
			$CaseFix = 1
			$iLineNumber += 1
			FileWriteLine($fhDebugFile, $sCurrentLine)
			ContinueLoop
		EndIf
		If StringLeft(StringStripWS($sCurrentLine, 8), 4) = "Case" Then
			If $CaseFix Then
				$bDebugging = 1
				$CaseFix = 0
			EndIf
			$iLineNumber += 1
			FileWriteLine($fhDebugFile, $sCurrentLine)
			ContinueLoop
		EndIf
		;
		If $bDebugging Then
			; Turn all single quotes into double quotes so we can use single quotes to delimit the
			; line when adding it to the debugging script.
			$sModifiedLine = StringReplace($sCurrentLine, "'", '"')
			$sComment = StringStripWS(StringLeft($sModifiedLine, StringInStr($sModifiedLine, ";", -1)), 3)
			If Not ($sComment = ";") And Not (StringStripWS($sCurrentLine, 3) = "") Then
				; Proper indenting is not really needed, but it makes the temporary script
				; look a hell of a lot better if someone needs to look at it for some reason.
				$sIndent = ''
				While StringIsSpace(StringLeft($sCurrentLine, StringLen($sIndent) + 1))
					$sIndent = StringLeft($sCurrentLine, StringLen($sIndent) + 1)
				WEnd
				; First we save the values of @Error and @Extended, then add our command that
				; updates the Edit control on our form with the script's current line, then we
				; restore @Error and @Extended to what they were. This guarantees that the
				; original script's code that relies on these values will continue to execute
				; as intended.
				FileWriteLine($fhDebugFile, StringFormat("%sDim $__err%s[2] = [@Error, @Extended]", $sIndent, $iRandom))
				; FileWriteLine($fhDebugFile, StringFormat("%sControlSetText('%s', '%s', 'Edit1', ControlGetText('%s', '%s', 'Edit1') & @CRLF & '%04u: %s')", $sIndent, $sTitle, $iRandom, $sTitle, $iRandom, $iLineNumber, $sModifiedLine))
				;FileWriteLine($fhDebugFile, StringFormat("%sControlCommand('%s', '%s', 'Edit1', 'EditPaste', '%04u: %s' & @CRLF)", $sIndent, $sTitle, $iRandom, $iSavedLine, $sModifiedLine))
				FileWriteLine($fhDebugFile, StringFormat("%sConsoleWrite('%04u: ' & $__err%s[0] & '-' & $__err%s[1] & ': %s' & @CRLF)", $sIndent, $iSavedLine, $iRandom, $iRandom, $sModifiedLine))
				FileWriteLine($fhDebugFile, StringFormat("%sSetError($__err%s[0], $__err%s[1])", $sIndent, $iRandom, $iRandom))
			EndIf
		EndIf
		FileWriteLine($fhDebugFile, $sCurrentLine)
		$iLineNumber += 1
	WEnd
	FileWriteLine($fhDebugFile, $sCurrentLine)
	FileClose($fhFileToDebug)
	FileClose($fhDebugFile)
EndFunc   ;==>RunAutoItDebug
;
; Validate/Translate/Set Input field value
Func SetDefaults(ByRef $fieldval, $Def_Value, $translate = "", $valid = "", $iNbr = 0, $Case_Value = 0)
	Local $tarray, $varray, $IsValid
	If $fieldval = "" Then
		$fieldval = $Def_Value
	ElseIf $translate <> "" Then
		$tarray = StringSplit($translate, ";")
		For $x = 1 To $tarray[0]
			$varray = StringSplit($tarray[$x], "=")
			If $varray[0] > 1 And $varray[1] = $fieldval Then $fieldval = $varray[2]
		Next
	EndIf
	If $valid <> "" Then
		$IsValid = False
		$tarray = StringSplit($valid, ";")
		For $x = 1 To $tarray[0]
			If (StringLower($tarray[$x]) == StringLower($fieldval) And $Case_Value = 0) Or ($tarray[$x] == $fieldval And $Case_Value = 1) Then
				$IsValid = True
				ExitLoop
			EndIf
		Next
		If $IsValid = False Then
			$fieldval = $Def_Value
		EndIf
	EndIf
	If $iNbr Then $fieldval = Number($fieldval)
EndFunc   ;==>SetDefaults
;
;Show a Window with Warning
Func Show_Warnings($Warning_TiTle, $Warning_Text)
	GUICreate($Warning_TiTle, 700, 310, -1, -1, $WS_SIZEBOX + $WS_SYSMENU + $WS_MINIMIZEBOX)
	GUICtrlCreateLabel("Do you want to stop the " & $Option & "?", 5, 257, 180, 20)
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKSIZE)
	Local $H_Yes = GUICtrlCreateButton("Stop", 280, 253, 60, 25)
	GUICtrlSetResizing($H_Yes, $GUI_DOCKBOTTOM + $GUI_DOCKSIZE + $GUI_DOCKHCENTER)
	Local $H_No = GUICtrlCreateButton("Continue anyway", 360, 253, 100, 25)
	GUICtrlSetResizing($H_No, $GUI_DOCKBOTTOM + $GUI_DOCKSIZE + $GUI_DOCKHCENTER)
	GUISetFont(9, 400, 0, "Courier New")
	GUICtrlCreateEdit(StringReplace($Warning_Text, @LF, @CRLF), 5, 5, 690, 240, BitOR($ES_WANTRETURN, $WS_VSCROLL, $WS_HSCROLL, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY))
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
	GUICtrlSetBkColor(-1, 0xFFEFEF)
	GUICtrlSetState($H_Yes, $GUI_FOCUS)
	GUISetState(@SW_SHOW)                                            ; Process GUI Input
	; Process GUI Input
	;-------------------------------------------------------------------------------------------
	While 1
		$rc = GUIGetMsg()
		Sleep(10)
		If $rc = 0 Then ContinueLoop
		; Cancel clicked
		If $rc = $H_Yes Then Exit
		If $rc = $H_No Then ExitLoop
		If $rc = -3 Then Exit
	WEnd
	GUIDelete()
EndFunc   ;==>Show_Warnings
;
; Get STDOUT and ERROUT from commandline tool
Func ShowStdOutErr($l_Handle, $ShowConsole = 1, $ReturnOutput = 0, $Replace = "", $WinHnd = 0, $INP_HotKey_Stop = "", $INP_HotKey_Restart = "")
	Local $Line = ""
	Local $tot_out, $err1 = 0, $err2 = 0, $cnt1 = 0, $cnt2 = 0
	Local $HotKeysSet = False
	Do
		If $WinHnd <> 0 And WinGetHandle("[ACTIVE]") = $WinHnd And Not $HotKeysSet Then
			; enable Hotkeys when the Editor has the focus
			HotKeySet($INP_HotKey_Stop, 'CTRL_BREAK_WRAPPER')
			HotKeySet($INP_HotKey_Restart, 'Run_the_Script')
			$HotKeysSet = True
		ElseIf $WinHnd <> 0 And WinGetHandle("[ACTIVE]") <> $WinHnd And $HotKeysSet Then
			; Disable Hotkeys when the Editor doesn't have the focus
			HotKeySet($INP_HotKey_Stop)
			HotKeySet($INP_HotKey_Restart)
			$HotKeysSet = False
		EndIf
		Sleep(10)
		; Read STDOUT
		$Line = StdoutRead($l_Handle)
		$err1 = @error
		ShowStdOutErr_process($Line, $Replace, $ShowConsole)
		If $ReturnOutput Then $tot_out &= $Line
		$Line = StderrRead($l_Handle)
		$err2 = @error
		ShowStdOutErr_process($Line, $Replace, $ShowConsole)
		If $ReturnOutput Then $tot_out &= $Line
		; end the loop also when AutoIt3 has ended but a sub process was shelled with Run() that is still active
		; only do this every 50 cycles to avoid cpu hunger
		If $cnt1 = 50 Then
			$cnt1 = 0
			; loop another 50 times just to ensure the buffers emptied.
			If Not ProcessExists($l_Handle) Then
				If $cnt2 > 2 Then ExitLoop
				$cnt2 += 1
			EndIf
		EndIf
		$cnt1 += 1
	Until ($err1 And $err2)
	Return $tot_out
EndFunc   ;==>ShowStdOutErr
;
Func ShowStdOutErr_process($Line, ByRef $Replace, $ShowConsole)
	; Replace the Tempfilename with the original sourcefilename to display the proper error/warning. This is used for Unicode filenames or content
	Local $UseMailSlot = StringInStr($CMDLINERAW, "/RunAdmin") <> 0
	If IsArray($Replace) Then
		For $x = 1 To UBound($Replace) - 1
			If $Replace[$x][2] <> "" Then
				$Line = StringReplace($Line, $Replace[$x][2], $Replace[$x][0])
			EndIf
		Next
	EndIf
	If $UseMailSlot And $Line <> "" Then
		_MailSlotWrite($sMailSlotConsole, $Line)                     ;Used when shelled script uses #requireAdmin
	EndIf
	; show line in console
	If $ShowConsole Then ConsoleWrite($Line)
EndFunc   ;==>ShowStdOutErr_process
;
Func Update_Version()
	If ($INP_Fileversion_AutoIncrement = 'y' Or $INP_Fileversion_Use_Template <> '') _
			And $INP_AutoIt3Wrapper_Testing = "n" Then
		If $INP_Fileversion = "" Then
			__ConsoleWrite("- Failed to Updated the Source Version. The Source doesnt contain the #AutoIt3Wrapper_Res_Fileversion directive." & @CRLF)
		Else
			If $INP_Fileversion_New <> "" Then
				SciTE_SaveSession()
				$ToTalFile = @CRLF & FileRead($ScriptFile_In_Org)
				; added & chr(61) & to avoid replacing this statement when the version is updated
				If $Pragma_Fileversion <> "" Then
					$ToTalFile = StringRegExpReplace($ToTalFile, '(?i)' & @CRLF & '(\h*?)#pragma compile(\h*?)\((\h*?)Fileversion(\h*?),(\h*?)(.*?)\)' & @CRLF, @CRLF & '\1#pragma compile(Fileversion, ' & $INP_Fileversion_New & ")" & @CRLF)
				Else
					$ToTalFile = StringRegExpReplace($ToTalFile, '(?i)' & @CRLF & '(\h*?)#AutoIt3Wrapper_Res_Fileversion(\h*?)=(.*?)' & @CRLF, @CRLF & '\1#AutoIt3Wrapper_Res_Fileversion=' & $INP_Fileversion_New & @CRLF)
					; Add #AutoIt3Wrapper_Res_Fileversion when missing and use template is there
					If @extended = 0 Then
						$ToTalFile = StringRegExpReplace($ToTalFile, '(?i)' & @CRLF & '(\h*?)(#AutoIt3Wrapper_Res_Fileversion_Use_Template\h*?=.*?)' & @CRLF, @CRLF & '\1\2' & @CRLF & '\1#AutoIt3Wrapper_Res_Fileversion=' & $INP_Fileversion_New & @CRLF)
					EndIf
				EndIf
				$ToTalFile = StringRegExpReplace($ToTalFile, '(?i)' & @CRLF & '(\h*?)Global Const \$VERSION(\h*?)=(\h*?)"(.*?)"' & @CRLF, @CRLF & '\1Global Const $VERSION = "' & $INP_Fileversion_New & '"' & @CRLF)
				$H_Outf = FileOpen($ScriptFile_In_Org, 2 + $SrceUnicodeFlag)
				FileWrite($H_Outf, StringMid($ToTalFile, 3))
				FileClose($H_Outf)
				__ConsoleWrite("-Updated the Source Version to:" & $INP_Fileversion_New & @CRLF)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>Update_Version
;
; Check for valid verion number
Func Valid_FileVersion($i_FileVersion, $IsFileVersion = 1)
	; Use template version and convert to new version
	If $IsFileVersion And $INP_Fileversion_Use_Template <> '' Then
		Local Static $_Template_Version = ""                         ; make static so we only generate the new version one time during the run
		If $_Template_Version = "" Then                              ; not initialized -> use template and create version
			$_Template_Version = $INP_Fileversion_Use_Template
			$_Template_Version = StringReplace($_Template_Version, "%YYYY", @YEAR)
			$_Template_Version = StringReplace($_Template_Version, "%YY", StringRight(@YEAR, 2))
			$_Template_Version = StringReplace($_Template_Version, "%MO", @MON)
			$_Template_Version = StringReplace($_Template_Version, "%DD", @MDAY)
			$_Template_Version = StringReplace($_Template_Version, "%HH", @HOUR)
			$_Template_Version = StringReplace($_Template_Version, "%MI", @MIN)
			$_Template_Version = StringReplace($_Template_Version, "%SE", @SEC)
			$_Template_Version = StringReplace($_Template_Version, "%MS", @MSEC)
		EndIf
		$i_FileVersion = $_Template_Version
	EndIf
	;
	Local $T_Numbers = StringSplit($i_FileVersion, ".")
	If $T_Numbers[0] > 4 Then
		__ConsoleWrite("- RC Invalid FileVersion :" & $i_FileVersion & ", contains more then 4 numbers.... Changed to:" & $AUT2EXE_PGM_VER & @CRLF)
		Return $AUT2EXE_PGM_VER
	EndIf
	;
	If $T_Numbers[0] < 4 Then ReDim $T_Numbers[5]
	For $x = 1 To 4
		If $T_Numbers[$x] = '' Then $T_Numbers[$x] = 0
		If Not ($T_Numbers[$x] == Number($T_Numbers[$x])) Then
			If $INP_Fileversion_Use_Template = '' Then
				__ConsoleWrite("! Invalid FileVersion value " & $x & "=" & $T_Numbers[$x] & ". It will be changed to:" & Number($T_Numbers[$x]) & @CRLF)
			EndIf
			$T_Numbers[$x] = Number($T_Numbers[$x])
		EndIf
	Next
	If $IsFileVersion Then
		; Auto Increment when requested
		$INP_Fileversion_New = $T_Numbers[1] & "." & $T_Numbers[2] & "." & $T_Numbers[3] & "." & $T_Numbers[4]
		If $INP_Fileversion_AutoIncrement <> "n" And $INP_Fileversion_Use_Template = '' Then
			$INP_Fileversion_New = $T_Numbers[1] & "." & $T_Numbers[2] & "." & $T_Numbers[3] & "." & $T_Numbers[4] + 1
		EndIf
	EndIf
	Return $T_Numbers[1] & "." & $T_Numbers[2] & "." & $T_Numbers[3] & "." & $T_Numbers[4]
EndFunc   ;==>Valid_FileVersion
;
; Write colored console message..
Func Write_RC_Console_Msg($text, $rc = "", $symbol = "", $Time = 1)
	If $Time Then $text = @HOUR & ":" & @MIN & ":" & @SEC & " " & $text
	If $symbol <> "" Then
		If $rc == "" Then
			__ConsoleWrite($symbol & ">" & $text & @CRLF)
		Else
			__ConsoleWrite($symbol & ">" & $text & "rc:" & $rc & @CRLF)
		EndIf
	Else
		If $rc == "" Then
			__ConsoleWrite(">" & $text & @CRLF)
		Else
			Switch $rc
				Case 0, -1                                           ; -1 use for Tidy when no change is made
					__ConsoleWrite("+>" & $text & "rc:" & $rc & @CRLF)
				Case 1
					__ConsoleWrite("->" & $text & "rc:" & $rc & @CRLF)
				Case Else
					__ConsoleWrite("!>" & $text & "rc:" & $rc & @CRLF)
			EndSwitch
		EndIf
	EndIf
EndFunc   ;==>Write_RC_Console_Msg
#EndRegion Functions
#Region SciTE Functions
; Received Data from SciTE
Func MY_WM_COPYDATA($HWindow, $msg, $wParam, $lParam)
	#forceref $HWindow, $msg, $wParam
	Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr', $lParam)
	Local $SciTECmdLen = DllStructGetData($COPYDATA, 2)
	Local $CmdStruct = DllStructCreate('Char[255]', DllStructGetData($COPYDATA, 3))
	$SciTECmd = StringLeft(DllStructGetData($CmdStruct, 1), $SciTECmdLen)
;~ 	__ConsoleWrite('<--' & $SciTECmd & @CRLF)
EndFunc   ;==>MY_WM_COPYDATA
;
; Restore The bookmarks and Folds and position to the same first line and set the caret on the correct line
Func SciTE_RestoreSession($Filename)
	If Not RunBySciTE() Then Return
	If FileExists($TempDir & "\AutoIt3Wrapper.session") Then
		Local $Fh = FileOpen($TempDir & "\AutoIt3Wrapper.session")
		Local $TempRec, $TempSesRec, $SciTEPos, $FoldsFound, $SciTECurLine = 0
		Local $Slp, $vFold, $Buf
		Local $j, $Bmarks, $Folds
		SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "menucommand:104")  ; revert to up-date the current file with the Tidied version
		While 1
			$TempRec = FileReadLine($Fh)
			If @error Then ExitLoop
			If StringInStr($TempRec, $Filename) Then
				$Buf = StringLeft($TempRec, 9)
				; Read all reacords for the current buffer
				While 1
					$TempRec = FileReadLine($Fh)
					If @error Then ExitLoop
					If StringLeft($TempRec, StringLen($Buf)) <> $Buf Then ExitLoop
					; save the cursor postion
					If StringInStr($TempRec, "position=") Then
						$SciTEPos = Number(StringMid($TempRec, StringInStr($TempRec, "=") + 1)) - 1
					EndIf
					; Restore BookMarks when found
					If StringInStr($TempRec, "bookmarks=") Then
						$TempSesRec = StringMid($TempRec, StringInStr($TempRec, "=") + 1)
						$Bmarks = StringSplit($TempSesRec, ",")
						ConsoleWrite(">   Restoring Bookmarks on line(s):" & $TempSesRec & @CRLF)
						For $j = 1 To $Bmarks[0]
							SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "extender:dostring editor:MarkerAdd(" & $Bmarks[$j] & "-1,1)")
						Next
					EndIf
					;  Restore Folds when found
					If StringInStr($TempRec, "folds=") Then
						$TempSesRec = StringMid($TempRec, StringInStr($TempRec, "=") + 1)
						$Folds = StringSplit($TempSesRec, ",")
						ConsoleWrite(">   Restoring Folds on line(s):" & $TempSesRec & @CRLF)
						For $j = 1 To $Folds[0]
							; need to jump to the line before restoring fold to make it work properly and added a variable sleep depending how far the jump is.
							SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "extender:dostring editor:GotoLine(" & $Folds[$j] & "-1)")
							$vFold = Number($Folds[$j]) - 1
							If $SciTECurLine > $vFold Then
								$Slp = ($SciTECurLine - $vFold) * 0.05 + 5
							Else
								$Slp = ($vFold - $SciTECurLine) * 0.05 + 5
							EndIf
							Sleep($Slp)
							SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "extender:dostring editor:ToggleFold(" & $vFold & ",1)")
							$SciTECurLine = $vFold                   ; estimate current line
						Next
						$FoldsFound = 1
					EndIf
				WEnd
			EndIf
		WEnd
		FileClose($Fh)
		; Set the screen and caret to the correct position when folds are restored.
		If $FoldsFound And $SciTEPos Then
			; print " $SciTEPos:";$SciTEPos;"   FirstLineVisible$:";FirstLineVisible$
			SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "extender:dostring editor.FirstVisibleLine=" & $FirstLineVisible & "")
			SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "extender:dostring editor:GotoPos(" & $SciTEPos & ")")
			SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "extender:dostring props[""Temp""]=editor:LineFromPosition(editor.CurrentPos)")
			Local $CurLine = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:Temp")
			If $CurLine <> $LastCaretLine Then
				; Print "current line:";SciTEData$;"   should be LastCaretLine$:";LastCaretLine$
				SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "extender:dostring editor:GotoLine(" & $LastCaretLine & ")")
			EndIf
		EndIf
		FileDelete($TempDir & "\AutoIt3Wrapper.session")
	Else
;~ 		ConsoleWrite("- Unable to restore Folds and Boomarks due to Sessionfile not found:" & $TempDir & "\AutoIt3Wrapper.session")
	EndIf
EndFunc   ;==>SciTE_RestoreSession
;
; Save current Session information to be able to restore Bookmarks and Folds
Func SciTE_SaveSession()
	If Not RunBySciTE() Then Return
	SendSciTE_Command($My_Hwnd, $SciTE_hwnd, 'extender:dostring props["Temp"]=editor.FirstVisibleLine')
	$FirstLineVisible = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:Temp")
	SendSciTE_Command($My_Hwnd, $SciTE_hwnd, 'extender:dostring props["Temp"]=editor.CurrentPos')
	$LastCaretPos = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:Temp")
	SendSciTE_Command($My_Hwnd, $SciTE_hwnd, 'extender:dostring props["Temp"]=editor:LineFromPosition(editor.CurrentPos)')
	$LastCaretLine = SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, "askproperty:Temp")
	FileDelete($TempDir & "\AutoIt3Wrapper.session")
	SendSciTE_Command($My_Hwnd, $SciTE_hwnd, "savesession:" & StringReplace($TempDir & "\AutoIt3Wrapper.session", "\", "\\"))
EndFunc   ;==>SciTE_SaveSession
;
Func SendSciTE_Command($My_Hwnd, $SciTE_hwnd, $sCmd)
	Local $CmdStruct = DllStructCreate('Char[' & StringLen($sCmd) + 1 & ']')
	DllStructSetData($CmdStruct, 1, $sCmd)
	Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
	DllStructSetData($COPYDATA, 1, 1)
	DllStructSetData($COPYDATA, 2, StringLen($sCmd) + 1)
	DllStructSetData($COPYDATA, 3, DllStructGetPtr($CmdStruct))
	DllCall('User32.dll', 'None', 'SendMessageA', 'HWnd', $SciTE_hwnd, _
			'Int', $WM_COPYDATA, 'HWnd', $My_Hwnd, _
			'Ptr', DllStructGetPtr($COPYDATA))
;~ 	__ConsoleWrite('-->' & $sCmd & @CRLF)
EndFunc   ;==>SendSciTE_Command
;
Func SendSciTE_GetInfo($My_Hwnd, $SciTE_hwnd, $sCmd)
	If Not RunBySciTE() Then Return
	Local $My_Dec_Hwnd = Dec(StringTrimLeft($My_Hwnd, 2))
	$sCmd = ":" & $My_Dec_Hwnd & ":" & $sCmd
	$SciTECmd = ""
	SendSciTE_Command($My_Hwnd, $SciTE_hwnd, $sCmd)
	For $x = 1 To 10
		If $SciTECmd <> "" Then ExitLoop
		Sleep(20)
	Next
	$SciTECmd = StringTrimLeft($SciTECmd, StringLen(":" & $My_Dec_Hwnd & ":"))
	$SciTECmd = StringReplace($SciTECmd, "macro:stringinfo:", "")
	Return $SciTECmd
EndFunc   ;==>SendSciTE_GetInfo
#EndRegion SciTE Functions
#Region GUI Functions
Func DirGetRelativePath($source, $target)
	; This UDF will get the relative Path to the file ... written by JdeB
	$source = StringReplace($source, "/", "\")
	$target = StringReplace($target, "/", "\")
	Local $sz_sDrive, $sz_sDir, $sz_sFName, $sz_sExt
	Local $sz_tDrive, $sz_tDir, $sz_tFName, $sz_tExt
	_PathSplit($source, $sz_sDrive, $sz_sDir, $sz_sFName, $sz_sExt)
	_PathSplit($target, $sz_tDrive, $sz_tDir, $sz_tFName, $sz_tExt)
	If $sz_sDrive <> $sz_tDrive Then
		Return $target
	EndIf
	;
	Local $a_sDir = StringSplit($sz_sDir, "\")
	Local $a_tDir = StringSplit($sz_tDir, "\")
	For $x = 1 To $a_sDir[0]
		If $a_sDir[$x] <> $a_tDir[$x] Then ExitLoop
	Next
	Local $R_Path = ""
	For $y = $x To $a_sDir[0] - 1
		$R_Path &= "..\"
	Next
	For $y = $x To $a_tDir[0] - 1
		$R_Path &= $a_tDir[$y] & "\"
	Next
	$R_Path &= $sz_tFName & $sz_tExt
	Return $R_Path
EndFunc   ;==>DirGetRelativePath
; Func to retrieve field content from GUI and check if it changed
Func GUI_GetValue($GUI_Ctrl_Hnd, ByRef $Current_Val, $translate = "")
	Local $GUI_Val = GUICtrlRead($GUI_Ctrl_Hnd)
	; Translate read value if needed
	Local $tarray = StringSplit($translate, ";")
	Local $varray
	For $x = 1 To $tarray[0]
		$varray = StringSplit($tarray[$x], "=")
		If $varray[0] > 1 And $varray[1] = $GUI_Val Then $GUI_Val = $varray[2]
	Next
	;
	If String($Current_Val) = String($GUI_Val) Then
		Return 0
	Else
		$Current_Val = $GUI_Val
		Return 1
	EndIf
EndFunc   ;==>GUI_GetValue
;
Func GUI_Show()
	; GUI Definition
	;-------------------------------------------------------------------------------------------
;~ 	Local $H_Comment, $H_Description, $H_Fileversion, $H_Fileversion_AutoIncrement_n, $H_Fileversion_AutoIncrement_p, $H_Fileversion_AutoIncrement_y
;~ 	local $H_LegalCopyright, $H_FieldNameEdit, $H_Res_Language
	Opt("GUICoordMode", 1)
	GUICreate("AutoIt3Wrapper GUI to Compile AutotIt3 Script (ver " & $VERSION & ")", 700, 525, (@DesktopWidth - 650) / 2, (@DesktopHeight - 500) / 2)
	GUISetHelp('"' & @WindowsDir & '\hh.exe" "' & @ScriptDir & '\..\Scite4AutoIt3.chm::/AutoIt3Wrapper.htm"')
	Local $h_File = GUICtrlCreateMenu("&File")
	Local $h_Exit = GUICtrlCreateMenuItem("&Exit", $h_File)
	Local $h_Help = GUICtrlCreateMenu("&Help")
	Local $h_HelpFile = GUICtrlCreateMenuItem("&Help", $h_Help)
	Local $h_About = GUICtrlCreateMenuItem("&About", $h_Help)
	Local $Init_Dir, $tempval
	Local $szDrive, $szDir, $szFName, $szExt
	Local $tab = GUICtrlCreateTab(10, 10, 630, 430)
	;=========================================================================================================================================
	Local $tab0 = GUICtrlCreateTabItem("AutoIt3/Aut2Exe")
	GUICtrlCreateLabel("AutoIt3 version to use:", 30, 60, 110, 40)
	GUIStartGroup()
	Local $H_AUTOIT3_Version_P = GUICtrlCreateRadio("Production:", 150, 57)
	Local $H_AUTOIT3_Version_B = GUICtrlCreateRadio("Beta:", 150, 77)
	Local $MainAutoIt_InstallDir
	;
	If StringRight($CurrentAutoIt_InstallDir, 5) = "\Beta" Then
		$MainAutoIt_InstallDir = StringTrimRight($CurrentAutoIt_InstallDir, 5)
	Else
		$MainAutoIt_InstallDir = $CurrentAutoIt_InstallDir
	EndIf
	; File AutoItSC.bin doesn't exists as of v 3.3.9.5
	If FileExists($MainAutoIt_InstallDir & "\aut2exe\AutoItSC.bin") Then
		GUICtrlCreateLabel("Ver: " & FileGetVersion($MainAutoIt_InstallDir & "\aut2exe\AutoItSC.bin"), 260, 60, 100, 25)
	Else
		GUICtrlCreateLabel("Ver: " & FileGetVersion($MainAutoIt_InstallDir & "\aut2exe\Aut2exe.exe"), 260, 60, 100, 25)
	EndIf
	If FileExists($MainAutoIt_InstallDir & "\beta\aut2exe\AutoItSC.bin") Then
		GUICtrlCreateLabel("Ver: " & FileGetVersion($MainAutoIt_InstallDir & "\Beta\aut2exe\AutoItSC.bin"), 260, 80, 100, 25)
	Else
		GUICtrlCreateLabel("Ver: " & FileGetVersion($MainAutoIt_InstallDir & "\Beta\aut2exe\Aut2exe.exe"), 260, 80, 100, 25)
	EndIf
	If $INP_AutoIt3_Version = "Beta" Then
		GUICtrlSetState($H_AUTOIT3_Version_B, $GUI_CHECKED)
	Else
		GUICtrlSetState($H_AUTOIT3_Version_P, $GUI_CHECKED)
	EndIf
	;
	GUICtrlCreateLabel("Source: ", 30, 105, 65, 20, $SS_RIGHT)
	GUICtrlCreateLabel($ScriptFile_In, 100, 105, 500, 20, BitOR($WS_BORDER, $SS_LEFTNOWORDWRAP, $SS_NOPREFIX))
	;
	GUICtrlCreateLabel("Output type: ", 30, 130, 65, 20, $SS_RIGHT)
	GUIStartGroup()
	Local $H_Out_Type_e = GUICtrlCreateRadio("EXE", 100, 130, 50, 25)
	Local $H_Out_Type_a = GUICtrlCreateRadio("A3X", 160, 130, 50, 25)
	GUIStartGroup()
	If $ScriptFile_Out_Type = "a3x" Then
		GUICtrlSetState($H_Out_Type_a, $GUI_CHECKED)
	Else
		GUICtrlSetState($H_Out_Type_e, $GUI_CHECKED)
	EndIf
	;
	GUICtrlCreateLabel("Target x86: ", 30, 155, 65, 20, $SS_RIGHT)
	;$ScriptFile_Out = DirGetRelativePath($ScriptFile_In,$ScriptFile_Out)
	Local $H_SCRIPTFILE_OUT = GUICtrlCreateInput($ScriptFile_Out, 100, 155, 440, 20)
	Local $H_SCRIPTFILE_OUT_CHANGE = GUICtrlCreateButton("...", 542, 155, 40, 20)
	GUICtrlCreateLabel("Target x64:", 30, 180, 65, 20, $SS_RIGHT)
	Local $H_SCRIPTFILE_OUT_X64 = GUICtrlCreateInput($ScriptFile_Out_x64, 100, 180, 440, 20)
	Local $H_SCRIPTFILE_OUT_CHANGE_X64 = GUICtrlCreateButton("...", 542, 180, 40, 20)
	;
	GUICtrlCreateLabel("Icon:", 30, 207, 65, 20, $SS_RIGHT)
	Local $H_INP_ICON_ICO = 0
	Local $AutoIt_Icon = RegRead("HKCR\AutoIt3Script\DefaultIcon", "")
	Local $AutoIt_Icon_Dir = StringLeft($AutoIt_Icon, StringInStr($AutoIt_Icon, "\", 0, -1))
	If FileExists($INP_Icon) Or FileExists($AutoIt_Icon_Dir & $INP_Icon) Then
		$H_INP_ICON_ICO = GUICtrlCreateIcon($INP_Icon, Default, 545, 230)
	Else
		__ConsoleWrite("->Icon not found:" & _PathFull($INP_Icon) & @CRLF)
	EndIf
	;$INP_Icon = DirGetRelativePath($ScriptFile_In,$INP_Icon)
	Local $H_INP_ICON = GUICtrlCreateEdit($INP_Icon, 100, 205, 440, 20)
	Local $H_INP_ICON_CHANGE = GUICtrlCreateButton("...", 542, 205, 40, 20)
	;
	;
	GUICtrlCreateLabel("FileInstall Compression:", 20, 235, 120, 20) ;, $SS_RIGHT)
	Local $H_Compression = GUICtrlCreateCombo("", 142, 232, 170, 80, $CBS_DROPDOWNLIST)
	Local $INP_W_Compression = "Normal"
	If $INP_Compression = 0 Then $INP_W_Compression = "Lowest"
	If $INP_Compression = 1 Then $INP_W_Compression = "Low"
	If $INP_Compression = 2 Then $INP_W_Compression = "Normal"
	If $INP_Compression = 3 Then $INP_W_Compression = "High"
	If $INP_Compression = 4 Then $INP_W_Compression = "Highest"
	GUICtrlSetData($H_Compression, "Lowest|Low|Normal|High|Highest", $INP_W_Compression)
	;
;~ 	Global $H_AUTOIT3_Ansi = GUICtrlCreateCheckbox("Use ANSI version of AutoIt3/Aut2Exe (Only works up till AutoIt3 v 3.2.12.0", 100, 230)
;~ 	If $INP_UseAnsi = "y" Then GUICtrlSetState($H_AUTOIT3_Ansi, $GUI_CHECKED)
	;
;~ 	Global $H_AUTOIT3_X64 = GUICtrlCreateCheckbox("Use X64 version of AutoIt3/Aut2Exe", 100, 255)
;~ 	If $INP_UseX64 = "y" Then GUICtrlSetState($H_AUTOIT3_X64, $GUI_CHECKED)
	GUICtrlCreateLabel("Output arch:", 30, 265, 70, 50)
	GUIStartGroup()
;~ 	Global $H_AUTOIT3_X86 = GUICtrlCreateRadio("Use X86 version.", 100, 255)
;~ 	Global $H_AUTOIT3_X64 = GUICtrlCreateRadio("Use X64 version.", 100, 272)
	Local $H_AUTOIT3_X86 = GUICtrlCreateCheckbox("Compile X86 version. (default)", 100, 255, 250, 25)
	Local $H_AUTOIT3_X64 = GUICtrlCreateCheckbox("Compile X64 version.", 100, 280, 250, 25)
	If $INP_UseX64 = "y" Then
		GUICtrlSetState($H_AUTOIT3_X64, $GUI_CHECKED)
	Else
		GUICtrlSetState($H_AUTOIT3_X86, $GUI_CHECKED)
	EndIf
	If $INP_Compile_Both = "y" Then
		GUICtrlSetState($H_AUTOIT3_X64, $GUI_CHECKED)
		GUICtrlSetState($H_AUTOIT3_X86, $GUI_CHECKED)
	EndIf
	;
	Local $H_AUTOIT3_Upx = GUICtrlCreateCheckbox("Use UPX", 100, 305)
	If $INP_UseUpx = "y" Then GUICtrlSetState($H_AUTOIT3_Upx, $GUI_CHECKED)
	;
	Local $H_Change2CUI = GUICtrlCreateCheckbox("Create CUI instead of GUI EXE.", 100, 330)
	If $INP_Change2CUI = "y" Then GUICtrlSetState($H_Change2CUI, $GUI_CHECKED)
	;
	Local $H_Add_Constants = GUICtrlCreateCheckbox("Add required Constants*.au3 to your script.", 100, 355)
	If $INP_Add_Constants = "y" Then GUICtrlSetState($H_Add_Constants, $GUI_CHECKED)
	; Help info
	GUICtrlSetTip($H_SCRIPTFILE_OUT, "Specify when a different outputfile is wanted. Default: scriptname.exe.")
;~ 	GUICtrlSetTip($H_INP_NODECOMPILE, "UNCheck to compile with a Random password.")
	GUICtrlSetTip($H_Compression, "Compression level used on the FileInstall() included files.")
;~ 	GUICtrlSetTip($H_AUTOIT3_Ansi, "Check to compile with the Ansi version when Win9x/Me support is needed.")
	GUICtrlSetTip($H_AUTOIT3_X86, "Check to compile with the X86 version of AutoIt3.")
	GUICtrlSetTip($H_AUTOIT3_X64, "Check to compile with the X64 version of AutoIt3.")
	GUICtrlSetTip($H_AUTOIT3_Upx, "Check to run UPX on the Output EXE.")
	GUICtrlSetTip($H_Change2CUI, "Check when you want to compile a Commandline-UI instead of a Grafical-UI.")
	GUICtrlSetTip($H_Add_Constants, "This will add all required Constants*.au3 includes to your Script. It will only run one time.")
	;=========================================================================================================================================
	Local $tab1 = GUICtrlCreateTabItem("Resource Update")
	; resource info
	Local $H_Res_L01 = GUICtrlCreateLabel("Comment:", 21, 60, 90, 20, $SS_RIGHT)
	$H_Comment = GUICtrlCreateInput($INP_Comment, 120, 45, 480, 35, 0x0004)
	;
	Local $H_Res_L02 = GUICtrlCreateLabel("Description:", 21, 87, 90, 20, $SS_RIGHT)
	$H_Description = GUICtrlCreateInput($INP_Description, 120, 85, 480, 20)
	If $INP_Fileversion <> "" Then $INP_Fileversion = Valid_FileVersion($INP_Fileversion)
	Local $H_Res_L03 = GUICtrlCreateLabel("FileVersion:", 21, 112, 90, 20, $SS_RIGHT)
	$H_Fileversion = GUICtrlCreateInput($INP_Fileversion, 120, 110, 80, 20)
	;
	$H_Fileversion_AutoIncrement_n = GUICtrlCreateRadio("Don't Auto Increment.", 210, 110, Default, Default, $WS_GROUP)
	$H_Fileversion_AutoIncrement_y = GUICtrlCreateRadio("Auto Increment", 340, 110)
	$H_Fileversion_AutoIncrement_p = GUICtrlCreateRadio("Prompt to Auto Increment", 450, 110)
	Switch $INP_Fileversion_AutoIncrement
		Case "y"
			GUICtrlSetState($H_Fileversion_AutoIncrement_y, $GUI_CHECKED)
		Case "p"
			GUICtrlSetState($H_Fileversion_AutoIncrement_p, $GUI_CHECKED)
		Case Else
			GUICtrlSetState($H_Fileversion_AutoIncrement_n, $GUI_CHECKED)
	EndSwitch
	;
	Local $H_Res_L12 = GUICtrlCreateLabel("ProductVersion:", 21, 137, 90, 20, $SS_RIGHT)
	$H_ProductVersion = GUICtrlCreateInput($INP_ProductVersion, 120, 135, 80, 20)
	Local $H_Res_L13 = GUICtrlCreateLabel("ProductName:", 210, 137, 68, 20, $SS_RIGHT)
	$H_ProductName = GUICtrlCreateInput($INP_ProductName, 280, 135, 320, 20)
	;
	Local $H_Res_L04 = GUICtrlCreateLabel("CompanyName:", 21, 140 + 25, 90, 20, BitOR($SS_RIGHT, $WS_GROUP))
	$H_CompanyName = GUICtrlCreateInput($INP_CompanyName, 120, 135 + 25, 480, 20)
	;
	Local $H_Res_L10 = GUICtrlCreateLabel("LegalCopyright:", 21, 165 + 25, 90, 20, BitOR($SS_RIGHT, $WS_GROUP))
	$H_LegalCopyright = GUICtrlCreateInput($INP_LegalCopyright, 120, 160 + 25, 480, 20)
	;
	Local $H_Res_L11 = GUICtrlCreateLabel("LegalTradeMarks:", 21, 190 + 25, 90, 20, BitOR($SS_RIGHT, $WS_GROUP))
	$H_LegalTradeMarks = GUICtrlCreateInput($INP_LegalTradeMarks, 120, 185 + 25, 480, 20)
	;
	Local $H_Res_L05 = GUICtrlCreateLabel("Language:", 21, 215 + 25, 90, 20, $SS_RIGHT)
	$H_Res_Language = GUICtrlCreateCombo("", 120, 210 + 25, 480, 20, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE)) ; $CBS_DROPDOWNLIST)
	Local $CountryTable, $Country
	Language_Code($INP_Res_Language, $CountryTable, $Country, 1)
	GUICtrlSetData(-1, $CountryTable, $Country)                      ; add other item snd set a new default
	Local $INP_FieldNameEdit = ""
	If $INP_FieldName1 <> "" Then
		$INP_FieldNameEdit &= $INP_FieldName1 & " = " & $INP_FieldValue1 & @CRLF
	EndIf
	If $INP_FieldName2 <> "" Then
		$INP_FieldNameEdit &= $INP_FieldName2 & " = " & $INP_FieldValue2 & @CRLF
	EndIf
	For $U = 1 To $INP_Res_FieldCount
		$INP_FieldNameEdit &= $INP_FieldName[$U] & " = " & $INP_FieldValue[$U] & @CRLF
	Next
	; "asInvoker", "highestAvailable", "requireAdministrator"
	Local $H_Res_L06 = GUICtrlCreateLabel("RequestedExecutionLevel:", 10, 239 + 25, 128, 20, $SS_RIGHT)
	Local $H_Res_requestedExecutionLevel_d = GUICtrlCreateRadio("Default", 140, 236 + 25, Default, Default, $WS_GROUP)
	Local $H_Res_requestedExecutionLevel_a = GUICtrlCreateRadio("asInvoker", 200, 236 + 25)
	Local $H_Res_requestedExecutionLevel_h = GUICtrlCreateRadio("highestAvailable", 275, 236 + 25)
	Local $H_Res_requestedExecutionLevel_r = GUICtrlCreateRadio("requireAdministrator", 380, 236 + 25)
	Local $H_Res_requestedExecutionLevel_n = GUICtrlCreateRadio("None", 500, 236 + 25)
	Switch $INP_Res_requestedExecutionLevel
		Case "None"
			GUICtrlSetState($H_Res_requestedExecutionLevel_n, $GUI_CHECKED)
		Case "asInvoker"
			GUICtrlSetState($H_Res_requestedExecutionLevel_a, $GUI_CHECKED)
		Case "highestAvailable"
			GUICtrlSetState($H_Res_requestedExecutionLevel_h, $GUI_CHECKED)
		Case "requireAdministrator"
			GUICtrlSetState($H_Res_requestedExecutionLevel_r, $GUI_CHECKED)
		Case Else
			GUICtrlSetState($H_Res_requestedExecutionLevel_d, $GUI_CHECKED)
	EndSwitch
	;
	Local $H_Res_L07 = GUICtrlCreateLabel("Extra resource Fields:", 11, 280 + 25, 74, 40, BitOR($SS_RIGHT, $WS_GROUP))
	$H_FieldNameEdit = GUICtrlCreateEdit($INP_FieldNameEdit, 100, 260 + 25, 500, 150 - 25)
	;
	Local $H_Res_SaveSource = GUICtrlCreateCheckbox("Save a copy of the Scriptsource in the output program resources.", 100, 415)
	If $INP_Res_SaveSource = "y" Then GUICtrlSetState($H_Res_SaveSource, $GUI_CHECKED)
	;
	;=========================================================================================================================================
	Local $tab1b = GUICtrlCreateTabItem("Res Add Files")
	Local $H_Res_L08 = GUICtrlCreateLabel("Extra Icons:", 11, 80, 74, 40, $SS_RIGHT)
	Local $INP_Icons_txt = ""
	For $x = 1 To $INP_Icons_cnt
		$INP_Icons_txt &= $INP_Icons[$x] & @CRLF
	Next
	Local $H_Icons = GUICtrlCreateEdit($INP_Icons_txt, 100, 60, 500, 160)
	Local $H_Res_L09 = GUICtrlCreateLabel("Extra Files:", 11, 250, 74, 40, $SS_RIGHT)
	;
	Local $Inp_Res_Files_txt = ""
	For $x = 1 To $INP_Res_Files_Cnt
		$Inp_Res_Files_txt &= $INP_Res_Files[$x] & @CRLF
	Next
	Local $H_Res_Files = GUICtrlCreateEdit($Inp_Res_Files_txt, 100, 230, 500, 160)
	GUICtrlSetTip($H_Res_L06, "Specify the RequestedExecutionLevel to be set in the Program Manifest.")
	GUICtrlSetTip($H_Res_requestedExecutionLevel_d, "Use the default from AUT2EXE setting in the Program Manifest.")
	GUICtrlSetTip($H_Res_requestedExecutionLevel_a, "Specify the RequestedExecutionLevel to be set in the Program Manifest.")
	GUICtrlSetTip($H_Res_requestedExecutionLevel_h, "Specify the RequestedExecutionLevel to be set in the Program Manifest.")
	GUICtrlSetTip($H_Res_requestedExecutionLevel_r, "Specify the RequestedExecutionLevel to be set in the Program Manifest.")
	GUICtrlSetTip($H_Res_requestedExecutionLevel_n, "Remove the current RequestedExecutionLevel from the Program Manifest set by AUT2EXE.")
	GUICtrlSetTip($H_FieldNameEdit, 'Add extra Resource info. One per line.' & @CRLF & 'Syntax: Fieldname = Description.' & @CRLF & 'Example:Made By = Jos van der Zande')
	GUICtrlSetTip($H_Res_L07, 'Add extra Resource info. One per line.' & @CRLF & 'Syntax: Fieldname = Description.' & @CRLF & 'Example:Made By = Jos van der Zande')
	GUICtrlSetTip($H_Icons, "Specify additional Icons to be included in the programs resources." & @CRLF & "One file per line." & @CRLF & "(F1-see helpfile for details)")
	GUICtrlSetTip($H_Res_L09, "Specify additional Files to be included in the programs resources." & @CRLF & "One file per line. Format: Filename[,Section [,ResName]]" & @CRLF & "(F1-see helpfile for details)")
	GUICtrlSetTip($H_Res_Files, "Specify additional Files to be included in the programs resources." & @CRLF & "One file per line. Format: Filename[,Section [,ResName]]" & @CRLF & "(F1-see helpfile for details)")
	;=================================================================================================================================
	Local $tab2 = GUICtrlCreateTabItem("Run Before/After")
	; run before program
	Local $H_Run_Stop_OnError = GUICtrlCreateCheckbox("Stop on RUN error (not returning 0)", 20, 35)
	If $INP_Run_Stop_OnError = "y" Then GUICtrlSetState($H_Run_Stop_OnError, $GUI_CHECKED)
	;
	GUICtrlCreateLabel("Specify here the commands to run before and after the Compilation process.", 50, 60, 500, 20)
	GUICtrlCreateLabel("Run before :", 30, 100, 65, 20, $SS_RIGHT)
	Local $txt_INP_Run_Before
	For $x = 1 To $INP_Run_Before[0]
		If $INP_Run_Before[$x] <> "" Then
			$txt_INP_Run_Before &= $INP_Run_Before[$x]
			If Not ($x = $INP_Run_Before[0]) Then $txt_INP_Run_Before &= @CRLF
		EndIf
	Next
	Local $H_Run_Before = GUICtrlCreateEdit($txt_INP_Run_Before, 100, 85, 445, 80)
	GUICtrlCreateLabel("Run after :", 30, 200, 65, 20, $SS_RIGHT)
	Local $txt_INP_Run_After
	For $x = 1 To $INP_Run_After[0]
		If $INP_Run_After[$x] <> "" Then
			$txt_INP_Run_After &= $INP_Run_After[$x]
			If Not ($x = $INP_Run_After[0]) Then $txt_INP_Run_After &= @CRLF
		EndIf
	Next
	Local $H_Run_After = GUICtrlCreateEdit($txt_INP_Run_After, 100, 170, 445, 80)
	Local $temp = "These commands will be executed one at a time as cmdline commands. " & @CRLF & _
			'The Commandlines can contain the following variables:' & @CRLF & _
			'  %in% , %out%, %outx64%, %icon% which will be replaced by the fullpath\filename.' & @CRLF & _
			'  %scriptdir% same as @ScriptDir and %scriptfile% = filename without extension.' & @CRLF & _
			'  %fileversion% set to the #AutoIt3Wrapper_Res_Fileversion directive value.' & @CRLF & _
			'  %scitedir% will be replaced by the SciTE program directory' & @CRLF & _
			'Examples:' & @CRLF & _
			'   copy "%in%" "c:\program files\autoit3\SciTE\AutoIt3Wrapper"' & @CRLF & _
			'   copy "%out%" "c:\program files\autoit3\SciTE\AutoIt3Wrapper"' & @CRLF & _
			'   start aacopy.bat "%out%" "C:\Program Files\AutoIt3\SciTE\AutoIt3Wrapper"'
	GUICtrlCreateEdit($temp, 20, 260, 600, 170, $ES_READONLY)
	GUICtrlSetFont(-1, Default, Default, Default, "Courier New")
	GUICtrlSetTip($H_Run_Before, "Specify the command(s), one on each line, to be executed before compilation.")
	GUICtrlSetTip($H_Run_After, "Specify the command(s), one on each line, to be executed after compilation.")
	;=================================================================================================================================
	Local $tab3 = GUICtrlCreateTabItem("Au3Check")
	; Run au3Check before compilation?
	GUICtrlCreateLabel("Au3Check Version: " & FileGetVersion($CurrentAutoIt_InstallDir & "\Au3check.exe"), 400, 50, 180, 20, $SS_RIGHT)
	Local $H_Run_AU3Check = GUICtrlCreateCheckbox("Run AU3Check before compilation.", 100, 65, 250, 20)
	If $INP_Run_AU3Check = "y" Then GUICtrlSetState($H_Run_AU3Check, $GUI_CHECKED)
	If $INP_Add_Constants = "y" Then GUICtrlSetState($H_Add_Constants, $GUI_CHECKED)
	Local $H_AU3Check_Stop_OnWarning = GUICtrlCreateCheckbox("Also stop on warnings", 100, 90, 250, 20)
	If $INP_AU3Check_Stop_OnWarning = "y" Then GUICtrlSetState($H_AU3Check_Stop_OnWarning, $GUI_CHECKED)
	GUICtrlCreateLabel("Skip Plugin Func(s):", 30, 115, 120, 20, $SS_RIGHT)
	Local $H_AU3Check_Plugin = GUICtrlCreateInput($INP_Au3check_Plugin, 155, 113, 390, 20)
	GUICtrlCreateLabel("Au3Check Parameters :", 30, 145, 120, 20, $SS_RIGHT)
	Local $H_AU3Check_Parameters = GUICtrlCreateInput($INP_AU3Check_Parameters, 155, 143, 390, 20)
	$temp = "Possible Parameters: " & @CRLF & _
			'     -q        : quiet (only error/warn output)' & @CRLF & _
			'     -d        : as Opt("MustDeclareVars", 1)' & @CRLF & _
			'     -I dir    : additional directories for searching include files' & @CRLF & _
			'     -U -|file : output unreferenced UDFs and global variables' & @CRLF & _
			'     -w 1      : already included file (on)' & @CRLF & _
			'     -w 2      : missing #comments-end (on)' & @CRLF & _
			'     -w 3      : already declared var (off)' & @CRLF & _
			'     -w 4      : local var used in global scope (off)' & @CRLF & _
			'     -w 5      : local var declared but not used (off)' & @CRLF & _
			'     -w 6      : warn when using Dim (off)' & @CRLF & _
			'     -v 1      : show include paths/files (off)' & @CRLF & _
			'     -v 2      : show lexer tokens (off)'
	GUICtrlCreateEdit($temp, 20, 180, 600, 240, $ES_READONLY)
	GUICtrlSetFont(-1, Default, Default, Default, "Courier New")
	GUICtrlSetTip($H_Run_AU3Check, "Run Au3Check to check your source for possible problems.")
	GUICtrlSetTip($H_AU3Check_Stop_OnWarning, "Also stop when Au3Check detects warnings." & @CRLF & "Normal behaviour is to continue.")
	;=================================================================================================================================
	Local $tab4 = GUICtrlCreateTabItem("Tidy")
	; Run Tidy ?
	GUICtrlCreateLabel("Tidy Version: " & FileGetVersion($SciTE_Dir & "\Tidy\Tidy.exe"), 400, 50, 180, 20, $SS_RIGHT)
	Local $H_Run_Tidy = GUICtrlCreateCheckbox("Run Tidy before compilation.", 100, 65, 250, 20)
	If $INP_Run_Tidy = "y" Then GUICtrlSetState($H_Run_Tidy, $GUI_CHECKED)
	;
	Local $H_Tidy_Stop_OnError = GUICtrlCreateCheckbox("Stop on Tidy Errors", 100, 90, 250, 20)
	If $INP_Tidy_Stop_OnError = "y" Then GUICtrlSetState($H_Tidy_Stop_OnError, $GUI_CHECKED)
	;
	GUICtrlCreateLabel("Tidy Parameters :", 30, 115, 120, 20, $SS_RIGHT)
	Local $H_Tidy_Parameters = GUICtrlCreateInput($INP_Tidy_Parameters, 155, 113, 390, 20)
	$temp = "Possible Parameters: " & @CRLF & _
			"   /tc n  : 0=Tab >0=Number of Spaces." & @CRLF & _
			"   /gd    : Generate documentation file." & @CRLF & _
			"   /rel   : Remove empty lines from the source." & @CRLF & _
			"   /reel  : Remove extra empty lines from the source, leaving one one." & @CRLF & _
			"   /ri    : Region indent." & @CRLF & _
			"   /sci 0 : Default Minimal output to the console: warning and errors." & @CRLF & _
			"   /sci 1 : Show more progress information. " & @CRLF & _
			"   /sci 9 : Show all debug lines as found in the Au3Stripper.log." & @CRLF & _
			"   /gds   : Show generated doc file in Notepad." & @CRLF & _
			'   /sdp x : Specify Diffprogram to use eg: ' & @CRLF & _
			'            /sdp C:\Progra~1\WinMerge\winmerge.exe "%new%" "%old%"' & @CRLF & _
			"   /nsdp  : Don't run program as specified by /sdp." & @CRLF & _
			"   /kv n  : n = number of backcopies to keep. 0 = all" & @CRLF & _
			"   /bdir x: x = Target backup directory." & @CRLF & _
			"   /sf    : Sort all Func-Endfunc Blocks in sequence FuncName." & @CRLF & _
			"            When #Region-#EndRegion is used sort them within that scope." & @CRLF & _
			"   /sfc   : Same as /sf but first sorts on Comment at the end of the Func() statement"
	GUICtrlCreateEdit($temp, 20, 150, 605, 250, $ES_READONLY)
	GUICtrlSetFont(-1, Default, Default, Default, "Courier New")
	;=================================================================================================================================
	Local $tab5 = GUICtrlCreateTabItem("Au3Stripper")
	; Run Au3Stripper ?
	GUICtrlCreateLabel("Au3Stripper Version: " & FileGetVersion($SciTE_Dir & "\Au3Stripper\Au3Stripper.exe"), 400, 50, 180, 20, $SS_RIGHT)
	Local $H_Run_Au3Stripper = GUICtrlCreateCheckbox("Run Au3Stripper before compilation.", 100, 65, 250, 20)
	If $INP_Run_Au3Stripper = "y" Then GUICtrlSetState($H_Run_Au3Stripper, $GUI_CHECKED)
	GUICtrlCreateLabel("Au3Stripper Parameters :", 30, 90, 120, 20, $SS_RIGHT)
	Local $H_Au3Stripper_Parameters = GUICtrlCreateInput($INP_Au3Stripper_Parameters, 155, 87, 390, 20)
	$temp = "Possible Parameters: " & @CRLF & _
			"/tl : Create Au3Stripper.Log with a trace of all actions." & @CRLF & _
			"/debug: add Debug information to Au3Stripper.Log." & @CRLF & _
			"/pe : Replace any reference to a Global Const variable with its actual value." & @CRLF & _
			"/so : This is the default when no parameters are provided. same as /sf + /sv" & @CRLF & _
			"/sf : Strip all unused Func's" & @CRLF & _
			"/sv : Strip unused Global and Local variable declarations." & @CRLF & _
			"/mo : Just merges the Include files into the source and strips the Comments." & @CRLF & _
			"      This is similar to aut2exe and helps finding the errorline." & @CRLF & _
			"/mi : Sets the maximum Iterations Au3Stripper will perform. Default is 5." & @CRLF & _
			"/rm : Rename Variables and Functions to a shorter name." & @CRLF & _
			"/rsln: Replace @ScriptLineNumber with the actual line number." & @CRLF & _
			"/Beta: Use Beta Includes." & @CRLF
	GUICtrlCreateEdit($temp, 20, 130, 600, 250, $ES_READONLY)
	GUICtrlSetFont(-1, Default, Default, Default, "Courier New")
	;=================================================================================================================================
	Local $H_Run_Versioning_n, $H_Run_Versioning_y, $H_Run_Versioning_v
	Local $H_cvs_Parameters, $tab6
	If FileExists($SciTE_Dir & "\VersionWrapper\VersionWrapper.exe") Then
		$tab6 = GUICtrlCreateTabItem("VersionWrapper")
		; Run VersionWrapper
		GUICtrlCreateLabel("VersionWrapper Version: " & FileGetVersion($SciTE_Dir & "\VersionWrapper\VersionWrapper.exe"), 400, 50, 180, 20, $SS_RIGHT)
		GUICtrlCreateLabel("Options to run the installed VersionWrapper addon", 30, 70, 600, 20)
		$H_Run_Versioning_n = GUICtrlCreateRadio("Don't run VersionWrapper.", 100, 95, 260, 20)
		$H_Run_Versioning_y = GUICtrlCreateRadio("Always Run VersionWrapper.", 100, 115, 260, 20)
		$H_Run_Versioning_v = GUICtrlCreateRadio("Only when FileVersion_AutoIncrement is set to yes.", 100, 135, 260, 20)
		Switch $INP_Run_Versioning
			Case "y"
				GUICtrlSetState($H_Run_Versioning_y, $GUI_CHECKED)
			Case "v"
				GUICtrlSetState($H_Run_Versioning_v, $GUI_CHECKED)
			Case Else
				GUICtrlSetState($H_Run_Versioning_n, $GUI_CHECKED)
		EndSwitch
		GUICtrlCreateLabel("cvs Parameters :", 10, 165, 90, 20, $SS_RIGHT)
		$H_cvs_Parameters = GUICtrlCreateInput($INP_Versioning_Parameters, 110, 162, 500, 20)
		$temp = "Possible parameters. " & @CRLF & _
				"   /NoPrompt  : Will skip the cvsComments prompt" & @CRLF & _
				"   /Comments  : Text to added in the cvsComments. It can contain the below variables." & @CRLF & _
				'The Commandlines can contain the following variables:' & @CRLF & _
				'  %in% , %out%, %outx64%, %icon% which will be replaced by the fullpath\filename.' & @CRLF & _
				'  %scriptdir% same as @ScriptDir and %scriptfile% = filename without extension.' & @CRLF & _
				'  %fileversion% set to the #AutoIt3Wrapper_Res_Fileversion directive value.' & @CRLF & _
				'  %scitedir% will be replaced by the SciTE program directory'
		GUICtrlCreateEdit($temp, 20, 190, 605, 240, $ES_READONLY)
		GUICtrlSetFont(-1, Default, Default, Default, "Courier New")
	EndIf
	;=================================================================================================================================
	GUICtrlCreateTabItem("")                                         ; end tabitem definition
	Local $H_COMPILE = GUICtrlCreateButton("&Compile Script", 120, 445, 120, 30)
	; make compile the default button with focus
	GUICtrlSetState($H_COMPILE, 256)
	Local $H_SaveOnly = GUICtrlCreateButton("&Save Only", 250, 445, 120, 30)
	;
	Local $H_CANCEL = GUICtrlCreateButton("C&ancel", 380, 445, 120, 30)
	GUICtrlCreateLabel("(F1 = Help)", 550, 460)
	GUISetState(@SW_SHOW)
	; Process GUI Input
	;-------------------------------------------------------------------------------------------
	While 1
		$rc = GUIGetMsg()
		If $rc = 0 Then ContinueLoop
		; Cancel clicked
		If $rc = $H_CANCEL Then Exit
		If $rc = $h_Exit Then Exit
		If $rc = $h_HelpFile Then
			Run('"' & @WindowsDir & '\hh.exe" "' & @ScriptDir & '\..\Scite4AutoIt3.chm::/AutoIt3Wrapper.htm"')
			ContinueLoop
		EndIf
		If $rc = $h_About Then
			MsgBox(262208, "AutoIt3Wrapper_GUI", _
					"AutoIt3Wrapper GUI is written to add Directives to the scriptsource which are used by AutoIt3Wrapper" & @CRLF & @CRLF & "Copyright (c) Jos van der Zande.")
		EndIf
		If $rc = -3 Then Exit
		; Change Target program clicked
		Switch $rc
			Case $tab
				Switch GUICtrlRead($tab)
					Case 1
						GUISetHelp('"' & @WindowsDir & '\hh.exe" "' & @ScriptDir & '\..\Scite4AutoIt3.chm::/AutoIt3Wrapper.htm"')
					Case 2
						GUISetHelp('"' & @WindowsDir & '\hh.exe" "' & @ScriptDir & '\..\Scite4AutoIt3.chm::/AutoIt3Wrapper.htm"')
					Case 3
						GUISetHelp('"' & @WindowsDir & '\hh.exe" "' & @ScriptDir & '\..\Scite4AutoIt3.chm::/AutoIt3Wrapper.htm"')
					Case 4
						GUISetHelp('"' & @WindowsDir & '\hh.exe" "' & @ScriptDir & '\..\Scite4AutoIt3.chm::/AutoIt3Wrapper.htm"')
					Case 5
						GUISetHelp('"' & @WindowsDir & '\hh.exe" "' & @ScriptDir & '\..\Scite4AutoIt3.chm::/tidy_doc.htm"')
					Case 6
						GUISetHelp('"' & @WindowsDir & '\hh.exe" "' & @ScriptDir & '\..\Scite4AutoIt3.chm::/Au3Stripper_doc.htm"')
					Case 7
						GUISetHelp('"' & @WindowsDir & '\hh.exe" "' & @ScriptDir & '\..\VersionWrapper\VersionWrapper.htm"')
				EndSwitch
			Case $H_SCRIPTFILE_OUT_CHANGE
				$Init_Dir = GUICtrlRead($H_SCRIPTFILE_OUT)
				$Init_Dir = _PathFull($Init_Dir)
				$Save_Workdir = @WorkingDir
				Local $ScriptFile_Out_New = FileOpenDialog("Select the Target program?", $Init_Dir, "Programs(*.Exe;*.A3x)", 2)
				If @error = 0 And $ScriptFile_Out_New <> "" Then
					;$ScriptFile_Out = $ScriptFile_Out_New
					$ScriptFile_Out_New = DirGetRelativePath($ScriptFile_In, $ScriptFile_Out_New)
					_PathSplit($ScriptFile_Out_New, $szDrive, $szDir, $szFName, $szExt)
					If GUICtrlRead($H_Out_Type_a) = $GUI_CHECKED Then
						If $szExt <> ".a3x" Then $ScriptFile_Out_New = $szDrive & $szDir & $szFName & ".a3x"
					Else
						If $szExt <> ".exe" Then $ScriptFile_Out_New = $szDrive & $szDir & $szFName & ".exe"
					EndIf
					GUICtrlSetData($H_SCRIPTFILE_OUT, $ScriptFile_Out_New)
					If StringRight($ScriptFile_Out_New, 3) = "a3x" Then
						Set_Res_state($GUI_DISABLE)
					Else
						Set_Res_state($GUI_ENABLE)
					EndIf
				EndIf
				FileChangeDir($Save_Workdir)
			Case $H_SCRIPTFILE_OUT_CHANGE_X64
				$Init_Dir = GUICtrlRead($H_SCRIPTFILE_OUT_X64)
				$Init_Dir = _PathFull($Init_Dir)
				$Save_Workdir = @WorkingDir
				Local $ScriptFile_Out_New_x64 = FileOpenDialog("Select the Target program?", $Init_Dir, "Programs(*.Exe;*.A3x)", 2)
				If @error = 0 And $ScriptFile_Out_New_x64 <> "" Then
					;$ScriptFile_Out = $ScriptFile_Out_New
					$ScriptFile_Out_New_x64 = DirGetRelativePath($ScriptFile_In, $ScriptFile_Out_New_x64)
					_PathSplit($ScriptFile_Out_New_x64, $szDrive, $szDir, $szFName, $szExt)
					If GUICtrlRead($H_Out_Type_a) = $GUI_CHECKED Then
						If $szExt <> ".a3x" Then $ScriptFile_Out_New_x64 = $szDrive & $szDir & $szFName & ".a3x"
					Else
						If $szExt <> ".exe" Then $ScriptFile_Out_New_x64 = $szDrive & $szDir & $szFName & ".exe"
					EndIf
					GUICtrlSetData($H_SCRIPTFILE_OUT_X64, $ScriptFile_Out_New_x64)
					If StringRight($ScriptFile_Out_New_x64, 3) = "a3x" Then
						Set_Res_state($GUI_DISABLE)
					Else
						Set_Res_state($GUI_ENABLE)
					EndIf
				EndIf
				FileChangeDir($Save_Workdir)
				; Change icon clicked
			Case $H_INP_ICON_CHANGE
				;$Init_Dir = RegRead($Registry & "\Aut2Exe", "LastIcon")
				$Init_Dir = GUICtrlRead($H_INP_ICON)
				$Init_Dir = _PathFull($Init_Dir)
				$Save_Workdir = @WorkingDir
				Local $H_INP_ICON_NEW = FileOpenDialog("Select the ICON for the program?", $Init_Dir, "Icons(*.ico)", 1)
				If @error = 0 Then
					If $H_INP_ICON_ICO = 0 Then
						$H_INP_ICON_ICO = GUICtrlCreateIcon($H_INP_ICON_NEW, Default, 545, 230)
						GUICtrlSetImage($H_INP_ICON_ICO, $H_INP_ICON_NEW)
					Else
						GUICtrlSetImage($H_INP_ICON_ICO, $H_INP_ICON_NEW)
					EndIf
;~ 					$INP_Icon = $H_INP_ICON_NEW
					$H_INP_ICON_NEW = DirGetRelativePath($ScriptFile_In, $H_INP_ICON_NEW)
					GUICtrlSetData($H_INP_ICON, $H_INP_ICON_NEW)
				EndIf
				FileChangeDir($Save_Workdir)
			Case $H_COMPILE, $H_SaveOnly
				; Validate Extra resource Information
				Local $tempvalues = StringSplit(GUICtrlRead($H_FieldNameEdit), @CRLF)
				For $U = 1 To $tempvalues[0]
					If StringStripWS($tempvalues[$U], 3) <> "" And StringInStr($tempvalues[$U], "|") + StringInStr($tempvalues[$U], "=") = 0 Then
						_GUICtrlTab_SetCurFocus($tab, 1)
						GUICtrlSetState($H_FieldNameEdit, $GUI_FOCUS)
						GUICtrlSetTip($H_FieldNameEdit, 'Add extra Resource info. One per line.' & @CRLF & 'Syntax: Fieldname = Description.' & @CRLF & 'Example:Made By = Jos van der Zande')
						MsgBox(4096 + 16 + 1, "Extra Resource Fields Error.", "There is one or more lines that doesn't contain a =.")
						ContinueLoop 2
					EndIf
				Next
				ExitLoop
		EndSwitch
	WEnd
	GUISetState(@SW_HIDE)
	; --- Read all info from the GUI
	Local $Save_Only = 0
	Local $Changes = 0
	;
	If $rc = $H_SaveOnly Then $Save_Only = 1
	;
	$ScriptFile_Out_New = GUICtrlRead($H_SCRIPTFILE_OUT)
	_PathSplit($ScriptFile_Out_New, $szDrive, $szDir, $szFName, $szExt)
	If $ScriptFile_Out_New <> "" Then
		If GUICtrlRead($H_Out_Type_a) = $GUI_CHECKED Then
			If $szExt <> ".a3x" Then $ScriptFile_Out_New = $szDrive & $szDir & $szFName & ".a3x"
		Else
			If $szExt <> ".exe" Then $ScriptFile_Out_New = $szDrive & $szDir & $szFName & ".exe"
		EndIf
	EndIf
	GUICtrlSetData($H_SCRIPTFILE_OUT, $ScriptFile_Out_New)
	$Changes += GUI_GetValue($H_SCRIPTFILE_OUT, $ScriptFile_Out)
	;
	$ScriptFile_Out_New_x64 = GUICtrlRead($H_SCRIPTFILE_OUT_X64)
	_PathSplit($ScriptFile_Out_New_x64, $szDrive, $szDir, $szFName, $szExt)
	If $ScriptFile_Out_New_x64 <> "" Then
		If GUICtrlRead($H_Out_Type_a) = $GUI_CHECKED Then
			If $szExt <> ".a3x" Then $ScriptFile_Out_New_x64 = $szDrive & $szDir & $szFName & ".a3x"
		Else
			If $szExt <> ".exe" Then $ScriptFile_Out_New_x64 = $szDrive & $szDir & $szFName & ".exe"
		EndIf
	EndIf
	GUICtrlSetData($H_SCRIPTFILE_OUT_X64, $ScriptFile_Out_New_x64)
	$Changes += GUI_GetValue($H_SCRIPTFILE_OUT_X64, $ScriptFile_Out_x64)
	;
	Local $GUI_ScriptFile_Out_Type
	If GUICtrlRead($H_Out_Type_a) = $GUI_CHECKED Then
		$GUI_ScriptFile_Out_Type = "a3x"
	Else
		$GUI_ScriptFile_Out_Type = "exe"
	EndIf
	If $ScriptFile_Out_Type <> $GUI_ScriptFile_Out_Type Then
		$ScriptFile_Out_Type = $GUI_ScriptFile_Out_Type
		$Changes += 1
	EndIf
	;
	$Changes += GUI_GetValue($H_INP_ICON, $INP_Icon)
	;
	$Changes += GUI_GetValue($H_Compression, $INP_W_Compression)
	If $INP_W_Compression = "Lowest" Then $INP_Compression = "0"
	If $INP_W_Compression = "Low" Then $INP_Compression = 1
	If $INP_W_Compression = "Normal" Then $INP_Compression = 2
	If $INP_W_Compression = "High" Then $INP_Compression = 3
	If $INP_W_Compression = "Highest" Then $INP_Compression = 4
	$Changes += GUI_GetValue($H_Change2CUI, $INP_Change2CUI, "1=y;0=n;4=n")
	;
;~ 	$INP_Allow_Decompile = GUICtrlRead($H_INP_NODECOMPILE)
	;
	$Changes += GUI_GetValue($H_Comment, $INP_Comment)
	$Changes += GUI_GetValue($H_Description, $INP_Description)
	$Changes += GUI_GetValue($H_Fileversion, $INP_Fileversion)
	$Changes += GUI_GetValue($H_Res_Language, $Country)
	Language_Code($INP_Res_Language, $CountryTable, $Country, 2)
	;None, asInvoker, highestAvailable or requireAdministrator   (default=None)"
	Local $GUI_RES_requestedExecutionLevel
	If GUICtrlRead($H_Res_requestedExecutionLevel_n) = $GUI_CHECKED Then
		$GUI_RES_requestedExecutionLevel = "None"
	ElseIf GUICtrlRead($H_Res_requestedExecutionLevel_a) = $GUI_CHECKED Then
		$GUI_RES_requestedExecutionLevel = "asInvoker"
	ElseIf GUICtrlRead($H_Res_requestedExecutionLevel_h) = $GUI_CHECKED Then
		$GUI_RES_requestedExecutionLevel = "highestAvailable"
	ElseIf GUICtrlRead($H_Res_requestedExecutionLevel_r) = $GUI_CHECKED Then
		$GUI_RES_requestedExecutionLevel = "requireAdministrator"
	Else
		$GUI_RES_requestedExecutionLevel = ""
	EndIf
	If $INP_Res_requestedExecutionLevel <> $GUI_RES_requestedExecutionLevel Then
		$INP_Res_requestedExecutionLevel = $GUI_RES_requestedExecutionLevel
		$Changes += 1
	EndIf
	;
	Local $GUI_Fileversion_AutoIncrement
	If GUICtrlRead($H_Fileversion_AutoIncrement_y) = $GUI_CHECKED Then
		$GUI_Fileversion_AutoIncrement = "y"
	ElseIf GUICtrlRead($H_Fileversion_AutoIncrement_p) = $GUI_CHECKED Then
		$GUI_Fileversion_AutoIncrement = "p"
	Else
		$GUI_Fileversion_AutoIncrement = "n"
	EndIf
	If $INP_Fileversion_AutoIncrement <> $GUI_Fileversion_AutoIncrement Then
		$INP_Fileversion_AutoIncrement = $GUI_Fileversion_AutoIncrement
		$Changes += 1
	EndIf
	;
	$Changes += GUI_GetValue($H_ProductName, $INP_ProductName)
	$Changes += GUI_GetValue($H_ProductVersion, $INP_ProductVersion)
	$Changes += GUI_GetValue($H_CompanyName, $INP_CompanyName)
	$Changes += GUI_GetValue($H_LegalCopyright, $INP_LegalCopyright)
	$Changes += GUI_GetValue($H_LegalTradeMarks, $INP_LegalTradeMarks)
	$Changes += GUI_GetValue($H_FieldNameEdit, $INP_FieldNameEdit)
	$Changes += GUI_GetValue($H_Icons, $INP_Icons_txt)
	$Changes += GUI_GetValue($H_Res_Files, $Inp_Res_Files_txt)
	$Changes += GUI_GetValue($H_Res_SaveSource, $INP_Res_SaveSource, "1=y;0=n;4=n")
	;
	$Changes += GUI_GetValue($H_Run_AU3Check, $INP_Run_AU3Check, "1=y;0=n;4=n")
	$Changes += GUI_GetValue($H_Add_Constants, $INP_Add_Constants, "1=y;0=n;4=n")
	$Changes += GUI_GetValue($H_AU3Check_Stop_OnWarning, $INP_AU3Check_Stop_OnWarning, "1=y;0=n;4=n")
	$Changes += GUI_GetValue($H_AU3Check_Plugin, $INP_Au3check_Plugin)
	$Changes += GUI_GetValue($H_AU3Check_Parameters, $INP_AU3Check_Parameters)
	$Changes += GUI_GetValue($H_Run_Stop_OnError, $INP_Run_Stop_OnError, "1=y;0=n;4=n")
	$Changes += GUI_GetValue($H_Run_Before, $txt_INP_Run_Before)
	$Changes += GUI_GetValue($H_Run_After, $txt_INP_Run_After)
	$Changes += GUI_GetValue($H_Run_Tidy, $INP_Run_Tidy, "1=y;0=n;4=n")
	$Changes += GUI_GetValue($H_Tidy_Stop_OnError, $INP_Tidy_Stop_OnError, "1=y;0=n;4=n")
	$Changes += GUI_GetValue($H_Tidy_Parameters, $INP_Tidy_Parameters)
	$Changes += GUI_GetValue($H_Run_Au3Stripper, $INP_Run_Au3Stripper, "1=y;0=n;4=n")
	$Changes += GUI_GetValue($H_Au3Stripper_Parameters, $INP_Au3Stripper_Parameters)
	;
	Local $GUI_AutoIt3_Version
	If GUICtrlRead($H_AUTOIT3_Version_B) = $GUI_CHECKED Then
		$GUI_AutoIt3_Version = "Beta"
	Else
		$GUI_AutoIt3_Version = "Prod"
	EndIf
	If $INP_AutoIt3_Version <> $GUI_AutoIt3_Version Then
		$INP_AutoIt3_Version = $GUI_AutoIt3_Version
		$Changes += 1
	EndIf
	;
	; X86/X64 logic
	Local $GUI_UseX64
	If GUICtrlRead($H_AUTOIT3_X64) = $GUI_CHECKED And GUICtrlRead($H_AUTOIT3_X86) = $GUI_CHECKED Then
		If $INP_Compile_Both = 'n' Then
			$INP_Compile_Both = 'y'
			$Changes += 1
		EndIf
	Else
		If $INP_Compile_Both = 'y' Then
			$INP_Compile_Both = 'n'
			$Changes += 1
		EndIf
	EndIf
	;
	If GUICtrlRead($H_AUTOIT3_X64) = $GUI_CHECKED Then
		$GUI_UseX64 = "y"
	Else
		$GUI_UseX64 = "n"
	EndIf
	If $INP_UseX64 <> $GUI_UseX64 Then
		$INP_UseX64 = $GUI_UseX64
		$Changes += 1
	EndIf
	; UPX
	Local $GUI_UseUpx
	If GUICtrlRead($H_AUTOIT3_Upx) = $GUI_CHECKED Then
		$GUI_UseUpx = "y"
	Else
		$GUI_UseUpx = "n"
	EndIf
	If $INP_UseUpx <> $GUI_UseUpx Then
		$INP_UseUpx = $GUI_UseUpx
		$Changes += 1
	EndIf
	;
	If $H_cvs_Parameters Then
		; Check VersionWrapper parameters when VersionWrapper is installed
		Local $GUI_Run_Versioning
		If GUICtrlRead($H_Run_Versioning_y) = $GUI_CHECKED Then
			$GUI_Run_Versioning = "y"
		ElseIf GUICtrlRead($H_Run_Versioning_v) = $GUI_CHECKED Then
			$GUI_Run_Versioning = "v"
		Else
			$GUI_Run_Versioning = "n"
		EndIf
		If $INP_Run_Versioning <> $GUI_Run_Versioning Then
			$INP_Run_Versioning = $GUI_Run_Versioning
			$Changes += 1
		EndIf
		$Changes += GUI_GetValue($H_cvs_Parameters, $INP_Versioning_Parameters)
	EndIf
	;
	GUIDelete()
	; Update the source when there where changes.
	If $Changes > 0 Then
		__ConsoleWrite('-> ' & $Changes & ' Change(s) made.' & @CRLF)
		Local $Full_source = @CRLF & FileRead($ScriptFile_In)
		; Add one @CRLF for REGEX testing purpose to be able to test for whole record.
		$Full_source = StringRegExpReplace($Full_source, "(?s)(?i)\r\n(\s*)#Region ;\*\*\*\* Directives created by AutoIt3Wrapper_GUI \*\*\*\*(.*?)\r\n", @CRLF)
		$Full_source = StringRegExpReplace($Full_source, "(?s)(?i)\r\n(\s*)#EndRegion ;\*\*\*\* Directives created by AutoIt3Wrapper_GUI \*\*\*\*(.*?)\r\n", @CRLF)
		Local $directives = ""
		If StringRegExp($Full_source, '(?s)(?i)' & @CRLF & '(\s*)#NoTrayIcon(.*?)' & @CRLF) Then
			$Full_source = StringRegExpReplace($Full_source, '(?s)(?i)' & @CRLF & '#NoTrayIcon(.*?)' & @CRLF, @CRLF)
			$directives &= "#NoTrayIcon" & @CRLF
		EndIf
		;
		If StringRegExp($Full_source, '(?s)(?i)' & @CRLF & '(\s*)#RequireAdmin(.*?)' & @CRLF) Then
			$Full_source = StringRegExpReplace($Full_source, '(?s)(?i)' & @CRLF & '#RequireAdmin(.*?)' & @CRLF, @CRLF)
			$directives &= "#RequireAdmin" & @CRLF
		EndIf
		$directives &= "#Region ;**** Directives created by AutoIt3Wrapper_GUI ****" & @CRLF
		; Aut2Exe Directives
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Prompt", "", "", "") ; Remove this obsolete paremeter
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Version", $INP_AutoIt3_Version, "prod", "p=prod;b=Beta")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Outfile_type", $ScriptFile_Out_Type, "exe", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_aut2exe", "", "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Icon", $INP_Icon, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Outfile", $ScriptFile_Out, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Outfile_x64", $ScriptFile_Out_x64, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Compression", $INP_Compression, "2", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_UseUpx", $INP_UseUpx, "n", "1=y;0=n;4=n")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_UPX_Parameters", $INP_Upx_Parameters, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Compile_Both", $INP_Compile_Both, "n", "1=y;0=n")
		If @OSArch = "X86" Or StringInStr(RegRead("HKCR\AutoIt3Script\Shell\Run\Command", ""), "AutoIt3.exe") Then
			Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_UseX64", $INP_UseX64, "n", "1=y;0=n;4=n")
		Else
			Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_UseX64", $INP_UseX64, "y", "1=y;0=n;4=n")
		EndIf
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Change2CUI", $INP_Change2CUI, "n", "1=y;0=n;4=n")
		; Resource Directives
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Comment", $INP_Comment, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Description", $INP_Description, "", "")
		If $INP_Fileversion_AutoIncrement <> "n" And $INP_Fileversion = "" Then $INP_Fileversion = "0.0.0.0"
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Fileversion", $INP_Fileversion, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Fileversion_AutoIncrement", $INP_Fileversion_AutoIncrement, "n", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Fileversion_First_Increment", $INP_Fileversion_First_Increment, "n", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_ProductName", $INP_ProductName, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_ProductVersion", $INP_ProductVersion, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_CompanyName", $INP_CompanyName, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_LegalCopyright", $INP_LegalCopyright, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_LegalTradeMarks", $INP_LegalTradeMarks, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_SaveSource", $INP_Res_SaveSource, "n", "1=y;0=n;4=n")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Language", $INP_Res_Language, "2057", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_requestedExecutionLevel", $INP_Res_requestedExecutionLevel, "default", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Compatibility", $INP_Res_Compatibility, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_HiDpi", $INP_RES_HiDpi, "n", "1=y;2:p;0=n;4=n")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Field1Name", "", "", "") ; Remove this obsolete paremeter
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Field2Name", "", "", "") ; Remove this obsolete paremeter
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Field1Value", "", "", "") ; Remove this obsolete paremeter
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Field2Value", "", "", "") ; Remove this obsolete paremeter
		$tempvalues = StringSplit($INP_FieldNameEdit, @CRLF)
		For $U = 1 To $tempvalues[0]
			$tempval = StringReplace($tempvalues[$U], "=", "|", 1)
			$tempval = StringReplace($tempval, " | ", "|", 1)
			If $tempval <> "|" Then Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Field", $tempval, "", "")
		Next
		$tempvalues = StringSplit($INP_Icons_txt, @CRLF)
		Local $y = 0
		ReDim $INP_Icons[$tempvalues[0] + 1]
		For $x = 1 To $tempvalues[0]
			$tempval = $tempvalues[$x]
			If $tempval <> "" Then
				$y += 1
				Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_Icon_Add", $tempval, "", "")
				$INP_Icons[$y] = $tempval
			EndIf
		Next
		ReDim $INP_Icons[$y + 1]
		;
		$y = 0
		$tempvalues = StringSplit($Inp_Res_Files_txt, @CRLF)
		ReDim $INP_Res_Files[$tempvalues[0] + 1]
		For $x = 1 To $tempvalues[0]
			$tempval = $tempvalues[$x]
			If $tempval <> "" Then
				$y += 1
				Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Res_File_Add", $tempval, "", "")
				$INP_Res_Files[$y] = $tempval
			EndIf
		Next
		ReDim $INP_Res_Files[$y + 1]
		; Au3Check directives
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Run_AU3Check", $INP_Run_AU3Check, "y", "1=y;0=n;4=n")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Add_Constants", $INP_Add_Constants, "n", "1=y;0=n;4=n")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_AU3Check_Stop_OnWarning", $INP_AU3Check_Stop_OnWarning, "n", "1=y;0=n;4=n")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_AU3Check_Parameters", $INP_AU3Check_Parameters, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Run_Stop_OnError", $INP_Run_Stop_OnError, "n", "1=y;0=n;4=n")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Run_Before", "", "", "")
		; Run Before/After Directives
		$INP_Run_Before = StringSplit($txt_INP_Run_Before, @CRLF, 1)
		For $U = 1 To $INP_Run_Before[0]
			Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Run_Before", $INP_Run_Before[$U], "", "")
		Next
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Run_After", "", "", "")
		$INP_Run_After = StringSplit($txt_INP_Run_After, @CRLF, 1)
		For $U = 1 To $INP_Run_After[0]
			Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Run_After", $INP_Run_After[$U], "", "")
		Next
		; Tidy Directives
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Run_Tidy", $INP_Run_Tidy, "n", "1=y;0=n;4=n")
		Update_Directive($Full_source, $directives, "#Tidy_Parameters", $INP_Tidy_Parameters, "", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Tidy_Stop_OnError", $INP_Tidy_Stop_OnError, "y", "1=y;0=n;4=n")
		; Au3Stripper Directives
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Run_Au3Stripper", $INP_Run_Au3Stripper, "n", "1=y;0=n;4=n")
		Update_Directive($Full_source, $directives, "#Au3Stripper_Parameters", $INP_Au3Stripper_Parameters, "", "")
		; VersionWrapper Directives
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Versioning", $INP_Run_Versioning, "n", "")
		Update_Directive($Full_source, $directives, "#AutoIt3Wrapper_Versioning_Parameters", $INP_Versioning_Parameters, "", "")
		;
		Local $test = "#Region ;**** Directives created by AutoIt3Wrapper_GUI ****" & @CRLF
		If StringRight($directives, StringLen($test)) = $test Then
			$directives = StringTrimRight($directives, StringLen($test))
		Else
			$directives &= "#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****" & @CRLF
		EndIf
		;
		FileRecycle($ScriptFile_In)
		Local $Fh = FileOpen($ScriptFile_In, 2 + $SrceUnicodeFlag)
		FileWrite($Fh, $directives)
		; remove the added @CRLF
		FileWrite($Fh, StringMid($Full_source, 3))
		FileClose($Fh)
	Else
		__ConsoleWrite('-> No changes made..' & @CRLF)
	EndIf
	#forceref $H_Res_L01, $H_Res_L02, $H_Res_L03, $H_Res_L04, $H_Res_L05, $H_Res_L06, $H_Res_L07, $H_Res_L08, $H_Res_L09, $H_Res_L10, $H_Res_L11, $H_Res_L12, $H_Res_L13
	#forceref $Changes
	#forceref $tab0, $tab1, $tab1b, $tab2, $tab3, $tab4, $tab5, $tab6, $H_Run_Versioning_n, $H_Run_Versioning_y, $H_Run_Versioning_v
	If $Save_Only Then Exit
	;
EndFunc   ;==>GUI_Show
;
Func Set_Res_state($G_state)
	GUICtrlSetState($H_Resource, $G_state)
	GUICtrlSetState($H_Comment, $G_state)
	GUICtrlSetState($H_Description, $G_state)
	GUICtrlSetState($H_Fileversion, $G_state)
	GUICtrlSetState($H_Fileversion_AutoIncrement_n, $G_state)
	GUICtrlSetState($H_Fileversion_AutoIncrement_p, $G_state)
	GUICtrlSetState($H_Fileversion_AutoIncrement_y, $G_state)
	GUICtrlSetState($H_ProductName, $G_state)
	GUICtrlSetState($H_ProductVersion, $G_state)
	GUICtrlSetState($H_CompanyName, $G_state)
	GUICtrlSetState($H_LegalCopyright, $G_state)
	GUICtrlSetState($H_LegalTradeMarks, $G_state)
	GUICtrlSetState($H_FieldNameEdit, $G_state)
	GUICtrlSetState($H_Res_Language, $G_state)
EndFunc   ;==>Set_Res_state
;
Func Update_Directive(ByRef $source, ByRef $directives, $directive, $Directive_Value, $Def_Value, $translate)
	; Remove directives from source
	Do
		$source = StringRegExpReplace($source, '(?s)(?i)' & @CRLF & "(\s*)" & $directive & '(.*?)' & @CRLF, @CRLF)
	Until Not @extended
	Local $tarray = StringSplit($translate, ";")
	Local $varray
	For $x = 1 To $tarray[0]
		$varray = StringSplit($tarray[$x], "=")
		If $varray[0] > 1 And $varray[1] = $Directive_Value Then $Directive_Value = $varray[2]
	Next
	If $Directive_Value = "" Or $Directive_Value = $Def_Value Then Return
	$directives &= $directive & "=" & $Directive_Value & @CRLF
EndFunc   ;==>Update_Directive
#EndRegion GUI Functions
#Region MailSLot
; part of MailSlot.au3
;.......script written by trancexx (trancexx at yahoo dot com)

; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotCheckForNextMessage
; Description ...: Checks for presence of a new message.
; Syntax.........: _MailSlotCheckForNextMessage ($hMailSlot)
; Parameters ....: $hMailSlot - Mailslot handle
; Return values .: Success - Returns 0 if there is no message or the size of a new message in bytes if there is one
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - GetMailslotInfo function or call to it failed.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa365435(VS.85).aspx
;
;==========================================================================================
Func _MailSlotCheckForNextMessage($hMailSlot)

	Local $aCall = DllCall("kernel32.dll", "int", "GetMailslotInfo", _
			"ptr", $hMailSlot, _
			"dword*", 0, _
			"dword*", 0, _
			"dword*", 0, _
			"dword*", 0)

	If @error Or Not $aCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	If $aCall[3] = -1 Or Not $aCall[4] Then
		Return 0
	Else
		Return $aCall[3]
	EndIf

EndFunc   ;==>_MailSlotCheckForNextMessage

; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotClose
; Description ...: Closes mailslot.
; Syntax.........: _MailSlotClose ($hMailSlot)
; Parameters ....: $hMailSlot - Mailslot handle
; Return values .: Success - Returns 1
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - CloseHandle function or call to it failed.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/ms724211(VS.85).aspx
;
;==========================================================================================
Func _MailSlotClose($hMailSlot)

	Local $aCall = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hMailSlot)

	If @error Or Not $aCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return 1

EndFunc   ;==>_MailSlotClose

; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotCreate
; Description ...: Creates a mailslot with the specified name.
; Syntax.........: _MailSlotCreate ($sMailSlotName [,$iSize [, $iTimeOut [, $pSecurityAttributes])
; Parameters ....: $sMailSlotName - The name of the mailslot
;                  $iSize - The maximum size of a single message that can be written to the mailslot, in bytes. 0 means any size.
;                  $iTimeOut - The time a read operation can wait for a message to be written to the mailslot before a time-out occurs, in milliseconds.
;                              Can be 0 - returns immediately if no message is present
;                                     -1 (minus one) - waits forever for a message
;                  $pSecurityAttributes - A pointer to a SECURITY_ATTRIBUTES structure. 0 means the handle cannot be inherited.
; Return values .: Success - Returns a handle that a mailslot server can use to perform operations on the mailslot
;                          - Sets @error to 0
;                  Failure - Returns -1 and sets @error:
;                  |1 - CreateMailslotW function or call to it failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......: Mailslot name must have the following form and must be unique: \\.\mailslot\[path]name
;                  The name may include multiple levels of pseudo directories separated by backslashes.
;                  For example \\.\mailslot\abc\def\ghi is valid name too.
; Link ..........; http://msdn.microsoft.com/en-us/library/aa365147(VS.85).aspx
;
;==========================================================================================
Func _MailSlotCreate($sMailSlotName, $iSize = 0, $iTimeOut = 0, $pSecurityAttributes = 0)

	Local $aCall = DllCall("kernel32.dll", "ptr", "CreateMailslotW", _
			"wstr", $sMailSlotName, _
			"dword", $iSize, _
			"dword", $iTimeOut, _
			"ptr", $pSecurityAttributes)

	If @error Or $aCall[0] = -1 Then
		Return SetError(1, 0, -1)
	EndIf

	Return $aCall[0]

EndFunc   ;==>_MailSlotCreate

; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotRead
; Description ...: Reads messages from the specified mailslot.
; Syntax.........: _MailSlotRead ($hMailSlot , $iSize [, $iMode])
; Parameters ....: $hMailSlot - Mailslot handle
;                  $iSize - The number of bytes to read.
;                  $iMode - Reading mode.
;                             Can be: 0 - read binary
;                                     1 - read ANSI
;                                     2 - read UTF8
; Return values .: Success - Returns read data
;                          - Sets @extended to number of read bytes
;                          - Sets @error to 0
;                  Special: Sets @error to -1 if specified buffer to read to is too small.
;                  Failure - Returns empty string and sets @error:
;                  |1 - DllCall() to ReadFile failed.
;                  |2 - GetLastError function or call to it failed.
;                  |3 - ReadFile function failed. @extended will be set to the return value of the GetLastError function.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa365467(VS.85).aspx
;                  http://msdn.microsoft.com/en-us/library/ms679360(VS.85).aspx
;
;==========================================================================================
Func _MailSlotRead($hMailSlot, $iSize, $iMode = 0)

	Local $tDataBuffer = DllStructCreate("byte[" & $iSize & "]")

	Local $aCall = DllCall("kernel32.dll", "int", "ReadFile", _
			"ptr", $hMailSlot, _
			"ptr", DllStructGetPtr($tDataBuffer), _
			"dword", $iSize, _
			"dword*", 0, _
			"ptr", 0)

	If @error Then
		Return SetError(1, 0, "")
	EndIf

	If Not $aCall[0] Then
		Local $aLastErrorCall = DllCall("kernel32.dll", "int", "GetLastError")
		If @error Then
			Return SetError(2, 0, "")
		EndIf
		If $aLastErrorCall[0] = 122 Then                             ; ERROR_INSUFFICIENT_BUFFER
			Return SetError(-1, 0, "")
		Else
			Return SetError(3, $aLastErrorCall[0], "")
		EndIf
	EndIf

	Local $vOut

	Switch $iMode
		Case 1
			$vOut = BinaryToString(DllStructGetData($tDataBuffer, 1))
		Case 2
			$vOut = BinaryToString(DllStructGetData($tDataBuffer, 1), 4)
		Case Else
			$vOut = DllStructGetData($tDataBuffer, 1)
	EndSwitch

	Return SetError(0, $aCall[4], $vOut)

EndFunc   ;==>_MailSlotRead

; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotWrite
; Description ...: Writes message to the specified mailslot.
; Syntax.........: _MailSlotWrite ($sMailSlotName , $vData [, $iMode])
; Parameters ....: $hMailSlot - Mailslot name
;                  $vData - Data to write.
;                  $iMode - Writing mode.
;                             Can be: 0 - write binary
;                                     1 - write ANSI
;                                     2 - write UTF8
; Return values .: Success - Returns the number of written bytes
;                          - Sets @error to 0
;                  Failure - Returns empty string and sets @error:
;                  |1 - CreateFileW function or call to it failed.
;                  |2 - WriteFile function or call to it failed.
;                  |3 - Opened mail slot handle could not be closed.
;                  |4 - WriteFile function or call to it failed and additionally opened mail slot handle could not be closed.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa363858(VS.85).aspx
;                  http://msdn.microsoft.com/en-us/library/aa365747(VS.85).aspx
;                  http://msdn.microsoft.com/en-us/library/ms724211(VS.85).aspx
;
;==========================================================================================
Func _MailSlotWrite($sMailSlotName, $vData, $iMode = 0)

	Local $aCall = DllCall("kernel32.dll", "ptr", "CreateFileW", _
			"wstr", $sMailSlotName, _
			"dword", 0x40000000, _                                   ; GENERIC_WRITE
			"dword", 1, _                                            ; FILE_SHARE_READ
			"ptr", 0, _
			"dword", 3, _                                            ; OPEN_EXISTING
			"dword", 0, _                                            ; SECURITY_ANONYMOUS
			"ptr", 0)

	If @error Or $aCall[0] = -1 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hMailSlotHandle = $aCall[0]

	Local $bData

	Switch $iMode
		Case 1
			$bData = StringToBinary($vData, 1)
		Case 2
			$bData = StringToBinary($vData, 4)
		Case Else
			$bData = $vData
	EndSwitch

	Local $iBufferSize = BinaryLen($bData)

	Local $tDataBuffer = DllStructCreate("byte[" & $iBufferSize & "]")
	DllStructSetData($tDataBuffer, 1, $bData)

	$aCall = DllCall("kernel32.dll", "int", "WriteFile", _
			"ptr", $hMailSlotHandle, _
			"ptr", DllStructGetPtr($tDataBuffer), _
			"dword", $iBufferSize, _
			"dword*", 0, _
			"ptr", 0)

	If @error Or Not $aCall[0] Then
		$aCall = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hMailSlotHandle)
		If @error Or Not $aCall[0] Then
			Return SetError(4, 0, 0)
		EndIf
		Return SetError(2, 0, 0)
	EndIf

	Local $iOut = $aCall[4]

	$aCall = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hMailSlotHandle)
	If @error Or Not $aCall[0] Then
		Return SetError(3, 0, $iOut)
	EndIf

	Return $iOut

EndFunc   ;==>_MailSlotWrite
;
; Check whether the process needs to be interrupted wi=hen running RequireAdmin
Func CheckInterrupt()
	If Not FileExists($RunAdminChkFile) Then
		__ConsoleWrite("! Kill request received from mainscript .. ending run of #RequireAdmin script." & @CRLF)
		_MailSlotWrite($sMailSlotConsole, "#$#Killed#$#")            ;Tell Master script the eleveated run is ended
		Exit 999
	EndIf
EndFunc   ;==>CheckInterrupt
#EndRegion MailSLot
#Region Versioning functions
#Region MainFunc Versioning
Func Versioning($SourceFile, $INP_Versioning_Parameters)
	;========================================================================================================================
	;Version program information
	;========================================================================================================================
	Local $Versioning = IniRead($AutoIt3WapperIni, "Versioning", "Versioning", "")
	; Check if Versioning was initialized
	If $Versioning = "" Then
		$Versioning = "SVN"
		If MsgBox(262144 + 4096 + 4, "AutoIt3Wrappper", "Versioning program information is not found yet." & @LF & _
				"Do you want to initialize the versioning setting based on using TortoiseSVN ?" & @CRLF & "You will get an UAC prompt in case this is needed.", 10) = 6 Then
			VersioningINIinit("SVN")
		EndIf
	EndIf
	;
	Local $VersionPGM = IniRead($AutoIt3WapperIni, $Versioning, "VersionPGM", "")
	Local $PromptVersionComments = "y"
	Local $VersionCommentsText = ""
	; Propmpt for version program and save in INI file
	If Not FileExists($VersionPGM) Then
		Debug("Your versioning program isn't found:" & $VersionPGM & ". Skipping task.  AutoIt3.INI:" & $AutoIt3WapperIni, 1, "!")
		Return
	EndIf
	If $PromptVersionComments = "" Then $PromptVersionComments = IniRead($AutoIt3WapperIni, "Versioning", "Prompt_Comments", "")
	If $PromptVersionComments = "" Then
		$PromptVersionComments = "y"
		IniWrite($AutoIt3WapperIni, "Versioning", "Prompt_Comments", "y")
	EndIf
	;
	FileDelete($UserData & "\AutoIt3Wrapper.log")
	Debug("==> Version program Info:")
	Debug("  Version program used  :" & $VersionPGM)
	Debug("  PromptVersionComments :" & $PromptVersionComments)
	Debug("  Parameters :" & $INP_Versioning_Parameters)
	;========================================================================================================================
	;Perform requested Version command
	;========================================================================================================================
	;Determine if source has its own version Versioning setup.
	If Not _Check_Source_versioned($SourceFile, $Versioning) Then
		Debug("Your sourcefile Directory has no " & $Versioning & " versioning setup.", 1, "!")
		Return
	EndIf
	;
	Local $vParams = StringSplit($INP_Versioning_Parameters, " ")
	Local $aTemp
	For $x = 1 To $vParams[0]
		Select
			Case $vParams[$x] = "/ShowDiff"
				Return _ShowDiff_Source($SourceFile, $Versioning)
			Case $vParams[$x] = "/NoPrompt"
				$PromptVersionComments = "n"
			Case $vParams[$x] = "/comments"
				$aTemp = StringRegExp($INP_Versioning_Parameters & @CR, '(?i)/comments\s(.*?)(\r|/noprompt|/showdiff)', 3)
				$VersionCommentsText = $aTemp[0]
				If StringLeft($VersionCommentsText, 1) = '"' Then $VersionCommentsText = StringTrimLeft($VersionCommentsText, 1)
				If StringRight($VersionCommentsText, 1) = '"' Then $VersionCommentsText = StringTrimRight($VersionCommentsText, 1)
		EndSelect
	Next
	; Commit the source
	Return _Commit_Source($SourceFile, $Versioning, $VersionCommentsText, $PromptVersionComments)
	; end of versioning func
EndFunc   ;==>Versioning
#EndRegion MainFunc Versioning
#Region Versioning Program Functions
Func _Check_Source_versioned($SourceFilename, $Versioning)
	;========================================================================================================================
	;Version program information
	;========================================================================================================================
	Debug("=========================================")
	Debug("==> Check if Directory has versioning.")
	Local $CommandChkVersioning = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandChkVersioning", ""), $SourceFilename)
	Local $CommandChkVersioning_ok_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandChkVersioning_ok_txt", ""), $SourceFilename, True, True)
	Local $CommandChkVersioning_ok_rc = IniRead($AutoIt3WapperIni, $Versioning, "CommandChkVersioning_ok_rc", "")
	Local $STD_Output_versionProgram
	Local $rc = _RunVersionPgm($CommandChkVersioning, $STD_Output_versionProgram, 0)
	Return CheckSTDOUTFor($STD_Output_versionProgram, $CommandChkVersioning_ok_txt, $rc, $CommandChkVersioning_ok_rc)
EndFunc   ;==>_Check_Source_versioned
;
;  Commit the source to the version repository
Func _Commit_Source($SourceFilename, $Versioning, $VersionCommentsText, $PromptVersionComments)
	Debug("=========================================")
	Debug("==> Commit Source process.")
	; Check if the original source has a SVN applied ... when not then copy the file
	; Check if source was updated
	Local $CommandStatusSource = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandStatusSource", ""), $SourceFilename)
	Local $CommandStatusSource_ADD_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandStatusSource_ADD_txt", ""), $SourceFilename, True, True)
	Local $CommandStatusSource_OK_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandStatusSource_ok_txt", ""), $SourceFilename, True, True)
	Local $STD_Output_versionProgram
	Local $aResult
	; Check if sourcefile is already added to versioning
	Debug("--> Check if sourcefile version status in repository.")
	Local $rc = _RunVersionPgm($CommandStatusSource, $STD_Output_versionProgram)
	Debug("Run Output:" & @CRLF & $STD_Output_versionProgram)
	;Save info for later processing
	Local $Status_Output = $STD_Output_versionProgram
	;Check If commit is needed
	Debug("--> Check if sourcefile was changed.")

	If Not CheckSTDOUTFor($STD_Output_versionProgram, $CommandStatusSource_OK_txt) Then
		__ConsoleWrite("+ Your version is the same as the " & $Versioning & " version, nothing to update." & @LF)
		Exit
	EndIf
	; Get the commit comments with the option to cancel the commit
	If $PromptVersionComments = "y" Then
		Debug("--> Retrieve old Version comments ")
		; retrieve previous commit description text
		Local $CommandLogSource = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandLogSource", ""), $SourceFilename)
		Local $CommandLogSourceLine = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandLogSourceLine", ""), $SourceFilename)
		If $CommandLogSourceLine = "" And $Versioning = "SVN" Then $CommandLogSourceLine = "(?m)\v+[^\|]*?\|[^\|]*?\|[^\|]*?\|.*\v+(.*?)$"
		If $CommandLogSourceLine = "" And $Versioning = "GIT" Then $CommandLogSourceLine = "(?m)commit.*\vAuthor.*\vDate.*\v.*\v+\s*(.*?)\v.*\v"
		If $CommandLogSource <> "" Then
			_RunVersionPgm($CommandLogSource, $STD_Output_versionProgram, 0)
			Debug("Run Output:" & @CRLF & $STD_Output_versionProgram)
			$aResult = StringRegExp($STD_Output_versionProgram, $CommandLogSourceLine, 3)
			Local $Prev_Msgs = ""
			For $x = 0 To UBound($aResult) - 1
				If $x > 0 Then $Prev_Msgs &= "|"
				$Prev_Msgs &= "-" & $x & ">:" & $aResult[$x]
			Next
		EndIf
		Debug("--> GUI Prompt Version comments  ")
		$VersionCommentsText = CommitDescription($VersionCommentsText, $Prev_Msgs)
		If $VersionCommentsText == "-1" Then
			Debug("Version update cancelled.", 1, "!")
			Return
		EndIf
	EndIf
	;
	; Check if sourcefile is already added to versioning else ADD it.
	Debug("--> Check if sourcefile already has versioning.")
	If CheckSTDOUTFor($Status_Output, $CommandStatusSource_ADD_txt) Then
		Local $CommandAddSource = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandAddSource", ""), $SourceFilename, True)
		Local $CommandAddSource_ok_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandAddSource_ok_txt", ""), $SourceFilename, True, True)
		Local $CommandAddSource_ok_rc = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandAddSource_ok_rc", ""), $SourceFilename, True, True)
		Debug("### Add source to repository.")
		$rc = _RunVersionPgm($CommandAddSource, $STD_Output_versionProgram)
		If CheckSTDOUTFor($STD_Output_versionProgram, $CommandAddSource_ok_txt, $rc, $CommandAddSource_ok_rc) Then
			Debug("Source Added succesfully to the repository.", 1, "")
		Else
			Debug("Source Add Failed." & @CRLF & $STD_Output_versionProgram, 1, "!")
		EndIf
	EndIf
	;Check If commit is needed
	Local $CommandCommitSource = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandCommitSource", ""), $SourceFilename, True)
	$CommandCommitSource = StringReplace($CommandCommitSource, "%commitcomment%", $VersionCommentsText)
	Local $CommandCommitSource_ok_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandCommitSource_ok_txt", ""), $SourceFilename, True, True)
	Local $CommandCommitSource_ok_rc = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandCommitSource_ok_rc", ""), $SourceFilename, True, True)
	Debug("### Commit source to repository.")
	$rc = _RunVersionPgm($CommandCommitSource, $STD_Output_versionProgram)
	If CheckSTDOUTFor($STD_Output_versionProgram, $CommandCommitSource_ok_txt, $rc, $CommandCommitSource_ok_rc) Then
		; get revision
		Local $CommandCommitSource_new_revision = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandCommitSource_new_revision", ""), $SourceFilename)
		$aResult = StringRegExp($STD_Output_versionProgram, $CommandCommitSource_new_revision, 3)
		ReDim $aResult[1]                                            ; ensure the array is valid in case the regex isn't found
		If $Versioning <> "GIT" Then
			Debug("Committed your source in the local " & $Versioning & " repository with revision: " & $aResult[0], 1, "-")
		Else
			Debug("Committed your source in the local " & $Versioning & " repository with ref: " & $aResult[0] & ". Now start sync with remote.", 1, "-")
			Local $CommandPullSource = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandPullSource", "pull"), $SourceFilename, True)
			Local $CommandPull_ok_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandPull_ok_txt", ""), $SourceFilename, True, True)
			Local $CommandPullSource_ok_rc = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandPullSource_ok_rc", "0"), $SourceFilename, True, True)
			Debug("### Sync now with remote repository, starting with pull to ensure local repo is up-to-date.")
			$rc = _RunVersionPgm($CommandPullSource, $STD_Output_versionProgram)
			If CheckSTDOUTFor($STD_Output_versionProgram, $CommandPull_ok_txt, $rc, $CommandPullSource_ok_rc) Then
				Debug("Pull repository ok." & @CRLF & $STD_Output_versionProgram, 1, "")
				Local $CommandPushSource = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandPushSource", "push"), $SourceFilename, True)
				Local $CommandPush_ok_txt = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandPush_ok_txt", ""), $SourceFilename, True, True)
				Local $CommandPushSource_ok_rc = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandPushSource_ok_rc", "0"), $SourceFilename, True, True)
				Debug("### Push repository to ensure we are up to date.")
				$rc = _RunVersionPgm($CommandPushSource, $STD_Output_versionProgram)
				If CheckSTDOUTFor($STD_Output_versionProgram, $CommandPush_ok_txt, $rc, $CommandPushSource_ok_rc) Then
					Debug("Push repository ok." & @CRLF & $STD_Output_versionProgram, 1, "")
				Else
					Debug("Push repository Failed." & @CRLF & $STD_Output_versionProgram, 1, "!")
				EndIf
			Else
				Debug("Pull repository Failed." & @CRLF & $STD_Output_versionProgram, 1, "!")
			EndIf
		EndIf
	Else
		Debug("Commit Failed. Check the log for additional errors." & @CRLF & $STD_Output_versionProgram, 1, "!> ")
	EndIf
EndFunc   ;==>_Commit_Source
;
Func _RunVersionPgm($VersionCommand, ByRef $STD_Output_versionProgram, $ShowOutput = 0)
	Local $Versioning = IniRead($AutoIt3WapperIni, "Versioning", "Versioning", "")
	Local $VersionPGM = IniRead($AutoIt3WapperIni, $Versioning, "VersionPGM", "")
;~ 	Local $VersionPGMShortName = FileGetShortName($VersionPGM)
;~ 	Local $VersionDir = IniRead($AutoIt3WapperIni, $Versioning, "SVNDir", @ScriptDir)
	Local $Pid
	Debug("Run Version program:" & $VersionPGM & ' ' & $VersionCommand & @CRLF)
	$Pid = Run('"' & $VersionPGM & '" ' & $VersionCommand & '', "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $Handle = _ProcessExitCode($Pid)
	$STD_Output_versionProgram = ShowStdOutErr($Pid, $ShowOutput, 1)
	Local $ExitCode = _ProcessExitCode($Pid, $Handle)
	_ProcessCloseHandle($Handle)
	Debug("Run ended with rc:" & $ExitCode & @CRLF)
	Return $ExitCode
EndFunc   ;==>_RunVersionPgm
;
Func _ShowDiff_Source($SourceFilename, $Versioning)
	Local $DiffPgm = IniRead($AutoIt3WapperIni, "Versioning", "DiffPGM", "")
	Local $DiffPgmOptions = IniRead($AutoIt3WapperIni, "Versioning", "DiffPGMOptions", "")
	Local $CommandGetLastVersion = ReplaceVarsINIText(IniRead($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion", ""), $SourceFilename, True, True)
	$CommandGetLastVersion = StringReplace($CommandGetLastVersion, "%sourcefile%", $SourceFilename)
	Local $CommandGetLastVersion_ok_txt = IniRead($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion_ok_txt", "")
	Local $CommandGetLastVersion_ok_rc = IniRead($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion_ok_rc", "")
	Local $STD_Output_versionProgram
	;
	If $DiffPgm = "" Or Not FileExists($DiffPgm) Then
		Debug("Your DIFF program isn't found:" & $DiffPgm & ". Skipping task.", 1, "!")
		Return
	EndIf
	; Check if the original source has versioning
	; Use the Scripts Own repository
	; Create a tempfile to retrieve the Version source to
	Local $tmpfile = __TempFile()
	Debug("Retrieving last version from Repository to temp file: " & $tmpfile, 0, "")
	Local $rc = _RunVersionPgm($CommandGetLastVersion, $STD_Output_versionProgram, 0)
	If CheckSTDOUTFor($STD_Output_versionProgram, $CommandGetLastVersion_ok_txt, $rc, $CommandGetLastVersion_ok_rc) Then
		Debug("source retrieved:", 0, "")
	Else
		Debug("Failed to retrieve the source. Likely the file isn't versioned yet. Check the versioning.log for details.", 1, "!")
		Return 0
	EndIf
	; Write source to Tempfile
	__DelTempFile($tmpfile)
	Local $FHs = FileOpen($tmpfile, 514)
	FileWrite($FHs, $STD_Output_versionProgram)
	FileClose($FHs)
	If Not FileExists($tmpfile) Or FileGetSize($tmpfile) = 0 Then
		MsgBox(48 + 262144, "VersionWrapper", "Script is not available in Versioning:" & @LF & $SourceFilename & @LF)
		__DelTempFile($tmpfile)
		Return
	EndIf
	Debug("Running Diff program " & '"' & $DiffPgm & '" ' & $DiffPgmOptions & ' "' & $SourceFilename & '" "' & $tmpfile & '"', 1, ">")
	RunWait('"' & $DiffPgm & '" ' & $DiffPgmOptions & ' "' & $SourceFilename & '" "' & $tmpfile & '"')
	; delete tempfile
	__DelTempFile($tmpfile)
EndFunc   ;==>_ShowDiff_Source
; Show input screen to add a comment to the Commit
Func CommitDescription($VersionCommentsText, $Prev_Descr = "")
	Local $nMsg
	GUICreate("Version Commit Text", 413, 298, 284, 188)
	GUICtrlCreateLabel("Description:", 16, 24, 60, 17)
	Local $Combo1 = GUICtrlCreateCombo("", 50, 5, 326, 169)
	If $Prev_Descr <> "" Then
		GUICtrlSetData(-1, $Prev_Descr, StringLeft($Prev_Descr, StringInStr($Prev_Descr, "|") - 1))
	Else
		GUICtrlSetState(-1, $GUI_HIDE)
	EndIf
	Local $Edit1 = GUICtrlCreateEdit($VersionCommentsText, 25, 40, 351, 169)
	Local $h_Ok = GUICtrlCreateButton("Ok", 72, 224, 81, 33, 0)
	Local $H_CANCEL = GUICtrlCreateButton("Cancel", 224, 224, 97, 33, 0)
	GUISetState(@SW_SHOW)
	While 1
		$nMsg = GUIGetMsg()
		Select
			Case $nMsg = $GUI_EVENT_CLOSE Or $nMsg = $H_CANCEL
				GUIDelete()
				Return -1
			Case $nMsg = $h_Ok
				Local $temp = StringReplace(GUICtrlRead($Edit1), '"', '\"')
				GUIDelete()
				Return $temp
			Case $nMsg = $Combo1
				If GUICtrlRead($Edit1) <> "" Then
					If MsgBox(4, "Confirm override", "Override the Text in the Edit control?") = 7 Then ContinueLoop
				EndIf
				GUICtrlSetData($Edit1, StringReplace(StringTrimLeft(GUICtrlRead($Combo1), StringInStr(GUICtrlRead($Combo1), ":")), "\r\n", @CRLF))
		EndSelect
	WEnd
EndFunc   ;==>CommitDescription
#EndRegion Versioning Program Functions
#Region Versioning Other functions
;Read Console output from shelled script when it suses #requireAdmin
Func _ReadMessage($hHandle)
	Local $iSize = _MailSlotCheckForNextMessage($hHandle)
	If $iSize Then
		Local $sdata = _MailSlotRead($hHandle, $iSize, 1)
		If $sdata = "#$#Killed#$#" Then Return 99                    ; Means elevated process has killed itself
		If StringLeft($sdata, 13) = "#$#Started#$#" Then
			Return StringMid($sdata, 14)                             ; Means elevated process has Started - return PID
		EndIf
		ConsoleWrite($sdata)
	EndIf
EndFunc   ;==>_ReadMessage

;Check returned STDOUT for given text or RC from versioning program as defined in INI
Func CheckSTDOUTFor($Output, $ChkText, $PgmRC = 0, $ChkRc = 999, $ChkRegex = True)
	Local $rc = 0

	Debug("----------------------------------------------------------------------------------")
	Debug("   Version Check STDOUT and RC of version program:")
	Debug("   $ChkText :" & $ChkText)
	Debug("   $PgmRC   :" & $PgmRC)
	Debug("   $ChkRc   :" & $ChkRc)
	If $ChkRc <> "" And $PgmRC = Number($ChkRc) Then
		$rc = 1
		Debug(" Returncode is a match.")
	ElseIf $ChkRegex Then
		If $ChkText <> "" And StringRegExp($Output, $ChkText) Then
			$rc = 1
			Debug(" Regex is a match.")
		EndIf
	Else
		If $ChkText <> "" And StringInStr($Output, $ChkText) Then
			$rc = 1
			Debug(" StringInStr is a match.")
		EndIf
	EndIf
	Debug("   $Output  :" & @CRLF & $Output)
	Debug("--- End STDOUT check ---------------------------------------------------------------")
	Return $rc
EndFunc   ;==>CheckSTDOUTFor
;
Func Debug($Txt, $ShowConsole = 0, $ConsolePref = "")
	Local $Debug = Number(IniRead($AutoIt3WapperIni, "Versioning", "Debug", "1"))
	If $Debug Then _FileWriteLog($UserData & "\AutoIt3Wrapper.log", $Txt)
	If $ShowConsole Then Write_RC_Console_Msg($Txt, "", $ConsolePref)
EndFunc   ;==>Debug
;
Func ReplaceVarsINIText($CmdText, $InSourceFilename, $Double_BackSlash = True, $IsRegex = False)
	Local $SourceDrive, $SourceDir, $SourceFilename, $SourceFileExt
	_PathSplit($InSourceFilename, $SourceDrive, $SourceDir, $SourceFilename, $SourceFileExt)
	$SourceDir = $SourceDrive & StringTrimRight($SourceDir, 1)
	If $Double_BackSlash Then
		$InSourceFilename = StringReplace($InSourceFilename, "\", "\\")
		$SourceDir = StringReplace($SourceDir, "\", "\\")
	EndIf
	If $IsRegex Then
		$InSourceFilename = StringReplace($InSourceFilename, "(", "\(")
		$InSourceFilename = StringReplace($InSourceFilename, ")", "\)")
	EndIf
	$CmdText = StringReplace($CmdText, "%sourcefile%", $InSourceFilename)
	$CmdText = StringReplace($CmdText, "%sourcefileonly%", $SourceFilename & $SourceFileExt)
	$CmdText = StringReplace($CmdText, "%sourcedir%", $SourceDir)
	Return $CmdText
EndFunc   ;==>ReplaceVarsINIText
;
Func RestartReqAdmin()
	Local $temp_Script = _TempFile($TempDir, "~", ".au3")
	$RunAdminChkFile = _TempFile($TempDir, "~", ".chk")              ; This is Global as it is used in other funcs
;~ 	Local $runline = "RunWait('""" & $AutoIt3_PGM & '" ' & StringReplace($cmdlineraw, " /run ", ' /RunAdmin "' & $RunAdminChkFile & '" ') & ' '', "", ' & @SW_HIDE & ',' & $STDERR_CHILD + $STDOUT_CHILD & ')'
	Local $runline = "RunWait('""" & @AutoItExe & '" ' & StringReplace($cmdlineraw, " /run ", ' /RunAdmin "' & $RunAdminChkFile & '" ') & ' '', "' & @WorkingDir & '")'
	FileWriteLine($RunAdminChkFile, 'TempFile')
	FileWriteLine($temp_Script, '#NoTrayIcon')
	FileWriteLine($temp_Script, '#RequireAdmin')
	FileWriteLine($temp_Script, '#AutoIt3Wrapper_AutoIt3="' & $AutoIt3_PGM & '"')
	FileWriteLine($temp_Script, $runline)
	FileWriteLine($temp_Script, "FileDelete('" & $RunAdminChkFile & "')")
	If _MailSlotClose($hMailSlot_Console) Then $hMailSlot_Console = 0
	$hMailSlot_Console = _MailSlotCreate($sMailSlotConsole)
	__ConsoleWrite("->" & @HOUR & ":" & @MIN & ":" & @SEC & " Script requires Admin rights while SciTE is at normal level -> Starting new AutoIt3Wrapper with #RequireAdmin to run the script." & @CRLF)
	Local $TmpPid = Run('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $temp_Script & '"')
	; Check for the script to start
;~ 	__ConsoleWrite("+->" & @HOUR & ":" & @MIN & ":" & @SEC & " Waiting for Script to start....")
	Local $NewPid = 0
	; wait for the tempscript to shell AutoIt3Wrapper to finish and check the MailSlot for its successfull startup
	ProcessWaitClose($TmpPid)
	For $x = 1 To 100
		$NewPid = _ReadMessage($hMailSlot_Console)
		If $NewPid > 0 Then ExitLoop
		Sleep(10)
	Next
	; Warn when process didn''t start. Could be when No is answered in the UAC prompt
	If $NewPid = 0 Then
		__ConsoleWrite("!>" & @HOUR & ":" & @MIN & ":" & @SEC & " Script Failed to start." & @CRLF)
	Else
		__ConsoleWrite("+>" & @HOUR & ":" & @MIN & ":" & @SEC & " Script started, waiting for output. (pid=" & $NewPid & ')' & @CRLF)
		; Wait for the script to finish and read the Mailslot for output from the Shelled script
		While FileExists($RunAdminChkFile)
			_ReadMessage($hMailSlot_Console)
			Sleep(10)
		WEnd
	EndIf
	FileDelete($temp_Script & "*.*")
	If _MailSlotClose($hMailSlot_Console) Then $hMailSlot_Console = 0
EndFunc   ;==>RestartReqAdmin
; Check whether AutoIt3Wrapper is shelled by SciTE
Func RunBySciTE()
	If Not ($RunBySciTE = "Unknown") Then Return $RunBySciTE
	$RunBySciTE = False
	;Check Multiple levels of parents
	Local $pl1 = _WinAPI_GetParentProcess(@AutoItPID)
	Local $pl2 = _WinAPI_GetParentProcess($pl1)
	Local $pl3 = _WinAPI_GetParentProcess($pl2)
	Local $pl4 = _WinAPI_GetParentProcess($pl3)
	If _ProcessGetName($pl1) <> "AutoIt3.exe" Then
		$RunByFull = _WinAPI_GetProcessFileName($pl1)
		$RunBy = _ProcessGetName($pl1)
	ElseIf _ProcessGetName($pl2) <> "AutoIt3.exe" Then
		$RunByFull = _WinAPI_GetProcessFileName($pl2)
		$RunBy = _ProcessGetName($pl2)
	ElseIf _ProcessGetName($pl3) <> "AutoIt3.exe" Then
		$RunByFull = _WinAPI_GetProcessFileName($pl3)
		$RunBy = _ProcessGetName($pl3)
	ElseIf _ProcessGetName($pl4) <> "AutoIt3.exe" Then
		$RunByFull = _WinAPI_GetProcessFileName($pl4)
		$RunBy = _ProcessGetName($pl4)
	EndIf
	If $RunBy = "SciTE.exe" Then $RunBySciTE = True
	; return
	Return $RunBySciTE
EndFunc   ;==>RunBySciTE

;
Func RunReqAdmin($Autoit3Commands, $prompt = 0)
	Local $temp_Script = _TempFile($TempDir, "~", ".au3")
	Local $temp_check = _TempFile($TempDir, "~", ".chk")
	FileWriteLine($temp_check, 'TempFile')
	FileWriteLine($temp_Script, '#NoTrayIcon')
	If Not IsAdmin() Then
		FileWriteLine($temp_Script, '#RequireAdmin')
		If $prompt = 1 Then MsgBox(262144, "Need Admin mode", "Admin mode is needed for this update. Answer the following prompts to allow the update.")
	EndIf
	FileWriteLine($temp_Script, $Autoit3Commands)
	FileWriteLine($temp_Script, "FileDelete('" & $temp_check & "')")
	RunWait('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $temp_Script & '"')
	; Wait for the script to finish
	While FileExists($temp_check)
		Sleep(50)
	WEnd
	FileDelete($temp_Script & "*.*")
EndFunc   ;==>RunReqAdmin
;
Func RunReqAdminDosCommand($Autoit3Commands, $prompt = 0, $outfile = "")
	Local $temp_Script = _TempFile($TempDir, "~", ".au3")
	FileDelete($outfile)
	FileWriteLine($outfile, '! Cancelled execution.')
	FileWriteLine($temp_Script, '#NoTrayIcon')
	If Not IsAdmin() Then
		FileWriteLine($temp_Script, '#RequireAdmin')
		If $prompt = 1 Then MsgBox(262144, "Need Admin mode", "Admin mode is needed for this update. Answer the following prompts to allow the update.")
	EndIf

	__ConsoleWrite(">Running AdminLevel:" & $Autoit3Commands & @CRLF)
	FileWriteLine($temp_Script, "AutoItWinSetTitle ('AutoIt3Wrapper_RunningCommand')")
	FileWriteLine($temp_Script, "$Pid = Run('" & @ComSpec & ' /C ' & $Autoit3Commands & "', ''," & @SW_HIDE & ", 2)")
	FileWriteLine($temp_Script, 'FileDelete("' & $outfile & '")')
	FileWriteLine($temp_Script, "$Handle = _ProcessExitCode($Pid)")
	FileWriteLine($temp_Script, "ShowStdOutErr($Pid, 1)")
	FileWriteLine($temp_Script, "$ExitCode = _ProcessExitCode($Pid, $Handle)")
	FileWriteLine($temp_Script, "_ProcessCloseHandle($Handle)")
	FileWriteLine($temp_Script, "Exit $ExitCode")
	FileWriteLine($temp_Script, "Func _ProcessCloseHandle($h_Process)")
	FileWriteLine($temp_Script, "	; Close the process handle of a PID")
	FileWriteLine($temp_Script, "	DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $h_Process)")
	FileWriteLine($temp_Script, "	If Not @error Then Return 1")
	FileWriteLine($temp_Script, "	Return 0")
	FileWriteLine($temp_Script, "EndFunc   ;==>_ProcessCloseHandle")
	FileWriteLine($temp_Script, "Func _ProcessExitCode($i_Pid, $h_Process = 0)")
	FileWriteLine($temp_Script, "	; 0 = Return Process Handle of PID else use Handle to Return Exitcode of a PID")
	FileWriteLine($temp_Script, "	Local $v_Placeholder")
	FileWriteLine($temp_Script, "	If Not IsArray($h_Process) Then")
	FileWriteLine($temp_Script, "		; Return the process handle of a PID")
	FileWriteLine($temp_Script, "		$h_Process = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'int', 0x400, 'int', 0, 'int', $i_Pid)")
	FileWriteLine($temp_Script, "		If Not @error Then Return $h_Process")
	FileWriteLine($temp_Script, "	Else")
	FileWriteLine($temp_Script, "		; Return Process Exitcode of PID")
	FileWriteLine($temp_Script, "		$h_Process = DllCall('kernel32.dll', 'ptr', 'GetExitCodeProcess', 'ptr', $h_Process[0], 'int*', $v_Placeholder)")
	FileWriteLine($temp_Script, "		If Not @error Then Return $h_Process[2]")
	FileWriteLine($temp_Script, "	EndIf")
	FileWriteLine($temp_Script, "	Return 0")
	FileWriteLine($temp_Script, "EndFunc   ;==>_ProcessExitCode")
	FileWriteLine($temp_Script, "Func ShowStdOutErr($l_Handle, $ShowConsole = 1, $Replace = '', $ReplaceWith = '')")
	FileWriteLine($temp_Script, "	Local $Line = 'x', $Line2 = 'x', $err1 = 0, $err2 = 0, $cnt1 = 0, $cnt2 = 0")
	FileWriteLine($temp_Script, "	Do")
	FileWriteLine($temp_Script, "		Sleep(10)")
	FileWriteLine($temp_Script, "		$Line = StdoutRead($l_Handle)")
	FileWriteLine($temp_Script, "		$err1 = @error")
	FileWriteLine($temp_Script, "		If $Replace <> '' Then $Line = StringReplace($Line, $Replace, $ReplaceWith)")
	If $outfile <> "" Then
		FileWriteLine($temp_Script, 'FileWrite("' & $outfile & '",$Line)')
	EndIf
	FileWriteLine($temp_Script, "		If $ShowConsole Then ConsoleWrite($Line)")
	FileWriteLine($temp_Script, "		$Line2 = StderrRead($l_Handle)")
	FileWriteLine($temp_Script, "		$err2 = @error")
	FileWriteLine($temp_Script, "		If $Replace <> '' Then $Line2 = StringReplace($Line2, $Replace, $ReplaceWith)")
	If $outfile <> "" Then
		FileWriteLine($temp_Script, 'FileWrite("' & $outfile & '",$Line2)')
	EndIf
	FileWriteLine($temp_Script, "		If $ShowConsole Then ConsoleWrite($Line2)")
	FileWriteLine($temp_Script, "		; end the loop also when AutoIt3 has ended but a sub process was shelled with Run() that is still active")
	FileWriteLine($temp_Script, "		; only do this every 50 cycles to avoid cpu hunger")
	FileWriteLine($temp_Script, "		If $cnt1 = 50 Then")
	FileWriteLine($temp_Script, "			$cnt1 = 0")
	FileWriteLine($temp_Script, "			; loop another 50 times just to ensure the buffers emptied.")
	FileWriteLine($temp_Script, "			If Not ProcessExists($l_Handle) Then")
	FileWriteLine($temp_Script, "				If $cnt2 > 2 Then ExitLoop")
	FileWriteLine($temp_Script, "				$cnt2 += 1")
	FileWriteLine($temp_Script, "			EndIf")
	FileWriteLine($temp_Script, "		EndIf")
	FileWriteLine($temp_Script, "		$cnt1 += 1")
	FileWriteLine($temp_Script, "	Until ($err1 And $err2)")
	FileWriteLine($temp_Script, "	Return")
	FileWriteLine($temp_Script, "EndFunc   ;==>ShowStdOutErr")
	Local $rc = RunWait('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $temp_Script & '"')
	Sleep(500)
	; Wait for the script to finish
	While WinExists("AutoIt3Wrapper_RunningCommand")
		Sleep(50)
	WEnd
	__DelTempFile($temp_Script)
	$rc = FileRead($TempConsOut)
	__DelTempFile($TempConsOut)
	Return $rc
EndFunc   ;==>RunReqAdminDosCommand

;; Initialise the Versiong setup using TortoiseSVN and WinMerge default setup.
Func VersioningINIinit($Versioning = "SVN", $Reshelled = 0)
	; Check if we can write to the AutoIt3Wrapper.INI
	Local $rc = IniWrite($AutoIt3WapperIni, "Versioning", "test", "1")
	If $rc Then
		IniDelete($AutoIt3WapperIni, "Versioning", "test")
	Else
		; relaunch AutoItWrapper as admin
		If $Reshelled = 0 Then
			Debug("Shell into Admin mode to be able to update AutoIt3Wrapper.ini ", 1, "+")
			RunReqAdmin('RunWait(''"' & @AutoItExe & '" "' & @ScriptFullPath & '" /Versioning_Init'')')
		Else
			Debug("Problems updating your AutoIt3Wrapper.ini with the needed information.", 1, "!")
			Exit
		EndIf
	EndIf
	; Check TortoiseSVN / SilkSVN  directory for SVN.exe file location  ; @TODO portable check - mLipok
	If FileExists(@ProgramFilesDir & "\TortoiseSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", @ProgramFilesDir & "\TortoiseSVN\bin\svn.exe")
	ElseIf FileExists("C:\Program Files (x86)\TortoiseSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", "C:\Program Files (x86)\TortoiseSVN\bin\svn.exe")
	ElseIf FileExists("C:\Program Files\TortoiseSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", "C:\Program Files\TortoiseSVN\bin\svn.exe")
	ElseIf FileExists(@ProgramFilesDir & "\SilkSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", @ProgramFilesDir & "\SilkSVN\bin\svn.exe")
	ElseIf FileExists("C:\Program Files (x86)\SilkSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", "C:\Program Files (x86)\SilkSVN\bin\svn.exe")
	ElseIf FileExists("C:\Program Files\SilkSVN\bin\svn.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
		IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", "C:\Program Files\SilkSVN\bin\svn.exe")
	Else
		MsgBox(48, "SVN.exe program Not Found.", "Please install TortoiseSVN or SilkSVN and select the correct directory for SVN.exe")
		Local $VersionPGM = FileOpenDialog("Select the location of SVN.EXE program", @ProgramFilesDir, "SVN (SVN.exe)", 1)
		If @error Then
			Debug("SVN.exe program not found. Buildin versioning will not be available", 1, "!")
			Exit
		Else
			IniWrite($AutoIt3WapperIni, "Versioning", "Versioning", $Versioning)
			IniWrite($AutoIt3WapperIni, $Versioning, "VersionPGM", $VersionPGM)
		EndIf
	EndIf
	Debug("Writing defaults to AutoIt3Wrapper.ini", 1, ">")
	; Check for WinMergeU already installed
	If FileExists(@ProgramFilesDir & "\WinMerge\WinMergeU.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGM", @ProgramFilesDir & "\WinMerge\WinMergeU.exe")
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGMOptions", "/wr")
	ElseIf FileExists("C:\Program Files (x86)\WinMerge\WinMergeU.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGM", "C:\Program Files (x86)\WinMerge\WinMergeU.exe")
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGMOptions", "/wr")
	ElseIf FileExists("C:\Program Files\WinMerge\WinMergeU.exe") Then
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGM", "C:\Program Files\WinMerge\WinMergeU.exe")
		IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGMOptions", "/wr")
	Else
		MsgBox(48, "WinMerge Not found", "Please install WinMerge and select the correct directory")
		Local $DiffPgm = FileOpenDialog("Select the location of WinMergeU program", @ProgramFilesDir, "WinMergeU (WinMergeU.exe)", 1)
		If @error Then
			Debug("WinMerge program not found. Alt-F12 Show Diff will not be available", 1, "!")
			IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGM", "")
		Else
			IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGM", $DiffPgm)
			IniWrite($AutoIt3WapperIni, "Versioning", "DiffPGMOptions", "/wr")
		EndIf
	EndIf
	IniWrite($AutoIt3WapperIni, "Versioning", "Prompt_Comments", "y")
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandChkVersioning", 'info "%sourcedir%"')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandChkVersioning_ok_txt", 'Working Copy Root Path:')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandChkVersioning_ok_rc", '')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandStatusSource", 'status "%sourcefile%" -u')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandStatusSource_ADD_txt", '\?\s*?%sourcefile%')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandStatusSource_ok_txt", '[MA\?][\s\d-]*?%sourcefile%')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandLogSource", 'log "%sourcefile%" -l 5')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandAddSource", 'add "%sourcefile%"')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandAddSource_ok_txt", 'A.*?%sourcefileonly%')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandAddSource_ok_rc", '')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandCommitSource", 'commit "%sourcefile%" --message "%commitcomment%"')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandCommitSource_ok_txt", "")
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandCommitSource_ok_rc", '0')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandCommitSource_new_revision", '(?i)(?s)committed revision\s*([0-9]*)')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion", 'cat "%sourcefile%"')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion_ok_txt", '')
	IniWrite($AutoIt3WapperIni, $Versioning, "CommandGetLastVersion_ok_rc", '0')
EndFunc   ;==>VersioningINIinit
#EndRegion Versioning Other functions
#EndRegion Versioning functions
#Region Support Unicode Filenames functions

Func _CheckAllSourceFileNames(ByRef $ScriptFileName)
	; Get Include Paths
	Local $User_IncludeDirs = StringSplit(RegRead("HKCU\Software\AutoIt v3\Autoit", "Include"), ";")
	ReDim $IncludeDirs[2 + UBound($User_IncludeDirs) - 1]
	; First store the AutoIt3 directory to the search table
	$IncludeDirs[0] = _PathFull($CurrentAutoIt_InstallDir) & "\include"
	$IncludeDirs_cnt = 1
	; Add User Include Directories to the table
	For $x = 1 To $User_IncludeDirs[0]
		If StringStripWS($User_IncludeDirs[$x], 3) <> "" And FileExists($User_IncludeDirs[$x]) Then
			$IncludeDirs[$IncludeDirs_cnt] = StringReplace($User_IncludeDirs[$x], '"', '')
			$IncludeDirs_cnt += 1
		EndIf
	Next
	; Add the scriptpath as last entry to the table
	Local $szDrive, $szDir, $szFName, $szExt
	_PathSplit($ScriptFileName, $szDrive, $szDir, $szFName, $szExt)
	$IncludeDirs[$IncludeDirs_cnt] = _PathFull($szDrive & $szDir)
	;
	; Add \ at the end of the Include dirs in the search table
	For $x = 0 To $IncludeDirs_cnt
		If StringRight($IncludeDirs[$x], 1) <> "\" Then
			$IncludeDirs[$x] &= "\"
		EndIf
	Next
	;
	;  Process scriptfile
	;
	; use [1] for original script info
	; use [2] for au3check script info
	$SourceFileNames[1][0] = $ScriptFileName
	$SourceFileNames[1][1] = ""
	$SourceFileNames[1][2] = ""
	; change the newsourcename to pure ASCII characters
	Local $nScriptFileName = BinaryToString(StringToBinary($ScriptFileName, 1), 1)
	; Replace any none standard ASCII character by a "u" to avoid issues
	$nScriptFileName = StringRegExpReplace($nScriptFileName, "[\x{0080}-\x{FFFF}]", "u")
	Local $tScriptFileName, $tScriptFileNameExt, $dummy
	Local $UTFIncludeNameFound = 0
	If $nScriptFileName <> $ScriptFileName Then
		_PathSplit($nScriptFileName, $dummy, $dummy, $tScriptFileName, $tScriptFileNameExt)
		$nScriptFileName = @TempDir & "\AutoIt3WrapperRunTmpFiles\" & $tScriptFileName & $tScriptFileNameExt
		$rc = FileCopy($ScriptFileName, $nScriptFileName, 1 + 8)
		$SourceFileNames[1][2] = $nScriptFileName
		$ScriptFileName = $nScriptFileName
	EndIf
	; Get all #include lines from Main script into Array and process them
	Local $TSourceCode = FileRead($ScriptFileName)
	$TSourceCode = StringRegExpReplace($TSourceCode & @CRLF, "(?s)(?i)(\s*#cs\s*.-\#ce\s*)(\r\n)", "\2")
	$TSourceCode = StringRegExpReplace($TSourceCode, "(?s)(?i)" & '("")|(".*?")|' & "('')|('.*?')|" & "(\s*;.*?)(\r\n)", "\1\2\3\4\6")
	Local $inclArray = StringRegExp($TSourceCode, "(?m)(?s)(?i)^\s*(#include\s*[<'""]\s*\S*\s*[>'""]).*?$", 3)
	For $x = 0 To UBound($inclArray) - 1
		$UTFIncludeNameFound += Add_Include($inclArray[$x], @ScriptDir)
	Next
	; Copy Main script to Temp dir when in contains #include filenames with UTF characters in the filename
	If $SourceFileNames[1][2] = "" Then
		If $UTFIncludeNameFound Then
			_PathSplit($nScriptFileName, $dummy, $dummy, $tScriptFileName, $tScriptFileNameExt)
			$nScriptFileName = @TempDir & "\AutoIt3WrapperRunTmpFiles\" & $tScriptFileName & $tScriptFileNameExt
			$rc = FileCopy($ScriptFileName, $nScriptFileName, 1 + 8)
			$SourceFileNames[1][2] = $nScriptFileName
			$ScriptFileName = $nScriptFileName
		EndIf
	EndIf
	;  Replace the tempfilename in the #include statements of all tempfiles
	For $x = 1 To UBound($SourceFileNames) - 1
		If $SourceFileNames[1][2] = "" Then ContinueLoop
		If $x = 2 Then ContinueLoop
		$TSourceCode = FileRead($SourceFileNames[$x][2])
		For $y = 2 To UBound($SourceFileNames) - 1
			If $y = 2 Then ContinueLoop                              ; skip au3check table record
			If $x = $y Then ContinueLoop                             ; skip own #include record
			If $SourceFileNames[$y][2] <> "" Then
				$TSourceCode = StringReplace($TSourceCode, $SourceFileNames[$y][1], '"' & $SourceFileNames[$y][2] & '"')
			EndIf
		Next
		FileMove($SourceFileNames[$x][2], StringReplace($SourceFileNames[$x][2], ".au3", "_old.au3"), 1)
		FileWrite($SourceFileNames[$x][2], $TSourceCode)
		If $x = 1 Then ConsoleWrite('->Main script copied to temp file because of unicode characters in one of the filenames: ' & $nScriptFileName & @CRLF)
	Next
EndFunc   ;==>_CheckAllSourceFileNames

;=========================================================
; Add all #Include files to the outputfile - recursively
;=========================================================
Func Add_Include($Include_Rec, $CurrentSourceDir = "")
	Local $IncludeFile, $IncludeFileFound = 0
	Local $inclArray, $UTFFilenameFound = 0
	; Find the proper path
	$IncludeFile = StringStripWS(StringMid(StringStripWS($Include_Rec, 3), 9), 3)
	; Save original includefile notation
	Local $sIncludeFile = $IncludeFile
	; Check if include file is already checked with its #include name ... return if true
	For $x = 2 To UBound($SourceFileNames) - 1
		If $SourceFileNames[$x][1] = $sIncludeFile Then
			Return
		EndIf
	Next
	; Determine the Path sequence to scan for include files
	Local $seqrev = 0
	$IncludeFile = StringRegExpReplace($IncludeFile, "[<>]", "")
	If @extended Then $seqrev = 1
	$IncludeFile = StringRegExpReplace($IncludeFile, '"', '')
	If @extended Then $seqrev = 0
	$IncludeFile = StringRegExpReplace($IncludeFile, "'", '')
	If @extended Then $seqrev = 0
	$IncludeFile = StringStripWS($IncludeFile, 3)
	Local $x1 = 0
	If FileExists($IncludeFile) Then
		$IncludeFileFound = 1
	ElseIf FileExists($CurrentSourceDir & $IncludeFile) Then
		$IncludeFileFound = 1
		$IncludeFile = $CurrentSourceDir & $IncludeFile
	Else
		; Search directories for include file
		For $x = 0 To $IncludeDirs_cnt
			$x1 = ($seqrev = 1 ? $x : $IncludeDirs_cnt - $x)
			If $IncludeDirs[$x1] <> "" And FileExists($IncludeDirs[$x1] & $IncludeFile) Then
				$IncludeFile = $IncludeDirs[$x1] & $IncludeFile
				$IncludeFileFound = 1
				ExitLoop
			EndIf
		Next
	EndIf
	; Check if include file is already checked with its fullname ... return if true
	Local $ScriptFileName = _PathFull($IncludeFile)
	For $x = 2 To UBound($SourceFileNames) - 1
		If $SourceFileNames[$x][0] = $ScriptFileName Then
			Return
		EndIf
	Next
	; Include file found so process it
	If $IncludeFileFound Then
		ReDim $SourceFileNames[UBound($SourceFileNames) + 1][3]
		Local $idx = UBound($SourceFileNames) - 1
		$SourceFileNames[$idx][0] = $ScriptFileName
		$SourceFileNames[$idx][1] = $sIncludeFile
		$SourceFileNames[$idx][2] = ""
		; change the newsourcename to pure ASCII characters
		Local $nScriptFileName = BinaryToString(StringToBinary($ScriptFileName, 1), 1)
		;log files to console
		If $Debug Then __ConsoleWrite("+ include:" & $ScriptFileName & " Encoding:" & FileGetEncoding($ScriptFileName) & @CRLF)
		; Replace any none standard ASCII character by a "u" to avoid issues
		$nScriptFileName = StringRegExpReplace($nScriptFileName, "[\x{0080}-\x{FFFF}]", "u")
		Local $tScriptFileName, $tScriptFileNameExt, $sDrive, $sDir
		_PathSplit($nScriptFileName, $sDrive, $sDir, $tScriptFileName, $tScriptFileNameExt)
		If $nScriptFileName <> $ScriptFileName Then
			; Add "number_" infront of the TempFilename to ensure they are all unique
			$nScriptFileName = @TempDir & "\AutoIt3WrapperRunTmpFiles\" & $idx & "_" & $tScriptFileName & $tScriptFileNameExt
			ConsoleWrite('->Includefile ' & $idx & ":" & $sIncludeFile & ' contains Unicode characters in name so copied to tempfile ' & $nScriptFileName & @CRLF)
			$rc = FileCopy($ScriptFileName, $nScriptFileName, 1 + 8)
			$SourceFileNames[$idx][2] = $nScriptFileName
			$UTFFilenameFound += 1
		EndIf
		; Get all #include lines from include file into Array and process them
		Local $TSourceCode = FileRead($ScriptFileName)
		$TSourceCode = StringRegExpReplace($TSourceCode & @CRLF, "(?s)(?i)(\s*#cs\s*.-\#ce\s*)(\r\n)", "\2")
		$TSourceCode = StringRegExpReplace($TSourceCode, "(?s)(?i)" & '("")|(".*?")|' & "('')|('.*?')|" & "(\s*;.*?)(\r\n)", "\1\2\3\4\6")
		$inclArray = StringRegExp($TSourceCode, "(?m)(?s)(?i)^\s*(#include\s*[<'""]\s*\S*\s*[>'""]).*?$", 3)
		For $x = 0 To UBound($inclArray) - 1
			$UTFFilenameFound += Add_Include($inclArray[$x], $sDrive & $sDir)
		Next
	Else
		ConsoleWrite('!->Includefile ' & $sIncludeFile & ' not found.' & @CRLF)
	EndIf
	Return $UTFFilenameFound
EndFunc   ;==>Add_Include
#EndRegion Support Unicode Filenames functions
