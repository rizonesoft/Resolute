#include-once

#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section

#include <File.au3>

#include "Localization.au3"
#include "Logging.au3"


; #INDEX# =======================================================================================================================
; Title .........: FileEx
; AutoIt Version : 3.3.15.0
; Language ......: English
; Description ...: File and Folder Management.
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================


; #VARIABLES# ===================================================================================================================
If Not IsDeclared("g_iSetBackupData") Then Global $g_iSetBackupData = 0
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _FileEx_BackupRemoveDirectory
; _FileEx_CleanDirectory
; _FileEx_CleanDirectoryName
; _FileEx_FileDelete
; _FileEx_GetExtension
; _FileEx_PathSplit
; _FileEx_ProgramFileExists
; _FileEx_RemoveFileName
; ===============================================================================================================================


Func _FileEx_BackupRemoveDirectory($sDirSource, $sDirDest, $overwrite = 1)

	If FileExists($sDirSource) Then

		If $g_iSetBackupData = 1 Then
			_Logging_EditWrite(StringFormat($g_aLangFile[0], $sDirSource))
			If DirCopy($sDirSource, $sDirDest, $overwrite) Then
				_Logging_EditWrite(StringFormat($g_aLangFile[1], $sDirDest))
				_Logging_EditWrite($g_aLangFile[2])
				_FileEx_CleanDirectory($sDirSource)
			Else
				_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangFile[3], $sDirSource), "ERROR"))
				_Logging_EditWrite("^ " & $g_aLangFile[4])
			EndIf
		Else
			_FileEx_CleanDirectory($sDirSource)
			_FileEx_CleanDirectory($sDirDest)
		EndIf

	EndIf

EndFunc   ;==>_FileEx_BackupRemoveDirectory


Func _FileEx_CleanDirectory($sDirPath)

	Local $sFullPath

	If FileExists($sDirPath) Then

		_Logging_EditWrite(StringFormat($g_aLangFile[5], $sDirPath))

		Local $aDirFiles = _FileListToArray($sDirPath, "*")
		If @error = 1 Then
			_Logging_EditWrite(_Logging_SetLevel($g_aLangFile[6], "ERROR"))
			_Logging_EditWrite(StringFormat("^ '%s'", $sDirPath))
		EndIf
		If @error = 4 Then
			_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangFile[7], $sDirPath), "ERROR"))
		EndIf

		If IsArray($aDirFiles) Then

			For $x = 1 To $aDirFiles[0]
				$sFullPath = $sDirPath & "\" & $aDirFiles[$x]
				If StringInStr(FileGetAttrib($sFullPath), "D") Then
					_Logging_EditWrite(StringFormat($g_aLangFile[9], $aDirFiles[$x]))
					FileSetAttrib($sFullPath, "-RASHNOT", 1)
					If DirRemove($sFullPath, 1) Then
						_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangFile[10], $aDirFiles[$x]), "SUCCESS"))
					Else
						_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangFile[8], $aDirFiles[$x]), "ERROR"))
					EndIf
				Else
					; FileDelete($sFullPath)
					_FileEx_FileDelete($sDirPath & "\" & $aDirFiles[$x])
				EndIf
			Next

		EndIf

	Else
		_Logging_EditWrite("'" & $sDirPath & "' does not exist.")
		Return True
	EndIf

EndFunc   ;==>_FileEx_CleanDirectory


Func _FileEx_CleanDirectoryName($sFileName)

	If StringCompare(StringLeft($sFileName, 1), "\") = 0 Then
		Return StringTrimLeft($sFileName, 1)
	Else
		Return $sFileName
	EndIf

EndFunc   ;==>_FileEx_CleanDirectoryName


Func _FileEx_FileDelete($sFilePath)

	_Logging_EditWrite(StringFormat($g_aLangFile[11], $sFilePath))
	If FileDelete($sFilePath) Then
		_Logging_EditWrite(_Logging_SetLevel($g_aLangFile[12], "SUCCESS"))
	Else
		_Logging_EditWrite(_Logging_SetLevel($g_aLangFile[13], "ERROR"))
		_Logging_EditWrite(StringFormat("^ '%s'", $sFilePath))
	EndIf

EndFunc   ;==>_FileEx_FileDelete


Func _FileEx_GetExtension($sFileName, $fExists = 0)

	If $fExists Then
		If (Not FileExists($sFileName)) Or (StringInStr(FileGetAttrib($sFileName), "D")) Then
			Return ""
		EndIf
	EndIf

	Local $sData = StringSplit($sFileName, "\")

	If IsArray($sData) Then
		If StringInStr($sData[$sData[0]], ".") Then
			Return StringRegExpReplace($sData[$sData[0]], "^.*\.", "")
		EndIf
	EndIf
	Return ""

EndFunc   ;==>_FileEx_GetExtension


Func _FileEx_PathSplit($sFullPath, $iFlag = 2)

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = "", $sReturn
	Local $aPathSplit = _PathSplit($sFullPath, $sDrive, $sDir, $sFileName, $sExtension)

	Switch $iFlag
		Case 1
			$sReturn = $sDrive
		Case 2
			$sReturn = $sDrive & $sDir
		Case 3
			$sReturn = $sFileName
		Case 4
			$sReturn = $sExtension
		Case 5
			$sReturn = $sFileName & $sExtension
	EndSwitch

	Return $sReturn

EndFunc   ;==>_FileEx_PathSplit


Func _FileEx_OpenTextFile($sFileName)

	_Logging_EditWrite(StringFormat($g_aLangFile[14], _FileEx_PathSplit($sFileName, 5)))
	If FileExists($sFileName) Then
		ShellExecute($sFileName)
		_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangFile[15], _FileEx_PathSplit($sFileName, 5)), "SUCCESS"))
	Else
		_Logging_EditWrite(_Logging_SetLevel(StringFormat($g_aLangFile[16], $sFileName), "ERROR"))
	EndIf

EndFunc


Func _FileEx_ProgramFileExists($sFileName)

	If @OSArch = "X64" Then
		Local $sFileName86 = StringReplace($sFileName, "Program Files", "Program Files (x86)")
		If FileExists($sFileName86) Then Return True
		If FileExists($sFileName) Then Return True
		Return False
	Else
		If FileExists($sFileName) Then Return True
		Return False
	EndIf

	Return False

EndFunc   ;==>_FileEx_ProgramFileExists


Func _FileEx_RemoveFileName($sPath)

	Local $sCleanPath = StringReplace($sPath, Chr(34), "")
	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sCleanPath, $sDrive, $sDir, $sFileName, $sExtension)
	Return ($sDrive & $sDir)

EndFunc   ;==>_FileEx_RemoveFileName
