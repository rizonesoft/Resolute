#Include <APIConstants.au3>
#Include <ComboConstants.au3>
#Include <EditConstants.au3>
#Include <GDIPlus.au3>
#Include <GUIComboBox.au3>
#Include <GUIConstantsEx.au3>
#Include <SliderConstants.au3>
#Include <StaticConstants.au3>
#Include <WinAPIEx.au3>

Opt('GUICloseOnESC', 0)
Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

Global Const $STM_SETIMAGE = 0x0172
Global Const $STM_GETIMAGE = 0x0173

Global $hForm, $hTool, $hObj, $hPic, $hSrc, $W, $H, $Button[2], $Check[3], $Combo, $Data, $Msg
Global $Light = StringSplit('Default|Tungsten lamp|Noon sunlight|NTSC daylight|Normal print|Bond paper print|Standard daylight|Northern daylight|Cool white lamp', '|')
Global $Slider[9][6] = [[0, 0, 'Red', 25, 650, 100], [0, 0, 'Green', 25, 650, 100], [0, 0, 'Blue', 25, 650, 100], [0, 0, 'Black', 0, 400, 10], [0, 0, 'White', 600, 1000, 10], [0, 0, 'Contrast', -100, 100, 1], [0, 0, 'Brightness', -100, 100, 1], [0, 0, 'Colorfulness', -100, 100, 1], [0, 0, 'Tint', -100, 100, 1]]
Global $Default[11] = [10000, 10000, 10000, 0, 10000, 0, 0, 0, 0, 0, 0]
Global $Adjust = $Default

_GDIPlus_Startup()

While 1
	$Data = FileOpenDialog('Load Image', @WorkingDir, 'Image Files (*.bmp;*.dib;*.gif;*.jpg;*.tif)|All Files (*.*)', 1 + 2)
	If Not $Data Then
		Exit
	EndIf
	$hObj = _GDIPlus_ImageLoadFromFile($Data)
	If $hObj Then
		$hSrc = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hObj)
		$W = _GDIPlus_ImageGetWidth($hObj)
		$H = _GDIPlus_ImageGetHeight($hObj)
		_GDIPlus_ImageDispose($hObj)
		If $hSrc Then
			ExitLoop
		EndIf
	EndIf
	MsgBox(16, 'Error', 'Unable to load image.')
WEnd

$hForm = GUICreate(_WinAPI_PathStripPath($Data), $W, $H)
GUICtrlCreatePic('', 0, 0, $W, $H)
GUICtrlSetState(-1, $GUI_DISABLE)
$hPic = GUICtrlGetHandle(-1)
$hTool = GUICreate('Adjustments', 303, 484, -1, -1, BitOR($WS_CAPTION, $WS_POPUP), 0, $hForm)
GUICtrlCreateGraphic(0, 0, 303, 436)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetBkColor(-1, 0xFFFFFF)
GUICtrlCreateGraphic(0, 436, 303, 1)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetBkColor(-1, 0xDFDFDF)
For $i = 0 To 8
	GUICtrlCreateLabel($Slider[$i][2] & ':', 10, 21 + $i * 31, 60, 14, $SS_RIGHT)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$Slider[$i][2] = GUICtrlCreateInput('', 243, 18 + $i * 31, 49, 19, BitOR($ES_CENTER, $ES_READONLY))
	GUICtrlSetFont(-1, 9.3, 400, 0, 'Arial')
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	$Slider[$i][0] = GUICtrlCreateSlider(71, 19 + $i * 31, 170, 20, BitOR($TBS_BOTH, $TBS_NOTICKS))
	GUICtrlSetLimit(-1, $Slider[$i][4], $Slider[$i][3])
	$Slider[$i][1] = GUICtrlGetHandle(-1)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
Next
GUICtrlCreateLabel('Illuminant:', 10, 310, 60, 14, $SS_RIGHT)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$Combo = GUICtrlCreateCombo('', 77, 306, 158, 160, $CBS_DROPDOWNLIST)
For $i = 1 To $Light[0]
	_GUICtrlComboBox_AddString(-1, $Light[$i])
Next
GUICtrlCreateLabel('Filters:', 10, 347, 60, 14, $SS_RIGHT)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$Check[0] = GUICtrlCreateCheckbox('Negative (invert colors)', 77, 343, 131, 21)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$Check[1] = GUICtrlCreateCheckbox('Logarithmic', 77, 368, 76, 21)
GUICtrlSetBkColor(-1, 0xFFFFFF)
$Check[2] = GUICtrlCreateCheckbox('Preview', 11, 401, 60, 21)
GUICtrlSetBkColor(-1, 0xFFFFFF)
GUICtrlSetState(-1, $GUI_CHECKED)
$Button[0] = GUICtrlCreateButton('Reset', 136, 448, 75, 25)
$Button[1] = GUICtrlCreateButton('Save...', 218, 448, 75, 25)
_Reset()
GUICtrlSetState($Slider[0][0], $GUI_FOCUS)
GUIRegisterMsg($WM_HSCROLL, 'WM_HSCROLL')
GUISetState(@SW_SHOW, $hForm)
GUISetState(@SW_SHOW, $hTool)

