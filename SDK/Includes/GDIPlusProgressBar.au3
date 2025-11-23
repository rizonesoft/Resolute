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
; _GDIPlusProgressBar_DrawWithPeak - Draws a progress bar with a faint peak indicator showing historical maximum
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
; Remarks........: This function uses GDIPlus for drawing. GDI+ must already be initialized by the caller
;                  (e.g., by FFLabels). Does not start/stop GDI+ to avoid destroying shared GDI+ resources.
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

	; GDI+ uses reference counting - safe to call startup multiple times
	; FFLabels will handle the final shutdown on exit
	_GDIPlus_Startup()

	Local $hDC = _WinAPI_GetDC($hWndCtrl)
	If Not $hDC Then
		Return SetError(4, 0, False)
	EndIf

	Local $hGraphics = _GDIPlus_GraphicsCreateFromHDC($hDC)
	If @error Or Not $hGraphics Then
		_WinAPI_ReleaseDC($hWndCtrl, $hDC)
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

	; Cleanup (but don't shutdown GDI+ - FFLabels manages it globally)
	_GDIPlus_BrushDispose($hBrushBg)
	_GDIPlus_BrushDispose($hBrushOuter)
	_GDIPlus_BrushDispose($hBrushInner)
	_GDIPlus_GraphicsDispose($hGraphics)
	_WinAPI_ReleaseDC($hWndCtrl, $hDC)

	Return True

EndFunc   ;==>_GDIPlusProgressBar_Draw


; #FUNCTION# ====================================================================================================
; Name...........: _GDIPlusProgressBar_DrawWithPeak
; Description....: Draws a progress bar with a faint peak indicator showing historical maximum.
; Syntax.........: _GDIPlusProgressBar_DrawWithPeak($hCtrl, $iPerc, $iPeakPerc, $iBackColor, $iOuterColor, $iInnerColor, $iPeakColor [, $bVertical = False])
; Parameters.....: $hCtrl       - Control ID as returned by GUICtrlCreate* (e.g. GUICtrlCreateGraphic)
;                  $iPerc       - Current percentage (0..100)
;                  $iPeakPerc   - Peak percentage (0..100) - historical maximum
;                  $iBackColor  - Background color (0xRRGGBB or 0xAARRGGBB)
;                  $iOuterColor - Outer bar color for current value (0xRRGGBB or 0xAARRGGBB)
;                  $iInnerColor - Inner bar color for current value (0xRRGGBB or 0xAARRGGBB)
;                  $iPeakColor  - Faint color for peak indicator (0xRRGGBB or 0xAARRGGBB)
;                  $bVertical   - [Optional] True for vertical bar, False for horizontal (default)
; Return values..: Success - True
;                  Failure - Sets @error and returns False
; Remarks........: Draws peak first (faint), then current value on top (bright).
; ===============================================================================================================
Func _GDIPlusProgressBar_DrawWithPeak($hCtrl, $iPerc, $iPeakPerc, $iBackColor, $iOuterColor, $iInnerColor, $iPeakColor, $bVertical = False)

	If $iPerc < 0 Then $iPerc = 0
	If $iPerc > 100 Then $iPerc = 100
	If $iPeakPerc < 0 Then $iPeakPerc = 0
	If $iPeakPerc > 100 Then $iPeakPerc = 100

	Local $hWndCtrl = GUICtrlGetHandle($hCtrl)
	If Not $hWndCtrl Then Return SetError(1, 0, False)

	; Get client size of the control
	Local $tRect = _WinAPI_GetClientRect($hWndCtrl)
	If @error Then Return SetError(2, 0, False)

	Local $iWidth  = DllStructGetData($tRect, "Right") - DllStructGetData($tRect, "Left")
	Local $iHeight = DllStructGetData($tRect, "Bottom") - DllStructGetData($tRect, "Top")
	If $iWidth <= 0 Or $iHeight <= 0 Then Return SetError(3, 0, False)

	; GDI+ uses reference counting - safe to call startup multiple times
	_GDIPlus_Startup()

	Local $hDC = _WinAPI_GetDC($hWndCtrl)
	If Not $hDC Then
		Return SetError(4, 0, False)
	EndIf

	Local $hGraphics = _GDIPlus_GraphicsCreateFromHDC($hDC)
	If @error Or Not $hGraphics Then
		_WinAPI_ReleaseDC($hWndCtrl, $hDC)
		Return SetError(5, 0, False)
	EndIf

	; Ensure colors are ARGB
	__GDIPlusProgressBar_VerifyARGB($iBackColor)
	__GDIPlusProgressBar_VerifyARGB($iOuterColor)
	__GDIPlusProgressBar_VerifyARGB($iInnerColor)
	__GDIPlusProgressBar_VerifyARGB($iPeakColor)

	Local $hBrushBg    = _GDIPlus_BrushCreateSolid($iBackColor)
	Local $hBrushOuter = _GDIPlus_BrushCreateSolid($iOuterColor)
	Local $hBrushInner = _GDIPlus_BrushCreateSolid($iInnerColor)
	Local $hBrushPeak  = _GDIPlus_BrushCreateSolid($iPeakColor)

	; Clear entire control background
	_GDIPlus_GraphicsFillRect($hGraphics, 0, 0, $iWidth, $iHeight, $hBrushBg)

	; Draw peak bar first (faint, underneath) with same color scheme but lighter opacity
	If $iPeakPerc > 0 Then
		Local $iFillW, $iFillH

		If Not $bVertical Then
			$iFillW = Round($iWidth * $iPeakPerc / 100)
			$iFillH = $iHeight
		Else
			$iFillW = $iWidth
			$iFillH = Round($iHeight * $iPeakPerc / 100)
		EndIf

		If $iFillW > 0 And $iFillH > 0 Then
			; Extract RGB from outer color and darken it by 40% for peak border
			Local $iR = BitShift(BitAND($iOuterColor, 0xFF0000), 16)
			Local $iG = BitShift(BitAND($iOuterColor, 0x00FF00), 8)
			Local $iB = BitAND($iOuterColor, 0x0000FF)
			$iR = Floor($iR * 0.6)
			$iG = Floor($iG * 0.6)
			$iB = Floor($iB * 0.6)
			Local $iPeakBorderColor = BitOR(0xFF000000, BitShift($iR, -16))
			$iPeakBorderColor = BitOR($iPeakBorderColor, BitShift($iG, -8))
			$iPeakBorderColor = BitOR($iPeakBorderColor, $iB)
			Local $hBrushPeakBorder = _GDIPlus_BrushCreateSolid($iPeakBorderColor)
			
			; Extract RGB from inner color and darken it by 40% for peak inner
			$iR = BitShift(BitAND($iInnerColor, 0xFF0000), 16)
			$iG = BitShift(BitAND($iInnerColor, 0x00FF00), 8)
			$iB = BitAND($iInnerColor, 0x0000FF)
			$iR = Floor($iR * 0.6)
			$iG = Floor($iG * 0.6)
			$iB = Floor($iB * 0.6)
			Local $iPeakInnerColor = BitOR(0xFF000000, BitShift($iR, -16))
			$iPeakInnerColor = BitOR($iPeakInnerColor, BitShift($iG, -8))
			$iPeakInnerColor = BitOR($iPeakInnerColor, $iB)
			Local $hBrushPeakInner = _GDIPlus_BrushCreateSolid($iPeakInnerColor)
			
			If Not $bVertical Then
				; Horizontal: lighter outer border then lighter inner fill
				_GDIPlus_GraphicsFillRect($hGraphics, 0, 0, $iFillW, $iFillH, $hBrushPeakBorder)
				If $iFillW > 2 And $iFillH > 2 Then
					_GDIPlus_GraphicsFillRect($hGraphics, 1, 1, $iFillW - 2, $iFillH - 2, $hBrushPeakInner)
				EndIf
			Else
				; Vertical: lighter outer border then lighter inner fill
				Local $iY = $iHeight - $iFillH
				_GDIPlus_GraphicsFillRect($hGraphics, 0, $iY, $iFillW, $iFillH, $hBrushPeakBorder)
				If $iFillW > 2 And $iFillH > 2 Then
					_GDIPlus_GraphicsFillRect($hGraphics, 1, $iY + 1, $iFillW - 2, $iFillH - 2, $hBrushPeakInner)
				EndIf
			EndIf
			
			_GDIPlus_BrushDispose($hBrushPeakBorder)
			_GDIPlus_BrushDispose($hBrushPeakInner)
		EndIf
	EndIf

	; Draw current value bar on top (bright)
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

	; Cleanup (but don't shutdown GDI+ - FFLabels manages it globally)
	_GDIPlus_BrushDispose($hBrushBg)
	_GDIPlus_BrushDispose($hBrushOuter)
	_GDIPlus_BrushDispose($hBrushInner)
	_GDIPlus_BrushDispose($hBrushPeak)
	_GDIPlus_GraphicsDispose($hGraphics)
	_WinAPI_ReleaseDC($hWndCtrl, $hDC)

	Return True

EndFunc   ;==>_GDIPlusProgressBar_DrawWithPeak


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
