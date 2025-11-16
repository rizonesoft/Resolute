#include-once

#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include "AutoIt3Script.au3"
#include "Localization.au3"


; #INDEX# =======================================================================================================================
; Title .........: Versioning
; AutoIt Version : 3.3.15.0
; Description ...: Versioning Functions
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
Global $g_aLangLogging[$LNG_COUNTLOGGING]

If Not IsDeclared("g_TitleShowAdmin") Then Global $g_TitleShowAdmin = False ;~ Show whether program is running as Administrator
If Not IsDeclared("g_TitleShowArch") Then Global $g_TitleShowArch = False ;~ Show program architecture
If Not IsDeclared("g_TitleShowVersion") Then Global $g_TitleShowVersion = True ;~ Show program version
If Not IsDeclared("g_TitleShowBuild") Then Global $g_TitleShowBuild = True ;~ Show program build
If Not IsDeclared("g_TitleShowAutoIt") Then Global $g_TitleShowAutoIt = False ;~ Show AutoIt version
; ===============================================================================================================================


; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _GetInternetExplorerVersion
; _GUIGetTitle
; _GetProgramVersion
; _GetProgramVersionFromFile
; _GetWindowsVersion
; ===============================================================================================================================


Func _GetInternetExplorerVersion()

	Local $sIEVersion = "0.0.0"

	If FileExists(@ProgramFilesDir & "\Internet Explorer\iexplore.exe") Then
		Local $sSpltString = StringSplit(FileGetVersion(@ProgramFilesDir & "\Internet Explorer\iexplore.exe"), ".")
		If $sSpltString[0] >= 3 Then
			; $sIEVersion = StringStripWS($sSpltString[1] & "." & $sSpltString[2] & "." & $sSpltString[3], 8)
			$sIEVersion = StringStripWS($sSpltString[1], 8)
		EndIf
	EndIf

	Return $sIEVersion

EndFunc   ;==>_GetInternetExplorerVersion


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

	If $iFlag = 0 Then
		Return $sFullVersion
	EndIf

	Local $sPltReturn = StringSplit($sFullVersion, ".")
	If $iFlag <= $sPltReturn[0] Then
		$sReturn = $sPltReturn[$iFlag]
	Else
		Return SetError(1, 0, 0)
	EndIf

	Return $sReturn

EndFunc   ;==>_GetProgramVersionFromFile


Func _GUIGetTitle($sGUIName)
    Local $sReturn, $sAdminInstance = "", $sProgramVersion = "", $sProgramMinorString = "", $sProgramBuild = ""
    Local $sAutoItArch = "", $sAutoItVers = ""

    _Localization_Versioning()

    If IsAdmin() And $g_TitleShowAdmin Then
        $sAdminInstance = $g_aLangVersioning[0] & " ~ "
    EndIf

    If $g_TitleShowArch Then
        $sAutoItArch = " : " & _AutoIt3Script_GetArchitecture() & "-" & $g_aLangVersioning[3]
    EndIf

    If @Compiled Then
        $sReturn = FileGetVersion(@ScriptFullPath)

        If @error Or Not StringRegExp($sReturn, "^\d+\.\d+\.\d+\.\d+$") Then
            Return ""
        EndIf

        Local $aVersionParts = StringSplit($sReturn, ".")

        If @error Then
            Return ""
        EndIf

        If $g_TitleShowVersion Then $sProgramVersion = " " & $aVersionParts[1]
        If $g_TitleShowBuild Then $sProgramBuild = " : " & $g_aLangVersioning[1] & " " & $aVersionParts[$aVersionParts[0]]

        Switch $aVersionParts[3]
            Case 0
                $sProgramMinorString = "Alpha "
            Case 1
                $sProgramMinorString = "Beta "
            Case 2
                $sProgramMinorString = "RC "
        EndSwitch

        $sReturn = $sAdminInstance & $sGUIName & $sProgramVersion & $sProgramBuild

        If $aVersionParts[3] >= 0 And $aVersionParts[3] <= 2 Then
            $sReturn &= " - (" & $sProgramMinorString & $aVersionParts[2] & ")"
        EndIf

        $sReturn &= $sAutoItArch

    Else
        If $g_TitleShowVersion Then $sProgramVersion = " " & _AutoIt3Script_GetVersion(@ScriptFullPath, 1)
        If $g_TitleShowBuild Then $sProgramBuild = " : " & $g_aLangVersioning[1] & " " & _AutoIt3Script_GetVersion(@ScriptFullPath, 4)
        If $g_TitleShowAutoIt Then $sAutoItVers = " : " & $g_aLangVersioning[2]

        $sReturn = $sAdminInstance & $sGUIName & $sProgramVersion & $sProgramBuild & $sAutoItVers & $sAutoItArch
    EndIf

    Return $sReturn
