#NoTrayIcon
#RequireAdmin

#AutoIt3Wrapper_Version=beta
#AutoIt3Wrapper_icon=WinPower.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Rizone's Power Tools
#AutoIt3Wrapper_Res_Fileversion=0.0.0.267
#AutoIt3Wrapper_Res_LegalCopyright=© 2009 Rizone Technologies
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y

#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <GUIConstants.au3>
#Include <Clipboard.au3>
#include <Misc.au3>
#include <Busy.au3>
#include "UDF\ModernMenu.au3" ; Only unknown constants are declared here
#include "UDF\Functions.au3"

;Opt("OnExitFunc", "_Closing")

Global $ATITLE = "Rizone's Power Tools", $AVER = FileGetVersion(@ScriptDir & "\" & @ScriptName)
Global $PLOG = @ScriptDir & "\Logging\Power.log"
Global $PRES = @ScriptDir & "\Powermres.dll"
Global $RREQ = 0, $eStatus

If @OSVersion = "WIN_2000" Then
	If Not IsDeclared("BAnswer") Then Local $BAnswer
	$BAnswer = MsgBox(64, $ATITLE, "This utility is not compatable with your version of windows. " & _
								   "If you believe this to be an error, please feel free to email me at " & _
								   "rizonetech@gmail.com will all the details.", 30)
	Exit
EndIf

If _Singleton(@ScriptName, 1) = 0 Then
	If Not IsDeclared("BAnswer") Then Local $BAnswer
	$BAnswer = MsgBox(262192, "Warning", "An occurence of " & $ATITLE & " is already running.", 30)
	Exit
EndIf

Global $WLDir = @ProgramFilesDir & "\Windows Live"

;_ReduceMemory(@AutoItPID)

If Round(FileGetSize($PLOG), -1) > 1 Then
	If FileExists($PLOG) Then
		_ClearFileAttributes($PLOG)
		FileDelete($PLOG)
	EndIf
Else
	_ClearFileAttributes($PLOG)
EndIf

;$ACCalc = _GUICtrlCreateODMenuItem("&Calculator", $MAcc, $PRES, -9)
;~ $ACCharMap = _GUICtrlCreateODMenuItem("C&haracter Map", $MAcc, $PRES, -11)
;~ $ACCommand = _GUICtrlCreateODMenuItem("Command P&rompt", $MAcc, $PRES, -12)
;~ $ACIEX = _GUICtrlCreateODMenuItem("IExpress &SFX Wizard", $MAcc, $PRES, -45)
;~ ; Internet Explorer Menu
;~ $ACIExp = _GUICtrlCreateODMenu("Internet &Explorer", $MAcc, $PRES, -46)
;~ $IEIntE = _GUICtrlCreateODMenuItem("Internet &Explorer " & FileGetVersion(@ProgramFilesDir & "\Internet Explorer\iexplore.exe"), $ACIExp, $PRES, -46)
;~ $IESett = _GUICtrlCreateODMenuItem("Internet &Properties", $ACIExp, $PRES, -65)
;~ ; ==> Internet Explorer Menu
;~ $ACMRT = _GUICtrlCreateODMenuItem("Malicious Software Remo&val (" & _GetProgramVersion(@SystemDir & "\mrt.exe", 2) & ")", $MAcc, $PRES, -70)
;~ $ACPaint = _GUICtrlCreateODMenuItem("Microsoft &Paint", $MAcc, $PRES, -47)
;~ ; Multimedia Menu
;~ $ACMedia = _GUICtrlCreateODMenu("Multimedia", $MAcc, $PRES, -54)
;~ $MMPlay6 = _GUICtrlCreateODMenuItem("Windows Media &Player " & FileGetVersion(@ProgramFilesDir & "\Windows Media Player\mplayer2.exe"), $ACMedia, $PRES, -48)
;~ $MMPlay = _GUICtrlCreateODMenuItem("Windows &Media Player " & FileGetVersion(@ProgramFilesDir & "\Windows Media Player\wmplayer.exe"), $ACMedia, $PRES, -49)
;~ _GUICtrlCreateODMenuItem("", $ACMedia)
;~ $MDVDPlay = _GUICtrlCreateODMenuItem("&DVD Player", $ACMedia, $PRES, -56)
;~ $MInsCodec = _GUICtrlCreateODMenuItem("&Install DVD Decoders", $ACMedia, $PRES, -55)
;~ _GUICtrlCreateODMenuItem("", $ACMedia)
;~ $MSndRec = _GUICtrlCreateODMenuItem("&Sound Recorder", $ACMedia, $PRES, -50)
;~ ; ==> Multimedia Menu
;~ $ACNote = _GUICtrlCreateODMenuItem("&Notepad", $MAcc, $PRES, -51)
;~ $ACObPack = _GUICtrlCreateODMenuItem("&Object Packager", $MAcc, $PRES, -52)
;~ $ACExplore = _GUICtrlCreateODMenuItem("Windows E&xplorer", $MAcc, $PRES, -53)
;~ ; Windows Live Menu
;~ $ACLive = _GUICtrlCreateODMenu("Windows &Live", $MAcc, $PRES, -68)
;~ $WLHome = _GUICtrlCreateODMenuItem("Windows Live &Home", $ACLive, $PRES, -68)
;~ _GUICtrlCreateODMenuItem("", $ACLive)
;~ $WLSkyDrive = _GUICtrlCreateODMenuItem("Windows Live Calenda&r (Online)", $ACLive, $PRES, -76)
;~ $WLCall = _GUICtrlCreateODMenuItem("Windows Live &Call (" & _GetProgramVersion($WLDir & "\Messenger\wlcstart.exe", 3) & ")", $ACLive, $PRES, -43)
;~ $WLFam = _GUICtrlCreateODMenuItem("Windows Live &Family Safety (" & _GetProgramVersion($WLDir & "\Family Safety\fsui.exe", 3) & ")", $ACLive, $PRES, -71)
;~ $WLMail = _GUICtrlCreateODMenuItem("Windows Live &Mail (" & _GetProgramVersion($WLDir & "\Mail\wlmail.exe", 3) & ")", $ACLive, $PRES, -72)
;~ $WLMsg = _GUICtrlCreateODMenuItem("Windows Live Messen&ger (" & _GetProgramVersion($WLDir & "\Messenger\msnmsgr.exe", 3) & ")", $ACLive, $PRES, -69)
;~ $WLPhoto = _GUICtrlCreateODMenuItem("Windows Live &Photo Gallery (" & _GetProgramVersion($WLDir & "\Photo Gallery\WLXPhotoGallery.exe", 3) & ")", $ACLive, $PRES, -73)
;~ $WLSkyDrive = _GUICtrlCreateODMenuItem("Windows Live Sky&Drive (Online)", $ACLive, $PRES, -68)
;~ $WLSync = _GUICtrlCreateODMenuItem("Windows Live &Sync (" & _GetProgramVersion($WLDir & "\Sync\WindowsLiveSync.exe", 3) & ")", $ACLive, $PRES, -74)
;~ $WLWriter = _GUICtrlCreateODMenuItem("Windows Live &Writer (" & _GetProgramVersion($WLDir & "\Writer\WindowsLiveWriter.exe", 3) & ")", $ACLive, $PRES, -75)
;~ _GUICtrlCreateODMenuItem("", $ACLive)
;~ $WLDown = _GUICtrlCreateODMenuItem("&Download Windows Live Essentials", $ACLive, $PRES, -68)
;~ $WLUnins = _GUICtrlCreateODMenuItem("Uninstall or &Repair Windows Live Programs", $ACLive, $PRES, -68)
;~ ; ==> Windows Live Menu
;~ $ACMsg = _GUICtrlCreateODMenuItem("Windows Messen&ger (" & _GetProgramVersion(@ProgramFilesDir & "\Messenger\msmsgs.exe", 3) & ")", $MAcc, $PRES, -69)
;~ $ACMovie = _GUICtrlCreateODMenuItem("Windows &Movie Maker (" & _GetProgramVersion(@ProgramFilesDir & "\Movie Maker\moviemk.exe", 3) & ")", $MAcc, $PRES, -67)

_Busy_Update("", 30)
; ===============================================================================================================================
; Administration Menu
; ===============================================================================================================================
$MAdmin = GUICtrlCreateMenu("&Administration")
$SIAdmin = _CreateSideMenu($MAdmin)
_SetSideMenuText($SIAdmin, "Administration")
$AAdTools = _GUICtrlCreateODMenu("&Administrative Tools", $MAdmin, $PRES, -8)
$ATATools = _GUICtrlCreateODMenuItem("&Administrative Tools", $AAdTools, $PRES, -8)
$ATCompMgmnt = _GUICtrlCreateODMenuItem("Computer &Management", $AAdTools, $PRES, -20)
_GUICtrlCreateODMenuItem("", $AAdTools)
$ATCertMan = _GUICtrlCreateODMenuItem("&Certificate Manager", $AAdTools, $PRES, -10)
$ATCompServ = _GUICtrlCreateODMenuItem("C&omponent Services", $AAdTools, $PRES, -13)
$ATDeviceMan = _GUICtrlCreateODMenuItem("&Device Manager", $AAdTools, $PRES, -7)
$ATDMgmt = _GUICtrlCreateODMenuItem("Dis&k Management", $AAdTools, $PRES, -14)
$ATEvent = _GUICtrlCreateODMenuItem("&Event Viewer", $AAdTools, $PRES, -15)
$ATIndexServ = _GUICtrlCreateODMenuItem("&Indexing Service", $AAdTools, $PRES, -16)
$ATODBCD = _GUICtrlCreateODMenuItem("&ODBC Data Source Administration", $AAdTools, $PRES, -17)
$ATPM = _GUICtrlCreateODMenuItem("&Performance Monitor", $AAdTools, $PRES, -1)
$ATRMon = _GUICtrlCreateODMenuItem("&Resource Monitor", $AAdTools, $PRES, -1)
$ATSFold = _GUICtrlCreateODMenuItem("&Shared Folder Manager", $AAdTools, $PRES, -18)
$ATWMI = _GUICtrlCreateODMenuItem("&Windows Management Infrastructure", $AAdTools, $PRES, -19)
; Briefcase Menu
$ABCase = _GUICtrlCreateODMenu("&Briefcase", $MAdmin, $PRES, -29)
$BIntro = _GUICtrlCreateODMenuItem("Briefcase &Introduction", $ABCase, $PRES, -29)
$BCreate = _GUICtrlCreateODMenuItem("&Create Briefcase", $ABCase, $PRES, -30)
_GUICtrlCreateODMenuItem("", $ABCase)
$BOpen = _GUICtrlCreateODMenuItem("&Open 'My Briefcase'", $ABCase, $PRES, -31)
; ==> Briefcase Menu
; Clipboard Menu
$MClip = _GUICtrlCreateODMenu("&ClipBoard Management", $MAdmin, $PRES, -32)
$CClear = _GUICtrlCreateODMenuItem("&Clear ClipBoard", $MClip, $PRES, -33)
_GUICtrlCreateODMenuItem("", $MClip)
$CViewer = _GUICtrlCreateODMenuItem("ClipBook &Viewer", $MClip, $PRES, -34)
; ==> Clipboard Menu
; Disk Management Menu
$MADMan = _GUICtrlCreateODMenu("&Disk Management", $MAdmin, $PRES, -14)
$DMMan = _GUICtrlCreateODMenuItem("Disk &Management", $MADMan, $PRES, -14)
_GUICtrlCreateODMenuItem("", $MADMan)
$DMClean = _GUICtrlCreateODMenuItem("Disk &Cleanup", $MADMan, $PRES, -36)
$DMDFrag = _GUICtrlCreateODMenuItem("Disk &Defragmenter", $MADMan, $PRES, -37)
$DMPMan = _GUICtrlCreateODMenuItem("Disk &Partition Manager", $MADMan, $PRES, -12)
_GUICtrlCreateODMenuItem("", $MADMan)
$DMHDrive = _GUICtrlCreateODMenuItem("&Browse Home Drive (" & @HomeDrive & ")", $MADMan, $PRES, -35)
; ==> Disk Management Menu
$AFSigVer = _GUICtrlCreateODMenuItem("&File Signature Verification", $MAdmin, $PRES, -61)
$AFSTrans = _GUICtrlCreateODMenuItem("Files and &Settings Transfer Wizard", $MAdmin, $PRES, -62)
; Hardware Management Menu
$AHMngmt = _GUICtrlCreateODMenu("&Hardware Management", $MAdmin, $PRES, -7)
$HMAddWiz = _GUICtrlCreateODMenuItem("Add &Hardware Wizard", $AHMngmt, $PRES, -4)
$HMDevMan = _GUICtrlCreateODMenuItem("&Device Manager", $AHMngmt, $PRES, -7)
$HMDrVer = _GUICtrlCreateODMenuItem("Driver &Verifier Manager", $AHMngmt, $PRES, -60)
; ==> Hardware Management Menu
; Network Management Menu
$NMan = _GUICtrlCreateODMenu("&Network Management", $MAdmin, $PRES, -40)
$NMConn = _GUICtrlCreateODMenuItem("Network &Connections", $NMan, $PRES, -41)
_GUICtrlCreateODMenu("", $NMan)
$NMHTerm = _GUICtrlCreateODMenuItem("&Hyper Terminal", $NMan, $PRES, -42)
$NMDialer = _GUICtrlCreateODMenuItem("Phone &Dialer", $NMan, $PRES, -43)
$NMRDesk = _GUICtrlCreateODMenuItem("&Remote Desktop Connection", $NMan, $PRES, -44)
$NMTelnet = _GUICtrlCreateODMenuItem("&Telnet Client", $NMan, $PRES, -12)
; ==> Network Management Menu

_Busy_Update("", 40)
; ===============================================================================================================================
; Control Panel Menu
; ===============================================================================================================================
$Mcnt = GUICtrlCreateMenu("&Control Panel")
$SIcnt = _CreateSideMenu($Mcnt)
_SetSideMenuText($SIcnt, "Control Panel")
$CCPanel = _GUICtrlCreateODMenuItem("&Control Panel", $Mcnt, $PRES, -21)
_GUICtrlCreateODMenuItem("", $Mcnt)
; Accessibility Menu Start
$CAccess = _GUICtrlCreateODMenu("&Accessibility Center", $Mcnt, $PRES, -2)
$AOptions = _GUICtrlCreateODMenuItem("&Accessibility Options", $CAccess, $PRES, -2)
$AUMan = _GUICtrlCreateODMenuItem("&Utility Manager" & @TAB & "Win+U", $CAccess, $PRES, -2)
$ASpeech = _GUICtrlCreateODMenuItem("&Speech Properties", $CAccess)
_GUICtrlCreateODMenuItem("", $CAccess)
$AWiz = _GUICtrlCreateODMenuItem("Accessibility &Wizard", $CAccess, $PRES, -25)
$ANarr = _GUICtrlCreateODMenuItem("&Narrator", $CAccess, $PRES, -26)
$AOSKey = _GUICtrlCreateODMenuItem("On-Screen &Keyboard", $CAccess, $PRES, -27)
$AMag = _GUICtrlCreateODMenuItem("Screen Magnifier", $CAccess, $PRES, -28)
; ==> Accessibility Menu End
$CAddHard = _GUICtrlCreateODMenuItem("Add &Hardware Wizard", $Mcnt, $PRES, -4)
; Add or Remove Programs Menu
$CAddRemove = _GUICtrlCreateODMenu("&Programs and Features", $Mcnt, $PRES, -5)
$APChRemove = _GUICtrlCreateODMenuItem("C&hange or Remove Programs", $CAddRemove, $PRES, -5)
_GUICtrlCreateODMenuItem("", $CAddRemove)
$APNewPrograms = _GUICtrlCreateODMenuItem("Add &New Programs", $CAddRemove, $PRES, -5)
$APWinComp = _GUICtrlCreateODMenuItem("Add or Remove &Windows Components", $CAddRemove, $PRES, -5)
$APAccess = _GUICtrlCreateODMenuItem("Set Pr&ogram Access and Defaults", $CAddRemove, $PRES, -6)
; ==> Add or Remove Programs Menu
$CAutUpdate = _GUICtrlCreateODMenuItem("Automatic &Updates", $Mcnt, $PRES, -57)
$CDateTime = _GUICtrlCreateODMenuItem("&Date and Time Properties", $Mcnt, $PRES, -22)
$ClDXDiag = _GUICtrlCreateODMenuItem("Direct&X Troubleshooter", $Mcnt, $PRES, -23)
; Display Properties Menu
$CDisp = _GUICtrlCreateODMenu("D&isplay Properties", $Mcnt, $PRES, -58)
$DisProp = _GUICtrlCreateODMenuItem("&Display Properties", $CDisp, $PRES, -58)
$DisCol = _GUICtrlCreateODMenuItem("&Color and Appearance", $CDisp, $PRES, -59)
; ==> Display Properties Menu
$CFonts = _GUICtrlCreateODMenuItem("&Font Management", $Mcnt, $PRES, -63)
$CGame = _GUICtrlCreateODMenuItem("&Game Controllers", $Mcnt, $PRES, -64)
$CIESett = _GUICtrlCreateODMenuItem("&Internet Properties", $Mcnt, $PRES, -65)
$CKey = _GUICtrlCreateODMenuItem("&Keyboard Properties", $Mcnt, $PRES, -66)
$CNConn = _GUICtrlCreateODMenuItem("&Network Connections", $Mcnt, $PRES, -41)
; User Accounts Menu
$AMUser = _GUICtrlCreateODMenu("&User Accounts", $Mcnt, $PRES, -39)
$UMEditor = _GUICtrlCreateODMenuItem("User Accounts &Editor", $AMUser, $PRES, -39)
$UMAccess = _GUICtrlCreateODMenuItem("User Account &Access Restrictions", $AMUser)
$UMSFMan = _GUICtrlCreateODMenuItem("&Shared Folder Manager", $AMUser, $PRES, -18)
; ==> User Accounts Menu

_Busy_Update("", 50)
; ===============================================================================================================================
; System Menu
; ===============================================================================================================================
$MSYS = GUICtrlCreateMenu("&System")
$SISYS = _CreateSideMenu($MSYS)
_SetSideMenuText($SISYS, "System")
$SLock = _GUICtrlCreateODMenuItem("&Lock Windows " & @TAB & "Ctrl+Alt+L", $MSYS, $PRES, -3)
$SREdit = _GUICtrlCreateODMenuItem("&Registry Editor", $MSYS, $PRES, -38)

_Busy_Update("", 90)

HotKeySet("{F2}", "_VistaRename")
HotKeySet("^!l", "_LockWorkstation")

;~ If Not FileExists(@ProgramFilesDir & "\Windows Media Player\mplayer2.exe") Then GUICtrlDelete($MMPlay6)
;~ If Not FileExists(@SystemDir & "\mrt.exe") Then GUICtrlDelete($ACMRT)
;~ If Not FileExists(@ScriptDir & "\Codecs\DScaler.exe") Then GUICtrlDelete($MInsCodec)
;~ If Not FileExists(@ProgramFilesDir & "\Messenger\msmsgs.exe") Then GUICtrlDelete($ACMsg)
;~ If Not FileExists(@ProgramFilesDir & "\Movie Maker\moviemk.exe") Then GUICtrlDelete($ACMovie)
;~ If Not FileExists(@SystemDir & "\packager.exe") Then GUICtrlDelete($ACObPack)
If Not FileExists(@SystemDir & "\ciadv.msc") Then GUICtrlDelete($ATIndexServ)
If Not FileExists(@SystemDir & "\resmon.exe") Then GUICtrlDelete($ATRMon)
If Not FileExists(@SystemDir & "\clipbrd.exe") Then GUICtrlDelete($CViewer)
If Not FileExists(@ProgramFilesDir & "\Windows NT\hypertrm.exe") Then GUICtrlDelete($NMHTerm)
If Not FileExists(@SystemDir & "\telnet.exe") Then GUICtrlDelete($NMTelnet)

If @OSVersion = "WIN_VISTA" Or @OSVersion = "WIN_2008" Then
	GUICtrlDelete($ASpeech)
	GUICtrlDelete($AUMan)
	GUICtrlDelete($AWiz)
	GUICtrlDelete($CAddHard)
	GUICtrlDelete($ABCase)

	_GUICtrlODMenuItemSetText($AFSTrans, "Windows Easy Transfer")
    _GUICtrlODMenuItemSetText($AOptions, "Ease of &Access Center" & @TAB & "Win+U")
	_GUICtrlODMenuItemSetText($APChRemove, "Uninstall or C&hange a Program")
	_GUICtrlODMenuItemSetText($APNewPrograms, "Install a Program From the &Network")
	_GUICtrlODMenuItemSetText($APWinComp, "Turn &Windows Features On or Off")
	_GUICtrlODMenuItemSetText($CAutUpdate, "Windows Update")
	_GUICtrlODMenuItemSetText($CDateTime, "Date and Time")
EndIf

_Busy_Update("", 100)
_Busy_Close()

GUISetState(@SW_SHOW)

Local $MTimer = 0
Local $RedMemTimer = 0

While 1

	If TimerDiff($MTimer) >= 1500 Then
		If FileExists(@DesktopDir & "\My Briefcase") Then
			GUICtrlSetState($BCreate, $GUI_DISABLE)
			GUICtrlSetState($BOpen, $GUI_ENABLE)
		Else
			GUICtrlSetState($BCreate, $GUI_ENABLE)
			GUICtrlSetState($BOpen, $GUI_DISABLE)
		EndIf
		$MTimer = TimerInit()
	EndIf

	If TimerDiff($RedMemTimer) >= 500 Then
;~ 		_ReduceMemory(@AutoItPID)
		$RedMemTimer = TimerInit()
	EndIf

	$nMsg = GUIGetMsg()
	Switch $nMsg

; ===============================================================================================================================
; File Menu
; ===============================================================================================================================
;~ 		Case $FMinimize;, $MTMinimize
;~ 			WinSetState($ATITLE & " " & $AVER, "", @SW_MINIMIZE)

; ===============================================================================================================================
; Accessories Menu
; ===============================================================================================================================
;~ 		Case $ACCalc
;~ 			ShellExecute("calc")
;~ 		Case $ACCharMap
;~ 			ShellExecute("charmap")
;~ 		Case $ACCommand
;~ 			ShellExecute("cmd.exe", "/k " & @ScriptDir & "\Command.bat", @SystemDir)
;~ 		Case $ACIEX
;~ 			ShellExecute("iexpress.exe", "", @SystemDir)
;~ 		; Internet Explorer Menu Events
;~ 		Case $IEIntE
;~ 			ShellExecute("iexplore.exe", "", @ProgramFilesDir & "\Internet Explorer")
;~ 		Case $IESett, $CIESett
;~ 			ShellExecute("control", "inetcpl.cpl")
;~ 		; ==> Internet Explorer Menu Events
;~ 		Case $ACMRT
;~ 			ShellExecute("MRT")
;~ 		Case $ACPaint
;~ 			ShellExecute("mspaint.exe", "", @SystemDir)
;~ 		; Multimedia Menu
;~ 		Case $MMPlay6
;~ 			ShellExecute("mplayer2.exe", "", @ProgramFilesDir & "\Windows Media Player")
;~ 		Case $MMPlay
;~ 			ShellExecute("wmplayer.exe", "/prefetch:1", @ProgramFilesDir & "\Windows Media Player")
;~ 		Case $MDVDPlay
;~ 			ShellExecute("dvdplay")
;~ 		Case $MInsCodec
;~ 			ShellExecute(@ScriptDir & "\Codecs\DScaler.exe")
;~ 		Case $MSndRec
;~ 			If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_2003" Then
;~ 				ShellExecute("sndrec32.exe", "", @SystemDir)
;~ 			Else
;~ 				ShellExecute("soundrecorder.exe", "", @SystemDir)
;~ 			EndIf
;~ 		; ==> Multimedia Menu
;~ 		Case $ACNote
;~ 			ShellExecute("notepad.exe", "", @SystemDir)
;~ 		Case $ACObPack
;~ 			Run("packager")
;~ 		Case $ACExplore
;~ 			ShellExecute("explorer.exe", "/n,/e", @WindowsDir)
;~ 		; Windows Live Menu Events
;~ 		Case $WLHome
;~ 			ShellExecute("http://home.live.com")
;~ 		Case $WLDown
;~ 			ShellExecute("http://download.live.com")
;~ 		; ==> Windows Live Menu Events
;~ 		Case $ACMsg
;~ 			ShellExecute(@ProgramFilesDir & "\Messenger\msmsgs.exe")
;~ 		Case $ACMovie
;~ 			ShellExecute(@ProgramFilesDir & "\Movie Maker\moviemk.exe")

; ===============================================================================================================================
; Administration Menu Events
; ===============================================================================================================================
;~ 		Case $ATATools
;~ 			ShellExecute("control", "admintools")
;~ 		Case $ATCompMgmnt
;~ 			ShellExecute("compmgmt.msc", "/s")
;~ 		Case $ATCertMan
;~ 			ShellExecute("mmc.exe", "certmgr.msc", @SystemDir)
;~ 		Case $ATCompServ
;~ 			ShellExecute("dcomcnfg")
;~ 		Case $ATDeviceMan, $HMDevMan
;~ 			ShellExecute("devmgmt.msc")
;~ 		Case $ATDMgmt, $DMMan
;~ 			ShellExecute("mmc", "diskmgmt.msc", @SystemDir)
;~ 		Case $ATEvent
;~ 			ShellExecute("eventvwr.exe", "", @SystemDir)
;~ 		Case $ATIndexServ
;~ 			ShellExecute("mmc.exe", "ciadv.msc", @SystemDir)
;~ 		Case $ATODBCD
;~ 			ShellExecute("odbcad32.exe", "", @SystemDir)
;~ 		Case $ATRMon
;~ 			Run("resmon")
;~ 		Case $ATPM
;~ 			ShellExecute("mmc.exe", "perfmon.msc", @SystemDir)
;~ 		Case $ATSFold, $UMSFMan
;~ 			ShellExecute("mmc.exe", "fsmgmt.msc", @SystemDir)
;~ 		Case $ATWMI
;~ 			ShellExecute("mmc.exe", "wmimgmt.msc", @SystemDir)
;~ 		; Briefcase Menu
;~ 		Case $BIntro
;~ 			ShellExecute("rundll32", "syncui.dll,Briefcase_Intro")
;~ 		Case $BCreate
;~ 			_MemoLogWrite("Creating Briefcase, Please Wait...")
;~ 			ShellExecute("rundll32", "syncui.dll,Briefcase_Create")
;~ 			_MemoLogWrite("Briefcase Created and is located @ " & @DesktopDir & "\My Briefcase", 1)
;~ 		Case $BOpen
;~ 			If FileExists(@DesktopDir & "\My Briefcase") Then ShellExecute(@DesktopDir & "\My Briefcase")
;~ 		; ==> Briefcase Menu
;~ 		; Clipboard Menu
;~ 		Case $CClear
;~ 			_MemoLogWrite("Clearing the Windows Clipboard, Please Wait...")
;~ 			If Not _ClipBoard_Open ($Form) Then _WinAPI_ShowError ("_ClipBoard_Open failed")
;~ 			If Not _ClipBoard_Empty () Then _WinAPI_ShowError ("_ClipBoard_Empty failed")
;~ 			_ClipBoard_Close ()
;~ 			_MemoLogWrite("Windows Clipboard Cleared.", 1)
;~ 		Case $CViewer
;~ 			ShellExecute("clipbrd.exe", "", @SystemDir)
;~ 		; ==> Clipboard Menu
;~ 		; Disk Management Menu
;~ 		Case $DMHDrive
;~ 			ShellExecute(@HomeDrive, "", @HomeDrive)
;~ 		Case $DMClean
;~ 			ShellExecute("cleanmgr")
;~ 		Case $DMDFrag
;~ 			If @OSVersion = "WIN_VISTA" Or @OSVersion = "WIN_2008" Then
;~ 				ShellExecute("dfrgui.exe", "", @SystemDir)
;~ 			Else
;~ 				ShellExecute("mmc", "dfrg.msc", @SystemDir)
;~ 			EndIf
;~ 		Case $DMPMan
;~ 			ShellExecute("diskpart")
;~ 		; ==> Disk Management Menu
;~ 		Case $AFSigVer
;~ 			ShellExecute("sigverif")
;~ 		Case $AFSTrans
;~ 			ShellExecute("migwiz")
;~ 		; Hardware Management Menu
;~ 		Case $HMDrVer
;~ 			ShellExecute("verifier")
;~ 		; ==> Hardware Management Menu
;~ 		; Network Management Menu
;~ 		Case $NMHTerm
;~ 			ShellExecute("hypertrm", "", @ProgramFilesDir & "\Windows NT")
;~ 		Case $NMDialer
;~ 			ShellExecute("dialer")
;~ 		Case $NMRDesk
;~ 			ShellExecute("mstsc")
;~ 		Case $NMTelnet
;~ 			ShellExecute("telnet.exe", "", @SystemDir)
;~ 		; ==> Network Management Menu

;~ ; ===============================================================================================================================
;~ ; Control Panel Menu Events
;~ ; ===============================================================================================================================
;~ 		Case $CCPanel
;~ 			ShellExecute("control")
;~ 		Case $AOptions
;~ 			ShellExecute("control", "access.cpl")
;~ 		Case $AUMan
;~ 			ShellExecute("utilman.exe", "", @SystemDir)
;~ 		Case $ASpeech
;~ 			ShellExecute("control", "speech")
;~ 		Case $AWiz
;~ 			ShellExecute("accwiz.exe")
;~ 		Case $ANarr
;~ 			ShellExecute("narrator.exe")
;~ 		Case $AOSKey
;~ 			ShellExecute("osk.exe")
;~ 		Case $AMag
;~ 			ShellExecute("magnify.exe")
;~ 		Case $CAddHard, $HMAddWiz
;~ 			ShellExecute("control", "hdwwiz.cpl")
;~ 		Case $APChRemove
;~ 			ShellExecute("control", "appwiz.cpl")
;~ 		Case $APNewPrograms
;~ 			ShellExecute("control", "appwiz.cpl,,1")
;~ 		Case $APWinComp
;~ 			If @OSVersion = "WIN_VISTA" OR @OSVersion = "WIN_2008" Then
;~ 				ShellExecute("optionalfeatures")
;~ 			Else
;~ 				ShellExecute("control", "appwiz.cpl,,2")
;~ 			EndIf
;~ 		Case $APAccess
;~ 			ShellExecute("control", "appwiz.cpl,,3")
;~ 		Case $CAutUpdate
;~ 			ShellExecute("control", "wuaucpl.cpl")
;~ 		Case $CDateTime
;~ 			ShellExecute("control", "timedate.cpl")
;~ 		Case $ClDXDiag
;~ 			ShellExecute("dxdiag")
;~ 		; Display Menu Events
;~ 		Case $DisProp
;~ 			ShellExecute("control", "desk.cpl")
;~ 		Case $DisCol
;~ 			ShellExecute("control", "color")
;~ 		; ==> Display Menu Events
;~ 		Case $CFonts
;~ 			ShellExecute("control", "fonts")
;~ 		Case $CGame
;~ 			ShellExecute("control", "joy.cpl")
;~ 		Case $CKey
;~ 			ShellExecute("control", "keyboard")
;~ 		Case $CNConn, $NMConn
;~ 			ShellExecute("control", "ncpa.cpl")
;~ 		; User Accounts Menu Events
;~ 		Case $UMEditor
;~ 			ShellExecute("control", "userpasswords")
;~ 		Case $UMAccess
;~ 			ShellExecute("control", "userpasswords2")
;~ 		; ==> User Accounts Menu Events

; ===============================================================================================================================
; System Menu Events
; ===============================================================================================================================
;~ 		Case $SREdit
;~ 			ShellExecute("regedit.exe", "", @WindowsDir)
;~ 		Case $SLock
;~ 			_LockWorkstation()

		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd

; ===============================================================================================================================
; System Menu Functions
; ===============================================================================================================================
Func _LockWorkstation()
	ShellExecute("rundll32.exe", "user32.dll,LockWorkStation")
EndFunc

Func _MemoLogWrite($MSG = "", $W = 0)
	Select
		Case $W = 1 ;Success
			GUICtrlSetBkColor($eStatus, 0xC1DCfC)
		Case $W = 2 ;Error
			GUICtrlSetBkColor($eStatus, 0xEFD6E1)
		Case $W = 3 ;Warning
			GUICtrlSetBkColor($eStatus, 0xF4FFD4)
	EndSelect
	GUICtrlSetData($eStatus, $MSG & @CRLF, 1)
	$OLog = FileOpen($PLOG, 1)
	;If $OpenRepairLog = -1 Then
		;MsgBox(0, "Error", "Unable to open file.")
		;Exit
	;EndIf
	FileWrite($OLog, $MSG & @CRLF)
	FileClose($OLog)
EndFunc

Func _SetMenuColors()
	_SetMenuBkColor(0xFFFFFF)
	_SetMenuIconBkColor(0xFFFFFF)
	_SetMenuSelectBkColor(0xC1DCfC)
	_SetMenuSelectRectColor(0x7DA2CE)
	_SetMenuIconBkGrdColor(0xD9D9D9)
	_SetMenuSelectTextColor(0x000000)
	_SetMenuTextColor(0x000000)
EndFunc

Func _SetTrayColors()
	_SetTrayBkColor(0xFFFFFF)
	_SetTrayIconBkColor(0xFFFFFF)
	_SetTrayIconBkGrdColor(0xD9D9D9)
	_SetTraySelectBkColor(0xC1DCfC)
	_SetTraySelectRectColor(0x7DA2CE)
	_SetTraySelectTextColor(0x000000)
	_SetTrayTextColor(0x000000)
EndFunc

Func _ClearFileAttributes($FN)
	FileSetAttrib($FN, "+A-S-R-H")
EndFunc

Func _BMsg()
	If $RREQ = 1 Then
		_SecBMsg()
	Else
		$RREQ = 1
		_MemoLogWrite("You will need to reboot your computer before the settings will take effect.", 3)
		If Not IsDeclared("MBOX") Then Local $MBOX
		$MBOX = MsgBox(65,"Reboot required!","You will need to reboot your computer before the settings will take effect. " & _
								   "Answer 'OK' to reboot your computer or 'Cancel' if you would like to reboot later. " & _
								   "Note that some settings might not take effect or some components might not function correctly until you reboot." & @CRLF & @CRLF & _
								   "Your computer will reboot automatically in 60 seconds.",60)
		If $MBOX = 1 Or $MBOX = -1 Then Shutdown(18)
	EndIf
EndFunc

Func _SecBMsg()
	_MemoLogWrite("Reboot: Previous changes to your computer detected. You will need to reboot your computer before making any more changes.", 3)
	If Not IsDeclared("MBOX") Then Local $MBOX
	$MBOX = MsgBox(49,"Reboot required!","Previous changes to your computer detected. " & _
					  "You will need to reboot your computer before you can make any further changes. " & _
					  "Answer 'OK' to reboot your computer or 'Cancel' if you would like to reboot later. " & _
					  "Note that some settings might not take effect or some components might not function correctly until you reboot." & @CRLF & @CRLF & _
					  "Your computer will reboot automatically in 60 seconds.",60)
	If $MBOX = 1 Or $MBOX = -1 Then Shutdown(18)
EndFunc

Func _Closing()
	Switch @EXITMETHOD
		Case 1
			If $RREQ = 1 Then
				_SecBMsg()
			EndIf
	EndSwitch
	;_TrayIconDelete($TRAY)
EndFunc
