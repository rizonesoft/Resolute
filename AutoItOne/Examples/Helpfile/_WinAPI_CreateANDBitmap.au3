#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WinAPIGdi.au3>
#include <WinAPIIcons.au3>
#include <WinAPIShPath.au3>

Local Const $sPng = @ScriptDir & '\Extras\Silverlight.png'

Local $a_hBitmap[2]
; Create 32 bits-per-pixel bitmap from a PNG image
Global $g_hDll = _GDIPlus_Startup(Default, True)
Local $hPng = _GDIPlus_ImageLoadFromFile($sPng)
$a_hBitmap[0] = _GDIPlus_BitmapCreateDIBFromBitmap($hPng)
Local $iWidth = _GDIPlus_ImageGetWidth($hPng)
Local $iHeight = _GDIPlus_ImageGetHeight($hPng)
_GDIPlus_ImageDispose($hPng)
_GDIPlus_Shutdown()

; Create 1 bits-per-pixel AND bitmask bitmap
$a_hBitmap[1] = _WinAPI_CreateANDBitmap($a_hBitmap[0])

; Create GUI
Local $hForm = GUICreate('Test ' & StringReplace(@ScriptName, '.au3', '()'), $iWidth * 2, $iHeight)
Local $aidPic[2]
$aidPic[0] = GUICtrlCreatePic('', 0, 0, $iWidth, $iHeight)
$aidPic[1] = GUICtrlCreatePic('', $iWidth, 0, $iWidth, $iHeight)

; Set both bitmaps to controls
For $i = 0 To 1
	GUICtrlSendMsg($aidPic[$i], $STM_SETIMAGE, 0, $a_hBitmap[$i])
Next

; Show GUI
GUISetState(@SW_SHOW)

; Create and save icon to .ico file
Local $hIcon
Local $sPath = FileSaveDialog('Save Icon', @ScriptDir, 'Icon Files (*.ico)', 2 + 16, _WinAPI_PathStripPath(_WinAPI_PathRenameExtension($sPng, '.ico')), $hForm)
If $sPath Then
	$hIcon = _WinAPI_CreateIconIndirect($a_hBitmap[0], $a_hBitmap[1])
	If $hIcon Then
		_WinAPI_SaveHICONToFile($sPath, $hIcon)
		_WinAPI_DestroyIcon($hIcon)
	EndIf
EndIf

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE
