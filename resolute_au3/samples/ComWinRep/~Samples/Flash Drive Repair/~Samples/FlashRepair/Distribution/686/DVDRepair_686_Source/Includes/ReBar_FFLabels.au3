#region Header
; #INDEX# =======================================================================================================================
; Title .........: 	GUICtrlFFLabel
; AutoIt Version : 	3.3.6.1
; Language ......: 	English
; Description ...: 	Creates Labels using GDI+ that dont flicker
; Author(s) .....: 	Brian J Christy (Beege), G.Sandler (MrCreatoR)
; Remarks........: 	This UDF registers windows msgs WM_SIZE, WM_SIZING, WM_ENTERSIZEMOVE, WM_EXITSIZEMOVE. If any of these msgs
;				   	are registered in your script you must pass the notifications on to this UDF. Below are examples of the calls
;					you will need to add if this is the case:
;
;					Func WM_SIZE($hWndGUI, $MsgID, $WParam, $LParam)
;    					__GUICtrlFFLabel_WM_SIZE($hWndGUI, $MsgID, $WParam)
;    					;USER CODE;
;					EndFunc   ;==>WM_SIZE;
;
;					Func WM_SIZING($hWndGUI, $MsgID, $WParam, $LParam)
;    					__GUICtrlFFLabel_WM_SIZING()
;    					;USER CODE;
;					EndFunc   ;==>WM_SIZING;
;
;					Func WM_ENTERSIZEMOVE($hWndGUI, $MsgID, $WParam, $LParam)
;    					__GUICtrlFFLabel_WM_ENTERSIZEMOVE($hWndGUI)
;    					;USER CODE;
;					EndFunc   ;==>WM_ENTERSIZEMOVE
;
;					Func WM_EXITSIZEMOVE($hWndGUI, $MsgID, $WParam, $LParam)
;   					__GUICtrlFFLabel_WM_EXITSIZEMOVE()
;    					;USER CODE;
;					EndFunc   ;==>WM_EXITSIZEMOVE
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _GUICtrlFFLabel_Create		- Creates a Flicker Free label using GDI+
; _GUICtrlFFLabel_SetData 		- Sets text of the labels
; _GUICtrlFFLabel_Delete		- Deletes label
; _GUICtrlFFLabel_Refresh		- Refresh all FF labels
; _GUICtrlFFLabel_GUISetBkColor	- Sets the backgound of the GUI and defualt backgound color for all FFlabels to match.
; _GUICtrlFFLabel_SetTextColor	- Sets text color of label
; ===============================================================================================================================
#endregion Header
#region Global Vars
#include-once
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Global $g_hMovingGUI = 0
Global $g_iAutoit_Def_BK_Color = __GUICtrlFFLabel_GetWindowBkColor()
Global $g_hRefreshCB
Global $g_ahGraphics[1] = [0]
Global $g_ahDCs[1] = [0]
Global $g_aRefreshTimer = 0

Global Enum $g_FF_hGUI, $g_FF_iGraphicsIndex, $g_iFF_DCIndex, $g_FF_bIsMinimized, $g_FF_hBitmap, $g_FF_hBuffer, $g_FF_hBrush, $g_FF_FontFamily, $g_FF_hStringformat, _
		$g_FF_Layout, $g_FF_hFont, $g_FF_iLeft, $g_FF_iTop, $g_FF_iWidth, $g_FF_iHeight, $g_FF_sRestore, $g_FF_bRemoved, $g_FF_iDef_BG_Color, $g_FF_Max
