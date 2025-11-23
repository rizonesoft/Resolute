

#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\memBoost\memBoost.ico
#AutoIt3Wrapper_Res_Description=Rizone Memory Booster
#AutoIt3Wrapper_Res_Fileversion=2.0.0.1845
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© 2010 Rizone Technologies
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\00.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\01.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\02.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\03.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\04.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\05.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\06.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\07.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\08.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\09.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\10.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\11.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\12.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\13.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\14.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\15.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\16.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\17.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\18.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\19.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\20.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\21.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\22.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\23.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\24.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\25.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\26.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\27.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\28.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\29.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\30.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\31.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\32.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\33.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\34.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\35.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\36.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\37.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\38.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\39.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\memBoost\40.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


Opt("TrayMenuMode", 3) ;~ Default tray menu items (Script Paused/Exit) will not be shown.
Opt("GUIOnEventMode", 1)
Opt("TrayOnEventMode", 1)
Opt("MustDeclareVars", 1)


#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <Constants.au3>
#include <WinAPIEx.au3>
#Include <Misc.au3>


Global Const $MBTitle = "Memory Booster", $MBver = FileGetVersion(@ScriptFullPath)
Global Const $MBSettings = @ScriptDir & "\memBoost.ini"
Global Const $MBHelpFile = @ScriptDir & "\Support\memBoost.chm"

;~ Settings
;~ Global $OSVer
Global $Initializing = 1, $SetOnTop, $SetNotify, $SetOpMeth, $SetAutoCount
Global $SetPlSounds, $SetPlWarn, $SetWarnEvery, $SetWarnLoad, $OSG

Global $MEMBOOST_GUI, $ABOUT_MENUITEM, $SHOWHIDE_TRAY
Global $MemInfo, $Count = 0, $TotalCount = 0, $miOptions, $btnOptions, $OptionsDlg, $chkAutStart, $chkOnTop, $chkShowNotify
Global $radIntel, $radAuto, $radNoAuto, $comboAutSec, $BtnOptApply, $chkPlSounds, $chkPlWarn, $cmPlWarnEvery, $cmPlWarnLoad
Global $btnOptimize
Global $CPUSAGE_ICON, $CPUSAGE_LABEL, $MEM_DIFF, $MEM_DIFF_PERC, $RAMUSAGE_ICON, $RAMUSAGE_LABEL
Global $PROGRESS_OPTIMIZE, $PROGRESS_COUNT

Global $IDLETIME, $KERNELTIME, $USERTIME
Global $STARTIDLE, $STARTKERNEL, $STARTUSER
Global $ENDIDLE, $ENDKERNEL, $ENDUSER
; Global $Timer

$IDLETIME   = DllStructCreate("dword;dword")
$KERNELTIME = DllStructCreate("dword;dword")
$USERTIME   = DllStructCreate("dword;dword")


If @OSVersion = "WIN_2000" Or @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then
	$OSG = "WIN6"
Else
	$OSG = "WIN8"
EndIf

_Singleton(@ScriptName, 0)


$SetOnTop = IniRead($MBSettings, "Main", "SetWindowOnTop", 1)
$SetNotify = IniRead($MBSettings, "Main", "ShowNotifications", 1)
$SetOpMeth = IniRead($MBSettings, "Modes", "DefaultOptimizationMethod", 0)
$SetAutoCount = IniRead($MBSettings, "Modes", "AutoOptimizationCount", 25)
$SetPlSounds = IniRead($MBSettings, "Sounds", "PlaySystemSounds", 1)
$SetPlWarn = IniRead($MBSettings, "Sounds", "PlayWarnings", 1)
$SetWarnEvery = IniRead($MBSettings, "Sounds", "PlayWarnEvery", 3)
$SetWarnLoad = IniRead($MBSettings, "Sounds", "PlayWarnIfExceed", 80)


If $CmdLine[0] == 0 Then
	_StartMainGUI(0)
ElseIf StringLower($CmdLine[1]) = "/smin" Then
	_StartMainGUI(1)
EndIf


