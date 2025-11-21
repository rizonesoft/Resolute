#Region Header
; #INDEX# =======================================================================================================================
; Title .........: SLG
; AutoIt Version : 3.3.4.0
; Language ......: English
; Description ...: Functions to assist in creating and updating Scrolling Line Graphs
; Author(s) .....: Beege
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_SLG_CreateGraph
;_SLG_UpdateGraph
;_SLG_ClearGraph
;_SLG_SetLineColor
;_SLG_SetYRange
;_SLG_SetBackGroundColor
;_SLG_AddLine
;_SLG_SetLineValue
;_SLG_SetLineWidth
;_SLG_EnableGridLines
;_SLG_SetGridLineColor
; ===============================================================================================================================

#Region User KeyWords and CallTips
#cs

Keywords:
au3.keywords.user.udfs= _slg_creategraph _slg_updategraph _slg_cleargraph \
_slg_setlinecolor _slg_setyrange _slg_setbackgroundcolor _slg_addline \
_slg_setlinevalue _slg_setlinewidth _slg_enablegridlines _slg_setgridlinecolor

CallTips:
_SLG_CreateGraph($hGUI, $iLeft, $iTop, $iWidth, $iHeight, $iY_Min, $iY_Max, $iIncrements, $Line_Color = 0xFF00FF00, $Line_Width = 2, $iBackGround = 0xFF000000, $bGridlines = True)
_SLG_UpdateGraph($iIndex)
_SLG_AddLine($iIndex, $Line_Color = 0xFF00FF00, $Line_Width = 2)
_SLG_ClearGraph($iIndex)
_SLG_SetLineValue($iIndex, $iValue, $iLine = 1)
_SLG_SetLineColor($iIndex, $iARGB, $iLine = 1)
_SLG_SetLineWidth($iIndex, $iWidth, $iLine = 1)
_SLG_SetYRange($iIndex, $iY_Min, $iY_Max)
_SLG_SetBackGroundColor($iIndex, $iARGB = 0xFF000000)
_SLG_SetGridLineColor($iIndex, $iARGB = Default)
_SLG_EnableGridLines($iIndex, $bGridlines = True)
#ce
#EndRegion

#include-once
#include <Color.au3>
#include <GDIPlus.au3>
#include <WindowsConstants.au3>
_GDIPlus_Startup()
OnAutoItExitRegister('_SLG_Exit')
#EndRegion Header

#Region Global Variables and Constants
Global Enum $g_hGraphic, $g_hBitmap, $g_hBuffer, $g_aPens, $g_iLeft, $g_iTop, $g_iWidth, $g_iHeight, $g_iIncrements, _
		$g_iIncrement_Size, $g_iShift_Distance, $g_iY, $g_iY_Last, $g_iY_Min, $g_iY_Max, $g_iY_Range, $g_hDC, $g_hGUI, $g_iBackColor, _
		$g_iX_counter, $g_iY_counter, $g_iX_counter_mem, $g_bGridlines, $g_iGridColor, $MAX
Global $aGraphs[1][$MAX]
$aGraphs[0][0] = 0
#cs

	$aGraphs[0][0]			= List Count
	[0][1-17]    			= Nothing

	$aGraphs[$i][0] 		= $Graphic Object Handle
	[$i][$g_hBitmap]     	= Bitmap Object Handle
	[$i][$g_hBuffer]    	= Buffer Handle
	[$i][$g_iLeft]     		= Left
	[$i][$g_iTop]     		= Top
	[$i][$g_iWidth]     	= Width
	[$i][$g_iHeight]  		= Height
	[$i][$g_iIncrements]    = Step Count
	[$i][$g_iIncrement_Size]= Step Size
	[$i][$g_iShift_Distance]= Shift Distance
	[$i][$g_iY_Min]     	= Y Min
	[$i][$g_iY_Max]     	= Y Max
	[$i][$g_iY_Range]     	= Y Range
	[$i][$g_hDC]     		= Display device context Handle
	[$i][$g_hGUI]     		= GUI Handle
	[$i][$g_iBackColor]     = BackGround Color value
	[$i][$g_iY_Last]     	= Array containing Last Y Cordnate for each Line
	[$i][$g_iY]     		= Array containing Y Cordnate for each Line
	[$i][$g_aPens]     		= Array containing Pen Handles for each Line
	[$i][$g_bGridlines]     = Draw GridLines flag
	[$i][$g_iGridColor]     = GridLines Color Value
	[$i][$g_iX_counter]     = Counter for X GridLines
	[$i][$g_iY_counter]     = Counter for Y GridLines
	[$i][$g_iX_counter_mem] = Original Counter Value

