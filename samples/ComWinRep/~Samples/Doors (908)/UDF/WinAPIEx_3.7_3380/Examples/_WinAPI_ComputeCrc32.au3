#Include <WinAPIEx.au3>

Opt('MustDeclareVars', 1)

Global $tData = DllStructCreate('byte[4096]')
Global $pData = DllStructGetPtr($tData)

ConsoleWrite(Hex(_WinAPI_ComputeCrc32($pData, 4096)) & @CR)

_WinAPI_FillMemory($pData, 4096, Random(0, 255, 1))

ConsoleWrite(Hex(_WinAPI_ComputeCrc32($pData, 4096)) & @CR)

_WinAPI_ZeroMemory($pData, 4096)

ConsoleWrite(Hex(_WinAPI_ComputeCrc32($pData, 4096)) & @CR)
