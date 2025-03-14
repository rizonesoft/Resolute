#include-once

#include "GuiCtrlInternals.au3"
#include "HeaderConstants.au3"
#include "Memory.au3"
#include "SendMessage.au3"
#include "StructureConstants.au3"
#include "UDFGlobalID.au3"
#include "WinAPIConv.au3"
#include "WinAPIHObj.au3"
#include "WinAPISysInternals.au3"

; #INDEX# =======================================================================================================================
; Title .........: Header
; AutoIt Version : 3.3.16.1
; Description ...: Functions that assist with Header control management.
;                  A header control is a window that is usually positioned above columns of text or numbers.  It contains a title
;                  for each column, and it can be divided into parts.
; Author(s) .....: Paul Campbell (PaulIA)
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================

; Optimization by pixelsearch DllStructCreate() once
Global $__g_tHeaderBuffer, $__g_tHeaderBufferANSI ; = DllStructCreate()

; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__HEADERCONSTANT_ClassName = "SysHeader32"
Global Const $__HEADERCONSTANT_DEFAULT_GUI_FONT = 17
Global Const $__HEADERCONSTANT_SWP_SHOWWINDOW = 0x0040
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _GUICtrlHeader_AddItem
; _GUICtrlHeader_ClearFilter
; _GUICtrlHeader_ClearFilterAll
; _GUICtrlHeader_Create
; _GUICtrlHeader_CreateDragImage
; _GUICtrlHeader_DeleteItem
; _GUICtrlHeader_Destroy
; _GUICtrlHeader_EditFilter
; _GUICtrlHeader_GetFilterText
; _GUICtrlHeader_GetBitmapMargin
; _GUICtrlHeader_GetImageList
; _GUICtrlHeader_GetItem
; _GUICtrlHeader_GetItemAlign
; _GUICtrlHeader_GetItemBitmap
; _GUICtrlHeader_GetItemCount
; _GUICtrlHeader_GetItemDisplay
; _GUICtrlHeader_GetItemFlags
; _GUICtrlHeader_GetItemFormat
; _GUICtrlHeader_GetItemImage
; _GUICtrlHeader_GetItemOrder
; _GUICtrlHeader_GetItemParam
; _GUICtrlHeader_GetItemRect
; _GUICtrlHeader_GetItemRectEx
; _GUICtrlHeader_GetItemText
; _GUICtrlHeader_GetItemWidth
; _GUICtrlHeader_GetOrderArray
; _GUICtrlHeader_GetUnicodeFormat
; _GUICtrlHeader_HitTest
; _GUICtrlHeader_InsertItem
; _GUICtrlHeader_Layout
; _GUICtrlHeader_OrderToIndex
; _GUICtrlHeader_SetBitmapMargin
; _GUICtrlHeader_SetFilterChangeTimeout
; _GUICtrlHeader_SetHotDivider
; _GUICtrlHeader_SetImageList
; _GUICtrlHeader_SetItem
; _GUICtrlHeader_SetItemAlign
; _GUICtrlHeader_SetItemBitmap
; _GUICtrlHeader_SetItemDisplay
; _GUICtrlHeader_SetItemFlags
; _GUICtrlHeader_SetItemFormat
; _GUICtrlHeader_SetItemImage
; _GUICtrlHeader_SetItemOrder
; _GUICtrlHeader_SetItemParam
; _GUICtrlHeader_SetItemText
; _GUICtrlHeader_SetItemWidth
; _GUICtrlHeader_SetOrderArray
; _GUICtrlHeader_SetUnicodeFormat
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; $tagHDHITTESTINFO
; $tagHDLAYOUT
; $tagHDTEXTFILTER
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagHDHITTESTINFO
; Description ...: Contains information about a hit test
; Fields ........: X     - Horizontal postion to be hit test, in client coordinates
;                  Y     - Vertical position to be hit test, in client coordinates
;                  Flags - Information about the results of a hit test
;                  Item  - If the hit test is successful, contains the index of the item at the hit test point
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: This structure is used with the $HDM_HITTEST message.
; ===============================================================================================================================
Global Const $tagHDHITTESTINFO = $tagPOINT & ";uint Flags;int Item"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagHDLAYOUT
; Description ...: Contains information used to set the size and position of the control
; Fields ........: Rect      - Pointer to a RECT structure that contains the rectangle that the header control will occupy
;                  WindowPos - Pointer to a WINDOWPOS structure that receives information about the size/position of the control
; Author ........: Paul Campbell (PaulIA)
; Remarks .......: This structure is used with the $HDM_LAYOUT message
; ===============================================================================================================================
Global Const $tagHDLAYOUT = "ptr Rect;ptr WindowPos"

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: $tagHDTEXTFILTER
; Description ...: Contains information about header control text filters
; Fields ........: Text    - Pointer to the buffer containing the filter
;                  TextMax - The maximum size, in characters, for an edit control buffer
; Author ........: Paul Campbell (PaulIA)
; Remarks .......:
; ===============================================================================================================================
Global Const $tagHDTEXTFILTER = "ptr Text;int TextMax"

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _GUICtrlHeader_AddItem($hWnd, $sText, $iWidth = 50, $iAlign = 0, $iImage = -1, $bOnRight = False)
	Return _GUICtrlHeader_InsertItem($hWnd, _GUICtrlHeader_GetItemCount($hWnd), $sText, $iWidth, $iAlign, $iImage, $bOnRight)
