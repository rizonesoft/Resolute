#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic, $hPic, $Width = 200, $Height = 200, $tBITMAPINFO, $tBits, $pBits, $hObj, $hBitmap, $hDC

; Create GUI
$hForm = GUICreate('MyGUI', $Width, $Height)
$Pic = GUICtrlCreatePic('', 0, 0, $Width, $Height)
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap
$tBITMAPINFO = DllStructCreate($tagBITMAPINFO)
DllStructSetData($tBITMAPINFO, 'Size', DllStructGetSize($tBITMAPINFO) - 4)
DllStructSetData($tBITMAPINFO, 'Width', $Width)
DllStructSetData($tBITMAPINFO, 'Height', $Height)
DllStructSetData($tBITMAPINFO, 'Planes', 1)
DllStructSetData($tBITMAPINFO, 'BitCount', 32)
DllStructSetData($tBITMAPINFO, 'Compression', $BI_RGB)
DllStructSetData($tBITMAPINFO, 'SizeImage', 0) ; => BI_RGB
$hBitmap = _WinAPI_CreateDIBSection(0, $tBITMAPINFO, $DIB_RGB_COLORS, $pBits)

; Fill bitmap colors
$tBits = DllStructCreate('dword[' & DllStructGetData($tBITMAPINFO, 'Width') * DllStructGetData($tBITMAPINFO, 'Height') & ']', $pBits)
For $y = 0 To $Height - 1
	For $x = 1 To $Width
		DllStructSetData($tBits, 1, Random(0xFFFFFF), $x + ($y * $Width))
	Next
Next

; Set gradient to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_FreeObject($hBitmap)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