#ce
#EndRegion Global Variables and Constants

#Region Public Functions
; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_CreateGraph
; Description ...: Creates a Scrolling Line Graph
; Syntax.........: _SLG_CreateGraph($hGUI, $iLeft, $iTop, $iWidth, $iHeight, $iY_Min, $iY_Max, $iIncrement_Total, $Line_Color = 0xFF00FF00, $iBackGround = 0xFF000000)
; Parameters ....: $hGUI       	- Handle to parent or owner window
;                  $iLeft 		- Left side of the graph
;                  $iTop    	- Top side of the graph
;                  $iWidth 		- Width of the graph
;                  $iHeight    	- Height of the graph
;                  $iY_Min     	- Minimum Y Value
;                  $iY_Max     	- Maximum Y Value
;				   $iIncrements - How many parts the Graph is divided up into. More Parts means more history..
;                  $Line_Color  - Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB). Default = Green
;                  $iLine_Width - Line Width. Default = 1
;                  $iBackGround	- BackGround Color. Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB). Default = Black
;				   $bGridlines  - Enable Gridlines. Default = True
; Return values .: Success      - Graph Index
; Author ........: Beege
; Remarks .......: Line index of line created is 1.
; ===============================================================================================================================
Func _SLG_CreateGraph($hGUI, $iLeft, $iTop, $iWidth, $iHeight, $iY_Min, $iY_Max, $iIncrements, $Line_Color = 0xFF00FF00, $iLine_Width = 2, $iBackGround = 0xFF000000, $bGridlines = True)

	ReDim $aGraphs[UBound($aGraphs) + 1][UBound($aGraphs, 2)]
	$aGraphs[0][0] += 1

	If $Line_Color = -1 Or $Line_Color = Default Then $Line_Color = 0xFF00FF00
	If $iBackGround = -1 Or $iBackGround = Default Then $iBackGround = 0xEE151D25
	If $iLine_Width = -1 Or $iLine_Width = Default Then $iLine_Width = 2
	If $bGridlines = -1 Or $bGridlines = Default Then $bGridlines = True

	$aGraphs[$aGraphs[0][0]][$g_hGraphic] = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	$aGraphs[$aGraphs[0][0]][$g_hBitmap] = _GDIPlus_BitmapCreateFromGraphics($iWidth, $iHeight, $aGraphs[$aGraphs[0][0]][$g_hGraphic])
	$aGraphs[$aGraphs[0][0]][$g_hBuffer] = _GDIPlus_ImageGetGraphicsContext($aGraphs[$aGraphs[0][0]][$g_hBitmap])
	$aGraphs[$aGraphs[0][0]][$g_iLeft] = $iLeft
	$aGraphs[$aGraphs[0][0]][$g_iTop] = $iTop
	$aGraphs[$aGraphs[0][0]][$g_iWidth] = $iWidth
	$aGraphs[$aGraphs[0][0]][$g_iHeight] = $iHeight
	$aGraphs[$aGraphs[0][0]][$g_iIncrements] = $iIncrements
	$aGraphs[$aGraphs[0][0]][$g_iIncrement_Size] = Int($iWidth / $iIncrements)
	$aGraphs[$aGraphs[0][0]][$g_iShift_Distance] = $iWidth - $aGraphs[$aGraphs[0][0]][$g_iIncrement_Size]
	_SLG_AddLine($aGraphs[0][0], $Line_Color, $iLine_Width)
	$aGraphs[$aGraphs[0][0]][$g_iY_Min] = $iY_Min
	$aGraphs[$aGraphs[0][0]][$g_iY_Max] = $iY_Max
	_SLG_SetYRange($aGraphs[0][0], $iY_Min, $iY_Max)
	$aGraphs[$aGraphs[0][0]][$g_hDC] = _WinAPI_GetDC($hGUI)
	$aGraphs[$aGraphs[0][0]][$g_hGUI] = $hGUI
	_SLG_SetBackGroundColor($aGraphs[0][0], BitOR($iBackGround, 0x00071320))
	$aGraphs[$aGraphs[0][0]][$g_bGridlines] = $bGridlines
	$aGraphs[$aGraphs[0][0]][$g_iX_counter] = 9;$iX_c
	$aGraphs[$aGraphs[0][0]][$g_iX_counter_mem] = 9;$iX_c
	$aGraphs[$aGraphs[0][0]][$g_iY_counter] = 9;$iY_c
	$aGraphs[$aGraphs[0][0]][$g_iGridColor] = Default
	_GDIPlus_GraphicsSetSmoothingMode($aGraphs[$aGraphs[0][0]][$g_hBuffer], 2)

	_GDIPlus_GraphicsClear($aGraphs[$aGraphs[0][0]][$g_hBuffer], $aGraphs[$aGraphs[0][0]][$g_iBackColor]);
	If $bGridlines Then _FullGridLines($aGraphs[0][0])
	Return $aGraphs[0][0]

