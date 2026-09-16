#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tStruct1, $tStruct2, $tStruct3

$tStruct1 = DllStructCreate('byte[4]')
_WinAPI_FillMemory(DllStructGetPtr($tStruct1), 4, 0xAA)

$tStruct2 = DllStructCreate('byte[4]')
_WinAPI_FillMemory(DllStructGetPtr($tStruct2), 4, 0xDD)

$tStruct3 = _WinAPI_UnionStruct($tStruct1, $tStruct2)

ConsoleWrite('First:  ' & DllStructGetData($tStruct1, 1) & @CR)
ConsoleWrite('Second: ' & DllStructGetData($tStruct2, 1) & @CR)
ConsoleWrite('Union:  ' & DllStructGetData($tStruct3, 1) & @CR)
