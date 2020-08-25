#include-once


#Region AutoIt3Wrapper Directives Dection
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										 ;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								 ;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Dection


#include <FontConstants.au3>
#include <GUIConstantsEx.au3>
#include <InetConstants.au3>
#include <StaticConstants.au3>
#include <WinAPIFiles.au3>
#include <WindowsConstants.au3>

#include "Link.au3"
#include "Localization.au3"
#include "Versioning.au3"
#include "WinEx.au3"


; #INDEX# =======================================================================================================================
; Title .........: Update
; AutoIt Version : 3.3.15.0
; Description ...: Update Notification Functions
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $g_aUpdateIcons[2] = [@ScriptFullPath, @ScriptFullPath]
Global $g_aDlgUpdateIcons[2] = [@ScriptFullPath, @ScriptFullPath]

If Not IsDeclared("g_hCoreGui") Then Global $g_hCoreGui
If Not IsDeclared("g_iParentState") Then Global $g_iParentState
If Not IsDeclared("g_iParent") Then Global $g_iParent
If Not IsDeclared("g_sThemesDir") Then Global $g_sThemesDir
If Not IsDeclared("g_sProgShortName") Then Global $g_sProgShortName
If Not IsDeclared("g_sProgName") Then Global $g_sProgName
If Not IsDeclared("g_sRemoteUpdateFile") Then Global $g_sRemoteUpdateFile
If Not IsDeclared("g_hUpdateGUI") Then Global $g_hUpdateGUI
If Not IsDeclared("g_sPathIni") Then Global $g_sPathIni
If Not IsDeclared("g_iCheckForUpdates") Then Global $g_iCheckForUpdates = 4
If Not IsDeclared("g_ChkUpdateNoShow") Then Global $g_ChkUpdateNoShow
If Not IsDeclared("g_iUpdateIconStart") Then Global $g_iUpdateIconStart
If Not IsDeclared("g_iMenuIconsStart") Then Global $g_iMenuIconsStart
If Not IsDeclared("g_iDialogIconStart") Then Global $g_iDialogIconStart
If Not IsDeclared("g_hUpdateMenuItem") Then Global $g_hUpdateMenuItem
If Not IsDeclared("g_sUrlCompHomePage") Then Global $g_sUrlCompHomePage
If Not IsDeclared("g_sUrlProgPage") Then Global $g_sUrlProgPage
If Not IsDeclared("g_sUrlProgUpdate") Then Global $g_sUrlProgUpdate
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _SoftwareUpdateCheck
; ===============================================================================================================================