EndFunc   ;==>_SLG_CreateGraph

; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_UpdateGraph
; Description ...: Updates Line Graph with new values
; Syntax.........: _SLG_UpdateGraph($iIndex, $iValue)
; Parameters ....: $iIndex		- Index returned from _SLG_CreateGraph()
; Return values .: Success      - 1
;                  Failure      - 0  and sets @ERROR:
;								- 1 Invalid iIndex
; Author ........: Beege
; Remarks .......: All Lines of the graph must be updated before calling this function.
; ===============================================================================================================================
Func _SLG_UpdateGraph($iIndex)

	If $iIndex > $aGraphs[0][0] Then Return SetError(1, @extended, 0)

	Local $aLineY = $aGraphs[$iIndex][$g_iY]

	For $i = 1 To $aLineY[0]
		If Not $aLineY[$i] Then Return
	Next

	Local $hShift_Section = _GDIPlus_BitmapCloneArea($aGraphs[$iIndex][$g_hBitmap], $aGraphs[$iIndex][$g_iIncrement_Size], 0, $aGraphs[$iIndex][$g_iShift_Distance], $aGraphs[$iIndex][$g_iHeight]);
	_GDIPlus_GraphicsClear($aGraphs[$iIndex][$g_hBuffer], $aGraphs[$iIndex][$g_iBackColor]);
	_GDIPlus_GraphicsDrawImageRect($aGraphs[$iIndex][$g_hBuffer], $hShift_Section, 0, 0, $aGraphs[$iIndex][$g_iShift_Distance], $aGraphs[$iIndex][$g_iHeight])

	If $aGraphs[$iIndex][$g_bGridlines] Then _AddGridLines($iIndex)

	Local $aLineYLast = $aGraphs[$iIndex][$g_iY_Last]
	Local $aPens = $aGraphs[$iIndex][$g_aPens]

	For $i = 1 To $aLineYLast[0]
		_GDIPlus_GraphicsDrawLine($aGraphs[$iIndex][$g_hBuffer], $aGraphs[$iIndex][$g_iShift_Distance] - 1, $aLineYLast[$i], $aGraphs[$iIndex][$g_iWidth] - 1, $aLineY[$i], $aPens[$i])
	Next
	_WriteBuffer($iIndex)

	_GDIPlus_BitmapDispose($hShift_Section)
	For $i = 1 To $aLineY[0]
		$aLineYLast[$i] = $aLineY[$i]
	Next
	$aGraphs[$iIndex][$g_iY_Last] = $aLineYLast

	Return 1

EndFunc   ;==>_SLG_UpdateGraph

; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_SetLineValue
; Description ...: Sets Line value
; Syntax.........: _SLG_SetLineValue($iIndex, $iValue, $iLine = 1)
; Parameters ....: $iIndex		- Index returned from _SLG_CreateGraph()
;                  $iValue 		- Value to add to graph
;                  $iLine 		- Line index returned from _SLG_AddLine()
; Return values .: Success      - 1
;                  Failure      - 0  and sets @ERROR:
;								- 1 Invalid iIndex
; Author ........: Beege
; Remarks .......: If your graph only has 1 line then the line index is 1
; ===============================================================================================================================
Func _SLG_SetLineValue($iIndex, $iValue, $iLine = 1)

	If $iIndex > $aGraphs[0][0] Then Return SetError(1, @extended, 0)

	If $iValue > $aGraphs[$iIndex][$g_iY_Max] Then
		$iValue = $aGraphs[$iIndex][$g_iY_Max]
	ElseIf $iValue < $aGraphs[$iIndex][$g_iY_Min] Then
		$iValue = $aGraphs[$iIndex][$g_iY_Min]
	EndIf

	Local $Percent = Abs($iValue - $aGraphs[$iIndex][$g_iY_Min]) / $aGraphs[$iIndex][$g_iY_Range]
	If $Percent > .992 Then $Percent = .992

	Local $iY = Int($aGraphs[$iIndex][$g_iHeight] - ($Percent * $aGraphs[$iIndex][$g_iHeight]))

	Local $aLineYLast = $aGraphs[$iIndex][$g_iY_Last]

	If Not $aLineYLast[$iLine] Then
		$aLineYLast[$iLine] = $iY
		$aGraphs[$iIndex][$g_iY_Last] = $aLineYLast
		Return 0
	Else
		Local $aLineY = $aGraphs[$iIndex][$g_iY]
		$aLineY[$iLine] = $iY
		$aGraphs[$iIndex][$g_iY] = $aLineY
		Return 1
	EndIf

EndFunc   ;==>_SLG_SetLineValue

; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_AddLine
; Description ...: Adds additional lines to the graph
; Syntax.........: _SLG_AddLine($iIndex, $Line_Color = 0xFF00FF00, $Line_Width = 1)
; Parameters ....: $iIndex		- Index returned from _SLG_CreateGraph()
;                  $iLine_Color	- Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB)
;                  $Line_Width	- Line Width
; Return values .: Success      - Line Index
;                  Failure      - 0  and sets @ERROR:
;								- 1 Invalid iIndex
; Author ........: Beege
; Remarks .......: Every line must have its value set before you can call _SLG_UpdateGraph()
; ===============================================================================================================================
Func _SLG_AddLine($iIndex, $Line_Color = 0xFF00FF00, $Line_Width = 2)

	If $iIndex > $aGraphs[0][0] Then Return SetError(1, @extended, 0)

	If $Line_Color = -1 Or $Line_Color = Default Then $Line_Color = 0xFF00FF00
	If $Line_Width = -1 Or $Line_Width = Default Then $Line_Width = 1

	Local $aLinesY = $aGraphs[$iIndex][$g_iY]
	Local $aLinesYLast = $aGraphs[$iIndex][$g_iY_Last]
	Local $aPens = $aGraphs[$iIndex][$g_aPens]

	If Not IsArray($aLinesYLast) Then
		Local $aLinesY[1] = [0]
		Local $aLinesYLast[1] = [0]
		Local $aPens[1] = [0]
	EndIf

	ReDim $aLinesYLast[UBound($aLinesYLast) + 1]
	ReDim $aLinesY[UBound($aLinesY) + 1]
	ReDim $aPens[UBound($aPens) + 1]

	$aLinesYLast[0] += 1
	$aLinesY[0] += 1
	$aPens[0] += 1

	$aLinesYLast[$aLinesYLast[0]] = False
	$aLinesY[$aLinesY[0]] = False
	$aPens[$aPens[0]] = _GDIPlus_PenCreate($Line_Color, $Line_Width)

	$aGraphs[$iIndex][$g_iY_Last] = $aLinesYLast
	$aGraphs[$iIndex][$g_iY] = $aLinesY
	$aGraphs[$iIndex][$g_aPens] = $aPens

	Return $aLinesY[0]

EndFunc   ;==>_SLG_AddLine

; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_SetLineColor
; Description ...: Sets Line Color of Graph
; Syntax.........: _SLG_SetLineColor($iIndex, $iARGB)
; Parameters ....: $iIndex		- Index returned from _SLG_CreateGraph()
;                  $iValue 		- Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB)
;                  $iLine 		- Line index returned from _SLG_AddLine()
; Return values .: Success      - 1
;                  Failure      - 0  and sets @ERROR:
;								- 1 Invalid iIndex
;								- 2 Invalid iLine
;								- 3 Error setting pen color
; Author ........: Beege
; Remarks .......: If your graph only has 1 line then the line index is 1
; ===============================================================================================================================
Func _SLG_SetLineColor($iIndex, $iARGB, $iLine = 1)

	If $iIndex > $aGraphs[0][0] Then Return SetError(1, @extended, 0)

	Local $aPens = $aGraphs[$iIndex][$g_aPens]
	If $iLine > $aPens[0] Then Return SetError(2, @extended, 0)

	_GDIPlus_PenSetColor($aPens[$iLine], $iARGB)
	If @error Then Return SetError(3, @extended, 0)

	Return 1

