#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Resources\MemBoost.ico
#AutoIt3Wrapper_Res_Description=Rizone Memory Booster
#AutoIt3Wrapper_Res_Fileversion=1.6.9.1732
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© 2010 Rizone Technologies
#AutoIt3Wrapper_Res_Icon_Add=Resources\0.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\1.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\2.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\3.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\4.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\5.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\6.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\7.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\8.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\9.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\10.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\11.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\RSS.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Facebook.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Twitter.ico
#AutoIt3Wrapper_Res_File_Add=Resources\Sidebar.bmp, rt_rcdata, SIDEBAR_IMAGE
#AutoIt3Wrapper_Res_File_Add=resources\Donate.jpg, rt_rcdata, DONATE_IMAGE
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#NoTrayIcon


Opt("TrayMenuMode", 3) ;~ Default tray menu items (Script Paused/Exit) will not be shown.
Opt("GUIOnEventMode", 1)
Opt("TrayOnEventMode", 1)
Opt("MustDeclareVars", 1)


;#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#Include <GuiImageList.au3>
#Include <GuiStatusBar.au3>
#Include <GuiListView.au3>
#include <GUIToolTip.au3>
#include <Constants.au3>
#Include <Misc.au3>

#include <UDF\memManager.au3>
#include <UDF\Resources.au3>
#include <UDF\SLG.au3>


Global Const $MBTitle = "Memory Booster", $MBver = FileGetVersion(@ScriptFullPath)
Global Const $MBSettings = @ScriptDir & "\memBoost.ini"
Global Const $MBHelpFile = @ScriptDir & "\Support\memBoost.chm"

;~ Settings
;~ Global $OSVer
Global $Initializing = 1, $SetStartMin, $SetOnTop, $SetNotify, $SetOpMeth, $SetAutoCount
Global $SetPlSounds, $SetPlWarn, $SetWarnEvery, $SetWarnLoad, $OSG

Global $MemInfo, $MemDiff, $Count = 0, $TotalCount = 0, $swAutoProcess = 0
Global $memBoostGUI, $prMemUs, $grMemUs, $btnOptimize
Global $lvMemStats, $prCount, $prOptimize, $hStatus, $trShowHide
Global $miOptions, $btnOptions, $OptionsDlg, $chkAutStart, $chkOnTop, $chkShowNotify
Global $radIntel, $radAuto, $radNoAuto, $comboAutSec, $BtnOptApply, $chkPlSounds, $chkPlWarn, $cmPlWarnEvery, $cmPlWarnLoad
Global $warnCount = 0
Global $miAbout, $btnAbout, $AboutDlg
Global $GraMS, $G1Line2, $G1Line3, $grCPU, $GraCPU, $prCPU

Global $IDLETIME, $KERNELTIME, $USERTIME
Global $StartIdle, $StartKernel, $StartUser
Global $EndIdle, $EndKernel, $EndUser
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
	_StartMainGUI()
ElseIf StringLower($CmdLine[1]) = "/smin" Then
	$SetStartMin = 1
	_StartMainGUI()
EndIf


