#Include <APIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <SliderConstants.au3>
#Include <StaticConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $Graphic, $Label, $hSlider, $Slider

; Create GUI
$hForm = GUICreate('MyGUI', 300, 327)
GUISetBkColor(0x808080)
$Graphic = GUICtrlCreateGraphic(0, 0, 150, 300)
GUICtrlSetBkColor(-1, 0x808080)
GUICtrlCreateLabel('', 0, 300, 303, 2, $SS_ETCHEDHORZ)
$Label = GUICtrlCreateLabel('0%', 30, 132, 90, 37, $SS_CENTER)
GUICtrlSetFont(-1, 24, 800, 0, 'Arial')
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)
$Slider = GUICtrlCreateSlider(0, 302, 300, 25, BitOR($TBS_BOTH, $TBS_NOTICKS))
$hSlider = GUICtrlGetHandle(-1)
GUICtrlSetLimit(-1, 50, -50)
GUICtrlSetData(-1, 0)

; Register WM_HSCROLL message for live scrolling and show GUI
GUIRegisterMsg($WM_HSCROLL, 'WM_HSCROLL')
GUISetState()

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE

Func WM_HSCROLL($hWnd, $iMsg, $wParam, $lParam)

	Local $Percent

	Switch $hWnd
		Case $hForm
			Switch $lParam
				Case $hSlider
					$Percent = GUICtrlRead($Slider)
					GUICtrlSetBkColor($Graphic, _WinAPI_ColorAdjustLuma(0x808080, $Percent))
					GUICtrlSetData($Label, $Percent & '%')
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_HSCROLL
