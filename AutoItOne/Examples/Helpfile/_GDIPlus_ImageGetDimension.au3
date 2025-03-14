#include <GDIPlus.au3>
#include <MsgBoxConstants.au3>

Example()

Func Example()
	Local $aDim, $hImage, $sFile

	$sFile = FileOpenDialog("Please select an image", "", "Image (*.jpg;*.png;*.bmp;*.gif;*.tif)", BitOR($FD_PATHMUSTEXIST, $FD_FILEMUSTEXIST))
	If @error Then Exit MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), "Error", "No image file has been selected", 30)

	_GDIPlus_Startup()

	$hImage = _GDIPlus_ImageLoadFromFile($sFile)
	If @error Or Not $hImage Then
		MsgBox(($MB_ICONERROR + $MB_SYSTEMMODAL), "Error", "This file isn't supported by GDIPlus!")
	Else
		$aDim = _GDIPlus_ImageGetDimension($hImage)
		MsgBox($MB_ICONINFORMATION, "Information", "Image dimension of " & @CRLF & $sFile & @CRLF & @CRLF & "Width = " & $aDim[0] & " pixel" & @CRLF & "Height = " & $aDim[1] & " pixel")
		_GDIPlus_ImageDispose($hImage)
	EndIf

	_GDIPlus_Shutdown()
EndFunc   ;==>Example