Global $g_aGDILbs[1][$g_FF_Max]
$g_aGDILbs[0][0] = 0
#cs
	$g_aGDILbs[0][0]				= List Count
	[0][1-$g_FF_Max]				= Nothing

	[$i][$g_FF_hGUI]    			= Gui Handle label is located on
	[$i][$g_FF_iGraphicsIndex]		= Array index number to $g_ahGraphics that holds this labels Graphics object handle
	[$i][$g_iFF_DCIndex]			= Array index number to $g_ahDCs that holds this labels display device context
	[$i][$g_FF_bIsMinimized]		= Flag indicating if window is minimzed
	[$i][$g_FF_hBitmap]				= Bitmap Object Handle
	[$i][$g_FF_hBuffer]    			= Buffer Handle
	[$i][$g_FF_hBrush]    			= Handle to brush
	[$i][$g_FF_FontFamily]    		= Handle to font family
	[$i][$g_FF_hStringformat]  		= Handle to stringformat
	[$i][$g_FF_Layout]  			= labels $tagGDIPRECTF structure
	[$i][$g_FF_hFont]    			= Handle to font
	[$i][$g_FF_iLeft]     			= Left
	[$i][$g_FF_iTop]     			= Top
	[$i][$g_FF_iWidth]     			= Width
	[$i][$g_FF_iHeight]  			= Height
	[$i][$g_FF_sRestore]    		= Last text written to label
	[$i][$g_FF_bRemoved]			= indicates to other functions that item has been deleted and objects in index are no longer valid
	[$i][$g_FF_iDef_BG_Color]		= Defualt Backgound Color of Label
#ce

#endregion Global Vars

#region Public Functions
; #FUNCTION# ====================================================================================================
; Name...........:	_GUICtrlFFLabel_Create
; Description....:	Creates a label that wont flicker using GDI+
; Syntax.........:	_GUICtrlFFLabel_Create($hWnd, $sText, $iLeft, $iTop, $iWidth, $iHeight, $iFontSize = 11, $sFontFamily = 'Courier New', $iFontStyle = 0, $g_iAlign = 0, $iColor = 0xFF000000)
; Parameters.....:	$hWnd - Handle to GUI
;					$sText - Text
;					$iLeft - The left side of the control.
;					$iTop - The top of the control.
;					$iWidth - The width of the control
;					$iHeight - The height of the control
;					$iFontSize - [Optional] - Size of font
;					$sFontFamily - [Optional] - Font to use. Default font is 'Microsoft Sans Serif'
;					$iFontStyle - [Optional] - The style of the typeface. Can be a combination of the following:
;										0 - Normal weight or thickness of the typeface
;										1 - Bold typeface
;										2 - Italic typeface
;										4 - Underline
;										8 - Strikethrough
;					$g_iAlign - [Optional] - Sets the text alignment of a string. The alignment can be one of the following:
;										0 - The text is aligned to the left
;										1 - The text is centered
;										2 - The text is aligned to the right
;										3 - No alignment. Needed it using tabs.
;					$iColor - [Optional] - Hex Color value. Value can be ARGB(0xAARRGGBB) or RGB(0xRRGGBB). Default color is Black
; Return values..:	Success - Index of label. Use with _GUICtrlFFLabel_SetData()
; Author.........:	Brian J Christy
; Remarks........:	None
; Example........:	Yes
; ===============================================================================================================
Func _GUICtrlFFLabel_Create($hWnd, $sText, $iLeft, $iTop, $iWidth, $iHeight, $iFontSize = 9, $sFontFamily = 'Microsoft Sans Serif', $iFontStyle = 0, $iAlign = 0, $iColor = 0xFF000000)

	If $sFontFamily = -1 Or $sFontFamily = Default Then $sFontFamily = 'Microsoft Sans Serif'
	If $iFontSize = -1 Or $iFontSize = Default Then $iFontSize = 9
	If $iFontStyle = -1 Or $iFontStyle = Default Then $iFontStyle = 0
	If $iAlign = -1 Or $iAlign = Default Then $iAlign = 0
	If $iColor = -1 Or $iColor = Default Then $iColor = 0xFF000000

	ReDim $g_aGDILbs[UBound($g_aGDILbs) + 1][$g_FF_Max]
	$g_aGDILbs[0][0] += 1

	If $g_aGDILbs[0][0] = 1 Then
		_GDIPlus_Startup()
		$g_hRefreshCB = DllCallbackRegister('_GUICtrlFFLabel_Refresh', 'none', '')
		OnAutoItExitRegister('__GUICtrlFFLabel_Dispose')
		GUIRegisterMsg(0x0214, '__GUICtrlFFLabel_WM_SIZING');WM_SIZING
		GUIRegisterMsg($WM_SIZE, '__GUICtrlFFLabel_WM_SIZE')
		GUIRegisterMsg(0x0232, '__GUICtrlFFLabel_WM_EXITSIZEMOVE')
		GUIRegisterMsg(0x0231, '__GUICtrlFFLabel_WM_ENTERSIZEMOVE')
	EndIf

	__GUICtrlFFLabel_Graphics_N_DC($g_aGDILbs[0][0], $hWnd)
	__GUICtrlFFLabel_VerifyARGB($iColor)

	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hGUI] = $hWnd
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iLeft] = $iLeft
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iTop] = $iTop
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iWidth] = $iWidth
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iHeight] = $iHeight
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_bIsMinimized] = False
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iDef_BG_Color] = $g_iAutoit_Def_BK_Color

	Local $iGraphicsIndex = $g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_iGraphicsIndex]
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hBitmap] = _GDIPlus_BitmapCreateFromGraphics($iWidth, $iHeight, $g_ahGraphics[$iGraphicsIndex])
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hBuffer] = _GDIPlus_ImageGetGraphicsContext($g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hBitmap])

	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hBrush] = _GDIPlus_BrushCreateSolid($iColor)
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_FontFamily] = _GDIPlus_FontFamilyCreate($sFontFamily)

	If $iAlign < 3 Then
		$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hStringformat] = _GDIPlus_StringFormatCreate()
		_GDIPlus_StringFormatSetAlign($g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hStringformat], $iAlign)
		If @error Then ConsoleWrite('error setting alignment' & @CRLF)
	EndIf

	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hFont] = _GDIPlus_FontCreate($g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_FontFamily], $iFontSize, $iFontStyle)
	_GDIPlus_GraphicsSetSmoothingMode($g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hBuffer], 4)
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_Layout] = _GDIPlus_RectFCreate(0, 0, $iWidth, $iHeight)
	$g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_bRemoved] = False
	_GUICtrlFFLabel_SetData($g_aGDILbs[0][0], $sText)

	Return $g_aGDILbs[0][0]

