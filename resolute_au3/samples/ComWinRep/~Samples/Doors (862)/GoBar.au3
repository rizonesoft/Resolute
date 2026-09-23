#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         Derick Payne

 Script Function:
	Rizonesoft Doors GoBar.

#ce ----------------------------------------------------------------------------


#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Resources\GoBar\GoBar.ico
#AutoIt3Wrapper_Res_Fileversion=0.1.5.154
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Description=Doors GoBar
#AutoIt3Wrapper_Res_LegalCopyright=© 2012 Rizonesoft
#AutoIt3Wrapper_Res_Icon_Add=Resources\GoBar\Memory.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\GoBar\Processor.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Indicators\00.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Indicators\01.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Indicators\02.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Indicators\03.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Indicators\04.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Indicators\05.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Indicators\06.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Indicators\07.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#NoTrayIcon


Opt("GUICloseOnESC", 0)         	;1=ESC  closes, 0=ESC won't close
Opt("GUIOnEventMode", 1)        	;0=disabled, 1=OnEvent mode enabled
Opt("MustDeclareVars", 1)       	;0=no, 1=require pre-declare
Opt("SendCapslockMode", 1)      	;1=store and restore, 0=don't
Opt("TrayAutoPause", 0)          	;0=no pause, 1=Pause
Opt("TrayIconDebug", 1)         	;0=no info, 1=debug line info
Opt("TrayOnEventMode", 0)        	;0=disable, 1=enable


#Include <Date.au3>
#include <GUIConstantsEx.au3>
;#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#include <UDF\FunctionsDoors.au3>
#include <UDF\ConstantsDoors.au3>
#include <UDF\FunctionsGoBar.au3>
#include <UDF\FunctionsIndicators.au3>


Global $GOBAR_INTERFACE, $BAR_MEMUSAGE, $LBL_MEMUSAGE, $BAR_PAGEUSAGE, $LBL_PAGEUSAGE, $DOORS_TIME
Global $SETTING_FNTQLTY = IniRead($DOORS_SYSTEM_INI, "Appearance", "FontQuality", 5)
Global $MEMTMP_FREE1 = 0, $MEMTMP_FREE2 = 0, $MEMTMP_FREE3 = 0
Global $KEYSTATE_ICON, $KEYSTATE_DIFF


IniWrite($DOORS_SYSTEM_INI, "Doors", "Build", _GetDoorsVersion(2))
IniWrite($DOORS_SYSTEM_INI, "Doors", "Version", _GetDoorsVersion(1))


_BuildGoBarInterface()


