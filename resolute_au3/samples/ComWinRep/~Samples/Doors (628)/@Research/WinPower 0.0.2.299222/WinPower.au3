#AutoIt3Wrapper_icon=Resources\WinPower.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Rizone's Power Tools
#AutoIt3Wrapper_Res_Fileversion=0.0.2.2993
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© 2009 Rizone Technologies



#Include <Includes\WinAPIEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>

#Include <GuiListView.au3>
#include <Constants.au3>
#Include <Clipboard.au3>

#include <Loader.au3>

#include <Date.au3>

Opt("TrayMenuMode", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("GUIOnEventMode", 1)
Opt("TrayOnEventMode", 1)
Opt("MouseClickDelay", 5)
Opt("MouseClickDownDelay", 5)
Opt("MouseClickDragDelay", 200)
;Opt("TrayIconDebug", 1) ; 0 = no info, 1 = debug line info


Global Const $PowerTitle = "Rizone's Power Tools", $PowerVer = FileGetVersion(@ScriptDir & "\" & @ScriptName)
Global Const $PowerRelDate = IniRead($PowerSettings, "Main", "ReleaseDate", "YYYY/MM/DD")
; Global Const $PROCESS_ALL_ACCESS = 0x1F0FFF



Global $Process = @ScriptName
_LoaderStart()
_LoaderUpdate(1)

Global $GLRBINSIZE = 0, $GLRBINITEMS = 0, $RBINEMPTY, $SHQUERYRBINFO = DllStructCreate("align 1;int;int64;int64")
Global $PowerForm, $eStatus, $hStatus, $GPowAni, $aParts[3] = [320, 550, -1]
Global $MemProg, $MemStats, $MemUsDiff = 0, $MemPrDiff = 0, $PageDiff = 0 ;Memory Variables
Global $GDRIVES = DriveGetDrive("FIXED"), $GDRIVENUMBER = 0
Global $GDRIVESELECTED ; Stores currently selected drive.
Global $GRBREQ = 0, $GMinute

; Load Settings
Global $LogFileSize, $HideOnMinimize

$HideOnMinimize = IniRead($PowerSettings, "GUI", "HideOnMinimize", 1)




Global Const $GBacDir = @ScriptDir & "\Backup"


Global Const $GQRegDefExe = $GBinDir & "\QRegDefrag\QRegDefrag.exe"
Global Const $GRescueDir = @ScriptDir & "\Rescue"
Global Const $GNTREGOPTEXE = $GBinDir & "\ERUNT\NTREGOPT.EXE"
Global Const $GERUNTEXE = $GBinDir & "\ERUNT\ERUNT.EXE"
Global Const $GERDNTEXE = $GRescueDir & "\ERDNT.EXE"
Global Const $GClamWinEXE = $GBinDir & "\ClamWin\Bin\ClamWin.exe"
Global Const $GDeadPixEXE = $GBinDir & "\PixRepair.exe"
Global Const $GJKDEXE = $GBinDir & "\JkDefrag\JkDefrag.exe" ;JkDefrag Executable
Global Const $GJKDLOG = $GBinDir & "\JkDefrag\JkDefrag.log" ;JkDefrag Log File

If @OSArch = "X86" Then Global $GFontRegEXE = $GBinDir & "\FontReg\FontReg.exe"
If @OSArch = "X64" Then Global $GFontRegEXE = $GBinDir & "\FontReg\FontReg64.exe"

Global Const $IEExplEXE = @ProgramFilesDir & "\Internet Explorer\IEXPLORE.EXE"
Global Const $GSendToDir = _WinAPI_ShellGetSpecialFolderPath($CSIDL_SENDTO)
Global Const $IEVersion = StringSplit(FileGetVersion(@ProgramFilesDir & "\Internet Explorer\IEXPLORE.EXE", "ProductVersion"), ".")
Global Const $FCatRoot = @SystemDir & "\CatRoot2\"

Global $InRName, $BCPoint

If Not FileExists($GBacDir) Then DirCreate($GBacDir)
If Not FileExists($GLogDir) Then DirCreate($GLogDir)

If Not FileExists($GBinDir) Then DirCreate($GThemeDir)

_CreateLoggingDirectory()
_LoaderUpdate(2)


_LoaderUpdate(3)






_LoaderUpdate(4)
Global Const $GPowerRes = @ScriptDir & "\WinPower.dll"
Global Const $GPowerRes16 = @ScriptDir & "\WinPower16.dll"
Global Const $GPWinTitle = $PowerTitle & " " & $PowerVer & " Prototype 5"

_Initialize()

_LoaderUpdate(5)
$PowerForm = GUICreate($GPWinTitle, 703, 500, 192, 124)
GUISetFont(8.5, 400, 0, "Verdana")
GUISetBkColor(0xEBEBEB)
$PowIcon = GUICtrlCreateIcon($GPowerRes, 1, 19, 10, 64, 64, $SS_NOTIFY)
GuiCtrlSetCursor($PowIcon, 0)
$QuiB1 = GUICtrlCreateButton("1", 15, 80, 25, 23, $WS_GROUP)
$QuiB2 = GUICtrlCreateButton("2", 40, 80, 25, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$QuiB3 = GUICtrlCreateButton("3", 65, 80, 25, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$QuiB4 = GUICtrlCreateButton("4", 15, 103, 25, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$QuiB5 = GUICtrlCreateButton("5", 40, 103, 25, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$QuiB6 = GUICtrlCreateButton("6", 65, 103, 25, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$QuiB7 = GUICtrlCreateButton("7", 15, 126, 25, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$QuiB8 = GUICtrlCreateButton("8", 40, 126, 25, 23)
GUICtrlSetState(-1, $GUI_DISABLE)
$QuiB9 = GUICtrlCreateButton("9", 65, 126, 25, 23, $WS_GROUP)
GUICtrlSetState(-1, $GUI_DISABLE)
$eStatus = GUICtrlCreateEdit("", 8, 344, 525, 105, BitOR($WS_VSCROLL, $ES_READONLY, $ES_AUTOVSCROLL, $WS_HSCROLL))
GUICtrlSetBkColor($eStatus, 0xFFFFFF)

GUICtrlSetOnEvent($QuiB1, "_ClearClipboard")

_PowerLogStart()
_CheckCommandPrompt()

_LoaderUpdate(6)

;~ $FiLOpenPLog = GUICtrlCreateMenuItem("&Open Log File...", $FiLogMenu)
;~ $FiLogDir = GUICtrlCreateMenuItem("Open &Logging Folder", $FiLogMenu)
;~ $FiMinimize = GUICtrlCreateMenuItem("&Minimize", $FileMenu)
;~ $FiClose = GUICtrlCreateMenuItem("&Close", $FileMenu)

;~ GUICtrlSetOnEvent($FiLOpenPLog, "_OpenPowerLog")
;~ GUICtrlSetOnEvent($FiLogDir, "_OpenLoggingFolder")
;~ GUICtrlSetOnEvent($FiMinimize, "_MinimizeClicked")
;~ GUICtrlSetOnEvent($FiClose, "_PowerCLosedClicked")

_LoaderUpdate(7)
; ===============================================================================================================================
; Accessories Menu
; ===============================================================================================================================

$AccMenu = GUICtrlCreateMenu("&Accessories")
$AccAccess = GUICtrlCreateMenu("&Accessibility Center", $AccMenu)
$AAccOpt = GUICtrlCreateMenuItem("Accessi&bility Options", $AccAccess)
$AccCalc = GUICtrlCreateMenuItem("&Calculator", $AccMenu)
$AccComm = GUICtrlCreateMenuItem("Command &Prompt", $AccMenu)

_LoaderUpdate(8)
GUICtrlSetOnEvent($AAccOpt, "_StartAccessibilityOptions")
GUICtrlSetOnEvent($AccComm, "_StartCommandPrompt")
GUICtrlSetOnEvent($AccCalc, "_StartCalculator")

_LoaderUpdate(9)
If Not FileExists(@SystemDir & "\calc.exe") Then GUICtrlDelete($AccCalc)
If Not FileExists(@SystemDir & "\cmd.exe") Then GUICtrlDelete($AccComm)

_LoaderUpdate(10)
; ===============================================================================================================================
; Administration Menu
; ===============================================================================================================================

$AdminMenu = GUICtrlCreateMenu("A&dministration")
$AdTools = GUICtrlCreateMenuItem("&Administrative Tools", $AdminMenu)
$AdCompMgmnt = GUICtrlCreateMenuItem("Computer &Management", $AdminMenu)
GUICtrlCreateMenuItem("", $AdminMenu)
$AdBrCase = GUICtrlCreateMenu("&Briefcase Management", $AdminMenu)
$BrIntro = GUICtrlCreateMenuItem("Briefcase &Introduction", $AdBrCase)
$BrCreate = GUICtrlCreateMenuItem("&Create Briefcase (Desktop)", $AdBrCase)
$BrRemove = GUICtrlCreateMenuItem("&Remove Briefcase", $AdBrCase)
GUICtrlCreateMenuItem("", $AdBrCase)
$BrOpen = GUICtrlCreateMenuItem("Open &Briefcase", $AdBrCase)
$AdCertMan = GUICtrlCreateMenuItem("Cer&tificate Manager", $AdminMenu)
$AdClip = GUICtrlCreateMenu("&ClipBoard Management", $AdminMenu)
$ClipClear = GUICtrlCreateMenuItem("&Clear ClipBoard - 1" & @TAB & "Ctrl+1", $AdClip)
$ClipViewer = GUICtrlCreateMenuItem("ClipBook &Viewer", $AdClip)
$AdCompServ = GUICtrlCreateMenuItem("C&omponent Services", $AdminMenu)
$AdDrvMan = GUICtrlCreateMenu("&Drive Management", $AdminMenu)
$DsMMan = GUICtrlCreateMenuItem("Disk &Management", $AdDrvMan)
GUICtrlCreateMenuItem("", $AdDrvMan)
$DsMCheckDsk = GUICtrlCreateMenuItem("C&heck Disk...", $AdDrvMan)
$DsMClean = GUICtrlCreateMenuItem("Disk &Cleanup", $AdDrvMan)
$DsMDFrag = GUICtrlCreateMenuItem("Disk &Defragmenter", $AdDrvMan)
$DsMPMan = GUICtrlCreateMenuItem("&Partition Manager", $AdDrvMan)
GUICtrlCreateMenuItem("", $AdDrvMan)
$DsMFormat = GUICtrlCreateMenuItem("&Format...", $AdDrvMan)
$AdEvView = GUICtrlCreateMenuItem("&Event Viewer", $AdminMenu)
$AdSigVer = GUICtrlCreateMenuItem("File Signature &Verification", $AdminMenu)
$AdFSTrans = GUICtrlCreateMenuItem("Files and Settings Transfer &Wizard", $AdminMenu)
$AdHardMan = GUICtrlCreateMenu("&Hardware Management", $AdminMenu)
$HarMAddWiz = GUICtrlCreateMenuItem("Add &Hardware Wizard", $AdHardMan)
$HarMDevMan = GUICtrlCreateMenuItem("&Device Manager", $AdHardMan)
$HarMDrVer = GUICtrlCreateMenuItem("Driver &Verifier Manager", $AdHardMan)
$AdIndexServ = GUICtrlCreateMenuItem("&Indexing Service", $AdminMenu)
$AdNetMngt = GUICtrlCreateMenu("&Network Management", $AdminMenu)
$NetMConn = GUICtrlCreateMenuItem("Network &Connections",$AdNetMngt)
$NetMHTerm = GUICtrlCreateMenuItem("&Hyper Terminal", $AdNetMngt)
$NetMDialer = GUICtrlCreateMenuItem("Phone &Dialer", $AdNetMngt)
$NetMRDesk = GUICtrlCreateMenuItem("&Remote Desktop Connection", $AdNetMngt)
$NetMRAcc = GUICtrlCreateMenuItem("Remote &Access Connection Manager", $AdNetMngt)
$NetMTelnet = GUICtrlCreateMenuItem("&Telnet Client", $AdNetMngt)
$AdTCP6 = GUICtrlCreateMenu("&IPv6 Management", $AdNetMngt)
$ATCP6Inst = GUICtrlCreateMenuItem("&Install IPv6", $AdTCP6)
$ATCP6Uninst = GUICtrlCreateMenuItem("&Uninstall IPv6", $AdTCP6)
GUICtrlCreateMenuItem("", $AdTCP6)
$ATCP6Reset = GUICtrlCreateMenuItem("&Reset IPv6", $AdTCP6)
$AdODBCD = GUICtrlCreateMenuItem("ODBC Data Sou&rce Administration.", $AdminMenu)
$AdPerMon = GUICtrlCreateMenuItem("&Performance Monitor", $AdminMenu)
$AdResMon = GUICtrlCreateMenuItem("&Resource Monitor", $AdminMenu)
$AdWMI = GUICtrlCreateMenuItem("Windows Management In&frastructure", $AdminMenu)
$AdMUser = GUICtrlCreateMenu("&User Management", $AdminMenu)
$UsMEditor = GUICtrlCreateMenuItem("&User Accounts Editor", $AdMUser)
$UsMAccess = GUICtrlCreateMenuItem("User Account &Access Restrictions", $AdMUser)
$UsMSFMan = GUICtrlCreateMenuItem("&Shared Folder Manager", $AdMUser)

_LoaderUpdate(11)
GUICtrlSetOnEvent($AdTools, "_StartAdminTools")
GUICtrlSetOnEvent($AdCompMgmnt, "_StartComputerManagement")
GUICtrlSetOnEvent($BrIntro, "_OpenBriefcaseIntroduction")
GUICtrlSetOnEvent($BrCreate, "_CreateBriefcase")
GUICtrlSetOnEvent($BrRemove, "_RemoveBriefcase")
GUICtrlSetOnEvent($BrOpen, "_OpenBriefcase")
GUICtrlSetOnEvent($AdCertMan, "_StartCertificateManager")
GUICtrlSetOnEvent($ClipClear, "_ClearClipboard")
GUICtrlSetOnEvent($ClipViewer, "_StartClipBookViewer")
GUICtrlSetOnEvent($AdCompServ, "_StartComponentServices")
GUICtrlSetOnEvent($DsMMan, "_StartDiskManagement")
GUICtrlSetOnEvent($DsMCheckDsk, "_CheckDiskGUI")
GUICtrlSetOnEvent($DsMClean, "_StartDiskCleanup")
GUICtrlSetOnEvent($DsMDFrag, "_StartWindowsDefrag")
GUICtrlSetOnEvent($DsMPMan, "_StartPartitionManager")
GUICtrlSetOnEvent($DsMFormat, "_FormatSelectedDrive")
GUICtrlSetOnEvent($AdEvView, "_StartEventViewer")
GUICtrlSetOnEvent($AdSigVer, "_StartFileSigVerification")
GUICtrlSetOnEvent($AdFSTrans, "_StartFilesSettingsTransferWiz")
GUICtrlSetOnEvent($HarMAddWiz, "_StartAddHardwareWizard")
GUICtrlSetOnEvent($HarMDevMan, "_StartDeviceManager")
GUICtrlSetOnEvent($HarMDrVer, "_StartDriverVerifier")
GUICtrlSetOnEvent($AdIndexServ, "_StartIndexingService")
GUICtrlSetOnEvent($NetMConn, "_OpenNetworkConnections")
GUICtrlSetOnEvent($NetMHTerm, "_StartHyperTerminal")
GUICtrlSetOnEvent($NetMDialer, "_StartPhoneDialer")
GUICtrlSetOnEvent($NetMRDesk, "_StartRemoteDesktopConn")
GUICtrlSetOnEvent($NetMRAcc, "_StartRemoteAccessConnMan")
GUICtrlSetOnEvent($NetMTelnet, "_StartTelnetClient")
GUICtrlSetOnEvent($ATCP6Inst, "_InstallIPv6")
GUICtrlSetOnEvent($ATCP6Uninst, "_UnInstallIPv6")
GUICtrlSetOnEvent($ATCP6Reset, "_ResetIPv6")
GUICtrlSetOnEvent($AdODBCD, "_StartODBCDataSourceAdmin")
GUICtrlSetOnEvent($AdPerMon, "_StartPerformanceMonitor")
GUICtrlSetOnEvent($AdResMon, "_StartResourceMonitor")
GUICtrlSetOnEvent($AdWMI, "_StartWinManInfrastructure")
GUICtrlSetOnEvent($UsMEditor, "_StartUserAccountsEditor")
GUICtrlSetOnEvent($UsMAccess, "_StartUserAccountAccess")
GUICtrlSetOnEvent($UsMSFMan, "_StartSharedFolderManager")

_LoaderUpdate(12)
If Not FileExists(@SystemDir & "\clipbrd.exe") Then GUICtrlDelete($ClipViewer)
If Not FileExists(@SystemDir & "\ciadv.msc") Then GUICtrlDelete($AdIndexServ)
If Not FileExists(@ProgramFilesDir & "\Windows NT\hypertrm.exe") Then GUICtrlDelete($NetMHTerm)
If Not FileExists(@SystemDir & "\telnet.exe") Then GUICtrlDelete($NetMTelnet)
If Not FileExists(@SystemDir & "\resmon.exe") Then GUICtrlDelete($AdResMon)

_LoaderUpdate(13)
;~ ; ===============================================================================================================================
;~ ; Control Panel Menu
;~ ; ===============================================================================================================================

;~ $ConPMenu = GUICtrlCreateMenu("&Control Panel")
;~ $CPConP = GUICtrlCreateMenuItem("&Control Panel", $ConPMenu)
;~ GUICtrlCreateMenuItem("", $ConPMenu)
;~ $CPAcc = GUICtrlCreateMenuItem("Accessi&bility Options", $ConPMenu)
;~ $CPAddRem = GUICtrlCreateMenu("&Programs and Features", $ConPMenu) ; Programs and Features Menu
;~ $CAPChRemove = GUICtrlCreateMenuItem("C&hange or Remove Programs", $CPAddRem)
;~ GUICtrlCreateMenuItem("", $CPAddRem)
;~ $CAPNewPrograms = GUICtrlCreateMenuItem("Add &New Programs", $CPAddRem)
;~ $CAPWinComp = GUICtrlCreateMenuItem("Add or Remove &Windows Components", $CPAddRem)
;~ $CAPAccess = GUICtrlCreateMenuItem("Set Pr&ogram Access and Defaults", $CPAddRem)
;~
;~ $CPAdminTools = GUICtrlCreateMenuItem("Administrati&ve Tools", $ConPMenu)
;~ $CPAutUpdate = GUICtrlCreateMenuItem("Automatic &Updates", $ConPMenu)
;~ $CPDateTime = GUICtrlCreateMenuItem("&Date and Time Properties", $ConPMenu)
;~ $CPlDXDiag = GUICtrlCreateMenuItem("Direct&X Troubleshooter", $ConPMenu)
;~ $CPDisp = GUICtrlCreateMenu("Display Pr&operties", $ConPMenu)
;~ $DisProp = GUICtrlCreateMenuItem("&Display Properties", $CPDisp)
;~ $DisColor = GUICtrlCreateMenuItem("&Color and Appearance", $CPDisp)
;~ $CPFonts = GUICtrlCreateMenuItem("&Font Management", $ConPMenu)
;~ $CPGame = GUICtrlCreateMenuItem("&Game Controllers", $ConPMenu)
;~ $CPIESett = GUICtrlCreateMenuItem("&Internet Properties", $ConPMenu)
;~ $CPKey = GUICtrlCreateMenuItem("&Keyboard Properties", $ConPMenu)
;~ $CPMouse = GUICtrlCreateMenuItem("&Mouse Properties", $ConPMenu)
;~ $CPNConn = GUICtrlCreateMenuItem("Network &Connections", $ConPMenu)
;~ $CPFold = GUICtrlCreateMenuItem("Fold&er Options", $ConPMenu)
;~ $CPPhone = GUICtrlCreateMenuItem("Pho&ne and Modem Options", $ConPMenu)
;~ $CPPrint = GUICtrlCreateMenuItem("P&rinters and Faxes", $ConPMenu)
;~ $CPPower = GUICtrlCreateMenuItem("Po&wer Options", $ConPMenu)
;~ $CPSecC = GUICtrlCreateMenuItem("&Security Center", $ConPMenu)
;~ $CPRegion = GUICtrlCreateMenuItem("Regional and &Language Options", $ConPMenu)
;~ $CPSTasks = GUICtrlCreateMenuItem("Scheduled &Tasks", $ConPMenu)
;~ $CPSAudio = GUICtrlCreateMenuItem("Sou&nd and Audio Device Properties", $ConPMenu)
;~ $PCSystemProp = GUICtrlCreateMenuItem("&System Properties", $ConPMenu)
;~ $CPUserAco = GUICtrlCreateMenuItem("User &Accounts", $ConPMenu)

_LoaderUpdate(14)
;~ GUICtrlSetOnEvent($CPConP, "_StartControlPanel")
;~ GUICtrlSetOnEvent($CPAcc, "_StartAccessibilityOptions")
;~ GUICtrlSetOnEvent($CAPChRemove, "_StartChangeRemovePrograms")
;~ GUICtrlSetOnEvent($CAPNewPrograms, "_StartAddNewPrograms")
;~ GUICtrlSetOnEvent($CAPWinComp, "_StartAddRemoveWindowsComponents")
;~ GUICtrlSetOnEvent($CAPAccess, "_StartProgramAccessDefaults")
;~
;~ GUICtrlSetOnEvent($CPAdminTools, "_StartAdminTools")
;~ GUICtrlSetOnEvent($CPAutUpdate, "_StartAutomaticUpdates")
;~ GUICtrlSetOnEvent($CPDateTime, "_StartDateTimeProperties")
;~ GUICtrlSetOnEvent($CPlDXDiag, "_StartDirectXTroubleshooter")
;~ GUICtrlSetOnEvent($DisProp, "_StartDisplayProperties")
;~ GUICtrlSetOnEvent($DisColor, "_StartColorAppearance")
;~ GUICtrlSetOnEvent($CPFonts, "_StartFontManagement")
;~ GUICtrlSetOnEvent($CPGame, "_StartGameControllers")
;~ GUICtrlSetOnEvent($CPIESett, "_StartInternetProperties")
;~ GUICtrlSetOnEvent($CPKey, "_StartKeyboardProperties")
;~ GUICtrlSetOnEvent($CPMouse, "_StartMouseProperties")
;~ GUICtrlSetOnEvent($CPNConn, "_StartNetworkConnections")
;~ GUICtrlSetOnEvent($CPFold, "_StartFolderOptions")
;~ GUICtrlSetOnEvent($CPPhone, "_StartPhoneModemOptions")
;~ GUICtrlSetOnEvent($CPPrint, "_StartPrintersFaxes")
;~ GUICtrlSetOnEvent($CPPower, "_StartPowerOptions")
;~ GUICtrlSetOnEvent($CPSecC, "_StartSecurityCenter")
;~ GUICtrlSetOnEvent($CPRegion, "_StartRegionalLanguageOptions")
;~ GUICtrlSetOnEvent($CPSTasks, "_StartScheduledTasks")
;~ GUICtrlSetOnEvent($CPSAudio, "_StartSoundAudioDeviceProperties")
;~ GUICtrlSetOnEvent($PCSystemProp, "_StartSystemProperties")
;~ GUICtrlSetOnEvent($CPUserAco, "_StartUserAccounts")

_LoaderUpdate(15)
; ===============================================================================================================================
; Maintenance Menu
; ===============================================================================================================================

$MntMenu = GUICtrlCreateMenu("&Maintenance")
$MMozBackup = GUICtrlCreateMenuItem("MozBackup...", $MntMenu)
$MBcWinAct = GUICtrlCreateMenu("Windows &Activation", $MntMenu)
$MBWAOpen = GUICtrlCreateMenuItem("&Activate Windows", $MBcWinAct)
GUICtrlCreateMenuItem("", $MBcWinAct)
$MBWABack = GUICtrlCreateMenuItem("&Backup Activation", $MBcWinAct)
$MBWARest = GUICtrlCreateMenuItem("&Restore Activation", $MBcWinAct)
$MnRecBin = GUICtrlCreateMenu("Recycle &Bin", $MntMenu)
$MnRecBOpen = GuiCtrlCreateMenuItem("&Open Recycle Bin", $MnRecBin)
$MnRecBEmp = GuiCtrlCreateMenuItem("&Empty Recycle Bin", $MnRecBin)
$MnRecBProp = GuiCtrlCreateMenuItem("Recycle Bin &Properties...", $MnRecBin)
$MnRegBack = GUICtrlCreateMenu("&Registry Backup", $MntMenu)
$MRegBack = GUICtrlCreateMenuItem("Backup &Registry", $MnRegBack)
$MRegRest = GUICtrlCreateMenuItem("Re&store Registry Backup", $MnRegBack)
$MnSysRest = GUICtrlCreateMenu("&System Restore", $MntMenu)
$MRCrRest = GUICtrlCreateMenuItem("&Create a System Restore Point...", $MnSysRest)
$MRORest = GUICtrlCreateMenuItem("&Open System Restore", $MnSysRest)

_LoaderUpdate(16)
GUICtrlSetOnEvent($MBWAOpen, "_OpenActivation")
GUICtrlSetOnEvent($MBWABack, "_BackupActivation")
GUICtrlSetOnEvent($MBWARest, "_RestoreActivation")
GUICtrlSetOnEvent($MnRecBOpen, "_OpenRecycleBin")
GUICtrlSetOnEvent($MnRecBEmp, "_EmptyRecycleBin")
GUICtrlSetOnEvent($MnRecBProp, "_OpenRecycleBinProperties")
GUICtrlSetOnEvent($MRegBack, "_BackupRegistry")
GUICtrlSetOnEvent($MRegRest, "_RestoreRegistry")
GUICtrlSetOnEvent($MRCrRest, "_CreateSystemRestore")
GUICtrlSetOnEvent($MRORest, "_OpenSystemRestore")

_LoaderUpdate(17)
If Not @OSVersion = "WIN_XP" Or @OSVersion = "WIN_2003" Then GUICtrlDelete($MBcWinAct)
If Not FileExists($GERUNTEXE) Then GuiCtrlSetState($MRegBack, $GUI_DISABLE)
If Not FileExists($GERDNTEXE) Then GuiCtrlSetState($MRegRest, $GUI_DISABLE)

_LoaderUpdate(18)
; ===============================================================================================================================
; Optimize Menu
; ===============================================================================================================================

$OptimMenu = GUICtrlCreateMenu("&Optimize")
$OpMemMenu = GUICtrlCreateMenu("Optimize &Memory", $OptimMenu)
$OMClrPWorkSet = GUICtrlCreateMenuItem("Clear Pr&ocesses Working Set " & @TAB & "Ctrl+Alt+O", $OpMemMenu)
$OMClrSysCache = GUICtrlCreateMenuItem("&Clear System Cache... " & @TAB & "Ctrl+Alt+C", $OpMemMenu)
$OpProcIdleT = GUICtrlCreateMenuItem("Process &Idle Tasks " & @TAB & "Ctrl+Alt+I", $OptimMenu)
$OpFlFBuff = GUICtrlCreateMenuItem("&Flush File Buffers " & @TAB & "Ctrl+Alt+F", $OptimMenu)
$OpRegMenu = GUICtrlCreateMenu("&Registry Optimization", $OptimMenu)
$ORegQSysDef = GUICtrlCreateMenuItem("&Quicksys RegDefrag", $OpRegMenu)
$OREGOPT = GUICtrlCreateMenuItem("&Registry Optimization (NTREGOPT)", $OpRegMenu)

_LoaderUpdate(19)
GUICtrlSetOnEvent($OMClrPWorkSet, "_ClearProcessesWorkingSet")
GUICtrlSetOnEvent($OMClrSysCache, "_ClearSystemCache")
GUICtrlSetOnEvent($OpProcIdleT, "_ProcessIdleTasks")
GUICtrlSetOnEvent($OpFlFBuff, "_FlushFileCache")
GUICtrlSetOnEvent($ORegQSysDef, "_OptimizeRegistry")
GUICtrlSetOnEvent($OREGOPT, "_StartNTREGOPT")

_LoaderUpdate(20)
If Not FileExists($GQRegDefExe) Then GuiCtrlSetState($ORegQSysDef, $GUI_DISABLE)
If Not FileExists($GQRegDefExe) And Not FileExists($GNTREGOPTEXE) Then GuiCtrlSetState($OpRegMenu, $GUI_DISABLE)

_LoaderUpdate(21)
; ===============================================================================================================================
; Repair Menu
; ===============================================================================================================================

$RepMenu = GUICtrlCreateMenu("&Repair")
$RepClearPS = GUICtrlCreateMenuItem("&Clear Print Spooler", $RepMenu)
$RepDeadPR = GUICtrlCreateMenuItem("&Dead Pixel Repair...", $RepMenu)
$RepInt = GUICtrlCreateMenu("&Internet", $RepMenu)
$RIntWUAU = GUICtrlCreateMenuItem("Repair Windows &Update / Automatic Updates", $RepInt)
$RIntSSLH = GUICtrlCreateMenuItem("Repair &SSL / HTTPS / Cryptography", $RepInt)
$RIntReset = GUICtrlCreateMenuItem("Reset Internet &Explorer " & $IEVersion[1] & "." & $IEVersion[2], $RepInt)
$RSetGooHome = GUICtrlCreateMenuItem("Set &Google as IE Home Page", $RepInt)
$RSetGooS = GUICtrlCreateMenuItem("Set Google as &Default Search Engine", $RepInt)
$RepNet = GUICtrlCreateMenu("&Networking", $RepMenu)
$RNetShowLSP = GUICtrlCreateMenuItem("Show Winsock &LSPs", $RepNet)
$RNetReset = GUICtrlCreateMenuItem("Reset &TCP/IP Stack", $RepNet)
$RNetResAll = GUICtrlCreateMenuItem("Reset TCP/IP Stack (&All)", $RepNet)
$RNetWinsock = GUICtrlCreateMenuItem("Repair &Winsock (Reset Catalog)", $RepNet)
$RNRNewTCPIP = GUICtrlCreateMenuItem("Release and Renew TCP/IP &Connections", $RepNet)
$RNFlushDNS = GUICtrlCreateMenuItem("Flush and Re-Register &DNS", $RepNet)
$RRFirewall = GUICtrlCreateMenuItem("Reset Windows &Firewall Configuration", $RepNet)
$RIconCache = GUICtrlCreateMenuItem("Rebuild &Icon Cache", $RepMenu)
$RREnable = GUICtrlCreateMenu("&Re-Enable Components", $RepMenu)
$EnQuickAll = GUICtrlCreateMenuItem("Quick Enable &All", $RREnable)
GUICtrlCreateMenuItem("", $RREnable)
$EnRegEdit = GUICtrlCreateMenuItem("Enable &Registry Editor", $RREnable)
$EnTaskMgr = GUICtrlCreateMenuItem("Enable &Task Manager", $RREnable)
$RRInsComp = GUICtrlCreateMenu("Re-Install &Windows Components", $RepMenu)
$RInsFirewall = GUICtrlCreateMenuItem("Re-Install Windows &Firewall", $RRInsComp)
$RepFonts = GUICtrlCreateMenuItem("Repair &Font Registrations", $RepMenu)
$RWinErr = GUICtrlCreateMenu("Windows &Errors", $RepMenu)
$WE80070005 = GUICtrlCreateMenuItem("0×80070005 &Installation Errors", $RWinErr)

_LoaderUpdate(22)
GUICtrlSetOnEvent($RepClearPS, "_ClearPrintSpooler")
GUICtrlSetOnEvent($RepDeadPR, "_StartDeadPixelRepair")
GUICtrlSetOnEvent($RIntWUAU, "_RepairWUAUClicked")
GUICtrlSetOnEvent($RIntSSLH, "_RepairSHCClicked")
GUICtrlSetOnEvent($RIntReset, "_ResetInternetExplorer")
GUICtrlSetOnEvent($RSetGooHome, "_SetGoogleAsHomePage")
GUICtrlSetOnEvent($RSetGooS, "_SetGoogleAsDefaultSearch")
GUICtrlSetOnEvent($RNetShowLSP, "_ShowWinsockLSPs")
GUICtrlSetOnEvent($RNetReset, "_ResetTCPIP")
GUICtrlSetOnEvent($RNetResAll, "_ResetTCPIPAll")
GUICtrlSetOnEvent($RNetWinsock, "_RepairWinsock")
GUICtrlSetOnEvent($RNRNewTCPIP, "_RelRenewTCPIP")
GUICtrlSetOnEvent($RNFlushDNS, "_FlushReregisterDNS")
GUICtrlSetOnEvent($RRFirewall, "_ResetFirewall")
GUICtrlSetOnEvent($RIconCache, "_RebuildIconCacheOption")
GUICtrlSetOnEvent($EnQuickAll, "_QuickEnableAll")
GUICtrlSetOnEvent($EnRegEdit, "_EnableRegistryEditor")
GUICtrlSetOnEvent($EnTaskMgr, "_EnableTaskManager")
GUICtrlSetOnEvent($RInsFirewall, "_ReinstallFirewall")
GUICtrlSetOnEvent($RepFonts, "_RepairFontRegistrations")
GUICtrlSetOnEvent($WE80070005, "_ResetSecSettings")

_LoaderUpdate(23)

_LoaderUpdate(24)
; ===============================================================================================================================
; Security Menu
; ===============================================================================================================================

$SecMenu = GUICtrlCreateMenu("Securit&y")
$SecAVFree = GUICtrlCreateMenu("&Best Free AntiVirus Software", $SecMenu)
$SAVFAvira = GUICtrlCreateMenuItem("&Avira AntiVir Personal", $SecAVFree) ; http://www.free-av.com/en/products/1/avira_antivir_personal__free_antivirus.html
$SAVFMSSecEss = GUICtrlCreateMenuItem("&Microsoft Security Essentials", $SecAVFree) ; http://www.microsoft.com/Security_Essentials/
$SAVFAvast = GUICtrlCreateMenuItem("a&vast! Home Edition", $SecAVFree) ; http://www.avast.com/eng/avast_4_home.html
$SAVFPanCloud = GUICtrlCreateMenuItem("&Panda Cloud AntiVirus", $SecAVFree) ; http://www.cloudantivirus.com
$SAVFAVG = GUICtrlCreateMenuItem("AV&G Anti-Virus Free Edition", $SecAVFree) ; http://free.avg.com/ww-en/download?prd=afg
GUICtrlCreateMenuItem("", $SecMenu)
$SecClamWin = GUICtrlCreateMenuItem("&ClamWin AntiVirus", $SecMenu)
$SecAntiVir = GUICtrlCreateMenu("&Online AntiVirus Scanners", $SecMenu)
$SAVEset = GUICtrlCreateMenuItem("&ESET Online Scanner", $SecAntiVir)
$SAVJotti = GUICtrlCreateMenuItem("&Jotti's Malware Scan", $SecAntiVir)
$SAVKaspersky = GUICtrlCreateMenuItem("&Kaspersky Virus File Scanner", $SecAntiVir) ; http://www.kaspersky.com/scanforvirus
$SAVPanda = GUICtrlCreateMenuItem("&Panda ActiveScan", $SecAntiVir)
$SecMsgSpam = GUICtrlCreateMenuItem("Stop &Messenger Spam", $SecMenu)

_LoaderUpdate(25)
GUICtrlSetOnEvent($SAVFAvira, "_StartAviraAntiVir")
GUICtrlSetOnEvent($SAVFMSSecEss, "_StartSecurityEssentials")
GUICtrlSetOnEvent($SAVFAvast, "_StartAvastAntiVirus")
GUICtrlSetOnEvent($SAVFPanCloud, "_StartPandaCloudAntiVirus")
GUICtrlSetOnEvent($SAVFAVG, "_StartAVGAntiVirus")
GUICtrlSetOnEvent($SecClamWin, "_StartClamWinAntiVirus")
GUICtrlSetOnEvent($SAVEset, "_StartESETOnlineScanner")
GUICtrlSetOnEvent($SAVJotti, "_StartJottiMalwareScan")
GUICtrlSetOnEvent($SAVKaspersky, "_StartKasperskyScanner")
GUICtrlSetOnEvent($SAVPanda, "_StartPandaActiveScan")
GUICtrlSetOnEvent($SecMsgSpam, "_StopMessengerSpam")

_LoaderUpdate(26)
_ConfigureSecurityMenus()

_LoaderUpdate(27)
; ===============================================================================================================================
; Utilities Menu
; ===============================================================================================================================

$UtilMenu = GUICtrlCreateMenu("&Utilities")
$UtNote2 = GUICtrlCreateMenuItem("Notepad&2", $UtilMenu)

_LoaderUpdate(28)
GUICtrlSetOnEvent($UtNote2, "_StartNotepad2")

_LoaderUpdate(29)
; ===============================================================================================================================
; System Menu
; ===============================================================================================================================

$SysMenu = GUICtrlCreateMenu("&System")
$SysLock = GUICtrlCreateMenuItem("&Lock Windows " & @TAB & "Ctrl+Alt+L", $SysMenu)
$SRegEdit = GUICtrlCreateMenuItem("&Registry Editor " & @TAB & "Ctrl+Alt+R", $SysMenu)
$STaskMgr = GUICtrlCreateMenuItem("&Task Manager" & @TAB & "Ctrl+Alt+Del", $SysMenu)
$SsShut = GUICtrlCreateMenu("&Shutdown", $SysMenu)
$SShutdown = GUICtrlCreateMenuItem("&Shutdown", $SsShut)
$SShutPower = GUICtrlCreateMenuItem("&Power Down", $SsShut)
$SSReboot = GUICtrlCreateMenuItem("&Reboot", $SsShut)
$SSLogoff = GUICtrlCreateMenuItem("&Logoff " & @UserName, $SsShut)
$SSHibernate = GUICtrlCreateMenuItem("&Hibernate", $SsShut)
GUICtrlCreateMenuItem("", $SsShut)
$SShutForce = GUICtrlCreateMenuItem("For&ce Shutdown", $SsShut)
$SSRebForce = GUICtrlCreateMenuItem("Forc&e Reboot", $SsShut)

_LoaderUpdate(30)
GUICtrlSetOnEvent($SysLock, "_LockWorkstation")
GUICtrlSetOnEvent($SRegEdit, "_StartRegistryEditor")
GUICtrlSetOnEvent($STaskMgr, "_StartTaskManager")
GUICtrlSetOnEvent($SShutdown, "_Shutdown")
GUICtrlSetOnEvent($SShutPower, "_Shutdown")
GUICtrlSetOnEvent($SSReboot, "_Shutdown")
GUICtrlSetOnEvent($SSLogoff, "_Shutdown")
GUICtrlSetOnEvent($SSHibernate, "_Shutdown")
GUICtrlSetOnEvent($SShutForce, "_Shutdown")
GUICtrlSetOnEvent($SSRebForce, "_Shutdown")

_LoaderUpdate(31)
; ===============================================================================================================================
; Help Menu
; ===============================================================================================================================

$HelpMenu = GUICtrlCreateMenu("&Help")
$HESupport = GUICtrlCreateMenuItem("&Email Support", $HelpMenu)
$HRizHome = GUICtrlCreateMenuItem("&Rizone Home", $HelpMenu)
GUICtrlCreateMenuItem("", $HelpMenu)
$HAbout = GUICtrlCreateMenuItem("&About...", $HelpMenu)

_LoaderUpdate(32)
GUICtrlSetOnEvent($HRizHome, "_AboutHome")
GUICtrlSetOnEvent($HESupport, "_AboutEmail2")
GUICtrlSetOnEvent($HAbout, "_About")

_LoaderUpdate(33)
; ===============================================================================================================================
; Configure Menus
; ===============================================================================================================================

If @OSVersion = "WIN_VISTA" Or @OSVersion = "WIN_2008" Then
	GUICtrlDelete($AdBrCase)
;~ 	GUICtrlSetData($CAPChRemove, "Uninstall or C&hange a Program")
;~ 	GUICtrlSetData($CAPNewPrograms, "Install a Program From the &Network")
;~ 	GUICtrlSetData($CAPWinComp, "Turn &Windows Features On or Off")
;~ 	GUICtrlSetData($CPAutUpdate, "Windows Update")
;~ 	GUICtrlSetData($CPDateTime, "Date and Time")
EndIf

_LoaderUpdate(34)
; ===============================================================================================================================
; Memory Optimization Group
; ===============================================================================================================================

GUICtrlCreateGroup("Memory Optimization", 108, 10, 250, 140)
$MemIcon = GUICtrlCreateIcon($GPowerRes, 2, 118, 25, 48, 48, $SS_NOTIFY)
GuiCtrlSetCursor($MemIcon, 0)
$MemProg = GUICtrlCreateProgress(175, 32, 170, 30)
$LabMemUsage = GUICtrlCreateLabel("1000 MB / 1000 MB - 100%", 118, 73, 200, 14)
GUICtrlSetFont(-1, 10, 800, 0, "")
GUICtrlSetBkColor(-1, 0xEBEBEB)
$PageLabel = GUICtrlCreateLabel("VIRTUAL :", 118, 91, 200, 15)
GUICtrlSetFont(-1, 8.5, 800, 0, "")
$LabPageUsage = GUICtrlCreateLabel("1000 MB / 1000 MB - 100%", 188, 91, 165, 15)
GUICtrlSetBkColor(-1, 0xEBEBEB)
$BtnOptMem = GUICtrlCreateButton("Optimize Memory", 118, 113, 150, 30) ;$BS_DEFPUSHBUTTON)
GuiCtrlSetTip($BtnOptMem, "Windows API call that tells Windows to clean up the workspace " & @CRLF & _
						  "of all processes thus freeing up any memory, processes no longer " & @CRLF & _
						  "needs, instead of forcing the memory out of ram.", "Clear Processes Working Set", 1, 1)
GUICtrlCreateGroup("", -99, -99, 1, 1) ; Close Group

_LoaderUpdate(35)
GUICtrlSetOnEvent($MemIcon, "_ClearProcessesWorkingSet")
GUICtrlSetOnEvent($BtnOptMem, "_ClearProcessesWorkingSet")

_LoaderUpdate(36)
$MemIcoCon = GUICtrlCreateContextMenu($MemIcon)
$MConClrPWorkSet = GUICtrlCreateMenuItem("Optimize Memory", $MemIcoCon)
GUICtrlSetState($MConClrPWorkSet, $GUI_DEFBUTTON)
GUICtrlCreateMenuItem("", $MemIcoCon)
$MConClrSysCache = GUICtrlCreateMenuItem("Clear System Cache...", $MemIcoCon)
$MConProcIdleT = GUICtrlCreateMenuItem("Process Idle Tasks", $MemIcoCon)

_LoaderUpdate(37)
GUICtrlSetOnEvent($MConClrPWorkSet, "_ClearProcessesWorkingSet")
GUICtrlSetOnEvent($MConClrSysCache, "_ClearSystemCache")
GUICtrlSetOnEvent($MConProcIdleT, "_ProcessIdleTasks")

_LoaderUpdate(38)
_GetMemoryStats()

_LoaderUpdate(39)
; ===============================================================================================================================
; Launch Pad Group
; ===============================================================================================================================

Local $iHGap = 368, $iVGap = 5, $iCount = 11, $iSize = 48, $iGap = 5, $lpIcon[$iCount + 1]
GUICtrlCreateGroup("", $iHGap, $iVGap, Ceiling($iCount / 2) * $iSize + (2 + (Ceiling($iCount / 2) + 1) * $iGap), 2 * $iSize + 3 * $iGap + 10)
For $a = 0 To $iCount
	If $a < $iCount / 2 Then
		$lpIcon[$a] = GUICtrlCreateIcon("", -1, $iHGap + $iGap + ($a * $iSize) + ($a * $iGap) + 1, _
									    $iVGap + 2 * $iGap + 2, $iSize, $iSize, $SS_NOTIFY)
	Else
		$b = $a - Ceiling($iCount / 2)
		$lpIcon[$a] = GUICtrlCreateIcon("", -1, $iHGap + $iGap + ($b * $iSize) + ($b * $iGap) + 1, _
									    $iVGap + 3 * $iGap + $iSize + 2, $iSize, $iSize, $SS_NOTIFY)
	EndIf
	GUICtrlSetOnEvent($lpIcon[$a], "_StartLaunchPadApps")
	GuiCtrlSetCursor($lpIcon[$a], 0)
Next
GUICtrlSetImage($lpIcon[0], $GPowerRes, 6)
GUICtrlSetTip($lpIcon[0], "Performs text-based (command-line) " & @CRLF & _
						  "functions.", "Command Prompt", 1, 1)
GUICtrlSetImage($lpIcon[1], $GPowerRes, 7)
GUICtrlSetTip($lpIcon[1], "Provides detailed information about computer performance" & @CRLF & _
						  "and running applications, processes and CPU usage, commit" & @CRLF & _
						  "charge and memory information, network activity and" & @CRLF & _
						  "statistics, logged-in users, and system services.", "Task Manager", 1, 1)
GUICtrlSetImage($lpIcon[2], $GPowerRes, 8)
GUICtrlSetTip($lpIcon[2], "Performs basic arithmetic tasks with " & @CRLF & _
						  "an on-screen calculator.", "Calculator", 1, 1)
GUICtrlSetImage($lpIcon[3], $GPowerRes, 9)
GUICtrlSetTip($lpIcon[3], "Creates and edits text files using basic" & @CRLF & _
						  "text formatting.", "Notepad2", 1, 1)
GUICtrlSetImage($lpIcon[4], $GPowerRes, 10)
GUICtrlSetTip($lpIcon[4], " Run ")
GUICtrlSetImage($lpIcon[5], $GPowerRes, 11)
GUICtrlSetTip($lpIcon[5], "Allows users to view and manipulate basic system settings" & @CRLF & _
						  "and controls via applets, such as adding hardware, " & @CRLF & _
						  "adding and removing software, controlling user accounts," & @CRLF & _
						  "and changing accessibility options.", "Control Panel", 1, 1)
GUICtrlSetImage($lpIcon[6], $GPowerRes, 12)
GUICtrlSetTip($lpIcon[6], "Configure Administrative settings " & @CRLF & _
						  "for your computer.", "Administrative Tools", 1, 1)
GUICtrlSetImage($lpIcon[7], $GPowerRes, 13)
GUICtrlSetImage($lpIcon[8], $GPowerRes, 14)
GUICtrlSetImage($lpIcon[9], $GPowerRes, 15)
GUICtrlSetImage($lpIcon[10], $GPowerRes, 16)
GUICtrlSetImage($lpIcon[11], $GPowerRes, 17)
GUICtrlSetTip($lpIcon[11], "Shutdown your computer. Right-Click for" & @CRLF & _
						   "options to Reboot, Logoff, Power Down or" & @CRLF & _
						   "to activate Hibernation mode.", "Shutdown", 1, 1)
GUICtrlCreateGroup("", -99, -99, 1, 1) ; Close Group

$lPadSEssCn =  GUICtrlCreateContextMenu($lpIcon[8])
$lPSEssCnSt = GuiCtrlCreateMenuItem("Security Essentials", $lPadSEssCn)
GUICtrlSetState($lPSEssCnSt, $GUI_DEFBUTTON)
$lPSECnUpdate = GuiCtrlCreateMenuItem("Update Security Essentials", $lPadSEssCn)

GUICtrlSetOnEvent($lPSEssCnSt, "_StartSecurityEssentials")
GUICtrlSetOnEvent($lPSECnUpdate, "_UpdateSecurityEssentials")

_LoaderUpdate(40)
$lPadShutCon = GUICtrlCreateContextMenu($lpIcon[11])
$lPSLock = GuiCtrlCreateMenuItem("Lock Windows", $lPadShutCon)
GuiCtrlCreateMenuItem("", $lPadShutCon)
$lPSShut = GuiCtrlCreateMenuItem("Shutdown", $lPadShutCon)
GUICtrlSetState(-1, $GUI_DEFBUTTON)
$lPPower = GUICtrlCreateMenuItem("Power Down", $lPadShutCon)
$lPReboot = GUICtrlCreateMenuItem("Reboot", $lPadShutCon)
$lPLogoff = GUICtrlCreateMenuItem("Logoff " & @UserName, $lPadShutCon)
$lPHibernate = GUICtrlCreateMenuItem("Hibernate", $lPadShutCon)
GUICtrlCreateMenuItem("", $lPadShutCon)
$lPShutForce = GUICtrlCreateMenuItem("Force Shutdown", $lPadShutCon)
$lPRebForce = GUICtrlCreateMenuItem("Force Reboot", $lPadShutCon)

_LoaderUpdate(41)
GUICtrlSetOnEvent($lPSLock, "_LockWorkstation")
GUICtrlSetOnEvent($lPSShut, "_Shutdown")
GUICtrlSetOnEvent($lPPower, "_Shutdown")
GUICtrlSetOnEvent($lPReboot, "_Shutdown")
GUICtrlSetOnEvent($lPLogoff, "_Shutdown")
GUICtrlSetOnEvent($lPHibernate, "_Shutdown")
GUICtrlSetOnEvent($lPShutForce, "_Shutdown")
GUICtrlSetOnEvent($lPRebForce, "_Shutdown")

_LoaderUpdate(42)
; ===============================================================================================================================
; Registry Optimization
; ===============================================================================================================================

$BtnOptReg = GUICtrlCreateButton("Registry Optimization", 370, 129, 155, 30, $WS_TABSTOP)
$BtnBackReg = GUICtrlCreateButton("Backup Registry", 530, 129, 155, 30, $WS_TABSTOP)

_LoaderUpdate(43)
GUICtrlSetOnEvent($BtnOptReg, "_OptimizeRegistry")
GUICtrlSetOnEvent($BtnBackReg, "_BackupRegistry")

_LoaderUpdate(44)
If Not FileExists($GQRegDefExe) And Not FileExists($GNTREGOPTEXE) Then GuiCtrlSetState($BtnOptReg, $GUI_DISABLE)

_LoaderUpdate(45)
; ===============================================================================================================================
; Drive Management Group
; ===============================================================================================================================

GUICtrlCreateGroup("Drive Management", 10, 157, 525, 178)
$DrvIcon = GUICtrlCreateIcon($GPowerRes, 5, 20, 170, 64, 64, $SS_NOTIFY)
GuiCtrlSetCursor($DrvIcon, 0)
$HDDCombo = GUICtrlCreateCombo("", 100, 180, 140, 30)
$LHDDNoLa = GUICtrlCreateLabel("Drive:", 20, 225, 63, 14)
$LHDDNo = GUICtrlCreateLabel("", 63, 225, 10, 14)
GUICtrlSetFont($LHDDNoLa, 8.5, 800, 0, "")
GUICtrlSetFont($LHDDNo, 8.5, 800, 0, "")
$LHDDBusLa = GUICtrlCreateLabel("BUS:", 20, 240, 53, 14)
GUICtrlSetFont($LHDDBusLa, 8.5, 800, 0, "")
GUICtrlSetColor($LHDDBusLa, 0x4051A0)
$LHDDBus = GUICtrlCreateLabel("", 53, 240, 50, 14)
GUICtrlSetFont($LHDDBus, 8.5, 800, 0, "")
GUICtrlSetColor($LHDDBus, 0x4051A0)
$PHDDFree = GUICtrlCreateProgress(100, 205, 140, 25)
GUICtrlCreateLabel("File System:", 250, 170, 100, 14)
GUICtrlSetColor(-1, 0x0046D5)
$LHDFS = GUICtrlCreateLabel("NTFS", 345, 170, 80, 14)
GUICtrlCreateLabel("Capacity:", 250, 185, 100, 14)
GUICtrlSetColor(-1, 0x0046D5)
$LHDCAP = GUICtrlCreateLabel("1000.00 GB", 345, 185, 80, 14)
GUICtrlCreateLabel("Free Space:", 250, 200, 100, 14)
GUICtrlSetColor(-1, 0x0046D5)
$LHDFREE = GUICtrlCreateLabel("1000.00 GB", 345, 200, 80, 14)
GUICtrlCreateLabel("% Free Space:", 250, 215, 100, 14)
GUICtrlSetColor(-1, 0x0046D5)
$LHDPFREE = GUICtrlCreateLabel("100%", 345, 215, 80, 14)
$HDDDMethod = GUICtrlCreateCombo("", 100, 235, 320, 30)
GUICtrlSetData($HDDDMethod, "Analyze Only|" & _
							"Defragment Only|" & _
							"Defragment and Fast Optimize|" & _
							"Force Together|" & _
							"Move to end of Disk|" & _
							"Optimize Files by Name (Folder + Filename)|" & _
							"Optimize Files by Size (Smallest First)|" & _
							"Optimize Files by Last Access (Newest First)|" & _
							"Optimize Files by Last Change (Oldest First)|" & _
							"Optimize Files by Creation Time (Oldest First)|", _
							"Defragment and Fast Optimize")
$BHDFormat = GUICtrlCreateButton("Format...", 425, 185, 100, 30)
$BHDDRun = GUICtrlCreateButton("Run", 425, 230, 100, 30)
GUICtrlSetFont($BHDDRun, 8.5, 800, 0, "")
$BHDDGeom = GUICtrlCreateButton("Geometry...", 20, 260, 100, 30)
$BHDChkDsk = GUICtrlCreateButton("Check Disk...", 120, 260, 120, 30)
$CkHDFixed = GUICtrlCreateCheckbox("Select all fixed Drives", 250, 265, 150, 20)
$BHDDLegend = GUICtrlCreateButton("Legend...", 425, 260, 100, 30)
GUICtrlSetTip($BHDDLegend, "Shows you what all those pretty colors represent " & @CRLF & _
						   "when you defrag your drives.", "JkDefrag Legend", 1, 1)
GUICtrlCreateGroup("", -99, -99, 1, 1) ; Close Group

_LoaderUpdate(46)
GUICtrlSetOnEvent($BHDFormat, "_FormatSelectedDrive")
GUICtrlSetOnEvent($BHDDRun, "_DefragDrive")
GUICtrlSetOnEvent($BHDDGeom, "_DriveGeometryDialog")
GUICtrlSetOnEvent($BHDChkDsk, "_CheckDiskGUI")
GUICtrlSetOnEvent($CkHDFixed, "_SelectAllFixedDisksDefrag")
GUICtrlSetOnEvent($BHDDLegend, "_ShowJKLegend")

_LoaderUpdate(47)
$DrvManCon = GUICtrlCreateContextMenu($DrvIcon)
$DMCnOpen = GUICtrlCreateMenuItem("Open", $DrvManCon)
GUICtrlSetState($DMCnOpen, $GUI_DEFBUTTON)
$DMCnExplore = GUICtrlCreateMenuItem("Explore", $DrvManCon)
GUICtrlCreateMenuItem("", $DrvManCon)
$DMCnDskMng = GUICtrlCreateMenuItem("Disk Management", $DrvManCon)
$DMCnCDisk = GUICtrlCreateMenuItem("Check Disk...", $DrvManCon)
$DMCnDClean = GUICtrlCreateMenuItem("Disk Cleanup", $DrvManCon)
$DMCnWinFrag = GUICtrlCreateMenuItem("Disk Defragmenter", $DrvManCon)
$DMCnPartMan = GUICtrlCreateMenuItem("Partition Manager", $DrvManCon)
GUICtrlCreateMenuItem("", $DrvManCon)
$DMCnFormat = GUICtrlCreateMenuItem("Format...", $DrvManCon)

_LoaderUpdate(48)
GUICtrlSetOnEvent($DrvIcon, "_OpenSelectedDrive")
GUICtrlSetOnEvent($DMCnOpen, "_OpenSelectedDrive")
GUICtrlSetOnEvent($DMCnExplore, "_ExploreSelectedDrive")
GUICtrlSetOnEvent($DMCnDskMng, "_StartDiskManagement")
GUICtrlSetOnEvent($DMCnCDisk, "_CheckDiskGUI")
GUICtrlSetOnEvent($DMCnDClean, "_StartDiskCleanup")
GUICtrlSetOnEvent($DMCnWinFrag, "_StartWindowsDefrag")
GUICtrlSetOnEvent($DMCnPartMan, "_StartPartitionManager")
GUICtrlSetOnEvent($DMCnFormat, "_FormatSelectedDrive")

_LoaderUpdate(49)
_FillInHDDComboBox()
_SetDiskInformation()

_LoaderUpdate(50)
; ===============================================================================================================================
; Online AntiVirus Scanners Group
; ===============================================================================================================================

GUICtrlCreateGroup("AntiVirus Scanners", 543, 167, 150, 90)
$AVIcon1 = GUICtrlCreateIcon($GPowerRes16, 1, 550, 190, 16, 16, $SS_NOTIFY)
GuiCtrlSetCursor($AVIcon1, 0)
$AVLb1 = GuiCtrlCreateLabel("ESET Scanner", 570, 190, 120, 16, $SS_NOTIFY)
GuiCtrlSetFont($AVLb1, 8.5, -1, 4) ;Underlined
GuiCtrlSetColor($AVLb1, 0x0000FF)
GuiCtrlSetCursor($AVLb1, 0)
GuiCtrlSetTip($AVLb1, "A user friendly, free and powerful tool which you can use to remove " & @CRLF & _
					  "malware from any PC utilizing only your web browser without having " & @CRLF & _
					  "to install anti-virus software. ESET Online Scanner uses the same " & @CRLF & _
					  "ThreatSense® technology and signatures as ESET NOD32 Antivirus, " & @CRLF & _
					  "and is always up-to-date.", "ESET Online Scanner", 1, 1)
$AVIcon2 = GUICtrlCreateIcon($GPowerRes16, 2, 550, 210, 16, 16, $SS_NOTIFY)
GuiCtrlSetCursor($AVIcon2, 0)
$AVLb2 = GuiCtrlCreateLabel("Panda ActiveScan", 570, 210, 120, 16, $SS_NOTIFY)
GuiCtrlSetFont($AVLb2, 8.5, -1, 4) ;Underlined
GuiCtrlSetColor($AVLb2, 0x0000FF)
GuiCtrlSetCursor($AVLb2, 0)
GuiCtrlSetTip($AVLb2, "An advanced online scanner based on Collective Intelligence " & @CRLF & _
					  "(scanning in-the-cloud) that detects malware that traditional " & @CRLF & _
					  "security solutions cannot detect.", "Panda ActiveScan", 1, 1)
$AVIcon3 = GUICtrlCreateIcon($GPowerRes16, 3, 550, 230, 16, 16, $SS_NOTIFY)
GuiCtrlSetCursor($AVIcon3, 0)
$AVLb3 = GuiCtrlCreateLabel("Jotti's Scan", 570, 230, 120, 16, $SS_NOTIFY)
GuiCtrlSetFont($AVLb3, 8.5, -1, 4) ;Underlined
GuiCtrlSetColor($AVLb3, 0x0000FF)
GuiCtrlSetCursor($AVLb3, 0)
GuiCtrlSetTip($AVLb3, "Jotti's malware scan is a free online service that enables you " & @CRLF & _
					  "to scan suspicious files with several anti-virus programs.", _
					  "Panda ActiveScan", 1, 1)
GUICtrlCreateGroup("", -99, -99, 1, 1) ; Close Group

_LoaderUpdate(51)
GUICtrlSetOnEvent($AVIcon1, "_StartESETOnlineScanner")
GUICtrlSetOnEvent($AVLb1, "_StartESETOnlineScanner")
GUICtrlSetOnEvent($AVIcon2, "_StartPandaActiveScan")
GUICtrlSetOnEvent($AVLb2, "_StartPandaActiveScan")
GUICtrlSetOnEvent($AVIcon3, "_StartJottiMalwareScan")
GUICtrlSetOnEvent($AVLb3, "_StartJottiMalwareScan")

_LoaderUpdate(52)
; ===============================================================================================================================
; Recycle Bin Group
; ===============================================================================================================================

GUICtrlCreateGroup("Recycle Bin", 543, 265, 150, 145)
$RecIcon = GUICtrlCreateIcon($GPowerRes, 3, 638, 285, 48, 48, BitOR($SS_NOTIFY,$WS_GROUP))
GUICtrlSetTip($RecIcon, "Open the Recycle Bin. Right-Click" & @CRLF & _
						"for more options.", "Recycle Bin", 1, 1)
GuiCtrlSetCursor($RecIcon, 0)
$LBinSize = GUICtrlCreateLabel("0 MB", 558, 290, 80, 17)
GUICtrlSetFont(-1, 8.5, 800, 0, "Verdana")
$LBinItems = GUICtrlCreateLabel("0 Objects", 558, 310, 80, 17)
$BtnBinEm = GUICtrlCreateButton("Clean Bin", 553, 340, 130, 30)
$BtnDClean = GUICtrlCreateButton("Disk Cleanup", 553, 370, 130, 30)
GUICtrlCreateGroup("", -99, -99, 1, 1) ; Close Group

_LoaderUpdate(53)
GUICtrlSetOnEvent($RecIcon, "_OpenRecycleBin")
GUICtrlSetOnEvent($BtnBinEm, "_EmptyRecycleBin")
GUICtrlSetOnEvent($BtnDClean, "_StartDiskCleanup")

_LoaderUpdate(54)
$RecBinCon	= GUICtrlCreateContextMenu($RecIcon)
$RBConOpen = GuiCtrlCreateMenuItem("Open", $RecBinCon)
$RBConExplore = GuiCtrlCreateMenuItem("Explore", $RecBinCon)
GUICtrlSetState($RBConOpen, $GUI_DEFBUTTON)
$RBConEmp = GuiCtrlCreateMenuItem("Empty Recycle Bin", $RecBinCon)
GuiCtrlCreateMenuItem("", $RecBinCon)
$RBConProp = GuiCtrlCreateMenuItem("Properties...", $RecBinCon)

_LoaderUpdate(55)
GUICtrlSetOnEvent($RBConOpen, "_OpenRecycleBin")
GUICtrlSetOnEvent($RBConExplore, "_ExploreRecycleBin")
GUICtrlSetOnEvent($RBConEmp, "_EmptyRecycleBin")
GUICtrlSetOnEvent($RBConProp, "_OpenRecycleBinProperties")

_LoaderUpdate(56)
_RefreshRecycleBin()
_LoaderUpdate(57)
_CheckRecycleBinEmpty()

_LoaderUpdate(58)
; ===============================================================================================================================
; General Buttons
; ===============================================================================================================================

$BtnOpenLog = GUICtrlCreateButton("O...", 540, 417, 35, 30)
$BtnClose = GUICtrlCreateButton("Close", 580, 417, 115, 30)

_LoaderUpdate(59)
GUICtrlSetOnEvent($BtnOpenLog, "_OpenPowerLog")
GUICtrlSetOnEvent($BtnClose, "_PowerCLosedClicked")

_LoaderUpdate(60)
; ===============================================================================================================================
; Status Bar
; ===============================================================================================================================

$hStatus = _GUICtrlStatusBar_Create ($PowerForm)
_GUICtrlStatusBar_SetParts ($hStatus, $aParts)
_GUICtrlStatusBar_SetText($hStatus, "", 0)
_GUICtrlStatusBar_SetMinHeight($hStatus, 20)
_GUICtrlStatusBar_SetText ($hStatus, _GetOSFullVersion())

_LoaderUpdate(61)
_SetStatusBarStuff()

_LoaderUpdate(62)
; ===============================================================================================================================
; Tray Menu
; ===============================================================================================================================

;~ $TMinimize  = TrayCreateItem("Minimize")
;~ $TClose  = TrayCreateItem("Close")

;~ TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "_MinimizeClicked")
;~ TrayItemSetOnEvent($TMinimize, "_MinimizeClicked")
;~ TrayItemSetOnEvent($TClose, "_PowerCLosedClicked")

_LoaderUpdate(63)
#include <Modules\mGeneral.au3>
#include <Modules\mAdministration.au3>
#include <Modules\mDriveManagement.au3>
#include <Modules\mMaintenance.au3>
#include <Modules\mOptimize.au3>
#include <Modules\mRepair.au3>
#include <Modules\mSecurity.au3>
#include <Modules\mSystem.au3>
#include <Modules\mHelp.au3>

#include <Modules\MOD_ControlPanel.au3>
#include <Modules\MOD_Directories.au3>
#include <Modules\MOD_Accessories.au3>
#include <Modules\MOD_Utilities.au3>
#include <Modules\MOD_Command.au3>

#include <Modules\MOD_File.au3>

_LoaderUpdate(64)
GUISetOnEvent($GUI_EVENT_CLOSE, "_PowerCLosedClicked")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "_PowerMinimizeClicked")
GUISetOnEvent($GUI_EVENT_RESTORE, "_PowerMinimizeClicked")
GUISetState(@SW_SHOW, $PowerForm)

TraySetClick(8)
TraySetState(1)

_LoaderUpdate(65)
; ===============================================================================================================================
; Set Hotkeys
; ===============================================================================================================================

If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_2003" Then HotKeySet("{F2}", "_VistaRename")
HotKeySet("^1", "_ClearClipboard")
HotKeySet("^!o", "_ClearProcessesWorkingSet")
HotKeySet("^!c", "_ClearSystemCache")
HotKeySet("^!i", "_ProcessIdleTasks")
HotKeySet("^!f", "_FlushFileCache")
HotKeySet("^!l", "_LockWorkstation")
HotKeySet("^!r", "_StartRegistryEditor")

Local $MemTimer = 0
Local $GTimer = 0
Local $G2Timer = 0

_LoaderUpdate(100)

While 1
	If TimerDiff($MemTimer) >= 2500 Then
		_GetMemoryStats()
		$MemTimer = TimerInit()
	EndIf
	If TimerDiff($GTimer) >= 200 Then
		_SetDiskInformation()
		$GTimer = TimerInit()
	EndIf
	If TimerDiff($G2Timer) >= 500 Then
		_SetStatusBarStuff()
		_RefreshRecycleBin()
		; _ReduceMemory(@AutoItPID)
		$G2Timer = TimerInit()
	EndIf
	Sleep(50) ; Idle
WEnd

Func _PowerCLosedClicked()
	TraySetState(2)
	;GUIDelete($PowerForm)
	$PID = ProcessExists($Process) ; Will return the PID or 0 if the process isn't found.
		If $PID Then ProcessClose($PID)
	Exit
EndFunc

;~ Func _MinimizeClicked()
;~ 	If $HideOnMinimize = 1 Then
;~ 		_HideShowMainForm()
;~ 	Else
;~ 		If TrayItemGetText($TMinimize) = "Minimize" Then
;~ 			TrayItemSetText($TMinimize, "Restore")
;~ 			GUISetState(@SW_MINIMIZE, $PowerForm)
;~ 		Else
;~ 			TrayItemSetText($TMinimize, "Minimize")
;~ 			GUISetState(@SW_RESTORE, $PowerForm)
;~ 		EndIf
;~ 	EndIf
;~ EndFunc

;~ Func _PowerMinimizeClicked()
;~ 	If $HideOnMinimize = 1 Then
;~ 		_HideShowMainForm()
;~ 	Else
;~ 		If TrayItemGetText($TMinimize) = "Minimize" Then
;~ 			TrayItemSetText($TMinimize, "Restore")
;~ 		Else
;~ 			TrayItemSetText($TMinimize, "Minimize")
;~ 		EndIf
;~ 	EndIf
;~ EndFunc

;~ Func _HideShowMainForm()
;~ 	If TrayItemGetText($TMinimize) = "Minimize" Then
;~ 		GUISetState(@SW_HIDE, $PowerForm)
;~ 		TrayItemSetText($TMinimize, "Show")
;~ 		TrayTip($PowerTitle & " is still running.", $PowerTitle & " will continue to run so that you can receive alerts. " & _
;~ 													"To restore the main window, double-click on this icon or right click and " & _
;~ 													"choose 'Show' from the context menu. ", 10, 1)
;~ 	Else
;~ 		GUISetState(@SW_SHOW, $PowerForm)
;~ 		GUISetState(@SW_RESTORE, $PowerForm)
;~ 		TrayItemSetText($TMinimize, "Minimize")
;~ 	EndIf
;~ EndFunc

; ===============================================================================================================================
; Memory Functions
; ===============================================================================================================================

Func _GetMemoryStats()
	Sleep(7)
	$MemStats = MemGetStats()
	Sleep(7)
	For $i = 1 To 6
		$MemStats[$i] = Round($MemStats[$i] / 1024)
	Next
	Sleep(7)
	$MemUsage = $MemStats[1] - $MemStats[2]
	$PageUsage = $MemStats[3] - $MemStats[4]
	$PagePerc = Round($PageUsage * 100 / $MemStats[3])
	Sleep(7)
	If $MemUsage <> $MemUsDiff Then GUICtrlSetData($LabMemUsage, $MemUsage & " MB / " & $MemStats[1] & " MB - " & $MemStats[0] & "%")
	If $MemStats[0] <> $MemPrDiff Then GUICtrlSetData($MemProg, $MemStats[0])
	If $PageUsage <> $PageDiff Then GUICtrlSetData($LabPageUsage, $PageUsage & " MB / " & $MemStats[3] & " MB - " & $PagePerc & "%")
	Sleep(7)
	$MemUsDiff = $MemUsage
	$MemPrDiff = $MemStats[0]
	$PageDiff = $PageUsage
	Sleep(7)
EndFunc ; ==> _GetMemoryStats

; ===============================================================================================================================
; Launch Pad Functions
; ===============================================================================================================================

Func _StartLaunchPadApps()
	Switch @GUI_CtrlId
		Case $lpIcon[0]
			_StartCommandPrompt()
		Case $lpIcon[1]
			_StartTaskManager()
		Case $lpIcon[2]
			_StartCalculator()
		Case $lpIcon[3]
			_StartNotepad2()
		Case $lpIcon[4]
		Case $lpIcon[5]
			_StartControlPanel()
		Case $lpIcon[6]
			_StartAdminTools()
		Case $lpIcon[7]
			_StartClamWinAntiVirus()
		Case $lpIcon[8]
			_StartSecurityEssentials()
		Case $lpIcon[9]
			_StartDeadPixelRepair()
		Case $lpIcon[10]
			_StartRegistryEditor()
		Case $lpIcon[11]
			_Shutdown()
	EndSwitch
EndFunc

; ===============================================================================================================================
; Drive Management Functions
; ===============================================================================================================================

Func _FillInHDDComboBox()
	If $GDRIVES[0] > 0 Then
		For $i = 1 to $GDRIVES[0]
			If DriveStatus($GDRIVES[$i]) = "READY" Then
				If DriveGetType($GDRIVES[$i]) = "FIXED" Then ;Or DriveGetType($GDRIVES[$i]) = "REMOVABLE" Then
					If DriveGetLabel($GDRIVES[$i]) <> "" Then
						GUICtrlSetData($HDDCombo, StringUpper($GDRIVES[$i]) & " [" & DriveGetLabel($GDRIVES[$i]) & "]" & "|", _SetHomeDriveAsDefault(@HomeDrive))
					Else
						GUICtrlSetData($HDDCombo, StringUpper($GDRIVES[$i]) & "|", _SetHomeDriveAsDefault(@HomeDrive))
					EndIf
				EndIf
			EndIf
		Next
	EndIf
EndFunc

Func _SetHomeDriveAsDefault($DRVDefault)
	If DriveGetLabel($DRVDefault) <> "" Then
		Return $DRVDefault & " [" & DriveGetLabel($DRVDefault) & "]"
	Else
		Return $DRVDefault
	EndIf
EndFunc

Func _SetDiskInformation()
	Local $LHDDSelect = StringLeft(GUICtrlRead($HDDCombo), 2)
	Local $HDDUsSpace = DriveSpaceTotal($LHDDSelect) - DriveSpaceFree($LHDDSelect)

	If $LHDDSelect <> $GDRIVESELECTED Then
		_SetDiskInfo($LHDDSelect, $HDDUsSpace)
	EndIf
	$GDRIVESELECTED = $LHDDSelect
EndFunc

Func _SetDiskInfo($LHDDSelect, $HDDUsSpace)
	Local $tSTORAGEDEVICENUMBER

	$tSTORAGEDEVICENUMBER = _WinAPI_GetDriveNumber($LHDDSelect)
	$GDRIVENUMBER = DllStructGetData($tSTORAGEDEVICENUMBER, 'DeviceNumber')

	GuiCtrlSetData($LHDDNo, DllStructGetData($tSTORAGEDEVICENUMBER, 'DeviceNumber'))
	GuiCtrlSetData($LHDDBus, _GetDriveBusType($LHDDSelect))
	GuiCtrlSetData($PHDDFree, Round($HDDUsSpace * 100 / DriveSpaceTotal($LHDDSelect)))
	GuiCtrlSetData($LHDFS, DriveGetFileSystem($LHDDSelect))
	GuiCtrlSetData($LHDCAP, Round(DriveSpaceTotal($LHDDSelect) / 1024, 2) & " GB")
	GuiCtrlSetData($LHDFREE, Round(DriveSpaceFree($LHDDSelect) / 1024, 2) & " GB")
	GuiCtrlSetData($LHDPFREE, Round(DriveSpaceFree($LHDDSelect) * 100 / DriveSpaceTotal($LHDDSelect)) & "%")

EndFunc

Func _SelectAllFixedDisksDefrag()
	Local $LHDD = StringLeft(GUICtrlRead($HDDCombo), 2)
	Local $HDDUsed = DriveSpaceTotal($LHDD) - DriveSpaceFree($LHDD)
	Local $AllDCAP = 0, $ALLPHDDUsed = 0, $ALLHDDFree = 0

	If GUICtrlRead($CkHDFixed) = 1 Then
		GUICtrlSetState($HDDCombo, $GUI_DISABLE)
		GuiCtrlSetData($LHDFS, "N/A")
		For $i = 1 To $GDRIVES[0]
			$AllDCAP += DriveSpaceTotal($GDRIVES[$i])
			$ALLPHDDUsed += DriveSpaceTotal($GDRIVES[$i]) - DriveSpaceFree($GDRIVES[$i])
			$ALLHDDFree += DriveSpaceFree($GDRIVES[$i])
		Next
		GUICtrlSetData($LHDCAP, Round($AllDCAP / 1024, 2) & " GB")
		GuiCtrlSetData($PHDDFree, Round($ALLPHDDUsed * 100 / $AllDCAP, 2))
		GuiCtrlSetData($LHDFREE, Round($ALLHDDFree / 1024, 2) & " GB")
		GuiCtrlSetData($LHDPFREE, Round($ALLHDDFree * 100 / $AllDCAP) & "%")
	Else
		GUICtrlSetState($HDDCombo, $GUI_ENABLE)
		_SetDiskInfo($LHDD, $HDDUsed)
	EndIf
EndFunc

; ===============================================================================================================================
; Recycle Bin Functions
; ===============================================================================================================================

; Global $SHQUERYRBINFO = DllStructCreate("int;int64;int64") ; v3.2.8.1
; Global $SHQUERYRBINFO = DllStructCreate("align 1;int;int64;int64") ; v3.2.11.3
; DllStructSetData($SHQUERYRBINFO, 1, DllStructGetSize($SHQUERYRBINFO))
; $Query = DllCall("shell32.dll", "int", "SHQueryRecycleBin", "str", "C:\", "ptr", DllStructGetPtr($SHQUERYRBINFO))
; ConsoleWrite("DllCall return value is: " & $Query[0] & @LF)
; ConsoleWrite(DllStructGetData($SHQUERYRBINFO, 1) & @LF & _ ; "cbSize" size of the struct = 20
; 			   DllStructGetData($SHQUERYRBINFO, 2) & @LF & _ ; size of recycle bin in bytes
; 			   DllStructGetData($SHQUERYRBINFO, 3) & @LF)    ; number of items in recycle bin
Func _RefreshRecycleBin()
	DllStructSetData($SHQUERYRBINFO, 1, DllStructGetSize($SHQUERYRBINFO))
	$Query = DllCall("shell32.dll", "int", "SHQueryRecycleBin", "str", "", "ptr", DllStructGetPtr($SHQUERYRBINFO))
	If DllStructGetData($SHQUERYRBINFO, 2) <> $GLRBINSIZE Or _
	   DllStructGetData($SHQUERYRBINFO, 3) <> $GLRBINITEMS Then
		GUICtrlSetData($LBinSize, _ConvertBytesTable(DllStructGetData($SHQUERYRBINFO, 2)))
		GUICtrlSetData($LBinItems, DllStructGetData($SHQUERYRBINFO, 3) & " Objects")
		If DllStructGetData($SHQUERYRBINFO, 2) <> 0 Or _
		   DllStructGetData($SHQUERYRBINFO, 3) Then
			GUICtrlSetState($MnRecBEmp, $GUI_ENABLE)
			GUICtrlSetState($BtnBinEm, $GUI_ENABLE)
			GUICtrlSetState($RBConEmp, $GUI_ENABLE)
			GUICtrlSetImage($RecIcon, $GPowerRes, 4)
			;$RBINEMPTY = 0
		Else
			GUICtrlSetState($MnRecBEmp, $GUI_DISABLE)
			GUICtrlSetState($BtnBinEm, $GUI_DISABLE)
			GUICtrlSetState($RBConEmp, $GUI_DISABLE)
			GUICtrlSetImage($RecIcon, $GPowerRes, 3)
			;$RBINEMPTY = 1
		EndIf
	EndIf
	$GLRBINSIZE = DllStructGetData($SHQUERYRBINFO, 2)
	$GLRBINITEMS = DllStructGetData($SHQUERYRBINFO, 3)
EndFunc ; ==> _RefreshRecycleBin

Func _CheckRecycleBinEmpty()
	If $GLRBINSIZE <> 0 Or _
	   $GLRBINITEMS <> 0 Then
		GUICtrlSetState($MnRecBEmp, $GUI_ENABLE)
		GUICtrlSetState($BtnBinEm, $GUI_ENABLE)
		GUICtrlSetState($RBConEmp, $GUI_ENABLE)
	Else
		GUICtrlSetState($MnRecBEmp, $GUI_DISABLE)
		GUICtrlSetState($BtnBinEm, $GUI_DISABLE)
		GUICtrlSetState($RBConEmp, $GUI_DISABLE)
	EndIf
EndFunc

; ===============================================================================================================================
; Status Bar Functions
; ===============================================================================================================================

Func _SetStatusBarStuff()
	$CurrentTime = _Date_Time_GetLocalTime()
	If $GMinute <> @MIN Then
		_GUICtrlStatusBar_SetText ($hStatus, @HOUR & ":" & @MIN & " " & _GetAMPM(@HOUR) & " - " & _
		_DateDayOfWeek(@WDAY) & " " & @MDAY & " " & _DateToMonth(@MON) & " " & @YEAR, 1)
	EndIf
	$GMinute = @MIN
EndFunc

Func _MemoLogWrite($Message = "", $iWarning = 0, $iTimeStamp = 1, $iToMemo = 1, $iToFile = 1)

	Local $sPrefix = ""
	Local $sTStamp = ""
	Local $OpenLog

	If $iTimeStamp = 1  Then $sTStamp = "[" & @HOUR & ":" & @MIN & "] "
	If $iToMemo = 1 Then
		Select
			Case $iWarning = 1 ; Success
				GUICtrlSetBkColor($eStatus, 0xC1DCfC)
			Case $iWarning = 2 ; Error
				GUICtrlSetBkColor($eStatus, 0xEFD6E1)
				$sPrefix = "ERROR: "
			Case $iWarning = 3 ; Warning
				GUICtrlSetBkColor($eStatus, 0xF4FFD4)
		EndSelect
		Sleep(10)

		_GUICtrlEdit_AppendText($eStatus, $Message & @CRLF)
	EndIf

	If $iToFile = 1 Then
		$OpenLog = FileOpen($GPowerLog, 1)

		If $OpenLog = -1 Then
			;_GUICtrlEdit_AppendText($eStatus, "The status could not be written to the log file, make sure the " & _
											;$GPowerLog & " directory is not write protected." & @CRLF)
			;GUICtrlSetBkColor($eStatus, 0xEFD6E1)
		EndIf

		FileWrite($OpenLog, $sTStamp & $sPrefix & $Message & @CRLF)
		FileClose($OpenLog)

	EndIf

EndFunc

Func _BootMessage()
	If Not IsDeclared("MBOX") Then Local $MBox
	If $GRBREQ = 1 Then
		_SecBootMessage()
	Else
		$GRBREQ = 1
		$MBox = MsgBox(65,"Reboot required!","You will need to reboot your computer before the settings will take effect. " & _
								   "Answer 'OK' to reboot your computer or 'Cancel' if you would like to reboot later. " & _
								   "Note that some settings might not take effect or some components might not function correctly until you reboot." & @CRLF & @CRLF & _
								   "Your computer will reboot automatically in 60 seconds.",60)
								   _MemoLogWrite("You will need to reboot your computer before the settings will take effect.", 3)
		If $MBox = 1 Or $MBox = -1 Then Shutdown(18)
	EndIf
EndFunc


Func _SecBootMessage()
	If Not IsDeclared("MBOX") Then Local $MBox
	$MBox = MsgBox(49,"Reboot required!","Previous changes to your computer detected. " & _
					  "You will need to reboot your computer before you can make any further changes. " & _
					  "Answer 'OK' to reboot your computer or 'Cancel' if you would like to reboot later. " & _
					  "Note that some settings might not take effect or some components might not function correctly until you reboot." & @CRLF & @CRLF & _
					  "Your computer will reboot automatically in 60 seconds.",60)
					  _MemoLogWrite("Previous changes to your computer detected.", 3)
					  _MemoLogWrite("Please Reboot before making any further changes.", 3)
	If $MBox = 1 Or $MBox = -1 Then Shutdown(18)
EndFunc

Func _DisableControls()
	GUICtrlDelete($PowIcon)
	GUISwitch($PowerForm)
	$GPowAni = GUICtrlCreateIcon(@ScriptDir & "\Themes\Process.ani", -1, 26, 17, 50, 50)
	WinSetState($PowerForm, "", @SW_DISABLE)
EndFunc

Func _EnableControls()
	WinSetState($PowerForm, "", @SW_ENABLE)
	GUICtrlDelete($GPowAni)
	$PowIcon = GUICtrlCreateIcon($GPowerRes, 1, 19, 10, 64, 64, $SS_NOTIFY)
	GuiCtrlSetCursor($PowIcon, 0)
	WinActivate($PowerForm)
EndFunc