Func _SoftwareUpdateCheck($iMenuSource = False)

	Local Const $iUpdateWidth = 300
	Local Const $iUpdateHeight = 250

	; You can not check for updates while it is checking for updates.
	If $iMenuSource = False Then
		GUICtrlSetState($g_hUpdateMenuItem, $GUI_DISABLE)
	EndIf

	Local $sLocalUpdateFile = _WinAPI_GetTempFileName(@TempDir, "u_")
	Local $hDownload = InetGet($g_sRemoteUpdateFile, $sLocalUpdateFile, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

	Do
		Sleep(250)
	Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

	; Retrieve the number of total bytes received and the filesize.
	Local $iBytesSize = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
	Local $iUpdateFileSize = FileGetSize($sLocalUpdateFile)

	; Close the handle returned by InetGet.
	InetClose($hDownload)

	If $iBytesSize = $iUpdateFileSize Then

		Local $iLocalBuild = Number(_GetProgramVersion(4))
		Local $iRemoteBuild = Number(IniRead($sLocalUpdateFile, "Update", "LatestBuild", 0))
		Local $icoUpdate, $lblUpdateMessage, $lblUpdateMessage2, $lblBuild1, $lblBuild2
		Local $lblUpdate, $chkShowNoMore, $btnUpdate, $btnOk

		$g_iCheckForUpdates = Int(IniRead($g_sPathIni, $g_sProgShortName, "CheckForUpdates", 4))
		$g_sUrlProgUpdate = IniRead($sLocalUpdateFile, "Update", "UpdateURL", _Link_Split($g_sUrlProgPage))

		Local $aUpdatePos[2] = [-1, -1]
		$g_iParentState = WinGetState($g_hCoreGui)

		If $g_iParentState > 0 Then
			$aUpdatePos = _WinEx_GetParentCentre($g_hCoreGui, $iUpdateWidth, $iUpdateHeight)
		EndIf
		__Update_SetResources()
		_Localization_Update()

		If $iLocalBuild < $iRemoteBuild Then

			If $g_iParentState > 0 Then
				GUISetState(@SW_DISABLE, $g_hCoreGui)
				$g_iParent = $g_hCoreGui
			Else
				$g_iParent = 0
			EndIf

			$g_hUpdateGUI = GUICreate($g_aLangUpdate[0], $iUpdateWidth, $iUpdateHeight, $aUpdatePos[0], $aUpdatePos[1], _
					BitOR($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST, $g_iParent)
			GUISetFont(9, 400, -1, "Verdana", $g_hUpdateGUI, $CLEARTYPE_QUALITY)
			If $g_iParentState > 0 Then GUISetIcon($g_aDlgUpdateIcons[0], $g_iDialogIconStart, $g_hUpdateGUI)
			GUISetOnEvent($GUI_EVENT_CLOSE, "__CloseUpdateDialog", $g_hUpdateGUI)

			$icoUpdate = GUICtrlCreateIcon($g_aUpdateIcons[0], $g_iUpdateIconStart, 10, 10, 64, 64)
			GUICtrlSetCursor($icoUpdate, 0)
			$lblUpdateMessage = GUICtrlCreateLabel($g_aLangUpdate[3], 84, 10, 200, 64)
			GUICtrlSetFont($lblUpdateMessage, 10)
			GUICtrlCreateLabel($g_aLangUpdate[7], 10, 89, 115, 18, $SS_RIGHT)
			GUICtrlCreateLabel($g_aLangUpdate[8], 10, 107, 115, 18, $SS_RIGHT)
			$lblBuild1 = GUICtrlCreateLabel($iLocalBuild, 130, 87, 80, 18)
			GUICtrlSetColor($lblBuild1, 0xE81123)
			GUICtrlSetFont($lblBuild1, 10)
			$lblBuild2 = GUICtrlCreateLabel($iRemoteBuild, 130, 105, 80, 18)
			GUICtrlSetColor($lblBuild2, 0x0000FF)
			GUICtrlSetCursor($lblBuild2, 0)
			GUICtrlSetFont($lblBuild2, 10)

			$g_chkUpdateNoShow = GUICtrlCreateCheckbox(Chr(32) & $g_aLangUpdate[9], 15, 140, 255, -1)
			GUICtrlSetState($g_chkUpdateNoShow, $g_iCheckForUpdates)
			$btnUpdate = GUICtrlCreateButton($g_aLangUpdate[10], ($iUpdateWidth - 250) / 2, 185, 250, 35)

			GUICtrlSetOnEvent($icoUpdate, "__OpenUpdateURL")
			GUICtrlSetOnEvent($lblBuild2, "__OpenUpdateURL")
			GUICtrlSetOnEvent($lblUpdate, "__OpenUpdateURL")
			GUICtrlSetOnEvent($btnUpdate, "__OpenUpdateURL")

			GUISetState(@SW_SHOW, $g_hUpdateGUI)

		ElseIf $iMenuSource = True And $iLocalBuild >= $iRemoteBuild Then

			Local $sUpdateDlgTitle = $g_aLangUpdate[1]
			Local $sUpdateMessage = $g_aLangUpdate[4]
			Local $sUpdateMessage2 = ""
			Local $iMessageColor = 0x169100
			Local $sUpdateIcon = $g_aUpdateIcons[0]
			Local $iUpdateIcon = $g_iUpdateIconStart
			Local $sUpdateDlgIcon = $g_aDlgUpdateIcons[0]
			Local $iUpdateDlgIcon = $g_iDialogIconStart

			If $iRemoteBuild == 0 Then
				$sUpdateDlgTitle = $g_aLangUpdate[2]
				$sUpdateMessage = $g_aLangUpdate[5]
				$sUpdateMessage2 = $g_aLangUpdate[6]
				$iMessageColor = 0xCC1D00
				$sUpdateIcon = $g_aUpdateIcons[1]
				$iUpdateIcon = $g_iUpdateIconStart + 1
				$sUpdateDlgIcon = $g_aDlgUpdateIcons[1]
				$iUpdateDlgIcon = $g_iDialogIconStart + 1
			EndIf

			If $g_iParentState > 0 Then GUISetState(@SW_DISABLE, $g_hCoreGui)
			$g_hUpdateGUI = GUICreate($sUpdateDlgTitle, $iUpdateWidth, $iUpdateHeight, $aUpdatePos[0], $aUpdatePos[1], _
					BitOR($WS_CAPTION, $WS_POPUPWINDOW), $WS_EX_TOPMOST, $g_hCoreGui)
			GUISetFont(9, 400, -1, "Verdana", $g_hUpdateGUI, $CLEARTYPE_QUALITY)
			If $g_iParentState > 0 Then GUISetIcon($sUpdateDlgIcon, $iUpdateDlgIcon, $g_hUpdateGUI)
			GUISetOnEvent($GUI_EVENT_CLOSE, "__CloseUpdateDialog", $g_hUpdateGUI)

			$icoUpdate = GUICtrlCreateIcon($sUpdateIcon, $iUpdateIcon, 10, 10, 64, 64)
			GUICtrlSetCursor($icoUpdate, 0)
			$lblUpdateMessage = GUICtrlCreateLabel($sUpdateMessage, 84, 10, 200, 80)
			GUICtrlSetColor($lblUpdateMessage, $iMessageColor)
			GUICtrlSetFont($lblUpdateMessage, 10)
			$lblUpdateMessage2 = GUICtrlCreateLabel($sUpdateMessage2, 15, 90, $iUpdateWidth - 30, 50)
			GUICtrlSetColor($lblUpdateMessage2, 0xFC6530)
			GUICtrlSetFont($lblUpdateMessage2, 9)

			$g_chkUpdateNoShow = GUICtrlCreateCheckbox(Chr(32) & $g_aLangUpdate[9], 15, 140, $iUpdateWidth - 30, -1)
			GUICtrlSetState($g_chkUpdateNoShow, $g_iCheckForUpdates)
			$btnOk = GUICtrlCreateButton($g_aLangUpdate[11], ($iUpdateWidth - 250) / 2, 185, 250, 35)

			GUICtrlSetOnEvent($icoUpdate, "__OpenHomePage")
			GUICtrlSetOnEvent($btnOk, "__CloseUpdateDialog")

			GUISetState(@SW_SHOW, $g_hUpdateGUI)

		EndIf

	EndIf

	FileDelete($sLocalUpdateFile)
	If $iMenuSource = False Then
		GUICtrlSetState($g_hUpdateMenuItem, $GUI_ENABLE)
	EndIf

EndFunc   ;==>_SoftwareUpdateCheck


Func __CloseUpdateDialog()

	IniWrite($g_sPathIni, $g_sProgShortName, "CheckForUpdates", GUICtrlRead($g_chkUpdateNoShow))
	If $g_iParentState > 0 Then
		GUISetState(@SW_ENABLE, $g_hCoreGui)
	EndIf
	GUIDelete($g_hUpdateGUI)

EndFunc   ;==>__CloseUpdateDialog


Func __OpenUpdateURL()
	ShellExecute(_Link_Split($g_sUrlProgUpdate))
EndFunc   ;==>__OpenUpdateURL

Func __OpenHomePage()
	ShellExecute(_Link_Split($g_sUrlCompHomePage))
EndFunc   ;==>__OpenHomePage


Func __Update_SetResources()

	If Not @Compiled Then
		$g_aUpdateIcons[0] = $g_sThemesDir & "\Icons\Update.ico"
		$g_aUpdateIcons[1] = $g_sThemesDir & "\Icons\Error.ico"
		$g_aDlgUpdateIcons[0] = $g_sThemesDir & "\Icons\Dialogs\Check.ico"
		$g_aDlgUpdateIcons[1] = $g_sThemesDir & "\Icons\Dialogs\Error.ico"
	EndIf

EndFunc   ;==>__Update_SetResources
