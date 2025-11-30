#include-once


#include <StringConstants.au3>

#include "CoreConstants.au3"
#include "Logging.au3"


Func _CheckInstallation()


EndFunc


;========================================================================================================================
; File Functions.
;========================================================================================================================

; #FUNCTION# ====================================================================================================
; Author ........: Derick Payne
; ===============================================================================================================
;~ Func _RemoveDirectory($sDirSource, $sDirDest, $overwrite = 1)

;~ 	_EditLoggingWrite("Removing [" & $sDirSource & "].")
;~ 	__RemoveDirectory($sDirDest)

;~ 	If FileExists($sDirSource) Then

;~ 		If DirCopy($sDirSource, $sDirDest, $overwrite) Then
;~ 			_EditLoggingWrite("The directory was successfully backed up to [" & $sDirDest & "].")
;~ 				Sleep(100)
;~ 			_EditLoggingWrite("We will now continue with removing it.")
;~ 			If __RemoveDirectory($sDirSource) Then
;~ 				Return 1
;~ 			Else
;~ 				Return 0
;~ 			EndIf
;~ 		Else
;~ 			_EditLoggingWrite("Error: [" & $sDirSource & "] could not be saved.")
;~ 				Sleep(100)
;~ 			If $CONF_REPAIRMODE = 1 Then
;~ 				If __RemoveDirectory($sDirSource) Then
;~ 					Return 1
;~ 				Else
;~ 					Return 0
;~ 				EndIf
;~ 			Else
;~ 				_EditLoggingWrite("To avoid data loss, this directory will not be removed.")
;~ 				Return 0
;~ 			EndIf
;~ 		EndIf

;~ 	Else
;~ 		Return 1
;~ 	EndIf

;~ EndFunc


; #FUNCTION# ====================================================================================================
; Author ........: Derick Payne
; ===============================================================================================================
;~ Func __RemoveDirectory($sDirPath, $recurse = 1)

;~ 	If FileExists($sDirPath) Then

;~ 			Sleep(1000)
;~ 		FileSetAttrib($sDirPath, "-RASHNOT", $recurse)

;~ 		If DirRemove($sDirPath, $recurse) Then
;~ 			_EditLoggingWrite("Successfully removed [" & $sDirPath & "].")
;~ 			Return 1
;~ 		Else
;~ 			_EditLoggingWrite("Error: [" & $sDirPath & "] could not be removed.")
;~ 			Return 0
;~ 		EndIf

;~ 	Else
;~ 		_EditLoggingWrite("[" & $sDirPath & "] does not exist.")
;~ 		Return 1
;~ 	EndIf

;~ EndFunc


;========================================================================================================================
; Registry Functions.
;========================================================================================================================

Func _RegistryWrite($hKey, $hValueName = "REG_NONE", $hRegType = "REG_SZ", $hValue = "")

	If $hValueName = "REG_NONE" Then
		RegWrite($hKey)
	Else
		RegWrite($hKey, $hValueName, $hRegType, $hValue)
	EndIf

	Local $nError = @error
	If $nError Then
		If $hValueName = "REG_NONE" Then
			_EditLoggingWrite("Could not write to [" & $hKey & "]")
		Else
			_EditLoggingWrite("Could not write to [" & $hKey & " --> " & $hValueName & " --> " & $hRegType & " --> " & $hValue & "]")
		EndIf
		_ReturnRegistryError($nError)
	Else
		Return True
	EndIf

	Return False

EndFunc



Func _ProgramFileExists($sFileName)

	If @OSArch = "X64" Then

		Local $sFileName86 = StringReplace($sFileName, "Program Files", "Program Files (x86)")

		If FileExists($sFileName86) Then
			Return True
		EndIf

		If FileExists($sFileName) Then
			Return True
		EndIf

		Return False

	Else

		If FileExists($sFileName) Then
			Return True
		EndIf

		Return False

	EndIf

	Return False

EndFunc





