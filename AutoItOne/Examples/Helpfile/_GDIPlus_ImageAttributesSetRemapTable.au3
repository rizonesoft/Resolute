#include <Array.au3>
#include <Color.au3>
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <ScreenCapture.au3>
#include <WinAPIHObj.au3>

Example_1()

Example_2()

Func Example_1()
	Local $hGui = GUICreate("GDI+", 800, 600)
	GUISetState(@SW_SHOW)

	_GDIPlus_Startup()
	Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui)
	_GDIPlus_GraphicsSetInterpolationMode($hGraphics, 5)

	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0(400, 600, $GDIP_PXF32RGB)
	Local $hContext = _GDIPlus_ImageGetGraphicsContext($hBitmap)

	Local $hBrush = _GDIPlus_LineBrushCreate(0, 0, 0, 600, 0xFFFFFFFF, 0x00FFFFFF)
	_GDIPlus_GraphicsFillRect($hContext, 0, 0, 400, 600, $hBrush)

	Local $aRemapTable[257][2]
	$aRemapTable[0][0] = 256
	Local $aRGB, $aHSL[3] = [0, 240, 120]
	For $i = 0 To 255
		$aRemapTable[$i + 1][0] = "0x" & Hex(BitOR(0xFF000000, BitShift($i, -16), BitShift($i, -8), $i), 8)

		$aHSL[0] = $i / 255 * 240
		$aRGB = _ColorConvertHSLtoRGB($aHSL)
		$aRemapTable[$i + 1][1] = "0x" & Hex(BitOR(0xFF000000, BitShift($aRGB[0], -16), BitShift($aRGB[1], -8), $aRGB[2]), 8)
	Next

	_GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hBitmap, 0, 0, 400, 600, 0, 0, 400, 600)
	_GDIPlus_GraphicsDrawString($hGraphics, "Original Bitmap Colors", 10, 10, "ARIAL", 14)

	Local $hImgAttr = _GDIPlus_ImageAttributesCreate()
	_GDIPlus_ImageAttributesSetRemapTable($hImgAttr, $aRemapTable)
	_GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hBitmap, 0, 0, 400, 600, 400, 0, 400, 600, $hImgAttr)
	_GDIPlus_GraphicsDrawString($hGraphics, "Remapped Colors", 410, 10, "ARIAL", 14)

	_ArrayDisplay($aRemapTable)

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_ImageAttributesDispose($hImgAttr)
	_GDIPlus_GraphicsDispose($hContext)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_Shutdown()
	GUIDelete($hGui)
EndFunc   ;==>Example_1

Func Example_2()
	_GDIPlus_Startup()
	Local Const $iW = 500, $iH = 500

	Local $hGui = GUICreate("GDI+", $iW, $iH)
	GUISetState()

	Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui)

	Local $hHBitmap = _ScreenCapture_Capture("", 0, 0, $iW, $iH)
	Local $hBmp = _GDIPlus_BitmapCreateFromHBITMAP($hHBitmap)

	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0($iW, $iH)
	Local $hCtxt = _GDIPlus_ImageGetGraphicsContext($hBitmap)

	_GDIPlus_GraphicsDrawImage($hGraphics, $hBmp, 0, 0)

	Local $hBrush = _GDIPlus_BrushCreateSolid(0xFF000000)
	_GDIPlus_GraphicsFillRect($hCtxt, 0, 0, $iW, $iH, $hBrush)
	_GDIPlus_BrushSetSolidColor($hBrush, 0xFFFF0000)
	_GDIPlus_GraphicsFillEllipse($hCtxt, 50, 50, $iW - 100, $iH - 100, $hBrush)

	Local $hIA = _GDIPlus_ImageAttributesCreate()
	Local $aRemapTable[2][2]
	$aRemapTable[0][0] = 1
	$aRemapTable[1][0] = 0xFFFF0000
	$aRemapTable[1][1] = 0x00000000
	_GDIPlus_ImageAttributesSetRemapTable($hIA, $aRemapTable)

	_GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hBitmap, 0, 0, $iW, $iH, 0, 0, $iW, $iH, $hIA)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	_GDIPlus_ImageAttributesDispose($hIA)
	_WinAPI_DeleteObject($hHBitmap)
	_GDIPlus_ImageDispose($hCtxt)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_BitmapDispose($hBmp)
	_GDIPlus_Shutdown()
	GUIDelete($hGui)
EndFunc   ;==>Example_2
