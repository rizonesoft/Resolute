#include <GDIPlus.au3>

CreateMultiFrameTIFF(@MyDocumentsDir & "\GDIPlus_MultiFrame.tif")
ShellExecute(@MyDocumentsDir & "\GDIPlus_MultiFrame.tif")

Func CreateMultiFrameTIFF($sFile, $iPages = 4)
	_GDIPlus_Startup()

	Local $sImgCLSID = _GDIPlus_EncodersGetCLSID("tif") ;create CLSID for a TIFF image file type

	;Create main image
	Local $hImage = _GDIPlus_BitmapCreateFromScan0(400, 300)
	Local $hContext = _GDIPlus_ImageGetGraphicsContext($hImage)
	_GDIPlus_GraphicsClear($hContext, 0xFFFFFFFF)
	_GDIPlus_GraphicsDrawRect($hContext, 5, 5, 390, 290)
	_GDIPlus_GraphicsDrawString($hContext, "MultiFrame TIFF" & @CRLF & "Frame " & 1 & "/" & $iPages, 20, 20, "ARIAL", 32)
	_GDIPlus_GraphicsDispose($hContext)

	;Save main image (first frame) and add MultiFrame-Param
	Local $tParamData = DllStructCreate("int")
	Local $pParamData = DllStructGetPtr($tParamData)
	DllStructSetData($tParamData, 1, $GDIP_EVTMULTIFRAME)
	Local $tParams = _GDIPlus_ParamInit(1)
	_GDIPlus_ParamAdd($tParams, $GDIP_EPGSAVEFLAG, 1, $GDIP_EPTLONG, $pParamData)
	_GDIPlus_ImageSaveToFileEx($hImage, $sFile, $sImgCLSID, $tParams)

	;Set param for additional frames
	DllStructSetData($tParamData, 1, $GDIP_EVTFRAMEDIMENSIONPAGE)
	$tParams = _GDIPlus_ParamInit(1)
	_GDIPlus_ParamAdd($tParams, $GDIP_EPGSAVEFLAG, 1, $GDIP_EPTLONG, $pParamData)

	;Create & save next frames
	Local $hImage_SubPage
	For $i = 2 To $iPages
		$hImage_SubPage = _GDIPlus_BitmapCreateFromScan0(400, 300)
		$hContext = _GDIPlus_ImageGetGraphicsContext($hImage_SubPage)
		_GDIPlus_GraphicsClear($hContext, 0xFFFFFFFF)
		_GDIPlus_GraphicsDrawRect($hContext, 5, 5, 390, 290)
		_GDIPlus_GraphicsDrawString($hContext, "MultiFrame TIFF" & @CRLF & "Frame " & $i & "/" & $iPages, 20, 20, "ARIAL", 32)
		_GDIPlus_GraphicsDispose($hContext)

		;add frame to file
		_GDIPlus_ImageSaveAddImage($hImage, $hImage_SubPage, $tParams)

		;dispose curent frame bitmap
		_GDIPlus_BitmapDispose($hImage_SubPage)
	Next

	;Close the multiframe file.
	DllStructSetData($tParamData, 1, $GDIP_EVTFLUSH)
	$tParams = _GDIPlus_ParamInit(1)
	_GDIPlus_ParamAdd($tParams, $GDIP_EPGSAVEFLAG, 1, $GDIP_EPTLONG, $pParamData)
	_GDIPlus_ImageSaveAdd($hImage, $tParams)

	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()
EndFunc   ;==>CreateMultiFrameTIFF
