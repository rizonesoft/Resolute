;
#Region Header
; #INDEX# =======================================================================================================================
; Title ............: SSLG
; AutoIt Version ...: 3.3.14.5
; Language .........: English
; Description ......: Functions to assist in creating and updating Scrolling Single Line Graphs
; Original Author(s): Beege ;http://www.autoitscript.com/forum/index.php?showtopic=109599
; Author(s) ........: Bilgus
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_SSLG_CreateGraph
;_SSLG_AddSample
;_SSLG_UpdateGraph
;_SSLG_SetSetSampleIndicator
;_SSLG_SetGrid
;_SSLG_SetLine
;_SSLG_SetSmoothingMode
;_SSLG_ClearGraph
;_SSLG_SetYRange
;_SSLG_SetBackGroundColor
; ===============================================================================================================================

#include-once
#include <GDIPlus.au3>
#include <WindowsConstants.au3>

_GDIPlus_Startup()
OnAutoItExitRegister(__SSLG_Exit)
#EndRegion Header

#Region Global Variables and Constants
Global Const $gSSLG_DICT = 1
Global Enum $gSSLG_idCtrl, $gSSLG_aRect, $gSSLG_hCtrl, $gSSLG_hPen, $gSSLG_hPenSamp, $gSSLG_hPenGrid, $gSSLG_hBrushLine, $gSSLG_hBrushBkgnd, _
		$gSSLG_hDCBuf, $gSSLG_hHBitmapGDI_, $gSSLG_hBitmap_1, $gSSLG_hGrBuf_1, $gSSLG_hBitmap_0, $gSSLG_hGrBuf_0, $gSSLG_hPathGridH, _
		$gSSLG_iY_Min, $gSSLG_iY_Max, $gSSLG_iY_Range, $gSSLG_iY_Last, $gSSLG_iX_Inc, $gSSLG_hPathLine, $gSSLG_hPathGridV, $gSSLG_hMatrixHT, _
		$gSSLG_bNeedResize, $gSSLG_iIncrements, $gSSLG_iIncrementSize, $gSSLG_iBackColor, $gSSLG_iSamples, $gSSLG_iSamplesTotal, $MAX

Global $g_SSLG[1][$MAX]

$g_SSLG[0][0] = 0
$g_SSLG[0][$gSSLG_DICT] = ObjCreate("Scripting.Dictionary")

#cs
	$g_SSLG[0][0]          = List Count
	[0][1]                  = Dictionary object (associative array)
	[0][2-27]               = Nothing

	[$i][$gSSLG_idCtrl]         = ControlID
	[$i][$gSSLG_aRect]          = Control position array [x, y, w, h]
	[$i][$gSSLG_hCtrl]          = Control Handle
	[$i][$gSSLG_hPen]           = Line Pen Handle
	[$i][$gSSLG_hPenSamp]       = Sample Finished Pen Handle
	[$i][$gSSLG_hPenGrid]       = Gridline Pen Handle
	[$i][$gSSLG_hBrushLine]     = Brush to fill under graph line
	[$i][$gSSLG_hBrushBkgnd]    = Brush for background ([$gSSLG_iBackColor])

	[$i][$gSSLG_hDCBuf]         = Device context Handle for buffer
	[$i][$gSSLG_hHBitmapGDI_]   = Standard GDI bitmap (selected into hDCBuf)
	[$i][$gSSLG_hBitmap_1]      = Buffer 1 Bitmap Object Handle
	[$i][$gSSLG_hGrBuf_1]       = Buffer 1 Graphic Object Handle
	[$i][$gSSLG_hBitmap_0]      = Buffer 0 Bitmap Object Handle
	[$i][$gSSLG_hGrBuf_0]       = Buffer 0 Graphic Object Handle

	[$i][$gSSLG_iY_Min]         = Y Min
	[$i][$gSSLG_iY_Max]         = Y Max
	[$i][$gSSLG_iY_Range]       = Y Range
	[$i][$gSSLG_iY_Last]        = Last Y Coordinate

	[$i][$gSSLG_iX_Inc]         = Vertical Gridline every #iX_Inc samples
	[$i][$gSSLG_hPathLine]      = Graphics Path Object Handle
	[$i][$gSSLG_hPathGridV]     = Graphics Path Object Handle Vertical Grid Lines
	[$i][$gSSLG_hPathGridH]		= Graphics Path Object Handle Horizontal Grid Lines
	[$i][$gSSLG_hMatrixHT]      = Graphics Path Horizontal Translation Matrice

	[$i][$gSSLG_bNeedResize]    = Resize graphics objects
	[$i][$gSSLG_iIncrements]    = Step Count
	[$i][$gSSLG_iIncrementSize] = Step Size
	[$i][$gSSLG_iBackColor]     = Background Color value
	[$i][$gSSLG_iSamples]       = Count of samples waiting to be drawn
	[$i][$gSSLG_iSamplesTotal]  = Count of total samples since ClearGraph()

#ce
#EndRegion Global Variables and Constants

#Region Public Functions
; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_CreateGraph
; Description ...: Creates a Scrolling Line Graph
; Syntax.........: _SSLG_CreateGraph($iLeft, $iTop, $iW, $iH, $iY_Min, $iY_Max, $iIncrements, $iBackGround = Default)

; Parameters ....:
;   $iLeft      - Left side of the graph
;   $iTop       - Top side of the graph
;   $iW             - Width of the graph
;   $iH             - Height of the graph
;   $iY_Min         - Minimum Y Value
;   $iY_Max         - Maximum Y Value
;   $iIncrements    - How many parts the Graph is divided up into.
;   $iBackGround    - BackGround Color. Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB). Default = Black

