; ===============================================================================================================================
; GUICtrlMenuEx UDF
; Purpose: Icon Support For Standard GuiMenu UDF
; Author:  Ward
; ===============================================================================================================================

#Include-once
#Include <WindowsConstants.au3>
#Include <GUIConstants.au3>
#Include <GuiMenu.au3>

; ===============================================================================================================================
; Functions List:
; _GUICtrlMenuEx_Startup($UseCallBack = Default)
; _GUICtrlMenuEx_SetItemIcon($Menu, $Item, $Icon, $ByPos = True)
; _GUICtrlMenuEx_AddMenuItem($Menu, $Text, $CmdID = 0, $Icon = 0, $SubMenu = 0)
; _GUICtrlMenuEx_InsertMenuItem($Menu, $Index, $Text, $CmdID = 0, $Icon = 0, $SubMenu = 0)
; _GUICtrlMenuEx_AddMenuBar($Menu)
; _GUICtrlMenuEx_InsertMenuBar($Menu, $Index)
; _GUICtrlMenuEx_DeleteMenu($Menu, $Item, $ByPos = True)
; _GUICtrlMenuEx_DestroyMenu($Menu)
; ===============================================================================================================================

Global $__g_GUICtrlMenuEx_UseCallback

Func _GUICtrlMenuEx_Startup($UseCallback = Default)
	If IsKeyword($UseCallback) Then
		If __GUICtrlMenuEx_VistaAndLater() Then
			$UseCallback = False
		Else
			$UseCallback = True
		EndIf
	EndIf

	If $UseCallback Then
		GUIRegisterMsg($WM_DRAWITEM, "__GUICtrlMenuEx_WM_DRAWITEM")
		GUIRegisterMsg($WM_MEASUREITEM, "__GUICtrlMenuEx_WM_MEASUREITEM")
	Else
		GUIRegisterMsg($WM_DRAWITEM, "")
		GUIRegisterMsg($WM_MEASUREITEM, "")
	EndIf
	$__g_GUICtrlMenuEx_UseCallback = $UseCallback
EndFunc

Func _GUICtrlMenuEx_SetItemIcon($Menu, $Item, $Icon, $ByPos = True)
	If $Icon Then
		If $__g_GUICtrlMenuEx_UseCallback Then
			$Icon = _WinAPI_CopyIcon($Icon)
			Local $MENUITEMINFO = _GUICtrlMenu_GetItemInfo($Menu, $Item, $ByPos)
			DllStructSetData($MENUITEMINFO, "Mask", $MIIM_BITMAP)
			DllStructSetData($MENUITEMINFO, "BmpItem", -1) ; HBMMENU_CALLBACK
			_GUICtrlMenu_SetItemInfo($Menu, $Item, $MENUITEMINFO, $ByPos)
			_GUICtrlMenu_SetItemData($Menu, $Item, $Icon)
		Else
			Local $Bitmap = __GUICtrlMenuEx_CreateBitmapFromIcon($Icon)
			_GUICtrlMenu_SetItemBmp($Menu, $Item, $Bitmap, $ByPos)
		EndIf
		Return True
	EndIf
	Return False
EndFunc

Func _GUICtrlMenuEx_AddMenuItem($Menu, $Text, $CmdID = 0, $Icon = 0, $SubMenu = 0)
	Local $Index = _GUICtrlMenu_AddMenuItem($Menu, $Text, $CmdID, $SubMenu)
	_GUICtrlMenuEx_SetItemIcon($Menu, $Index, $Icon)
	Return $Index
EndFunc

Func _GUICtrlMenuEx_InsertMenuItem($Menu, $Index, $Text, $CmdID = 0, $Icon = 0, $SubMenu = 0)
	If _GUICtrlMenu_InsertMenuItem($Menu, $Index, $Text, $CmdID, $SubMenu) Then
		If _GUICtrlMenuEx_SetItemIcon($Menu, $Index, $Icon) Then Return True
	EndIf
	Return False
EndFunc

Func _GUICtrlMenuEx_AddMenuBar($Menu)
	Local $Item = _GUICtrlMenu_AddMenuItem($Menu, "")
	_GUICtrlMenu_SetItemType($Menu, $Item, $MFT_SEPARATOR)
EndFunc

Func _GUICtrlMenuEx_InsertMenuBar($Menu, $Index)
	If _GUICtrlMenu_InsertMenuItem($Menu, $Index, "") Then
		_GUICtrlMenu_SetItemType($Menu, $Index, $MFT_SEPARATOR)
		Return True
	EndIf
	Return False
EndFunc

