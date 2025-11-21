#include-once

#Region AutoIt3Wrapper Directives Section
;===============================================================================================================
; Tidy Settings
;===============================================================================================================
#AutoIt3Wrapper_Run_Tidy=Y                                         ;~ (Y/N) Run Tidy before compilation. Default=N
#AutoIt3Wrapper_Tidy_Stop_OnError=Y                                ;~ (Y/N) Continue when only Warnings. Default=Y

#EndRegion AutoIt3Wrapper Directives Section


; #INDEX# =======================================================================================================================
; Title .........: GDIPlusProgressBar
; AutoIt Version : 3.3.15.0+
; Language ......: English
; Description ...: Progress bar drawing using GDI+ on an existing control.
; Author(s) .....: Rizonesoft (patterned after ProgressBar.au3), adapted for GDI+ usage
; ===============================================================================================================================

#include <GDIPlus.au3>
#include <WinAPI.au3>

; #CURRENT# =====================================================================================================================
; _GDIPlusProgressBar_Draw       - Draws a horizontal or vertical progress bar using GDI+ on a control
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================
; Name...........: _GDIPlusProgressBar_Draw
; Description....: Draws a progress bar (horizontal or vertical) using GDI+ inside a control.
; Syntax.........: _GDIPlusProgressBar_Draw($hCtrl, $iPerc, $iBackColor, $iOuterColor, $iInnerColor [, $bVertical = False])
; Parameters.....: $hCtrl       - Control ID as returned by GUICtrlCreate* (e.g. GUICtrlCreateGraphic)
;                  $iPerc       - Percentage (0..100). Values < 0 are ignored, >100 are clamped to 100.
;                  $iBackColor  - Background color (0xRRGGBB or 0xAARRGGBB)
;                  $iOuterColor - Outer bar color (0xRRGGBB or 0xAARRGGBB)
;                  $iInnerColor - Inner bar color (0xRRGGBB or 0xAARRGGBB)
;                  $bVertical   - [Optional] True to draw vertical bar from bottom up, False for horizontal (default)
; Return values..: Success - True
;                  Failure - Sets @error and returns False
; Remarks........: This function uses GDIPlus for drawing. It starts and shuts down GDIPlus internally on each call
;                  to remain self-contained and avoid interfering with other GDIPlus users.
; ===============================================================================================================
Func _GDIPlusProgressBar_Draw($hCtrl, $iPerc, $iBackColor, $iOuterColor, $iInnerColor, $bVertical = False)

	If $iPerc < 0 Then Return False
	If $iPerc > 100 Then $iPerc = 100

	Local $hWndCtrl = GUICtrlGetHandle($hCtrl)
	If Not $hWndCtrl Then Return SetError(1, 0, False)

	; Get client size of the control
	Local $tRect = _WinAPI_GetClientRect($hWndCtrl)
	If @error Then Return SetError(2, 0, False)

	Local $iWidth  = DllStructGetData($tRect, "Right") - DllStructGetData($tRect, "Left")
	Local $iHeight = DllStructGetData($tRect, "Bottom") - DllStructGetData($tRect, "Top")
	If $iWidth <= 0 Or $iHeight <= 0 Then Return SetError(3, 0, False)

	_GDIPlus_Startup()

	Local $hDC = _WinAPI_GetDC($hWndCtrl)
	If Not $hDC Then
		_GDIPlus_Shutdown()
		Return SetError(4, 0, False)
	EndIf

	Local $hGraphics = _GDIPlus_GraphicsCreateFromHDC($hDC)
	If @error Or Not $hGraphics Then
		_WinAPI_ReleaseDC($hWndCtrl, $hDC)
		_GDIPlus_Shutdown()
		Return SetError(5, 0, False)
	EndIf

	; Ensure colors are ARGB
	__GDIPlusProgressBar_VerifyARGB($iBackColor)
	__GDIPlusProgressBar_VerifyARGB($iOuterColor)
	__GDIPlusProgressBar_VerifyARGB($iInnerColor)

	Local $hBrushBg    = _GDIPlus_BrushCreateSolid($iBackColor)
	Local $hBrushOuter = _GDIPlus_BrushCreateSolid($iOuterColor)
	Local $hBrushInner = _GDIPlus_BrushCreateSolid($iInnerColor)

	; Clear entire control background
	_GDIPlus_GraphicsFillRect($hGraphics, 0, 0, $iWidth, $iHeight, $hBrushBg)

	If $iPerc > 0 Then
		Local $iFillW, $iFillH

		If Not $bVertical Then
			$iFillW = Round($iWidth * $iPerc / 100)
			$iFillH = $iHeight
		Else
			$iFillW = $iWidth
			$iFillH = Round($iHeight * $iPerc / 100)
		EndIf

		If $iFillW > 0 And $iFillH > 0 Then
			If Not $bVertical Then
				; Horizontal: fill from left to right
				_GDIPlus_GraphicsFillRect($hGraphics, 0, 0, $iFillW, $iFillH, $hBrushOuter)
				If $iFillW > 2 And $iFillH > 2 Then
					_GDIPlus_GraphicsFillRect($hGraphics, 1, 1, $iFillW - 2, $iFillH - 2, $hBrushInner)
				EndIf
			Else
				; Vertical: fill from bottom to top
				Local $iY = $iHeight - $iFillH
				_GDIPlus_GraphicsFillRect($hGraphics, 0, $iY, $iFillW, $iFillH, $hBrushOuter)
				If $iFillW > 2 And $iFillH > 2 Then
					_GDIPlus_GraphicsFillRect($hGraphics, 1, $iY + 1, $iFillW - 2, $iFillH - 2, $hBrushInner)
				EndIf
			EndIf
		EndIf
	EndIf

	; Cleanup
	_GDIPlus_BrushDispose($hBrushBg)
	_GDIPlus_BrushDispose($hBrushOuter)
	_GDIPlus_BrushDispose($hBrushInner)
	_GDIPlus_GraphicsDispose($hGraphics)
	_WinAPI_ReleaseDC($hWndCtrl, $hDC)
	_GDIPlus_Shutdown()

	Return True

EndFunc   ;==>_GDIPlusProgressBar_Draw


; #FUNCTION# ====================================================================================================
; Name...........: __GDIPlusProgressBar_VerifyARGB
; Description....: Verifies color is ARGB; converts 0xRRGGBB to 0xFFRRGGBB.
; Syntax.........: __GDIPlusProgressBar_VerifyARGB(ByRef $iHex)
; Parameters.....: $iHex - [ByRef] Hex color value as number or string.
; ===============================================================================================================
Func __GDIPlusProgressBar_VerifyARGB(ByRef $iHex)
	If IsString($iHex) Then
		If StringLeft($iHex, 2) = '0x' Then $iHex = StringTrimLeft($iHex, 2)
		If StringLen($iHex) = 6 Then
			$iHex = '0xFF' & $iHex
		Else
			$iHex = '0x' & $iHex
		EndIf
	Else
		If $iHex <= 0xFFFFFF Then $iHex = '0xFF' & Hex($iHex, 6)
	EndIf
EndFunc   ;==>__GDIPlusProgressBar_VerifyARGB
