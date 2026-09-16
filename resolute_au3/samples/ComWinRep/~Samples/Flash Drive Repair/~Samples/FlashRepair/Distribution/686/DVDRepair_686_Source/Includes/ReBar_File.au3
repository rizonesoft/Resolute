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


Func _FileDelete($sFilePath)

	_EditLoggingWrite("Removing [" & $sFilePath & "]")
	Local $iDelete = FileDelete($sFilePath)

    ; Display a message of whether the file was deleted.
    If $iDelete Then
        _EditLoggingWrite("The file was successfuly deleted.")
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


Func _RemoveDirectory($sDirSource, $sDirDest, $overwrite = 1)

	If Not IsDeclared("g_ReBarRepairMode") Then Global $g_ReBarRepairMode = 1
	If FileExists($sDirSource) Then

		If Not IsDeclared("g_OptionBackupData") Then Global $g_OptionBackupData = 0

		If $g_OptionBackupData Then
			_EditLoggingWrite("Saving [" & $sDirSource & "].")
			If DirCopy($sDirSource, $sDirDest, $overwrite) Then
				_EditLoggingWrite("The directory was successfully saved to [" & $sDirDest & "].")
				_EditLoggingWrite("We will now continue with removing it.")
			Else
				_EditLoggingWrite("Error: [" & $sDirSource & "] could not be saved.")
				_EditLoggingWrite("^ To avoid data loss, this directory will not be removed.")
			EndIf
		Else
			__RemoveDirectory($sDirSource)
			__RemoveDirectory($sDirDest)
		EndIf

	EndIf

EndFunc


Func _RemoveFiles($DirPath, $sWildcards)
EndFunc


Func __RemoveDirectory($sDirPath)

	If FileExists($sDirPath) Then

		_EditLoggingWrite("Clearing [" & $sDirPath & "].")

		Local $aDirFiles = _FileListToArray($sDirPath, "*")
		If @error = 1 Then
			_EditLoggingWrite("Error: Directory Path")
			_EditLoggingWrite("^ [" & $sDirPath & "]")
			;Return
		EndIf
		If @error = 4 Then
			_EditLoggingWrite("Nothing Here")
			_EditLoggingWrite("[" & $sDirPath & "]")
			;Return
		EndIf

		If IsArray($aDirFiles) Then

			For $x = 1 To $aDirFiles[0]
				_EditLoggingWrite("Deleting [" & $aDirFiles[$x] & "]")
				_FileDelete($sDirPath & "\" & $aDirFiles[$x])
			Next

		EndIf

		_EditLoggingWrite("Removing [" & $sDirPath & "].")
		_EditLoggingWrite("Setting attributes for [" & $sDirPath & "].")
		FileSetAttrib($sDirPath, "-RASHNOT", 1)
		If DirRemove($sDirPath, 1) Then
			_EditLoggingWrite("Successfully removed [" & $sDirPath & "].")
			Return True
		Else
			_EditLoggingWrite("Error: [" & $sDirPath & "] could not be removed.")
			Return False
		EndIf

	Else

		_EditLoggingWrite("[" & $sDirPath & "] does not exist.")
		Return True

	EndIf

EndFunc


Func _CopyDirectoryWithExcl($sDirPath, $sExcludes = "")
EndFunc