Func _GUICtrlMenuEx_DeleteMenu($Menu, $Item, $ByPos = True)
	If $__g_GUICtrlMenuEx_UseCallback Then
		Local $Icon = _GUICtrlMenu_GetItemData($Menu, $Item, $ByPos)
		_WinAPI_DestroyIcon($Icon)
	Else
		Local $Bitmap = _GUICtrlMenu_GetItemBmp($Menu, $Item, $ByPos)
		_WinAPI_DeleteObject($Bitmap)
	EndIf
	Return _GUICtrlMenu_DeleteMenu($Menu, $Item, $ByPos)
EndFunc

Func _GUICtrlMenuEx_DestroyMenu($Menu)
	Local $Count = _GUICtrlMenu_GetItemCount($Menu)
	For $i = 1 To $Count
		_GUICtrlMenuEx_DeleteMenu($Menu, 0)
	Next
	Return _GUICtrlMenu_DestroyMenu($Menu)
EndFunc


Func _GUICtrlMenuEx_SetItemData($Menu)

EndFunc


Func __GUICtrlMenuEx_WM_MEASUREITEM($hWnd, $Msg, $wParam, $lParam)
	If $__g_GUICtrlMenuEx_UseCallback Then
		Local $MeasureItem = DllStructCreate('UINT CtlType;UINT CtlID;UINT itemID;UINT itemWidth;UINT itemHeight;ULONG_PTR itemData', $lParam)
		If DllStructGetData($MeasureItem, "CtlType") = 1 Then ; ODT_MENU = 1
			Local $Icon =  DllStructGetData($MeasureItem, "itemData")
			If $Icon Then
				Local $Size = __GUICtrlMenuEx_GetIconSize($Icon)
				DllStructSetData($MeasureItem, "itemWidth", $Size[0])
				DllStructSetData($MeasureItem, "itemHeight", $Size[1])
				Return TRUE
			EndIf
		EndIf
	EndIf
	Return 0
EndFunc

Func __GUICtrlMenuEx_WM_DRAWITEM($hWnd, $Msg, $wParam, $lParam)
	If $__g_GUICtrlMenuEx_UseCallback Then
		Local $DrawItem = DllStructCreate('UINT CtlType;UINT CtlID;UINT itemID;UINT itemAction;UINT itemState;HWND hwndItem;HWND hDC;INT rcItem[4];ULONG_PTR itemData', $lParam)
		If DllStructGetData($DrawItem, "CtlType") = 1 Then ; ODT_MENU = 1
			Local $Icon =  DllStructGetData($DrawItem, "itemData")
			If $Icon Then
				Local $hDC = DllStructGetData($DrawItem, "hDC")
				Local $Left = DllStructGetData($DrawItem, "rcItem", 1)
				Local $Top = DllStructGetData($DrawItem, "rcItem", 2)
				_WinAPI_DrawIconEx($hDC, $Left / 2, $Top, $Icon, 0, 0, 0, 0, 3)
			EndIf
			Return TRUE
		EndIf
	EndIf
	Return 0
EndFunc

Func __GUICtrlMenuEx_GetIconSize($Icon)
	Local Const $tagBITMAP = "LONG bmType;LONG bmWidth;LONG bmHeight;LONG bmWidthBytes;WORD bmPlanes;WORD bmBitsPixel;ptr bmBits"
	Local $IconInfo = _WinAPI_GetIconInfo($Icon)

	Local $BITMAP = DllStructCreate($tagBITMAP)
	_WinAPI_GetObject($IconInfo[5], DllStructGetSize($BITMAP), DllStructGetPtr($BITMAP))

	Local $Width = DllStructGetData($BITMAP, "bmWidth")
	Local $Height = DllStructGetData($BITMAP, "bmHeight")

	_WinAPI_DeleteObject($IconInfo[4])
	_WinAPI_DeleteObject($IconInfo[5])

	Local $Ret[2] = [$Width, $Height]
	Return $Ret
EndFunc

Func __GUICtrlMenuEx_CreateBitmapFromIcon($Icon)
	Switch @OSVersion
	Case "WIN_2008R2", "WIN_7", "WIN_2008", "WIN_VISTA"
		Return __GUICtrlMenuEx_CreateBitmapFromIcon_Vista($Icon)

	Case Else
		Return __GUICtrlMenuEx_CreateBitmapFromIcon_XP($Icon)
	EndSwitch
EndFunc