Func _StartMainGUI()

	Local $picSideBar, $mFile, $miOptNow, $miDefrag, $miClose, $ilImg, $hToolTip
	Local $mHelp, $miContents, $miHome, $miRSS, $miFacebook, $miTwitter
	Local $btnDefrag, $btnClose, $btnHelp
	Local $aParts[3] = [300, 350, -1]
	Local $trOptNow, $trDefrag, $trClose

	_GetSystemTime($StartIdle, $StartKernel, $StartUser)

	$memBoostGUI = GUICreate($MBTitle & " " & $MBver, 435, 520, -1, -1)
	GUISetFont(9, 400, 0, "Tahoma", $memBoostGUI, 5)
	GUISetHelp("hh.exe " & $MBHelpFile, $memBoostGUI)

	$picSideBar = GUICtrlCreatePic("", 0, 0, 50, 550)
	_ResourceSetImageToCtrl($picSideBar, "SIDEBAR_IMAGE", $RT_RCDATA)

	$mFile = GUICtrlCreateMenu("&File")
	$miOptNow = GUICtrlCreateMenuItem("&Optimize memory", $mFile)
	$miDefrag = GUICtrlCreateMenuItem("&Defrag memory", $mFile)
	GUICtrlCreateMenuItem("", $mFile)
	$miOptions = GUICtrlCreateMenuItem("O&ptions...", $mFile)
	GUICtrlCreateMenuItem("", $mFile)
	$miClose = GUICtrlCreateMenuItem("&Close memBooster", $mFile)

	GUICtrlSetOnEvent($miOptNow, "_OptimizeItemPressed")
	GUICtrlSetOnEvent($miDefrag, "_DefragMemory")
	GUICtrlSetOnEvent($miOptions, "_OptionsDlg")
	GUICtrlSetOnEvent($miClose, "_CloseMemoryBooster")

	$mHelp = GUICtrlCreateMenu("&Help")
	$miContents = GUICtrlCreateMenuItem("&Contents " & @TAB & "F1", $mHelp)
	$miAbout = GUICtrlCreateMenuItem("&About...", $mHelp)
	GUICtrlCreateMenuItem("", $mHelp)
	$miHome = GUICtrlCreateMenuItem("Rizone Home", $mHelp)
	GUICtrlCreateMenuItem("", $mHelp)
	$miRSS = GUICtrlCreateMenuItem("Subscribe in a Reader", $mHelp)
	$miFacebook = GUICtrlCreateMenuItem("Our Facebook page", $mHelp)
	$miTwitter = GUICtrlCreateMenuItem("Follow us on Twitter", $mHelp)

	GUICtrlSetOnEvent($miHome, "_OpenRizoneHomePage")
	GUICtrlSetOnEvent($miContents, "_OpenHelpFileContents")
	GUICtrlSetOnEvent($miAbout, "_AboutDlg")
	GUICtrlSetOnEvent($miRSS, "_SubscribeInReader")
	GUICtrlSetOnEvent($miFacebook, "_OpenFacebook")
	GUICtrlSetOnEvent($miTwitter, "_FollowOnTwitter")

	$grMemUs = GUICtrlCreateGroup("Memory Usage (0%)", 60, 5, 365, 60)
	$prMemUs = GUICtrlCreateProgress(70, 30, 340, 20)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

	;Local $ERRORN_CODE
	;Local $DEBUG = $ERRORN_CODE[99]

	GUICtrlCreateGroup("Memory Statistics", 60, 120, 180, 110)
	$GraMS = _SLG_CreateGraph($memBoostGUI, 65, 140, 170, 80, 1, 100, 100, 0xFF00ACFF, 2, -1, True)
	$G1Line2 = _SLG_AddLine($GraMS, 0xFFFFFF00, 1)
	$G1Line3 = _SLG_AddLine($GraMS, 0xFFFF8000, 1)
	_SLG_SetLineValue($GraMS, 1)
	_SLG_SetLineValue($GraMS, 1, $G1Line2)
	_SLG_SetLineValue($GraMS, 1, $G1Line3)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

	$grCPU = GUICtrlCreateGroup("CPU Usage (0%)", 245, 120, 180, 110)
	$GraCPU = _SLG_CreateGraph($memBoostGUI, 250, 140, 170, 65, 1, 100, 100, 0xFF00FF00, 1, -1, True)
	_SLG_SetLineValue($GraCPU, 1)
	_SLG_UpdateGraph($GraCPU)
	$prCPU = GUICtrlCreateProgress(250, 212, 170, 13)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

	$btnOptimize = GUICtrlCreateButton("Optimize", 60, 70, 115, 35, $BS_DEFPUSHBUTTON)
	GUICtrlSetTip($btnOptimize,	"Optimize Memory now!", "Optimize Memory", 1, 1)
	GuiCtrlSetState($btnOptimize, $GUI_FOCUS)
	$btnDefrag = GUICtrlCreateButton("Defrag", 180, 70, 115, 35)
	$btnOptions = GUICtrlCreateButton("Options...", 300, 70, 115, 35)

	GUICtrlSetOnEvent($btnOptimize, "_OptimizeItemPressed")
	GUICtrlSetOnEvent($btnDefrag, "_DefragMemory")
	GUICtrlSetOnEvent($btnOptions, "_OptionsDlg")

	$lvMemStats = GUICtrlCreateListView("", 60, 240, 365, 150)
	_GUICtrlListView_SetExtendedListViewStyle($lvMemStats, BitOR($LVS_EX_DOUBLEBUFFER, $LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
	$ilImg = _GUIImageList_Create() ;~ Create the solid bitmaps for the icons
	_GUIImageList_Add($ilImg, _GUICtrlListView_CreateSolidBitMap($lvMemStats, 0x20D820, 16, 16))
	_GUIImageList_Add($ilImg, _GUICtrlListView_CreateSolidBitMap($lvMemStats, 0x0080FF, 16, 16))
	_GUIImageList_Add($ilImg, _GUICtrlListView_CreateSolidBitMap($lvMemStats, 0xFFFF00, 16, 16))
	_GUIImageList_Add($ilImg, _GUICtrlListView_CreateSolidBitMap($lvMemStats, 0xFF8000, 16, 16))
	_GUIImageList_Add($ilImg, _GUICtrlListView_CreateSolidBitMap($lvMemStats, 0xFF0000, 16, 16))
	_GUIImageList_Add($ilImg, _GUICtrlListView_CreateSolidBitMap($lvMemStats, 0xCCCCCC, 16, 16))

	_GUICtrlListView_AddColumn($lvMemStats, "Description", 170)
	_GUICtrlListView_AddColumn($lvMemStats, "Value", 200)

	_GUICtrlListView_AddItem($lvMemStats, "  CPU Usage", 0)
	_GUICtrlListView_AddSubItem($lvMemStats, 0, "0", 1)
	_GUICtrlListView_AddItem($lvMemStats, "  Total Memory", 5)
	_GUICtrlListView_AddSubItem($lvMemStats, 1, "0", 1)
	_GUICtrlListView_AddItem($lvMemStats, "  Used Memory (RAM)", 1)
	_GUICtrlListView_AddSubItem($lvMemStats, 2, "0", 1)
	_GUICtrlListView_AddItem($lvMemStats, "  Available Memory (RAM)", 0)
	_GUICtrlListView_AddSubItem($lvMemStats, 3, "0", 1)
	_GUICtrlListView_AddItem($lvMemStats, "  Total Pagefile", 5)
	_GUICtrlListView_AddSubItem($lvMemStats, 4, "0", 1)
	_GUICtrlListView_AddItem($lvMemStats, "  Used Pagefile", 2)
	_GUICtrlListView_AddSubItem($lvMemStats, 5, "0", 1)
	_GUICtrlListView_AddItem($lvMemStats, "  Available Pagefile", 0)
	_GUICtrlListView_AddSubItem($lvMemStats, 6, "0", 1)
	_GUICtrlListView_AddItem($lvMemStats, "  Used Virtual Memory", 3)
	_GUICtrlListView_AddSubItem($lvMemStats, 7, "0", 1)

	_GUICtrlListView_SetImageList($lvMemStats, $ilImg, 1)

	; Make tips visible on top
	$hToolTip = _GUICtrlListView_GetToolTips($lvMemStats)

	If IsHWnd($hToolTip) Then
        WinSetOnTop($hToolTip, "", 1)
        _GUIToolTip_SetDelayTime($hToolTip, 3, 60) ; Speeds up infotip appearance
    EndIf

	$btnClose = GUICtrlCreateButton("Close", 290, 395, 135, 30)
	$btnAbout = GUICtrlCreateButton("?", 60, 395, 35, 30)
	$btnHelp = GUICtrlCreateButton("Help", 95, 395, 100, 30)

	GUICtrlSetOnEvent($btnClose, "_CloseMemoryBooster")
	GUICtrlSetOnEvent($btnAbout, "_AboutDlg")
	GUICtrlSetOnEvent($btnHelp, "_OpenHelpFileContents")

	$prCount = GUICtrlCreateProgress(60, 435, 365, 15)
	$prOptimize = GUICtrlCreateProgress(60, 453, 365, 10)

	$hStatus = _GUICtrlStatusBar_Create($memBoostGUI)
	_GUICtrlStatusBar_SetParts($hStatus, $aParts)
	If $SetOpMeth = 0 Then
		_GUICtrlStatusBar_SetText($hStatus, " T:" & $Count, 1)
	ElseIf $SetOpMeth = 1 Then
		_GUICtrlStatusBar_SetText($hStatus, " T:" & $SetAutoCount, 1)
	EndIf
	_GUICtrlStatusBar_SetText($hStatus, " " & @HOUR & ":" & @MIN & ":" & @SEC, 2)

	;GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseMemoryBooster")
	GUISetOnEvent($GUI_EVENT_CLOSE, "_HideMainForm")
	GUISetOnEvent($GUI_EVENT_MINIMIZE, "_UpdateGraphs")
	GUISetOnEvent($GUI_EVENT_RESTORE, "_UpdateGraphs")

	$trOptNow = TrayCreateItem("&Optimize memory")
	$trDefrag = TrayCreateItem("&Defrag memory")
	TrayCreateItem("")
	$trShowHide = TrayCreateItem("&Hide memBooster")
	TrayCreateItem("")
	$trClose = TrayCreateItem("&Close memBooster")

	TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "_ShowHideMainForm")
	TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "_ShowHideMainForm")

	TrayItemSetOnEvent($trOptNow, "_ClearProcessesWorkingSet")
	TrayItemSetOnEvent($trDefrag, "_DefragMemory")
	TrayItemSetOnEvent($trShowHide, "_ShowHideMainForm")
	TrayItemSetOnEvent($trClose, "_CloseMemoryBooster")

	If $SetStartMin = 0 Then
		GUISetState(@SW_SHOW, $memBoostGUI)
	Else
		GUISetState(@SW_HIDE, $memBoostGUI)
		TrayItemSetText($trShowHide, "&Show memBooster")
	EndIf

	TraySetIcon(@ScriptFullPath, -6)
	TraySetState()
	TraySetClick(8)

	AdlibRegister("_TimerStuff", 1000)
	AdlibRegister("_WarningSounds", 60000)
	_TimerStuff()
	_SetWindowOnTop()

	While 1

		Sleep(25) ;~ Idle
		_WinAPI_EmptyWorkingSet()
		;If $Initializing Then _TimerStuff()

	WEnd

