#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tStruct = DllStructCreate('byte[4096]')
Global $pStruct = DllStructGetPtr($tStruct)

ConsoleWrite(Hex(_WinAPI_ComputeCrc32($pStruct, 4096)) & @CR)

_WinAPI_FillMemory($pStruct, 4096, Random(0, 255, 1))

ConsoleWrite(Hex(_WinAPI_ComputeCrc32($pStruct, 4096)) & @CR)

_WinAPI_ZeroMemory($pStruct, 4096)

ConsoleWrite(Hex(_WinAPI_ComputeCrc32($pStruct, 4096)) & @CR)