EndFunc   ;==>_SLG_SetLineColor

; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_SetLineWidth
; Description ...: Sets Line Width
; Syntax.........: _SLG_SetLineWidth($iIndex, $iWidth, $iLine = 1)
; Parameters ....: $iIndex		- Index returned from _SLG_CreateGraph()
;                  $iValue 		- Width of Line
;                  $iLine 		- Line index returned from _SLG_AddLine()
; Return values .: Success      - 1
;                  Failure      - 0  and sets @ERROR:
;								- 1 Invalid iIndex
;								- 2 Invalid iLine index
;								- 3 Error setting pen width
; Author ........: Beege
; Remarks .......: If your graph only has 1 line then the line index is 1
; ===============================================================================================================================
Func _SLG_SetLineWidth($iIndex, $iWidth, $iLine = 1)

	If $iIndex > $aGraphs[0][0] Then Return SetError(1, @extended, 0)

	Local $aPens = $aGraphs[$iIndex][$g_aPens]
	If $iLine > $aPens[0] Then Return SetError(2, @extended, 0)

	Local $aPens = $aGraphs[$iIndex][$g_aPens]
	_GDIPlus_PenSetWidth($aPens[$iLine], $iWidth)
	If @error Then Return SetError(3, @extended, 0)

	Return 1

EndFunc   ;==>_SLG_SetLineWidth

; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_ClearGraph
; Description ...: Clears all data from Graph
; Syntax.........: _SLG_ClearGraph($iIndex)
; Parameters ....: $iIndex		- Index returned from _SLG_CreateGraph()
; Return values .: Success      - 1
;                  Failure      - 0  and sets @ERROR:
;								- 1 Invalid iIndex
; Author ........: Beege
; Remarks .......: none
; ===============================================================================================================================
Func _SLG_ClearGraph($iIndex)

	If $iIndex > $aGraphs[0][0] Then Return SetError(1, @extended, 0)

	_GDIPlus_GraphicsClear($aGraphs[$iIndex][$g_hBuffer], $aGraphs[$iIndex][$g_iBackColor]);
	If $aGraphs[$iIndex][$g_bGridlines] Then _FullGridLines($iIndex)
	_WriteBuffer($iIndex)

	Return 1

EndFunc   ;==>_SLG_ClearGraph

; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_SetYRange
; Description ...: Sets the Minimum and Maximum Y Values
; Syntax.........: _SLG_SetYRange($iIndex, $iY_Min, $iY_Max)
; Parameters ....: $iIndex		- Index returned from _SLG_CreateGraph()
;                  $iY_Min      - Minimum Y Value
;                  $iY_Max      - Maximum Y Value
; Return values .: Success      - 1
;                  Failure      - 0  and sets @ERROR:
;								- 1 Invalid iIndex
; Author ........: Beege
; Remarks .......: User should most likly want to ClearGraph after changing Y Range
; ===============================================================================================================================
Func _SLG_SetYRange($iIndex, $iY_Min, $iY_Max)

	If $iIndex > $aGraphs[0][0] Then Return SetError(1, @extended, 0)

	$aGraphs[$iIndex][$g_iY_Min] = $iY_Min
	$aGraphs[$iIndex][$g_iY_Max] = $iY_Max
	$aGraphs[$iIndex][$g_iY_Range] = Abs($iY_Max - $iY_Min)

	Return 1

EndFunc   ;==>_SLG_SetYRange

; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_SetBackGroundColor
; Description ...: Sets Graph BackGround Color
; Syntax.........: _SLG_SetBackGroundColor($iIndex, $iARGB = 0xFF000000)
; Parameters ....: $iIndex		- Index returned from _SLG_CreateGraph()
;                  $iARGB      	- Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB). Default = Black
; Return values .: Success      - 1
;                  Failure      - 0  and sets @ERROR:
;								- 1 Invalid iIndex
; Author ........: Beege
; Remarks .......: All previous data will be cleared
; ===============================================================================================================================
Func _SLG_SetBackGroundColor($iIndex, $iARGB = 0xFF0141b22)

	If $iIndex > $aGraphs[0][0] Then Return SetError(1, @extended, 0)

	$aGraphs[$iIndex][$g_iBackColor] = $iARGB
	_SLG_ClearGraph($iIndex)

	Return 1

