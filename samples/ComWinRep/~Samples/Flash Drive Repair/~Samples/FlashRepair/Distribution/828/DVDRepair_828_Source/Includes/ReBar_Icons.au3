#Include-once

#Include <Constants.au3>
#Include <GDIPlus.au3>
#Include <WinAPI.au3>
#Include <WinAPIShellEx.au3>
#Include <WindowsConstants.au3>

; #INDEX# =======================================================================================================================
; Title .........: Icons
; AutoIt Version : 3.3.15.0
; Description ...: Additional and corrected functions for working with icons.
; Author(s) .....: Yashied, Derick Payne (Rizonesoft)
; ===============================================================================================================================

#Region Global Variables and Constants

; #VARIABLES# ===================================================================================================================
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__SS_BITMAP = 0x0E
Global Const $__SS_ICON = 0x03
Global Const $__STM_SETIMAGE = 0x0172
Global Const $__STM_GETIMAGE = 0x0173
; ===============================================================================================================================
#EndRegion Global Variables and Constants


#Region Functions list
; #CURRENT# =====================================================================================================================
; _Icons_SetCombineBkIcon
; _Icons_SetHIcon

; _Icons_BitmapCrop
; _Icons_BitmapCreateFromIcon
; _Icons_BitmapCreateSolidBitmap
; _Icons_BitmapDuplicate
; _Icons_BitmapGetSize
; _Icons_BitmapIsAlpha
; _Icons_BitmapIsHBitmap
; _Icons_BitmapLoad
; _Icons_BitmapResize
; _Icons_CtrlCheckHandle
; _Icons_CtrlCheckSize
; _Icons_CtrlEnum
; _Icons_CtrlFitTo
; _Icons_CtrlGetRect
; _Icons_CtrlGetSize
; _Icons_CtrlInvalidate
; _Icons_CtrlSetImage
; _Icons_CtrlUpdate
; _Icons_IconDuplicate
; _Icons_IconExtract
; _Icons_IconGetSize
; _Icons_IconMerge
; ===============================================================================================================================

; #INTERNAL# ===========================================================================================================
; __Icons_SystemGetColor
; __Icons_SystemSwitchColor
; ===============================================================================================================================
#EndRegion Functions list