Func _BuildGoBarInterface()

	Local $TBar

	$GOBAR_INTERFACE = GUICreate(	"Rizonesoft Doors " & _GetDoorsVersion(1) & " ( Build " & _GetDoorsVersion(2) & " )", _
									600, 80, -1, -1, -1, $WS_EX_COMPOSITED)
	;WinSetOnTop($GOBAR_INTERFACE, "", 1)
	GUISetFont(8.5, 400, -1, "Tahoma", $GOBAR_INTERFACE, $SETTING_FNTQLTY)


	Local $mnuGo, $miWinPower, $mnuOptimize, $miMBLegacies, $mnuSysUtils, $miCDDIRep, $miCIntRep, $miQuickErase, $miWinVersion
	Local $miControl, $miClose

	$mnuGo = GUICtrlCreateMenu("::: &Go :::")

	$miWinPower = GuiCtrlCreateMenuItem("&Rizonesoft Power Suite : " & FileGetVersion(@ScriptDir & "\WinPower.exe"), $mnuGo)
	GuiCtrlCreateMenuItem("", $mnuGo)

	$mnuOptimize = GuiCtrlCreateMenu("&Optimization", $mnuGo)
	$miMBLegacies = GuiCtrlCreateMenuItem("&Memory Booster (Legacies)", $mnuOptimize)

	$mnuSysUtils = GUICtrlCreateMenu("&System Utilities", $mnuGo)
	$miCDDIRep = GuiCtrlCreateMenuItem("CD / &DVD Icon Repair", $mnuSysUtils)
	$miCIntRep = GuiCtrlCreateMenuItem("Complete &Internet Repair", $mnuSysUtils)
	$miQuickErase = GuiCtrlCreateMenuItem("Quick &Erase", $mnuSysUtils)
	GuiCtrlCreateMenuItem("", $mnuSysUtils)
	$miWinVersion = GuiCtrlCreateMenuItem("&Windows Version", $mnuSysUtils)

	GuiCtrlCreateMenuItem("", $mnuGo)


	$miControl = GuiCtrlCreateMenuItem("Doors Control &Panel...", $mnuGo)
	GuiCtrlCreateMenuItem("", $mnuGo)
	$miClose = GuiCtrlCreateMenuItem("&Close ", $mnuGo)

	GUICtrlCreateIcon(@ScriptFullPath, 201, 5, 5, 16, 16)

	$LBL_MEMUSAGE = GuiCtrlCreateLabel(" 100% - 99000MB", 130, 3, 90, 11)
	GuiCtrlSetFont($LBL_MEMUSAGE, 7, 400, -1, "Tahoma", 5)
	$BAR_MEMUSAGE = GuiCtrlCreateLabel("", 26, 6, 10, 6)
	GUICtrlSetBkColor($BAR_MEMUSAGE, 0x68CEFA)
	GuiCtrlCreateLabel("", 25, 5, 100, 8)
	GUICtrlSetBkColor(-1, 0x071320)

	$BAR_PAGEUSAGE = GuiCtrlCreateLabel("", 26, 16, 50, 6)
	GUICtrlSetBkColor($BAR_PAGEUSAGE, 0xFABA00)
	$LBL_PAGEUSAGE = GuiCtrlCreateLabel(" 100% - 99000MB", 130, 14, 90, 11)
	GuiCtrlSetFont($LBL_PAGEUSAGE, 7, 400, -1, "Tahoma", 5)
	GuiCtrlCreateLabel("", 25, 15, 100, 8)
	GUICtrlSetBkColor(-1, 0x071320)

	$KEYSTATE_ICON = GuiCtrlCreateIcon(@ScriptFullPath, 203, 5, 38, 16, 16)

	GuiCtrlCreateLabel("", 500, 35, 1, 40) ;~ Seperator 1
	GUICtrlSetBKColor(-1, 0x68CEFA)
	$DOORS_TIME = GuiCtrlCreateLabel("00:00:00", 540, 40, 300, 20)
	GUICtrlSetColor($DOORS_TIME, 0x68CEFA)
	GuiCtrlSetBkColor($DOORS_TIME, $GUI_BKCOLOR_TRANSPARENT)
	$TBar = GUICtrlCreateLabel("", -10, 30, 620, 50) ;~ Bottom Bar
	GUICtrlSetBkColor($TBar, 0x071320)

	If Not FileExists(@ScriptDir & "\Control.exe") Then GUICtrlSetState($miControl, $GUI_DISABLE)

	_UpdateDoorsTime()
	_GatherDisplayStats()
	_UpdateDisplayColors()

	GUISetState(@SW_SHOW)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseMe")

	GuiCtrlSetOnEvent($miCDDIRep, "_LaunchCDDVDIconRepair")
	GuiCtrlSetOnEvent($miCIntRep, "_LaunchCompleteInternetRepair")
	GuiCtrlSetOnEvent($miQuickErase, "_LaunchQuickErase")

	GuiCtrlSetOnEvent($miMBLegacies, "_ShowMemoryBoosterLegacies")

	GuiCtrlSetOnEvent($miWinVersion, "_DisplayWindowsAboutDlg")
	GuiCtrlSetOnEvent($miControl, "_OpenDoorsControlPanel")
	GuiCtrlSetOnEvent($miClose, "_CloseMe")

	AdlibRegister("_UpdateDoorsTime", 1000)
	AdlibRegister("_GatherDisplayStats", 1500)
	AdlibRegister("_UpdateDisplayColors", 5000)
	AdlibRegister("_toggleKeysState", 500)

	While 1
		Sleep(50)
	WEnd

EndFunc


#region Programs Menu

Func _ShowMemoryBoosterLegacies()
	ShellExecute(@ScriptDir & "\memBoostl.exe")
EndFunc

Func _LaunchCDDVDIconRepair()
	ShellExecute(@ScriptDir & "\CDDIRep.exe")
EndFunc

Func _LaunchCompleteInternetRepair()
	ShellExecute(@ScriptDir & "\CIntRep.exe")
EndFunc

Func _LaunchQuickErase()
	ShellExecute(@ScriptDir & "\QuickErace.exe")