; Return values .: Success  - ControlId
; Author ........: Beege, Bilgus
; Remarks .......: $iIncrements will be rounded if $iW is not evenly divisible
; ===============================================================================================================================
Func _SSLG_CreateGraph($iLeft, $iTop, $iW, $iH, $iY_Min, $iY_Max, $iIncrements, $iBackGround = Default)
	If $iBackGround = Default Then $iBackGround = 0xFF000000

	ReDim $g_SSLG[UBound($g_SSLG) + 1][UBound($g_SSLG, 2)]
	$g_SSLG[0][0] += 1
	Local $oDict = $g_SSLG[0][$gSSLG_DICT]
	Local $iIdx = $g_SSLG[0][0]
	Local $aResult, $aPos

	Local $iCtrlID = GUICtrlCreateLabel("", $iLeft, $iTop, $iW, $iH, $WS_CLIPSIBLINGS)
	Local $hCtrl = GUICtrlGetHandle($iCtrlID)

	If $iW < 0 Or $iH < 0 Then ;Allow -W/H
		$aResult = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $hCtrl)
		If Not @error Then
			$aPos = WinGetClientSize($aResult[0])
			If Not @error Then
				If $iW < 0 Then $iW = $aPos[0] + $iW
				If $iH < 0 Then $iH = $aPos[1] + $iH
				GUICtrlSetPos($iCtrlID, $iLeft, $iTop, $iW, $iH)
			EndIf
		EndIf
	EndIf

	$g_SSLG[$iIdx][$gSSLG_idCtrl] = $iCtrlID
	$g_SSLG[$iIdx][$gSSLG_hCtrl] = $hCtrl

	Local $hDC = _WinAPI_GetDC($hCtrl)
	$g_SSLG[$iIdx][$gSSLG_hDCBuf] = _WinAPI_CreateCompatibleDC($hDC)
	_WinAPI_ReleaseDC($hCtrl, $hDC)

	;Store references
	$oDict.Add(Hex($iCtrlID), $iIdx)
	$oDict.Add(Hex($hCtrl), $iIdx)

	$g_SSLG[$iIdx][$gSSLG_iIncrements] = $iIncrements

	$g_SSLG[$iIdx][$gSSLG_hPathLine] = _GDIPlus_PathCreate() ;Create new path object
	$g_SSLG[$iIdx][$gSSLG_hPathGridV] = _GDIPlus_PathCreate() ;Create new path object
	$g_SSLG[$iIdx][$gSSLG_hPathGridH] = _GDIPlus_PathCreate() ;Create new path object
	$g_SSLG[$iIdx][$gSSLG_hMatrixHT] = _GDIPlus_MatrixCreate() ;Horizontal translation matrix

	;Initially these are disabled; use _SetGrid & _SetSampleIndicator
	$g_SSLG[$iIdx][$gSSLG_hPenSamp] = False
	$g_SSLG[$iIdx][$gSSLG_hPenGrid] = False

	$g_SSLG[$iIdx][$gSSLG_iBackColor] = __SSLG_RGB_ARGB($iBackGround)
	$g_SSLG[$iIdx][$gSSLG_hBrushBkgnd] = _GDIPlus_BrushCreateSolid($g_SSLG[$iIdx][$gSSLG_iBackColor])
	GUICtrlSetBkColor(-1, BitAND(BitNOT(0xFF000000), $iBackGround))
	GUICtrlSetColor(-1, 0xFFFFFF)

	_SSLG_SetLine($iCtrlID, 0xFF00FF00, 2)

	$g_SSLG[$iIdx][$gSSLG_iY_Last] = False
	$g_SSLG[$iIdx][$gSSLG_iX_Inc] = 0

	$g_SSLG[$iIdx][$gSSLG_iSamples] = 0
	$g_SSLG[$iIdx][$gSSLG_iSamplesTotal] = 0

	_SSLG_SetYRange($iCtrlID, $iY_Min, $iY_Max)

	_SSLG_SetSmoothingMode($iCtrlID)

	$g_SSLG[$iIdx][$gSSLG_bNeedResize] = True
	_SSLG_ClearGraph($iCtrlID)

	Return $iCtrlID

EndFunc   ;==>_SSLG_CreateGraph

; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_AddSample
; Description ...: Adds a new value to Line Graph
; Syntax.........: _SSLG_AddSample($iIdx, $iValue)
; Parameters ....: $idSSLG - Control ID returned from _SSLG_CreateGraph()
;                  $iValue - Value to add to graph Default advances graph without a data point displayed
; Return values .: Success  - 1
;   Failure     - 0 and sets @ERROR:
;                               - 1 Invalid iIndex
;                               - 3 Too many samples ~truncated
;                               - 4 Busy in another SSLG function
; Author ........: Bilgus
; Remarks .......: Adding too many samples between calls to UpdateGraph will cause samples to be lost
; ===============================================================================================================================