; #FUNCTION# ====================================================================================================================
; Name...........: _Icons_SetCombineBkIcon
; Description....: Creates the icon from a combination of the specified two icons on solid background and sets it to use for a control.
; Syntax.........: _Icons_SetCombineBkIcon ( $hWnd, $iBackground, $sIcon1 [, $iIndex1 [, $iWidth1 [, $iHeight1 [, $sIcon2 [, $iIndex2 [, $iWidth2 [, $iHeight2 [, $iX [, $iY [, $hOverlap]]]]]]]]]] )
; Parameters.....: $hWnd        - The control identifier (controlID) or handle as returned by a GUICtrlCreateIcon() function.
;                  $iBackground - Value of the color (in RGB) for background. If the value of this parameter is (-1), the color will match
;                                 background color of the window that contains the control.
;                  $sIcon1      - Name of the file containing the icon for the back icon.
;                  $iIndex1     - Index of the icon in the file, for the back icon.
;                  $iWidth1     - Width of the back icon. (-1) - determined from the system metrics for large icon.
;                  $iHeight1    - Height of the back icon. (-1) - determined from the system metrics for large icon.
;                  $sIcon2      - Name of the file containing the icon for the top icon.
;                  $iIndex2     - Index of the icon in the file, for the top icon.
;                  $iWidth2     - Width of the top icon.
;                  $iHeight2    - Height of the back icon.
;                  $iX          - X value of the upper-left corner of the top icon.
;                  $iY          - Y value of the upper-left corner of the top icon.
;                  $hOverlap    - The control identifier (controlID) or handle to the control that overlaps with the $hWnd control.
;                                 If this parameter is 0 (flicker reducing is disable) the control will be redrawn by sending WM_ERASEBKGND
;                                 and WM_NCPAINT messages to the parent window. If $hOverlap is (-1) the WM_... messages will be sent to
;                                 all top and bottom-level controls. Note that method works only in case of a complete overlapping
;                                 controls, such as icon is placed completely on top of the Tab. If $hOverlap is handle to the control
;                                 the WM_... messages will be sent to this control only. All top-level controls will be ignored.
; Return values..: Success      - 1
;                  Failure      - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: Created by using this function icon is always placed on a solid background (NOT transparent). Use value (-1) to automatically
;                  determine the background color of the current window. The window should not be a hidden state. The function uses GDI+,
;                  so if you often call this function, call the _GDIPlus_Startup() at the top of your code is a good idea.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _Icons_SetCombineBkIcon($hWnd, $iBackground, $sIcon1, $iIndex1 = 0, $iWidth1 = -1, $iHeight1 = -1, $sIcon2 = '', $iIndex2 = 0, $iWidth2 = -1, $iHeight2 = -1, $iX = 0, $iY = 0, $hOverlap = 0)

	$hWnd = _Icons_CtrlCheckHandle($hWnd)
	If $hWnd = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hParent

	If $iBackground < 0 Then

		$hParent = _WinAPI_GetParent($hWnd)
		If (BitAND(WinGetState($hParent), 2)) And (Not BitAND(WinGetState($hParent), 16)) Then
			$iBackground = __Icons_SystemGetColor($hParent)
		EndIf
		If $iBackground < 0 Then
			$iBackground = __Icons_SystemSwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE))
		EndIf

	EndIf

	_Icons_CtrlCheckSize($hWnd, $iWidth1, $iHeight1)
	_Icons_CtrlCheckSize($hWnd, $iWidth2, $iHeight2)

	Local $hBack = _Icons_IconExtract($sIcon1, $iIndex1, $iWidth1, $iHeight1)
	Local $hFront = _Icons_IconExtract($sIcon2, $iIndex2, $iWidth2, $iHeight2)
	Local $hIcon = _Icons_IconMerge($iBackground, $hBack, $hFront, $iX, $iY, $iWidth1, $iHeight1)

	If $hBack Then
		_WinAPI_DestroyIcon($hBack)
	EndIf
	If $hFront Then
		_WinAPI_DestroyIcon($hFront)
	EndIf
	If Not ($hOverlap < 0) Then
		$hOverlap = _Icons_CtrlCheckHandle($hOverlap)
	EndIf
	If Not _Icons_CtrlSetImage($hWnd, $hIcon, $IMAGE_ICON, $hOverlap) Then
		If $hIcon Then
			_WinAPI_DestroyIcon($hIcon)
		EndIf
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_Icons_SetCombineBkIcon


; #FUNCTION# ====================================================================================================================
; Name...........: _Icons_SetHIcon
; Description....: Sets the icon object (HIcon) to use for a control.
; Syntax.........: _Icons_SetHIcon ( $hWnd, $hIcon [, $hOverlap] )
; Parameters.....: $hWnd     - The control identifier (controlID) or handle as returned by a GUICtrlCreateIcon() function.
;                  $hIcon    - The handle to a icon (HIcon). If this value is 0, the function just release the control of the
;                              previous icons.
;                  $hOverlap - The control identifier (controlID) or handle to the control that overlaps with the $hWnd control.
;                              If this parameter is 0 (flicker reducing is disable) the control will be redrawn by sending WM_ERASEBKGND
;                              and WM_NCPAINT messages to the parent window. If $hOverlap is (-1) the WM_... messages will be sent to
;                              all top and bottom-level controls. Note that method works only in case of a complete overlapping
;                              controls, such as icon is placed completely on top of the Tab. If $hOverlap is handle to the control
;                              the WM_... messages will be sent to this control only. All top-level controls will be ignored.
; Return values..: Success   - 1
;                  Failure   - 0 and sets the @error flag to non-zero.
; Author.........: Yashied
; Modified.......:
; Remarks........: This function works like _Icons_SetIcon(), but only for the icon handles. The function copies the icon in the control,
;                  and if the icon is no longer needed, it is necessary to release the resources associated with the icon by
;                  using the _WinAPI_DestroyIcon() function.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================================
Func _Icons_SetHIcon($hWnd, $hIcon, $hOverlap = 0)

	$hWnd = _Icons_CtrlCheckHandle($hWnd)
	If $hWnd = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	If Not ($hOverlap < 0) Then
		$hOverlap = _Icons_CtrlCheckHandle($hOverlap)
	EndIf

	$hIcon = _Icons_IconDuplicate($hIcon)
	If Not _Icons_CtrlSetImage($hWnd, $hIcon, $IMAGE_ICON, $hOverlap) Then
		If $hIcon Then
			_WinAPI_DestroyIcon($hIcon)
		EndIf
		Return SetError(1, 0, 0)
	EndIf

	Return 1

