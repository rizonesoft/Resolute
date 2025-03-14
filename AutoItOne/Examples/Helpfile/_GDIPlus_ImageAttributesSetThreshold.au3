#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <ScreenCapture.au3>
#include <WinAPIHObj.au3>

Example()

Func Example()
	_GDIPlus_Startup()
	Local Const $iW = @DesktopWidth / 2, $iH = @DesktopHeight / 2

	Local $hGui = GUICreate("GDI+", $iW, $iH)
	GUISetState()

	Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui)

	Local $hHBitmap = _ScreenCapture_Capture("", 0, 0, $iW, $iH)
	Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)

	Local $hIA = _GDIPlus_ImageAttributesCreate()
	_GDIPlus_ImageAttributesSetThreshold($hIA, 0.6666) ;create black & white bitmap
	Local $tBWMatrix = _GDIPlus_ColorMatrixCreateGrayScale()
	Local $pBWMatrix = DllStructGetPtr($tBWMatrix)
	_GDIPlus_ImageAttributesSetColorMatrix($hIA, $GDIP_COLORADJUSTTYPE_DEFAULT, True, $pBWMatrix)

	_GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hBitmap, 0, 0, $iW, $iH, 0, 0, $iW, $iH, $hIA)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	_GDIPlus_ImageAttributesDispose($hIA)
	_WinAPI_DeleteObject($hHBitmap)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_Shutdown()
EndFunc   ;==>Example
