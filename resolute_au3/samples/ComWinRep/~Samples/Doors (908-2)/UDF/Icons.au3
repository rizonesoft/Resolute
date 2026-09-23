#Region Header

#cs

    Title:          Support for Icons UDF Library for AutoIt3
    Filename:       Icons.au3
    Description:    Additional and corrected functions for working with icons
    Author:         Yashied
    Version:        1.8
    Requirements:   AutoIt v3.3 +, Developed/Tested on WindowsXP Pro Service Pack 2
    Uses:           Constants.au3, GDIPlus.au3, WinAPI.au3, WindowsConstants.au3
    Notes:          -

                    http://www.autoitscript.com/forum/index.php?showtopic=92675

    Available functions:

    _SetCombineBkIcon
    _SetIcon
    _SetImage

    Added special for Handles (HIcon and HBitmap):

    _SetHIcon
    _SetHImage

    Not documented (Internal) functions:

    _Icons_Bitmap_Crop
    _Icons_Bitmap_CreateFromIcon
    _Icons_Bitmap_CreateSolidBitmap
    _Icons_Bitmap_Duplicate
    _Icons_Bitmap_GetSize
    _Icons_Bitmap_IsAlpha
    _Icons_Bitmap_IsHBitmap
    _Icons_Bitmap_Load
    _Icons_Bitmap_Resize

    _Icons_Control_CheckHandle
    _Icons_Control_CheckSize
	_Icons_Control_Enum
    _Icons_Control_FitTo
    _Icons_Control_GetRect
    _Icons_Control_GetSize
    _Icons_Control_Invalidate
    _Icons_Control_SetImage
    _Icons_Control_Update

    _Icons_Icon_Duplicate
    _Icons_Icon_Extract
    _Icons_Icon_CreateFromBitmap
    _Icons_Icon_GetSize
    _Icons_Icon_Merge

    _Icons_System_GetColor
    _Icons_System_SwitchColor

    Example:

        #Include <GUIConstantsEx.au3>
        #Include <Icons.au3>

        Global Const $sPng = RegRead('HKLM\SOFTWARE\AutoIt v3\AutoIt', 'InstallDir') & '\Examples\GUI\Advanced\Images\Torus.png'
        Global Const $sJpg = @TempDir & '\~wallpaper.jpg'
        Global Const $sGreen = @TempDir & '\~green.png'
        Global Const $sRed = @TempDir & '\~red.png'
        Global Const $sLogo = @TempDir & '\~logo.png'
        
        Example1()
        Example2()
        Example3()
        Example4()
        Example5()
        Example6()
        Example7()
        
        Func Example1()
            
            GUICreate('Example1', 204, 108)
            $Icon1 = GUICtrlCreateIcon('', 0, 30, 38, 32, 32)
            $Icon2 = GUICtrlCreateIcon('', 0, 88, 38, 32, 32)
            $Icon3 = GUICtrlCreateIcon('', 0, 146, 38, 32, 32)
            GUISetState()

            _SetCombineBkIcon($Icon1, -1, @SystemDir & '\shell32.dll', 70, 32, 32, @SystemDir & '\shell32.dll', 22, 24, 24, 0, 8)
            _SetCombineBkIcon($Icon2, -1, @SystemDir & '\shell32.dll', 3, 32, 32, @SystemDir & '\shell32.dll', 28, 32, 32)
            _SetCombineBkIcon($Icon3, -1, @SystemDir & '\shell32.dll', 220, 32, 32, @SystemDir & '\shell32.dll', 29, 32, 32)

            Do
            Until GUIGetMsg() = $GUI_EVENT_CLOSE
            
            GUIDelete()
            
        EndFunc   ;==>Example1
        
        Func Example2()
            
            GUICreate('Example2', 216, 128)
            $Icon = GUICtrlCreateIcon('', 0, 40, 40, 48, 48)
            GUICtrlCreateIcon(@WindowsDir & '\explorer.exe', 0, 128, 40, 48, 48)
            GUISetState()

            _SetIcon($Icon, @WindowsDir & '\explorer.exe', 0, 48, 48)

            Do
            Until GUIGetMsg() = $GUI_EVENT_CLOSE
            
            GUIDelete()
            
        EndFunc   ;==>Example2
        
        Func Example3()
            
            GUICreate('Example3', 715, 388)
            $Pic1 = GUICtrlCreatePic('', 10, 10, 386, 368)
            $Pic2 = GUICtrlCreatePic('', 406, 10, 193, 184)
            $Pic3 = GUICtrlCreatePic('', 609, 10, 96, 92)
            GUISetState()

            _SetImage($Pic1, $sPng)
            _SetImage($Pic2, $sPng)
            _SetImage($Pic3, $sPng)

            Do
            Until GUIGetMsg() = $GUI_EVENT_CLOSE
        
            GUIDelete()
            
        EndFunc   ;==>Example3

        Func Example4()
            
            GUICreate('Example4', 253, 244)
            $Pic1 = GUICtrlCreatePic('', 10, 10, 193, 184)
            $Pic2 = GUICtrlCreatePic('', 60, 60, 193, 184)
            GUISetState()

            _SetImage($Pic2, $sPng)
            _SetImage($Pic1, $sPng)

            Do
            Until GUIGetMsg() = $GUI_EVENT_CLOSE

            GUIDelete()

        EndFunc   ;==>Example4

        Func Example5()

            Local $aIndex[10] = [4, 13, 23, 31, 86, 104, 130, 150, 168, 170]

            GUICreate('Example5', 600, 400)
            $Pic = GUICtrlCreatePic('', 0, 0, 600, 400)
            For $i = 1 To UBound($aIndex)
                GUICtrlCreatePic('', Random(0, 600 - 48, 1), Random(0, 400 - 48, 1), 48, 48)
                $hIcon = _Icons_Icon_Extract(@SystemDir & '\shell32.dll', $aIndex[$i - 1], 48, 48)
                $hBitmap = _Icons_Bitmap_CreateFromIcon($hIcon)
                _SetHImage($Pic + $i, $hBitmap)
                _WinAPI_DeleteObject($hBitmap)
                _WinAPI_DestroyIcon($hIcon)
            Next
            GUISetState()

            InetGet('http://dota.ru/3d/big/p324_42.jpg', $sJpg)
            $hBitmap = _Icons_Bitmap_Load($sJpg)
            $hArea = _Icons_Bitmap_Crop($hBitmap, 420, 320, 600, 400)
            _SetHImage($Pic, $hArea)
            _WinAPI_DeleteObject($hBitmap)
            _WinAPI_DeleteObject($hArea)
            FileDelete($sJpg)

            Do
            Until GUIGetMsg() = $GUI_EVENT_CLOSE

            GUIDelete()

        EndFunc   ;==>Example5

        Func Example6()

            GUICreate('Example6', 800, 500)
            $Background = GUICtrlCreatePic('', 0, 0, 800, 500)
            GUICtrlSetState(-1, $GUI_DISABLE)
            $Button = GUICtrlCreateButton('Test', 355, 460, 90, 23)
            $Pic1 = GUICtrlCreatePic('', 102, 122, 256, 256)
            $Pic2 = GUICtrlCreatePic('', 442, 122, 256, 256)
            GUISetState()

            InetGet('http://autoit.rv.ua/files/Pictures/icons_ex_back.jpg', $sJpg)
            InetGet('http://autoit.rv.ua/files/Pictures/icons_ex_green.png', $sGreen)
            InetGet('http://autoit.rv.ua/files/Pictures/icons_ex_red.png', $sRed)
            _SetImage($Background, $sJpg)
            $hGreen = _Icons_Bitmap_Load($sGreen)
            $hRed = _Icons_Bitmap_Load($sRed)
            _SetHImage($Pic1, $hRed)
            _SetHImage($Pic2, $hRed)
            FileDelete($sJpg)
            FileDelete($sGreen)
            FileDelete($sRed)

            $pCtrlID = 0

            While 1
                $Cursor = GUIGetCursorInfo()
                If @error Then
                    ContinueLoop
                EndIf
                $nCtrlID = $Cursor[4]
                If $nCtrlID <> $pCtrlID Then
                    Switch $pCtrlID
                        Case $Pic1
                            _SetHImage($Pic1, $hRed)
                        Case $Pic2
                            _SetHImage($Pic2, $hRed, -1)
                    EndSwitch
                    Switch $nCtrlID
                        Case $Pic1
                            _SetHImage($Pic1, $hGreen)
                        Case $Pic2
                            _SetHImage($Pic2, $hGreen, -1)
                    EndSwitch
                    $pCtrlID = $nCtrlID
                EndIf
                $Msg = GUIGetMsg()
                Switch $Msg
                    Case $GUI_EVENT_CLOSE
                        ExitLoop
                    Case $Button
                        GUICtrlSetState($Button, $GUI_DISABLE)
                        For $i = 1 To 50
                            GUIGetMsg()
                            _SetHImage($Pic1, $hGreen)
                            _SetHImage($Pic2, $hGreen, -1)
                            Sleep(50)
                            _SetHImage($Pic1, $hRed)
                            _SetHImage($Pic2, $hRed, -1)
                            Sleep(50)
                        Next
                        GUICtrlSetState($Button, $GUI_ENABLE)
                EndSwitch
            WEnd

            GUIDelete()

        EndFunc   ;==>Example6

        Func Example7()

            GUICreate('Example7', 400, 93)
            $Pic = GUICtrlCreatePic('', 0, 0, 400, 93)
            $hIcon = _Icons_Icon_Extract(@SystemDir & '\shell32.dll', 86, 24, 24)
            $hBitmap = _Icons_Bitmap_CreateFromIcon($hIcon)
            For $i = 1 To 5
                GUICtrlCreatePic('', 258 + ($i - 1) * 28, 12, 24, 24)
                _SetHImage($Pic + $i, $hBitmap)
            Next
            _WinAPI_DeleteObject($hBitmap)
            _WinAPI_DestroyIcon($hIcon)
            GUISetState()

            InetGet('http://www.autoitscript.com/forum/public/style_images/autoit/logo.png', $sLogo)
            $hBitmap = _Icons_Bitmap_Load($sLogo)
            $hArea = _Icons_Bitmap_Crop($hBitmap, 0, 7, 400, 93)
            _SetHImage($Pic, $hArea)
            _WinAPI_DeleteObject($hBitmap)
            _WinAPI_DeleteObject($hArea)
            FileDelete($sLogo)

            Do
            Until GUIGetMsg() = $GUI_EVENT_CLOSE

            GUIDelete()

        EndFunc   ;==>Example7