Func _StartMainGUI($StartMin = 0)

	Local $mFile, $miOptNow, $miClose
	Local $mHelp, $miContents, $miHome, $miRSS, $miFacebook, $miTwitter
	Local $btnClose
	Local $trOptNow, $trDefrag, $trClose

	$MEMBOOST_GUI = GUICreate($MBTitle & " " & $MBver, 380, 350, -1, -1, -1, $WS_EX_COMPOSITED)
	GUISetFont(8.5, 400, 0, "Tahoma")
	GUISetHelp("hh.exe " & $MBHelpFile, $MEMBOOST_GUI)

	$mFile = GUICtrlCreateMenu("&File")
	$miOptNow = GUICtrlCreateMenuItem("&Optimize memory", $mFile)
	$miOptions = GUICtrlCreateMenuItem("O&ptions...", $mFile)
	GUICtrlCreateMenuItem("", $mFile)
	$miClose = GUICtrlCreateMenuItem("&Close memBooster", $mFile)

	$mHelp = GUICtrlCreateMenu("&Help")
	$miContents = GUICtrlCreateMenuItem("&Contents " & @TAB & "F1", $mHelp)
	$ABOUT_MENUITEM = GUICtrlCreateMenuItem("&About...", $mHelp)
	GUICtrlCreateMenuItem("", $mHelp)
	$miHome = GUICtrlCreateMenuItem("Rizonesoft Home", $mHelp)
	GUICtrlCreateMenuItem("", $mHelp)
	$miRSS = GUICtrlCreateMenuItem("Subscribe in a Reader", $mHelp)
	$miFacebook = GUICtrlCreateMenuItem("Our Facebook page", $mHelp)
	$miTwitter = GUICtrlCreateMenuItem("Follow us on Twitter", $mHelp)

	GUICtrlSetOnEvent($miOptNow, "_OptimizeItemPressed")
	GUICtrlSetOnEvent($miOptions, "_OptionsDlg")
	GUICtrlSetOnEvent($miClose, "_CLosedClicked")

	$PROGRESS_COUNT = GUICtrlCreateLabel("", 35, 161, 304, 1) ;~ Bottom Bar
	GUICtrlSetBkColor(-1, 0x13ff92)
	GUICtrlCreateLabel("", 34, 160, 306, 3) ;~ Bottom Bar
	GUICtrlSetBkColor(-1, 0x014804a)

	$PROGRESS_OPTIMIZE = GUICtrlCreateLabel("", 35, 153, 304, 4) ;~ Bottom Bar
	GUICtrlSetBkColor(-1, 0x13ff92)
	GUICtrlCreateLabel("", 34, 152, 306, 6) ;~ Bottom Bar
	GUICtrlSetBkColor(-1, 0x014804a)
	GUICtrlCreateLabel("", 32, 150, 310, 15) ;~ Bottom Bar
	GUICtrlSetBkColor(-1, 0x0F1318)

	GUICtrlCreateLabel("", 242, 20, 100, 125) ;~ Bottom Bar
	GUICtrlSetBkColor(-1, 0x0F1318)

	$RAMUSAGE_ICON = GUICtrlCreateIcon(@ScriptFullPath, 201, 155, 50, 64, 64)
	$RAMUSAGE_LABEL = GUICtrlCreateLabel("1.00 GB", 155, 120, 64, -1, $SS_CENTER)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GuiCTrlSetColor(-1, 0x13FF92)

	GUICtrlCreateLabel("", 137, 20, 100, 125) ;~ Bottom Bar
	GUICtrlSetBkColor(-1, 0x0F1318)

	$CPUSAGE_ICON = GUICtrlCreateIcon(@ScriptFullPath, 201, 50, 50, 64, 64)
	$CPUSAGE_LABEL = GUICtrlCreateLabel("0%", 50, 120, 64, -1, $SS_CENTER)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	GuiCTrlSetColor(-1, 0x13FF92)
	GUICtrlCreateLabel("", 32, 20, 100, 125) ;~ Bottom Bar
	GUICtrlSetBkColor(-1, 0x0F1318)

	GUICtrlCreateLabel("", -10, -10, 450, 225) ;~ Bottom Bar
	GUICtrlSetBkColor(-1, 0x151C23)

	$btnOptimize = GUICtrlCreateButton("Optimize", 32, 230, 100, 35, $BS_DEFPUSHBUTTON)
	GUICtrlSetTip($btnOptimize,	"Optimize Memory now!", "Optimize Memory", 1, 1)
	GuiCtrlSetState($btnOptimize, $GUI_FOCUS)
	$btnOptions = GUICtrlCreateButton("Options...", 137, 230, 100, 35)
	$btnClose = GUICtrlCreateButton("Close", 242, 230, 100, 35)

	GUICtrlSetOnEvent($btnOptimize, "_OptimizeItemPressed")
	GUICtrlSetOnEvent($btnOptions, "_OptionsDlg")
	GUICtrlSetOnEvent($btnClose, "_CLosedClicked")


	GUISetOnEvent($GUI_EVENT_CLOSE, "_HideMainForm")


	$trOptNow = TrayCreateItem("&Optimize memory")
	TrayCreateItem("")
	$SHOWHIDE_TRAY = TrayCreateItem("&Hide memBooster")
	TrayCreateItem("")
	$trClose = TrayCreateItem("&Close memBooster")

	TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "_ShowHideMainForm")
	TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "_ShowHideMainForm")

	TrayItemSetOnEvent($trOptNow, "_ClearProcessesWorkingSet")
	TrayItemSetOnEvent($SHOWHIDE_TRAY, "_ShowHideMainForm")
	TrayItemSetOnEvent($trClose, "_CLosedClicked")

	If $StartMin = 0 Then
		GUISetState(@SW_SHOW, $MEMBOOST_GUI)
	Else
		GUISetState(@SW_HIDE, $MEMBOOST_GUI)
		TrayItemSetText($SHOWHIDE_TRAY, "&Show memBooster")
	EndIf

	TraySetIcon(@ScriptFullPath, 99)
	TraySetState()
	TraySetClick(8)

