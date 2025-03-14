#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>

Example()

Func Example()
	Local $hGUI = GUICreate("GDI+", 660, 360)
	GUISetState(@SW_SHOW)

	_GDIPlus_Startup()
	Local $hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	_GDIPlus_GraphicsSetSmoothingMode($hGraphic, $GDIP_SMOOTHINGMODE_HIGHQUALITY)
	_GDIPlus_GraphicsClear($hGraphic, 0xFF000000)

	Local $hPen = _GDIPlus_PenCreate(0xFF4488FF, 2, 0)
	_GDIPlus_GraphicsDrawRect($hGraphic, 20, 20, 300, 320, $hPen)

	;Scale the pen width by a factor of 10 in the horizontal
	;direction and a factor of 5 in the vertical direction
	Local $hMatrix = _GDIPlus_MatrixCreate2(10, 0, 0, 5, 0, 0)
	_GDIPlus_PenSetTransform($hPen, $hMatrix)
	_GDIPlus_GraphicsDrawRect($hGraphic, 340, 20, 300, 320, $hPen)

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	_GDIPlus_PenDispose($hPen)
	_GDIPlus_MatrixDispose($hMatrix)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_Shutdown()
EndFunc   ;==>Example
