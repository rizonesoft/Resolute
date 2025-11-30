#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=Resources\WinPower.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Doors Hive System
#AutoIt3Wrapper_Res_Fileversion=0.9.0.909
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Datum
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Big-Smile.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Crying.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Devilish.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Glasses.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Grin.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Plain.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Sad.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Smile.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Surprise.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Wink.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\emotes\Wink.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\RBEmp.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\RBFull.ico


Opt("TrayMenuMode", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("GUIOnEventMode", 1)
Opt("GUIResizeMode", 802) ;~ $GUI_DOCKALL
Opt("MustDeclareVars", 1)

;#include <GuiConstantsEx.au3>
;#include <GuiMenu.au3>

#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#Include <Date.au3>
#include <Misc.au3>

#include <UDF\Icons.au3>
;#include <UDF\Status.au3>
#include <UDF\WinAPIEx_3.7_3380\WinAPIEx.au3>
#include <UDF\CoreDoors.au3>
;~ #include <UDF\GUIExtender.au3>
#include <UDF\GUICtrlMenuEx.au3>

#include <UDF\_Accessories.au3>
#include <UDF\HmDoors.au3>
#include <UDF\HmGo.au3>
#include <UDF\HmRepair.au3>
#include <UDF\HmSecurity.au3>


;~ If _Singleton(@ScriptName, 1) = 0 Then
;~ 	MsgBox(262192, "Warning", "An occurence of Doors is already running.", 30)
;~ 	Exit
;~ EndIf


Global Const $ExitProcess = False
Global Const $DoorsVersion =  FileGetVersion(@ScriptFullPath)

Global Const $DoorsRes = @ScriptDir & "\Structure\Shell20.exe"

Global $doorsForm, $mainMenu, $goMenu, $goCompSub, $goProgSub, $progMulitSub, $goCSFSub, $doorsMenu, $dlogSub
Global $accMenu, $accDiskSub, $accMaintSub, $accOptiSub, $optiMemSub, $accEnhSub, $enhShellSub, $accComPSub
Global $adminMenu, $repairMenu, $repWinSub, $securMenu, $secVClSub, $sysMenu
Global $iaHGap = 350, $iaVGap = 55, $iaCount = 13, $iaSize = 48, $iaGap = 5, $alpIcon[$iaCount + 1]
Global $ibHGap = 350, $ibVGap = 180, $ibCount = 13, $ibSize = 48, $ibGap = 5, $blpIcon[$ibCount + 1]
Global $eStatus
Global $hMemIco, $hCPUIco, $icoKState, $KSDiff = 0, $DoorsTime, $TM1Free, $TM2Free, $memUsageBar, $pageUsBar, $lblMemUsage, $lblPageUs
Global $GuiUpdate = True, $doorsIcon
;~ Global $CCom1, $CCom2, $CCom3, $CCom4, $CCom5, $CCom6, $CCom7, $CCom8, $CCom9
Global $guiDoorsRetracted = False, $guiDoorsCoords, $guiDoorsPosX, $guiDoorsPosY, $btnGuiExtend


;_LoaderStart()

;~ _InitializeLogFile(5)
;~ _LoggingWrite("", False)
;~ _LoggingWrite("", False)
;~ _LoggingWrite("                                            ./", False)
;~ _LoggingWrite("                                          (o o)", False)
;~ _LoggingWrite("--------------------------------------oOOo-(_)-oOOo--------------------------------------", False)

;_LoaderUpdate(1)
;_SetAutorunProtectionStatus()

;_LoaderUpdate(2)
;_CheckIntegrity()

;~ Load Settings
;~ _LoaderUpdate(3)
;~ Func _LoadAppSettings()
;~ 	$CCom1 = IniRead($SETTINGS_DOORS, "QuickLaunch", "1", "")
;~ EndFunc

;~ _LoaderUpdate(4)
;~ _LoaderUpdate(5)
;~ _LoaderUpdate(6)
;~ _LoaderUpdate(7)
;~ _LoaderUpdate(8)
;~ _LoaderUpdate(9)

;~ _mainGUI()


Func _mainGUI()

	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

;~ 	$doorsForm = GUICreate("Datum Doors " & _GetDoorsVersion(1) & " : Build " & _
;~ 		_GetDoorsVersion(4), 750, 550, -1, -1, -1, -1)
;~ 	GUISetFont(8.5, 400, 0, "Verdana")
;~ 	GUISetBkColor(0xEBEBEB)


;~ 	$guiDoorsCoords = WinGetPos($doorsForm)
;~ 	$guiDoorsPosX = $guiDoorsCoords[0]
;~ 	$guiDoorsPosY = $guiDoorsCoords[1]

;~ 	_GUICtrlMenuEx_Startup(Default)

;~ 	$mainMenu = _GUICtrlMenu_CreateMenu()

;~ 	Local $winOrbIco = _WinAPI_ShellExtractIcon(@ScriptFullPath, -201 - Random(0, 9, 1), 32, 32)
;~ 	Local $goIcon[3], $shell20[50]

;~ 	For $ex = 0 To UBound($shell20) - 1
;~ 		$shell20[$ex] = _WinAPI_ShellExtractIcon($DoorsRes, -211 - $ex, 16, 16)
;~ 	Next


	_LoaderUpdate(10)
	; ===============================================================================================================================
	; Go Menu
	; ===============================================================================================================================
	$goIcon[0] = _WinAPI_ShellExtractIcon($DoorsRes, -211, 24, 24)
	$goIcon[1] = _WinAPI_ShellExtractIcon($DoorsRes, -212, 24, 24)
	$goIcon[2] = _WinAPI_ShellExtractIcon($DoorsRes, -213, 24, 24)

	$goMenu = _GUICtrlMenu_CreateMenu()
	_GUICtrlMenu_SetMenuStyle($goMenu, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($mainMenu, "&Go", 1, $goMenu)

	_LoaderUpdate(11)
	$goCompSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($goCompSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($goMenu, "&Computer", 1, $goCompSub)
	_GUICtrlMenuEx_AddMenuItem($goCompSub, "&Computer", 1101, $shell20[0])
	_GUICtrlMenuEx_AddMenuBar($goCompSub)
	_GUICtrlMenuEx_AddMenuItem($goCompSub, "&Home Drive (" & @HomeDrive & ")", 1102, $shell20[3])
	_GUICtrlMenuEx_SetItemIcon($goMenu, 0, $goIcon[0])


	_GUICtrlMenuEx_AddMenuItem($goMenu, "&Documents", 1108, $goIcon[1])

	_LoaderUpdate(12)
	$goProgSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($goProgSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($goMenu, "&Programs", 2, $goProgSub)
	_GUICtrlMenuEx_SetItemIcon($goMenu, 2, $goIcon[2])

	$progMulitSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($progMulitSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($goProgSub, "&Multimedia", 0, $progMulitSub)
	_GUICtrlMenuEx_SetItemIcon($goProgSub, 0, $shell20[4])
	_GUICtrlMenuEx_AddMenuItem($progMulitSub, "&Rip and convert audio", 1103, $shell20[5])


	_LoaderUpdate(13)
	; ===============================================================================================================================
	; Doors Menu
	; ===============================================================================================================================

	$doorsMenu = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($doorsMenu, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($mainMenu, "&Doors", 2, $doorsMenu)

	$dlogSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($dlogSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($doorsMenu, "&Doors Logging", 0, $dlogSub)
	_GUICtrlMenuEx_AddMenuItem($dlogSub, "Open logging &folder", 1204, $shell20[1])
	_GUICtrlMenuEx_AddMenuItem($dlogSub, "Open &logging file", 1205, $shell20[25])

	_GUICtrlMenuEx_AddMenuItem($doorsMenu, "&Doors Update", 1201, $shell20[6])
	_GUICtrlMenuEx_AddMenuBar($doorsMenu)
	_GUICtrlMenuEx_AddMenuItem($doorsMenu, "&Minimize", 1202, $shell20[7])
	_GUICtrlMenuEx_AddMenuItem($doorsMenu, "&Shutdown Doors", 1203, $shell20[8])


	_LoaderUpdate(14)
	; ===============================================================================================================================
	; Accessories Menu
	; ===============================================================================================================================

	HotKeySet("^!c", "_LaunchConsole")

	$accMenu = _GUICtrlMenu_CreateMenu()
	_GUICtrlMenu_SetMenuStyle($accMenu, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($mainMenu, "Acc&essories", 3, $accMenu)

	$accDiskSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($accDiskSub , 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($accMenu, "&Disk and File Management", 1, $accDiskSub)
	_GUICtrlMenuEx_SetItemIcon($accMenu, 0, $shell20[3])

	_LoaderUpdate(15)
	$accMaintSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($accMaintSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($accMenu, "&Maintenance", 2, $accMaintSub)
	_GUICtrlMenuEx_AddMenuItem($accMaintSub, "&Uninstall programs", 1306, $shell20[14])
	_GUICtrlMenuEx_SetItemIcon($accMenu, 1, $shell20[9])
	_GUICtrlMenuEx_AddMenuBar($accMaintSub)
	_GUICtrlMenuEx_AddMenuItem($accMaintSub, "&Unstoppable Copier", 1310, $shell20[14])

	_LoaderUpdate(16)
	$accOptiSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($accOptiSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($accMenu, "&Optimization", 2, $accOptiSub)
	$optiMemSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($optiMemSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($accOptiSub, "&Memory Management", 1, $optiMemSub)
	_GUICtrlMenuEx_AddMenuItem($accOptiSub, "&Disk Defragmenter", 1304, $shell20[15])
	_GUICtrlMenuEx_SetItemIcon($accOptiSub, 0, $shell20[24])
	_GUICtrlMenuEx_AddMenuItem($optiMemSub, "&Force mem into PageFile (Experimental)", 1308, $shell20[24])
	_GUICtrlMenuEx_SetItemIcon($accMenu, 2, $shell20[10])

	_LoaderUpdate(17)
	$accEnhSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($accEnhSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($accMenu, "&Enhancements", 3, $accEnhSub)
	$enhShellSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($enhShellSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($accEnhSub, "&Shell Extensions", 1, $enhShellSub)
	_GUICtrlMenuEx_AddMenuItem($enhShellSub, "&Ownership", 1305, $shell20[18])
	_GUICtrlMenuEx_SetItemIcon($accEnhSub, 0, $shell20[17])
	_GUICtrlMenuEx_SetItemIcon($accMenu, 3, $shell20[11])

	_GUICtrlMenuEx_AddMenuBar($accMenu)
	_GUICtrlMenuEx_AddMenuItem($accMenu, "Notebook &Indicators", 1307, $shell20[19])
	_GUICtrlMenuEx_AddMenuItem($accMenu, "Quick &Erase", 1309, $shell20[26])
	_GUICtrlMenuEx_AddMenuBar($accMenu)

	_LoaderUpdate(18)
	$accComPSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($accComPSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($accMenu, "Command &Prompt", 4, $accComPSub)
	_GUICtrlMenuEx_AddMenuItem($accComPSub, "Command &Prompt", 1301, $shell20[12])
	_GUICtrlMenuEx_AddMenuItem($accComPSub, "Command &Prompt repair", 1302, $shell20[13])
	_GUICtrlMenuEx_SetItemIcon($accMenu, 6, $shell20[12])

	_GUICtrlMenuEx_AddMenuItem($accMenu, "&Console " & @TAB & "Ctrl+Alt+S", 1303, $shell20[16])


	_LoaderUpdate(19)
	; ===============================================================================================================================
	; Administration Menu
	; ===============================================================================================================================

	$adminMenu = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($adminMenu, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($mainMenu, "&Administration", 4, $adminMenu)


	_LoaderUpdate(20)
	; ===============================================================================================================================
	; Repair Menu
	; ===============================================================================================================================

	$repairMenu = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($repairMenu, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($mainMenu, "&Repair", 4, $repairMenu)

	$repWinSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($repWinSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($repairMenu, "&Windows", 1, $repWinSub)
	_GUICtrlMenuEx_AddMenuItem($repWinSub, "Repair &font registrations", 1501, $shell20[21])
	_GUICtrlMenuEx_SetItemIcon($repairMenu, 0, $shell20[20])


	_LoaderUpdate(21)
	; ===============================================================================================================================
	; Security Menu
	; ===============================================================================================================================

	$securMenu = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($securMenu, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($mainMenu, "&Confidence", 5, $securMenu)

	$secVClSub = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($secVClSub, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($securMenu, "&Virus Cleaners", 1, $secVClSub)
	_GUICtrlMenuEx_AddMenuItem($secVClSub, "ClamWin Antivirus Scanner", 1601, $shell20[23])
	_GUICtrlMenuEx_SetItemIcon($securMenu, 0, $shell20[22])


	_LoaderUpdate(22)
	; ===============================================================================================================================
	; System Menu
	; ===============================================================================================================================
	$sysMenu = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_SetMenuStyle($sysMenu, 0x04000000) ;~ $MNS_CHECKORBMP
	_GUICtrlMenu_AddMenuItem($mainMenu, "&System", 6, $sysMenu)
_GUICtrlMenuEx_AddMenuItem($sysMenu, "Windows &version", 1701, $shell20[20])


	_LoaderUpdate(23)
	_GUICtrlMenuEx_SetItemIcon($mainMenu, 0, $winOrbIco)

	_LoaderUpdate(24)
	_GUICtrlMenu_SetMenu($doorsForm, $mainMenu)

	;~ _GUIExtender_Init($doorsForm, 0, 0)
	;~ _GUIExtender_Section_Start(0, 0)

;~ 	If @OSVersion = "WIN_2003" Then
;~ 		$hMemIco = GUICtrlCreateIcon("", 0, 10, 5, 16, 16)
;~ 		$hCPUIco = GUICtrlCreateIcon("", 0, 195, 5, 16, 16)
;~ 	Else
;~ 		$hMemIco = GUICtrlCreateIcon($DoorsRes, 209, 10, 5, 16, 16)
;~ 		$hCPUIco = GUICtrlCreateIcon($DoorsRes, 210, 195, 5, 16, 16)
;~ 	EndIf

;~ 	GuiCtrlCreateLabel("", 35, 5, 100, 8)
;~ 	GUICtrlSetBkColor(-1, 0x071320)
;~ 	$memUsageBar = GuiCtrlCreateLabel("", 36, 6, 10, 6)
;~ 	GUICtrlSetBkColor($memUsageBar, 0x68CEFA)
;~ 	$lblMemUsage = GuiCtrlCreateLabel("100%", 140, 3, 50, 11)
;~ 	GuiCtrlSetFont($lblMemUsage, 7, 400, -1, "Tahoma", 5)

;~ 	GuiCtrlCreateLabel("", 35, 15, 100, 8)
;~ 	GUICtrlSetBkColor(-1, 0x071320)
;~ 	$pageUsBar = GuiCtrlCreateLabel("", 36, 16, 50, 6)
;~ 	GUICtrlSetBkColor($pageUsBar, 0xFABA00)
;~ 	$lblPageUs = GuiCtrlCreateLabel("100%", 140, 14, 50, 11)
;~ 	GuiCtrlSetFont($lblPageUs, 7, 400, -1, "Tahoma", 5)

;~ 	GuiCtrlCreateLabel("", 215, 6, 100, 12)
;~ 	GUICtrlSetBkColor(-1, 0x071320)
;~ 	GuiCtrlCreateLabel("", 216, 7, 50, 10)
;~ 	GUICtrlSetBkColor(-1, 0x7CCC7C)

;~ 	GUICtrlCreateLabel("", -50, 29, 800, 1) ;~ Bottom Bar
;~ 	GUICtrlSetBkColor(-1, 0xd9d9d9)
;~ 	GuiCtrlCreateLabel("", -50, 30, 800, 20)
;~ 	GUICtrlSetBkColor(-1, 0xe5e5e5)
;~ 	GUICtrlCreateLabel("", -50, 50, 800, 1) ;~ Bottom Bar
;~ 	GUICtrlSetBkColor(-1, 0xf0f0f0)
;~ 	GUICtrlCreateLabel("", -50, 52, 800, 1) ;~ Bottom Bar
;~ 	GUICtrlSetBkColor(-1, 0xd9d9d9)

;~ 	$icoKState = GUICtrlCreateIcon($DoorsRes, 201, 5, 32, 16, 16)
;~ 	$DoorsTime = GuiCtrlCreateLabel("00:00:00", 680, 33, 300, 20)
;~ 	GUICtrlSetColor($DoorsTime, 0x071320)
;~ 	GuiCtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;~ 	GuiCtrlSetFont(-1, 7.5, 400, -1, "Verdana")

;~ 	$btnGuiExtend = GuiCtrlCreateButton("5", 710, 3, 23, 23)
;~ 	GUICtrlSetFont($btnGuiExtend, 10, 400, 0, "Webdings")
;~ 	GUICtrlSetOnEvent($btnGuiExtend, "_GuiExtender")

;~ 	GUICtrlCreateCheckBox(Chr(0x61), 688, 3, 23, 23, $BS_PUSHLIKE)
;~ 	GUICtrlSetFont(-1, 10, 400, 0, "Webdings")


;~ 	$doorsIcon = GUICtrlCreateIcon(@ScriptFullPath, 99, 20, 60, 64, 64, $SS_NOTIFY)
;~ 	GuiCtrlSetCursor($doorsIcon, 0)

	_LoaderUpdate(27)
	Local $QuiB1, $QuiB2, $QuiB3, $QuiB4, $QuiB5, $QuiB6, $QuiB7, $QuiB8, $QuiB9, $QuiE

	$quiB1 = GUICtrlCreateButton("1", 15, 130, 25, 23)
	If $CCom1 = "" Then GuiCtrlSetState($QuiB1, $GUI_DISABLE)
	$QuiB2 = GUICtrlCreateButton("2", 40, 130, 25, 23)
	$QuiB3 = GUICtrlCreateButton("3", 65, 130, 25, 23)
	$QuiB4 = GUICtrlCreateButton("4", 15, 153, 25, 23)
	$QuiB5 = GUICtrlCreateButton("5", 40, 153, 25, 23)
	$QuiB6 = GUICtrlCreateButton("6", 65, 153, 25, 23)
	$QuiB7 = GUICtrlCreateButton("7", 15, 176, 25, 23)
	$QuiB8 = GUICtrlCreateButton("8", 40, 176, 25, 23)
	$QuiB9 = GUICtrlCreateButton("9", 65, 176, 25, 23)
	$QuiE = GUICtrlCreateButton("...", 15, 199, 75, 23)


	_LoaderUpdate(28)
	_WinAPI_DestroyIcon($winOrbIco)

	For $x = 0 To UBound($goIcon) - 1
		_WinAPI_DestroyIcon($goIcon[$x])
	Next
	For $c = 0 To UBound($shell20) - 1
		_WinAPI_DestroyIcon($shell20[$c])
	Next

	_LoaderUpdate(29)


	;~ $iMore_Section = _GUIExtender_Section_Start(0, 465)

	_LoaderUpdate(96)
	GUICtrlCreateGroup("", $iaHGap, $iaVGap, Round($iaCount / 2) * $iaSize + (2 + (Round($iaCount / 2) + 1) * $iaGap), 2 * $iaSize + 3 * $iaGap + 10)
	For $a = 0 To $iaCount
		If $a < $iaCount / 2 Then
			$alpIcon[$a] = GUICtrlCreateIcon(	"", 0, $iaHGap + $iaGap + ($a * $iaSize) + ($a * $iaGap) + 1, _
												$iaVGap + 2 * $iaGap + 2, $iaSize, $iaSize, $SS_NOTIFY)
		Else
			Local $b = $a - Round($iaCount / 2)
			$alpIcon[$a] = GUICtrlCreateIcon(	"", 0, $iaHGap + $iaGap + ($b * $iaSize) + ($b * $iaGap) + 1, _
												$iaVGap + 3 * $iaGap + $iaSize + 2, $iaSize, $iaSize, $SS_NOTIFY)
		EndIf
		GuiCtrlSetCursor($alpIcon[$a], 0)
		GUICtrlSetResizing($alpIcon[$a], $GUI_DOCKALL)
	Next

	_LoaderUpdate(97)

	GUICtrlSetOnEvent($alpIcon[7], "_LaunchRevoUninstaller")
	GUICtrlSetOnEvent($alpIcon[8], "_LaunchDefragmentation")
	GUICtrlSetOnEvent($alpIcon[13], "_LaunchConsole")


	GUICtrlCreateGroup("", $ibHGap, $ibVGap, Ceiling($ibCount / 2) * $ibSize + (2 + (Ceiling($ibCount / 2) + 1) * $ibGap), 2 * $ibSize + 3 * $ibGap + 10)
	For $i = 0 To $ibCount
		If $i < $ibCount / 2 Then
			$blpIcon[$i] = GUICtrlCreateIcon(	"", 0, $ibHGap + $ibGap + ($i * $ibSize) + ($i * $ibGap) + 1, _
												$ibVGap + 2 * $ibGap + 2, $ibSize, $ibSize, $SS_NOTIFY)
		Else
			Local $j = $i - Ceiling($ibCount / 2)
			$blpIcon[$i] = GUICtrlCreateIcon(	"", 0, $ibHGap + $ibGap + ($j * $ibSize) + ($j * $ibGap) + 1, _
												$ibVGap + 3 * $ibGap + $ibSize + 2, $ibSize, $ibSize, $SS_NOTIFY)
		EndIf
		;GUICtrlSetOnEvent($lpIcon[$a], "_StartLaunchPadApps")
		GuiCtrlSetCursor($blpIcon[$i], 0)
	Next

	$eStatus = GUICtrlCreateEdit("", 15, 344, 525, 110, BitOR($WS_VSCROLL, $ES_READONLY, $ES_AUTOVSCROLL, $WS_HSCROLL))
	GUICtrlSetBkColor($eStatus, 0xFFFFFF)


	; ===============================================================================================================================
	; Recycle Bin Group
	; ===============================================================================================================================

	Local $RecIcon, $LBinSize, $LBinItems, $BtnBinEm, $BtnDClean
	Local $RecBinCon, $RBConOpen, $RBConExplore, $RBConEmp, $RBConProp

	GUICtrlCreateGroup("", 578, 305, 150, 150)
	$RecIcon = GUICtrlCreateIcon(@ScriptFullPath, 212, 668, 325, 48, 48, BitOR($SS_NOTIFY,$WS_GROUP))
	GUICtrlSetTip($RecIcon, "Open the Recycle Bin. Right-Click" & @CRLF & _
							"for more options.", "Recycle Bin", 1, 1)
	GuiCtrlSetCursor($RecIcon, 0)
	$LBinSize = GUICtrlCreateLabel("0 MB", 590, 330, 80, 17)
	GUICtrlSetFont(-1, 8.5, 800, 0, "Verdana")
	$LBinItems = GUICtrlCreateLabel("0 Objects", 590, 350, 80, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1) ; Close Group
	$RecBinCon	= GUICtrlCreateContextMenu($RecIcon)
	$RBConOpen = GuiCtrlCreateMenuItem("Open", $RecBinCon)
	$RBConExplore = GuiCtrlCreateMenuItem("Explore", $RecBinCon)
	GUICtrlSetState($RBConOpen, $GUI_DEFBUTTON)
	$RBConEmp = GuiCtrlCreateMenuItem("Empty Recycle Bin", $RecBinCon)
	GuiCtrlCreateMenuItem("", $RecBinCon)
	$RBConProp = GuiCtrlCreateMenuItem("Properties...", $RecBinCon)


	;~ _GUIExtender_Section_End()

	;$btnMore = GuiCtrlCreateButton(6, 650, 10, 23, 23)
	;GUICtrlSetFont($btnMore, 10, 400, 0, "Webdings")

	;GUICtrlSetOnEvent($btnMore, "_MoreGUI")

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CLoseDoors")
	GUISetOnEvent($GUI_EVENT_RESTORE, "_GuiUpdate")
	;~ GUISetOnEvent($GUI_EVENT_RESIZED, "_GetNewGUIPosition")

	GUISetState(@SW_SHOW, $doorsForm)
	_GuiUpdate()

	_LoaderUpdate(98)
	_ReduceMem()

	_LoaderUpdate(99)
	AdlibRegister("_ReduceMem", 5000)
	AdlibRegister("_GatherDisplayStats", 1000)
	AdlibRegister("_toggleKeysState", 200)

	_GatherDisplayStats()
;~ 	_LoaderUpdate(100)

	While 1

		_CheckDock()
		_GetNewGUIPosition()

		If $GuiUpdate = True Then
			_GuiUpdate()
		EndIf

		Sleep(50) ; Idle
		_WinAPI_EmptyWorkingSet()

	WEnd

EndFunc


Func _GetNewGUIPosition()

	Local $guiDoorsPos = WinGetPos($doorsForm)
	$guiDoorsPosX = $guiDoorsPos[0]
	$guiDoorsPosY = $guiDoorsPos[1]

EndFunc


Func _GuiExtender()
	If IsArray($guiDoorsCoords) Then
		If $guiDoorsRetracted = False Then
			_GuiRetract(465)
		ElseIf $guiDoorsRetracted = True Then
			_GuiExpand()
		EndIf
	EndIf
EndFunc


Func _GuiRetract($iSize)
	WinMove($doorsForm, "", $guiDoorsPosX, $guiDoorsPosY, $guiDoorsCoords[2], $guiDoorsCoords[3] - $iSize)
	GUICtrlSetData($btnGuiExtend, 6)
	$guiDoorsRetracted = True
EndFunc

Func _GuiExpand()
	WinMove($doorsForm, "", $guiDoorsPosX, $guiDoorsPosY, $guiDoorsCoords[2], $guiDoorsCoords[3])
	GUICtrlSetData($btnGuiExtend, 5)
	_GuiUpdate()
	$guiDoorsRetracted = False
EndFunc


Func WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
	Local $Code =_WinAPI_HiWord($wParam)
	If $Code = 0 Then _RunMenuCommand(_WinAPI_LoWord($wParam))
EndFunc


Func _CheckDock()

;~ 	Local $winCoord, $winStart, $X2, $Y2, $Dockit

;~ 	$winCoord = WinGetPos($doorsForm)

;~ 	$X2 = $winCoord[2] + $winCoord[0] - 1
;~     $Y2 = $winCoord[3] + $winCoord[1] - 1

;~ 	$winStart = WinGetPos('classname=Shell_TrayWnd')

;~ 	If $winCoord[1] < 50 And $winCoord[1] <> 0 Then
;~         ConsoleWrite("Dock Top "&$winCoord[1]&@CRLF)
;~ 		$Dockit = True
;~         $winCoord[1]=0
;~     EndIf

;~ If $Dockit Then WinMove($doorsForm,'',$winCoord[0],$winCoord[1])


EndFunc


Func _ReduceMem()

	Local $aProcsList, $aPIniList

	$aPIniList = StringSplit("cmd.exe|Command.exe|Console.exe|DiskDefrag.exe|firefox.exe|plugin-container.exe|Revouninstaller.exe", "|")

	$aProcsList = ProcessList()
	For $i = 1 To $aProcsList[0][0]
		For $x = 1 To $aPIniList[0]
			If $aProcsList[$i][0] = $aPIniList[$x] Then
				_WinAPI_EmptyWorkingSet($aProcsList[$i][1])
			EndIf
		Next
	Next

EndFunc





Func _CloseDoors()

	GUISetState(@SW_HIDE, $doorsForm)

	_GUICtrlMenuEx_DestroyMenu($mainMenu)

	_GUICtrlMenuEx_DestroyMenu($goMenu)
	_GUICtrlMenuEx_DestroyMenu($goCompSub)
	_GUICtrlMenuEx_DestroyMenu($goProgSub)
	_GUICtrlMenuEx_DestroyMenu($progMulitSub)
	_GUICtrlMenuEx_DestroyMenu($goCSFSub)

	_GUICtrlMenuEx_DestroyMenu($doorsMenu)
	_GUICtrlMenuEx_DestroyMenu($dlogSub)

	_GUICtrlMenuEx_DestroyMenu($accMenu)
	_GUICtrlMenuEx_DestroyMenu($accMaintSub)
	_GUICtrlMenuEx_DestroyMenu($accOptiSub)
	_GUICtrlMenuEx_DestroyMenu($optiMemSub)
	_GUICtrlMenuEx_DestroyMenu($accEnhSub)
	_GUICtrlMenuEx_DestroyMenu($enhShellSub)
	_GUICtrlMenuEx_DestroyMenu($accComPSub)

	_GUICtrlMenuEx_DestroyMenu($adminMenu)
	_GUICtrlMenuEx_DestroyMenu($repairMenu)
	_GUICtrlMenuEx_DestroyMenu($repWinSub)

	_GUICtrlMenuEx_DestroyMenu($securMenu)
	_GUICtrlMenuEx_DestroyMenu($secVClSub)

	_GUICtrlMenuEx_DestroyMenu($sysMenu)

	GUIDelete($doorsForm)
	TraySetState(2)

	If $ExitProcess = True Then
		Local $ProcessID = ProcessExists(@ScriptName) ; Will return the PID or 0 if the process isn't found.
		If $ProcessID Then ProcessClose($ProcessID)
	EndIf

	Exit

EndFunc


Func _GuiUpdate()

	Local $hPIcon[3]
	Local $memIco, $cpuIco

	$hPIcon[0] = _WinAPI_ShellExtractIcon($DoorsRes, -225, 48, 48)
	$hPIcon[1] = _WinAPI_ShellExtractIcon($DoorsRes, -226, 48, 48)
	$hPIcon[2] = _WinAPI_ShellExtractIcon($DoorsRes, -227, 48, 48)

	$memIco = _WinAPI_ShellExtractIcon($DoorsRes, -209, 16, 16)
	$cpuIco = _WinAPI_ShellExtractIcon($DoorsRes, -210, 16, 16)

	_SetHIcon($alpIcon[7], $hPIcon[0], -1)
	GUICtrlSetTip($alpIcon[7], "Uninstall software and remove unwanted programs installed on your computer", "Revo Uninstaller", 1, 2)
	_SetHIcon($alpIcon[8], $hPIcon[1], -1)
	GUICtrlSetTip($alpIcon[8], "Defragments your disks so that your computer runs faster and more efficiently.", "Disk Defragmenter", 1, 2)
	_SetHIcon($alpIcon[13], $hPIcon[2], -1)
	GUICtrlSetTip($alpIcon[13], "Performs text-based (command-line) functions.", "Console " & FileGetVersion($PE_CONSOLE), 1, 2)

	For $j = 0 To UBound($hPIcon) - 1
		_WinAPI_DestroyIcon($hPIcon[$j])
	Next

	If @OSVersion = "WIN_2003" Then
		_SetHIcon($hMemIco, $memIco, -1)
		_SetHIcon($hCPUIco, $cpuIco, -1)

		_WinAPI_DestroyIcon($memIco)
		_WinAPI_DestroyIcon($cpuIco)
	EndIf

	$GuiUpdate = False

EndFunc



Func _RunMenuCommand($mnuID)
	_StartProcessing()
	Switch $mnuID
		Case 1101
			ShellExecute("explorer", "/e,::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
		Case 1102
			ShellExecute("explorer", "/e," & @HomeDrive)
		Case 1103
			_LaunchPowerEnc()
		Case 1108
			;ShellExecute("explorer", "/e,::{450D8FBA-AD25-11D0-98A8-0800361B1103}")
			ShellExecute(@AppDataDir & "\Microsoft\Windows\Libraries\Documents.library-ms")

		Case 1201
			;~ Start Doors Update
			_LaunchDoorsUpdate()
		Case 1202
			WinSetState($doorsForm, "", @SW_MINIMIZE)
		Case 1203
			_CloseDoors()
		Case 1204
			_OpenFolder($DIR_LOGGING)
		Case 1205
			_OpenTextFile($LOGGFILE_DOORS)
		Case 1301
			_LaunchCommandPrompt()
		Case 1302
			_StartCommandPromptRepair()
		Case 1303
			_LaunchConsole()
		Case 1304
			_LaunchDefragmentation()
		Case 1305
			_LaunchOwnership()
		Case 1306
			_LaunchRevoUninstaller()
		Case 1307
			_LaunchIndicators()
		Case 1308
			ShellExecute($DIR_CONSOLE & "\Command.exe", "/DEFRAG", $DIR_CONSOLE, "", @SW_HIDE)
		Case 1309
			_LaunchQuickErase()
		Case 1310
		Case 1501
			_RepairFontRegistrations()
		Case 1601
			_LaunchClamWinAntivirus()
		Case 1701
			;~ _WinAPI_AboutDlg("", "", "", 0, $doorsForm)
			_WinAPI_AboutDlg("", "", "", 0)
;~ 		Case 1301
;~ 			ShellExecute("calc")
;~ 		Case 1302
;~ 			ShellExecute("charmap")
;~ 		Case 1601
;~ 			_StartDefragmentation()
;~ 		Case 1701
;~ 			_LaunchFixedLocation($PE_WINREPAIR)
;~ 		Case 1702
;~ 			_RestoreWindowsShell()
;~ 		Case 1703
;~ 			_RepairMissingCDIcon()
;~ 		Case 1704
;~ 			_ResetAutorunSettings()
;~ 		Case 1705
;~ 			_UpdateCDDriveFirmware()
;~ 		Case 1801
;~ 			_AutorunProtection()
;~ 			_GUICtrlMenu_SetItemText($confiMenu, 0, _SetAutorunProtectionStatus())
;~ 		Case 1901
;~ 			_LaunchConsole()
	EndSwitch
	_EndProcessing()
EndFunc


Func _GatherDisplayStats()

	Local $memStats = MemGetStats()
	Local $pageUsPerc = Round((($memStats[3] - $memStats[4]) / $memStats[3]) * 100)
	Local $CurTime = _Date_Time_GetLocalTime()

	GuiCtrlSetData($DoorsTime, _Date_Time_SystemTimeToTimeStr($CurTime))

	If $MemStats[0] <> $TM1Free Then
		_DrawStatusSizeFromPercentage($memUsageBar, $memStats[0], 35, 5, 100, 8)
		GuiCtrlSetData($lblMemUsage, $memStats[0] & "%")
		$TM1Free = $memStats[0]
	EndIf

	If $pageUsPerc <> $TM2Free Then
		_DrawStatusSizeFromPercentage($pageUsBar, $pageUsPerc, 35, 15, 100, 8)
		GuiCtrlSetData($lblPageUs, $PageUsPerc & "%")
		$TM2Free = $pageUsPerc
	EndIf


EndFunc ;~ ==> _GatherDisplayStats()


Func _toggleKeysState()

	Local $KeyState = 0

	If _WinAPI_GetKeyState(0x90) <> 0 then
		$KeyState = $KeyState  + 1
	EndIf

	If _WinAPI_GetKeyState(0x91) <> 0 Then
		$KeyState = $KeyState  + 2
	EndIf

	If _WinAPI_GetKeyState(0x14) <> 0 Then
		$KeyState = $KeyState  + 4
	EndIf

	If $KSDiff <> $KeyState Then

	Select
		Case $KeyState = 1
			GUICtrlSetImage($icoKState, $DoorsRes, 202)
		Case $KeyState = 2
			GUICtrlSetImage($icoKState, $DoorsRes, 203)
		Case $KeyState = 3
			GUICtrlSetImage($icoKState, $DoorsRes, 204)
		Case $KeyState = 4
			GUICtrlSetImage($icoKState, $DoorsRes, 205)
		Case $KeyState = 5
			GUICtrlSetImage($icoKState, $DoorsRes, 206)
		Case $KeyState = 6
			GUICtrlSetImage($icoKState, $DoorsRes, 207)
		Case $KeyState = 7
			GUICtrlSetImage($icoKState, $DoorsRes, 208)
		Case Else
			GUICtrlSetImage($icoKState, $DoorsRes, 201)
	EndSelect

	$KSDiff = $KeyState
	EndIf

EndFunc


Func _StartProcessing()
	GUISetCursor(15)
EndFunc


Func _EndProcessing()
	GUISetCursor(2)
EndFunc


;~ Func _CheckIntegrity()

;~ 	If Not FileExists($DoorsRes) Then
;~ 		MsgBox(262192, 	"Resource not found!", "An important resource file could not be found @ [" & $DoorsRes & "]. " & _
;~ 						"Although Doors can still function without it, the menus will display without pretty little icons." & @CRLF, 60)

;~ 	EndIf

;~ 	If Not FileExists($DIR_LOGGING) Then DirCreate($DIR_LOGGING)

;~ EndFunc