EndFunc   ;==>_GUICtrlHeader_AddItem

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_ClearFilter($hWnd, $iIndex)
	Return _SendMessage($hWnd, $HDM_CLEARFILTER, $iIndex) <> 0
EndFunc   ;==>_GUICtrlHeader_ClearFilter

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_ClearFilterAll($hWnd)
	Return _SendMessage($hWnd, $HDM_CLEARFILTER, -1) <> 0
EndFunc   ;==>_GUICtrlHeader_ClearFilterAll

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost
; ===============================================================================================================================
Func _GUICtrlHeader_Create($hWnd, $iStyle = 0x00000046)
	$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__UDFGUICONSTANT_WS_VISIBLE)

	Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
	If @error Then Return SetError(@error, @extended, 0)

	Local $hHeader = _WinAPI_CreateWindowEx(0, $__HEADERCONSTANT_ClassName, "", $iStyle, 0, 0, 0, 0, $hWnd, $nCtrlID)
	Local $tRECT = _WinAPI_GetClientRect($hWnd)
	Local $tWindowPos = _GUICtrlHeader_Layout($hHeader, $tRECT)
	Local $iFlags = BitOR(DllStructGetData($tWindowPos, "Flags"), $__HEADERCONSTANT_SWP_SHOWWINDOW)
	_WinAPI_SetWindowPos($hHeader, DllStructGetData($tWindowPos, "InsertAfter"), _
			DllStructGetData($tWindowPos, "X"), DllStructGetData($tWindowPos, "Y"), _
			DllStructGetData($tWindowPos, "CX"), DllStructGetData($tWindowPos, "CY"), $iFlags)
	_WinAPI_SetFont($hHeader, _WinAPI_GetStockObject($__HEADERCONSTANT_DEFAULT_GUI_FONT))

	Return $hHeader
EndFunc   ;==>_GUICtrlHeader_Create

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_CreateDragImage($hWnd, $iIndex)
	Return Ptr(_SendMessage($hWnd, $HDM_CREATEDRAGIMAGE, $iIndex))
EndFunc   ;==>_GUICtrlHeader_CreateDragImage

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_DeleteItem($hWnd, $iIndex)
	Return _SendMessage($hWnd, $HDM_DELETEITEM, $iIndex) <> 0
EndFunc   ;==>_GUICtrlHeader_DeleteItem

; #FUNCTION# ====================================================================================================================
; Author ........: Gary Frost
; Modified.......:
; ===============================================================================================================================
Func _GUICtrlHeader_Destroy(ByRef $hWnd)
	If Not _WinAPI_IsClassName($hWnd, $__HEADERCONSTANT_ClassName) Then Return SetError(2, 2, False)

	Local $iDestroyed = 0
	If IsHWnd($hWnd) Then
		If _WinAPI_InProcess($hWnd, $__g_hGUICtrl_LastWnd) Then
			Local $nCtrlID = _WinAPI_GetDlgCtrlID($hWnd)
			Local $hParent = _WinAPI_GetParent($hWnd)
			$iDestroyed = _WinAPI_DestroyWindow($hWnd)
			Local $iRet = __UDF_FreeGlobalID($hParent, $nCtrlID)
			If Not $iRet Then
				; can check for errors here if needed, for debug
			EndIf
		Else
			; Not Allowed to Destroy Other Applications Control(s)
			Return SetError(1, 1, False)
		EndIf
	Else
		$iDestroyed = GUICtrlDelete($hWnd)
	EndIf
	If $iDestroyed Then $hWnd = 0

	Return $iDestroyed <> 0