EndFunc   ;==>_Icons_SetHIcon





























; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_BitmapCrop($hBitmap, $iX, $iY, $iWidth, $iHeight)

	If Not _Icons_BitmapIsHBitmap($hBitmap) Then
		Return 0
	EndIf

	Local $hDC, $hDestDC, $hSrcDC, $hBmp

	$hDC = _WinAPI_GetDC(0)
	$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBmp = _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
	_WinAPI_SelectObject($hDestDC, $hBmp)
	$hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
	_WinAPI_SelectObject($hSrcDC, $hBitmap)
	_WinAPI_ReleaseDC(0, $hDC)

	If Not _WinAPI_BitBlt($hDestDC, 0, 0, $iWidth, $iHeight, $hSrcDC, $iX, $iY, $SRCCOPY) Then
		_WinAPI_DeleteObject($hBmp)
		$hBmp = 0
	EndIf

	_WinAPI_DeleteDC($hDestDC)
	_WinAPI_DeleteDC($hSrcDC)

	Return $hBmp

EndFunc   ;==>_Icons_BitmapCrop


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_BitmapCreateFromIcon($hIcon)

	Local $tICONINFO = DllStructCreate($tagICONINFO)
	Local $Ret, $hBitmap

	$Ret = DllCall("user32.dll", "int", "GetIconInfo", "ptr", $hIcon, "ptr", DllStructGetPtr($tICONINFO))
	If (@error) Or ($Ret[0] = 0) Then
		Return 0
	EndIf

	$hBitmap = _Icons_BitmapDuplicate(DllStructGetData($tICONINFO, 5), 1)
	If Not _Icons_BitmapIsAlpha($hBitmap) Then
		_GDIPlus_Startup()
		_WinAPI_DeleteObject($hBitmap)
		$Ret = DllCall($__g_hGDIPDll, "int", "GdipCreateBitmapFromHICON", "ptr", $hIcon, "ptr*", 0)
		If (Not @error) And ($Ret[0] = 0) Then
			$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Ret[2])
			_GDIPlus_ImageDispose($Ret[2])
		Else
			$hBitmap = 0
		EndIf
		_GDIPlus_Shutdown()
	EndIf

	Return $hBitmap

EndFunc   ;==>_Icons_BitmapCreateFromIcon


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_BitmapCreateSolidBitmap($iColor, $iWidth, $iHeight)

	Local $hDC, $hMemDC, $tRect, $hBitmap, $hBrush, $tRect = DllStructCreate($tagRECT)

	DllStructSetData($tRect, 1, 0)
	DllStructSetData($tRect, 2, 0)
	DllStructSetData($tRect, 3, $iWidth)
	DllStructSetData($tRect, 4, $iHeight)

	$hDC = _WinAPI_GetDC(0)
	$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
	_WinAPI_SelectObject($hMemDC, $hBitmap)
	_WinAPI_ReleaseDC(0, $hDC)
	$hBrush = _WinAPI_CreateSolidBrush(__Icons_SystemSwitchColor($iColor))

	If Not _WinAPI_FillRect($hMemDC, DllStructGetPtr($tRect), $hBrush) Then
		_WinAPI_DeleteObject($hBitmap)
		$hBitmap = 0
	EndIf

	_WinAPI_DeleteObject($hBrush)
	_WinAPI_DeleteDC($hMemDC)

	Return $hBitmap

EndFunc   ;==>_Icons_BitmapCreateSolidBitmap


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_BitmapDuplicate($hBitmap, $fDelete = 0)

	If $fDelete Then
		$fDelete = $LR_COPYDELETEORG
	EndIf

	Local $Ret = DllCall("user32.dll", "hwnd", "CopyImage", "ptr", $hBitmap, "int", 0, "int", 0, "int", 0, "int", BitOR($LR_CREATEDIBSECTION, $fDelete))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	Return $Ret[0]