;~ 	;GUISetBkColor(0xEBEBEB)

;~ 	GUICtrlCreateIcon(@ScriptFullPath, 201, 260, 50, 64, 64)
;~ 	GUICtrlCreateLabel("1.00 GB", 260, 120, 64, -1, $SS_CENTER)
;~ 	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;~ 	GuiCTrlSetColor(-1, 0x13FF92)



;~ 	GUICtrlCreateLabel("Smart: ", 32, 175, 50, -1, $SS_RIGHT)
;~ 	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;~ 	GUICtrlSetColor(-1, 0xd7d9db)
;~ 	GUICtrlCreateLabel(" On", 82, 175, 50, -1)
;~ 	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;~ 	GUICtrlSetColor(-1, 0x13ff92)
;~ 	GUICtrlCreateLabel("Auto: ", 132, 175, 50, -1, $SS_RIGHT)
;~ 	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;~ 	GUICtrlSetColor(-1, 0xd7d9db)
;~ 	GUICtrlCreateLabel(" On", 182, 175, 50, -1)
;~ 	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
;~ 	GUICtrlSetColor(-1, 0x13ff92)


	AdlibRegister("_TimerStuff", 1000)
	_TimerStuff()
	_SetWindowOnTop()

	While 1

		Sleep(25) ;~ Idle
		_WinAPI_EmptyWorkingSet()

	WEnd

EndFunc


Func _OpenHelpFileContents()
	If FileExists($MBHelpFile) Then ShellExecute($MBHelpFile)
EndFunc

Func _ShowHideMainForm()

	If TrayItemGetText($SHOWHIDE_TRAY) = "&Show memBooster" Then
		_ShowMainForm()
	Else
		_HideMainForm()
	EndIf

EndFunc


Func _HideMainForm()

	GUISetState(@SW_HIDE, $MEMBOOST_GUI)

	TrayTip("Clear Tray Tip", "", 0)
	If $SetNotify = 1 Then
		TrayTip($MBTitle & " is still running.",	$MBTitle & " will continue to run so that we can keep on monitoring your system, " & _
													"automatically optimize your memory and fix memory leaks. To close Memory Booster, " & _
													"right-click here and choose 'Close'.", 20, 1)
	EndIf
	TrayItemSetText($SHOWHIDE_TRAY, "&Show memBooster")
	;GUISetState(@SW_HIDE, $OptionsDlg)
	;GUISetState(@SW_HIDE, $AboutDlg)

EndFunc


Func _ShowMainForm()

	GUISetState(@SW_SHOW, $MEMBOOST_GUI)
	TrayItemSetText($SHOWHIDE_TRAY, "Hide Window")

EndFunc


Func _TimerStuff()

	$MemInfo = MemGetStats()

	_GetSystemTime($ENDIDLE, $ENDKERNEL, $ENDUSER)
	_CalculateProcessorUsage()
	_GetSystemTime($STARTIDLE, $STARTKERNEL, $STARTUSER)
	_UpdateMemoryStats()

	If $SetOpMeth = 2 Then

		;If GUICtrlRead($prCount) = 100 Then
;~ 			_GUICtrlStatusBar_SetText($hStatus, "", 0)
;~ 			_GUICtrlStatusBar_SetText($hStatus, "", 1)
			;GuiCtrlSetData($prCount, 0)
		_DrawStatusSizeFromPercentage($PROGRESS_COUNT, 0, 34, 160, 306, 3)
		;EndIf

	Else

		If $SetOpMeth = 1 Then

			$Count = $SetAutoCount

		ElseIf $SetOpMeth = 0 Then

			If $MemInfo[0] > 85 Then
				$Count = 5
			ElseIf $MemInfo[0] >= 65 And $MemInfo[0] < 85 Then
				$Count = 10
			ElseIf $MemInfo[0] >= 45 And $MemInfo[0] < 65 Then
				$Count = 15
			ElseIf $MemInfo[0] >= 25 And $MemInfo[0] < 45 Then
				$Count = 20
			Else
				$Count = 25
			EndIf

		EndIf

		If $TotalCount > 0 Then

			$TotalCount -= 1
			If $TotalCount < $Count Then
				;_GUICtrlStatusBar_SetText($hStatus, " Optimizing memory in " & $TotalCount & " seconds . . . . .", 0)
				;_GUICtrlStatusBar_SetText($hStatus, " T:" & $Count, 1)
				;GUICtrlSetData($prCount, ($TotalCount / $Count) * 100)
				_DrawStatusSizeFromPercentage($PROGRESS_COUNT, ($TotalCount / $Count) * 100, 34, 160, 306, 3)
			Else
				$TotalCount = $Count
			EndIf

		Else

			$TotalCount = $Count
			;$swAutoProcess = 1
			_ClearProcessesWorkingSet()

		EndIf

	EndIf

