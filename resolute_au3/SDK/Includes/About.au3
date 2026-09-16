#include-once


#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y                                        ;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y                                ;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include <ButtonConstants.au3>
#include <GuiEdit.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <Constants.au3>

#include "Link.au3"
#include "Localization.au3"
#include "ProgressBar.au3"
#include "Versioning.au3"


; #INDEX# =======================================================================================================================
; Title .........: About
; AutoIt Version : 3.3.15.0
; Description ...: About Dialog
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $CNT_ABOUTICONS = 9
Global Const $UPDATE_INTERVAL_MEMORY = 2000    ; Memory stats update interval in ms
Global Const $UPDATE_INTERVAL_DISK = 5000      ; Disk stats update interval in ms
Global Const $UPDATE_INTERVAL_HOVER = 50       ; Icon hover check interval in ms
Global Const $THRESHOLD_WARNING = 60           ; Warning threshold percentage
Global Const $THRESHOLD_CRITICAL = 90          ; Critical threshold percentage
Global Const $SW_MINIMIZE = 0x00000008
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $g_hAboutGui, $g_AboutProgIcon
Global $g_aAboutProgIcons[3] = [@ScriptFullPath, @ScriptFullPath, 1]
Global $g_aAboutIcons[$CNT_ABOUTICONS][4]
Global $g_sDlgAboutIcon = @ScriptFullPath
Global $g_hRAMLabel, $g_hRAMPRog1, $g_hRAMProg2
Global $g_hSpaceLabel, $g_hSpaceProg1, $g_hSpaceProg2
Global $g_aBuffers[4] = [0, 0, 0, 0]
Global $g_hLastMemUpdate = 0
Global $g_hLastDiskUpdate = 0

If Not IsDeclared("g_hCoreGui") Then Global $g_hCoreGui
If Not IsDeclared("g_iParentState") Then Global $g_iParentState
If Not IsDeclared("g_iParent") Then Global $g_iParent
If Not IsDeclared("g_hGuiIcon") Then Global $g_hGuiIcon
If Not IsDeclared("g_sProgName") Then Global $g_sProgName
If Not IsDeclared("g_sProgShortName") Then Global $g_sProgShortName
If Not IsDeclared("g_sCompanyName") Then Global $g_sCompanyName
If Not IsDeclared("g_iAboutIconStart") Then Global $g_iAboutIconStart
If Not IsDeclared("g_sUrlCompHomePage") Then Global $g_sUrlCompHomePage
If Not IsDeclared("g_sUrlSupport") Then Global $g_sUrlSupport
If Not IsDeclared("g_sUrlDownloads") Then Global $g_sUrlDownloads
If Not IsDeclared("g_sUrlFacebook") Then Global $g_sUrlFacebook
If Not IsDeclared("g_sUrlPayPal") Then Global $g_sUrlPayPal
If Not IsDeclared("g_sUrlGitHub") Then Global $g_sUrlGitHub
If Not IsDeclared("g_sUrlGitHubIssues") Then Global $g_sUrlGitHubIssues
If Not IsDeclared("g_sUrlSA") Then Global $g_sUrlSA
If Not IsDeclared("g_sUrlProgPage") Then Global $g_sUrlProgPage
If Not IsDeclared("g_sUrlProgForum") Then Global $g_sUrlProgForum
If Not IsDeclared("g_sAboutCredits") Then Global $g_sAboutCredits
If Not IsDeclared("g_iSizeIcon") Then Global $g_iSizeIcon
If Not IsDeclared("g_sThemesDir") Then Global $g_sThemesDir
If Not IsDeclared("g_iDialogIconStart") Then Global $g_iDialogIconStart
If Not IsDeclared("g_hTrItemAbout") Then Global $g_hTrItemAbout