EndFunc


Func _TimerStuff()

	$MemInfo = MemGetStats()

	_GetSystemTime($EndIdle, $EndKernel, $EndUser)
	_CPUCalc()
	_GetSystemTime($StartIdle, $StartKernel, $StartUser)

	_UpdateMemoryStats()

	If $SetOpMeth = 2 Then

		;If GUICtrlRead($prCount) = 100 Then
			_GUICtrlStatusBar_SetText($hStatus, "", 0)
			_GUICtrlStatusBar_SetText($hStatus, "", 1)
			GuiCtrlSetData($prCount, 0)
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
				_GUICtrlStatusBar_SetText($hStatus, " Optimizing memory in " & $TotalCount & " seconds . . . . .", 0)
				_GUICtrlStatusBar_SetText($hStatus, " T:" & $Count, 1)
				GUICtrlSetData($prCount, ($TotalCount / $Count) * 100)
			Else
				$TotalCount = $Count
			EndIf

		Else

			$TotalCount = $Count
			$swAutoProcess = 1
			_ClearProcessesWorkingSet()

		EndIf

	EndIf

	_GUICtrlStatusBar_SetText($hStatus, " " & @HOUR & ":" & @MIN & ":" & @SEC & " " & _GetAMPM(@HOUR), 2)

	$Initializing = 0