EndFunc   ;==>_GUICtrlHeader_Destroy

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_EditFilter($hWnd, $iIndex, $bDiscard = True)
	Return _SendMessage($hWnd, $HDM_EDITFILTER, $iIndex, $bDiscard) <> 0
EndFunc   ;==>_GUICtrlHeader_EditFilter

; #FUNCTION# ====================================================================================================================
; Author ........: Jpm
; Modified.......:
; ===============================================================================================================================
Func _GUICtrlHeader_GetFilterText($hWnd, $iIndex)
	Local $tBuffer, $iMsg
	If _GUICtrlHeader_GetUnicodeFormat($hWnd) Then
		$tBuffer = DllStructCreate("wchar Text[64]")
		$iMsg = $HDM_GETITEMW
	Else
		$tBuffer = DllStructCreate("char Text[64]")
		$iMsg = $HDM_GETITEMA
	EndIf

	Local $tFilter = DllStructCreate($tagHDTEXTFILTER)
	DllStructSetData($tFilter, "Text", DllStructGetPtr($tBuffer))
	DllStructSetData($tFilter, "TextMax", DllStructGetSize($tBuffer))

	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_FILTER)
	DllStructSetData($tItem, "Type", 0)
	DllStructSetData($tItem, "pFilter", DllStructGetPtr($tFilter))

	__GUICtrl_SendMsg($hWnd, $iMsg, $iIndex, $tItem, $tBuffer, False, -1, True)

	Return DllStructGetData($tBuffer, "Text")
EndFunc   ;==>_GUICtrlHeader_GetFilterText

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_GetBitmapMargin($hWnd)
	Return _SendMessage($hWnd, $HDM_GETBITMAPMARGIN)
EndFunc   ;==>_GUICtrlHeader_GetBitmapMargin

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_GetImageList($hWnd)
	Return Ptr(_SendMessage($hWnd, $HDM_GETIMAGELIST))
EndFunc   ;==>_GUICtrlHeader_GetImageList

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), Jpm
; ===============================================================================================================================
Func _GUICtrlHeader_GetItem($hWnd, $iIndex, ByRef $tItem)
	Local $iMsg
	If _GUICtrlHeader_GetUnicodeFormat($hWnd) Then
		$iMsg = $HDM_GETITEMW
	Else
		$iMsg = $HDM_GETITEMA
	EndIf
	Local $iRet = __GUICtrl_SendMsg($hWnd, $iMsg, $iIndex, $tItem, 0, True)

	Return $iRet <> 0
EndFunc   ;==>_GUICtrlHeader_GetItem

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemAlign($hWnd, $iIndex)
	Switch BitAND(_GUICtrlHeader_GetItemFormat($hWnd, $iIndex), $HDF_JUSTIFYMASK)
		Case $HDF_LEFT
			Return 0
		Case $HDF_RIGHT
			Return 1
		Case $HDF_CENTER
			Return 2
		Case Else
			Return -1
	EndSwitch
EndFunc   ;==>_GUICtrlHeader_GetItemAlign

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemBitmap($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_BITMAP)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)

	Return DllStructGetData($tItem, "hBmp")
EndFunc   ;==>_GUICtrlHeader_GetItemBitmap

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemCount($hWnd)
	Return _SendMessage($hWnd, $HDM_GETITEMCOUNT)
EndFunc   ;==>_GUICtrlHeader_GetItemCount

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemDisplay($hWnd, $iIndex)
	Local $iRet = 0

	Local $iFormat = _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	If BitAND($iFormat, $HDF_BITMAP) <> 0 Then $iRet = BitOR($iRet, 1)
	If BitAND($iFormat, $HDF_BITMAP_ON_RIGHT) <> 0 Then $iRet = BitOR($iRet, 2)
	If BitAND($iFormat, $HDF_OWNERDRAW) <> 0 Then $iRet = BitOR($iRet, 4)
	If BitAND($iFormat, $HDF_STRING) <> 0 Then $iRet = BitOR($iRet, 8)

	Return $iRet
