#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tICO, $tHDR, $hFile, $hBitmap, $hSource, $tData, $Bytes, $Lenght

; Load image
$hSource = _WinAPI_LoadImage(0, @ScriptDir & '\Extras\AutoIt.bmp', $IMAGE_BITMAP, 0, 0, BitOR($LR_LOADFROMFILE, $LR_CREATEDIBSECTION))

; Resize bitmap to 256x256 pixels
$hBitmap = _WinAPI_ResizeBitmap($hSource, 256, 256, $HALFTONE)

; Create compressed PNG data
$Lenght = _WinAPI_CompressBitmapBits($hBitmap, $tData)

; Create .ico file
If Not @error Then
	$tICO = DllStructCreate('align 1;ushort Reserved;ushort Type;ushort Count;byte Header[20]')
	$tHDR = DllStructCreate('byte Width;byte Height;byte Colors;byte Reserved;word Planes;word BPP;long Size;long Offset', DllStructGetPtr($tICO, 'Header'))
	DllStructSetData($tICO, 'Reserved', 0)
	DllStructSetData($tICO, 'Type', 1)
	DllStructSetData($tICO, 'Count', 1)
	DllStructSetData($tHDR, 'Width', 0)
	DllStructSetData($tHDR, 'Height', 0)
	DllStructSetData($tHDR, 'Colors', 0)
	DllStructSetData($tHDR, 'Reserved', 0)
	DllStructSetData($tHDR, 'Planes', 1)
	DllStructSetData($tHDR, 'BPP', 32)
	DllStructSetData($tHDR, 'Size', $Lenght)
	DllStructSetData($tHDR, 'Offset', DllStructGetSize($tICO))
	$hFile = _WinAPI_CreateFile(@ScriptDir & '\MyIcon.ico', 1, 4)
	_WinAPI_WriteFile($hFile, DllStructGetPtr($tICO), DllStructGetSize($tICO), $Bytes)
	_WinAPI_WriteFile($hFile, DllStructGetPtr($tData), $Lenght, $Bytes)
	_WinAPI_CloseHandle($hFile)
EndIf

; Delete unnecessary bitmaps
_WinAPI_DeleteObject($hSource)
_WinAPI_DeleteObject($hBitmap)
