#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global Const $STM_SETIMAGE = 0x0172

Global Const $sANDBits = _
	'FF FF FF FF' & _
	'FF FF C3 FF' & _
	'FF FF 00 FF' & _
	'FF FE 00 7F' & _
	'FF FC 00 1F' & _
	'FF F8 00 0F' & _
	'FF F8 00 0F' & _
	'FF F0 00 07' & _
	'FF F0 00 03' & _
	'FF E0 00 03' & _
	'FF E0 00 01' & _
	'FF E0 00 01' & _
	'FF F0 00 01' & _
	'FF F0 00 00' & _
	'FF F8 00 00' & _
	'FF FC 00 00' & _
	'FF FF 00 00' & _
	'FF FF 80 00' & _
	'FF FF E0 00' & _
	'FF FF E0 01' & _
	'FF FF F0 01' & _
	'FF FF F0 01' & _
	'FF FF F0 03' & _
	'FF FF E0 03' & _
	'FF FF E0 07' & _
	'FF FF C0 0F' & _
	'FF FF C0 0F' & _
	'FF FF 80 1F' & _
	'FF FF 00 7F' & _
	'FF FC 00 FF' & _
	'FF F8 03 FF' & _
	'FF FC 3F FF'

Global Const $sXORBits = _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 38 00' & _
	'00 00 7C 00' & _
	'00 00 7C 00' & _
	'00 00 7C 00' & _
	'00 00 38 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00' & _
	'00 00 00 00'

Global $tANDBits, $pANDBits, $tXORBits, $pXORBits, $bData, $hIcon

; Create AND bitmask structure
$bData = Binary('0x' & StringStripWS($sANDBits, 8))
$tANDBits = DllStructCreate('byte[' & BinaryLen($bData)& ']')
$pANDBits = DllStructGetPtr($tANDBits)
DllStructSetData($tANDBits, 1, $bData)

; Create XOR bitmask structure
$bData = Binary('0x' & StringStripWS($sXORBits, 8))
$tXORBits = DllStructCreate('byte[' & BinaryLen($bData)& ']')
$pXORBits = DllStructGetPtr($tXORBits)
DllStructSetData($tXORBits, 1, $bData)

; Create monochrome icon (32x32)
$hIcon = _WinAPI_CreateIcon(0, 32, 32, 1, 1, $pANDBits, $pXORBits)

; Create GUI
GUICreate('MyGUI', 128, 128)
GUICtrlCreateIcon('', 0, 48, 48, 32, 32)
GUICtrlSendMsg(-1, $STM_SETIMAGE, 1, $hIcon)
GUISetState()

Do
Until GUIGetMsg() = -3
