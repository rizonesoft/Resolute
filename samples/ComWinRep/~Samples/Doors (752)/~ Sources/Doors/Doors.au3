#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\Doors.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Description=Rizonesoft Doors System
#AutoIt3Wrapper_Res_Fileversion=0.0.0.77
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Res_Icon_Add=Resources\Error.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Cinema.ico
#AutoIt3Wrapper_Res_Icon_Add=Resources\Globe.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)


#include <StaticConstants.au3>
#include <GuiConstantsEx.au3>

#include <UDF\Components_Accessories.au3>
#include <UDF\Components_Control.au3>


Global $doorsForm


_BuildMainGUI()


Func _BuildMainGUI()

	$doorsForm = GUICreate("Rizonesoft Doors 1 : " & FileGetVersion(@ScriptFullPath), 750, 550, -1, -1)
	GUISetFont(8.5, 400, 0, "Verdana")
	GUISetBkColor(0xEBEBEB)


	; ===============================================================================================================================
	; Control Menu
	; ===============================================================================================================================
	Local $controlMenu, $playthroughItem
	$controlMenu = GUICtrlCreateMenu("&Control")


	; ===============================================================================================================================
	; Accessories Menu
	; ===============================================================================================================================
	Local $accessoriesMenu, $multiMenu, $homeCinemaItem, $evilPlayerItem, $winLameItem, $repairDivXItem, $editMP3TagsItem
	Local $repairMP3Item

	$accessoriesMenu = GUICtrlCreateMenu("&Accessories")
	$multiMenu = GUICtrlCreateMenu("&Multimedia", $accessoriesMenu, 0)
	$homeCinemaItem = GUICtrlCreateMenuItem("Home &Cinema", $multiMenu, 0)
	$evilPlayerItem = GUICtrlCreateMenuItem("&Listen to some music [EvilPlayer]", $multiMenu, 1)
	GUICtrlCreateMenuItem("", $multiMenu, 2)
	$winLameItem = GUICtrlCreateMenuItem("Convert &audio files [winLAME]", $multiMenu, 3)
	$editMP3TagsItem = GUICtrlCreateMenuItem("&Edit MP3 Tags", $multiMenu, 4)
	GUICtrlCreateMenuItem("", $multiMenu, 5)
	$repairDivXItem = GUICtrlCreateMenuItem("Repair &DivX movies", $multiMenu, 6)
	$repairMP3Item = GUICtrlCreateMenuItem("Repair M&P3 audio files", $multiMenu, 7)

	GUICtrlSetOnEvent($evilPlayerItem, "_LaunchEvilPlayer")
	GUICtrlSetOnEvent($winLameItem, "_LaunchWinLAME")
	GUICtrlSetOnEvent($editMP3TagsItem, "_LaunchMP3TagTools")
	GUICtrlSetOnEvent($repairDivXItem, "_LaunchDivXRepair")
	GUICtrlSetOnEvent($repairMP3Item, "_LaunchMP3Repair")
	GUICtrlSetOnEvent($homeCinemaItem, "_LaunchHomeCinema")


	Local $iaHGap = 350, $iaVGap = 10, $iaCount = 13, $iaSize = 48, $iaGap = 5, $alpIcon[$iaCount + 1]

	GUICtrlCreateGroup("", $iaHGap, $iaVGap, Round($iaCount / 2) * $iaSize + (2 + (Round($iaCount / 2) + 1) * $iaGap), 2 * $iaSize + 3 * $iaGap + 10)
	For $a = 0 To $iaCount
		If $a < $iaCount / 2 Then
			$alpIcon[$a] = GUICtrlCreateIcon(	@ScriptFullPath, 99, $iaHGap + $iaGap + ($a * $iaSize) + ($a * $iaGap) + 1, _
												$iaVGap + 2 * $iaGap + 2, $iaSize, $iaSize, $SS_NOTIFY)
		Else
			Local $b = $a - Round($iaCount / 2)
			$alpIcon[$a] = GUICtrlCreateIcon(	@ScriptFullPath, 99, $iaHGap + $iaGap + ($b * $iaSize) + ($b * $iaGap) + 1, _
												$iaVGap + 3 * $iaGap + $iaSize + 2, $iaSize, $iaSize, $SS_NOTIFY)
		EndIf
		;GUICtrlSetOnEvent($lpIcon[$a], "_StartLaunchPadApps")
		GuiCtrlSetCursor($alpIcon[$a], 0)
	Next

	GUICtrlSetImage($alpIcon[1], @ScriptFullPath, 203)


	If Not $FOUND_EVILPLAYER Then GUICtrlSetState($evilPlayerItem, $GUI_DISABLE)
	If Not $FOUND_WINLAME Then GUICtrlSetState($winLameItem, $GUI_DISABLE)
	If Not $FOUND_MP3TAGTOOLS Then GUICtrlSetState($editMP3TagsItem, $GUI_DISABLE)
	If Not $FOUND_DIVXREPAIR Then GUICtrlSetState($repairDivXItem, $GUI_DISABLE)
	If Not $FOUND_MP3REPAIR Then GUICtrlSetState($repairMP3Item, $GUI_DISABLE)
	If Not $FOUND_HOMECINEMA Then
		GUICtrlSetState($homeCinemaItem, $GUI_DISABLE)
		GUICtrlSetImage($alpIcon[0], @ScriptFullPath, 201)
		GUICtrlSetTip($alpIcon[0], 	"Home Cinema could not be found!" & @CRLF & _
									"Should be @ '" & $CORE_HOMECINEMA & "'", "Oops!", 3, 1)
	Else
		GUICtrlSetImage($alpIcon[0], @ScriptFullPath, 202)
		GUICtrlSetTip($alpIcon[0], 	"Relax and watch some movies.", "Home Cinema", 1, 1)
	EndIf

	GUICtrlSetOnEvent($alpIcon[0], "_LaunchHomeCinema")


	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseDoors")

	GUISetState(@SW_SHOW, $doorsForm)


	While 1
		Sleep(50) ; Idle
	WEnd

EndFunc


Func _CloseDoors()
	_CloseApplication($doorsForm)
EndFunc