Func _SSLG_AddSample($idSSLG, $iValue = Default)
	Local $iIdx = __SSLG_LookupHandle($idSSLG, True)
	If $iIdx > $g_SSLG[0][0] Then Return SetError(1, @extended, 0)

	Local $hPath = $g_SSLG[$iIdx][$gSSLG_hPathLine]
	Local $hPath_Grid = $g_SSLG[$iIdx][$gSSLG_hPathGridV]
	Local $aRect = $g_SSLG[$iIdx][$gSSLG_aRect]
	Local $iH = $aRect[3]
	
	Local $iY = $g_SSLG[$iIdx][$gSSLG_iY_Last]
	Local $iY_Last = $g_SSLG[$iIdx][$gSSLG_iY_Last]
	Local $iY_Min = $g_SSLG[$iIdx][$gSSLG_iY_Min]
	Local $iY_Max = $g_SSLG[$iIdx][$gSSLG_iY_Max]

	If $g_SSLG[$iIdx][$gSSLG_iY_Last] = Default And $iValue <> Default Then 
		Return SetError(4, @extended, 0)
	Else
		$g_SSLG[$iIdx][$gSSLG_iY_Last] = Default ;Used as Mutex
	EndIf

	If $g_SSLG[$iIdx][$gSSLG_iSamples] <= 0 Then ; First sample, reset paths
		_GDIPlus_PathReset($hPath)
		_GDIPlus_PathReset($g_SSLG[$iIdx][$gSSLG_hPathGridV])
	EndIf

	If $iValue <> Default Then
		If $iY_Min < $iY_Max Then
			$iY = $g_SSLG[$iIdx][$gSSLG_iY_Max] - $iValue ;Need to flip direction of Y
		Else
			$iY = $iValue
		EndIf
		If Not $iY_Last Then $iY_Last = $iY
		_GDIPlus_PathAddLine($hPath, $g_SSLG[$iIdx][$gSSLG_iSamples] - 1, $iY_Last, $g_SSLG[$iIdx][$gSSLG_iSamples], $iY)
		;ConsoleWrite(StringFormat("AddLine (%d, %d) (%d, %d) \r\n", $g_SSLG[$iIdx][$gSSLG_iSamples] - 1, $iY_Last, $g_SSLG[$iIdx][$gSSLG_iSamples], $iY ))
	EndIf

	If $g_SSLG[$iIdx][$gSSLG_hPenGrid] And Mod($g_SSLG[$iIdx][$gSSLG_iSamplesTotal], $g_SSLG[$iIdx][$gSSLG_iX_Inc]) = 0 Then
		;Make a new vertical grid line
		_GDIPlus_PathStartFigure($hPath_Grid)
		_GDIPlus_PathAddLine($hPath_Grid, $g_SSLG[$iIdx][$gSSLG_iSamples], $iY_Min, $g_SSLG[$iIdx][$gSSLG_iSamples], $iY_Max)
		_GDIPlus_PathCloseFigure($hPath_Grid)
	EndIf

	$g_SSLG[$iIdx][$gSSLG_iSamples] += 1
	$g_SSLG[$iIdx][$gSSLG_iSamplesTotal] += 1 ;Used to track gridline increment
	$g_SSLG[$iIdx][$gSSLG_iY_Last] = $iY ;Release Mutex

	If $g_SSLG[$iIdx][$gSSLG_iSamples] > $g_SSLG[$iIdx][$gSSLG_iIncrements] Then Return SetError(3, @extended, 0)

	Return 1

EndFunc   ;==>_SSLG_AddSample

; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_UpdateGraph
; Description ...: Updates Line Graph with new values
; Syntax.........: _SSLG_UpdateGraph($iIdx, $iValue)
; Parameters ....: $idSSLG - Control ID returned from _SSLG_CreateGraph()
;                  $bCompress - Compress end of graph rather than discard (slower)
;                  $bFill - Fill under the graph line with hBrushLine
;				   $bForce Update even though control is disabled
; Return values .: Success  - 1
;   @Extended   - Number of samples displayed
;   Failure     - 0 and sets @ERROR:
;                               - 1 Invalid iIndex
;                               - 2 No Samples
;                               - 3 Samples overflow graph
;                               - 4 Busy in another SSLG function
; Author ........: Bilgus
; Remarks .......: Flip Y_Min and Y_Max in the call to CreateGraph to change fill area from under to above
;                  $bCompress = True uses more CPU and increases memory churn due to GDI+ temp objects
; ===============================================================================================================================
Func _SSLG_UpdateGraph($idSSLG, $bCompress = False, $bFill = False, $bForce = False)
	Local $iIdx = __SSLG_LookupHandle($idSSLG, $bForce)
	If $iIdx > $g_SSLG[0][0] Then Return SetError(1, @extended, 0)
	Local $iErr = 0, $iY_Last

	If $g_SSLG[$iIdx][$gSSLG_bNeedResize] Then _SSLG_ClearGraph($idSSLG)

	Local $iSamples = $g_SSLG[$iIdx][$gSSLG_iSamples]

	If $iSamples < 1 Then
		Return SetError(2, @extended, 0)
	ElseIf $iSamples > $g_SSLG[$iIdx][$gSSLG_iIncrements] Then
		;ConsoleWrite("!Full!" & @CRLF)
		$iSamples = $g_SSLG[$iIdx][$gSSLG_iIncrements]
		$iErr = 3
	EndIf

	If $g_SSLG[$iIdx][$gSSLG_iY_Last] = Default Then
		SetError(4, @extended, 0) ; Currently in the AddSample or GraphClear Function
	Else
		$iY_Last = $g_SSLG[$iIdx][$gSSLG_iY_Last]
		$g_SSLG[$iIdx][$gSSLG_iY_Last] = Default ;Used as Mutex
	EndIf

	$g_SSLG[$iIdx][$gSSLG_iSamples] = 0

	Local $hPath = $g_SSLG[$iIdx][$gSSLG_hPathLine]

	Local $hMatrixHT = $g_SSLG[$iIdx][$gSSLG_hMatrixHT]

	Local $aRect = $g_SSLG[$iIdx][$gSSLG_aRect]
	Local $iW = $aRect[2]
	Local $iH = $aRect[3]

	Local $iIncrement = $g_SSLG[$iIdx][$gSSLG_iIncrementSize]
	Local $iInc_Total = $iIncrement * $iSamples
	Local $iShiftDist = $iW - $iInc_Total
	;ConsoleWrite(StringFormat("!Display (%d, %d; %d;) \r\n", $iSamples, $iInc_Total, $iShiftDist))

	Local $iHistX = $iInc_Total
	Local $iHistW = $iShiftDist
	If $bCompress Then
		$iHistX = 0
		$iHistW = $iW
	EndIf

	Local $aGraphic[2], $aBmp[2]
	Static Local $iLastBuf = 0
	;Swap back buffer each call
	Local $iBuf0 = $iLastBuf, $iBuf1 = (1 - $iLastBuf) ;Toggles 0,1
	$aGraphic[$iBuf0] = $g_SSLG[$iIdx][$gSSLG_hGrBuf_0]
	$aGraphic[$iBuf1] = $g_SSLG[$iIdx][$gSSLG_hGrBuf_1]
	$aBmp[$iBuf0] = $g_SSLG[$iIdx][$gSSLG_hBitmap_0]
	$aBmp[$iBuf1] = $g_SSLG[$iIdx][$gSSLG_hBitmap_1]
	$iLastBuf = $iBuf1

	;Shift/Copy/Compress the last data to the current bitmap
	_GDIPlus_GraphicsDrawImageRectRect($aGraphic[0], $aBmp[1], _
			$iHistX, 0, $iHistW, $iH, _ ;[Src XYWH]
			0, 0, $iShiftDist, $iH) ; [Dst XYWH]

	;Here we scale the path(points) to the size of the graph X increment and Y range
	_GDIPlus_MatrixSetElements($hMatrixHT, $iIncrement, 0, 0, (($iH - 1) / $g_SSLG[$iIdx][$gSSLG_iY_Range]), $iShiftDist, 0)

	If $bFill And _GDIPlus_PathGetPointCount($hPath) > 0 Then
		;Create 3 lines to enclose desired fill area -- If $iY_Min was used it'd fill top of graph instead
		Local $iY_F = $g_SSLG[$iIdx][$gSSLG_iY_Max]
		Static Local $tPoints = DllStructCreate("float[" & 3 * 2 & "]")
		DllStructSetData($tPoints, 1, $iSamples, 1)
		DllStructSetData($tPoints, 1, $iY_Last, 2)
		DllStructSetData($tPoints, 1, $iSamples, 3)
		DllStructSetData($tPoints, 1, $iY_F, 4)
		DllStructSetData($tPoints, 1, -1, 5)
		DllStructSetData($tPoints, 1, $iY_F, 6)
		DllCall($__g_hGDIPDll, "int", "GdipAddPathLine2", "handle", $hPath, "struct*", $tPoints, "int", 3)
		;_GDIPlus_PathSetFillMode ($hPath, 0)

		_GDIPlus_MatrixSetElements($hMatrixHT, $iIncrement, 0, 0, (($iH - 1) / $g_SSLG[$iIdx][$gSSLG_iY_Range]), $iShiftDist, 0)
		_GDIPlus_PathTransform($hPath, $hMatrixHT)
		_GDIPlus_GraphicsFillPath($aGraphic[0], $hPath, $g_SSLG[$iIdx][$gSSLG_hBrushLine])
		_GDIPlus_GraphicsDrawPath($aGraphic[0], $hPath, $g_SSLG[$iIdx][$gSSLG_hPen])
	Else
		_GDIPlus_MatrixSetElements($hMatrixHT, $iIncrement, 0, 0, (($iH - 1) / $g_SSLG[$iIdx][$gSSLG_iY_Range]), $iShiftDist, 0)
		_GDIPlus_PathTransform($hPath, $hMatrixHT)
		_GDIPlus_GraphicsDrawPath($aGraphic[0], $hPath, $g_SSLG[$iIdx][$gSSLG_hPen])
	EndIf
	;_GDIPlus_PathReset($hPath) (Now Handled in AddSample)

	If $g_SSLG[$iIdx][$gSSLG_hPenGrid] Then
		_GDIPlus_PathAddPath($g_SSLG[$iIdx][$gSSLG_hPathGridV], $g_SSLG[$iIdx][$gSSLG_hPathGridH], False)
		_GDIPlus_PathTransform($g_SSLG[$iIdx][$gSSLG_hPathGridV], $hMatrixHT)
		_GDIPlus_GraphicsDrawPath($aGraphic[0], $g_SSLG[$iIdx][$gSSLG_hPathGridV], $g_SSLG[$iIdx][$gSSLG_hPenGrid])
		;_GDIPlus_PathReset($g_SSLG[$iIdx][$gSSLG_hPathGridV]) (Now Handled in AddSample)
	EndIf

	If $g_SSLG[$iIdx][$gSSLG_hPenSamp] Then ;Place a line at the end of each sample period
		_GDIPlus_GraphicsDrawLine($aGraphic[0], $iW - 1, 0, $iW - 1, $iH, $g_SSLG[$iIdx][$gSSLG_hPenSamp])
	EndIf

	__SSLG_GraphicsDraw($iIdx, $aBmp[0], $iW, $iH) ;Copy back to ctrl

	;Clear Next Bitmap
	_GDIPlus_GraphicsFillRect($aGraphic[1], 0, 0, $iW, $iH, $g_SSLG[$iIdx][$gSSLG_hBrushBkgnd])

	$g_SSLG[$iIdx][$gSSLG_iY_Last] = $iY_Last ;Release mutex
	Return SetError($iErr, $iSamples, 1)

