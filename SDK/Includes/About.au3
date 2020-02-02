#include-once


#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include <ButtonConstants.au3>
#include <GuiEdit.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

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
Global Const $CNT_ABOUTICONS = 6
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $g_hAboutGui, $g_AboutProgIcon
Global $g_aAboutProgIcons[3] = [@ScriptFullPath, @ScriptFullPath, 1]
Global $g_aAboutIcons[$CNT_ABOUTICONS][4]
Global $g_sDlgAboutIcon = @ScriptFullPath
Global $g_hRAMLabel, $g_hRAMPRog1, $g_hRAMProg2
Global $g_hSpaceLabel, $g_hSpaceProg1, $g_hSpaceProg2
Global $g_aBuffers[4] = [0, 0, 0, 0]

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
If Not IsDeclared("g_sUrlTwitter") Then Global $g_sUrlTwitter
If Not IsDeclared("g_sUrlGooglePlus") Then Global $g_sUrlGooglePlus
If Not IsDeclared("g_sUrlRSS") Then Global $g_sUrlRSS
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

	Local $abTitle, $abHome, $abSupport
	Local $abGNU, $abBtnOK

	__About_SetResources()
	_Localization_About()

	$g_iParentState = WinGetState($g_hCoreGui)

	If $g_iParentState > 0 Then
		WinSetTrans($g_hCoreGui, Default, 200)
		GUISetState(@SW_DISABLE, $g_hCoreGui)
		$g_iParent = $g_hCoreGui
	Else
		$g_iParent = 0
	EndIf

	TrayItemSetState($g_hTrItemAbout, $GUI_DISABLE)
	$g_hAboutGui = GUICreate($g_aLangAbout[0], 420, 500, -1, -1, _
			BitOR($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST, $g_iParent)
	GUISetFont(8.5, 400, 0, "Verdana", $g_hAboutGui, 5)
	If $g_iParentState > 0 Then GUISetIcon($g_sDlgAboutIcon, $g_iDialogIconStart + 3, $g_hAboutGui)
	GUISetOnEvent($GUI_EVENT_CLOSE, "__About_CloseDialog", $g_hAboutGui)

	$g_AboutProgIcon = GUICtrlCreateIcon($g_aAboutProgIcons[0], 99, 10, 10, $g_iSizeIcon, $g_iSizeIcon)
	GUICtrlSetCursor($g_AboutProgIcon, 0)
	GUICtrlSetOnEvent($g_AboutProgIcon, "_About_ProgramPage")

	$abTitle = GUICtrlCreateLabel($g_sProgName, $g_iSizeIcon + 22, 16, 220, 18)
	GUICtrlSetFont($abTitle, 11, 700)
	GUICtrlCreateLabel($g_aLangAbout[1] & Chr(32) & _GetProgramVersion(0), $g_iSizeIcon + 22, 40, 230, 15)
	GUICtrlCreateLabel($g_aLangAbout[2] & Chr(32) & @AutoItVersion, $g_iSizeIcon + 22, 55, 230, 15)
	GUICtrlCreateLabel($g_aLangAbout[3] & " © " & @YEAR & " " & $g_sCompanyName, $g_iSizeIcon + 22, 75, 230, 15)
	GUICtrlSetColor(-1, 0x666666)
	$g_aAboutIcons[0][0] = GUICtrlCreateIcon($g_aAboutIcons[0][1], $g_iAboutIconStart, 346, 0, 64, 64)
	GUICtrlSetTip($g_aAboutIcons[0][0], $g_aLangAbout[5], $g_aLangAbout[4], $TIP_INFOICON, $TIP_BALLOON)
	GUICtrlSetCursor($g_aAboutIcons[0][0], 0)

	GUICtrlCreateLabel("", 10, 105, 400, 1)
	GUICtrlSetBkColor(-1, 0xA0A0A0)
	GUICtrlCreateLabel("", 10, 106, 400, 1)
	GUICtrlSetBkColor(-1, 0xFFFFFF)

	GUICtrlCreateLabel($g_aLangAbout[6] & ": ", 5, 120, 100, 15, $SS_RIGHT)
	$abHome = GUICtrlCreateLabel(_Link_Split($g_sUrlCompHomePage, 2), 110, 120, 265, 15)
	GUICtrlSetFont($abHome, 8.5, -1, 4) ;Underlined
	GUICtrlSetColor($abHome, 0x0000FF)
	GUICtrlSetCursor($abHome, 0)
	GUICtrlCreateLabel($g_aLangAbout[7] & ": ", 5, 138, 100, 15, $SS_RIGHT)
	$abGNU = GUICtrlCreateLabel("GNU General Public License 3", 110, 138, 265, 15)
	GUICtrlSetColor($abGNU, 0x666666)
	GUICtrlCreateLabel($g_aLangAbout[8] & ": ", 5, 156, 100, 15, $SS_RIGHT)
	$abSupport = GUICtrlCreateLabel(_Link_Split($g_sUrlSupport, 2), 110, 156, 265, 15)
	GUICtrlSetFont($abSupport, 8.5, -1, 4) ;Underlined
	GUICtrlSetColor($abSupport, 0x0000FF)
	GUICtrlSetCursor($abSupport, 0)

	$g_aAboutIcons[1][0] = GUICtrlCreateIcon($g_aAboutIcons[1][1], $g_iAboutIconStart + 2, 353, 165, 48, 48)
	GUICtrlSetTip($g_aAboutIcons[1][0], $g_aLangAbout[10], $g_aLangAbout[9], $TIP_INFOICON, $TIP_BALLOON)
	GUICtrlSetCursor($g_aAboutIcons[1][0], 0)

	GUICtrlCreateGroup($g_aLangAbout[11], 10, 205, 400, 125)
	GUICtrlSetFont(-1, 10, 700, 2)
	GUICtrlCreateEdit($g_sAboutCredits, 20, 230, 380, 85, BitOR($WS_VSCROLL, $ES_READONLY), $WS_EX_CLIENTEDGE)
	GUICtrlSetColor(-1, 0x333333)
	GUICtrlSetFont(-1, 8.5, -1, 2)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$g_hRAMLabel = GUICtrlCreateLabel("", 20, 346, 380, 15)
	GUICtrlSetFont($g_hRAMLabel, 8, 700)
	GUICtrlSetColor($g_hRAMLabel, 0x333333)
	GUICtrlSetTip($g_hRAMLabel, $g_aLangAbout[18])

	GUICtrlCreateLabel("", 20, 363, 380, 15)
	GUICtrlSetBkColor(-1, 0x555555)
	GUICtrlSetTip(-1, $g_aLangAbout[18])
	GUICtrlCreateLabel("", 21, 364, 378, 13)
	GUICtrlSetBkColor(-1, 0xD3D3D3)
	GUICtrlSetTip(-1, $g_aLangAbout[18])

	$g_hRAMPRog1 = GUICtrlCreateLabel("", 22, 365, 50, 11)
	GUICtrlSetTip($g_hRAMPRog1, $g_aLangAbout[18])
	$g_hRAMProg2 = GUICtrlCreateLabel("", 23, 366, 48, 9)
	GUICtrlSetTip($g_hRAMProg2, $g_aLangAbout[18])

	$g_hSpaceLabel = GUICtrlCreateLabel("", 20, 383, 380, 15)
	GUICtrlSetFont($g_hSpaceLabel, 8, 700)
	GUICtrlSetColor($g_hSpaceLabel, 0x333333)

;~ ProgressBar Background
	GUICtrlCreateLabel("", 20, 400, 380, 15)
	GUICtrlSetBkColor(-1, 0x555555)
	GUICtrlCreateLabel("", 21, 401, 378, 13)
	GUICtrlSetBkColor(-1, 0xD3D3D3)
;~ ProgressBar
	$g_hSpaceProg1 = GUICtrlCreateLabel("", 22, 402, 50, 11)
	$g_hSpaceProg2 = GUICtrlCreateLabel("", 23, 403, 48, 9)

	$abBtnOK = GUICtrlCreateButton($g_aLangAbout[16], 260, 450, 150, 38, $BS_DEFPUSHBUTTON)
	GUICtrlSetFont($abBtnOK, 9)

	$g_aAboutIcons[2][0] = GUICtrlCreateIcon($g_aAboutIcons[2][1], $g_iAboutIconStart + 4, 20, 455, 32, 32)
	GUICtrlSetTip($g_aAboutIcons[2][0], $g_aLangAbout[12])
	GUICtrlSetCursor($g_aAboutIcons[2][0], 0)
	$g_aAboutIcons[3][0] = GUICtrlCreateIcon($g_aAboutIcons[3][1], $g_iAboutIconStart + 6, 55, 455, 32, 32)
	GUICtrlSetTip($g_aAboutIcons[3][0], $g_aLangAbout[13])
	GUICtrlSetCursor($g_aAboutIcons[3][0], 0)
	$g_aAboutIcons[4][0] = GUICtrlCreateIcon($g_aAboutIcons[4][1], $g_iAboutIconStart + 8, 90, 455, 32, 32)
	GUICtrlSetTip($g_aAboutIcons[4][0], $g_aLangAbout[14])
	GUICtrlSetCursor($g_aAboutIcons[4][0], 0)
	$g_aAboutIcons[5][0] = GUICtrlCreateIcon($g_aAboutIcons[5][1], $g_iAboutIconStart + 10, 125, 455, 32, 32)
	GUICtrlSetTip($g_aAboutIcons[5][0], $g_aLangAbout[15])
	GUICtrlSetCursor($g_aAboutIcons[5][0], 0)

	GUICtrlSetOnEvent($abBtnOK, "__About_CloseDialog")
	GUICtrlSetOnEvent($abHome, "_About_HomePage")
	GUICtrlSetOnEvent($abSupport, "_About_Support")
	GUICtrlSetOnEvent($g_aAboutIcons[0][0], "_About_PayPal")
	GUICtrlSetOnEvent($g_aAboutIcons[1][0], "_About_SouthAfrica")
	GUICtrlSetOnEvent($g_aAboutIcons[2][0], "_About_Facebook")
	GUICtrlSetOnEvent($g_aAboutIcons[3][0], "_About_Twitter")
	GUICtrlSetOnEvent($g_aAboutIcons[4][0], "_About_GooglePlus")
	GUICtrlSetOnEvent($g_aAboutIcons[5][0], "_About_GitHub")

	GUISetState(@SW_SHOW, $g_hAboutGui)
	__About_SetMemoryStats()
	__About_SetDriveSpaceStats()

	AdlibRegister("__About_OnIconsHover", 50)
	AdlibRegister("__About_SetMemoryStats", 3000)
	AdlibRegister("__About_SetDriveSpaceStats", 5000)

EndFunc   ;==>_About_ShowDialog


Func _About_Support()
	ShellExecute(_Link_Split($g_sUrlSupport))
EndFunc   ;==>_About_Contact


Func _About_Downloads()
	ShellExecute(_Link_Split($g_sUrlDownloads))
EndFunc   ;==>_About_Downloads


Func _About_Facebook()
	ShellExecute(_Link_Split($g_sUrlFacebook))
EndFunc   ;==>_About_Facebook


Func _About_GitHub()
	ShellExecute(_Link_Split($g_sUrlGitHub))
EndFunc   ;==>_About_GitHub


Func _About_GitHubIssues()
	ShellExecute(_Link_Split($g_sUrlGitHubIssues))
EndFunc   ;==>_About_GitHubIssues


Func _About_GooglePlus()
	ShellExecute(_Link_Split($g_sUrlGooglePlus))
EndFunc   ;==>_About_GooglePlus


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


Func _About_Twitter()
	ShellExecute(_Link_Split($g_sUrlTwitter))
EndFunc   ;==>_About_Twitter


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
		$g_aAboutIcons[3][1] = $g_sThemesDir & "\Icons\About\Twitter.ico"
		$g_aAboutIcons[3][2] = $g_sThemesDir & "\Icons\About\TwitterH.ico"
		$g_aAboutIcons[4][1] = $g_sThemesDir & "\Icons\About\GooglePlus.ico"
		$g_aAboutIcons[4][2] = $g_sThemesDir & "\Icons\About\GooglePlusH.ico"
		$g_aAboutIcons[5][1] = $g_sThemesDir & "\Icons\About\GitHub.ico"
		$g_aAboutIcons[5][2] = $g_sThemesDir & "\Icons\About\GitHubH.ico"

	EndIf

	For $iAh = 0 To $CNT_ABOUTICONS - 1
		$g_aAboutIcons[$iAh][3] = 1
	Next

	$g_aAboutProgIcons[2] = 1

EndFunc   ;==>__About_SetResources


Func __About_SetDriveSpaceStats()

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	_PathSplit(@ScriptDir, $sDrive, $sDir, $sFileName, $sExtension)
	Local $iSpaceUsed = DriveSpaceTotal($sDrive) - DriveSpaceFree($sDrive)
	Local $iSpacePerc = Round(($iSpaceUsed / DriveSpaceTotal($sDrive)) * 100)
	Local $iSpacePercFree = 100 - $iSpacePerc

	If $iSpaceUsed <> $g_aBuffers[0] Then
		GUICtrlSetData($g_hSpaceLabel, StringUpper(StringFormat($g_aLangAbout[19], _
				$sDrive, Round(DriveSpaceFree($sDrive) / 1024, 2), Round(DriveSpaceTotal($sDrive) / 1024, 2), $iSpacePercFree)))
		$g_aBuffers[0] = $iSpaceUsed
	EndIf

	If $iSpacePerc <> $g_aBuffers[1] Then

		If $iSpacePerc >= 0 And $iSpacePerc < 60 Then
			_ProgressBar_SetColors($g_hSpaceProg1, $g_hSpaceProg2, "Green")
		ElseIf $iSpacePerc > 60 And $iSpacePerc < 90 Then
			_ProgressBar_SetColors($g_hSpaceProg1, $g_hSpaceProg2, "Blue")
		ElseIf $iSpacePerc > 90 And $iSpacePerc <= 100 Then
			_ProgressBar_SetColors($g_hSpaceProg1, $g_hSpaceProg2, "Red")
		EndIf

		_ProgressBar_SetData($g_hAboutGui, $g_hSpaceProg1, $g_hSpaceProg2, 22, 402, 376, $iSpacePerc)
		$g_aBuffers[1] = $iSpacePerc

	EndIf

EndFunc   ;==>__About_SetDriveSpaceStats


Func __About_SetMemoryStats()

	Local $aRAMStats = MemGetStats()
	Local $iRAMFree = 10, $iRAMPerc = 10, $iRAMPercFree = 10

	If IsArray($aRAMStats) Then

		$iRAMFree = Round($aRAMStats[2] / 1024)
		$iRAMPerc = $aRAMStats[0]
		$iRAMPercFree = 100 - $aRAMStats[0]

		If $iRAMFree <> $g_aBuffers[2] Then
			GUICtrlSetData($g_hRAMLabel, StringUpper(StringFormat($g_aLangAbout[17], _
					$iRAMFree, Round($aRAMStats[1] / 1024), $iRAMPercFree)))
			$g_aBuffers[2] = $iRAMFree
		EndIf

		If $iRAMPerc <> $g_aBuffers[3] Then
			If $iRAMPerc >= 0 And $iRAMPerc < 60 Then
				_ProgressBar_SetColors($g_hRAMPRog1, $g_hRAMProg2, "Green")
			ElseIf $iRAMPerc > 60 And $iRAMPerc < 90 Then
				_ProgressBar_SetColors($g_hRAMPRog1, $g_hRAMProg2, "Blue")
			ElseIf $iRAMPerc > 90 And $iRAMPerc <= 100 Then
				_ProgressBar_SetColors($g_hRAMPRog1, $g_hRAMProg2, "Red")
			EndIf

			_ProgressBar_SetData($g_hAboutGui, $g_hRAMPRog1, $g_hRAMProg2, 22, 365, 376, $iRAMPerc)
			$g_aBuffers[3] = $iRAMPerc
		EndIf

	EndIf

EndFunc   ;==>__About_SetMemoryStats
