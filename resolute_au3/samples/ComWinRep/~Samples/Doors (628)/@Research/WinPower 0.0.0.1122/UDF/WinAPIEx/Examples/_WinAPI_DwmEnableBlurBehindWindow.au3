#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If Not _WinAPI_DwmIsCompositionEnabled() Then
	MsgBox(16, 'Error', 'Require Windows Vista or later with enabled Aero theme.')
	Exit
EndIf

Global $hForm, $hRgn

; Create GUI
$hForm = GUICreate('MyGUI', 400, 400)

GUISetBkColor(0)

; Create the "sheet of glass" effect for the specified region. You must call this function whenever DWM composition is toggled.
_WinAPI_DwmGetColorizationColor()
If Not @extended Then
	$hRgn = _WinAPI_CreateEllipticRgn(_WinAPI_CreateRectEx(50, 50, 300, 300))
Else
	$hRgn = 0
EndIf
_WinAPI_DwmEnableBlurBehindWindow($hForm, 1, 0, $hRgn)
If $hRgn Then
	_WinAPI_DeleteObject($hRgn)
EndIf

GUISetState()

Do
Until GUIGetMsg() = -3