#ce

#Include-once

#Include <Constants.au3>
#Include <GDIPlus.au3>
#Include <WinAPI.au3>
#Include <WindowsConstants.au3>

#EndRegion Header

#Region Local Variables and Constants

Global Const $__SS_BITMAP = 0x0E
Global Const $__SS_ICON = 0x03

Global Const $__STM_SETIMAGE = 0x0172
Global Const $__STM_GETIMAGE = 0x0173

#EndRegion Local Variables and Constants

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Name...........: _SetCombineBkIcon
; Description....: Creates the icon from a combination of the specified two icons on solid background and sets it to use for a control.
; Syntax.........: _SetCombineBkIcon ( $hWnd, $iBackground, $sIcon1 [, $iIndex1 [, $iWidth1 [, $iHeight1 [, $sIcon2 [, $iIndex2 [, $iWidth2 [, $iHeight2 [, $iX [, $iY [, $hOverlap]]]]]]]]]] )
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

Func _SetCombineBkIcon($hWnd, $iBackground, $sIcon1, $iIndex1 = 0, $iWidth1 = -1, $iHeight1 = -1, $sIcon2 = '', $iIndex2 = 0, $iWidth2 = -1, $iHeight2 = -1, $iX = 0, $iY = 0, $hOverlap = 0)

	$hWnd = _Icons_Control_CheckHandle($hWnd)
	If $hWnd = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hParent

	If $iBackground < 0 Then
		$hParent = _WinAPI_GetParent($hWnd)
		If (BitAND(WinGetState($hParent), 2)) And (Not BitAND(WinGetState($hParent), 16)) Then
			$iBackground = _Icons_System_GetColor($hParent)
		EndIf
		If $iBackground < 0 Then
			$iBackground = _Icons_System_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE))
		EndIf
	EndIf

	_Icons_Control_CheckSize($hWnd, $iWidth1, $iHeight1)
	_Icons_Control_CheckSize($hWnd, $iWidth2, $iHeight2)

	Local $hBack = _Icons_Icon_Extract($sIcon1, $iIndex1, $iWidth1, $iHeight1)
	Local $hFront = _Icons_Icon_Extract($sIcon2, $iIndex2, $iWidth2, $iHeight2)
	Local $hIcon = _Icons_Icon_Merge($iBackground, $hBack, $hFront, $iX, $iY, $iWidth1, $iHeight1)

	If $hBack Then
		_WinAPI_DestroyIcon($hBack)
	EndIf
	If $hFront Then
		_WinAPI_DestroyIcon($hFront)
	EndIf
	If Not ($hOverlap < 0) Then
		$hOverlap = _Icons_Control_CheckHandle($hOverlap)
	EndIf
	If Not _Icons_Control_SetImage($hWnd, $hIcon, $IMAGE_ICON, $hOverlap) Then
		If $hIcon Then
			_WinAPI_DestroyIcon($hIcon)
		EndIf
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_SetCombineBkIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _SetIcon
; Description....: Sets the icon to use for a control.
; Syntax.........: _SetIcon ( $hWnd, $sIcon [, $iIndex [, $iWidth [, $iHeight [, $hOverlap]]]] )
; Parameters.....: $hWnd     - The control identifier (controlID) or handle as returned by a GUICtrlCreateIcon() function.
;                  $sIcon    - Name of the file containing the icon.
;                  $iIndex   - Index of the icon in the file.
;                  $iWidth   - Width of the icon. (-1) - determined from the system metrics for large icon.
;                  $iHeight  - Height of the icon. (-1) - determined from the system metrics for large icon.
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
; Remarks........: This function is similar to GUICtrlSetImage(), but it can work correctly with icons of arbitrary size. See example 2
;                  from this library.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _SetIcon($hWnd, $sIcon, $iIndex = 0, $iWidth = -1, $iHeight = -1, $hOverlap = 0)

	$hWnd = _Icons_Control_CheckHandle($hWnd)
	If $hWnd = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	_Icons_Control_CheckSize($hWnd, $iWidth, $iHeight)

	Local $hIcon = _Icons_Icon_Extract($sIcon, $iIndex, $iWidth, $iHeight)

	If Not ($hOverlap < 0) Then
		$hOverlap = _Icons_Control_CheckHandle($hOverlap)
	EndIf
	If Not _Icons_Control_SetImage($hWnd, $hIcon, $IMAGE_ICON, $hOverlap) Then
		If $hIcon Then
			_WinAPI_DestroyIcon($hIcon)
		EndIf
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_SetIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _SetImage
; Description....: Sets the image to use for a control.
; Syntax.........: _SetImage ( $hWnd, $sImage [, $hOverlap] )
; Parameters.....: $hWnd     - The control identifier (controlID) or handle as returned by a GUICtrlCreatePic() function.
;                  $sImage   - Name of the file containing the image.
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
; Remarks........: This function is similar to GUICtrlSetImage(), but it can work with PNG, TIFF, etc image type. If the size of
;                  image and control are different, image will be resizing (using an antialiasing) to the control. The function uses
;                  GDI+, so if you often call this function, call the _GDIPlus_Startup() at the top of your code is a good idea.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _SetImage($hWnd, $sImage, $hOverlap = 0)

	$hWnd = _Icons_Control_CheckHandle($hWnd)
	If $hWnd = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result, $hImage, $hBitmap, $hFit

	_GDIPlus_Startup()

	$hImage = _GDIPlus_BitmapCreateFromFile($sImage)
	$hFit = _Icons_Control_FitTo($hWnd, $hImage)
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hFit)

	_GDIPlus_ImageDispose($hFit)
	_GDIPlus_Shutdown()

	If Not ($hOverlap < 0) Then
		$hOverlap = _Icons_Control_CheckHandle($hOverlap)
	EndIf
	$Result = _Icons_Control_SetImage($hWnd, $hBitmap, $IMAGE_BITMAP, $hOverlap)
	If $Result Then
		$hImage = _SendMessage($hWnd, $__STM_GETIMAGE, $IMAGE_BITMAP, 0)
		If (@error) Or ($hBitmap = $hImage) Then
			$hBitmap = 0
		EndIf
	EndIf
	If $hBitmap Then
		_WinAPI_DeleteObject($hBitmap)
	EndIf
	Return SetError(1 - $Result, 0, $Result)
