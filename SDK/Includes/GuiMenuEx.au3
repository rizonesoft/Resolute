#include-once
OnAutoItExitRegister("_OnAutoItExit")

#include <WindowsConstants.au3>
#include <WinAPI.au3>


Global $sLOGFONT = "int;int;int;int;int;byte;byte;byte;byte;byte;byte;byte;byte;wchar[32]"
Global Const $sNONCLIENTMETRICS = "uint;int;int;int;int;int;" & $sLOGFONT & ";int;int;" & $sLOGFONT & ";int;int;" & $sLOGFONT & ";" & $sLOGFONT & ";" & $sLOGFONT
Global Const $sMENUITEMINFO	=	"uint;uint;uint;uint;uint;hwnd;hwnd;hwnd;long;ptr;uint;hwnd"

Global $g_hComctl32Dll				= DllOpen("comctl32.dll")
Global $hGdi32Dll					= DllOpen("gdi32.dll")
Global $hShell32Dll					= DllOpen("shell32.dll")
Global $hUser32Dll					= DllOpen("user32.dll")
Global $hMsimg32Dll					= DllOpen("msimg32.dll")

; Set default color values
Global $nMenuBkClr					= 0xFFFFFF
Global $nMenuIconBkClr				= 0xF0F0F0
Global $nMenuSelectBkClr			= __GuiCtrlMenuEx_GetBGRColor(0xCCE8FF)
Global $nMenuSelectRectClr			= __GuiCtrlMenuEx_GetBGRColor(0x99D1FF)
Global $nMenuSelectTextClr			= 0x000000
Global $nMenuTextClr				= 0x000000
Global $nMenuIconBkClr2				= $nMenuIconBkClr

; Store the menu item:
Global $arMenuItems[1][8]
$arMenuItems[0][0]					= 0
Global $nMenuItemsRedim				= 10

; Create a usable font for using in ownerdrawn menus
Global $hMenuFont					= 0
_GuiCtrlMenuEx_CreateMenu($hMenuFont)

; Create an image list for saving/drawing our menu icons
Global $hMenuImageList	= __GuiImageListEx_Create(16, 16, BitOr(0x0001, 0x0020), 0, 1)
Global $MENULASTITEM				= -1

GUIRegisterMsg($WM_DRAWITEM, "WM_DRAWITEM")
GUIRegisterMsg($WM_MEASUREITEM, "WM_MEASUREITEM")
GUIRegisterMsg($WM_SETTINGCHANGE, "WM_SETTINGCHANGE")


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_AddMenuIcon
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_AddMenuIcon($sIconFile, $nIconID)

	If IsHWnd($sIconFile) Or Number($sIconFile) > 0 Then Return __GuiImageListEx_AddIcon($hMenuImageList, $sIconFile)
	Local $stIcon	= DllStructCreate("hwnd")
	Local $nCount	= __GuiCtrlMenuEx_ExtractIconEx($sIconFile, $nIconID, 0, DllStructGetPtr($stIcon), 1)
	Local $nIndex	= -1

	If $nCount > 0 Then
		$nIndex	= __GuiImageListEx_AddIcon($hMenuImageList, DllStructGetData($stIcon, 1))
		_WinAPI_DestroyIcon(DllStructGetData($stIcon, 1))
	EndIf

	$stIcon = 0

	Return $nIndex
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_CreateMenu
; Description ...: Create a menu and set its style to OwnerDrawn
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_CreateMenu($sText, $nParentMenu = "", $sIconFile = "", $nIconID = 0)

	Local $nMenu
	If $nParentMenu = "" Then
		$nMenu	= GUICtrlCreateMenu($sText)
	Else
		$nMenu	= GUICtrlCreateMenu($sText, $nParentMenu)
	EndIf

	$nIconID = __GuiCtrlMenuEx_GetIconID($nIconID, $sIconFile)

	If $nMenu > 0 Then
		Local $nIdx = __GuiCtrlMenuEx_GetNewItemIndex()
		If $nIdx = 0 Then Return 0

		$MENULASTITEM = $nMenu

		Local $hMenu	= GUICtrlGetHandle($nParentMenu)

		$arMenuItems[$nIdx][0] = $nMenu
		$arMenuItems[$nIdx][1] = $sText
		$arMenuItems[$nIdx][2] = _GuiCtrlMenuEx_AddMenuIcon($sIconFile, $nIconID)
		$arMenuItems[$nIdx][3] = $hMenu
		$arMenuItems[$nIdx][4] = 0
		$arMenuItems[$nIdx][5] = False
		$arMenuItems[$nIdx][6] = -1
		$arMenuItems[$nIdx][7] = True

		__GuiCtrlMenuEx_SetOwnerDrawn($hMenu, $nMenu, $sText)
	EndIf

	Return $nMenu

EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_CreateMenuFont
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_CreateMenuFont(ByRef $hFont, $bBold = FALSE, $bSide = FALSE)

	Local $stNCM = DllStructCreate($sNONCLIENTMETRICS)
	DllStructSetData($stNCM, 1, DllStructGetSize($stNCM))

	If _WinAPI_SystemParametersInfo(0x0029, DllStructGetSize($stNCM), DllStructGetPtr($stNCM), 0) Then
		Local $stMenuLogFont = DllStructCreate($sLOGFONT)

		Local $i
		For $i = 1 To 14
			DllStructSetData($stMenuLogFont, $i, DllStructGetData($stNCM, $i + 38))
		Next

		If $bSide Then
			DllStructSetData($stMenuLogFont, 3, 900)
			DllStructSetData($stMenuLogFont, 4, 900)
		EndIf

		If $bBold Then DllStructSetData($stMenuLogFont, 5, 700)

		If $hFont > 0 Then _WinAPI_DeleteObject($hFont)

		$hFont = _WinAPI_CreateFontIndirect(DllStructGetPtr($stMenuLogFont))
		If $hFont = 0 Then $hFont = _GuiCtrlMenuEx_CreateMenuFontByName("MS Sans Serif")
	EndIf

EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_CreateMenuFontByName
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_CreateMenuFontByName($sFontName, $nHeight = 8, $nWidth = 400)

	Local $stFontName = DllStructCreate("char[260]")
	DllStructSetData($stFontName, 1, $sFontName)

	Local $hDC		= _WinAPI_GetDC(0) ; Get the Desktops DC
	Local $nPixel	= _WinAPI_GetDeviceCaps($hDC, 90)
	$nHeight		= 0 - _WinAPI_MulDiv($nHeight, $nPixel, 72)
	_WinAPI_ReleaseDC(0, $hDC)

	Local $hFont = _WinAPI_CreateFont($nHeight, 0, 0, 0, $nWidth, 0, 0, 0, 0, 0, 0, 0, 0, DllStructGetPtr($stFontName))

	$stFontName = 0
	Return $hFont

EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_CreateMenuItem
; Description ...: Create a menu item and set its style to OwnerDrawn.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_CreateMenuItem($sMenuItemText, $nParentMenu, $sIconFile = "", $nIconID = 0, $bRadio = 0)
	Local $nMenuItem	= GUICtrlCreateMenuItem($sMenuItemText, $nParentMenu, -1, $bRadio)

	$nIconID = __GuiCtrlMenuEx_GetIconID($nIconID, $sIconFile)

	If $nMenuItem > 0 Then
		Local $nIdx = __GuiCtrlMenuEx_GetNewItemIndex()
		If $nIdx = 0 Then Return 0

		$MENULASTITEM = $nMenuItem

		Local $hMenu = GUICtrlGetHandle($nParentMenu)

		$arMenuItems[$nIdx][0] = $nMenuItem
		$arMenuItems[$nIdx][1] = $sMenuItemText
		$arMenuItems[$nIdx][2] = _GuiCtrlMenuEx_AddMenuIcon($sIconFile, $nIconID)
		$arMenuItems[$nIdx][3] = $hMenu
		$arMenuItems[$nIdx][4] = $bRadio
		$arMenuItems[$nIdx][5] = False
		$arMenuItems[$nIdx][6] = -1
		$arMenuItems[$nIdx][7] = False

		__GuiCtrlMenuEx_SetOwnerDrawn($hMenu, $nMenuItem, $sMenuItemText)

	EndIf

	Return $nMenuItem
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_DrawText
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_DrawText($hDC, $ptrText, $nLenText, $ptrRect, $nFlags)
	Local $nHeight = DllCall($hUser32Dll, "int", "DrawTextW", "hwnd", $hDC, "ptr", $ptrText, "int", $nLenText, "ptr", $ptrRect, "int", $nFlags)
	Return $nHeight[0]
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_SetMenuBkColor
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_SetMenuBkColor($nColor)
	$nMenuBkClr	= __GuiCtrlMenuEx_GetBGRColor($nColor)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_SetMenuIconBkColor
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_SetMenuIconBkColor($nColor)
	$nMenuIconBkClr	= $nColor
	; $nMenuIconBkClr2 = $nMenuIconBkClr
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_SetMenuIconBkGrdColor
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_SetMenuIconBkGrdColor($nColor)
	$nMenuIconBkClr2 = __GuiCtrlMenuEx_GetBGRColor($nColor)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_SetMenuItemIcon
; Description ...: Set the icon of an menu item.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_SetMenuItemIcon($nMenuID, $sIconFile = "", $nIconID = 0)

	If $nMenuID = -1 Then $nMenuID = $MENULASTITEM
	If $nMenuID <= 0 Then Return 0

	$nIconID = __GuiCtrlMenuEx_GetIconID($nIconID, $sIconFile)

	Local $i

	For $i = 1 To $arMenuItems[0][0]
		If $arMenuItems[$i][0] = $nMenuID Then
			If $sIconFile = "" Then
				$arMenuItems[$i][2] = -1
			Else
				If $arMenuItems[$i][2] = -1 Then
					$arMenuItems[$i][2] = _GuiCtrlMenuEx_AddMenuIcon($sIconFile, $nIconID)
				Else
					_GuiCtrlMenuEx_ReplaceMenuIcon($sIconFile, $nIconID, $arMenuItems[$i][2])
				EndIf
			EndIf

			Return 1
		EndIf
	Next

	Return 0

EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_SetMenuItemText
; Description ...: Set the text of an menu item.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_SetMenuItemText($nMenuID, $sText)

	If $nMenuID = -1 Then $nMenuID = $MENULASTITEM
	If $nMenuID <= 0 Then Return 0

	Local $i

	For $i = 1 To $arMenuItems[0][0]
		If $arMenuItems[$i][0] = $nMenuID Then
			$arMenuItems[$i][1] = $sText
			__GuiCtrlMenuEx_SetOwnerDrawn($arMenuItems[$i][3], $nMenuID, $sText, False)
			GUICtrlSetData($nMenuID, $sText)
			__GuiCtrlMenuEx_SetOwnerDrawn($arMenuItems[$i][3], $nMenuID, $sText)
			Return 1
		EndIf
	Next

EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_SetMenuSelectBkColor
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_SetMenuSelectBkColor($nColor)
	$nMenuSelectBkClr = __GuiCtrlMenuEx_GetBGRColor($nColor)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_SetMenuSelectRectColor
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_SetMenuSelectRectColor($nColor)
	$nMenuSelectRectClr = __GuiCtrlMenuEx_GetBGRColor($nColor)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_SetMenuSelectTextColor
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_SetMenuSelectTextColor($nColor)
	$nMenuSelectTextClr	= __GuiCtrlMenuEx_GetBGRColor($nColor)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_SetMenuSelectTextColor
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; ===============================================================================================================================
Func _GuiCtrlMenuEx_SetMenuTextColor($nColor)
	$nMenuTextClr = __GuiCtrlMenuEx_GetBGRColor($nColor)
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_ExtractIconEx
; Description ...:
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_ExtractIconEx($sIconFile, $nIconID, $ptrIconLarge, $ptrIconSmall, $nIcons)
	Local $nCount = DllCall($hShell32Dll, "int", "ExtractIconExW", "wstr", $sIconFile, "int", $nIconID, _
					"ptr", $ptrIconLarge, "ptr", $ptrIconSmall, "int", $nIcons)
	Return $nCount[0]
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_FillGradientRect
; Description ...: Fill background rect with gradient colors.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_FillGradientRect($hDC, $stRect, $nClr1, $nClr2, $bVert = FALSE)
	Local $stVert = DllStructCreate("long;long;ushort;ushort;ushort;ushort;" & _
									"long;long;ushort;ushort;ushort;ushort")

	DllStructSetData($stVert, 1, DllStructGetData($stRect, 1))
	DllStructSetData($stVert, 2, DllStructGetData($stRect, 2))
	DllStructSetData($stVert, 3, BitShift(__GuiCtrlMenuEx_GetClrColor($nClr1, 3), -8))
	DllStructSetData($stVert, 4, BitShift(__GuiCtrlMenuEx_GetClrColor($nClr1, 2), -8))
	DllStructSetData($stVert, 5, BitShift(__GuiCtrlMenuEx_GetClrColor($nClr1, 1), -8))
	DllStructSetData($stVert, 6, 0)

	DllStructSetData($stVert, 7, DllStructGetData($stRect, 3))
	DllStructSetData($stVert, 8, DllStructGetData($stRect, 4))
	DllStructSetData($stVert, 9, BitShift(__GuiCtrlMenuEx_GetClrColor($nClr2, 3), -8))
	DllStructSetData($stVert, 10, BitShift(__GuiCtrlMenuEx_GetClrColor($nClr2, 2), -8))
	DllStructSetData($stVert, 11, BitShift(__GuiCtrlMenuEx_GetClrColor($nClr2, 1), -8))
	DllStructSetData($stVert, 12, 0)

	Local $stGradRect = DllStructCreate("ulong;ulong")
	DllStructSetData($stGradRect, 1, 0)
	DllStructSetData($stGradRect, 2, 1)

	If $bVert Then
		__GuiCtrlMenuEx_GradientFill($hDC, DllStructGetPtr($stVert), 2, DllStructGetPtr($stGradRect), 1, 1)
	Else
		__GuiCtrlMenuEx_GradientFill($hDC, DllStructGetPtr($stVert), 2, DllStructGetPtr($stGradRect), 1, 0)
	EndIf
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_GetBGRColor
; Description ...: Return an BGR color to a given RGB color.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_GetBGRColor($nColor)
	If $nColor <> -2 Then
		Return BitOr(BitShift(BitAnd($nColor, 0xFF), -16), BitAnd($nColor, 0xFF00), BitShift($nColor, 16))
	Else
		Return $nColor
	EndIf
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_GetClrColor
; Description ...: Get color part
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_GetClrColor($nColor, $nMode)
	Local $nClr = __GuiCtrlMenuEx_GetBGRColor($nColor)

	Switch $nMode
		Case 1
			$nClr = BitShift($nClr, 16)
		Case 2
			$nClr = BitShift(BitAnd($nClr, 0xFF00), 8)
		Case 3
			$nClr = BitAnd($nClr, 0xFF)
	EndSwitch

	Return $nClr
EndFunc


Func __GuiCtrlMenuEx_GetTextExtentPoint32($hDC, $ptrText, $nTextLength, $ptrSize)
	Local $bResult = DllCall($hGdi32Dll, "int", "GetTextExtentPoint32W", "hwnd" ,$hDC, "ptr", $ptrText, "int", $nTextLength, "ptr", $ptrSize)
	Return $bResult[0]
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_GetIconID
; Description ...: Get the icon ID like in newer Autoit versions.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_GetIconID($nID, $sFile)

	If StringRight($sFile, 4) = ".exe" Then
		If $nID < 0 Then
			$nID = - ($nID + 1)
		ElseIf $nID > 0 Then
			$nID = - $nID
		EndIf
	ElseIf StringRight($sFile, 4) = ".icl" And $nID < 0 Then
		$nID = - ($nID + 1)
	Else
		If $nID > 0 Then
			$nID = - $nID
		ElseIf $nID < 0 Then
			$nID = - ($nID + 1)
		EndIf
	EndIf

	Return $nID

EndFunc


Func __GuiCtrlMenuEx_GetMenuItemCount($hMenu)
	Local $nCount = DllCall($hUser32Dll, "int", "GetMenuItemCount", "hwnd", $hMenu)
	Return $nCount[0]
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_GetMenuIconIndex
; Description ...: Get the index of an icon from our store.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_GetMenuIconIndex($nMenuItemID, ByRef $nIconIndex, ByRef $nSelIconIndex)
	Local $i

	For $i = 1 To $arMenuItems[0][0]
		If $arMenuItems[$i][0] = $nMenuItemID Then
			$nIconIndex = $arMenuItems[$i][2]
			$nSelIconIndex = $arMenuItems[$i][6]
			ExitLoop
		EndIf
	Next
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_GetMenuHandle
; Description ...: Get the parent menu handle for a menu item.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_GetMenuHandle($nMenuItemID)
	Local $i, $hMenu = 0

	For $i = 1 To $arMenuItems[0][0]
		If $arMenuItems[$i][0] = $nMenuItemID Then
			$hMenu = $arMenuItems[$i][3]
			ExitLoop
		EndIf
	Next

	Return $hMenu
EndFunc



; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_GetMenuInfos
; Description ...: Get some system menu constants.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_GetMenuInfos(ByRef $nS, ByRef $nX)
	$nS	= _WinAPI_GetSystemMetrics(49)
	$nX	= _WinAPI_GetSystemMetrics(71)
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_GetMenuIsRadio
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func _GuiCtrlMenuEx_GetMenuIsRadio($nMenuItemID)
	Local $i, $bRadio = 0

	For $i = 1 To $arMenuItems[0][0]
		If $arMenuItems[$i][0] = $nMenuItemID Then
			$bRadio = $arMenuItems[$i][4]
			ExitLoop
		EndIf
	Next

	Return $bRadio
EndFunc


Func __GuiCtrlMenuEx_GetMenuItemID($hMenu, $nPos)
	Local $nID = DllCall($hUser32Dll, "int", "GetMenuItemID", "hwnd", $hMenu, "int", $nPos)
	Return $nID[0]
EndFunc


Func __GuiCtrlMenuEx_GetMenuItemInfo($hMenu, $nID, $bPos, $pMII)
	Local $nResult = DllCall($hUser32Dll, "int", "GetMenuItemInfo", "hwnd", $hMenu, "uint", $nID, "int", $bPos, "ptr", $pMII)
	Return $nResult[0]
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_GetMenuMaxTextWidth
; Description ...: Get the maximum text width in a menu.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_GetMenuMaxTextWidth($hDC, $hMenu, ByRef $nMaxWidth, ByRef $nMaxAccWidth)

	Local $i, $stSize, $stText, $nLen
	Local $nWidth		= 0
	Local $nAccWidth	= 0
	Local $arString

	For $i = 1 To $arMenuItems[0][0]
		If $arMenuItems[$i][3] = $hMenu Then
			$arString = StringSplit($arMenuItems[$i][1], @Tab)
			If Not IsArray($arString) Then ContinueLoop

			If $arString[0] > 1 Then
				$nLen	= StringLen($arString[2])
				$stSize	= DllStructCreate("int;int")

				$stText = DllStructCreate("wchar[" & $nLen + 1 & "]")
				DllStructSetData($stText, 1, $arString[2])

				__GuiCtrlMenuEx_GetTextExtentPoint32($hDC, DllStructGetPtr($stText), $nLen, DllStructGetPtr($stSize))

				$nAccWidth = DllStructGetData($stSize, 1)
				$stText	= 0
				$stSize	= 0

				If $nAccWidth > $nMaxAccWidth Then $nMaxAccWidth = $nAccWidth
			EndIf

			$nLen	= StringLen($arString[1])
			$stSize	= DllStructCreate("int;int")

			$stText = DllStructCreate("wchar[" & $nLen + 1 & "]")
			DllStructSetData($stText, 1, $arString[1])

			__GuiCtrlMenuEx_GetTextExtentPoint32($hDC, DllStructGetPtr($stText), $nLen, DllStructGetPtr($stSize))

			$nWidth = DllStructGetData($stSize, 1)
			$stText	= 0
			$stSize	= 0

			If $nWidth > $nMaxWidth Then $nMaxWidth = $nWidth
		EndIf
	Next

EndFunc


Func __GuiCtrlMenuEx_GetMenuState($hMenu, $nID, $nFlags)
	Local $nState = DllCall($hUser32Dll, "int", "GetMenuState", "hwnd", $hMenu, "int", $nID, "int", $nFlags)
	Return $nState[0]
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_GetMenuText
; Description ...: Get the menu item text.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_GetMenuText($nMenuItemID)
	Local $i, $sText = ""

	For $i = 1 To $arMenuItems[0][0]
		If $arMenuItems[$i][0] = $nMenuItemID Then
			$sText = $arMenuItems[$i][1]
			ExitLoop
		EndIf
	Next

	Return $sText
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_GetNewItemIndex
; Description ...: Return a free index in the item array or create a new index.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_GetNewItemIndex()

	Local $i = 0, $bFreeFound = False

	For $i = 1 To $arMenuItems[0][0]
		If $arMenuItems[$i][0] = 0 Then
			$bFreeFound = TRUE
			ExitLoop
		EndIf
	Next

	If Not $bFreeFound Then
		$arMenuItems[0][0] += 1
		Local $nSize = UBound($arMenuItems)
		If $arMenuItems[0][0] > $nSize - $nMenuItemsRedim Then _
			Redim $arMenuItems[$nSize + $nMenuItemsRedim][8]
		$i = $arMenuItems[0][0]
	EndIf

	Return $i

EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_GradientFill
; Description ...:
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_GradientFill($hDC, $pVert, $nNumVert, $pRect, $nNumRect, $nFillMode)
	Local $nResult = DllCall($hMsimg32Dll, "int", "GradientFill", "hwnd", $hDC, "ptr", $pVert, "ulong", $nNumVert, _
						"ptr", $pRect, "ulong", $nNumRect, "ulong", $nFillMode)
	Return $nResult[0]
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_MenuItemSetSelIcon
; Description ...: Set the selected icon of an menu item.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func _GuiCtrlMenuEx_MenuItemSetSelIcon($nMenuID, $sIconFile = "", $nIconID = 0)
	If $nMenuID = -1 Then $nMenuID = $MENULASTITEM
	If $nMenuID <= 0 Then Return 0

	$nIconID = __GuiCtrlMenuEx_GetIconID($nIconID, $sIconFile)

	Local $i

	For $i = 1 To $arMenuItems[0][0]
		If $arMenuItems[$i][0] = $nMenuID Then
			If $sIconFile = "" Then
				$arMenuItems[$i][6] = -1
			Else
				If $arMenuItems[$i][6] = -1 Then
					$arMenuItems[$i][6] = _GuiCtrlMenuEx_AddMenuIcon($sIconFile, $nIconID)
				Else
					_GuiCtrlMenuEx_ReplaceMenuIcon($sIconFile, $nIconID, $arMenuItems[$i][6])
				EndIf
			EndIf

			Return 1
		EndIf
	Next

	Return 0
EndFunc


; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlMenuEx_ReplaceMenuIcon
; Description ...: Replace an icon in our menu image list.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func _GuiCtrlMenuEx_ReplaceMenuIcon($sIconFile, $nIconID, $nReplaceIndex)
	If $nReplaceIndex < 0 Then Return -1
	If IsHWnd($sIconFile) Or Number($sIconFile)>0 Then Return __GuiImageListEx_ReplaceIcon($hMenuImageList, $nReplaceIndex, $sIconFile)

	Local $stIcon	= DllStructCreate("hwnd")
	Local $nCount	= __GuiCtrlMenuEx_ExtractIconEx($sIconFile, $nIconID, 0, DllStructGetPtr($stIcon), 1)

	If $nCount > 0 Then
		__GuiImageListEx_ReplaceIcon($hMenuImageList, $nReplaceIndex, DllStructGetData($stIcon, 1))
		_WinAPI_DestroyIcon(DllStructGetData($stIcon, 1))
	EndIf

	$stIcon = 0

	Return 1
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_SetItemRect
; Description ...: Sets 4 values to a itemrect struct.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_SetItemRect(ByRef $stStruct, $p1, $p2, $p3, $p4)
	DllStructSetData($stStruct, 1, $p1)
	DllStructSetData($stStruct, 2, $p2)
	DllStructSetData($stStruct, 3, $p3)
	DllStructSetData($stStruct, 4, $p4)
EndFunc


Func _GuiCtrlMenuEx_SetMenuItemInfo($hMenu, $nID, $bPos, $pMII)
	Local $nResult = DllCall($hUser32Dll, "int", "SetMenuItemInfo", "hwnd", $hMenu, "uint", $nID, "int", $bPos, "ptr", $pMII)
	Return $nResult[0]
EndFunc


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __GuiCtrlMenuEx_SetOwnerDrawn
; Description ...: Convert a normal menu item to an ownerdrawn menu item.
; Author ........: Holger Kotsch
; Modified.......: Derick Payne (Rizonesoft)
; Remarks .......:
; ===============================================================================================================================
Func __GuiCtrlMenuEx_SetOwnerDrawn($hMenu, $MenuItemID, $sText, $bOwnerDrawn = True)

	Local $nType = 0 ; MF_STRING__GuiCtrlMenuEx_GetBGRColor
	If StringLen($sText) = 0 Then $nType = 0x00000800
	If $bOwnerDrawn Then $nType = BitOr($nType, 0x00000100)

	Local $stMII = DllStructCreate($sMENUITEMINFO)
	DllStructSetData($stMII, 1, DllStructGetSize($stMII))
	DllStructSetData($stMII, 2, 0x00000010) ; MIIM_TYPE
	DllStructSetData($stMII, 3, $nType)

	Local $stTypeData = DllStructCreate("uint")
	DllStructSetData($stTypeData, 1, $MenuItemID)
	DllStructSetData($stMII, 10, DllStructGetPtr($stTypeData))

	_GuiCtrlMenuEx_SetMenuItemInfo($hMenu, $MenuItemID, False, DllStructGetPtr($stMII))

EndFunc


Func __GuiImageListEx_Create($nImageWidth, $nImageHeight, $nFlags, $nInitial, $nGrow)
	Local $hImageList = DllCall($g_hComctl32Dll, "hwnd", "ImageList_Create", "int", $nImageWidth, "int", $nImageHeight, _
						"int", $nFlags, "int", $nInitial, "int", $nGrow)
	Return $hImageList[0]
EndFunc


Func __GuiImageListEx_AddIcon($hIml, $hIcon)
	Local $nIndex = DllCall($g_hComctl32Dll, "int", "ImageList_AddIcon", "hwnd", $hIml, "hwnd", $hIcon)
	Return $nIndex[0]
EndFunc


Func __GuiImageListEx_Destroy($hIml)
	Local $bResult = DllCall($g_hComctl32Dll, "int", "ImageList_Destroy", "hwnd", $hIml)
	Return $bResult[0]
EndFunc


Func __GuiImageListEx_Draw($hIml, $nIndex, $hDC, $nX, $nY, $nStyle)
	Local $bResult = DllCall($g_hComctl32Dll, "int", "ImageList_Draw", "hwnd", $hIml, "int", $nIndex, "hwnd", $hDC, _
						"int", $nX, "int", $nY, "int", $nStyle)
	Return $bResult[0]
EndFunc


Func __GuiImageListEx_DrawEx($hIml, $nIndex, $hDC, $nX, $nY, $nDx, $nDy, $nBkClr, $nFgClr, $nStyle)
	Local $bResult = DllCall($g_hComctl32Dll, "int", "ImageList_DrawEx", "hwnd", $hIml, "int", $nIndex, "hwnd", $hDC, _
						"int", $nX, "int", $nY, "int", $nDx, "int", $nDy, "int", $nBkClr, "int", $nFgClr, "int", $nStyle)
	Return $bResult[0]
EndFunc


Func __GuiImageListEx_ReplaceIcon($hIml, $nIndex, $hIcon)
	Local $bResult = DllCall($g_hComctl32Dll, "int", "ImageList_ReplaceIcon", "hwnd", $hIml, "int", $nIndex, "hwnd", $hIcon)
	Return $bResult[0]
EndFunc