EndFunc   ;==>_Icons_BitmapDuplicate


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_BitmapGetSize($hBitmap)

	If Not _Icons_BitmapIsHBitmap($hBitmap) Then
		Return 0
	EndIf

	Local $tObj = DllStructCreate("long Type;long Width;long Height;long WidthBytes;ushort Planes;ushort BitsPixel;ptr Bits")
	Local $Ret = DllCall("gdi32.dll", "int", "GetObject", "int", $hBitmap, "int", DllStructGetSize($tObj), "ptr", DllStructGetPtr($tObj))

	If (@error) Or ($Ret[0] = 0) Then
		Return 0
	EndIf

	Local $Size[2] = [DllStructGetData($tObj, "Width"), DllStructGetData($tObj, "Height")]

	If ($Size[0] = 0) Or ($Size[1] = 0) Then
		Return 0
	EndIf

	Return $Size

EndFunc   ;==>_Icons_BitmapGetSize


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_BitmapIsAlpha($hBitmap)

	Local $Ret, $Lenght, $tBits

	$Ret = DllCall("gdi32.dll", "int", "GetBitmapBits", "ptr", $hBitmap, "long", 0, "ptr", 0)
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	$Lenght = $Ret[0] / 4
	$tBits = DllStructCreate("dword[" & $Lenght & "]")
	$Ret = DllCall("gdi32.dll", "int", "GetBitmapBits", "ptr", $hBitmap, "long", $Ret[0], "ptr", DllStructGetPtr($tBits))
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf

	For $i = 1 To $Lenght
		If BitAND(DllStructGetData($tBits, 1, $i), 0xFF000000) Then
			Return 1
		EndIf
	Next

	Return 0

EndFunc   ;==>_Icons_BitmapIsAlpha


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_BitmapIsHBitmap($hBitmap)

	Local $Ret  = DllCall("gdi32.dll", "dword", "GetObjectType", "ptr", $hBitmap)

	If (Not @error) And ($Ret[0] = 7) Then
		Return 1
	EndIf

	Return 0

EndFunc   ;==>_Icons_BitmapIsHBitmap


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_BitmapLoad($sImage)

	_GDIPlus_Startup()

	Local $hImage = _GDIPlus_ImageLoadFromFile($sImage)
	Local $hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)

	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()

	Return $hBitmap
EndFunc   ;==>_Icons_BitmapLoad


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_BitmapResize($hBitmap, $iWidth, $iHeight, $fHalftone = 0)

	Local $Size = _Icons_BitmapGetSize($hBitmap)

	If $Size = 0 Then
		Return 0
	EndIf

	Local $Ret, $hDC, $hDestDC, $hSrcDC, $hBmp

	$hDC = _WinAPI_GetDC(0)
	$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBmp = _WinAPI_CreateCompatibleBitmap($hDC, $iWidth, $iHeight)
	_WinAPI_SelectObject($hDestDC, $hBmp)
	$hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
	_WinAPI_SelectObject($hSrcDC, $hBitmap)
	_WinAPI_ReleaseDC(0, $hDC)

	If $fHalftone Then
		$fHalftone = 4
	Else
		$fHalftone = 3
	EndIf

	DllCall("gdi32.dll", "int", "SetStretchBltMode", "hwnd", $hDestDC, "int", $fHalftone)
	$Ret = DllCall("gdi32.dll", "int", "StretchBlt", "hwnd", $hDestDC, "int", 0, "int", 0, "int", _
		$iWidth, "int", $iHeight, "hwnd", $hSrcDC, "int", 0, "int", 0, "int", $Size[0], "int", $Size[1], "dword", $SRCCOPY)
	If (@error) Or ($Ret[0] = 0) Then
		_WinAPI_DeleteObject($hBmp)
		$hBmp = 0
	EndIf

	_WinAPI_DeleteDC($hDestDC)
	_WinAPI_DeleteDC($hSrcDC)

	Return $hBmp

EndFunc   ;==>_Icons_BitmapResize


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_CtrlCheckHandle($hWnd)

	If Not IsHWnd($hWnd) Then
		$hWnd = GUICtrlGetHandle($hWnd)
		If $hWnd = 0 Then
			Return 0
		EndIf
	EndIf

	Return $hWnd