EndFunc   ;==>_SSLG_UpdateGraph

; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_SetSampleIndicator
; Description ...: Sets Line Color and line size of sample update line
; Syntax.........: _SSLG_SetSetSampleIndicator($iIdx, $iARGB, $iPenSize)
; Parameters ....: $idSSLG - Control ID returned from _SSLG_CreateGraph()
;                  $iLineColor - Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB) [Default] = False Removes Indicator
;                  $iPenSize - Size of pen [Default] = 2
;				   $iPenStyle  - GDIP_DASHSTYLE [Default] = $GDIP_DASHSTYLESOLID
; Return values .: Success  - 1
;   Failure     - 0 and sets @ERROR:
;                               - 1 Invalid iIndex
;                               - 2 Error setting pen color
; Author ........: Bilgus
; Remarks .......: none
; ===============================================================================================================================
Func _SSLG_SetSetSampleIndicator($idSSLG, $iLineColor = False, $iPenSize = Default, $iPenStyle = Default)
	Local $iIdx = __SSLG_LookupHandle($idSSLG)
	If $iIdx > $g_SSLG[0][0] Then Return SetError(1, @extended, 0)

	If $iPenStyle = Default Then $iPenStyle = $GDIP_DASHSTYLESOLID

	If $iLineColor = False Then
		_GDIPlus_PenDispose($g_SSLG[$iIdx][$gSSLG_hPenSamp])
		$g_SSLG[$iIdx][$gSSLG_hPenSamp] = False
		Return 1
	EndIf

	If $iPenStyle = Default Then $iPenStyle = $GDIP_DASHSTYLEDOT

	$iLineColor = __SSLG_RGB_ARGB($iLineColor)
	If Not $g_SSLG[$iIdx][$gSSLG_hPenSamp] And $iPenSize = Default Then $iPenSize = 1

	If $iPenSize <> Default Then
		_GDIPlus_PenDispose($g_SSLG[$iIdx][$gSSLG_hPenSamp])
		$g_SSLG[$iIdx][$gSSLG_hPenSamp] = _GDIPlus_PenCreate($iLineColor, $iPenSize)
	Else
		_GDIPlus_PenSetColor($g_SSLG[$iIdx][$gSSLG_hPenSamp], $iLineColor)
		If @error Then Return SetError(2, @extended, 0)
	EndIf
	_GDIPlus_PenSetDashStyle($g_SSLG[$iIdx][$gSSLG_hPenSamp], $iPenStyle)

	Return 1