Func _GUIGetTitle($sGUIName)

	Local $sReturn = ""

	If @Compiled Then

		Local $sReturn = FileGetVersion(@ScriptFullPath)

		Local $sPltReturn = StringSplit($sReturn, ".")
		If IsArray($sPltReturn) Then
			$sReturn = $sGUIName & " " & $sPltReturn[1] & " : Build " & $sPltReturn[$sPltReturn[0]]
		EndIf

	Else

		$sReturn = $sGUIName & " : using AutoIt version: " & @AutoItVersion & " " & _AutoItGetArchitecture() & "-Bit"

	EndIf

	Return $sReturn

EndFunc


Func _GetWindowsVersion($sWinVer)

	Local $sReturn = ""
	$sReturn = StringReplace($sWinVer, "WIN_", "Windows ",  $STR_CASESENSE)
	$sReturn = StringReplace($sReturn, "81", "8.1",  $STR_CASESENSE)
	Return $sReturn

EndFunc


Func _AutoItGetArchitecture()

	If @AutoItX64 Then
		Return 64
	Else
		Return 32
	EndIf

EndFunc


Func _SwitchRegistryError($nError)

	Switch @error
		Case 1
			_EditLoggingWrite("Unable to open requested key!")
		Case 2
			_EditLoggingWrite("Unable to open requested main key!")
		Case 3
			_EditLoggingWrite("Unable to remote connect to the registry!")
		Case -1
			_EditLoggingWrite("Unable to delete requested value!")
		Case -2
			_EditLoggingWrite("Unable to delete requested key/value!")
	EndSwitch

EndFunc


Func _BeginProcess($CtrlIcon, $CtrlCheckbox, $isDownload = false)

	GUICtrlSetImage($CtrlIcon, $FILE_PROCSNANI)
	GUICtrlSetState($CtrlCheckbox, $GUI_CHECKED)
	GUICtrlSetState($CtrlCheckbox, $GUI_DISABLE)

EndFunc


Func _EndProcess($CtrlIcon, $CtrlCheckbox, $iconIndex)

	GUICtrlSetImage($CtrlIcon, @ScriptFullPath, 205)
	GUICtrlSetState($CtrlCheckbox, $GUI_UNCHECKED)
	GUICtrlSetState($CtrlCheckbox, $GUI_ENABLE)
	GUICtrlSetImage($CtrlIcon, @ScriptFullPath, $iconIndex)

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
			Sleep(10)
		EndIf
	EndIf

EndFunc


Func _RegistryDelete($hKey, $hValue = "REG_NONE")

	If $hValue = "REG_NONE" Then
		RegDelete($hKey)
	Else
		RegDelete($hKey, $hValue)
	EndIf

	Local $nError = @error
	If $nError Then
		If $hValue = "REG_NONE" Then
			_EditLoggingWrite("Could not remove branch [" & $hKey & "]")
		Else
			_EditLoggingWrite("Could not remove " & Chr(34) & $hValue & Chr(34) & " in branch [" & $hKey & "]")
		EndIf
		_ReturnRegistryError($nError)
	EndIf

EndFunc


;~ Func _ReregisterDLL($sFileName, $Param = "/s")

;~ 	Local $sCleanFileName = StringReplace($sFileName, Chr(34), "", 0, $STR_NOCASESENSE)

;~ 	Local $eRegSvr32

;~ 	;~ If Not $Cancel Then
;~ 		;~ _MemoLogWrite("RegSvr32.exe: Registering '" & $FilePath & "'.....")
;~ 		$eRegSvr32 = ShellExecuteWait("regsvr32.exe", " " & $Param & " " & $sFileName, "")

;~ 		Switch $eRegSvr32
;~ 			Case 0
;~ 				_EditLoggingWrite("RegSvr32.exe: [" & $sCleanFileName & "] registration succeeded.")
;~ 			Case 1
;~ 				_EditLoggingWrite("RegSvr32.exe: [" & $sCleanFileName & "] To register a module, you must provide a binary name.")
;~ 			Case 3
;~ 				_EditLoggingWrite("RegSvr32.exe: [" & $sCleanFileName & "] Specified module not found")
;~ 			Case 4
;~ 				_EditLoggingWrite("RegSvr32.exe: [" & $sCleanFileName & "] Module loaded but entry-point DllRegisterServer was not found.")
;~ 			Case 5
;~ 				_EditLoggingWrite("RegSvr32.exe: [" & $sCleanFileName & "] Error number: 0x80070005")
;~ 		EndSwitch
;~ 	;~ EndIf