EndFunc   ;==>_GUICtrlHeader_GetItemDisplay

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemFlags($hWnd, $iIndex)
	Local $iRet = 0

	Local $iFormat = _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	If BitAND($iFormat, $HDF_IMAGE) <> 0 Then $iRet = BitOR($iRet, 1)
	If BitAND($iFormat, $HDF_RTLREADING) <> 0 Then $iRet = BitOR($iRet, 2)
	If BitAND($iFormat, $HDF_SORTDOWN) <> 0 Then $iRet = BitOR($iRet, 4)
	If BitAND($iFormat, $HDF_SORTUP) <> 0 Then $iRet = BitOR($iRet, 8)

	Return $iRet
EndFunc   ;==>_GUICtrlHeader_GetItemFlags

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_FORMAT)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)

	Return DllStructGetData($tItem, "Fmt")
EndFunc   ;==>_GUICtrlHeader_GetItemFormat

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemImage($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_IMAGE)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)

	Return DllStructGetData($tItem, "Image")
EndFunc   ;==>_GUICtrlHeader_GetItemImage

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemOrder($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_ORDER)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)

	Return DllStructGetData($tItem, "Order")
EndFunc   ;==>_GUICtrlHeader_GetItemOrder

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemParam($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_PARAM)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)

	Return DllStructGetData($tItem, "Param")
EndFunc   ;==>_GUICtrlHeader_GetItemParam

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemRect($hWnd, $iIndex)
	Local $aRect[4]

	Local $tRECT = _GUICtrlHeader_GetItemRectEx($hWnd, $iIndex)
	$aRect[0] = DllStructGetData($tRECT, "Left")
	$aRect[1] = DllStructGetData($tRECT, "Top")
	$aRect[2] = DllStructGetData($tRECT, "Right")
	$aRect[3] = DllStructGetData($tRECT, "Bottom")

	Return $aRect
EndFunc   ;==>_GUICtrlHeader_GetItemRect

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), Jpm
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemRectEx($hWnd, $iIndex)
	Local $tRECT = DllStructCreate($tagRECT)
	__GUICtrl_SendMsg($hWnd, $HDM_GETITEMRECT, $iIndex, $tRECT, 0, True)

	Return $tRECT
EndFunc   ;==>_GUICtrlHeader_GetItemRectEx

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), Jpm
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemText($hWnd, $iIndex)
	Local $tBuffer, $iMsg
	If _GUICtrlHeader_GetUnicodeFormat($hWnd) Then
		$tBuffer = $__g_tHeaderBuffer
		$iMsg = $HDM_GETITEMW
	Else
		$tBuffer = $__g_tHeaderBufferANSI
		$iMsg = $HDM_GETITEMA
	EndIf
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_TEXT)
	DllStructSetData($tItem, "TextMax", DllStructGetSize($tBuffer))
	__GUICtrl_SendMsg($hWnd, $iMsg, $iIndex, $tItem, $tBuffer, False, 3, True, 5)

	Return DllStructGetData($tBuffer, "Text")
EndFunc   ;==>_GUICtrlHeader_GetItemText

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_GetItemWidth($hWnd, $iIndex)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_WIDTH)
	_GUICtrlHeader_GetItem($hWnd, $iIndex, $tItem)

	Return DllStructGetData($tItem, "XY")
EndFunc   ;==>_GUICtrlHeader_GetItemWidth

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), Jpm
; ===============================================================================================================================
Func _GUICtrlHeader_GetOrderArray($hWnd)
	Local $iItems = _GUICtrlHeader_GetItemCount($hWnd)
	Local $tBuffer = DllStructCreate("int[" & $iItems & "]")
	__GUICtrl_SendMsg($hWnd, $HDM_GETORDERARRAY, $iItems, $tBuffer, 0, True)

	Local $aBuffer[$iItems + 1]
	$aBuffer[0] = $iItems
	For $iI = 1 To $iItems
		$aBuffer[$iI] = DllStructGetData($tBuffer, 1, $iI)
	Next

	Return $aBuffer
EndFunc   ;==>_GUICtrlHeader_GetOrderArray

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), Jpm
; ===============================================================================================================================
Func _GUICtrlHeader_GetUnicodeFormat($hWnd)
	If Not IsDllStruct($__g_tHeaderBuffer) Then
		$__g_tHeaderBuffer = DllStructCreate("wchar Text[4096]")
		$__g_tHeaderBufferANSI = DllStructCreate("char Text[4096]", DllStructGetPtr($__g_tHeaderBuffer))
	EndIf

	Return _SendMessage($hWnd, $HDM_GETUNICODEFORMAT) <> 0