EndFunc


Func _WarningSounds()

	If $SetPlWarn Then

		$warnCount += 1

		If $warnCount = $SetWarnEvery Then
			Local $memWarnings = MemGetStats()
			If $memWarnings[0] >= $SetWarnLoad Then
				SoundPlay("")
				SoundPlay(@ScriptDir & "\Sounds\mem-high.mp3", 0)
			EndIf
			$warnCount = 0
		EndIf

	EndIf

EndFunc


Func _GetAMPM($hour = "")

	If $hour > 0 And $hour < 12 Then
		Return "AM"
	Else
		Return "PM"
	EndIf

EndFunc


Func _GetSystemTime(ByRef $sIdle, ByRef $sKernel, ByRef $sUser)

	DllCall("kernel32.dll", "int", "GetSystemTimes", "ptr", DllStructGetPtr($IDLETIME), _
            "ptr", DllStructGetPtr($KERNELTIME), _
            "ptr", DllStructGetPtr($USERTIME))

    $sIdle = DllStructGetData($IDLETIME, 1)
    $sKernel = DllStructGetData($KERNELTIME, 1)
    $sUser = DllStructGetData($USERTIME, 1)

EndFunc   ;==>_GetSysTime


Func _CPUCalc()

    Local $iSystemTime, $iTotal, $iCalcIdle, $iCalcKernel, $iCalcUser

    $iCalcIdle   = ($EndIdle - $StartIdle)
    $iCalcKernel = ($EndKernel - $StartKernel)
    $iCalcUser   = ($EndUser - $StartUser)

    $iSystemTime = ($iCalcKernel + $iCalcUser)
    $iTotal = Int(($iSystemTime - $iCalcIdle) * (100 / $iSystemTime)) & "%"

	_SLG_SetLineValue($GraCPU, $iTotal)
	_SLG_UpdateGraph($GraCPU)

	If StringTrimRight(_GUICtrlListView_GetItemText($lvMemStats, 6, 1), 1) <> $iTotal Then
		If $iTotal > 0 And $iTotal < 100 Then
			ControlSetText($memBoostGUI, "", $grCPU, "CPU Usage (" & $iTotal & ")")
			_GUICtrlListView_SetItemText($lvMemStats, 0, $iTotal, 1)

			If $iTotal >= 60 Then
				_GUICtrlListView_SetItemImage($lvMemStats, 0, 4)
			Else
				_GUICtrlListView_SetItemImage($lvMemStats, 0, 0)
			EndIf

			GUICtrlSetData($prCPU, $iTotal)
		EndIf
	EndIf

