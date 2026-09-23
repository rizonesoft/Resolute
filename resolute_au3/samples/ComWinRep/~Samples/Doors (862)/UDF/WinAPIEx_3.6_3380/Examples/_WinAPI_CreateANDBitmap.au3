#Include <GDIPlus.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $sPng = @ScriptDir & '\Extras\Silverlight.png'

Global Const $STM_SETIMAGE = 0x0172

Global $hForm, $Pic[2], $hBitmap[2], $hPng, $hIcon, $Width, $Height, $Path

; Create 32 bits-per-pixel bitmap from a PNG image
_GDIPlus_Startup()
$hPng = _GDIPlus_ImageLoadFromFile($sPng)
$hBitmap[0] = _GDIPlus_BitmapCreateDIBFromBitmap($hPng)
$Width = _GDIPlus_ImageGetWidth($hPng)
$Height = _GDIPlus_ImageGetHeight($hPng)
_GDIPlus_ImageDispose($hPng)
_GDIPlus_Shutdown()

; Create 1 bits-per-pixel AND bitmask bitmap
$hBitmap[1] = _WinAPI_CreateANDBitmap($hBitmap[0])

; Create GUI
$hForm = GUICreate('MyGUI', $Width * 2, $Height)
$Pic[0] = GUICtrlCreatePic('', 0, 0, $Width, $Height)
$Pic[1] = GUICtrlCreatePic('', $Width, 0, $Width, $Height)

; Set both bitmaps to controls
For $i = 0 To 1
	GUICtrlSendMsg($Pic[$i], $STM_SETIMAGE, 0, $hBitmap[$i])
Next

; Show GUI
GUISetState()

; Create and save icon to .ico file
$Path = FileSaveDialog('Save Icon', @ScriptDir, 'Icon Files (*.ico)', 2 + 16, _WinAPI_PathStripPath(_WinAPI_PathRenameExtension($sPng, '.ico')), $hForm)
If $Path Then
	$hIcon = _WinAPI_CreateIconIndirect($hBitmap[0], $hBitmap[1])
	If Not @error Then
		_WinAPI_SaveHICONToFile($Path, $hIcon)
		_WinAPI_DestroyIcon($hIcon)
	EndIf
EndIf

Do
Until GUIGetMsg() = -3

; Unlike _GDIPlus_BitmapCreateHBITMAPFromBitmap() that creates a device-dependent bitmap (DDB), this function creates a device-independent bitmap (DIB) which may be used for semi-transparent images

Func _GDIPlus_BitmapCreateDIBFromBitmap($hBitmap)

	Local $hDIB = 0, $aSize, $tData, $pBits

	$aSize = DllCall($ghGDIPDll, 'uint', 'GdipGetImageDimension', 'ptr', $hBitmap, 'float*', 0, 'float*', 0)
	If (@error) Or ($aSize[0]) Then
		Return 0
	EndIf
	$tData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $aSize[2], $aSize[3], $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	$pBits = DllStructGetData($tData, 'Scan0')
	If Not $pBits Then
		Return 0
	EndIf
	$hDIB = _WinAPI_CreateDIB($aSize[2], $aSize[3])
	If Not @error Then
		_WinAPI_SetBitmapBits($hDIB, $aSize[2] * $aSize[3] * 4, $pBits)
	EndIf
	_GDIPlus_BitmapUnlockBits($hBitmap, $tData)
	Return $hDIB
EndFunc   ;==>_GDIPlus_BitmapCreateDIBFromBitmap