EndFunc   ;==>_GUICtrlFFLabel_Create

; #FUNCTION# ====================================================================================================
; Name...........:	_GUICtrlFFLabel_Move
; Description....:	Moves FF label
; Syntax.........:	_GUICtrlFFLabel_Move($iIndex, $iX = Default, $iY = Default)
; Parameters.....:	$iIndex - Index returned from _GUICtrlFFLabel_Create()
;					$iX - [Optional] - X coordinate to move to.
;					$iY - [Optional] - Y coordinate to move to.
; Return values..:	Success - Moves Label
; Author.........:	Brian J Christy
; Remarks........:	None
; Example........:
; ===============================================================================================================
Func _GUICtrlFFLabel_Move($iIndex, $iX = Default, $iY = Default)
	If $iIndex > $g_aGDILbs[0][0] Or $g_aGDILbs[$iIndex][$g_FF_bRemoved] Then Return

	_GDIPlus_GraphicsClear($g_aGDILbs[$iIndex][$g_FF_hBuffer], $g_aGDILbs[$iIndex][$g_FF_iDef_BG_Color])
	__GUICtrlFFLabel_WriteBuffer($iIndex)

	If $iX <> Default Then $g_aGDILbs[$iIndex][$g_FF_iLeft] = $iX
	If $iY <> Default Then $g_aGDILbs[$iIndex][$g_FF_iTop] = $iY

	_GUICtrlFFLabel_SetData($iIndex, $g_aGDILbs[$iIndex][$g_FF_sRestore])

