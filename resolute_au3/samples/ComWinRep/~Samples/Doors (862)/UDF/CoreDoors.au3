#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.0
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------


#include-once

#include <Constants.au3>
#include <GuiEdit.au3>
#include <Date.au3>


Global $AUTORUN_PROTECTION = False



Global Const $PE_AUSDEFRAG = $DIR_STRUCTURE & "\ausdiskdefrag.exe"
Global Const $PE_CONSOLE = $DIR_STRUCTURE & "\Console\Console.exe"
Global Const $PE_WINREPAIR = $DIR_STRUCTURE & "\WinRepair.exe"

Global Const $WIN2K_AUSDEFRAG = @SystemDir & "\dfrg.msc"


Func _IsWindowsAboveSeven()
	If @OSVersion = "WIN_8" Or @OSVersion = "WIN_7" Or @OSVersion = "WIN_2008R2" Then
		Return True
	Else
		REturn False
	EndIf
EndFunc








Func _OpenInternetBrowser($sURL)
	ShellExecute($sURL)
EndFunc


Func _DeleteRegistryData($regK, $regN)

	Local $iSuccess

	_MemoLoggingWrite("Deleting [" & $regK & "] " & Chr(34) & $regN & Chr(34))
	If RegRead($regK, $regN) <> "" Then
		_MemoLoggingWrite("Found [" & $regK & "] " & Chr(34) & $regN & Chr(34))
		$iSuccess = RegDelete($regK, $regN)
		If $iSuccess = 1 Then
			_MemoLoggingWrite("[" & $regK & "] " & Chr(34) & $regN & Chr(34) & " should be bye-bye now.", 1)
		Else
			_MemoLoggingWrite("The requested registry data could not be deleted.", 2)
		EndIf
	Else
		_MemoLoggingWrite("This is not an error, just could not find anything to delete.")
	EndIf

EndFunc


Func _WriteRegistryData($rsK, $rsN, $rsT, $rsD)

	Local $iSuccess

	_MemoLoggingWrite("Writing to [" & $rsK & "] " & Chr(34) & $rsN & Chr(34) & " = " & Chr(34) & $rsD & Chr(34))
	$iSuccess = RegWrite($rsK, $rsN, $rsT, $rsD)
	If $iSuccess = 1 Then
		_MemoLoggingWrite("[" & $rsK & "] " & Chr(34) & $rsN & Chr(34) & " = " & Chr(34) & $rsD & Chr(34) & " created successfully.", 1)
	Else
		_MemoLoggingWrite("Could not write the requested data to the registry.", 2)
	EndIf

EndFunc


Func _ConsoleRun($sCommand)

	Local $processID, $stdLine, $stdErrLine, $iSuccess = 0

	$ProcessID = Run(@ComSpec & " /c " & $sCommand, @SystemDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	While 1
		$stdLine = StdoutRead($processID)
		If @error Then ExitLoop
		If $stdLine And $stdLine <> "." And Not StringIsSpace($stdLine) Then
			If StringInStr($stdLine, "success", 2) Or StringInStr($stdLine, "sucess", 2) _
			Or StringInStr($stdLine, "OK", 2) Then $iSuccess = 1
			_MemoLoggingWrite($stdLine, $iSuccess)
			$iSuccess = 0
		EndIf
	Wend

	While 1
		$stdErrLine = StderrRead($processID)
		If @error Then ExitLoop
		If $stdErrLine And $stdErrLine <> "." And Not StringIsSpace($stdErrLine) Then
			_MemoLoggingWrite($stdErrLine, 2)
		EndIf
	WEnd

	StdioClose($processID)

EndFunc





Func _ReturnFullOSVersion()
	If @OSVersion = "WIN_VISTA" Then
		Return "Windows Vista"
	Else
		Return StringReplace(@OSVersion, "WIN_", "Windows ")
	EndIf
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_ShellExtractIcon
; Description....: Extracts the icon with the specified dimension from the specified file.
; Syntax.........: _WinAPI_ShellExtractIcon ( $sIcon, $iIndex, $iWidth, $iHeight )
; Parameters.....: $sIcon   - Path and name of the file from which the icon are to be extracted.
;                  $iIndex  - The zero-based index of the icon to extract. If this value is a negative number, the function extracts
;                             the icon whose resource identifier is equal to the absolute value of $iIndex.
;                  $iWidth  - Horizontal icon size wanted.
;                  $iHeight - Vertical icon size wanted.
; Return values..: Success  - Handle to the extracted icon.
;                  Failure  - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: If the icon with the specified dimension is not found in the file, it will choose the nearest appropriate icon
;                  and change to the specified dimension.
;
;                  When you are finished using the icon, destroy it using the _WinAPI_DestroyIcon() function.
; Related........:
; Link...........: @@MsdnLink@@ SHExtractIcons
; Example........: Yes
; ===============================================================================================================================

Func _WinAPI_ShellExtractIcon($sIcon, $iIndex, $iWidth, $iHeight)

	Local $Ret = DllCall('shell32.dll', 'int', 'SHExtractIconsW', 'wstr', $sIcon, 'int', $iIndex, 'int', $iWidth, 'int', $iHeight, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)

	If (@error) Or (Not $Ret[0]) Or (Not $Ret[5]) Then
		Return SetError(1, 0, 0)
	EndIf

	Return $Ret[5]

EndFunc   ;==>_WinAPI_ShellExtractIcon