; ===============================================================================================================================
; WM_MEASURE procedure
; ===============================================================================================================================
Func WM_MEASUREITEM($hWnd, $Msg, $wParam, $lParam)
	#forceref $Msg, $wParam
	Local $nResult = False

	Local $stMeasureItem = DllStructCreate("uint;uint;uint;uint;uint;dword", $lParam)

	If DllStructGetData($stMeasureItem, 1) = 1 Then

		Local $nIconSize	= 0
		Local $nCheckX		= 0
		Local $nSpace		= 2

		__GuiCtrlMenuEx_GetMenuInfos($nIconSize, $nCheckX)

		If $nIconSize < $nCheckX Then $nIconSize = $nCheckX

		Local $nMenuItemID	= DllStructGetData($stMeasureItem, 3)
		Local $hDC			= _WinAPI_GetDC($hWnd)
		Local $hMenu		= __GuiCtrlMenuEx_GetMenuHandle($nMenuItemID)
		Local $nState		= __GuiCtrlMenuEx_GetMenuState($hMenu, $nMenuItemID, 0)
		; Reassign the current menu font to the menuitem
		Local $hMFont		= 0
		Local $bBoldFont	= False

		If BitAnd($nState, 0x00001000) And Not BitAnd($nState, 0x00000010) Then
			_GuiCtrlMenuEx_CreateMenuFont($hMFont, True)
			$bBoldFont	= True
		Else
			$hMFont = $hMenuFont
		EndIf

		Local $hFont			= _WinAPI_SelectObject($hDC, $hMFont)
		Local $sText			= __GuiCtrlMenuEx_GetMenuText($nMenuItemID)
		Local $nSideWidth		= 0
		Local $nMaxTextWidth	= 0
		Local $nMaxTextAccWidth	= 0

		__GuiCtrlMenuEx_GetMenuMaxTextWidth($hDC, $hMenu, $nMaxTextWidth, $nMaxTextAccWidth)
		If $nMaxTextAccWidth > 0 Then $nMaxTextAccWidth += 4

		Local $nHeight		= 2 * $nSpace + $nIconSize
		Local $nWidth		= 0

		; Set a default separator height
		If $sText = "" Then
			$nHeight = 4
		Else
			$nWidth	= 6 * $nSpace + 2 * $nIconSize + $nMaxTextWidth + $nMaxTextAccWidth + $nSideWidth
			; Maybe this differs - have no emulator here at the moment
			$nWidth = $nWidth - $nCheckX + 1
		EndIf

		DllStructSetData($stMeasureItem, 4, $nWidth)	; ItemWidth
		DllStructSetData($stMeasureItem, 5, $nHeight)	; ItemHeight

		_WinAPI_SelectObject($hDC, $hFont)
		If $bBoldFont Then _WinAPI_DeleteObject($hMFont)

		_WinAPI_ReleaseDC($hWnd, $hDC)
		$nResult = True
	EndIf

	$stMeasureItem	= 0
	Return $nResult
EndFunc