;~ 	_GUICtrlStatusBar_SetText($hStatus, " " & @HOUR & ":" & @MIN & ":" & @SEC & " " & _GetAMPM(@HOUR), 2)

;~ 	$Initializing = 0

EndFunc


Func _GetSystemTime(ByRef $sIdle, ByRef $sKernel, ByRef $sUser)

	DllCall("kernel32.dll", "int", "GetSystemTimes", "ptr", DllStructGetPtr($IDLETIME), _
            "ptr", DllStructGetPtr($KERNELTIME), _
            "ptr", DllStructGetPtr($USERTIME))

    $sIdle = DllStructGetData($IDLETIME, 1)
    $sKernel = DllStructGetData($KERNELTIME, 1)
    $sUser = DllStructGetData($USERTIME, 1)

EndFunc   ;==>_GetSysTime


Func _CalculateProcessorUsage()

    Local $iSystemTime, $iTotal, $iCalcIdle, $iCalcKernel, $iCalcUser
	Local $iCPUsageToIcon

    $iCalcIdle   = ($ENDIDLE - $STARTIDLE)
    $iCalcKernel = ($ENDKERNEL - $STARTKERNEL)
    $iCalcUser   = ($ENDUSER - $STARTUSER)

    $iSystemTime = ($iCalcKernel + $iCalcUser)
    $iTotal = Int(($iSystemTime - $iCalcIdle) * (100 / $iSystemTime))

	If $iTotal >= 0 And $iTotal <= 100 Then

		If $iTotal <= 0 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 201)
		ElseIf $iTotal <= 3 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 202)
		ElseIf $iTotal <= 5 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 203)
		ElseIf $iTotal <= 8 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 204)
		ElseIf $iTotal <= 10 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 205)
		ElseIf $iTotal <= 13 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 206)
		ElseIf $iTotal <= 15 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 207)
		ElseIf $iTotal <= 18 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 208)
		ElseIf $iTotal <= 20 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 209)
		ElseIf $iTotal <= 23 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 210)
		ElseIf $iTotal <= 25 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 211)
		ElseIf $iTotal <= 28 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 212)
		ElseIf $iTotal <= 30 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 213)
		ElseIf $iTotal <= 33 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 214)
		ElseIf $iTotal <= 35 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 215)
		ElseIf $iTotal <= 38 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 216)
		ElseIf $iTotal <= 40 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 217)
		ElseIf $iTotal <= 43 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 218)
		ElseIf $iTotal <= 45 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 219)
		ElseIf $iTotal <= 48 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 220)
		ElseIf $iTotal <= 50 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 221)
		ElseIf $iTotal <= 53 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 222)
		ElseIf $iTotal <= 55 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 223)
		ElseIf $iTotal <= 58 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 224)
		ElseIf $iTotal <= 60 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 225)
		ElseIf $iTotal <= 63 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 226)
		ElseIf $iTotal <= 65 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 227)
		ElseIf $iTotal <= 68 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 228)
		ElseIf $iTotal <= 70 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 229)
		ElseIf $iTotal <= 73 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 230)
		ElseIf $iTotal <= 75 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 231)
		ElseIf $iTotal <= 78 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 232)
		ElseIf $iTotal <= 80 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 233)
		ElseIf $iTotal <= 83 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 234)
		ElseIf $iTotal <= 85 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 235)
		ElseIf $iTotal <= 88 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 236)
		ElseIf $iTotal <= 90 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 237)
		ElseIf $iTotal <= 93 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 238)
		ElseIf $iTotal <= 95 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 239)
		ElseIf $iTotal <= 98 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 240)
		ElseIf $iTotal < 100 Then
			GUICtrlSetImage($CPUSAGE_ICON, @ScriptFullPath, 241)
		EndIf

		GuiCtrlSetData($CPUSAGE_LABEL, $iTotal & "%")

	EndIf

EndFunc