EndFunc   ;==>_Icons_CtrlCheckHandle


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_CtrlCheckSize($hWnd, ByRef $iX, ByRef $iY)

	Local $Size = _Icons_CtrlGetSize($hWnd)

	If $iX < 1 Then
		If $Size = 0 Then
			$iX = _WinAPI_GetSystemMetrics($SM_CXICON)
		Else
			$iX = $Size[0]
		EndIf
	EndIf

	If $iY < 1 Then
		If $Size = 0 Then
			$iY = _WinAPI_GetSystemMetrics($SM_CYICON)
		Else
			$iY = $Size[1]
		EndIf
	EndIf

EndFunc   ;==>_Icons_CtrlCheckSize


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_CtrlEnum($hWnd, $iDirection)

	Local $iWnd, $Count = 0, $aWnd[50] = [$hWnd]

	If $iDirection Then
		$iDirection = $GW_HWNDNEXT
	Else
		$iDirection = $GW_HWNDPREV
	EndIf

	While 1

		$iWnd = _WinAPI_GetWindow($aWnd[$Count], $iDirection)
		If Not $iWnd Then
			ExitLoop
		EndIf

		$Count += 1
		If $Count = UBound($aWnd) Then
			ReDim $aWnd[$Count + 50]
		EndIf

		$aWnd[$Count] = $iWnd

	WEnd

	ReDim $aWnd[$Count + 1]
	Return $aWnd

EndFunc   ;==>_Icons_CtrlEnum


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_CtrlFitTo($hWnd, $hImage)

	Local $Size = _Icons_CtrlGetSize($hWnd)

	If $Size = 0 Then
		Return SetError(1, 0, $hImage)
	EndIf

	_GDIPlus_Startup()

	Local $Width = _GDIPlus_ImageGetWidth($hImage), $Height = _GDIPlus_ImageGetHeight($hImage)
	Local $Ret, $Error = 0

	If ($Width = -1) Or ($Height = -1) Then
		$Error = 1
	Else
		If ($Width <> $Size[0]) Or ($Height <> $Size[1]) Then
			$Ret = DllCall($__g_hGDIPDll, "int", "GdipGetImageThumbnail", "ptr", $hImage, "int", $Size[0], "int", $Size[1], "ptr*", 0, "ptr", 0, "ptr", 0)
			If (Not @error) And ($Ret[0] = 0) Then
				_GDIPlus_ImageDispose($hImage)
				$hImage = $Ret[4]
			Else
				$Error = 1
			EndIf
		EndIf
	EndIf

	_GDIPlus_Shutdown()

	Return SetError($Error, 0, $hImage)
EndFunc   ;==>_Icons_CtrlFitTo


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_CtrlGetRect($hWnd)

	Local $Pos = ControlGetPos($hWnd, "", "")

	If (@error) Or ($Pos[2] = 0) Or ($Pos[3] = 0) Then
		Return 0
	EndIf

	Local $tRect = DllStructCreate($tagRECT)

	DllStructSetData($tRect, 1, $Pos[0])
	DllStructSetData($tRect, 2, $Pos[1])
	DllStructSetData($tRect, 3, $Pos[0] + $Pos[2])
	DllStructSetData($tRect, 4, $Pos[1] + $Pos[3])

	Return $tRect

EndFunc   ;==>_Icons_CtrlGetRect


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_CtrlGetSize($hWnd)

	Local $tRect = DllStructCreate($tagRECT)
	Local $Ret = DllCall("user32.dll", "int", "GetClientRect", "hwnd", $hWnd, "ptr", DllStructGetPtr($tRect))

	If (@error) Or ($Ret[0] = 0) Then
		Return 0
	EndIf

	Local $Size[2] = [DllStructGetData($tRect, 3) - DllStructGetData($tRect, 1), DllStructGetData($tRect, 4) - DllStructGetData($tRect, 2)]

	If ($Size[0] = 0) Or ($Size[1] = 0) Then
		Return 0
	EndIf

	Return $Size

EndFunc   ;==>_Icons_CtrlGetSize


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_CtrlInvalidate($hWnd)

	Local $tRect = _Icons_CtrlGetRect($hWnd)

	If IsDllStruct($tRect) Then
		_WinAPI_InvalidateRect(_WinAPI_GetParent($hWnd), $tRect)
	EndIf

