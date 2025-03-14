#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>

Example()

Func Example()
	Local $sFile, $hClone, $hImage, $hGUI, $aDim, $hCanvas

	; Load an image
	$sFile = FileOpenDialog("Select an image", "", "Image (*.jpg;*.png;*.bmp;*.gif;*.tif)")
	If @error Then Exit MsgBox($MB_ICONWARNING, "Waring", "No image was selected! Exiting script...")

	; Initialize GDI+ library
	_GDIPlus_Startup()

	; Capture 32 bit bitmap
	$hImage = _GDIPlus_ImageLoadFromFile($sFile)
	If @error Then
		_GDIPlus_Shutdown()
		Exit MsgBox($MB_ICONERROR, "Error", "Image is not suppored by GDIPlus! Exiting script...")
	EndIf

	; Create an image clone
	$hClone = _GDIPlus_ImageClone($hImage)

	; Display cloned image in a GUI
	$aDim = _GDIPlus_ImageGetDimension($hClone)
	$hGUI = GUICreate("_GDIPlus_ImageClone Example", $aDim[0] > @DesktopWidth ? @DesktopWidth : $aDim[0], $aDim[1] > @DesktopHeight ? @DesktopHeight : $aDim[1], -1, -1, $WS_POPUPWINDOW, $WS_EX_TOPMOST)
	GUISetState()
	$hCanvas = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	_GDIPlus_GraphicsDrawImageRect($hCanvas, $hClone, 0, 0, $aDim[0], $aDim[1])

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	; Clean up resources
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_ImageDispose($hClone)
	_GDIPlus_GraphicsDispose($hCanvas)

	; Shut down GDI+ library
	_GDIPlus_Shutdown()

EndFunc   ;==>Example
