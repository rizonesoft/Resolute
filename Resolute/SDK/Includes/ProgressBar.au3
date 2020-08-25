#include-once


#Region AutoIt3Wrapper Directives Dection
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y										;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y								;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Dection


#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>


; #INDEX# =======================================================================================================================
; Title .........: ProgressBar
; AutoIt Version : 3.3.15.0
; Description ...: Custom Progress Bar Functions.
; Author(s) .....: Derick Payne (Rizonesoft)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _ProgressBar_DrawSizeFromPercentage
; _ProgressBar_SetData
; _ProgressBar_SetColors
; ===============================================================================================================================


Func _ProgressBar_DrawSizeFromPercentage($hControl, $iPerc, $iLeft, $iTop, $iWidth, $iHeight)

	If $iPerc > -1 Then
		If $iPerc > 100 Then $iPerc = 100
		If $iPerc == 0 Then
			GUICtrlSetState($hControl, $GUI_HIDE)
		Else

			__ProgressBar_Unhide($hControl)

			If BitAND(GUICtrlGetState($hControl), 32) = 32 Then
				GUICtrlSetState($hControl, 16)
			EndIf
			GUICtrlSetPos($hControl, $iLeft, $iTop, ($iWidth * $iPerc) / 100, $iHeight)

		EndIf
	EndIf

EndFunc   ;==>_ProgressBar_DrawSizeFromPercentage


Func _ProgressBar_SetData($hParent, $hControl1, $hControl2, $iLeft, $iTop, $iWidth, $iPerc)

	Local $aProgressPos
	Local $iBarWidth = 10

	If $iPerc > -1 Then
		If $iPerc > 100 Then $iPerc = 100
		If $iPerc == 0 Then
			GUICtrlSetState($hControl1, $GUI_HIDE)
			GUICtrlSetState($hControl2, $GUI_HIDE)
		Else

			__ProgressBar_Unhide($hControl1)
			__ProgressBar_Unhide($hControl2)

			$iBarWidth = Round($iWidth * $iPerc) / 100

			If GUICtrlSetPos($hControl1, $iLeft, $iTop, $iBarWidth) Then
				$aProgressPos = ControlGetPos($hParent, "", $hControl1)
				If @error Then
					Return SetError(1, 0, False)
				Else
					GUICtrlSetPos($hControl2, $aProgressPos[0] + 1, $aProgressPos[1] + 1, $aProgressPos[2] - 2)
				EndIf
			Else
				Return SetError(1, 0, False)
			EndIf

		EndIf

	EndIf

EndFunc   ;==>_ProgressBar_SetData


Func _ProgressBar_SetColors($hControl1, $hControl2, $sColor = "")

	Local $iColor1, $iColor2

	Switch $sColor
		Case "Green"
			$iColor1 = 0x008600
			$iColor2 = 0x85EA7B
		Case "Blue"
			$iColor1 = 0x2574CB
			$iColor2 = 0x98C0FE
		Case "Red"
			$iColor1 = 0x9B0606
			$iColor2 = 0xFB9595
		Case Else
			$iColor1 = 0x555555
			$iColor2 = 0x969696
	EndSwitch

	GUICtrlSetBkColor($hControl1, $iColor1)
	GUICtrlSetBkColor($hControl2, $iColor2)

EndFunc   ;==>_ProgressBar_SetColors


Func __ProgressBar_Unhide($hControl)
	If BitAND(GUICtrlGetState($hControl), $GUI_HIDE) = $GUI_HIDE Then
		GUICtrlSetState($hControl, $GUI_SHOW)
	EndIf
EndFunc   ;==>__ProgressBar_Unhide
