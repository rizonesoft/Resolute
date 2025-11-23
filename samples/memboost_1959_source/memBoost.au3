#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\memBoost.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Rizonesoft Memory Booster
#AutoIt3Wrapper_Res_Fileversion=1.9.5.1960
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=© 2014, Rizonesoft
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
#AutoIt3Wrapper_Res_Icon_Add=Resources\Facebook.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Twitter.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\LinkedIn.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Google.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Donate.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Memory.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Processor.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Info.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Gear.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


Opt("TrayMenuMode", 3) ;~ Default tray menu items (Script Paused/Exit) will not be shown.
Opt("GUIOnEventMode", 1)
Opt("TrayOnEventMode", 1)
Opt("MustDeclareVars", 1)


;#include <StaticConstants.au3>
#Include <GuiStatusBar.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#Include <GuiImageList.au3>
#Include <GuiListView.au3>
#include <WinAPIProc.au3>
#include <GUIToolTip.au3>
#include <Constants.au3>
#include <Process.au3>
#Include <Misc.au3>

#include <UDF\Functions.au3>
#include <UDF\Resources.au3>
#include <UDF\SLG.au3>


;~ Application Settings
;~ Global Const $APPSET_TITLE = "Memory Booster"
;~ Global Const $APPSET_VERSION = _GetExecVersioning(@ScriptFullPath, 5)

Global Const $MBSettings = @ScriptDir & "\memBoost.ini"
Global Const $MBHelpFile = @ScriptDir & "\Support\memBoost.chm"

;~ Settings
;~ Global $OSVer
;~ Global $Initializing = 1, $SetStartMin, $SetOnTop, $SetNotify, $SetOpMeth, $SetAutoCount, $SetForceBehave
;~ Global $SetPlSounds, $SetPlWarn, $SetWarnEvery, $SetWarnLoad, $OSG

Global $MemInfo, $MemDiff, $Count = 0, $TotalCount = 0, $swAutoProcess = 0
Global $memBoostGUI, $prMemUs, $grMemUs, $btnOptimize
Global $lvMemStats, $prCount, $prOptimize, $trShowHide
Global $miOptions, $btnOptions, $OptionsDlg, $chkAutStart, $chkOnTop, $chkShowNotify
Global $radIntel, $radAuto, $radNoAuto, $comboAutSec, $BtnOptApply, $chkPlSounds, $chkPlWarn, $cmPlWarnEvery, $cmPlWarnLoad
Global $warnCount = 0, $chkForceBehave
Global $miAbout, $btnAbout, $AboutDlg
Global $GraMS, $G1Line2, $G1Line3, $grCPU, $GraCPU, $prCPU
Global $hStatus, $aParts[3] = [250, 300, -1]
Global $OpCPUIcon


;~ Global $IDLETIME, $KERNELTIME, $USERTIME
;~ Global $StartIdle, $StartKernel, $StartUser
;~ Global $EndIdle, $EndKernel, $EndUser
;~ ; Global $Timer

;~ $IDLETIME   = DllStructCreate("dword;dword")
;~ $KERNELTIME = DllStructCreate("dword;dword")
;~ $USERTIME   = DllStructCreate("dword;dword")


;~ If @OSVersion = "WIN_2000" Or @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2003" Then
;~ 	$OSG = "WIN6"
;~ Else
;~ 	$OSG = "WIN8"
;~ EndIf


;~ _Singleton(@ScriptName, 0)


;~ $SetOnTop = IniRead($MBSettings, "Main", "SetWindowOnTop", 1)
;~ $SetNotify = IniRead($MBSettings, "Main", "ShowNotifications", 1)
;~ $SetForceBehave = IniRead($MBSettings, "Main", "ForceProcessesBehave", 0)
;~ $SetOpMeth = IniRead($MBSettings, "Modes", "DefaultOptimizationMethod", 0)
;~ $SetAutoCount = IniRead($MBSettings, "Modes", "AutoOptimizationCount", 25)
;~ $SetPlSounds = IniRead($MBSettings, "Sounds", "PlaySystemSounds", 0)
;~ $SetPlWarn = IniRead($MBSettings, "Sounds", "PlayWarnings", 0)
;~ $SetWarnEvery = IniRead($MBSettings, "Sounds", "PlayWarnEvery", 3)
;~ $SetWarnLoad = IniRead($MBSettings, "Sounds", "PlayWarnIfExceed", 80)