Global $g_sCachedScriptDir = @ScriptDir
Global $g_sCachedYear = @YEAR
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _About_ShowDialog
; _About_Contact
; _About_Facebook
; _About_GitHub
; _About_GooglePlus
; _About_HomePage
; _About_PayPal
; _About_SouthAfrica
; _About_Twitter
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Author ........: Derick Payne (Rizonesoft)
; Modified.......:
; ===============================================================================================================================
Func _About_ShowDialog()

	For $xB = 0 To 3
		$g_aBuffers[$xB] = 0
	Next

	__About_SetResources()
	_Localization_About()

	$g_iParentState = WinGetState($g_hCoreGui)
	
	; Don't try to parent or modify transparency if main window is minimized
	If BitAND($g_iParentState, 16) Then  ; @SW_MINIMIZE = 16
		$g_iParent = 0
	ElseIf $g_iParentState > 0 Then
		WinSetTrans($g_hCoreGui, Default, 200)
		GUISetState(@SW_DISABLE, $g_hCoreGui)
		$g_iParent = $g_hCoreGui
	Else
		$g_iParent = 0
	EndIf

	TrayItemSetState($g_hTrItemAbout, $GUI_DISABLE)
	$g_hAboutGui = GUICreate($g_aLangAbout[0], 420, 500, -1, -1, _
			BitOR($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST, $g_iParent)
	GUISetFont(8.5, Default, Default, "Verdana", $g_hAboutGui, 5)
	If $g_iParentState > 0 And Not BitAND($g_iParentState, 16) Then 
		GUISetIcon($g_sDlgAboutIcon, $g_iDialogIconStart + 3, $g_hAboutGui)
	EndIf
	GUISetOnEvent($GUI_EVENT_CLOSE, "__About_CloseDialog", $g_hAboutGui)

	$g_AboutProgIcon = GUICtrlCreateIcon($g_aAboutProgIcons[0], 99, 10, 10, $g_iSizeIcon, $g_iSizeIcon)
	GUICtrlSetCursor($g_AboutProgIcon, 0)
	GUICtrlSetOnEvent($g_AboutProgIcon, "_About_ProgramPage")

	__About_CreateMainSection()
	__About_CreateInfoSection()
	__About_CreateStatsSection()
	__About_CreateButtonSection()

	GUISetState(@SW_SHOW, $g_hAboutGui)
	__About_SetMemoryStats()
	__About_SetDriveSpaceStats()

	AdlibRegister("__About_OnIconsHover", $UPDATE_INTERVAL_HOVER)
	AdlibRegister("__About_SetMemoryStats", $UPDATE_INTERVAL_MEMORY)
	AdlibRegister("__About_SetDriveSpaceStats", $UPDATE_INTERVAL_DISK)

EndFunc   ;==>_About_ShowDialog


Func _About_Downloads()
	ShellExecute(_Link_Split($g_sUrlDownloads))
EndFunc   ;==>_About_Downloads


Func _About_HomePage()
	ShellExecute(_Link_Split($g_sUrlCompHomePage))
EndFunc   ;==>_About_HomePage


Func _About_PayPal()
	ShellExecute(_Link_Split($g_sUrlPayPal))
EndFunc   ;==>_About_PayPal


Func _About_ProgramPage()
	ShellExecute(_Link_Split($g_sUrlProgPage))
EndFunc   ;==>_About_ProgramPage


Func _About_SouthAfrica()
	ShellExecute(_Link_Split($g_sUrlSA))
EndFunc   ;==>_About_SouthAfrica


Func _About_Facebook()
	ShellExecute(_Link_Split($g_sUrlFacebook))
EndFunc   ;==>_About_Facebook


Func _About_Support()
	ShellExecute(_Link_Split($g_sUrlSupport))
EndFunc   ;==>_About_Support


Func _About_GitHub()
	ShellExecute(_Link_Split($g_sUrlGitHub))
EndFunc   ;==>_About_GitHub


Func _About_GitHubIssues()
	ShellExecute(_Link_Split($g_sUrlGitHubIssues))
EndFunc   ;==>_About_GitHubIssues


Func __About_CloseDialog()

	AdlibUnRegister("__About_OnIconsHover")
	AdlibUnRegister("__About_SetMemoryStats")
	AdlibUnRegister("__About_SetDriveSpaceStats")

	If $g_iParentState > 0 Then
		WinSetTrans($g_hCoreGui, Default, 255)
		GUISetState(@SW_ENABLE, $g_hCoreGui)
	EndIf
	GUIDelete($g_hAboutGui)
	TrayItemSetState($g_hTrItemAbout, $GUI_ENABLE)

EndFunc   ;==>__About_CloseDialog


Func __About_OnIconsHover()

	Local $iCursorAbout = GUIGetCursorInfo()
	If Not @error Then

		If $iCursorAbout[4] = $g_AboutProgIcon And $g_aAboutProgIcons[2] == 1 Then
			$g_aAboutProgIcons[2] = 0
			GUICtrlSetImage($g_AboutProgIcon, $g_aAboutProgIcons[1], 201)
		ElseIf $iCursorAbout[4] <> $g_AboutProgIcon And $g_aAboutProgIcons[2] == 0 Then
			$g_aAboutProgIcons[2] = 1
			GUICtrlSetImage($g_AboutProgIcon, $g_aAboutProgIcons[0], 99)
		EndIf

		For $iA = 0 To $CNT_ABOUTICONS - 1
			If $iCursorAbout[4] = $g_aAboutIcons[$iA][0] And $g_aAboutIcons[$iA][3] == 1 Then
				$g_aAboutIcons[$iA][3] = 0
				GUICtrlSetImage($g_aAboutIcons[$iA][0], $g_aAboutIcons[$iA][2], $g_iAboutIconStart + ($iA * 2) + 1)
			ElseIf $iCursorAbout[4] <> $g_aAboutIcons[$iA][0] And $g_aAboutIcons[$iA][3] == 0 Then
				$g_aAboutIcons[$iA][3] = 1
				GUICtrlSetImage($g_aAboutIcons[$iA][0], $g_aAboutIcons[$iA][1], $g_iAboutIconStart + ($iA * 2))
			EndIf
		Next

	EndIf

EndFunc   ;==>__About_OnIconsHover


Func __About_SetResources()

	If @Compiled Then

		$g_sDlgAboutIcon = @ScriptFullPath
		$g_aAboutProgIcons[0] = @ScriptFullPath
		$g_aAboutProgIcons[1] = @ScriptFullPath

		For $iAi = 0 To $CNT_ABOUTICONS - 1
			$g_aAboutIcons[$iAi][1] = @ScriptFullPath
			$g_aAboutIcons[$iAi][2] = @ScriptFullPath
		Next

	Else

		$g_sDlgAboutIcon = $g_sThemesDir & "\Icons\Dialogs\Information.ico"
		$g_aAboutProgIcons[0] = $g_sThemesDir & "\Icons\" & $g_sProgShortName & ".ico"
		$g_aAboutProgIcons[1] = $g_sThemesDir & "\Icons\" & $g_sProgShortName & "H.ico"

		$g_aAboutIcons[0][1] = $g_sThemesDir & "\Icons\About\PayPal.ico"
		$g_aAboutIcons[0][2] = $g_sThemesDir & "\Icons\About\PayPalH.ico"
		$g_aAboutIcons[1][1] = $g_sThemesDir & "\Icons\About\sa.ico"
		$g_aAboutIcons[1][2] = $g_sThemesDir & "\Icons\About\saH.ico"
		$g_aAboutIcons[2][1] = $g_sThemesDir & "\Icons\About\Facebook.ico"
		$g_aAboutIcons[2][2] = $g_sThemesDir & "\Icons\About\FacebookH.ico"
		$g_aAboutIcons[3][1] = $g_sThemesDir & "\Icons\About\GitHub.ico"
		$g_aAboutIcons[3][2] = $g_sThemesDir & "\Icons\About\GitHubH.ico"

	EndIf

	For $iAh = 0 To $CNT_ABOUTICONS - 1
		$g_aAboutIcons[$iAh][3] = 1
	Next

	$g_aAboutProgIcons[2] = 1

EndFunc   ;==>__About_SetResources


Func __About_CreateMainSection()

	Local $abTitle = GUICtrlCreateLabel($g_sProgName, $g_iSizeIcon + 22, 16, 220, 18)
	GUICtrlSetFont($abTitle, 10, 700)
	GUICtrlCreateLabel($g_aLangAbout[1] & Chr(32) & _GetProgramVersion(0), $g_iSizeIcon + 22, 40, 230, 15)
	GUICtrlSetColor(-1, 0x333333)
	GUICtrlCreateLabel($g_aLangAbout[2] & Chr(32) & @AutoItVersion, $g_iSizeIcon + 22, 55, 230, 15)
	GUICtrlSetColor(-1, 0x333333)
	GUICtrlCreateLabel($g_aLangAbout[3] & " © " & $g_sCachedYear & " " & $g_sCompanyName, $g_iSizeIcon + 22, 75, 230, 15)
	GUICtrlSetColor(-1, 0x666666)
	$g_aAboutIcons[0][0] = GUICtrlCreateIcon($g_aAboutIcons[0][1], $g_iAboutIconStart, 346, 0, 64, 64)
	GUICtrlSetTip($g_aAboutIcons[0][0], $g_aLangAbout[5], $g_aLangAbout[4], $TIP_INFOICON)
	GUICtrlSetCursor($g_aAboutIcons[0][0], 0)
	GUICtrlSetOnEvent($g_aAboutIcons[0][0], "_About_PayPal")

EndFunc


Func __About_CreateInfoSection()

	GUICtrlCreateLabel("", 10, 105, 400, 1)
	GUICtrlSetBkColor(-1, 0xA0A0A0)
	GUICtrlCreateLabel("", 10, 106, 400, 1)
	GUICtrlSetBkColor(-1, 0xFFFFFF)

	Local $abHome = __About_CreateLink($g_aLangAbout[6], $g_sUrlCompHomePage, 120)
	GUICtrlSetOnEvent($abHome, "_About_HomePage")

	GUICtrlCreateLabel($g_aLangAbout[7] & ": ", 5, 138, 100, 15, $SS_RIGHT)
	GUICtrlCreateLabel("GNU General Public License 3", 110, 138, 265, 15)
	GUICtrlSetColor(-1, 0x666666)

	Local $abSupport = __About_CreateLink($g_aLangAbout[8], $g_sUrlSupport, 156)
	GUICtrlSetOnEvent($abSupport, "_About_Support")

	$g_aAboutIcons[1][0] = GUICtrlCreateIcon($g_aAboutIcons[1][1], $g_iAboutIconStart + 2, 353, 165, 48, 48)
	GUICtrlSetTip($g_aAboutIcons[1][0], $g_aLangAbout[10], $g_aLangAbout[9], $TIP_INFOICON)
	GUICtrlSetCursor($g_aAboutIcons[1][0], 0)
	GUICtrlSetOnEvent($g_aAboutIcons[1][0], "_About_SouthAfrica")

EndFunc


Func __About_CreateStatsSection()

	GUICtrlCreateGroup($g_aLangAbout[11], 10, 205, 400, 125)
	GUICtrlSetFont(-1, 10, 500, 2)
	GUICtrlCreateEdit($g_sAboutCredits, 20, 230, 380, 85, BitOR($WS_VSCROLL, $ES_READONLY), $WS_EX_CLIENTEDGE)
	GUICtrlSetColor(-1, 0x333333)
	GUICtrlSetFont(-1, 8.5, -1, 2)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$g_hRAMLabel = GUICtrlCreateLabel("", 20, 346, 380, 15)
	GUICtrlSetFont($g_hRAMLabel, 8, 700, Default, "Verdana")
	GUICtrlSetColor($g_hRAMLabel, 0x333333)
	GUICtrlSetTip($g_hRAMLabel, $g_aLangAbout[15])

	__About_CreateProgressBar($g_hRAMPRog1, $g_hRAMProg2, 365)

	$g_hSpaceLabel = GUICtrlCreateLabel("", 20, 383, 380, 15)
	GUICtrlSetFont($g_hSpaceLabel, 8, 700, Default, "Verdana")
	GUICtrlSetColor($g_hSpaceLabel, 0x333333)

	__About_CreateProgressBar($g_hSpaceProg1, $g_hSpaceProg2, 402)

EndFunc


Func __About_CreateButtonSection()

	$g_aAboutIcons[2][0] = GUICtrlCreateIcon($g_aAboutIcons[2][1], $g_iAboutIconStart + 4, 20, 455, 32, 32)
	GUICtrlSetTip($g_aAboutIcons[2][0], $g_aLangAbout[12])
	GUICtrlSetCursor($g_aAboutIcons[2][0], 0)
	GUICtrlSetOnEvent($g_aAboutIcons[2][0], "_About_Facebook")

	$g_aAboutIcons[3][0] = GUICtrlCreateIcon($g_aAboutIcons[3][1], $g_iAboutIconStart + 6, 60, 455, 32, 32)
	GUICtrlSetTip($g_aAboutIcons[3][0], $g_aLangAbout[13])
	GUICtrlSetCursor($g_aAboutIcons[3][0], 0)
	GUICtrlSetOnEvent($g_aAboutIcons[3][0], "_About_GitHub")

	Local $abBtnOK = GUICtrlCreateButton($g_aLangAbout[14], 260, 450, 150, 38, $BS_DEFPUSHBUTTON)
	GUICtrlSetFont($abBtnOK, 9)
	GUICtrlSetOnEvent($abBtnOK, "__About_CloseDialog")

EndFunc


Func __About_CreateProgressBar(ByRef $hProg1, ByRef $hProg2, $iPosY)

	GUICtrlCreateLabel("", 20, $iPosY - 2, 380, 15)
	GUICtrlSetBkColor(-1, 0x555555)
	GUICtrlCreateLabel("", 21, $iPosY - 1, 378, 13)
	GUICtrlSetBkColor(-1, 0xD3D3D3)

	$hProg1 = GUICtrlCreateLabel("", 22, $iPosY, 50, 11)
	$hProg2 = GUICtrlCreateLabel("", 23, $iPosY + 1, 48, 9)

EndFunc


Func __About_CreateLink($sLabel, $sUrl, $iPosY)

	GUICtrlCreateLabel($sLabel & ": ", 5, $iPosY, 100, 15, $SS_RIGHT)
	Local $hLink = GUICtrlCreateLabel(_Link_Split($sUrl, 2), 110, $iPosY, 265, 15)
	GUICtrlSetFont($hLink, 8.5, -1, 4)
	GUICtrlSetColor($hLink, 0x0000FF)
	GUICtrlSetCursor($hLink, 0)
	Return $hLink

EndFunc


Func __About_SetDriveSpaceStats()

	Static $sCachedDrive = "", $iLastCheck = 0
	
	If TimerDiff($iLastCheck) < $UPDATE_INTERVAL_DISK Then Return
	$iLastCheck = TimerInit()
	
	If $sCachedDrive = "" Then
		Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
		_PathSplit($g_sCachedScriptDir, $sDrive, $sDir, $sFileName, $sExtension)
		$sCachedDrive = $sDrive
	EndIf
	
	Local $iSpaceUsed = DriveSpaceTotal($sCachedDrive) - DriveSpaceFree($sCachedDrive)
	Local $iSpacePerc = Round(($iSpaceUsed / DriveSpaceTotal($sCachedDrive)) * 100)
	Local $iSpacePercFree = 100 - $iSpacePerc
	
	If $iSpaceUsed <> $g_aBuffers[0] Then
		GUICtrlSetData($g_hSpaceLabel, StringUpper(StringFormat($g_aLangAbout[16], _
				$sCachedDrive, Round(DriveSpaceFree($sCachedDrive) / 1024, 2), _
				Round(DriveSpaceTotal($sCachedDrive) / 1024, 2), $iSpacePercFree)))
		$g_aBuffers[0] = $iSpaceUsed
	EndIf
	
	If $iSpacePerc <> $g_aBuffers[1] Then
		Local $sColor = "Green"  ; Default color for normal usage
		If $iSpacePerc > $THRESHOLD_CRITICAL Then
			$sColor = "Red"      ; Critical usage level
		ElseIf $iSpacePerc > $THRESHOLD_WARNING Then
			$sColor = "Blue"     ; Warning usage level
		EndIf
		_ProgressBar_SetColors($g_hSpaceProg1, $g_hSpaceProg2, $sColor)
		
		_ProgressBar_SetData($g_hAboutGui, $g_hSpaceProg1, $g_hSpaceProg2, 22, 402, 376, $iSpacePerc)
		$g_aBuffers[1] = $iSpacePerc
	EndIf

EndFunc


Func __About_SetMemoryStats()

	Static $iLastCheck = 0
	
	If TimerDiff($iLastCheck) < $UPDATE_INTERVAL_MEMORY Then Return
	$iLastCheck = TimerInit()
	
	Local $aRAMStats = MemGetStats()
	If Not IsArray($aRAMStats) Then Return
	
	Local $iRAMFree = Round($aRAMStats[2] / 1024)
	Local $iRAMUsed = Round($aRAMStats[1] / 1024)
	Local $iRAMPerc = $aRAMStats[0]
	Local $iRAMPercFree = 100 - $iRAMPerc
	
	If $iRAMFree <> $g_aBuffers[2] Then
		GUICtrlSetData($g_hRAMLabel, StringUpper(StringFormat($g_aLangAbout[19], _
				$iRAMFree, $iRAMUsed, $iRAMPercFree)))
		$g_aBuffers[2] = $iRAMFree
		
		Local $sColor = "Green"  ; Default color for normal usage
		If $iRAMPerc > $THRESHOLD_CRITICAL Then
			$sColor = "Red"      ; Critical usage level
		ElseIf $iRAMPerc > $THRESHOLD_WARNING Then
			$sColor = "Blue"     ; Warning usage level
		EndIf
		_ProgressBar_SetColors($g_hRAMPRog1, $g_hRAMProg2, $sColor)
	EndIf
	
	If $iRAMPerc <> $g_aBuffers[3] Then
		_ProgressBar_SetData($g_hAboutGui, $g_hRAMPRog1, $g_hRAMProg2, 22, 365, 376, $iRAMPerc)
		$g_aBuffers[3] = $iRAMPerc
	EndIf

EndFunc