EndFunc
; #FUNCTION# ====================================================================================================
; Name...........:	_GUICtrlFFLabel_SetData
; Description....:	Sets text of Flicker Free Label
; Syntax.........:	_GUICtrlFFLabel_SetData($iIndex, $sText, $iBackGround = Default)
; Parameters.....:	$iIndex - Index returned from _GUICtrlFFLabel_Create()
;					$sText - Text you want to be displayed
;					$iBackGround - [Optional] - background color of text. Default is default autoit color
; Return values..:	Success - sets the text of label
; Author.........:	Brian J Christy
; Remarks........:	tip: when your laying out your gui, having the background color different helps show you full size of label.
; Example........:	Yes
; ===============================================================================================================
Func _GUICtrlFFLabel_SetData($iIndex, $sText, $iBackGround = Default)
	If $iIndex > $g_aGDILbs[0][0] Or $g_aGDILbs[$iIndex][$g_FF_bRemoved] Then Return SetError(-1)

	$g_aGDILbs[$iIndex][$g_FF_sRestore] = $sText
	If $g_aGDILbs[$iIndex][$g_FF_bIsMinimized] Then Return

	If $iBackGround = Default Then $iBackGround = $g_aGDILbs[$iIndex][$g_FF_iDef_BG_Color]
	_GDIPlus_GraphicsClear($g_aGDILbs[$iIndex][$g_FF_hBuffer], $iBackGround)
	_GDIPlus_GraphicsDrawStringEx($g_aGDILbs[$iIndex][$g_FF_hBuffer], $sText, $g_aGDILbs[$iIndex][$g_FF_hFont], $g_aGDILbs[$iIndex][$g_FF_Layout], $g_aGDILbs[$iIndex][$g_FF_hStringformat], $g_aGDILbs[$iIndex][$g_FF_hBrush])
	$g_aGDILbs[$iIndex][$g_FF_sRestore] = $sText
	__GUICtrlFFLabel_WriteBuffer($iIndex)
EndFunc   ;==>_GUICtrlFFLabel_SetData
; #FUNCTION# ====================================================================================================
; Name...........:	_GUICtrlFFLabel_Delete
; Description....:	Deletes Flicker Free Label.
; Syntax.........:	_GUICtrlFFLabel_Delete($iIndex)
; Parameters.....:	$iIndex - Index returned from _GUICtrlFFLabel_Create()
; Return values..:	Success - Deletes label.
; Author.........:	G.Sandler, Brian J Christy
; Remarks........: 	None
; Example........:	Yes
; ===============================================================================================================
Func _GUICtrlFFLabel_Delete($iIndex)
	If $iIndex > $g_aGDILbs[0][0] Or $g_aGDILbs[$iIndex][$g_FF_bRemoved] Then Return SetError(-1)

	_GUICtrlFFLabel_SetData($iIndex, '')

	_GDIPlus_FontDispose($g_aGDILbs[$iIndex][$g_FF_hFont])
	_GDIPlus_StringFormatDispose($g_aGDILbs[$iIndex][$g_FF_hStringformat])
	_GDIPlus_FontFamilyDispose($g_aGDILbs[$iIndex][$g_FF_FontFamily])
	_GDIPlus_BrushDispose($g_aGDILbs[$iIndex][$g_FF_hBrush])
	_GDIPlus_GraphicsDispose($g_aGDILbs[$iIndex][$g_FF_hBuffer])
	_GDIPlus_ImageDispose($g_aGDILbs[$iIndex][$g_FF_hBitmap])

	$g_aGDILbs[$iIndex][$g_FF_bRemoved] = True
EndFunc   ;==>_GUICtrlFFLabel_Delete
; #FUNCTION# ====================================================================================================
; Name...........:	_GUICtrlFFLabel_Refresh
; Description....:	Used to refresh all FF labels. See Remarks
; Syntax.........:	_GUICtrlFFLabel_Refresh()
; Parameters.....:	None.
; Return values..:	Success - all labels are visible after Restore Event
; Author.........:	Brian J Christy
; Remarks........:	Refreshing is done automatically. This should really only need to be used if you have Scroll
;					bars on your GUI. Also to be clear, when I say Gui scroll bars I mean specifically on your
;					GUI. NOT an edit box scroll bar, Listview scroll bar, etc..
; ===============================================================================================================
Func _GUICtrlFFLabel_Refresh()
	If $g_hMovingGUI Then
;~ 		ConsoleWrite('Moving Refresh' & @CRLF)
		For $i = 1 To $g_aGDILbs[0][0]
			If Not $g_aGDILbs[$i][$g_FF_bRemoved] And $g_aGDILbs[$i][$g_FF_hGUI] = $g_hMovingGUI Then _GUICtrlFFLabel_SetData($i, $g_aGDILbs[$i][$g_FF_sRestore])
		Next
	Else
;~ 		ConsoleWrite('Refresh All' & @CRLF)
		For $i = 1 To $g_aGDILbs[0][0]
			If Not $g_aGDILbs[$i][$g_FF_bRemoved] Then _GUICtrlFFLabel_SetData($i, $g_aGDILbs[$i][$g_FF_sRestore])
		Next
	EndIf