Func _UpdateMemoryStats()

	Local $MemUs = Round(($MemInfo[1] - $MemInfo[2]) / 1024)

	If $MEM_DIFF_PERC <> $MemInfo[0] Then

		If $MemInfo[0] >= 0 And $MemInfo[0] <= 100 Then

			If $MemInfo[0] <= 0 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 201)
			ElseIf $MemInfo[0] <= 3 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 202)
			ElseIf $MemInfo[0] <= 5 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 203)
			ElseIf $MemInfo[0] <= 8 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 204)
			ElseIf $MemInfo[0] <= 10 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 205)
			ElseIf $MemInfo[0] <= 13 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 206)
			ElseIf $MemInfo[0] <= 15 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 207)
			ElseIf $MemInfo[0] <= 18 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 208)
			ElseIf $MemInfo[0] <= 20 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 209)
			ElseIf $MemInfo[0] <= 23 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 210)
			ElseIf $MemInfo[0] <= 25 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 211)
			ElseIf $MemInfo[0] <= 28 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 212)
			ElseIf $MemInfo[0] <= 30 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 213)
			ElseIf $MemInfo[0] <= 33 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 214)
			ElseIf $MemInfo[0] <= 35 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 215)
			ElseIf $MemInfo[0] <= 38 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 216)
			ElseIf $MemInfo[0] <= 40 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 217)
			ElseIf $MemInfo[0] <= 43 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 218)
			ElseIf $MemInfo[0] <= 45 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 219)
			ElseIf $MemInfo[0] <= 48 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 220)
			ElseIf $MemInfo[0] <= 50 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 221)
			ElseIf $MemInfo[0] <= 53 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 222)
			ElseIf $MemInfo[0] <= 55 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 223)
			ElseIf $MemInfo[0] <= 58 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 224)
			ElseIf $MemInfo[0] <= 60 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 225)
			ElseIf $MemInfo[0] <= 63 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 226)
			ElseIf $MemInfo[0] <= 65 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 227)
			ElseIf $MemInfo[0] <= 68 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 228)
			ElseIf $MemInfo[0] <= 70 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 229)
			ElseIf $MemInfo[0] <= 73 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 230)
			ElseIf $MemInfo[0] <= 75 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 231)
			ElseIf $MemInfo[0] <= 78 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 232)
			ElseIf $MemInfo[0] <= 80 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 233)
			ElseIf $MemInfo[0] <= 83 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 234)
			ElseIf $MemInfo[0] <= 85 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 235)
			ElseIf $MemInfo[0] <= 88 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 236)
			ElseIf $MemInfo[0] <= 90 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 237)
			ElseIf $MemInfo[0] <= 93 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 238)
			ElseIf $MemInfo[0] <= 95 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 239)
			ElseIf $MemInfo[0] <= 98 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 240)
			ElseIf $MemInfo[0] <= 100 Then
				GUICtrlSetImage($RAMUSAGE_ICON, @ScriptFullPath, 241)
			EndIf



		EndIf


;~ 		GuiCtrlSetData($grMemUs, "RAM Usage: " & $MemUs & " MB / " & Round($MemInfo[1] / 1024) & " MB (" & $MemInfo[0] & "%)")
;~ 		GUICtrlSetData($prMemUs, $MemInfo[0])

;~ 		Local $OneDig = StringLeft($MemInfo[0], 1)
;~ 		TraySetToolTip(	$MBTitle & " " & $MBver & @CRLF & _
;~ 						"----------------------------------------" & @CRLF & _
;~ 						"Memory Usage: " & $MemInfo[0] & "%")
;~ 		TraySetIcon(@ScriptFullPath, (-1 * ($OneDig + 6)))

		$MEM_DIFF_PERC = $MemInfo[0]

	EndIf

	GuiCtrlSetData($RAMUSAGE_LABEL, $MemUs & " MB")

;~ 	Local $MemUs, $MemFrPerc, $PagUs, $PagPerc, $PagFrPerc, $VirUs, $VirPerc

;~ 	$MemUs = Round(($MemInfo[1] - $MemInfo[2]) / 1024)
;~ 	$MemFrPerc = Round(($MemInfo[2] / $MemInfo[1]) * 100)
;~ 	$PagUs = Round($MemInfo[3] - $MemInfo[4])
;~ 	$PagPerc = Round(($PagUs / $MemInfo[3]) * 100)
;~ 	$PagFrPerc = Round(($MemInfo[4] / $MemInfo[3]) * 100)
;~ 	$VirUs = Round($MemInfo[5] - $MemInfo[6])
;~ 	$VirPerc = Round(($VirUs / $MemInfo[5]) * 100)

;~ 	If $MemDiff <> $MemUs Then

;~ 		GuiCtrlSetData($grMemUs, "RAM Usage: " & $MemUs & " MB / " & Round($MemInfo[1] / 1024) & " MB (" & $MemInfo[0] & "%)")
;~ 		GUICtrlSetData($prMemUs, $MemInfo[0])

;~ 		Local $OneDig = StringLeft($MemInfo[0], 1)
;~ 		TraySetToolTip(	$MBTitle & " " & $MBver & @CRLF & _
;~ 						"----------------------------------------" & @CRLF & _
;~ 						"Memory Usage: " & $MemInfo[0] & "%")
;~ 		TraySetIcon(@ScriptFullPath, (-1 * ($OneDig + 6)))

;~ 		$MemDiff = $MemUs

;~ 	EndIf

