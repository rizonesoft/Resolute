#include-once

; #INDEX# =======================================================================================================================
; Title .........: Services
; AutoIt Version : 3.2.3++
; Language ......: English
; Description ...: Functions that allow management of services without the use of external files
; Author(s) .....: Matthew McMullan (NerdFencer)
; Dll(s) ........:
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_SvcGetDisplayName
;_SvcGetName
;_SvcPause
;_SvcResume
;_SvcSetStartMode
;_SvcStart
;_SvcStop
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _SvcGetDisplayName
; Description ...: Gets the Display Name of a service
; Syntax.........: _SvcGetDisplayName($sService)
; Parameters ....: $sService    - Name of the service (note: this differs from DisplayName)
; Return values .: Success      - Display Name of the Service
;                  Failure      - False
; Author ........: Matthew McMullan (NerdFencer)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........: http://msdn.microsoft.com/en-us/library/aa394418%28VS.85%29.aspx
; Example .......: No
; ===============================================================================================================================
Func _SvcGetDisplayName($sService)
	Local $objRoot = ObjGet("winmgmts:\\" & @ComputerName &"\root\cimv2")
	Local $objServices = $objRoot.ExecQuery("SELECT * FROM Win32_Service")
	For $objService In $objServices
		If $objService.Name = $sService Then
			Return $objService.DisplayName
		EndIf
	Next
	Return False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _SvcGetName
; Description ...: Gets the Name of a service given its display name
; Syntax.........: _SvcGetDisplayName($sService)
; Parameters ....: $sService    - Name of the service
; Return values .: Success      - Display Name of the Service
;                  Failure      - False
; Author ........: Matthew McMullan (NerdFencer)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SvcGetName($sService)
	Local $objRoot = ObjGet("winmgmts:\\" & @ComputerName &"\root\cimv2")
	Local $objServices = $objRoot.ExecQuery("SELECT * FROM Win32_Service")
	For $objService In $objServices
		If $objService.DisplayName = $sService Then
			Return $objService.Name
		EndIf
	Next
	Return False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _SvcPause
; Description ...: Pauses the Service
; Syntax.........: _SvcPause($sService)
; Parameters ....: $sService    - Name of the service (note: this differs from DisplayName)
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Matthew McMullan (NerdFencer)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SvcPause($sService)
	Local $objRoot = ObjGet("winmgmts:\\" & @ComputerName &"\root\cimv2")
	Local $objServices = $objRoot.ExecQuery("SELECT * FROM Win32_Service")
	For $objService In $objServices
		If $objService.Name = $sService Then
			Local $iOutput = $objService.PauseService()
			If $iOutput==0 Or $iOutput==24 Then
				Return True
			EndIf
			Return False
		EndIf
	Next
	Return False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _SvcResume
; Description ...: Resumes the Service
; Syntax.........: _SvcResume($sService)
; Parameters ....: $sService    - Name of the service (note: this differs from DisplayName)
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Matthew McMullan (NerdFencer)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SvcResume($sService)
	Local $objRoot = ObjGet("winmgmts:\\" & @ComputerName &"\root\cimv2")
	Local $objServices = $objRoot.ExecQuery("SELECT * FROM Win32_Service")
	For $objService In $objServices
		If $objService.Name = $sService Then
			Local $iOutput = $objService.ResumeService()
			If $iOutput==0 Or $iOutput==10 Then
				Return True
			EndIf
			Return False
		EndIf
	Next
	Return False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _SvcSetStartMode
; Description ...: Sets the start mode of the system restore service
; Syntax.........: _SvcSetStartMode($sService, $sMode)
; Parameters ....: $sService    - Name of the service (note: this differs from DisplayName)
;                  |$sMode      - "Automatic", "Manual", or "Disabled"
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Matthew McMullan (NerdFencer)
; Modified.......:
; Remarks .......: "Boot" and "System" are also valid, but do NOT use them unless you really know what you are doing
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SvcSetStartMode($sService, $sMode)
	If StringLower($sMode)=="demand" Then
		$sMode = "Manual"
	ElseIf StringLower($sMode) == "auto" Then
		$sMode = "Automatic"
	ElseIf StringLower($sMode) == "disabled" Then
		$sMode = "Disabled"
	EndIf
	If Not($sMode=="Automatic" Or $sMode=="Manual" Or $sMode=="Disabled" Or $sMode=="Boot" Or $sMode=="System") Then
		Return False
	EndIf
	Local $objRoot = ObjGet("winmgmts:\\" & @ComputerName &"\root\cimv2")
	Local $objServices = $objRoot.ExecQuery("SELECT * FROM Win32_Service")
	For $objService In $objServices
		If $objService.Name == $sService Then
			If $objService.StartMode == $sMode Then

			EndIf
			Local $iOutput = $objService.ChangeStartMode($sMode)

			Return ($iOutput==0)
		EndIf
	Next
	Return False
EndFunc

Func _SvcGetStartMode($sService)
	Local $objRoot = ObjGet("winmgmts:\\" & @ComputerName &"\root\cimv2")
	Local $objServices = $objRoot.ExecQuery("SELECT * FROM Win32_Service")
	For $objService In $objServices
		If StringLower($objService.Name) == StringLower($sService) Then
			Return $objService.StartMode
		EndIf
	Next
	Return False
EndFunc


Func _SvcGetState($sService)
	Local $objRoot = ObjGet("winmgmts:\\" & @ComputerName &"\root\cimv2")
	Local $objServices = $objRoot.ExecQuery("SELECT * FROM Win32_Service")
	For $objService In $objServices
		If StringLower($objService.Name) == StringLower($sService) Then
			Return $objService.State
		EndIf
	Next
	Return False
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _SvcStart
; Description ...: Starts the System Restore Service
; Syntax.........: _SvcStart($sService, $bForce = True)
; Parameters ....: $sService    - Name of the service (note: this differs from DisplayName)
;                  |$bForce     - Forces the service to start even if it is disabled
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Matthew McMullan (NerdFencer)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SvcStart($sService, $bForce = True)
	Local $objRoot = ObjGet("winmgmts:\\" & @ComputerName &"\root\cimv2")
	Local $objServices = $objRoot.ExecQuery("SELECT * FROM Win32_Service")
	For $objService In $objServices
		If $objService.Name = $sService Then
			Local $iOutput = $objService.StartService()
			If $iOutput==0 Or $iOutput==10 Then
				Return True
			EndIf
			If $iOutput == 14 And $bForce==True Then
				$objService.ChangeStartMode("Manual")
				$iOutput = $objService.StartService()
				If $iOutput==0 Or $iOutput==10 Then
					Return True
				EndIf
			EndIf
			Return False
		EndIf
	Next
	Return False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _SvcStop
; Description ...: Stops the Service
; Syntax.........: _SvcStop($sService)
; Parameters ....: $sService    - Name of the service (note: this differs from DisplayName)
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Matthew McMullan (NerdFencer)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _SvcStop($sService)
	Local $objRoot = ObjGet("winmgmts:\\" & @ComputerName &"\root\cimv2")
	Local $objServices = $objRoot.ExecQuery("SELECT * FROM Win32_Service")
	For $objService In $objServices
		If $objService.Name = $sService Then
			Local $iOutput = $objService.StopService()
			If $iOutput==0 Or $iOutput==6 Then
				Return True
			EndIf
			Return False
		EndIf
	Next
	Return False
EndFunc