EndFunc   ;==>_SetImage

; #FUNCTION# ====================================================================================================================
; Name...........: _SetHIcon
; Description....: Sets the icon object (HIcon) to use for a control.
; Syntax.........: _SetHIcon ( $hWnd, $hIcon [, $hOverlap] )
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
; Remarks........: This function works like SetIcon(), but only for the icon handles. The function copies the icon in the control,
;                  and if the icon is no longer needed, it is necessary to release the resources associated with the icon by
;                  using the _WinAPI_DestroyIcon() function.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _SetHIcon($hWnd, $hIcon, $hOverlap = 0)

	$hWnd = _Icons_Control_CheckHandle($hWnd)
	If $hWnd = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	If Not ($hOverlap < 0) Then
		$hOverlap = _Icons_Control_CheckHandle($hOverlap)
	EndIf
	$hIcon = _Icons_Icon_Duplicate($hIcon)
	If Not _Icons_Control_SetImage($hWnd, $hIcon, $IMAGE_ICON, $hOverlap) Then
		If $hIcon Then
			_WinAPI_DestroyIcon($hIcon)
		EndIf
		Return SetError(1, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_SetHIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _SetHImage
; Description....: Sets the bitmap object (HBitmap) to use for a control.
; Syntax.........: _SetHImage ( $hWnd, $hBitmap [, $hOverlap] )
; Parameters.....: $hWnd     - The control identifier (controlID) or handle as returned by a GUICtrlCreatePic() function.
;                  $hBitmap  - The handle to a bitmap (HBitmap). If this value is 0, the function just release the control of the
;                              previous image.
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
; Remarks........: This function works like SetImage(), but only for the bitmap handles, and does not support resizing. If necessary,
;                  use _GDIPlus_BitmapCreateHBITMAPFromBitmap() function to craete HBitmap from image object (HImage). The function copies
;                  the bitmap in the control, and if the bitmap is no longer needed, it is necessary to release the resources
;                  associated with the bitmap by using the _WinAPI_DeleteObject() function.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _SetHImage($hWnd, $hBitmap, $hOverlap = 0)

	$hWnd = _Icons_Control_CheckHandle($hWnd)
	If $hWnd = 0 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $Result, $hImage

	If Not ($hOverlap < 0) Then
		$hOverlap = _Icons_Control_CheckHandle($hOverlap)
	EndIf
	$hBitmap = _Icons_Bitmap_Duplicate($hBitmap)
	$Result = _Icons_Control_SetImage($hWnd, $hBitmap, $IMAGE_BITMAP, $hOverlap)
	If $Result Then
		$hImage = _SendMessage($hWnd, $__STM_GETIMAGE, $IMAGE_BITMAP, 0)
		If (@error) Or ($hBitmap = $hImage) Then
			$hBitmap = 0
		EndIf
	EndIf
	If $hBitmap Then
		_WinAPI_DeleteObject($hBitmap)
	EndIf
	Return SetError(1 - $Result, 0, $Result)
EndFunc   ;==>_SetHImage

#EndRegion Public Functions

#Region Internal Functions

Func _Icons_Bitmap_Crop($hBitmap, $iX, $iY, $iWidth, $iHeight)

	If Not _Icons_Bitmap_IsHBitmap($hBitmap) Then
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
EndFunc   ;==>_Icons_Bitmap_Crop

Func _Icons_Bitmap_CreateFromIcon($hIcon)

	Local $tICONINFO = DllStructCreate($tagICONINFO)
	Local $Ret, $hBitmap

	$Ret = DllCall('user32.dll', 'int', 'GetIconInfo', 'ptr', $hIcon, 'ptr', DllStructGetPtr($tICONINFO))
	If (@error) Or ($Ret[0] = 0) Then
		Return 0
	EndIf
	$hBitmap = _Icons_Bitmap_Duplicate(DllStructGetData($tICONINFO, 5), 1)
	If Not _Icons_Bitmap_IsAlpha($hBitmap) Then
		_GDIPlus_Startup()
		_WinAPI_DeleteObject($hBitmap)
		$Ret = DllCall($ghGDIPDll, 'int', 'GdipCreateBitmapFromHICON', 'ptr', $hIcon, 'ptr*', 0)
		If (Not @error) And ($Ret[0] = 0) Then
			$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Ret[2])
			_GDIPlus_ImageDispose($Ret[2])
		Else
			$hBitmap = 0
		EndIf
		_GDIPlus_Shutdown()
	EndIf
	Return $hBitmap