EndFunc   ;==>_GUICtrlHeader_GetUnicodeFormat

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), Jpm
; ===============================================================================================================================
Func _GUICtrlHeader_HitTest($hWnd, $iX, $iY)
	Local $tTest = DllStructCreate($tagHDHITTESTINFO)
	DllStructSetData($tTest, "X", $iX)
	DllStructSetData($tTest, "Y", $iY)
	Local $aTest[11]
	$aTest[0] = __GUICtrl_SendMsg($hWnd, $HDM_HITTEST, 0, $tTest, 0, True)

	Local $iFlags = DllStructGetData($tTest, "Flags")
	$aTest[1] = BitAND($iFlags, $HHT_NOWHERE) <> 0
	$aTest[2] = BitAND($iFlags, $HHT_ONHEADER) <> 0
	$aTest[3] = BitAND($iFlags, $HHT_ONDIVIDER) <> 0
	$aTest[4] = BitAND($iFlags, $HHT_ONDIVOPEN) <> 0
	$aTest[5] = BitAND($iFlags, $HHT_ONFILTER) <> 0
	$aTest[6] = BitAND($iFlags, $HHT_ONFILTERBUTTON) <> 0
	$aTest[7] = BitAND($iFlags, $HHT_ABOVE) <> 0
	$aTest[8] = BitAND($iFlags, $HHT_BELOW) <> 0
	$aTest[9] = BitAND($iFlags, $HHT_TORIGHT) <> 0
	$aTest[10] = BitAND($iFlags, $HHT_TOLEFT) <> 0

	Return $aTest
EndFunc   ;==>_GUICtrlHeader_HitTest

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), Jpm
; ===============================================================================================================================
Func _GUICtrlHeader_InsertItem($hWnd, $iIndex, $sText, $iWidth = 50, $iAlign = 0, $iImage = -1, $bOnRight = False)
	Local $aAlign[3] = [$HDF_LEFT, $HDF_RIGHT, $HDF_CENTER]

	Local $tBuffer, $pBuffer, $iMsg
	If _GUICtrlHeader_GetUnicodeFormat($hWnd) Then
		$iMsg = $HDM_INSERTITEMW
		$tBuffer = $__g_tHeaderBuffer
	Else
		$tBuffer = $__g_tHeaderBufferANSI
		$iMsg = $HDM_INSERTITEMA
	EndIf
	Local $iBuffer
	If $sText <> -1 Then
		$iBuffer = StringLen($sText) + 1
		DllStructSetData($tBuffer, "Text", $sText)
		$pBuffer = DllStructGetPtr($tBuffer)
	Else
		$iBuffer = 0
		$tBuffer = 0
		$pBuffer = -1 ; LPSTR_TEXTCALLBACK
	EndIf
	Local $iFmt = $aAlign[$iAlign]
	Local $iMask = BitOR($HDI_WIDTH, $HDI_FORMAT)
	If $sText <> "" Then
		$iMask = BitOR($iMask, $HDI_TEXT)
		$iFmt = BitOR($iFmt, $HDF_STRING)
	EndIf
	If $iImage <> -1 Then
		$iMask = BitOR($iMask, $HDI_IMAGE)
		$iFmt = BitOR($iFmt, $HDF_IMAGE)
	EndIf
	If $bOnRight Then $iFmt = BitOR($iFmt, $HDF_BITMAP_ON_RIGHT)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $iMask)
	DllStructSetData($tItem, "XY", $iWidth)
	DllStructSetData($tItem, "Fmt", $iFmt)
	DllStructSetData($tItem, "Image", $iImage)
	DllStructSetData($tItem, "Text", $pBuffer)
	DllStructSetData($tItem, "TextMax", $iBuffer)
	Local $iRet = __GUICtrl_SendMsg($hWnd, $iMsg, $iIndex, $tItem, $tBuffer, False, -1)

	Return $iRet
