#include-once

#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										 ;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								 ;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


#include <WinAPI.au3>


; #INDEX# =======================================================================================================================
; Title .........: WinEx
; AutoIt Version : 3.3.15.0
; Language ......: English
; Description ...: Extended Windows Functions.
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _WinEx_GetParentCentre
; _WinEx_GetTaskBarHeight
; ===============================================================================================================================


Func _WinEx_GetParentCentre($hParent, $iChWidth, $iChHeight)

	Local $iMonitors = _WinAPI_GetSystemMetrics(80)
	If $iMonitors == 0 Then
		Return SetError(1, 0, 1)
	EndIf

	Local $aPosReturn[2]
	Local $aParentPos = WinGetPos($hParent)

	If Not @error Then

		$aPosReturn[0] = $aParentPos[0] + (($aParentPos[2] - $iChWidth) / 2)
		$aPosReturn[1] = $aParentPos[1] + ((($aParentPos[3] - $iChHeight) - _WinEx_GetTaskBarHeight()) / 2)
		If $iMonitors == 1 Then

			Local $iRightEdge = @DesktopWidth - $iChWidth
			If $aPosReturn[0] > $iRightEdge Then
				$aPosReturn[0] = $iRightEdge - 25
			ElseIf $aPosReturn[0] < 0 Then
				$aPosReturn[0] = 20
			EndIf

			Local $iBottomEdge = (@DesktopHeight - $iChHeight) - _WinEx_GetTaskBarHeight()
			If $aPosReturn[1] > $iBottomEdge Then
				$aPosReturn[1] = $iBottomEdge - 50
			ElseIf $aPosReturn[1] < 0 Then
				$aPosReturn[1] = 20
			EndIf

			Return $aPosReturn

		Else

			$aPosReturn[0] = -1
			$aPosReturn[1] = -1
			Return $aPosReturn

		EndIf

	Else

		$aPosReturn[0] = -1
		$aPosReturn[1] = -1
		Return SetError(2, 0, $aPosReturn)

	EndIf

EndFunc   ;==>_WinEx_GetParentCentre


Func _WinEx_GetTaskBarHeight()

	Local $aPos = WinGetPos("[CLASS:Shell_TrayWnd; W:" & @DesktopWidth & "]")
	If Not @error Then
		Return $aPos[3]
	Else
		Return 0
	EndIf

EndFunc   ;==>_WinEx_GetTaskBarHeight