If $CmdLine[0] == 0 Then
	_StartMainGUI()
ElseIf StringLower($CmdLine[1]) = "/smin" Then
	$SetStartMin = 1
	_StartMainGUI()
EndIf


Func _StartMainGUI()

	Local $picSideBar, $mFile, $miOptNow, $miClose, $ilImg, $hToolTip
	Local $mHelp, $miContents, $miHome, $miRSS, $miFacebook, $miTwitter
	Local $btnClose, $btnHelp
	Local $trOptNow, $trClose

	_GetSystemTime($StartIdle, $StartKernel, $StartUser)

	$memBoostGUI = GUICreate($APPSET_TITLE & " " & _GetExecVersioning(@ScriptFullPath, 5), 385, 530, -1, -1)
	GUISetFont(9, 400, 0, "Tahoma", $memBoostGUI, 5)
	GUISetHelp("hh.exe " & $MBHelpFile, $memBoostGUI)

	$grMemUs = GUICtrlCreateGroup("Memory Usage (0%)", 10, 10, 365, 55)
	GUICtrlCreateIcon(@ScriptFullPath, 218, 20, 35, 16, 16)
	$prMemUs = GUICtrlCreateProgress(40, 35, 320, 16)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

	;Local $ERRORN_CODE
	;Local $DEBUG = $ERRORN_CODE[99]

	GUICtrlCreateGroup("Memory Statistics", 10, 155, 180, 110)
	$GraMS = _SLG_CreateGraph($memBoostGUI, 15, 175, 170, 80, 1, 100, 100, 0xFF00ACFF, 2, -1, True)
	$G1Line2 = _SLG_AddLine($GraMS, 0xFFFFFF00, 1)
	$G1Line3 = _SLG_AddLine($GraMS, 0xFFFF8000, 1)
	_SLG_SetLineValue($GraMS, 1)
	_SLG_SetLineValue($GraMS, 1, $G1Line2)
	_SLG_SetLineValue($GraMS, 1, $G1Line3)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

	$grCPU = GUICtrlCreateGroup("CPU Usage (0%)", 195, 155, 180, 110)
	$GraCPU = _SLG_CreateGraph($memBoostGUI, 200, 175, 170, 65, 1, 100, 100, 0xFF00FF00, 1, -1, True)
	_SLG_SetLineValue($GraCPU, 1)
	_SLG_UpdateGraph($GraCPU)
	GUICtrlCreateIcon(@ScriptFullPath, 219, 200, 246, 16, 16)
	$prCPU = GUICtrlCreateProgress(220, 247, 150, 13)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

	$btnOptimize = GUICtrlCreateButton("Optimize", 60, 75, 125, 35, $BS_DEFPUSHBUTTON)
	GUICtrlSetTip($btnOptimize,	"Optimize Memory now!", "Optimize Memory", 1, 1)
	GuiCtrlSetState($btnOptimize, $GUI_FOCUS)
	$btnOptions = GUICtrlCreateButton("Options...", 195, 75, 125, 35)
	$chkForceBehave = GUICtrlCreateCheckbox(" Force malicious processes to behave. (Optimize Processor)", 20, 115, 350, 20)
	If $SetForceBehave = 1 Then GUICtrlSetState($chkForceBehave, $GUI_CHECKED)


	GUICtrlSetOnEvent($btnOptimize, "_OptimizeItemPressed")
	GUICtrlSetOnEvent($btnOptions, "_OptionsDlg")

	$lvMemStats = GUICtrlCreateListView("", 10, 275, 365, 150)
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
	_GUICtrlListView_AddItem($lvMemStats, "  Available Memory (RAM)", 5)
	_GUICtrlListView_AddSubItem($lvMemStats, 3, "0", 1)
	_GUICtrlListView_AddItem($lvMemStats, "  Total Pagefile", 5)
	_GUICtrlListView_AddSubItem($lvMemStats, 4, "0", 1)
	_GUICtrlListView_AddItem($lvMemStats, "  Used Pagefile", 2)
	_GUICtrlListView_AddSubItem($lvMemStats, 5, "0", 1)
	_GUICtrlListView_AddItem($lvMemStats, "  Available Pagefile", 5)
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

	$btnHelp = GUICtrlCreateButton("Help", 10, 430, 100, 30)
	$btnAbout = GUICtrlCreateButton("About", 110, 430, 100, 30)
	$btnClose = GUICtrlCreateButton("Close", 240, 430, 135, 30)

	GUICtrlSetOnEvent($btnClose, "_CloseMemoryBooster")
	GUICtrlSetOnEvent($btnAbout, "_AboutDlg")
	GUICtrlSetOnEvent($btnHelp, "_OpenHelpFileContents")

	$prCount = GUICtrlCreateProgress(10, 470, 365, 15)
	$prOptimize = GUICtrlCreateProgress(10, 488, 365, 8)

	;GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseMemoryBooster")
	GUISetOnEvent($GUI_EVENT_CLOSE, "_HideMainForm")
	GUISetOnEvent($GUI_EVENT_MINIMIZE, "_UpdateGraphs")
	GUISetOnEvent($GUI_EVENT_RESTORE, "_UpdateGraphs")

	$hStatus = _GUICtrlStatusBar_Create($memBoostGUI)
	_GUICtrlStatusBar_SetParts($hStatus, $aParts)
	If $SetOpMeth = 0 Then
		_GUICtrlStatusBar_SetText($hStatus, " T:" & $Count, 1)
	ElseIf $SetOpMeth = 1 Then
		_GUICtrlStatusBar_SetText($hStatus, " T:" & $SetAutoCount, 1)
	EndIf
	_GUICtrlStatusBar_SetText($hStatus, " " & @HOUR & ":" & @MIN & ":" & @SEC & " ", 2)

	$trOptNow = TrayCreateItem("&Optimize memory")
	TrayCreateItem("")
	$trShowHide = TrayCreateItem("&Hide memBooster")
	TrayCreateItem("")
	$trClose = TrayCreateItem("&Close memBooster")

	TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "_ShowHideMainForm")
	TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "_ShowHideMainForm")

	TrayItemSetOnEvent($trOptNow, "_ClearProcessesWorkingSet")
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
				_GUICtrlStatusBar_SetText($hStatus, " Optimizing memory in " & $TotalCount & " seconds", 0)
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
				SoundPlay(@ScriptDir & "\Sounds\Mem-High.mp3", 0)
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

	$MemUs = Round(($MemInfo[1] - $MemInfo[2]) / 1024, -1)
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
		TraySetToolTip($APPSET_TITLE & " " & $APPSET_VERSION & @CRLF & _
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

	Local $hToken, $aProcsList, $forceBehave = False

	If GUICtrlRead($chkForceBehave) = $GUI_CHECKED Then
		$forceBehave = True
	ElseIf GUICtrlRead($chkForceBehave) = $GUI_UNCHECKED Then
		$forceBehave = False
	EndIf

	;If Not (@error Or @extended) Then
		$aProcsList = ProcessList()
		For $i = 1 To $aProcsList[0][0]
			_GUICtrlStatusBar_SetText($hStatus, " Clearing process " & $i & " of " & $aProcsList[0][0] & " working set")

			_WinAPI_EmptyWorkingSet($aProcsList[$i][1])
			If $forceBehave And _ProcessGetPriority($aProcsList[$i][1]) > 2 Then
				ProcessSetPriority($aProcsList[$i][0], 2)
			Else
			EndIf
			Sleep(1)

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
		TrayTip($APPSET_TITLE & " is still running.",	$APPSET_TITLE & " will continue to run so that we can keep on monitoring your system, " & _
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

	If GUICtrlRead($chkForceBehave) = $GUI_CHECKED Then
		$SetForceBehave = 1
	ElseIf GUICtrlRead($chkForceBehave) = $GUI_UNCHECKED Then
		$SetForceBehave = 0
	EndIf

	IniWrite($MBSettings, "Main", "ForceProcessesBehave", $SetForceBehave)

	TraySetState(2)
	Exit

EndFunc


Func _OptionsDlg()

	GuiCtrlSetState($btnOptions, $GUI_DISABLE)
	GuiCtrlSetState($miOptions, $GUI_DISABLE)

	Local $OptionsDlg, $BtnOptOK, $BtnOptCancel

	$OptionsDlg = GUICreate($APPSET_TITLE & " Options", 500, 400, -1, -1, BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	GUISetFont(9, 400, 0, "Tahoma", $OptionsDlg, 5)
	GUISetIcon(@ScriptFullPath, 221)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_OptionsCloseClicked", $OptionsDlg)

	GUICtrlCreateGroup("", 15, 10, 470, 100)
	$chkAutStart = GUICtrlCreateCheckbox(" Start 'Memory Booster' when Windows starts", 25, 30, 300, 15)
	$chkOnTop = GUICtrlCreateCheckbox(" Show 'Memory Booster' Always On Top", 25, 50, 300, 15)
	$chkShowNotify = GUICtrlCreateCheckbox(" Show program notifications", 25, 70, 300, 15)
	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

;~ 	GUICtrlCreateGroup("Memory optimization modes", 15, 120, 3470, 100)
;~ 	$radIntel = GUICtrlCreateRadio(" Intelligent memory optimization", 25, 145, 300, 15)
;~ 	$radAuto = GUICtrlCreateRadio(" Automatically optimize memory every", 25, 165, 227, 15)
;~ 	$comboAutSec = GUICtrlCreateCombo("", 260, 162, 55, 20)
;~ 	GUICtrlSetData($comboAutSec, "3|5|10|15|20|25|30|35|40|45|50|55|60|65|70|75|80|85|90|95|100|105|110|115|120", $SetAutoCount)
;~ 	GUICtrlCreateLabel(" sec", 320, 165, 50, 15)
;~ 	$radNoAuto = GUICtrlCreateRadio(" Don't automatically optimize memory", 25, 185, 300, 15)
;~ 	GUICtrlCreateGroup("", -99, -99, 1, 1)  ;~ Close group

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

	If $SetPlSounds = 1 Then GUICtrlSetState($chkPlSounds, $GUI_CHECKED)
	If $SetPlWarn = 1 Then GUICtrlSetState($chkPlWarn, $GUI_CHECKED)

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

	Local $abTitle = "About " & $APPSET_TITLE
	Local $abVersion, $abCopyright, $abGNU
	Local $abHome, $abDonate
	Local $abSpaceLabel, $abSpaceProg, $abBtnOK
	Local $abFacebook, $abTwittter, $abLinkedIn, $abGoogle

	$AboutDlg = GUICreate($abTitle, 400, 500, -1, -1, BitOr($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST)
	GUISetFont(9, 400, 0, "Tahoma", $AboutDlg, 5)
	GUISetIcon(@ScriptFullPath, 220)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseAboutDlg", $AboutDlg)

	GUICtrlCreateIcon(@ScriptFullPath, 99, 10, 10, 64, 64)
	$abDonate = GUICtrlCreateIcon(@ScriptFullPath, 217, 320, 0, 64, 64)
	GUICtrlSetTip($abDonate, "Help us keep our software free.")
	GUICtrlSetCursor($abDonate, 0)
	$abTitle = GUICtrlCreateLabel($APPSET_TITLE, 88, 16, 220, 18)
	GuiCtrlSetFont($abTitle, 10)
	$abVersion = GUICtrlCreateLabel("Version " & FileGetVersion(@ScriptFullPath), 88, 40, 220, 20)
	$abCopyright = GUICtrlCreateLabel("Copyright © 2014 Rizonesoft", 88, 55, 220, 20)
	GuiCtrlSetColor($abCopyright, 0x555555)

	GUICtrlCreateLabel("Rizonesoft Home: ", 20, 90, 130, 15, $SS_RIGHT)
	$abHome = GUICtrlCreateLabel("www.rizonesoft.com", 155, 90, 220, 15)
	GuiCtrlSetFont($abHome, -1, -1, 4) ;Underlined
	GuiCtrlSetColor($abHome, 0x0000FF)
	$abGNU = GUICtrlCreateLabel("This program is free software: you can redistribute it and/or modify " & _
								"it under the terms of the GNU General Public License as published by " & _
								"the Free Software Foundation, either version 3 of the License, or " & _
								"(at your option) any later version." & @CRLF & @CRLF & _
								"This program is distributed in the hope that it will be useful, " & _
								"but WITHOUT ANY WARRANTY; without even the implied warranty of " & _
								"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the " & _
								"GNU General Public License for more details.", 20, 125, 350, 180)
	GuiCtrlSetColor($abGNU, 0x555555)
	GUICtrlCreateLabel(	"Contributors: Derick Payne (Rizonesoft), Beege", 20, 280, 350, 100)

	Local $ScriptDirSplt = StringSplit(@ScriptDir, "\")
	Local $ScriptDrive  = $ScriptDirSplt[1]
	Local $drvSpaceUsed = DriveSpaceTotal($ScriptDrive) - DriveSpaceFree($ScriptDrive)

	$abSpaceLabel = GUICtrlCreateLabel("(" & $ScriptDrive & ") " & Round(DriveSpaceFree($ScriptDrive) / 1024, 1) & " GB free of " & _
					Round(DriveSpaceTotal($ScriptDrive) / 1024, 1) & " GB", 15, 380, 300, 15)
	$abSpaceProg = GUICtrlCreateProgress(15, 400, 350, 15)
	GUICtrlSetData($abSpaceProg, ($drvSpaceUsed / DriveSpaceTotal($ScriptDrive)) * 100)
	$abBtnOK = GUICtrlCreateButton("OK", 250, 450, 123, 33, $BS_DEFPUSHBUTTON)

	$abFacebook = GUICtrlCreateIcon(@ScriptFullPath, 213, 20, 450, 32, 32)
	GUICtrlSetTip($abFacebook, "Like us on Facebook and stay updated.")
	GUICtrlSetCursor($abFacebook, 0)
	$abTwittter = GUICtrlCreateIcon(@ScriptFullPath, 214, 55, 450, 32, 32)
	GUICtrlSetTip($abTwittter, "Follow us on Twitter for the latest updates.")
	GUICtrlSetCursor($abTwittter, 0)
	$abLinkedIn = GUICtrlCreateIcon(@ScriptFullPath, 215, 90, 450, 32, 32)
	GUICtrlSetTip($abLinkedIn, "Connect with us on LinkedIn")
	GUICtrlSetCursor($abLinkedIn, 0)
	$abGoogle = GUICtrlCreateIcon(@ScriptFullPath, 216, 125, 450, 32, 32)
	GUICtrlSetTip($abGoogle, "Connect with us on Google+")
	GUICtrlSetCursor($abGoogle, 0)

	GUICtrlSetOnEvent($abHome, "_HomePageClicked")
	GUICtrlSetOnEvent($abFacebook, "_OpenFacebook")
	GUICtrlSetOnEvent($abTwittter, "_FollowOnTwitter")
	GUICtrlSetOnEvent($abLinkedIn, "_OpenLinkedIn")
	GUICtrlSetOnEvent($abGoogle, "_OpenGooglePlus")
	GUICtrlSetOnEvent($abBtnOK, "_CloseAboutDlg")
	GUICtrlSetOnEvent($abDonate, "_DonateSomething")

	GUISetState(@SW_SHOW, $AboutDlg)

EndFunc


Func _CloseAboutDlg()

	GuiCtrlSetState($btnAbout, $GUI_ENABLE)
	GuiCtrlSetState($miAbout, $GUI_ENABLE)

	GUISetState(@SW_HIDE, @GUI_WinHandle)
	GuiCtrlSetState($btnOptimize, $GUI_FOCUS)

EndFunc


Func _HomePageClicked()
	ShellExecute("http://www.rizonesoft.com")
EndFunc


Func _OpenFacebook()
	ShellExecute("https://www.facebook.com/rizonesoft")
EndFunc


Func _FollowOnTwitter()
	ShellExecute("https://twitter.com/rizonesoft")
EndFunc


Func _OpenLinkedIn()
	ShellExecute("http://www.linkedin.com/in/rizonesoft")
EndFunc


Func _OpenGooglePlus()
	ShellExecute("https://plus.google.com/+Rizonesoftsa/posts")
EndFunc


Func _DonateSomething()
	ShellExecute("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7UGGCSDUZJPFE")
EndFunc