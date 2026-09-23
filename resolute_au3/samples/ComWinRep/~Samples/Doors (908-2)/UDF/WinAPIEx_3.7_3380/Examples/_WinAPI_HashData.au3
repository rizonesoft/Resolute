#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $bData, $tData, $pData, $iSize

$bData = Binary('0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF')
$iSize = BinaryLen($bData)
$tData = DllStructCreate('byte[' & $iSize & ']')
$pData = DllStructGetPtr($tData)
DllStructSetData($tData, 1, $bData)

ConsoleWrite(_WinAPI_HashData($pData, $iSize) & @CR)
