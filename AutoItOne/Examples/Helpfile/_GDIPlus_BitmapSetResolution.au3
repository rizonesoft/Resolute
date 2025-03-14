#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>

Example(@MyDocumentsDir & "\GDIPlus_A4_72.png", 72) ;A4: 210 x 297 mm
ShellExecuteWait(@MyDocumentsDir & "\GDIPlus_A4_72.png")

Example(@MyDocumentsDir & "\GDIPlus_A4_300.png", 300) ;A4: 210 x 297 mm
ShellExecuteWait(@MyDocumentsDir & "\GDIPlus_A4_300.png")

Example(@MyDocumentsDir & "\GDIPlus_Letter_72.png", 72, 215.9, 279.4) ;Letter: 8.5 x 11 in
ShellExecuteWait(@MyDocumentsDir & "\GDIPlus_Letter_72.png")

Example(@MyDocumentsDir & "\GDIPlus_Letter_300.png", 300, 215.9, 279.4) ;Letter: 8.5 x 11 in
ShellExecuteWait(@MyDocumentsDir & "\GDIPlus_Letter_300.png")

Func Example($sFileName, $fDPI, $fPageW = 210, $fPageH = 297)
	_GDIPlus_Startup()

	Local $iBMP_W = Ceiling($fPageW / 25.4 * $fDPI) ;Calc BitmapSize in Pixels
	Local $iBMP_H = Ceiling($fPageH / 25.4 * $fDPI)
	Local $hBitmap = _GDIPlus_BitmapCreateFromScan0($iBMP_W, $iBMP_H)
	Local $hContext = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsClear($hContext, 0xFFFFFFFF)

	_GDIPlus_BitmapSetResolution($hBitmap, $fDPI, $fDPI) ;Set DPI Resolution

	_GDIPlus_GraphicsDrawString($hContext, StringFormat("%.1f x %.1f mm\n%.1f x %.1f in\n%.1f DPI", $fPageW, $fPageH, $fPageW / 25.4, $fPageH / 25.5, $fDPI), 20, 20, "ARIAL", 48)

	_GDIPlus_ImageSaveToFile($hBitmap, $sFileName)

	_GDIPlus_GraphicsDispose($hContext)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_Shutdown()
EndFunc   ;==>Example
