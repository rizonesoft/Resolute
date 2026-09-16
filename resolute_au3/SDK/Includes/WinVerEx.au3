#include-once

#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section



; #INDEX# =======================================================================================================================
; Title .........: WinVerEx.au3
; AutoIt Version : 3.3.16.1
; Description ...: Functions for Windows Version Checking.
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _IsWindows10_2004_OrAbove
; _IsUnsupportedOS
; ===============================================================================================================================


Func _IsWindows10_2004_OrAbove()
    Local $tOSVersionInfo = DllStructCreate("DWORD;DWORD;DWORD;DWORD;wchar[128]")
    DllStructSetData($tOSVersionInfo, 1, DllStructGetSize($tOSVersionInfo))

    Local $aResult = DllCall("ntdll.dll", "long", "RtlGetVersion", "ptr", DllStructGetPtr($tOSVersionInfo))

    If @error Then
        ConsoleWrite("Error calling RtlGetVersion" & @CRLF)
        Return False
    EndIf

    Local $dwMajorVersion = DllStructGetData($tOSVersionInfo, 2)
    Local $dwMinorVersion = DllStructGetData($tOSVersionInfo, 3)
    Local $dwBuildNumber  = DllStructGetData($tOSVersionInfo, 4)

    ; Major version for Windows 10 is 10 (0x0A)
    ; Minor version for Windows 10 is 0  (0x00)
    ; Build version for Windows 10 2004 is 19041 or higher
    If ($dwMajorVersion = 10) And ($dwMinorVersion = 0) And ($dwBuildNumber >= 19041) Then
        ConsoleWrite("+\tWindows 10 (2004 or above) detected." & @CRLF)
        Return True
    Else
        ConsoleWrite("-\tWindows 10 (2004 or above) NOT detected." & @CRLF)
        Return False
    EndIf
EndFunc

Func _IsUnsupportedOS()
    Local $aUnsupportedOS[8] = ["WIN_VISTA", "WIN_XP", "WIN_XPe", "WIN_2012", "WIN_2008R2", "WIN_2008", "WIN_2003"]
    For $i = 0 To UBound($aUnsupportedOS) - 1
        If $aUnsupportedOS[$i] = @OSVersion Then
            ConsoleWrite("Unsupported Windows version detected: " & @OSVersion & @CRLF)
            Return True
        EndIf
    Next
    Return False
EndFunc