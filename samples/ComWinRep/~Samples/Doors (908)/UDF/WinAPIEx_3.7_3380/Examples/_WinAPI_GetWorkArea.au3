#Include <APIConstants.au3>
#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $hForm, $tRECT, $X, $Y, $Width, $Height

$tRECT = _WinAPI_GetWorkArea()
$Width = DllStructGetData($tRECT, 'Right') - DllStructGetData($tRECT, 'Left')
$Height = DllStructGetData($tRECT, 'Bottom') - DllStructGetData($tRECT, 'Top')
$X = DllStructGetData($tRECT, 'Left')
$Y = DllStructGetData($tRECT, 'Top')

$hForm = GUICreate('MyGUI', $Width, $Height, $X, $Y, $WS_POPUP, $WS_EX_TOPMOST)
GUISetBkColor(0, $hForm)
WinSetTrans($hForm, '', 128)
GUISetState()

Do
Until GUIGetMsg() = -3