EndFunc   ;==>_CPUCalc


Func _UpdateMemoryStats()

	Local $MemUs, $MemFrPerc, $PagUs, $PagPerc, $PagFrPerc, $VirUs, $VirPerc

	$MemUs = Round(($MemInfo[1] - $MemInfo[2]) / 1024)
	$MemFrPerc = Round(($MemInfo[2] / $MemInfo[1]) * 100)
	$PagUs = Round($MemInfo[3] - $MemInfo[4])
	$PagPerc = Round(($PagUs / $MemInfo[3]) * 100)
	$PagFrPerc = Round(($MemInfo[4] / $MemInfo[3]) * 100)
	$VirUs = Round($MemInfo[5] - $MemInfo[6])
	$VirPerc = Round(($VirUs / $MemInfo[5]) * 100)

	If $MemDiff <> $MemUs Then

		GuiCtrlSetData($grMemUs, "RAM Usage: " & $MemUs & " MB / " & Round($MemInfo[1] / 1024) & " MB (" & $MemInfo[0] & "%)")
		GUICtrlSetData($prMemUs, $MemInfo[0])

		Local $OneDig = StringLeft($MemInfo[0], 1)
		TraySetToolTip(	$MBTitle & " " & $MBver & @CRLF & _
						"----------------------------------------" & @CRLF & _
						"Memory Usage: " & $MemInfo[0] & "%")
		TraySetIcon(@ScriptFullPath, (-1 * ($OneDig + 6)))

		$MemDiff = $MemUs

	EndIf

	_GUICtrlListView_SetItemText($lvMemStats, 1, Round($MemInfo[1] / 1024) & " MB", 1)
	_GUICtrlListView_SetItemText($lvMemStats, 2, $MemUs & " MB (" & $MemInfo[0] & "%)", 1)
	_GUICtrlListView_SetItemText($lvMemStats, 3, Round($MemInfo[2] / 1024) & " MB (" & $MemFrPerc & "%)", 1)
	_GUICtrlListView_SetItemText($lvMemStats, 4, Round($MemInfo[3] / 1024) & " MB", 1)
	_GUICtrlListView_SetItemText($lvMemStats, 5, Round($PagUs / 1024) & " MB (" & $PagPerc & "%)", 1)
	_GUICtrlListView_SetItemText($lvMemStats, 6, Round($MemInfo[4] / 1024) & " MB (" & $PagFrPerc & "%)", 1)
	_GUICtrlListView_SetItemText($lvMemStats, 7, Round($VirUs / 1024) & " MB / " & Round($MemInfo[5] / 1024) & " MB (" & $VirPerc & "%)", 1)

	If $MemFrPerc <= 100 - $SetWarnLoad Then
		_GUICtrlListView_SetItemImage($lvMemStats, 3, 4)
	Else
		_GUICtrlListView_SetItemImage($lvMemStats, 3, 0)
	EndIf
	If $PagFrPerc <= 100 - $SetWarnLoad Then
		_GUICtrlListView_SetItemImage($lvMemStats, 6, 4)
	Else
		_GUICtrlListView_SetItemImage($lvMemStats, 6, 0)
	EndIf

	_SLG_SetLineValue($GraMS, $MemInfo[0])
	_SLG_SetLineValue($GraMS, $PagPerc, $G1Line2)
	_SLG_SetLineValue($GraMS, $VirPerc, $G1Line3)
	_SLG_UpdateGraph($GraMS)

