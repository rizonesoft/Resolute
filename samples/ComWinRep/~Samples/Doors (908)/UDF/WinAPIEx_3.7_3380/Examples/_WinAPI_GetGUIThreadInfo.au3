#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $hWnd, $Info, $Input[11], $PID

$hForm = GUICreate('', 240, 268, 10, 10, BitOR($WS_CAPTION, $WS_POPUP), $WS_EX_TOPMOST)
GUICtrlCreateLabel('Thread state:', 20, 18, 90, 14)
GUICtrlCreateLabel('Active window:', 20, 40, 90, 14)
GUICtrlCreateLabel('Keyboard focus:', 20, 62, 90, 14)
GUICtrlCreateLabel('Mouse capture:', 20, 84, 90, 14)
GUICtrlCreateLabel('Active menu:', 20, 106, 90, 14)
GUICtrlCreateLabel('Move or size loop:', 20, 128, 90, 14)
GUICtrlCreateLabel('Caret:', 20, 150, 90, 14)
GUICtrlCreateLabel('Left:', 20, 172, 90, 14)
GUICtrlCreateLabel('Top:', 20, 194, 90, 14)
GUICtrlCreateLabel('Width:', 20, 216, 90, 14)
GUICtrlCreateLabel('Height:', 20, 238, 90, 14)
For $i = 0 To 10
	$Input[$i] = GUICtrlCreateLabel('', 114, 18 + 22 * $i, 116, 14)
Next
GUISetState(@SW_SHOWNOACTIVATE)

Do
	$hWnd = WinGetHandle('[ACTIVE]')
	$Info = _WinAPI_GetGUIThreadInfo(_WinAPI_GetWindowThreadProcessId($hWnd, $PID))
	If Not @error Then
		WinSetTitle($hForm, '', WinGetTitle($hWnd))
		$Info[0] = '0x' & Hex($Info[0], 8)
	Else
		WinSetTitle($hForm, '', '')
		Dim $Info[11]
		For $i = 0 To 10
			$Info[$i] = ''
		Next
		$hWnd = 0
	EndIf
	For $i = 0 To 10
		If StringCompare(GUICtrlRead($Input[$i]), $Info[$i]) Then
			GUICtrlSetData($Input[$i], $Info[$i])
		EndIf
	Next
Until GUIGetMsg() = -3