EndFunc   ;==>_SSLG_SetSetSampleIndicator

; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_SetGrid
; Description ...: Sets Grid color x/y interval and line size of Grid
; Syntax.........: _SSLG_SetGrid($iIdx, $iX_c, $iY_c, $iARGB, $iPenSize)
; Parameters ....: $idSSLG     - Control ID returned from _SSLG_CreateGraph()
;                  $iX_c = 0   - X axis grid lines (vertical) [Default] = 0 --  Removes Vertical
;                  $iY_c = 0   - Y axis grid lines (hoizontal) [Default] = 0 -- Removes Horizontal
;                  $iGridColor - Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB)
;                  $iPenSize   - Size of pen [Default] = 2
;				   $iPenStyle  - GDIP_DASHSTYLE [Default] =
; Return values .: Success  - 1
;   Failure     - 0 and sets @ERROR:
;                               - 1 Invalid iIndex
;                               - 2 Error setting pen color
; Author ........: Bilgus
; Remarks .......: none
; ===============================================================================================================================
Func _SSLG_SetGrid($idSSLG, $iX_c, $iY_c, $iGridColor = Default, $iPenSize = Default, $iPenStyle = Default)
	Local $iIdx = __SSLG_LookupHandle($idSSLG)
	If $iIdx > $g_SSLG[0][0] Then Return SetError(1, @extended, 0)
	Local $aRect = $g_SSLG[$iIdx][$gSSLG_aRect]
	Local $iH = $aRect[3]

	If $iGridColor = Default Then $iGridColor = 0xFFA0A0A0
	If $iPenSize = Default Then $iPenSize = 1
	If $iPenStyle = Default Then $iPenStyle = $GDIP_DASHSTYLESOLID

	$iGridColor = __SSLG_RGB_ARGB($iGridColor)

	Local $hPath_Grid = $g_SSLG[$iIdx][$gSSLG_hPathGridH]

	_GDIPlus_PathReset($hPath_Grid)

	_GDIPlus_PenDispose($g_SSLG[$iIdx][$gSSLG_hPenGrid])
	$g_SSLG[$iIdx][$gSSLG_hPenGrid] = False

	;NOTE: notice the negative (-) sign on the Step value -- without it Step = 0 hangs

	For $j = $iH - 1 To 0 Step -Int($iY_c)
		_GDIPlus_PathStartFigure($hPath_Grid)
		_GDIPlus_PathAddLine($hPath_Grid, -1, $j, $g_SSLG[$iIdx][$gSSLG_iIncrements] - 1, $j)
		_GDIPlus_PathCloseFigure($hPath_Grid)
	Next

	$g_SSLG[$iIdx][$gSSLG_iX_Inc] = Int($iX_c)
	If $iX_c <> 0 Or $iY_c <> 0 Then
		$g_SSLG[$iIdx][$gSSLG_hPenGrid] = _GDIPlus_PenCreate($iGridColor, $iPenSize)
		_GDIPlus_PenSetDashStyle($g_SSLG[$iIdx][$gSSLG_hPenGrid], $iPenStyle)
	EndIf

	_SSLG_ClearGraph($idSSLG)

	Return 1

EndFunc   ;==>_SSLG_SetGrid

; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_SetLine
; Description ...: Sets Line Color and line size of Graph
; Syntax.........: _SSLG_SetLineColor($iIdx, $iARGB)
; Parameters ....: $idSSLG - Control ID returned from _SSLG_CreateGraph()
;                  $iLineColor - Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB)
;                  $iPenSize - Size of pen [Default] = 2
;                  $iFillColor - Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB) [Default] = $iLineColor
;				   $hBrush - you may also supply your own brush to fill area under plotted line (deleted on exit by SSLG)
; Return values .: Success  - 1
;   Failure     - 0 and sets @ERROR:
;                               - 1 Invalid iIndex
;                               - 2 Error setting pen color
; Author ........: Bilgus
; Remarks .......: none
; ===============================================================================================================================
Func _SSLG_SetLine($idSSLG, $iLineColor, $iPenSize = Default, $iFillColor = Default, $hBrush = Default)
	Local $iIdx = __SSLG_LookupHandle($idSSLG)
	If $iIdx > $g_SSLG[0][0] Then Return SetError(1, @extended, 0)

	$iLineColor = __SSLG_RGB_ARGB($iLineColor)
	If $iFillColor = Default Then $iFillColor = $iLineColor
	$iFillColor = __SSLG_RGB_ARGB($iFillColor)

	_GDIPlus_BrushDispose($g_SSLG[$iIdx][$gSSLG_hBrushLine])
	If $hBrush = Default Then
		$g_SSLG[$iIdx][$gSSLG_hBrushLine] = _GDIPlus_BrushCreateSolid($iFillColor)
	Else
		$g_SSLG[$iIdx][$gSSLG_hBrushLine] = $hBrush
	EndIf

	If Not $g_SSLG[$iIdx][$gSSLG_hPen] And $iPenSize = Default Then $iPenSize = 2
	If $iPenSize <> Default Then
		_GDIPlus_PenDispose($g_SSLG[$iIdx][$gSSLG_hPen])
		$g_SSLG[$iIdx][$gSSLG_hPen] = _GDIPlus_PenCreate($iLineColor, $iPenSize)
	EndIf

	GUICtrlSetColor($idSSLG, BitAND(BitNOT(0xFF000000), $iLineColor))
	_GDIPlus_PenSetColor($g_SSLG[$iIdx][$gSSLG_hPen], $iLineColor)
	If @error Then Return SetError(2, @extended, 0)

	Return 1

EndFunc   ;==>_SSLG_SetLine

; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_SetSmoothingMode
; Description ...: Sets the graph object rendering quality

; Syntax.........: _SSLG_SetSmoothingMode($iIdx, $iSmooth = 2)
; Parameters ....: $idSSLG - Control ID returned from _SSLG_CreateGraph()
;                  $iSmooth - Smoothing mode
;                         0 - Smoothing is not applied
;                         1 - Smoothing is applied using an 8 X 4 box filter
;                         2 - Smoothing is applied using an 8 X 8 box filter [Default]
; Return values .: Success  - 1
;   Failure     - 0 and sets @ERROR:
;                               - 1 Invalid iIndex
; Author ........: Beege
; Remarks .......: none
; ===============================================================================================================================
Func _SSLG_SetSmoothingMode($idSSLG, $iSmooth = 0)
	Local $iIdx = __SSLG_LookupHandle($idSSLG)
	If $iIdx > $g_SSLG[0][0] Then Return SetError(1, @extended, 0)

	_GDIPlus_GraphicsSetSmoothingMode($g_SSLG[$iIdx][$gSSLG_hGrBuf_0], $iSmooth)
	_GDIPlus_GraphicsSetSmoothingMode($g_SSLG[$iIdx][$gSSLG_hGrBuf_1], $iSmooth)

	Return 1

EndFunc   ;==>_SSLG_SetSmoothingMode

; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_ClearGraph
; Description ...: Clears all data from Graph
; Syntax.........: _SSLG_ClearGraph($iIdx)
; Parameters ....: $idSSLG - Control ID returned from _SSLG_CreateGraph()
; Return values .: Success  - 1
;   Failure     - 0 and sets @ERROR:
;                               - 1 Invalid iIndex
; Author ........: Bilgus
; Remarks .......: none
; ===============================================================================================================================
Func _SSLG_ClearGraph($idSSLG)
	Local $iIdx = __SSLG_LookupHandle($idSSLG)
	If $iIdx > $g_SSLG[0][0] Then Return SetError(1, @extended, 0)

	If $g_SSLG[$iIdx][$gSSLG_bNeedResize] Then 
		if __SSLG_GraphicsSetup($iIdx) = 0 Then Return
	EndIf

	$g_SSLG[$iIdx][$gSSLG_iY_Last] = Default ;Used as Mutex

	;Need to clear both buffers we dont keep track which is current
	_GDIPlus_GraphicsClear($g_SSLG[$iIdx][$gSSLG_hGrBuf_0], $g_SSLG[$iIdx][$gSSLG_iBackColor]) ;
	_GDIPlus_GraphicsClear($g_SSLG[$iIdx][$gSSLG_hGrBuf_1], $g_SSLG[$iIdx][$gSSLG_iBackColor]) ;

	_GDIPlus_PathReset($g_SSLG[$iIdx][$gSSLG_hPathGridV])
	_GDIPlus_PathReset($g_SSLG[$iIdx][$gSSLG_hPathLine])

	$g_SSLG[$iIdx][$gSSLG_iSamplesTotal] = 0
	$g_SSLG[$iIdx][$gSSLG_iSamples] = 0

	If $g_SSLG[$iIdx][$gSSLG_hPenGrid] Then
		;Add blank samples to draw grid
		For $i = 0 To $g_SSLG[$iIdx][$gSSLG_iIncrements] - 1
			_SSLG_AddSample($idSSLG, Default)
		Next
		$g_SSLG[$iIdx][$gSSLG_iY_Last] = False
		_SSLG_UpdateGraph($idSSLG, False, False, True)
	EndIf

	$g_SSLG[$iIdx][$gSSLG_iY_Last] = False

	Return 1

EndFunc   ;==>_SSLG_ClearGraph

; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_SetResizeGraph
; Description ...: Resize Graph after call to GUICtrlSetPos
; Syntax.........: _SSLG_ResizeGraph($iIdx)
; Parameters ....: $idSSLG - Control ID returned from _SSLG_CreateGraph()
; Return values .: Success  - 1
;   Failure     - 0 and sets @ERROR:
;                               - 1 Invalid iIndex
; Author ........: Bilgus
; Remarks .......: Only sets flag -- resize will occur on next ClearGraph or UpdateGraph
; ===============================================================================================================================
Func _SSLG_SetResizeGraph($idSSLG)
	Local $iIdx = __SSLG_LookupHandle($idSSLG)
	If $iIdx > $g_SSLG[0][0] Then Return SetError(1, @extended, 0)
	$g_SSLG[$iIdx][$gSSLG_bNeedResize] = True

	Return 1

EndFunc   ;==>_SSLG_SetResizeGraph

; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_SetYRange
; Description ...: Sets the Minimum and Maximum Y Values
; Syntax.........: _SSLG_SetYRange($iIdx, $iY_Min, $iY_Max)
; Parameters ....: $idSSLG - Control ID returned from _SSLG_CreateGraph()
;   $iY_Min     - Minimum Y Value
;   $iY_Max     - Maximum Y Value
; Return values .: Success  - 1
;   Failure     - 0 and sets @ERROR:
;                               - 1 Invalid iIndex
; Author ........: Beege
; Remarks .......: User should most likly want to ClearGraph after changing Y Range
; ===============================================================================================================================
Func _SSLG_SetYRange($idSSLG, $iY_Min, $iY_Max)
	Local $iIdx = __SSLG_LookupHandle($idSSLG)
	If $iIdx > $g_SSLG[0][0] Then Return SetError(1, @extended, 0)
	$g_SSLG[$iIdx][$gSSLG_iY_Min] = $iY_Min
	$g_SSLG[$iIdx][$gSSLG_iY_Max] = $iY_Max
	$g_SSLG[$iIdx][$gSSLG_iY_Range] = Abs($iY_Max - $iY_Min)
	
	Return 1

EndFunc   ;==>_SSLG_SetYRange

