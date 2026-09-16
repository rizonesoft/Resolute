#Include <WinAPIEx.au3>
#Include <WindowsConstants.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $Pic1, $Pic2, $hPic1, $hPic2, $hObj, $hBmp, $hBitmap1, $hBitmap2, $hDC, $hDestDC, $hDestSv, $hSrcDC, $hSrcSv

; Create GUI
$hForm = GUICreate('MyGUI', 260, 140)
$Pic1 = GUICtrlCreatePic('', 20, 20, 100, 100)
$hPic1 = GUICtrlGetHandle($Pic1)
$Pic2 = GUICtrlCreatePic('', 140, 20, 100, 100)
$hPic2 = GUICtrlGetHandle($Pic2)

; Create bitmap1
$hDC = _WinAPI_GetDC($hPic1)
$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap1 = _WinAPI_CreateCompatibleBitmapEx($hDC, 100, 100, 0xFF00FF)
$hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap1)
$hBmp = _WinAPI_CreateCompatibleBitmapEx($hDC, 70, 70, 0x00A060)
_WinAPI_DrawBitmap($hDestDC, 15, 15, $hBmp)
_WinAPI_FreeObject($hBmp)
$hBmp = _WinAPI_CreateCompatibleBitmapEx($hDC, 40, 40, 0xFF00FF)
_WinAPI_DrawBitmap($hDestDC, 30, 30, $hBmp)
_WinAPI_FreeObject($hBmp)

_WinAPI_ReleaseDC($hPic1, $hDC)
_WinAPI_SelectObject($hDestDC, $hDestSv)
_WinAPI_DeleteDC($hDestDC)

; Create bitmap2
$hDC = _WinAPI_GetDC($hPic2)
$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap2 = _WinAPI_CreateCompatibleBitmapEx($hDC, 100, 100, _WinAPI_SwitchColor(_WinAPI_GetSysColor($COLOR_3DFACE)))
$hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap2)
$hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
$hSrcSv = _WinAPI_SelectObject($hSrcDC, $hBitmap1)
_WinAPI_TransparentBlt($hDestDC, 0, 0, 100, 100, $hSrcDC, 0, 0, 100, 100, 0xFF00FF)

_WinAPI_ReleaseDC($hPic1, $hDC)
_WinAPI_SelectObject($hDestDC, $hDestSv)
_WinAPI_SelectObject($hSrcDC, $hSrcSv)
_WinAPI_DeleteDC($hDestDC)
_WinAPI_DeleteDC($hSrcDC)

; Set bitmaps to controls
For $i = 1 To 2
	_SendMessage(Eval('hPic' & $i), $STM_SETIMAGE, 0, Eval('hBitmap' & $i))
	$hObj = _SendMessage(Eval('hPic' & $i), $STM_GETIMAGE)
	If $hObj <> Eval('hBitmap' & $i) Then
		_WinAPI_FreeObject(Eval('hBitmap' & $i))
	EndIf
Next

GUISetState()

Do
Until GUIGetMsg() = -3