;~ 	If $eRegSvr32 >= 1 Then
;~ 		Return 0
;~ 	Else
;~ 		Return 1
;~ 	EndIf

;~ EndFunc   ;==>_ReregisterDLL


;~ Func _ReturnRegistryError($nError)
;~ 	Switch $nError
;~ 		Case 1
;~ 			_EditLoggingWrite("Unable to open requested key!")
;~ 		Case 2
;~ 			_EditLoggingWrite("Unable to open requested main key!")
;~ 		Case 3
;~ 			_EditLoggingWrite("Unable to remote connect to the registry!")
;~ 		Case -1
;~ 			_EditLoggingWrite("Unable to delete requested value!")
;~ 		Case -2
;~ 			_EditLoggingWrite("Unable to delete requested key/value!")
;~ 	EndSwitch
;~ EndFunc


Func _RunCommand($sCommand)

	Local $iCMD = Run(@ComSpec & " /c " & $sCommand, @SystemDir, @SW_HIDE, $STDERR_MERGED)
	Local $sOutput, $sSuccess = ""

	While 1
		$sOutput = StdoutRead($iCMD)
		If @error Then
			ExitLoop
		EndIf
		If __HasOutput($sOutput) Then
			_EditLoggingWrite(StringStripWS($sOutput, $STR_STRIPLEADING + $STR_STRIPTRAILING))
			Sleep(50)
		EndIf
	WEnd

EndFunc


Func __HasOutput($sOutput)

	$sOutput = StringStripWS($sOutput, $STR_STRIPLEADING + $STR_STRIPTRAILING + $STR_STRIPSPACES)

	Switch $sOutput
		Case "", ".", ".."
			Return False
		Case Else
			Return True
	EndSwitch

EndFunc


; #FUNCTION# ====================================================================================================
; Name...........: _KillProcess
; Description ...:
; Syntax.........: _Closerocess($sProcess)
; Parameters ....: $BugProcess - Process to Close
; Return values .: Success  -
;                  Failure  -
; Author ........: Venom
; Modified.......:
; Remarks .......: None
; Link ..........:
; Example .......:
; ===============================================================================================================
Func _KillProcess($sProcess)

	If ProcessExists($sProcess) Then

		Local $aProcessList = ProcessList()
		For $i = 1 To $aProcessList[0][0]
			If $aProcessList[$i][0] = $sProcess Then
				_KillProcessInstance($aProcessList[$i][1])
			EndIf
		Next

	EndIf

EndFunc


Func _KillProcessInstance($iPID)

	Local $iReturn

	If ProcessClose($iPID) Then
		$iReturn = 1
	Else
		$iReturn = 0
		Switch @error
			Case 1
				_EditLoggingWrite("OpenProcess failed")
			Case 2
				_EditLoggingWrite("AdjustTokenPrivileges Failed")
			Case 3
				_EditLoggingWrite("TerminateProcess Failed")
			Case 4
				_EditLoggingWrite("Cannot verify if process exists")
		EndSwitch
	EndIf

	Return $iReturn

EndFunc


Func _GetIEVersion()

	Local $ieExec = @ProgramFilesDir & "\Internet Explorer\iexplore.exe"
	Local $sSpltString =  StringSplit(FileGetVersion($ieExec), ".")
	Local $sIEversion = "0"

	If FileExists($ieExec) Then

		If IsArray($sSpltString) Then
			$sIEversion = $sSpltString[1] & "." & $sSpltString[2] & "." & $sSpltString[3]
		Else
			$sIEversion = "0"
		EndIf

	Else
		$sIEversion = "0"
	EndIf

	$sIEversion = StringStripWS($sIEversion, 8)
	Return $sIEversion

EndFunc