; #FUNCTION# ====================================================================================================================
; Name...........: _SSLG_SetBackGroundColor
; Description ...: Sets Graph BackGround Color
; Syntax.........: _SSLG_SetBackGroundColor($iIdx, $iARGB = 0xFF000000)
; Parameters ....: $idSSLG - Control ID returned from _SSLG_CreateGraph()
;   $iARGB      - Alpha, Red, Green and Blue Hex Value. (0xAARRGGBB). Default = Black
; Return values .: Success  - 1
;   Failure     - 0 and sets @ERROR:
;                               - 1 Invalid iIndex
; Author ........: Beege
; Remarks .......: All previous data will be cleared
; ===============================================================================================================================
Func _SSLG_SetBackGroundColor($idSSLG, $iARGB = 0xFF000000)
	Local $iIdx = __SSLG_LookupHandle($idSSLG)
	If $iIdx > $g_SSLG[0][0] Then Return SetError(1, @extended, 0)

	$g_SSLG[$iIdx][$gSSLG_iBackColor] = __SSLG_RGB_ARGB($iARGB)
	_GDIPlus_BrushDispose($g_SSLG[$iIdx][$gSSLG_hBrushBkgnd])
	$g_SSLG[$iIdx][$gSSLG_hBrushBkgnd] = _GDIPlus_BrushCreateSolid($g_SSLG[$iIdx][$gSSLG_iBackColor])
	_SSLG_ClearGraph($iIdx)

	Return 1

EndFunc   ;==>_SSLG_SetBackGroundColor
#EndRegion Public Functions

#Region Internal Functions
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __SSLG_RGB_ARGB
; Description ...: Convert RBG color to ARGB color
; Syntax.........:
; Parameters ....:
; Return values .:
; Author ........: Bilgus
; Remarks .......:
; ===============================================================================================================================
Func __SSLG_RGB_ARGB($iARGB)
	If BitAND($iARGB, 0xFF000000) = 0 Then
		$iARGB = BitOR($iARGB, 0xFF000000)
	EndIf

	Return $iARGB

EndFunc   ;==>__SSLG_RGB_ARGB

; #INTERNAL_USE_ONLY# ====================================================================================================================
; Name...........: __SSLG_GraphicsSetup
; Description ...: Internal function -- (Re)Creates all the graphics objects
; Syntax.........: __SSLG_GraphicsSetup($iIdx)
; Parameters ....: $iIdx - INTERNAL Graph ID
; Return values .: N/A
;   Failure     - 0 and sets @ERROR:
;                               - 2 No change
; Author ........: Bilgus
; Remarks .......: All previous data will be cleared, Graphics objects destroyed, Re-created if $bReInit = True
; ===============================================================================================================================
Func __SSLG_GraphicsSetup($iIdx)
	$g_SSLG[$iIdx][$gSSLG_bNeedResize] = False

	Local $aRectOld = $g_SSLG[$iIdx][$gSSLG_aRect]
	Local $aRect = WinGetPos($g_SSLG[$iIdx][$gSSLG_hCtrl])

	If $g_SSLG[$iIdx][$gSSLG_hBitmap_0] And $aRect[2] = $aRectOld[2] And $aRect[3] = $aRectOld[3] Then
		;ConsoleWrite("Resize not needed")
		Return SetError(2, @extended, 0)
	EndIf
	$g_SSLG[$iIdx][$gSSLG_aRect] = $aRect
	Local $iW = $aRect[2]
	Local $iH = $aRect[3]

	;ConsoleWrite("New SZ: (" & $aRect[0] & ", " & $aRect[1] & "), (" & $iW & ", " & $iH & ")" & @CRLF)
	Local $hHBMP, $hGrBuf0, $hGrBuf1, $hBitmap0, $hBitmap1
	If $g_SSLG[$iIdx][$gSSLG_hBitmap_0] Then
		$hHBMP = $g_SSLG[$iIdx][$gSSLG_hHBitmapGDI_]
		$hGrBuf0 = $g_SSLG[$iIdx][$gSSLG_hGrBuf_0]
		$hBitmap0 = $g_SSLG[$iIdx][$gSSLG_hBitmap_0]
		$hGrBuf1 = $g_SSLG[$iIdx][$gSSLG_hGrBuf_1]
		$hBitmap1 = $g_SSLG[$iIdx][$gSSLG_hBitmap_1]
		$g_SSLG[$iIdx][$gSSLG_iIncrementSize] = -1
	EndIf


	Local $hGraphic = _GDIPlus_GraphicsCreateFromHWND($g_SSLG[$iIdx][$gSSLG_hCtrl])
	Local $hBitmap = _GDIPlus_BitmapCreateFromGraphics($iW, $iH, $hGraphic)
	
	;$GDIP_PXF32PARGB (Pre-multiplied) appears to be the most efficient format as far as GDI+ is concerned
	$g_SSLG[$iIdx][$gSSLG_hBitmap_0] = _GDIPlus_BitmapCloneArea($hBitmap, 0, 0, $iW, $iH, $GDIP_PXF32PARGB)
	$g_SSLG[$iIdx][$gSSLG_hGrBuf_0] = _GDIPlus_ImageGetGraphicsContext($g_SSLG[$iIdx][$gSSLG_hBitmap_0])

	$g_SSLG[$iIdx][$gSSLG_hBitmap_1] = _GDIPlus_BitmapCloneArea($hBitmap, 0, 0, $iW, $iH, $GDIP_PXF32PARGB)
	$g_SSLG[$iIdx][$gSSLG_hGrBuf_1] = _GDIPlus_ImageGetGraphicsContext($g_SSLG[$iIdx][$gSSLG_hBitmap_1])

	$g_SSLG[$iIdx][$gSSLG_hHBitmapGDI_] = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)

	$g_SSLG[$iIdx][$gSSLG_iIncrementSize] = Ceiling($iW / ($g_SSLG[$iIdx][$gSSLG_iIncrements] + 1))
	$g_SSLG[$iIdx][$gSSLG_iIncrements] = Int($iW / $g_SSLG[$iIdx][$gSSLG_iIncrementSize])

	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_GraphicsDispose($hGraphic)

	Local $aResult = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $g_SSLG[$iIdx][$gSSLG_hCtrl])
	If Not @error Then _WinAPI_RedrawWindow($aResult[0])

	_WinAPI_DeleteObject($hHBMP)
	_GDIPlus_GraphicsDispose($hGrBuf0)
	_GDIPlus_BitmapDispose($hBitmap0)
	_GDIPlus_GraphicsDispose($hGrBuf1)
	_GDIPlus_BitmapDispose($hBitmap1)

	Return 1

