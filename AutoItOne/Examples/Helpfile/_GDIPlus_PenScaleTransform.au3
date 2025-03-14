#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>

Opt("GUIOnEventMode", 1)

_GDIPlus_Startup()
Global $g_hGui = GUICreate("GDI+", 800, 360)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
Global $g_hGraphics = _GDIPlus_GraphicsCreateFromHWND($g_hGui)
Global $g_hBmp_Buffer = _GDIPlus_BitmapCreateFromScan0(800, 360)
Global $g_hGfx_Buffer = _GDIPlus_ImageGetGraphicsContext($g_hBmp_Buffer)
_GDIPlus_GraphicsSetSmoothingMode($g_hGfx_Buffer, $GDIP_SMOOTHINGMODE_HIGHQUALITY)
_GDIPlus_GraphicsSetPixelOffsetMode($g_hGfx_Buffer, $GDIP_SMOOTHINGMODE_HIGHQUALITY)
GUISetState()

Global Const $g_cPI = ATan(1) * 4
Global Const $g_cDeg2Rad = $g_cPI / 180

Global $g_hPath = _GDIPlus_PathCreate()
Local $hFamily = _GDIPlus_FontFamilyCreate("Arial")
Local $tLayout = _GDIPlus_RectFCreate(10, 20)
_GDIPlus_PathAddString($g_hPath, "AutoIt", $tLayout, $hFamily, 0, 256, 0)
_GDIPlus_FontFamilyDispose($hFamily)

Global $g_hPen = _GDIPlus_PenCreate(0, 2, 0) ;Create Pen: Width = 2, Units = World coordinates
_GDIPlus_PenSetMiterLimit($g_hPen, 0) ;Disable Miter

Global $g_fAngle, $g_fStep = 0

While Sleep(10)
	_Draw()
WEnd

Func _Draw($fExtrude = 8)
	$g_fStep += 0.01
	$g_fAngle = Mod(Sin($g_fStep) * 360 + 45, 360)

	_GDIPlus_GraphicsClear($g_hGfx_Buffer, 0xF4303030)

	_GDIPlus_PenSetColor($g_hPen, 0x8000A000)
	_GDIPlus_PenScaleTransform($g_hPen, $fExtrude, 1) ;Scale Pen in X-Direction
	_GDIPlus_PenRotateTransform($g_hPen, $g_fAngle, True) ;Rotate Pen
	_GDIPlus_GraphicsDrawPath($g_hGfx_Buffer, $g_hPath, $g_hPen)

	_GDIPlus_PenResetTransform($g_hPen) ;Reset Pen´s transformation matrix
	_GDIPlus_PenSetColor($g_hPen, 0xA000FF00)
	_GDIPlus_GraphicsTranslateTransform($g_hGfx_Buffer, $fExtrude * Cos($g_fAngle * $g_cDeg2Rad), $fExtrude * Sin($g_fAngle * $g_cDeg2Rad)) ;Offset foreground text, to match scaled-rotated text
	_GDIPlus_GraphicsDrawPath($g_hGfx_Buffer, $g_hPath, $g_hPen)
	_GDIPlus_GraphicsResetTransform($g_hGfx_Buffer)

	_GDIPlus_GraphicsDrawImage($g_hGraphics, $g_hBmp_Buffer, 0, 0)
EndFunc   ;==>_Draw

Func _Exit()
	_GDIPlus_PathDispose($g_hPath)
	_GDIPlus_PenDispose($g_hPen)
	_GDIPlus_GraphicsDispose($g_hGfx_Buffer)
	_GDIPlus_BitmapDispose($g_hBmp_Buffer)
	_GDIPlus_GraphicsDispose($g_hGraphics)
	GUIDelete($g_hGui)
	_GDIPlus_Shutdown()
	Exit
EndFunc   ;==>_Exit
