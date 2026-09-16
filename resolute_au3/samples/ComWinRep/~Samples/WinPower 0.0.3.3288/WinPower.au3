#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.2.0
 Author:         Rizone Technologies

 Script Function:
	Rizone Utility Suite.

#ce ----------------------------------------------------------------------------


#NoTrayIcon
#RequireAdmin


#AutoIt3Wrapper_icon=Resources\WinPower.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=Rizone Power Suite
#AutoIt3Wrapper_Res_Fileversion=0.0.3.3289
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y


Opt("GUICloseOnESC", 0)
Opt("TrayMenuMode", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("GUIOnEventMode", 1)
Opt("TrayOnEventMode", 1)
Opt("MouseClickDelay", 5)
Opt('MustDeclareVars', 1)
Opt("MouseClickDownDelay", 5)
Opt("MouseClickDragDelay", 200)
;Opt("TrayIconDebug", 1) ; 0 = no info, 1 = debug line info


#include <WindowsConstants.au3>
#include <ListboxConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <GuiConstantsEx.au3>
#Include <GuiEdit.au3>
#include <Misc.au3>

#include <UDF\Administration.au3>
#include <UDF\Repair.au3>


Global Const $GPowerSettings = @ScriptDir & "\WinPower.ini"
Global Const $PowerTitle = "Rizone Power Suite", $PowerVer = FileGetVersion(@ScriptDir & "\" & @ScriptName)
Global Const $GFormTitle = $PowerTitle & " " & $PowerVer
Global Const $ResDir = @ScriptDir & "\Resources"
Global Const $GThemeDir = @ScriptDir & "\Themes"
Global Const $PowerIcoRes = $ResDir & "\WinPower.ico"

Global $PowerForm, $eComDesc, $eStatus, $PowerIcon, $GPowAni


_Main()


Func _Main()

	Local $AdminMenu, $ManConMenu, $McEvntView
	Local $ReprMenu, $RepWins

	$PowerForm = GUICreate($GFormTitle, 800, 540, 395, 210)
	GUISetFont(8.5, 400, 0, "Verdana")
	GUISetBkColor(0xEBEBEB)

	$AdminMenu = GUICtrlCreateMenu("&Administration")
	$ManConMenu = GUICtrlCreateMenu("&Management Console", $AdminMenu)
	$McEvntView = GuiCtrlCreateMenuItem("&Event Viewer", $ManConMenu)
	$ReprMenu = GUICtrlCreateMenu("&Repair")
	$RepWins = GuiCtrlCreateMenuItem("&Winsock Repair", $ReprMenu)

	GUICtrlSetOnEvent($McEvntView, "_OpenEventViewer")
	GUICtrlSetOnEvent($RepWins, "_OpenWinsockRepair")

	Local $iaHGap = 400, $iaVGap = 10, $iaCount = 13, $iaSize = 48, $iaGap = 5, $alpIcon[$iaCount + 1]

	GUICtrlCreateGroup("", $iaHGap, $iaVGap, Ceiling($iaCount / 2) * $iaSize + (2 + (Ceiling($iaCount / 2) + 1) * $iaGap), 2 * $iaSize + 3 * $iaGap + 10)
	For $a = 0 To $iaCount
		If $a < $iaCount / 2 Then
			$alpIcon[$a] = GUICtrlCreateIcon(	"", -1, $iaHGap + $iaGap + ($a * $iaSize) + ($a * $iaGap) + 1, _
												$iaVGap + 2 * $iaGap + 2, $iaSize, $iaSize, $SS_NOTIFY)
		Else
			Local $b = $a - Ceiling($iaCount / 2)
			$alpIcon[$a] = GUICtrlCreateIcon(	"", -1, $iaHGap + $iaGap + ($b * $iaSize) + ($b * $iaGap) + 1, _
												$iaVGap + 3 * $iaGap + $iaSize + 2, $iaSize, $iaSize, $SS_NOTIFY)
		EndIf
		;GUICtrlSetOnEvent($lpIcon[$a], "_StartLaunchPadApps")
		GuiCtrlSetCursor($alpIcon[$a], 0)
	Next

	GUICtrlSetImage($alpIcon[11], $ResDir & "\DocError.ico", -1)
	GUICtrlSetTip($alpIcon[11], "WinsRepair.exe could not be found!", "Oops!", 3, 1)
	GUICtrlSetImage($alpIcon[12], $ResDir & "\DocError.ico", -1)
	GUICtrlSetTip($alpIcon[12], "WinsRepair.exe could not be found!", "Oops!", 3, 1)

	Local $ibHGap = 400, $ibVGap = 135, $ibCount = 13, $ibSize = 48, $ibGap = 5, $blpIcon[$ibCount + 1]

	GUICtrlCreateGroup("", $ibHGap, $ibVGap, Ceiling($ibCount / 2) * $ibSize + (2 + (Ceiling($ibCount / 2) + 1) * $ibGap), 2 * $ibSize + 3 * $iaGap + 10)
	For $i = 0 To $ibCount
		If $i < $ibCount / 2 Then
			$blpIcon[$i] = GUICtrlCreateIcon(	"", -1, $ibHGap + $ibGap + ($i * $ibSize) + ($i * $ibGap) + 1, _
												$ibVGap + 2 * $ibGap + 2, $ibSize, $ibSize, $SS_NOTIFY)
		Else
			Local $j = $i - Ceiling($ibCount / 2)
			$blpIcon[$i] = GUICtrlCreateIcon(	"", -1, $ibHGap + $ibGap + ($j * $ibSize) + ($j * $ibGap) + 1, _
												$ibVGap + 3 * $ibGap + $ibSize + 2, $ibSize, $ibSize, $SS_NOTIFY)
		EndIf
		;GUICtrlSetOnEvent($lpIcon[$a], "_StartLaunchPadApps")
		GuiCtrlSetCursor($blpIcon[$i], 0)
	Next

	Local $icHGap = 400, $icVGap = 259, $icCount = 9, $icSize = 48, $icGap = 5, $clpIcon[$icCount + 1]

	GUICtrlCreateGroup("", $icHGap, $icVGap, Ceiling($icCount / 2) * $icSize + (2 + (Ceiling($icCount / 2) + 1) * $icGap), 2 * $icSize + 3 * $iaGap + 10)
	For $m = 0 To $icCount
		If $m < $icCount / 2 Then
			$clpIcon[$m] = GUICtrlCreateIcon(	"", -1, $icHGap + $icGap + ($m * $icSize) + ($m * $icGap) + 1, _
												$icVGap + 2 * $icGap + 2, $icSize, $icSize, $SS_NOTIFY)
		Else
			Local $n = $m - Ceiling($icCount / 2)
			$clpIcon[$m] = GUICtrlCreateIcon(	"", -1, $icHGap + $icGap + ($n * $icSize) + ($n * $icGap) + 1, _
												$icVGap + 3 * $icGap + $icSize + 2, $icSize, $icSize, $SS_NOTIFY)
		EndIf
		GuiCtrlSetCursor($clpIcon[$m], 0)
	Next

	GUICtrlSetImage($clpIcon[1], $GThemeDir & "\WinsRepair.ico", -1)
	GUICtrlSetTip($clpIcon[1], "WinsRepair.exe could not be found!", "Oops!", 3, 1)

	GUICtrlSetOnEvent($clpIcon[1], "_OpenWinsockRepair")

	$eStatus = GUICtrlCreateEdit("", 10, 390, 570, 100)
	$PowerIcon = GUICtrlCreateIcon($PowerIcoRes, -1, 600, 395, 64, 64, $SS_NOTIFY)

	GUISetOnEvent($GUI_EVENT_CLOSE, "_CLosedClicked")

	GUISetState(@SW_SHOW, $PowerForm)

	While 1
		Sleep(50) ; Idle
	WEnd

EndFunc


Func _CLosedClicked()

	Local $PID

	;~ TraySetState(2)
	GUIDelete($PowerForm)
	$PID = ProcessExists(@ScriptName) ; Will return the PID or 0 if the process isn't found.
	If $PID Then ProcessClose($PID)
	Exit

EndFunc