EndFunc   ;==>__SSLG_GraphicsSetup

; #INTERNAL_USE_ONLY# ====================================================================================================================
; Name...........: __SSLG_GraphicsDraw
; Description ...: Internal function -- BitBlt back to hDC
; Syntax.........: __SSLG_GraphicsDraw($iIdx)
; Parameters ....: $iIdx - INTERNAL Graph ID
;                  $iW - Width
;                  $iH - Height
; Return values .: N/A
; Author ........: Bilgus
; Remarks .......: Copy the GDI+ bitmap to a HBITMAP blit to the screen
; ===============================================================================================================================
Func __SSLG_GraphicsDraw($iIdx, $hBitmap, $iW, $iH)
	Local $hObjOld, $hDC_Src, $hDC_Dst, $hHBitmap, $hGraphic

	;$hBitmap = GDI+ Bitmap [SRC]
	$hHBitmap = $g_SSLG[$iIdx][$gSSLG_hHBitmapGDI_] ;Standard GDI Bitmap [DEST]

	;DC where we can select the Standard GDI Bitmap
	$hDC_Src = $g_SSLG[$iIdx][$gSSLG_hDCBuf]
	$hObjOld = _WinAPI_SelectObject($hDC_Src, $hHBitmap)

	$hGraphic = _GDIPlus_GraphicsCreateFromHDC($hDC_Src)
	_GDIPlus_GraphicsSetSmoothingMode($hGraphic, 2)
	_GDIPlus_GraphicsDrawImageRect($hGraphic, $hBitmap, 0, 0, $iW, $iH)
	_GDIPlus_GraphicsDispose($hGraphic)

	$hDC_Dst = _WinAPI_GetDC($g_SSLG[$iIdx][$gSSLG_hCtrl])
	_WinAPI_BitBlt($hDC_Dst, 0, 0, $iW, $iH, $hDC_Src, 0, 0, $SRCCOPY) ;Copy back to ctrl
	_WinAPI_ReleaseDC($g_SSLG[$iIdx][$gSSLG_hCtrl], $hDC_Dst)

	_WinAPI_SelectObject($hDC_Src, $hObjOld) ;Put old object back

EndFunc   ;==>__SSLG_GraphicsDraw

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __SSLG_LookupHandle
; Description ...: Converts controlID or Handles to internal graph index
; Syntax.........:
; Parameters ....:
; Return values .:
; Author ........: Bilgus
; Remarks .......:
; ===============================================================================================================================
Func __SSLG_LookupHandle($idSSLG, $bForce = True)
	Static Local $idSSLG_Last = -1
	Static Local $hSSLG_Last = 0
	Local Const $GUI_DISABLE = 128
	If $bForce Or Not BitAND(GUICtrlGetState($idSSLG), $GUI_DISABLE) Then
		If $idSSLG = $idSSLG_Last Then Return $hSSLG_Last ;Shortcut
		$idSSLG = Hex($idSSLG)
		Local $oDict = $g_SSLG[0][$gSSLG_DICT]

		If $oDict.Exists($idSSLG) Then
			$idSSLG_Last = $idSSLG
			$hSSLG_Last = $oDict.Item($idSSLG)
			Return $hSSLG_Last
		EndIf

		ConsoleWriteError("Graph ControlID: " & $idSSLG & " does not exist" & @CRLF)
		For $vKey In $oDict
			ConsoleWriteError("[" & $vKey & "] = " & $oDict.Item($vKey) & @CRLF)
		Next
	EndIf

	Return SetError(1, @extended, $g_SSLG[0][0] + 1)

EndFunc   ;==>__SSLG_LookupHandle

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __SSLG_Exit()
; Description ...: Cleans up stored objects
; Syntax.........:
; Parameters ....:
; Return values .:
; Author ........:
; Remarks .......:
; ===============================================================================================================================
Func __SSLG_Exit()
	If $g_SSLG[0][0] Then
		For $i = 1 To $g_SSLG[0][0]
			$g_SSLG[$i][$gSSLG_iY_Last] = Default ;Mutex

			_WinAPI_DeleteObject($g_SSLG[$i][$gSSLG_hHBitmapGDI_])

			_GDIPlus_GraphicsDispose($g_SSLG[$i][$gSSLG_hGrBuf_1])
			_GDIPlus_BitmapDispose($g_SSLG[$i][$gSSLG_hBitmap_1])

			_GDIPlus_GraphicsDispose($g_SSLG[$i][$gSSLG_hGrBuf_0])
			_GDIPlus_BitmapDispose($g_SSLG[$i][$gSSLG_hBitmap_0])

			_GDIPlus_MatrixDispose($g_SSLG[$i][$gSSLG_hMatrixHT])

			_GDIPlus_PathDispose($g_SSLG[$i][$gSSLG_hPathLine])
			_GDIPlus_PathDispose($g_SSLG[$i][$gSSLG_hPathGridV])
			_GDIPlus_PathDispose($g_SSLG[$i][$gSSLG_hPathGridH])

			_GDIPlus_PenDispose($g_SSLG[$i][$gSSLG_hPenGrid])
			_GDIPlus_PenDispose($g_SSLG[$i][$gSSLG_hPenSamp])
			_GDIPlus_PenDispose($g_SSLG[$i][$gSSLG_hPen])

			_GDIPlus_BrushDispose($g_SSLG[$i][$gSSLG_hBrushLine])
			_GDIPlus_BrushDispose($g_SSLG[$i][$gSSLG_hBrushBkgnd])
			_WinAPI_DeleteDC($g_SSLG[$i][$gSSLG_hDCBuf])
		Next
	EndIf

	_GDIPlus_Shutdown()

EndFunc   ;==>__SSLG_Exit
#EndRegion Internal Functions
