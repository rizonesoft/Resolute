#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $tBIV5HDR, $tBits, $pBits, $hBitmap, $hObj

; Create 32 bits-per-pixel device-independent bitmap (DIB) that use a mask
$tBIV5HDR = DllStructCreate($tagBITMAPV5HEADER)

DllStructSetData($tBIV5HDR, 'bV5Size', DllStructGetSize($tBIV5HDR))
DllStructSetData($tBIV5HDR, 'bV5Width', 256)
DllStructSetData($tBIV5HDR, 'bV5Height', 256)
DllStructSetData($tBIV5HDR, 'bV5Planes', 1)
DllStructSetData($tBIV5HDR, 'bV5BitCount', 32)
DllStructSetData($tBIV5HDR, 'biCompression', $BI_BITFIELDS)
DllStructSetData($tBIV5HDR, 'bV5SizeImage', 0)
DllStructSetData($tBIV5HDR, 'bV5XPelsPerMeter', 0)
DllStructSetData($tBIV5HDR, 'bV5YPelsPerMeter', 0)
DllStructSetData($tBIV5HDR, 'bV5ClrUsed', 0)
DllStructSetData($tBIV5HDR, 'bV5ClrImportant', 0)
DllStructSetData($tBIV5HDR, 'bV5RedMask', 0x00FF0000)
DllStructSetData($tBIV5HDR, 'bV5GreenMask', 0x0000FF00)
DllStructSetData($tBIV5HDR, 'bV5BlueMask', 0x000000FF)
DllStructSetData($tBIV5HDR, 'bV5AlphaMask', 0xFF000000)
DllStructSetData($tBIV5HDR, 'bV5CSType', 0)
DllStructSetData($tBIV5HDR, 'bV5Endpoints', 0, 1)
DllStructSetData($tBIV5HDR, 'bV5Endpoints', 0, 2)
DllStructSetData($tBIV5HDR, 'bV5Endpoints', 0, 3)
DllStructSetData($tBIV5HDR, 'bV5GammaRed', 0)
DllStructSetData($tBIV5HDR, 'bV5GammaGreen', 0)
DllStructSetData($tBIV5HDR, 'bV5GammaBlue', 0)
DllStructSetData($tBIV5HDR, 'bV5Intent', 0)
DllStructSetData($tBIV5HDR, 'bV5ProfileData', 0)
DllStructSetData($tBIV5HDR, 'bV5ProfileSize', 0)
DllStructSetData($tBIV5HDR, 'bV5Reserved', 0)

$hBitmap = _WinAPI_CreateDIBSection(0, $tBIV5HDR, $DIB_RGB_COLORS, $pBits)

; Fill bitmap green with variable alpha chanel
$tBits = DllStructCreate('dword[65536]', $pBits)
For $y = 0 To 255
	For $x = 1 To 256
		DllStructSetData($tBits, 1, BitOR(0x00FF00, BitShift($y, -24)), $x + (256 * $y))
	Next
Next

; Create GUI
$hForm = GUICreate('MyGUI', 256, 256)
$Pic = GUICtrlCreatePic('', 0, 0, 256, 256)
$hPic = GUICtrlGetHandle($Pic)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_DeleteObject($hBitmap)
EndIf

; Set background color to green and show GUI
GUISetBkColor(0x0000FF)
GUISetState()

Do
Until GUIGetMsg() = -3