EndFunc   ;==>_GUICtrlHeader_InsertItem

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_Layout($hWnd, ByRef $tRECT)
	Local $tLayout = DllStructCreate($tagHDLAYOUT)
	Local $tWindowPos = DllStructCreate($tagWINDOWPOS)

	; cannot be optimized with __GUICtrl_SendMsg() as $tLayout need to point to 2 areas $tRECT and $tWindowPos
	If _WinAPI_InProcess($hWnd, $__g_hGUICtrl_LastWnd) Then
		DllStructSetData($tLayout, "Rect", DllStructGetPtr($tRECT))
		DllStructSetData($tLayout, "WindowPos", DllStructGetPtr($tWindowPos))
		_SendMessage($hWnd, $HDM_LAYOUT, 0, $tLayout, 0, "wparam", "struct*")
	Else
		Local $iLayout = DllStructGetSize($tLayout)
		Local $iRect = DllStructGetSize($tRECT)
		Local $iWindowPos = DllStructGetSize($tWindowPos)
		Local $tMemMap
		Local $pMemory = _MemInit($hWnd, $iLayout + $iRect + $iWindowPos, $tMemMap)
		DllStructSetData($tLayout, "Rect", $pMemory + $iLayout)
		DllStructSetData($tLayout, "WindowPos", $pMemory + $iLayout + $iRect)
		_MemWrite($tMemMap, $tLayout, $pMemory, $iLayout)
		_MemWrite($tMemMap, $tRECT, $pMemory + $iLayout, $iRect)
		_SendMessage($hWnd, $HDM_LAYOUT, 0, $pMemory, 0, "wparam", "ptr")
		_MemRead($tMemMap, $pMemory + $iLayout + $iRect, $tWindowPos, $iWindowPos)
		_MemFree($tMemMap)
	EndIf

	Return $tWindowPos
EndFunc   ;==>_GUICtrlHeader_Layout

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_OrderToIndex($hWnd, $iOrder)
	Return _SendMessage($hWnd, $HDM_ORDERTOINDEX, $iOrder)
EndFunc   ;==>_GUICtrlHeader_OrderToIndex

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetBitmapMargin($hWnd, $iWidth)
	Return _SendMessage($hWnd, $HDM_SETBITMAPMARGIN, $iWidth)
EndFunc   ;==>_GUICtrlHeader_SetBitmapMargin

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetFilterChangeTimeout($hWnd, $iTimeOut)
	Return _SendMessage($hWnd, $HDM_SETFILTERCHANGETIMEOUT, 0, $iTimeOut)
EndFunc   ;==>_GUICtrlHeader_SetFilterChangeTimeout

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetHotDivider($hWnd, $iFlag, $iInputValue)
	Return _SendMessage($hWnd, $HDM_SETHOTDIVIDER, $iFlag, $iInputValue)
EndFunc   ;==>_GUICtrlHeader_SetHotDivider

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetImageList($hWnd, $hImage)
	Return _SendMessage($hWnd, $HDM_SETIMAGELIST, 0, $hImage, 0, "wparam", "handle", "handle")
EndFunc   ;==>_GUICtrlHeader_SetImageList

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), Jpm
; ===============================================================================================================================
Func _GUICtrlHeader_SetItem($hWnd, $iIndex, ByRef $tItem)
	Local $iMsg
	If _GUICtrlHeader_GetUnicodeFormat($hWnd) Then
		$iMsg = $HDM_SETITEMW
	Else
		$iMsg = $HDM_SETITEMA
	EndIf

	Local $iRet = __GUICtrl_SendMsg($hWnd, $iMsg, $iIndex, $tItem)

	Return $iRet <> 0
EndFunc   ;==>_GUICtrlHeader_SetItem

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemAlign($hWnd, $iIndex, $iAlign)
	Local $aAlign[3] = [$HDF_LEFT, $HDF_RIGHT, $HDF_CENTER]

	Local $iFormat = _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	$iFormat = BitAND($iFormat, BitNOT($HDF_JUSTIFYMASK))
	$iFormat = BitOR($iFormat, $aAlign[$iAlign])

	Return _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
EndFunc   ;==>_GUICtrlHeader_SetItemAlign

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemBitmap($hWnd, $iIndex, $hBitmap)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", BitOR($HDI_FORMAT, $HDI_BITMAP))
	DllStructSetData($tItem, "Fmt", $HDF_BITMAP)
	DllStructSetData($tItem, "hBMP", $hBitmap)

	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemBitmap

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemDisplay($hWnd, $iIndex, $iDisplay)
	Local $iFormat = BitAND(_GUICtrlHeader_GetItemFormat($hWnd, $iIndex), Not $HDF_DISPLAYMASK)
	If BitAND($iDisplay, 1) <> 0 Then $iFormat = BitOR($iFormat, $HDF_BITMAP)
	If BitAND($iDisplay, 2) <> 0 Then $iFormat = BitOR($iFormat, $HDF_BITMAP_ON_RIGHT)
	If BitAND($iDisplay, 4) <> 0 Then $iFormat = BitOR($iFormat, $HDF_OWNERDRAW)
	If BitAND($iDisplay, 8) <> 0 Then $iFormat = BitOR($iFormat, $HDF_STRING)

	Return _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