EndFunc   ;==>_Icons_Bitmap_CreateFromIcon

Func _Icons_Bitmap_CreateSolidBitmap($iColor, $iWidth, $iHeight)

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
	$hBrush = _WinAPI_CreateSolidBrush(_Icons_System_SwitchColor($iColor))
	If Not _WinAPI_FillRect($hMemDC, DllStructGetPtr($tRect), $hBrush) Then
		_WinAPI_DeleteObject($hBitmap)
		$hBitmap = 0
	EndIf

	_WinAPI_DeleteObject($hBrush)
	_WinAPI_DeleteDC($hMemDC)

	Return $hBitmap
EndFunc   ;==>_Icons_Bitmap_CreateSolidBitmap

Func _Icons_Bitmap_Duplicate($hBitmap, $fDelete = 0)

	If $fDelete Then
		$fDelete = $LR_COPYDELETEORG
	EndIf

	Local $Ret = DllCall('user32.dll', 'hwnd', 'CopyImage', 'ptr', $hBitmap, 'int', 0, 'int', 0, 'int', 0, 'int', BitOR($LR_CREATEDIBSECTION, $fDelete))

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[0]
EndFunc   ;==>_Icons_Bitmap_Duplicate

Func _Icons_Bitmap_GetSize($hBitmap)

	If Not _Icons_Bitmap_IsHBitmap($hBitmap) Then
		Return 0
	EndIf

    Local $tObj = DllStructCreate('long Type;long Width;long Height;long WidthBytes;ushort Planes;ushort BitsPixel;ptr Bits')
	Local $Ret = DllCall('gdi32.dll', 'int', 'GetObject', 'int', $hBitmap, 'int', DllStructGetSize($tObj), 'ptr', DllStructGetPtr($tObj))

	If (@error) Or ($Ret[0] = 0) Then
		Return 0
	EndIf

	Local $Size[2] = [DllStructGetData($tObj, 'Width'), DllStructGetData($tObj, 'Height')]

	If ($Size[0] = 0) Or ($Size[1] = 0) Then
		Return 0
	EndIf
	Return $Size