;~ 	_GUICtrlListView_SetItemText($lvMemStats, 1, Round($MemInfo[1] / 1024) & " MB", 1)
;~ 	_GUICtrlListView_SetItemText($lvMemStats, 2, $MemUs & " MB (" & $MemInfo[0] & "%)", 1)
;~ 	_GUICtrlListView_SetItemText($lvMemStats, 3, Round($MemInfo[2] / 1024) & " MB (" & $MemFrPerc & "%)", 1)
;~ 	_GUICtrlListView_SetItemText($lvMemStats, 4, Round($MemInfo[3] / 1024) & " MB", 1)
;~ 	_GUICtrlListView_SetItemText($lvMemStats, 5, Round($PagUs / 1024) & " MB (" & $PagPerc & "%)", 1)
;~ 	_GUICtrlListView_SetItemText($lvMemStats, 6, Round($MemInfo[4] / 1024) & " MB (" & $PagFrPerc & "%)", 1)
;~ 	_GUICtrlListView_SetItemText($lvMemStats, 7, Round($VirUs / 1024) & " MB / " & Round($MemInfo[5] / 1024) & " MB (" & $VirPerc & "%)", 1)

;~ 	If $MemFrPerc <= 100 - $SetWarnLoad Then
;~ 		_GUICtrlListView_SetItemImage($lvMemStats, 3, 4)
;~ 	Else
;~ 		_GUICtrlListView_SetItemImage($lvMemStats, 3, 0)
;~ 	EndIf
;~ 	If $PagFrPerc <= 100 - $SetWarnLoad Then
;~ 		_GUICtrlListView_SetItemImage($lvMemStats, 6, 4)
;~ 	Else
;~ 		_GUICtrlListView_SetItemImage($lvMemStats, 6, 0)
;~ 	EndIf

;~ 	_SLG_SetLineValue($GraMS, $MemInfo[0])
;~ 	_SLG_SetLineValue($GraMS, $PagPerc, $G1Line2)
;~ 	_SLG_SetLineValue($GraMS, $VirPerc, $G1Line3)
;~ 	_SLG_UpdateGraph($GraMS)

EndFunc


Func _SetWindowOnTop()

	If $SetOnTop = 1 Then
		WinSetOnTop($MEMBOOST_GUI, "", 1)
		WinSetOnTop($OptionsDlg, "", 1)
	Else
		WinSetOnTop($MEMBOOST_GUI, "", 0)
	EndIf

EndFunc


Func _OptimizeItemPressed()
;~ 	$swAutoProcess = 0
	_ClearProcessesWorkingSet()
EndFunc


Func _ClearProcessesWorkingSet()

	Local $hToken, $aProcsList

	;Enable SeDebugPrivilege privilege for obtain full access rights to another processes
	;$hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	;_WinAPI_AdjustTokenPrivileges($hToken, $SE_DEBUG_NAME, 1)

	;If Not (@error Or @extended) Then
		$aProcsList = ProcessList()
		For $i = 1 To $aProcsList[0][0]
			;_GUICtrlStatusBar_SetText($hStatus, " Clearing Process " & $i & " Of " & $aProcsList[0][0] & " Working Set . . . . .")
			_WinAPI_EmptyWorkingSet($aProcsList[$i][1])

			;If $aProcsList[$i][1] <> -1 Then
				;Local $aiHandle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1F0FFF, 'int', False, 'int', $aProcsList[$i][1])
				;Local $aiReturn = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', $aiHandle[0])
				;DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $aiHandle[0])
			;Else
				;Local $aiReturn = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', -1)
			;EndIf
			Sleep(25)
			_DrawStatusSizeFromPercentage($PROGRESS_OPTIMIZE, ($i / $aProcsList[0][0]) * 100, 34, 152, 306, 6)
			;GUICtrlSetData($prOptimize, ($i / $aProcsList[0][0]) * 100)
		Next
		;_GUICtrlStatusBar_SetText($hStatus, " Memory Optimization complete.", 0)
		;If Not $swAutoProcess Then
			;If $SetPlSounds Then
				;SoundPlay("")
				;SoundPlay(@ScriptDir & "\Sounds\optimization-complete.mp3", 0)
			;EndIf
		;EndIf
	;EndIf

EndFunc ;~ ==> _ClearProcessesWorkingSet


Func _CLosedClicked()

	AdlibUnRegister("_TimerStuff")
;~ 	AdlibUnRegister("_WarningSounds")

	TraySetState(2)
	Exit

EndFunc


;~ Func _CLosedClicked()

;~ 	Local $PID

;~ 	TraySetState(2)
;~ 	GUIDelete($MEM_FORM)
;~ 	$PID = ProcessExists(@ScriptName) ; Will return the PID or 0 if the process isn't found.
;~ 	If $PID Then ProcessClose($PID)
;~ 	Exit

;~ EndFunc