EndFunc   ;==>_Icons_CtrlInvalidate


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_CtrlSetImage($hWnd, $hImage, $iType, $hOverlap)

	Local $Static, $Style, $Update, $tRect, $hPrev

	Switch $iType
		Case $IMAGE_BITMAP
			$Static = $__SS_BITMAP
		Case $IMAGE_ICON
			$Static = $__SS_ICON
		Case Else
			Return 0
	EndSwitch

	$Style = _WinAPI_GetWindowLong($hWnd, $GWL_STYLE)
	If @error Then
		Return 0
	EndIf

	_WinAPI_SetWindowLong($hWnd, $GWL_STYLE, BitOR($Style, $Static))
	If @error Then
		Return 0
	EndIf

	$tRect = _Icons_CtrlGetRect($hWnd)
	$hPrev = _SendMessage($hWnd, $__STM_SETIMAGE, $iType, $hImage)
	If @error Then
		Return 0
	EndIf

	If $hPrev Then
		If $iType = $IMAGE_BITMAP Then
			_WinAPI_DeleteObject($hPrev)
		Else
			_WinAPI_DestroyIcon($hPrev)
		EndIf
	EndIf

	If (Not $hImage) And (IsDllStruct($tRect)) Then
		_WinAPI_MoveWindow($hWnd, 	DllStructGetData($tRect, 1), _
									DllStructGetData($tRect, 2), _
									DllStructGetData($tRect, 3) - DllStructGetData($tRect, 1), _
									DllStructGetData($tRect, 4) - DllStructGetData($tRect, 2), 0)
	EndIf

	If $hOverlap Then
		If Not IsHWnd($hOverlap) Then
			$hOverlap = 0
		EndIf
		_Icons_CtrlUpdate($hWnd, $hOverlap)
	Else
		_Icons_CtrlInvalidate($hWnd)
	EndIf

	Return 1

EndFunc   ;==>__Icons_CtrlSetImage


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_CtrlUpdate($hWnd, $hOverlap)

	Local $tBack, $tFront = _Icons_CtrlGetRect($hWnd)

	If $tFront = 0 Then
		Return
	EndIf

	Local $aNext = _Icons_CtrlEnum($hWnd, 1)
	Local $aPrev = _Icons_CtrlEnum($hWnd, 0)

	If UBound($aPrev) = 1 Then
		_WinAPI_InvalidateRect(_WinAPI_GetParent($hWnd), $tFront)
		Return
	EndIf

	Local $aWnd[UBound($aNext) + UBound($aPrev - 1)]
	Local $tIntersect = DllStructCreate($tagRECT), $pIntersect = DllStructGetPtr($tIntersect)
	Local $iWnd, $Ret, $XOffset, $YOffset, $Count = 0, $Update = 0

	For $i = UBound($aPrev) - 1 To 1 Step -1
		$aWnd[$Count] = $aPrev[$i]
		$Count += 1
	Next

	For $i = 0 To UBound($aNext) - 1
		$aWnd[$Count] = $aNext[$i]
		$Count += 1
	Next

	For $i = 0 To $Count - 1
		If $aWnd[$i] = $hWnd Then
			_WinAPI_InvalidateRect($hWnd)
		Else

			If (Not $hOverlap) Or ($aWnd[$i] = $hOverlap) Then
				$tBack = _Icons_CtrlGetRect($aWnd[$i])
				$Ret = DllCall("user32.dll", "int", "IntersectRect", "ptr", $pIntersect, "ptr", DllStructGetPtr($tFront), "ptr", DllStructGetPtr($tBack))

				If (Not @error) And ($Ret[0]) Then
					$Ret = DllCall("user32.dll", "int", "IsRectEmpty", "ptr", $pIntersect)

					If (Not @error) And (Not $Ret[0]) Then
						$XOffset = DllStructGetData($tBack, 1)
						$YOffset = DllStructGetData($tBack, 2)
						$Ret = DllCall("user32.dll", "int", "OffsetRect", "ptr", $pIntersect, "int", -$XOffset, "int", -$YOffset)

						If (Not @error) And ($Ret[0]) Then
							_WinAPI_InvalidateRect($aWnd[$i], $tIntersect)
							$Update += 1
						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	Next

	If Not $Update Then
		_WinAPI_InvalidateRect(_WinAPI_GetParent($hWnd), $tFront)
	EndIf

