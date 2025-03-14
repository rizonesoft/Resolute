#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>

Example()

Func Example()
	Local $hGUI = GUICreate("GDI+", 800, 360)
	GUISetState(@SW_SHOW)

	_GDIPlus_Startup()
	Local $hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	_GDIPlus_GraphicsSetSmoothingMode($hGraphic, $GDIP_SMOOTHINGMODE_HIGHQUALITY)
	_GDIPlus_GraphicsClear($hGraphic, 0xFF000000)

	Local $hPath = _GDIPlus_PathCreate()
	Local $hFamily = _GDIPlus_FontFamilyCreate("Arial Black")
	_GDIPlus_PathAddString($hPath, "AutoIt", _GDIPlus_RectFCreate(10, 25), $hFamily, 0, 205, 0)

	Local $hBrush = _GDIPlus_BrushCreateSolid(0xF0FFFFFF)
	Local $hPen = _GDIPlus_PenCreate(0xFF4488FF, 12)
	_GDIPlus_PenSetLineJoin($hPen, 2)

	Local $aCompounds[7]
	$aCompounds[0] = 6 ;number of elements in the compound array

	$aCompounds[1] = 0 ;
	$aCompounds[2] = 0.3 ;first line [0 to 0.3] * PenWidth

	$aCompounds[3] = 0.55 ;
	$aCompounds[4] = 0.7 ;second line [0.55 to 0.7] * PenWidth

	$aCompounds[5] = 0.9 ;
	$aCompounds[6] = 1 ;third line [0.9 to 1] * PenWidth

	_GDIPlus_PenSetCompound($hPen, $aCompounds)

	_GDIPlus_GraphicsFillPath($hGraphic, $hPath, $hBrush)
	_GDIPlus_GraphicsDrawPath($hGraphic, $hPath, $hPen)

	_GDIPlus_PenSetColor($hPen, 0xFFFF66FF)
	_GDIPlus_GraphicsDrawRect($hGraphic, 20, 20, 760, 320, $hPen)

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_PathDispose($hPath)
	_GDIPlus_PenDispose($hPen)
	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_Shutdown()
EndFunc   ;==>Example
