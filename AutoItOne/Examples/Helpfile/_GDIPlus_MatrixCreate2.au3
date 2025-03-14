#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>

Example_1()
Example_2()

Func Example_1()
	Local $hGui = GUICreate("GDI+", 800, 400)
	GUISetBkColor(0x282828)
	GUISetState(@SW_SHOW)

	_GDIPlus_Startup()
	Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui)
	Local $hMatrix_S = _GDIPlus_MatrixCreate2(2, 0, 0, 1, 0, 0) ;horizontal doubling
	Local $hMatrix_T = _GDIPlus_MatrixCreate2(1, 0, 0, 1, 50, 0) ;horizontal translation of 50 units
	Local $hBrush_Line = _GDIPlus_LineBrushCreateFromRect(_GDIPlus_RectFCreate(0, 0, 200, 100), 0xFFFF0000, 0xFF0000FF, 1)
	_GDIPlus_GraphicsFillRect($hGraphics, 0, 0, 800, 100, $hBrush_Line) ;fill a large area with the gradient brush (no transformation).
	_GDIPlus_LineBrushSetTransform($hBrush_Line, $hMatrix_S) ;apply the scaling transformation.
	_GDIPlus_GraphicsFillRect($hGraphics, 0, 150, 800, 100, $hBrush_Line) ;fill a large area with the scaled gradient brush.
	_GDIPlus_LineBrushMultiplyTransform($hBrush_Line, $hMatrix_T) ;form a composite transformation: first scale, then translate.
	_GDIPlus_GraphicsFillRect($hGraphics, 0, 300, 800, 100, $hBrush_Line) ;fill a large area with the scaled and translated gradient brush.

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	_GDIPlus_MatrixDispose($hMatrix_S)
	_GDIPlus_MatrixDispose($hMatrix_T)
	_GDIPlus_BrushDispose($hBrush_Line)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_Shutdown()
	GUIDelete($hGui)
EndFunc   ;==>Example_1

Func Example_2()
	Local $hGui = GUICreate("GDI+", 800, 400)
	GUISetBkColor(0x282828)
	GUISetState(@SW_SHOW)

	_GDIPlus_Startup()
	Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui)
	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0(800, 400)
	Local $hContext = _GDIPlus_ImageGetGraphicsContext($hBitmap)

	Local $hBrush_Line = _GDIPlus_LineBrushCreateFromRect(_GDIPlus_RectFCreate(0, 0, 200, 100), 0xFFFF0000, 0xFF0000FF)

	Local $hMatrix_S, $i = 0
	Do
		$hMatrix_S = _GDIPlus_MatrixCreate2(2.5, 0, Cos($i / 200) * 10, 1, 0, Sin($i / 50) * 75)
		_GDIPlus_LineBrushSetTransform($hBrush_Line, $hMatrix_S)

		_GDIPlus_GraphicsFillRect($hContext, 0, 150, 800, 100, $hBrush_Line)

		_GDIPlus_GraphicsDrawImageRect($hGraphics, $hBitmap, 0, 0, 800, 400)
		_GDIPlus_MatrixDispose($hMatrix_S)

		$i += 1
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	_GDIPlus_MatrixDispose($hMatrix_S)
	_GDIPlus_BrushDispose($hBrush_Line)
	_GDIPlus_GraphicsDispose($hContext)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_Shutdown()
	GUIDelete($hGui)
EndFunc   ;==>Example_2