EndFunc

#endregion


Func _UpdateDoorsTime()

	Local $currTime = _Date_Time_GetLocalTime()
	GuiCtrlSetData($DOORS_TIME, _Date_Time_SystemTimeToTimeStr($currTime))

EndFunc


Func _GatherDisplayStats()

	Local $memStats = MemGetStats()

	If $memStats[2] <> $MEMTMP_FREE1 Then
		_DrawStatusSizeFromPercentage($BAR_MEMUSAGE, $memStats[0], 25, 5, 100, 8)
		GuiCtrlSetData($LBL_MEMUSAGE, " " & $memStats[0] & "% - " & Round($memStats[1] / 1024) & "MB")
		$MEMTMP_FREE1 = $memStats[2]
	EndIf

	If $MemStats[4] <> $MEMTMP_FREE2 Then
		Local $pageUsPerc = Round((($memStats[3] - $memStats[4]) / $memStats[3]) * 100)
		_DrawStatusSizeFromPercentage($BAR_PAGEUSAGE, $pageUsPerc, 25, 15, 100, 8)
		GuiCtrlSetData($LBL_PAGEUSAGE, " " & $pageUsPerc & "% - " & Round($memStats[3] / 1024) & "MB")
		$MEMTMP_FREE2 = $memStats[4]
	EndIf

EndFunc


Func _UpdateDisplayColors()

	Local $colMemStats = MemGetStats()

	If $colMemStats[0] <> $MEMTMP_FREE3 Then
		If $colMemStats[0] > 85 Then
			GUICtrlSetBkColor($BAR_MEMUSAGE, 0xFC0038)
			GuiCtrlSetColor($LBL_MEMUSAGE, 0xB60038)
		ElseIf $colMemStats[0] < 85 Then
			GUICtrlSetBkColor($BAR_MEMUSAGE, 0x68CEFA)
			GuiCtrlSetColor($LBL_MEMUSAGE, 0x000000)
		EndIf
		$MEMTMP_FREE3 = $colMemStats[0]
	EndIf

EndFunc


Func _OpenDoorsControlPanel()
	ShellExecute(@ScriptDir & "\Control.exe")
EndFunc


Func _toggleKeysState()

	Local $KeyState = 0

	If _GetNumLockState() <> 0 then
		$KeyState += 1
	EndIf

	If _GetScrollLockState() <> 0 Then
		$KeyState += 2
	EndIf

	If _GetCapsLockState() <> 0 Then
		$KeyState += 4
	EndIf

	If $KEYSTATE_DIFF <> $KeyState Then

	Select
		Case $KeyState = 1
			GUICtrlSetImage($KEYSTATE_ICON, @ScriptFullPath, 204)
		Case $KeyState = 2
			GUICtrlSetImage($KEYSTATE_ICON, @ScriptFullPath, 205)
		Case $KeyState = 3
			GUICtrlSetImage($KEYSTATE_ICON, @ScriptFullPath, 206)
		Case $KeyState = 4
			GUICtrlSetImage($KEYSTATE_ICON, @ScriptFullPath, 207)
		Case $KeyState = 5
			GUICtrlSetImage($KEYSTATE_ICON, @ScriptFullPath, 208)
		Case $KeyState = 6
			GUICtrlSetImage($KEYSTATE_ICON, @ScriptFullPath, 209)
		Case $KeyState = 7
			GUICtrlSetImage($KEYSTATE_ICON, @ScriptFullPath, 210)
		Case Else
			GUICtrlSetImage($KEYSTATE_ICON, @ScriptFullPath, 203)
	EndSelect

	$KEYSTATE_DIFF = $KeyState
	EndIf

EndFunc


Func _DisplayWindowsAboutDlg()
	_WinAPI_AboutDlg(	"Windows Version", "Windows Version Information", _
						"Rizonesoft Doors " & _GetDoorsVersion(1) & " ( Build " & _GetDoorsVersion(2) & " ) " & @CRLF & _
						"Copyright © 2012 Rizonesoft. " & @TAB & "no nonsense", _
						_WinAPI_ShellExtractIcon(@ScriptFullPath, 0, 32, 32), $GOBAR_INTERFACE)
EndFunc


Func _CloseMe()

	GUIDelete($GOBAR_INTERFACE)
	Exit

EndFunc

