#include-once

#include <WinAPILocale.au3>

#include "ReBar_Logging.au3"


; #INDEX# =======================================================================================================================
; Title .........: ReBar File
; AutoIt Version : 3.3.15.0
; Description ...: Functions that assist with files and directories.
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

#Region Global Variables and Constants

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================
#EndRegion Global Variables and Constants


#Region Functions list
; #CURRENT# =====================================================================================================================
; _FileGetExtension
; ==============================================================================================================================
#EndRegion Functions list


Func _BackupRemoveDirectory($sDirSource, $sDirDest, $overwrite = 1)

	If Not IsDeclared("g_ReBarRepairMode") Then Global $g_ReBarRepairMode = 1
	If FileExists($sDirSource) Then

		If Not IsDeclared("g_PrefsBackupData") Then Global $g_PrefsBackupData = 0

		If $g_PrefsBackupData  = 1 Then
			_EditLoggingWrite("Saving [" & $sDirSource & "].")
			If DirCopy($sDirSource, $sDirDest, $overwrite) Then
				_EditLoggingWrite("The directory was successfully saved to [" & $sDirDest & "].")
				_EditLoggingWrite("We will now continue with removing it.")
				_CleanDirectory($sDirSource)
			Else
				_EditLoggingWrite("Error: [" & $sDirSource & "] could not be saved.")
				_EditLoggingWrite("^ To avoid data loss, this directory will not be removed.")
			EndIf
		Else
			_CleanDirectory($sDirSource)
			_CleanDirectory($sDirDest)
		EndIf

	EndIf

EndFunc


Func _FileDelete($sFilePath)

	_EditLoggingWrite("Removing [" & $sFilePath & "]")
    If FileDelete($sFilePath) Then
        _EditLoggingWrite("The file was successfully deleted.")
    Else
		_EditLoggingWrite("An error occurred whilst deleting the file.")
		_EditLoggingWrite("^ [" & $sFilePath & "]")
    EndIf

EndFunc


; #FUNCTION# ====================================================================================================================
; Author(s) .....: Yashied
; Modified ......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _FileGetExtension($sFile, $fExists = 0)

	If $fExists Then
		If (Not FileExists($sFile)) Or (StringInStr(FileGetAttrib($sFile), "D")) Then
			Return ""
		EndIf
	EndIf

	Local $Data = StringSplit($sFile, "\")

	If IsArray($Data) Then
		If StringInStr($Data[$Data[0]], ".") Then
			Return StringRegExpReplace($Data[$Data[0]], "^.*\.", "")
		EndIf
	EndIf
	Return ""
EndFunc


Func _OpenTextFile($sFileName)

	; _StartLogging("Opening [" & $sFileName & "]")
	If FileExists($sFileName) Then
		ShellExecute($sFileName)
		; _EditLoggingWrite("Success: Showing [" & $sFileName & "] file.")
		Return SetError(0, 0, 1)
	Else
		; _EditLoggingWrite("Error: Could not find the [" & $sFileName & "] file.")
		Return SetError(1, 0, 0)
	EndIf
	; _EndLogging()

EndFunc


Func _ProgramFileExists($sFileName)

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

EndFunc


Func _CleanDirectory($sDirPath)

	Local $sFullPath

	If FileExists($sDirPath) Then

		_EditLoggingWrite("Clearing [" & $sDirPath & "].")

		Local $aDirFiles = _FileListToArray($sDirPath, "*")
		If @error = 1 Then
			_EditLoggingWrite("Error: Directory Path")
			_EditLoggingWrite("^ [" & $sDirPath & "]")
		EndIf
		If @error = 4 Then
			_EditLoggingWrite("Nothing Here: [" & $sDirPath & "]")
		EndIf

		If IsArray($aDirFiles) Then

			For $x = 1 To $aDirFiles[0]
				$sFullPath = $sDirPath & "\" & $aDirFiles[$x]
				If StringInStr(FileGetAttrib($sFullPath), "D") Then
					_EditLoggingWrite("Setting attributes for [" & $aDirFiles[$x] & "].")
					FileSetAttrib($sFullPath, "-RASHNOT", 1)
					If DirRemove($sFullPath, 1) Then
						_EditLoggingWrite("Successfully removed [" & $aDirFiles[$x] & "].")
					Else
						_EditLoggingWrite("Error: [" & $aDirFiles[$x] & "] could not be removed.")
					EndIf
				Else
					; FileDelete($sFullPath)
					_FileDelete($sDirPath & "\" & $aDirFiles[$x])
				EndIf
			Next

		EndIf



	Else

		_EditLoggingWrite("[" & $sDirPath & "] does not exist.")
		Return True

	EndIf

EndFunc


;~ Func _CopyDirectoryWithExcl($sDirPath, $sExcludes = "")
;~ EndFunc
