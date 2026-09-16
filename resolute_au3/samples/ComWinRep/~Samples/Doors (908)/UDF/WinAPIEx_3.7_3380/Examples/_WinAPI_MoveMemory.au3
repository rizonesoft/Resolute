#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tStruct1 = DllStructCreate('dword')
Global $tStruct2 = DllStructCreate('byte[4]')

DllStructSetData($tStruct1, 1, 0x11223344)

_WinAPI_MoveMemory(DllStructGetPtr($tStruct2), DllStructGetPtr($tStruct1), 4)

ConsoleWrite('0x' & Hex(DllStructGetData($tStruct1, 1)) & @CR)
ConsoleWrite(DllStructGetData($tStruct2, 1) & @CR)