Func __GUICtrlMenuEx_CreateBitmapFromIcon_XP($Icon)
	Local $Size = __GUICtrlMenuEx_GetIconSize($Icon)
	Local $DC = _WinAPI_GetDC(0)
	Local $DestDC = _WinAPI_CreateCompatibleDC($DC)
	Local $Bitmap = _WinAPI_CreateSolidBitmap(0, _WinAPI_GetSysColor($COLOR_MENU), $Size[0], $Size[1])
	Local $OldBitmap = _WinAPI_SelectObject($DestDC, $Bitmap)
	If $OldBitmap > 0 Then
		_WinAPI_DrawIconEx($DestDC, 0, 0, $Icon, 0, 0, 0, 0, 3) ; DI_NORMAL = 3
		_WinAPI_SelectObject($DestDC, $OldBitmap)
	EndIf
	_WinAPI_ReleaseDC(0, $DC)
	_WinAPI_DeleteDC($DestDC)
	Return $Bitmap
EndFunc

Func __GUICtrlMenuEx_CreateBitmapFromIcon_Vista($Icon)
	Local $Size = __GUICtrlMenuEx_GetIconSize($Icon)
    Local $DestDC = _WinAPI_CreateCompatibleDC(0)
	Local $Bitmap = __GUICtrlMenuEx_Create32BitHBITMAP($DestDC, $Size)
	Local $OldBitmap = _WinAPI_SelectObject($DestDC, $Bitmap)
    If $OldBitmap > 0 Then
		Local $BlendFunction = DllStructCreate("BYTE BlendOp; BYTE BlendFlags; BYTE SourceConstantAlpha; BYTE AlphaFormat")
		DllStructSetData($BlendFunction, 1, 0) ; AC_SRC_OVER
		DllStructSetData($BlendFunction, 2, 0)
		DllStructSetData($BlendFunction, 3, 255)
		DllStructSetData($BlendFunction, 4, 1) ; AC_SRC_ALPHA = 1

		Local $PaintParams = DllStructCreate("DWORD Size; DWORD Flags; ptr Exclude; ptr BlendFunction")
		DllStructSetData($PaintParams, "Size", DllStructGetSize($PaintParams))
		DllStructSetData($PaintParams, "Flags", 1) ; BPPF_ERASE = 1
		DllStructSetData($PaintParams, "BlendFunction", DllStructGetPtr($BlendFunction))

		Local $Rect = DllStructCreate($tagRECT)
		DllStructSetData($Rect, "Right", $Size[0])
		DllStructSetData($Rect, "Bottom", $Size[1])

		Local $PaintBuffer = __GUICtrlMenuEx_BeginBufferedPaint($DestDC, DllStructGetPtr($Rect), 1, DllStructGetPtr($PaintParams)) ; BPBF_DIB
		If Not @Error And $PaintBuffer[0] Then
			If _WinAPI_DrawIconEx($PaintBuffer[1], 0, 0, $Icon, 0, 0, 0, 0, 3) Then ; DI_NORMAL = 3
				__GUICtrlMenuEx_ConvertBufferToPARGB32($PaintBuffer[0], $DestDC, $Icon, $Size)
			EndIf
			__GUICtrlMenuEx_EndBufferedPaint($PaintBuffer[0], True)
		EndIf
		_WinAPI_SelectObject($DestDC, $OldBitmap)
    EndIf
    _WinAPI_DeleteDC($DestDC)
    Return $Bitmap
EndFunc

Func __GUICtrlMenuEx_ConvertBufferToPARGB32($BufferedPaint, $hDC, $Icon, $Size)
	Local $Row
	Local $ARGBPtr = __GUICtrlMenuEx_GetBufferedPaintBits($BufferedPaint, $Row)
	If $ARGBPtr Then
		Local $ARGB = DllStructCreate("dword[" & ($Size[0] * $Size[1]) & "]", $ARGBPtr)
		If Not __GUICtrlMenuEx_HasAlpha($ARGB, $Size, $Row) Then
			Local $IconInfo = _WinAPI_GetIconInfo($Icon)
			If $IconInfo[4] Then
				__GUICtrlMenuEx_ConvertToPARGB32($hDC, $ARGB, $IconInfo[4], $Size, $Row)
			EndIf
			_WinAPI_DeleteObject($IconInfo[4])
			_WinAPI_DeleteObject($IconInfo[5])
		EndIf
	EndIf
EndFunc

Func __GUICtrlMenuEx_HasAlpha($ARGB, $Size, $Row)
	Local $Delta = $Row - $Size[0]
	Local $Pos = 1

	For $Y = $Size[1] To 1 Step -1
		For $X = $Size[0] To 1 Step -1
			If BitAND(DllStructGetData($ARGB, 1, $Pos), 0xFF000000) Then
				Return True
			EndIf
			$Pos += 1
		Next
		$Pos += $Delta
	Next
	Return False
EndFunc