EndFunc   ;==>_Icons_CtrlUpdate


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_IconDuplicate($hIcon)

	If $hIcon Then
		Return _WinAPI_CopyIcon($hIcon)
	EndIf

	Return 0

EndFunc   ;==>_Icons_IconDuplicate


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_IconExtract($sIcon, $iIndex, $iWidth, $iHeight)

	Local $Ret = DllCall(	"shell32.dll", "int", "SHExtractIconsW", "wstr", $sIcon, "int", $iIndex, "int", $iWidth, "int", $iHeight, _
							"ptr*", 0, "ptr*", 0, "int", 1, "int", 0)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[5]
EndFunc   ;==>_Icons_IconExtract


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_IconGetSize($hIcon)

	Local $tICONINFO = DllStructCreate($tagICONINFO)
	Local $Ret = DllCall("user32.dll", "int", "GetIconInfo", "ptr", $hIcon, "ptr", DllStructGetPtr($tICONINFO))

	If (@error) Or ($Ret[0] = 0) Then
		Return 0
	EndIf

	Local $Size = _Icons_BitmapGetSize(DllStructGetData($tICONINFO, 5))

	_WinAPI_DeleteObject(DllStructGetData($tICONINFO, 4))
	_WinAPI_DeleteObject(DllStructGetData($tICONINFO, 5))

	If ($Size[0] = 0) Or ($Size[1] = 0) Then
		Return 0
	EndIf

	Return $Size

EndFunc   ;==>_Icons_IconGetSize


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _Icons_IconMerge($iBackground, $hBack, $hFront, $iX, $iY, $iWidth = -1, $iHeight = -1)

	Local $Size

	If ($iWidth < 1) Or ($iHeight < 1) Then
		$Size = _Icons_IconGetSize($hBack)
		If $Size = 0 Then
			Return 0
		EndIf
		If $iWidth < 1 Then
			$iWidth = $Size[0]
		EndIf
		If $iHeight < 1 Then
			$iHeight = $Size[0]
		EndIf
	EndIf

	Local $hDC, $hMemDC, $hImage, $hBitmap, $hIcon

	$hDC = _WinAPI_GetDC(0)
	$hMemDC = _WinAPI_CreateCompatibleDC($hDC)
	$hBitmap = _Icons_BitmapCreateSolidBitmap($iBackground, $iWidth, $iHeight)
	_WinAPI_SelectObject($hMemDC, $hBitmap)
	_WinAPI_ReleaseDC(0, $hDC)
	If $hBack Then
		_WinAPI_DrawIconEx($hMemDC, 0, 0, $hBack, 0, 0, 0, 0, $DI_NORMAL)
	EndIf
	If $hFront Then
		_WinAPI_DrawIconEx($hMemDC, $iX, $iY, $hFront, 0, 0, 0, 0, $DI_NORMAL)
	EndIf

	_GDIPlus_Startup()

	$hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	$hIcon = DllCall($__g_hGDIPDll, "int", "GdipCreateHICONFromBitmap", "ptr", $hImage, "ptr*", 0)
	If (Not @error) And ($hIcon[0] = 0) Then
		$hIcon = $hIcon[2]
	Else
		$hIcon = 0
	EndIf

	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()

	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteDC($hMemDC)

	Return $hIcon

EndFunc   ;==>_Icons_IconMerge


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func __Icons_SystemGetColor($hWnd)

	Local $Ret, $hDC = _WinAPI_GetDC($hWnd)

	If $hDC = 0 Then
		Return -1
	EndIf
	$Ret = DllCall("gdi32.dll", "int", "GetBkColor", "hwnd", $hDC)
	If (@error) Or ($Ret[0] < 0) Then
		$Ret = -1
	EndIf
	_WinAPI_ReleaseDC($hWnd, $hDC)
	If $Ret < 0 Then
		Return -1
	EndIf
	Return __Icons_SystemSwitchColor($Ret[0])

EndFunc   ;==>__Icons_SystemGetColor


; #FUNCTION# ====================================================================================================================
; Author ........: Yashied
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func __Icons_SystemSwitchColor($iColor)

	Return BitOR(BitAND($iColor, 0x00FF00), BitShift(BitAND($iColor, 0x0000FF), -16), BitShift(BitAND($iColor, 0xFF0000), 16))

EndFunc   ;==>__Icons_SystemSwitchColor