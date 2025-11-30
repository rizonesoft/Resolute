#include-once


; #INDEX# =======================================================================================================================
; Title .........: Versioning
; AutoIt Version : 3.3.15.0
; Description ...: Versioning Functions
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================


;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										 ;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								 ;~ (Y/N) Continue when only Warnings. Default=Y


#include "ReBar_Functions.au3"
#include "ReBar_Declarations.au3"
#include "ReBar_AutoIt3Script.au3"


#Region Global Variables and Constants

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================
#EndRegion Global Variables and Constants


#Region Functions list
; #CURRENT# =====================================================================================================================
; _GetProgramVersion
; _GetProgramVersionFromFile
; _GUIGetTitle
; ===============================================================================================================================
#EndRegion Functions list


; #FUNCTION# ====================================================================================================================
; Author(s) .....: Derick Payne (Rizonesoft)
; Modified ......:
; ===============================================================================================================================
Func _GetProgramVersion($iFlag = 1)

	Local $sReturn = ""

	If @Compiled Then
		$sReturn = _GetProgramVersionFromFile(@ScriptFullPath, $iFlag)
		If @error Then Return SetError(1, 0, 0)
	Else
		$sReturn = _AutoIt3Script_GetVersion(@ScriptFullPath, $iFlag)
	EndIf

	Return $sReturn

EndFunc   ;==>_GetProgramVersion


Func _GetProgramVersionFromFile($sFileName, $iFlag = 1)

	Local $sReturn = ""
	Local $sFullVersion = FileGetVersion($sFileName)

	If $iFlag == 0 Then
		$sReturn = $sFullVersion
	EndIf

	Local $sPltReturn = StringSplit($sFullVersion, ".")
	If $iFlag <= $sPltReturn[0] Then
		$sReturn = $sPltReturn[$iFlag]
	Else
		Return SetError(1, 0, 0)
	EndIf

	Return $sReturn

EndFunc   ;==>_GetProgramVersion


Func _GUIGetTitle($sGUIName)

	Local $sReturn = ""
	Local $sAdminInstance = ""
	Local $sProgamVersion = ""
	Local $sProgramBuild = ""
	Local $sAutoItArch = ""
	Local $sAutoItVers = ""

	If IsAdmin() And $g_ReBarTitleShowAdmin == 1 Then $sAdminInstance = "Administrator ~ "
	If $g_ReBarTitleShowArch == 1 Then $sAutoItArch = " : " & _AutoItGetArchitecture() & "-Bit"

	If @Compiled Then

		Local $sReturn = FileGetVersion(@ScriptFullPath)

		Local $sPltReturn = StringSplit($sReturn, ".")
		If IsArray($sPltReturn) Then

			If $g_ReBarTitleShowVersion == 1 Then $sProgamVersion = Chr(32) & $sPltReturn[1]
			If $g_ReBarTitleShowBuild == 1 Then $sProgramBuild = " : Build " & $sPltReturn[$sPltReturn[0]]
			$sReturn = $sAdminInstance & $sGUIName & $sProgamVersion & $sProgramBuild & $sAutoItArch

		EndIf

	Else

		If $g_ReBarTitleShowVersion == 1 Then $sProgamVersion = Chr(32) & _AutoIt3Script_GetVersion(@ScriptFullPath, 1)
		If $g_ReBarTitleShowBuild == 1 Then $sProgramBuild = " : Build " & _AutoIt3Script_GetVersion(@ScriptFullPath, 4)
		If $g_ReBarTitleShowAutoIt == 1 Then $sAutoItVers = " : using AutoIt version " & @AutoItVersion
		$sReturn = $sAdminInstance & $sGUIName & $sProgamVersion & $sProgramBuild & $sAutoItVers & $sAutoItArch

	EndIf

	Return $sReturn

EndFunc   ;==>_GUIGetTitle


Func _GetInternetExplorerVersion()

	Local $IEVersion = "0.0.0"

	If FileExists(@ProgramFilesDir & "\Internet Explorer\iexplore.exe") Then
		Local $sSpltString =  StringSplit(FileGetVersion(@ProgramFilesDir & "\Internet Explorer\iexplore.exe"), ".")
		If $sSpltString[0] >= 3 Then
			$IEVersion = StringStripWS($sSpltString[1] & "." & $sSpltString[2] & "." & $sSpltString[3], 8)
		EndIf
	EndIf

	Return $IEVersion