; ===============================================================================================================================
; WM_DRAWITEM procedure
; ===============================================================================================================================
Func WM_DRAWITEM($hWnd, $Msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $wParam
	Local $nResult		= "GUI_RUNDEFMSG"
	Local $stDrawItem	= DllStructCreate("uint;uint;uint;uint;uint;hwnd;hwnd;int[4];dword", $lParam) ; Works on x64

	If DllStructGetData($stDrawItem, 1) = 1 Then ; 1 = ODT_MENU
		$nResult = False

		Local $nMenuItemID	= DllStructGetData($stDrawItem, 3)
		Local $nAction		= DllStructGetData($stDrawItem, 4)
		Local $nState		= DllStructGetData($stDrawItem, 5)
		Local $hMenu		= DllStructGetData($stDrawItem, 6)
		Local $hDC			= DllStructGetData($stDrawItem, 7)

		Local $bChecked		= BitAnd($nState, 0x0008)
		Local $bGrayed		= BitAnd($nState, 0x0002)
		Local $bSelected	= BitAnd($nState, 0x0001)
		Local $bDefault		= BitAnd($nState, 0x0020)
		Local $bNoAcc		= BitAnd($nState, 0x0100)
		Local $bIsRadio		= _GuiCtrlMenuEx_GetMenuIsRadio($nMenuItemID)
		Local $nCtrlStyle 	= 0x0001
		Local $hSideFont	= 0
		Local $hOldObj		= 0
		Local $nSideWidth	= 0
		Local $nSideHeight	= 0
		Local $bHasSide		= False
		Local $bStretch		= False

		Local $arIR[4]
		$arIR[0]			= DllStructGetData($stDrawItem, 8, 1) + $nSideWidth
		$arIR[1]			= DllStructGetData($stDrawItem, 8, 2)
		$arIR[2]			= DllStructGetData($stDrawItem, 8, 3)
		$arIR[3]			= DllStructGetData($stDrawItem, 8, 4)

		Local $stItemRect	= DllStructCreate("int;int;int;int")
		__GuiCtrlMenuEx_SetItemRect($stItemRect, $arIR[0], $arIR[1], $arIR[2], $arIR[3])

		; Set default menu values if info function fails
		Local $nIconSize	= 16
		Local $nCheckX		= 16
		Local $nSpace		= 2

		__GuiCtrlMenuEx_GetMenuInfos($nIconSize, $nCheckX)

		Local $nMBkClr			= $nMenuBkClr
		Local $nMIconBkClr		= $nMenuIconBkClr
		Local $nMIconBkClr2		= $nMenuIconBkClr2
		Local $nMSelectBkClr	= $nMenuSelectBkClr
		Local $nMSelectRectClr	= $nMenuSelectRectClr
		Local $nMSelectTextClr	= $nMenuSelectTextClr
		Local $nMTextClr		= $nMenuTextClr

		; Select our at beginning selfcreated menu font into the item device context
		Local $hMFont		= 0
		Local $bBoldFont	= False

		If $bDefault Then
			_GuiCtrlMenuEx_CreateMenuFont($hMFont, True)
			$bBoldFont = True
		Else
			$hMFont = $hMenuFont
		EndIf

		Local $hBrush		= 0
		Local $hOldBrush	= 0
		Local $nClrSel		= 0
		Local $hBorderBrush	= 0
		Local $nLen			= 0

		; Show side menu only if action = ODA_DRAWENTIRE
		If $nAction = 1 Then
			Local $nCount = __GuiCtrlMenuEx_GetMenuItemCount($hMenu)
			Local $nID = __GuiCtrlMenuEx_GetMenuItemID($hMenu, $nCount - 1)

			If $nID = -1 Then
				Local $stMII = DllStructCreate($sMENUITEMINFO)
				DllStructSetData($stMII, 1, DllStructGetSize($stMII))
				DllStructSetData($stMII, 2, 0x00000002) ; MIIM_ID
				If __GuiCtrlMenuEx_GetMenuItemInfo($hMenu, $nCount - 1, True, DllStructGetPtr($stMII)) Then _
					$nID = DllStructGetData($stMII, 5)
			EndIf

		EndIf

		If $hSideFont <> 0 Then _WinAPI_DeleteObject($hSideFont)
		Local $hFont = _WinAPI_SelectObject($hDC, $hMFont)

		; Only show a menu bar when the item is enabled
		If $bSelected Then
			$hBorderBrush	= _WinAPI_CreateSolidBrush($nMSelectRectClr)
			$hBrush			= _WinAPI_CreateSolidBrush($nMSelectBkClr) ; BGR color value
			$nClrSel		= $nMSelectBkClr
		Else
			$hBrush			= _WinAPI_CreateSolidBrush($nMBkClr)
			$nClrSel		= $nMBkClr
		EndIf

		Local $nClrTxt 		= 0

		If $bSelected And Not $bGrayed Then
			$nClrTxt = _WinAPI_SetTextColor($hDC, $nMSelectTextClr)
		ElseIf $bGrayed Then
			$nClrTxt = _WinAPI_SetTextColor($hDC, _WinAPI_GetSysColor(17))
		Else
			$nClrTxt = _WinAPI_SetTextColor($hDC, $nMTextClr)
		EndIf

		Local $nClrBk = _WinAPI_SetBkColor($hDC, $nClrSel)
		$hOldBrush = _WinAPI_SelectObject($hDC, $hBrush)

		_WinAPI_FillRect($hDC, DllStructGetPtr($stItemRect), $hBrush)
		_WinAPI_SelectObject($hDC, $hOldBrush)
		_WinAPI_DeleteObject($hBrush)

		If Not $bSelected Or $bGrayed Then
			; Reassign the item rect
			__GuiCtrlMenuEx_SetItemRect($stItemRect, $arIR[0], $arIR[1], $arIR[0] + 2 * $nSpace + $nIconSize + 1, $arIR[3])

			If $nMIconBkClr = $nMIconBkClr2  Or $nMIconBkClr2 = -1 Then
				$hBrush		= _WinAPI_CreateSolidBrush($nMIconBkClr)
				$hOldBrush	= _WinAPI_SelectObject($hDC, $hBrush)
				_WinAPI_FillRect($hDC, DllStructGetPtr($stItemRect), $hBrush)
				_WinAPI_SelectObject($hDC, $hOldBrush)
				_WinAPI_DeleteObject($hBrush)
			Else
				__GuiCtrlMenuEx_FillGradientRect($hDC, $stItemRect, $nMIconBkClr, $nMIconBkClr2)
			EndIf
		EndIf

		If $bChecked Then
			__GuiCtrlMenuEx_SetItemRect($stItemRect, $arIR[0] + 1, $arIR[1] + 1, $arIR[0] + $nIconSize + $nSpace + 1, $arIR[1] + $nIconSize + $nSpace + 1)

			If $bSelected Then
				$hBrush		= _WinAPI_CreateSolidBrush($nMSelectBkClr)
			Else
				$hBrush		= _WinAPI_CreateSolidBrush($nMBkClr)
			EndIf

			$hOldBrush	= _WinAPI_SelectObject($hDC, $hBrush)
			_WinAPI_FillRect($hDC, DllStructGetPtr($stItemRect), $hBrush)
			_WinAPI_SelectObject($hDC, $hOldBrush)
			_WinAPI_DeleteObject($hBrush)

			; Create a checkmark/bullet for the checked/radio items
			Local $hDCBitmap	= _WinAPI_CreateCompatibleDC($hDC)
			Local $hbmpCheck	= _WinAPI_CreateBitmap($nIconSize, $nIconSize, 1, 1, 0)
			Local $hbmpOld		= _WinAPI_SelectObject($hDCBitmap, $hbmpCheck)
			Local $x 			= DllStructGetData($stItemRect, 1) + ($nIconSize + $nSpace - $nCheckX) / 2
			Local $y 			= DllStructGetData($stItemRect, 2) + ($nIconSize + $nSpace - $nCheckX) / 2 - $nSpace

			__GuiCtrlMenuEx_SetItemRect($stItemRect, 0, 0, $nIconSize, $nIconSize)
			If $bIsRadio Then $nCtrlStyle = 0x0002

			_WinAPI_DrawFrameControl($hDCBitmap, DllStructGetPtr($stItemRect), 2, $nCtrlStyle)
			_WinAPI_BitBlt($hDC, $x, $y + 1, $nCheckX, $nCheckX, $hDCBitmap, 0, 0, 0x00CC0020)
			__GuiCtrlMenuEx_SetItemRect($stItemRect, $arIR[0] + 1, $arIR[1] + 1, $arIR[0] + $nIconSize + $nSpace + 1, $arIR[1] + $nIconSize + $nSpace + 1)
			$hBrush	= _WinAPI_CreateSolidBrush($nMSelectRectClr)
			$hOldBrush	= _WinAPI_SelectObject($hDC, $hBrush)
			_WinAPI_FrameRect($hDC, DllStructGetPtr($stItemRect), $hBrush)
			_WinAPI_SelectObject($hDC, $hOldBrush)
			_WinAPI_DeleteObject($hBrush)
			_WinAPI_SelectObject($hDCBitmap, $hbmpOld)
			_WinAPI_DeleteObject($hbmpCheck)
			_WinAPI_DeleteDC($hDCBitmap)
		EndIf

		; Reassign the item rect
		__GuiCtrlMenuEx_SetItemRect($stItemRect, $arIR[0], $arIR[1], $arIR[2], $arIR[3])

		If $bSelected Then ; Show also a rect around a disabled item
			$hOldBrush	= _WinAPI_SelectObject($hDC, $hBorderBrush)
			_WinAPI_FrameRect($hDC, DllStructGetPtr($stItemRect), $hBorderBrush)
			_WinAPI_SelectObject($hDC, $hOldBrush)
			_WinAPI_DeleteObject($hBorderBrush)
		EndIf

		Local $sText	= __GuiCtrlMenuEx_GetMenuText($nMenuItemID)
		If $bNoAcc Then $sText = StringReplace($sText, "&", "")

		Local $nWidth	= 0
		Local $sAcc		= ""
		Local $arText	= StringSplit($sText, @Tab)
		Local $bTab		= FALSE

		If IsArray($arText) And $arText[0] > 1 Then
			$sText	= $arText[1]
			$sAcc	= $arText[2]
			$bTab	= TRUE
		EndIf

		$nLen			= StringLen($sText)
		Local $stText	= DllStructCreate("wchar[" & $nLen + 1 & "]")
		DllStructSetData($stText, 1, $sText)

		Local $nSaveLeft = DllStructGetData($stItemRect, 1)
		Local $nLeft = $nSaveLeft
		$nLeft += $nSpace		; Left border
		$nLeft += $nSpace		; Space after gray border
		$nLeft += $nIconSize	; Icon width
		$nLeft += $nSpace + 2	; Right after the icon

		DllStructSetData($stItemRect, 1, $nLeft)
		Local $nFlags = BitOr(0x00000100, 0x00000020, 0x00000004)
		_GuiCtrlMenuEx_DrawText($hDC, DllStructGetPtr($stText), $nLen, DllStructGetPtr($stItemRect), $nFlags)

		; Draw accelerator text
		If $bTab Then

			Local $nMaxTextWidth	= 0
			Local $nMaxTextAccWidth	= 0

			__GuiCtrlMenuEx_GetMenuMaxTextWidth($hDC, $hMenu, $nMaxTextWidth, $nMaxTextAccWidth)
			If $nMaxTextAccWidth > 0 Then $nMaxTextAccWidth += 4
			$nWidth	= 6 * $nSpace + 2 * $nIconSize + $nMaxTextWidth ; Maybe this differs - have no emulator here at the moment
			$nWidth = $nWidth - $nCheckX + 1
			$nLen = StringLen($sAcc)
			$stText = DllStructCreate("wchar[" & $nLen + 1 & "]")
			DllStructSetData($stText, 1, $sAcc)
			__GuiCtrlMenuEx_SetItemRect($stItemRect, $arIR[0] + $nWidth, $arIR[1], $arIR[0] + $nWidth + $nMaxTextAccWidth, $arIR[3]) ; Set rect for acc text
			_GuiCtrlMenuEx_DrawText($hDC, DllStructGetPtr($stText), $nLen, DllStructGetPtr($stItemRect), $nFlags)
			__GuiCtrlMenuEx_SetItemRect($stItemRect, $arIR[0], $arIR[1], $arIR[2], $arIR[3]) ; Reset rect values

		EndIf

		Local $nNoSelIconIndex = -1
		Local $nSelIconIndex = -1

		__GuiCtrlMenuEx_GetMenuIconIndex($nMenuItemID, $nNoSelIconIndex, $nSelIconIndex)

		Local $nIconIndex = $nNoSelIconIndex
		If $bSelected And $nSelIconIndex > -1 Then $nIconIndex = $nSelIconIndex

		If $nIconIndex > -1 Then
			If Not $bChecked Then
				If $bGrayed Then
					; An easy way to draw something that looks deactivated
					__GuiImageListEx_DrawEx($hMenuImageList, $nIconIndex, $hDC, $nSpace + $nSideWidth, DllStructGetData($stItemRect, 2) + 2, 0, 0, 0xFFFFFFFF, 0xFFFFFFFF, BitOr(0x0004, 0x0001))
				Else
					; Draw the icon "normal"
					__GuiImageListEx_Draw($hMenuImageList, $nIconIndex, $hDC, $nSpace + $nSideWidth, DllStructGetData($stItemRect, 2) + 2, 0x0001)
				EndIf
			EndIf
		EndIf

		DllStructSetData($stItemRect, 1, $nSaveLeft)

		; Draw a "line" for a separator item
		If StringLen($sText) = 0 Then
			DllStructSetData($stItemRect, 1, DllStructGetData($stItemRect, 1) + 4 * $nSpace + $nIconSize)
			DllStructSetData($stItemRect, 2, DllStructGetData($stItemRect, 2) + 1)
			DllStructSetData($stItemRect, 4, DllStructGetData($stItemRect, 1) + 2)
			_WinAPI_DrawEdge($hDC, DllStructGetPtr($stItemRect), 0x0006, 0x0002)
		EndIf

		$stText		= 0
		$stItemRect	= 0
		_WinAPI_SelectObject($hDC, $hFont)
		If $bBoldFont Then _WinAPI_DeleteObject($hMFont)
		_WinAPI_SetTextColor($hDC, $nClrTxt)
		_WinAPI_SetBkColor($hDC, $nClrBk)

		$nResult = True

	EndIf

	$stDrawItem	= 0
	Return $nResult

EndFunc


; ===============================================================================================================================
; WM_SETTINGCHANGE procedure
; ===============================================================================================================================
Func WM_SETTINGCHANGE($hWnd, $Msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $lParam
	If $wParam = 0x002A Then _GuiCtrlMenuEx_CreateMenuFont($hMenuFont)
EndFunc


Func _OnAutoItExit()

	__GuiImageListEx_Destroy($hMenuImageList)
	_WinAPI_DeleteObject($hMenuFont)

	DllClose($g_hComctl32Dll)
	DllClose($hGdi32Dll)
	DllClose($hShell32Dll)
	DllClose($hUser32Dll)
	DllClose($hMsimg32Dll)

	$arMenuItems	= 0

EndFunc