EndFunc   ;==>_SLG_SetBackGroundColor

; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_SetGridLineColor($iIndex)
; Description ...: Sets Graph GridLines Color Value
; Syntax.........: _SLG_SetGridLineColor($iIndex, $iARGB = Default)
; Parameters ....: $iIndex		- Index returned from _SLG_CreateGraph()
;                  $iARGB      	- Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB). Default = Invert of Background Color.
; Return values .: Success      - 1
;                  Failure      - 0  and sets @ERROR:
;								- 1 Invalid iIndex
; Author ........: Beege
; Remarks .......: All previous data will be cleared
; ===============================================================================================================================
Func _SLG_SetGridLineColor($iIndex, $iARGB = Default)

	If $iIndex > $aGraphs[0][0] Then Return SetError(1, @extended, 0)

	$aGraphs[$iIndex][$g_iGridColor] = $iARGB
	_SLG_ClearGraph($iIndex)

	Return 1

EndFunc   ;==>_SLG_SetGridLineColor

; #FUNCTION# ====================================================================================================================
; Name...........: _SLG_EnableGridLines
; Description ...: Enables or Disables Drawing of Gridlines for Graph
; Syntax.........: _SLG_EnableGridLines($iIndex, $bGridlines = True)
; Parameters ....: $iIndex		- Index returned from _SLG_CreateGraph()
;                  $bGridlines 	- GridLines flag:
;                  |True  - GridLines will be drawn
;                  |False - GridLines will not be drawn
; Return values .: Success      - 1
;                  Failure      - 0  and sets @ERROR:
;								- 1 Invalid iIndex
;								- 2 Invalid $bGridlines Value
; Author ........: Beege
; Remarks .......: none
; ===============================================================================================================================
Func _SLG_EnableGridLines($iIndex, $bGridlines = True)

	If $iIndex > $aGraphs[0][0] Then Return SetError(1, @extended, 0)
	If $bGridlines <> True And $bGridlines <> False Then SetError(2, @extended, 0)

	$aGraphs[$iIndex][$g_bGridlines] = $bGridlines

	Return 1

EndFunc   ;==>_SLG_EnableGridLines

#EndRegion Public Functions
#Region Internel Functions
; #FUNCTION# ====================================================================================================================
; Author ........: UEZ
; Modified ......: Beege
; ===============================================================================================================================
Func _AddGridLines($iIndex)
	Local $iGridlineColor = $aGraphs[$iIndex][$g_iGridColor]

	If $iGridlineColor = Default Or $iGridlineColor = -1 Then $iGridlineColor = 0x11FFFFFF
	;If $iGridlineColor = Default Or $iGridlineColor = -1 Then $iGridlineColor = BitOR(0xFF000000, (0xFFFFFFFF - $aGraphs[$iIndex][$g_iBackColor]));Invert Background RGB

	Local $iY1, $hPen = _GDIPlus_PenCreate($iGridlineColor)

	For $iY1 = 0 To $aGraphs[$iIndex][$g_iHeight] Step $aGraphs[$iIndex][$g_iY_counter]
		_GDIPlus_GraphicsDrawLine($aGraphs[$iIndex][$g_hBuffer], $aGraphs[$iIndex][$g_iShift_Distance] - 1, $iY1, $aGraphs[$iIndex][$g_iWidth], $iY1, $hPen)
	Next
	If $aGraphs[$iIndex][$g_iX_counter] <= 0 Then
		_GDIPlus_GraphicsDrawLine($aGraphs[$iIndex][$g_hBuffer], $aGraphs[$iIndex][$g_iWidth] - 1, 0, $aGraphs[$iIndex][$g_iWidth] - 1, $aGraphs[$iIndex][$g_iHeight], $hPen)
		$aGraphs[$iIndex][$g_iX_counter] = $aGraphs[$iIndex][$g_iX_counter_mem]
	EndIf
	$aGraphs[$iIndex][$g_iX_counter] -= $aGraphs[$iIndex][$g_iIncrement_Size]

	_GDIPlus_PenDispose($hPen)