EndFunc


Func _SoftwareUpdateCheck()

	; If Not IsDeclared("g_ReBarUpdateLocal") Then Local $g_ReBarUpdateLocal

;~ 	If Not Ping("http://www.rizonesoft.com", 2000) Then
;~ 		Return
;~ 	EndIf

	Local $sLocalFile = _WinAPI_GetTempFileName($g_ReBarCachePath, "u_")
	Local $hDownload = InetGet($g_ReBarUpdateRemote, $sLocalFile, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)

	Do
		Sleep(250)
	Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

	; Retrieve the number of total bytes received and the filesize.
	Local $iBytesSize = InetGetInfo($hDownload, $INET_DOWNLOADREAD)
	Local $iUpdateFileSize = FileGetSize($sLocalFile)

	; Close the handle returned by InetGet.
	InetClose($hDownload)

	If $iBytesSize = $iUpdateFileSize Then

		Local $iLocalBuild = Number(_GetProgramVersion(4))
		; MsgBox(0, "", $iLocalBuild)
		Local $iRemoteBuild = IniRead($sLocalFile, "Update", "LatestBuild", $iLocalBuild)
		$g_ReBarUpdateURL = IniRead($sLocalFile, "Update", "UpdateURL", $g_ReBarAboutHome)

		If $iLocalBuild < Number($iRemoteBuild) Then

			Local $icoUpdate, $lblUpdateDesc, $lblBuild1, $lblBuild2, $lblUpdate

			$g_ReBarUpdateGUI = GUICreate("Update Available", 265, 180, -1, -1)
			GUISetIcon($g_ReBarResDoors, 108, $g_ReBarUpdateGUI)
			GUISetFont($g_ReBarFontSize, 400, -1, $g_ReBarFontName, $g_ReBarUpdateGUI)
			GUISetState(@SW_SHOW, $g_ReBarUpdateGUI)
			GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseUpdateDialog", $g_ReBarUpdateGUI)

			$icoUpdate = GUICtrlCreateIcon($g_ReBarResDoors, 108, 10, 10, 64, 64)
			GUICtrlSetCursor($icoUpdate, 0)
			$lblUpdateDesc = GUICtrlCreateLabel($g_ReBarProgName & " update available.", 84, 10, 180, 64)
			; GUICtrlSetColor($lblUpdateDesc, 0x00B400)
			GUICtrlSetFont($lblUpdateDesc, 10)

			GUICtrlCreateLabel("Current Build:", 10, 89, 95, 18, $SS_RIGHT)
			GUICtrlCreateLabel("Update Build:", 10, 107, 95, 18, $SS_RIGHT)
			$lblBuild1 = GUICtrlCreateLabel($iLocalBuild, 110, 87, 50, 18)
			GUICtrlSetColor($lblBuild1, 0xE81123)
			GUICtrlSetFont($lblBuild1, 10)
			$lblBuild2 = GUICtrlCreateLabel($iRemoteBuild, 110, 105, 50, 18)
			GUICtrlSetColor($lblBuild2, 0x0000FF)
			GUICtrlSetCursor($lblBuild2, 0)
			GUICtrlSetFont($lblBuild2, 10)
			$lblUpdate = GUICtrlCreateLabel("Click here to download " & $g_ReBarProgName & _
					" Build " & $iRemoteBuild & " now.", 10, 135, 245, 30)
			GUICtrlSetColor($lblUpdate, 0x0000FF)
			GUICtrlSetCursor($lblUpdate, 0)

			GUICtrlSetOnEvent($icoUpdate, "_OpenUpdateURL")
			GUICtrlSetOnEvent($lblBuild2, "_OpenUpdateURL")
			GUICtrlSetOnEvent($lblUpdate, "_OpenUpdateURL")

		EndIf

	EndIf

	FileDelete($sLocalFile)

EndFunc   ;==>_SoftwareUpdateCheck


Func _CloseUpdateDialog()
	GUIDelete($g_ReBarUpdateGUI)
EndFunc   ;==>_CloseUpdateDialog


Func _OpenUpdateURL()
	ShellExecute($g_ReBarUpdateURL)
EndFunc   ;==>_OpenUpdateURL
