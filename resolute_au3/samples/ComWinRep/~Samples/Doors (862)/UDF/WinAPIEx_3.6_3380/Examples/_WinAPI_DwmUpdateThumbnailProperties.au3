#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

If Not _WinAPI_DwmIsCompositionEnabled() Then
	MsgBox(16, 'Error', 'Require Windows Vista or later with enabled Aero theme.')
	Exit
EndIf

Global $hWnd, $hForm, $hThumbnail, $tSIZE, $tDestRect, $tSrcRect, $Width, $Height

Run(@SystemDir & '\calc.exe')
$hWnd = WinWaitActive('Calculator', '', 3)
If Not $hWnd Then
	Exit
EndIf

; Create GUI
$hForm = GUICreate('MyGUI', 400, 400)

GUISetBkColor(0)

; Create the "sheet of glass" effect for the entire window. You must call this function whenever DWM composition is toggled.
_WinAPI_DwmExtendFrameIntoClientArea($hForm)

; Create a DWM thumbnail relationship (2:1)
$hThumbnail = _WinAPI_DwmRegisterThumbnail($hForm, $hWnd)
$tSIZE = _WinAPI_DwmQueryThumbnailSourceSize($hThumbnail)
$Width = DllStructGetData($tSIZE, 1)
$Height = DllStructGetData($tSIZE, 2)
$tDestRect = _WinAPI_CreateRectEx((400 - $Width / 2) / 2, (400 - $Height / 2) / 2, $Width / 2, $Height / 2)
$tSrcRect = _WinAPI_CreateRectEx(-20, -20, $Width + 40, $Height + 40)
_WinAPI_DwmUpdateThumbnailProperties($hThumbnail, 1, 0, 255, $tDestRect, $tSrcRect)

GUISetState()

Do
Until GUIGetMsg() = -3