EndFunc   ;==>_GUICtrlFFLabel_Refresh
; #FUNCTION# ====================================================================================================
; Name...........:	_GUICtrlFFLabel_GUISetBkColor
; Description....:  Sets the backgound of the GUI and defualt backgound color of all FFlabels to match.
; Syntax.........:	_GUICtrlFFLabel_GUISetBkColor($nBkColor, $hWnd = -1)
; Parameters.....:	$nBkColor - Hex Color of text. (Red, Green and Blue 0xRRGGBB)
;					$hWnd - [Optional] - Windows handle as returned by GUICreate (default is the last created window).
; Return values..:	Success - Set GUI background color and set $g_iAutoit_Def_BK_Color to current color (to use in _GUICtrlFFLabel_SetData).
; Author.........:	G.Sandler (MrCreatoR), Brian J Christy
; Remarks........:	The window needs to be visible for this function to work so use after calling Guisetstate(@SW_SHOW).
; ===============================================================================================================
Func _GUICtrlFFLabel_GUISetBkColor($nBkColor, $hWnd = -1)
	If $hWnd = -1 Then $hWnd = $g_aGDILbs[$g_aGDILbs[0][0]][$g_FF_hGUI]
	GUISetBkColor($nBkColor, $hWnd)
	Local $iBGColor = __GUICtrlFFLabel_GetWindowBkColor($hWnd)
	For $i = 1 To $g_aGDILbs[0][0]
		If $g_aGDILbs[$i][$g_FF_hGUI] Then $g_aGDILbs[$i][$g_FF_iDef_BG_Color] = $iBGColor
	Next
	_GUICtrlFFLabel_Refresh()
EndFunc   ;==>_GUICtrlFFLabel_GUISetBkColor
; #FUNCTION# ====================================================================================================
; Name...........:	_GUICtrlFFLabel_SetTextColor
; Description....:	Sets text color of label
; Syntax.........:	_GUICtrlFFLabel_SetTextColor($iIndex, $nColor)
; Parameters.....:	$iIndex - Index returned from _GUICtrlFFLabel_Create()
;					$nColor - Hex Color value. Value can be ARGB(0xAARRGGBB) or RGB(0xRRGGBB). Default color is Black
; Return values..:	Success - True
;					Failure - False
; Author.........:	Brian J Christy
; Remarks........:	None
; ===============================================================================================================
Func _GUICtrlFFLabel_SetTextColor($iIndex, $nColor = 0xFF000000)
	If $iIndex > $g_aGDILbs[0][0] Or $g_aGDILbs[$iIndex][$g_FF_bRemoved] Then Return
	__GUICtrlFFLabel_VerifyARGB($nColor)
	If _GDIPlus_BrushSetSolidColor($g_aGDILbs[$iIndex][$g_FF_hBrush], $nColor) Then
		_GUICtrlFFLabel_SetData($iIndex, $g_aGDILbs[$iIndex][$g_FF_sRestore])
		Return True
	EndIf
	Return False
EndFunc   ;==>_GUICtrlFFLabel_SetTextColor
#endregion Public Functions

#region internal functions
; #FUNCTION# ====================================================================================================
; Name...........:	__GUICtrlFFLabel_GetWindowBkColor
; Description....:	Returns backgound color of GUI
; Parameters.....:	$hWnd - [Optional] - Handle to Gui. No handle retruns autoit default backgound color.
; Author.........:	G.Sandler (MrCreatoR)
; ===============================================================================================================
Func __GUICtrlFFLabel_GetWindowBkColor($hWnd = 0)
	Local $hDC, $iOpt, $hBkGUI, $nColor

	If $hWnd Then
		$hDC = _WinAPI_GetDC($hWnd)
		$nColor = DllCall('gdi32.dll', 'int', 'GetBkColor', 'hwnd', $hDC)
		$nColor = $nColor[0] ;BGR
		$nColor = Hex(BitOR(BitAND($nColor, 0x00FF00), BitShift(BitAND($nColor, 0x0000FF), -16), BitShift(BitAND($nColor, 0xFF0000), 16)), 6) ;convert to RGB
		_WinAPI_ReleaseDC($hWnd, $hDC)
		Return "0xFF" & $nColor
	EndIf

	$iOpt = Opt("WinWaitDelay", 10)
	$hBkGUI = GUICreate("", 2, 2, 1, 1, $WS_POPUP, $WS_EX_TOOLWINDOW)
	GUISetState()
	WinWait($hBkGUI)
	$nColor = Hex(PixelGetColor(1, 1, $hBkGUI), 6)
	GUIDelete($hBkGUI)
	Opt("WinWaitDelay", $iOpt)

	Return '0xFF' & $nColor