Func _OptionsDlg()

	GuiCtrlSetState($btnOptions, $GUI_DISABLE)
	GuiCtrlSetState($miOptions, $GUI_DISABLE)

	Local $OptionsDlg, $BtnOptOK, $BtnOptCancel

	$OptionsDlg = GUICreate($MBTitle & " Options", 500, 400, -1, -1, BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	GUISetFont(9, 400, 0, "Tahoma", $OptionsDlg, 5)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_OptionsCloseClicked", $OptionsDlg)

	GUICtrlCreateGroup("", 15, 10, 470, 100)
	$chkAutStart = GUICtrlCreateCheckbox(" Start 'Memory Booster' when Windows starts", 25, 30, 300, 15)
	$chkOnTop = GUICtrlCreateCheckbox(" Show 'Memory Booster' Always On Top", 25, 50, 300, 15)
	$chkShowNotify = GUICtrlCreateCheckbox(" Show program notifications", 25, 70, 300, 15)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

	GUICtrlCreateGroup("Memory optimization modes", 15, 120, 3470, 100)
	$radIntel = GUICtrlCreateRadio(" Intelligent memory optimization", 25, 145, 300, 15)
	$radAuto = GUICtrlCreateRadio(" Automatically optimize memory every", 25, 165, 227, 15)
	$comboAutSec = GUICtrlCreateCombo("", 260, 162, 55, 20)
	GUICtrlSetData($comboAutSec, "3|5|10|15|20|25|30|35|40|45|50|55|60|65|70|75|80|85|90|95|100|105|110|115|120", $SetAutoCount)
	GUICtrlCreateLabel(" sec", 320, 165, 50, 15)
	$radNoAuto = GUICtrlCreateRadio(" Don't automatically optimize memory", 25, 185, 300, 15)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

	GUICtrlCreateGroup("Sounds", 15, 230, 470, 100)
	$chkPlSounds = GUICtrlCreateCheckbox(" Play sounds on program events. ", 25, 255, 270, 20)
	$chkPlWarn = GUICtrlCreateCheckbox(" Play Warning every ", 25, 278, 130, 20)
	$cmPlWarnEvery = GUICtrlCreateCombo("", 155, 278, 50, 20)
	GUICtrlSetData(-1, "1|3|6|9|12|15|20|30|40|50|60|120", $SetWarnEvery)
	GUICtrlCreateLabel("minutes if load exceed", 215, 281, 150, 20)
	$cmPlWarnLoad = GUICtrlCreateCombo("", 350, 278, 50, 20)
	GUICtrlSetData(-1, "30|40|50|60|70|80|90", $SetWarnLoad)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

	$btnOptOK = GUICtrlCreateButton("OK", 170, 350, 100, 30)
	$btnOptCancel = GUICtrlCreateButton("Cancel", 270, 350, 100, 30)
	$btnOptApply = GUICtrlCreateButton("Apply", 370, 350, 100, 30)

	If FileExists(@StartupDir & "\Rizone Memory Booster.lnk") Then GUICtrlSetState($ChkAutStart, $GUI_CHECKED)
	If $SetOnTop = 1 Then GUICtrlSetState($chkOnTop, $GUI_CHECKED)
	If $SetNotify = 1 Then GUICtrlSetState($chkShowNotify, $GUI_CHECKED)

	Switch $SetOpMeth
		Case 0
			GUICtrlSetState($radIntel, $GUI_CHECKED)
		Case 1
			GUICtrlSetState($radAuto, $GUI_CHECKED)
		Case 2
			GUICtrlSetState($radNoAuto, $GUI_CHECKED)
	EndSwitch

	If $SetPlSounds Then GUICtrlSetState($chkPlSounds, $GUI_CHECKED)
	If $SetPlWarn Then GUICtrlSetState($chkPlWarn, $GUI_CHECKED)

	_SetAutoMemRadioOptions()
	_SetPlayWarningSoundsOption()

	GUICtrlSetOnEvent($chkAutStart, "_EnableApplyButton")
	GUICtrlSetOnEvent($chkOnTop, "_EnableApplyButton")
	GUICtrlSetOnEvent($chkShowNotify, "_EnableApplyButton")
	GUICtrlSetOnEvent($radIntel, "_SetAutoMemRadioOptions")
	GUICtrlSetOnEvent($radAuto, "_SetAutoMemRadioOptions")
	GUICtrlSetOnEvent($comboAutSec, "_SetAutoMemRadioOptions")
	GUICtrlSetOnEvent($radNoAuto, "_SetAutoMemRadioOptions")
	GUICtrlSetOnEvent($chkPlSounds, "_EnableApplyButton")
	GUICtrlSetOnEvent($chkPlWarn, "_SetPlayWarningSoundsOption")
	GUICtrlSetOnEvent($cmPlWarnEvery, "_EnableApplyButton")
	GUICtrlSetOnEvent($cmPlWarnLoad, "_EnableApplyButton")
	GUICtrlSetOnEvent($btnOptOK, "_OptionsOKButtonPressed")
	GUICtrlSetOnEvent($btnOptCancel, "_OptionsCloseClicked")
	GUICtrlSetOnEvent($btnOptApply, "_OptionsApplyButtonPressed")

	GuiCtrlSetState($BtnOptApply, $GUI_DISABLE)

	GUISetState(@SW_SHOW, $OptionsDlg)

EndFunc

Func _SetAutoMemRadioOptions()

	If GUICtrlRead($radIntel) = $GUI_CHECKED Then
		GuiCtrlSetState($comboAutSec, $GUI_DISABLE)
	ElseIf GUICtrlRead($radAuto) = $GUI_CHECKED Then
		GuiCtrlSetState($comboAutSec, $GUI_ENABLE)
	ElseIf GUICtrlRead($radNoAuto) = $GUI_CHECKED Then
		GuiCtrlSetState($comboAutSec, $GUI_DISABLE)
	EndIf

	_EnableApplyButton()

EndFunc

Func _SetPlayWarningSoundsOption()

	If GUICtrlRead($chkPlWarn) = $GUI_CHECKED Then
		GuiCtrlSetState($cmPlWarnEvery, $GUI_ENABLE)
		GuiCtrlSetState($cmPlWarnLoad, $GUI_ENABLE)
	Else
		GuiCtrlSetState($cmPlWarnEvery, $GUI_DISABLE)
		GuiCtrlSetState($cmPlWarnLoad, $GUI_DISABLE)
	EndIf

	_EnableApplyButton()

EndFunc

Func _EnableApplyButton()
	GuiCtrlSetState($btnOptApply, $GUI_ENABLE)
EndFunc

Func _OptionsOKButtonPressed()

	_OptionsApplyButtonPressed()
	_OptionsCloseClicked()

EndFunc

Func _OptionsApplyButtonPressed()

	If GUICtrlRead($chkAutStart) = $GUI_CHECKED Then
		FileDelete(@StartupDir & "\Rizone Memory Booster.lnk")
		FileCreateShortcut(@ScriptFullPath, @StartupDir & "\Rizone Memory Booster.lnk", @StartupDir, "/smin")
	Else
		FileDelete(@StartupDir & "\Rizone Memory Booster.lnk")
	EndIf

	If GUICtrlRead($chkOnTop) = $GUI_CHECKED Then
		$SetOnTop = 1
	ElseIf GUICtrlRead($chkOnTop) = $GUI_UNCHECKED Then
		$SetOnTop = 0
	EndIf

	_SetWindowOnTop()

	If GUICtrlRead($chkShowNotify) = $GUI_CHECKED Then
		$SetNotify = 1
	ElseIf GUICtrlRead($chkShowNotify) = $GUI_UNCHECKED Then
		$SetNotify = 0
	EndIf

	If GUICtrlRead($radIntel) = $GUI_CHECKED Then
		$SetOpMeth = 0
	ElseIf GUICtrlRead($radAuto) = $GUI_CHECKED Then
		$SetOpMeth = 1
	ElseIf GUICtrlRead($radNoAuto) = $GUI_CHECKED Then
		$SetOpMeth = 2
	EndIf

	$SetAutoCount = GUICtrlRead($comboAutSec)

	If GUICtrlRead($chkPlSounds) = $GUI_CHECKED Then
		$SetPlSounds = 1
	Else
		$SetPlSounds = 0
	EndIf
	If GUICtrlRead($chkPlWarn) = $GUI_CHECKED Then
		$SetPlWarn = 1
	Else
		$SetPlWarn = 0
	EndIf

	$SetWarnEvery = GUICtrlRead($cmPlWarnEvery)
	$SetWarnLoad = GUICtrlRead($cmPlWarnLoad)

	IniWrite($MBSettings, "Main", "SetWindowOnTop", $SetOnTop)
	IniWrite($MBSettings, "Main", "ShowNotifications", $SetNotify)
	IniWrite($MBSettings, "Modes", "DefaultOptimizationMethod", $SetOpMeth)
	IniWrite($MBSettings, "Modes", "AutoOptimizationCount", $SetAutoCount)
	IniWrite($MBSettings, "Sounds", "PlaySystemSounds", $SetPlSounds)
	IniWrite($MBSettings, "Sounds", "PlayWarnings", $SetPlWarn)
	IniWrite($MBSettings, "Sounds", "PlayWarnEvery", $SetWarnEvery)
	IniWrite($MBSettings, "Sounds", "PlayWarnIfExceed", $SetWarnLoad)

	GuiCtrlSetState($btnOptApply, $GUI_DISABLE)

EndFunc

Func _OptionsCloseClicked()

	GuiCtrlSetState($btnOptions, $GUI_ENABLE)
	GuiCtrlSetState($miOptions, $GUI_ENABLE)

	GUISetState(@SW_HIDE, @GUI_WinHandle)
	GuiCtrlSetState($btnOptimize, $GUI_FOCUS)

EndFunc