EndFunc   ;==>_Icons_Bitmap_GetSize

Func _Icons_Bitmap_IsAlpha($hBitmap)

	Local $Ret, $Lenght, $tBits

	$Ret = DllCall('gdi32.dll', 'int', 'GetBitmapBits', 'ptr', $hBitmap, 'long', 0, 'ptr', 0)
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	$Lenght = $Ret[0] / 4
	$tBits = DllStructCreate('dword[' & $Lenght & ']')
	$Ret = DllCall('gdi32.dll', 'int', 'GetBitmapBits', 'ptr', $hBitmap, 'long', $Ret[0], 'ptr', DllStructGetPtr($tBits))
	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	For $i = 1 To $Lenght
		If BitAND(DllStructGetData($tBits, 1, $i), 0xFF000000) Then
			Return 1
		EndIf
	Next
	Return 0
EndFunc   ;==>_Icons_Bitmap_IsAlpha

Func _Icons_Bitmap_IsHBitmap($hBitmap)

	Local $Ret  = DllCall('gdi32.dll', 'dword', 'GetObjectType', 'ptr', $hBitmap)

	If (Not @error) And ($Ret[0] = 7) Then
		Return 1
	EndIf
	Return 0
EndFunc   ;==>_Icons_Bitmap_IsHBitmap