EndFunc   ;==>__GUICtrlFFLabel_GetWindowBkColor
Func __GUICtrlFFLabel_WriteBuffer($iIndex)

	Local $hGDI_HBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($g_aGDILbs[$iIndex][$g_FF_hBitmap])
	Local $hDC = _WinAPI_CreateCompatibleDC($g_ahDCs[$g_aGDILbs[$iIndex][$g_iFF_DCIndex]])
	_WinAPI_SelectObject($hDC, $hGDI_HBitmap)
	_WinAPI_BitBlt($g_ahDCs[$g_aGDILbs[$iIndex][$g_iFF_DCIndex]], $g_aGDILbs[$iIndex][$g_FF_iLeft], $g_aGDILbs[$iIndex][$g_FF_iTop], $g_aGDILbs[$iIndex][$g_FF_iWidth], $g_aGDILbs[$iIndex][$g_FF_iHeight], $hDC, 0, 0, 0x00CC0020);$SRCCOPY)
	_WinAPI_DeleteObject($hGDI_HBitmap)
	_WinAPI_DeleteDC($hDC)

EndFunc   ;==>__GUICtrlFFLabel_WriteBuffer
; #FUNCTION# ====================================================================================================
; Name...........:	__GUICtrlFFLabel_Graphics_N_DC
; Description....:	Handles creation of DC and Graphics objects per GUI
; Author.........:	Brian J Christy
; ===============================================================================================================
Func __GUICtrlFFLabel_Graphics_N_DC($iIndex, $hWnd)

	;Go through array and see if the GUI hwnd already exists. If it does set the new label to use the hwnds Graphics and DC.
	For $i = 1 To $g_aGDILbs[0][0]
		If $g_aGDILbs[$i][$g_FF_hGUI] = $hWnd Then
			$g_aGDILbs[$iIndex][$g_FF_iGraphicsIndex] = $g_aGDILbs[$i][$g_FF_iGraphicsIndex]
			$g_aGDILbs[$iIndex][$g_iFF_DCIndex] = $g_aGDILbs[$i][$g_iFF_DCIndex]
			Return
		EndIf
	Next

	;If we got this far then it is a new GUI handle. Create the Graphics and DC for that handle and then set new label to use those objects.
	ReDim $g_ahGraphics[UBound($g_ahGraphics) + 1]
	$g_ahGraphics[0] += 1
	ReDim $g_ahDCs[UBound($g_ahDCs) + 1]
	$g_ahDCs[0] += 1

	$g_ahGraphics[$g_ahGraphics[0]] = _GDIPlus_GraphicsCreateFromHWND($hWnd)
	$g_ahDCs[$g_ahDCs[0]] = _WinAPI_GetDC($hWnd)
	$g_aGDILbs[$iIndex][$g_FF_iGraphicsIndex] = $g_ahGraphics[0]
	$g_aGDILbs[$iIndex][$g_iFF_DCIndex] = $g_ahDCs[0]