EndFunc   ;==>_GUICtrlHeader_SetItemDisplay

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemFlags($hWnd, $iIndex, $iFlags)
	Local $iFormat = _GUICtrlHeader_GetItemFormat($hWnd, $iIndex)
	$iFormat = BitAND($iFormat, BitNOT($HDF_FLAGMASK))
	If BitAND($iFlags, 1) <> 0 Then $iFormat = BitOR($iFormat, $HDF_IMAGE)
	If BitAND($iFlags, 2) <> 0 Then $iFormat = BitOR($iFormat, $HDF_RTLREADING)
	If BitAND($iFlags, 4) <> 0 Then $iFormat = BitOR($iFormat, $HDF_SORTDOWN)
	If BitAND($iFlags, 8) <> 0 Then $iFormat = BitOR($iFormat, $HDF_SORTUP)

	Return _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
EndFunc   ;==>_GUICtrlHeader_SetItemFlags

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemFormat($hWnd, $iIndex, $iFormat)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_FORMAT)
	DllStructSetData($tItem, "Fmt", $iFormat)

	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemFormat

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemImage($hWnd, $iIndex, $iImage)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_IMAGE)
	DllStructSetData($tItem, "Image", $iImage)

	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemImage

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemOrder($hWnd, $iIndex, $iOrder)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_ORDER)
	DllStructSetData($tItem, "Order", $iOrder)

	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemOrder

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemParam($hWnd, $iIndex, $iParam)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_PARAM)
	DllStructSetData($tItem, "Param", $iParam)

	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemParam

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), Jpm
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemText($hWnd, $iIndex, $sText)
	Local $tBuffer, $iMsg
	If _GUICtrlHeader_GetUnicodeFormat($hWnd) Then
		$tBuffer = $__g_tHeaderBuffer
		$iMsg = $HDM_SETITEMW
	Else
		$tBuffer = $__g_tHeaderBufferANSI
		$iMsg = $HDM_SETITEMA
	EndIf
	Local $iBuffer, $pBuffer
	If $sText <> -1 Then
		$iBuffer = StringLen($sText) + 1
		DllStructSetData($tBuffer, "Text", $sText)
		$pBuffer = DllStructGetPtr($tBuffer)
	Else
		$iBuffer = 0
		$tBuffer = 0
		$pBuffer = -1 ; LPSTR_TEXTCALLBACK
	EndIf
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_TEXT)
	DllStructSetData($tItem, "Text", $pBuffer)
	DllStructSetData($tItem, "TextMax", $iBuffer)
	Local $iRet = __GUICtrl_SendMsg($hWnd, $iMsg, $iIndex, $tItem, $tBuffer, False, -1)

	Return $iRet <> 0
EndFunc   ;==>_GUICtrlHeader_SetItemText

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetItemWidth($hWnd, $iIndex, $iWidth)
	Local $tItem = DllStructCreate($tagHDITEM)
	DllStructSetData($tItem, "Mask", $HDI_WIDTH)
	DllStructSetData($tItem, "XY", $iWidth)

	Return _GUICtrlHeader_SetItem($hWnd, $iIndex, $tItem)
EndFunc   ;==>_GUICtrlHeader_SetItemWidth

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost), Jpm
; ===============================================================================================================================
Func _GUICtrlHeader_SetOrderArray($hWnd, ByRef $aOrder)
	Local $tBuffer = DllStructCreate("int[" & $aOrder[0] & "]")
	For $iI = 1 To $aOrder[0]
		DllStructSetData($tBuffer, 1, $aOrder[$iI], $iI)
	Next
	Local $iRet = __GUICtrl_SendMsg($hWnd, $HDM_SETORDERARRAY, $aOrder[0], $tBuffer)

	Return $iRet <> 0
EndFunc   ;==>_GUICtrlHeader_SetOrderArray

; #FUNCTION# ====================================================================================================================
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
; ===============================================================================================================================
Func _GUICtrlHeader_SetUnicodeFormat($hWnd, $bUnicode)
	Return _SendMessage($hWnd, $HDM_SETUNICODEFORMAT, $bUnicode)
EndFunc   ;==>_GUICtrlHeader_SetUnicodeFormat
