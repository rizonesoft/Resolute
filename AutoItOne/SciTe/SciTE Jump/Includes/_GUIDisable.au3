#include-once

; #AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7
; #INDEX# =======================================================================================================================
; Title .........: _GUIDisable
; AutoIt Version : v3.2.2.0 or higher
; Language ......: English
; Description ...: Creates a dimming effect on the current/selected GUI.
; Note ..........:
; Author(s) .....: guinness
; Remarks .......: Thanks to supersonic for the idea of adjusting the UDF when using Classic themes in Windows Vista+.
; ===============================================================================================================================

; #INCLUDES# ====================================================================================================================
#include <APIConstants.au3>
#include <GUIConstantsEx.au3>
#include <WinAPIEx.au3>
; #include <WindowsConstants.au3>

; #GLOBAL VARIABLES# ============================================================================================================
Global Enum $__hGUIDisableHWnd, $__hGUIDisableHWndPrevious, $__iGUIDisableMax
Global $__aGUIDisable[$__iGUIDisableMax]

; #CURRENT# =====================================================================================================================
; _GUIDisable: Creates a dimming effect on the current/selected GUI.
; ===============================================================================================================================

; #INTERNAL_USE_ONLY#============================================================================================================
; __GUIDisable_WM_SIZE: Automatically re-sizes the dimmed effect when the GUI is re-sized.
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _GUIDisable
; Description ...: Creates a dimming effect on the current/selected GUI.
; Syntax ........: _GUIDisable($hWnd[, $iAnimate = 1[, $iBrightness = 5[, $bColor = 0x000000]]])
; Parameters ....: $hWnd             - GUI handle the effect should be applied to. This can either be a variable of the GUI handle or -1 for the current GUI.
;                  $iAnimate            - [optional] Animate the dimmed effect. Animate = 1 or don't animate = 0. Default is 1.
;                  $iBrightness         - [optional] Percentage of how bright the effect is. Default is 5.
;                  $bColor              - [optional] Color of the dimming effect. Default is 0x000000.
; Return values .: Success - Returns handle of dimmed GUI.
;                  Failure - Returns 0 and sets @error to non-zero
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func _GUIDisable($hWnd, $iAnimate = Default, $iBrightness = Default, $bColor = 0x000000)
	; Local Const $AW_SLIDE_IN_TOP = 0x00040004, $AW_SLIDE_OUT_TOP = 0x00050008

	If $iAnimate = Default Then
		$iAnimate = 1
	EndIf
	If $iBrightness = Default Then
		$iBrightness = 5
	EndIf

	If $hWnd = -1 And $__aGUIDisable[$__hGUIDisableHWnd] = 0 Then
		Local $iLabel = GUICtrlCreateLabel('', -99, -99, 1, 1)
		$hWnd = _WinAPI_GetParent(GUICtrlGetHandle($iLabel))
		If @error Then
			Return SetError(1, 0 * GUICtrlDelete($iLabel), 0)
		EndIf
		GUICtrlDelete($iLabel)
	EndIf

	If IsHWnd($__aGUIDisable[$__hGUIDisableHWnd]) Then
		If $iAnimate Then
			_WinAPI_AnimateWindow($__aGUIDisable[$__hGUIDisableHWnd], BitOR($AW_SLIDE, $AW_VER_NEGATIVE, $AW_HIDE), 250)
			; DllCall('user32.dll', 'int', 'AnimateWindow', 'hwnd', $__aGUIDisable[$__hGUIDisableHWnd], 'dword', 250, 'dword', $AW_SLIDE_OUT_TOP)
		EndIf
		GUIDelete($__aGUIDisable[$__hGUIDisableHWnd])
		GUISwitch($__aGUIDisable[$__hGUIDisableHWndPrevious])
		$__aGUIDisable[$__hGUIDisableHWnd] = 0
		$__aGUIDisable[$__hGUIDisableHWndPrevious] = 0
	Else
		$__aGUIDisable[$__hGUIDisableHWndPrevious] = $hWnd

		Local $iLeft = 0, $iTop = 0
		Local $sCurrentTheme = RegRead('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes', 'CurrentTheme')
		Local $iIsClassicTheme = Number(StringInStr($sCurrentTheme, 'Basic.theme', 2) = 0 And StringInStr($sCurrentTheme, 'Ease of Access Themes', 2) > 0)

		Local $aStyle = GUIGetStyle($__aGUIDisable[$__hGUIDisableHWndPrevious])
		If UBound($aStyle) Then
			If BitAND($aStyle[0], $WS_SIZEBOX) Then
				; If RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\', 'CurrentVersion') >= 6.0 Then ; Windows Vista+.
				If _IsWindowsVersion() Then ; Windows Vista+.
					If $iIsClassicTheme Then
						$iLeft -= 1
						$iTop -= 1
					Else
						$iLeft -= 5
						$iTop -= 5
					EndIf
				Else
					$iLeft -= 1
					$iTop -= 1
				EndIf
			EndIf
		EndIf

		Local $aWinGetPos = WinGetClientSize($__aGUIDisable[$__hGUIDisableHWndPrevious])
		$__aGUIDisable[$__hGUIDisableHWnd] = GUICreate('', $aWinGetPos[0], $aWinGetPos[1], $iLeft, $iTop, $WS_POPUP, $WS_EX_MDICHILD, $__aGUIDisable[$__hGUIDisableHWndPrevious])
		GUISetBkColor($bColor, $__aGUIDisable[$__hGUIDisableHWnd])
		WinSetTrans($__aGUIDisable[$__hGUIDisableHWnd], '', Round($iBrightness * (255 / 100)))
		GUIRegisterMsg($WM_SIZE, '__GUIDisable_WM_SIZE')
		If $iAnimate Then
			_WinAPI_AnimateWindow($__aGUIDisable[$__hGUIDisableHWnd], BitOR($AW_SLIDE, $AW_VER_POSITIVE), 250)
			; DllCall('user32.dll', 'int', 'AnimateWindow', 'hwnd', $__aGUIDisable[$__hGUIDisableHWnd], 'dword', 250, 'dword', $AW_SLIDE_IN_TOP)
		Else
			GUISetState(@SW_SHOW, $__aGUIDisable[$__hGUIDisableHWnd])
		EndIf
		GUISetState(@SW_DISABLE, $__aGUIDisable[$__hGUIDisableHWnd])
		GUISwitch($__aGUIDisable[$__hGUIDisableHWndPrevious])
	EndIf
	Return $__aGUIDisable[$__hGUIDisableHWnd]
EndFunc   ;==>_GUIDisable

; #INTERNAL_USE_ONLY#============================================================================================================
Func __GUIDisable_WM_SIZE($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $iHeight = _WinAPI_HiWord($lParam)
	Local $iWidth = _WinAPI_LoWord($lParam)
	If $hWnd = $__aGUIDisable[$__hGUIDisableHWndPrevious] Then
		Local $iWinGetPos = WinGetPos($__aGUIDisable[$__hGUIDisableHWnd])
		If @error = 0 Then
			WinMove($__aGUIDisable[$__hGUIDisableHWnd], '', $iWinGetPos[0], $iWinGetPos[1], $iWidth, $iHeight)
		EndIf
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>__GUIDisable_WM_SIZE
