#include <GUIConstantsEx.au3>
#include <Misc.au3>
#include <WindowsConstants.au3>

Example()

Func Example()
	Local $hGUI, $idCOLORREF, $idBGR, $idRGB, $idMemo, $idRGBwA1, $idRGBwA2, $idClear

	$hGUI = GUICreate("_ChooseColor() Example", 400, 300)
	$idMemo = GUICtrlCreateEdit("", 2, 55, 396, 200, BitOR($WS_VSCROLL, $WS_HSCROLL))
	GUICtrlSetFont($idMemo, 10, 400, 0, "Courier New")
	$idCOLORREF = GUICtrlCreateButton("COLORREF", 40, 10, 80, 40)
	$idBGR = GUICtrlCreateButton("BGR", 130, 10, 80, 40)
	$idRGB = GUICtrlCreateButton("RGB", 220, 10, 80, 40)
	$idClear = GUICtrlCreateButton("Clear", 310, 10, 60, 40)
	$idRGBwA1 = GUICtrlCreateButton("RGB + custom #1", 80, 260, 100, 40)
	$idRGBwA2 = GUICtrlCreateButton("RGB + custom #2", 210, 260, 100, 40)
	GUISetState(@SW_SHOW)

	Local $aCustColors1[17]
	$aCustColors1[0] = -9  ; init. the custom colors
	$aCustColors1[3] = 0xFF0000 ; if you would like to,
	$aCustColors1[16] = 0x0000FF ; without having to load the interface.
	_ChooseColor($aCustColors1)

	Local $aCustColors2[17]
	$aCustColors2[2] = 0x0000FF
	$aCustColors2[15] = 0xFF0000

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				GUIDelete()
				ExitLoop
			Case $idClear
				GUICtrlSetState($idClear, $GUI_DISABLE)
				_ChooseColor(-10)
				Sleep(200) ; some feedback to show something was done  =)
				GUICtrlSetState($idClear, $GUI_ENABLE)
			Case $idCOLORREF
				_ShowChoice($hGUI, $idMemo, 0, _ChooseColor(0, 255, 0, $hGUI), "COLORREF color of your choice: ")
			Case $idBGR
				_ShowChoice($hGUI, $idMemo, 1, _ChooseColor(1, 0x808000, 1, $hGUI), "BGR Hex color of your choice: ")
			Case $idRGB
				_ShowChoice($hGUI, $idMemo, 2, _ChooseColor(2, 0x0080C0, 2, $hGUI), "RGB Hex color of your choice: ")
			Case $idRGBwA1
				$aCustColors1[0] = 2 ; this is the "ReturnType"
				$aCustColors1 = _ChooseColor($aCustColors1, 0x0080C0, 2, $hGUI) ; to update the saved custom colors back to the array
				_ShowChoice($hGUI, $idMemo, 2, $aCustColors1[0], "RGB Hex color of your choice ( #1 ): ")
			Case $idRGBwA2
				$aCustColors2[0] = 2
				_ShowChoice($hGUI, $idMemo, 2, _ChooseColor($aCustColors2, 0x0080C0, 2, $hGUI)[0], "RGB Hex color of your choice ( #2 ): ")
		EndSwitch
	WEnd
EndFunc   ;==>Example

Func _ShowChoice($hGUI, $idMemo, $iType, $iChoose, $sMessage)
	Local $sCr
	If $iChoose <> -1 Then

		If $iType = 0 Then ; convert COLORREF to RGB for this example
			$sCr = Hex($iChoose, 6)
			GUISetBkColor('0x' & StringMid($sCr, 5, 2) & StringMid($sCr, 3, 2) & StringMid($sCr, 1, 2), $hGUI)
		Else
			GUISetBkColor($iChoose, $hGUI)
		EndIf

		GUICtrlSetData($idMemo, $sMessage & $iChoose & @CRLF, 1)

	Else
		GUICtrlSetData($idMemo, "User Canceled Selction" & @CRLF, 1)
	EndIf
EndFunc   ;==>_ShowChoice
