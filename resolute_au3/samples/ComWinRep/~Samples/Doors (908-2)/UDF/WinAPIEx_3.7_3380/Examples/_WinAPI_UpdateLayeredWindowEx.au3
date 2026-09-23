#Include <APIConstants.au3>
#Include <GDIPlus.au3>
#Include <Misc.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $hImage, $hBitmap, $Opacity = 0, $Step = 3

_GDIPlus_Startup()
$hImage = _GDIPlus_ImageLoadFromFile(@ScriptDir & '\Extras\Exclamation.png')
$hForm = GUICreate('MyGUI', _GDIPlus_ImageGetWidth($hImage), _GDIPlus_ImageGetHeight($hImage), -1, -1, $WS_POPUPWINDOW, BitOR($WS_EX_LAYERED, $WS_EX_TOPMOST))
$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_GDIPlus_ImageDispose($hImage)
_GDIPlus_Shutdown()
GUISetState()

Do
	_WinAPI_UpdateLayeredWindowEx($hForm, -1, -1, $hBitmap, $Opacity)
	$Opacity += $Step
	If ($Opacity = 0) Or ($Opacity = 255) Then
		$Step = -$Step
		Sleep(500)
	EndIf
	Sleep(10)
Until _IsPressed('1B')

_WinAPI_DeleteObject($hBitmap)
