#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hWnd, $hForm, $Pic, $hPic, $Size, $hObj, $hBmp, $hBitmap, $hDC, $hDestDC, $hDestSv, $hSrcDC, $hSrcSv

Run(@SystemDir & '\calc.exe')
$hWnd = WinWaitActive('Calculator', '', 3)
If Not $hWnd Then
	Exit
EndIf

; Create GUI
$Size = WinGetPos($hWnd)
$hForm = GUICreate('MyGUI', $Size[2] + 80, $Size[3] + 80)
$Pic = GUICtrlCreatePic('', 40, 40, $Size[2], $Size[3])
$hPic = GUICtrlGetHandle($Pic)

; Create bitmap
$hDC = _WinAPI_GetDC($hPic)
$hDestDC = _WinAPI_CreateCompatibleDC($hDC)
$hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $Size[2], $Size[3])
$hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap)
$hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
$hBmp = _WinAPI_CreateCompatibleBitmap($hDC, $Size[2], $Size[3])
$hSrcSv = _WinAPI_SelectObject($hSrcDC, $hBmp)
_WinAPI_PrintWindow($hWnd, $hSrcDC)
_WinAPI_BitBlt($hDestDC, 0, 0, $Size[2], $Size[3], $hSrcDC, 0, 0, $MERGECOPY)

_WinAPI_ReleaseDC($hPic, $hDC)
_WinAPI_SelectObject($hDestDC, $hDestSv)
_WinAPI_SelectObject($hSrcDC, $hSrcSv)
_WinAPI_DeleteDC($hDestDC)
_WinAPI_DeleteDC($hSrcDC)
_WinAPI_DeleteObject($hBmp)

; Set bitmap to control
_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
$hObj = _SendMessage($hPic, $STM_GETIMAGE)
If $hObj <> $hBitmap Then
	_WinAPI_DeleteObject($hBitmap)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
