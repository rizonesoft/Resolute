#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tStruct = DllStructCreate('byte[8]')

ConsoleWrite(DllStructGetData($tStruct, 1) & @CR)

_WinAPI_FillMemory(DllStructGetPtr($tStruct), 8, 0xAB)

ConsoleWrite(DllStructGetData($tStruct, 1) & @CR)

_WinAPI_ZeroMemory(DllStructGetPtr($tStruct), 8)

ConsoleWrite(DllStructGetData($tStruct, 1) & @CR)
