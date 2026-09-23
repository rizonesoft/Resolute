#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tStruct1, $tStruct2

$tStruct1 = DllStructCreate('byte[8]')
_WinAPI_FillMemory(DllStructGetPtr($tStruct1), 8, 0x1D)

$tStruct2 = _WinAPI_CopyStruct($tStruct1)

ConsoleWrite('Source:      ' & DllStructGetData($tStruct1, 1) & @CR)
ConsoleWrite('Destination: ' & DllStructGetData($tStruct2, 1) & @CR)