EndFunc


Func _UpdateGraphs()
	_SLG_UpdateGraph($GraMS)
	_SLG_UpdateGraph($GraCPU)
EndFunc


Func _OptimizeItemPressed()
	$swAutoProcess = 0
	_ClearProcessesWorkingSet()
EndFunc


Func _ClearProcessesWorkingSet()

	Local $hToken, $aProcsList

	;Enable SeDebugPrivilege privilege for obtain full access rights to another processes
	;$hToken = _WinAPI_OpenProcessToken(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
	;_WinAPI_AdjustTokenPrivileges($hToken, $SE_DEBUG_NAME, 1)

	;If Not (@error Or @extended) Then
		Sleep(3)
		$aProcsList = ProcessList()
		For $i = 1 To $aProcsList[0][0]
			_GUICtrlStatusBar_SetText($hStatus, " Clearing Process " & $i & " Of " & $aProcsList[0][0] & " Working Set . . . . .")
			_WinAPI_EmptyWorkingSet($aProcsList[$i][1])

			;If $aProcsList[$i][1] <> -1 Then
				;Local $aiHandle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1F0FFF, 'int', False, 'int', $aProcsList[$i][1])
				;Local $aiReturn = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', $aiHandle[0])
				;DllCall('kernel32.dll', 'int', 'CloseHandle', 'int', $aiHandle[0])
			;Else
				;Local $aiReturn = DllCall("psapi.dll", 'int', 'EmptyWorkingSet', 'long', -1)
			;EndIf

			GUICtrlSetData($prOptimize, ($i / $aProcsList[0][0]) * 100)
		Next
		_GUICtrlStatusBar_SetText($hStatus, " Memory Optimization complete.", 0)
		If Not $swAutoProcess Then
			If $SetPlSounds Then
				SoundPlay("")
				SoundPlay(@ScriptDir & "\Sounds\optimization-complete.mp3", 0)
			EndIf
		EndIf
	;EndIf