While 1
	$Msg = GUIGetMsg()
	Switch $Msg
		Case 0
			ContinueLoop
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button[0]
			_Reset()
		Case $Button[1]
			GUISetState(@SW_DISABLE, $hForm)
			$Data = FileSaveDialog('Save Image', @WorkingDir, 'Image Files (*.bmp;*.dib;*.gif;*.jpg;*.tif)|All Files (*.*)', 2 + 16, @ScriptDir & '\MyImage.jpg', $hTool)
			GUICtrlSetState($Button[1], $GUI_FOCUS)
			GUISetState(@SW_ENABLE, $hForm)
			If Not $Data Then
				ContinueLoop
			EndIf
			$hObj = _GDIPlus_BitmapCreateFromHBITMAP(_SendMessage($hPic, $STM_GETIMAGE))
			If $hObj Then
				If _GDIPlus_ImageSaveToFile($hObj, $Data) Then
					$Data = 0
				EndIf
				_GDIPlus_ImageDispose($hObj)
			EndIf
			If $Data Then
				MsgBox(16, 'Error', 'Unable to save image.')
			EndIf
		Case $Check[0]
			If GUICtrlRead($Check[0]) = $GUI_CHECKED Then
				$Adjust[9] = BitOR($Adjust[9], $CA_NEGATIVE)
			Else
				$Adjust[9] = BitAND($Adjust[9], BitNOT($CA_NEGATIVE))
			EndIf
			_Update()
		Case $Check[1]
			If GUICtrlRead($Check[1]) = $GUI_CHECKED Then
				$Adjust[9] = BitOR($Adjust[9], $CA_LOG_FILTER)
			Else
				$Adjust[9] = BitAND($Adjust[9], BitNOT($CA_LOG_FILTER))
			EndIf
			_Update()
		Case $Check[2]
			If GUICtrlRead($Check[2]) = $GUI_CHECKED Then
				_SetBitmapAdjust($hPic, $hSrc, $Adjust)
			Else
				_SetBitmapAdjust($hPic, $hSrc)
			EndIf
		Case $Combo
			$Data = _GUICtrlComboBox_GetCurSel($Combo)
			If $Adjust[10] <> $Data Then
				$Adjust[10] = $Data
				_Update()
			EndIf
	EndSwitch
WEnd

Func _Reset()
	$Adjust = $Default
	For $i = 0 To 8
		GUICtrlSetData($Slider[$i][0], $Adjust[$i] / $Slider[$i][5])
		GUICtrlSetData($Slider[$i][2], $Adjust[$i])
	Next
	_GUICtrlComboBox_SetCurSel($Combo, $Adjust[10])
	If BitAND($Adjust[9], $CA_LOG_FILTER) Then
		GUICtrlSetState($Check[1], $GUI_CHECKED)
	Else
		GUICtrlSetState($Check[1], $GUI_UNCHECKED)
	EndIf
	If BitAND($Adjust[9], $CA_NEGATIVE) Then
		GUICtrlSetState($Check[0], $GUI_CHECKED)
	Else
		GUICtrlSetState($Check[0], $GUI_UNCHECKED)
	EndIf
	_Update()
EndFunc   ;==>_Reset

Func _SetBitmapAdjust($hWnd, $hBitmap, $aAdjust = 0)

	Local $hPrev, $tAdjust = 0

	If Not IsHWnd($hWnd) Then
		$hWnd = GUICtrlGetHandle($hWnd)
		If Not $hWnd Then
			Return 0
		EndIf
	EndIf

	If IsArray($aAdjust) Then
		$tAdjust = _WinAPI_CreateColorAdjustment($aAdjust[9], $aAdjust[10], $aAdjust[0], $aAdjust[1], $aAdjust[2], $aAdjust[3], $aAdjust[4], $aAdjust[5], $aAdjust[6], $aAdjust[7], $aAdjust[8])
	EndIf
	$hBitmap = _WinAPI_AdjustBitmap($hBitmap, -1, -1, $HALFTONE, $tAdjust)
	If @error Then
		Return 0
	EndIf
	$hPrev = _SendMessage($hWnd, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
	If $hPrev Then
		_WinAPI_DeleteObject($hPrev)
	EndIf
	$hPrev = _SendMessage($hWnd, $STM_GETIMAGE)
	If $hPrev <> $hBitmap Then
		_WinAPI_DeleteObject($hBitmap)
	EndIf
	Return 1
EndFunc   ;==>_SetBitmapAdjust

Func _Update()
	If GUICtrlRead($Check[2]) = $GUI_CHECKED Then
		_SetBitmapAdjust($hPic, $hSrc, $Adjust)
	EndIf
EndFunc   ;==>_Update

Func WM_HSCROLL($hWnd, $iMsg, $wParam, $lParam)
	Switch $hWnd
		Case $hTool
			For $i = 0 To 8
				If $Slider[$i][1] = $lParam Then
					$Adjust[$i] = $Slider[$i][5] * GUICtrlRead($Slider[$i][0])
					GUICtrlSetData($Slider[$i][2], $Adjust[$i])
					_Update()
					ExitLoop
				EndIf
			Next
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_HSCROLL