Func _Icons_Bitmap_Load($sImage)

	_GDIPlus_Startup()

	Local $hImage = _GDIPlus_ImageLoadFromFile($sImage)
	Local $hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)

	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()

	Return $hBitmap
EndFunc   ;==>_Icons_Bitmap_Load

Func _Icons_Bitmap_Resize($hBitmap, $iWidth, $iHeight, $fHalftone = 0)

	Local $Size = _Icons_Bitmap_GetSize($hBitmap)

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
	DllCall('gdi32.dll', 'int', 'SetStretchBltMode', 'hwnd', $hDestDC, 'int', $fHalftone)
	$Ret = DllCall('gdi32.dll', 'int', 'StretchBlt', 'hwnd', $hDestDC, 'int', 0, 'int', 0, 'int', $iWidth, 'int', $iHeight, 'hwnd', $hSrcDC, 'int', 0, 'int', 0, 'int', $Size[0], 'int', $Size[1], 'dword', $SRCCOPY)
	If (@error) Or ($Ret[0] = 0) Then
		_WinAPI_DeleteObject($hBmp)
		$hBmp = 0
	EndIf

	_WinAPI_DeleteDC($hDestDC)
	_WinAPI_DeleteDC($hSrcDC)

	Return $hBmp
EndFunc   ;==>_Icons_Bitmap_Resize

Func _Icons_Control_CheckHandle($hWnd)
	If Not IsHWnd($hWnd) Then
		$hWnd = GUICtrlGetHandle($hWnd)
		If $hWnd = 0 Then
			Return 0
		EndIf
	EndIf
	Return $hWnd
EndFunc   ;==>_Icons_Control_CheckHandle

Func _Icons_Control_CheckSize($hWnd, ByRef $iX, ByRef $iY)

	Local $Size = _Icons_Control_GetSize($hWnd)

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
EndFunc   ;==>_Icons_Control_CheckSize

Func _Icons_Control_Enum($hWnd, $iDirection)

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
EndFunc   ;==>_Icons_Control_Enum

Func _Icons_Control_FitTo($hWnd, $hImage)

	Local $Size = _Icons_Control_GetSize($hWnd)

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
			$Ret = DllCall($ghGDIPDll, 'int', 'GdipGetImageThumbnail', 'ptr', $hImage, 'int', $Size[0], 'int', $Size[1], 'ptr*', 0, 'ptr', 0, 'ptr', 0)
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
EndFunc   ;==>_Icons_Control_FitTo

Func _Icons_Control_GetRect($hWnd)

	Local $Pos = ControlGetPos($hWnd, '', '')

	If (@error) Or ($Pos[2] = 0) Or ($Pos[3] = 0) Then
		Return 0
	EndIf

	Local $tRect = DllStructCreate($tagRECT)

	DllStructSetData($tRect, 1, $Pos[0])
	DllStructSetData($tRect, 2, $Pos[1])
	DllStructSetData($tRect, 3, $Pos[0] + $Pos[2])
	DllStructSetData($tRect, 4, $Pos[1] + $Pos[3])

	Return $tRect
EndFunc   ;==>_Icons_Control_GetRect

Func _Icons_Control_GetSize($hWnd)

	Local $tRect = DllStructCreate($tagRECT)
	Local $Ret = DllCall('user32.dll', 'int', 'GetClientRect', 'hwnd', $hWnd, 'ptr', DllStructGetPtr($tRect))

	If (@error) Or ($Ret[0] = 0) Then
		Return 0
	EndIf

	Local $Size[2] = [DllStructGetData($tRect, 3) - DllStructGetData($tRect, 1), DllStructGetData($tRect, 4) - DllStructGetData($tRect, 2)]

	If ($Size[0] = 0) Or ($Size[1] = 0) Then
		Return 0
	EndIf
	Return $Size