EndFunc ;~ ==> _ClearProcessesWorkingSet


Func _DefragMemory()

	If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
	$iMsgBoxAnswer = MsgBox(262193,	"Mischievous function!", "This is an experimental function. It will force most of the " & _
									"memory into the pagefile. In most cases, this is not a good thing, but could free a " & _
									"lot of RAM. You can try it and if it slows down your computer or cause programs to " & _
									"lock up simply reboot and everything should be fine.")
	Select
		Case $iMsgBoxAnswer = 1 ;OK

			If $SetPlSounds Then
				SoundPlay("")
				SoundPlay(@ScriptDir & "\Sounds\defragging-memory.mp3", 0)
			EndIf

			_GUICtrlStatusBar_SetText($hStatus, " Defragging Memory, please wait . . . . .")

			Local $memStruct = MemGetStats()
			If @OSVersion = "WIN_2003" Or @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Then



			ElseIf @OSVersion = "WIN_2008R2" Or @OSVersion = "WIN_7" Or @OSVersion = "WIN_2008" Or @OSVersion = "WIN_VISTA" Then
				DllStructCreate("byte[" & Round($memStruct[1] * (1024 / 2.5)) & "]")
				;DllStructCreate("char[" & ($memStruct[1] * 512) & "]")
			EndIf

			ClipPut("")
			EnvUpdate()

			If $SetPlSounds Then
				SoundPlay("")
				SoundPlay(@ScriptDir & "\Sounds\defrag-complete.mp3", 0)
			EndIf

		Case $iMsgBoxAnswer = 2 ;Cancel
			_GUICtrlStatusBar_SetText($hStatus, " Defragging Cancelled!")
	EndSelect

EndFunc


Func _OpenHelpFileContents()
	If FileExists($MBHelpFile) Then ShellExecute($MBHelpFile)
EndFunc


Func _SetWindowOnTop()

	If $SetOnTop = 1 Then
		WinSetOnTop($memBoostGUI, "", 1)
		WinSetOnTop($OptionsDlg, "", 1)
	Else
		WinSetOnTop($memBoostGUI, "", 0)
	EndIf

EndFunc


Func _ShowHideMainForm()

	If TrayItemGetText($trShowHide) = "&Show memBooster" Then
		_ShowMainForm()
	Else
		_HideMainForm()
	EndIf

EndFunc


Func _HideMainForm()

	GUISetState(@SW_HIDE, $memBoostGUI)

	TrayTip("Clear Tray Tip", "", 0)
	If $SetNotify = 1 Then
		TrayTip($MBTitle & " is still running.",	$MBTitle & " will continue to run so that we can keep on monitoring your system, " & _
													"automatically optimize your memory and fix memory leaks. To close Memory Booster, " & _
													"right-click here and choose 'Close'.", 20, 1)
	EndIf
	TrayItemSetText($trShowHide, "&Show memBooster")
	GUISetState(@SW_HIDE, $OptionsDlg)
	GUISetState(@SW_HIDE, $AboutDlg)

EndFunc


Func _ShowMainForm()
	GUISetState(@SW_SHOW, $memBoostGUI)
	_UpdateGraphs()
	TrayItemSetText($trShowHide, "Hide Window")
EndFunc


Func _CloseMemoryBooster()

	AdlibUnRegister("_TimerStuff")
	AdlibUnRegister("_WarningSounds")

	TraySetState(2)
	Exit

EndFunc


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


