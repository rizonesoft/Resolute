#include-once


#include <StringConstants.au3>
#include <InetConstants.au3>
#include <WinAPIFiles.au3>
#include <WinAPI.au3>
#include <File.au3>

#include "ReBar_Declarations.au3"
#include "ReBar_AutoIt3Script.au3"


Func _GetParentPath($sFullPath)

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sFullPath, $sDrive, $sDir, $sFileName, $sExtension)

	Return $sDrive & $sDir

EndFunc


Func _GetWindowsVersion()

	Local $sReturn = ""
    Local $sWinVersion = @OSVersion
	If StringRegExp(FileGetVersion('winver.exe'), "^10\.\d") Then $sWinVersion = "WIN_10"
	$sReturn = StringReplace($sWinVersion, "WIN_", "Windows ",  $STR_CASESENSE)
	Return $sReturn

EndFunc


Func _AutoItGetArchitecture()

	If @AutoItX64 Then
		Return 64
	Else
		Return 32
	EndIf

EndFunc


Func _CheckResources($sResFile)

	If Not IsDeclared("REBAR_PROG_NAME") Then Global $REBAR_PROG_NAME
	If Not IsDeclared("REBAR_MSG_TIMEOUT") Then Global $REBAR_MSG_TIMEOUT

	If Not FileExists($sResFile) Then

		If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
		$iMsgBoxAnswer = MsgBox($MB_OK + $MB_ICONHAND, "Required resources missing!", "A required resource file (" & $sResFile & ") " & _
				"is missing. This file keeps all the pretty icons. Why somebody would not like pretty icons is beyond me? " & _
				"What would you do with all this extra space?" & $REBAR_PROG_NAME, $REBAR_MSG_TIMEOUT)
		Select
			Case $iMsgBoxAnswer = -1 ;Timeout
			Case Else ;OK
		EndSelect
	EndIf

EndFunc   ;==>_CheckResources


; #FUNCTION# ====================================================================================================================
; Author ........: Rizonesoft (Derick Payne)
; Modified.......:
; ===============================================================================================================================
Func _GetDriveFromPath($sFileFullPath)

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sFileFullPath, $sDrive, $sDir, $sFileName, $sExtension)
	Return $sDrive

EndFunc


Func _IsInstalledOnCDROM($sFileFullPath)

	Local $sDrive = _GetDriveFromPath($sFileFullPath)
	Local $iDriveType = _WinAPI_GetDriveType($sDrive)

	If $iDriveType = $DRIVE_CDROM Then
		Return True
	EndIf

	Return False

EndFunc


; #FUNCTION# ====================================================================================================================
; Author.........: KaFu
; URL............: https://www.autoitscript.com/forum/topic/133076-looking-for-a-non-invasive-way-to-check-if-a-file-or-directory-is-writable-deletable-solved/#comment-927626
; Modified.......:
; Returns........: 1 = Success, file is writeable and deletable.
;                  2 = Access Denied because of lacking access rights OR because file is open by another process.
;                  3 = File is set "Read Only" by attribute.
;                  4 = File not found.
; ===============================================================================================================================
Func _FileWriteAccessible($sFile)

    If Not FileExists("\\?\" & $sFile) Then Return 4 ; File not found
    If StringInStr(FileGetAttrib("\\?\" & $sFile), "R", 2) Then Return 3 ; Read-Only Flag set
    Local $hFile = _WinAPI_CreateFileEx("\\?\" & $sFile, 3, 2, 7, 0x02000000)
    If $hFile = 0 Then Return 2 ; File not accessible, UAC issue?
    _WinAPI_CloseHandle($hFile)
    Return 1 ; Success

EndFunc   ;==>_FileWriteAccessible


Func _AddParenthesisToName($sName)

	If StringInStr($sName, Chr(32)) Then
		Return Chr(91) & $sName & Chr(93)
	EndIf

	Return $sName

EndFunc


Func _DrawStatusSizeFromPercentage($FrBar, $Perc, $BcLeft, $BcTop, $BcWidth, $BcHeight)

	If $Perc > -1 Then
		If $Perc > 100 Then $Perc = 100
		If $Perc = 0 Then
			GUICtrlSetState($FrBar, 32)
		Else

			If BitAND(GUICtrlGetState($FrBar), 32) = 32 Then
				GUICtrlSetState($FrBar, 16)
			EndIf
			GUICtrlSetPos($FrBar, $BcLeft + 1, $BcTop + 1, (($BcWidth - 2) * $Perc) / 100, $BcHeight - 2)
		EndIf
	EndIf

EndFunc


Func _ReBarRebootWindows()

	Local $iMBox = MsgBox(65, "Rebooting Windows!", "Make sure your work is saved before continuing. " & _
			"Answer 'OK' to reboot your computer or 'Cancel' if you would like to reboot later." & @CRLF & @CRLF & _
			"Your computer will reboot automatically in 60 seconds.", 60)
	Switch $iMBox
		Case 1, -1
			Shutdown(18)
		Case 2
			Return
	EndSwitch

EndFunc   ;==>_RebootWindows