EndFunc   ;==>__GUICtrlFFLabel_Graphics_N_DC
; #FUNCTION# ====================================================================================================
; Name...........:	__GUICtrlFFLabel_Dispose
; Description....:	Exit function for UDF. Disposes all GDI+ objects
; ===============================================================================================================
Func __GUICtrlFFLabel_Dispose()
	DllCallbackFree($g_hRefreshCB)
	For $i = 1 To $g_aGDILbs[0][0]
		If Not $g_aGDILbs[$i][$g_FF_bRemoved] Then
			_GDIPlus_FontDispose($g_aGDILbs[$i][$g_FF_hFont])
			_GDIPlus_StringFormatDispose($g_aGDILbs[$i][$g_FF_hStringformat])
			_GDIPlus_FontFamilyDispose($g_aGDILbs[$i][$g_FF_FontFamily])
			_GDIPlus_BrushDispose($g_aGDILbs[$i][$g_FF_hBrush])
			_GDIPlus_GraphicsDispose($g_aGDILbs[$i][$g_FF_hBuffer])
			_GDIPlus_ImageDispose($g_aGDILbs[$i][$g_FF_hBitmap])
		EndIf
	Next
	For $i = 1 To $g_ahGraphics[0]
		_GDIPlus_GraphicsDispose($g_ahGraphics[$i])
		For $j = 1 To $g_aGDILbs[0][0]
			If $g_aGDILbs[$j][$g_iFF_DCIndex] = $i Then
				_WinAPI_ReleaseDC($g_aGDILbs[$j][$g_FF_hGUI], $g_ahDCs[$i])
				ExitLoop
			EndIf
		Next
	Next
	_GDIPlus_Shutdown()
EndFunc   ;==>__GUICtrlFFLabel_Dispose
; #FUNCTION# ====================================================================================================
; Name...........:	__GUICtrlFFLabel_VerifyARGB
; Description....:	Verifys color is in ARGB format. If not color will be converted.
; Syntax.........:	__GUICtrlFFLabel_VerifyARGB(ByRef $iHex)
; Parameters.....:	$iHex - [ByRef] - Hex color
; Author.........:	Brian J Christy
; ===============================================================================================================
Func __GUICtrlFFLabel_VerifyARGB(ByRef $iHex)
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
EndFunc   ;==>__GUICtrlFFLabel_VerifyARGB

Func __GUICtrlFFLabel_WM_ENTERSIZEMOVE($hWndGUI)
	$g_hMovingGUI = $hWndGUI
	$g_aRefreshTimer = DllCall('user32.dll', 'UINT', 'SetTimer', 'hwnd', 0, 'UINT', 0, 'UINT', 50, 'ptr', DllCallbackGetPtr($g_hRefreshCB))
EndFunc   ;==>__GUICtrlFFLabel_WM_ENTERSIZEMOVE
Func __GUICtrlFFLabel_WM_EXITSIZEMOVE()
	DllCall('user32.dll', 'bool', 'KillTimer', 'hwnd', 0, 'UINT', $g_aRefreshTimer[0])
	$g_hMovingGUI = 0
EndFunc   ;==>__GUICtrlFFLabel_WM_EXITSIZEMOVE
Func __GUICtrlFFLabel_WM_SIZE($hWndGUI, $MsgID, $wParam)
	#forceref $hWndGUI, $MsgID
	Switch $wParam
		Case 0;restore
			For $i = 1 To $g_aGDILbs[0][0]
				If $g_aGDILbs[$i][$g_FF_hGUI] = $hWndGUI Then
					If $g_aGDILbs[$i][$g_FF_bIsMinimized] Then $g_aGDILbs[$i][$g_FF_bIsMinimized] = False
				EndIf
			Next
			AdlibRegister('__GUICtrlFFLabel_DelayedRefresh', 100)
		Case 1;minimize
			For $i = 1 To $g_aGDILbs[0][0]
				If $g_aGDILbs[$i][$g_FF_hGUI] = $hWndGUI Then $g_aGDILbs[$i][$g_FF_bIsMinimized] = True
			Next
		Case 2;Maximize
			AdlibRegister('__GUICtrlFFLabel_DelayedRefresh', 100)
	EndSwitch

	Return 'GUI_RUNDEFMSG'

EndFunc   ;==>__GUICtrlFFLabel_WM_SIZE
Func __GUICtrlFFLabel_WM_SIZING()
	_GUICtrlFFLabel_Refresh()
	Return 'GUI_RUNDEFMSG'
EndFunc   ;==>__GUICtrlFFLabel_WM_SIZING
Func __GUICtrlFFLabel_DelayedRefresh()
	_GUICtrlFFLabel_Refresh()
	AdlibUnRegister('__GUICtrlFFLabel_DelayedRefresh')
EndFunc   ;==>__GUICtrlFFLabel_DelayedRefresh
#endregion internal functions