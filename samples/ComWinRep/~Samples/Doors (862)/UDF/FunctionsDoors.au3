#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.7.18 (beta)
 Author:         Rizonesoft (Derick Payne)

 Script Function:
	Doors Functions

#ce ----------------------------------------------------------------------------


#include-once


;~ #FUNCTION# ====================================================================================================================
;~ Name...........: _GetDoorsVersion
;~ Description ...: Stuff that needs doing before application startup.
;~ Syntax.........: _GetDoorsVersion([Flag = 1])
;~ Parameters ....: $Flag	- Return What?
;~ Return ........: If $Flag = 1 Then return Doors version
;~					If $Flag = 2 Then return Doors build
;~ Author ........: Rizonesoft (Derick Payne)
;~ Modified.......:
;~ Remarks .......:
; ===============================================================================================================================
Func _GetDoorsVersion($Flag = 1)

	Local $drsBuild = FileGetVersion(@ScriptDir & "\GoBar.exe")
	Local $drsBldSplt

	$drsBldSplt = StringSplit($drsBuild, ".")
	If $Flag = 1 Then
		Return $drsBldSplt[1]
	ElseIf $Flag = 2 Then
		Return $drsBuild
	EndIf

EndFunc ;~ ==> _GetDoorsVersion()


Func _DrawStatusSizeFromPercentage($FrBar, $Perc, $BcLeft, $BcTop, $BcWidth, $BcHeight)

	If $Perc > 0 Then
		If $Perc > 100 Then $Perc = 100
		If $Perc = 0 Then
			GUICtrlSetState($FrBar, $GUI_HIDE)
		Else

			If BitAND(GUICtrlGetState($FrBar), $GUI_HIDE) = $GUI_HIDE Then
				;GUICtrlSetState($FrBar, $GUI_SHOW)
			EndIf
			GUICtrlSetPos($FrBar, $BcLeft + 1, $BcTop + 1, (($BcWidth - 2) * $Perc) / 100, $BcHeight - 2)
		EndIf
	EndIf

EndFunc


; #FUNCTION# ====================================================================================================
; Name...........: _ReduceMemory
; Description ...: Reduce memory usage of process ID (PID) given.
; Syntax.........: _ReduceMemory($iPID = -1, $hPsAPIdll = 'psapi.dll', $hKernel32dll = 'kernel32.dll')
; Parameters ....: $BugProcess - Process to Close
; Return values .: $iPID - PID of process to reduce memory. If -1 reduce self memory usage.
;                  $hPsAPIdll - Optional handle to psapi.dll.
;                  $hKernel32dll - Optional handle To kernel32.dll.
; Requirement(s) : psapi.dll (Doesn't come with WinNT4 by default)
; Author(s) .....: w0uter,  Saunders (admin@therks.com)
; Modified.......: Venom (Rizone Technologies)
; Remarks .......: If @OSVersion = 'WIN_NT4' Then FileInstall('psapi.dll', @SystemDir & '\psapi.dll')
; Link ..........:
; Example .......:
; ===============================================================================================================
Func _ReduceMemory($iPID = -1, $hPsAPIdll = 'psapi.dll', $hKernel32dll = 'kernel32.dll')
    If $iPID <> -1 Then
        Local $aHandle = DllCall($hKernel32dll, 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $iPID)
        Local $aReturn = DllCall($hPsAPIdll, 'int', 'EmptyWorkingSet', 'long', $aHandle[0])
        DllCall($hKernel32dll, 'int', 'CloseHandle', 'int', $aHandle[0])
    Else
        Local $aReturn = DllCall($hPsAPIdll, 'int', 'EmptyWorkingSet', 'long', -1)
    EndIf

    Return $aReturn[0]
EndFunc