Func __GUICtrlMenuEx_ConvertToPARGB32($hDC, ByRef $ARGB, $hBmp, $Size, $Row)
	Local $BITMAPINFO = DllStructCreate($tagBITMAPINFO)
	DllStructSetData($BITMAPINFO, "Size", DllStructGetSize($BITMAPINFO))
	DllStructSetData($BITMAPINFO, "Planes", 1)
	DllStructSetData($BITMAPINFO, "Compression", 0) ; BI_RGB = 0
	DllStructSetData($BITMAPINFO, "Width", $Size[0])
	DllStructSetData($BITMAPINFO, "Height", $Size[1])
	DllStructSetData($BITMAPINFO, "BitCount", 32)

	Local $ARGBMask = DllStructCreate("dword[" & ($Size[0] * $Size[1]) & "]")
	If _WinAPI_GetDIBits($hDC, $hBmp, 0, $Size[1], DllStructGetPtr($ARGBMask), DllStructGetPtr($BITMAPINFO), 0) = $Size[1] Then
		Local $Delta = $Row - $Size[0]
		Local $Pos = 1

		For $Y = $Size[1] To 1 Step -1
			For $X = $Size[0] To 1 Step -1
				If DllStructGetData($ARGBMask, 1, $Pos) Then
					DllStructSetData($ARGB, 1, 0, $Pos)
				Else
					DllStructSetData($ARGB, 1, BitOR(DllStructGetData($ARGB, 1, $Pos), 0xFF000000), $Pos)
				EndIf
				$Pos += 1
			Next
		Next
	EndIf
EndFunc

Func __GUICtrlMenuEx_Create32BitHBITMAP($hDC, $Size, $Bits = 0)
	Local $BITMAPINFO = DllStructCreate($tagBITMAPINFO)
	DllStructSetData($BITMAPINFO, "Size", DllStructGetSize($BITMAPINFO))
	DllStructSetData($BITMAPINFO, "Planes", 1)
	DllStructSetData($BITMAPINFO, "Compression", 0) ; BI_RGB = 0
	DllStructSetData($BITMAPINFO, "Width", $Size[0])
	DllStructSetData($BITMAPINFO, "Height", $Size[1])
	DllStructSetData($BITMAPINFO, "BitCount", 32)
	Return __GUICtrlMenuEx_CreateDIBSection($hDC, DllStructGetPtr($BITMAPINFO), 0, $Bits, 0, 0)
EndFunc

Func __GUICtrlMenuEx_CreateDIBSection($hDC, $BMI, $Usage, $Bits, $Section, $Offset)
	Local $Ret = DllCall("gdi32.dll", "hwnd", "CreateDIBSection", "hwnd", $hDC, "ptr", $BMI, "uint", $Usage, "ptr*", $Bits, "hwnd", $Section, "dword", $Offset)
	If Not @Error Then
		Return $Ret[0]
	EndIf
	Return SetError(1, 0, 0)
EndFunc

Func __GUICtrlMenuEx_BeginBufferedPaint($DCTarget, $RectTarget, $Format, $PaintParams)
	Local $Ret = DllCall("UxTheme.dll", "hwnd", "BeginBufferedPaint", "hwnd", $DCTarget, "ptr", $RectTarget, "dword", $Format, "ptr", $PaintParams, "hwnd*", 0)
	If Not @Error Then
		Local $Array[2] = [$Ret[0], $Ret[5]]
		Return $Array
	EndIf
	Return SetError(1, 0, 0)
EndFunc

Func __GUICtrlMenuEx_EndBufferedPaint($BufferedPaint, $UpdateTarget = True)
	Local $Ret = DllCall("UxTheme.dll", "hwnd", "EndBufferedPaint", "hwnd", $BufferedPaint, "int", $UpdateTarget)
	If Not @Error Then
		Return $Ret[0]
	EndIf
	Return SetError(1, 0, 0)
EndFunc

Func __GUICtrlMenuEx_GetBufferedPaintBits($BufferedPaint, ByRef $Row)
	Local $Ret = DllCall("UxTheme.dll", "int", "GetBufferedPaintBits", "hwnd", $BufferedPaint, "ptr*", 0, "int*", 0)
	If Not @Error Then
		$Row = $Ret[3]
		Return $Ret[2]
	EndIf
	Return SetError(1, 0, 0)
EndFunc

Func __GUICtrlMenuEx_VistaAndLater() ; Modify from Mat's code
	Local $OSVI = DllStructCreate("DWORD OSVersionInfoSize; DWORD MajorVersion; DWORD MinorVersion; DWORD BuildNumber; DWORD PlatformId; wchar CSDVersion[128]")
	DllStructSetData($OSVI, "OSVersionInfoSize", DllStructGetSize($OSVI))
	DllCall("kernel32.dll", "bool", "GetVersionExW", "ptr", DllStructGetPtr($OSVI))
	Return DllStructGetData($OSVI, "MajorVersion") >= 6
EndFunc