EndFunc   ;==>_Icons_Control_GetSize

Func _Icons_Control_Invalidate($hWnd)

	Local $tRect = _Icons_Control_GetRect($hWnd)

	If IsDllStruct($tRect) Then
		_WinAPI_InvalidateRect(_WinAPI_GetParent($hWnd), $tRect)
	EndIf
EndFunc   ;==>_Icons_Control_Invalidate

Func _Icons_Control_SetImage($hWnd, $hImage, $iType, $hOverlap)

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
	$tRect = _Icons_Control_GetRect($hWnd)
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
		_WinAPI_MoveWindow($hWnd, DllStructGetData($tRect, 1), DllStructGetData($tRect, 2), DllStructGetData($tRect, 3) - DllStructGetData($tRect, 1), DllStructGetData($tRect, 4) - DllStructGetData($tRect, 2), 0)
	EndIf
	If $hOverlap Then
		If Not IsHWnd($hOverlap) Then
			$hOverlap = 0
		EndIf
		_Icons_Control_Update($hWnd, $hOverlap)
	Else
		_Icons_Control_Invalidate($hWnd)
	EndIf
	Return 1
EndFunc   ;==>_Icons_Control_SetImage

#cs

Func _Icons_Control_Update($hWnd)

	Local $tBack, $tFront = _Icons_Control_GetRect($hWnd)
	Local $tIntersect = DllStructCreate($tagRECT), $pIntersect = DllStructGetPtr($tIntersect)
	Local $iWnd, $Ret, $XOffset, $YOffset, $Count = 0, $Result = 0
	Local $aWnd[50] = [$hWnd]

	While 1
		$iWnd = _WinAPI_GetWindow($aWnd[$Count], $GW_HWNDPREV)
		If Not $iWnd Then
			ExitLoop
		EndIf
		$Count += 1
		If $Count = UBound($aWnd) Then
			ReDim $aWnd[$Count + 50]
		EndIf
		$aWnd[$Count] = $iWnd
	WEnd
	If ($Count > 0) And (Not IsDllStruct($tFront)) Then
		Return 1
	EndIf
	For $i = $Count To 1 Step -1
		$tBack = _Icons_Control_GetRect($aWnd[$i])
		$Ret = DllCall('user32.dll', 'int', 'IntersectRect', 'ptr', $pIntersect, 'ptr', DllStructGetPtr($tFront), 'ptr', DllStructGetPtr($tBack))
		If (Not @error) And ($Ret[0]) Then
			$Ret = DllCall('user32.dll', 'int', 'IsRectEmpty', 'ptr', $pIntersect)
			If (Not @error) And (Not $Ret[0]) Then
				$XOffset = DllStructGetData($tBack, 1)
				$YOffset = DllStructGetData($tBack, 2)
				$Ret = DllCall('user32.dll', 'int', 'OffsetRect', 'ptr', $pIntersect, 'int', -$XOffset, 'int', -$YOffset)
				If (Not @error) And ($Ret[0]) Then
					_WinAPI_InvalidateRect($aWnd[$i], $tIntersect)
					$Result += 1
				EndIf
			EndIf
		EndIf
	Next
	Return $Result
EndFunc   ;==>_Icons_Control_Update

#ce

Func _Icons_Control_Update($hWnd, $hOverlap)

	Local $tBack, $tFront = _Icons_Control_GetRect($hWnd)

	If $tFront = 0 Then
		Return
	EndIf

	Local $aNext = _Icons_Control_Enum($hWnd, 1)
	Local $aPrev = _Icons_Control_Enum($hWnd, 0)

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
				$tBack = _Icons_Control_GetRect($aWnd[$i])
				$Ret = DllCall('user32.dll', 'int', 'IntersectRect', 'ptr', $pIntersect, 'ptr', DllStructGetPtr($tFront), 'ptr', DllStructGetPtr($tBack))
				If (Not @error) And ($Ret[0]) Then
					$Ret = DllCall('user32.dll', 'int', 'IsRectEmpty', 'ptr', $pIntersect)
					If (Not @error) And (Not $Ret[0]) Then
						$XOffset = DllStructGetData($tBack, 1)
						$YOffset = DllStructGetData($tBack, 2)
						$Ret = DllCall('user32.dll', 'int', 'OffsetRect', 'ptr', $pIntersect, 'int', -$XOffset, 'int', -$YOffset)
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
EndFunc   ;==>_Icons_Control_Update

Func _Icons_Icon_Duplicate($hIcon)
	If $hIcon Then
		Return _WinAPI_CopyIcon($hIcon)
	EndIf
	Return 0
EndFunc   ;==>_Icons_Icon_Duplicate