Func _AboutDlg()

	GuiCtrlSetState($btnAbout, $GUI_DISABLE)
	GuiCtrlSetState($miAbout, $GUI_DISABLE)

	Local $AbDlT = "About " & $MBTitle
	Local $abHome, $picDonate
	Local $abSpaceLabel, $abSpaceProg, $abBtnOK
	Local $abRSS, $abFacebook, $abTwittter

	$AboutDlg = GUICreate($AbDlT, 400, 300, -1, -1, BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	GUISetFont(9, 400, 0, "Tahoma", $AboutDlg, 5)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseAboutDlg", $AboutDlg)

	GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 10, 64, 64)
	GUICtrlCreateLabel($MBTitle, 88, 16, 300, 18)
	GUICtrlSetFont(-1, 9, 800, 0, "Verdana")
	GUICtrlCreateLabel("Version " & FileGetVersion(@ScriptFullPath), 88, 40, 300, 20)
	GUICtrlCreateLabel("Copyright © 2010 Rizone Technologies", 88, 55, 300, 20)
	GuiCtrlSetFont(-1, 8.5) ;Underlined
	GuiCtrlSetColor(-1, 0x555555)

	$abHome = GUICtrlCreateLabel("http://www.rizone3.com", 88, 88, 200, 15)
	GuiCtrlSetFont($abHome, 9, -1, 4) ;Underlined
	GuiCtrlSetColor($abHome, 0x0000FF)
	GuiCtrlSetCursor($abHome, 0)

	$picDonate = GUICtrlCreatePic("", 300, 130, 62, 31)
	_ResourceSetImageToCtrl($picDonate, "DONATE_IMAGE", $RT_RCDATA)
	GUICtrlSetCursor(-1, 0)

	Local $drvSpaceUsed = DriveSpaceTotal(@HomeDrive) - DriveSpaceFree(@HomeDrive)

	$abSpaceLabel = GUICtrlCreateLabel("(" & @HomeDrive & ") " & Round(DriveSpaceFree(@HomeDrive) / 1024, 1) & " GB free of " & _
					Round(DriveSpaceTotal(@HomeDrive) / 1024, 1) & " GB", 15, 180, 300, 15)
	$abSpaceProg = GUICtrlCreateProgress(15, 200, 350, 15)
	GUICtrlSetData($abSpaceProg, ($drvSpaceUsed / DriveSpaceTotal(@HomeDrive)) * 100)
	$abBtnOK = GUICtrlCreateButton("OK", 250, 250, 123, 33, $BS_DEFPUSHBUTTON)

	$abRSS = GUICtrlCreateIcon(@ScriptFullPath, 213, 20, 250, 32, 32)
	GUICtrlSetCursor($abRSS, 0)
	$abFacebook = GUICtrlCreateIcon(@ScriptFullPath, 214, 57, 250, 32, 32)
	GUICtrlSetCursor($abFacebook, 0)
	$abTwittter = GUICtrlCreateIcon(@ScriptFullPath, 215, 94, 250, 32, 32)
	GUICtrlSetCursor($abTwittter, 0)

	GUICtrlSetOnEvent($abHome, "_OpenRizoneHomePage")
	GUICtrlSetOnEvent($picDonate, "_DonateSomething")
	GUICtrlSetOnEvent($abRSS, "_SubscribeInReader")
	GUICtrlSetOnEvent($abFacebook, "_OpenFacebook")
	GUICtrlSetOnEvent($abTwittter, "_FollowOnTwitter")
	GUICtrlSetOnEvent($abBtnOK, "_CloseAboutDlg")

	GUISetState(@SW_SHOW, $AboutDlg)

EndFunc


Func _CloseAboutDlg()

	GuiCtrlSetState($btnAbout, $GUI_ENABLE)
	GuiCtrlSetState($miAbout, $GUI_ENABLE)

	GUISetState(@SW_HIDE, @GUI_WinHandle)
	GuiCtrlSetState($btnOptimize, $GUI_FOCUS)

EndFunc


Func _DonateSomething()
	ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=CEZABT5KGTU74&lc=ZA&item_name=Rizone%20Technologies&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted")
EndFunc


Func _OpenRizoneHomePage()
	ShellExecute("http://www.rizone3.com")
EndFunc


Func _SubscribeInReader()
	ShellExecute("http://feeds.feedburner.com/rizone3")
EndFunc


Func _OpenFacebook()
	ShellExecute("http://www.facebook.com/pages/Rizonetech/168097502680")
EndFunc


Func _FollowOnTwitter()
	ShellExecute("http://twitter.com/Rizonetech")
EndFunc