EndFunc   ;==>_AddGridLines

Func _FullGridLines($iIndex)
	Local $iGridlineColor = $aGraphs[$iIndex][$g_iGridColor]

	If $iGridlineColor = Default Or $iGridlineColor = -1 Then $iGridlineColor = 0x11FFFFFF
	;If $iGridlineColor = Default Or $iGridlineColor = -1 Then $iGridlineColor = BitOR(0xFF000000, (0xFFFFFFFF - $aGraphs[$iIndex][$g_iBackColor]));Invert Background RGB

	Local $iY1, $hPen = _GDIPlus_PenCreate($iGridlineColor)
	Local $hShift_Section = _GDIPlus_BitmapCloneArea($aGraphs[$iIndex][$g_hBitmap], 0, 0, $aGraphs[$iIndex][$g_iWidth], $aGraphs[$iIndex][$g_iHeight]);
	_GDIPlus_GraphicsClear($aGraphs[$iIndex][$g_hBuffer], $aGraphs[$iIndex][$g_iBackColor]);
	_GDIPlus_GraphicsDrawImageRect($aGraphs[$iIndex][$g_hBuffer], $hShift_Section, 0, 0, $aGraphs[$iIndex][$g_iWidth], $aGraphs[$iIndex][$g_iHeight])
	For $iY1 = 0 To $aGraphs[$iIndex][$g_iHeight] Step $aGraphs[$iIndex][$g_iY_counter]
		_GDIPlus_GraphicsDrawLine($aGraphs[$iIndex][$g_hBuffer], 0, $iY1, $aGraphs[$iIndex][$g_iWidth], $iY1, $hPen)
	Next

	For $iX = 0 To $aGraphs[$iIndex][$g_iWidth] Step $aGraphs[$iIndex][$g_iIncrement_Size]
		If $aGraphs[$iIndex][$g_iX_counter] <= 0 Then
			_GDIPlus_GraphicsDrawLine($aGraphs[$iIndex][$g_hBuffer], $iX, 0, $iX, $aGraphs[$iIndex][$g_iHeight], $hPen)
			$aGraphs[$iIndex][$g_iX_counter] = $aGraphs[$iIndex][$g_iX_counter_mem]
		EndIf
		$aGraphs[$iIndex][$g_iX_counter] -= $aGraphs[$iIndex][$g_iIncrement_Size]
	Next
	_WriteBuffer($iIndex)
	_GDIPlus_BitmapDispose($hShift_Section)
	_GDIPlus_PenDispose($hPen)

EndFunc   ;==>_FullGridLines

Func _WriteBuffer($iIndex)

	Local $hGDI_HBitmap, $hDC

	$hGDI_HBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($aGraphs[$iIndex][$g_hBitmap])
	$hDC = _WinAPI_CreateCompatibleDC($aGraphs[$iIndex][$g_hDC])
	_WinAPI_SelectObject($hDC, $hGDI_HBitmap)
	_WinAPI_BitBlt($aGraphs[$iIndex][$g_hDC], $aGraphs[$iIndex][$g_iLeft], $aGraphs[$iIndex][$g_iTop], $aGraphs[$iIndex][$g_iWidth], $aGraphs[$iIndex][$g_iHeight], $hDC, 0, 0, $SRCCOPY)
	_WinAPI_DeleteObject($hGDI_HBitmap)
	_WinAPI_DeleteDC($hDC)

EndFunc   ;==>_WriteBuffer

Func _SLG_Exit()

	Local $i, $j, $aPens

	If $aGraphs[0][0] Then
		For $i = 1 To $aGraphs[0][0]
			_GDIPlus_GraphicsDispose($aGraphs[$i][$g_hBuffer])
			_GDIPlus_BitmapDispose($aGraphs[$i][$g_hBitmap])
			_GDIPlus_GraphicsDispose($aGraphs[$i][$g_hGraphic])
			$aPens = $aGraphs[$i][$g_aPens]
			For $j = 1 To $aPens[0]
				_GDIPlus_PenDispose($aPens[$j])
			Next
			_WinAPI_ReleaseDC($aGraphs[$i][$g_hGUI], $aGraphs[$i][$g_hDC])
		Next
	EndIf

	_GDIPlus_Shutdown()

EndFunc   ;==>_SLG_Exit
#EndRegion Internel Functions