Func _Icons_Icon_Extract($sIcon, $iIndex, $iWidth, $iHeight)

	Local $Ret = DllCall('shell32.dll', 'int', 'SHExtractIconsW', 'wstr', $sIcon, 'int', $iIndex, 'int', $iWidth, 'int', $iHeight, 'ptr*', 0, 'ptr*', 0, 'int', 1, 'int', 0)

	If (@error) Or ($Ret[0] = 0) Then
		Return SetError(1, 0, 0)
	EndIf
	Return $Ret[5]
EndFunc   ;==>_Icons_Icon_Extract

#cs

Func _Icons_Icon_CreateFromBitmap($hBitmap)

	Local $Ret, $hImage, $hIcon = 0

	_GDIPlus_Startup()
	$hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	If $hImage Then
		$Ret = DllCall($ghGDIPDll, 'int', 'GdipCreateHICONFromBitmap', 'ptr', $hImage, 'int*', 0)
		If (Not @error) And ($Ret[0] = 0) Then
			$hIcon = $Ret[2]
		EndIf
		_GDIPlus_ImageDispose($hImage)
	EndIf
	_GDIPlus_Shutdown()
	Return $hIcon
EndFunc   ;==>_Icons_Icon_CreateFromBitmap

#ce

Func _Icons_Icon_CreateFromBitmap($hBitmap)

	Local $Size = _Icons_Bitmap_GetSize($hBitmap)

	If $Size = 0 Then
		Return 0
	EndIf

	Local $tICONINFO = DllStructCreate($tagICONINFO)
	Local $hMask = _Icons_Bitmap_CreateSolidBitmap(0, $Size[0], $Size[1])
	Local $hIcon = 0

	DllStructSetData($tICONINFO, 1, 1)
	DllStructSetData($tICONINFO, 2, 0)
	DllStructSetData($tICONINFO, 3, 0)
	DllStructSetData($tICONINFO, 4, $hMask)
	DllStructSetData($tICONINFO, 5, $hBitmap)

	Local $Ret = DllCall('user32.dll', 'ptr', 'CreateIconIndirect', 'ptr', DllStructGetPtr($tICONINFO))

	If (Not @error) And ($Ret[0]) Then
		$hIcon = $Ret[0]
	EndIf
	_WinAPI_DeleteObject($hMask)
	Return $hIcon
EndFunc   ;==>_Icons_Icon_CreateFromBitmap

Func _Icons_Icon_GetSize($hIcon)

	Local $tICONINFO = DllStructCreate($tagICONINFO)
	Local $Ret = DllCall('user32.dll', 'int', 'GetIconInfo', 'ptr', $hIcon, 'ptr', DllStructGetPtr($tICONINFO))

	If (@error) Or ($Ret[0] = 0) Then
		Return 0
	EndIf

	Local $Size = _Icons_Bitmap_GetSize(DllStructGetData($tICONINFO, 5))

	_WinAPI_DeleteObject(DllStructGetData($tICONINFO, 4))
	_WinAPI_DeleteObject(DllStructGetData($tICONINFO, 5))

	If ($Size[0] = 0) Or ($Size[1] = 0) Then
		Return 0
	EndIf
	Return $Size
EndFunc   ;==>_Icons_Icon_GetSize

Func _Icons_Icon_Merge($iBackground, $hBack, $hFront, $iX, $iY, $iWidth = -1, $iHeight = -1)

	Local $Size

	If ($iWidth < 1) Or ($iHeight < 1) Then
		$Size = _Icons_Icon_GetSize($hBack)
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
	$hBitmap = _Icons_Bitmap_CreateSolidBitmap($iBackground, $iWidth, $iHeight)
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
	$hIcon = DllCall($ghGDIPDll, 'int', 'GdipCreateHICONFromBitmap', 'ptr', $hImage, 'ptr*', 0)
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
EndFunc   ;==>_Icons_Icon_Merge

Func _Icons_System_GetColor($hWnd)

	Local $Ret, $hDC = _WinAPI_GetDC($hWnd)

	If $hDC = 0 Then
		Return -1
	EndIf
	$Ret = DllCall('gdi32.dll', 'int', 'GetBkColor', 'hwnd', $hDC)
	If (@error) Or ($Ret[0] < 0) Then
		$Ret = -1
	EndIf
	_WinAPI_ReleaseDC($hWnd, $hDC)
	If $Ret < 0 Then
		Return -1
	EndIf
	Return _Icons_System_SwitchColor($Ret[0])
EndFunc   ;==>_Icons_System_GetColor

Func _Icons_System_SwitchColor($iColor)
	Return BitOR(BitAND($iColor, 0x00FF00), BitShift(BitAND($iColor, 0x0000FF), -16), BitShift(BitAND($iColor, 0xFF0000), 16))
EndFunc   ;==>_Icons_System_SwitchColor

#EndRegion Internal Functions