EndFunc   ;==>_GUIGetTitle


Func _GetWindowsVersion($iFlad = 0)

	Local $sReturn = ""
	Local $sWinVersion = @OSVersion

	; If StringRegExp(FileGetVersion('winver.exe'), "^10\.\d") Then $sWinVersion = "WIN_10"
	If __WinVer_RtlGetVersion() >= 0x0604 Then $sWinVersion = "WIN_10"

	Switch $iFlad
		Case 0
			$sReturn = $sWinVersion
		Case 1
			$sReturn = StringReplace($sWinVersion, "WIN_", "Windows ", $STR_CASESENSE)
	EndSwitch

	Return $sReturn

EndFunc   ;==>_GetWindowsVersion


Func __WinVer_RtlGetVersion()
    ; GetVersionEx
    ; https://msdn.microsoft.com/de-de/library/windows/desktop/ms724451(v=vs.85).aspx
    ; With the release of Windows 8.1, the behavior of the GetVersionEx API has changed in the value it will return for the operating system version.
    ; The value returned by the GetVersionEx function now depends on how the application is manifested.

    ; If you don't want to depend on manifests and reply on this deprecated API, use kernel-mode RtlGetVersion:
    ; https://msdn.microsoft.com/en-us/library/windows/hardware/ff561910(v=vs.85).aspx

    #cs
        typedef struct _OSVERSIONINFOW {
        ULONG dwOSVersionInfoSize;
        ULONG dwMajorVersion;
        ULONG dwMinorVersion;
        ULONG dwBuildNumber;
        ULONG dwPlatformId;
        WCHAR szCSDVersion[128];
        } RTL_OSVERSIONINFOW, *PRTL_OSVERSIONINFOW;
    #ce

    Local $tOSVI = DllStructCreate('dword;dword;dword;dword;dword;wchar[128]')
    DllStructSetData($tOSVI, 1, DllStructGetSize($tOSVI))
    Local $Ret = DllCall("ntdll.dll", "int", "RtlGetVersion", "ptr", DllStructGetPtr($tOSVI))
    If @error Or $Ret[0] <> 0 Then Return SetError(1, 0, 0) ; RtlGetVersion returns STATUS_SUCCESS = 0

    ; 0x0501 = Win XP
    ; 0x0502 = Win Server 2003
    ; 0x0600 = Win Vista
    ; 0x0601 = Win7 / Major Version = 6, Minor Version = 1
    ; 0x0602 = Win8
    ; 0x0603 = Win8.1
    ; 0x0604 = Win10 "Technical Preview"
    ; 0x0A00 = Win10 RTM (build 10240 or later) / Major Version = 10, Minor Version = 0

    ; Return "0x" & Hex(BitOR(BitShift(10, -8), 0), 4)
    Return "0x" & Hex(BitOR(BitShift(DllStructGetData($tOSVI, 2), -8), DllStructGetData($tOSVI, 3)), 4)
EndFunc   ;==>__WINVER_RtlGetVersion


Func __WINVER_GetVersionExW()
    Local $tOSVI = DllStructCreate('dword;dword;dword;dword;dword;wchar[128]')
    DllStructSetData($tOSVI, 1, DllStructGetSize($tOSVI))
    Local $Ret = DllCall('kernel32.dll', 'int', 'GetVersionExW', 'ptr', DllStructGetPtr($tOSVI))
    If (@error) Or (Not $Ret[0]) Then Return SetError(1, 0, 0)
    Return BitOR(BitShift(DllStructGetData($tOSVI, 2), -8), DllStructGetData($tOSVI, 3))
EndFunc   ;==>__WINVER_GetVersionExW